"use client";

import { motion, useReducedMotion } from "motion/react";
import Image from "next/image";
import { useEffect, useState } from "react";

const SCREENS = [
  { src: "/screens/home.webp", alt: "SemesterForge home screen with profile card and community feed", label: "Home" },
  { src: "/screens/subjects.png", alt: "SemesterForge Resources tab listing the student's subjects", label: "Subjects" },
  { src: "/screens/add.png", alt: "SemesterForge Add Document screen with Files, Photos, Camera and Link", label: "Add" },
];
const COUNT = SCREENS.length;

/** Time each screen stays before the next one slides in. Three screens = a 12 second loop. */
const STEP_MS = 4000;
const SLIDE_S = 0.9;
const EASE = [0.65, 0, 0.35, 1] as const;

const PHONE_W = 216; // main phone frame
const SIDE_W = Math.round(PHONE_W * 0.84);
const SIDE_VISIBLE = 0.42; // how much of each side phone sticks out from behind the main one
const SIDE_X = PHONE_W / 2 + SIDE_W * SIDE_VISIBLE - SIDE_W / 2; // distance of a side phone's centre from the middle

/**
 * The screens that one phone shows, in order. Offset 0 is the main phone (current screen),
 * +1 the right phone (next screen), -1 the left phone (previous screen). The last item is a
 * copy of the first so the loop can wrap without a visible jump.
 */
function screensFor(offset: number) {
  return Array.from({ length: COUNT + 1 }, (_, i) => SCREENS[(((i + offset) % COUNT) + COUNT) % COUNT]);
}

/**
 * A strip of screens that slides left. The phone frame around it stays still.
 * Every image is loaded up front (`eager`) so nothing pops in while sliding.
 */
function Track({
  offset,
  index,
  jump,
  sizes,
  hidden,
  onDone,
}: {
  offset: number;
  index: number;
  jump: boolean;
  sizes: string;
  hidden?: boolean;
  onDone?: () => void;
}) {
  return (
    <motion.div
      className="flex"
      initial={false}
      animate={{ x: `-${index * 100}%` }}
      transition={jump ? { duration: 0 } : { duration: SLIDE_S, ease: EASE }}
      onAnimationComplete={onDone}
    >
      {screensFor(offset).map((screen, i) => (
        <Image
          key={i}
          src={screen.src}
          alt={hidden || i === COUNT ? "" : screen.alt}
          aria-hidden={hidden || i === COUNT}
          width={720}
          height={1600}
          sizes={sizes}
          loading="eager"
          draggable={false}
          className="h-auto w-full shrink-0 select-none"
        />
      ))}
    </motion.div>
  );
}

/**
 * Three phone frames that never move: a main one in the middle and two peeking out
 * from behind it. Only the screens inside slide to the left, together, like a carousel.
 * Three dots underneath show and change the current screen. Loops forever.
 */
export function PhoneCarousel() {
  const reduce = useReducedMotion();
  const [index, setIndex] = useState(0); // 0..COUNT (the last one is a copy of the first)
  const [jump, setJump] = useState(false); // true while snapping back to the start with no animation

  // Advance after each screen has been shown for STEP_MS. Restarting on every change keeps the
  // timing even when someone taps a dot.
  useEffect(() => {
    if (reduce) return;
    const id = window.setTimeout(() => {
      setJump(false);
      setIndex((i) => (i >= COUNT ? 0 : i + 1));
    }, STEP_MS);
    return () => window.clearTimeout(id);
  }, [index, reduce]);

  const active = index % COUNT;

  const goTo = (i: number) => {
    setJump(false);
    setIndex(i);
  };

  // After sliding onto the copy of the first screen, snap back to the real first one.
  const wrap = () => {
    if (index === COUNT) {
      setJump(true);
      setIndex(0);
    }
  };

  return (
    <div className="relative mx-auto flex h-[470px] w-[310px] flex-col items-center justify-center sm:h-[560px] sm:w-[470px]">
      <div className="pointer-events-none absolute top-1/2 left-1/2 h-80 w-80 -translate-x-1/2 -translate-y-[55%] rounded-full bg-indigo-600/35 blur-[120px]" />
      <div className="pointer-events-none absolute top-1/4 left-1/4 h-52 w-52 rounded-full bg-pink-600/20 blur-[100px]" />
      <div className="pointer-events-none absolute right-8 bottom-1/3 h-48 w-48 rounded-full bg-teal-500/15 blur-[100px]" />

      <div className="relative origin-center scale-[0.72] sm:scale-100" style={{ width: PHONE_W }}>
        {/* Side phones: still frames showing the previous and next screens. */}
        <div className="pointer-events-none absolute top-1/2 left-1/2" style={{ perspective: 1200 }} aria-hidden="true">
          {[
            { offset: -1, x: -SIDE_X, rot: 14 },
            { offset: 1, x: SIDE_X, rot: -14 },
          ].map(({ offset, x, rot }) => (
            <div
              key={offset}
              className="absolute"
              style={{
                width: SIDE_W,
                left: -SIDE_W / 2 + x,
                top: "-50%",
                transform: `translateY(-47%) rotateY(${rot}deg)`,
                filter: "brightness(0.5)",
              }}
            >
              <div className="rounded-[2.2rem] border border-white/15 bg-[#111] p-[7px] shadow-xl shadow-black/50">
                <div className="overflow-hidden rounded-[1.8rem]">
                  <Track offset={offset} index={index} jump={jump} sizes={`${SIDE_W}px`} hidden />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Main phone: the frame never moves, only the screens inside it. */}
        <div className="relative z-10 rounded-[2.6rem] border border-white/15 bg-[#111] p-[8px] shadow-2xl shadow-black/60">
          <div className="overflow-hidden rounded-[2.1rem]">
            <Track offset={0} index={index} jump={jump} sizes={`${PHONE_W}px`} onDone={wrap} />
          </div>
        </div>

        {/* Three dots. The active one stretches into a pill and fills up while the screen is showing. */}
        <div className="relative z-10 mt-6 flex items-center justify-center gap-2.5">
          {SCREENS.map((screen, i) => {
            const on = i === active;
            return (
              <button
                key={screen.src}
                type="button"
                onClick={() => goTo(i)}
                aria-label={`Show ${screen.label} screen`}
                aria-current={on}
                className={`relative h-2 cursor-pointer overflow-hidden rounded-full bg-white/25 transition-all duration-500 ${
                  on ? "w-10" : "w-2 hover:bg-white/45"
                }`}
              >
                {on && (
                  <motion.span
                    key={index}
                    className="absolute inset-0 origin-left rounded-full bg-gradient-to-r from-indigo-300 via-fuchsia-300 to-rose-300"
                    initial={reduce ? false : { scaleX: 0 }}
                    animate={{ scaleX: 1 }}
                    transition={{ duration: reduce ? 0 : STEP_MS / 1000, ease: "linear" }}
                  />
                )}
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
