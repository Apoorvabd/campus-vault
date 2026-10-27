import { EmailTemplate, EmailTemplates } from "../email.types";
import { codeBox, heading, note, paragraph } from "./blocks";

export const passwordReset: EmailTemplate<EmailTemplates["passwordReset"]> = {
  subject: "Your Semester Forge password reset code",
  preheader: ({ code, expiresInMinutes }) =>
    `Your password reset code is ${code}. It expires in ${expiresInMinutes} minutes.`,
  content: ({ code, expiresInMinutes }) =>
    [
      heading("Reset your password"),
      paragraph("Enter this code in the app to choose a new password for your Semester Forge account."),
      codeBox(code),
      paragraph(`This code expires in ${expiresInMinutes} minutes.`),
      note(
        "Didn't ask for this? You can safely ignore this email: your password stays the same unless this code is used. Never share this code with anyone."
      ),
    ].join(""),
  text: ({ code, expiresInMinutes }) =>
    `Your Semester Forge password reset code is ${code}.\nIt expires in ${expiresInMinutes} minutes.\n\nDidn't ask for this? You can safely ignore this email: your password stays the same unless this code is used. Never share this code with anyone.`,
};
