# Google login

"Login with Google" on the login screen and on signup step 1 (Android).

## Flow

1. The app opens Google's account picker and gets an **ID token**.
2. `POST /auth/google { idToken }`: the backend verifies the token with Google
   (signature, issuer, expiry, audience, `email_verified`).
   - The Google account (or its email) already has an account: logged in,
     `{ needsSignup: false, user, tokens }`.
   - No account yet: `{ needsSignup: true, profile: { email, firstName, lastName } }`.
     The app opens signup step 2 for the academic details.
3. `POST /auth/google/register { idToken, universityId, collegeId, courseId, currentSemester }`
   creates the account. Name and email come from the verified token, the username
   is generated, `isVerified` is true and there is no password.

The app sends the same ID token again in step 3 (Google tokens last about an
hour), so the backend keeps no state between the two calls.

## Rules worth knowing

- **Linking:** a password account with the same email gets the Google account
  attached (`User.googleId`). If that account was never verified (created before
  email OTP existed), its password is removed and its sessions are ended, because
  whoever set that password may not own the email.
- A Google-only account that tries email + password gets "This account uses
  Google sign-in".
- A deactivated account gets 403, a Google account linked to a different user gets 409.
- `/auth/google*` is rate limited per IP (60 per 15 min, generous: a campus
  shares one IP).

## Configuration

Google Cloud needs two OAuth clients in one project:

| Client | Used for | Where its value goes |
|---|---|---|
| **Web application** | The audience of the ID token | `GOOGLE_CLIENT_ID` in the backend `.env` and on Render, and `googleServerClientId` in `mobile/lib/core/network/google_config.dart` |
| **Android** (package `in.semesterforge.app` + SHA-1) | Lets Google recognise the app | Nothing in code; it only has to exist |

The Web client ID is public (not a secret). The JSON that Google lets you download
for the Web client also contains a **client secret**: we do not use it, so keep
that file out of the repo.

SHA-1 for local and shared APK builds (they are signed with the debug key for now):

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

When a real release keystore is created, add its SHA-1 as another Android client.

The Android package name (`applicationId` in `mobile/android/app/build.gradle.kts`)
must match the Android client. Changing it later means editing that client too.

While the consent screen is in **Testing**, only the listed test users can sign in.
Publish it to Production once the home page, privacy policy and terms links are
live and the domain is verified.
