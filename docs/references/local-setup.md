# Development Setup

Last updated: 2026-02-15

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
- Health: `http://localhost:8000/health`

## 2. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```

Frontend URL:
- App: `http://localhost:3000`

Frontend env keys commonly used:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL`
- `VITE_ENABLE_SOCIAL_IMPORT`

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
2. Run `backend/db/supabase/migrations/001_full_schema.sql`.
3. Apply subsequent migrations in numeric order.
4. Ensure storage bucket exists for `SUPABASE_STORAGE_BUCKET` (default `fitcheck-images`).

Quick schema verification after backend starts:

```bash
curl -sS http://localhost:8000/health
```

Expect `"schema_ready": true`.

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

## 6. Remotion Setup (Optional)

```bash
cd remotion
npm install
npm run dev
```

## 7. Validation Commands

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

- `schema_ready: false` on `/health`:
  - Re-run missing Supabase migrations.
- `401` from API with valid login:
  - Check frontend token storage and refresh flow (`frontend/src/api/client.ts`).
- CORS issues:
  - Confirm `BACKEND_CORS_ORIGINS` and `FRONTEND_URL` in backend env.
- Social import routes missing:
  - Confirm `ENABLE_SOCIAL_IMPORT=true`.
