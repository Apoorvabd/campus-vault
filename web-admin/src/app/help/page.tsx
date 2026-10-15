import type { Metadata } from "next";
import { LegalPage } from "@/components/LegalPage";
import { HELP_FAQ } from "@/lib/legal";
import { SUPPORT_EMAIL } from "@/lib/site";

export const metadata: Metadata = {
  title: "Help Center",
  description: "Answers about uploading resources, offline storage, XP, rejected documents and reporting content in SemesterForge.",
  alternates: { canonical: "/help" },
};

const actions = [
  ["Contact Support", `mailto:${SUPPORT_EMAIL}`, "Questions, feedback or something not working."],
  ["Report an Issue", `mailto:${SUPPORT_EMAIL}?subject=Report%20an%20issue`, "Found a bug or a wrong resource? Tell us."],
] as const;

export default function HelpPage() {
  return (
    <LegalPage title="Help Center & Issues" intro="Quick answers, and how to reach us if you need more.">
      <div className="grid gap-4 sm:grid-cols-2">
        {actions.map(([label, href, hint]) => (
          <a key={label} href={href} className="card-flat rounded-2xl p-6 transition hover:-translate-y-1">
            <h2 className="font-semibold text-white">{label}</h2>
            <p className="mt-2 text-sm text-muted">{hint}</p>
          </a>
        ))}
      </div>

      <h2 className="grad-warm mt-14 text-2xl font-bold tracking-tight">Frequently Asked Questions</h2>
      <div className="mt-6 space-y-3">
        {HELP_FAQ.map((f) => (
          <details key={f.q} className="card-flat group rounded-2xl px-6 py-5 open:border-white/25">
            <summary className="flex cursor-pointer items-center justify-between gap-4 text-left">
              <h3 className="text-base font-medium sm:text-lg">{f.q}</h3>
              <span className="faq-plus grid h-7 w-7 shrink-0 place-items-center rounded-full bg-white/10 text-lg leading-none transition-transform">+</span>
            </summary>
            <p className="mt-3 leading-relaxed text-muted">{f.a}</p>
          </details>
        ))}
      </div>

      <div className="mt-12 text-center">
        <p className="font-medium">Still need help?</p>
        <p className="mt-1 text-sm text-muted">
          Email us at{" "}
          <a className="text-[#a5b4fc] underline-offset-4 hover:underline" href={`mailto:${SUPPORT_EMAIL}`}>
            {SUPPORT_EMAIL}
          </a>
        </p>
      </div>
    </LegalPage>
  );
}
