# Tech Stack

Last updated: 2026-08-08

## Overview

This document captures the technologies actively used by the FitCheck AI codebase and their roles.

## Backend

### Framework and Runtime

- FastAPI (`backend/requirements.txt`)
- Python 3.12+
- Uvicorn ASGI server
- Pydantic + `pydantic-settings`

Why:
- async-friendly API server
- typed request/response validation
- straightforward route/service modularity

### Data and Storage

- Supabase (PostgreSQL + Auth)
- S3-compatible object storage (Cloudflare R2 / Railway bucket) via `aioboto3`
- Supabase Python client (`supabase`)

Why:
- managed relational database + auth on Supabase
- private object storage with short-lived presigned GET URLs (see
  `backend/app/services/object_storage.py`); the DB stores `storage_path`
  keys, never public URLs

### AI and Integrations

- `google-genai` (Gemini access)
- OpenAI-compatible access path via backend provider abstraction
- `httpx` for outbound API calls
- `sse-starlette` (SSE streaming for batch AI jobs)
- `pillow-heif` (HEIC/HEIF decode — iPhone/modern-camera photos; uploads are
  transcoded to WebP)
- `pyswisseph` (ephemeris math for astrology recommendations)
- In-house Apple App Store Server API client (`backend/app/services/apple_iap_service.py`,
  httpx-based; verifies IAP transactions + App Store Server Notifications V2)
- In-house Google Play Developer API client (`backend/app/services/google_play_service.py`,
  httpx-based; Play Developer API v3 + Real-time Developer Notifications)

Provider configuration groups:
- `AI_GEMINI_*`
- `AI_OPENAI_*`
- `AI_CHAT_*` / `AI_VISION_*` / `AI_IMAGE_*` (per-leg; see `backend/.env.example`)

### Vector and Search (Optional)

- Pinecone SDK (`pinecone`)

Why:
- embedding-based similarity and retrieval flows

### Billing and Other Services

- Stripe (`stripe`)
- Weather integration via configured weather API key
- OAuth integrations for social import flows

## Web Frontend

### Core

- React 18
- TypeScript 5
- Vite 5

### UI and State

- Tailwind CSS
- Radix UI primitives + shadcn-style component composition
- Zustand
- TanStack Query

### Forms and Validation

- React Hook Form
- Zod

### HTTP and Analytics

- Axios
- PostHog JS

## Mobile App (Flutter)

### Core

- Flutter (Dart SDK in `flutter/pubspec.yaml`)
- GetX (routing + state/dependency patterns)

### Networking and Data

- Dio + `http`
- Supabase Flutter

### Utilities

- `image_picker`, `cached_network_image`, `shimmer`, `share_plus`
- PostHog Flutter
- Shorebird (OTA updates — `flutter/shorebird.yaml`)

## Admin Console

- React 19
- Vite 7
- Tailwind CSS 4 (via `@tailwindcss/vite`)
- TypeScript 5.9
- Vitest 3 (+ Testing Library, MSW, vitest-axe)
- `openapi-fetch` client generated from the backend OpenAPI contract
  (`contracts/openapi.json` → `src/shared/api/schema.d.ts`)
- Radix UI primitives, TanStack Query/Table/Virtual, react-router-dom 7,
  Zustand, Zod 4, recharts

Role:
- internal ops console at `admin.fitcheckaiapp.com`; server-enforced RBAC
  (see `backend/app/core/permissions.py`), UI gating is cosmetic

## Developer Tooling

### JavaScript/Frontend

- ESLint
- TypeScript compiler (`tsc` via build script)

### Python/Backend

- Pytest
- Pytest-asyncio

### Flutter

- Flutter test
- build_runner/freezed/json_serializable for model generation

## Environment Strategy

Backend keys are loaded from:
- `backend/.env`
- root `.env`

Frontend keys are provided through Vite env vars:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_PUBLISHABLE_KEY`
- `VITE_API_BASE_URL`

Flutter keys are provided through:
- `--dart-define` values
- optional `.env` asset fallback

## Infrastructure Notes

- Hosted Supabase is required.
- Local development uses non-Docker workflows.
- Dockerfiles are present for containerized deployment paths, not for standard local dev.

## Summary Table

| Layer | Primary Technologies |
|------|-----------------------|
| Backend API | FastAPI, Uvicorn, Pydantic |
| Data/Auth/Storage | Supabase (Postgres + Auth) + S3-compatible object storage (R2) |
| AI Provider Access | Gemini/OpenAI/custom via backend abstraction |
| Vector Search | Pinecone (optional) |
| Web App | React, TypeScript, Vite, Tailwind, Zustand, TanStack Query |
| Admin Console | React 19, Vite 7, Tailwind 4, vitest 3, openapi-fetch |
| Mobile App | Flutter, GetX, Supabase Flutter, Dio, Shorebird |
| Testing | Pytest, frontend build/lint validation, Flutter test |
