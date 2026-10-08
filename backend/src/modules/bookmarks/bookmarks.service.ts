import { AppError } from "../../utils";
import { presentPost } from "../posts/posts.service";
import {
  addPostBookmark,
  addResourceBookmark,
  countPostBookmarks,
  countResourceBookmarks,
  findBookmarkedPosts,
  findBookmarkedResources,
  postExists,
  removePostBookmark,
  removeResourceBookmark,
  resourceExists,
} from "./bookmarks.repository";

const requirePost = async (postId: string, userId: string) => {
  if (!(await postExists(postId, userId))) {
    throw new AppError("Post not found.", 404);
  }
};

const requireResource = async (resourceId: string, userId: string) => {
  if (!(await resourceExists(resourceId, userId))) {
    throw new AppError("Resource not found.", 404);
  }
};

export const bookmarkPostService = async (userId: string, postId: string) => {
  await requirePost(postId, userId);
  await addPostBookmark(userId, postId);
  return { bookmarked: true, bookmarksCount: await countPostBookmarks(postId) };
};

export const unbookmarkPostService = async (userId: string, postId: string) => {
  await requirePost(postId, userId);
  await removePostBookmark(userId, postId);
  return { bookmarked: false, bookmarksCount: await countPostBookmarks(postId) };
};

export const bookmarkResourceService = async (
  userId: string,
  resourceId: string
) => {
  await requireResource(resourceId, userId);
  await addResourceBookmark(userId, resourceId);
  return {
    bookmarked: true,
    bookmarksCount: await countResourceBookmarks(resourceId),
  };
};

export const unbookmarkResourceService = async (
  userId: string,
  resourceId: string
) => {
  await requireResource(resourceId, userId);
  await removeResourceBookmark(userId, resourceId);
  return {
    bookmarked: false,
    bookmarksCount: await countResourceBookmarks(resourceId),
  };
};

const pageMeta = (page: number, limit: number, total: number) => ({
  page,
  limit,
  total,
  totalPages: Math.ceil(total / limit),
});

export const listBookmarkedPostsService = async (
  userId: string,
  page: number,
  limit: number
) => {
  const { posts, total } = await findBookmarkedPosts(userId, page, limit);
  return { posts: posts.map(presentPost), meta: pageMeta(page, limit, total) };
};

export const listBookmarkedResourcesService = async (
  userId: string,
  page: number,
  limit: number
) => {
  const { resources, total } = await findBookmarkedResources(userId, page, limit);
  // Everything in this list is bookmarked by definition
  return {
    resources: resources.map((resource) => ({ ...resource, isBookmarked: true })),
    meta: pageMeta(page, limit, total),
  };
};
