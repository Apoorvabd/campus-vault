"use client";

import { motion } from "motion/react";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";

const links = [
  ["Features", "/#features"],
  ["For DU students", "/#du"],
  ["Roadmap", "/#roadmap"],
  ["FAQ", "/#faq"],
];

export function Nav() {
  // The bar slides away while the footer is on screen and slides back when it leaves.
  const [hidden, setHidden] = useState(false);

  useEffect(() => {
    const update = () => {
      const footer = document.querySelector("footer");
      if (!footer) return;
      const footerShown = footer.getBoundingClientRect().top < window.innerHeight - 40;
      // Not on very short pages where the footer is visible without scrolling.
      setHidden(footerShown && window.scrollY > 80);
    };
    update();
    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);
    return () => {
      window.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, []);

  return (
    <motion.header
      initial={false}
      animate={hidden ? { y: "-110%", opacity: 0 } : { y: 0, opacity: 1 }}
      transition={{ duration: hidden ? 0.45 : 0.55, ease: [0.22, 1, 0.36, 1] }}
      aria-hidden={hidden}
      className="fixed inset-x-0 top-0 z-50"
      style={{ pointerEvents: hidden ? "none" : "auto" }}
    >
      <nav
        aria-label="Main"
        className="flex w-full items-center justify-between border-b border-white/[0.08] bg-[#010102]/95 px-4 py-2.5 shadow-lg shadow-black/40 backdrop-blur-xl sm:px-8 lg:px-12"
      >
        <Link href="/" className="flex items-center gap-2.5">
          <span className="grid h-10 w-10 place-items-center rounded-xl bg-white">
            <Image src="/logo.svg" alt="" width={34} height={31} />
          </span>
          <span className="font-semibold tracking-tight">SemesterForge</span>
        </Link>
        <div className="flex items-center gap-8">
          <div className="hidden items-center gap-7 text-sm text-muted md:flex">
            {links.map(([label, href]) => (
              <a key={href} href={href} className="transition hover:text-white">
                {label}
              </a>
            ))}
          </div>
          <Link
            href="/#get-app"
            className="rounded-xl bg-gradient-to-r from-[#6366f1] to-[#ec4899] px-4 py-2 text-sm font-medium text-white transition hover:brightness-110"
          >
            Get the app
          </Link>
        </div>
      </nav>
    </motion.header>
  );
}
