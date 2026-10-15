"use client";

import { useEffect, useRef } from "react";

const FONT = 'ui-monospace, "SF Mono", Menlo, Consolas, monospace';
const MATH_FONT = 'Georgia, "Times New Roman", serif';
const COLORS = ["255,255,255", "199,210,254", "240,171,252", "94,234,212", "253,211,77"];
const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const DIGITS = "23456789";
const SIZES = [9, 11, 13, 15, 18];
const TAU = Math.PI * 2;

/** For now only math symbols are shown. Set to false to bring back the 0s, 1s, digits and letters. */
const ONLY_MATH = true;

/** Symbols that float in the background and that a touch sends out. */
const MATH = ["Σ", "Π", "∞", "∫", "χ", "π", "γ", "δ", "Δ", "Γ", "θ", "λ", "μ", "φ", "ψ", "Ω"];

/** Symbols whose outline becomes the shape of the wave that spreads across the screen. */
const WAVE_SYMBOLS = ["π", "χ", "∞", "γ", "δ", "Σ", "Π", "∫", "Δ", "Ω"];

function glyph(math = 0.14) {
  if (ONLY_MATH) return MATH[Math.floor(Math.random() * MATH.length)];
  const t = Math.random();
  if (t < math) return MATH[Math.floor(Math.random() * MATH.length)];
  const r = (t - math) / (1 - math);
  if (r < 0.62) return Math.random() < 0.5 ? "0" : "1";
  if (r < 0.82) return DIGITS[Math.floor(Math.random() * DIGITS.length)];
  return LETTERS[Math.floor(Math.random() * LETTERS.length)];
}

/* ---- Symbol shapes ----
 * Each symbol is drawn once to a hidden canvas. From that we keep a soft mask (is this point
 * inside the symbol?) in "unit" coordinates, where the symbol's bigger side spans -1..1, and a
 * list of points that lie on the symbol, used to place the bits that a touch sends out. */

const MASK_N = 128;
const MASK_RANGE = 1.2; // the mask covers -1.2..1.2 units
const REF = 140; // font size the symbol is drawn at

type SymbolShape = {
  ch: string;
  mask: Float32Array;
  points: number[]; // flat list of u,v pairs inside the symbol
  D: number; // symbol's larger side in px at REF size
  cx: number; // centre of the symbol relative to the text origin, px at REF size
  cy: number;
};

const shapeCache = new Map<string, SymbolShape>();

function buildSymbol(ch: string): SymbolShape {
  const size = 260;
  const c = document.createElement("canvas");
  c.width = c.height = size;
  const g = c.getContext("2d", { willReadFrequently: true })!;
  g.font = `${REF}px ${MATH_FONT}`;
  g.textAlign = "left";
  g.textBaseline = "alphabetic";
  const m = g.measureText(ch);
  const L = m.actualBoundingBoxLeft;
  const R = m.actualBoundingBoxRight;
  const A = m.actualBoundingBoxAscent;
  const Dn = m.actualBoundingBoxDescent;
  const D = Math.max(L + R, A + Dn, 1);
  const cx = (R - L) / 2;
  const cy = (Dn - A) / 2;
  const X0 = size / 2 - cx;
  const Y0 = size / 2 - cy;
  g.fillStyle = "#fff";
  g.fillText(ch, X0, Y0);
  const px = g.getImageData(0, 0, size, size).data;
  const alphaAt = (x: number, y: number) => {
    const xi = Math.round(x);
    const yi = Math.round(y);
    if (xi < 0 || yi < 0 || xi >= size || yi >= size) return 0;
    return px[(yi * size + xi) * 4 + 3] / 255;
  };

  let mask = new Float32Array(MASK_N * MASK_N);
  const points: number[] = [];
  for (let j = 0; j < MASK_N; j++) {
    for (let i = 0; i < MASK_N; i++) {
      const u = -MASK_RANGE + (2 * MASK_RANGE * (i + 0.5)) / MASK_N;
      const v = -MASK_RANGE + (2 * MASK_RANGE * (j + 0.5)) / MASK_N;
      const a = alphaAt(X0 + cx + (u * D) / 2, Y0 + cy + (v * D) / 2);
      mask[j * MASK_N + i] = a;
      if (a > 0.6) points.push(u, v);
    }
  }
  // Two quick box blurs so the mask changes smoothly (keeps the wave from flickering).
  for (let pass = 0; pass < 2; pass++) {
    const out = new Float32Array(mask.length);
    for (let j = 0; j < MASK_N; j++) {
      for (let i = 0; i < MASK_N; i++) {
        let sum = 0;
        let n = 0;
        for (let dj = -1; dj <= 1; dj++) {
          for (let di = -1; di <= 1; di++) {
            const ii = i + di;
            const jj = j + dj;
            if (ii < 0 || jj < 0 || ii >= MASK_N || jj >= MASK_N) continue;
            sum += mask[jj * MASK_N + ii];
            n++;
          }
        }
        out[j * MASK_N + i] = sum / n;
      }
    }
    mask = out;
  }
  return { ch, mask, points, D, cx, cy };
}

function getSymbol(ch: string): SymbolShape {
  let s = shapeCache.get(ch);
  if (!s) {
    s = buildSymbol(ch);
    shapeCache.set(ch, s);
  }
  return s;
}

/** Soft "inside the symbol" value (0..1) at unit coordinates (u, v). */
function inside(sh: SymbolShape, u: number, v: number): number {
  if (u <= -MASK_RANGE || u >= MASK_RANGE || v <= -MASK_RANGE || v >= MASK_RANGE) return 0;
  const fx = ((u + MASK_RANGE) / (2 * MASK_RANGE)) * MASK_N - 0.5;
  const fy = ((v + MASK_RANGE) / (2 * MASK_RANGE)) * MASK_N - 0.5;
  const x0 = Math.max(0, Math.min(MASK_N - 2, Math.floor(fx)));
  const y0 = Math.max(0, Math.min(MASK_N - 2, Math.floor(fy)));
  const tx = Math.max(0, Math.min(1, fx - x0));
  const ty = Math.max(0, Math.min(1, fy - y0));
  const m = sh.mask;
  const a = m[y0 * MASK_N + x0] * (1 - tx) + m[y0 * MASK_N + x0 + 1] * tx;
  const b = m[(y0 + 1) * MASK_N + x0] * (1 - tx) + m[(y0 + 1) * MASK_N + x0 + 1] * tx;
  return a * (1 - ty) + b * ty;
}

const WAVE_SPEED = 470; // how fast the symbol grows, px per second (its half-size)
const WAVE_GAP = 80; // distance between crests (in half-size px)
const SCALE_BAND = 46; // thickness of a crest (in half-size px)
const WAVE_RINGS = 3;

/**
 * How strongly a wave crest sits at a point. The wave front is the outline of the symbol
 * blown up around the touch point: `scale` is the symbol's half-size in px. The crest is the
 * thin band between the symbol at this size and a slightly smaller copy of it.
 */
function crestAt(sh: SymbolShape, rx: number, ry: number, scale: number): number {
  if (scale <= SCALE_BAND + 2) return 0;
  const outer = inside(sh, rx / scale, ry / scale);
  const innerScale = scale - SCALE_BAND;
  const inner = inside(sh, rx / innerScale, ry / innerScale);
  return Math.max(0, outer - inner);
}

type Ripple = { x: number; y: number; age: number; life: number; shape: SymbolShape };

type Idle = {
  ch: string;
  size: number;
  color: number;
  alpha: number;
  phase: number;
  x: number;
  y: number;
  vx: number;
  vy: number;
};

type Bit = {
  ch: string;
  size: number;
  color: number;
  alpha: number;
  ox: number; // where the burst started
  oy: number;
  tx: number; // offset from the origin that makes up the symbol
  ty: number;
  delay: number;
  age: number;
  life: number;
  grow: number; // seconds to reach its place in the symbol
  phase: number;
};

/** How many bits a touch sends out to draw the symbol. Kept low so it stays light. */
const BURST_BITS = 58;

/**
 * Background of tiny floating math symbols. Every click or tap sends a wave across the whole
 * screen, shaped like a symbol (π, χ, ∞, γ, δ, Σ...), with a small cluster of symbols spreading
 * out to draw the same shape. Sits behind the page content and ignores pointer events.
 */
export function Particles() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    let w = 0;
    let h = 0;
    let dpr = 1;
    const idle: Idle[] = [];
    let bits: Bit[] = [];
    let ripples: Ripple[] = [];
    const pointer = { x: -9999, y: -9999 };
    let lastSymbol = -1;

    const rand = (a: number, b: number) => a + Math.random() * (b - a);
    const pickSize = () => SIZES[Math.floor(Math.random() * 4)];
    const pickColor = () => Math.floor(Math.random() * COLORS.length);

    /* Pre-rendered glyphs: drawImage is much cheaper than fillText for hundreds of bits. */
    const sprites = new Map<string, HTMLCanvasElement>();
    const sprite = (ch: string, color: number, size: number) => {
      const key = `${ch}|${color}|${size}|${dpr}`;
      let s = sprites.get(key);
      if (!s) {
        s = document.createElement("canvas");
        s.width = Math.ceil(size * 1.6 * dpr);
        s.height = Math.ceil(size * 1.8 * dpr);
        const c = s.getContext("2d");
        if (c) {
          c.scale(dpr, dpr);
          const math = MATH.includes(ch);
          c.font = math ? `${Math.round(size * 1.3)}px ${MATH_FONT}` : `${size}px ${FONT}`;
          c.textAlign = "center";
          c.textBaseline = "middle";
          c.fillStyle = `rgb(${COLORS[color]})`;
          c.fillText(ch, (size * 1.6) / 2, (size * 1.8) / 2);
        }
        sprites.set(key, s);
      }
      return s;
    };
    const draw = (ch: string, color: number, size: number, x: number, y: number, alpha: number, scale = 1) => {
      if (alpha <= 0.01) return;
      const s = sprite(ch, color, size);
      const dw = (s.width / dpr) * scale;
      const dh = (s.height / dpr) * scale;
      ctx.globalAlpha = alpha > 1 ? 1 : alpha;
      ctx.drawImage(s, x - dw / 2, y - dh / 2, dw, dh);
    };

    const makeIdle = (): Idle => ({
      ch: glyph(),
      size: pickSize(),
      color: pickColor(),
      alpha: rand(0.2, 0.65),
      phase: rand(0, TAU),
      x: rand(0, w),
      y: rand(0, h),
      vx: rand(-5, 5),
      vy: rand(-12, -3),
    });

    const resize = () => {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      w = window.innerWidth;
      h = window.innerHeight;
      canvas.width = w * dpr;
      canvas.height = h * dpr;
      canvas.style.width = `${w}px`;
      canvas.style.height = `${h}px`;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      const target = Math.min(460, Math.round((w * h) / 2800));
      while (idle.length < target) idle.push(makeIdle());
      idle.length = target;
    };

    const burst = (x: number, y: number) => {
      // Pick a different symbol from last time.
      let si = Math.floor(Math.random() * WAVE_SYMBOLS.length);
      if (si === lastSymbol) si = (si + 1) % WAVE_SYMBOLS.length;
      lastSymbol = si;
      const symbol = WAVE_SYMBOLS[si];
      const shape = getSymbol(symbol);

      // A few symbols spread out and settle into the same shape around the touch point.
      const radius = Math.min(rand(190, 250), Math.min(w, h) * 0.42);
      const grow = rand(1.1, 1.5);
      const count = shape.points.length / 2;
      for (let i = 0; i < BURST_BITS && count > 0; i++) {
        const k = Math.floor(Math.random() * count) * 2;
        bits.push({
          ch: Math.random() < 0.6 ? symbol : glyph(),
          size: SIZES[2 + Math.floor(Math.random() * 3)],
          color: pickColor(),
          alpha: rand(0.75, 1),
          ox: x,
          oy: y,
          tx: shape.points[k] * radius + rand(-1.5, 1.5),
          ty: shape.points[k + 1] * radius + rand(-1.5, 1.5),
          delay: rand(0, 0.12),
          age: 0,
          life: rand(4.6, 5.2),
          grow,
          phase: rand(0, TAU),
        });
      }
      if (bits.length > 400) bits = bits.slice(bits.length - 400);

      // The wave itself: the same symbol, blown up until it has swept past the whole screen.
      const far = Math.max(Math.hypot(x, y), Math.hypot(w - x, y), Math.hypot(x, h - y), Math.hypot(w - x, h - y));
      ripples.push({ x, y, age: 0, life: (far * 1.2 + 260) / WAVE_SPEED, shape });
      if (ripples.length > 4) ripples.shift();
    };

    const onDown = (e: PointerEvent) => burst(e.clientX, e.clientY);
    const onMove = (e: PointerEvent) => {
      pointer.x = e.clientX;
      pointer.y = e.clientY;
    };
    const onLeave = () => {
      pointer.x = pointer.y = -9999;
    };

    resize();
    for (const s of WAVE_SYMBOLS) getSymbol(s); // build the symbol masks up front

    if (reduce) {
      // Static symbols only: no animation and no click waves.
      for (const d of idle) draw(d.ch, d.color, d.size, d.x, d.y, d.alpha * 0.6);
      window.addEventListener("resize", resize);
      return () => window.removeEventListener("resize", resize);
    }

    let last = performance.now();
    let raf = 0;
    const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

    const frame = (now: number) => {
      const dt = Math.min((now - last) / 1000, 0.05);
      last = now;
      ctx.clearRect(0, 0, w, h);

      // Advance the waves and draw their rings: the outline of the symbol, growing.
      ripples = ripples.filter((r) => (r.age += dt) < r.life);
      ctx.textAlign = "left";
      ctx.textBaseline = "alphabetic";
      ctx.lineJoin = "round";
      for (const r of ripples) {
        const S = r.age * WAVE_SPEED;
        const fade = Math.max(0, 1 - r.age / r.life);
        for (let k = 0; k < WAVE_RINGS; k++) {
          const sk = S - k * WAVE_GAP;
          if (sk <= 6) continue;
          const sh = r.shape;
          const fs = (REF * 2 * sk) / sh.D;
          if (fs > 5200) continue;
          const kk = fs / REF;
          ctx.font = `${fs}px ${MATH_FONT}`;
          ctx.globalAlpha = 0.85 * Math.sqrt(fade) * Math.exp(-S / 3000) * (1 - k * 0.22);
          ctx.strokeStyle = k % 2 ? "rgb(240,171,252)" : "rgb(165,180,252)";
          ctx.lineWidth = 3.2 - k * 0.6;
          ctx.strokeText(sh.ch, r.x - sh.cx * kk, r.y - sh.cy * kk);
        }
      }

      for (const d of idle) {
        const dx = d.x - pointer.x;
        const dy = d.y - pointer.y;
        const dist2 = dx * dx + dy * dy;
        if (dist2 < 130 * 130 && dist2 > 1) {
          const dist = Math.sqrt(dist2);
          const force = (1 - dist / 130) * 50;
          d.vx += (dx / dist) * force * dt;
          d.vy += (dy / dist) * force * dt;
        }
        d.vx *= 1 - 1.1 * dt;
        d.vy += (-8 - d.vy) * 0.9 * dt; // settle back to a slow upward drift
        d.x += (d.vx + Math.sin(now / 1800 + d.phase) * 5) * dt;
        d.y += d.vy * dt;
        if (d.y < -10) {
          d.y = h + 10;
          d.x = rand(0, w);
        }
        if (d.x < -10) d.x = w + 10;
        if (d.x > w + 10) d.x = -10;

        if (Math.random() < 0.35 * dt) d.ch = glyph(); // flicker to a new symbol now and then
        const twinkle = 0.55 + 0.45 * Math.sin(now / 900 + d.phase);

        // Wave: bits ride with each crest of the symbol-shaped wave and glow as it passes.
        let ox = 0;
        let oy = 0;
        let glow = 0;
        for (const r of ripples) {
          const rx = d.x - r.x;
          const ry = d.y - r.y;
          const dist = Math.hypot(rx, ry) || 1;
          const S = r.age * WAVE_SPEED;
          let crest = 0;
          for (let k = 0; k < WAVE_RINGS; k++) crest += crestAt(r.shape, rx, ry, S - k * WAVE_GAP) * Math.pow(0.7, k);
          if (crest <= 0.001) continue;
          crest = Math.min(crest, 1);
          const decay = Math.exp(-dist / 2200) * Math.sqrt(Math.max(0, 1 - r.age / r.life));
          const amp = 26 * decay * crest;
          ox += (rx / dist) * amp;
          oy += (ry / dist) * amp;
          glow += crest * decay;
        }
        draw(d.ch, d.color, d.size, d.x + ox, d.y + oy, d.alpha * twinkle * (1 + glow * 3), 1 + glow * 0.5);
      }

      let write = 0;
      for (let i = 0; i < bits.length; i++) {
        const b = bits[i];
        b.age += dt;
        const a = b.age - b.delay;
        if (b.age >= b.life) continue; // expired, drop it
        bits[write++] = b;
        if (a < 0) continue;

        // Spread into place with an ease-out, then keep floating gently upward.
        const p = easeOut(Math.min(a / b.grow, 1));
        const floatUp = a > b.grow ? (a - b.grow) * 5 : 0;
        const wobbleX = Math.sin(now / 700 + b.phase) * 2 * p;
        const wobbleY = Math.cos(now / 800 + b.phase) * 2 * p;
        const x = b.ox + b.tx * p + wobbleX;
        const y = b.oy + b.ty * p + wobbleY - floatUp;

        const fadeStart = b.life * 0.68;
        const fade = b.age < fadeStart ? 1 : Math.max(0, 1 - (b.age - fadeStart) / (b.life - fadeStart));
        const appear = Math.min(a / 0.15, 1);
        draw(b.ch, b.color, b.size, x, y, b.alpha * fade * appear, 0.75 + 0.25 * fade);
      }
      bits.length = write;
      ctx.globalAlpha = 1;

      raf = requestAnimationFrame(frame);
    };
    raf = requestAnimationFrame(frame);

    window.addEventListener("resize", resize);
    window.addEventListener("pointerdown", onDown, { passive: true });
    window.addEventListener("pointermove", onMove, { passive: true });
    document.addEventListener("pointerleave", onLeave);

    return () => {
      cancelAnimationFrame(raf);
      window.removeEventListener("resize", resize);
      window.removeEventListener("pointerdown", onDown);
      window.removeEventListener("pointermove", onMove);
      document.removeEventListener("pointerleave", onLeave);
    };
  }, []);

  return <canvas ref={canvasRef} aria-hidden="true" className="pointer-events-none fixed inset-0 -z-10" />;
}
