"use client";

import { motion } from "motion/react";
import Image from "next/image";

const links = [
  ["Features", "#features"],
  ["For DU students", "#du"],
  ["Roadmap", "#roadmap"],
  ["FAQ", "#faq"],
];

export function Nav() {
  return (
    <motion.header
      initial={{ y: -30, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.7, ease: [0.22, 1, 0.36, 1] }}
      className="fixed inset-x-0 top-4 z-50 px-4"
    >
      <nav
        aria-label="Main"
        className="mx-auto flex max-w-4xl items-center justify-between rounded-2xl border border-white/10 bg-[#0f1740]/80 py-2.5 pr-2.5 pl-4 shadow-lg shadow-black/40 backdrop-blur-xl"
      >
        <a href="#top" className="flex items-center gap-2.5">
          <span className="grid h-8 w-8 place-items-center rounded-lg bg-white">
            <Image src="/logo.svg" alt="" width={22} height={17} />
          </span>
          <span className="font-semibold tracking-tight">Semester Forge</span>
        </a>
        <div className="hidden items-center gap-7 text-sm text-muted md:flex">
          {links.map(([label, href]) => (
            <a key={href} href={href} className="transition hover:text-white">
              {label}
            </a>
          ))}
        </div>
        <a
          href="#get-app"
          className="rounded-xl bg-gradient-to-r from-[#6366f1] to-[#ec4899] px-4 py-2 text-sm font-medium text-white transition hover:brightness-110"
        >
          Get the app
        </a>
      </nav>
    </motion.header>
  );
}
