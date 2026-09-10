import { PrismaClient, ResourceStatus, ResourceType, ResourceSourceType, Visibility } from "@prisma/client";
import { resources } from "./../../../sources/resources";

// System account used for bulk-imported PYQs.
// (uploadedById / approvedById are required fields on Resource.)
const SYSTEM_USER_ID = "cmto7v5he00019k3bt8ev0q2e";

export async function seedResource(prisma: PrismaClient) {
  console.log("Seeding resources (PYQs)...");

  // Preload courses (courseCode -> courseId) — cheap, ~116 rows.
  const courses = await prisma.course.findMany({
    select: { id: true, code: true },
  });
  const courseIdByCode = new Map<string, string>();
  for (const c of courses) {
    if (c.code) courseIdByCode.set(c.code, c.id);
  }

  // Preload subjects (courseId + code -> subjectId) — cheap, ~1.6k rows.
  const subjects = await prisma.subject.findMany({
    select: { id: true, code: true, courseId: true },
  });
  const subjectIdByKey = new Map<string, string>();
  for (const s of subjects) {
    subjectIdByKey.set(`${s.courseId}:${s.code}`, s.id);
  }

  let created = 0;
  let skippedNoCourse = 0;
  let skippedNoSubject = 0;
  let skippedNoUrl = 0;

  const batchSize = 50;
  for (let i = 0; i < resources.length; i += batchSize) {
    const batch = resources.slice(i, i + batchSize);

    await Promise.all(
      batch.map(async (r) => {
        if (!r.externalUrl || !r.subjectCode) {
          skippedNoUrl++;
          return;
        }

        const courseId = courseIdByCode.get(r.courseCode);
        if (!courseId) {
          skippedNoCourse++;
          return;
        }

        const subjectId = subjectIdByKey.get(`${courseId}:${r.subjectCode}`);
        if (!subjectId) {
          // Subject doesn't exist yet in the Subject table for this UPC.
          // We deliberately do NOT create it here — subjects are seeded
          // separately (seedSubject). Run that first to widen coverage.
          skippedNoSubject++;
          return;
        }

        await prisma.resource.upsert({
          where: {
            subjectId_externalUrl: {
              subjectId,
              externalUrl: r.externalUrl,
            },
          },
          update: {},
          create: {
            title: r.title,
            resourceType: ResourceType.PYQ,
            sourceType: ResourceSourceType.EXTERNAL_LINK,
            externalUrl: r.externalUrl,
            visibility: Visibility.PUBLIC,
            status: ResourceStatus.APPROVED,
            subjectId,
            uploadedById: SYSTEM_USER_ID,
            approvedById: SYSTEM_USER_ID,
            approvedAt: new Date(),
          },
        });
        created++;
      }),
    );
  }

  console.log(`✅ Resources seeded: ${created} created/upserted.`);
  console.log(`   Skipped (course not found):  ${skippedNoCourse}`);
  console.log(`   Skipped (subject not found): ${skippedNoSubject}`);
  console.log(`   Skipped (missing url/code):  ${skippedNoUrl}`);
}
