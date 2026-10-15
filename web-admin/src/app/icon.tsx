import { readFile } from "node:fs/promises";
import { join } from "node:path";
import { ImageResponse } from "next/og";

export const size = { width: 96, height: 96 };
export const contentType = "image/png";

/** Browser-tab icon: the SemesterForge mark on a white tile (the mark has dark parts that vanish on dark tabs). */
export default async function Icon() {
  const svg = await readFile(join(process.cwd(), "public", "logo.svg"));
  const src = `data:image/svg+xml;base64,${svg.toString("base64")}`;
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          background: "#ffffff",
          borderRadius: 22,
        }}
      >
        <img src={src} width={76} height={69} alt="" />
      </div>
    ),
    size,
  );
}
