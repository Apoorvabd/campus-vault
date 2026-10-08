-- AlterTable
ALTER TABLE "User" ADD COLUMN     "selectedSubjectIds" TEXT[] DEFAULT ARRAY[]::TEXT[],
ADD COLUMN     "subjectsConfirmedAt" TIMESTAMP(3),
ADD COLUMN     "subjectsSemester" INTEGER;
