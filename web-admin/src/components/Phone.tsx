import Image from "next/image";

/** Phone frame around a real app screenshot from /public/screens. */
export function Phone({
  src,
  alt,
  priority = false,
  className = "",
}: {
  src: string;
  alt: string;
  priority?: boolean;
  className?: string;
}) {
  return (
    <div
      className={`relative w-[270px] shrink-0 rounded-[2.6rem] border border-white/15 bg-[#111] p-[9px] shadow-2xl shadow-black/60 ${className}`}
    >
      <Image
        src={src}
        alt={alt}
        width={720}
        height={1600}
        priority={priority}
        sizes="270px"
        className="h-auto w-full rounded-[2.1rem]"
      />
    </div>
  );
}
