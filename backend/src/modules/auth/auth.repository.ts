//findUserByEmail, findUserByUsername, createUser, findUserById

// src/modules/auth/auth.repository.ts

import prisma from "../../config/prisma";
import { RegisterInput } from "./auth.types";


export const findUserById = async (id: string) => {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      firstName: true,
      lastName: true,
      username: true,
      email: true,
      role: true,
      canPost: true,
      isActive: true,
      isVerified: true,
      universityId: true,
      collegeId: true,
      courseId: true,
      currentSemester: true,
      // passwordHash jaan-boojh kar nahi liya —
      // ye function "current user" jaisi jagah use hoga (Day 5 ka getMe),
      // wahan password hash kabhi bahar nahi jaana chahiye
    },
  });
};

export const findUserForRefresh = async (id: string) => {
  return prisma.user.findUnique({
    where: { id },
    select: { id: true, email: true, role: true, isActive: true, tokenVersion: true },
  });
};

// Invalidates every refresh token issued so far for this user
export const bumpTokenVersion = async (id: string) => {
  return prisma.user.update({
    where: { id },
    data: { tokenVersion: { increment: 1 } },
    select: { id: true },
  });
};

export const findUserByEmail = async (email: string) => {
  return prisma.user.findUnique({
    where: { email },
  });
};

export const findUserByUsername = async (username: string) => {
  return prisma.user.findUnique({
    where: { username },
  });
};


export const findCollegeAndCourse = async (collegeId: string, courseId: string) => {
  return Promise.all([
    prisma.college.findUnique({ where: { id: collegeId }, select: { universityId: true } }),
    prisma.course.findUnique({ where: { id: courseId }, select: { universityId: true } }),
  ]);
};

// Case-insensitive, because accounts keep the email exactly as it was typed
export const findUserByEmailInsensitive = async (email: string) => {
  return prisma.user.findFirst({
    where: { email: { equals: email, mode: "insensitive" } },
  });
};

export const isEmailRegistered = async (email: string) => {
  return (await findUserByEmailInsensitive(email)) !== null;
};

export const findUserByGoogleId = async (googleId: string) => {
  return prisma.user.findUnique({ where: { googleId } });
};

/**
 * Attaches a Google account to an existing user. For an account whose email was
 * never verified, the password is dropped and its sessions are ended too: the
 * person who set that password may not be the real owner of the email.
 */
export const linkGoogleAccount = async (
  id: string,
  googleId: string,
  isUnverified: boolean
) => {
  return prisma.user.update({
    where: { id },
    data: {
      googleId,
      isVerified: true,
      ...(isUnverified && { passwordHash: null, tokenVersion: { increment: 1 } }),
    },
  });
};

export const createUser = async (
  userData: Omit<RegisterInput, "password" | "username" | "emailProof"> & {
    username: string;
    passwordHash: string | null;
    googleId?: string;
    canPost: boolean;
    isVerified: boolean;
  }
) => {
  return prisma.user.create({
    data: userData,
    select: {
      id: true,
      firstName: true,
      lastName: true,
      username: true,
      email: true,
      role: true,
      canPost: true,
      isActive: true,
      isVerified: true,
      universityId: true,
      collegeId: true,
      courseId: true,
      currentSemester: true,
    },
  });
};