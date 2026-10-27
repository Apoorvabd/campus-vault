import { z } from "zod";

// What every signup collects about the student, with a password or with Google
const academicFields = {
  universityId: z.string().min(1, "University is required"),
  collegeId: z.string().min(1, "College is required"),
  courseId: z.string().min(1, "Course is required"),
  currentSemester: z.number().int().min(1, "Current semester is required"),
};

export const registerSchema = z.object({
  firstName: z.string().trim().min(3, "First name must be at least 3 characters"),
  lastName: z.string().trim().min(1, "Last name cannot be empty").optional(),
  username: z
    .string()
    .trim()
    .min(3, "Username must be at least 3 characters")
    .max(30, "Username must be at most 30 characters")
    .regex(/^[a-zA-Z0-9_]+$/, "Username can contain letters, numbers, and underscores")
    .optional(),
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters long"),
  ...academicFields,
  // Handed out by POST /auth/email-verification/verify (32 random bytes, hex)
  emailProof: z.string().length(64, "Verify your email first"),
});

export const googleLoginSchema = z.object({
  idToken: z.string().min(1, "Google token is required"),
});

export const googleRegisterSchema = z.object({
  idToken: z.string().min(1, "Google token is required"),
  ...academicFields,
});

export const sendEmailCodeSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
});

export const resetPasswordSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  // Handed out by POST /auth/forgot-password/verify (32 random bytes, hex)
  resetProof: z.string().length(64, "Verify your email first"),
  newPassword: z.string().min(8, "Password must be at least 8 characters long"),
});

export const changePasswordSchema = z.object({
  currentPassword: z.string().min(1, "Current password is required"),
  newPassword: z.string().min(8, "Password must be at least 8 characters long"),
});

export const verifyEmailCodeSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  code: z.string().regex(/^\d{6}$/, "Code must be 6 digits"),
});


export const loginSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters long"),
});
export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1, "Refresh token is required"),
});
