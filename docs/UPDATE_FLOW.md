# In-app update flow

This document describes how the Android APK update chain works end to end and
the backend contract it depends on.

## Overview

```
startup
  └─ GET /app/releases/latest
       ├─ failure / invalid metadata        → continue normally (fail-open)
       ├─ backend version_code <= installed → continue normally
       ├─ newer + optional                  → UpdateOptionalAvailable (no gate)
       └─ newer + mandatory                 → update gate
             └─ download to <file>.part
                  └─ validate (size, hash, package, version, signature, minSdk)
                       └─ atomic rename to app-update-<versionCode>.apk
                            └─ check install permission
                                 └─ open Android package installer
```

The installed `version_code` is the only value used to decide whether an update
is required. A lower or equal backend `version_code` never triggers an update
and never causes a downgrade.

## Backend metadata contract

`GET /app/releases/latest` returns:

```json
{
  "success": true,
  "message": "...",
  "data": {
    "id": 123,
    "version_code": 12,
    "version_name": "4.0.12",
    "changelog": "...",
    "file_name": "app-v4.0.12-12.apk",
    "file_size": 24567890,
    "file_url": "https://mr-edu.ertiqaa.site/storage/releases/app-v4.0.12-12.apk",
    "published_at": "2026-11-01T10:00:00+00:00"
  }
}
```

Required by the client:

- `version_code`: positive integer, strictly greater than every previously
  distributed build.
- `version_name`: non-empty `X.Y.Z`.

Optional hardening fields (backward compatible):

| Field | Type | Client behaviour |
| --- | --- | --- |
| `is_mandatory` | bool | Defaults to `true` when absent. `false` makes a release optional. |
| `min_supported_version` | int (`version_code`) | Installed builds below this value are forced to update even if `is_mandatory=false`. |
| `sha256` | hex string | When present, the downloaded APK must match exactly. Strongly recommended. The pipeline sends it when the repository variable `PUBLISH_INTEGRITY_FIELDS=true`; the live backend does not return it yet (**backend change required**). |
| `is_active` / `status` | bool / string | `is_active:false` or `status` in `inactive`, `disabled`, `draft` makes the release unusable; the client does not show a gate. |
| `file_size` | int (bytes) | When present, the downloaded size must match exactly. |

`file_url` is optional:

- when valid (HTTPS, trusted host, `.apk`/download path) it is used as-is;
- otherwise the client falls back to
  `https://mr-edu.ertiqaa.site/api/v1/app/releases/latest/download`.

## Validation performed before installation

A file is never passed to Android's installer unless **all** checks pass:

1. File exists, is not empty and is at least 1 MiB.
2. If `file_size` is published, the byte length matches exactly.
3. SHA-256 matches `sha256` when published.
4. Android `PackageManager` can parse the archive.
5. `applicationId` matches the installed app (`com.example.teacher` today).
6. APK `versionCode` equals the published `version_code`.
7. APK `versionName` equals the published `version_name` (when non-empty).
8. The signing certificate matches the installed app's certificate.
9. The APK `minSdk` is supported by the device.
10. The released file name ends with `.apk`.

Cached files are re-validated with the same checks on every attempt. A cached
file is never trusted merely because its name matches.

Downloads are written to `<final path>.part`; the final path is produced with an
atomic rename only after validation. On failure the partial file is deleted.

## Mandatory vs optional

- Mandatory releases show a blocking screen with no skip/cancel, and the Android
  back button is disabled.
- Optional releases do not block startup. They are surfaced as
  `UpdateOptionalAvailable` and are never auto-downloaded.
- If the update check fails (network, server, invalid metadata), the app
  **fails open** and continues; users are not locked out by a backend outage.
- Availability safeguard: if the *same* mandatory update fails to download,
  validate or install twice in a row (broken artifact, offline device, storage
  full), the gate shows a secondary "المتابعة إلى التطبيق مؤقتًا" action. This
  prevents a corrupt server artifact from bricking every client. The update is
  re-checked on the next app start, so the requirement is never silently
  dropped — it is only deferrable while it is literally not installable.

## Installing

`REQUEST_INSTALL_PACKAGES` is declared in the manifest. On Android 8+ the app
checks `canRequestPackageInstalls()`. When permission is missing the gate shows
a button that opens the system "Install unknown apps" screen, plus a retry
action.

Opening the installer does **not** guarantee installation: the user can cancel,
and Android can reject a package without telling the app. The app therefore
**stays on the mandatory gate** after opening the installer and offers
"إعادة فتح المثبّت", which re-validates the cached file (no re-download) and
reopens the installer. When installation succeeds Android replaces and
restarts the app, so the gate disappears naturally.

Each reopen counts as an incomplete attempt, so the bounded escape hatch above
also covers a package that Android keeps rejecting.

> Up to 4.0.10 the splash screen left the gate as soon as the installer was
> opened, so cancelling the installer skipped a mandatory update until the next
> cold start, and the reopen action was unreachable.

## Why "There was a problem parsing the package" happened

Evidence gathered (Nov 2026): the live release (`version_code` 10,
`app-v4.0.10.apk`) is currently consistent — its size matches `file_size`,
`aapt` reports `com.example.teacher` / 10 / `4.0.10`, and `apksigner` verifies
the production certificate. The failure therefore came from the release
history and the old client, not from the artifact served today.

**Confirmed contributing causes (from the code):**

1. *Server file collision.* The pipeline named every upload
   `app-v<version_name>.apk`. Reverting `pubspec.yaml` to an earlier version
   name and releasing again overwrote a file that an already-published release
   still referenced. Devices then downloaded an APK whose `versionCode`, size
   and contents no longer matched the metadata they had read. Fixed: uploads
   are now `app-v<version_name>-<version_code>.apk` and existing files are
   never overwritten.
2. *Weak client validation (pre-4.0.11).* The old client only checked the ZIP
   magic bytes and reused `app-update.apk` by name. A truncated download, an
   HTML/JSON error body saved as `.apk`, or a stale cached file was handed to
   the installer, which reports exactly "There was a problem parsing the
   package".

**Why the prompt repeated:** when the backend advertises a `version_code`
higher than the `versionCode` inside the file actually served (collision
above), Android either refuses the package or installs an older/equal build.
The installed `versionCode` never reaches the advertised one, so every start
asks again. The current client rejects such a file before installation
(`versionCode` must equal the published `version_code`) and the pipeline
verifies the served file's SHA-256 after publishing.

Not provable from this repository: the exact sequence of historical backend
records (the API only exposes the latest release). If the backend keeps a
release history, check it for two releases sharing a `file_name`.

The current flow prevents a recurrence by:

- downloading to a temporary file and validating it as a real APK;
- checking package id, version code, signature and optional checksum;
- never falling back to an old APK when the current download fails;
- deleting stale/partial files before each attempt;
- uploading every build under a unique, never-overwritten file name.

## Operational rules

- Never decrement or reuse a `version_code`.
- Never replace the signing key; the installed app will reject the update.
- Publish `sha256` and `file_size` from the exact artifact that was uploaded.
- Keep the previous APK on the server as a rollback artifact.
- After publishing, verify both `/app/releases/latest` and the download endpoint
  (release.yml does this automatically).
