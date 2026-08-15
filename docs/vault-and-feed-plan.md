# Campus Vault — Vault + Social Feed: How They Fit in One App

> **Purpose of this doc:** you already have a full backend roadmap in [`path.md`](./path.md).
> That doc tells you *the order to build things in*. This doc answers a narrower question you
> asked directly: **"I have two ideas — a document vault, and a social feed — how do I combine
> them into one coherent app instead of two bolted-together features?"**
>
> No code is written here. This is the design decision layer that should exist *before* Phase 5
> (Resource System) and Phase 6 (Social) in `path.md` are implemented, because a couple of small
> schema/permission decisions made now will save you a rework later.

---

## 1. The two pillars, restated

**Pillar A — The Vault (utility, low-noise, high-trust)**
Students store and retrieve PYQs, notes, syllabi, lab manuals. A document either:
- lives on Campus Vault's own storage (Cloudinary), or
- lives elsewhere on the internet (Drive link, another site) and Campus Vault just indexes/points to it, or
- lives only on the student's device and they simply want it *discoverable* (metadata entry, no file at all — "ping me if you have this").

This pillar's job is **findability and trust**: search, filter by course/subject/semester, and an
approval workflow so junk doesn't drown out real material.

**Pillar B — The Feed (engagement, social, lower-trust)**
Students post updates, announcements, discussions. Others comment, like, bookmark. This pillar's
job is **engagement and voice control** — not everyone should be able to post, but most people
should be able to react.

These are different trust models on purpose: the Vault wants *many contributors, gated by
moderation*; the Feed wants *few posters, open reactions*. Don't merge their permission logic —
merge their *presentation* and *infrastructure* instead. That's the actual integration problem.

---

## 2. What already unifies them (good news: your schema mostly does this already)

Looking at your current `schema.prisma`, both pillars already sit on the same four shared
primitives:

| Shared primitive | Used by Vault | Used by Feed |
|---|---|---|
| `User` + `UserRole` | uploader / approver | author / commenter |
| `Upload` (Cloudinary asset) | resource file | post cover image |
| `Comment` (polymorphic `postId` \| `resourceId`) | comments on resources | comments on posts |
| `Like` / `Bookmark` (same polymorphic pattern) | like/bookmark a resource | like/bookmark a post |

This is the right shape — one engagement layer (`Comment`/`Like`/`Bookmark`) serving both
content types. **Keep this.** It means your feed UI and your resource-detail UI can literally
reuse the same `<CommentThread>` / `<LikeButton>` components on the frontend, and the same
`comment.service.ts` / `like.service.ts` on the backend, parameterized by `{ postId | resourceId }`.

So the "single app" integration isn't really a data-modeling problem you're missing — it's three
concrete decisions still open:

1. How does a Resource represent "not uploaded here" (external link / local-only) — right now `Resource.uploadId` is mandatory.
2. How is **"who can post"** actually decided — role-based, or a separate grantable permission?
3. How does the product surface both pillars without them feeling like two different apps?

Each is addressed below as a decision, not a task list — pick the option, then it becomes a
normal item in `path.md`'s Phase 5 / Phase 6.

---

## 3. Decision 1 — Resource storage location (Vault content) — ✅ SCHEMA DONE

Right now every `Resource` requires an `Upload` (`uploadId String @unique`, not nullable). That
only covers "uploaded to our Cloudinary." Your idea includes two more cases: an external URL, and
a "metadata-only, lives on the student's machine" entry.

**Implemented in `prisma/schema.prisma`:** added a `sourceType` enum to `Resource` and made
`uploadId` optional.

```prisma
enum ResourceSourceType {
  HOSTED         // File uploaded to Campus Vault (Cloudinary) — needs `upload`
  EXTERNAL_LINK  // File lives elsewhere (Drive, another site) — needs `externalUrl`
  REFERENCE_ONLY // No file at all, only metadata (e.g. "I have this locally, ask me")
}
```

`Resource` now has:
- `sourceType ResourceSourceType @default(HOSTED)`
- `uploadId String? @unique` (was required, now optional)
- `upload Upload?` (relation made optional to match)
- `externalUrl String?` (new)
- `@@index([sourceType])` (new)

Rules (**not yet enforced by Prisma — this is a service-layer TODO, next step**):
- `HOSTED` → `uploadId` required, `externalUrl` must be null.
- `EXTERNAL_LINK` → `uploadId` null, `externalUrl` required — validate it's a well-formed URL,
  and add a lightweight reachability/HEAD check at creation time (not a full crawl). This also
  covers "student's local storage accessed through the PWA" — the PWA can read a File System
  Access handle or a local file, but what gets stored server-side is still just a reference/URL
  the client resolves, not raw bytes, so it reuses the same `EXTERNAL_LINK` shape.
- `REFERENCE_ONLY` → both null. Useful for "I have this on paper, ask me" or crowdsourcing demand
  before someone uploads the real file. Treat with lower trust in search ranking.

Prisma can't express this XOR at the schema level (see §8.1), so the create/update service for
`Resource` must validate exactly-the-right-fields-for-the-sourceType before writing, and the
approval workflow (`PENDING` → `APPROVED`/`REJECTED`) should apply uniformly across all three —
an external link still needs a moderator to confirm it's not spam/malware before it's trusted.

**Remaining work (Phase 5, not done yet):** the validation rules above, in
`resource.validation.ts` / `resource.service.ts`, once that module is built.

---

## 4. Decision 2 — "Who can post" (Feed permission model) — ✅ SCHEMA DONE

You described this as *"I will set permission for each people like who can post or not, but they
can like/comment."* That's not the same shape as your existing `UserRole` enum
(`STUDENT / FACULTY / UNIVERSITY_ADMIN / SUPER_ADMIN`), which is coarse and role-based. What you
want is a **grantable capability**, independent of role — e.g. a STUDENT could be trusted to post
(a senior, a placement-cell volunteer, a club rep) without being promoted to FACULTY/ADMIN.

**Implemented in `prisma/schema.prisma`:** added a boolean flag on `User`, deliberately kept
separate from `role`:

```prisma
canPost Boolean @default(false)
```

Admins (`UNIVERSITY_ADMIN`/`SUPER_ADMIN`) flip it per user. `POST /posts` will check
`req.user.canPost === true`. Defaults to `false` for everyone at signup — grant it individually or
in bulk (e.g. "everyone in student council") once the admin module exists.

**Remaining work (Phase 6, not done yet):**
- `requirePostPermission` middleware that reads `req.user.canPost`.
- An admin endpoint to grant/revoke it (`PATCH /admin/users/:id/can-post`).
- If you later need scoping ("can post only within their own college's feed") or an audit trail
  of who granted it and when, upgrade to a dedicated `PostingPermission` model — but don't build
  that until the plain boolean actually feels limiting (YAGNI).

Either way, the rule for engagement stays simple and separate: **any authenticated, active user
can comment/like/bookmark**, gated only by `authenticate` middleware, no extra permission check.
That asymmetry (narrow posting, open reacting) is the whole point of the Feed pillar — keep it
explicit in the `post.routes.ts` vs `comment.routes.ts` middleware stacks so it's obvious at a
glance:

```
POST /posts              → authenticate, requirePostPermission, validate, controller
POST /posts/:id/comments → authenticate, validate, controller   // no extra gate
POST /posts/:id/like     → authenticate, controller             // no extra gate
```

---

## 5. Decision 3 — How the app *feels* like one product, not two

This is UX/IA, not schema, but it's the actual "how do I manage these two things in a single
app" question underneath your message.

- **One home surface, two rails.** A single home screen with a "Vault" tab (search/filter-first,
  grid of resources) and a "Feed" tab (chronological, post-first). Don't merge them into one feed
  — a PYQ card and a social post have different scan patterns and different intents (retrieval vs.
  browsing). Trying to interleave them in one list usually makes both worse.
- **Cross-linking, not merging.** A post can reference a resource ("check the new DSA notes I
  uploaded" with a resource-card embed), and a resource-detail page can show "Discussion" (which
  is just the same `Comment` model scoped to that resource). This is where the shared engagement
  layer from §2 pays off — you get cross-pollination without merging the data models.
  If posts want to reference resources, that's one small optional relation
  (`Post.linkedResourceId?`) worth adding *after* both pillars work independently, not before.
- **One search bar, scoped results.** Users shouldn't have to know whether what they want is a
  "resource" or a "post" — a top-level search can return both, grouped by type, reusing the same
  search infra (§7 of `path.md`, generalized to two entities instead of one).
- **One notification/activity feed later**, once both pillars exist — "your resource was
  approved," "someone commented on your post" — but that's explicitly post-MVP; don't build it now.

---

## 6. Where this slots into your existing roadmap

Nothing here replaces `path.md` — it's precise about *what* to build. This doc governs a few
*shape* decisions inside phases 5 and 6:

```
PHASE 5 — RESOURCE SYSTEM (path.md)
  ✅ Add ResourceSourceType enum + optional uploadId + externalUrl   ← from §3, schema done
  ⬜ Service-layer validation: enforce right fields per sourceType (XOR, see §8.1)
  ⬜ Cloudinary
  ⬜ Resource CRUD (branches on sourceType)
  ⬜ Resource upload
  ⬜ Resource approval / rejection (applies uniformly across sourceType)
  ⬜ Search / Filtering / Pagination

PHASE 6 — SOCIAL (path.md)
  ✅ Add User.canPost boolean (default false)                        ← from §4, schema done
  ⬜ requirePostPermission middleware (checks canPost, not role)
  ⬜ Admin endpoint to grant/revoke canPost
  ⬜ Posts (gated by requirePostPermission)
  ⬜ Comments (open to any authenticated user, works on Post OR Resource)
  ⬜ Likes (same, open)
  ⬜ Bookmarks (same, open)

POST-MVP (only after both pillars work standalone)
  ⬜ Post.linkedResourceId — cross-linking a post to a resource
  ⬜ Unified search across Post + Resource
  ⬜ Activity/notification feed
```

---

## 7. Summary — the actual answer to "how do I manage both in one app"

- Keep them as two pillars with **different trust models** (Vault: many contributors + moderation;
  Feed: few posters + open reactions) — don't force one permission system onto both.
- They already share the right backbone (`User`, `Upload`, `Comment`, `Like`, `Bookmark`) — the
  work is three small, additive decisions, not a redesign:
  1. `Resource.sourceType` (HOSTED / EXTERNAL_LINK / REFERENCE_ONLY) + optional `uploadId`.
  2. `User.canPost` boolean, checked by its own middleware, decoupled from `UserRole`.
  3. Two clearly separated UI surfaces (Vault, Feed) that cross-link through the shared comment
     engine rather than merging into one list.
- Build order stays what `path.md` already says — just apply decisions (1) and (2) at the start
  of Phase 5 and Phase 6 respectively, before the CRUD endpoints are written, so you're not
  migrating a live schema later.

---

## 8. Additional risks worth flagging before you proceed

These weren't in scope of "how do the two pillars fit together" but surfaced from re-reading the
schema and roadmap critically. Grouped by how expensive they get if caught late — fix the first
group now (cheap, schema-level), the rest can wait but should be *decided*, not forgotten.

### 8.1 Fix now — cheap while the schema is still young

- **No college/university identity verification.** Anyone can self-register and claim any
  university/college — there's no email-domain check (`@college.edu`) or admin-approval-on-signup
  step. For a platform whose entire value proposition is "trusted, college-scoped content," this
  is the single biggest trust gap. You don't need to build full verification now, but decide the
  approach before launch: domain-matching at signup, or `isVerified` gated by an admin/OTP step,
  or just accept it's self-reported for v1 and say so in the UI. Silently leaving it unhandled is
  the risky option, not any specific choice.
- **`Comment`/`Like`/`Bookmark` have no XOR constraint** between `postId` and `resourceId` — both
  are nullable, so Prisma/Postgres won't stop a row with both null or both set. Add either a DB
  `CHECK` constraint or enforce it strictly in the service layer (reject if not exactly one is
  set) before any data exists that would need cleaning up later.
- **No `Report`/flagging model.** `path.md` §39 lists "Reports" under the admin module, but
  there's no schema for it. Right now the only way bad content gets caught is an admin manually
  browsing. Add a lightweight `Report { id, reporterId, postId?, resourceId?, reason, status }`
  early — it's the same polymorphic pattern you already use for Comment/Like, so it's cheap to add
  alongside them in Phase 6, not a separate effort.
- **Resource/Post have no direct `universityId`/`collegeId`.** They only reach it indirectly via
  `Resource → Subject → Course → University`. That's fine for display, but painful for two things
  you *will* need: (a) scoping "which admin can approve/moderate which content" to their own
  university/college, and (b) fast filtering ("show me only my college's resources") without a
  3-table join on every list query. Consider denormalizing `universityId` (and maybe `collegeId`)
  directly onto `Resource` and `Post` — set once at creation from the author's profile, indexed.

### 8.2 Decide the policy now, build later

- **Hard deletes everywhere** (`onDelete: Cascade` throughout). Once a resource or post is
  deleted, it's gone — no audit trail for "why was this removed," no recovery from an accidental
  or malicious delete-by-admin. Worth at least a `deletedAt` soft-delete on `Resource`/`Post`
  before real moderation starts, even if you don't build a recycle-bin UI for it yet.
- **No duplicate detection or versioning for resources.** Five students will upload the same PYQ.
  Nothing today merges them, ranks the "best" copy, or lets someone upload a corrected version of
  an existing entry — you just get five near-identical `PENDING` items in the moderation queue.
  Doesn't need solving for MVP, but the moderation UI should expect it (e.g. show "3 similar
  resources exist" at approval time) rather than being surprised by it later.
- **External links rot and aren't re-validated.** `EXTERNAL_LINK` resources (from §3) can go dead
  or, worse, get taken over and start pointing somewhere malicious after approval. A periodic
  link-check job (even a simple monthly HEAD-request sweep that flags dead links for re-review)
  should be on the post-MVP list, not forgotten entirely.
- **`Visibility.PREMIUM` exists with no monetization logic anywhere.** Either it's aspirational
  scope creep sitting in the schema for no current reason, or you have a real plan for it. If it's
  the former, consider dropping it until there's an actual paywall to attach it to — an unused enum
  value is harmless, but it does signal a decision you haven't actually made yet.
- **`canPost` has no rate limiting, spam protection, or grant/revoke audit trail.** A compromised
  or briefly-trusted-then-abusive account with `canPost=true` can spam the feed with no throttle.
  Not urgent for MVP (small user base), but note it as a pre-launch item, not a "later" item.
- **Naive search won't scale.** `path.md` §32 implies `ILIKE`-style substring search. Fine at low
  volume; once resource count grows past a few thousand rows, expect slow, low-relevance results.
  Postgres full-text search (`tsvector`) is a reasonable upgrade path and doesn't require a new
  service — flag it as a Phase 9 (Performance) item rather than discovering it as a production
  incident.

### 8.3 A product-level risk, not a schema one

- **Two products, one team.** Vault (utility, moderation-heavy) and Feed (social, engagement-heavy)
  pull development attention in different directions. If you're building this solo or with a small
  team, building both in parallel risks neither reaching a genuinely solid state. Consider
  explicitly sequencing: ship the Vault to a point where it's actually useful and trustworthy on
  its own first (Phases 1–5), *then* layer the Feed on top (Phase 6) — rather than half-building
  both simultaneously. `path.md`'s phase order already implies this; treat it as a real commitment,
  not just a checklist ordering.
