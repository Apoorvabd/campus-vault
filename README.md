# Semester Forge Backend

Backend API for **Semester Forge** — a community-driven platform for university students to access and contribute Previous Year Question Papers (PYQs), Notes, Syllabus, Lab Manuals, and academic updates.

---

## 📌 What This Actually Is

Semester Forge started as a simple idea — "give Delhi University students an easy place to download PYQs" — but a plain PYQ-download site is a solved problem (dupyq.online already does it, and copying it is a dead end). The idea has since grown into something narrower and harder to copy: **an exam-companion app**, not just a paper repository.

The real value isn't the PYQs themselves — it's that a student's *entire semester's worth of scattered material* lives against the subject it belongs to, so exam week is "open the app," not "search four Telegram groups and a Drive folder."

This is built around **two pillars** that intentionally use different trust models instead of one merged system:

- **The Vault** — findability, low-noise, high-trust. Official PYQs (18,000+ already seeded from the DU Question Paper Bank), notes, syllabi and lab manuals, gated by an approval workflow so junk doesn't drown out real material. A resource can live three ways:
  - **Hosted** — uploaded to Semester Forge's own storage (Cloudinary)
  - **External link** — points elsewhere (Drive, another site)
  - **Reference only** — pure metadata, no file, for "I have this locally, ask me" or crowdsourcing demand before a real upload exists

- **The Feed** — engagement, social, lower-trust. Students post updates and discussions; most people can react (comment/like/bookmark) but only a smaller, admin-granted set of users can post — a permission independent of role, so a trusted senior or club rep can post without being made an admin.

The feature that actually differentiates this from a generic PYQ site is **local resource binding**: a student can point the app at a file already sitting on their own device — a note, a scanned page, anything — and bind it to a subject without ever uploading it anywhere. Combined with the Vault's own resources, this becomes **Exam Mode**: one screen, per subject, showing everything the student collected across the whole semester in a single scroll. That screen is the actual pitch.

Contribution is incentivized rather than just tolerated — uploading approved material earns a student visible credit (reputation points), turning moderation from a chore into a reason to come back.

### Where it's headed

- **App-first, not website-first.** The real product is a mobile app (Flutter). The website's only job is a landing page with a direct APK download link — there's no Play Store budget yet, so sideloading is the distribution channel for now.
- **Backend built for rapid, screen-paired iteration.** Infrastructure (auth, middleware, upload pipeline) is built once, standalone; every feature after that is built API-and-screen together, so nothing gets built that isn't actually consumed.
- **Full build sequencing lives in [`docs/backend_plan.md`](docs/backend_plan.md)** (day-by-day backend execution order) and **[`docs/vault-and-feed-plan.md`](docs/vault-and-feed-plan.md)** (how the Vault and Feed pillars fit together at the schema/permission level).

---

## 🔧 Tech Stack

* Node.js
* Express.js
* TypeScript
* PostgreSQL
* Prisma ORM
* JWT Authentication
* Cloudinary
* Multer
* Zod
* PWA Ready (Frontend)

---

## ✨ Features

* User Authentication
* Role Based Access Control (RBAC)
* University & College Management
* Course & Subject Management
* Previous Year Question Papers (PYQs)
* Notes Upload
* Local file binding (a student's own on-device files, linked to a subject without uploading)
* Resource Approval Workflow
* Academic Posts
* Likes & Comments
* Bookmarks
* File Upload with Cloudinary
* Standardized API Responses
* Centralized Error Handling

---

## 📁 Project Structure

```text
src/
│
├── config/
├── middleware/
├── modules/
│   ├── auth/
│   ├── user/
│   ├── university/
│   ├── college/
│   ├── course/
│   ├── subject/
│   ├── resource/
│   ├── post/
│   ├── comment/
│   ├── like/
│   ├── bookmark/
│   ├── admin/
│
├── prisma/
├── routes/
├── types/
├── utils/
│
├── app.ts
├── server.ts
```

---

## 👤 User Roles

* Student
* University Admin
* Super Admin

---

## 📚 Resource Types

* Previous Year Questions (PYQ)
* Notes
* Lab Manual
* Syllabus

---

## 🚦 Resource Status

* Pending
* Approved
* Rejected

---

## ⚙️ Installation

```bash
git clone <repository-url>

cd backend

npm install
```

Create `.env`

```env
PORT=5000

DATABASE_URL=

JWT_SECRET=

JWT_EXPIRES_IN=7d

CLIENT_URL=http://localhost:5173

CLOUDINARY_CLOUD_NAME=

CLOUDINARY_API_KEY=

CLOUDINARY_API_SECRET=
```

Run the development server

```bash
npm run dev
```

---

## 📜 Scripts

```bash
npm run dev
npm run build
npm run start

npm run prisma:generate
npm run prisma:migrate
npm run prisma:studio
```

---

## 🔗 API Version

```
/api/v1
```

---

## 🎯 Vision

Semester Forge aims to become a centralized academic platform where students can discover, contribute, and share quality educational resources while maintaining content quality through an approval workflow and role-based moderation — built around one core moment: opening the app the week before an exam and finding an entire semester's worth of material already waiting, organized by subject, in one place.
