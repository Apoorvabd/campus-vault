import { Router, Request, Response, NextFunction } from "express";
import { authenticate } from "../../middleware/auth.middleware";
import { authorize } from "../../middleware/role.middleware";
import { validate } from "../../middleware/validate.middleware";
import { AppError } from "../../utils/appError";
import {
  getAppUpdate,
  postAppUpdate,
  getAllAppUpdates,
} from "./app_update.controller";
import {
  createAppUpdateSchema,
  getAppUpdateQuerySchema,
} from "./app_update.validation";

export const adminOrCiAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const ciSecret =
    process.env.BACKEND_APP_VERSION_SECRET ||
    process.env.APP_UPDATE_SECRET ||
    process.env.ADMIN_API_KEY;

  const apiKeyHeader =
    (req.headers["x-app-version-secret"] as string) ||
    (req.headers["x-api-key"] as string) ||
    (req.headers["x-admin-key"] as string);

  const authHeader = req.headers.authorization;
  const bearerToken = authHeader?.startsWith("Bearer ")
    ? authHeader.split(" ")[1]
    : undefined;

  // 1. CI / GitHub Actions check via BACKEND_APP_VERSION_SECRET
  if (ciSecret && (apiKeyHeader === ciSecret || bearerToken === ciSecret)) {
    return next();
  }

  // 2. Fallback to standard Admin JWT auth
  if (bearerToken) {
    return authenticate(req, res, () => {
      authorize("SUPER_ADMIN", "UNIVERSITY_ADMIN")(req, res, next);
    });
  }

  return next(
    new AppError(
      "Unauthorized: Admin token or valid CI secret key is required.",
      401
    )
  );
};

const router = Router();

// Public route for mobile clients:
// Supports GET /api/app/update or /api/v1/app/update or /app/update
router.get(
  "/update",
  validate({ query: getAppUpdateQuerySchema }),
  getAppUpdate
);
router.get(
  "/app/update",
  validate({ query: getAppUpdateQuerySchema }),
  getAppUpdate
);

// Admin / CI route:
// Supports POST /api/admin/app-update or /api/v1/admin/app-update or /admin/app-update
router.post(
  "/admin/app-update",
  adminOrCiAuth,
  validate({ body: createAppUpdateSchema }),
  postAppUpdate
);
router.post(
  "/app-update",
  adminOrCiAuth,
  validate({ body: createAppUpdateSchema }),
  postAppUpdate
);

// Admin route to list updates:
router.get("/admin/app-updates", adminOrCiAuth, getAllAppUpdates);
router.get("/app-updates", adminOrCiAuth, getAllAppUpdates);

export default router;
