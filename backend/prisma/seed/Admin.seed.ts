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

      universityId: "cmtn6aslx00009kb3uhu10tsb",

      collegeId: "cmtn6e9c1002b9kmckligwi0l",

      courseId: "cmtn6skc2005z9kj82xt37us4",

      currentSemester:5,

      isVerified:true,

      isActive:true
    }

  });


  console.log("✅ Admin seeded successfully");

}