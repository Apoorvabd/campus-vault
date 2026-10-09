# Pre-deploy checks (test release ke liye)

Test APK + Render backend deploy se pehle ye sab dekhna hai. Ye abhi test release
ke liye hai; final release ke liye jo alag se karna hai wo "Final release se pehle"
section mein hai.

`[x]` = ho chuka hai, `[ ]` = karna baaki hai.

---

## 0. Ab tak ka status

- [x] Release APK compile hoti hai (dummy URL ke saath build check ki, koi error nahi, sirf 3 purani Java `source/target 8` warnings).
  - Ye sirf "build nahi toota" ka saboot hai. APK phone par chalakar nahi dekhi (R8/shrink ki runtime dikkat neeche section 5 mein dekhni hai).
- [x] Backend ka health route: `GET /api/v1/health` ([routes/index.ts](../backend/src/routes/index.ts)), bina auth aur bina database ke.
- [x] App landing screen par server ko jagane ka ping bhejti hai (`apiClient.wakeServer()`, [api_client.dart](../mobile/lib/core/network/api_client.dart), [main.dart](../mobile/lib/main.dart)).
- [x] Normal request ka receive timeout 15s se 45s (Render cold start ke liye).
- [x] Dev ke liye `mobile/scripts/dev.sh` (adb reverse + `flutter run`). Release APK mein iski zaroorat nahi.

---

## 1. Backend deploy (Render)

- [ ] Render par service banao.
  - Build command: `npm install && npx prisma generate && npm run build`
  - Start command: `npm start`
  - `typescript` devDependency mein hai, to build ke waqt dev dependencies install honi chahiye (`NODE_ENV=production` install ke baad set karo, pehle nahi).
  - `prisma` aur `dotenv` already dependencies mein hain.
- [ ] Environment variables daalo (`backend/src/.env.example` dekho):
  - [ ] `DATABASE_URL`
  - [ ] `JWT_ACCESS_SECRET` (dev wale se alag aur lamba)
  - [ ] `JWT_REFRESH_SECRET` (dev wale se alag aur lamba)
  - [ ] `JWT_ACCESS_EXPIRES_IN` (jaise `15m`)
  - [ ] `JWT_REFRESH_EXPIRES_IN` (jaise `7d`)
  - [ ] `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY`, `CLOUDINARY_API_SECRET`
  - [ ] `CLIENT_URL`
  - [ ] `NODE_ENV=production`
  - `PORT` Render khud deta hai, code `PORT` padhta hai.
  - `DU_EMAIL`, `DU_PASSWORD`, `QB_*` sirf `scripts/scrape-pyq.ts` ke liye hain, app ko nahi chahiye.
- [ ] Deploy ke baad migrations chalao: `npx prisma migrate deploy`
  - Naye subjects-form wale columns (`selectedSubjectIds`, `subjectsSemester`, `subjectsConfirmedAt`) wahan bhi lagne chahiye. Migration: `backend/prisma/migrations/20261008120000_add_user_selected_subjects`.
- [ ] Health check path `/api/v1/health` set karo.
- [ ] Deploy ke baad browser ya curl se `https://<naam>.onrender.com/api/v1/health` kholke check karo (`{"success":true,"status":"ok"}`).
- [ ] Render ka free plan ~15 min idle ke baad so jaata hai. Pehli request 30 se 60 second le sakti hai. Chaho to uptime monitor (jaise UptimeRobot) se har 10 se 14 minute mein `/api/v1/health` ping karwao.

## 2. Backend code mein release se pehle

- [ ] `/test` route production mein khula hai ([routes/index.ts](../backend/src/routes/index.ts), `router.use("/test", testRoutes)`). Ise hatao ya sirf non-production par chalao.
- [ ] Database kaunsa use hoga tay karo. Abhi `DATABASE_URL` wahi Supabase hai jo local dev mein chalta hai, to testers ka data bhi usi mein jayega. Alag production DB chahiye to naya banake migrations aur seed chalani padegi.
- [ ] Seed data check karo: universities, colleges, courses, subjects database mein hone chahiye.
- [ ] Users ka `canPost` default `false` hai. Testers ko Create Post chalane ke liye `canPost = true` karna padega (Prisma Studio ya SQL).
- [ ] Resources `PENDING` bante hain aur sirf `APPROVED` dikhte hain. App mein approve karne ka admin screen nahi hai. Ek admin user banao aur resources ko API ya SQL se approve karo.
- [ ] Ek SUPER_ADMIN ya admin user bana ke rakho.
- [ ] Final ke liye (abhi zaroori nahi): rate limiting, `app.set("trust proxy", ...)`, helmet.

## 3. Mobile app (release build ke liye zaroori)

- [ ] **API URL:** app ka default `http://localhost:5000/api/v1` hai ([api_config.dart](../mobile/lib/core/network/api_config.dart)). Release APK mein ye phone par kahin nahi pahunchega. Build mein URL dena zaroori hai:

  ```bash
  cd mobile && flutter build apk --release --dart-define=API_BASE_URL=https://<naam>.onrender.com/api/v1
  ```

  - Ya Render ka URL milne ke baad `api_config.dart` ka default hi usi par kar do, taaki bhoolne par app na toote.
- [ ] **HTTPS hi chalega:** release manifest mein `usesCleartextTraffic` nahi hai (sirf debug manifest mein hai). Render ka URL https hai, to theek. Release APK ko local `http://192.168...` backend se test nahi kar paoge.
- [ ] **Version badhao:** `mobile/pubspec.yaml` mein `version: 1.0.0+1`. Har naye test APK par build number badhao (`+2`, `+3`...), warna testers ke phone par update install nahi hoga.
- [ ] **Signing:** abhi release APK debug key se sign hoti hai ([build.gradle.kts](../mobile/android/app/build.gradle.kts)). Sideload test ke liye chalega. Play Store ke liye apni keystore chahiye.
- [ ] **Application ID:** `com.example.mobile` hai. Test ke liye theek, par Play Store se pehle badalna padega (baad mein badal nahi sakte).
- [x] INTERNET permission main manifest mein hai. App name "Semester Forge", icons aur assets (Lottie, images) theek hain.

## 4. Release APK mein jo confusing ya adhura dikhta hai

- [ ] **Fake data hide karo ya "Coming soon" likho:**
  - Profile mein "My Resource Requests" par hardcoded "2 Pending" badge ([profile_screen.dart:125](../mobile/lib/features/profile/presentation/profile_screen.dart)) aur uske andar mock requests ki list ([my_requests_screen.dart](../mobile/lib/features/profile/presentation/my_requests_screen.dart)).
  - "Storage & Cache" par fake "142 MB" ([profile_screen.dart:176](../mobile/lib/features/profile/presentation/profile_screen.dart)).
  - Contributor Badges bhi mock ho sakta hai, ek baar dekh lo.
- [ ] **Exam Mode** tab par tap karne se kuch nahi hota (bottom nav ka index 1).
- [ ] Welcome screen par "Terms" aur "Privacy Policy" underline hain par tap par kuch nahi hota.
- [ ] `google_fonts` pehli baar font network se laata hai. Internet na ho to default font dikhta hai. Final ke liye fonts app ke andar bundle kar do.
- [ ] `flutter test` abhi fail hota hai (`mobile/test/widget_test.dart` purana hai aur `MyApp` ke required arguments nahi deta). Build par asar nahi, par CI mein dikkat dega. Theek karo ya hata do.
- [ ] iOS abhi cover nahi kiya (Apple developer account aur alag signing chahiye).

## 5. APK par smoke test (isi order mein)

Phone par release APK install karke:

- [ ] Welcome screen (animation chalti hai, status bar aur navigation bar ke rang theek)
- [ ] Get started, Landing screen, Login
- [ ] Render so raha ho tab pehli request (30 se 60 second tak intezaar, error na aaye)
- [ ] Register: Delhi University apne aap select, college aur course dropdown mein aate hain, semester dropdown
- [ ] Register ke baad Subjects form khulta hai, subjects chun ke save ho jaate hain
- [ ] Home: Community aur Resources swipe aur tab tap, feed load hoti hai
- [ ] Subject detail kholna aur resource open karna (in-app browser)
- [ ] Add Document: file upload (Cloudinary) aur external link
- [ ] Create Post (user ka `canPost` true karke), Comments add aur delete
- [ ] Saved screen, bookmark add aur hatana
- [ ] Profile: Curriculum aur semester badalna, My Subjects, Edit profile
- [ ] Logout, phir wapas Welcome
- [ ] R8 se runtime dikkat: login ke baad token save hona (secure storage), app band karke kholne par login bana rehna, file picker, image picker, Lottie, in-app browser

## 6. Final release se pehle (abhi zaroori nahi)

- [ ] Apni keystore se signing, aur keystore ka backup
- [ ] Unique application ID
- [ ] Privacy policy aur terms ke asli links
- [ ] Fonts bundle karna
- [ ] Rate limiting, helmet, `trust proxy` backend mein
- [ ] Crash reporting ya logging
- [ ] Production database alag karna
- [ ] Admin screen ya admin tooling resources approve karne ke liye
- [ ] iOS build (agar chahiye)
