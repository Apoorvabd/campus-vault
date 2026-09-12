import { CollegeGender, PrismaClient } from "@prisma/client";

export async function seedTestColleges(prisma: PrismaClient) {
  console.log("Seeding test colleges...");

  const university = await prisma.university.findUnique({
    where: {
      id: "cmtn6atae00019kb3aqsl16za",
    },
  });

  if (!university) {
    throw new Error("Example university not found");
  }

  const colleges = [
    {
      name: "College 1",
      shortName: "C1",
      code: "C001",
      gender: CollegeGender.CO_ED,
      address: "Example Address 1",
    },
    {
      name: "College 2",
      shortName: "C2",
      code: "C002",
      gender: CollegeGender.CO_ED,
      address: "Example Address 2",
    },
  ];

  for (const college of colleges) {
    await prisma.college.upsert({
      where: {
        code: college.code,
      },

      update: {
        name: college.name,
        shortName: college.shortName,
        gender: college.gender,
        address: college.address,
        universityId: university.id,
      },

      create: {
        name: college.name,
        shortName: college.shortName,
        code: college.code,
        gender: college.gender,
        address: college.address,
        universityId: university.id,
      },
    });
  }

  console.log("✅ Test colleges seeded successfully.");
}

const prisma = new PrismaClient();

seedTestColleges(prisma)
  .catch((error) => {
    console.error("❌ Seeding failed:", error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });