// To add an email: add its data here, create a file in templates/, register it
// in templates/index.ts. sendEmail() then type-checks the data for that name.
export type EmailTemplates = {
  verifyEmail: { code: string; expiresInMinutes: number };
  passwordReset: { code: string; expiresInMinutes: number };
  passwordChanged: Record<string, never>;
};

export type TemplateName = keyof EmailTemplates;

export type EmailTemplate<T> = {
  subject: string;
  // Grey preview line shown next to the subject in the inbox
  preheader: (data: T) => string;
  // HTML that goes between the fixed top and bottom of every email
  content: (data: T) => string;
  // Plain-text fallback (also helps with spam filters)
  text: (data: T) => string;
};
