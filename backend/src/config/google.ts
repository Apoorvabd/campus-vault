// src/config/google.ts

import { OAuth2Client } from "google-auth-library";
import { AppError } from "../utils/appError";

// The Web client ID from Google Cloud. The app asks Google for an ID token made
// for this client (serverClientId), and only tokens made for it are accepted.
const clientId = process.env.GOOGLE_CLIENT_ID;

const client = new OAuth2Client();

export type GoogleProfile = {
  googleId: string;
  email: string;
  firstName: string;
  lastName: string | null;
};

/**
 * Checks an ID token from the app with Google (signature, issuer, expiry and
 * audience) and returns who it belongs to.
 */
export const verifyGoogleIdToken = async (idToken: string): Promise<GoogleProfile> => {
  if (!clientId) {
    throw new AppError("Google sign-in is not configured.", 503);
  }

  let payload;
  try {
    const ticket = await client.verifyIdToken({ idToken, audience: clientId });
    payload = ticket.getPayload();
  } catch {
    throw new AppError("Invalid Google token. Please try again.", 401);
  }

  if (!payload?.sub || !payload.email || !payload.email_verified) {
    throw new AppError("Your Google account has no verified email.", 400);
  }

  return {
    googleId: payload.sub,
    email: payload.email,
    firstName: payload.given_name ?? payload.name ?? payload.email.split("@")[0],
    lastName: payload.family_name ?? null,
  };
};
