# FitCheck AI Backend

FastAPI backend for FitCheck AI.

## Responsibilities

- Exposes versioned REST API under `/api/v1/*`
- Handles authentication and token verification
- Orchestrates wardrobe, outfit, recommendation, photoshoot, social, referral, and subscription flows
- Integrates with Supabase (Postgres + auth) and a Cloudflare R2 bucket (S3-compatible storage)
- Integrates with configurable AI providers (OpenAI/custom)
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
- Storage (Cloudflare R2, S3-compatible): `OBJECT_STORAGE_ENDPOINT`, `OBJECT_STORAGE_REGION`, `OBJECT_STORAGE_ACCESS_KEY_ID`, `OBJECT_STORAGE_SECRET_ACCESS_KEY`, `OBJECT_STORAGE_BUCKET`
- AI provider config: `AI_DEFAULT_PROVIDER`, `AI_OPENAI_*`, `AI_CHAT_*`/`AI_VISION_*`/`AI_IMAGE_*` (per-leg)
- Embeddings (separate from the provider config above): `AI_GEMINI_API_KEY`, `AI_GEMINI_EMBEDDING_MODEL`
- Optional integrations: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, `META_OAUTH_*`

All file uploads/downloads go through the private Cloudflare R2 bucket via
`app/services/object_storage.py` (`S3StorageBackend`, `aioboto3`), wrapped by
`app/services/storage_service.py`. The DB stores bucket keys; clients receive
short-lived presigned GET URLs. See `docs/BACKEND.md` → Storage.

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
# From backend/ so the `app` package is importable
PYTHONPATH=. pytest
```

## Railway (production deploy)

This monorepo keeps Railway config under `backend/`, not the repo root:

- Config file: `backend/railway.json`
- Dockerfile: `backend/Dockerfile`
- Healthcheck: `GET /health` (see `railway.json`)

Railway **Config-as-Code does not follow Root Directory**. Set service settings to:

| Setting | Value |
|---------|--------|
| Root Directory | `/backend` |
| Config as Code | `/backend/railway.json` |
| Watch Paths (optional) | `/backend/**` |

If Config as Code is left as `railway.json`, Railway looks at the **repo root** and fails with `service config at 'railway.json' not found` even though `backend/railway.json` exists.

Required env vars on the service (no defaults): `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`.

Storage: set the canonical `OBJECT_STORAGE_ENDPOINT` (Cloudflare R2: `https://<accountid>.r2.cloudflarestorage.com`), `OBJECT_STORAGE_REGION=auto`, `OBJECT_STORAGE_ACCESS_KEY_ID`, `OBJECT_STORAGE_SECRET_ACCESS_KEY`, `OBJECT_STORAGE_BUCKET` as service variables. See the Storage section above.

### Health probes

| Path | Role | Notes |
|------|------|--------|
| `GET /health` | **Liveness** (Railway healthcheck) | Process up only. No DB. Includes `rss_mb` + `commit`. |
| `GET /ready` | Readiness / operators | Cached schema status. Not used for restarts. |

### Diagnosing restarts (OOM / crash loop)

1. Railway → service → **Metrics**: memory sawtooth to the plan limit right before restarts → OOM.
2. Railway → **Deployments / events**: exit code `137` is almost always OOM-kill.
3. Railway → **Logs** around the last lines before death: look for `process_memory` / `batch_job_created` / `photoshoot_job_created` with large `payload_mb`.
4. Confirm plan RAM (512MB / 1GB / …). Raise memory **only after** concurrency/base64 caps are deployed; otherwise the next spike still OOMs.

**`Stopping Container` is not an app crash.** That line is Railway sending SIGTERM (new deploy, replica replace, scale-down, or sleep). Look for:

- `FitCheck AI shutting down (commit=…)` + `process_memory … reason=shutdown` → clean platform stop
- Sudden death with no shutdown line + memory at the plan limit → OOM
- Python traceback → application bug

Startup is intentionally non-blocking: the process accepts `/health` before schema/Pinecone finish. Logs will show `Accepting traffic; background init scheduled`, then later `Background startup finished` / `Schema readiness check complete`.

Stabilizers in this codebase:

- Max **2** concurrent batch jobs and **2** concurrent photoshoot jobs process-wide (429 when full).
- Batch image base64 capped at ~10MB; source reference base64 released after extraction/generation.
- Generated images kept for GET status / poll fallback until finished job TTL (~15m); SSE event history cleared on complete (it duplicated base64).
- Job TTLs ~15–30m; extraction cache capped at 200 entries.
- Uvicorn `--limit-concurrency 50 --timeout-keep-alive 5`.
- Production logs go to stdout only (no session files under `/app/logs`).

## Development Notes

- Keep endpoint handlers thin; move domain logic into `app/services/`.
- Prefer service abstractions over direct integration logic inside routes.
- Use hosted Supabase; do not run Supabase locally.
