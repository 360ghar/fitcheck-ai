# Backend

Last updated: 2026-07-22

Deep guide for the FastAPI app under `backend/`. Architecture layers: root `ARCHITECTURE.md`. Package-local agent entry: `backend/CLAUDE.md` (thin pointer here).

## Commands

```bash
cd backend
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
pytest
pytest -v --cov=app
ruff check .
```

- Swagger: `http://localhost:8000/api/v1/docs`
- ReDoc: `http://localhost:8000/api/v1/redoc`
- Health: `http://localhost:8000/health`

## Application structure

```text
app/
├── main.py              # app, middleware, routers, error handlers
├── api/v1/              # route modules + deps.py
├── core/                # config, security, exceptions, middleware, logging
├── models/              # Pydantic schemas
├── services/            # business logic + integrations
├── db/connection.py     # Supabase clients
└── agents/              # extraction / image generation agents
```

## Layers (summary)

- **Routes** (`api/v1/`): HTTP only; use `Depends(get_db)`, `Depends(get_current_user)`.
- **Services**: domain logic, AI, storage, jobs.
- **Models**: request/response contracts.
- **Core**: settings, JWT, exceptions, middleware.
- **DB**: service-role and publishable Supabase clients.

Forbidden: services/models/core importing `app.api`. See `scripts/check_architecture.py`.

## Database

- Hosted Supabase via `supabase-py`.
- `get_service_client()` for elevated route work; `get_client()` for some auth flows.
- Migrations: `backend/db/supabase/migrations/` (baseline `001_full_schema.sql`).
- Generated overview: `docs/generated/db-schema.md`.
- Model notes: `docs/references/data-models.md`.

Key tables (non-exhaustive): `users`, `user_preferences`, `user_settings`, `user_ai_settings`, `items`, `item_images`, `outfits`, `outfit_images`, `calendar_events`, `user_streaks`, `shared_outfits`, subscription/referral tables, photoshoot + social import tables.

## Auth

- Supabase Auth issues JWTs; backend verifies with `SUPABASE_JWT_SECRET`.
- `get_current_user` loads user from `sub` claim.
- Details: `docs/references/auth-flow.md`.

## Errors

Custom exceptions in `app/core/exceptions.py` (`FitCheckException` hierarchy). Handlers return:

```json
{
  "error": "Human-readable message",
  "code": "ERROR_CODE",
  "details": {},
  "correlation_id": "uuid"
}
```

## Middleware order

1. `CorrelationIdMiddleware`  
2. `RequestLoggingMiddleware`  
3. `CORSMiddleware`  

## AI provider system

Configured in `app/core/config.py` / env:

- **Custom** (default): Agnes AI OpenAI-compatible gateway (`apihub.agnes-ai.com`)
- **OpenAI**: GPT-4o / DALL-E style paths when selected

Typical custom stack:

- Chat/vision: `agnes-2.0-flash` via `/v1/chat/completions`
- Images: `agnes-image-2.1-flash` primary → `agnes-image-2.0-flash` fallback via `/v1/images/generations`
- Transient failures (429/503/timeout/empty images) retry fallback; non-transient raise
- Embeddings: Google `google.genai` via `AI_GEMINI_API_KEY` (not a selectable chat provider)

User AI settings: `user_ai_settings` with encrypted keys (`AI_ENCRYPTION_KEY`).

Services: `ai_service.py`, `ai_provider_service.py`, `ai_settings_service.py`, `ai_provider_health_service.py`.

## Runtime flows

### Batch wardrobe extraction (primary multi-upload path)

Pipeline: `batch_processing.py` + `batch_extraction_service.py` + `batch_job_service.py`.

1. **Client prepare:** optional compress (≤~1568px longest edge, JPEG ~0.85); keep originals for save fallback.
2. **Start job:**
   - Web: `POST /api/v1/ai/batch-extract-multipart` (binary files)
   - Flutter / legacy: `POST /api/v1/ai/batch-extract` (JSON base64)
3. Backend returns `202` with `job_id` + `sse_url`; work continues in the background.
4. **Extract:** images processed in parallel; each completion emits SSE `image_extraction_complete`.
5. **Generate (optional `auto_generate`):** as items appear, product-image generation is enqueued and **overlaps** remaining extracts (concurrency capped, historically up to 5).
6. **Client review:** UI may open review as soon as items exist; studio images fill in via SSE. User can save mid-generation using original photos when studio images are not ready.
7. **Persist:** client uploads chosen images via `POST /api/v1/items/upload` and creates items via `POST /api/v1/items`.
8. Optional embeddings/vector indexing after item create.

Synchronous helpers still exist for one-offs (`POST /ai/extract-items`, `POST /ai/generate-product-image`); wardrobe multi-upload is job-based.

### Outfit generation

1. Client submits selected items and generation options.
2. Backend calls AI provider for image generation (respect rate limits via `app.services.rate_limit`).
3. Backend stores generated images and updates outfit records.
4. Client receives image URLs and render metadata.

### Recommendations

1. Client requests recommendations.
2. Backend aggregates wardrobe/profile context.
3. Optional embedding/similarity via vector service (Pinecone when configured).
4. Ranked recommendations returned.

### Rate limiting helper

Subscription-aware AI limits live in `app.services.rate_limit` (`rate_limited_operation`), not `app.core` (core must not import services). IP-based demo limits remain in `app.core.ip_rate_limit`.

## Route registration

Modules wired from `main.py` include: auth, users, items, outfits, shared_outfits, recommendations, calendar, weather, gamification, ai, ai_settings, batch_processing, photoshoot, feedback, waitlist, demo, subscription, referral, social_import (flagged), blog.

## Adding an endpoint

1. Route module in `app/api/v1/`  
2. Pydantic models in `app/models/`  
3. Logic in `app/services/`  
4. Register router in `main.py`  
5. Update `docs/references/api-spec.md` if the curated summary is still used; prefer OpenAPI accuracy  

## Environment (high level)

Required: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`  

AI: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*` (embeddings), `AI_CUSTOM_*` / `OPENAI_*` overrides  

Optional: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, social import flags, `AI_ENCRYPTION_KEY`  

Full templates: `backend/.env.example`. Backend also loads repo root `.env`.

## Logging

- `app/core/logging_config.py`
- Files under `backend/logs/`
- `LOG_LEVEL` (default INFO)
- Correlation ID on requests for agent grepping

## API surface reference

Curated: `docs/references/api-spec.md`  
Live: OpenAPI when server runs  

## Tests

- `backend/tests/`, `pytest` + `pytest-asyncio`
- CI: `.github/workflows/backend-ci.yml` (ruff + pytest + architecture check)
