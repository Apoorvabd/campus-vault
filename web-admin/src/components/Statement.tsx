"use client";

import { motion, useReducedMotion } from "motion/react";

type Part = { text: string; warm?: boolean };

/** Big gradient statement. Words pop in quickly, one after another. */
export function Statement({ parts }: { parts: Part[] }) {
  const reduce = useReducedMotion();
  let i = 0;
  return (
    <motion.p
      className="text-3xl leading-snug font-semibold tracking-tight sm:text-5xl sm:leading-[1.15]"
      initial="hidden"
      whileInView="shown"
      viewport={{ once: true, amount: 0.4 }}
      transition={{ staggerChildren: reduce ? 0 : 0.035 }}
    >
      {parts.flatMap((part) =>
        part.text.split(" ").map((word) => (
          <span key={i++}>
          <motion.span
            className={`inline-block ${part.warm ? "grad-warm" : "grad-cool"}`}
            variants={{
              hidden: { opacity: 0, y: 22, filter: "blur(8px)" },
              shown: { opacity: 1, y: 0, filter: "blur(0px)" },
            }}
            transition={{ duration: 0.45, ease: [0.22, 1, 0.36, 1] }}
          >
            {word}
          </motion.span>{" "}
          </span>
        )),
      )}
    </motion.p>
  );
}
