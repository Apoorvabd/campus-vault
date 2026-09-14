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


export const createUser = async (
  userData: Omit<RegisterInput, "password"> & { passwordHash: string }
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
      isActive: true,
      isVerified: true,
      universityId: true,
      collegeId: true,
      courseId: true,
      currentSemester: true,
    },
  });
};