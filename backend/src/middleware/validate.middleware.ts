// src/middleware/validate.middleware.ts

import { NextFunction, Request, Response } from "express";
import { ZodTypeAny } from "zod";
import { AppError } from "../utils/appError";

interface ValidateSchemas {
  body?: ZodTypeAny;
  params?: ZodTypeAny;
  query?: ZodTypeAny;
}

export const validate = (schemas: ValidateSchemas) => {
  return (req: Request, _res: Response, next: NextFunction) => {
    const errors: string[] = [];

    // 1. Body check
    if (schemas.body) {
      const result = schemas.body.safeParse(req.body);
      if (!result.success) {
        result.error.issues.forEach((issue) => {
          errors.push(`${issue.path.join(".")}: ${issue.message}`);
        });
      } else {
        req.body = result.data; // parsed/transformed value use karo
      }
    }

    // 2. Params check
    if (schemas.params) {
      const result = schemas.params.safeParse(req.params);
      if (!result.success) {
        result.error.issues.forEach((issue) => {
          errors.push(`${issue.path.join(".")}: ${issue.message}`);
        });
      } else {
        req.params = result.data as any;
      }
    }

    // 3. Query check
    if (schemas.query) {
      const result = schemas.query.safeParse(req.query);
      if (!result.success) {
        result.error.issues.forEach((issue) => {
          errors.push(`${issue.path.join(".")}: ${issue.message}`);
        });
      } else {
        // Express 5 gotcha — agar `req.query = result.data` error de
        // ("Cannot set property query"), to iski jagah ye line use karna:
        // (req as any).validatedQuery = result.data;
        req.query = result.data as any;
      }
    }

    // 4. Agar kahin bhi error mila, request yahi rok do
    if (errors.length > 0) {
      return next(new AppError(errors.join("; "), 400));
    }

    next();
  };
};