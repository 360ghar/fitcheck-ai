# FitCheck AI

FitCheck AI is a multi-platform wardrobe intelligence product with AI-assisted item extraction, outfit planning, outfit generation, recommendations, and social sharing.

## Monorepo Apps

- `backend/`: FastAPI API and business logic
- `frontend/`: React + TypeScript web app (Vite)
- `flutter/`: Flutter mobile app (GetX)
- `remotion/`: Remotion promo/video compositions
- `docs/`: Product, technical, and implementation documentation

## Core Capabilities

- AI wardrobe extraction from single or batch image uploads
- Wardrobe CRUD, filtering, condition tracking, and analytics
- Outfit creation and generation workflows
- Virtual try-on flow
- Calendar and weather-informed outfit planning
- Recommendations (matching items, complete look, shopping/gap-oriented suggestions)
- Photoshoot image generation flow
- Social sharing and public outfit links
- Gamification and referral/subscription flows
- Optional social import pipeline with OAuth/session support

## High-Level Architecture

1. Web and mobile clients call FastAPI endpoints under `/api/v1/*`.
2. Backend validates auth and coordinates domain services (`backend/app/services/`).
3. Supabase provides Postgres + storage.
4. AI provider abstraction supports Gemini, OpenAI, and custom OpenAI-compatible endpoints.
5. Optional vector features use Pinecone.

## Project Structure

```text
fitcheck-ai/
├── AGENTS.md
├── README.md
├── run-dev.sh
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── api/v1/
│   │   ├── services/
│   │   ├── models/
│   │   ├── core/
│   │   └── db/
│   ├── db/supabase/migrations/
│   ├── tests/
│   └── requirements.txt
├── frontend/
│   ├── src/
│   │   ├── App.tsx
│   │   ├── pages/
│   │   ├── components/
│   │   ├── api/
│   │   ├── stores/
│   │   └── lib/
│   ├── package.json
│   └── vite.config.ts
├── flutter/
│   ├── lib/
│   │   ├── app/
│   │   ├── core/
│   │   └── features/
│   └── pubspec.yaml
├── remotion/
│   ├── src/
│   └── package.json
└── docs/
    ├── README.md
    ├── PROJECT_OVERVIEW.md
    ├── SUMMARY.md
    ├── 1-product/
    ├── 2-technical/
    ├── 3-features/
    ├── 4-implementation/
    └── 5-development/
```

## Local Development

This repository uses hosted Supabase. Do not run Supabase locally.

### Prerequisites

- Python 3.12+
- Node.js 18+
- Hosted Supabase project
- Optional: Pinecone account for vector features
- Optional: AI provider keys (Gemini/OpenAI/custom endpoint)

### Fastest Start (Web + API)

```bash
./run-dev.sh
```

Starts:
- Backend: `http://localhost:8000`
- Frontend: `http://localhost:3000`
- API docs: `http://localhost:8000/api/v1/docs`

### Manual Start

Backend:

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

Frontend:

```bash
cd frontend
npm install
npm run dev
```

Flutter:

```bash
cd flutter
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:8000 --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
```

## Environment Configuration

All required keys for this workspace are already present in `.env`.

Reference templates:
- Backend: `backend/.env.example`
- Frontend: `frontend/.env.example`
- Flutter: `flutter/.env.example`

Common keys:

- Backend Supabase: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`
- Frontend: `VITE_SUPABASE_URL`, `VITE_SUPABASE_PUBLISHABLE_KEY`, `VITE_API_BASE_URL`
- Flutter: `API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`
- AI: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*`, `AI_OPENAI_*`, `AI_CUSTOM_*`

## Backend API Domains

Route modules in `backend/app/api/v1/`:

- `auth.py`: auth and token flows
- `users.py`: profile/settings/preferences
- `items.py`: wardrobe item CRUD and metadata
- `outfits.py`: outfit CRUD and generation-related flows
- `ai.py`: extraction/generation and AI operations
- `ai_settings.py`: provider settings and health checks
- `batch_processing.py`: batch extraction jobs and SSE streams
- `recommendations.py`: recommendation endpoints
- `calendar.py`: calendar planning endpoints
- `weather.py`: weather-related endpoints
- `gamification.py`: streaks/achievements/leaderboard
- `photoshoot.py`: photoshoot generation and demo/use-case endpoints
- `social_import.py`: social account/media import (feature-flagged)
- `shared_outfits.py`: public shared outfit access/feedback
- `subscription.py` and `referral.py`: billing/referral flows
- `feedback.py` and `waitlist.py`: support and pre-launch endpoints

## Documentation

See `docs/README.md` for the full index.

Recommended starting points:
- Complete implementation map: `docs/PROJECT_OVERVIEW.md`
- Setup: `docs/5-development/setup.md`
- Architecture: `docs/2-technical/architecture.md`
- API spec: `docs/2-technical/api-spec.md`

## Validation Commands

- Backend tests: `cd backend && pytest`
- Frontend lint: `cd frontend && npm run lint`
- Frontend build/type check: `cd frontend && npm run build`
- Flutter tests: `cd flutter && flutter test`
- Remotion preview: `cd remotion && npm run dev`

## Notes

- Local Docker-based workflows are intentionally not used in this project workflow.
- Keep business logic in backend services and avoid route-layer bloat.
- Update docs whenever endpoint, schema, feature, or env changes are made.
