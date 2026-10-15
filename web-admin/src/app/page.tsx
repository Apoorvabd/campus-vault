import { Counter } from "@/components/Counter";
import { Nav } from "@/components/Nav";
import { Footer } from "@/components/Footer";
import { Particles } from "@/components/Particles";
import { PhoneCarousel } from "@/components/PhoneCarousel";
import { Phone } from "@/components/Phone";
import { Reveal } from "@/components/Reveal";
import { ShakeHeading } from "@/components/ShakeHeading";
import { Statement } from "@/components/Statement";
import Link from "next/link";
import { FAQ, GITHUB_URL, SITE_DESCRIPTION, SITE_NAME, SITE_URL, SUPPORT_EMAIL } from "@/lib/site";

const features = [
  {
    id: "vault",
    eyebrow: "The Vault",
    title: "Your subjects, sorted for you.",
    body: "Pick your course and semester once. Every subject shows up with its code and type, and opens straight to its papers, notes and syllabus.",
    points: ["Search notes and PYQs from one bar", "Subjects grouped by your semester", "Bookmark anything for later"],
    src: "/screens/subjects.webp",
    alt: "SemesterForge Resources tab listing the student's subjects for the semester",
    glow: "bg-brand/45",
    accent: "text-[#8fb0ff]",
  },
  {
    id: "add",
    eyebrow: "Contribute",
    title: "Add what helped you, from anywhere.",
    body: "Upload a PDF, pick photos from your gallery, snap a page with the camera or paste a Drive link. Everything is reviewed by an admin before others see it.",
    points: ["Files, photos, camera or link", "Reviewed before it goes public", "Earn credit when it helps others"],
    src: "/screens/add.webp",
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
    src: "/screens/form.webp",
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
    src: "/screens/profile.webp",
    alt: "Profile screen showing course, semester, college and upload stats",
    glow: "bg-pink/35",
    accent: "text-[#f9a8d4]",
  },
];

const duCourses = ["B.A. (Hons)", "B.Com (Hons)", "B.Sc. (Hons)", "B.Voc", "B.Tech", "BBA", "Programme courses", "70+ colleges"];

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "Organization",
      "@id": `${SITE_URL}/#organization`,
      name: SITE_NAME,
      url: SITE_URL,
      logo: { "@type": "ImageObject", url: `${SITE_URL}/apple-icon`, width: 180, height: 180 },
      sameAs: [GITHUB_URL],
      contactPoint: { "@type": "ContactPoint", contactType: "customer support", email: SUPPORT_EMAIL },
    },
    {
      "@type": "WebSite",
      "@id": `${SITE_URL}/#website`,
      url: SITE_URL,
      name: SITE_NAME,
      description: SITE_DESCRIPTION,
      inLanguage: "en-IN",
      publisher: { "@id": `${SITE_URL}/#organization` },
    },
    {
      "@type": "SoftwareApplication",
      name: SITE_NAME,
      applicationCategory: "EducationalApplication",
      operatingSystem: "Android",
      description: SITE_DESCRIPTION,
      audience: { "@type": "EducationalAudience", educationalRole: "student" },
      url: SITE_URL,
      publisher: { "@id": `${SITE_URL}/#organization` },
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
      <Particles />
      <Nav />

      {/* HERO */}
      <section className="relative flex min-h-[100svh] items-center px-6 pt-32 pb-16 lg:pt-24">
        <div className="pointer-events-none absolute inset-x-0 top-0 -z-10 h-[900px] bg-[radial-gradient(60%_50%_at_30%_0%,rgba(79,70,229,0.3),transparent_70%),radial-gradient(40%_35%_at_90%_30%,rgba(190,24,93,0.18),transparent_70%),radial-gradient(35%_30%_at_5%_40%,rgba(13,148,136,0.15),transparent_70%)]" />
        <div className="mx-auto grid w-full max-w-6xl items-center gap-10 lg:grid-cols-[1.1fr_0.9fr] lg:gap-6">
          <div className="text-center lg:pl-14 lg:text-left">
            <div className="hero-in">
              <ShakeHeading className="max-w-3xl font-bold tracking-tight">
                <span className="mx-auto mb-6 block w-fit rounded-full border border-white/20 bg-[#0d1030] px-4 py-1.5 text-xs font-medium tracking-normal text-white shadow-[0_8px_24px_-10px_rgba(0,0,0,0.8)] lg:mx-0">
                  DU PYQs, notes &amp; syllabus in one app
                </span>
                <span className="grad-title block text-[2.06rem] leading-tight font-semibold sm:text-[2.475rem] lg:text-[2.86rem]">
                  Your whole semester.
                </span>
                <span className="grad-warm mt-1 block text-[4.05rem] leading-[0.95] sm:text-[5.4rem] lg:text-[6.75rem]">One app</span>
              </ShakeHeading>
            </div>
            <div className="hero-in" style={{ "--d": "120ms" } as React.CSSProperties}>
              <p className="mx-auto mt-6 max-w-xl text-lg text-muted lg:mx-0">
                Delhi University previous year question papers (PYQs), notes, syllabi and your own files, organised by course and subject, so exam week starts with opening the app.
              </p>
            </div>
            <div className="hero-in" style={{ "--d": "180ms" } as React.CSSProperties}>
              <div id="get-app" className="mt-9 flex scroll-mt-32 flex-wrap items-center justify-center gap-3 lg:justify-start">
                <StoreBadge sub="Download for" label="Android (APK)" />
                <StoreBadge sub="Coming to" label="iPhone" />
              </div>
              <p className="mt-3 text-xs text-white/40">Download link going live soon</p>
            </div>
          </div>

          <div className="hero-in" style={{ "--d": "250ms" } as React.CSSProperties}>
            <PhoneCarousel />
          </div>
        </div>
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
              <div className="card-flat float-card h-full rounded-3xl p-6" style={{ animationDelay: `${(i % 4) * 0.7}s` }}>
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
              <div className="card-flat float-card rounded-3xl p-8 text-center" style={{ animationDelay: `${i * 0.8}s` }}>
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
        <div className="card-flat grid items-center gap-12 rounded-[2rem] p-8 sm:p-14 lg:grid-cols-2">
          <Reveal>
            <p className="text-sm font-medium text-[#5eead4]">Made for Delhi University</p>
            <h2 className="grad-title mt-3 text-4xl leading-tight font-bold tracking-tight sm:text-5xl">
              DU PYQs, notes and syllabus, by subject.
            </h2>
            <p className="mt-5 text-lg text-muted">
              Looking for DU previous year question papers? SemesterForge keeps them next to your notes, syllabus and lab manuals, grouped by course, semester and UPC, so you stop hunting across groups and drives.
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
            SemesterForge grows with the students using it. Here is what we are building next.
          </p>
        </Reveal>
        <div className="mt-14 grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {roadmap.map((r, i) => (
            <Reveal key={r.title} delay={(i % 4) * 60} lift className="h-full">
              <div className="card-flat float-card h-full rounded-3xl p-6" style={{ animationDelay: `${(i % 4) * 0.7}s` }}>
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
              <details className="card-flat group rounded-2xl px-6 py-5 open:border-white/25">
                <summary className="flex cursor-pointer items-center justify-between gap-4 text-left font-medium">
                  <h3 className="text-base font-medium sm:text-lg">{f.q}</h3>
                  <span className="faq-plus grid h-7 w-7 shrink-0 place-items-center rounded-full bg-gradient-to-br from-indigo-500 to-pink-500 text-lg leading-none transition-transform">+</span>
                </summary>
                <p className="mt-3 leading-relaxed text-muted">{f.a}</p>
              </details>
            </Reveal>
          ))}
        </div>
        <p className="mt-8 text-center text-sm text-muted">
          More answers about uploads, XP and reports are in the{" "}
          <Link href="/help" className="text-[#a5b4fc] underline-offset-4 hover:underline">
            SemesterForge Help Center
          </Link>
          .
        </p>
      </section>

      {/* CTA */}
      <section className="relative px-6 pb-28 text-center">
        <div className="pointer-events-none absolute inset-x-0 bottom-0 -z-10 h-[500px] bg-[radial-gradient(50%_60%_at_50%_100%,rgba(109,40,217,0.3),transparent_70%)]" />
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

      <Footer />
    </div>
  );
}
