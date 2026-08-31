# SyncBox

Photo and file synchronization across desktop, mobile, and a Laravel API. This repository currently ships the CI/CD foundation, a health endpoint, and Hello SyncBox clients. The synchronization engine comes next.

## Layout

```text
/
├── backend/                 Laravel API
├── desktop/                 Tauri + React desktop app
├── mobile/                  Flutter Android and iOS app
├── docker/                  Nginx and PHP image config
├── .github/workflows/       GitHub Actions
├── Dockerfile               Production API image
├── docker-compose.yml       Production-like stack
└── docker-compose.dev.yml   Local API stack
```

## Local development

### API

```bash
cp backend/.env.example backend/.env
# set APP_KEY, DB_PASSWORD, and DB_ROOT_PASSWORD
docker compose -f docker-compose.dev.yml up --build
```

Health check:

```text
GET http://localhost:8080/api/v1/health

{
  "success": true,
  "message": "SyncBox API is running"
}
```

Without Docker:

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate
php artisan test
vendor/bin/phpstan analyse
vendor/bin/pint --test
php artisan serve
```

### Desktop

```bash
cd desktop
npm install
npm test
npm run lint
npm run tauri dev
```

The development client reads `desktop/.env.development` and calls `http://127.0.0.1:8080`. Staging and production API URLs are injected at build time from GitHub Variables. Do not put production URLs or secrets in source.

### Mobile

```bash
cd mobile
flutter create . --org com.syncbox --project-name syncbox --platforms android,ios
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Android emulator host loopback is `http://10.0.2.2:8080`.

## Environments

| Environment | Example API host | Desktop source |
| --- | --- | --- |
| Development | `api-dev.example.com` or `http://127.0.0.1:8080` | `desktop/.env.development` and `vars.API_BASE_URL` |
| Staging | `api-staging.example.com` | GitHub environment `staging` |
| Production | `api.example.com` | GitHub environment `production` |

Create GitHub Environments named `development`, `staging`, and `production`. Require reviewers on `production`.

## Versioning

Semantic versioning is stored in `VERSION` and copied into the desktop, mobile, and backend files:

```bash
node scripts/sync-version.mjs 1.0.1
git commit -am "Release 1.0.1"
git tag v1.0.1
git push origin main --tags
```

Pushing `v1.0.0` creates a GitHub Release with:

- `SyncBox-Windows.exe`
- `SyncBox-Windows.msi`
- `SyncBox-macOS.dmg`
- `SyncBox-Linux.AppImage`
- `SyncBox-Linux.deb`
- `SyncBox-Android.apk`

## Branch strategy

```text
feature/*  →  develop  →  main  →  version tag
```

Production deploys only from `main` or a `v*.*.*` tag. Pull requests never deploy.

Required pull request checks:

- Backend / Tests and static analysis
- Desktop / Tests, lint, and build validation
- Mobile / Analyze, test, and Android build

## GitHub Variables

| Name | Purpose |
| --- | --- |
| `API_BASE_URL` | API origin baked into desktop and mobile builds |
| `APP_ENV` | `development`, `staging`, or `production` |

## GitHub Secrets

Never commit these values. Never echo them in workflows.

| Secret | Used by |
| --- | --- |
| `APP_KEY` | Laravel |
| `DB_PASSWORD` / `DB_ROOT_PASSWORD` | MySQL |
| `JWT_SECRET` | API auth (later) |
| `STORAGE_BUCKET` / `STORAGE_ACCESS_KEY` / `STORAGE_SECRET_KEY` | Object storage |
| `ANDROID_KEYSTORE_BASE64` | Android release signing |
| `ANDROID_KEYSTORE_PASSWORD` | Android release signing |
| `ANDROID_KEY_ALIAS` | Android release signing |
| `ANDROID_KEY_PASSWORD` | Android release signing |
| `IOS_CERTIFICATE_BASE64` | iOS signing |
| `IOS_CERTIFICATE_PASSWORD` | iOS signing |
| `IOS_PROVISIONING_PROFILE_BASE64` | iOS signing |
| `APPLE_CERTIFICATE` / `APPLE_CERTIFICATE_PASSWORD` / `APPLE_SIGNING_IDENTITY` / `APPLE_ID` / `APPLE_PASSWORD` / `APPLE_TEAM_ID` | macOS signing |
| `TAURI_SIGNING_PRIVATE_KEY` / `TAURI_SIGNING_PRIVATE_KEY_PASSWORD` | Tauri updater signatures |
| `DEPLOY_HOST` / `DEPLOY_USER` / `DEPLOY_SSH_KEY` / `DEPLOY_APP_DIR` | Production SSH deploy |

Enable secret scanning and push protection on the GitHub repository.

## Deployment and rollback

A production tag runs tests, publishes `ghcr.io/<owner>/<repo>:<tag>`, then SSH-deploys with Docker Compose.

Rollback options:

1. Actions → Deploy → Run workflow → set `image_tag` to a previous tag, or
2. On the server: `./deploy/rollback.sh ghcr.io/<owner>/<repo> v1.0.0`

The production environment should require approval before the deploy job runs.

## Artifact retention

| Artifact | Retention |
| --- | --- |
| Test reports | 7 days |
| Desktop installers and Android APK | 14 days |
| Failure logs | 5 days |

Release assets on the GitHub Release remain available independently of workflow artifacts.
