import { verifyGoogleIdToken, GoogleProfile } from "../../config/google";
import { AppError } from "../../utils";
import { invalidateAuthUser } from "../../utils/authCache";
import {
  assertCollegeAndCourseMatchUniversity,
  createUserWithUsername,
  issueTokens,
  toPublicUser,
} from "./auth.service";
import {
  findUserByEmailInsensitive,
  findUserByGoogleId,
  isEmailRegistered,
  linkGoogleAccount,
} from "./auth.repository";
import { GoogleRegisterInput } from "./auth.types";

// An account made with a password and the same email gets the Google account attached
const linkToEmailAccount = async (profile: GoogleProfile) => {
  const existing = await findUserByEmailInsensitive(profile.email);
  if (!existing) return null;

  if (existing.googleId) {
    throw new AppError("This email is already linked to another Google account.", 409);
  }
  if (!existing.isActive) {
    throw new AppError("Account is deactivated", 403);
  }

  const linked = await linkGoogleAccount(existing.id, profile.googleId, !existing.isVerified);
  // isVerified (and possibly the sessions) changed, so drop the cached copy
  invalidateAuthUser(existing.id);
  return linked;
};

/**
 * Logs the user in, or says the app must finish signing up first (the Google
 * account has no Semester Forge account yet).
 */
export const loginWithGoogle = async (idToken: string) => {
  const profile = await verifyGoogleIdToken(idToken);

  const user =
    (await findUserByGoogleId(profile.googleId)) ?? (await linkToEmailAccount(profile));

  if (!user) {
    return {
      needsSignup: true as const,
      profile: {
        email: profile.email,
        firstName: profile.firstName,
        lastName: profile.lastName,
      },
    };
  }
  if (!user.isActive) {
    throw new AppError("Account is deactivated", 403);
  }

  return {
    needsSignup: false as const,
    user: toPublicUser(user),
    tokens: issueTokens(user, user.tokenVersion),
  };
};

/**
 * Creates the account for a Google user. Name and email come from the verified
 * token; the app only adds the academic details it collected.
 */
export const registerWithGoogle = async (input: GoogleRegisterInput) => {
  const profile = await verifyGoogleIdToken(input.idToken);

  // The user may have signed up in the meantime, or the app retried
  if ((await findUserByGoogleId(profile.googleId)) || (await isEmailRegistered(profile.email))) {
    throw new AppError("An account already exists for this email. Please log in.", 409);
  }

  await assertCollegeAndCourseMatchUniversity(input);

  const user = await createUserWithUsername({
    firstName: profile.firstName,
    lastName: profile.lastName ?? undefined,
    email: profile.email,
    googleId: profile.googleId,
    passwordHash: null,
    canPost: true,
    isVerified: true,
    universityId: input.universityId,
    collegeId: input.collegeId,
    courseId: input.courseId,
    currentSemester: input.currentSemester,
  });

  // A new account starts at tokenVersion 0 (the schema default)
  return { user: { ...user, hasPassword: false }, tokens: issueTokens(user, 0) };
};
