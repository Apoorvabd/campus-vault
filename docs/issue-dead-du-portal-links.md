# ISSUE: ~65% of resources point to a dead DU Question Paper Bank link

| | |
|---|---|
| **Status** | Open (not started) |
| **Priority** | High before public launch |
| **Owner** | Apoorv (will fix in the coming days) |
| **Reported** | 2026-10-07 |
| **Labels** | data, resources, launch-blocker |

## 1. Summary

Of the **18,194** resources in the database, **11,902 (65%)** link to
`https://qb.exam.du.ac.in/uploads/questions/*.pdf`. Those links no longer
return a file. Users who tap "Open" get an error page, not a PDF.

## 2. Numbers (database, read-only count on 2026-10-07)

| Link host | Rows | Share | Health (sampled) |
|---|---|---|---|
| `qb.exam.du.ac.in` (DU Question Paper Bank) | **11,902** | 65% | **300 of 300 sampled returned 404** |
| `drive.google.com` | 5,085 | 28% | 100 of 100 sampled OK (direct download works) |
| `academicaffairs.du.ac.in` | 1,205 | 7% | 25 of 40 OK; 15 could not be tested (URLs with spaces / special characters, my test tool could not send them; probably fine) |
| other (2 test rows created by Claude while testing) | 2 | 0% | PENDING, link `example.com`, safe to delete |

All 18,194 rows are `sourceType = EXTERNAL_LINK`. No file is hosted by us.
11,902 of them are `APPROVED`, so users currently see them.

Estimated usable today: about **5,850 confirmed** + about 450 probable.
Estimated dead: about **11,900**.

Subject coverage if the dead rows are removed:

- Subjects total: 5,508. With at least one **working** resource: **2,572 (47%)**.
- **2,904 subjects (53%) would have nothing.**
- 115 of 116 courses keep at least one subject. By coverage: 13 courses
  are 75% or better, 34 are 50 to 75%, 35 are 25 to 50%, 34 are below 25%.
- Per-subject list: `docs/subjects-with-working-resources.csv`
  (columns: course, semester, subject, code, type, working, dead).

## 3. What is actually wrong (evidence)

1. `qb.exam.du.ac.in` now resolves to `35.244.29.224` (Google Cloud) and
   serves a **different DU application**, the "Competence Enhancement Scheme
   (CES)" site. Its TLS certificate is for `www.ces.du.ac.in` (hostname
   mismatch, so browsers show "Not Secure"), and its 404 page says
   "Competence Enhancement Scheme (CES): 2025-2026".
2. The old Question Paper Bank had a public search (`/web-search`) in a
   Wayback snapshot of **2026-03-09**. Today `/web-search`, `/login` and every
   `/uploads/questions/*.pdf` path return **404**; `/` redirects to
   `/index.php/site/login`.
3. SRCC notices say students reach the portal with a **DU domain email ID**,
   so access is restricted to logged-in DU students.
4. The data in this repo (`sources/all.json`, snapshot 2026-09-12, scraped
   with the owner's own login at the time) contains the DU URLs. Those URLs
   worked when scraped; they do not now.

What is **not** known: whether the portal moved to a new URL, is behind a
login that now hides files, was briefly misconfigured during a server
migration, or was closed on purpose. The old public web-search result still
lists `qb.exam.du.ac.in` as current, so it may be temporary.

## 4. How dupyq.online (a competitor/inspiration) handled it

Facts observed from public data on 2026-10-07:

- Its catalog (`/data/papers/courses/<course>.json`, 111 course files) holds
  **20,713 papers, 100% on `drive.google.com`, 0 on `du.ac.in`**.
- The snapshot of its catalog saved in `sources/all.json` (2026-09-12) was
  **mixed**: 13,229 DU-portal links plus 8,018 Drive links. So the change to
  100% Drive happened within about four weeks.
- Ids changed from `du-qb-<n>` to `drive-<driveFileId>`. File names follow
  `UPC - Subject - Type - Course`. Its front end has "catalog overrides"
  (edit, hide, replace URL) and a `/api/papers-zip` endpoint that builds zips
  from Drive file ids.
- Files carry a watermark (reported by the owner).
- The site says "Not affiliated with the University of Delhi" and has Pricing
  and Refund pages.

Inference (not verified): it downloaded the papers while the DU portal was
reachable, re-hosted them on Google Drive, and replaced the catalog URLs.

Other **public, working** sources found: college-hosted pages with direct
PDFs, e.g. Sri Aurobindo College (`aurobindo.du.ac.in/question-papers`,
about 268 PDF references), SBS (`sbs.du.ac.in/previous-question-papers/`,
about 88), Shyam Lal College (`slc.du.ac.in/Library/previous-years-question-papers`,
about 27), ANDC (`andcollege.du.ac.in/studentcorner/questionpapers`, about 13).
The old `web.du.ac.in/PreviousQuestionPapers/` no longer responds.

## 5. Options

| # | Option | Pros | Cons |
|---|---|---|---|
| A | **Do nothing** | none | 65% of Open buttons fail |
| B | **Set the dead rows to PENDING** | one SQL update, no code | PENDING means "awaiting review", it will flood a future admin queue; needs a marker + backup of ids to undo; writes 11,902 rows to the hosted DB |
| C | **Backend flag `DU_QB_AVAILABLE=false`** hides rows whose `externalUrl` contains `qb.exam.du.ac.in` | no DB writes, flip back to `true` when the portal returns, admin queue stays clean | a little backend code, one extra filter in list/search/bookmark queries |
| D | **Show but disable**: card visible, Open shows "File unavailable on DU's portal right now" | honest, nothing lost | cards are useless until fixed |
| E | **Replace dead URLs with Drive links from dupyq** (match on UPC + year + set) | about 90% of the dead rows have a candidate (11,566 of 12,778 matched on UPC + year in a quick check) | depends on a third party (permission / terms, Drive quotas, files may disappear); sets must be matched carefully |
| F | **Host the files ourselves** (Cloudflare R2 / S3 / Cloudinary), flip rows from `EXTERNAL_LINK` to `HOSTED` | no outside dependency, no warnings, full control | needs a legitimate source of the PDFs first; about 10 to 20 GB; copyright and DU / source terms |
| G | **Add public college-hosted PDFs** as a clean extra source | official, public, no login | small and uneven coverage |
| H | **Wait for DU** (it may be temporary) and re-check weekly | zero effort | no guarantee |

The data model already supports a later move to F: `Resource.sourceType`
(`EXTERNAL_LINK` to `HOSTED`) and `uploadId`. The app opens `Resource.fileUrl`
either way, so **no app change is needed** when links are swapped or hosted.

## 6. Plan

**Owner's interim plan (decided 2026-10-07):**

- For the courses taught in the owner's own college, get the papers from
  dupyq and keep **only about 100 files and their links** locally (small,
  limited scope). Finish the full fix later.
- Suggested care: keep it to a small number of files, keep **links and
  metadata** (not a bulk copy), and contact dupyq for permission before
  anything public. dupyq's terms were not found on its site (the usual
  /terms, /about, /disclaimer paths return 404; the footer links Terms /
  Privacy / Contact).
- Match each dupyq row to an existing Subject using `upc`, `yearRange` and the
  set in `note` (dupyq fields: `id, yearRange, semesterGroup, course, subject,
  semester, pdfUrl, note, source, fileName, upc, paperType, verified, college`).

**Before launch (pick one, they can be combined):** C (or B) to stop showing
dead links, plus E/F/G over time. Re-check DU weekly (section 8).

## 7. Reversible way to hide rows in the database (option B)

Back up first, then mark so it can be undone. Table and column names are
Prisma defaults (quoted camelCase).

```sql
-- 1. backup the ids (psql)
\copy (SELECT id FROM "Resource" WHERE "externalUrl" LIKE '%qb.exam.du.ac.in%') TO 'dead_du_ids.csv' CSV

-- 2. hide, with a marker
UPDATE "Resource"
SET status = 'PENDING', "rejectionReason" = 'DU_QB_OFFLINE_2026-10-07'
WHERE "externalUrl" LIKE '%qb.exam.du.ac.in%' AND status = 'APPROVED';
-- expected: 11902 rows

-- 3. undo when DU is back
UPDATE "Resource"
SET status = 'APPROVED', "rejectionReason" = NULL
WHERE "rejectionReason" = 'DU_QB_OFFLINE_2026-10-07';
```

Option C sketch (no DB change): read `process.env.DU_QB_AVAILABLE`; when it is
`"false"`, add `NOT: { externalUrl: { contains: "qb.exam.du.ac.in" } }` to the
`where` in `findResources` (and the bookmarked-resources query).

## 8. How to re-check the DU portal (read-only)

```bash
# who answers for the hostname and what certificate it presents
echo | openssl s_client -connect qb.exam.du.ac.in:443 -servername qb.exam.du.ac.in 2>/dev/null \
  | openssl x509 -noout -subject -dates

# is a sample PDF back? (-k ignores the certificate error)
curl -sk -o /dev/null -w "%{http_code}\n" \
  https://qb.exam.du.ac.in/uploads/questions/1778057936.pdf    # 404 today, 200 when fixed

# is the public search back?
curl -sk -o /dev/null -w "%{http_code}\n" https://qb.exam.du.ac.in/web-search
```

Contact (from the old portal page): Examination Branch, University of Delhi;
controllerofexamination@exam1.du.ac.in; 011-27662449.

## 9. Count query (to re-measure)

```sql
SELECT CASE
  WHEN "externalUrl" LIKE '%qb.exam.du.ac.in%'          THEN 'du-portal'
  WHEN "externalUrl" LIKE '%drive.google.com%'          THEN 'drive'
  WHEN "externalUrl" LIKE '%academicaffairs.du.ac.in%'  THEN 'academicaffairs'
  ELSE 'other' END AS host, count(*)
FROM "Resource" GROUP BY 1;
```

## 10. Open questions

- Did the DU Question Paper Bank move to a new URL, or is access now limited
  to logged-in DU students only?
- Does dupyq allow other apps to link to its Drive files?
- Is a bulk re-host of DU question papers allowed by DU (copyright and portal terms)?
- Which "launch scope" is acceptable: only popular courses (about 47% of
  subjects covered today) or all of DU?

## 11. Related

- `docs/subjects-with-working-resources.csv`: per-subject working vs dead counts
- `docs/remaining-work.md`: other open items
- `backend/prisma/schema.prisma`: `Resource`, `ResourceSourceType`, `ResourceStatus`
- Seed sources: `sources/resources.ts`, `sources/all.json`, `sources/all.filtered.json`
