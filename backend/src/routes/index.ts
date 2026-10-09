
import { Router } from "express";
import authRoutes from "../modules/auth/auth.routes";
import universityRoutes from "../modules/university/university.routes";
import collegeRoutes from "../modules/college/college.routes";
import courseRoutes from "../modules/course/course.routes";
import subjectsRoutes from "../modules/subjects/subjects.routes";
import resourceRoutes from "../modules/resourses/resourses.routes";
import postsRoutes from "../modules/posts/posts.routes";
import profileRoutes from "../modules/profile/profile.routes";
import bookmarksRoutes from "../modules/bookmarks/bookmarks.routes";
import testRoutes from "../routes/test-route";

const router = Router();

// Cheap "are you awake?" check: no auth, no database. The mobile app calls it
// as soon as the welcome screen shows, so a sleeping host (Render free tier)
// is already starting up by the time the user logs in or registers.
router.get("/health", (_req, res) => {
  res.status(200).json({ success: true, status: "ok" });
});

router.use("/auth", authRoutes);
router.use("/universities", universityRoutes);
router.use("/colleges", collegeRoutes);
router.use("/courses", courseRoutes);
router.use("/subjects", subjectsRoutes);
router.use("/resources", resourceRoutes);
router.use("/posts", postsRoutes);
router.use("/profile", profileRoutes);
router.use("/bookmarks", bookmarksRoutes);
router.use("/test", testRoutes);

export default router;