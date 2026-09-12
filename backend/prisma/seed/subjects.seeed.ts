import { PrismaClient } from "@prisma/client";
import { subjects } from "./../../../sources/subjects";

export async function seedSubject(prisma: PrismaClient) {
  console.log("Seeding subjects...");
  const batchSize = 20;
for(let i=0;i<subjects.length;i+=batchSize){

   const batch = subjects.slice(i,i+batchSize);

  await Promise.all(
    batch.map(async (subject) => {

      const course = await prisma.course.findUnique({
        where: {
          code: subject.courseCode,
        },
      });

      if (!course) {
        throw new Error(`Course not found: ${subject.courseCode}`);
      }


      await prisma.subject.upsert({

        where: {
          courseId_code: {
            courseId: course.id,
            code: subject.code,
          },
        },

        update: {
          name: subject.name,
          semester: subject.semester,
          credits: subject.credits,
          type: subject.type,
        },

        create: {
          name: subject.name,
          code: subject.code,
          semester: subject.semester,
          credits: subject.credits,
          type: subject.type,
          courseId: course.id,
        },

      });

    })
  );
}

  console.log("✅ Subjects seeded successfully.");
}