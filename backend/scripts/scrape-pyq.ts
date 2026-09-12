/**
 * DU Question Paper Bank scraper.
 *
 * For every unique UPC found in sources/subjects.ts, this:
 *   1. Logs into https://qb.exam.du.ac.in (credentials from .env)
 *   2. Searches that UPC on /web-search
 *   3. Follows every matching result's /web-page-details/<hash> page
 *   4. Extracts the real PDF link + session/marks/set metadata
 *   5. Appends the result to scripts/output/pyq-scrape-results.json
 *
 * This script ONLY writes to that JSON file. It does not touch the
 * database — review the output first, then a separate import step
 * will upsert it into Resource rows.
 *
 * Resumable: if interrupted, re-running skips UPCs already present
 * in the output file.
 *
 * Usage:
 *   DU_EMAIL=you@example.com DU_PASSWORD=yourpassword npx tsx scripts/scrape-pyq.ts
 * (or put DU_EMAIL / DU_PASSWORD in backend/.env)
 */

import "dotenv/config";
import * as fs from "node:fs";
import * as path from "node:path";
import * as cheerio from "cheerio";
import { subjects } from "../../sources/subjects";

const BASE_URL = process.env.QB_BASE_URL || "https://qb.exam.du.ac.in";
const EMAIL = process.env.DU_EMAIL;
const PASSWORD = process.env.DU_PASSWORD;
const POLITE_DELAY_MS = Number(process.env.QB_DELAY_MS || 1500);
const FLUSH_EVERY = 20;

const OUTPUT_DIR = path.join(__dirname, "output");
const OUTPUT_FILE = path.join(OUTPUT_DIR, "pyq-scrape-results.json");
const FAILED_FILE = path.join(OUTPUT_DIR, "pyq-scrape-failures.json");

interface ScrapedPaper {
  courseCode: string;
  upc: string;
  subjectNameOnPortal: string;
  detailUrl: string;
  pdfUrl: string | null;
  session: string | null;
  marks: string | null;
  set: string | null;
  remarks: string | null;
  questionFor: string | null;
}

// ---------- tiny cookie jar (Node's fetch has no built-in cookie jar) ----------

class CookieJar {
  private cookies = new Map<string, string>();

  absorb(res: Response) {
    // Node/undici exposes multiple Set-Cookie headers via getSetCookie()
    const raw =
      typeof (res.headers as any).getSetCookie === "function"
        ? (res.headers as any).getSetCookie()
        : res.headers.get("set-cookie")
          ? [res.headers.get("set-cookie") as string]
          : [];
    for (const line of raw) {
      const [pair] = line.split(";");
      const eq = pair.indexOf("=");
      if (eq === -1) continue;
      const name = pair.slice(0, eq).trim();
      const value = pair.slice(eq + 1).trim();
      this.cookies.set(name, value);
    }
  }

  header(): string {
    return Array.from(this.cookies.entries())
      .map(([k, v]) => `${k}=${v}`)
      .join("; ");
  }
}

const jar = new CookieJar();

async function request(
  url: string,
  init: RequestInit = {},
): Promise<{ res: Response; body: string; finalUrl: string }> {
  let currentUrl = url;
  let currentInit = init;

  // Manually follow redirects so we never lose a Set-Cookie issued mid-chain.
  for (let hop = 0; hop < 5; hop++) {
    const res = await fetch(currentUrl, {
      ...currentInit,
      redirect: "manual",
      headers: {
        "User-Agent":
          "Mozilla/5.0 (compatible; CampusVaultPyqSync/1.0; personal-use-scraper)",
        Cookie: jar.header(),
        ...(currentInit.headers || {}),
      },
    });
    jar.absorb(res);

    if (res.status >= 300 && res.status < 400 && res.headers.get("location")) {
      const next = new URL(res.headers.get("location")!, currentUrl).toString();
      currentUrl = next;
      currentInit = { method: "GET" }; // redirects are always followed as GET
      continue;
    }

    const body = await res.text();
    return { res, body, finalUrl: currentUrl };
  }
  throw new Error(`Too many redirects starting at ${url}`);
}

function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

// ---------- auth ----------

async function login(): Promise<void> {
  if (!EMAIL || !PASSWORD) {
    throw new Error(
      "DU_EMAIL / DU_PASSWORD are not set. Put them in backend/.env (never commit that file).",
    );
  }

  const { body: loginPageHtml, finalUrl } = await request(`${BASE_URL}/login`);
  const $ = cheerio.load(loginPageHtml);

  const form = $("form").filter((_, el) => $(el).find('input[type="password"]').length > 0).first();
  if (form.length === 0) {
    throw new Error("Could not find the login form on /login — page structure may have changed.");
  }

  const action = form.attr("action") || finalUrl;
  const actionUrl = new URL(action, finalUrl).toString();

  const emailField =
    form.find('input[type="email"]').attr("name") ||
    form.find('input[name*="email" i]').attr("name") ||
    "email";
  const passwordField = form.find('input[type="password"]').attr("name") || "password";

  const payload = new URLSearchParams();
  form.find('input[type="hidden"]').each((_, el) => {
    const name = $(el).attr("name");
    const value = $(el).attr("value") || "";
    if (name) payload.set(name, value);
  });
  payload.set(emailField, EMAIL);
  payload.set(passwordField, PASSWORD);

  const { res, body, finalUrl: afterLoginUrl } = await request(actionUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: payload.toString(),
  });

  const stillOnLogin =
    afterLoginUrl.includes("/login") && /type="password"/i.test(body);
  if (stillOnLogin) {
    throw new Error(
      "Login POST did not authenticate (still seeing the login form back). Check DU_EMAIL/DU_PASSWORD, or the form field names may differ from what this script guessed.",
    );
  }

  console.log(`Logged in as ${EMAIL}. Landed on: ${afterLoginUrl} (status ${res.status})`);
}

async function isLoggedOut(html: string): Promise<boolean> {
  return /type="password"/i.test(html) && /Log ?In/i.test(html);
}

// ---------- scraping ----------

function extractDetailField(
  $: cheerio.CheerioAPI,
  label: string,
): string | null {
  let found: string | null = null;
  $("li").each((_, el) => {
    const text = $(el).text().trim();
    if (text.toLowerCase().startsWith(label.toLowerCase())) {
      const parts = text.split(":");
      found = parts.slice(1).join(":").trim();
    }
  });
  return found;
}

async function scrapeUpc(courseCode: string, upc: string): Promise<ScrapedPaper[]> {
  const searchUrl = `${BASE_URL}/web-search?search_term=${encodeURIComponent(upc)}`;
  let { body } = await request(searchUrl);

  if (await isLoggedOut(body)) {
    console.log("  session expired mid-run, re-logging in...");
    await login();
    ({ body } = await request(searchUrl));
    if (await isLoggedOut(body)) {
      throw new Error("Still logged out after re-login attempt — aborting.");
    }
  }

  const $ = cheerio.load(body);
  const detailUrls = new Set<string>();

  $(".card").each((_, card) => {
    const title = $(card).find(".card-body h5").text().trim();
    const link = $(card).find(".card-body a").attr("href");
    if (!link) return;
    // only keep exact-UPC matches (title ends with "- <UPC>")
    if (title.endsWith(`- ${upc}`)) {
      detailUrls.add(new URL(link, BASE_URL).toString());
    }
  });

  const papers: ScrapedPaper[] = [];
  for (const detailUrl of detailUrls) {
    await sleep(POLITE_DELAY_MS);
    const { body: detailHtml } = await request(detailUrl);
    const $$ = cheerio.load(detailHtml);

    const heading = $$("h1").first().text();
    const subjectName =
      heading.split("::")[0]?.replace(/Question Paper Name/i, "").trim() || "";

    const pdfUrl = $$("embed").attr("src") || null;

    papers.push({
      courseCode,
      upc,
      subjectNameOnPortal: subjectName,
      detailUrl,
      pdfUrl,
      session: extractDetailField($$, "Session"),
      marks: extractDetailField($$, "Marks"),
      set: extractDetailField($$, "Set"),
      remarks: extractDetailField($$, "Remarks"),
      questionFor: extractDetailField($$, "Question For"),
    });
  }

  return papers;
}

// ---------- persistence / resume ----------

function loadJsonArray<T>(file: string): T[] {
  if (!fs.existsSync(file)) return [];
  try {
    return JSON.parse(fs.readFileSync(file, "utf-8"));
  } catch {
    return [];
  }
}

function saveJsonArray(file: string, data: unknown[]) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(data, null, 2));
}

// ---------- main ----------

async function main() {
  const uniqueUpcs = new Map<string, string>(); // upc -> courseCode (first seen)
  for (const s of subjects) {
    if (!s.code) continue;
    if (!uniqueUpcs.has(s.code)) uniqueUpcs.set(s.code, s.courseCode || "");
  }

  const results = loadJsonArray<ScrapedPaper>(OUTPUT_FILE);
  const failures = loadJsonArray<{ upc: string; error: string }>(FAILED_FILE);
  const alreadyDone = new Set(results.map((r) => r.upc));
  const alreadyFailed = new Set(failures.map((f) => f.upc));

  const todo = Array.from(uniqueUpcs.entries()).filter(
    ([upc]) => !alreadyDone.has(upc) && !alreadyFailed.has(upc),
  );

  console.log(`Total unique UPCs: ${uniqueUpcs.size}`);
  console.log(`Already scraped:   ${alreadyDone.size}`);
  console.log(`Already failed:    ${alreadyFailed.size}`);
  console.log(`Remaining to do:   ${todo.length}`);

  if (todo.length === 0) {
    console.log("Nothing left to do.");
    return;
  }

  await login();

  let sinceFlush = 0;
  for (let i = 0; i < todo.length; i++) {
    const [upc, courseCode] = todo[i];
    process.stdout.write(`[${i + 1}/${todo.length}] UPC ${upc} (${courseCode}) ... `);
    try {
      const papers = await scrapeUpc(courseCode, upc);
      results.push(...papers);
      console.log(`${papers.length} paper(s) found`);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.log(`FAILED: ${message}`);
      failures.push({ upc, error: message });
      if (/aborting|Still logged out/i.test(message)) {
        console.error("Fatal auth error — stopping the run. Progress so far is saved.");
        break;
      }
    }

    sinceFlush++;
    if (sinceFlush >= FLUSH_EVERY) {
      saveJsonArray(OUTPUT_FILE, results);
      saveJsonArray(FAILED_FILE, failures);
      sinceFlush = 0;
    }

    await sleep(POLITE_DELAY_MS);
  }

  saveJsonArray(OUTPUT_FILE, results);
  saveJsonArray(FAILED_FILE, failures);

  console.log("\nDone for this run.");
  console.log(`Results file:  ${OUTPUT_FILE} (${results.length} papers total)`);
  console.log(`Failures file: ${FAILED_FILE} (${failures.length} UPCs)`);
}

main().catch((err) => {
  console.error("Scraper crashed:", err);
  process.exit(1);
});
