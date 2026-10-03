import { Prisma } from "@prisma/client";
import prisma from "../../config/prisma";

const postInclude = (userId?: string) => ({
  author: {
    select: {
      id: true,
      firstName: true,
      lastName: true,
      username: true,
      avatar: { select: { secureUrl: true } },
    },
  },
  coverImage: true,
  _count: { select: { comments: true, likes: true } },
  ...(userId
    ? { likes: { where: { userId }, select: { id: true } } }
    : {}),
});

export const createPost = async (data: Prisma.PostUncheckedCreateInput) => {
  return prisma.post.create({
    data,
    include: postInclude(data.authorId),
  });
};

export const findPostById = async (postId: string, userId?: string) => {
  return prisma.post.findUnique({
    where: { id: postId },
    include: postInclude(userId),
  });
};

export const findPosts = async (filters: {
  authorId?: string;
  courseId?: string;
  search?: string;
  cursor?: string;
  limit: number;
  userId?: string;
}) => {
  const { authorId, courseId, search, cursor, limit, userId } = filters;
  const where: Prisma.PostWhereInput = {
    isPublished: true,
    ...(authorId ? { authorId } : {}),
    ...(courseId ? { author: { courseId } } : {}),
    ...(search
      ? {
          OR: [
            { title: { contains: search, mode: "insensitive" } },
            { content: { contains: search, mode: "insensitive" } },
          ],
        }
      : {}),
  };

  const posts = await prisma.post.findMany({
    where,
    ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    take: limit + 1,
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    include: postInclude(userId),
  });
  const hasNextPage = posts.length > limit;
  const pagePosts = hasNextPage ? posts.slice(0, limit) : posts;
  const nextCursor = hasNextPage ? pagePosts[pagePosts.length - 1]?.id : null;

  return {
    posts: pagePosts,
    meta: {
      limit,
      hasNextPage,
      nextCursor,
    },
  };
};

export const updatePost = async (
  postId: string,
  data: Prisma.PostUpdateInput
) => {
  return prisma.post.update({
    where: { id: postId },
    data,
  });
};

export const deletePost = async (postId: string) => {
  return prisma.post.delete({ where: { id: postId } });
};

export const createComment = async (data: Prisma.CommentUncheckedCreateInput) => {
  return prisma.comment.create({
    data,
    include: {
      user: {
        select: { id: true, firstName: true, lastName: true, username: true },
      },
    },
  });
};

export const findCommentById = async (commentId: string) => {
  return prisma.comment.findUnique({ where: { id: commentId } });
};

export const findCommentsByPostId = async (
  postId: string,
  cursor: string | undefined,
  limit: number
) => {
  const where = { postId };
  const comments = await prisma.comment.findMany({
    where,
    ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    take: limit + 1,
    orderBy: [{ createdAt: "asc" }, { id: "asc" }],
    include: {
      user: {
        select: { id: true, firstName: true, lastName: true, username: true },
      },
    },
  });
  const hasNextPage = comments.length > limit;
  const pageComments = hasNextPage ? comments.slice(0, limit) : comments;
  const nextCursor = hasNextPage
    ? pageComments[pageComments.length - 1]?.id
    : null;

  return {
    comments: pageComments,
    meta: {
      limit,
      hasNextPage,
      nextCursor,
    },
  };
};

export const updateComment = async (commentId: string, content: string) => {
  return prisma.comment.update({
    where: { id: commentId },
    data: { content },
    include: {
      user: {
        select: { id: true, firstName: true, lastName: true, username: true },
      },
    },
  });
};

export const deleteComment = async (commentId: string) => {
  return prisma.comment.delete({ where: { id: commentId } });
};

export const likePost = async (userId: string, postId: string) => {
  return prisma.like.upsert({
    where: { userId_postId: { userId, postId } },
    create: { userId, postId },
    update: {},
  });
};

export const unlikePost = async (userId: string, postId: string) => {
  return prisma.like.deleteMany({ where: { userId, postId } });
};

export const countPostLikes = async (postId: string) => {
  return prisma.like.count({ where: { postId } });
};
