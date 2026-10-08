import prisma from "../../config/prisma";
import { postInclude } from "../posts/posts.repository";

export const postExists = async (postId: string, userId: string) => {
  const post = await prisma.post.findUnique({
    where: { id: postId },
    select: { isPublished: true, authorId: true },
  });
  return !!post && (post.isPublished || post.authorId === userId);
};

export const resourceExists = async (resourceId: string, userId: string) => {
  const resource = await prisma.resource.findUnique({
    where: { id: resourceId },
    select: { status: true, uploadedById: true },
  });
  return (
    !!resource && (resource.status === "APPROVED" || resource.uploadedById === userId)
  );
};

export const addPostBookmark = (userId: string, postId: string) =>
  prisma.bookmark.upsert({
    where: { userId_postId: { userId, postId } },
    create: { userId, postId },
    update: {},
  });

export const removePostBookmark = (userId: string, postId: string) =>
  prisma.bookmark.deleteMany({ where: { userId, postId } });

export const countPostBookmarks = (postId: string) =>
  prisma.bookmark.count({ where: { postId } });

export const addResourceBookmark = (userId: string, resourceId: string) =>
  prisma.bookmark.upsert({
    where: { userId_resourceId: { userId, resourceId } },
    create: { userId, resourceId },
    update: {},
  });

export const removeResourceBookmark = (userId: string, resourceId: string) =>
  prisma.bookmark.deleteMany({ where: { userId, resourceId } });

export const countResourceBookmarks = (resourceId: string) =>
  prisma.bookmark.count({ where: { resourceId } });

export const findBookmarkedPosts = async (
  userId: string,
  page: number,
  limit: number
) => {
  const where = { userId, post: { is: { isPublished: true } } };
  const [rows, total] = await Promise.all([
    prisma.bookmark.findMany({
      relationLoadStrategy: "join",
      where,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
      include: { post: { include: postInclude(userId) } },
    }),
    prisma.bookmark.count({ where }),
  ]);
  return { posts: rows.map((row) => row.post!), total };
};

export const findBookmarkedResources = async (
  userId: string,
  page: number,
  limit: number
) => {
  const where = { userId, resource: { is: { status: "APPROVED" as const } } };
  const [rows, total] = await Promise.all([
    prisma.bookmark.findMany({
      relationLoadStrategy: "join",
      where,
      orderBy: { createdAt: "desc" },
      skip: (page - 1) * limit,
      take: limit,
      include: {
        resource: {
          include: {
            upload: true,
            subject: {
              select: {
                id: true,
                name: true,
                code: true,
                semester: true,
                type: true,
                courseId: true,
              },
            },
            uploadedBy: {
              select: { id: true, firstName: true, lastName: true, username: true },
            },
          },
        },
      },
    }),
    prisma.bookmark.count({ where }),
  ]);
  return { resources: rows.map((row) => row.resource!), total };
};
