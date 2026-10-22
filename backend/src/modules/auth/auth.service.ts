import bcrypt from 'bcrypt';
import { Prisma } from '@prisma/client';
import { randomInt } from 'node:crypto';
import { generateRefreshToken, generateAccessToken ,verifyRefreshToken} from './../../config/jwt';
import { findUserByEmail, createUser, findUserByUsername, findUserById, findCollegeAndCourse, findUserForRefresh, bumpTokenVersion } from './auth.repository';
import { RegisterInput, AuthTokens } from './auth.types';
import { assertEmailProof, clearEmailProof } from './emailVerification.service';
import { AppError } from '../../utils';

const issueTokens = (
  user: { id: string; email: string; role: string },
  tokenVersion: number
): AuthTokens => {
  const payload = { email: user.email, userId: user.id, role: user.role };
  return {
    accessToken: generateAccessToken(payload),
    refreshToken: generateRefreshToken({ ...payload, tokenVersion }),
  };
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

  const [college, course] = await findCollegeAndCourse(input.collegeId, input.courseId);
  if (!college) {
    throw new AppError('College not found', 404);
  }
  if (!course) {
    throw new AppError('Course not found', 404);
  }
  if (college.universityId !== input.universityId || course.universityId !== input.universityId) {
    throw new AppError('College and course must belong to the selected university', 400);
  }

  const hashedPassword = await bcrypt.hash(input.password, 10);
  const { password: _password, username: _username, emailProof: _emailProof, ...userInput } = input;
  const usernamePrefix = input.firstName
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z]/g, '')
    .slice(0, 3)
    .toLowerCase()
    .padEnd(3, 'x');

  let user;
  for (let attempt = 0; attempt < 20; attempt += 1) {
    const username =
      requestedUsername ?? `${usernamePrefix}${randomInt(1000, 10000)}`;
    try {
      user = await createUser({
        ...userInput,
        username,
        passwordHash: hashedPassword,
        canPost: true,
        isVerified: true,
      });
      break;
    } catch (error) {
      const isUsernameCollision =
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002' &&
        String(error.meta?.target).toLowerCase().includes('username');
      if (requestedUsername || !isUsernameCollision || attempt === 19) {
        if (isUsernameCollision) {
          throw new AppError('User with this username already exists', 409);
        }
        throw error;
      }
    }
  }
  if (!user) {
    throw new AppError('Could not generate a unique username. Please try again.', 503);
  }

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

    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
        throw new AppError('Invalid Credentials ', 401);
    }

    // Checked after the password so a stranger cannot learn which accounts exist
    if (!user.isActive) {
        throw new AppError('Account is deactivated', 403);
    }

    const tokens = issueTokens(user, user.tokenVersion);

    // passwordHash and tokenVersion must never leave the server
    const { passwordHash: _passwordHash, tokenVersion: _tokenVersion, ...safeUser } = user;

    return {
        user: safeUser,
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
