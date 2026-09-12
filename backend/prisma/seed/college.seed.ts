import { colleges } from "./../../../sources/college";
import { CollegeGender, PrismaClient } from "@prisma/client";

export async function seedCollege(prisma: PrismaClient) {
  console.log("Seeding colleges...");

  const university = await prisma.university.findUnique({
    where: {
      shortName: "DU",
    },
  });

  if (!university) {
    throw new Error("DU university not found");
  }

  await Promise.all(
    colleges.map((college) =>
      prisma.college.upsert({
        where: {
          code: college.code, // code unique hai schema me
        },

        update: {
          name: college.name,
          shortName: college.shortName,
          gender: college.gender as CollegeGender,
          address: college.address,
          universityId: university.id,
        },

        create: {
          name: college.name,
          shortName: college.shortName,
          code: college.code,
          gender: college.gender as CollegeGender,
          address: college.address,
          universityId: university.id,
        },
      })
    )
  );

  console.log("✅ Colleges seeded successfully.");
}