-- Forgot password uses the same one-time codes as signup
ALTER TYPE "OtpPurpose" ADD VALUE 'PASSWORD_RESET';
