import { ImageResponse } from "next/og";

export const alt = "Semester Forge: DU PYQs, notes and syllabus in one app";
export const size = { width: 1200, height: 630 };
export const contentType = "image/png";

export default function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          width: "100%",
          height: "100%",
          display: "flex",
          flexDirection: "column",
          justifyContent: "center",
          padding: 80,
          color: "white",
          background:
            "radial-gradient(circle at 15% 10%, rgba(99,102,241,0.7), transparent 55%), radial-gradient(circle at 90% 90%, rgba(236,72,153,0.5), transparent 50%), #0b1030",
        }}
      >
        <div style={{ fontSize: 34, color: "#c7d2fe", marginBottom: 24 }}>Semester Forge</div>
        <div style={{ fontSize: 88, fontWeight: 700, lineHeight: 1.05, display: "flex", flexDirection: "column" }}>
          <span>DU PYQs, notes</span>
          <span style={{ color: "#f0abfc" }}>and syllabus. One app.</span>
        </div>
        <div style={{ fontSize: 32, marginTop: 36, color: "#cbd5ff" }}>
          118 courses · 5,500+ subjects · Built for Delhi University students
        </div>
      </div>
    ),
    size,
  );
}
