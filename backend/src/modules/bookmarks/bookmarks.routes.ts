import { Router } from "express";
import { authenticate, validate } from "../../middleware";
import {
  listBookmarksQuerySchema,
  postIdParamsSchema,
  resourceIdParamsSchema,
} from "./bookmarks.validation";
import {
  bookmarkPost,
  bookmarkResource,
  listBookmarkedPosts,
  listBookmarkedResources,
  unbookmarkPost,
  unbookmarkResource,
} from "./bookmarks.controller";

const router = Router();

// Every bookmark route needs a logged-in user
router.use(authenticate);

router.get("/posts", validate({ query: listBookmarksQuerySchema }), listBookmarkedPosts);
router.get(
  "/resources",
  validate({ query: listBookmarksQuerySchema }),
  listBookmarkedResources
);

router.post("/posts/:postId", validate({ params: postIdParamsSchema }), bookmarkPost);
router.delete("/posts/:postId", validate({ params: postIdParamsSchema }), unbookmarkPost);

router.post(
  "/resources/:resourceId",
  validate({ params: resourceIdParamsSchema }),
  bookmarkResource
);
router.delete(
  "/resources/:resourceId",
  validate({ params: resourceIdParamsSchema }),
  unbookmarkResource
);

export default router;
