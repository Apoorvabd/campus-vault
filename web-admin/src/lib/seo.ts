import type { Metadata } from "next";
import { SITE_NAME } from "@/lib/site";

/** The shared share image (src/app/opengraph-image.tsx). Pages that set their own openGraph must name it again. */
const SHARE_IMAGE = { url: "/opengraph-image", width: 1200, height: 630, alt: "SemesterForge: DU PYQs, notes and syllabus in one app" };

/**
 * Metadata for a public page: title, description, canonical, Open Graph and Twitter in one place,
 * so every page gets its own values instead of inheriting the home page's.
 * `title` is the short page title; the layout's template adds "| SemesterForge".
 */
export function pageMetadata({
  title,
  description,
  path,
}: {
  title: string;
  description: string;
  path: string;
}): Metadata {
  const full = `${title} | ${SITE_NAME}`;
  return {
    title,
    description,
    alternates: { canonical: path },
    openGraph: { type: "website", url: path, siteName: SITE_NAME, title: full, description, locale: "en_IN", images: [SHARE_IMAGE] },
    twitter: { card: "summary_large_image", title: full, description, images: [SHARE_IMAGE.url] },
  };
}
