// Building blocks for the middle part of an email. Inline styles only: email
// clients ignore most external and <style> CSS. The class names are hooks for
// the dark-mode rules in layout.ts.

export const FONT =
  "-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Helvetica,Arial,sans-serif";

export const escapeHtml = (value: string) =>
  value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");

export const heading = (text: string) =>
  `<h1 class="text-main" style="margin:0 0 12px 0;font-family:${FONT};font-size:22px;line-height:28px;font-weight:700;color:#0F172A;">${escapeHtml(text)}</h1>`;

export const paragraph = (text: string) =>
  `<p class="text-sub" style="margin:0 0 12px 0;font-family:${FONT};font-size:15px;line-height:24px;color:#475569;">${escapeHtml(text)}</p>`;

export const codeBox = (code: string) =>
  `<table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" style="margin:20px 0 16px 0;">
  <tr>
    <td align="center" class="code-box" style="background-color:#E8F0FE;border:1px solid #C7DAFB;border-radius:12px;padding:22px 12px;">
      <span class="code-text" style="font-family:'SF Mono',SFMono-Regular,Menlo,Consolas,'Courier New',monospace;font-size:36px;line-height:40px;font-weight:700;letter-spacing:10px;color:#1D4FC4;">${escapeHtml(code)}</span>
    </td>
  </tr>
</table>`;

// Small grey text under a divider, for the "ignore this email" kind of line
export const note = (text: string) =>
  `<div class="divider" style="margin-top:20px;padding-top:16px;border-top:1px solid #E2E8F0;">
  <p class="text-sub" style="margin:0;font-family:${FONT};font-size:13px;line-height:20px;color:#64748B;">${escapeHtml(text)}</p>
</div>`;
