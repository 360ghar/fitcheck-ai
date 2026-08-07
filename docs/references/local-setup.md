# Development Setup

Last updated: 2026-08-08

## Overview

This guide covers local development for the full FitCheck AI repository.

Important project rules:
- Do not use Docker for local development.
- Use hosted Supabase (do not run Supabase locally).
- In this workspace, required keys are already available in the root `.env`.

## Prerequisites

- Python 3.12+
- Node.js 18+
- npm 9+
- Hosted Supabase project
- Optional: Flutter SDK (for mobile app development)
- Optional: Pinecone + AI provider keys for advanced AI/vector flows

## Environment Files

Reference templates:
- Backend: `backend/.env.example`
- Frontend: `frontend/.env.example`
- Flutter: `flutter/.env.example`

Backend loads environment values from:
- `backend/.env`
- repository root `.env`

## 1. Backend Setup

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Run backend:

```bash
uvicorn app.main:app --reload --port 8000
```

Backend URLs:
- API root: `http://localhost:8000`
- Swagger: `http://localhost:8000/api/v1/docs`
- ReDoc: `http://localhost:8000/api/v1/redoc`
- Health (liveness): `http://localhost:8000/health`
- Readiness (schema check): `http://localhost:8000/ready`

## 2. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

Frontend URL:
- App: `http://localhost:3000`

Frontend env keys used (from `frontend/.env.example`):
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL` (optional — leave empty for dev; the Vite proxy serves
  same-origin `/api/v1/...`, avoiding CORS preflights)
- `VITE_ENABLE_SOCIAL_IMPORT` (feature flag for social import routes)
- `VITE_ENABLE_GAMIFICATION` (feature flag for streaks/achievements; default off)
- Optional: `VITE_PUBLIC_POSTHOG_KEY` / `VITE_PUBLIC_POSTHOG_HOST`
  (analytics), `VITE_SENTRY_DSN` (error tracking), `VITE_BLOG_ADMIN_EMAILS`
  (admin blog access)

## 3. One-Command Web + API Startup

From repo root:

```bash
./run-dev.sh
```

This starts:
- backend on `:8000`
- frontend on `:3000`

## 4. Supabase Schema Initialization

1. Open your Supabase SQL Editor.
2. Apply **all** migrations in numeric order from
   `backend/db/supabase/migrations/` (43 files, numbered `001`..`042` — note
   `002` has two files: `002_astrology_profile.sql` and
   `002_user_profile_trigger.sql`). Do not skip any: the backend treats a
   partial schema as broken (`GET /ready` fails closed on missing
   tables/columns).
3. File storage does **not** live in Supabase. Uploads go to a private
   S3-compatible object-storage bucket (Cloudflare R2) configured by the
   `OBJECT_STORAGE_*` vars in `backend/.env.example`
   (`OBJECT_STORAGE_ENDPOINT`, `OBJECT_STORAGE_REGION` (keep `auto`),
   `OBJECT_STORAGE_ACCESS_KEY_ID`, `OBJECT_STORAGE_SECRET_ACCESS_KEY`,
   `OBJECT_STORAGE_BUCKET`). There is no `SUPABASE_STORAGE_BUCKET` setup step:
   create the R2 bucket, an S3 API token, and a CORS policy on the bucket
   allowing your web origins (the frontend `fetch()`es image URLs for
   download/share and reads one through a canvas). Only the `OBJECT_STORAGE_*`
   names are read; provider-specific names (`R2_*`, `AWS_*`) are not aliased.

   Image serving is configured by (`backend/app/core/config.py`):
   - `OBJECT_STORAGE_PRESIGN_TTL` — presigned GET URL lifetime before it
     rotates on the next refetch (default `3600` seconds). URLs are
     short-lived by design; the DB stores `storage_path` keys, never URLs.
   - `IMAGE_SERVING_MODE` — `presigned` (default) materializes a short-lived
     presigned GET URL per read; `worker` emits stable path-only URLs
     (`IMAGE_CDN_BASE_URL` + `/{storage_path}`) served by the Cloudflare
     Worker in `infra/images-worker` (validates the app JWT + per-user path
     ownership, edge-cached). Flip only after the Worker + custom domain are
     deployed.
   - `THUMBNAIL_SERVING` (default off) — when on, read paths emit
     `thumbnail_url` pointing at a separate downscaled object
     (`{storage_path}_thumb`). Uploads always create the thumb variant; run
     `backend/scripts/generate_thumbnails.py` to backfill pre-existing objects
     before flipping this on.

Quick schema verification after backend starts:

```bash
curl -sS http://localhost:8000/ready
```

Expect `"schema_ready": true` (and `"status": "ready"`). `/ready` fail-closes:
a missing table/column from any migration reports `not_ready`, and in DEBUG
mode the response lists the gaps under `missing_tables`. `/health` is a pure
liveness probe (status/service/version/commit/rss_mb, no DB/network I/O) and
does **not** carry `schema_ready`; `/api/v1/health` exists as a compatibility
alias of `/health` (see `backend/app/api/v1/health.py` and
`backend/app/main.py`).

## 5. Flutter Setup (Optional)

```bash
cd flutter
flutter pub get
```

Run with explicit defines:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Flutter can also read an asset `.env` file via `EnvConfig`.

## 6. Validation Commands

- Backend tests:

```bash
cd backend && pytest
```

- Frontend lint and build:

```bash
cd frontend && npm run lint && npm run build
```

- Flutter tests:

```bash
cd flutter && flutter test
```

## Troubleshooting

- `schema_ready: false` on `/ready`:
  - Re-run missing Supabase migrations in numeric order (001..042).
- `401` from API with valid login:
  - Check frontend token storage and refresh flow (`frontend/src/api/client.ts`).
- CORS issues:
  - Confirm `BACKEND_CORS_ORIGINS` and `FRONTEND_URL` in backend env.
- Social import routes missing:
  - Confirm `ENABLE_SOCIAL_IMPORT=true`.
