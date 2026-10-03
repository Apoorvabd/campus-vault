import { Request, Response } from "express";
import { asyncHandler, sendResponse } from "../../utils";
import {
  createCommentService,
  createPostService,
  deleteCommentService,
  deletePostService,
  getPostService,
  likePostService,
  listCommentsService,
  listPostsService,
  unlikePostService,
  updateCommentService,
  updatePostService,
} from "./posts.service";
import type { ListCommentsQuery, ListPostsQuery } from "./post.validation";

export const createPost = asyncHandler(async (req: Request, res: Response) => {
  const post = await createPostService(
    req.body,
    req.file,
    req.user!.id,
    req.user!.canPost
  );
  res.status(201).json(
    sendResponse(res, {
      statusCode: 201,
      message: "Post created successfully.",
      data: { post },
    })
  );
});

export const listPosts = asyncHandler(async (req: Request, res: Response) => {
  const { authorId, courseId, search, cursor, limit } =
    req.validatedQuery as ListPostsQuery;
  const result = await listPostsService({
    authorId,
    courseId,
    search,
    cursor,
    limit,
    userId: req.user?.id,
  });
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Posts fetched successfully.",
      data: { posts: result.posts },
      meta: result.meta,
    })
  );
});

export const getPost = asyncHandler(async (req: Request, res: Response) => {
  const post = await getPostService(req.params.id as string, req.user?.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Post fetched successfully.",
      data: { post },
    })
  );
});

export const updatePost = asyncHandler(async (req: Request, res: Response) => {
  const post = await updatePostService(
    req.params.id as string,
    req.body,
    req.file,
    req.user!.id
  );
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Post updated successfully.",
      data: { post },
    })
  );
});

export const deletePost = asyncHandler(async (req: Request, res: Response) => {
  await deletePostService(req.params.id as string, req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Post deleted successfully.",
    })
  );
});

export const listComments = asyncHandler(async (req: Request, res: Response) => {
  const { cursor, limit } = req.validatedQuery as ListCommentsQuery;
  const result = await listCommentsService(
    req.params.id as string,
    cursor,
    limit,
    req.user?.id
  );
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Comments fetched successfully.",
      data: { comments: result.comments },
      meta: result.meta,
    })
  );
});

export const createComment = asyncHandler(async (req: Request, res: Response) => {
  const comment = await createCommentService(
    req.params.id as string,
    req.body.content,
    req.user!.id
  );
  res.status(201).json(
    sendResponse(res, {
      statusCode: 201,
      message: "Comment added successfully.",
      data: { comment },
    })
  );
});

export const updateComment = asyncHandler(async (req: Request, res: Response) => {
  const comment = await updateCommentService(
    req.params.id as string,
    req.params.commentId as string,
    req.body.content,
    req.user!.id
  );
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Comment updated successfully.",
      data: { comment },
    })
  );
});

export const deleteComment = asyncHandler(async (req: Request, res: Response) => {
  await deleteCommentService(
    req.params.id as string,
    req.params.commentId as string,
    req.user!.id
  );
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Comment deleted successfully.",
    })
  );
});

export const likePost = asyncHandler(async (req: Request, res: Response) => {
  const result = await likePostService(req.params.id as string, req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Post liked successfully.",
      data: result,
    })
  );
});

export const unlikePost = asyncHandler(async (req: Request, res: Response) => {
  const result = await unlikePostService(req.params.id as string, req.user!.id);
  res.status(200).json(
    sendResponse(res, {
      statusCode: 200,
      message: "Post unliked successfully.",
      data: result,
    })
  );
});
