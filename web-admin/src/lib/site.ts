// Canonical domain. Override with NEXT_PUBLIC_SITE_URL only for previews.
export const SITE_URL = (process.env.NEXT_PUBLIC_SITE_URL ?? "https://semesterforge.in").replace(/\/$/, "");

export const SITE_NAME = "SemesterForge";

export const SITE_TITLE = "SemesterForge: DU Notes, PYQs & Syllabus App for Students";

export const SITE_DESCRIPTION =
  "SemesterForge is a student app for University of Delhi: find PYQs, notes, syllabus and lab manuals by course and subject, and keep your own files for exam week.";

export const FAQ = [
  {
    q: "Where can I find DU previous year question papers (PYQs)?",
    a: "SemesterForge organises Delhi University PYQs by course, semester and subject. Pick your course once, and every subject opens straight to its papers, notes and syllabus. You can also search by subject name or UPC code.",
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
    q: "Is SemesterForge an official Delhi University app?",
    a: "No. SemesterForge is a community project built by and for students and is not affiliated with or endorsed by Delhi University.",
  },
  {
    q: "How do I get the app?",
    a: "SemesterForge is available as an Android APK. The download link is going live soon, and the Play Store and iPhone versions are on the roadmap.",
  },
];

/** Same support address the app's Help Center shows. */
export const SUPPORT_EMAIL = "support@semesterforge.app";
export const GITHUB_URL = "https://github.com/Apoorvabd/campus-vault";
