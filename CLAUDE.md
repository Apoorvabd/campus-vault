# Semester Forge (campus-vault) — Claude ke liye working rules

Ye rules user (Apoorv) ne diye hain. Har session me inhe follow karna hai, bina yaad dilaye.
Baat-cheet Hinglish me hoti hai — jawab bhi usi tone me do.

---

## 1. Behaviour rules

### 1.1 `?` = sirf samjhao, action mat lo
Agar user ke message me `?` ko marker ki tarah use kiya gaya hai, to iska matlab hai:
**sirf baat samjhani hai.** Koi file edit nahi, koi command nahi, koi branch/commit nahi, koi GitHub issue nahi.
Sirf explain karo, discuss karo, options batao.

### 1.2 "Sawal pucho" mode
Jab user bole **"sawal pucho"** (ya similar):
- Jitne bhi relevant sawal ho sakte hain, utne pucho. Kam nahi, sab ek saath.
- **Jab tak user sab sawalon ka jawab na de, aage mat badho.** Guess karke shuru mat karo.
- Agar user kisi sawal ka jawab nahi de raha, to usi sawal ko **do baar** pucho.
  Do baar puchne ke baad bhi jawab na mile, tab code likhne se pehle ek baar confirm karo ("code likhun?") — bina confirm kiye mat likho.

### 1.3 Code likhte waqt batate hue chalo
Code likhte time user ko **live batao** ki ab kya kar rahe ho ("ab schema padh raha hun", "ab service banata hun", "ab migration likhta hun").
Ye tab tak karna hai jab tak user khud na bole ki **"isko background me chalao"** — uske baad chup-chaap kaam karke end me summary do.

### 1.4 Security pehle
Security ka khayal sabse zyada rakhna hai.
- Kahin bhi koi security concern dikhe (auth gap, leaked secret, missing validation, over-permissive access, unsafe upload, etc.) to **turant user ko batao** — kaam khatam hone ka wait mat karo.
- GitHub pe issue banana ho to **pehle user se pucho**, phir banao.
- Secrets (`.env`, API keys, DB URLs, passwords) kabhi commit mat karo, kabhi chat me repeat mat karo.

### 1.5 Messy code nahi
- Clean, chhota, readable code. Aas-paas ke code ke style, naming aur comment density se match karo.
- Ek file ek kaam. Dead code, debug logs, commented-out blocks, copy-paste mat chhodo.
- Koi bhi change ke saath scope se bahar ka refactor mat karo.

### 1.6 Folder structure maintain karo
- Existing structure follow karo (neeche section 2). Nayi file wahin rakho jahan uska module hai.
- Structure badalna ho (naya folder, move, rename) to **pehle user se pucho**.

### 1.7 Branch ho to batao
Agar kisi kaam ke liye branch bana rahe ho to user ko **turant batao**: branch ka naam kya hai aur us branch pe kya kiya ja raha hai.
Commit/push/PR tabhi jab user bole. `main` pe seedha kaam mat karo agar change bada hai — branch banao aur batao.

---

## 2. Repo structure (isse maintain karna hai)

```
campus-vault/
├── backend/            Express 5 + Prisma 6 + PostgreSQL + Zod (TypeScript)
│   ├── prisma/         schema.prisma, migrations/, seed/, seed.ts
│   ├── scripts/        one-off scripts (scraper, ingest, db-status)
│   └── src/
│       ├── app.ts, server.ts
│       ├── config/     prisma, jwt, cloudinary
│       ├── middleware/ auth, role (authorize), validate, upload, error, notFound
│       ├── utils/      appError, apiResponse, asyncHandler, authCache
│       ├── routes/     index.ts (saare module routes yahin mount hote hain)
│       └── modules/<name>/   <name>.routes | controller | service | repository | validation | types
├── mobile/             Flutter app
├── web-admin/          Next.js (abhi sirf marketing/legal pages; admin panel yahin banega)
├── docs/               plans, status, guides
└── sources/            raw/seed data (subjects, resources, courses)
```

Backend ka module pattern: **routes → controller → service → repository**. Validation Zod se `*.validation.ts` me.
`web-admin/AGENTS.md` ke mutabik Next.js yahan breaking-change wala version hai — code likhne se pehle `node_modules/next/dist/docs/` padho.

---

## 3. Project context (short)

- Roles: `STUDENT`, `FACULTY`, `UNIVERSITY_ADMIN`, `SUPER_ADMIN`. `canPost` alag flag hai (role se independent).
- Resource flow: `PENDING → APPROVED / REJECTED`; `sourceType`: `HOSTED | EXTERNAL_LINK | REFERENCE_ONLY`.
- Auth: JWT + 30s in-memory `authCache` (role/isActive badalne par `invalidateAuthUser` call karna zaroori).
- DB abhi Prisma ke through hi access hoti hai (backend ek hi DB user se connect hota hai).
