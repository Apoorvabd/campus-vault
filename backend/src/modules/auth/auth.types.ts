import { z } from "zod";
import { registerSchema, loginSchema, googleRegisterSchema } from "./auth.validation";

export type RegisterInput = z.infer<typeof registerSchema>;
export type GoogleRegisterInput = z.infer<typeof googleRegisterSchema>;
export type LoginInput = z.infer<typeof loginSchema>;

export interface JwtUserPayload {
  userId: string;
  email: string;
  role: string;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
}