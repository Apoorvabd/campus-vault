import { EmailTemplate, EmailTemplates, TemplateName } from "../email.types";
import { verifyEmail } from "./verifyEmail";

// The mapped type makes it a compile error to add a name to EmailTemplates
// without registering its template here.
export const templates: {
  [K in TemplateName]: EmailTemplate<EmailTemplates[K]>;
} = {
  verifyEmail,
};
