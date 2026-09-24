import { Router } from "express";
import { getSubjects } from "./subjects.controller";

const router = Router();

router.get("/", getSubjects);

export default router;
