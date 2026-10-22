-- Logout bumps this so previously issued refresh tokens stop working
ALTER TABLE "User" ADD COLUMN "tokenVersion" INTEGER NOT NULL DEFAULT 0;
