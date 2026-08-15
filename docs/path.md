# Campus Vault Backend — Complete Project Roadmap

> **Project:** Campus Vault
> **Backend:** Node.js + Express + TypeScript
> **Database:** PostgreSQL
> **ORM:** Prisma
> **Authentication:** JWT
> **Validation:** Zod
> **File Storage:** Cloudinary
> **Architecture:** Modular Backend

---

# 1. Project Goal

Campus Vault is a university-focused platform where students can:

* Find colleges, courses and subjects
* Upload academic resources
* Access PYQs, notes, assignments, books and other resources
* Search resources
* Bookmark resources
* Like/comment on posts
* Create posts
* Manage their profile
* Access resources according to visibility/status

Admins and university administrators can:

* Manage universities
* Manage colleges
* Manage courses
* Manage subjects
* Approve/reject resources
* Manage users
* Moderate platform content

---

# 2. Technology Stack

## Backend

* Node.js
* Express.js
* TypeScript

## Database

* PostgreSQL
* Prisma ORM

## Authentication

* JWT
* Access Token
* Refresh Token
* Password hashing

## Validation

* Zod

## File Storage

* Cloudinary

## Development

* npm
* TypeScript
* Prisma CLI
* Environment variables

---

# 3. Current Project Structure

```text
backend/
│
├── prisma/
│   └── schema.prisma
│
├── src/
│   │
│   ├── config/
│   │   ├── prisma.ts
│   │   └── jwt.ts
│   │
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   ├── notFound.middleware.ts
│   │   └── index.ts
│   │
│   ├── modules/
│   │
│   ├── routes/
│   │
│   ├── types/
│   │   └── express.d.ts
│   │
│   ├── utils/
│   │   ├── apiResponse.ts
│   │   ├── appError.ts
│   │   ├── asyncHandler.ts
│   │   └── index.ts
│   │
│   ├── app.ts
│   └── server.ts
│
├── .env
├── .env.example
├── prisma.config.ts
├── package.json
└── tsconfig.json
```

---

# 4. Database Setup — COMPLETED

## PostgreSQL

Database connection successfully configured.

Environment:

```env
DATABASE_URL=...
```

Prisma is connected and schema validation is working.

---

# 5. Prisma Setup — COMPLETED

Prisma configuration is working.

Commands successfully used:

```bash
npx prisma format
npx prisma validate
```

Schema:

```text
prisma/schema.prisma
```

Prisma version currently being used:

```text
Prisma CLI 6.19.3
```

---

# 6. Database Schema — COMPLETED

The database schema has been designed around the Campus Vault requirements.

Important entities include:

* User
* University
* College
* Course
* CollegeCourse
* Subject
* Resource
* Post
* Comment
* Like
* Bookmark

Enums include concepts such as:

```text
UserRole
ResourceType
ResourceStatus
UploadType
TargetType
SubjectType
Visibility
```

The schema has already been migrated and tables are visible in PostgreSQL.

---

# 7. Initial Database Seed — MOSTLY COMPLETED

Seed data has been prepared for the academic structure.

## University

University seed has been created.

Primary university currently being populated:

```text
University of Delhi
```

## Colleges

DU colleges have been prepared with information such as:

```text
name
gender
address
```

Examples:

```text
Ramanujan College
Hans Raj College
Hindu College
Miranda House
SRCC
Shaheed Sukhdev College of Business Studies
...
```

## Courses

Important DU courses have been added.

Examples include:

```text
B.Com
B.Com (Hons.)
B.Com Programme
B.Sc. (Hons.) Computer Science
B.Sc. (Hons.) Mathematics
B.Sc. (Hons.) Statistics
B.Voc. Software Development
B.Voc. Banking, Financial Services and Insurance
BMS
B.A. (Hons.) Political Science
B.A. (Hons.) English
B.A. (Hons.) Hindi
...
```

## Subjects

Large subject seed has been prepared.

It includes:

```text
DSC
DSE
GE
VAC
SEC
EVS
NCC
```

Multiple semesters and courses have been covered.

The subject seed has grown to approximately 2500+ lines.

## Remaining Seed Work

* [ ] Verify all foreign-key relationships
* [ ] Run complete seed
* [ ] Verify duplicate handling
* [ ] Verify subject → course mapping
* [ ] Verify college → university mapping
* [ ] Verify course → college mapping
* [ ] Verify all semester values
* [ ] Verify course codes
* [ ] Add missing data only if required

Recommended approach for large seed data:

```ts
prisma.model.createMany({
  data,
  skipDuplicates: true,
});
```

For very large datasets, use batches instead of firing thousands of individual queries simultaneously.

---

# 8. Global API Response — COMPLETED

Utility created:

```text
src/utils/apiResponse.ts
```

Purpose:

Keep API responses consistent.

Expected structure:

```json
{
  "success": true,
  "message": "Fetched successfully.",
  "data": {}
}
```

---

# 9. Global Error Class — COMPLETED

File:

```text
src/utils/appError.ts
```

Purpose:

Allow application errors to be thrown without manually handling them in every controller.

Example:

```ts
throw new AppError(
  "User not found",
  404
);
```

---

# 10. Async Handler — COMPLETED

File:

```text
src/utils/asyncHandler.ts
```

Purpose:

Remove repetitive controller-level:

```ts
try {

} catch {

}
```

Controllers can instead use:

```ts
asyncHandler(async (req, res) => {
  // business logic
});
```

Errors are forwarded to the global error middleware.

---

# 11. Global Error Middleware — COMPLETED

File:

```text
src/middleware/error.middleware.ts
```

It currently handles major categories such as:

* AppError
* Prisma errors
* Duplicate record
* Record not found
* Prisma validation errors
* JWT errors
* Unknown errors

Generic response:

```json
{
  "success": false,
  "message": "Internal server error."
}
```

---

# 12. Not Found Middleware — COMPLETED

File:

```text
src/middleware/notFound.middleware.ts
```

Purpose:

Handle routes that don't exist.

Example:

```text
GET /api/v1/random
```

Response:

```json
{
  "success": false,
  "message": "Cannot GET /api/v1/random"
}
```

---

# 13. Prisma Client Singleton — COMPLETED

File:

```text
src/config/prisma.ts
```

The application uses one Prisma client instance instead of creating:

```ts
new PrismaClient()
```

inside every service/repository.

Usage:

```ts
import prisma from "../config/prisma";
```

Then:

```ts
await prisma.user.findMany();
```

---

# 14. JWT Configuration — COMPLETED

File:

```text
src/config/jwt.ts
```

JWT functionality prepared for:

```text
generateAccessToken()
generateRefreshToken()
verifyAccessToken()
verifyRefreshToken()
```

Environment variables:

```env
JWT_ACCESS_SECRET=...
JWT_REFRESH_SECRET=...

JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

---

# 15. Authentication Middleware — COMPLETED

File:

```text
src/middleware/auth.middleware.ts
```

Current flow:

```text
Authorization Header
        ↓
Bearer Token
        ↓
Verify JWT
        ↓
Find User
        ↓
Check User
        ↓
Check Active Status
        ↓
req.user
        ↓
next()
```

Routes can use:

```ts
router.get(
  "/profile",
  authenticate,
  controller
);
```

---

# 16. Express Request User Type — COMPLETED

Because authentication attaches:

```ts
req.user
```

to Express Request, the Express type has been extended.

File:

```text
src/types/express.d.ts
```

This gives TypeScript awareness of:

```ts
req.user
```

---

# 17. Remaining Common Middleware

## Role Middleware

```text
src/middleware/role.middleware.ts
```

Purpose:

```text
authenticate
      ↓
authorize
      ↓
controller
```

Example:

```ts
authorize(
  "SUPER_ADMIN",
  "UNIVERSITY_ADMIN"
);
```

Status:

```text
TODO
```

---

# 18. Validation Middleware

Use:

```text
Zod
```

Create reusable:

```ts
validate(schema)
```

Example:

```ts
router.post(
  "/register",
  validate(registerSchema),
  register
);
```

This will be reused throughout the project.

Status:

```text
TODO
```

---

# 19. Authentication Module — NEXT MAJOR TASK

Create:

```text
src/modules/auth/
│
├── auth.controller.ts
├── auth.service.ts
├── auth.repository.ts
├── auth.routes.ts
├── auth.validation.ts
├── auth.types.ts
└── index.ts
```

---

# 20. Auth API

## Register

```text
POST /auth/register
```

Flow:

```text
Request
 ↓
Validation
 ↓
Controller
 ↓
Service
 ↓
Check existing user
 ↓
Hash password
 ↓
Create user
 ↓
Generate tokens
 ↓
Response
```

---

## Login

```text
POST /auth/login
```

Flow:

```text
Request
 ↓
Validation
 ↓
Find user
 ↓
Compare password
 ↓
Generate access token
 ↓
Generate refresh token
 ↓
Response
```

---

## Refresh Token

```text
POST /auth/refresh
```

Purpose:

Generate a new access token without requiring the user to log in again.

---

## Logout

```text
POST /auth/logout
```

Purpose:

Invalidate/remove refresh token.

---

## Current User

```text
GET /auth/me
```

Protected by:

```ts
authenticate
```

---

# 21. Password Security

Use:

```text
bcrypt
```

Register:

```text
plain password
      ↓
bcrypt hash
      ↓
database
```

Login:

```text
password
      ↓
bcrypt.compare()
      ↓
valid / invalid
```

Never store plain passwords.

---

# 22. Refresh Token Strategy

Recommended:

```text
Access Token
15 minutes

Refresh Token
7 days
```

Refresh token should preferably be stored securely and revocable.

Future requirements:

* [ ] Store refresh token hash
* [ ] Refresh token rotation
* [ ] Logout
* [ ] Logout from all devices
* [ ] Token revocation

---

# 23. User Module

After Auth:

```text
modules/user/
```

Features:

```text
GET /users/me
PATCH /users/me
GET /users/:id
```

Possible future features:

* Profile picture
* Bio
* Course information
* College information
* University information
* Account settings

---

# 24. University Module

Admin functionality:

```text
POST   /universities
GET    /universities
GET    /universities/:id
PATCH  /universities/:id
DELETE /universities/:id
```

Public functionality:

```text
GET /universities
```

---

# 25. College Module

```text
POST   /colleges
GET    /colleges
GET    /colleges/:id
PATCH  /colleges/:id
DELETE /colleges/:id
```

Filters:

```text
university
gender
location
```

---

# 26. Course Module

```text
POST   /courses
GET    /courses
GET    /courses/:id
PATCH  /courses/:id
DELETE /courses/:id
```

Possible filters:

```text
university
college
course type
duration
```

---

# 27. Subject Module

```text
POST   /subjects
GET    /subjects
GET    /subjects/:id
PATCH  /subjects/:id
DELETE /subjects/:id
```

Filters:

```text
course
semester
subject type
paper code
```

Important types:

```text
DSC
DSE
GE
SEC
VAC
AEC
```

---

# 28. Resource Module — CORE FEATURE

This is the heart of Campus Vault.

Resource types:

```text
PYQ
NOTES
SYLLABUS
BOOK
ASSIGNMENT
OTHER
```

Statuses:

```text
PENDING
APPROVED
REJECTED
```

Visibility:

```text
PUBLIC
PREMIUM
```

---

# 29. Resource APIs

```text
POST   /resources
GET    /resources
GET    /resources/:id
PATCH  /resources/:id
DELETE /resources/:id
```

Additional:

```text
POST /resources/:id/approve
POST /resources/:id/reject
```

---

# 30. Resource Upload Flow

```text
Student
   ↓
Upload PDF
   ↓
Cloudinary
   ↓
Get URL + public ID
   ↓
Create Resource
   ↓
PENDING
   ↓
Admin Review
   ↓
APPROVED / REJECTED
```

---

# 31. Cloudinary Module

Create:

```text
src/config/cloudinary.ts
```

Environment:

```env
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=
```

Features:

```text
uploadFile()
deleteFile()
```

---

# 32. Search

Global resource search:

```text
GET /resources?search=dsa
```

Search by:

```text
title
description
subject
course
college
```

---

# 33. Filtering

Resources should support:

```text
course
college
subject
semester
resource type
status
visibility
```

Example:

```text
GET /resources
    ?course=
    &subject=
    &semester=3
    &type=PYQ
```

---

# 34. Pagination

Every large listing should eventually support:

```text
page
limit
```

Response:

```json
{
  "success": true,
  "data": [],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

# 35. Post Module

Students can create posts.

```text
POST   /posts
GET    /posts
GET    /posts/:id
PATCH  /posts/:id
DELETE /posts/:id
```

---

# 36. Comment Module

```text
POST   /posts/:id/comments
GET    /posts/:id/comments
DELETE /comments/:id
```

---

# 37. Like Module

```text
POST   /posts/:id/like
DELETE /posts/:id/like
```

Also potentially:

```text
POST /resources/:id/like
```

depending on final product requirements.

---

# 38. Bookmark Module

```text
POST   /resources/:id/bookmark
DELETE /resources/:id/bookmark
GET    /users/me/bookmarks
```

---

# 39. Admin Module

Admin dashboard functionality:

```text
Users
Resources
Universities
Colleges
Courses
Subjects
Posts
Reports
```

Admin operations:

```text
Approve
Reject
Delete
Suspend
Restore
```

---

# 40. Role-Based Access Control

Roles already exist in the database design.

Expected hierarchy:

```text
SUPER_ADMIN
      ↓
UNIVERSITY_ADMIN
      ↓
FACULTY
      ↓
STUDENT
```

Access rules will be implemented through:

```text
authenticate()
authorize()
```

Example:

```ts
router.post(
  "/resources/:id/approve",
  authenticate,
  authorize("SUPER_ADMIN", "UNIVERSITY_ADMIN"),
  approveResource
);
```

---

# 41. API Versioning

Recommended route structure:

```text
/api/v1/auth
/api/v1/users
/api/v1/universities
/api/v1/colleges
/api/v1/courses
/api/v1/subjects
/api/v1/resources
/api/v1/posts
```

---

# 42. Route Architecture

Main router:

```text
src/routes/
```

Example:

```text
routes/
├── index.ts
├── auth.routes.ts
├── user.routes.ts
├── university.routes.ts
├── college.routes.ts
├── course.routes.ts
├── subject.routes.ts
├── resource.routes.ts
└── post.routes.ts
```

Or routes can be kept inside each module and centrally mounted.

Recommended for this project:

```text
modules/
└── auth/
    └── auth.routes.ts
```

Then central router imports module routes.

---

# 43. Module Architecture

Each major module should follow:

```text
module/
│
├── controller
├── service
├── repository
├── routes
├── validation
└── types
```

Responsibilities:

## Controller

Request/response only.

## Service

Business logic.

## Repository

Database queries.

## Validation

Input validation.

## Routes

Endpoint + middleware composition.

---

# 44. Testing

After major modules:

```text
Unit Tests
Integration Tests
API Tests
```

Tools can include:

```text
Vitest / Jest
Supertest
```

Test:

```text
Register
Login
Invalid login
Unauthorized request
Forbidden request
Resource creation
Resource approval
Resource upload
Search
Pagination
```

---

# 45. API Documentation

Add:

```text
Swagger / OpenAPI
```

Document:

```text
Auth
Users
Resources
Courses
Subjects
Posts
Admin
```

---

# 46. Security

Before deployment:

* [ ] Helmet
* [ ] CORS configuration
* [ ] Rate limiting
* [ ] Secure JWT secrets
* [ ] Password hashing
* [ ] Input validation
* [ ] File type validation
* [ ] File size limits
* [ ] SQL injection protection through Prisma
* [ ] Sensitive error hiding
* [ ] Environment variable validation
* [ ] Secure refresh token handling

---

# 47. Logging

Later add a proper logger.

Possible:

```text
Pino
Winston
```

Logs:

```text
Request
Error
Database
Authentication
Important events
```

Do not expose sensitive information in logs.

---

# 48. Performance

After functionality is complete:

* [ ] Database indexes
* [ ] Pagination
* [ ] Select only required Prisma fields
* [ ] Avoid N+1 queries
* [ ] Redis caching where useful
* [ ] Query optimization
* [ ] Cloudinary optimization
* [ ] Rate limiting

---

# 49. Redis — FUTURE

Redis can be introduced for:

```text
Caching
Rate limiting
Sessions / token management
Frequently accessed resources
Trending posts
```

Do not introduce Redis before the core application is stable.

---

# 50. Deployment

Backend deployment:

```text
Node.js
PostgreSQL
Cloudinary
Environment Variables
```

Deployment checklist:

* [ ] Production build
* [ ] Production environment variables
* [ ] Database migration
* [ ] Seed production-safe data
* [ ] CORS production domain
* [ ] Cloudinary configuration
* [ ] Logging
* [ ] Health check
* [ ] Error monitoring

---

# 51. Health Check

Add:

```text
GET /health
```

Response:

```json
{
  "success": true,
  "message": "Server is healthy."
}
```

Later check:

```text
API
Database
Redis
Cloudinary
```

---

# 52. CI/CD

Later implement:

```text
GitHub
   ↓
Push
   ↓
CI
   ↓
Lint
   ↓
Type Check
   ↓
Tests
   ↓
Build
   ↓
Deploy
```

---

# 53. Final Development Order

This is the order to follow.

```text
PHASE 1 — FOUNDATION
────────────────────────
✅ Project setup
✅ TypeScript
✅ Express
✅ PostgreSQL
✅ Prisma
✅ Prisma schema
✅ Database migration
✅ Seed structure

PHASE 2 — COMMON INFRASTRUCTURE
────────────────────────
✅ ApiResponse
✅ AppError
✅ asyncHandler
✅ Global Error Handler
✅ Not Found Handler
✅ Prisma Singleton
✅ JWT Utility
✅ Auth Middleware

⬜ Validation Middleware
⬜ Role Middleware

PHASE 3 — AUTH
────────────────────────
⬜ Register
⬜ Login
⬜ Refresh Token
⬜ Logout
⬜ Get Current User
⬜ Password hashing
⬜ Refresh token management

PHASE 4 — ACADEMIC STRUCTURE
────────────────────────
⬜ University API
⬜ College API
⬜ Course API
⬜ Subject API
⬜ Relationship APIs

PHASE 5 — RESOURCE SYSTEM
────────────────────────
⬜ Cloudinary
⬜ Resource CRUD
⬜ Resource upload
⬜ Resource approval
⬜ Resource rejection
⬜ Search
⬜ Filtering
⬜ Pagination

PHASE 6 — SOCIAL
────────────────────────
⬜ Posts
⬜ Comments
⬜ Likes
⬜ Bookmarks

PHASE 7 — ADMIN
────────────────────────
⬜ Admin APIs
⬜ User management
⬜ Resource moderation
⬜ Academic data management
⬜ Reports

PHASE 8 — QUALITY
────────────────────────
⬜ Swagger
⬜ Tests
⬜ Logging
⬜ Security
⬜ Error monitoring

PHASE 9 — PERFORMANCE
────────────────────────
⬜ Indexing
⬜ Query optimization
⬜ Redis
⬜ Caching
⬜ Rate limiting

PHASE 10 — DEPLOYMENT
────────────────────────
⬜ Production config
⬜ CI/CD
⬜ Backend deployment
⬜ Database deployment
⬜ Cloudinary production
⬜ Monitoring
```

---

# 54. Immediate Next Steps

Do NOT jump to Resource yet.

Current immediate sequence:

```text
1. ⬜ Validation Middleware

2. ⬜ Role Middleware

3. ⬜ Auth Module
      ├── validation
      ├── repository
      ├── service
      ├── controller
      └── routes

4. ⬜ Test Auth completely

5. ⬜ User Module

6. ⬜ University Module

7. ⬜ College Module

8. ⬜ Course Module

9. ⬜ Subject Module

10. ⬜ Resource Module
```

---

# 55. Definition of Done

The backend will be considered MVP-complete when:

* [ ] User can register
* [ ] User can login
* [ ] JWT authentication works
* [ ] Roles work
* [ ] User can access profile
* [ ] Academic hierarchy works
* [ ] Student can upload resources
* [ ] Admin can approve/reject resources
* [ ] Students can search resources
* [ ] Students can filter resources
* [ ] Pagination works
* [ ] Students can create posts
* [ ] Comments work
* [ ] Likes work
* [ ] Bookmarks work
* [ ] Global error handling works
* [ ] Validation works
* [ ] API documentation exists
* [ ] Tests exist for critical flows
* [ ] Production deployment works

---

# 56. Final Architecture

```text
                    CLIENT
                      │
                      ▼
                Express Router
                      │
                      ▼
                 Middleware
          ┌───────────┼────────────┐
          │           │            │
     Validation   Authentication   Role
          │           │            │
          └───────────┼────────────┘
                      ▼
                  Controller
                      │
                      ▼
                    Service
                      │
                      ▼
                  Repository
                      │
                      ▼
                    Prisma
                      │
                      ▼
                  PostgreSQL


Additional Services:

        ┌──────────────┐
        │  Cloudinary  │
        └──────────────┘

        ┌──────────────┐
        │    Redis     │
        │   Future     │
        └──────────────┘
```

---

# Current Status

## Completed

```text
████████████████░░░░░░░░░░░░░░░░░░

Foundation              ✅
Database                ✅
Prisma                  ✅
Schema                  ✅
Seed                    🟡
Common Utilities        ✅
Error Handling          ✅
JWT                     ✅
Authentication          🟡
Business Modules        ⬜
Testing                 ⬜
Deployment              ⬜
```

## Current Focus

> **Finish Authentication → then build the academic/resource system.**

The next coding task should be:

```text
Validation Middleware
        ↓
Role Middleware
        ↓
Auth Module
        ↓
Test Auth
        ↓
User Module
```

Do not build Redis, caching, advanced optimization, or deployment prematurely. First make the complete MVP work end-to-end.
