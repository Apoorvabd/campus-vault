# Email service and signup email verification

## Sending an email

```ts
await sendEmail({
  to: user.email,
  template: "verifyEmail",
  data: { code, expiresInMinutes: 5 },
});
```

`data` is type-checked against the chosen template. Code lives in
`backend/src/modules/email/`:

| File | Job |
|---|---|
| `email.service.ts` | `sendEmail()`: renders the template inside the layout and sends it with Resend |
| `email.types.ts` | The data each template needs (`EmailTemplates`) |
| `templates/layout.ts` | Fixed top (brand) and bottom (footer) shared by every email |
| `templates/blocks.ts` | `heading`, `paragraph`, `codeBox`, `note` for the middle part |
| `templates/<name>.ts` | One email: subject, preheader, content, plain-text version |
| `templates/index.ts` | Registry of all templates |

### Adding a new email

1. Add its data type to `EmailTemplates` in `email.types.ts`.
2. Create `templates/<name>.ts` (build `content` from the blocks; add a block to
   `blocks.ts` if you need a new kind, e.g. a button).
3. Register it in `templates/index.ts`. Forgetting this is a compile error.
4. Call `sendEmail({ template: "<name>", ... })`.

Templates are TypeScript functions (not `.html` files) on purpose: `npm run build`
only compiles `.ts`, so HTML files would be missing from `dist/` in production.

## Configuration

| Variable | Meaning |
|---|---|
| `RESEND_API_KEY` | From the Resend dashboard. Empty in dev: the email is printed in the console. |
| `EMAIL_FROM` | `Semester Forge <no-reply@yourdomain.com>`. The domain must be verified in Resend (SPF/DKIM). |

In production without `RESEND_API_KEY` the server still starts (with a warning) but
`sendEmail` fails with 503, so signup is blocked until the key is set.

## Signup email verification

The email is verified on signup step 1, before the account exists. Codes live in
the `EmailOtp` table, keyed by lowercase email.

1. `POST /auth/email-verification/send` `{ email }`
   - 409 if an account with this email already exists (nothing is sent)
   - 429 if the last code was sent less than 30 seconds ago (the app waits 35 s
     before it offers "Resend OTP", to leave room for a slow network)
   - 200 `{ cooldownSeconds }`
2. `POST /auth/email-verification/verify` `{ email, code }`
   - 400 wrong or expired code, 429 after 4 wrong attempts (request a new code)
   - 200 `{ emailProof }`
3. `POST /auth/register` now requires `emailProof`. The account is created with
   `isVerified = true`.

| Rule | Value |
|---|---|
| Code | 6 digits, bcrypt-hashed in the database |
| Code lifetime | 5 minutes |
| Wrong attempts | 4, then the code is deleted |
| Proof lifetime | 30 minutes (only its sha256 is stored) |
| Rate limits | send: 5/hour per IP+email and 20/hour per IP; verify: 10 per 15 min per IP+email |

Emails are compared in lowercase here; the account keeps the email as typed.

Resend's free plan has a daily sending quota, so the per-IP send limit matters:
without it one client could use the quota up and block everyone's signup.

Old app builds that do not send `emailProof` can no longer register.
