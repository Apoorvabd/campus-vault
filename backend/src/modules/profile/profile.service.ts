import { AppError } from "../../utils";
import { Prisma } from "@prisma/client";
import { uploadAndSave } from "../upload/upload.service";
import {
  findCourseSemesterLimit,
  findPrivateProfileById,
  findPublicProfileByUsername,
  findUsernameOwner,
  getProfileStats,
  updateProfile,
} from "./profile.repository";

export const getMyProfileService = async (userId: string) => {
  const [profile, stats] = await Promise.all([
    findPrivateProfileById(userId),
    getProfileStats(userId),
  ]);
  if (!profile) {
    throw new AppError("Profile not found.", 404);
  }
  return { ...profile, stats };
};

export const getPublicProfileService = async (username: string) => {
  const profile = await findPublicProfileByUsername(username);
  if (!profile) {
    throw new AppError("Profile not found.", 404);
  }
  const stats = await getProfileStats(profile.id);
  return { ...profile, stats };
};

export const updateMyProfileService = async (
  userId: string,
  input: {
    firstName?: string;
    lastName?: string | null;
    username?: string;
    bio?: string | null;
    headline?: string | null;
    currentSemester?: number;
  }
) => {
  if (Object.keys(input).length === 0) {
    throw new AppError("At least one profile field is required.", 400);
  }

  const data = { ...input };
  if (data.username !== undefined) {
    data.username = data.username.trim().toLowerCase();
    const owner = await findUsernameOwner(data.username);
    if (owner && owner.id !== userId) {
      throw new AppError("This username is already taken.", 409);
    }
  }

  if (input.currentSemester !== undefined) {
    const currentProfile = await findPrivateProfileById(userId);
    if (!currentProfile) {
      throw new AppError("Profile not found.", 404);
    }
    const course = await findCourseSemesterLimit(currentProfile.course.id);
    if (!course || input.currentSemester > course.totalSemesters) {
      throw new AppError(
        `Semester must be between 1 and ${course?.totalSemesters ?? "the course limit"}.`,
        400
      );
    }
  }

  try {
    return await updateProfile(userId, data);
  } catch (error) {
    const isUsernameCollision =
      data.username !== undefined &&
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === "P2002" &&
      String(error.meta?.target).toLowerCase().includes("username");
    if (isUsernameCollision) {
      throw new AppError("This username is already taken.", 409);
    }
    throw error;
  }
};

export const updateMyAvatarService = async (
  userId: string,
  file: Express.Multer.File | undefined
) => {
  if (!file) {
    throw new AppError("Avatar image is required.", 400);
  }
  if (!file.mimetype.startsWith("image/")) {
    throw new AppError("Avatar must be an image.", 400);
  }

  const upload = await uploadAndSave(file, "profile-avatars", userId);
  return updateProfile(userId, {
    avatar: { connect: { id: upload.id } },
  });
};

export const removeMyAvatarService = async (userId: string) => {
  return updateProfile(userId, {
    avatar: { disconnect: true },
  });
};
