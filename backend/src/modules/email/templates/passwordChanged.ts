import { EmailTemplate, EmailTemplates } from "../email.types";
import { heading, note, paragraph } from "./blocks";

export const passwordChanged: EmailTemplate<EmailTemplates["passwordChanged"]> = {
  subject: "Your Semester Forge password was changed",
  preheader: () => "Your Semester Forge password was changed.",
  content: () =>
    [
      heading("Your password was changed"),
      paragraph(
        "The password for your Semester Forge account was just changed, and you were signed out of all your devices. Log in again with the new password."
      ),
      note(
        "Wasn't you? Open the app, tap Forgot password? on the login screen to reset it right away, and write to support@semesterforge.in."
      ),
    ].join(""),
  text: () =>
    "The password for your Semester Forge account was just changed, and you were signed out of all your devices. Log in again with the new password.\n\nWasn't you? Open the app, tap Forgot password? on the login screen to reset it right away, and write to support@semesterforge.in.",
};
