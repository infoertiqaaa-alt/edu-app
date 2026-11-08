# Environment configuration

All build-time configuration is injected with `--dart-define`; no environment
values are hardcoded per build target in Dart source.

The single source of truth is `lib/core/config/app_config.dart`.

## Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `APP_ENV` | No | `production` | `development`, `staging` or `production` (also accepts `dev`, `stage`, `prod`). Unknown values fail fast at startup. |
| `API_BASE_URL` | In dev/staging; optional in production | `https://mr-edu.ertiqaa.site/api/v1` | REST API base URL. Must be HTTPS in production. A trailing slash is removed. |
| `STORAGE_BASE_URL` | In dev/staging; optional in production | `https://mr-edu.ertiqaa.site/storage` | Base URL used to resolve relative image/file paths. |
| `DOWNLOAD_HOSTS` | No | API/storage hosts | Comma-separated extra hostnames allowed as APK download sources (for example a CDN). |
| `ALLOW_INSECURE_HTTP` | No | `false` | Allows `http://` in non-production builds only. Never honoured in production. |

### Validation rules

`AppConfig.validate()` runs before the widget tree starts and fails the app
immediately when configuration is invalid. It rejects:

- unknown `APP_ENV`;
- missing/invalid `API_BASE_URL` or `STORAGE_BASE_URL` outside production;
- non-HTTPS URLs (except non-production builds with `ALLOW_INSECURE_HTTP=true`);
- `localhost` / `127.0.0.1` in production.

### Download trust

`ReleaseDownloadUrl` accepts an APK URL only when:

1. the scheme is `https`,
2. the host is the API host, the storage host, or one of `DOWNLOAD_HOSTS`,
3. the path ends with `.apk` or `/download`.

Otherwise the client falls back to `${API_BASE_URL}/app/releases/latest/download`.
Redirects during download are checked against the same host allowlist.

## Examples

Development:

```bash
flutter run \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL=https://dev.example.com/api/v1 \
  --dart-define=STORAGE_BASE_URL=https://dev.example.com/storage
```

Staging with a CDN:

```bash
flutter build apk --release \
  --dart-define=APP_ENV=staging \
  --dart-define=API_BASE_URL=https://staging.example.com/api/v1 \
  --dart-define=STORAGE_BASE_URL=https://staging.example.com/storage \
  --dart-define=DOWNLOAD_HOSTS=cdn.example.com
```

Production (also what release.yml uses):

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://mr-edu.ertiqaa.site/api/v1 \
  --dart-define=STORAGE_BASE_URL=https://mr-edu.ertiqaa.site/storage
```

> `--dart-define` values are compiled into the app and are not secrets. Never
> pass passwords, tokens or keystore data this way.
