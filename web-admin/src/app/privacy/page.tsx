import type { Metadata } from "next";
import { pageMetadata } from "@/lib/seo";
import { LegalPage, SectionList } from "@/components/LegalPage";
import { LAST_UPDATED, PRIVACY } from "@/lib/legal";

export const metadata: Metadata = pageMetadata({
  title: "Privacy Policy",
  description:
    "What the SemesterForge app collects, how it is used, who it is shared with, and the controls you have over your data.",
  path: "/privacy",
});

export default function PrivacyPage() {
  return (
    <LegalPage title="Privacy Policy" intro="What we collect, how we use it, and what you control.">
      <SectionList sections={PRIVACY} />
      <p className="mt-8 text-sm text-white/40">Last updated: {LAST_UPDATED}</p>
    </LegalPage>
  );
}
