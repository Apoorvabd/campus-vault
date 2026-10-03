import { NextFunction, Request, Response } from "express";

import prisma from "../config/prisma";
import { verifyAccessToken } from "../config/jwt";
import { AppError } from "../utils/appError";

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

  req.user = user;

  next();
};