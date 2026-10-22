import { EMAIL_FROM, resend } from "../../config/resend";
import { AppError } from "../../utils";
import { EmailTemplate, EmailTemplates, TemplateName } from "./email.types";
import { renderLayout } from "./templates/layout";
import { templates } from "./templates";

const isProduction = process.env.NODE_ENV === "production";

if (!resend && isProduction) {
  console.warn("RESEND_API_KEY is not set: emails cannot be sent.");
}

/**
 * The one way to send an email:
 *   await sendEmail({ to, template: "verifyEmail", data: { code, expiresInMinutes } });
 * `data` is type-checked against the chosen template. Without an API key it
 * prints the email to the console in dev and refuses in production.
 */
export const sendEmail = async <T extends TemplateName>({
  to,
  template,
  data,
}: {
  to: string;
  template: T;
  data: EmailTemplates[T];
}): Promise<void> => {
  const { subject, preheader, content, text } = templates[
    template
  ] as EmailTemplate<EmailTemplates[T]>;

  if (!resend) {
    if (isProduction) {
      throw new AppError("Email service is not configured.", 503);
    }
    console.log(`[email:dev] to=${to} subject="${subject}"\n${text(data)}`);
    return;
  }

  const { error } = await resend.emails.send({
    from: EMAIL_FROM,
    to,
    subject,
    html: renderLayout({ preheader: preheader(data), content: content(data) }),
    text: text(data),
  });

  if (error) {
    console.error("Resend failed:", error);
    throw new AppError("Could not send the email. Please try again.", 502);
  }
};
