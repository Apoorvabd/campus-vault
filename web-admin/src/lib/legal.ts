// Copied from the app (Help Center and Privacy & Terms screens) so the website says the same thing.

export type Section = { title: string; body: string };

export const LAST_UPDATED = "September 2026";

export const PRIVACY: Section[] = [
  {
    title: "What we collect",
    body: "Your name, college email, course, semester and college are used to personalize your feed and verify your academic standing. Documents you upload are stored either privately on your device (Save Locally) or shared to SemesterForge, depending on the option you choose at upload time.",
  },
  {
    title: "How we use it",
    body: "Academic details help match you with the right subjects and batchmates. Uploaded resources shared to SemesterForge are shown to other verified students from your course and semester.",
  },
  {
    title: "Sharing",
    body: "We never sell your personal data. Resources you save locally never leave your device unless you explicitly choose to share them to SemesterForge.",
  },
  {
    title: "Your controls",
    body: "You can delete any resource you've uploaded, clear your local vault cache from Settings, and request full account deletion at any time from Account Settings.",
  },
];

export const TERMS: Section[] = [
  {
    title: "Academic Integrity",
    body: "SemesterForge is built for genuine peer-to-peer academic resource sharing. Uploading plagiarized, copyrighted, or exam-leaked material is strictly prohibited and may result in account suspension.",
  },
  {
    title: "Content ownership",
    body: "You retain ownership of resources you upload. By sharing to SemesterForge, you grant other verified students in your course a license to view and download it for personal academic use.",
  },
  {
    title: "Community conduct",
    body: "Posts and comments must follow the Honor Code: no harassment, spam, or misinformation. Repeated violations can lead to a permanent ban.",
  },
  {
    title: "Account termination",
    body: "We may suspend accounts that violate these terms. You may also delete your account at any time; your locally saved files remain on your device regardless.",
  },
];

export const HELP_FAQ: { q: string; a: string }[] = [
  {
    q: "How do I upload a resource?",
    a: "Tap the Add tab on the bottom nav, fill in the course, semester and subject, attach your file and choose whether to save it to SemesterForge or keep it locally.",
  },
  {
    q: "Why was my document rejected?",
    a: "Batchmates or moderators can flag a document for being mislabeled, low quality, or violating the Honor Code. You will see the reason on the document's status once reviewed.",
  },
  {
    q: "How does offline storage work?",
    a: "When you save a document with an offline copy, SemesterForge keeps a private copy on your device so you can open it without internet. It never leaves your phone unless you also share it to the Vault.",
  },
  {
    q: "How do I earn XP?",
    a: "You earn XP by uploading resources to SemesterForge, getting upvotes from batchmates, and maintaining a good contributor rating.",
  },
  {
    q: "How do I report inappropriate content?",
    a: "Open the post or resource, tap the overflow menu, and choose Report. Our moderation team reviews every report within 48 hours.",
  },
];
