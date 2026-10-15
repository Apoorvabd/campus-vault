import type { Metadata } from "next";
import Link from "next/link";
import { LegalPage } from "@/components/LegalPage";

// Served with a real 404 status. Kept out of search results.
export const metadata: Metadata = {
  title: "Page not found",
  robots: { index: false, follow: true },
};

export default function NotFound() {
  return (
    <LegalPage title="Page not found" intro="That page doesn't exist or has moved.">
      <ul className="space-y-3 text-lg">
        <li>
          <Link href="/" className="text-[#a5b4fc] underline-offset-4 hover:underline">
            Go to the SemesterForge home page
          </Link>
        </li>
        <li>
          <Link href="/help" className="text-[#a5b4fc] underline-offset-4 hover:underline">
            Visit the SemesterForge Help Center
          </Link>
        </li>
      </ul>
    </LegalPage>
  );
}
