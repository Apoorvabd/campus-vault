import {PrismaClient} from "@prisma/client";
import { seedUniversity } from "./seed/university.seed";
import { seedCollege } from "./seed/college.seed";
import { seedCourse } from "./seed/courses.seed";
import { seedSubject } from "./seed/subjects.seeed";
// import { seedUser } from "./seed/user.seed";
import { seedAdmin } from "./seed/Admin.seed";
import {seedUser} from "./seed/User.seed";
import {seedTestColleges} from "./seed/LocalCollege.seed";
import {seedResource} from "./seed/Resource.seed";

 const prisma = new PrismaClient();
 async function main() {
    console.log("Seeding database...");
      await seedUniversity(prisma);
      await seedCollege(prisma);
      await seedCourse(prisma);
    //  await seedCollegeCourse(prisma);
      await seedSubject(prisma);
    //  await seedUser(prisma);
    // await seedAdmin(prisma); // admin already exists in DB, this upsert has a pre-existing username-clash bug
      // await seedUser(prisma);
      // await seedTestColleges(prisma);
      await seedResource(prisma); // run after seedSubject, since it looks up existing Subjects
  console.log("✅ Database seeded successfully.");
 }

 main()
 .catch((e) => {
    console.error(e);
 }
).finally(async () => {
    await prisma.$disconnect();
 }
);

//