-- Where each resource link came from (so we can see / undo / replace a whole source at once)
ALTER TABLE "Resource" ADD COLUMN "source" TEXT;
CREATE INDEX "Resource_source_idx" ON "Resource"("source");

-- Backfill the existing seeded rows by the host of their link
UPDATE "Resource" SET "source" = 'du-qb'              WHERE "externalUrl" LIKE '%qb.exam.du.ac.in%';
UPDATE "Resource" SET "source" = 'drive-seed'         WHERE "externalUrl" LIKE '%drive.google.com%';
UPDATE "Resource" SET "source" = 'du-academicaffairs' WHERE "externalUrl" LIKE '%academicaffairs.du.ac.in%';
UPDATE "Resource" SET "source" = 'ramanujan-library'  WHERE "externalUrl" LIKE '%library.ramanujancollege.ac.in%';
