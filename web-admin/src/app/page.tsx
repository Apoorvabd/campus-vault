import Image from "next/image";
import { Counter } from "@/components/Counter";
import { Nav } from "@/components/Nav";
import { HeroPhone } from "@/components/HeroPhone";
import { Phone } from "@/components/Phone";
import { Reveal } from "@/components/Reveal";
import { Statement } from "@/components/Statement";
import { FAQ, SITE_DESCRIPTION, SITE_NAME, SITE_URL } from "@/lib/site";

const features = [
  {
    id: "vault",
    eyebrow: "The Vault",
    title: "Your subjects, sorted for you.",
    body: "Pick your course and semester once. Every subject shows up with its code and type, and opens straight to its papers, notes and syllabus.",
    points: ["Search notes and PYQs from one bar", "Subjects grouped by your semester", "Bookmark anything for later"],
    src: "/screens/subjects.png",
    alt: "Semester Forge Resources tab listing the student's subjects for the semester",
    glow: "bg-brand/45",
    accent: "text-[#8fb0ff]",
  },
  {
    id: "add",
    eyebrow: "Contribute",
    title: "Add what helped you, from anywhere.",
    body: "Upload a PDF, pick photos from your gallery, snap a page with the camera or paste a Drive link. Everything is reviewed by an admin before others see it.",
    points: ["Files, photos, camera or link", "Reviewed before it goes public", "Earn credit when it helps others"],
    src: "/screens/add.png",
    alt: "Add Document screen with Files, Photos, Camera and Link options",
    glow: "bg-violet/40",
    accent: "text-[#b69cff]",
  },
  {
    id: "tag",
    eyebrow: "Organised",
    title: "Tagged right, found fast.",
    body: "Give it a title, pick the subject and mark it as a PYQ, notes, syllabus, reference book, assignment or lab manual. Clean tags are what keep the Vault easy to search.",
    points: ["PYQ, notes, syllabus, lab manual and more", "Linked to the exact subject", "Optional description for exam year or unit"],
    src: "/screens/form.png",
    alt: "Add Document form with title, subject and category fields",
    glow: "bg-teal/35",
    accent: "text-[#5eead4]",
  },
  {
    id: "profile",
    eyebrow: "Your profile",
    title: "Your course, your college, your credit.",
    body: "Your profile keeps your course, semester and college in one place, with your uploads, posts and likes counted. Requests and contributor badges are coming right behind it.",
    points: ["Uploads, posts and likes at a glance", "Resource requests", "Contributor badges"],
    src: "/screens/profile.png",
    alt: "Profile screen showing course, semester, college and upload stats",
    glow: "bg-pink/35",
    accent: "text-[#f9a8d4]",
  },
];

const moreColors = ["from-brand/25", "from-violet/25", "from-teal/25", "from-pink/25"];

const duCourses = ["B.A. (Hons)", "B.Com (Hons)", "B.Sc. (Hons)", "B.Voc", "B.Tech", "BBA", "Programme courses", "70+ colleges"];

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    { "@type": "WebSite", "@id": `${SITE_URL}/#website`, url: SITE_URL, name: SITE_NAME, description: SITE_DESCRIPTION, inLanguage: "en-IN" },
    {
      "@type": "SoftwareApplication",
      name: SITE_NAME,
      applicationCategory: "EducationalApplication",
      operatingSystem: "Android",
      description: SITE_DESCRIPTION,
      audience: { "@type": "EducationalAudience", educationalRole: "student" },
      url: SITE_URL,
    },
    {
      "@type": "FAQPage",
      mainEntity: FAQ.map((f) => ({ "@type": "Question", name: f.q, acceptedAnswer: { "@type": "Answer", text: f.a } })),
    },
  ],
};

const more = [
  ["Approval workflow", "Uploads are reviewed before they appear. Quality stays high."],
  ["Reputation", "Contribute approved material and your credit shows on your profile."],
  ["Three ways to store", "Hosted, external link, or reference only. Whatever you have works."],
  ["A feed with a voice", "Updates and discussions from your campus. Like, comment and bookmark."],
];

const stats = [
  { n: 118, s: "", label: "Courses covered" },
  { n: 5500, s: "+", label: "Subjects" },
  { n: 18000, s: "+", label: "Papers indexed" },
  { n: 70, s: "+", label: "Colleges" },
];

const statColors = ["from-brand/30", "from-violet/30", "from-teal/30", "from-pink/30"];

const chips = [
  "Previous year papers", "Notes", "Syllabus", "Lab manuals", "Exam Mode", "Bookmarks",
  "Community feed", "Local files", "Reputation", "Approval workflow",
];

const roadmap = [
  { tag: "In the works", title: "Exam Mode", body: "A dedicated exam-week screen per subject: everything you collected, in one scroll, with a countdown." },
  { tag: "In the works", title: "Resource requests", body: "Can't find a paper? Request it and get notified when someone uploads it." },
  { tag: "Planned", title: "Badges and levels", body: "Real contributor badges and XP, based on how much your uploads help others." },
  { tag: "Planned", title: "Notifications", body: "Know when a request is fulfilled, an upload is approved, or a post gets a reply." },
  { tag: "Planned", title: "Offline downloads", body: "Save papers on your device and study without internet." },
  { tag: "Planned", title: "Campus sign-in", body: "Log in with your university account and skip the password." },
  { tag: "Planned", title: "Admin console", body: "A web panel for admins to review uploads and manage subjects and users." },
  { tag: "Later", title: "Play Store and iPhone", body: "Today the app is an APK. Official stores and iOS come next." },
];

const tagStyle: Record<string, string> = {
  "In the works": "bg-teal/20 text-[#5eead4]",
  Planned: "bg-violet/20 text-[#c4b5fd]",
  Later: "bg-pink/20 text-[#f9a8d4]",
};

function StoreBadge({ label, sub }: { label: string; sub: string }) {
  return (
    <span className="inline-flex items-center gap-3 rounded-xl border border-white/15 bg-black/60 px-5 py-2.5 text-left backdrop-blur">
      <span className="text-[10px] leading-tight text-white/60">
        {sub}
        <span className="block text-base font-semibold text-white">{label}</span>
      </span>
    </span>
  );
}

export default function Home() {
  return (
    <div id="top" className="relative overflow-x-clip">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd).replace(/</g, "\\u003c") }}
      />
      <Nav />

      {/* HERO */}
      <section className="relative flex min-h-[100svh] flex-col items-center px-6 pt-36 text-center">
        <div className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[900px] bg-[radial-gradient(60%_50%_at_50%_0%,rgba(99,102,241,0.4),transparent_70%),radial-gradient(40%_35%_at_85%_20%,rgba(236,72,153,0.22),transparent_70%),radial-gradient(35%_30%_at_10%_30%,rgba(20,184,166,0.2),transparent_70%)]" />
        <Reveal>
          <p className="mx-auto mb-6 inline-block rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-xs text-white/70">
            DU PYQs, notes &amp; syllabus in one app
          </p>
        </Reveal>
        <Reveal delay={60}>
          <h1 className="mx-auto max-w-4xl text-5xl leading-[1.02] font-bold tracking-tight sm:text-7xl lg:text-[5.5rem]">
            <span className="grad-title">Your whole semester.</span>
            <br />
            <span className="grad-warm">One app.</span>
          </h1>
        </Reveal>
        <Reveal delay={120}>
          <p className="mx-auto mt-6 max-w-xl text-lg text-muted">
            Delhi University previous year question papers (PYQs), notes, syllabi and your own files, organised by course and subject, so exam week starts with opening the app.
          </p>
        </Reveal>
        <Reveal delay={180}>
          <div id="get-app" className="mt-9 flex flex-wrap items-center justify-center gap-3 scroll-mt-32">
            <StoreBadge sub="Download for" label="Android (APK)" />
            <StoreBadge sub="Coming to" label="iPhone" />
          </div>
          <p className="mt-3 text-xs text-white/40">Download link going live soon</p>
        </Reveal>

        <HeroPhone />
      </section>

      {/* STATEMENT */}
      <section className="relative mx-auto max-w-4xl px-6 py-28 text-center sm:py-40">
        <div className="pointer-events-none absolute inset-x-0 top-1/2 -z-10 mx-auto h-72 max-w-2xl -translate-y-1/2 rounded-full bg-violet/20 blur-[120px]" />
        <Statement
          parts={[
            { text: "The night before the exam, you don't need more apps. You need" },
            { text: "everything for one subject,", warm: true },
            { text: "in one place." },
          ]}
        />
      </section>

      {/* FEATURES */}
      <section id="features" className="mx-auto max-w-6xl scroll-mt-28 space-y-32 px-6 pb-32">
        {features.map((f, i) => (
          <div
            key={f.id}
            className={`grid items-center gap-12 lg:grid-cols-2 ${i % 2 ? "lg:[&>*:first-child]:order-2" : ""}`}
          >
            <Reveal>
              <p className={`text-sm font-medium ${f.accent}`}>{f.eyebrow}</p>
              <h2 className="grad-title mt-3 text-4xl leading-tight font-bold tracking-tight sm:text-5xl">{f.title}</h2>
              <p className="mt-5 max-w-lg text-lg text-muted">{f.body}</p>
              <ul className={`mt-6 space-y-2.5 ${f.accent}`}>
                {f.points.map((p) => (
                  <li key={p} className="flex items-center gap-3 text-white/85">
                    <span className="h-1.5 w-1.5 rounded-full bg-current opacity-80" />
                    {p}
                  </li>
                ))}
              </ul>
            </Reveal>
            <Reveal variant="phone" delay={100} className="relative flex justify-center">
              <div className={`absolute top-1/2 left-1/2 h-72 w-72 -translate-x-1/2 -translate-y-1/2 rounded-full blur-[110px] ${f.glow}`} />
              <Phone src={f.src} alt={f.alt} />
            </Reveal>
          </div>
        ))}
      </section>

      {/* MORE */}
      <section className="mx-auto max-w-6xl px-6 pb-32">
        <Reveal>
          <h2 className="grad-title mx-auto max-w-2xl text-center text-4xl font-bold tracking-tight sm:text-5xl">
            Built to keep the signal high.
          </h2>
        </Reveal>
        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {more.map(([t, b], i) => (
            <Reveal key={t} delay={i * 60} lift className="h-full">
              <div className={`h-full rounded-3xl border border-white/10 bg-gradient-to-b ${moreColors[i]} to-white/[0.02] p-6 transition hover:border-white/25`}>
                <h3 className="font-semibold">{t}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{b}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* MARQUEE */}
      <section className="marquee overflow-hidden py-6 [mask-image:linear-gradient(to_right,transparent,black_15%,black_85%,transparent)]">
        <div className="marquee-track gap-3" style={{ "--speed": "45s" } as React.CSSProperties}>
          {[...chips, ...chips].map((c, i) => (
            <span key={i} className="mr-3 rounded-full border border-white/15 bg-white/[0.07] px-6 py-3 text-lg whitespace-nowrap text-white/80">
              {c}
            </span>
          ))}
        </div>
      </section>

      {/* NUMBERS */}
      <section id="numbers" className="mx-auto max-w-6xl scroll-mt-28 px-6 py-32">
        <Reveal>
          <h2 className="grad-title text-center text-4xl font-bold tracking-tight sm:text-5xl">Already a lot inside.</h2>
          <p className="mx-auto mt-4 max-w-xl text-center text-muted">
            A big catalogue to start from, and a community that keeps adding to it.
          </p>
        </Reveal>
        <div className="mt-14 grid grid-cols-2 gap-4 lg:grid-cols-4">
          {stats.map((s, i) => (
            <Reveal key={s.label} lift className="h-full">
              <div className={`rounded-3xl border border-white/10 bg-gradient-to-b ${statColors[i]} to-transparent p-8 text-center`}>
                <p className="text-4xl font-bold tracking-tight sm:text-5xl">
                  <Counter to={s.n} suffix={s.s} />
                </p>
                <p className="mt-2 text-sm text-muted">{s.label}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* FOR DU STUDENTS */}
      <section id="du" className="mx-auto max-w-6xl scroll-mt-28 px-6 pb-32">
        <div className="grid items-center gap-12 rounded-[2rem] border border-white/10 bg-gradient-to-br from-indigo-500/20 via-fuchsia-500/10 to-teal-400/15 p-8 sm:p-14 lg:grid-cols-2">
          <Reveal>
            <p className="text-sm font-medium text-[#5eead4]">Made for Delhi University</p>
            <h2 className="grad-title mt-3 text-4xl leading-tight font-bold tracking-tight sm:text-5xl">
              DU PYQs, notes and syllabus, by subject.
            </h2>
            <p className="mt-5 text-lg text-muted">
              Looking for DU previous year question papers? Semester Forge keeps them next to your notes, syllabus and lab manuals, grouped by course, semester and UPC, so you stop hunting across groups and drives.
            </p>
          </Reveal>
          <Reveal delay={100}>
            <div className="flex flex-wrap gap-3">
              {duCourses.map((c) => (
                <span key={c} className="rounded-full border border-white/15 bg-white/[0.07] px-5 py-2.5 text-white/85">
                  {c}
                </span>
              ))}
            </div>
            <p className="mt-6 text-sm text-white/50">
              Community project, not affiliated with Delhi University.
            </p>
          </Reveal>
        </div>
      </section>

      {/* ROADMAP */}
      <section id="roadmap" className="mx-auto max-w-6xl scroll-mt-28 px-6 pb-32">
        <Reveal>
          <p className="text-center text-sm font-medium text-[#5eead4]">Where we&apos;re headed</p>
          <h2 className="grad-warm mx-auto mt-3 max-w-2xl text-center text-4xl font-bold tracking-tight sm:text-5xl">
            This is just the start.
          </h2>
          <p className="mx-auto mt-4 max-w-xl text-center text-muted">
            Semester Forge grows with the students using it. Here is what we are building next.
          </p>
        </Reveal>
        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {roadmap.map((r, i) => (
            <Reveal key={r.title} delay={(i % 4) * 60} lift className="h-full">
              <div className="h-full rounded-3xl border border-white/10 bg-white/[0.05] p-6">
                <span className={`rounded-full px-3 py-1 text-xs font-medium ${tagStyle[r.tag]}`}>{r.tag}</span>
                <h3 className="mt-4 text-lg font-semibold">{r.title}</h3>
                <p className="mt-2 text-sm leading-relaxed text-muted">{r.body}</p>
              </div>
            </Reveal>
          ))}
        </div>
      </section>

      {/* FAQ */}
      <section id="faq" className="mx-auto max-w-3xl scroll-mt-28 px-6 pb-32">
        <Reveal>
          <h2 className="grad-title text-center text-4xl font-bold tracking-tight sm:text-5xl">Questions, answered.</h2>
        </Reveal>
        <div className="mt-12 space-y-3">
          {FAQ.map((f, i) => (
            <Reveal key={f.q} delay={i * 40}>
              <details className="group rounded-2xl border border-white/10 bg-white/[0.05] px-6 py-5 transition open:border-white/25 open:bg-white/[0.08]">
                <summary className="flex cursor-pointer items-center justify-between gap-4 text-left font-medium">
                  <h3 className="text-base font-medium sm:text-lg">{f.q}</h3>
                  <span className="faq-plus grid h-7 w-7 shrink-0 place-items-center rounded-full bg-gradient-to-br from-indigo-500 to-pink-500 text-lg leading-none transition-transform">+</span>
                </summary>
                <p className="mt-3 leading-relaxed text-muted">{f.a}</p>
              </details>
            </Reveal>
          ))}
        </div>
      </section>

      {/* CTA */}
      <section className="relative px-6 pb-28 text-center">
        <div className="pointer-events-none absolute inset-x-0 bottom-0 -z-10 h-[500px] bg-[radial-gradient(50%_60%_at_50%_100%,rgba(139,92,246,0.4),transparent_70%)]" />
        <Reveal>
          <h2 className="grad-warm mx-auto max-w-3xl text-5xl leading-tight font-bold tracking-tight sm:text-6xl">
            Walk into exam week ready.
          </h2>
          <div className="mt-9 flex flex-wrap items-center justify-center gap-3">
            <StoreBadge sub="Download for" label="Android (APK)" />
          </div>
          <p className="mt-3 text-xs text-white/40">Download link going live soon</p>
        </Reveal>
      </section>

      {/* FOOTER */}
      <footer className="border-t border-white/10 px-6 py-10">
        <div className="mx-auto flex max-w-6xl flex-col items-center justify-between gap-4 text-sm text-white/50 sm:flex-row">
          <div className="flex items-center gap-2.5">
            <span className="grid h-7 w-7 place-items-center rounded-md bg-white">
              <Image src="/logo.svg" alt="" width={18} height={14} />
            </span>
            <span className="font-medium text-white/80">Semester Forge</span>
          </div>
          <p>A community project for students. © 2026</p>
        </div>
      </footer>
    </div>
  );
}
