import { z } from "zod";

const paginationSchema = {
  limit: z.coerce.number().int().min(1).max(100).default(20),
  cursor: z.string().min(1).optional(),
};

export const postIdParamsSchema = z.object({
  id: z.string().min(1, "Post ID is required"),
});

export const commentParamsSchema = z.object({
  id: z.string().min(1, "Post ID is required"),
  commentId: z.string().min(1, "Comment ID is required"),
});

export const listPostsQuerySchema = z.object({
  ...paginationSchema,
  authorId: z.string().min(1).optional(),
  courseId: z.string().min(1).optional(),
  search: z.string().trim().max(100).optional(),
});

export const listCommentsQuerySchema = z.object({
  ...paginationSchema,
});

export const createPostSchema = z.object({
  title: z.string().trim().min(1, "Title is required").max(200),
  content: z.string().trim().min(1, "Content is required").max(20000),
});

export const updatePostSchema = z.object({
  title: z.string().trim().min(1, "Title cannot be empty").max(200).optional(),
  content: z
    .string()
    .trim()
    .min(1, "Content cannot be empty")
    .max(20000)
    .optional(),
});

export const createCommentSchema = z.object({
  content: z.string().trim().min(1, "Comment cannot be empty").max(5000),
});

export const updateCommentSchema = createCommentSchema;

export type ListPostsQuery = z.infer<typeof listPostsQuerySchema>;
export type ListCommentsQuery = z.infer<typeof listCommentsQuerySchema>;
