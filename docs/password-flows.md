# Forgot password and change password

## Forgot password (logged out)

Three calls, the same 6-digit code flow as signup (`otp.service.ts`, purpose
`PASSWORD_RESET`):

1. `POST /auth/forgot-password/send { email }`
   - Always answers 200 "If this email has an account, a code is on its way.",
     also for unknown emails, inactive accounts and during the cooldown, so it
     cannot be used to find out who is registered.
2. `POST /auth/forgot-password/verify { email, code }` returns `{ resetProof }`.
   - Code lives 5 minutes, 4 wrong attempts kill it, a new one can be sent after 30 s
     (the app waits 35 s).
3. `POST /auth/forgot-password/reset { email, resetProof, newPassword }`
   - The proof lives 10 minutes and is checked against its stored sha256.
   - Sets the password, bumps `tokenVersion` (every device is logged out), marks
     the email verified, and sends the "password changed" email.
   - Works for Google-only accounts too: it gives them a password, and they can
     use both ways to log in.

In the app (`forgot_password_screen.dart`) the three steps are one screen. After a
successful reset it goes back to the login screen (no auto-login).

## Change password (logged in)

`POST /auth/change-password { currentPassword, newPassword }`

- A wrong current password is a **400**, not a 401: the app treats a 401 as an
  expired session and tries to refresh the token.
- The new password must differ from the current one (min 8 characters, as everywhere).
- Other devices are logged out (`tokenVersion` bump); the response carries fresh
  tokens for this device, which the app stores.
- Sends the "password changed" email.
- Limited to 10 attempts per 15 minutes per user.

The "Change Password" tile in Profile shows only when `hasPassword` is true. The
user from login, register, Google login and `/auth/me` carries `hasPassword`;
Google-only accounts have none.

## Emails

`passwordReset` (the code) and `passwordChanged` (no data), both in
`backend/src/modules/email/templates/`. See `docs/email-service.md`.

## Rate limits

| Route | Limit |
|---|---|
| forgot-password/send | 5 per hour per IP+email, 20 per hour per IP |
| forgot-password/verify | 10 per 15 min per IP+email |
| forgot-password/reset | 10 per 15 min per IP+email |
| change-password | 10 per 15 min per user |

## Good to know

- Access tokens already issued stay valid until they expire (15 minutes); what
  ends immediately is the ability to refresh them.
- A reset also marks the email verified, which heals old accounts that were
  created before email verification existed.
