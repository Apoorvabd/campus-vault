# Remaining work and intentionally stale features

Updated: 2026-10-06

This file lists what is **not** wired to the backend yet. These items were left
as they are on purpose (static or mock) because the owner has a separate plan
for them, or because the backend has no API for them.

## 0. Biggest open issue

**About 65% of resources (11,902 of 18,194) link to a dead DU Question Paper
Bank URL.** Full analysis, numbers, options and the plan are in
[`issue-dead-du-portal-links.md`](issue-dead-du-portal-links.md).

## 1. Screens kept as static / mock data (no backend)

| Screen / element | File | Status |
|---|---|---|
| My Resource Requests (list, "New request" sheet, "2 Pending" badge on Profile) | `features/profile/presentation/my_requests_screen.dart`, badge in `profile_screen.dart` | Mock. Needs a Requests API (create, list, status, fulfilled-by). |
| Contributor Badges / XP / level | `features/profile/presentation/contributor_badges_screen.dart` | Mock. Needs a gamification API, or derive badges from `profile.stats`. |
| Storage & Cache (sizes, switches) and the "142 MB" label on Profile | `features/profile/presentation/storage_cache_screen.dart`, `profile_screen.dart` | Mock. Needs on-device file storage first (path_provider). |
| Honor Code "I agree" toggle | `features/profile/presentation/honor_code_screen.dart` | Local only, not saved. Optional `POST /profile/me/honor-code`. |
| Help Center (Contact Support, Report an Issue) | `features/support/presentation/help_center_screen.dart` | No-op buttons. Use `url_launcher` mailto: or a support-ticket API. |
| Privacy & Terms | `features/support/presentation/privacy_terms_screen.dart` | Static text (fine). |
| Notification bell in the top bar | `core/widgets/home_top_bar.dart` | No-op. No notifications model or API in the backend. |
| Exam Mode tab in the bottom bar | `app_navigation.dart` | Not built. |
| "Forgot password?", "Google Workspace SSO" on Login | `features/Auth/presentation/loginscreen.dart` | No-op. No reset-password or OAuth endpoints. |
| Profile footer version line ("v2.4.1 (Build ...)") | `profile_screen.dart` | Hard-coded. Use `package_info_plus` later. |

## 2. Decisions made for this release

- **Saved** = server bookmarks (posts and resources). PDFs open online through
  their URL. No on-device downloads or offline mode ("Downloaded" and
  "Locally saved" tabs were removed).
- **Resource ratings** (the star values) were removed everywhere: no API exists.
- **"Resource Requests" filter chip** on the Community tab was replaced by
  "My Posts".
- **Uploads** go to the server as PENDING and appear in lists only after an
  admin approves them. Allowed files: PDF, JPG, PNG up to 15 MB.
- **Posting** is open to every student (`canPost: true` is set on register).

## 3. Backend changes made in this round

- `canPost: true` for new users (register).
- New `optionalAuthenticate` middleware: `GET /posts`, `GET /posts/:id/comments`,
  `GET /resources`, `GET /resources/:id` accept an optional token and return
  `isLiked` / `isBookmarked` when it is sent.
- New **Bookmarks API** (`/api/v1/bookmarks`): `GET /posts`, `GET /resources`,
  `POST|DELETE /posts/:postId`, `POST|DELETE /resources/:resourceId`.
- **Resources**:
  - Public list is APPROVED only. PENDING/REJECTED are visible only to the
    uploader and to admins. (Fixes the data leak.)
  - New filters: `courseId`, `semester`, `mine=true`, `sort=downloads`;
    `limit` is capped at 50; query is validated.
  - List and detail include `subject`, `uploadedBy`, `upload`, `isBookmarked`.
  - `POST /resources/:id/download` increments `downloadCount`.
  - Creating a resource with an unknown `subjectId` now returns a clear 404.

## 4. Backend items still open

- **Existing users** still have `canPost = false`. Run once against the
  database: `UPDATE "User" SET "canPost" = true;` (the `.env` database is
  hosted, so check first that it is safe to run there).
- `/api/v1/test/upload` is still mounted in production routing; remove it.
- Login does not check `isActive` (deactivated users can log in; the first
  protected request then returns 403).
- `GET /subjects` returns inactive subjects and has no ordering.
- Courses are not filterable by college (the `CollegeCourse` table has no
  endpoint).
- Registration does not verify that the college and course belong to the chosen
  university, and the Prisma foreign-key error (P2003) falls through to a
  generic 500.
- `lastName` minimum of 3 characters rejects short surnames.
- Admin approval has no UI and is not scoped per university
  (see `docs/api-gap-analysis.md`).
- No comment likes, post edit UI, or resource comment endpoints.
- Refresh tokens are stateless (no revocation); `/auth/logout` is a no-op.
- Inconsistent naming: `_count.likes` on posts vs `likesCount` in the like
  response (the app handles both).

## 5. App items still open

- Folder `features/Auth` is capitalised; Dart convention is lowercase.
- App name strings: `pubspec.yaml` name/description and `web/index.html` still
  say "mobile" / "A new Flutter project".
- Tabs are rebuilt on every switch (`pushReplacement`); state is not kept.
  Switching to an `IndexedStack` shell would keep scroll positions.
- `features/subject/data/subject_data.dart` (mock catalog) is no longer used by
  any screen and can be deleted.
- No automated tests beyond the default `widget_test.dart`.
- iOS: confirm the App Transport Security setting before testing a real iPhone
  against a local `http://` backend.
