// src/config/resend.ts

import { Resend } from "resend";

// null when no key is set: the email service then logs to the console instead
// of sending (local dev), or refuses to send in production.
export const resend = process.env.RESEND_API_KEY
  ? new Resend(process.env.RESEND_API_KEY)
  : null;

// Needs a domain verified in Resend; the default only works for Resend's own
// test mode (mails to the account owner).
export const EMAIL_FROM =
  process.env.EMAIL_FROM ?? "Semester Forge <onboarding@resend.dev>";
