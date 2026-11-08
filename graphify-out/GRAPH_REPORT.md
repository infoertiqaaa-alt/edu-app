# Graph Report - MR  (2026-11-07)

## Corpus Check
- 168 files · ~48,373 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 69 file(s) not represented in the graph (top: .ttf 12, .xml 11, (none) 9)

## Summary
- 1890 nodes · 2713 edges · 128 communities (111 shown, 17 thin omitted)
- Extraction: 97% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 67 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Release & Update Docs
- reports_state.dart
- profile_repository_impl.dart
- Pubspec Dependencies
- macOS/iOS Runner
- Local Storage Layer
- Lesson Video Controls
- user_model.dart
- DI Service Locator
- Update Cubit Wiring
- CI Workflow
- scanned_student_model.dart
- Lesson Detail Screen
- Linux Runner
- Reports View UI
- Android MainActivity Bridge
- update_flow_test.dart
- Bloc Cubits & Usecases
- login_screen.dart
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
- lesson_notes_state.dart
- App Config
- Stateful Screens
- Reports Models
- Release Model
- Profile & QR Views
- Windows FlutterWindow
- lessons_repository.dart
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
- auth_cubit.dart
- Splash Screen
- QR Scan Repository
- Remote Data Sources
- network_layer_test.dart
- JSON Parsers
- scan_qr_camera_view.dart
- Dio Network Client
- Session Manager
- Lessons Data Layer
- Root Page Navigation
- Student Profile Model
- Windows Utils & Main
- App Router
- Route Names
- lesson_note_model.dart
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
- package:flutter/material.dart
- Student Report Model
- Onboarding Study Illustration
- ScanQrCubit
- Custom Button
- Windows Plugin Registrant
- Release Workflow Outputs
- API Response Model
- Lesson Model
- auth_state.dart
- Onboarding Teacher Illustration
- Release Workflow Steps
- List
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
- lesson_detail_state.dart
- Win32 Point Struct
- APK Inspector Fakes
- Update Comparator
- lessons_state.dart
- Graphify Agent Rules
- Reports Feature Doc
- profile_state.dart
- profile_repository.dart
- profile_cubit.dart
- scan_qr_entry_view.dart
- financial_report_model.dart
- AuthRepository
- attendance_report_model.dart
- auto_auth_cubit.dart
- string
- Size

## God Nodes (most connected - your core abstractions)
1. `UpdateCubit` - 24 edges
2. `_` - 22 edges
3. `Win32Window` - 21 edges
4. `dependencies` - 20 edges
5. `ScanQrCubit` - 18 edges
6. `env` - 17 edges
7. `UpdateState` - 17 edges
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
- **Classroom Teaching Scene** — assets_onboarding1_teacher, assets_onboarding1_chalkboard, assets_onboarding1_speech_bubble, assets_onboarding1_classroom_props [EXTRACTED 1.00]
- **Linux Flutter desktop build pipeline** — linux_cmakelists_binary_name, linux_runner_cmakelists_runner_executable, linux_flutter_cmakelists_flutter_library, linux_flutter_cmakelists_flutter_assemble, linux_cmakelists_install_bundle [EXTRACTED 1.00]
- **Windows Flutter desktop build pipeline** — windows_cmakelists_binary_name, windows_runner_cmakelists_runner_executable, windows_flutter_cmakelists_flutter_library, windows_flutter_cmakelists_flutter_wrapper_app, windows_flutter_cmakelists_flutter_assemble, windows_cmakelists_install_in_place [EXTRACTED 1.00]
- **MR Brand Identity** — assets_app_icon_mr_monogram, assets_app_icon_apple_shape, assets_app_icon_red_orange_palette, assets_app_icon_est_2024 [INFERRED 0.85]
- **Study Scene Composition** — assets_onboarding2_student_with_laptop, assets_onboarding2_student_writing_notes, assets_onboarding2_book_stack, assets_onboarding2_graduation_cap, assets_onboarding2_globe [INFERRED 0.85]
- **Bad release recovery (no rollback risk -> runbook)** — docs_app_feature_report_no_rollback_for_mandatory_update, docs_ci_cd_report_no_rollback_kill_switch, docs_rollback_withdraw_backend_metadata, docs_rollback_forward_fix [INFERRED 0.85]
- **Client update hardening against corrupt/bad releases** — docs_update_flow_pre_install_validation, docs_update_flow_atomic_download, docs_update_flow_availability_safeguard, docs_update_flow_optional_hardening_fields, docs_environment_releasedownloadurl [INFERRED 0.85]
- **Web splash and bootstrap flow** — web_index_index_html, web_index_splash_screen, web_index_removesplashfromweb, web_index_flutter_bootstrap_js [INFERRED 0.85]

## Communities (128 total, 17 thin omitted)

### Community 0 - "Release & Update Docs"
Cohesion: 0.05
Nodes (56): Changelog (Keep a Changelog), Release 4.0.10 (Initial release), Release 4.0.11 (update cycle, session, notes isolation, bundled fonts, CI hardening), F11 Assistant QR scan + attendance registration, F3 Authentication (AuthCubit, token+role secure storage), Backend API surface (auth, student, assistant, app/releases), DioClient bearer-token interceptor + NetworkExceptions, Risk: no handling for expired/revoked tokens (global 401) (+48 more)

### Community 1 - "reports_state.dart"
Cohesion: 0.20
Nodes (11): ReportsCubit, message, props, reports, ReportsError, ReportsInitial, ReportsLoaded, ReportsLoading (+3 more)

### Community 2 - "profile_repository_impl.dart"
Cohesion: 0.18
Nodes (9): _cachedAt, _cachedProfile, _cachedUserId, _cacheTtl, clearCache, getProfile, _isCacheFresh, remoteDataSource (+1 more)

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

### Community 7 - "user_model.dart"
Cohesion: 0.12
Nodes (14): fromJson, LoginResponseModel, message, success, token, user, email, fromJson (+6 more)

### Community 9 - "Update Cubit Wiring"
Cohesion: 0.05
Nodes (25): _apkFileNameFor, _apkInspector, _apkInstaller, _attemptsBeforeEscapeHatch, canContinueOffline, checkForUpdate, _cleanupStaleApks, continueWithoutUpdate (+17 more)

### Community 10 - "CI Workflow"
Cohesion: 0.06
Nodes (35): name, needs, runs-on, steps, timeout-minutes, concurrency, cancel-in-progress, group (+27 more)

### Community 11 - "scanned_student_model.dart"
Cohesion: 0.17
Nodes (11): dob, fromJson, grade, guardianName, guardianPhone, id, name, phone (+3 more)

### Community 12 - "Lesson Detail Screen"
Cohesion: 0.06
Nodes (25): _controller, createState, didChangeAppLifecycleState, dispose, icon, index, initState, _isFullScreen (+17 more)

### Community 13 - "Linux Runner"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 14 - "Reports View UI"
Cohesion: 0.05
Nodes (45): _CustomAppBar, LessonDetailScreen, LessonHeaderInfo, LessonTabSection, _NavButton, _NoteCard, NotesTabContent, _ThumbnailPlaceholder (+37 more)

### Community 16 - "update_flow_test.dart"
Cohesion: 0.06
Nodes (51): ApkInstaller, UpdateCubit, apkPath, failure, message, props, receivedBytes, release (+43 more)

### Community 17 - "Bloc Cubits & Usecases"
Cohesion: 0.20
Nodes (6): LessonsRepositoryImpl, LessonsRepository, getLessonDetail, _lessonsRepository, getLessons, _lessonsRepository

### Community 18 - "login_screen.dart"
Cohesion: 0.14
Nodes (9): build, createState, dispose, LoginScreen, _LoginView, _LoginViewState, _obscurePassword, _passwordController (+1 more)

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
Cohesion: 0.10
Nodes (14): getSavedUserRole, login, getReports, UpdateRepositoryImpl, downloadReleaseApk, getLatestRelease, UpdateRepository, call (+6 more)

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
Cohesion: 0.07
Nodes (23): build, _applySearch, build, createState, dispose, _HeaderWidget, lesson, LessonCardWidget (+15 more)

### Community 27 - "Win32 Window Impl"
Cohesion: 0.16
Nodes (8): EnableNonClientDpiScaling, Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, WindowClassRegistrar::GetWindowClass(), instance_, WindowClassRegistrar::UnregisterWindowClass()

### Community 28 - "Network Failures"
Cohesion: 0.15
Nodes (16): ApiException, AuthenticationFailure, Failure, handle, _handleStatusCode, InvalidCredentialsFailure, message, NetworkExceptions (+8 more)

### Community 29 - "lesson_notes_state.dart"
Cohesion: 0.27
Nodes (11): LessonNotesCubit, LessonNotesError, LessonNotesInitial, LessonNotesLoaded, LessonNotesLoading, LessonNotesState, message, notes (+3 more)

### Community 30 - "App Config"
Cohesion: 0.11
Nodes (16): allowInsecureHttp, _apiBaseUrlOverride, AppConfig, AppEnvironment, _downloadHostsRaw, _effectiveUri, environmentName, _environmentRaw (+8 more)

### Community 31 - "Stateful Screens"
Cohesion: 0.18
Nodes (12): SplashScreen, _SplashScreenState, _LessonDetailBody, _LessonDetailBodyState, VideoPlayerWidget, _VideoPlayerWidgetState, _LessonsListBody, _LessonsListBodyState (+4 more)

### Community 32 - "Reports Models"
Cohesion: 0.20
Nodes (6): AttendanceReportModel, attendance, financials, fromJson, ReportsModel, student

### Community 33 - "Release Model"
Cohesion: 0.11
Nodes (16): changelog, fileName, fileSize, fileUrl, fromJson, id, isAvailable, isMandatory (+8 more)

### Community 34 - "Profile & QR Views"
Cohesion: 0.13
Nodes (13): ProfileCubit, _avatarRadius, build, _headerHeight, _ProfileBody, _profileImageUrl, ProfileView, _avatarRadius (+5 more)

### Community 35 - "Windows FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 37 - "Lesson Notes Repo"
Cohesion: 0.22
Nodes (6): addNote, deleteNote, loadNotes, _messageFor, _repository, updateNote

### Community 38 - "Reports Data Layer"
Cohesion: 0.18
Nodes (6): getReports, remoteDataSource, ReportsRepositoryImpl, ReportsRepository, getReports, _reportsRepository

### Community 39 - "App Colors"
Cohesion: 0.12
Nodes (14): AppColors, background, backgroundGradient, buttonGradient, cardBackground, grey, hintText, primary (+6 more)

### Community 40 - "APK Validation Service"
Cohesion: 0.12
Nodes (14): ApkInspection, _, ApkValidationResult, ApkValidationService, inspection, inspector, invalid, isValid (+6 more)

### Community 41 - "Release Workflow Env"
Cohesion: 0.12
Nodes (17): ANDROID_KEYSTORE_BASE64, APK_NAME, APK_SHA256, BACKEND_PASSWORD, BACKEND_USERNAME, HOST, KEY_ALIAS, KEY_PASSWORD (+9 more)

### Community 42 - "App Entry & QR Entry"
Cohesion: 0.20
Nodes (4): build, main, MyApp, setupServiceLocator

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
Cohesion: 0.21
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 48 - "Splash Screen"
Cohesion: 0.14
Nodes (9): _authResolved, build, createState, _isBlockingUpdateState, _proceedToNavigation, _SplashBody, _SplashBodyState, _targetRoute (+1 more)

### Community 49 - "QR Scan Repository"
Cohesion: 0.10
Nodes (12): registerAttendance, remoteDataSource, ScanQrRepositoryImpl, scanStudent, registerAttendance, ScanQrRepository, scanStudent, registerAttendance (+4 more)

### Community 50 - "Remote Data Sources"
Cohesion: 0.13
Nodes (14): dio, registerAttendance, ScanQrRemoteDataSource, ScanQrRemoteDataSourceImpl, scanStudent, dio, getProfile, ProfileRemoteDataSource (+6 more)

### Community 51 - "network_layer_test.dart"
Cohesion: 0.09
Nodes (11): dbPath, main, repoFor, tempDir, _capture, close, fetch, main (+3 more)

### Community 52 - "JSON Parsers"
Cohesion: 0.13
Nodes (14): asBool, asBoolOr, asDouble, asDoubleOr, asInt, asIntOr, asMap, asMapList (+6 more)

### Community 53 - "scan_qr_camera_view.dart"
Cohesion: 0.20
Nodes (6): build, createState, _isProcessing, _onDetect, ScanQrCameraView, _ScanQrCameraViewState

### Community 54 - "Dio Network Client"
Cohesion: 0.18
Nodes (7): dio, DioClient, _sessionManager, _tokenStorage, SessionManager, TokenStorage, InMemoryTokenStorage

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
Cohesion: 0.17
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 61 - "Route Names"
Cohesion: 0.15
Nodes (12): lessonDetail, loginScreen, onBoardingView, profileView, reportsView, root, root1, Routes (+4 more)

### Community 62 - "lesson_note_model.dart"
Cohesion: 0.20
Nodes (8): content, createdAt, fromMap, id, lessonId, LessonNote, toMap, updatedAt

### Community 63 - "In-Memory Token Storage"
Cohesion: 0.15
Nodes (11): clearSession, getRole, getToken, getUserId, hasToken, role, saveRole, saveToken (+3 more)

### Community 64 - "QR Code Painter"
Cohesion: 0.17
Nodes (9): backgroundColor, build, color, data, paint, _QrCodePainter, QrCodeWidget, shouldRepaint (+1 more)

### Community 65 - "Notes Repo Impl"
Cohesion: 0.12
Nodes (14): NotesDatabase, addNote, _database, deleteNote, getNotes, LessonNotesRepositoryImpl, _requireUserId, _tokenStorage (+6 more)

### Community 66 - "Release Workflow Jobs"
Cohesion: 0.17
Nodes (11): concurrency, cancel-in-progress, group, env, BACKEND_BASE_URL, FLUTTER_VERSION, SERVER_REMOTE_DIR, jobs (+3 more)

### Community 67 - "Custom Text Field"
Cohesion: 0.11
Nodes (13): build, controller, CustomTextField, hintText, keyboardType, obscureText, prefixIcon, suffixIcon (+5 more)

### Community 69 - "Font Weights"
Cohesion: 0.18
Nodes (9): bold, extraBold, extraLight, FontWeightHelper, light, medium, regular, semiBold (+1 more)

### Community 70 - "Onboarding Pager"
Cohesion: 0.17
Nodes (8): build, controller, createState, currentScreen, initState, Onboard, _RootState, screens

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
Cohesion: 0.18
Nodes (9): _avatarRadius, build, createState, _headerHeight, _isRegistering, _profileImageUrl, _registerAttendance, ScanQrResultView (+1 more)

### Community 76 - "Auth Remote Source"
Cohesion: 0.13
Nodes (9): AuthRemoteDataSource, AuthRemoteDataSourceImpl, dio, login, getSavedUserRole, login, remoteDataSource, tokenStorage (+1 more)

### Community 77 - "Error Dialog"
Cohesion: 0.22
Nodes (6): AppErrorDialog, build, buttonText, message, show, title

### Community 78 - "Info Section Card"
Cohesion: 0.14
Nodes (11): build, _InfoRow, InfoRowData, InfoSectionCard, label, rows, title, value (+3 more)

### Community 79 - "package:flutter/material.dart"
Cohesion: 0.10
Nodes (11): appNavigatorKey, font14BlueSemiBold, font24BlackBold, font24BlueBold, font32BlueBold, TextStyles, build, Onboard1View (+3 more)

### Community 80 - "Student Report Model"
Cohesion: 0.22
Nodes (8): fromJson, grade, groupName, id, name, profileImage, studentCode, StudentReportModel

### Community 81 - "Onboarding Study Illustration"
Cohesion: 0.36
Nodes (8): Stack of Bookmarked Books, Education / Learning Theme, Globe, Graduation Cap, onboarding2.png (Onboarding Illustration 2), App Onboarding Flow, Student Using Laptop on Book Stack, Student Writing in Notebook

### Community 82 - "ScanQrCubit"
Cohesion: 0.38
Nodes (9): ScanQrCubit, message, props, ScanQrError, ScanQrInitial, ScanQrLoading, ScanQrState, ScanQrSuccess (+1 more)

### Community 83 - "Custom Button"
Cohesion: 0.25
Nodes (5): build, CustomButton, isLoading, onPressed, text

### Community 85 - "Release Workflow Outputs"
Cohesion: 0.20
Nodes (10): release, apk_name, version_code, version_name, environment, if, name, outputs (+2 more)

### Community 86 - "API Response Model"
Cohesion: 0.22
Nodes (5): ApiResponse, data, fromJson, message, success

### Community 87 - "Lesson Model"
Cohesion: 0.17
Nodes (8): chapterName, durationMinutes, fromJson, id, LessonModel, thumbnailUrl, title, main

### Community 88 - "auth_state.dart"
Cohesion: 0.36
Nodes (9): AuthCubit, AuthError, AuthInitial, AuthLoading, AuthState, AuthSuccess, message, props (+1 more)

### Community 89 - "Onboarding Teacher Illustration"
Cohesion: 0.48
Nodes (7): Chalkboard with Equations (x+y=1, e=mc2), Classroom Props (globe, open book, desk, plant, wastebasket), Education / Learning Theme, onboarding1.png (Teacher at Chalkboard Illustration), App Onboarding Flow, Speech Bubble (ellipsis), Teacher Character

### Community 90 - "Release Workflow Steps"
Cohesion: 0.29
Nodes (7): steps, id, if, name, run, shell, uses

### Community 91 - "List"
Cohesion: 0.36
Nodes (8): AutoAuthCubit, AutoAuthAuthenticated, AutoAuthInitial, AutoAuthLoading, AutoAuthState, AutoAuthUnauthenticated, props, role

### Community 92 - "App Fonts"
Cohesion: 0.29
Nodes (5): AppFonts, cairo, cairoFamily, tajawal, tajawalFamily

### Community 93 - "YouTube URL Parser"
Cohesion: 0.29
Nodes (4): extractVideoId, _videoIdPattern, _youtubeHosts, YoutubeUrlParser

### Community 94 - "Release & Update Tests"
Cohesion: 0.20
Nodes (3): main, main, main

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

### Community 106 - "lesson_detail_state.dart"
Cohesion: 0.36
Nodes (9): LessonDetailCubit, lesson, LessonDetailError, LessonDetailInitial, LessonDetailLoaded, LessonDetailLoading, LessonDetailState, message (+1 more)

### Community 107 - "Win32 Point Struct"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 108 - "APK Inspector Fakes"
Cohesion: 0.67
Nodes (3): ApkInspector, NativeApkInspector, FakeApkInspector

### Community 110 - "lessons_state.dart"
Cohesion: 0.36
Nodes (9): LessonsCubit, lessons, LessonsError, LessonsInitial, LessonsLoaded, LessonsLoading, LessonsState, message (+1 more)

### Community 118 - "profile_state.dart"
Cohesion: 0.29
Nodes (9): isStale, message, profile, ProfileError, ProfileInitial, ProfileLoaded, ProfileLoading, ProfileState (+1 more)

### Community 119 - "profile_repository.dart"
Cohesion: 0.25
Nodes (5): ProfileRepositoryImpl, cachedProfile, clearCache, getProfile, ProfileRepository

### Community 120 - "profile_cubit.dart"
Cohesion: 0.25
Nodes (5): StudentProfileModel, getProfile, _isLoading, _lastLoaded, _profileRepository

### Community 121 - "scan_qr_entry_view.dart"
Cohesion: 0.25
Nodes (3): build, _ScanQrEntryBody, ScanQrEntryView

### Community 122 - "financial_report_model.dart"
Cohesion: 0.25
Nodes (6): data, FinancialRecordModel, FinancialReportModel, fromJson, records, total

### Community 123 - "AuthRepository"
Cohesion: 0.29
Nodes (5): AuthRepositoryImpl, AuthRepository, _authRepository, call, CheckAuthStatus

### Community 124 - "attendance_report_model.dart"
Cohesion: 0.29
Nodes (6): AttendanceRecordModel, date, fromJson, id, records, total

### Community 125 - "auto_auth_cubit.dart"
Cohesion: 0.33
Nodes (3): checkAuthentication, _checkAuthStatus, _isChecking

### Community 126 - "string"
Cohesion: 0.33
Nodes (4): build, imageUrl, radius, StudentAvatar

### Community 127 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

## Ambiguous Edges - Review These
- `Decorative Background Illustration` → `Diverging Arrows from Common Origin`  [AMBIGUOUS]
  assets/item2.png · relation: conceptually_related_to
- `Mathematics / Graphing Theme` → `Spiral Curve`  [AMBIGUOUS]
  assets/item3.png · relation: conceptually_related_to
- `Education / Learning Theme` → `Globe`  [AMBIGUOUS]
  assets/onboarding2.png · relation: conceptually_related_to
- `Education / Learning Theme` → `Speech Bubble (ellipsis)`  [AMBIGUOUS]
  assets/onboarding1.png · relation: conceptually_related_to

## Knowledge Gaps
- **776 isolated node(s):** `AppEnvironment`, `AppConfig`, `_environmentRaw`, `_apiBaseUrlOverride`, `_storageBaseUrlOverride` (+771 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1165 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **17 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TokenStorage` connect `Dio Network Client` to `Notes Repo Impl`, `profile_repository_impl.dart`, `Local Storage Layer`, `DI Service Locator`, `Auth Remote Source`, `Session Manager`, `scan_qr_entry_view.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `AppEnvironment`, `AppConfig`, `_environmentRaw` to the rest of the system?**
  _776 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Release & Update Docs` be split into smaller, more focused modules?**
  _Cohesion score 0.05010351966873706 - nodes in this community are weakly interconnected._
- **Why does `Win32Window` connect `Win32Window Header` to `Windows FlutterWindow`, `Windows Runner Includes`, `Win32 Message Handling`, `Win32 Point Struct`, `Win32 Window Impl`, `Size`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Should `Pubspec Dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.04081632653061224 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Decorative Background Illustration` and `Diverging Arrows from Common Origin`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._
- **What is the exact relationship between `Mathematics / Graphing Theme` and `Spiral Curve`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._