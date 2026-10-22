# New features (nf)

Ye file un features ki list hai jo abhi build nahi ho rahe, baad ke liye rakhe gaye hain.
Chat me `nf` ya "new feature" likhne par yahan nayi row add hoti hai, date aur time ke saath.

**Priority:** High > Priority > Normal > Later
**Kahan kaam:** Backend / Mobile / Both (+ Schema agar migration chahiye)

## Features

| # | Feature | Priority | Kahan kaam | Notes | Added (IST) |
|---|---|---|---|---|---|
| NF-1 | Exam Mode | High | Both | Bottom bar me tab already hai par tap pe no-op (`mobile/lib/app_navigation.dart`, `core/widgets/bottom_nav_bar.dart`). Design aur backend plan baki. | 2026-10-22 23:49 |
| NF-2 | Search me filters (type, year, semester) | Priority | Both | UI: `features/search/presentation/search_screen.dart`. `GET /resources` pe `courseId`, `semester`, `sort` pehle se hain; baaki filters backend me check karne hain. | 2026-10-22 23:49 |
| NF-3 | Onboarding tips (pehli baar ke liye) | Priority | Mobile | "Pehli baar dekha" flag `shared_preferences` se (pubspec me already hai). | 2026-10-22 23:49 |
| NF-4 | Points system (Contributor Badges / XP) | Normal | Both + Schema | Screen abhi mock hai: `features/profile/presentation/contributor_badges_screen.dart`. Backend me points ka model/API nahi. | 2026-10-22 23:49 |
| NF-5 | Notifications (bell + push) | Normal | Both + Schema | Bell no-op hai (`core/widgets/home_top_bar.dart`). Notification model/API nahi. Push ke liye FCM bhi lagega. | 2026-10-22 23:49 |
| NF-6 | Block / mute user | Later | Both + Schema | Report/flag feature ke baad. | 2026-10-22 23:49 |

## Brainstorming baki

| Feature | Kahan kaam | Notes | Added (IST) |
|---|---|---|---|
| My Resource Requests | Both + Schema | Screen abhi mock hai (`features/profile/presentation/my_requests_screen.dart`), Profile pe "2 Pending" badge hard-coded. Requests API chahiye. Pehle brainstorming. | 2026-10-22 23:49 |
