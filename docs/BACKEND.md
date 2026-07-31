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

Key tables (non-exhaustive): `users`, `user_preferences`, `user_settings`, `user_ai_settings`, `items`, `item_images`, `outfits`, `outfit_images`, `calendar_events`, `shared_outfits`, subscription/referral tables, photoshoot + social import tables.

`user_streaks` / `user_achievements` exist in the schema but are **read-only in practice** — no code path writes them. They are required by the `/ready` schema check only when `ENABLE_GAMIFICATION=true` (`GAMIFICATION_TABLES` in `app/main.py`), which is off by default.

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
- **Gemini** (opt-in): native `google-genai` SDK, not OpenAI-compatible HTTP - chat/vision/image
  all via `client.aio.models.generate_content`. No per-leg URL config (the SDK talks directly to
  Google); fallback is Gemini-model-to-Gemini-model only, not cross-provider. Bypasses
  `ai_provider_health_service` entirely (no pre-flight probe - a bad key/model/quota surfaces
  from the real call itself). See `app/services/gemini_provider.py`.
- **Hybrid vision leg** (`AI_VISION_PROVIDER=gemini`, opt-in, system-config only - no BYOK):
  keeps chat/image on the Custom provider (Agnes) but routes the vision leg's *primary* call
  directly to Google's native API via an internal `GeminiProvider` instance, falling back to
  Agnes (`AI_VISION_FALLBACK_MODEL`) on **any** failure - not just retryable ones, since the
  fallback is a genuinely different vendor that may succeed where Gemini refused. This is the
  first real cross-provider fallback in the codebase (see `AIProviderService._chat_with_vision_via_native_gemini`
  in `ai_provider_service.py`). `AI_VISION_API_URL` must stay blank in this mode -
  `config_health.py` flags it as an error otherwise, since it becomes dead config once the leg
  is redirected.

Typical custom stack:

- Chat/vision: `gemini-3.6-flash` (primary) / `agnes-2.5-flash` (fallback after 1 retry) via `/v1/chat/completions`
- Images: `agnes-image-2.1-flash` primary → `agnes-image-2.0-flash` fallback via `/v1/images/generations`
- Transient failures (429/503/timeout/empty images) retry fallback; non-transient raise
- Embeddings: Google `google.genai` via `AI_GEMINI_API_KEY` (not the same code path as the
  native Gemini chat/vision/image provider above, though it shares the same key)

Env: one flat `AI_*` per-leg scheme. Each of chat / vision / vision-fallback / image / image-fallback can have its OWN `AI_<LEG>_API_URL` + `AI_<LEG>_API_KEY` + `AI_<LEG>_MODEL`; a blank url/key inherits its parent (`vision`→`chat`, `vision_fallback`→`vision`, `image`→`chat`, `image_fallback`→`image`), so a single-host setup only needs the `AI_CHAT_*` trio. See `backend/.env.example`. Gemini's own `AI_GEMINI_CHAT_MODEL` / `AI_GEMINI_VISION_MODEL` / `AI_GEMINI_IMAGE_MODEL` are separate settings with no per-leg URLs - do not confuse them with the Custom-leg vars above.

Provider dispatch is registry-driven: `AIProvider` (enum) → concrete class, via `PROVIDER_REGISTRY` in `app/services/ai_provider_interface.py`. `AIProviderService` (OpenAI-compatible) registers itself under both `OPENAI` and `CUSTOM`; `GeminiProvider` registers under `GEMINI`. Adding a fourth provider means writing one class + `@register_provider(...)`, not editing the factory functions.

User AI settings: `user_ai_settings` with encrypted keys (`AI_ENCRYPTION_KEY`).

Services: `ai_service.py` (embeddings only), `ai_provider_service.py` (OpenAI-compatible provider + shared factories), `ai_provider_interface.py` (common interface + registry), `gemini_provider.py` (native Gemini provider), `ai_settings_service.py`, `ai_provider_health_service.py`.

## Runtime flows

### Batch wardrobe extraction (primary multi-upload path)

Pipeline: `batch_processing.py` + `batch_extraction_service.py` + `batch_job_service.py`.

1. **Client prepare:** optional compress (≤~1568px longest edge, JPEG ~0.85); keep originals for save fallback.
2. **Start job:**
   - Web: `POST /api/v1/ai/batch-extract-multipart` (binary files)
   - Flutter / legacy: `POST /api/v1/ai/batch-extract` (JSON base64)
3. Backend returns `202` with `job_id` + `sse_url`; work continues in the background.
4. **Extract:** images processed in parallel; each completion emits SSE `image_extraction_complete`.
5. **Generate (optional `auto_generate`):** as items appear, product-image generation is enqueued and **overlaps** remaining extracts (capped by `AI_GENERATION_CONCURRENCY`, default 30; see "Batch concurrency caps" below). Reference-image strategy per item (`resolve_product_reference_image` in `app/utils/image_processing.py`): a single-item source photo is sent as-is; a multi-item photo crops to the item's bbox when it's confident and not near-full-frame, otherwise the reference is dropped entirely and generation falls back to text-only from the dense description — the full uncropped multi-item photo is never sent, since that reliably caused the model to bleed in other garments or pass the photo through unchanged. Each generated product image is then **matted** (`app/utils/background_removal.py`) and returned as a transparent WebP; see "Generated image transparency" below.
6. **Client review:** UI may open review as soon as items exist; studio images fill in via SSE. User can save mid-generation using original photos when studio images are not ready.
7. **Persist:** client uploads chosen images via `POST /api/v1/items/upload` and creates items via `POST /api/v1/items`.
8. Optional embeddings/vector indexing after item create.

Synchronous helpers still exist for one-offs (`POST /ai/extract-items`, `POST /ai/generate-product-image`); wardrobe multi-upload is job-based.

#### Batch concurrency caps

The pipeline enforces two **process-wide** `asyncio.Semaphore` ceilings (singletons in `app/core/concurrency.py`, shared across all concurrent jobs on the worker and the outfit-variation fan-out in `image_generation_agent`):

| Env var | Default | Caps |
|---------|---------|------|
| `AI_EXTRACTION_CONCURRENCY` | 30 | concurrent per-image vision extraction calls |
| `AI_GENERATION_CONCURRENCY` | 30 | concurrent per-item product-image generations (also gates `generate_variations`) |

Each matte adds ~110ms of GIL-held C work per generated image, run via `asyncio.to_thread` so it never sits on the event loop serving the SSE stream (a full-resolution flood fill would have been ~562ms and, at 30-wide, ~17s of serialized CPU).

These are NOT per-job: two simultaneous batch jobs draw from the same pool. A per-job `generation_batch_size` (route default = `AI_GENERATION_CONCURRENCY`) can only tighten below the global ceiling, never exceed it. Raise cautiously: each in-flight request holds a multi-MB base64 buffer, and shared AI gateways can 429/503 under high parallelism. Floors at 1 so a misconfigured 0/negative value cannot deadlock the pipeline.

### Outfit generation

1. Client submits selected items (each with its wardrobe `item_id`) and generation options to `POST /api/v1/ai/generate-outfit`.
2. **Resolve garment references** (`resolve_outfit_item_references` in `app/services/item_reference_service.py`): one batched, **user-scoped** query over `items` + `item_images` for the submitted ids, then download + downscale (`AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE`, default 768) with process-wide bounded concurrency. Up to `AI_MAX_OUTFIT_ITEMS` text items are accepted (default 100), but only the first `AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES` stored image references (default 12) are resolved. This cap is current behavior; the active no-cap acceptance criterion is not verified. Ownership is enforced by `.eq("user_id", …)` on the parent `items` row, since `item_images` has no `user_id` of its own; another user's id resolves to nothing. Any failure (missing image, dead URL, DB error) degrades that item to text-only rather than failing the request. Runs inside the rate limit (one generation charge regardless of reference count) but outside `with_retry`.
3. `image_generation_agent.generate_outfit` builds one inline image list — avatar first when used, then garments in item order — and a prompt that binds `IMAGE n` → `Item n` (`_build_reference_map` in `app/agents/image_generation_agent.py`, `GARMENT_REFERENCE_LOCK` in `app/agents/prompt_fidelity.py`). Items with no image are explicitly told to render from their description. `IDENTITY_LOCK` stays ahead of the garment block so the avatar remains the sole source for face/body/hair/skin. Multi-image has to go through `chat(..., response_modalities=["TEXT","IMAGE"])`, since `generate_image()` takes a single `reference_image`; with zero images the pre-existing text-to-image path is used unchanged.
4. Backend stores generated images and updates outfit records.
5. Client receives image URLs and render metadata.

Sending no `item_id` is still valid and produces the previous text-only prompt byte-for-byte. Grep `Outfit item references resolved` and `AI image generation request started` (`reference_images=`) to see how many references a generation actually carried.

### Generated image transparency

No provider we use can return an alpha channel (`_generate_image_via_images_api` sends a fixed payload with no `output_format`; `gemini_provider` discards the response mime), so the backdrop is cut **after** generation by `app/utils/background_removal.py` — Pillow only, no `rembg`, no `onnxruntime`, no hosted API. Output is **WebP q85 with alpha** (`MATTE_FORMAT`), measured at roughly half the bytes of the opaque JPEG it replaces, so the in-memory batch job and its SSE payloads shrink.

| Path | Matted? |
|------|---------|
| `generate_product_image` | yes |
| `generate_outfit` flat-lay branch (incl. `generate_flat_lay`, `include_model=False`) | yes |
| `generate_outfit` avatar branch, generic-model branch, `generate_try_on` | **no** — a threshold matte cannot cut hair, and the guards do not catch it (a full-body figure lands ~0.70–0.80 transparent, under `MAX_TRANSPARENT_FRACTION`) |

- `background="transparent"` means "render on a matte-optimal flat white, then cut the alpha server-side". It resolves to the **same** prompt fragment as `"white"` / `"studio white"` via `_resolve_background`, which is why no client change was needed. `"gray"` / `"gradient"` stay honest: they fail the matte's first guard and keep their opaque original.
- Three guards; any failure returns the **original bytes unmodified**: no white backdrop found (`skipped_no_background`), matte ate the subject (`rejected_ate_subject`), centre of frame went transparent (`rejected_center_transparent`). Grep `Background matte finished` for `status` / `transparent_fraction` / `center_opacity`.
- `app/utils/image_processing.py` is the deliberate **inverse** and must stay that way: it flattens alpha onto white and encodes JPEG for the MODEL. A matted item image downloaded back as a garment reference is flattened there, which is exactly the "clean isolated garment on white" the reference prompts ask for.
- Object content types are now sniffed from the bytes at every upload site (`StorageService._sniff_content_type`). Before this, any `storage.upload()` without explicit `file_options` inherited storage3's `content-type: text/plain;charset=UTF-8` default, so every item/outfit/avatar object was served as text/plain.

#### Backfilling the existing corpus

Images generated before the matte landed are still opaque JPEGs on white. `backend/scripts/backfill_transparent_backgrounds.py` re-mattes them **in place** — same storage key, `upsert=true`, `content-type: image/webp` — so `image_url` and `thumbnail_url` never change and no denormalised copy or shared link goes stale. Read the module docstring before running it; the extension deliberately ends up disagreeing with the bytes, and that is not a defect to "fix".

Targets `item_images` and `outfit_images WHERE generation_type='ai'` only. Never `items.source_image_url` (the original photo has a real background), never `social_import_items` (temporary review-queue objects), never `outfit_generations.image_urls` (denormalised copies that stay valid for free).

Run it in this order — step 2 is the real visual check, bounded to one account before anyone else's wardrobe is touched:

```bash
cd backend && source .venv/bin/activate
DRY_RUN=1 python scripts/backfill_transparent_backgrounds.py                  # writes nothing; prints the guard distribution + projected storage delta
ONLY_USER_ID=<your-uuid> LIMIT=20 python scripts/backfill_transparent_backgrounds.py
LIMIT=200 CONCURRENCY=4 python scripts/backfill_transparent_backgrounds.py
CONCURRENCY=8 python scripts/backfill_transparent_backgrounds.py
TABLES=outfit_images python scripts/backfill_transparent_backgrounds.py       # expect most to be skipped by G1: they are model shots
```

A JSONL audit (`backend/logs/transparent_backfill.jsonl`) makes the run resumable — rows with a terminal action are skipped, `error` rows stay retryable. A rejected or skipped matte writes **nothing**: no upload, no DB patch. If more than 10% of decoded images are rejected the script says so loudly and names `WHITE_MIN_CHANNEL` — that is the signal the generation prompts drifted from what the algorithm assumes, and it is worth stopping for.

### Recommendations

1. Client requests recommendations.
2. Backend aggregates wardrobe/profile context.
3. Optional embedding/similarity via vector service (Pinecone when configured).
4. Ranked recommendations returned.

### Rate limiting helper

Subscription-aware AI limits live in `app.services.rate_limit` (`rate_limited_operation`), not `app.core` (core must not import services). IP-based demo limits remain in `app.core.ip_rate_limit`.

## Route registration

Modules wired from `main.py` include: auth, users, items, outfits, shared_outfits, recommendations, calendar, weather, gamification (flagged), ai, ai_settings, batch_processing, photoshoot, feedback, waitlist, demo, subscription, referral, social_import (flagged), blog.

### Flagged routes — two different shapes

| Flag | Default | Shape when off |
|------|---------|----------------|
| `ENABLE_SOCIAL_IMPORT` | `true` | **Router not mounted.** The paths 404 and vanish from OpenAPI. |
| `ENABLE_GAMIFICATION` | `false` | **Router stays mounted.** Handlers return `200` with a neutral zeroed payload. |

The gamification asymmetry is deliberate and must not be "made consistent".
`flutter/lib/features/dashboard/controllers/dashboard_controller.dart:60-67` runs an
unguarded `Future.wait([fetchDashboard(), fetchStreak()])` under one `catch`, so a
404 on `/api/v1/gamification/streak` rejects the whole wait, leaves `dashboard.value`
unassigned, and renders a permanent error banner on the mobile home screen. The flag
is therefore enforced per handler in `app/api/v1/gamification.py` (which also kills
the write-on-GET that inserted a zeroed `user_streaks` row). Unmounting the router
only becomes safe after the Flutter side is fixed — see TD-034 in
`docs/exec-plans/tech-debt-tracker.md`. Guarded by `backend/tests/test_gamification_flag.py`.

## Adding an endpoint

1. Route module in `app/api/v1/`  
2. Pydantic models in `app/models/`  
3. Logic in `app/services/`  
4. Register router in `main.py`  
5. Update `docs/references/api-spec.md` if the curated summary is still used; prefer OpenAPI accuracy  

## Environment (high level)

Required: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`  

AI: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*` (embeddings), `AI_CHAT_*`/`AI_VISION_*`/`AI_IMAGE_*` (per-leg, see `.env.example`), `AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE` (garment reference size, default 768), `AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES` (default 12), `AI_OUTFIT_ITEM_REFERENCE_DOWNLOAD_CONCURRENCY` (default 8), and `AI_MAX_OUTFIT_ITEMS` (default 100)

Optional: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, social import flags, `ENABLE_GAMIFICATION` (default `false`), `AI_ENCRYPTION_KEY`  

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
