
import { Router } from "express";
import authRoutes from "../modules/auth/auth.routes";
import testRoutes from "../routes/test-route";

const router = Router();

router.use("/auth", authRoutes);
router.use("/test", testRoutes);


export default router;