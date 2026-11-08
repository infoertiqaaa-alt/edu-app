# MR Flutter App — CI/CD Analysis Report

> **Historical snapshot.** This report describes the pipeline as it was audited
> (4.0.10). Most findings have since been addressed. The current, authoritative
> behaviour is documented in [`CI_CD_RELEASE.md`](CI_CD_RELEASE.md) and
> [`ROLLBACK.md`](ROLLBACK.md); prefer those when they disagree with this file.

**Date:** 2026-11-07
**Pipeline:** `.github/workflows/release.yml` (781 lines)
**Supporting doc:** `docs/CI_CD_RELEASE.md` (314 lines)
**Scope:** GitHub Actions → signed Android APK → SCP to server → publish metadata to backend → verify

---

## 1. Executive summary

The project has **one** workflow: a production Android release pipeline triggered by
changes to `pubspec.yaml` or `CHANGELOG.md` on `main` (and by manual dispatch).
It is a carefully engineered release pipeline: strict version parsing, changelog
enforcement, backend duplicate-version pre-check, production-only signing,
post-build certificate verification, upload verification, backend publishing with
a single 401 retry, and end-to-end verification of the published "latest" release.

However, it is a **release-only** pipeline. There is **no CI on pull requests**, no
`flutter analyze`, no `flutter test`, no artifact retention, no deployment
approval, and no rollback. The project can only be validated manually before a
version bump; once the bump is pushed, production is updated automatically.

**Overall CI/CD maturity: 6.5 / 10** — strong release mechanics, weak quality and
governance controls.

---

## 2. Pipeline inventory

| Property | Value |
|---|---|
| Workflow name | `Release Android APK` |
| File | `.github/workflows/release.yml` |
| Trigger (push) | `main`, paths `pubspec.yaml`, `CHANGELOG.md` |
| Trigger (manual) | `workflow_dispatch` |
| Concurrency | `release-${{ github.ref }}`, `cancel-in-progress: true` |
| Runner | `ubuntu-latest` |
| Timeout | 60 minutes |
| Jobs | 1 (`release`) |
| Java | Temurin 17, Gradle cache |
| Flutter | `subosito/flutter-action@v2`, `stable`, SDK cache |
| Output | Universal signed `app-v<version_name>.apk` |
| Destination | Server storage dir + backend release API |
| Artifact retention | None (APK not uploaded to GitHub Actions) |
| Environments / approvals | None |
| Quality gates | None (no analyze/test/lint) |

---

## 3. Stage-by-stage behavior

| # | Stage | What it does | Failure behavior |
|---|---|---|---|
| 1 | Checkout | `actions/checkout@v4` | fail |
| 2 | Setup Java | Temurin 17 + Gradle cache | fail |
| 3 | Setup Flutter | stable channel + cache | fail |
| 4 | Dependencies | `flutter pub get` | fail |
| 5 | Read version | Parses `version: X.Y.Z+N` from `pubspec.yaml`, validates both parts | fail on missing/malformed |
| 6 | Read changelog | `awk` extracts the exact `## X.Y.Z` section from `CHANGELOG.md` | fail if missing/empty |
| 7 | Backend pre-check | `GET /app/releases/latest` (3 attempts); rejects if backend `version_code >=` build code | fail on duplicate/lower; allow 404/204 |
| 8 | Prepare signing | Base64-decodes keystore into `android/app/upload-keystore.jks`, writes `android/keystore.properties` | fail if secrets missing/empty |
| 9 | Build APK | `flutter build apk --release` | fail |
| 9b | Verify signature | Compares `apksigner` APK cert SHA-256 with `keytool` keystore cert SHA-256 | fail on mismatch |
| 10 | Rename | Copies to `app-v<version>.apk` | fail if APK missing |
| 11 | Upload | `scp` to `.../storage/app/public/releases/<apk>` | fail on SSH/SCP error |
| 12 | Verify upload | SSH `test -f` on the remote path | fail |
| 13 | Backend login | `POST /auth/login`, extracts `data.token`, masks it | fail if login/token missing |
| 14 | Publish | `POST /app/releases` with `version_code`, `version_name`, `changelog`, `file_name`; re-login + retry once on 401 | fail on other non-2xx |
| 15 | Verify latest | `GET /app/releases/latest`, asserts code/name/file match (3 attempts) | fail on mismatch |
| 16 | Download check | `HEAD /app/releases/latest/download` | soft fail (`continue-on-error`) |
| 17 | Cleanup | Removes keystore, properties, changelog, temp APK files | always runs |

**Version/changelog contract**

- `pubspec.yaml#version` is the single source of truth.
- `CHANGELOG.md` must contain a section whose header exactly equals
  `## <version_name>`.
- `version_code` must be a positive integer and strictly greater than the backend's
  current latest code.
- APK name is deterministic: `app-v<version_name>.apk`.

**Signing model**

- Release builds use **only** the production keystore. `android/app/build.gradle.kts`
  throws a Gradle error if `keystore.properties` is missing/incomplete or the
  keystore file does not exist when `assembleRelease`/`packageRelease`/`bundleRelease`
  runs, so the old Debug-signing fallback cannot silently ship.
- CI additionally verifies the built APK's signing certificate matches the keystore
  decoded from `ANDROID_KEYSTORE_BASE64`.
- The keystore and `keystore.properties` are deleted in an `if: always()` step.

---

## 4. Secrets and configuration

| Name | Type | Used for |
|---|---|---|
| `SERVER_HOST` | secret | SCP/SSH target |
| `SERVER_USER` | secret | SSH user |
| `SERVER_SSH_KEY` | secret | SSH private key |
| `SERVER_KNOWN_HOSTS` | secret (optional) | Pinned host keys |
| `BACKEND_USERNAME` | secret | Backend login |
| `BACKEND_PASSWORD` | secret | Backend login |
| `ANDROID_KEYSTORE_BASE64` | secret | Release keystore |
| `KEYSTORE_PASSWORD` | secret | Keystore password |
| `KEY_ALIAS` | secret | Signing alias |
| `KEY_PASSWORD` | secret | Key password |
| `SERVER_PORT` | variable (optional) | SSH port, default 22 |
| `BACKEND_BASE_URL` | workflow env | `https://mr-edu.ertiqaa.site/api/v1` |

Good practices already present:

- No credential values in the repository or workflow.
- Backend token is minted per run, masked (`::add-mask::`), kept in `$GITHUB_ENV`
  for the job only, and never stored as a long-lived secret.
- SSH key is written to a `chmod 600` temp file and deleted.
- Keystore is generated only inside the ephemeral runner and cleaned up.
- `::error::` annotations point to the exact failing step.

---

## 5. Security analysis

| Control | Status | Comment |
|---|---|---|
| Production keystore only | ✅ Strong | Gradle guard + certificate comparison |
| Signature verification before publish | ✅ Strong | `apksigner` vs `keytool` SHA-256 |
| SSH host verification | ⚠️ Conditional | Falls back to `StrictHostKeyChecking=no` + `/dev/null` if `SERVER_KNOWN_HOSTS` is unset |
| Token masking | ✅ | Backend bearer token masked |
| Secret-at-rest in repo | ✅ | Keystore/properties/SSH not committed; `.gitignore` covers `*.jks`, `*.keystore`, `keystore.properties` |
| Least-privilege GITHUB_TOKEN | ❌ | No `permissions:` block; default token permissions apply |
| Action pinning | ⚠️ | Tags (`@v4`, `@v2`) rather than commit SHAs |
| Dependency integrity | ⚠️ | `flutter pub get` without `--enforce-lockfile`; Flutter channel floating |
| Artifact checksum | ❌ | No SHA-256 published or verified server-side/client-side |
| Code quality gate | ❌ | No analyze/test before release |
| Deployment approval | ❌ | No GitHub Environment / required reviewers |
| Secret scanning / Dependabot | ❌ | Not configured |
| Build provenance/SBOM | ❌ | Not generated |
| Rollback | ❌ | No previous-release pointer or kill switch |

**Host-key note:** the permissive fallback exists for backward compatibility, but it
removes the protection against a compromised DNS/network path. For a production
release pipeline, `SERVER_KNOWN_HOSTS` should be mandatory.

**Local machine note:** `android/keystore.properties` and a root-level
`upload-keystore.jks` exist in the working tree. They are covered by `.gitignore`,
but confirm the keystore was never committed historically and rotate it if it was.
The root-level location also differs from the CI layout (`android/app/`), so local
release builds should be re-verified.

---

## 6. CI/CD findings and risks

### P0 — release-blocking risks

1. **No quality gate.**
   The pipeline never runs `flutter analyze` or `flutter test`. The project currently
   passes both locally (0 analyzer issues, 19/19 tests), but nothing prevents a
   regression from being signed and published to every user. A release workflow
   should depend on a passing CI workflow.

2. **Automatic production release on version bump.**
   Pushing a `pubspec.yaml` change to `main` publishes to production immediately.
   There is no environment protection, no reviewer approval, and no staging soak.
   Combined with the app's mandatory update gate, a bad build reaches all users at
   once.

3. **No rollback / kill switch.**
   If `POST /app/releases` publishes a broken version, every older client will
   detect `latest > installed` and be forced to install it. There is no
   "minimum supported version", no pinned previous release, and no API to revert
   `latest`.

### P1 — high impact

4. **Partial release is possible.**
   The APK is SCP'd to the server (stage 11) *before* backend metadata is published
   (stage 14). If publishing fails, an orphan APK remains on the server while the
   backend still points to the old release. Add cleanup/rollback of the uploaded
   file on failure, or publish metadata first and confirm the file before making it
   "latest".

5. **Weak download verification.**
   Stage 16 only checks `HEAD` and ignores all non-zero HTTP codes
   (`continue-on-error`, and a 500 is logged as "reachable"). It should require
   HTTP 200 and a sensible `Content-Length` (or compare against the uploaded file
   size/hash).

6. **No checksum in publish metadata.**
   Clients verify only the ZIP magic bytes. A SHA-256 in the release payload and a
   client-side check would make the update tamper/corruption resistant.

7. **No artifact retention.**
   The APK exists only on the server. It is not uploaded with
   `actions/upload-artifact`, so there is no immutable build record, no easy
   re-download for support, and no diffable artifact per run.

8. **Floating toolchain.**
   `channel: stable` + `flutter pub get` means the same commit can produce
   different binaries over time. Pin the Flutter version (e.g. via
   `.fvmrc`/`flutter-version-file`) and use `--enforce-lockfile`.

9. **Manual dispatch is not branch-restricted.**
   `workflow_dispatch` can run against a non-`main` ref, and nothing asserts
   `github.ref == 'refs/heads/main'`, so a feature branch could publish if the
   required secrets are available to it.

10. **No GitHub Release/tag.**
    There is no tag creation, no GitHub Release with notes, and no changelog link
    in the repository. Traceability lives only in the Actions log and backend.

### P2 — medium

11. **No `permissions:` block.** Add `permissions: contents: read` (plus the
    minimum needed) to limit the default token.
12. **Actions pinned to tags, not SHAs.** Supply-chain hardening.
13. **Insecure SSH default.** Make `SERVER_KNOWN_HOSTS` required.
14. **No failure/success notifications** (Slack, email, Teams).
15. **No dependency/security scanning** (Dependabot, CodeQL, secret scanning).
16. **No build caching for pub.** Gradle is cached; the pub cache is not.
17. **Universal APK only.** No `--split-per-abi`, no App Bundle (AAB), no
    `--obfuscate --split-debug-info`; larger download and no symbol upload.
18. **No Play Store path.** Direct APK + `REQUEST_INSTALL_PACKAGES` is the only
    distribution model.
19. **`SERVER_REMOTE_DIR` is a global env with no existence/permission pre-check.**
    A wrong path fails late (after a full build).
20. **No concurrency control across different refs.** A manual run on another ref
    can build/publish concurrently with `main`.
21. **No explicit `jq`/`curl` availability check.** They are preinstalled on
    `ubuntu-latest`, but the workflow depends on them implicitly.

### Documentation inconsistencies

22. `docs/CI_CD_RELEASE.md` §10 says `data.file_url` is **not** the download source,
    while `UpdateCubit.startUpdate()` downloads `release.fileUrl` when non-empty.
23. The doc lists `download_latest_apk.dart`; the actual file is
    `download_release_apk.dart`.
24. The doc says the APK lands in `storage/app/public/releases`; the app's
    `ApiConstants.storageBaseUrl` maps to `/storage`, so the public URL is
    consistent — but the doc and the workflow hardcode the path in two places.
25. `README.md` and `pubspec.yaml` still describe the project as
    "A new Flutter project".

---

## 7. Recommended target pipeline

```
PR opened/updated
  └─ ci.yml
       ├─ flutter analyze
       ├─ flutter test (with coverage)
       ├─ (optional) build debug APK
       └─ required check for branch protection

push tag vX.Y.Z (or manual approval on main)
  └─ release.yml
       ├─ needs: ci
       ├─ environment: production  (required reviewers)
       ├─ verify ref == main/tag
       ├─ flutter build apk --release --obfuscate --split-debug-info
       ├─ verify signature (existing stage)
       ├─ upload artifact (APK + SHA256SUMS + symbols)
       ├─ publish metadata (including sha256 + min_supported_version)
       ├─ verify latest + download (strict HTTP 200)
       ├─ create git tag + GitHub Release
       └─ cleanup / rollback on failure
```

**Quick wins (low effort, high value)**

1. Add a `ci.yml` that runs `flutter analyze` and `flutter test` on every PR/push.
2. Add `permissions: contents: read` and pin actions to SHAs.
3. Require `SERVER_KNOWN_HOSTS` and remove the permissive SSH fallback.
4. Upload the APK (and a generated SHA-256) as a workflow artifact.
5. Add `--enforce-lockfile` and pin the Flutter version.
6. Guard the job with `if: github.ref == 'refs/heads/main'` (or a tag check).
7. Make stage 16 strict (require HTTP 200).
8. Publish `sha256` and a `min_supported_version` in the release metadata.

**Medium-term**

9. Introduce a `production` GitHub Environment with required reviewers and
   environment-scoped secrets.
10. Implement backend rollback/kill-switch and a client "minimum supported version"
    policy so a bad release can be withdrawn.
11. Publish an AAB for Play Store distribution (or explicitly document side-loading),
    and evaluate Play In-App Updates.
12. Add Dependabot, CodeQL, and secret scanning.
13. Add notifications and a release dashboard/runbook.

---

## 8. Release runbook checklist (current pipeline)

Before pushing:

- [ ] `flutter analyze` is clean.
- [ ] `flutter test` passes.
- [ ] `pubspec.yaml` version is `X.Y.Z+N`, with `N` greater than the live backend code.
- [ ] `CHANGELOG.md` contains `## X.Y.Z` with release notes.
- [ ] Release is signed with the same production keystore as every previous build.
- [ ] The Android `applicationId` is final (currently it is **not** — see app report).
- [ ] Backend `/app/releases/latest` is reachable from the runner.
- [ ] All required secrets/variables exist (`SERVER_*`, `BACKEND_*`, signing keys).
- [ ] `SERVER_KNOWN_HOSTS` is set (recommended).
- [ ] Server release directory is writable and has free space.

After the run:

- [ ] Workflow is green end to end.
- [ ] `GET /app/releases/latest` returns the new code/name/file.
- [ ] The download URL serves the APK with HTTP 200.
- [ ] Install the APK on a device and confirm the update gate behaves.
- [ ] Keep the previous APK and its signing certificate fingerprint for rollback.

---

## 9. Maturity scorecard

| Dimension | Score | Reason |
|---|---|---|
| Build automation | 9/10 | Signed, cached, reproducible stages |
| Release verification | 8/10 | Signature + backend verification; weak download check |
| Security of secrets | 8/10 | Ephemeral token/keystore; insecure SSH fallback |
| Quality gates | 1/10 | No analyze/test/lint |
| Governance/approvals | 2/10 | No environment, no reviewers, no tagging |
| Observability | 4/10 | Good log annotations; no notifications/metrics |
| Rollback/resilience | 2/10 | No rollback, partial-release window |
| Supply-chain hardening | 3/10 | Tags not SHAs, floating SDK/deps |
| **Overall** | **6.5/10** | Excellent release mechanics, incomplete CI governance |

---

*Generated from a full review of `.github/workflows/release.yml` and
`docs/CI_CD_RELEASE.md` on 2026-11-07.*
