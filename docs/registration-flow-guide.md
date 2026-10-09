# Registration flow: study guide

Everything we built for login and registration in the Flutter app, explained
file by file. Read it in order, top to bottom. Each part builds on the one before.

---

## 0. Read this first: the one idea behind everything

The app is split into **layers**. Each layer has one job and only talks to the
layer directly below it.

```
┌─────────────────────────────────────────────────────────┐
│  UI (screens)          draws state, reports taps        │  presentation/
├─────────────────────────────────────────────────────────┤
│  Bloc / Cubit          decides what happens, emits state│  bloc/
├─────────────────────────────────────────────────────────┤
│  Repository            talks to the API, returns models │  data/
├─────────────────────────────────────────────────────────┤
│  ApiClient + Dio       HTTP, tokens, refresh            │  core/network/
├─────────────────────────────────────────────────────────┤
│  Backend (Express)     /auth/register, /universities... │  backend/
└─────────────────────────────────────────────────────────┘
```

**Rule:** a screen never calls the API. A repository never touches widgets.
The Bloc never touches Dio. This is why each file is small and easy to change.

**Data goes down as requests and comes back up as results:**

```
Tap "Complete Setup"
  → screen adds an EVENT to AuthBloc
    → AuthBloc calls AuthRepository.register(...)
      → AuthRepository calls ApiClient.dio.post('/auth/register')
        → backend creates the user, returns { user, tokens }
      ← AuthRepository saves tokens, returns a UserModel
    ← AuthBloc emits the STATE Authenticated(user)
  ← main.dart's listener sees Authenticated and opens Home
```

---

## 1. Suggested reading order (about 90 minutes)

1. `core/network/token_storage.dart` (small)
2. `core/network/api_exception.dart` (small)
3. `core/network/api_client.dart` (the hard one, read slowly)
4. `Auth/data/user_model.dart`, `signup_draft.dart`
5. `Auth/data/auth_repository.dart`
6. `Auth/bloc/auth_event.dart`, `auth_state.dart`, `auth_bloc.dart`
7. `main.dart`
8. `catalog/data/*`, then **`catalog/bloc/*` (the Cubit)**
9. `core/widgets/app_picker_field.dart`
10. `Auth/presentation/registration_step1_screen.dart`, then `step2`

Paths are under `mobile/lib/features/` unless they start with `core/`.

---

## 2. Layer 1: networking (`lib/core/network/`)

### `token_storage.dart`

Saves and reads the two tokens in the phone's encrypted storage
(`flutter_secure_storage`: Keychain on iOS, Keystore on Android).

| Method | Used by |
|---|---|
| `readAccessToken()` | `ApiClient`, before every request |
| `readRefreshToken()` | `ApiClient` (refresh) and `AuthRepository` (`hasSavedSession`) |
| `saveTokens(...)` | after login, register and refresh |
| `clear()` | logout, or when the refresh fails |

Why not `SharedPreferences`? It is plain text. Tokens are keys to the account.

### `api_config.dart`

One constant: the backend base URL. Default is `http://10.0.2.2:5000/api/v1`,
which is how the **Android emulator** reaches your Mac. Other devices:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:5000/api/v1        # iOS simulator
flutter run --dart-define=API_BASE_URL=http://<mac-lan-ip>:5000/api/v1     # real phone
```

### `api_exception.dart`

Dio throws a messy `DioException`. We convert it into our own
`ApiException(message, statusCode)`. Priority:

1. The server sent `{ "message": "..." }` → use that text ("Invalid Credentials").
2. No answer (timeout, no internet) → a friendly fixed message.

Result: the Bloc only has to catch one error type and show `e.message`.

### `api_client.dart` (read this slowly)

Builds one shared Dio and adds two **interceptors** (middleware for every request).

**`_attachToken` runs before every request:** reads the access token and adds
`Authorization: Bearer <token>`. No screen ever handles tokens.

**`_handleError` runs when a request fails.** Steps:

1. Not a 401, or already retried, or it is a login/register/refresh call?
   Pass the error on untouched. (A wrong password is also a 401 and must show
   as an error, not trigger a refresh.)
2. Otherwise refresh the token, but only once even if 4 requests failed together:
   ```dart
   _refreshing ??= _refreshAccessToken().whenComplete(() => _refreshing = null);
   ```
   `??=` means "assign only if null". The first failing request starts the
   refresh. The others find `_refreshing` already set and wait for the same result.
3. Refresh failed → `_sessionExpired.add(null)`. The AuthBloc listens to this.
4. Refresh worked → put the new token on the original request, mark
   `retried = true` (so it cannot loop), and replay it. The screen never knows.

Two Dio objects exist on purpose: `dio` (with interceptors) and `_refreshDio`
(without). If the refresh call went through the interceptor and got a 401, it
would try to refresh itself forever.

`onSessionExpired` is a broadcast **Stream**. ApiClient has no idea about
screens. It just announces "the session died" and whoever cares reacts.

---

## 3. Layer 2: auth data (`Auth/data/`)

### `user_model.dart`

A typed Dart object for the backend's user JSON.

```dart
factory UserModel.fromJson(Map<String, dynamic> json) { ... }
```

- **`factory`** = a constructor that can run logic before returning an object.
  Here: read each key from the map and cast it. Used as
  `UserModel.fromJson(res.data['data']['user'])`.
- `String? lastName`: nullable because the database allows no last name.
- `extends Equatable` + `props`: two models with the same fields compare equal.
  Bloc needs this to know whether a new state is really different (see §6).
- `fullName` is a getter: calculated each time, not stored.

### `signup_draft.dart`

A plain class holding what step 1 collected (name, username, email, password).
Step 1 passes it to step 2 through the constructor. Nothing fancy: it only
exists so the data survives the screen change.

### `auth_repository.dart`

The only class that knows the auth URLs. Takes `ApiClient` and `TokenStorage`
in its constructor (**dependency injection**: it is handed them, it does not
create them, so there is one shared copy and tests can pass fakes).

| Method | What it does |
|---|---|
| `login(email, password)` | POST `/auth/login`, save tokens, return `UserModel` |
| `register(...)` | POST `/auth/register`, save tokens, return `UserModel` |
| `getMe()` | GET `/auth/me`: "who am I?" (app start) |
| `hasSavedSession()` | local check: is there a refresh token? |
| `logout()` | POST `/auth/logout`; `finally` always clears tokens |

Patterns to notice:

- `try { ... } on DioException catch (e) { throw ApiException.fromDio(e); }`:
  every method converts errors the same way.
- `if (lastName != null && lastName.isNotEmpty) 'lastName': lastName` inside
  the map is a **collection-if**: the key is only added when true. The backend
  rejects an empty `username`, so we must leave it out, not send `""`.
- `_saveSessionAndGetUser` is shared by login and register (same response shape).

---

## 4. Layer 3: the AuthBloc (`Auth/bloc/`)

Full explanation of Bloc concepts is in §6. Here is what each file holds.

### `auth_event.dart`: what can happen (inputs)

`AuthStarted`, `LoginSubmitted(email, password)`,
`RegisterSubmitted(firstName, ..., currentSemester)`, `LogoutRequested`,
`SessionExpired`. Events are *verbs*. Data the handler needs travels inside.

### `auth_state.dart`: what the app can be (outputs)

`AuthInitial`, `AuthLoading`, `Authenticated(user)`, `Unauthenticated`,
`AuthFailure(message)`. States are *conditions*.

`sealed class` = all subclasses live in this file, so Dart can warn you if a
`switch` forgets one.

### `auth_bloc.dart`

```dart
on<LoginSubmitted>(_onLoginSubmitted);   // "when this event arrives, run this"
```

Every handler has the same shape:

```
emit(AuthLoading());
try   { call repository; emit(Authenticated(user)); }
on ApiException catch (e) { emit(AuthFailure(e.message)); }
catch (_)                 { emit(AuthFailure('Something went wrong...')); }
```

The last `catch (_)` is a safety net. Without it, an unexpected bug would leave
the state stuck on `AuthLoading` forever.

The constructor also listens to `apiClient.onSessionExpired` and turns it into
a `SessionExpired` event. `close()` cancels that subscription (otherwise: leak).

Table of what happens:

| Situation | States emitted |
|---|---|
| App opens, saved login valid | `AuthInitial` → `Authenticated` |
| App opens, nothing saved | `AuthInitial` → `Unauthenticated` |
| Register or login succeeds | `AuthLoading` → `Authenticated` |
| Wrong password / email taken | `AuthLoading` → `AuthFailure("...")` |
| Logout, or refresh token dead | `Unauthenticated` |

---

## 5. Layer 3 again: the CatalogCubit (`catalog/`): the new thing

This is the part you asked about most. Go slowly.

### 5.1 Cubit vs Bloc

|  | Bloc | Cubit |
|---|---|---|
| Input | You `add(Event)` | You call a **method** directly |
| Output | `emit(State)` | `emit(State)` (identical) |
| Extra files | Event classes + `on<>` handlers | None |
| Use when | Events matter or need logging/transforming (login, app start) | Simple "do this, update state" (a form with pickers) |

A Cubit **is** a Bloc without events. Same `emit`, same `BlocBuilder` in the UI.
That is why `CatalogCubit` is shorter than `AuthBloc`.

### 5.2 Why a Cubit for step 2

Step 2 needs: a list of universities, a chosen university, the colleges and
courses of *that* university, a chosen college and course, plus loading flags
and errors. That is "form state that changes when the user picks things".
Nobody needs an event history for that, so a Cubit fits.

### 5.3 `catalog_models.dart`

`University`, `College`, `Course`: three small `Equatable` classes with
`fromJson`, same idea as `UserModel`. `Course.totalSemesters` lets step 2 show
the right number of semester buttons.

### 5.4 `catalog_repository.dart`

```dart
Future<List<University>> getUniversities() =>
    _getList('/universities', 'universities', University.fromJson);
```

One private helper, `_getList<T>`, does fetch → read `data[key]` → convert each
item with the function you pass. `<T>` is a **generic**: "some type the caller
decides". `University.fromJson` is passed as a function (a *tear-off*), and
`.map(...)` calls it on every item. This avoids writing the same code three times.

Colleges and courses need `?universityId=...`, passed as `queryParameters`.

### 5.5 `catalog_state.dart`

One class holding everything true at the same moment:

```
universities, colleges, courses              ← the lists
selectedUniversity, selectedCollege, selectedCourse   ← the choices
isLoadingUniversities, isLoadingOptions      ← spinners
error                                        ← last error message
bool get isComplete                          ← all three chosen?
```

**Why one class, not sealed states like AuthState?** Auth is *one thing at a time*
(loading OR authenticated OR failed). The form is *many things at once*
(universities loaded AND one selected AND colleges still loading). One class
with fields models that cleanly.

**States are immutable:** you never edit `state.selectedCollege = x`. You create
a modified copy:

```dart
state.copyWith(selectedCollege: college)   // same as before, except this field
```

`copyWith` keeps every field you did not mention (`field ?? this.field`).
Exception: `error: error` has no `?? this.error`, on purpose, so every new
state wipes an old error unless you pass a new one.

### 5.6 `catalog_cubit.dart`: method by method

```dart
class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(this._repository) : super(const CatalogState());
```

`super(const CatalogState())` is the starting state: empty lists, nothing chosen.

**`loadUniversities()`**

```
emit(copyWith(isLoadingUniversities: true))      → spinner on the University field
await repository.getUniversities()
if (isClosed) return;                            → screen already gone? stop
emit(copyWith(universities: list, isLoadingUniversities: false))
on ApiException → emit(copyWith(isLoadingUniversities: false, error: message))
```

**`selectUniversity(university)`**: the interesting one.

```dart
emit(CatalogState(
  universities: state.universities,
  selectedUniversity: university,
  isLoadingOptions: true,
));
```

It builds a **fresh** state instead of `copyWith`. Reason: switching university
must clear the old college and course, and `copyWith` would keep them.

Then it fetches colleges and courses **at the same time**:

```dart
final results = await Future.wait([
  _repository.getColleges(university.id),
  _repository.getCourses(university.id),
]);
```

`Future.wait` starts both requests and finishes when both are done (faster than
one after the other). If one fails, you get the original `ApiException`.
`results[0] as List<College>` tells Dart the type of each result.

**The two guards after every `await`:**

1. `if (isClosed) return;`
   `BlocProvider(create: ...)` in step 2 **closes the cubit automatically** when
   the screen is popped. Emitting on a closed cubit throws. If the user presses
   back while a request is in flight, the guard stops the crash.
2. `state.selectedUniversity != university`
   A **race condition** guard. User taps University A, then quickly University B.
   A's slower response arrives after B was chosen. Without the guard, A's
   colleges would overwrite B's. The check says "is this still the university
   I asked for? If not, drop the answer."

**`selectCollege`, `selectCourse`**: one-liners: `emit(state.copyWith(...))`.

### 5.7 A timeline (what the state looks like over time)

User opens step 2, taps "University", picks "Delhi University":

| # | Event | State (key fields) |
|---|---|---|
| 1 | cubit created | lists empty, nothing selected |
| 2 | `loadUniversities()` starts | `isLoadingUniversities: true` |
| 3 | response arrives | `universities: [..2 items..]`, loading false |
| 4 | user picks DU, `selectUniversity` | `selectedUniversity: DU`, `isLoadingOptions: true`, college/course cleared |
| 5 | both responses arrive | `colleges: [71]`, `courses: [118]`, loading false |
| 6 | user picks a college | `selectedCollege: X` |
| 7 | user picks a course | `selectedCourse: Y`, `isComplete == true` |

At every row, `BlocBuilder` rebuilds the form from that snapshot. The UI has no
variables of its own for any of this. That is the whole point.

---

## 6. Bloc/Cubit concepts, plain and short

**State is the single source of truth.** The screen is a function of state:
`UI = f(state)`. Change state, the screen redraws.

**`emit(newState)`** pushes a state out. Bloc compares it with the old one
using `==`. If they are equal, **nothing happens**.

**Equatable** makes `==` compare *fields* instead of identity. Without it, every
`emit` would look "different" even when nothing changed (or, with sloppy
equality, real changes could be missed). Always list all fields in `props`.

**Three widgets connect UI and state:**

| Widget | Use for | Runs |
|---|---|---|
| `BlocBuilder` | *Drawing*: show a spinner, fill a picker | every state change, inside `build` |
| `BlocListener` | *One-time reactions*: snackbar, navigation | once per change, **not** part of drawing |
| `BlocConsumer` / `MultiBlocListener` | builder + listener together / several listeners | same |

Why not show a snackbar inside a builder? `build` can run many times (rotation,
keyboard), so you would get repeated snackbars. Listeners fire once per state change.

`listenWhen: (previous, current) => ...` filters which changes a listener reacts
to. Step 2 uses it so the catalog error snackbar only fires when the error is
**new** (`current.error != previous.error`).

**Getting a Bloc/Cubit from the tree:**

```dart
context.read<AuthBloc>().add(...)          // grab it once (use in onPressed)
BlocBuilder<CatalogCubit, CatalogState>    // watch it and rebuild
```

`read` does not rebuild. `BlocBuilder` does. Use `read` in callbacks,
`BlocBuilder` for display.

**`BlocProvider(create: ...)`** creates the object, hands it to everything
below, and **closes it** when the widget leaves the tree. `..loadUniversities()`
is Dart's cascade: "create it, then also call this".

**Why "ProviderNotFound" happened earlier:** two different file paths
(`auth/` vs `Auth/`) made two different `AuthBloc` classes. Always use exact
folder casing in imports.

---

## 7. The picker (`core/widgets/app_picker_field.dart`)

Two classes:

- **`AppPickerField<T>`**: the field. Shows the selected text or the hint, a
  down arrow, or a spinner while `isLoading`. Disabled when `enabled: false`
  (college and course are disabled until a university is chosen).
- **`_PickerSheet<T>`**: the bottom sheet with the list, opened by
  `showModalBottomSheet<T>(...)`. `await` waits until it closes and returns the
  tapped item (or `null` if dismissed). A row tap does `Navigator.pop(context, item)`.

Details worth knowing:

- Generic `<T>` makes one widget work for universities, colleges and courses.
  You pass `itemLabel: (c) => c.name` so it knows how to print an item.
- `InkWell` + `InputDecorator` instead of a `TextField`: a read-only text field
  would need a controller (and controllers leak if not disposed).
- The search box appears only if there are more than 8 items.
- The check mark uses `item == widget.selected`, which works because of Equatable.

---

## 8. The screens (`Auth/presentation/`)

### `loginscreen.dart`

- Two `TextEditingController`s (that is how you read what was typed), disposed
  in `dispose()`.
- `_submit()` validates, then `context.read<AuthBloc>().add(LoginSubmitted(...))`.
- `BlocBuilder` on the button: `AuthLoading` → label "Signing in..." and
  `onPressed: null` (null disables the button, preventing double taps).
- `BlocListener` shows the `AuthFailure` message. Guard
  `ModalRoute.of(context)?.isCurrent` stops it reacting when a signup screen is
  on top (the login screen stays alive underneath).

### `registration_step1_screen.dart`

- Five controllers, one per field.
- `_validate()` returns the first problem or `null`. Rules mirror the backend's
  `registerSchema` (first name 3+, last name empty or 3+, username 3-30 of
  `[a-zA-Z0-9_]` or empty, valid email, password 8+). Failing fast saves a round trip.
- `_next()` builds a `SignupDraft` (empty optional fields become `null`) and
  pushes `SignupStep2Screen(draft: draft)`.

### `registration_step2_screen.dart`

Split in two widgets:

- **`SignupStep2Screen`** (stateless): only creates the cubit:
  ```dart
  BlocProvider(create: (context) =>
      CatalogCubit(context.read<CatalogRepository>())..loadUniversities(), ...)
  ```
  The UI must be *below* the provider, so it lives in a child widget.
- **`_SignupStep2View`** (stateful): holds the two things that are not catalog
  data: `_selectedSemester` (`int?`, null until chosen) and `_agreedToTerms`.

In `build`:

- `MultiBlocListener` with two listeners: `AuthBloc` failures (register errors)
  and `CatalogCubit` errors (with a **Retry** action if nothing loaded).
- `BlocBuilder<CatalogCubit, CatalogState>` rebuilds the form on every catalog change.

In `_buildForm`:

- Three `AppPickerField`s wired to the cubit: `onSelected: cubit.selectCollege`
  (a method reference, same as `(c) => cubit.selectCollege(c)`).
- Semester buttons = `catalog.selectedCourse?.totalSemesters ?? 8`. If you pick a
  4-semester course while Sem 6 was selected, the selection is ignored (treated as unselected).
- Submit button inside `BlocBuilder<AuthBloc, AuthState>`: disabled and
  "Creating account..." while `AuthLoading`.

`_submit()` checks in order: all pickers chosen → semester valid → terms
ticked → `add(RegisterSubmitted(...))`. It reads the catalog selection with
`context.read<CatalogCubit>().state`.

**There is no navigation on success.** That is `main.dart`'s job:

---

## 9. `main.dart`: where everything is connected

```dart
final tokenStorage = TokenStorage();
final apiClient = ApiClient(tokenStorage);
final authRepository = AuthRepository(apiClient, tokenStorage);
final catalogRepository = CatalogRepository(apiClient);
```

Built **once**, in dependency order (each takes the previous). That is
dependency injection by hand.

```dart
MultiRepositoryProvider(providers: [...repositories...],
  child: BlocProvider(create: (_) => AuthBloc(...)..add(const AuthStarted()),
    child: MaterialApp(... builder: (context, child) => BlocListener<AuthBloc, AuthState>(...)
```

- Repositories are provided so any screen can `context.read<CatalogRepository>()`.
- `AuthBloc` lives above `MaterialApp` so **every screen** can reach it.
  `..add(const AuthStarted())` fires the "is someone already logged in?" check.
- The `BlocListener` in `MaterialApp.builder` sits above all routes. On
  `Authenticated` it runs `pushAndRemoveUntil(HomeScreen)`; on `Unauthenticated`
  it runs `pushAndRemoveUntil(LandingScreen)`. `pushAndRemoveUntil(..., (r) => false)`
  clears the whole stack, so the back button cannot return to login after
  signing in. That is why no form screen navigates by itself.
- `_navigatorKey` lets the listener navigate without a screen's `context`.
- `_SplashScreen` is only the spinner shown while `AuthStarted` runs.

---

## 10. The whole registration, step by step

1. App starts. `AuthStarted` → no saved tokens → `Unauthenticated` → Landing.
2. Landing → Sign In → "Register with email" → **Step 1**.
3. User types, taps **Next Step**. `_validate()` passes → `SignupDraft` → **Step 2**.
4. Step 2 builds → `BlocProvider` creates `CatalogCubit` → `loadUniversities()` runs.
5. User picks university → `selectUniversity` → colleges + courses fetched together.
6. User picks college, course, semester, ticks terms, taps **Complete Setup**.
7. `_submit()` passes → `AuthBloc.add(RegisterSubmitted(...))`.
8. `AuthBloc`: `emit(AuthLoading)` → button shows "Creating account...".
9. `AuthRepository.register` → POST `/auth/register` → backend hashes the
   password, creates the user, returns `{ user, tokens }`.
10. Repository saves the tokens (`TokenStorage`), returns `UserModel`.
11. `AuthBloc`: `emit(Authenticated(user))`.
12. `main.dart` listener → `pushAndRemoveUntil(HomeScreen)`.
13. Next app launch: `AuthStarted` → `hasSavedSession` true → `getMe()` →
    `Authenticated` → straight to Home.

**What if it fails?**

| Failure | Where it is caught | What the user sees |
|---|---|---|
| Short password | step 1 `_validate` | snackbar, no network call |
| Email already used | backend 409 → `ApiException` → `AuthFailure` | snackbar "User with this email already exists" |
| Server down / wrong URL | `ApiException.fromDio` | "Cannot reach the server..." |
| Universities fail to load | `CatalogCubit` error | snackbar with **Retry** |
| Unexpected bug | `catch (_)` in the bloc | "Something went wrong..." (never stuck loading) |

---

## 11. Dart concepts cheat sheet

| Concept | Meaning in one line |
|---|---|
| `final` | assigned once, never changed |
| `const` | fixed at compile time (cannot hold a controller) |
| `String?` | may be `null`; `String` may not |
| `factory` | constructor that runs logic first (e.g. `fromJson`) |
| `Future` / `async` / `await` | a value that arrives later; `await` pauses until it does |
| `Stream` | many values over time (`onSessionExpired`) |
| `sealed class` | closed family of subclasses, enables exhaustive `switch` |
| `Equatable` / `props` | compare objects by fields |
| generics `<T>` | "a type decided by the caller" |
| `..` cascade | do something to the object just created (`create()..load()`) |
| `??=` | assign only if currently null |
| `if (x) 'key': v` | collection-if: include an entry conditionally |
| `_name` | leading underscore = private to the file |
| `late final` | assigned later, once (the stream subscription) |

---

## 12. Self-test (try these tomorrow)

1. In `selectUniversity`, change `emit(CatalogState(...))` to a `copyWith`. Pick
   a college, then change university. What breaks, and why?
2. Delete `if (isClosed) return;`, open step 2 and press back immediately.
3. Remove `props` from `CatalogState`. Does the UI still update correctly?
4. Put `print(state)` inside a `BlocListener` and watch the order of states
   while registering (`flutter run` terminal).
5. Make the password 7 characters. Where is the error caught? Which layer?
6. Turn off the backend and tap Complete Setup. Which message appears, and which
   file produced it?
7. Add a "Reset" button on step 2 that clears the selections. Which class
   gets the new method, and what does it emit?

---

## 13. Known gaps and what comes next

- **Home and Profile still show hardcoded data.** Next: read `Authenticated.user`
  and show the real name, course and college.
- **No Logout button is wired.** `LogoutRequested` exists; nothing sends it yet.
- **Courses are not filtered by college.** The backend has a `CollegeCourse`
  table but no endpoint using it.
- **Login is email-only.** The backend `loginSchema` requires an email.
- **Backend:** invalid IDs (nonexistent college/course) currently produce a
  generic 500; a Prisma foreign-key error handler would give a clear message.
- **Folder casing:** `features/Auth` is capitalised; Dart convention is lowercase.
  Renaming later means updating every import at once.
