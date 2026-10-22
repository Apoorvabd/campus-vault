import { EmailTemplate, EmailTemplates } from "../email.types";
import { codeBox, heading, note, paragraph } from "./blocks";

// Sent while signing up, so there is no user (and no name) yet
export const verifyEmail: EmailTemplate<EmailTemplates["verifyEmail"]> = {
  subject: "Your Semester Forge verification code",
  preheader: ({ code, expiresInMinutes }) =>
    `Your code is ${code}. It expires in ${expiresInMinutes} minutes.`,
  content: ({ code, expiresInMinutes }) =>
    [
      heading("Verify your email"),
      paragraph("Enter this code in the app to finish creating your account."),
      codeBox(code),
      paragraph(`This code expires in ${expiresInMinutes} minutes.`),
      note(
        "Didn't request this? You can safely ignore this email. Never share this code with anyone."
      ),
    ].join(""),
  text: ({ code, expiresInMinutes }) =>
    `Your Semester Forge verification code is ${code}.\nIt expires in ${expiresInMinutes} minutes.\n\nDidn't request this? You can safely ignore this email. Never share this code with anyone.`,
};
