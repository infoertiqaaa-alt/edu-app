# Graph Report - MR  (2026-11-07)

## Corpus Check
- Corpus is ~45,566 words - fits in a single context window. You may not need a graph.

## Summary
- 1873 nodes · 2669 edges · 118 communities (99 shown, 19 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 67 edges (avg confidence: 0.86)
- Token cost: 408,743 input · 0 output

## Community Hubs (Navigation)
- Release & Update Docs
- Lessons & Student State
- Student Profile Feature
- Pubspec Dependencies
- macOS/iOS Runner
- Local Storage Layer
- Lesson Video Controls
- Auth Login Flow
- DI Service Locator
- Update Cubit Wiring
- CI Workflow
- QR Scan Feature
- Lesson Detail Screen
- Linux Runner
- Reports View UI
- Android MainActivity Bridge
- Update State Machine
- Bloc Cubits & Usecases
- Shared Stateless Widgets
- Update Test Fakes
- Mandatory Update View
- Release Remote Source
- Repository Interfaces
- APK Inspector
- Auth Repository Tests
- API Constants
- Lessons List Screen
- Win32 Window Impl
- Network Failures
- Update Restart Tests
- App Config
- Stateful Screens
- Reports Models
- Release Model
- Profile & QR Views
- Windows FlutterWindow
- Dartz Repositories
- Lesson Notes Repo
- Reports Data Layer
- App Colors
- APK Validation Service
- Release Workflow Env
- App Entry & QR Entry
- Lesson Detail Model
- Desktop CMake Builds
- Profile Repository Tests
- Win32Window Header
- Auth Repository
- Splash Screen
- QR Scan Repository
- Remote Data Sources
- Notes & Parser Tests
- JSON Parsers
- Update Flow Tests
- Dio Network Client
- Session Manager
- Lessons Data Layer
- Root Page Navigation
- Student Profile Model
- Windows Utils & Main
- App Router
- Route Names
- Text Styles
- In-Memory Token Storage
- QR Code Painter
- Notes Repo Impl
- Release Workflow Jobs
- Custom Text Field
- Font Weights
- Onboarding Pager
- Web Manifest
- Win32 Message Handling
- Native Splash Config
- Release Workflow Setup
- QR Scan Result View
- Auth Remote Source
- Error Dialog
- Info Section Card
- Onboarding Views
- Student Report Model
- Onboarding Study Illustration
- Onboarding Background
- Custom Button
- Windows Plugin Registrant
- Release Workflow Outputs
- API Response Model
- Lesson Model
- Add Note Dialog
- Onboarding Teacher Illustration
- Release Workflow Steps
- App Navigator Key
- App Fonts
- YouTube URL Parser
- Release & Update Tests
- Analysis Options
- Navigation Extensions
- MR App Icon
- Font Licenses
- Release Workflow Triggers
- Web Splash Bootstrap
- Number Formatter
- Login Request Model
- Arrows Line Art
- Spiral Line Art
- JSON Parser Tests
- Win32 Point Struct
- APK Inspector Fakes
- Update Comparator
- Path Provider Fakes
- Graphify Agent Rules
- Reports Feature Doc

## God Nodes (most connected - your core abstractions)
1. `UpdateCubit` - 24 edges
2. `_` - 21 edges
3. `Win32Window` - 21 edges
4. `dependencies` - 20 edges
5. `ScanQrCubit` - 18 edges
6. `UpdateState` - 17 edges
7. `env` - 16 edges
8. `ProfileCubit` - 13 edges
9. `Release workflow (.github/workflows/release.yml)` - 13 edges
10. `MainActivity` - 12 edges

## Surprising Connections (you probably didn't know these)
- `Web splash screen (light/dark picture)` --semantically_similar_to--> `Launch Screen Assets`  [INFERRED] [semantically similar]
  web/index.html → ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md
- `BINARY_NAME teacher (Windows)` --semantically_similar_to--> `BINARY_NAME teacher (Linux)`  [INFERRED] [semantically similar]
  windows/CMakeLists.txt → linux/CMakeLists.txt
- `flutter_assemble target (Windows)` --semantically_similar_to--> `flutter_assemble target (Linux)`  [INFERRED] [semantically similar]
  windows/flutter/CMakeLists.txt → linux/flutter/CMakeLists.txt
- `Release 4.0.11 (update cycle, session, notes isolation, bundled fonts, CI hardening)` --references--> `F10 Offline lesson notes (SQLite app.db)`  [INFERRED]
  CHANGELOG.md → docs/APP_FEATURE_REPORT.md
- `FakeAuthRemoteDataSource` --implements--> `AuthRemoteDataSource`  [EXTRACTED]
  test/auth_repository_test.dart → lib/features/auth/data/datasources/auth_remote_data_source.dart

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Signed APK release verification chain** — docs_ci_cd_release_quality_gate, docs_ci_cd_release_backend_pre_check, docs_ci_cd_release_apk_identity_signature_verification, docs_ci_cd_release_atomic_server_upload, docs_ci_cd_release_strict_download_verification [EXTRACTED 1.00]
- **Client update hardening against corrupt/bad releases** — docs_update_flow_pre_install_validation, docs_update_flow_atomic_download, docs_update_flow_availability_safeguard, docs_update_flow_optional_hardening_fields, docs_environment_releasedownloadurl [INFERRED 0.85]
- **Bad release recovery (no rollback risk -> runbook)** — docs_app_feature_report_no_rollback_for_mandatory_update, docs_ci_cd_report_no_rollback_kill_switch, docs_rollback_withdraw_backend_metadata, docs_rollback_forward_fix [INFERRED 0.85]
- **Linux Flutter desktop build pipeline** — linux_cmakelists_binary_name, linux_runner_cmakelists_runner_executable, linux_flutter_cmakelists_flutter_library, linux_flutter_cmakelists_flutter_assemble, linux_cmakelists_install_bundle [EXTRACTED 1.00]
- **Windows Flutter desktop build pipeline** — windows_cmakelists_binary_name, windows_runner_cmakelists_runner_executable, windows_flutter_cmakelists_flutter_library, windows_flutter_cmakelists_flutter_wrapper_app, windows_flutter_cmakelists_flutter_assemble, windows_cmakelists_install_in_place [EXTRACTED 1.00]
- **Web splash and bootstrap flow** — web_index_index_html, web_index_splash_screen, web_index_removesplashfromweb, web_index_flutter_bootstrap_js [INFERRED 0.85]
- **MR Brand Identity** — assets_app_icon_mr_monogram, assets_app_icon_apple_shape, assets_app_icon_red_orange_palette, assets_app_icon_est_2024 [INFERRED 0.85]
- **Classroom Teaching Scene** — assets_onboarding1_teacher, assets_onboarding1_chalkboard, assets_onboarding1_speech_bubble, assets_onboarding1_classroom_props [EXTRACTED 1.00]
- **Study Scene Composition** — assets_onboarding2_student_with_laptop, assets_onboarding2_student_writing_notes, assets_onboarding2_book_stack, assets_onboarding2_graduation_cap, assets_onboarding2_globe [INFERRED 0.85]

## Communities (118 total, 19 thin omitted)

### Community 0 - "Release & Update Docs"
Cohesion: 0.05
Nodes (56): Changelog (Keep a Changelog), Release 4.0.10 (Initial release), Release 4.0.11 (update cycle, session, notes isolation, bundled fonts, CI hardening), F11 Assistant QR scan + attendance registration, F3 Authentication (AuthCubit, token+role secure storage), Backend API surface (auth, student, assistant, app/releases), DioClient bearer-token interceptor + NetworkExceptions, Risk: no handling for expired/revoked tokens (global 401) (+48 more)

### Community 1 - "Lessons & Student State"
Cohesion: 0.05
Nodes (56): AutoAuthCubit, AutoAuthAuthenticated, AutoAuthInitial, AutoAuthLoading, AutoAuthState, AutoAuthUnauthenticated, props, role (+48 more)

### Community 2 - "Student Profile Feature"
Cohesion: 0.05
Nodes (38): content, createdAt, fromMap, id, lessonId, LessonNote, toMap, updatedAt (+30 more)

### Community 3 - "Pubspec Dependencies"
Cohesion: 0.04
Nodes (48): dependencies, ai_barcode_scanner, crypto, dartz, dio, equatable, flutter, flutter_bloc (+40 more)

### Community 4 - "macOS/iOS Runner"
Cohesion: 0.05
Nodes (21): Cocoa, file_selector_macos, Flutter, flutter_secure_storage_macos, FlutterMacOS, Foundation, AppDelegate, SceneDelegate (+13 more)

### Community 5 - "Local Storage Layer"
Cohesion: 0.04
Nodes (34): _completedKey, isCompleted, markCompleted, OnboardingStorage, clearSession, clearToken, getRole, getToken (+26 more)

### Community 6 - "Lesson Video Controls"
Cohesion: 0.04
Nodes (39): bufferedFraction, build, _buildControls, _commit, controller, _controlsVisible, createState, dispose (+31 more)

### Community 7 - "Auth Login Flow"
Cohesion: 0.06
Nodes (32): fromJson, LoginResponseModel, message, success, token, user, email, fromJson (+24 more)

### Community 9 - "Update Cubit Wiring"
Cohesion: 0.05
Nodes (25): _apkFileNameFor, _apkInspector, _apkInstaller, _attemptsBeforeEscapeHatch, canContinueOffline, checkForUpdate, _cleanupStaleApks, continueWithoutUpdate (+17 more)

### Community 10 - "CI Workflow"
Cohesion: 0.06
Nodes (35): name, needs, runs-on, steps, timeout-minutes, concurrency, cancel-in-progress, group (+27 more)

### Community 11 - "QR Scan Feature"
Cohesion: 0.08
Nodes (27): dob, fromJson, grade, guardianName, guardianPhone, id, name, phone (+19 more)

### Community 12 - "Lesson Detail Screen"
Cohesion: 0.06
Nodes (25): _controller, createState, didChangeAppLifecycleState, dispose, icon, index, initState, _isFullScreen (+17 more)

### Community 13 - "Linux Runner"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 14 - "Reports View UI"
Cohesion: 0.07
Nodes (23): _arabicMonths, attendance, _AttendanceRecordRow, _AttendanceRecordsList, _cardDecoration, child, _FinancialRecordRow, _FinancialRecordsList (+15 more)

### Community 16 - "Update State Machine"
Cohesion: 0.18
Nodes (23): UpdateCubit, apkPath, failure, message, props, receivedBytes, release, totalBytes (+15 more)

### Community 17 - "Bloc Cubits & Usecases"
Cohesion: 0.09
Nodes (12): _authRepository, call, CheckAuthStatus, checkAuthentication, _checkAuthStatus, _isChecking, LessonsRepositoryImpl, LessonsRepository (+4 more)

### Community 18 - "Shared Stateless Widgets"
Cohesion: 0.09
Nodes (22): _CustomAppBar, LessonHeaderInfo, LessonNavigationRow, _NavButton, _NoteCard, NotesTabContent, _ThumbnailPlaceholder, _VideoPlaybackError (+14 more)

### Community 19 - "Update Test Fakes"
Cohesion: 0.09
Nodes (20): canRequestPackageInstalls, downloadCount, downloadedUrls, downloadFails, downloadReleaseApk, fileUrl, fromJson, getInstalledApp (+12 more)

### Community 20 - "Mandatory Update View"
Cohesion: 0.09
Nodes (19): actionLabel, build, _buildBody, _Card, child, _FailureBody, icon, _iconFor (+11 more)

### Community 21 - "Release Remote Source"
Cohesion: 0.11
Nodes (13): _deleteSafely, dio, downloadReleaseApk, getLatestRelease, _isApk, ReleaseRemoteDataSource, ReleaseRemoteDataSourceImpl, downloadReleaseApk (+5 more)

### Community 22 - "Repository Interfaces"
Cohesion: 0.11
Nodes (13): getSavedUserRole, login, UpdateRepositoryImpl, downloadReleaseApk, getLatestRelease, UpdateRepository, call, DownloadReleaseApk (+5 more)

### Community 23 - "APK Inspector"
Cohesion: 0.10
Nodes (18): _asInt, canRequestPackageInstalls, _channel, deviceSdk, error, fromMap, getInstalledApp, inspect (+10 more)

### Community 24 - "Auth Repository Tests"
Cohesion: 0.10
Nodes (15): calls, error, fromJson, id, login, main, options, remote (+7 more)

### Community 25 - "API Constants"
Cohesion: 0.11
Nodes (15): ApiConstants, baseUrl, connectTimeout, latestRelease, latestReleaseDownload, latestReleaseDownloadUrl, lessons, login (+7 more)

### Community 26 - "Lessons List Screen"
Cohesion: 0.11
Nodes (16): _applySearch, createState, dispose, _HeaderWidget, lesson, LessonCardWidget, lessons, _LessonsContent (+8 more)

### Community 27 - "Win32 Window Impl"
Cohesion: 0.16
Nodes (8): EnableNonClientDpiScaling, Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, WindowClassRegistrar::GetWindowClass(), instance_, WindowClassRegistrar::UnregisterWindowClass()

### Community 28 - "Network Failures"
Cohesion: 0.15
Nodes (16): ApiException, AuthenticationFailure, Failure, handle, _handleStatusCode, InvalidCredentialsFailure, message, NetworkExceptions (+8 more)

### Community 29 - "Update Restart Tests"
Cohesion: 0.11
Nodes (13): ApkInstaller, FakeApkInstaller, cubit, getApplicationSupportPath, inspector, installer, main, repository (+5 more)

### Community 30 - "App Config"
Cohesion: 0.11
Nodes (16): allowInsecureHttp, _apiBaseUrlOverride, AppConfig, AppEnvironment, _downloadHostsRaw, _effectiveUri, environmentName, _environmentRaw (+8 more)

### Community 31 - "Stateful Screens"
Cohesion: 0.15
Nodes (16): ScanQrResultView, _ScanQrResultViewState, SplashScreen, _SplashScreenState, _LessonDetailBody, _LessonDetailBodyState, VideoPlayerWidget, _VideoPlayerWidgetState (+8 more)

### Community 32 - "Reports Models"
Cohesion: 0.11
Nodes (12): AttendanceReportModel, data, FinancialRecordModel, FinancialReportModel, fromJson, records, total, attendance (+4 more)

### Community 33 - "Release Model"
Cohesion: 0.11
Nodes (16): changelog, fileName, fileSize, fileUrl, fromJson, id, isAvailable, isMandatory (+8 more)

### Community 34 - "Profile & QR Views"
Cohesion: 0.12
Nodes (11): _avatarRadius, build, _headerHeight, _ProfileBody, _profileImageUrl, ProfileView, _avatarRadius, Gap12 (+3 more)

### Community 35 - "Windows FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 36 - "Dartz Repositories"
Cohesion: 0.13
Nodes (6): registerAttendance, scanStudent, getLessonDetail, getLessons, getReports, install

### Community 37 - "Lesson Notes Repo"
Cohesion: 0.12
Nodes (12): LessonNotesRepositoryImpl, addNote, deleteNote, getNotes, LessonNotesRepository, updateNote, addNote, deleteNote (+4 more)

### Community 38 - "Reports Data Layer"
Cohesion: 0.14
Nodes (10): dio, getReports, ReportsRemoteDataSource, ReportsRemoteDataSourceImpl, getReports, remoteDataSource, ReportsRepositoryImpl, ReportsRepository (+2 more)

### Community 39 - "App Colors"
Cohesion: 0.12
Nodes (14): AppColors, background, backgroundGradient, buttonGradient, cardBackground, grey, hintText, primary (+6 more)

### Community 40 - "APK Validation Service"
Cohesion: 0.12
Nodes (14): ApkInspection, _, ApkValidationResult, ApkValidationService, inspection, inspector, invalid, isValid (+6 more)

### Community 41 - "Release Workflow Env"
Cohesion: 0.12
Nodes (16): ANDROID_KEYSTORE_BASE64, APK_NAME, APK_SHA256, BACKEND_PASSWORD, BACKEND_USERNAME, HOST, KEY_ALIAS, KEY_PASSWORD (+8 more)

### Community 42 - "App Entry & QR Entry"
Cohesion: 0.13
Nodes (6): _ScanQrEntryBody, ScanQrEntryView, build, main, MyApp, setupServiceLocator

### Community 43 - "Lesson Detail Model"
Cohesion: 0.12
Nodes (15): aboutLesson, chapterName, createdAt, durationMinutes, fromJson, id, LessonDetailModel, nextLessonId (+7 more)

### Community 44 - "Desktop CMake Builds"
Cohesion: 0.18
Nodes (15): APPLICATION_ID com.example.teacher, APPLY_STANDARD_SETTINGS() (Linux), BINARY_NAME teacher (Linux), Linux relocatable install bundle, flutter_assemble target (Linux), flutter INTERFACE library (libflutter_linux_gtk.so), Linux runner executable (main.cc, my_application.cc), APPLY_STANDARD_SETTINGS() (Windows) (+7 more)

### Community 45 - "Profile Repository Tests"
Cohesion: 0.12
Nodes (11): calls, connectionError, error, getProfile, main, name, options, remote (+3 more)

### Community 46 - "Win32Window Header"
Cohesion: 0.15
Nodes (7): Size, height, width, Win32Window, child_content_, quit_on_close_, window_handle_

### Community 47 - "Auth Repository"
Cohesion: 0.14
Nodes (8): AuthRepositoryImpl, getSavedUserRole, login, remoteDataSource, tokenStorage, AuthRepository, _authRepository, login

### Community 48 - "Splash Screen"
Cohesion: 0.14
Nodes (9): _authResolved, build, createState, _isBlockingUpdateState, _proceedToNavigation, _SplashBody, _SplashBodyState, _targetRoute (+1 more)

### Community 49 - "QR Scan Repository"
Cohesion: 0.14
Nodes (9): registerAttendance, remoteDataSource, ScanQrRepositoryImpl, scanStudent, ScanQrRepository, registerAttendance, _repository, reset (+1 more)

### Community 50 - "Remote Data Sources"
Cohesion: 0.16
Nodes (10): dio, registerAttendance, ScanQrRemoteDataSource, ScanQrRemoteDataSourceImpl, scanStudent, dio, getProfile, ProfileRemoteDataSource (+2 more)

### Community 51 - "Notes & Parser Tests"
Cohesion: 0.13
Nodes (5): dbPath, main, repoFor, tempDir, main

### Community 52 - "JSON Parsers"
Cohesion: 0.13
Nodes (14): asBool, asBoolOr, asDouble, asDoubleOr, asInt, asIntOr, asMap, asMapList (+6 more)

### Community 53 - "Update Flow Tests"
Cohesion: 0.13
Nodes (13): cubit, getApplicationSupportPath, inspector, installer, main, repository, requireUpdateAndStart, supportDir (+5 more)

### Community 54 - "Dio Network Client"
Cohesion: 0.14
Nodes (9): dio, DioClient, _sessionManager, _tokenStorage, SessionManager, build, imageUrl, radius (+1 more)

### Community 55 - "Session Manager"
Cohesion: 0.16
Nodes (10): dispose, _events, expireSession, _expiring, hasSession, logout, SessionEnded, SessionEvent (+2 more)

### Community 56 - "Lessons Data Layer"
Cohesion: 0.18
Nodes (8): dio, getLessonDetail, getLessons, LessonsRemoteDataSource, LessonsRemoteDataSourceImpl, getLessonDetail, getLessons, remoteDataSource

### Community 57 - "Root Page Navigation"
Cohesion: 0.15
Nodes (10): build, controller, createState, currentScreen, initState, Root, _RootState, screenRoute (+2 more)

### Community 58 - "Student Profile Model"
Cohesion: 0.14
Nodes (13): dob, email, fromJson, grade, guardianName, guardianPhone, id, name (+5 more)

### Community 59 - "Windows Utils & Main"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 61 - "Route Names"
Cohesion: 0.15
Nodes (12): lessonDetail, loginScreen, onBoardingView, profileView, reportsView, root, root1, Routes (+4 more)

### Community 62 - "Text Styles"
Cohesion: 0.15
Nodes (8): font14BlueSemiBold, font24BlackBold, font24BlueBold, font32BlueBold, TextStyles, build, CustomButtonOnboard, text

### Community 63 - "In-Memory Token Storage"
Cohesion: 0.15
Nodes (11): clearSession, getRole, getToken, getUserId, hasToken, role, saveRole, saveToken (+3 more)

### Community 64 - "QR Code Painter"
Cohesion: 0.17
Nodes (9): backgroundColor, build, color, data, paint, _QrCodePainter, QrCodeWidget, shouldRepaint (+1 more)

### Community 65 - "Notes Repo Impl"
Cohesion: 0.17
Nodes (10): TokenStorage, NotesDatabase, addNote, _database, deleteNote, getNotes, _requireUserId, _tokenStorage (+2 more)

### Community 66 - "Release Workflow Jobs"
Cohesion: 0.17
Nodes (11): concurrency, cancel-in-progress, group, env, BACKEND_BASE_URL, FLUTTER_VERSION, SERVER_REMOTE_DIR, jobs (+3 more)

### Community 67 - "Custom Text Field"
Cohesion: 0.17
Nodes (8): build, controller, CustomTextField, hintText, keyboardType, obscureText, prefixIcon, suffixIcon

### Community 69 - "Font Weights"
Cohesion: 0.18
Nodes (9): bold, extraBold, extraLight, FontWeightHelper, light, medium, regular, semiBold (+1 more)

### Community 70 - "Onboarding Pager"
Cohesion: 0.18
Nodes (6): build, controller, createState, currentScreen, initState, screens

### Community 71 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 73 - "Native Splash Config"
Cohesion: 0.20
Nodes (9): color, color_dark, image, flutter_native_splash, android_12, color, color_dark, fullscreen (+1 more)

### Community 74 - "Release Workflow Setup"
Cohesion: 0.20
Nodes (10): with, cache, channel, distribution, flutter-version, if-no-files-found, java-version, name (+2 more)

### Community 75 - "QR Scan Result View"
Cohesion: 0.20
Nodes (7): _avatarRadius, build, createState, _headerHeight, _isRegistering, _profileImageUrl, _registerAttendance

### Community 76 - "Auth Remote Source"
Cohesion: 0.25
Nodes (5): AuthRemoteDataSource, AuthRemoteDataSourceImpl, dio, login, FakeAuthRemoteDataSource

### Community 77 - "Error Dialog"
Cohesion: 0.22
Nodes (6): AppErrorDialog, build, buttonText, message, show, title

### Community 78 - "Info Section Card"
Cohesion: 0.22
Nodes (8): build, _InfoRow, InfoRowData, InfoSectionCard, label, rows, title, value

### Community 79 - "Onboarding Views"
Cohesion: 0.28
Nodes (4): build, Onboard1View, build, Onboard2View

### Community 80 - "Student Report Model"
Cohesion: 0.22
Nodes (8): fromJson, grade, groupName, id, name, profileImage, studentCode, StudentReportModel

### Community 81 - "Onboarding Study Illustration"
Cohesion: 0.36
Nodes (8): Stack of Bookmarked Books, Education / Learning Theme, Globe, Graduation Cap, onboarding2.png (Onboarding Illustration 2), App Onboarding Flow, Student Using Laptop on Book Stack, Student Writing in Notebook

### Community 82 - "Onboarding Background"
Cohesion: 0.25
Nodes (5): backgroundColor, build, child, iconColor, OnboardingBackground

### Community 83 - "Custom Button"
Cohesion: 0.25
Nodes (5): build, CustomButton, isLoading, onPressed, text

### Community 85 - "Release Workflow Outputs"
Cohesion: 0.25
Nodes (8): release, apk_name, version_code, version_name, name, outputs, runs-on, timeout-minutes

### Community 86 - "API Response Model"
Cohesion: 0.25
Nodes (5): ApiResponse, data, fromJson, message, success

### Community 87 - "Lesson Model"
Cohesion: 0.25
Nodes (7): chapterName, durationMinutes, fromJson, id, LessonModel, thumbnailUrl, title

### Community 88 - "Add Note Dialog"
Cohesion: 0.25
Nodes (5): AddNoteDialog, build, controller, isEditing, onSaved

### Community 89 - "Onboarding Teacher Illustration"
Cohesion: 0.48
Nodes (7): Chalkboard with Equations (x+y=1, e=mc2), Classroom Props (globe, open book, desk, plant, wastebasket), Education / Learning Theme, onboarding1.png (Teacher at Chalkboard Illustration), App Onboarding Flow, Speech Bubble (ellipsis), Teacher Character

### Community 90 - "Release Workflow Steps"
Cohesion: 0.29
Nodes (7): steps, id, if, name, run, shell, uses

### Community 92 - "App Fonts"
Cohesion: 0.29
Nodes (5): AppFonts, cairo, cairoFamily, tajawal, tajawalFamily

### Community 93 - "YouTube URL Parser"
Cohesion: 0.29
Nodes (4): extractVideoId, _videoIdPattern, _youtubeHosts, YoutubeUrlParser

### Community 95 - "Analysis Options"
Cohesion: 0.33
Nodes (5): analyzer, exclude, include, linter, rules

### Community 96 - "Navigation Extensions"
Cohesion: 0.33
Nodes (4): NavigationContext, push, pushReplacement, pushUntil

### Community 97 - "MR App Icon"
Cohesion: 0.60
Nodes (5): App Icon (app_icon.png), Apple Silhouette Motif, est. 2024, MR Monogram, Red-Orange Gradient Palette

### Community 98 - "Font Licenses"
Cohesion: 0.40
Nodes (4): Cairo Font (The Cairo Project Authors, 2009), SIL Open Font License 1.1 (Cairo), SIL Open Font License 1.1 (Tajawal), Tajawal Font (Boutros International, 2018)

### Community 99 - "Release Workflow Triggers"
Cohesion: 0.40
Nodes (5): on, push, workflow_dispatch, branches, paths

### Community 100 - "Web Splash Bootstrap"
Cohesion: 0.40
Nodes (4): Launch Screen Assets, flutter_bootstrap.js loader, Web index.html (MR), Web splash screen (light/dark picture)

### Community 101 - "Number Formatter"
Cohesion: 0.40
Nodes (4): formatDynamic, formatNumber, _groupDigits, NumberFormatter

### Community 102 - "Login Request Model"
Cohesion: 0.40
Nodes (4): LoginRequestModel, password, toJson, username

### Community 104 - "Arrows Line Art"
Cohesion: 0.83
Nodes (4): Decorative Background Illustration, Diverging Arrows from Common Origin, item2.png (decorative line-art asset), Hand-drawn Wavy Curve / Path

### Community 105 - "Spiral Line Art"
Cohesion: 0.83
Nodes (4): Cartesian Coordinate System (x/y axes), item3.png (spiral on x-y axes illustration), Mathematics / Graphing Theme, Spiral Curve

### Community 107 - "Win32 Point Struct"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 108 - "APK Inspector Fakes"
Cohesion: 0.67
Nodes (3): ApkInspector, NativeApkInspector, FakeApkInspector

## Ambiguous Edges - Review These
- `Diverging Arrows from Common Origin` → `Decorative Background Illustration`  [AMBIGUOUS]
  assets/item2.png · relation: conceptually_related_to
- `Spiral Curve` → `Mathematics / Graphing Theme`  [AMBIGUOUS]
  assets/item3.png · relation: conceptually_related_to
- `Speech Bubble (ellipsis)` → `Education / Learning Theme`  [AMBIGUOUS]
  assets/onboarding1.png · relation: conceptually_related_to
- `Education / Learning Theme` → `Globe`  [AMBIGUOUS]
  assets/onboarding2.png · relation: conceptually_related_to

## Knowledge Gaps
- **770 isolated node(s):** `AppEnvironment`, `AppConfig`, `_environmentRaw`, `_apiBaseUrlOverride`, `_storageBaseUrlOverride` (+765 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1152 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **19 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TokenStorage` connect `Notes Repo Impl` to `Student Profile Feature`, `Local Storage Layer`, `DI Service Locator`, `App Entry & QR Entry`, `Auth Repository`, `Dio Network Client`, `Session Manager`?**
  _High betweenness centrality (0.033) - this node is a cross-community bridge._
- **What connects `AppEnvironment`, `AppConfig`, `_environmentRaw` to the rest of the system?**
  _770 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Release & Update Docs` be split into smaller, more focused modules?**
  _Cohesion score 0.05010351966873706 - nodes in this community are weakly interconnected._
- **Why does `UpdateCubit` connect `Update State Machine` to `Lessons & Student State`, `DI Service Locator`, `Update Cubit Wiring`, `Splash Screen`, `Mandatory Update View`, `Update Flow Tests`, `Update Restart Tests`?**
  _High betweenness centrality (0.020) - this node is a cross-community bridge._
- **Should `Lessons & Student State` be split into smaller, more focused modules?**
  _Cohesion score 0.05110809588421529 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Diverging Arrows from Common Origin` and `Decorative Background Illustration`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Spiral Curve` and `Mathematics / Graphing Theme`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._