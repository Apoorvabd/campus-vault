# Admin API gap analysis

Updated: 2026-10-04

This inventory compares the current backend routes and Prisma schema with the
admin operations the app may need. It is a menu for deciding scope, not a
commitment to implement every route.

## Admin access rules to decide

- `SUPER_ADMIN` should be able to manage all universities and users.
- `UNIVERSITY_ADMIN` should normally be limited to users and content within
  their own university. Every list, detail, and mutation must enforce that
  scope in the service/repository; checking only the role is not sufficient.
- Only `SUPER_ADMIN` should be able to grant/revoke admin roles or create other
  `SUPER_ADMIN` accounts.
- Prefer deactivation/hiding over permanent deletion for accounts and content.
- Use cursor pagination for potentially large admin lists.

The existing `authorize(...roles)` middleware only checks role membership. It
does not implement university-level scope.

## Already implemented: do not duplicate in an admin router

### Authentication and user profile

- `POST /auth/register`, `/auth/login`, `/auth/refresh-token`,
  `/auth/logout`, `GET /auth/me`
- `GET /profile/me`, `PATCH /profile/me`
- `PUT /profile/me/avatar`, `DELETE /profile/me/avatar`
- `GET /profile/:username`

The profile API lets a user edit their own profile, not another user's profile
or admin-controlled fields such as `role`, `canPost`, `isVerified`, and
`isActive`.

### Posts

- `GET /posts`, `GET /posts/:id`
- `POST /posts`, `PATCH /posts/:id`, `DELETE /posts/:id`
- Comment list/create/update/delete under `/posts/:id/comments`
- Like/unlike under `/posts/:id/like`

These routes cover user post and comment operations. There is no admin post or
comment moderation route yet.

### Resource moderation

- `PATCH /resources/:id/approve`
- `PATCH /resources/:id/reject`

These already require `SUPER_ADMIN` or `UNIVERSITY_ADMIN`. University scope is
not currently enforced. `GET /resources` exists, but its listing is not a
dedicated, safely scoped moderation queue.

**Existing access-control gap to address:** `GET /resources` is public and
currently honors an explicit `?status=PENDING` or `?status=REJECTED` filter.
That means non-approved resources may be retrievable by unauthenticated
clients. Before or alongside admin work, restrict public listing to approved
resources and expose non-approved statuses only through an authenticated,
scoped moderation route.

### Read-only academic catalog

- `GET /universities`
- `GET /colleges?universityId=...`
- `GET /courses?universityId=...`
- `GET /subjects?courseId=...`

These are public reads only; admin create/update/archive operations are absent.

## Candidate admin routes

Suggested prefix: `/admin`. These are proposed routes; choose the groups and
individual operations needed before implementation.

### 1. Dashboard and overview

| Method | Candidate route | Purpose |
|---|---|---|
| `GET` | `/admin/dashboard` | Summary counts: users, active users, pending resources, published posts, and recent activity |
| `GET` | `/admin/analytics/users` | User growth and active-user counts over a date range |
| `GET` | `/admin/analytics/resources` | Resource submissions, approvals, rejections, and downloads |
| `GET` | `/admin/analytics/posts` | Post/comment/like counts over a date range |

Dashboard aggregates can be built from current tables. Historical trends and
an activity feed need event/audit data; the current schema does not retain
those histories.

### 2. User administration

| Method | Candidate route | Purpose |
|---|---|---|
| `GET` | `/admin/users` | Cursor-paginated search/filter by name, email, username, role, university, active/verified state, and `canPost` |
| `GET` | `/admin/users/:userId` | Inspect profile and content summary |
| `PATCH` | `/admin/users/:userId/status` | Activate/deactivate an account (`isActive`) |
| `PATCH` | `/admin/users/:userId/verification` | Verify/unverify an account (`isVerified`) |
| `PATCH` | `/admin/users/:userId/posting-permission` | Grant/revoke `canPost` |
| `PATCH` | `/admin/users/:userId/role` | Change role; restrict to `SUPER_ADMIN` |

The schema has fields for all these changes. A permanent
`DELETE /admin/users/:userId` is possible but not recommended: user-owned
content and retention requirements need a deliberate deletion policy first.
There is no password-reset/admin impersonation route proposed here.

### 3. Resource moderation and management

| Method | Candidate route | Purpose |
|---|---|---|
| `GET` | `/admin/resources` | Cursor-paginated moderation queue; filter by status, university, subject, type, uploader, and search |
| `GET` | `/admin/resources/:resourceId` | Inspect resource, upload, subject, and uploader |
| `PATCH` | `/resources/:id/approve` | Already implemented; add university-scope enforcement |
| `PATCH` | `/resources/:id/reject` | Already implemented; add university-scope enforcement |
| `PATCH` | `/admin/resources/:resourceId/status` | Optional restore/reopen action, if moderation needs it |
| `DELETE` | `/admin/resources/:resourceId` | Optional removal of harmful/duplicate content; prefer soft-delete if auditability is required |

The existing resource list accepts status filters, but should not be treated as
the admin queue until public visibility, authentication, and university scope
are explicitly enforced.

### 4. Post and comment moderation

| Method | Candidate route | Purpose |
|---|---|---|
| `GET` | `/admin/posts` | Search/filter posts, including hidden posts and author/course |
| `PATCH` | `/admin/posts/:postId/visibility` | Hide/restore a post using existing `isPublished` |
| `DELETE` | `/admin/posts/:postId` | Optional moderator removal |
| `GET` | `/admin/comments` | Search/filter comments by post, author, and date |
| `DELETE` | `/admin/comments/:commentId` | Remove a comment that violates policy |

`Post.isPublished` can represent hidden versus visible for now, but there is no
moderation reason, moderator ID, or moderation timestamp. Add those fields if
moderation history is required. Comments have no soft-delete or moderation
fields.

### 5. Academic catalog management

The catalog is currently read-only. Candidate admin operations:

| Method | Candidate route | Purpose |
|---|---|---|
| `POST`, `PATCH`, `DELETE` | `/admin/universities[/:universityId]` | Create/update/archive university data and logo |
| `POST`, `PATCH`, `DELETE` | `/admin/colleges[/:collegeId]` | Manage colleges within a university |
| `POST`, `PATCH`, `DELETE` | `/admin/courses[/:courseId]` | Manage courses within a university |
| `POST`, `PATCH`, `DELETE` | `/admin/colleges/:collegeId/courses/:courseId` | Link/unlink a course and college |
| `POST`, `PATCH`, `DELETE` | `/admin/subjects[/:subjectId]` | Manage subjects, semester, type, credits, and active state |

Prefer archive/deactivate rather than hard-delete when users or resources
reference a catalog entry. The current schema has `Subject.isActive`, but no
equivalent active/archive flag for universities, colleges, or courses.

### 6. Reports and user-submitted flags — requires schema/API additions

There is no report/flag model today. If users should report posts, comments,
resources, or accounts, first add a `Report` model with reporter, target,
reason, status, timestamps, and moderation outcome. Then consider:

| Method | Candidate route | Purpose |
|---|---|---|
| `POST` | `/reports` | Submit a report (authenticated user) |
| `GET` | `/admin/reports` | Cursor-paginated moderation queue |
| `GET` | `/admin/reports/:reportId` | Inspect report and target |
| `PATCH` | `/admin/reports/:reportId` | Resolve/dismiss report and record outcome |

### 7. Audit log and admin activity — requires schema additions

There is no audit-log table. If it is important to know who changed a user's
role, approved a resource, hid a post, or when it happened, add an audit/event
model before relying on admin actions. Candidate read endpoint:

| Method | Candidate route | Purpose |
|---|---|---|
| `GET` | `/admin/audit-logs` | Cursor-paginated, filterable admin action history |

Do not infer historical actions from current state: current records only show
the latest state.

### 8. Bookmarks, likes, and content history

No dedicated admin CRUD routes are currently necessary for likes/bookmarks.
They can be included in user/content detail views or analytics. Unlike removes
the current `Like` row, so the schema cannot answer who unliked something or
when. Add a like-event table only if that history is a product requirement.

### 9. Upload and storage operations — optional

`Upload` rows are created for uploaded files, but there is no admin upload
browser, orphan cleanup, or storage usage endpoint. Possible additions after
defining deletion/reference safety:

- `GET /admin/uploads` — search/filter uploads and owners.
- `GET /admin/storage/summary` — aggregate storage usage.
- `DELETE /admin/uploads/:uploadId` — only when no profile, resource, post, or
  user-file record references it; Cloudinary deletion must also be handled.

## Suggested minimum first release

1. `GET /admin/dashboard`
2. User list/detail and controls for `isActive`, `isVerified`, and `canPost`
3. A scoped resource moderation queue, while retaining the existing
   approve/reject endpoints
4. Post visibility moderation
5. Catalog CRUD only if an admin needs to maintain universities, colleges,
   courses, or subjects from the app

Add reports and audit logs before promising report triage or a complete
historical record of admin actions.
