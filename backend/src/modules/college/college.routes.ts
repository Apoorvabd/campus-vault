import { Router } from "express";
import { getColleges } from "./college.controller";

const router = Router();

router.get("/", getColleges);

export default router;
