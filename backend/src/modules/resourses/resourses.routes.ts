import { Router } from "express";
import { authenticate, authorize, validate } from "../../middleware";
import { upload } from "../../middleware/upload.middleware";
import { createResourceSchema, rejectResourceSchema } from "./resourses.validation";
import {
  createResource,
  listResources,
  getResource,
  approveResource,
  rejectResource,
} from "./resourses.controller";

const router = Router();

// multer pehle chalta hai — multipart body ke text fields tabhi req.body me aate hain,
// isliye validate uske BAAD lagaya hai
router.post(
  "/",
  authenticate,
  upload.single("file"),
  validate({ body: createResourceSchema }),
  createResource
);

router.get("/", listResources);
router.get("/:id", getResource);

router.patch(
  "/:id/approve",
  authenticate,
  authorize("SUPER_ADMIN", "UNIVERSITY_ADMIN"),
  approveResource
);

router.patch(
  "/:id/reject",
  authenticate,
  authorize("SUPER_ADMIN", "UNIVERSITY_ADMIN"),
  validate({ body: rejectResourceSchema }),
  rejectResource
);

export default router;
