# Campus Vault — Backend Execution Plan (Day-wise)

> Ye file **sirf tumhare liye day-wise TODO** hai — har din khol lo, jo likha hai wahi likho, agle din agla item. Order fix hai taaki roz "aaj kya karu" na sochna pade.
>
> **Priority tumne khud set ki hai:** Post/Comment/Like/Bookmark abhi nahi. Pehle — middleware pura tight, phir Auth, phir academic read-APIs (dropdowns ke liye zaroori), phir Upload service (Cloudinary), phir Resource module, phir **UserFile module (local-binding — tumhara core feature)**. Social module isके baad.
>
> Is file ko `backend_plan.md` bola tha tumne — same naam se `docs/backend_plan.md` me hai.

---

## 0. Pehle current src ka reality-check (maine padh liya hai)

Taaki tumhe pata ho kaha se shuru ho raha hai — kuch cheeze already ban chuki hain jo tumhe pata nahi shayad:

| File | Status |
|---|---|
| `src/middleware/auth.middleware.ts` | ✅ **Done aur sahi hai** — Bearer token check → verify → user fetch → `req.user` |
| `src/middleware/role.middleware.ts` | ✅ **Done** — `authorize("SUPER_ADMIN", ...)` |
| `src/middleware/error.middleware.ts` | ✅ Likha hua hai, lekin **`app.ts` me wire nahi hai abhi** — bug |
| `src/middleware/notFound.middleware.ts` | ✅ Likha hua hai, **`app.ts` me wire nahi hai abhi** — bug |
| `src/middleware/validate.middleware.ts` (Zod) | ❌ **Exist hi nahi karti** — banani hai (Day 2) |
| `src/config/jwt.ts` | ✅ Done — access + refresh, dono ready |
| `src/config/prisma.ts` | ✅ Done (singleton) |
| `src/utils/*` (apiResponse, appError, asyncHandler) | ✅ Sab done |
| `src/modules/auth/*.ts` (controller/service/repository/validation/types/routes) | ❌ **6 files bani hain, sab khaali hain** — Week 1 ka kaam |
| `src/routes/index.ts` (central router) | ❌ Exist nahi karta |
| `app.ts` | Health check hai, **koi route mount nahi hai**, error/notFound middleware bhi wire nahi hai |
| `.env` vs `.env.example` | Mismatch — `.env` me `JWT_ACCESS_SECRET`/`JWT_REFRESH_SECRET` hai, `.env.example` me purana `JWT_SECRET` likha hai — Day 1 me fix karna |
| `CLOUDINARY_*` keys | `.env` me **khaali hain** — Day 10 se pehle Cloudinary account bana ke bharna hoga |
| `cloudinary`, `multer` packages | ✅ Already `package.json` me installed — config likhna baaki hai |

**Conclusion:** foundation acha hai, galti kahi nahi hai — bas Auth module ka andar khaali hai aur do middleware wiring bugs hain. Ye sab Week 1 me clear ho jayega.

---

## 1. File-likhne ka order — ek convention pakad lo

Har module (auth ho, resource ho, userFile ho) isi order me likhna — is se sochna nahi padega:

```
1. <module>.types.ts        ← pehle shape decide karo (input/output interfaces)
2. <module>.validation.ts   ← Zod schema (types ke hi based)
3. <module>.repository.ts   ← sirf Prisma queries, koi business logic nahi
4. <module>.service.ts      ← business logic — repository ko call karta hai
5. <module>.controller.ts   ← req/res only — service ko call karta hai
6. <module>.routes.ts       ← middleware chain + controller wire
7. routes/index.ts me mount karo
```

Reasoning: neeche se upar likhte ho (data shape → DB query → logic → HTTP), to har layer ke paas pichle layer ready milta hai — beech me ruk ke "iska type kya hoga" sochna nahi padega.

**Backend-first ya screen-ke-saath?** Dono karo, lekin phase alag:
- **Phase 1–2 (Middleware + Auth + Upload service)** — ye pure infrastructure hai, koi specific screen inko drive nahi karti, sabko chahiye hi honge. Ye pehle akela likho, Flutter khole bina.
- **Phase 3 onwards (Resource, UserFile)** — yaha se **screen-driven jao**: ek screen socho ("Bind local file to subject" screen), uska exact API likho, Flutter me wahi screen banao jo usko call kare, test karo, agle screen pe jao. Isse tum wo hi APIs likhoge jo actually use hongi — extra/unused endpoints nahi banenge.

---

## 2. Cloudinary ya kuch aur?

**Abhi ke liye Cloudinary hi rakho — already sahi decision hai, badalne ki zaroorat nahi:**

- Package already installed hai (`package.json` me `cloudinary": "^2.10.0"`), schema (`Upload` model) already Cloudinary ki shape follow karta hai (`publicId`, `url`, `secureUrl`) — badalne se rework hoga.
- Free tier: 25 credits/month (~25GB storage+bandwidth combined) — PYQ PDFs (usually 1-5MB) ke liye MVP + beta ke liye kaafi hai.
- Direct `multer` + `cloudinary` integration well-documented hai, PDF aur image dono handle karta hai.

**Google Drive** ka comparison abhi nahi kar raha — tumne khud bola baad me discuss karenge. Ek line abhi ke liye: Drive API quota/auth flow zyada complex hai ek single-owner service-account setup ke liye, aur `Resource.sourceType = EXTERNAL_LINK` already Drive links ko bina kisi extra kaam ke support karta hai (student khud Drive link paste kar sakta hai) — to Drive "apna storage" ki jagah "external link ka ek source" bankar already fit ho jata hai schema me. Jab volume badhega aur Cloudinary free tier tight lagne lage, tab full comparison karenge.

---

## 3. WEEK 1 — Middleware complete + Auth module

### Day 1 — Housekeeping + middleware wiring bugs fix (~1.5–2 hrs)
1. Working tree commit karo (migrations, schema, seed changes, scraper — pichli baar discuss kiya tha).
2. `.env.example` ko `.env` se match karo: `JWT_SECRET` hata ke `JWT_ACCESS_SECRET` / `JWT_REFRESH_SECRET` / `JWT_ACCESS_EXPIRES_IN` / `JWT_REFRESH_EXPIRES_IN` likho.
3. `src/app.ts` me neeche add karo (order matters — sabse last me):
   ```
   app.use(notFoundHandler)       // sab routes ke baad
   app.use(globalErrorHandler)    // sabse last
   ```
   (`src/middleware/index.ts` se already export ho rahe hain — bas `app.ts` me import + use karna hai.)
4. `src/routes/index.ts` banao — abhi khaali central router (`express.Router()`), `app.ts` me `app.use("/api/v1", router)` laga do. Health check bhi yaha shift kar sakte ho (`GET /api/v1/health`).

### Day 2 — Validation middleware (Zod) (~2 hrs)
1. `src/middleware/validate.middleware.ts` likho — ek generic function jo `{ body?, params?, query? }` Zod schemas leta hai aur teeno ko parse/replace karta hai request pe, fail hone pe `AppError(400, ...)` (Zod ke issues ko readable message me join karke).
2. `middleware/index.ts` me export add karo.
3. Ek dummy route pe laga ke test karo (Postman se galat body bhejo, 400 aana chahiye clean message ke saath) — phir dummy route hata do.

### Day 3 — Auth: types + validation (~2 hrs)
`src/modules/auth/auth.types.ts`:
- `RegisterInput` — firstName, lastName?, username, email, password, universityId, collegeId, courseId, currentSemester (ye sab `User` model me required hain — signup form me dropdown-selected aayenge)
- `LoginInput` — email, password
- `JwtUserPayload` — userId, email, role
- `AuthTokens` — accessToken, refreshToken

`src/modules/auth/auth.validation.ts`:
- `registerSchema`, `loginSchema` (Zod) — email format, password min-length (8), username pattern (alphanumeric+underscore), currentSemester positive int.

### Day 4 — Auth: repository + service (~2.5 hrs)
`auth.repository.ts`: `findUserByEmail`, `findUserByUsername`, `createUser`, `findUserById` — sirf Prisma calls, kuch aur nahi.

`auth.service.ts`:
- `registerUser(input)` → email/username duplicate check → `bcrypt.hash(password, 10)` → `createUser` → tokens generate (`generateAccessToken`/`generateRefreshToken` already `config/jwt.ts` me hain) → return `{ user, tokens }`
- `loginUser(input)` → findUserByEmail → `bcrypt.compare` → tokens generate
- `refreshTokens(refreshToken)` → `verifyRefreshToken` → naya access token
- `getCurrentUser(userId)` → findUserById (password hash exclude karke)

> Refresh token ko DB me store/rotate karna (`path.md` §22 ka "future requirement") **abhi skip karo** — stateless refresh MVP ke liye theek hai, baad me upgrade karna.

### Day 5 — Auth: controller + routes + mount (~2 hrs)
`auth.controller.ts` — har function `asyncHandler` me wrapped, `sendResponse` se response bhejo:
- `register`, `login`, `refresh`, `logout` (abhi sirf client-side token clear karne ka signal — 200 bhej do), `getMe`

`auth.routes.ts`:
```
POST /register   → validate(registerSchema) → register
POST /login       → validate(loginSchema)    → login
POST /refresh     → refresh
POST /logout      → authenticate → logout
GET  /me          → authenticate → getMe
```

`routes/index.ts` me: `router.use("/auth", authRoutes)`.

### Day 6 — Auth end-to-end test (~1.5–2 hrs)
Postman/Thunder Client me: register → login → `/me` with Bearer token → refresh → ek galat password se login try (401 aana chahiye) → ek duplicate email se register try (409 aana chahiye, `error.middleware.ts` ka P2002 handler already isko cover karta hai).

### Day 7 — Buffer / catch-up
Jo bhi din chuta ho ya bug mila ho, isi din clear karo. Week 2 clean start honi chahiye.

---

## 4. WEEK 2 — Academic read-APIs + Upload service (Cloudinary)

### Day 8 — University + College read APIs (~2 hrs)
Ye **read-only** hain aur data already seeded hai — to service layer skip kar sakte ho, seedha repository → controller:
- `GET /api/v1/universities` — list
- `GET /api/v1/colleges?universityId=` — filter by university

### Day 9 — Course + Subject read APIs (~2 hrs)
- `GET /api/v1/courses?universityId=`
- `GET /api/v1/subjects?courseId=&semester=&type=` — ye query signup form aur "add resource" form dono me dropdown ke liye chahiye hogi

### Day 10 — Cloudinary config + Multer middleware (~2.5 hrs)
1. Cloudinary free account banao (agar nahi bana), `.env` me 3 keys bharo.
2. `src/config/cloudinary.ts` — `cloudinary.config()` env se, plus do helper: `uploadToCloudinary(buffer, folder, resourceType)` aur `deleteFromCloudinary(publicId)`.
3. `src/middleware/upload.middleware.ts` — `multer` memory storage, file-filter (`pdf`, `jpg`, `png` only), size limit (~15MB), export `upload.single("file")`.

### Day 11 — Upload flow test (throwaway route) (~1.5 hrs)
Ek temporary `POST /api/v1/_test-upload` route banao jo `upload.middleware` + `uploadToCloudinary` chain karke URL wapas de. Postman se ek PDF bhejo, Cloudinary dashboard me file dikhni chahiye. **Kaam ho jaye to ye route delete kar dena** — ye sirf plumbing test tha.

### Day 12–13 — `Upload` DB record helper (~3 hrs)
Ek chhota shared helper (`src/modules/upload/upload.service.ts` ya `utils/uploadHelper.ts`) — Cloudinary se upload hone ke baad `Upload` row Prisma me create kare (`publicId`, `url`, `secureUrl`, `mimeType`, `extension`, `size`, `type`, `uploadedById`). Ye Resource module aur UserFile module dono reuse karenge — isliye ek jagah likho.

### Day 14 — Buffer

---

## 5. WEEK 3 — Resource module (screen-driven: "Upload/Browse PYQ")

Yaha se pairing shuru: ek Flutter screen socho, uski exact API likho.

### Day 15 — Resource: types + validation (~2.5 hrs)
`resource.validation.ts` me sabse important part — `sourceType` ke hisaab se XOR rule Zod `.superRefine()` se enforce karo:
- `HOSTED` → file zaroori (multer se aayega, body me nahi — controller level check), `externalUrl` null
- `EXTERNAL_LINK` → `externalUrl` required + valid URL, no file
- `REFERENCE_ONLY` → dono absent

### Day 16 — Resource: repository (~2 hrs)
`createResource`, `findMany({ subjectId?, resourceType?, status?, search?, page, limit })`, `findById`, `updateStatus`.

### Day 17 — Resource: service (~2.5 hrs)
Business logic branch: `sourceType === HOSTED` → upload helper (Day 12-13 wala) call karo → `Upload` row + `Resource` row ek Prisma `$transaction` me. `EXTERNAL_LINK`/`REFERENCE_ONLY` → seedha `Resource` create, `status: PENDING` default.

### Day 18 — Resource: controller + routes (~2 hrs)
```
POST   /resources             → authenticate, upload.middleware.single("file"), validate, create
GET    /resources              → list (public, filters + pagination)
GET    /resources/:id          → detail
PATCH  /resources/:id/approve  → authenticate, authorize("SUPER_ADMIN","UNIVERSITY_ADMIN")
PATCH  /resources/:id/reject   → same
```

### Day 19–20 — Test + Flutter pairing (~4 hrs total)
Postman se teeno `sourceType` test karo. Phir (agar is week Flutter bhi chhoo rahe ho) ek chhota "Browse PYQs" list screen bana ke `GET /resources` consume karo — ye first real end-to-end loop hoga.

### Day 21 — Buffer

---

## 6. WEEK 4 — UserFile module (tumhara core feature — local binding)

Ye woh feature hai jo Campus Vault ko "sirf ek aur PYQ site" hone se bachata hai — priority sahi hai.

### Day 22 — UserFile: types + validation (~2 hrs)
Fields: `name` (required), `subjectId` (required), `localUri?` (device path/content-uri — file nahi, sirf reference), `mimeType?`, `extension?`, `size?`. Upload optional hai — student pehle sirf "mere paas hai" bind kare, baad me chahe to real copy upload kare (`uploadId` tab fill hoga).

### Day 23 — UserFile: repository (~2 hrs)
`create`, `findManyByUser(userId)`, `findManyBySubject(userId, subjectId)`, `update`, `delete` (ownership check zaroori — user apni hi file delete kar sake).

### Day 24 — UserFile: service + controller + routes (~2.5 hrs)
```
POST   /user-files                    → authenticate, validate, bind local file
GET    /user-files?subjectId=         → authenticate, list (Exam Mode query — same jo bundle me use hogi)
PATCH  /user-files/:id/upload         → authenticate, upload.middleware, real copy upload karke uploadId set
DELETE /user-files/:id                → authenticate, ownership-check, delete
```

### Day 25 — "Exam Mode" combined endpoint (~2 hrs)
Ye tumhara actual differentiator hai — ek endpoint jo dono jagah se data mila ke de:
```
GET /subjects/:id/bundle
→ { subject, resources: Resource[], userFiles: UserFile[] }
```
`Promise.all([resourceRepo.findMany({subjectId}), userFileRepo.findManyBySubject(userId, subjectId)])` — dono parallel. Ye single API call se Flutter ki "Exam Mode" screen ban jayegi.

### Day 26–27 — Test end-to-end (~3 hrs)
3-4 UserFiles bind karo 2 alag subjects me, kuch Resources bhi un subjects pe, `GET /subjects/:id/bundle` call karke verify karo dono type ek saath aa rahe hain.

### Day 28 — Buffer + regression pass
Sab kuch ek baar phir se Postman me chalao (register → login → subject list → resource upload → userFile bind → bundle fetch) — agar Postman collection bana rakhi hai to save kar lo, har week ke end me yahi collection re-run kar sakte ho regression ke liye.

---

## 7. Isके baad kya (jab UserFile solid ho jaye)

Ye ab explicitly **is plan ke scope se bahar hai** — jab upar ka sab kaam ho jaye tab discuss karenge:
- Post / Comment / Like / Bookmark module (`canPost` flag already schema me hai)
- Admin approve/reject UI-level flows, moderation
- Rate limiting, Helmet, production security pass
- Cloudinary vs Drive ka full comparison (jaisa tumne bola tha baad me)
- **Notifications (push + in-app)** — neeche note kiya hai, Social module ke saath hi karna

### Notifications — jab wo phase aaye, tab ye karna

Do alag cheezein hain, alag kaam:

- **In-app notification** (bell icon list — "tumhara resource approve hua", "kisi ne comment kiya") → koi external service nahi chahiye. Sirf apna `Notification` model (`userId`, `type`, `message`, `isRead`, `linkTo`) + `GET /notifications` endpoint. Jab bhi approval/comment/like jaisa event ho, service layer se ek row insert kar do. **Ye pehle karna** — free hai aur turant value deta hai.
- **Push notification** (app band ho tab bhi phone pe aaye) → **Firebase Cloud Messaging (FCM)**, free. Flutter side `firebase_messaging` (device token generate karta hai), backend side `firebase-admin` package se us token pe push bhejo. Play Store ki zaroorat nahi — sideloaded APK pe bhi FCM chalta hai (bas phone me Google Play Services hona chahiye, jo almost sab Android phones me hota hai). Schema me tab ek chhota addition chahiye hoga: `User.deviceToken String?`. **Ye baad me karna** — real users aane ke baad hi value deta hai, warna push karne ke liye koi receiver hi nahi hoga.

---

*Last updated: 13 Sep 2026*
