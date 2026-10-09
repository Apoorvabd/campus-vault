import { NextFunction, Request, Response } from "express";

import prisma from "../config/prisma";
import { verifyAccessToken } from "../config/jwt";
import { AppError } from "../utils/appError";
import { getCachedAuthUser, setCachedAuthUser } from "../utils/authCache";

export const authenticate = async (
  req: Request,
  _res: Response,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new AppError("Authentication token is required.", 401));
  }

  const token = authHeader.split(" ")[1];

  const payload = verifyAccessToken(token);

  // Fast path: recently verified user, no database round trip
  const cached = getCachedAuthUser(payload.userId);
  if (cached) {
    req.user = cached;
    return next();
  }

  const user = await prisma.user.findUnique({
    where: {
      id: payload.userId,
    },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      email: true,
      username: true,
      role: true,
      canPost: true,
      isActive: true,
      isVerified: true,
      universityId: true,
      collegeId: true,
      courseId: true,
      currentSemester: true,
    },
  });

  if (!user) {
    return next(new AppError("User not found.", 404));
  }

  if (!user.isActive) {
    return next(new AppError("Your account has been deactivated.", 403));
  }

  // Only active users are cached, so a deactivated account is rejected at most
  // 30 seconds late.
  setCachedAuthUser(user.id, user);

  req.user = user;

  next();
};

/**
 * Like `authenticate`, but anonymous requests are allowed through.
 * - No Authorization header: continue without req.user.
 * - Header present: it must be valid (an expired token still gets a 401 so the
 *   client refreshes it instead of silently being treated as logged out).
 */
export const optionalAuthenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  if (!req.headers.authorization) {
    return next();
  }
  return authenticate(req, res, next);
};
