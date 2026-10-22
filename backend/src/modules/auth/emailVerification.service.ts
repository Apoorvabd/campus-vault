import bcrypt from "bcrypt";
import { createHash, randomBytes, randomInt } from "node:crypto";
import { AppError } from "../../utils";
import { sendEmail } from "../email/email.service";
import { isEmailRegistered } from "./auth.repository";
import {
  addEmailOtpAttempt,
  deleteEmailOtp,
  deleteStaleEmailOtps,
  findEmailOtp,
  markEmailOtpVerified,
  saveEmailOtp,
} from "./emailVerification.repository";

const CODE_TTL_MINUTES = 5;
const RESEND_COOLDOWN_SECONDS = 5;
const MAX_ATTEMPTS = 4;
// How long the app may take between verifying the email and finishing signup
const PROOF_TTL_MS = 30 * 60 * 1000;

// Emails are compared in lowercase; the account keeps the email as typed
const normalizeEmail = (email: string) => email.trim().toLowerCase();
const sha256 = (value: string) => createHash("sha256").update(value).digest("hex");

export const sendEmailCode = async (rawEmail: string) => {
  const email = normalizeEmail(rawEmail);

  // Checked before anything is sent, so a taken email never gets a code
  if (await isEmailRegistered(email)) {
    throw new AppError("An account with this email already exists.", 409);
  }

  const existing = await findEmailOtp(email);
  if (existing) {
    const waitSeconds = Math.ceil(
      (existing.sentAt.getTime() + RESEND_COOLDOWN_SECONDS * 1000 - Date.now()) / 1000
    );
    if (waitSeconds > 0) {
      throw new AppError(`Please wait ${waitSeconds}s before requesting another code.`, 429);
    }
  }

  const code = randomInt(0, 1_000_000).toString().padStart(6, "0");
  const now = new Date();
  await saveEmailOtp({
    email,
    codeHash: await bcrypt.hash(code, 10),
    expiresAt: new Date(now.getTime() + CODE_TTL_MINUTES * 60 * 1000),
    sentAt: now,
  });

  try {
    await sendEmail({
      to: email,
      template: "verifyEmail",
      data: { code, expiresInMinutes: CODE_TTL_MINUTES },
    });
  } catch (error) {
    // Nothing reached the user, so do not make them wait out the cooldown
    await deleteEmailOtp(email);
    throw error;
  }

  deleteStaleEmailOtps().catch((error) => console.error(error));

  return { cooldownSeconds: RESEND_COOLDOWN_SECONDS };
};

export const verifyEmailCode = async (rawEmail: string, code: string) => {
  const email = normalizeEmail(rawEmail);

  const otp = await findEmailOtp(email);
  if (!otp || otp.verifiedAt || otp.expiresAt < new Date()) {
    throw new AppError("Code expired. Please request a new one.", 400);
  }

  // The attempt is counted before comparing, so parallel guesses cannot get
  // past the limit
  const { attempts } = await addEmailOtpAttempt(email);
  const isCorrect =
    attempts <= MAX_ATTEMPTS && (await bcrypt.compare(code, otp.codeHash));

  if (!isCorrect) {
    if (attempts >= MAX_ATTEMPTS) {
      await deleteEmailOtp(email);
      throw new AppError("Too many wrong attempts. Please request a new code.", 429);
    }
    throw new AppError("Incorrect code.", 400);
  }

  // The app keeps this and sends it back with register; only its hash is stored
  const emailProof = randomBytes(32).toString("hex");
  await markEmailOtpVerified(email, sha256(emailProof));

  return { emailProof };
};

export const assertEmailProof = async (rawEmail: string, proof: string) => {
  const otp = await findEmailOtp(normalizeEmail(rawEmail));

  const isValid =
    otp?.verifiedAt &&
    otp.proofHash === sha256(proof) &&
    Date.now() - otp.verifiedAt.getTime() < PROOF_TTL_MS;

  if (!isValid) {
    throw new AppError("Please verify your email first.", 400);
  }
};

export const clearEmailProof = async (rawEmail: string) => {
  await deleteEmailOtp(normalizeEmail(rawEmail));
};
