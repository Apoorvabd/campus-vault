
import { Router } from "express";
import authRoutes from "../modules/auth/auth.routes";
import universityRoutes from "../modules/university/university.routes";
import collegeRoutes from "../modules/college/college.routes";
import courseRoutes from "../modules/course/course.routes";
import subjectsRoutes from "../modules/subjects/subjects.routes";
import resourceRoutes from "../modules/resourses/resourses.routes";
import testRoutes from "../routes/test-route";

const router = Router();

router.use("/auth", authRoutes);
router.use("/universities", universityRoutes);
router.use("/colleges", collegeRoutes);
router.use("/courses", courseRoutes);
router.use("/subjects", subjectsRoutes);
router.use("/resources", resourceRoutes);
router.use("/test", testRoutes);

export default router;