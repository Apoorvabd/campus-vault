import bcrypt from 'bcrypt';
import { Prisma } from '@prisma/client';
import { randomInt } from 'node:crypto';
import { generateRefreshToken, generateAccessToken ,verifyRefreshToken} from './../../config/jwt';
import { findUserByEmail, createUser, findUserByUsername, findUserById, findCollegeAndCourse, findUserForRefresh, bumpTokenVersion } from './auth.repository';
import { RegisterInput, AuthTokens } from './auth.types';
import { assertEmailProof, clearEmailProof } from './emailVerification.service';
import { AppError } from '../../utils';

export const issueTokens = (
  user: { id: string; email: string; role: string },
  tokenVersion: number
): AuthTokens => {
  const payload = { email: user.email, userId: user.id, role: user.role };
  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken({ ...payload, tokenVersion }),
  };
};

// passwordHash, tokenVersion and googleId must never leave the server
export const toPublicUser = <
  T extends { passwordHash: string | null; tokenVersion: number; googleId: string | null }
>(
  user: T
) => {
  const { passwordHash: _passwordHash, tokenVersion: _tokenVersion, googleId: _googleId, ...publicUser } = user;
  return publicUser;
};

export const assertCollegeAndCourseMatchUniversity = async (ids: {
  universityId: string;
  collegeId: string;
  courseId: string;
}) => {
  const [college, course] = await findCollegeAndCourse(ids.collegeId, ids.courseId);
  if (!college) {
    throw new AppError('College not found', 404);
  }
  if (!course) {
    throw new AppError('Course not found', 404);
  }
  if (college.universityId !== ids.universityId || course.universityId !== ids.universityId) {
    throw new AppError('College and course must belong to the selected university', 400);
  }
};

type NewUser = Omit<Parameters<typeof createUser>[0], 'username'>;

/**
 * Creates the user with the requested username, or with a generated one
 * (first three letters of the name + 4 digits), retrying on a collision.
 */
export const createUserWithUsername = async (data: NewUser, requestedUsername?: string) => {
  const usernamePrefix = data.firstName
    .normalize('NFKD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[^a-zA-Z]/g, '')
    .slice(0, 3)
    .toLowerCase()
    .padEnd(3, 'x');

  for (let attempt = 0; attempt < 20; attempt += 1) {
    const username =
      requestedUsername ?? `${usernamePrefix}${randomInt(1000, 10000)}`;
    try {
      return await createUser({ ...data, username });
    } catch (error) {
      const isUsernameCollision =
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002' &&
        String(error.meta?.target).toLowerCase().includes('username');
      if (requestedUsername || !isUsernameCollision) {
        if (isUsernameCollision) {
          throw new AppError('User with this username already exists', 409);
        }
        throw error;
      }
    }
  }
  throw new AppError('Could not generate a unique username. Please try again.', 503);
};

export const registerUser = async (
  input: RegisterInput): Promise<{ user: any; tokens: AuthTokens }> => {
  // Check if user with the same email already exists
  const existingUser = await findUserByEmail(input.email);
  if (existingUser) {
    throw new AppError('User with this email already exists', 409);
  }

  await assertEmailProof(input.email, input.emailProof);

  const requestedUsername = input.username?.trim().toLowerCase();
  if (requestedUsername && await findUserByUsername(requestedUsername)) {
    throw new AppError('User with this username already exists', 409);
  }

  await assertCollegeAndCourseMatchUniversity(input);

  const hashedPassword = await bcrypt.hash(input.password, 10);
  const { password: _password, username: _username, emailProof: _emailProof, ...userInput } = input;

  const user = await createUserWithUsername(
    { ...userInput, passwordHash: hashedPassword, canPost: true, isVerified: true },
    requestedUsername
  );

  // The email is taken now, so a leftover proof is useless; failing here must not fail the signup
  clearEmailProof(input.email).catch((error) => console.error(error));

  // A new account starts at tokenVersion 0 (the schema default)
  const tokens = issueTokens(user, 0);

  return {
    user,
    tokens,
  };

};

export const loginUser= async (email:string , password:string): Promise<{user:any, tokens:AuthTokens}> => {

    const user = await findUserByEmail(email);
    if (!user) {
        throw new AppError('Invalid Credentials ', 401);
    }

    if (!user.passwordHash) {
        throw new AppError('This account uses Google sign-in. Please use "Login with Google".', 400);
    }

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
        throw new AppError('Invalid Credentials ', 401);
    }

    // Checked after the password so a stranger cannot learn which accounts exist
    if (!user.isActive) {
        throw new AppError('Account is deactivated', 403);
    }

    const tokens = issueTokens(user, user.tokenVersion);

    return {
        user: toPublicUser(user),
        tokens,
    };
}

export const getMeService = async (userId: string): Promise<any> => {
    const user = await findUserById(userId);
    if (!user) {
        throw new AppError('User not found', 404);
    }
    return user;
}

export const refreshTokens = async (refreshToken: string): Promise<{ tokens: AuthTokens }> => {

    const decoded = verifyRefreshToken(refreshToken);
    const user = await findUserForRefresh(decoded.userId);
    if (!user) {
        throw new AppError('User not found', 404);
    }
    if(user.isActive === false){
        throw new AppError('User is not active', 403);
    }
    // Logout bumps tokenVersion, which retires every token issued before it
    if ((decoded.tokenVersion ?? 0) !== user.tokenVersion) {
        throw new AppError('Session expired. Please log in again.', 401);
    }

    const tokens = issueTokens(user, user.tokenVersion);

    return {
        tokens,
    };
}

export const logoutUser = async (userId: string): Promise<void> => {
    await bumpTokenVersion(userId);
}
