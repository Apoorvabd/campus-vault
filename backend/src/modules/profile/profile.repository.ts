import { Prisma, ResourceStatus } from "@prisma/client";
import prisma from "../../config/prisma";
import { invalidateAuthUser } from "../../utils/authCache";

const privateProfileSelect = {
  id: true,
  firstName: true,
  lastName: true,
  username: true,
  email: true,
  bio: true,
  headline: true,
  role: true,
  canPost: true,
  isVerified: true,
  currentSemester: true,
  subjectsSemester: true,
  subjectsConfirmedAt: true,
  createdAt: true,
  avatar: { select: { id: true, secureUrl: true } },
  university: { select: { id: true, name: true, shortName: true } },
  college: { select: { id: true, name: true, shortName: true } },
  course: {
    select: {
      id: true,
      name: true,
      shortName: true,
      totalSemesters: true,
    },
  },
} satisfies Prisma.UserSelect;

const publicProfileSelect = {
  id: true,
  firstName: true,
  lastName: true,
  username: true,
  bio: true,
  headline: true,
  currentSemester: true,
  createdAt: true,
  avatar: { select: { secureUrl: true } },
  university: { select: { id: true, name: true, shortName: true } },
  college: { select: { id: true, name: true, shortName: true } },
  course: { select: { id: true, name: true, shortName: true } },
} satisfies Prisma.UserSelect;

export const findPrivateProfileById = async (userId: string) => {
  return prisma.user.findUnique({
    relationLoadStrategy: "join",
    where: { id: userId },
    select: privateProfileSelect,
  });
};

export const findPublicProfileByUsername = async (username: string) => {
  return prisma.user.findUnique({
    relationLoadStrategy: "join",
    where: { username, isActive: true },
    select: publicProfileSelect,
  });
};

export const findUsernameOwner = async (username: string) => {
  return prisma.user.findUnique({
    where: { username },
    select: { id: true },
  });
};

export const getProfileStats = async (userId: string) => {
  const [posts, approvedResources, postLikes] = await Promise.all([
    prisma.post.count({ where: { authorId: userId, isPublished: true } }),
    prisma.resource.count({
      where: { uploadedById: userId, status: ResourceStatus.APPROVED },
    }),
    prisma.like.count({
      where: { post: { authorId: userId, isPublished: true } },
    }),
  ]);

  return { posts, approvedResources, postLikes };
};

export const updateProfile = async (
  userId: string,
  data: Prisma.UserUpdateInput
) => {
  const updated = await prisma.user.update({
    relationLoadStrategy: "join",
    where: { id: userId },
    data,
    select: privateProfileSelect,
  });
  // The login check caches user fields for a short time; drop the stale copy
  invalidateAuthUser(userId);
  return updated;
};

export const findCourseSemesterLimit = async (courseId: string) => {
  return prisma.course.findUnique({
    where: { id: courseId },
    select: { totalSemesters: true },
  });
};
