-- AlterTable
ALTER TABLE "Subject" ALTER COLUMN "semester" DROP NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Resource_subjectId_externalUrl_key" ON "Resource"("subjectId", "externalUrl");
