# FitCheck AI Backend

FastAPI backend for FitCheck AI.

## Responsibilities

- Exposes versioned REST API under `/api/v1/*`
- Handles authentication and token verification
- Orchestrates wardrobe, outfit, recommendation, photoshoot, social, referral, and subscription flows
- Integrates with Supabase (Postgres + storage)
- Integrates with configurable AI providers (Gemini/OpenAI/custom)
- Supports optional vector search and social import flows

## Main Entry Points

- App entry: `app/main.py`
- Config: `app/core/config.py`
- Routes: `app/api/v1/`
- Services: `app/services/`
- Models: `app/models/`
- DB access: `app/db/connection.py`
- Migrations: `db/supabase/migrations/`

## Quick Start

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

URLs:
- API: `http://localhost:8000`
- Swagger: `http://localhost:8000/api/v1/docs`
- ReDoc: `http://localhost:8000/api/v1/redoc`
- Health: `http://localhost:8000/health`

## Environment

Template: `backend/.env.example`

Core keys:
- Supabase: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`
- AI provider config: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*`, `AI_OPENAI_*`, `AI_CUSTOM_*`
- Optional integrations: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, `META_OAUTH_*`

## Route Domains

Current route modules in `app/api/v1/`:
- `auth.py`
- `users.py`
- `items.py`
- `outfits.py`
- `shared_outfits.py`
- `recommendations.py`
- `calendar.py`
- `weather.py`
- `gamification.py`
- `ai.py`
- `ai_settings.py`
- `batch_processing.py`
- `photoshoot.py`
- `subscription.py`
- `referral.py`
- `feedback.py`
- `waitlist.py`
- `demo.py`
- `social_import.py` (feature-flagged)

## Testing

```bash
cd backend
pytest
```

## Development Notes

- Keep endpoint handlers thin; move domain logic into `app/services/`.
- Prefer service abstractions over direct integration logic inside routes.
- Use hosted Supabase; do not run Supabase locally.
