import { AppError } from "../../utils";
import { uploadAndSave } from "../upload/upload.service";
import {
  countPostLikes,
  createComment,
  createPost,
  deleteComment,
  deletePost,
  findCommentById,
  findCommentsByPostId,
  findPostById,
  findPosts,
  likePost,
  unlikePost,
  updateComment,
  updatePost,
} from "./posts.repository";

const presentPost = <T extends { likes?: { id: string }[] }>(post: T) => {
  const { likes, ...postData } = post;
  return {
    ...postData,
    ...(likes ? { isLiked: likes.length > 0 } : {}),
  };
};

const requireVisiblePost = async (postId: string, userId?: string) => {
  const post = await findPostById(postId, userId);
  if (!post || (!post.isPublished && post.authorId !== userId)) {
    throw new AppError("Post not found.", 404);
  }
  return post;
};

const requireImage = (file: Express.Multer.File) => {
  if (!file.mimetype.startsWith("image/")) {
    throw new AppError("Post cover must be an image.", 400);
  }
};

export const createPostService = async (
  input: { title: string; content: string },
  file: Express.Multer.File | undefined,
  authorId: string,
  canPost: boolean
) => {
  if (!canPost) {
    throw new AppError("You do not have permission to create posts.", 403);
  }

  let coverImageId: string | undefined;
  if (file) {
    requireImage(file);
    const upload = await uploadAndSave(file, "post-covers", authorId);
    coverImageId = upload.id;
  }

  const post = await createPost({
    title: input.title,
    content: input.content,
    authorId,
    isPublished: true,
    ...(coverImageId ? { coverImageId } : {}),
  });
  return presentPost(post);
};

export const listPostsService = async (filters: {
  authorId?: string;
  courseId?: string;
  search?: string;
  cursor?: string;
  limit: number;
  userId?: string;
}) => {
  const result = await findPosts(filters);
  return { ...result, posts: result.posts.map(presentPost) };
};

export const getPostService = async (postId: string, userId?: string) => {
  return presentPost(await requireVisiblePost(postId, userId));
};

export const updatePostService = async (
  postId: string,
  input: { title?: string; content?: string },
  file: Express.Multer.File | undefined,
  userId: string
) => {
  const post = await findPostById(postId);
  if (!post) {
    throw new AppError("Post not found.", 404);
  }
  if (post.authorId !== userId) {
    throw new AppError("You can only edit your own posts.", 403);
  }
  if (!input.title && !input.content && !file) {
    throw new AppError("Provide post fields or a cover image to update.", 400);
  }

  let coverImageId: string | undefined;
  if (file) {
    requireImage(file);
    const upload = await uploadAndSave(file, "post-covers", userId);
    coverImageId = upload.id;
  }

  const updated = await updatePost(postId, {
    ...(input.title !== undefined ? { title: input.title } : {}),
    ...(input.content !== undefined ? { content: input.content } : {}),
    ...(coverImageId ? { coverImage: { connect: { id: coverImageId } } } : {}),
  });
  const updatedPost = await findPostById(updated.id, userId);
  if (!updatedPost) {
    throw new AppError("Post not found after update.", 404);
  }
  return presentPost(updatedPost);
};

export const deletePostService = async (postId: string, userId: string) => {
  const post = await findPostById(postId);
  if (!post) {
    throw new AppError("Post not found.", 404);
  }
  if (post.authorId !== userId) {
    throw new AppError("You can only delete your own posts.", 403);
  }
  await deletePost(postId);
};

export const listCommentsService = async (
  postId: string,
  cursor: string | undefined,
  limit: number,
  userId?: string
) => {
  await requireVisiblePost(postId, userId);
  return findCommentsByPostId(postId, cursor, limit);
};

export const createCommentService = async (
  postId: string,
  content: string,
  userId: string
) => {
  await requireVisiblePost(postId, userId);
  return createComment({ postId, content, userId });
};

const requireOwnedComment = async (
  postId: string,
  commentId: string,
  userId: string
) => {
  const comment = await findCommentById(commentId);
  if (!comment || comment.postId !== postId) {
    throw new AppError("Comment not found.", 404);
  }
  if (comment.userId !== userId) {
    throw new AppError("You can only modify your own comments.", 403);
  }
};

export const updateCommentService = async (
  postId: string,
  commentId: string,
  content: string,
  userId: string
) => {
  await requireOwnedComment(postId, commentId, userId);
  return updateComment(commentId, content);
};

export const deleteCommentService = async (
  postId: string,
  commentId: string,
  userId: string
) => {
  await requireOwnedComment(postId, commentId, userId);
  await deleteComment(commentId);
};

export const likePostService = async (postId: string, userId: string) => {
  await requireVisiblePost(postId, userId);
  await likePost(userId, postId);
  return { liked: true, likesCount: await countPostLikes(postId) };
};

export const unlikePostService = async (postId: string, userId: string) => {
  await requireVisiblePost(postId, userId);
  await unlikePost(userId, postId);
  return { liked: false, likesCount: await countPostLikes(postId) };
};
