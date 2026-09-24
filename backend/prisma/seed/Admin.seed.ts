import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

export async function seedAdmin(prisma: PrismaClient) {

  console.log("Seeding admin user...");

  const hashedPassword = await bcrypt.hash(
    "SUPERapplication@2007",
    10
  );


  await prisma.user.upsert({

    where:{
      email:"admin@campusvault.com"
    },


    update:{
      role: "SUPER_ADMIN",
    },


    create:{

      firstName:"Super",
      lastName:"Admin",

      username:"superadmin",

      email:"apoooorvabd@gmail.com",

      passwordHash:hashedPassword,

      role: "SUPER_ADMIN",

      universityId: "cmu34ecar00019kxadldh8gn2",

      collegeId: "cmu34ecvi00049kxarwxvztj4",

      courseId: "cmu34eexq00409kxamowp8h1w",

      currentSemester:5,

      isVerified:true,

      isActive:true
    }

  });


  console.log("✅ Admin seeded successfully");

}