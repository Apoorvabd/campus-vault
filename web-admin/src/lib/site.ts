// Set NEXT_PUBLIC_SITE_URL in the deployment environment to the real domain.
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000").replace(/\/$/, "");

export const SITE_NAME = "Semester Forge";

export const SITE_TITLE = "Semester Forge: DU PYQs, Notes & Syllabus for Delhi University Students";

export const SITE_DESCRIPTION =
  "Delhi University (DU) previous year question papers, notes, syllabus and lab manuals organised by course, subject and semester. 118 courses, 5,500+ subjects, one Android app for exam week.";

export const FAQ = [
  {
    q: "Where can I find DU previous year question papers (PYQs)?",
    a: "Semester Forge organises Delhi University PYQs by course, semester and subject. Pick your course once, and every subject opens straight to its papers, notes and syllabus. You can also search by subject name or UPC code.",
  },
  {
    q: "Which DU courses and colleges are covered?",
    a: "The catalogue covers 118 courses, 5,500+ subjects and 70+ colleges, including B.A., B.Com, B.Sc., B.Voc and more. If something is missing, you can add it yourself and it goes live after an admin approves it.",
  },
  {
    q: "Can I upload my own notes and papers?",
    a: "Yes. Add a PDF, photos from your gallery, a camera scan or a link to a Drive file. Every upload is reviewed by an admin before other students can see it, which keeps the Vault clean.",
  },
  {
    q: "Can I keep my files private on my phone?",
    a: "Yes. You can bind a file that is already on your phone to a subject without uploading it anywhere. Share it with everyone only if you choose to.",
  },
  {
    q: "Is Semester Forge an official Delhi University app?",
    a: "No. Semester Forge is a community project built by and for students and is not affiliated with or endorsed by Delhi University.",
  },
  {
    q: "How do I get the app?",
    a: "Semester Forge is available as an Android APK. The download link is going live soon, and the Play Store and iPhone versions are on the roadmap.",
  },
];
