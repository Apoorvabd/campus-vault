# Campus Vault — Backend Execution Plan (Day-wise)

> Ye file **sirf tumhare liye day-wise TODO** hai — har din khol lo, jo likha hai wahi likho, agle din agla item. Jo ho chuka hai wo neeche sirf **✅ list** me hai (bina explanation ke), poori detailing sirf **abhi jo karna hai** uski hai.
>
> **Priority order:** Middleware → Auth → Upload service (Cloudinary) → Academic read-APIs → Resource module → **UserFile module (local-binding — core feature)** → Social module sabse aakhir me.

---

## ✅ Ho chuka hai (done)

- **Middleware** — `authenticate`, `authorize`, `validate.middleware.ts` (Zod), `error.middleware.ts` + `notFound.middleware.ts` (`app.ts` me wired), `apiResponse.ts` (`success` field fix ke saath)
- **Auth module — poora complete, tested** — `types` → `validation` → `repository` → `service` → `controller` → `routes`, sab mount hai `routes/index.ts` → `app.ts` (`/api/v1`) ke through. Register/login/refresh-token/me/logout — sab Postman/REST-Client se test ho chuke hain.
- **Cloudinary decision locked** — purana Cloudinary account reuse karna hai (0.96% credits use hue the), `campus-vault/` folder-prefix se naya data alag rakhna hai. Drive comparison abhi nahi karna, baad me.
- **`src/config/cloudinary.ts`** likh diya — config + `uploadToCloudinary()` (stream-based) + `deleteFromCloudinary()`.
- **`src/middleware/upload.middleware.ts`** likh diya — multer memory storage, fileFilter (pdf/jpg/png), 15MB limit.

---

## 1. File-likhne ka order — convention (har naye module pe follow karna)

```
1. <module>.types.ts        ← shape decide karo
2. <module>.validation.ts   ← Zod schema
3. <module>.repository.ts   ← sirf Prisma queries
4. <module>.service.ts      ← business logic
5. <module>.controller.ts   ← req/res only
6. <module>.routes.ts       ← middleware chain + controller wire
7. routes/index.ts me mount
```

**Phase 3 (Resource) onwards screen-driven jana hai** — ek Flutter screen socho, uski exact API likho, test karo, agle screen pe jao. Extra/unused endpoints mat banao.

---

## 2. Ab kya karna hai

### 🔜 Agla kaam — Upload flow test (~1.5 hrs)
Ek temporary `POST /api/v1/_test-upload` route banao jo `upload.middleware` + `uploadToCloudinary` chain karke URL wapas de. Postman/REST-Client se ek PDF bhejo, Cloudinary dashboard ke `campus-vault/` folder me file dikhni chahiye. **Kaam ho jaye to ye route delete kar dena** — sirf plumbing test tha.

> Known chhota gap (abhi block nahi karega): 15MB se badi file pe multer apna `MulterError` throw karta hai jo `AppError` nahi hai — `globalErrorHandler` abhi isko specifically handle nahi karta, generic 500 dega. Resource module test karte waqt ismein `else if (error instanceof multer.MulterError)` branch add kar dena.

### `Upload` DB record helper (~3 hrs)
Ek chhota shared helper (`src/modules/upload/upload.service.ts` ya `utils/uploadHelper.ts`) — Cloudinary se upload hone ke baad `Upload` row Prisma me create kare (`publicId`, `url`, `secureUrl`, `mimeType`, `extension`, `size`, `type`, `uploadedById`). Resource aur UserFile module dono isko reuse karenge — isliye ek hi jagah likho.

### Academic read-APIs (University/College/Course/Subject) (~4 hrs)
Read-only hain, data already seeded hai — service layer skip kar sakte ho, seedha repository → controller:
- `GET /api/v1/universities` — list
- `GET /api/v1/colleges?universityId=`
- `GET /api/v1/courses?universityId=`
- `GET /api/v1/subjects?courseId=&semester=&type=` — signup form aur "add resource" form dono me dropdown ke liye chahiye

---

## 3. WEEK 3 — Resource module (screen-driven: "Upload/Browse PYQ")

### Resource: types + validation (~2.5 hrs)
`resource.validation.ts` me sabse important part — `sourceType` ke hisaab se XOR rule Zod `.superRefine()` se enforce karo:
- `HOSTED` → file zaroori (multer se aayega, body me nahi), `externalUrl` null
- `EXTERNAL_LINK` → `externalUrl` required + valid URL, no file
- `REFERENCE_ONLY` → dono absent

### Resource: repository (~2 hrs)
`createResource`, `findMany({ subjectId?, resourceType?, status?, search?, page, limit })`, `findById`, `updateStatus`.

### Resource: service (~2.5 hrs)
Business logic branch: `sourceType === HOSTED` → upload helper call karo → `Upload` row + `Resource` row ek Prisma `$transaction` me. `EXTERNAL_LINK`/`REFERENCE_ONLY` → seedha `Resource` create, `status: PENDING` default.

### Resource: controller + routes (~2 hrs)
```
POST   /resources             → authenticate, upload.middleware.single("file"), validate, create
GET    /resources              → list (public, filters + pagination)
GET    /resources/:id          → detail
PATCH  /resources/:id/approve  → authenticate, authorize("SUPER_ADMIN","UNIVERSITY_ADMIN")
PATCH  /resources/:id/reject   → same
```

### Test + Flutter pairing (~4 hrs)
Postman se teeno `sourceType` test karo. Phir ek chhota "Browse PYQs" list screen bana ke `GET /resources` consume karo — ye first real end-to-end loop hoga.

---

## 4. WEEK 4 — UserFile module (core feature — local binding)

Ye woh feature hai jo Campus Vault ko "sirf ek aur PYQ site" hone se bachata hai.

### UserFile: types + validation (~2 hrs)
Fields: `name` (required), `subjectId` (required), `localUri?` (device path/content-uri — file nahi, sirf reference), `mimeType?`, `extension?`, `size?`. Upload optional hai — student pehle sirf "mere paas hai" bind kare, baad me chahe to real copy upload kare (`uploadId` tab fill hoga).

### UserFile: repository (~2 hrs)
`create`, `findManyByUser(userId)`, `findManyBySubject(userId, subjectId)`, `update`, `delete` (ownership check zaroori).

### UserFile: service + controller + routes (~2.5 hrs)
```
POST   /user-files                    → authenticate, validate, bind local file
GET    /user-files?subjectId=         → authenticate, list (Exam Mode query)
PATCH  /user-files/:id/upload         → authenticate, upload.middleware, real copy upload karke uploadId set
DELETE /user-files/:id                → authenticate, ownership-check, delete
```

### "Exam Mode" combined endpoint (~2 hrs)
Actual differentiator — ek endpoint jo dono jagah se data mila ke de:
```
GET /subjects/:id/bundle
→ { subject, resources: Resource[], userFiles: UserFile[] }
```
`Promise.all([resourceRepo.findMany({subjectId}), userFileRepo.findManyBySubject(userId, subjectId)])` — dono parallel.

### Test end-to-end (~3 hrs)
3-4 UserFiles bind karo 2 alag subjects me, kuch Resources bhi un subjects pe, `GET /subjects/:id/bundle` call karke verify karo dono type ek saath aa rahe hain.

### Regression pass
Sab kuch phir se chalao (register → login → subject list → resource upload → userFile bind → bundle fetch) — REST Client `.http` file ko regression collection ki tarah reuse karo.

---

## 5. Isके baad kya (scope se bahar abhi — sirf reminder list)

- Post / Comment / Like / Bookmark module (`canPost` flag schema me already hai)
- Admin approve/reject UI-level flows, moderation
- Rate limiting, Helmet, production security pass
- Cloudinary vs Drive full comparison
- **Notifications** — in-app pehle (apna `Notification` model, free), push baad me (FCM, jab real users ho)
- **PDF compression** (Ghostscript) — jab storage/bandwidth genuinely tight lage

---

*Last updated: 15 Sep 2026*
