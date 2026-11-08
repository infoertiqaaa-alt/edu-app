# Release rollback and recovery

This runbook covers the release pipeline in `.github/workflows/release.yml`.
It never assumes that "re-running the workflow" is safe; identify the failing
stage first.

## Ground rules

- **Never** decrement or reuse a `version_code`.
- **Never** replace or rotate the production signing key to "fix" an install
  error. Installed apps only accept updates signed with the same certificate.
- Never overwrite a release file on the server. Every build is uploaded as
  `app-v<version_name>-<version_code>.apk`, so the previous release's file is
  the rollback artifact and stays untouched. (Releases up to `version_code` 10
  used `app-v<version_name>.apk`; leave those files in place too.)
- Backend metadata must always point at the exact artifact that was verified.
- The server-side download endpoint and the backend `file_url` must agree.

## Identify the failure point

| Last successful stage | State | Recovery |
| --- | --- | --- |
| Quality gate / version / pre-check | Nothing was uploaded or published | Fix the cause, bump version if needed, re-run |
| Keystore / build / signature / identity | Nothing was uploaded | Fix secrets/build, re-run |
| APK upload / remote checksum | Server may contain a `.part` file; no final file | Re-run the workflow; the `.part` is overwritten |
| Backend publish | The orphan-cleanup step deletes the new, unreferenced APK | Inspect backend latest release; fix the cause and re-run |
| Latest-release verification | Backend serves unexpected metadata | Republish the intended release |
| Download verification | Server/backend/CDN inconsistent | Restore or re-upload the exact artifact |

## Case 1 — Upload failed before the atomic move

No final file was created and no existing file was touched. Remove any
partial file:

```bash
ssh release@host
cd /var/www/educational_platforms/mr-edu.ertiqaa.site/storage/app/public/releases
rm -f app-v<version_name>-<version_code>.apk.part
```

Then fix the cause and re-run the workflow.

## Case 2 — The server file is corrupt or mismatched

1. Compare the server hash with the artifact hash from the failed workflow
   (the `.sha256` file in the `release-apk-*` workflow artifact):

   ```bash
   sha256sum app-v<version_name>-<version_code>.apk
   ```

2. Re-upload the exact artifact from the workflow run to a temporary name,
   verify its hash, then move it into place (this release's own file only —
   never another release's file):

   ```bash
   f=app-v<version_name>-<version_code>.apk
   scp "$f" release@host:/path/releases/"$f".part
   ssh release@host "sha256sum /path/releases/$f.part"
   ssh release@host "mv -f /path/releases/$f.part /path/releases/$f"
   ```

4. Purge any CDN cache for the file and the download endpoint.

## Case 3 — Backend metadata was published but must be withdrawn

If the release must not be offered (for example the wrong APK was published):

1. The previous release's APK is still on the server under its own name; it
   needs no restore. Re-point the backend to it **only if** the previous
   `version_code` is still higher than anything users may have installed
   (otherwise the client correctly ignores it — see Case 4).
2. In the backend admin (or via the release API used by the pipeline), set the
   release back to the previous valid values:
   - `version_code`
   - `version_name`
   - `file_name`
   - `changelog`
3. Optionally mark the bad release `is_active: false` / `status: inactive` so the
   client stops treating it as usable. The client fails open in that case.
4. Verify:

   ```bash
   curl -s https://mr-edu.ertiqaa.site/api/v1/app/releases/latest | jq '.data'
   ```

> If the backend API does not support editing a published release, publish a new
> corrected release with a **higher** `version_code`. Never lower the code to
> "undo" a release.

## Case 4 — A bad build reached users

Because `version_code` cannot go backwards:

1. Immediately publish a fixed build with a **higher** `version_code` and run
   the normal release pipeline.
2. Mark the bad release inactive in the backend as soon as the fixed metadata is
   ready, so devices that have not updated yet are not offered the bad build.
3. Verify the fixed APK is served with the expected SHA-256 before announcing.
4. If mandatory updates are involved, ensure `min_supported_version` points to
   the fixed release.

## Case 5 — Signature / installation failures

- Error: "app not installed" / signature mismatch → the APK was signed with a
  different key. Rebuild with the production keystore; do not rotate the key.
- Error: "problem parsing the package" → the artifact is corrupt or not a real
  APK. Compare its SHA-256 with the built artifact and inspect with
  `apksigner verify` and `aapt dump badging`.
- The hardened client (4.0.11+) validates these cases before opening the
  installer, so it should surface a clear message instead of the Android error.

## Post-rollback verification checklist

- [ ] `/app/releases/latest` returns the intended `version_code`, `version_name`
      and `file_name`.
- [ ] `file_url` points at the intended artifact (or is empty and the fallback
      endpoint is used).
- [ ] Downloading `file_url` returns HTTP 200 with the expected SHA-256.
- [ ] The APK's `applicationId`, `versionCode`, `versionName` and signature
      match the intended build.
- [ ] No release file on the server was overwritten; the previous APK is
      retained for the next rollback.
- [ ] Users/support are informed, including whether the update is mandatory.

## What is intentionally not automated

The workflow does not automatically revert backend metadata after a failed
verification, because that could hide a real infrastructure problem and needs a
human decision about which release is valid. Follow the cases above.
