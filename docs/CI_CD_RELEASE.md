# CI/CD release pipeline

This repository uses two GitHub Actions workflows:

| Workflow | File | Trigger | Purpose |
| --- | --- | --- | --- |
| CI | `.github/workflows/ci.yml` | every pull request, pushes to `main`, manual | Formatting, analysis, tests and a Debug APK build |
| Release | `.github/workflows/release.yml` | push to `main` changing `pubspec.yaml` or `CHANGELOG.md`, manual | Build, verify, upload and publish a signed release APK |

Both workflows use least-privilege permissions (`contents: read`) and pinned
tool versions:

- Flutter `3.47.9`
- Java 17 (Temurin)
- GitHub Actions pinned to commit SHAs

## Versioning

`pubspec.yaml` is the single source of truth:

```yaml
version: 4.0.11+11
```

- `4.0.11` → `versionName`
- `11` → `versionCode` (must always increase; never reuse or decrease)

The same version must have a matching section in `CHANGELOG.md`:

```markdown
## 4.0.11

* ...
```

The pipeline extracts the `## <version_name>` section and sends it to the
backend as the release changelog. A missing section fails the release.

## Required repository secrets

| Secret | Used for |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | Base64 of the production signing keystore |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Signing key alias |
| `KEY_PASSWORD` | Signing key password |
| `SERVER_SSH_KEY` | Private SSH key for the release server |
| `SERVER_HOST` | Release server hostname |
| `SERVER_USER` | SSH user |
| `SERVER_KNOWN_HOSTS` | **Required.** Pinned SSH host keys for the server |
| `BACKEND_USERNAME` | Backend account allowed to publish releases |
| `BACKEND_PASSWORD` | Backend account password |

Optional repository variables:

| Variable | Default | Purpose |
| --- | --- | --- |
| `SERVER_PORT` | `22` | SSH port |
| `PUBLISH_INTEGRITY_FIELDS` | unset | Set to `true` **only after** the backend accepts and stores `sha256` and `file_size` on `POST /app/releases`. The pipeline then sends both, computed from the exact uploaded APK, and the client enforces them. |

## Governance (GitHub settings that must be configured)

The workflow files enforce what they can; the rest is repository
configuration that only an admin can set:

1. **Release source**: the release job runs only when `github.ref` is
   `refs/heads/main`. A manual dispatch from another branch is skipped.
2. **Production environment**: the job declares `environment: production`.
   In *Settings → Environments → production* add **required reviewers** and
   restrict deployment branches to `main`. The job (and every secret) then
   waits for an explicit approval. Move the release secrets listed above into
   this environment so no other workflow can read them.
3. **Branch protection on `main`**: require a pull request, require the CI
   checks `Format, analyze and test` and `Debug APK build` to pass, and block
   force pushes. Without this a direct push to `main` that touches
   `pubspec.yaml` starts a release.
4. **Concurrency**: one release per ref at a time; a running release is never
   cancelled (`cancel-in-progress: false`).

## Application identity

The Android `applicationId` is `com.example.teacher`. It looks like a template
placeholder, but it **is the production identity**: every APK distributed so
far (verified: `version_code` 10, signed by `CN=kamal taha, O=MR Education`,
certificate SHA-256 `626da476…30e0`) and the Firebase Android client in
`android/app/google-services.json` use it. The iOS bundle id
(`com.ertiqaa.mr`) is independent.

Changing it creates a *different* Android app: installed users would not
receive updates (the in-app updater rejects the package id), and Firebase
would need a new Android client. Only change it with an explicit migration
plan (new Firebase client, a final release of the old id that tells users to
install the new app, and data migration for local notes).

> `SERVER_KNOWN_HOSTS` is mandatory. The workflow never disables host-key
> verification (`StrictHostKeyChecking=no` is not used). Generate it with:
>
> ```bash
> ssh-keyscan -p 22 release.example.com > known_hosts
> ```
>
> Review the fingerprint through an independent trusted channel before storing
> it.

## Release stages

1. **Checkout** (pinned action).
2. **Setup Java 17**.
3. **Setup Flutter 3.47.9**.
4. **`flutter pub get --enforce-lockfile`** (the committed `pubspec.lock` is
   used as-is; a drifted lockfile fails the run).
5. **Quality gate**: `dart format --set-exit-if-changed`, `flutter analyze`,
   `flutter test`.
6. **Read and validate version** from `pubspec.yaml` (`X.Y.Z+positive int`).
7. **Read changelog** section for that version.
8. **Backend pre-check**: fails if the backend already serves a
   `version_code >=` this build, or if its response has a release without a
   numeric `version_code` (only `data: null`/404 count as "no release yet").
9. **Prepare signing keystore** from secrets (never committed).
10. **Build signed release APK** with explicit production `--dart-define`s.
11. **Verify APK identity and version** using `aapt`: `applicationId` matches
    `android/app/build.gradle.kts`, `versionCode`/`versionName` match
    `pubspec.yaml`, and `REQUEST_INSTALL_PACKAGES` is present.
12. **Verify APK signature** with `apksigner` against the production keystore.
13. **Rename uniquely** to `app-v<version_name>-<version_code>.apk`. The name
    used to be `app-v<version_name>.apk`; two builds sharing a version name
    then overwrote the file the live release pointed to (see
    [`UPDATE_FLOW.md`](UPDATE_FLOW.md#why-there-was-a-problem-parsing-the-package-happened)).
14. **Compute SHA-256**, write a `.sha256` file, upload both as a workflow
    artifact (retention: 90 days).
15. **Atomic server upload**: refuse if the final file already exists, upload
    to `<file>.part`, verify the remote SHA-256, then `mv -n` into place.
    Existing release files are never overwritten; each previous release keeps
    its own file as a rollback artifact.
16. **Verify remote file** by re-reading its SHA-256 over SSH.
17. **Login to backend** and **publish release metadata** (retry once on 401).
    `sha256`/`file_size` are included only when `PUBLISH_INTEGRITY_FIELDS=true`.
18. **Verify `/app/releases/latest`** returns the exact version/name/file.
19. **Strict download verification**: download the artifact from `file_url` (or
    the fallback endpoint), require HTTP 200, verify SHA-256, minimum size and
    file type. Any mismatch fails the workflow.
20. **Orphan cleanup**: if the upload succeeded but the backend never accepted
    the release, the just-uploaded (uniquely named, unreferenced) file is
    deleted.
21. **Cleanup** secrets/temporary files (always runs).

## Artifact and failure behaviour

- The signed APK and its checksum are retained as a GitHub Actions artifact for
  90 days.
- A release run is never cancelled by a newer run (`cancel-in-progress: false`),
  preventing half-finished uploads/publishes.
- Failures before stage 17 leave the backend untouched.
- A failure in stages 18–19 means the backend metadata or download endpoint is
  inconsistent with the uploaded file. Do **not** re-run blindly: check which
  stage failed and follow [`ROLLBACK.md`](ROLLBACK.md).

## Local release build

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://mr-edu.ertiqaa.site/api/v1 \
  --dart-define=STORAGE_BASE_URL=https://mr-edu.ertiqaa.site/storage
```

A local release build requires `android/keystore.properties` pointing to the
production keystore. Release builds never fall back to debug signing; packaging
fails with a clear error when signing is not configured.

## Troubleshooting

| Symptom | Cause | Action |
| --- | --- | --- |
| Pre-check fails (`backend already has version_code`) | `version_code` was not increased | Bump `version` in `pubspec.yaml` |
| Upload fails (`already exists on the server; refusing to overwrite`) | The same build was already uploaded (re-run) | Confirm no release references the file, or bump `version_code` |
| Release job skipped | Workflow dispatched from a branch other than `main` | Merge to `main` first |
| Missing changelog section | No `## <version_name>` in `CHANGELOG.md` | Add the section |
| APK identity mismatch | Stale build output or wrong `applicationId` | Run `flutter clean` and rebuild; check `android/app/build.gradle.kts` |
| Signature mismatch | Wrong keystore/alias or debug-signed APK | Verify secrets; never change the production key |
| SSH host verification failure | Missing/stale `SERVER_KNOWN_HOSTS` | Re-generate and update the secret |
| Download verification mismatch | Uploaded file differs from built artifact, CDN cache, or wrong `file_url` | Inspect server file hash and CDN cache; see rollback doc |
| Installer shows "problem parsing the package" | Old client build or corrupt/overwritten server artifact | Ensure the APK hash matches; ship the hardened client (4.0.11+) |

## Related documents

- [`ENVIRONMENT.md`](ENVIRONMENT.md) — `--dart-define` configuration.
- [`UPDATE_FLOW.md`](UPDATE_FLOW.md) — client update behaviour and backend
  metadata contract.
- [`ROLLBACK.md`](ROLLBACK.md) — rollback and recovery procedure.
