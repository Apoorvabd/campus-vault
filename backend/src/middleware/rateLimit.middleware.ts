import { Request } from "express";
import rateLimit, { ipKeyGenerator } from "express-rate-limit";
import { AppError } from "../utils/appError";

const MINUTE = 60 * 1000;

const createLimiter = (
  windowMs: number,
  limit: number,
  keyGenerator?: (req: Request) => string
) =>
  rateLimit({
    windowMs,
    limit,
    standardHeaders: "draft-7",
    legacyHeaders: false,
    ...(keyGenerator && { keyGenerator }),
    // Same JSON shape as every other error (see globalErrorHandler)
    handler: (_req, _res, next) =>
      next(new AppError("Too many attempts. Please try again in a few minutes.", 429)),
  });

// Keyed by IP + email so one campus Wi-Fi does not lock out everyone together
const ipAndEmail = (req: Request) => {
  const email = String(req.body?.email ?? "").toLowerCase();
  return `${ipKeyGenerator(req.ip ?? "")}:${email}`;
};

export const loginLimiter = createLimiter(15 * MINUTE, 10, ipAndEmail);

export const registerLimiter = createLimiter(60 * MINUTE, 5);

export const refreshTokenLimiter = createLimiter(15 * MINUTE, 30);

// Google verifies the token itself, so this only guards the endpoint from
// floods. It is per IP, hence generous (a campus shares one IP).
export const googleAuthLimiter = createLimiter(15 * MINUTE, 60);

// Every send costs an email (Resend has a daily quota), so there is also a
// per-IP cap on top of the per-email one
export const emailCodeSendLimiter = createLimiter(60 * MINUTE, 5, ipAndEmail);

export const emailCodeSendIpLimiter = createLimiter(60 * MINUTE, 20);

export const emailCodeVerifyLimiter = createLimiter(15 * MINUTE, 10, ipAndEmail);
