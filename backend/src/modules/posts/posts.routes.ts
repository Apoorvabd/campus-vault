import { Router } from "express";
import { authenticate, validate } from "../../middleware";
import { upload } from "../../middleware/upload.middleware";
import {
  commentParamsSchema,
  createCommentSchema,
  createPostSchema,
  listCommentsQuerySchema,
  listPostsQuerySchema,
  postIdParamsSchema,
  updateCommentSchema,
  updatePostSchema,
} from "./post.validation";
import {
  createComment,
  createPost,
  deleteComment,
  deletePost,
  getPost,
  likePost,
  listComments,
  listPosts,
  unlikePost,
  updateComment,
  updatePost,
} from "./posts.controller";

const router = Router();

router.get("/", validate({ query: listPostsQuerySchema }), listPosts);
router.get(
  "/:id",
  authenticate,
  validate({ params: postIdParamsSchema }),
  getPost
);

router.post(
  "/",
  authenticate,
  upload.single("coverImage"),
  validate({ body: createPostSchema }),
  createPost
);

router.patch(
  "/:id",
  authenticate,
  upload.single("coverImage"),
  validate({ params: postIdParamsSchema, body: updatePostSchema }),
  updatePost
);

router.delete(
  "/:id",
  authenticate,
  validate({ params: postIdParamsSchema }),
  deletePost
);

router.get(
  "/:id/comments",
  validate({ params: postIdParamsSchema, query: listCommentsQuerySchema }),
  listComments
);

router.post(
  "/:id/comments",
  authenticate,
  validate({ params: postIdParamsSchema, body: createCommentSchema }),
  createComment
);

router.patch(
  "/:id/comments/:commentId",
  authenticate,
  validate({ params: commentParamsSchema, body: updateCommentSchema }),
  updateComment
);

router.delete(
  "/:id/comments/:commentId",
  authenticate,
  validate({ params: commentParamsSchema }),
  deleteComment
);

router.post(
  "/:id/like",
  authenticate,
  validate({ params: postIdParamsSchema }),
  likePost
);
router.delete(
  "/:id/like",
  authenticate,
  validate({ params: postIdParamsSchema }),
  unlikePost
);

export default router;
