import { Router } from "express";
import { authenticate, validate } from "../../middleware";
import {
  getMySubjects,
  getSubjects,
  getSubjectsForm,
  saveMySubjects,
  searchMySubjects,
} from "./subjects.controller";
import { saveMySubjectsSchema } from "./subjects.validation";

const router = Router();

router.get("/", getSubjects);
router.get("/mine", authenticate, getMySubjects);
router.get("/search", authenticate, searchMySubjects);
router.get("/form", authenticate, getSubjectsForm);
router.put(
  "/mine",
  authenticate,
  validate({ body: saveMySubjectsSchema }),
  saveMySubjects
);

export default router;
