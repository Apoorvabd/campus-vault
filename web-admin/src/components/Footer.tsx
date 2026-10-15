import Image from "next/image";
import Link from "next/link";
import { GITHUB_URL, SUPPORT_EMAIL } from "@/lib/site";

const columns = [
  {
    title: "Product",
    links: [
      ["Features", "/#features"],
      ["For DU students", "/#du"],
      ["Roadmap", "/#roadmap"],
      ["FAQ", "/#faq"],
    ],
  },
  {
    title: "Support",
    links: [
      ["Help Center", "/help"],
      ["Terms of Service", "/terms"],
      ["Privacy Policy", "/privacy"],
    ],
  },
] as const;

/** Site footer: a near-black card with the brand, links, help and contact details. */
export function Footer() {
  return (
    <footer className="w-full border-t border-white/[0.08] bg-[#010102]">
      <div className="w-full px-4 py-12 sm:px-8 lg:px-12">
        <div className="grid gap-12 lg:grid-cols-[1.4fr_1fr_1fr_1.2fr]">
          <div>
            <Link href="/" className="flex items-center gap-3">
              <span className="grid h-11 w-11 place-items-center rounded-xl bg-white">
                <Image src="/logo.svg" alt="" width={34} height={31} />
              </span>
              <span className="text-lg font-semibold tracking-tight">SemesterForge</span>
            </Link>
            <p className="mt-5 max-w-xs text-sm leading-relaxed text-white/55">
              Your whole semester in one app: PYQs, notes, syllabi and your own files, organised by subject for Delhi University students.
            </p>
          </div>

          {columns.map((col) => (
            <nav key={col.title} aria-label={col.title}>
              <h2 className="text-sm font-semibold text-white">{col.title}</h2>
              <ul className="mt-4 space-y-3 text-sm text-white/55">
                {col.links.map(([label, href]) => (
                  <li key={href}>
                    <Link href={href} className="transition hover:text-white">
                      {label}
                    </Link>
                  </li>
                ))}
              </ul>
            </nav>
          ))}

          <div>
            <h2 className="text-sm font-semibold text-white">Contact</h2>
            <ul className="mt-4 space-y-3 text-sm text-white/55">
              <li>
                <a href={`mailto:${SUPPORT_EMAIL}`} className="transition hover:text-white">
                  {SUPPORT_EMAIL}
                </a>
              </li>
              <li>
                <a href={`mailto:${SUPPORT_EMAIL}?subject=Report%20an%20issue`} className="transition hover:text-white">
                  Report an issue
                </a>
              </li>
              <li>
                <a href={GITHUB_URL} target="_blank" rel="noopener noreferrer" className="transition hover:text-white">
                  GitHub
                </a>
              </li>
            </ul>
            <p className="mt-5 text-xs leading-relaxed text-white/40">
              Moderators review every report within 48 hours.
            </p>
          </div>
        </div>

        <div className="mt-12 flex flex-col gap-3 border-t border-white/[0.08] pt-6 text-xs text-white/40 sm:flex-row sm:items-center sm:justify-between">
          <p>© 2026 SemesterForge. A community project for students.</p>
          <p>Not affiliated with or endorsed by Delhi University.</p>
        </div>
      </div>
    </footer>
  );
}
