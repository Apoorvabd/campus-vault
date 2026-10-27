import { AppError } from "../../utils";
import { sendEmail } from "../email/email.service";
import { isEmailRegistered } from "./auth.repository";
import {
  CODE_TTL_MINUTES,
  RESEND_COOLDOWN_SECONDS,
  assertOtpProof,
  clearOtp,
  issueOtp,
  normalizeEmail,
  verifyOtp,
} from "./otp.service";

export const sendEmailCode = async (rawEmail: string) => {
  const email = normalizeEmail(rawEmail);

  // Checked before anything is sent, so a taken email never gets a code
  if (await isEmailRegistered(email)) {
    throw new AppError("An account with this email already exists.", 409);
  }

  const issued = await issueOtp(email, "EMAIL_VERIFY");
  if ("waitSeconds" in issued) {
    throw new AppError(`Please wait ${issued.waitSeconds}s before requesting another code.`, 429);
  }

  try {
    await sendEmail({
      to: email,
      template: "verifyEmail",
      data: { code: issued.code, expiresInMinutes: CODE_TTL_MINUTES },
    });
  } catch (error) {
    // Nothing reached the user, so do not make them wait out the cooldown
    await clearOtp(email, "EMAIL_VERIFY");
    throw error;
  }

  return { cooldownSeconds: RESEND_COOLDOWN_SECONDS };
};

export const verifyEmailCode = async (rawEmail: string, code: string) => {
  return { emailProof: await verifyOtp(rawEmail, "EMAIL_VERIFY", code) };
};

export const assertEmailProof = async (rawEmail: string, proof: string) => {
  await assertOtpProof(rawEmail, "EMAIL_VERIFY", proof);
};

export const clearEmailProof = async (rawEmail: string) => {
  await clearOtp(rawEmail, "EMAIL_VERIFY");
};
