import type { ReactNode } from "react";
import { Footer } from "@/components/Footer";
import { Nav } from "@/components/Nav";

/** Shared shell for the Help, Terms and Privacy pages. */
export function LegalPage({ title, intro, children }: { title: string; intro?: string; children: ReactNode }) {
  return (
    <div className="relative flex min-h-screen flex-col">
      <Nav />
      <main className="mx-auto w-full max-w-3xl flex-1 px-6 pt-32 pb-24">
        <h1 className="grad-title text-4xl font-bold tracking-tight sm:text-5xl">{title}</h1>
        {intro && <p className="mt-4 text-lg text-muted">{intro}</p>}
        <div className="mt-10">{children}</div>
      </main>
      <Footer />
    </div>
  );
}

export function SectionList({ sections }: { sections: { title: string; body: string }[] }) {
  return (
    <div className="space-y-4">
      {sections.map((s) => (
        <section key={s.title} className="card-flat rounded-2xl p-6">
          <h2 className="font-semibold text-[#a5b4fc]">{s.title}</h2>
          <p className="mt-2 leading-relaxed text-muted">{s.body}</p>
        </section>
      ))}
    </div>
  );
}
