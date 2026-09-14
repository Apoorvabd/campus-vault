# Campus Vault — Project Status

_Last updated: 2026-09-10_

## 1. Repo me abhi kya chal raha hai (git status)

Ye sab **abhi tak commit nahi hua hai** — sirf working tree me hai.

### Naye files (untracked)
| File | Kya hai |
|---|---|
| `sources/subjects.ts` | 5,508 subjects (DU ke saare courses ke) |
| `sources/resources.ts` | 21,510 PYQ resource entries (course-matched) |
| `backend/prisma/seed/Resource.seed.ts` | Resource table ka seed script |
| `backend/prisma/seed/LocalCollege.seed.ts` | Test colleges ka seed |
| `backend/scripts/scrape-pyq.ts` | DU Question Paper Bank ka scraper (login + search + PDF-link extraction) |
| `backend/scripts/output/` | Scraper ke results (JSON files — gitignored) |
| `backend/prisma/migrations/20260905103352_make_subject_semester_optional/` | Naya migration (semester ko optional banaya) |
| `backend/prisma/migrations/20260902212112_init/`, `20260904151141_add_user_files/` | Pehle se the, abhi tak commit nahi hue |
| `papers.md`, `cources.md`, `all.json`, `all.clean.json`, `all.filtered.json` | Raw/working data files (DU portal + dupyq.online se) |

### Modified files
| File | Kya badla |
|---|---|
| `backend/prisma/schema.prisma` | `Subject.semester` ab optional (`Int?`); `Resource` me `@@unique([subjectId, externalUrl])` add kiya |
| `backend/prisma/seed.ts` | Seed chain wire kiya: University → College → Course → Subject → Resource |
| `sources/course.ts` | 116 → **118 courses** (2 naye add kiye: BAHSS, BTECHITMI); sabka `durationYears: 4`, `totalSemesters: 8` |
| `backend/prisma/seed/subjects.seeed.ts`, `Admin.seed.ts`, `college.seed.ts` | Minor fixes |
| `backend/.gitignore`, `.env.example`, `package.json` | Scraper ke liye env vars aur `cheerio` dependency add |

### Deleted (138 files)
`backend/.agents/skills/prisma-*` aur `backend/.claude/skills/prisma-*` — ye Prisma ki bundled skill-docs thi (reference material), tracked thi par ab delete dikha rahi hai git status me. **Ye maine nahi kiya** — pehle se hi tumhare working tree me tha jab session shuru hua. Verify kar lena ki ye intentional hai.

---

## 2. Database — abhi actual state (live check kiya)

| Table | Count |
|---|---|
| University | 2 |
| College | 71 |
| Course | 118 |
| **Subject** | **5,508** |
| **Resource (PYQs)** | **18,192** |
| User | 1 (admin) |

Poora seed chain successfully chal chuka hai. Resources me `externalUrl` DU ke apne server (`qb.exam.du.ac.in`) ka direct link hai — koi PDF apne server pe host nahi ki.

---

## 3. Is session me kya-kya hua (poori journey, short me)

1. **Seed file debug kiya** — `password` vs `passwordHash` field-mismatch bug dhoondha (User seed)
2. **`course.ts`** ko schema-compliant banaya — `durationYears` add kiya, `totalSemesters` fill kiya
3. **`subjects.ts`** banaya `papers.md` se (jo tumne dupyq.online se manually copy kiya tha) — UPC/type/credits clean kiye, duplicates/garbage-codes hataye
4. **Semester data** ke liye kaafi analysis ki — DSC/3-rule test kiya aur **51% galat nikla** (reject kiya), sirf verified explicit patterns use kiye
5. **dupyq.online ka architecture samjha** — wo khud PDF host nahi karta, sirf DU ke official `qb.exam.du.ac.in` portal ko index karta hai
6. **Apna scraper likha** (`scrape-pyq.ts`) — DU portal pe login karke UPC-wise search, PDF link + session/marks/set nikaalta hai
7. **Schema update kiya** — `Subject.semester` optional banaya, `Resource` me `[subjectId, externalUrl]` unique constraint add kiya (multi-file-per-UPC support ke liye)
8. **dupyq ka poora catalog (29,319 entries)** download karke clean kiya, UPC extract kiya, tumhare 118 courses tak filter kiya
9. **`resources.ts` (21,510)** aur expanded **`subjects.ts` (5,508)** banaye
10. **Poora DB seed kiya** — kai iterations me (migration lagi, admin-seed bug fix kiya), final: **18,192 resources** DB me

---

## 4. Ab aage kya sochna hai (open items)

- [ ] **3,318 resources abhi bhi skip ho rahe hain** — unka `Subject.type` papers.md/dupyq data se nikal nahi paya (jaise BAPMAM: 490, BAPS: 208, BSCS: 177 waghera). Inhe manually ya kisi aur source se resolve karna hoga, ya accept kar lo jitna mila utna hai.
- [ ] **138 deleted Prisma skill files** — verify karo ye intentional hai ya accidental.
- [ ] **Migrations abhi commit nahi hue** — DB pe apply ho chuki hain, par git me nahi hain. Commit karna zaroori hai taaki team/deploy sync rahe.
- [ ] **Koi bhi commit nahi hua is poore session me** — sab kuch working tree me pending hai. Jab ready ho, ek ya multiple commits me organize karna hoga.
- [ ] `backend/scripts/output/` gitignored hai (theek hai, scraped data hai) — lekin `all.json`, `all.clean.json`, `all.filtered.json`, `papers.md`, `cources.md` root me pade hain, untracked — inhe bhi gitignore karna chahiye ya cleanup, kyunki ye working/raw data files hain, source code nahi.
- [ ] `Resource.seed.ts` me `uploadedById`/`approvedById` hardcoded admin ID use karta hai — production me ye theek hai for bulk-import, par documented hona chahiye kyun.

---

## 5. Quick reference — chalane ke commands

```bash
# Seed poora chain chalane ke liye
cd backend
npx prisma db seed

# Scraper (naye UPCs ke liye, agar future me chahiye)
npx tsx scripts/scrape-pyq.ts

# DB counts check karne ke liye
npx tsx -e "import {PrismaClient} from '@prisma/client'; const p=new PrismaClient(); (async()=>{console.log(await p.resource.count())})()"
```
