import {PrismaClient} from '@prisma/client';
import bcrypt from 'bcrypt';


export async function seedUser(prisma: PrismaClient) {

  console.log("Seeding  user...");

  const hashedPassword = await bcrypt.hash(
    "Super@2007",
    10
  );


  await prisma.user.upsert({

    where:{
      email:"mrapoorvchaturvedi7@gmail.com"
    },


    update:{
      role: "STUDENT",
    },


    create:{

      firstName:"Super",
      lastName:"user",

      username:"user1",

      
      email:"mrapoorvchaturvedi7@gmail.com",

      passwordHash: hashedPassword,

      universityId: "cmu34ecar00019kxadldh8gn2",

      collegeId: "cmu34ecvi00049kxarwxvztj4",

      courseId: "cmu34eexq00409kxamowp8h1w",

      currentSemester:5,

      isVerified:true,

      isActive:true
    }

  });


  console.log("✅ user seeded successfully");

}