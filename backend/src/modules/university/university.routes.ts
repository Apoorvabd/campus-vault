import { Router } from "express";
import { getUniversities } from "./university.controller";

const router = Router();

router.get("/", getUniversities);

export default router;
