# MR Flutter App — Feature & Architecture Report

> **Historical snapshot (4.0.10).** Several risks listed here are fixed in
> 4.0.11 (runtime Google Fonts, the hard-coded fallback video, unscoped notes,
> no global 401/expired-session handling, missing CI quality gate). Auto-login
> still restores from the stored token; an expired token is cleared by the
> first 401. See
> [`../CHANGELOG.md`](../CHANGELOG.md), [`UPDATE_FLOW.md`](UPDATE_FLOW.md) and
> [`ENVIRONMENT.md`](ENVIRONMENT.md) for current behaviour.

**Date:** 2026-11-07
**App version:** 4.0.10+10 (`pubspec.yaml`)
**Platforms scaffolded:** Android, iOS, Web, Windows, macOS, Linux (only Android has a release pipeline)
**Code size:** 96 Dart files in `lib/` (~6,800 lines), 4 test files (~443 lines)
**Verification run:** `flutter analyze` → *No issues found*; `flutter test` → **19/19 passed**

---

## 1. Executive summary

The app is a Flutter client for an educational platform ("MR"). It is built with a
feature-first, clean-architecture-inspired layout (data / domain / presentation),
BLoC/Cubit state management, `get_it` dependency injection, Dio networking, and
`dartz` `Either` for error handling.

Two user roles are supported at routing level:

- **Student** → main shell with three tabs: QR identity card, lessons, reports.
- **Assistant / non-student** → QR scanner flow: scan a student card, view the
  student, register attendance.

A mandatory in-app update mechanism runs at every startup and can block the app
until a newer APK is installed.

The codebase is compact, consistent, and analyzable with zero analyzer issues.
The main risk areas are not "broken code" but release/identity concerns:
the Android application ID is still a placeholder (`com.example.teacher`), the
in-app APK update path has no rollback or checksum, there are no CI quality
gates, and several screens/packages are unfinished or unused.

---

## 2. Technology stack

| Area | Choice |
|---|---|
| Framework | Flutter (stable), Dart SDK `^3.11.5` |
| State management | `flutter_bloc` 9 / `bloc` 9 (`Cubit` used everywhere) |
| DI | `get_it` (`lib/core/di/service_locator.dart`) |
| Networking | `dio` + custom `DioClient` interceptor |
| Functional error model | `dartz` `Either<Failure, T>` |
| Secure session | `flutter_secure_storage` (token + role) |
| Simple flags | `shared_preferences` (onboarding completed) |
| Local data | `sqflite` (lesson notes, `app.db`) |
| Responsive UI | `flutter_screenutil` (design size 375×812) |
| Fonts | `google_fonts` (Cairo, Tajawal) fetched at runtime |
| QR display | `qr` + custom `CustomPainter` |
| QR scanning | `ai_barcode_scanner` (QR only, camera + gallery) |
| Video | `youtube_player_flutter` with custom controls |
| App updates | `package_info_plus`, `path_provider`, `open_filex` |
| Splash/icons | `flutter_native_splash`, `flutter_launcher_icons` |
| Native analytics | Firebase Analytics via Gradle (`com.google.gms.google-services`), no FlutterFire code |

---

## 3. Architecture

```
lib/
├── main.dart                      ScreenUtilInit + MaterialApp + onGenerateRoute
├── core/
│   ├── constants/api_constants.dart
│   ├── di/service_locator.dart    all singletons/factories
│   ├── extensions/                push / pushReplacement / pushUntil / pop
│   ├── network/                   Dio client, ApiResponse<T>, Failure mapper
│   ├── routing/                   named routes + switch-based AppRouter
│   ├── storage/                   TokenStorage, OnboardingStorage
│   ├── theme/                     AppColors, FontWeightHelper, TextStyles
│   └── widgets/                   CustomButton, AppErrorDialog, StudentAvatar
└── features/
    ├── auth/          splash, login, auto-login, AuthCubit, AutoAuthCubit
    ├── onboarding/    2-page intro, persisted completion flag
    ├── root.dart      3-tab shell (QR, Lessons, Reports)
    ├── student/       QR card, profile, reports + models
    ├── lessons/       list, detail, YouTube, local notes (SQLite)
    ├── assistant/     QR entry → camera → result → attendance
    └── update/        release check, APK download/install, blocker UI
```

Patterns applied consistently:

- Each feature has `data` (models, data sources, repositories) and `presentation`
  (cubits, states, screens/widgets); most also have `domain` repositories.
- UI reads state with `BlocBuilder` / `BlocListener`; one-shot actions use listeners.
- Failures from Dio are normalized in `NetworkExceptions.handle()` into Arabic messages.
- Navigation is centralized in `AppRouter` with named routes and `settings.arguments`.

---

## 4. Startup and navigation flow

```
main()
 └─ setupServiceLocator()
 └─ MyApp → initial route /splash
      SplashScreen
        ├─ AutoAuthCubit.checkAuthentication()  (token + role from secure storage)
        └─ UpdateCubit.checkForUpdate()         (GET /app/releases/latest)
             │
             ├─ update required → MandatoryUpdateView (blocks navigation, PopScope)
             └─ not required / check failed → continue
                    │
                    ├─ authenticated + role == student → /root  (3 tabs)
                    ├─ authenticated + other role      → /scan_qr_entry
                    └─ unauthenticated → onboarding (first run) or /login
```

Guard behavior: the update check **fails open** (network/server error does not block
the app), while a detected newer `version_code` **fails closed** (mandatory gate).

---

## 5. Feature catalog

### F1. Splash / bootstrap
- Files: `features/auth/presentation/screens/splash_screen.dart`
- Runs auth restore and update check in parallel and waits for both signals before
  navigating.
- On onboarding-not-completed, routes to `/onBoardingView`; otherwise `/login`.
- Blocks on `UpdateRequired`, `UpdateDownloading`, `UpdateDownloadFailed`,
  `UpdateInstallStarted`, `UpdateInstallFailed`; `UpdateInstallStarted` unblocks
  navigation so the system installer can take over.

### F2. Onboarding
- Files: `features/onboarding/**`
- Two RTL image pages with dots, "استمر" / "يلا نبدأ", back arrow.
- Persists `ONBOARDING_COMPLETED` in `shared_preferences`.
- On finish: clears navigation stack and opens login.

### F3. Authentication
- Files: `features/auth/**`, `lib/core/storage/token_storage.dart`
- `POST /auth/login` with `{username, password}`.
- Stores `AUTH_TOKEN` and `AUTH_ROLE` in `flutter_secure_storage`.
- `AuthCubit` validates only "non-empty" fields, shows `AuthLoading`, then
  routes by `user.role == 'student'`.
- Auto-login on launch only checks that a token exists and returns its stored role;
  it does **not** validate the token against the server.
- Errors use a custom Arabic dialog; server messages are preferred when present.

### F4. Role-based landing
- Student → `Root` shell.
- Any other role (assistant/teacher) → `ScanQrEntryView`.
- There is no route guard; protection relies on the splash/login redirect.

### F5. Student home — QR identity card
- Files: `features/student/presentation/screens/qr_code_view.dart`,
  `widgets/qr_code_widget.dart`
- Fetches `/student/profile`, shows name, grade, avatar (tap → profile page).
- Renders `qr_code_string` with a hand-written QR painter (`qr` package).
- Text instructs the student to show the code at the center to record attendance.

### F6. Student profile
- Files: `features/student/presentation/screens/profile_view.dart`
- Sections: personal information (ID, student code, grade, DOB, name, email,
  phone) and guardian information (name, phone).
- Avatar supports relative storage paths (resolved to `.../storage/...`) and
  markdown-style image values.
- Logout clears token + role and resets the stack to login.

### F7. Reports
- Files: `features/student/presentation/screens/reports_view.dart`, `data/models/*report*`
- `GET /student/reports` → `{student, attendance, financials}`.
- Displays a student summary card, attendance total + record dates, and financial
  total + record values, with pull-to-refresh and empty states.
- Dates are formatted to Arabic month names; financial rows are generic
  `data` maps joined into a string.

### F8. Lessons list
- Files: `features/lessons/presentation/screens/lessons_list_screen.dart`
- `GET /student/lessons`; cards show chapter badge, title, duration, thumbnail,
  play overlay.
- Client-side search over title and chapter (instant filter), pull-to-refresh,
  full-screen loading/error/empty states.
- No pagination — assumes the endpoint returns all lessons.

### F9. Lesson detail + video
- Files: `features/lessons/presentation/screens/lesson_detail_screen.dart`,
  `widgets/lesson_video_controls.dart`
- `GET /student/lessons/{id}`.
- YouTube embed with custom controls: play/pause, ±10 s, seek bar with buffered
  fraction, timestamps, auto-hide, fullscreen with orientation/system-UI changes,
  loop on end.
- Prev/next lesson buttons from `previous_lesson_id` / `next_lesson_id`.
- Tabs: overview (`about_lesson`, `what_you_will_learn`) and notes.
- Supports `youtu.be`, `?v=`, `/embed/`, `/shorts/` URL forms.
- If the URL is missing/unparseable, a hardcoded fallback video ID is played.

### F10. Lesson notes (offline)
- Files: `features/lessons/data/datasources/notes_database.dart`,
  `repositories/lesson_notes_repository_impl.dart`, `presentation/cubit/lesson_notes_cubit.dart`
- SQLite `app.db`, table `lesson_notes` (id, lesson_id, content, created_at,
  updated_at) with an index on `lesson_id`.
- Add / edit / delete with confirmation; newest first; 500-character limit.
- Data is device-local and not synced to the backend.

### F11. Assistant QR scan + attendance
- Files: `features/assistant/scan_qr_code/**`
- Three screens share one `ScanQrCubit` via `BlocProvider.value`.
- Entry screen: instructions, scan button, logout.
- Camera: `ai_barcode_scanner`, QR-only, gallery import, duplicate-frame guard,
  loading overlay, error snackbar, replacement navigation on success.
- `GET /assistant/student/scan/{qr}` → student details, then
  `POST /assistant/attendance/register` with `{student_id}`.
- Success: green snackbar "تم تسجيل الحضور بنجاح", stack reset to scan entry.

### F12. Mandatory in-app update
- Files: `features/update/**`
- Reads installed `version_code` via `package_info_plus`; compares with backend
  `version_code` (`latest > installed` ⇒ update required).
- Downloads the APK (3-minute receive timeout), validates ZIP/APK magic bytes,
  saves to `ApplicationSupport/updates/app-update-<versionCode>.apk`, reuses a
  matching cached file, deletes stale/legacy APKs, then opens the system installer
  through `open_filex`.
- Blocking UI: no dismiss, no back (`PopScope(canPop: false)`), progress bar,
  retry on failure, changelog display.
- The download source is `release.file_url` when present, otherwise
  `/app/releases/latest/download`.

### F13. Cross-cutting UX
- Arabic-first UI with explicit `Directionality.rtl` on screens.
- Orange brand palette (`#E8552A`), gradients, Cairo/Tajawal fonts.
- `flutter_screenutil` for size scaling from a 375×812 design.
- Shared `StudentAvatar` automatically resolves relative image paths.
- Standard loading / error / empty / retry states across features.
- No dark theme, no localization framework (strings are hardcoded Arabic).

---

## 6. Backend API surface used by the app

Base URL: `https://mr-edu.ertiqaa.site/api/v1`
Storage base: `https://mr-edu.ertiqaa.site/storage`

| Method | Endpoint | Used by | Notes |
|---|---|---|---|
| POST | `/auth/login` | Login, CI | Returns `data.token` + `data.user` |
| GET | `/student/profile` | QR home, profile | Avatar, QR string, guardian data |
| GET | `/student/lessons` | Lessons list | No pagination |
| GET | `/student/lessons/{id}` | Lesson detail | Video URL, prev/next IDs |
| GET | `/student/reports` | Reports | student + attendance + financials |
| GET | `/assistant/student/scan/{qr}` | Scanner | URL-encoded QR value |
| POST | `/assistant/attendance/register` | Scanner | `{student_id}` |
| GET | `/app/releases/latest` | Update check, CI | `version_code`, `file_url`, changelog |
| GET | `/app/releases/latest/download` | Update download | Fallback APK source |
| POST | `/app/releases` | CI only | Publishes release metadata |

Networking details:

- `DioClient` attaches `Authorization: Bearer <token>` to every request via an
  interceptor; `Content-Type: application/json`; 15 s connect/receive timeouts.
- `ApiResponse<T>` expects `{success, message, data}`.
- `NetworkExceptions` maps timeouts, connection errors, and 400/401/403/404/500
  to Arabic user messages.

---

## 7. Local storage

| Store | Data | Notes |
|---|---|---|
| `flutter_secure_storage` | auth token, role | Cleared on logout |
| `shared_preferences` | onboarding completed | Boolean |
| SQLite `app.db` | lesson notes | Device-local, not user-scoped |

---

## 8. Quality gates (executed)

| Check | Result |
|---|---|
| `flutter analyze` | No issues found |
| `flutter test` | 19/19 passed |
| Test coverage focus | Update feature only (comparator, model parsing, download/caching/install state machine, restart behavior) |
| Tests for auth, lessons, reports, scan, routing, widgets | None |

---

## 9. Strengths

1. **Consistent structure** — every feature follows the same data/presentation split.
2. **Predictable state** — Cubit + immutable states; no business logic in widgets.
3. **Centralized DI and routing** — easy to trace dependencies and navigation.
4. **Uniform error model** — every repository returns `Either<Failure, T>`.
5. **Offline-capable notes** — local SQLite with CRUD and index.
6. **Strong update logic** — version-aware cache, stale APK cleanup, APK magic-byte
   validation, gate that cannot be dismissed, fail-open on check errors.
7. **Zero analyzer noise and a green test suite.**
8. **Thoughtful video UX** — custom controls, fullscreen orientation handling,
   buffering/seek feedback.
9. **Responsive/RTL-first UI** with a coherent visual identity.

---

## 10. Findings and risks

### P0 — resolve before any store/public release

1. **Placeholder Android application ID.**
   `android/app/build.gradle.kts` uses `namespace` / `applicationId =
   "com.example.teacher"` (with a TODO), `MainActivity` lives under
   `com/example/teacher`, and `google-services.json` is registered for
   `com.example.teacher`. iOS uses `com.ertiqaa.mr`. Changing the Android ID after
   distribution makes upgrades impossible (users must uninstall) and breaks the
   Firebase registration. Decide the final ID before the next public APK.

2. **No rollback path for a mandatory update.**
   The app forces every user onto the backend "latest" APK. If that APK is bad,
   all users are blocked. There is no kill-switch, no minimum-supported-version
   fallback, and no previous-release pointer.

### P1 — high impact

3. **Downloaded APK is only checked by magic bytes.**
   `release_remote_data_source.dart` verifies the `PK` header but not a SHA-256
   checksum or signer. Android's installer blocks signature mismatches for
   updates, but integrity and corrupted-download detection would be stronger with
   a published checksum.

4. **No handling for expired/revoked tokens.**
   Auto-login trusts token presence only. A stale token lands the user in the app,
   where each request returns 401 mapped to *"اسم المستخدم أو كلمة المرور غير
   صحيحة"* (a login-credentials message), with no redirect to login. Add a global
   401 handler that clears the session.

5. **Hardcoded production URL, no environments/flavors.**
   `ApiConstants.baseUrl` is compiled in. The workflow's `BACKEND_BASE_URL` is not
   injected into the app. There is no staging configuration.

6. **Hardcoded fallback YouTube video.**
   `_fallbackVideoId = 'AEHJqatke6E'` means a missing/invalid `video_url` silently
   plays unrelated content instead of showing an error. This is a content-correctness
   risk in an education product.

7. **Documentation contradicts the update implementation.**
   `docs/CI_CD_RELEASE.md` says `data.file_url` is metadata only and is **not** the
   download source, but `UpdateCubit.startUpdate()` downloads `release.fileUrl`
   whenever it is non-empty. The docs also name `download_latest_apk.dart`, while
   the file is `download_release_apk.dart`.

8. **Direct APK self-update conflicts with Play Store distribution.**
   If the app is later published on Google Play, a mandatory downloaded-APK flow
   (and `REQUEST_INSTALL_PACKAGES`) is not the recommended update path. Plan for
   Play In-App Updates or keep a documented side-load distribution model.

### P2 — medium

9. **Unused dependencies** (no references in `lib/`): `pinput`, `flutter_svg`,
   `carousel_slider`, `smooth_page_indicator`, `flutter_staggered_grid_view`,
   `sqflite_common_ffi`. `flutter_native_splash` is a runtime dependency but is
   only a build-time tool. Remove or move to `dev_dependencies`.
10. **~6.4 MB of assets bundled, much of it unreferenced.**
    Only `item2.png`, `item3.png`, `token_atom.png`, `onboarding1.png`,
    `onboarding2.png` are referenced from Dart. Design screenshots
    (`lessons-screen.png`, `lesson-video-screen.png`, `profile.png`) and several
    logos/splashes are also shipped because the whole `assets/` directory is
    declared. This inflates the APK.
11. **Notes are not scoped to a user.** All accounts on the same device share the
    same `lesson_notes` table.
12. **No caching or shared profile state.** `Root` builds all three tabs at once;
    the QR tab and profile screen each create their own `ProfileCubit` and refetch
    the profile. No repository cache.
13. **No pagination.** Lessons and reports are fetched in full.
14. **Fragile dynamic financial rendering.** Values are extracted from an untyped
    `data` map and concatenated; field order/labels are not controlled.
15. **Leftover/dead code and TODOs.** TODO markers in `scanned_student_model.dart`,
    commented-out report button in `qr_code_view.dart`, an unused `Gap` import,
    unused `TextStyles`, and an unused `AppColors.background`/`cardBackground`
    distinction.
16. **Google Fonts fetched at runtime.** First launch without network falls back
    to system fonts (and fonts are not bundled). Prefer bundling Cairo/Tajawal.
17. **No accessibility/localization framework.** Hardcoded Arabic strings, no
    `intl`, no semantic labels, no dynamic-type review, no dark mode.
18. **Placeholder project metadata.** README and `pubspec.yaml` description still
    say "A new Flutter project", and the package name is `mr` while the folder is
    `teacher`.

### P3 — low

19. Login button can submit whitespace-only input (only trimmed-empty is blocked,
    which is handled) but there is no password-length/format rule, no "forgot
    password", and no keyboard "next/done" flow.
20. Two different logout locations (profile tab and scanner entry); no logout in
    the lessons/reports tabs.
21. Some UI colors/buttons (green logout, `#FF5722` dialog button) are outside the
    central palette.
22. Native `CAMERA` permission is not declared in the app manifest (it is supplied
    by `ai_barcode_scanner`'s manifest merge). Worth pinning explicitly to avoid
    surprises if the plugin changes.

---

## 11. Recommended roadmap

**Before the next release**
- Decide and apply the final `applicationId`/bundle ID; regenerate
  `google-services.json`; update iOS to match if desired.
- Add CI checks (`flutter analyze`, `flutter test`) and a PR workflow before release.
- Add a SHA-256 for the published APK and verify it client-side after download.
- Handle 401 globally: clear token/role and route to login.
- Fix the `file_url` documentation/code mismatch.
- Remove unused dependencies and exclude design screenshots from the asset bundle.

**Short term**
- Introduce flavors/`--dart-define` for API base URL (dev/staging/prod).
- Add a backend-controlled kill-switch / minimum version / rollback for updates.
- Cache profile data and avoid duplicate fetches in the tab shell.
- Bundle fonts and add `intl`-based localization.
- Add widget/unit tests for auth, lessons, reports, and scan flows.

**Medium term**
- Replace the hardcoded fallback video with an explicit error state.
- Scope notes per user (or move them server-side).
- Add pagination and pull-to-refresh everywhere data can grow.
- Adopt `ThemeData` and a single design-token layer instead of per-screen styles.
- Evaluate Play In-App Updates if distributing through Google Play.

---

## 12. Feature completeness matrix

| Feature | UI | API | Local persistence | Tests | Status |
|---|---|---|---|---|---|
| Onboarding | ✅ | — | ✅ | ❌ | Complete |
| Login / auto-login | ✅ | ✅ | ✅ | ❌ | Complete (no token expiry handling) |
| Student QR card | ✅ | ✅ | — | ❌ | Complete |
| Student profile | ✅ | ✅ | — | ❌ | Complete (read-only) |
| Reports | ✅ | ✅ | — | ❌ | Complete (basic) |
| Lessons list | ✅ | ✅ | — | ❌ | Complete |
| Lesson detail / video | ✅ | ✅ | — | ❌ | Complete |
| Lesson notes | ✅ | — | ✅ | ❌ | Complete (offline only) |
| Assistant scan | ✅ | ✅ | — | ❌ | Complete |
| Attendance registration | ✅ | ✅ | — | ❌ | Complete |
| Mandatory update | ✅ | ✅ | ✅ | ✅ | Complete (see risks) |
| Push notifications | ❌ | ❌ | — | — | Not present |
| Offline mode / sync | ❌ | ❌ | Partial (notes) | — | Not present |
| Payments | ❌ | — | — | — | Not present |
| Teacher/assistant dashboard | ❌ | — | — | — | Not present (scanner only) |

---

*Generated from a full source review on 2026-11-07. Line references may shift as
the code evolves.*
