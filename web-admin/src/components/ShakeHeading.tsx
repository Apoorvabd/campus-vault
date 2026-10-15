"use client";

import { motion, useAnimationControls, useReducedMotion } from "motion/react";
import { useEffect, type ReactNode } from "react";

/** Main heading that gives a small shake whenever the user clicks or taps anywhere. */
export function ShakeHeading({ children, className = "" }: { children: ReactNode; className?: string }) {
  const controls = useAnimationControls();
  const reduce = useReducedMotion();

  useEffect(() => {
    if (reduce) return;
    const shake = () => {
      controls.start({
        x: [0, -7, 6, -5, 3, -1.5, 0],
        y: [0, 2, -2, 1.5, -1, 0, 0],
        rotate: [0, -0.5, 0.45, -0.3, 0.2, 0, 0],
        transition: { duration: 0.5, ease: "easeOut" },
      });
    };
    window.addEventListener("pointerdown", shake, { passive: true });
    return () => window.removeEventListener("pointerdown", shake);
  }, [controls, reduce]);

  return (
    <motion.h1 animate={controls} className={className}>
      {children}
    </motion.h1>
  );
}
