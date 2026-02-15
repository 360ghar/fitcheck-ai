# FitCheck AI Project Overview

Last updated: 2026-02-15

## Purpose

This document is the implementation-level overview of the complete FitCheck AI project. It complements product and technical specs by describing how the repository is currently organized and how major subsystems collaborate.

## System Context

FitCheck AI provides wardrobe intelligence workflows:
- Cataloging clothing items from photos
- Building and generating outfits
- Planning outfits against weather/calendar context
- Producing AI photoshoot images
- Sharing outfits and collecting feedback
- Supporting engagement features (gamification, subscription, referrals)

Primary runtime architecture:
1. Clients (React web, Flutter mobile) call FastAPI endpoints.
2. FastAPI routes invoke service-layer abstractions.
3. Service layer persists/fetches data from Supabase and optional vector indexes.
4. AI provider abstractions dispatch model calls (Gemini/OpenAI/custom).

## Repository Components

### Backend (`backend/`)

Main entry: `backend/app/main.py`

Responsibilities:
- API route registration and middleware wiring
- health checks and startup checks
- schema readiness check against Supabase
- optional vector index initialization

Key backend areas:
- `backend/app/api/v1/`: HTTP route handlers by domain
- `backend/app/services/`: domain services and integrations
- `backend/app/models/`: Pydantic models for request/response + domain contracts
- `backend/app/core/`: config, middleware, security, exceptions, logging
- `backend/app/db/`: Supabase client accessors
- `backend/app/agents/`: AI agent implementations (extraction/image-generation support)
- `backend/tests/`: pytest suite

Route modules currently wired in `main.py`:
- `auth`, `users`, `items`, `outfits`, `shared_outfits`
- `recommendations`, `calendar`, `weather`, `gamification`
- `ai`, `ai_settings`, `batch_processing`
- `photoshoot`, `feedback`, `waitlist`, `demo`
- `subscription`, `referral`
- `social_import` (feature-flagged)

### Web Frontend (`frontend/`)

Main entry: `frontend/src/main.tsx`
Routing shell: `frontend/src/App.tsx`

Responsibilities:
- user-facing web UX for auth, wardrobe, outfits, recommendations, planning, and settings
- API integration with token refresh and error handling
- state management for auth and feature flows

Key frontend areas:
- `frontend/src/pages/`: routed pages and top-level screens
- `frontend/src/components/`: feature components
- `frontend/src/components/ui/`: reusable UI primitives
- `frontend/src/api/`: API wrappers per backend domain
- `frontend/src/stores/`: Zustand stores
- `frontend/src/lib/`: shared utilities (color analysis, stats, exports, etc.)
- `frontend/src/hooks/`: app-specific hooks

### Flutter App (`flutter/`)

Main entry: `flutter/lib/main.dart`

Responsibilities:
- native mobile experience for the same major product domains
- feature-first architecture with GetX routing/bindings/controllers

Key flutter areas:
- `flutter/lib/app/`: app routes, bindings, theme setup
- `flutter/lib/core/`: env config, networking, shared services/utilities/widgets
- `flutter/lib/features/`: feature modules (auth, wardrobe, outfits, photoshoot, recommendations, profile, subscription, etc.)

### Remotion (`remotion/`)

Purpose:
- scripted marketing/promo videos and stills for product storytelling

Key area:
- `remotion/src/fitcheck/`: theme, scenes, and assets for promo composition

### Documentation (`docs/`)

Purpose:
- product specs (`1-product/`)
- architecture/API/data models (`2-technical/`)
- feature implementation notes (`3-features/`)
- component/workflow/security details (`4-implementation/`)
- setup and launch docs (`5-development/`)

## Data & External Dependencies

### Supabase

Used for:
- Postgres domain tables
- auth identity and token verification flow
- object storage for item/outfit/image assets

Schema migration source:
- `backend/db/supabase/migrations/`
- start at `001_full_schema.sql`

### AI Providers

Provider abstraction supports:
- Gemini (`AI_GEMINI_*`)
- OpenAI (`AI_OPENAI_*`)
- Custom OpenAI-compatible endpoint (`AI_CUSTOM_*`)

Configuration and user/provider settings managed through:
- `backend/app/services/ai_provider_service.py`
- `backend/app/services/ai_settings_service.py`
- `backend/app/services/ai_provider_health_service.py`

### Optional Integrations

- Pinecone for vector indexing/retrieval (`vector_service.py`)
- Stripe billing and webhook flows (`subscription_service.py`)
- Weather API integration (`weather_service.py`)
- Social OAuth/import pipeline (`social_*` services)

## Operational Flows

### Local Web + API Development

- Preferred: `./run-dev.sh`
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:3000`
- API docs: `http://localhost:8000/api/v1/docs`

### Schema Validation

Backend health endpoint reports schema readiness:
- `GET /health`
- returns `schema_ready` and optional missing tables (debug)

### Testing & Verification

- Backend tests: `cd backend && pytest`
- Frontend lint/build: `cd frontend && npm run lint && npm run build`
- Flutter tests: `cd flutter && flutter test`

## Architectural Boundaries

- Route handlers should remain thin and delegate business logic to `services/`.
- Shared domain contracts belong in `models/`.
- Client apps should not reimplement server business rules that already exist in services.
- Environment-driven behavior should be centralized in backend `core/config.py` and flutter `EnvConfig`.

## Current Documentation Links

- Documentation index: `docs/README.md`
- Documentation summary: `docs/SUMMARY.md`
- Development setup: `docs/5-development/setup.md`
- Implementation status tracker: `docs/IMPLEMENTATION_STATUS.md`
