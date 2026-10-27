import bcrypt from "bcrypt";
import { OtpPurpose } from "@prisma/client";
import { createHash, randomBytes, randomInt } from "node:crypto";
import { AppError } from "../../utils";
import {
  addOtpAttempt,
  deleteOtp,
  deleteStaleOtps,
  findOtp,
  markOtpVerified,
  saveOtp,
} from "./otp.repository";

// The one-time-code machinery shared by signup (EMAIL_VERIFY) and forgot password
// (PASSWORD_RESET): issue a code, check it, hand out a proof, check the proof.

export const CODE_TTL_MINUTES = 5;
export const RESEND_COOLDOWN_SECONDS = 30;
const MAX_ATTEMPTS = 4;
// How long the app may take between verifying the code and using the proof
const PROOF_TTL_MS: Record<OtpPurpose, number> = {
  EMAIL_VERIFY: 30 * 60 * 1000,
  PASSWORD_RESET: 10 * 60 * 1000,
};

// Emails are compared in lowercase; an account keeps the email as typed
export const normalizeEmail = (email: string) => email.trim().toLowerCase();
const sha256 = (value: string) => createHash("sha256").update(value).digest("hex");

/**
 * Creates a fresh code for the email (replacing any older one). Returns the code
 * to send, or how long to wait when the last one went out too recently.
 */
export const issueOtp = async (
  rawEmail: string,
  purpose: OtpPurpose
): Promise<{ code: string } | { waitSeconds: number }> => {
  const email = normalizeEmail(rawEmail);

  const existing = await findOtp(email, purpose);
  if (existing) {
    const waitSeconds = Math.ceil(
      (existing.sentAt.getTime() + RESEND_COOLDOWN_SECONDS * 1000 - Date.now()) / 1000
    );
    if (waitSeconds > 0) return { waitSeconds };
  }

  const code = randomInt(0, 1_000_000).toString().padStart(6, "0");
  const now = new Date();
  await saveOtp({
    email,
    purpose,
    codeHash: await bcrypt.hash(code, 10),
    expiresAt: new Date(now.getTime() + CODE_TTL_MINUTES * 60 * 1000),
    sentAt: now,
  });

  deleteStaleOtps().catch((error) => console.error(error));

  return { code };
};

/** Checks the code and returns the proof; only the proof's hash is stored. */
export const verifyOtp = async (
  rawEmail: string,
  purpose: OtpPurpose,
  code: string
): Promise<string> => {
  const email = normalizeEmail(rawEmail);

  const otp = await findOtp(email, purpose);
  if (!otp || otp.verifiedAt || otp.expiresAt < new Date()) {
    throw new AppError("Code expired. Please request a new one.", 400);
  }

  // The attempt is counted before comparing, so parallel guesses cannot get
  // past the limit
  const { attempts } = await addOtpAttempt(email, purpose);
  const isCorrect =
    attempts <= MAX_ATTEMPTS && (await bcrypt.compare(code, otp.codeHash));

  if (!isCorrect) {
    if (attempts >= MAX_ATTEMPTS) {
      await deleteOtp(email, purpose);
      throw new AppError("Too many wrong attempts. Please request a new code.", 429);
    }
    throw new AppError("Incorrect code.", 400);
  }

  const proof = randomBytes(32).toString("hex");
  await markOtpVerified(email, purpose, sha256(proof));
  return proof;
};

export const assertOtpProof = async (
  rawEmail: string,
  purpose: OtpPurpose,
  proof: string
) => {
  const otp = await findOtp(normalizeEmail(rawEmail), purpose);

  const isValid =
    otp?.verifiedAt &&
    otp.proofHash === sha256(proof) &&
    Date.now() - otp.verifiedAt.getTime() < PROOF_TTL_MS[purpose];

  if (!isValid) {
    throw new AppError("Please verify your email first.", 400);
  }
};

export const clearOtp = async (rawEmail: string, purpose: OtpPurpose) => {
  await deleteOtp(normalizeEmail(rawEmail), purpose);
};
