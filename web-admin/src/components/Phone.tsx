import Image from "next/image";

/** Phone frame around a real app screenshot from /public/screens. */
export function Phone({
  src,
  alt,
  priority = false,
  width = 270,
  className = "",
}: {
  src: string;
  alt: string;
  priority?: boolean;
  /** Frame width in px. Height follows the screenshot ratio. */
  width?: number;
  className?: string;
}) {
  return (
    <div
      style={{ width, padding: Math.max(6, Math.round(width / 30)) }}
      className={`relative shrink-0 rounded-[2.6rem] border border-white/15 bg-[#111] shadow-2xl shadow-black/60 ${className}`}
    >
      <Image
        src={src}
        alt={alt}
        width={720}
        height={1600}
        priority={priority}
        sizes={`${width}px`}
        className="h-auto w-full rounded-[2.1rem]"
      />
    </div>
  );
}
