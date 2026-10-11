"use client";

import { motion, useReducedMotion, useScroll, useTransform } from "motion/react";
import { Phone } from "@/components/Phone";

/** Hero phone. Rises in on load and drifts with scroll. */
export function HeroPhone() {
  const reduce = useReducedMotion();
  const { scrollY } = useScroll();
  const y = useTransform(scrollY, [0, 700], [0, reduce ? 0 : -90]);
  const glowY = useTransform(scrollY, [0, 700], [0, reduce ? 0 : 60]);

  return (
    <div className="relative mt-16 flex w-full justify-center [mask-image:linear-gradient(to_bottom,black_55%,transparent)]">
      <motion.div style={{ y: glowY }} className="absolute inset-0 flex justify-center">
        <div className="absolute top-10 h-72 w-72 rounded-full bg-brand/50 blur-[110px]" />
        <div className="absolute top-24 -ml-60 h-56 w-56 rounded-full bg-pink/35 blur-[100px]" />
        <div className="absolute top-40 ml-64 h-48 w-48 rounded-full bg-teal/30 blur-[100px]" />
      </motion.div>
      <motion.div
        style={{ y }}
        initial={reduce ? false : { opacity: 0, y: 120, scale: 0.94 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.9, delay: 0.35, ease: [0.22, 1, 0.36, 1] }}
      >
        <Phone
          src="/screens/home.webp"
          alt="Semester Forge home screen with profile card and community feed"
          priority
          className="animate-float"
        />
      </motion.div>
    </div>
  );
}
