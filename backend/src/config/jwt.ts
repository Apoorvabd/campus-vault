import jwt ,{Secret, SignOptions} from "jsonwebtoken";

interface JwtPayload {
    userId: string;
    email: string;
    role: string;
}

const ACCESS_TOKEN_SECRET: Secret = process.env.JWT_ACCESS_SECRET || "your_access_token_secret";
const REFRESH_TOKEN_SECRET: Secret = process.env.JWT_REFRESH_SECRET || "your_refresh_token_secret";
const ACCESS_TOKEN_EXPIRES_IN: string = process.env.JWT_ACCESS_EXPIRES_IN || "15m";
const REFRESH_TOKEN_EXPIRES_IN: string = process.env.JWT_REFRESH_EXPIRES_IN || "7d";

export const generateAccessToken = (payload: JwtPayload): string => {    return jwt.sign(payload, ACCESS_TOKEN_SECRET as Secret, { expiresIn: ACCESS_TOKEN_EXPIRES_IN } as SignOptions)};

export const generateRefreshToken = (payload: JwtPayload & { tokenVersion: number }): string => {
    return jwt.sign(payload, REFRESH_TOKEN_SECRET as Secret, { expiresIn: REFRESH_TOKEN_EXPIRES_IN } as SignOptions);
}

export const verifyAccessToken = (token: string): JwtPayload => {
  return jwt.verify(token, ACCESS_TOKEN_SECRET) as JwtPayload;
};

// tokenVersion is missing on refresh tokens issued before it existed
export const verifyRefreshToken = (token: string): JwtPayload & { tokenVersion?: number } => {
  return jwt.verify(token, REFRESH_TOKEN_SECRET) as JwtPayload & { tokenVersion?: number };
};
