import bcrypt from "bcrypt";
import { AppError } from "../../utils";
import { invalidateAuthUser } from "../../utils/authCache";
import { sendEmail } from "../email/email.service";
import { issueTokens } from "./auth.service";
import {
  findUserByEmailInsensitive,
  findUserForPasswordChange,
  updatePassword,
} from "./auth.repository";
import {
  CODE_TTL_MINUTES,
  RESEND_COOLDOWN_SECONDS,
  assertOtpProof,
  clearOtp,
  issueOtp,
  normalizeEmail,
  verifyOtp,
} from "./otp.service";

// Tells the owner their password changed; a failure here must not undo the change
const notifyPasswordChanged = (email: string) => {
  sendEmail({ to: email, template: "passwordChanged", data: {} }).catch((error) =>
    console.error(error)
  );
};

/**
 * Emails a reset code. The answer is the same whether or not an account exists
 * (and during the cooldown), so this cannot be used to find out who is registered.
 */
export const sendPasswordResetCode = async (rawEmail: string) => {
  const email = normalizeEmail(rawEmail);
  const user = await findUserByEmailInsensitive(email);

  if (user?.isActive) {
    const issued = await issueOtp(email, "PASSWORD_RESET");
    if ("code" in issued) {
      sendEmail({
        to: email,
        template: "passwordReset",
        data: { code: issued.code, expiresInMinutes: CODE_TTL_MINUTES },
      }).catch(async (error) => {
        console.error(error);
        await clearOtp(email, "PASSWORD_RESET");
      });
    }
  }

  return { cooldownSeconds: RESEND_COOLDOWN_SECONDS };
};

export const verifyPasswordResetCode = async (rawEmail: string, code: string) => {
  return { resetProof: await verifyOtp(rawEmail, "PASSWORD_RESET", code) };
};

/** Sets the new password, ends every session and emails the owner. */
export const resetPassword = async (
  rawEmail: string,
  resetProof: string,
  newPassword: string
) => {
  await assertOtpProof(rawEmail, "PASSWORD_RESET", resetProof);

  const user = await findUserByEmailInsensitive(normalizeEmail(rawEmail));
  if (!user || !user.isActive) {
    throw new AppError("Please verify your email first.", 400);
  }

  await updatePassword(user.id, await bcrypt.hash(newPassword, 10), true);
  await clearOtp(rawEmail, "PASSWORD_RESET");
  invalidateAuthUser(user.id);
  notifyPasswordChanged(user.email);
};

/**
 * For a logged-in user. Other devices are logged out; this one gets fresh tokens
 * so the user stays in.
 */
export const changePassword = async (
  userId: string,
  currentPassword: string,
  newPassword: string
) => {
  const user = await findUserForPasswordChange(userId);
  if (!user?.passwordHash) {
    throw new AppError("This account has no password to change.", 400);
  }

  // 400, not 401: the app treats a 401 as an expired session and tries to refresh
  if (!(await bcrypt.compare(currentPassword, user.passwordHash))) {
    throw new AppError("Current password is incorrect.", 400);
  }
  if (currentPassword === newPassword) {
    throw new AppError("New password must be different from the current one.", 400);
  }

  const updated = await updatePassword(user.id, await bcrypt.hash(newPassword, 10), false);
  notifyPasswordChanged(user.email);

  return { tokens: issueTokens(updated, updated.tokenVersion) };
};
