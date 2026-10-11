# Semester Forge

**Your whole semester. One app.**

Semester Forge is a community-driven exam companion for university students, starting with **Delhi University (DU)**. It brings Previous Year Question Papers (PYQs), Notes, Syllabus, Lab Manuals and campus updates together, organised by course and subject, so exam week starts with *opening the app*, not with searching four Telegram groups and a Drive folder.

This repository is a monorepo with everything that makes up the product:

| Folder | What it is | Stack |
|---|---|---|
| [`mobile/`](mobile) | The student app (Android APK, iOS-ready) | Flutter, flutter_bloc, Dio |
| [`backend/`](backend) | REST API, database and seed data | Node.js, Express 5, TypeScript, Prisma, PostgreSQL |
| [`web-admin/`](web-admin) | Public landing page now, admin panel later | Next.js 16, Tailwind v4, motion |
| [`docs/`](docs) | Plans, guides, design system, status notes | Markdown / HTML |
| [`sources/`](sources) | Raw and cleaned DU catalogue data used for seeding | TypeScript / JSON |

---

## 📌 What This Actually Is

Semester Forge started as a simple idea, "give Delhi University students an easy place to download PYQs", but a plain PYQ-download site is a solved problem (dupyq.online already does it, and copying it is a dead end). The idea has since grown into something narrower and harder to copy: **an exam-companion app**, not just a paper repository.

The real value isn't the PYQs themselves. It's that a student's *entire semester's worth of scattered material* lives against the subject it belongs to, so exam week is "open the app," not "search four Telegram groups and a Drive folder."

This is built around **two pillars** that intentionally use different trust models instead of one merged system:

- **The Vault** (findability, low-noise, high-trust). Official PYQs (18,000+ seeded from the DU Question Paper Bank), notes, syllabi and lab manuals, gated by an approval workflow so junk doesn't drown out real material. A resource can live three ways:
  - **Hosted**: uploaded to Semester Forge's own storage (Cloudinary)
  - **External link**: points elsewhere (Drive, another site)
  - **Reference only**: pure metadata, no file, for "I have this locally, ask me" or crowdsourcing demand before a real upload exists

- **The Feed** (engagement, social, lower-trust). Students post updates and discussions; most people can react (comment, like, bookmark) but posting is a permission independent of role, so a trusted senior or club rep can post without being made an admin.

The feature that differentiates this from a generic PYQ site is **local resource binding**: a student can point the app at a file already sitting on their own device (a note, a scanned page, anything) and bind it to a subject without ever uploading it anywhere. Combined with the Vault's own resources, this becomes **Exam Mode**: one screen per subject, showing everything the student collected across the whole semester in a single scroll. That screen is the actual pitch.

Contribution is incentivised rather than just tolerated. Uploading approved material earns a student visible credit (reputation points), turning moderation from a chore into a reason to come back.

---

## 📱 The App (`mobile/`)

A Flutter app (Dart SDK ^3.11) using `flutter_bloc` for state, `dio` for networking and `flutter_secure_storage` for tokens. It talks to the backend in `/api/v1`.

### What students can do today

- **Sign up and log in**: two-step registration (account, then university, college, course and semester), JWT access and refresh tokens kept in secure storage.
- **Welcome and landing flow**: animated intro (Lottie) before login.
- **Pick your subjects**: choose the subjects you study this semester; the Resources tab then shows "Your Subjects" for your semester.
- **Resources tab**: subjects with their UPC code and type (DSC, DSE, GE, SEC...), opening into a **subject detail** screen with every PYQ, note, syllabus and lab manual, filterable by type, with infinite scroll.
- **Community tab (the Feed)**: post updates (with images), like, comment (comment sheet), bookmark; filter *All Posts* / *My Posts*.
- **Search**: search notes and PYQs with recent searches remembered on the device.
- **Saved**: bookmarked posts and resources in one place.
- **Add document**: contribute by **Files** (PDF), **Photos** (gallery), **Camera** (snap a page) or **Link** (Drive, Dropbox...), then tag it with title, subject and category (PYQ, Notes, Syllabus, Reference Book, Assignment, Lab Manual, Other). Uploads are sent as *Pending* and appear publicly after admin approval.
- **Local vault**: bind a file already on your phone to a subject and keep it private on the device, or share it with everyone.
- **Profile**: course, semester and college, upload/post/like counts, edit profile, curriculum view, honor code, help centre, privacy and terms.

### Planned or still mock

These screens exist but are intentionally static until their APIs are built (details in [`docs/remaining-work.md`](docs/remaining-work.md)):

- **Exam Mode** tab (shown as "Coming soon")
- **Resource Requests**, **Contributor Badges / XP** and **Storage & Cache** screens
- Notifications bell, "Forgot password", campus SSO sign-in

### Run the app

```bash
cd mobile
flutter pub get
./scripts/dev.sh              # runs against the backend on this Mac (port 5000)
```

`scripts/dev.sh` sets `adb reverse tcp:5000 tcp:5000` for connected Android devices, then runs `flutter run` with `API_BASE_URL=http://localhost:5000/api/v1`. Release builds (the APK you share) point at the deployed backend on Render by default. You can override the base URL with `--dart-define=API_BASE_URL=http://<host>:5000/api/v1`. See [`mobile/lib/core/network/api_config.dart`](mobile/lib/core/network/api_config.dart).

Build the shareable APK:

```bash
cd mobile
flutter build apk --release
```

### App structure

```text
mobile/lib/
├── core/            # network (api client, token storage), models, repositories, theme, shared widgets
└── features/
    ├── Auth/        # login, 2-step registration
    ├── landing/     # welcome / intro
    ├── catalog/     # universities, colleges, courses for sign-up
    ├── home/        # Community and Resources tabs
    ├── subjects/    # subject picks (setup)
    ├── subject/     # subject detail
    ├── resources/   # resource lists and actions
    ├── community/   # feed, comments, create post
    ├── search/      # search and recent searches
    ├── saved/       # bookmarks
    ├── upload/      # add document, create post, save choice, subject picker
    ├── local_vault/ # bind files on the device to subjects
    ├── profile/     # profile, curriculum, honor code, requests, badges, storage
    ├── support/     # help centre, privacy and terms
    └── shell/       # bottom navigation shell
```

---

## 🔧 The Backend (`backend/`)

REST API at **`/api/v1`**, with a `/health` endpoint used to wake the free-tier server on cold start.

### Tech stack

- Node.js, Express 5, TypeScript
- PostgreSQL with Prisma ORM
- JWT authentication (access and refresh tokens), bcrypt
- Cloudinary and Multer for file uploads
- Zod for request validation
- Cheerio for the DU question-paper scraper

### Modules

```text
backend/src/
├── config/        # prisma, jwt, cloudinary
├── middleware/    # auth (required and optional), error handling
├── modules/
│   ├── auth/        # register, login, refresh
│   ├── university/  # universities
│   ├── college/     # colleges
│   ├── course/      # courses
│   ├── subjects/    # subject catalogue and per-user subject picks
│   ├── resourses/   # PYQs, notes, syllabus, lab manuals (+ approval workflow)
│   ├── posts/       # feed posts and comments, likes
│   ├── bookmarks/   # saved posts and resources
│   ├── profile/     # profile and stats
│   └── upload/      # Cloudinary uploads
├── routes/
├── utils/
├── app.ts
└── server.ts
```

Database models (Prisma): `University`, `College`, `Course`, `CollegeCourse`, `Subject`, `User`, `Upload`, `Resource`, `UserFile`, `Post`, `Comment`, `Like`, `Bookmark`. See [`docs/er.png`](docs/er.png).

### Features

- User authentication and role-based access control (Student, University Admin, Super Admin)
- University, college, course and subject management
- PYQs, notes, syllabus and lab manuals with an **approval workflow** (*Pending*, *Approved*, *Rejected*)
- Resource sources: hosted, external link, reference only
- Local file binding (device files linked to a subject without upload)
- Feed posts with likes, comments and bookmarks; per-user `canPost` permission
- Public lists return approved items only; pending and rejected are visible to the uploader and admins
- Optional authentication on public reads so the API returns `isLiked` and `isBookmarked`
- File upload with Cloudinary (PDF, JPG, PNG up to 15 MB)
- Standardised API responses and centralised error handling

### Data

The seeded DU catalogue (from the DU Question Paper Bank and a cleaned community dataset in [`sources/`](sources)):

| Table | Count |
|---|---|
| Universities | 2 |
| Colleges | 71 |
| Courses | 118 |
| Subjects | 5,508 |
| Resources (PYQs) | ~18,000 |

> ⚠️ Roughly 65% of seeded resources point to a DU Question Paper Bank URL that is no longer reachable. The analysis and options are in [`docs/issue-dead-du-portal-links.md`](docs/issue-dead-du-portal-links.md).

### Run the backend

```bash
cd backend
npm install
```

Create `backend/.env`:

```env
PORT=5000
NODE_ENV=development

DATABASE_URL=

JWT_ACCESS_SECRET=
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_SECRET=
JWT_REFRESH_EXPIRES_IN=7d

CLIENT_URL=http://localhost:5173

CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

```bash
npm run prisma:migrate      # apply migrations
npx prisma db seed          # seed universities, colleges, courses, subjects, resources
npm run dev                 # http://localhost:5000
```

### Scripts

```bash
npm run dev               # tsx watch
npm run build             # tsc
npm run start             # node dist/server.js
npm run prisma:generate
npm run prisma:migrate
npm run prisma:studio
```

---

## 🌐 The Website (`web-admin/`)

A Next.js 16 app (App Router, Tailwind CSS v4, `motion`). Today it is the **public landing page** for the app. Later it will also host the **admin panel** (review uploads, manage subjects and users).

The landing page has a dark gradient design with the app's real screenshots in phone frames, a Delhi University section, FAQ and roadmap. SEO is built in: metadata, Open Graph image, `robots.txt`, `sitemap.xml` and JSON-LD (WebSite, SoftwareApplication, FAQPage).

```bash
cd web-admin
npm install
npm run dev        # http://localhost:3000
```

Set the real domain before deploying so canonical URLs and the sitemap are correct:

```env
NEXT_PUBLIC_SITE_URL=https://your-domain.com
```

The download button is not linked yet; point it at the hosted APK when it is ready.

---

## 🗺️ Where it's headed

- **App-first, not website-first.** The real product is the mobile app. The website's job is a landing page with a direct APK download link. There is no Play Store budget yet, so sideloading is the distribution channel for now.
- **Exam Mode**: the dedicated per-subject exam-week screen (everything collected in one scroll).
- **Resource requests**: ask for a paper that is missing and get notified when it is uploaded.
- **Contributor badges and levels**: reputation and XP that reflect how much your uploads help others.
- **Notifications**: upload approved, request fulfilled, replies to posts.
- **Offline downloads**: save papers on the device and study without internet.
- **Campus sign-in** (SSO) and password reset.
- **Admin console** on the web for reviewing uploads and managing subjects and users, scoped per university.
- **Play Store and iPhone** releases.
- **Backend built for rapid, screen-paired iteration.** Infrastructure (auth, middleware, upload pipeline) is built once; every feature after that is built API-and-screen together, so nothing gets built that isn't actually consumed.

---

## 📚 Documentation (`docs/`)

| Doc | What's inside |
|---|---|
| [`backend_plan.md`](docs/backend_plan.md) | Day-by-day backend execution order |
| [`vault-and-feed-plan.md`](docs/vault-and-feed-plan.md) | How the Vault and Feed pillars fit together at schema and permission level |
| [`remaining-work.md`](docs/remaining-work.md) | What is still static or mock, and open backend and app items |
| [`api-gap-analysis.md`](docs/api-gap-analysis.md) | Gaps between the app screens and the backend API |
| [`issue-dead-du-portal-links.md`](docs/issue-dead-du-portal-links.md) | The dead DU portal links problem and options |
| [`local-vault-storage.md`](docs/local-vault-storage.md) | How on-device file binding works |
| [`registration-flow-guide.md`](docs/registration-flow-guide.md) | Study guide for the login and registration flow |
| [`pre-deploy-checks.md`](docs/pre-deploy-checks.md) | Checklist before shipping |
| [`design-system.html`](docs/design-system.html) | Colours, type and components |
| [`Semester_Forge_Product_Documentation.html`](docs/Semester_Forge_Product_Documentation.html) | Product documentation |
| [`PROJECT_STATUS.md`](docs/PROJECT_STATUS.md) | Status notes and quick commands |

---

## 👤 User Roles

* Student
* University Admin
* Super Admin

## 📚 Resource Types

* Previous Year Questions (PYQ)
* Notes
* Lab Manual
* Syllabus
* Reference Book and Assignment (app categories)

## 🚦 Resource Status

* Pending
* Approved
* Rejected

---

## 🎯 Vision

Semester Forge aims to become a centralised academic platform where students can discover, contribute and share quality educational resources while maintaining content quality through an approval workflow and role-based moderation, built around one core moment: opening the app the week before an exam and finding an entire semester's worth of material already waiting, organised by subject, in one place.

> Semester Forge is a community project built by and for students. It is not affiliated with or endorsed by Delhi University.
