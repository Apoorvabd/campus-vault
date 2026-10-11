"use client";

import { motion, useReducedMotion } from "motion/react";
import type { ReactNode } from "react";

const variants = {
  up: { hidden: { opacity: 0, y: 28, filter: "blur(6px)" }, shown: { opacity: 1, y: 0, filter: "blur(0px)" } },
  phone: {
    hidden: { opacity: 0, y: 70, scale: 0.92, rotate: 3 },
    shown: { opacity: 1, y: 0, scale: 1, rotate: 0 },
  },
  fade: { hidden: { opacity: 0 }, shown: { opacity: 1 } },
};

export function Reveal({
  children,
  delay = 0,
  className = "",
  variant = "up",
  lift = false,
}: {
  children: ReactNode;
  /** milliseconds */
  delay?: number;
  className?: string;
  variant?: keyof typeof variants;
  lift?: boolean;
}) {
  const reduce = useReducedMotion();
  if (reduce) return <div className={className}>{children}</div>;

  return (
    <motion.div
      className={className}
      variants={variants[variant]}
      initial="hidden"
      whileInView="shown"
      viewport={{ once: true, amount: 0.15 }}
      transition={{ duration: 0.7, delay: delay / 1000, ease: [0.22, 1, 0.36, 1] }}
      whileHover={lift ? { y: -6, transition: { duration: 0.25 } } : undefined}
    >
      {children}
    </motion.div>
  );
}
