import { z } from "zod";

export const postIdParamsSchema = z.object({
  postId: z.string().min(1, "Post ID is required"),
});

export const resourceIdParamsSchema = z.object({
  resourceId: z.string().min(1, "Resource ID is required"),
});

export const listBookmarksQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

export type ListBookmarksQuery = z.infer<typeof listBookmarksQuerySchema>;
