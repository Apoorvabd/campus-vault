import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { LegalPage, SectionList } from "@/components/LegalPage";
import { LAST_UPDATED, TERMS } from "@/lib/legal";

export const metadata: Metadata = pageMetadata({
  title: "Terms of Service",
  description:
    "The rules for using the SemesterForge app: academic integrity, content ownership, community conduct and account termination.",
  path: "/terms",
});

export default function TermsPage() {
  return (
    <LegalPage title="Terms of Service" intro="The ground rules that keep SemesterForge useful for everyone.">
      <SectionList sections={TERMS} />
      <p className="mt-8 text-sm text-white/40">Last updated: {LAST_UPDATED}</p>
    </LegalPage>
  );
}
