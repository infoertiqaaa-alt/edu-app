# CI/CD Release Pipeline

This document describes the automated Android APK release pipeline for the **MR** Flutter app.

The pipeline lives entirely in GitHub Actions and is triggered automatically when the app version
and/or the changelog change on `main`. It builds a **signed release APK**, uploads it to the
production server over **SCP/SSH**, and publishes release metadata to the **Backend API**, then
verifies that the Backend is serving the new release before the workflow can succeed.

---

## 1. How versioning works

The single source of truth is **`pubspec.yaml`**:

```yaml
version: 2.1.0+2
```

- `2.1.0` → **version_name** (user-facing semantic version)
- `2` → **version_code** (Android build number / unique integer)

The pipeline extracts both automatically. You **never** hard-code a version in GitHub Actions.

The APK filename is generated deterministically:

```
app-v${version_name}.apk
```

Example: `version: 2.1.0+2` → `app-v2.1.0.apk`

---

## 2. How the pipeline works (stage by stage)

1. **Checkout** — clone the repo.
2. **Setup Java 17** — Java 17 is required by the project's Gradle/AGP config (see
   `android/app/build.gradle.kts` → `JavaVersion.VERSION_17`).
3. **Setup Flutter** — stable channel with caching.
4. **`flutter pub get`** — install dependencies.
5. **Read version** — parse `VERSION_NAME` and `VERSION_CODE` from `pubspec.yaml`; validates
   that the code is numeric and fails if the version line is malformed.
6. **Read changelog** — extract the `## VERSION_NAME` section from `CHANGELOG.md`; fails if the
   section is missing.
7. **Pre-check Backend** — calls `GET /app/releases/latest`; if the Backend already has a release
   with a `version_code >=` this build's, the workflow **fails** (prevents duplicates/overwrites).
8. **Build signed APK** — decodes the keystore from a GitHub Secret and runs
   `flutter build apk --release`.
9. **Rename APK** — copies to `app-v${version_name}.apk` and fails if the APK was not produced.
10. **Upload via SCP** — uploads the APK to the production server releases directory.
11. **Verify on server** — SSH `test -f` to confirm the file exists remotely.
12. **Publish release** — `POST /app/releases` (Bearer token) with `version_code`, `version_name`,
    `changelog`, and `file_name`; fails on any non-2xx response.
13. **Verify latest release** — `GET /app/releases/latest` and asserts the returned release matches
    what we just published (`version_code`, `version_name`, `file_name`); fails on mismatch.
14. **Download endpoint check (optional)** — a lightweight `HEAD` against the download endpoint.

Any failed step aborts the workflow so a partial release is never reported as successful.

---

## 3. How to create a release

A release is created by updating **two** files and pushing to `main`:

### Step 1 — Bump the version in `pubspec.yaml`

```yaml
version: 2.1.0+2
```

`version_code` (`2`) must be **higher** than the previous release's code. The Backend enforces
this and the pipeline also pre-checks it.

### Step 2 — Add release notes to `CHANGELOG.md`

Add a new `## 2.1.0` section at the top of the list, matching the `version_name` exactly:

```markdown
## 2.1.0

* Added new lessons
* Fixed video playback issue
* Improved application performance
```

> The `## 2.1.0` header MUST exactly match `version_name`. If it doesn't, the workflow fails and
> nothing is published.

### Step 3 — Commit and push

```bash
git add pubspec.yaml CHANGELOG.md
git commit -m "Release 2.1.0"
git push origin main
```

That's it. GitHub Actions runs the pipeline automatically.

---

## 4. Triggering the pipeline

- **On push to `main`** — only when `pubspec.yaml` **or** `CHANGELOG.md` changed (path filter).
- **Manually** — via the GitHub web UI: **Actions → "Release Android APK" → Run workflow**
  (`workflow_dispatch`).

---

## 5. Required GitHub Secrets

Create these under **GitHub → Settings → Secrets and variables → Actions → Secrets**.
Never commit any of these values.

| Secret name | Purpose |
|---|---|
| `SERVER_HOST` | Production server hostname/IP (e.g. `mr-edu.ertiqaa.site`) |
| `SERVER_USER` | SSH user (e.g. `deploy`) |
| `SERVER_SSH_KEY` | SSH **private key** (PEM) allowed to SCP/SSH into the server |
| `BACKEND_API_TOKEN` | Bearer token for `POST /app/releases` |
| `ANDROID_KEYSTORE_BASE64` | Your release keystore (`.jks`) encoded as **base64** |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Signing key alias |
| `KEY_PASSWORD` | Key password |

Optional **GitHub Variable** (Settings → Variables):

| Variable name | Purpose | Default |
|---|---|---|
| `SERVER_PORT` | Custom SSH port | `22` |

---

## 6. Generating the signing keystore (once)

If you don't already have a release keystore, create one locally:

```bash
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 -validity 10000
```

Then encode it as base64 and store it in the `ANDROID_KEYSTORE_BASE64` secret:

**Windows (PowerShell):**

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("$PWD\upload-keystore.jks"))
```

**macOS / Linux:**

```bash
base64 -i upload-keystore.jks
```

Paste the output into the `ANDROID_KEYSTORE_BASE64` secret value (do **not** commit the `.jks`).

> **Important:** `android/upload-keystore.jks`, `android/keystore.properties`, and any `*.jks`
> files are **git-ignored**. The CI job recreates them from secrets at build time and they are
> never committed.

---

## 7. Server APK location

The APK is uploaded to:

```
/var/www/educational_platforms/mr-edu.ertiqaa.site/storage/app/public/releases/app-v<VERSION_NAME>.apk
```

The public download path is:

```
https://mr-edu.ertiqaa.site/storage/releases/app-v<VERSION_NAME>.apk
```

---

## 8. Backend endpoints used

| Method | Endpoint | Auth | Used by |
|---|---|---|---|
| `GET` | `/api/v1/app/releases/latest` | None | Pipeline (pre-check + verification) & Flutter client |
| `POST` | `/api/v1/app/releases` | Bearer | Pipeline (publish) |
| `GET` | `/api/v1/app/releases/latest/download` | None | Flutter client |

Base URL: `https://mr-edu.ertiqaa.site/api/v1`

---

## 9. Troubleshooting failures

| Symptom | Likely cause |
|---|---|
| `No changelog section found for version` | `CHANGELOG.md` is missing a `## <version_name>` header exactly matching `pubspec.yaml` |
| `version_code ... is not a positive integer` | `pubspec.yaml` version is malformed (e.g. no `+code`) |
| `Backend already has version_code ... >= this build` | Version was not bumped; increment `version_code` |
| `Missing one or more signing secrets` | `ANDROID_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` not set |
| `Decoded keystore file is empty` | `ANDROID_KEYSTORE_BASE64` is not a valid base64 keystore |
| `Release APK was not generated` | Build failed / plugin incompatibility; check build logs |
| `Missing SSH secrets` | `SERVER_SSH_KEY`, `SERVER_HOST`, `SERVER_USER` not set |
| `Uploaded APK not found on server` | SCP target path wrong or server user lacks write permission to `storage/app/public/releases` |
| `Backend rejected the release publish` | Token invalid/expired, or `version_code` not unique / not increasing |
| `version_name/version_code/file_name mismatch` | Backend didn't register what we sent; inspect the returned body |

Check the Actions log tab of the failed run for `::error::` lines, which point to the exact step.

---

## 10. How the Flutter client detects updates

The client-side update feature (separate from CI/CD publishing) is **architected but not yet
fully implemented**. The client responsibilities are:

1. Call `GET /api/v1/app/releases/latest` (no auth).
2. Read the installed app version code (e.g. with `package_info_plus`).
3. Compare: `installedVersionCode < latestVersionCode` → update available.
4. Show an update UI; on "Update", download from
   `GET /api/v1/app/releases/latest/download`, show progress, save locally, and launch the
   Android package installer.

The relevant endpoint constants already exist in `lib/core/constants/api_constants.dart`:

```dart
static const String latestRelease = '/app/releases/latest';
static const String latestReleaseDownload = '/app/releases/latest/download';
```

The recommended flow uses `package_info_plus` (for the installed version) plus a
Flutter-friendly download + install package (e.g. `open_filex`). Do **not** use raw shell
`pm install` commands to install the APK; use a proper Android-compatible mechanism.

---

## Security notes

- No secrets are stored in the repository or workflow files.
- The keystore, passwords, SSH key, and Backend token are all referenced via
  `${{ secrets.* }}` / `${{ vars.* }}`.
- The keystore is decoded inside the CI runner and deleted at the end of the job (runner is
  ephemeral).
- The SSH private key is written to a temporary file with `chmod 600` and removed after use;
  it is never printed.
