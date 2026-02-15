# Repository Guidelines

## Project Overview

FitCheck AI is a multi-app monorepo for AI-assisted wardrobe management, outfit generation, and related social/planning workflows.

Primary deliverables in this repo:
- `backend/`: FastAPI API server (auth, wardrobe, AI, recommendations, social import, subscriptions, photoshoot)
- `frontend/`: React + TypeScript web app (Vite)
- `flutter/`: Flutter mobile app (GetX architecture)
- `remotion/`: Marketing/promo video compositions
- `docs/`: Product, technical, implementation, and development documentation

## Architecture At A Glance

- Clients (`frontend/`, `flutter/`) call the FastAPI backend (`backend/app/main.py`) for app-domain operations.
- Backend validates auth tokens and orchestrates business logic in `backend/app/services/`.
- Supabase is the source of truth for Postgres + storage.
- AI providers are abstracted behind backend services (`ai_provider_service.py`, `ai_service.py`, `ai_settings_service.py`).
- Optional vector indexing/retrieval runs through Pinecone (`vector_service.py`).

## Project Structure

- `backend/app/main.py`: API app setup, middleware, route registration, health checks
- `backend/app/api/v1/`: HTTP route handlers by domain
- `backend/app/services/`: business logic and third-party integrations
- `backend/app/models/`: Pydantic schemas
- `backend/db/supabase/migrations/`: Supabase SQL migrations (`001_full_schema.sql` baseline)
- `backend/tests/`: backend test suite (`pytest`)
- `frontend/src/pages/`: route pages
- `frontend/src/components/`: feature and shared components
- `frontend/src/components/ui/`: reusable UI primitives
- `frontend/src/api/`: API client modules
- `frontend/src/stores/`: Zustand stores
- `flutter/lib/features/`: feature modules (auth, wardrobe, outfits, photoshoot, recommendations, etc.)
- `flutter/lib/core/`: shared services/config/network/utilities
- `docs/`: authoritative written specs and setup guides

## Development Workflow (No Docker)

### Prerequisites
- Python 3.12+
- Node.js 18+
- Flutter SDK (for mobile work)
- Hosted Supabase project

### Start Web + API
- `./run-dev.sh` (starts backend on `:8000` and frontend on `:3000`)

### Start Manually
- Backend:
  - `cd backend`
  - `python -m venv .venv && source .venv/bin/activate`
  - `pip install -r requirements.txt`
  - `uvicorn app.main:app --reload --port 8000`
- Frontend:
  - `cd frontend`
  - `npm install`
  - `npm run dev`

### Mobile (Flutter)
- `cd flutter`
- `flutter pub get`
- Run with env defines (or `.env` asset):
  - `flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`

## Environment & Infrastructure

- Do not run Supabase locally; use hosted Supabase.
- Apply schema in Supabase SQL Editor starting with:
  - `backend/db/supabase/migrations/001_full_schema.sql`
- Backend loads env from:
  - `backend/.env`
  - repository root `.env`
- Frontend env template: `frontend/.env.example`
- Backend env template: `backend/.env.example`
- Flutter env template: `flutter/.env.example`

Key backend env groups:
- Supabase: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`
- AI providers: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*`, `AI_OPENAI_*`, `AI_CUSTOM_*`
- Optional: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, social-import flags

## Backend Conventions

- Keep route-layer concerns in `backend/app/api/v1/`.
- Keep reusable domain/business logic in `backend/app/services/`.
- Keep schema definitions in `backend/app/models/`.
- Use dependency helpers from `backend/app/api/v1/deps.py` and DB accessors in `backend/app/db/connection.py`.
- Preserve middleware/error patterns in `backend/app/core/`.

## Frontend Conventions

- Routing entry: `frontend/src/App.tsx`.
- API calls: `frontend/src/api/*.ts` through `frontend/src/api/client.ts`.
- State: Zustand stores under `frontend/src/stores/`.
- Shared utilities: `frontend/src/lib/`.
- Follow existing style: 2-space indentation, single quotes, no semicolons.

## Flutter Conventions

- GetX route/binding pattern under `flutter/lib/app/`.
- Feature-first modules under `flutter/lib/features/`.
- Shared infra under `flutter/lib/core/`.
- Environment loaded via `flutter/lib/core/config/env_config.dart`.

## Build, Test, and Validation Commands

- `cd backend && pytest`
- `cd frontend && npm run lint`
- `cd frontend && npm run build`
- `cd remotion && npm run dev` (preview video composition)
- `cd flutter && flutter test`

## Coding Style & Naming

- Backend (Python):
  - 4-space indentation
  - type hints where practical
  - `snake_case` for functions/modules
  - `PascalCase` for classes
- Frontend (TypeScript/React):
  - `PascalCase` components
  - `camelCase` hooks/utilities
  - keep existing formatting patterns
- Flutter (Dart): follow existing project style and feature modularity

## Testing Guidelines

- Backend:
  - framework: `pytest` + `pytest-asyncio`
  - tests in `backend/tests/`
  - files named `test_*.py`
- Frontend:
  - no formal test runner configured yet
  - validate with `npm run build` + manual QA
- Flutter:
  - run `flutter test` for available tests

## Commit & Pull Request Guidelines

- Use clear, imperative commit subjects; preferred format: `type: summary`
  - examples: `feat: add social import session timeout`, `fix: handle missing refresh token`
- PRs should include:
  - short description
  - test/verification steps
  - screenshots for UI changes
  - env/config updates (and update relevant `.env.example` when needed)

## Non-Negotiable Project Instructions

- Never run the project using Docker for local development.
- Use hosted Supabase; do not run Supabase locally or in Docker.
- Treat `.env` values as already provisioned in this workspace unless told otherwise.
- Maintain modular boundaries and avoid bypassing service abstractions.
