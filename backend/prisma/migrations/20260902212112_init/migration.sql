-- CreateEnum
CREATE TYPE "ResourceSourceType" AS ENUM ('HOSTED', 'EXTERNAL_LINK', 'REFERENCE_ONLY');

-- DropForeignKey
ALTER TABLE "Resource" DROP CONSTRAINT "Resource_uploadId_fkey";

-- AlterTable
ALTER TABLE "Resource" ADD COLUMN     "externalUrl" TEXT,
ADD COLUMN     "sourceType" "ResourceSourceType" NOT NULL DEFAULT 'HOSTED',
ALTER COLUMN "uploadId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "canPost" BOOLEAN NOT NULL DEFAULT false;

-- CreateIndex
CREATE INDEX "Resource_sourceType_idx" ON "Resource"("sourceType");

-- AddForeignKey
ALTER TABLE "Resource" ADD CONSTRAINT "Resource_uploadId_fkey" FOREIGN KEY ("uploadId") REFERENCES "Upload"("id") ON DELETE SET NULL ON UPDATE CASCADE;
