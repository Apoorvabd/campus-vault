import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
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

  const existingUsername = await findUserByUsername(input.username);
  if (existingUsername) {
    throw new AppError('User with this username already exists', 409);
  }

  const hashedPassword = await bcrypt.hash(input.password, 10);
  const { password: _password, ...userInput } = input;
  const user = await createUser({ ...userInput, passwordHash: hashedPassword });
  
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

    return {
        user,
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