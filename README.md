# FitCheck AI

FitCheck AI is a multi-platform wardrobe intelligence product with AI-assisted item extraction, outfit planning, outfit generation, recommendations, and social sharing.

## Monorepo apps

- `backend/` — FastAPI API and business logic
- `frontend/` — React + TypeScript web app (Vite)
- `flutter/` — Flutter mobile app (GetX)
- `remotion/` — Remotion promo/video compositions
- `docs/` — Agent-first knowledge base (product, design, plans, quality)
- `scripts/` — Harness checks (architecture + docs structure)

## Agent / contributor maps

- **Agents:** `AGENTS.md` and `CLAUDE.md` (identical short maps)
- **Architecture layers:** `ARCHITECTURE.md`
- **Knowledge hub:** `docs/README.md`

## Core capabilities

- AI wardrobe extraction (single or batch, SSE jobs)
- Wardrobe CRUD, filtering, condition tracking
- Outfit creation and generation
- Virtual try-on
- Calendar and weather-informed planning
- Recommendations (match, complete look, gap-oriented)
- Photoshoot image generation
- Social sharing and public outfit links
- Gamification, referral, subscription flows
- Optional social import pipeline

## High-level architecture

1. Web and mobile clients call FastAPI under `/api/v1/*`.
2. Routes coordinate domain services (`backend/app/services/`).
3. Supabase provides Postgres + storage + auth.
4. AI provider abstraction (custom/OpenAI; Gemini for embeddings).
5. Optional vector features use Pinecone.

Details and **enforced layer rules:** `ARCHITECTURE.md`.

## Local development

Hosted Supabase only. **Do not** use Docker or local Supabase for development.

### Prerequisites

- Python 3.12+
- Node.js 18+
- Hosted Supabase project
- Optional: Flutter, Pinecone, AI provider keys

### Fastest start (web + API)

```bash
./run-dev.sh
```

- Backend: `http://localhost:8000`
- Frontend: `http://localhost:3000`
- API docs: `http://localhost:8000/api/v1/docs`

### Manual start

```bash
# Backend
cd backend && python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend
cd frontend && npm install && npm run dev
```

Full setup: `docs/references/local-setup.md`.

## Environment

Workspace `.env` values are expected to be provisioned. Templates:

- `backend/.env.example`
- `frontend/.env.example`
- `flutter/.env.example`

## Documentation map

| Need | Location |
|------|----------|
| Agent map | `AGENTS.md` / `CLAUDE.md` |
| Architecture | `ARCHITECTURE.md` |
| Knowledge hub | `docs/README.md` |
| Backend depth | `docs/BACKEND.md` |
| Frontend depth | `docs/FRONTEND.md` |
| Product specs | `docs/product-specs/` |
| Setup | `docs/references/local-setup.md` |
| Quality / debt | `docs/QUALITY_SCORE.md`, `docs/exec-plans/tech-debt-tracker.md` |
| Exec plans | `docs/exec-plans/` |

## Validation

```bash
./scripts/check_all.sh
cd backend && pytest
cd frontend && npm run lint && npm run build
cd flutter && flutter test
```

Harness CI: docs structure + architecture (`.github/workflows/docs-ci.yml`); backend also runs architecture in `backend-ci.yml`.

## Notes

- Keep business logic in services; keep routes thin.
- Update docs in the same change as behavior/API/env changes.
- Do not grow `AGENTS.md`/`CLAUDE.md`—update `docs/` instead.
