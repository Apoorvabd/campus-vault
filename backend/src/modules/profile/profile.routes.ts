import { Router } from "express";
import { authenticate, validate } from "../../middleware";
import { upload } from "../../middleware/upload.middleware";
import {
  getMyProfile,
  getPublicProfile,
  removeMyAvatar,
  updateMyAvatar,
  updateMyProfile,
} from "./profile.controller";
import {
  updateProfileSchema,
  usernameParamsSchema,
} from "./profile.validation";

const router = Router();

router.get("/me", authenticate, getMyProfile);
router.patch(
  "/me",
  authenticate,
  validate({ body: updateProfileSchema }),
  updateMyProfile
);
router.put(
  "/me/avatar",
  authenticate,
  upload.single("avatar"),
  updateMyAvatar
);
router.delete("/me/avatar", authenticate, removeMyAvatar);
router.get(
  "/:username",
  validate({ params: usernameParamsSchema }),
  getPublicProfile
);

export default router;
