import bcrypt from 'bcrypt';
import { Prisma } from '@prisma/client';
import { randomInt } from 'node:crypto';
import { generateRefreshToken, generateAccessToken ,verifyRefreshToken} from './../../config/jwt';
import { findUserByEmail, createUser, findUserByUsername, findUserById } from './auth.repository';
import { RegisterInput, AuthTokens } from './auth.types';
import { AppError } from '../../utils';

export const registerUser = async (
  input: RegisterInput): Promise<{ user: any; tokens: AuthTokens }> => {
  // Check if user with the same email already exists
  const existingUser = await findUserByEmail(input.email);
  if (existingUser) {
    throw new AppError('User with this email already exists', 409);
  }

  const requestedUsername = input.username?.trim().toLowerCase();
  if (requestedUsername && await findUserByUsername(requestedUsername)) {
    throw new AppError('User with this username already exists', 409);
  }

  const hashedPassword = await bcrypt.hash(input.password, 10);
  const { password: _password, username: _username, ...userInput } = input;
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
  
  const tokens: AuthTokens = { 
    accessToken: generateAccessToken(
        {email: user.email, userId: user.id, role: user.role},
    ),
     refreshToken: generateRefreshToken(
        {email: user.email, userId: user.id, role: user.role},
    )
  };

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

    const tokens: AuthTokens = { 
        accessToken: generateAccessToken(
            {email: user.email, userId: user.id, role: user.role},
        ),
         refreshToken: generateRefreshToken(
            {email: user.email, userId: user.id, role: user.role},
        )
      };

    // passwordHash must never leave the server
    const { passwordHash: _passwordHash, ...safeUser } = user;

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
    const user = await findUserById(decoded.userId);
    if (!user) {
        throw new AppError('User not found', 404);
    }
    if(user.isActive === false){
        throw new AppError('User is not active', 403);
    }

    const tokens: AuthTokens = { 
        accessToken: generateAccessToken(
            {email: user.email, userId: user.id, role: user.role},
        ),
         refreshToken: generateRefreshToken(
            {email: user.email, userId: user.id, role: user.role},
        )
      };

    return {
        tokens,
    };
}