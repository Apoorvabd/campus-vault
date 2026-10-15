import type { Metadata } from "next";
import { LegalPage, SectionList } from "@/components/LegalPage";
import { LAST_UPDATED, TERMS } from "@/lib/legal";

export const metadata: Metadata = {
  title: "Terms of Service",
  description: "The rules for using SemesterForge: academic integrity, content ownership and community conduct.",
  alternates: { canonical: "/terms" },
};

export default function TermsPage() {
  return (
    <LegalPage title="Terms of Service" intro="The ground rules that keep SemesterForge useful for everyone.">
      <SectionList sections={TERMS} />
      <p className="mt-8 text-sm text-white/40">Last updated: {LAST_UPDATED}</p>
    </LegalPage>
  );
}
