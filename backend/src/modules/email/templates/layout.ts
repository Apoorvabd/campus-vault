import { FONT, escapeHtml } from "./blocks";

// Cloudinary resizes on the fly (w_320): 320px is sharp enough for the 140px
// logo on high-density screens, at ~15 KB instead of the 187 KB original. The
// logo is a light square, so it gets rounded corners to look like a tile on the
// dark-mode card.
const LOGO_URL =
  "https://res.cloudinary.com/dsbare0x9/image/upload/w_320,q_auto/v1792707159/dukestudent/resources/n1hwbmbieit2zblc0k8u.jpg";

const LOGO = `<div style="text-align:center;margin-bottom:20px;"><img src="${LOGO_URL}" width="140" height="140" alt="Semester Forge" style="display:inline-block;width:140px;height:140px;border:0;border-radius:16px;background-color:#FFFFFF;"></div>`;

// The fixed top (brand) and bottom (footer) shared by every email. A template
// only supplies the `content` that goes in the card between them.
export const renderLayout = ({
  preheader,
  content,
}: {
  preheader: string;
  content: string;
}) => `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="color-scheme" content="light dark">
  <meta name="supported-color-schemes" content="light dark">
  <title>Semester Forge</title>
  <style>
    @media (prefers-color-scheme: dark) {
      .bg-page { background-color: #0B1220 !important; }
      .bg-card { background-color: #111A2E !important; border-color: #1E293B !important; }
      .text-main { color: #F1F5F9 !important; }
      .text-sub { color: #94A3B8 !important; }
      .divider { border-top-color: #1E293B !important; }
      .code-box { background-color: #1B2A4A !important; border-color: #2F6FED !important; }
      .code-text { color: #DBE7FF !important; }
    }
    @media only screen and (max-width: 620px) {
      .container { width: 100% !important; }
      .pad { padding-left: 20px !important; padding-right: 20px !important; }
      .code-text { font-size: 30px !important; letter-spacing: 6px !important; }
    }
  </style>
</head>
<body class="bg-page" style="margin:0;padding:0;background-color:#F1F5F9;">
  <div style="display:none;max-height:0;overflow:hidden;opacity:0;color:transparent;">${escapeHtml(preheader)}</div>
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0" class="bg-page" style="background-color:#F1F5F9;">
    <tr>
      <td align="center" style="padding:32px 12px;">
        <table role="presentation" width="560" cellpadding="0" cellspacing="0" border="0" class="container" style="width:560px;max-width:560px;">
          <tr>
            <td class="bg-card" style="background-color:#FFFFFF;border:1px solid #E2E8F0;border-radius:16px;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td class="pad" style="padding:36px;">${LOGO}${content}</td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td align="center" style="padding:20px 12px 0 12px;font-family:${FONT};">
              <p class="text-sub" style="margin:0;font-size:12px;line-height:18px;color:#94A3B8;">This is an automated message from Semester Forge. Please do not reply.</p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
