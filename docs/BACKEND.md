# Backend

Last updated: 2026-08-08

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
- Health: `http://localhost:8000/health` — plus `GET /api/v1/health` as a
  compatibility alias serving the same cheap liveness payload (probes pointed at
  the prefixed path stop 404ing; see `app/api/v1/health.py`).

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

Services not named in their own sections: `social_auth_service.py`,
`social_oauth_service.py`, `social_scraper_service.py`, `social_url_service.py`
(social import), `token_refresh_service.py` (OAuth token refresh),
`job_persistence.py` (durable job mirror rows), `extraction_cache_service.py`
(extraction result cache), `outfit_service.py` (outfit lifecycle, incl. the
reconnect-protected delete), `feedback_service.py`, `promo_service.py`,
`astrology_service.py`.

## Database

- Hosted Supabase via `supabase-py`. The sync client's singleton pool can
  die on gateway restarts/idles (`ConnectionTerminated`), and httpcore's HTTP/2
  pool can throw `RuntimeError: deque mutated during iteration` under
  concurrent shared-client use; `app/utils/db.py` `is_db_connection_error` +
  `execute_with_reconnect`/`run_sync_with_reconnect` detect both classes and
  rebuild the client and retry once on the hot paths. Structured PostgREST
  responses (`APIError`) are retried only when the `code` is a bare gateway
  HTTP status (429/500/502/503/520/521/522/524 — a non-PostgREST-JSON 5xx/429
  body, i.e. the gateway itself in a bad state); deterministic SQLSTATE/PGRST
  codes (`22P02`, `PGRST202`, …) never trigger a rebuild (2026-08-07: a
  deterministic `22P02` from a jsonb `contains` filter was misclassified via
  the `invalid input` text marker and retried 3x before 500ing); JSONB `@>`
  filters must use `jsonb_contains()` (JSON array literal) — `contains(list)`
  emits a Postgres array literal (`{a,b}`) that JSONB columns reject. Covered
  so far:
  `/items`, `/auth/oauth/sync`, `/outfits` (list + create + the delete handlers
  — `DELETE /{outfit_id}`, `/{outfit_id}/items/{item_id}`,
  `/{outfit_id}/images/{image_id}`; reconnected 2026-08-07), `get_subscription`
  (also the shared choke point behind `/subscription`, `/referral/*`,
  `/users/dashboard`), usage check/increment + `reserve/release_ai_usage`,
  AI settings, `/users/me` + `/settings` + `/preferences`, referral service,
  and object-storage uploads via the S3 backend (2026-08-01 + 2026-08-03 incidents).
- `get_service_client()` for elevated route work; `get_client()` for some auth flows.
- Migrations: `backend/db/supabase/migrations/` (baseline `001_full_schema.sql`).
- Generated overview: `docs/generated/db-schema.md`.
- Model notes: `docs/references/data-models.md`.

Key tables (non-exhaustive): `users`, `user_preferences`, `user_settings`, `user_ai_settings`, `items`, `item_images`, `outfits`, `outfit_images`, `calendar_events`, `shared_outfits`, subscription/referral tables, photoshoot + social import tables.

`user_streaks` / `user_achievements` exist in the schema but are **read-only in practice** — no code path writes them. They are required by the `/ready` schema check only when `ENABLE_GAMIFICATION=true` (`GAMIFICATION_TABLES` in `app/main.py`), which is off by default.

## Storage

File storage is a **private S3-compatible bucket** — Railway Bucket (since the 2026-08-04 migration) or Cloudflare R2 (2026-08-05 egress RCA; R2 egress is $0). The S3 layer is provider-agnostic; moving providers is an env repoint + object copy, no storage code change. The DB (Postgres) + Auth stay on Supabase; only file storage changes.

- **S3 backend** — `app/services/object_storage.py` implements `S3StorageBackend`, a thin `aioboto3` wrapper (upload / download / copy / delete / delete_many / presigned GET / list_keys / close). `get_storage_backend()` returns a process-wide lazy singleton; `close_storage_backend()` releases it at shutdown. The constructor accepts explicit endpoint/region/keys/bucket overrides — used by `storage_inventory.py`'s `--endpoint/--bucket` flags to inspect a bucket other than the configured one (e.g. the old bucket after a provider cutover).
- **Service layer** — `app/services/storage_service.py` keeps its existing public method signatures and return shapes so callers change as little as possible; internals now talk to `S3StorageBackend`. `_build_key(user_id, category, ext)` replaces the old filename generator.
- **Key layout** — `{user_id}/{category}/{uuid4hex}.{ext}` (no timestamps). Categories: `items`, `outfits`, `avatars`, `sources`, `feedback`. Temporary previews and user-saved renders live in shared **top-level folders** — `tmp/{user_id}/{source}/...` (photoshoot / batch / social-import review previews) and `generated/{user_id}/{image_type}/...` (try-on / outfit / product renders saved with `save_to_storage=true`) — so every preview in the bucket shares ONE common prefix and the whole folder can be listed or cleared in a single pass (`scripts/cleanup_temp_assets.py`). Extensions derive from sniffed bytes (`EXTENSION_BY_MIME`). `promote_temp_image_to_item` moves `tmp/...` → `items/...` via an S3 server-side copy. The serving allowlist (`app/api/v1/images.py`, `infra/images-worker/worker.js`) accepts both the top-level form and the legacy per-user form (`{user_id}/tmp|generated/...`) until `scripts/migrate_temp_keys_layout.py` has converted every old key.
- **Accepted upload formats** — `SUPPORTED_UPLOAD_MIME_TYPES` (`app/utils/image_processing.py`) and `ALLOWED_IMAGE_EXTENSIONS` (`app/services/storage_service.py`) gate every upload: JPEG, PNG, WebP, GIF, AVIF, plus HEIC/HEIF, BMP, TIFF. Every stored image is normalized by `StorageService._normalize_upload_bytes` (run on the bounded image executor after `_validate_image`) to the **storage compression profile**: HEIC/HEIF/BMP/TIFF are transcoded to WebP (browsers cannot render them), and everything is downscaled to `STORAGE_MAX_EDGE` (2048px) and re-encoded as WebP at `STORAGE_QUALITY` (82) whenever that is strictly smaller than the input (keep-smaller — an already-optimized WebP or small PNG passes through byte-identical). Animated GIFs pass through untouched. Alpha survives (WebP), so background-removed cutouts stay transparent. The key/content-type are minted from the sniffed final bytes, so converted objects carry `.webp` / `image/webp`. Nothing downstream consumes more than 2048px (AI references are capped at 1568px before leaving the app), so this is lossless at display sizes while cutting stored bytes ~3-4x.
- **Thumbnails** — every canonical upload (items/outfits/avatars/sources/feedback) writes a deterministic `{storage_path}_thumb` sibling (smaller of downscaled JPEG / original bytes; `THUMB_MAX_EDGE` / `THUMB_QUALITY`). Promote, delete, delete-multiple and account deletion (`resolve_owned_storage_paths`) all handle thumbs; the inventory script treats `_thumb` keys as referenced. `generate_thumbnails.py` backfills the legacy corpus.
- **Private buckets, presigned URLs** — the bucket is private. The DB stores `storage_path` (the bucket key), never a URL. `image_url` / `thumbnail_url` / `public_url` are **short-lived presigned GET URLs** materialized at read time (default 1h, `OBJECT_STORAGE_PRESIGN_TTL=3600`). `build_object_url` exists only as a stable locator for inventory scripts; the app does not serve public URLs. `materialize_image_urls` / `serve_url` in `app/api/v1/images.py` honor `IMAGE_SERVING_MODE` + `THUMBNAIL_SERVING` (see below).
- **Worker serving mode (`IMAGE_SERVING_MODE=worker`)** — rotating presigned URLs defeat every cache, so the egress RCA adds an optional Cloudflare Worker (`infra/images-worker/`) fronting R2 with **stable path-only URLs**: token auth (HS256 `SUPABASE_JWT_SECRET` or JWKS ES256/RS256), per-user path ownership (404 on mismatch, indistinguishable from missing), path-keyed edge cache. See `docs/SECURITY.md` "Worker serving mode" for the threat model. AI provider-bound fetches always stay presigned (providers cannot send JWTs).
- **SSRF-safe downloads** — `download_to_base64` / `download_and_downscale_to_base64` fetch via the S3 backend by bucket key (`key_from_path`), never from arbitrary URLs.
- **Config** — see `backend/.env.example`:
  - `OBJECT_STORAGE_ENDPOINT`, `OBJECT_STORAGE_REGION`, `OBJECT_STORAGE_ACCESS_KEY_ID`, `OBJECT_STORAGE_SECRET_ACCESS_KEY`, `OBJECT_STORAGE_BUCKET` — the only storage variables the backend reads (no provider-specific aliases).
  - `IMAGE_SERVING_MODE` (`presigned` default | `worker`), `IMAGE_CDN_BASE_URL` (Worker custom domain), `THUMBNAIL_SERVING` (`false` default; emit `thumbnail_url` → `_thumb` keys).
- **Migration tooling** (see `docs/exec-plans/completed/2026-08-04-railway-bucket-migration-contract.md` and `docs/exec-plans/active/2026-08-05-railway-egress-rca.md` for the live execution logs; the one-time Supabase→Railway→R2 copy scripts have been removed — storage is on R2):
  - `backend/scripts/storage_inventory.py` — orphan / missing report against the active bucket (dry-run by default; `--delete` to remove orphans). Thumb-aware: `_thumb` siblings of referenced keys are never orphans. **Part of the weekly storage routine**: run `--delete` (2h grace protects in-flight uploads) alongside `cleanup_temp_assets.py --delete` so DB-unreferenced objects (replaced avatars, deleted-item leftovers, failed uploads) are removed the same week they appear — measured at 192MB / 296 objects before the leak fixes.
  - `backend/scripts/cleanup_temp_assets.py` — **manual weekly cleanup** of the `tmp/` folder (dry-run default; `--delete` to delete; optional `--source` / `--min-age-hours`; JSONL audit). Temp previews are never DB-referenced and become unreachable once their 1h presigned URL expires, so this script is the only thing that removes them.
  - `backend/scripts/migrate_temp_keys_layout.py` — **optional** one-time rewrite of legacy per-user preview keys (`{user}/tmp/...`, `{user}/generated/...`) to the top-level folders (dry-run default; `--apply` to execute; server-side copy-then-delete; idempotent). Not required for correctness: legacy keys keep serving via the dual-layout allowlists and `cleanup_temp_assets.py` removes old-layout tmp objects regardless. Run it (outside active review flows) only if you want a single-layout bucket or R2 lifecycle rules on the `tmp/` prefix.
  - `backend/scripts/generate_thumbnails.py` — backfill `_thumb` siblings for existing canonical keys (dry-run default; `--apply`), resumable via age/audit.
  - `backend/scripts/recompress_assets.py` — one-time backfill of the pre-compression corpus: downloads each canonical/`generated` object, re-encodes to the WebP q82 @ 2048px profile (keep-smaller), overwrites the SAME key in place, and regenerates/backfills the `_thumb` sibling (dry-run default; `--apply`; JSONL audit; resume-safe). Keys are unchanged, so no DB row or client-held URL goes stale.

### AI provider image input

- Request models accept an owned `storage_path` in place of inline base64 (`ExtractItemsRequest`, `ExtractSingleItemRequest`, `GenerateProductImageRequest`, `TryOnRequest`); the route validates ownership (`_owned_storage_path` — canonical keys plus the `tmp/` / `generated/` preview folders) and materializes a fresh presigned URL (`_materialize_image_source`).
- Stored avatar URLs (`users.avatar_url`) are re-materialized from their bucket key before being sent to providers (`_provider_ready_avatar_url`) — the DB holds expiring presigned URLs; external https OAuth avatars pass through, non-https/non-owned URLs are refused.
- `GeminiProvider._decode_image_part` downloads http(s) image URLs server-side with a 10 MB byte cap and an SSRF guard that refuses loopback / link-local / RFC1918 / multicast / reserved / metadata hosts before any fetch.

## Auth

- Supabase Auth issues JWTs; backend verifies with `SUPABASE_JWT_SECRET`.
- `get_current_user` loads user from `sub` claim.
- Details: `docs/references/auth-flow.md`.
- **Referral redemption durability (2026-08-04 RCA):** `redeem_referral`
  persists `users.referred_by_code` BEFORE calling the atomic RPC
  `redeem_referral_atomic` (migrations 022/026; service-role only). A
  transient failure (missing RPC from an unapplied migration, dead pooled
  connection) leaves the hook set, and `process_pending_referral` — wired
  into `login` and `oauth/sync` — completes the grant on the next sign-in
  (the RPC is idempotent). The hook is cleared on definitive rejection
  (invalid/own code) and on success. register/`oauth/sync` surface a
  "will be applied on your next sign-in" block on transient failure instead
  of silence. Boot probe `missing_referral_rpcs` (in `app/utils/db.py`)
  logs a runbook hint when the referral RPCs are absent. Referral credit
  semantics (activation/extension/stacking) live in
  `apply_referral_credit_atomic` (migration 033); repair past silent drops
  with `backend/scripts/repair_pending_referrals.py`.

## Admin API & RBAC

Internal admin console (`admin/` SPA → `admin.fitcheckaiapp.com`) — all
endpoints under the **`/api/v1/admin/*`** prefix (mounted in `main.py` via
`app.api.v1.admin.router`). Every endpoint sits behind `require_admin` or
`require_permission("…")` from `app/api/v1/deps.py`; **the backend is the only
trust boundary** — the UI's permission gating is cosmetic.

- **Roles → permissions** live in `app/core/permissions.py` (pure functions,
  no `app.api` imports so any layer can use them): roles
  `super_admin`/`admin` (`*` = everything), `ops`, `support`, `content_editor`.
  Legacy fallback (`get_user_role`): an explicit admin `role` wins; otherwise
  `is_admin = True` OR an `@fitcheckaiapp.com` email resolves to `admin`,
  preserving the pre-RBAC `blog.py` behavior. Migration `037_admin_roles.sql`
  adds `users.role` + `users.is_admin` + `users.custom_daily_quota` +
  `support_tickets.internal_notes`; `038_audit_events.sql` adds the
  append-only `audit_events` table (service-role-only RLS).
- **Permission vocabulary**: `dashboards.read`, `users.read`/`users.write`,
  `subscriptions.read`/`subscriptions.refund`, `iap.read`, `quotas.read`,
  `ops.read`, `storage.cleanup`, `audit.read`, `content.read`/`content.write`,
  `promo.read`, `feedback.read`/`feedback.write`, `search`. Full matrix in
  `docs/exec-plans/active/2026-08-07-admin-panel.md` and `admin/README.md`.
- **Key endpoint groups** (all under `/api/v1/admin`): `GET /me` (session
  bootstrap: profile + role + permissions), `users` (list/detail/PATCH
  role-is_active/is_admin with self-demotion + last-admin guards/activity),
  `subscriptions` (+ `POST …/refund`, Stripe-only; store-billed rows
  rejected), `iap/transactions` (+ `mark-refunded`, status-only — store
  webhooks stay authoritative), `quotas` (+ `PATCH /users/{id}/quota-override`),
  `dashboards` (overview/top-users/referrals/revenue/trends), `promo-codes`
  (CRUD, gated by `content.write`), `feedback` (status + internal notes),
  `ops` (health, storage inventory + `DELETE …/temp` cleanup), `audit` (trail
  explorer +
  per-entity history), `search`, `settings` (read-only deployment info).
  Blog admin writes stay in `blog.py` (`/api/v1/blog/admin/posts`, …) guarded
  by its local `verify_admin` — now a thin wrapper over the shared role
  resolution; the admin app's content feature is the UI for them.
- **Dashboards aggregates are SQL RPCs, not PostgREST selects** — this
  project's PostgREST has select-side aggregates disabled
  (`db-aggregates-enabled = false`) and the legacy bare-`count` select
  shorthand emits SQL without `GROUP BY` (Postgres 42803), so grouped counts
  can never run through `select`. The top-users lists therefore call the
  service-role functions from migration `040_admin_dashboard_top_users.sql`
  (`admin_top_users_outfits` / `_items` / `_referrals`); `dashboards/overview`
  and `dashboards/referrals` use plain `count=exact` HEAD counts, which work.
- **Revenue + trends dashboards** (`dashboards/revenue`, `dashboards/trends`,
  2026-08-07): `revenue` estimates MRR from the configured plan prices
  (`PLAN_AMOUNTS` in `admin_service.py` — yearly plans amortized), splits it
  by `billing_provider` (Stripe vs Apple/Google), and counts trial rows,
  30-day churn lifecycle events (`stripe_webhook_events` deleted + Apple
  `EXPIRED`/`REVOKE` + Google `SUBSCRIPTION_*` rows) and refunds marked in
  the window (`audit_events` actions `subscription.refunded` /
  `iap.refund_marked`). `trends?days=7|15|30|90` returns zero-filled daily
  series
  from the service-role RPCs in `041_admin_trends.sql`
  (`admin_trend_signups` / `_jobs` / `_paid` / `_active` — same hardening as
  migration 040). "AI-active users" is distinct users with ≥1 durable job
  that day (`users.last_login_at` cannot produce a daily series) across all
  four job tables, extraction included. Google churn counts only rows whose
  ledger `event_type` carries a real RTDN name (`SUBSCRIPTION_EXPIRED` /
  `CANCELED` / `REVOKED` — the webhook stores the mapped name, not a
  blanket label; rows written before that fix carry `'rtdn'` and are
  invisible to churn by design). The RPC functions declare `p_days` and
  `admin_service.dashboard_trends` must pass `{"p_days": days}` (PostgREST
  matches args by name; a `days` key raises PGRST202). The UNION-based
  functions qualify outer columns with the subquery alias (`s.day`, …) —
  bare `day` collides with the `RETURNS TABLE` out-param and raises 42702.
  Both are
  read-only and ride on `dashboards.read`; revenue is an estimate — store
  rows never carry amounts.
- **Audit trail**: every admin mutation calls `record_audit`
  (`app/services/audit_service.py`) with actor, action, entity, payload, ip,
  user-agent. `record_audit` **never raises** — a failed audit write is logged
  and swallowed so it cannot fail the admin action it documents.
- **CORS**: `https://admin.fitcheckaiapp.com` + `http://localhost:5173` are in
  the `BACKEND_CORS_ORIGINS` defaults (`app/core/config.py`) and
  `backend/.env.example`; no wildcard.

Tests: `backend/tests/api/test_admin_{authz,ops,commerce,audit,users}.py` +
`backend/tests/integration/test_admin/test_admin_{predicates,quotas,dashboards,revenue_trends}.py`
(172 tests across 9 files — authz 403s, role predicates, CRUD, suspend,
refund, audit rows, quota overrides, dashboard aggregates).

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

Registered via `app.add_middleware(...)` in `main.py` — **first added =
outermost**, so a request traverses the stack in the order below and the
response flows back out in reverse:

1. `CORSMiddleware` (outermost — added first)  
2. `RequestLoggingMiddleware`  
3. `CorrelationIdMiddleware` (innermost — added last, runs closest to the route)

## AI provider system

Configured in `app/core/config.py` / env:

- **Custom** (default): Agnes AI OpenAI-compatible gateway (`apihub.agnes-ai.com`)
- **OpenAI**: GPT-4o / DALL-E style paths when selected
- **Gemini** (opt-in): native `google-genai` SDK, not OpenAI-compatible HTTP - chat/vision/image
  all via `client.aio.models.generate_content`. No per-leg URL config (the SDK talks directly to
  Google); fallback is Gemini-model-to-Gemini-model only, not cross-provider. Bypasses
  `ai_provider_health_service` entirely (no pre-flight probe - a bad key/model/quota surfaces
  from the real call itself). See `app/services/gemini_provider.py`.
- **Hybrid vision leg** (`AI_VISION_PROVIDER=gemini` — the **default**, system-config only - no BYOK):
  keeps chat/image on the Custom provider (Agnes) but routes the vision leg's *primary* call
  directly to Google's native API via an internal `GeminiProvider` instance, falling back to
  Agnes (`AI_VISION_FALLBACK_MODEL`) on **any** failure - not just retryable ones, since the
  fallback is a genuinely different vendor that may succeed where Gemini refused. This is the
  first real cross-provider fallback in the codebase (see `AIProviderService._chat_with_vision_via_native_gemini`
  in `ai_provider_service.py`). `AI_VISION_API_URL` must stay blank in this mode -
  `config_health.py` flags it as an error otherwise, since it becomes dead config once the leg
  is redirected.

- **Quota resilience** (native Gemini leg): the server's Gemini key is on Google's free tier
  in prod (5 req/min, 20 req/day per model - too small for production concurrency, and the
  cause of the 2026-07-29/30 429 storm). `classify_gemini_error()` in `gemini_provider.py`
  splits the failure modes: daily free-tier quota → **not retryable** (forces the Agnes
  fallback immediately instead of burning retries), per-minute quota → retryable after the
  provider's `RetryInfo.retryDelay` (parsed as decimal seconds), 503/5xx → transient, 4xx →
  hard. `AIServiceError` carries `error_kind` (`upstream_quota`/`transient`/`hard`) +
  `retry_after_seconds`, serialized via `to_dict()` so clients show "try again shortly"
  (never an upgrade CTA for server-key issues); `with_retry` honors the advised delay as a
  floor. The OpenAI-compatible legs propagate `Retry-After` the same way, and batch/social
  pipelines stop grinding remaining items via `capacity_exhausted` events. Full design:
  `docs/exec-plans/active/quota-fallback-and-upgrade-propagation.md`.

Typical custom stack (`AI_DEFAULT_PROVIDER=custom`, the default):

- Chat: `agnes-2.5-flash` (primary, `AI_CHAT_MODEL`) via `/v1/chat/completions`
- Vision: `gemini-3.6-flash` **primary** via the native Gemini leg (default
  `AI_VISION_PROVIDER=gemini`) → `agnes-2.5-flash` fallback (`AI_VISION_FALLBACK_MODEL`)
  on **any** failure, not after a fixed retry count
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
3. **Resolve the source photo (upload flow only)** — when the request carries `use_source_photo: true` (`GenerateOutfitRequest`; set only by `frontend/src/lib/outfit-from-upload.ts` for the one-outfit-per-uploaded-photo flow), `resolve_outfit_source_reference` fetches the **original uploaded photo** the items were extracted from (`items.source_image_url`) with one batched, user-scoped query, dedupes by URL, and sends at most one photo (the one shared by the most items; a tie is skipped; `AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS` gates coverage, `AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES` caps). It is downscaled to the same 768px edge and added to the prompt as an "as worn" reference (`SOURCE_PHOTO_REFERENCE_LOCK`), so the render reproduces real fit/draping/layering instead of compounding the loss from the extracted/generated item shots. Every failure degrades to the item-reference-only behavior. The flag defaults **off**: the outfit builder, preview, and manual regenerations never send the source photo.
4. `image_generation_agent.generate_outfit` builds one inline image list — avatar first when used, then the source photo (upload flow only), then garments in item order — and a prompt that binds `IMAGE n` → `Item n` (`_build_reference_map` in `app/agents/image_generation_agent.py`, `GARMENT_REFERENCE_LOCK` in `app/agents/prompt_fidelity.py`). Items with no image are explicitly told to render from their description. `IDENTITY_LOCK` stays ahead of the garment block so the avatar remains the sole source for face/body/hair/skin (the source photo is an outfit source, never an identity source). Multi-image has to go through `chat(..., response_modalities=["TEXT","IMAGE"])`, since `generate_image()` takes a single `reference_image`; with zero images the pre-existing text-to-image path is used unchanged.
5. Backend stores generated images and updates outfit records.
6. Client receives image URLs and render metadata.

Sending no `item_id` is still valid and produces the previous text-only prompt byte-for-byte; sending `use_source_photo: false` (the default) produces the previous reference-only prompt byte-for-byte. Grep `Outfit item references resolved` / `Outfit source photo reference resolved` and `AI image generation request started` (`reference_images=`) to see how many references a generation actually carried.

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

### Photoshoot generation
1. `POST /api/v1/photoshoot/generate` (async) creates a `PhotoshootJob` and returns `job_id` (202); the pipeline runs in the background and streams SSE on `/{job_id}/events`. `sync=true` remains as a legacy compatibility path (TD-019 closed for the web app 2026-08-03).
2. **Scene planning** is one multimodal LLM call (`PhotoshootService.generate_prompts`) that produces a subject lock + N scene plans; there is **no caching** of this call (deliberately).
3. **Image generation** runs in batches (`batch_size` per job) with a per-job fan-out of `PHOTOSHOOT_CONCURRENCY_LIMIT` (default **4** since 2026-08-03; was 2) under the process-wide `image_gen_slot()` cap (`AI_GENERATION_CONCURRENCY`, default 30) shared with try-on/outfit/batch generation. Per-image provider calls take ~30–45s, so 10 images at concurrency 4 run in ~4 waves (~2–2.5 min). Each generated image is uploaded to a durable storage URL at generation time; the job row carries metadata + URLs only, and terminal jobs release base64 payloads.
4. **SSE progress contract** (clients render a live experience): `batch_started` includes `scene_labels` (string index → short human label built from the prompt's setting/pose, capped at 48 chars), and `image_complete` / `image_failed` include a `label` for the slot. Clients show the next pending scene label, a real progress % (10% upload + 90% completed count), a rolling ETA from per-image latency, and a live thumbnail gallery.
5. **Terminal semantics** (2026-08-05): a job that generated **zero images** is marked **FAILED** — `run_pipeline` broadcasts `job_failed` (with `error`, post-release `usage`, `failed_indices`, and the first per-index provider error via `PhotoshootJobService.get_first_error`) instead of `job_complete`, so clients show an error dialog with a retry path instead of an empty "0 images generated" screen. Partial runs still broadcast `job_complete`, and both terminal payloads carry **post-release** usage (re-read via `get_usage` after `release_daily_usage`, falling back to the reservation snapshot if that read fails), so the client's quota display always matches the DB. Per-index provider errors are retained on the job row (`image_failures`, 500-char bounded — column added by migration **035**, apply before deploying this backend) and surfaced on `GET /status` (`first_error`) for support triage.
6. **Demo flow** (anonymous landing page): `POST /api/v1/photoshoot/demo` now returns a `job_id` (202) instead of blocking for the whole run. The job runs under a pseudo-user derived from a SHA-256 hash of the client IP (`demo_<hash>`) with quota reservation skipped (the IP rate limit at creation is the gate); jobs stay **in-memory only** because `photoshoot_jobs.user_id` is FK-constrained to `users`. Progress/results are read via `GET /api/v1/photoshoot/demo/{job_id}/status`, which re-derives the pseudo-user from the request IP to enforce ownership (no auth, no SSE).

### Recommendations

1. Client requests recommendations.
2. Backend aggregates wardrobe/profile context.
3. Optional embedding/similarity via vector service (Pinecone when configured).
4. Ranked recommendations returned.

### Rate limiting helper

Subscription-aware AI limits live in `app.services.rate_limit` (`rate_limited_operation`), not `app.core` (core must not import services). IP-based demo limits remain in `app.core.ip_rate_limit`.

### Quota reservation migrations (hosted Supabase)

AI admission is enforced by atomic DB RPCs, not read-then-write counters: `reserve_ai_usage` / `release_ai_usage` for the daily AI quotas (`AISettingsService.reserve_usage`), `reserve_usage` for the monthly subscription quotas (`SubscriptionService.increment_usage`), and `reserve_daily_photoshoot_usage` for photoshoot. All three live in migrations **022** (`backend/db/supabase/migrations/022_wave_b_hardening.sql`), **024** (`024_atomic_daily_quota_reservations.sql`), and **026** (`026_harden_rpc_privileges.sql`, which revokes them from browser roles and grants to `service_role`). If the hosted DB is missing them, PostgREST answers every `rpc()` with `PGRST202` and admission fails closed.

That failure mode hit production on 2026-07-31: every `POST /api/v1/ai/batch-extract-multipart` returned 500 ("Failed to reserve AI usage") and related quota paths 503 because the migrations had never been applied to the hosted project. The services now log the actionable detail — which function is missing and which migrations create it (via `is_pgrst202_missing_rpc` / `missing_rpc_log_hint` in `app/utils/db.py`) — and return a **friendly** 503 (`AI_SERVICE_ERROR`) to the client; raw DB/RPC text is never sent to users (regression-tested in `backend/tests/test_wave_b_hardening.py`). Apply the migrations in order on the hosted DB whenever the backend is deployed past a124226 (verify-before-apply checklist in `docs/exec-plans/active/2026-08-01-batch-quota-rpc-outage-fix.md`).

The same migration-gap class also breaks **durable job creation**: batch (`extraction_jobs`, migration 016) and photoshoot (`photoshoot_jobs`, migration 023) mirror rows are written on every job start, and a missing table/column (`PGRST205`/`42703`) or a stale `valid_batch_size` CHECK (`23514`, 016 allows ≤10 while the API sends up to 50) previously escaped as an opaque 500. `BatchJobService.create_job` / `PhotoshootJobService.create_job` now wrap those raw postgrest errors into the same friendly retryable 503 and log the migration hint (via `job_persistence_migration_hint` in `app/utils/db.py`), with the exception type embedded in the log message text because Railway's plain-text drain does not render structured `extra` fields. At boot, `_seed_schema_status_in_thread` (in `app/main.py`) probes the hosted DB for the quota RPCs (`missing_quota_rpcs`) and logs a runbook hint when any are absent, and the `/ready` table check now includes `extraction_jobs` / `photoshoot_jobs`.

## Billing: subscriptions (Stripe web + store IAP)

Three billing rails share one `subscriptions` row, identified by `billing_provider` (`stripe` | `apple` | `google`):

- **Web** (`frontend/`): Stripe Checkout — `POST /api/v1/subscription/checkout`, portal, `cancel`, webhook (`/webhook`). Rails: `stripe_*` columns.
- **iOS** (`flutter/`): Apple In-App Purchase. The app buys via StoreKit and calls `POST /api/v1/subscription/iap/transaction` with the StoreKit transaction ID; the backend verifies it with the App Store Server API (ES256 JWT signed with the App Store Connect API key) before granting entitlement. Renewals/expirations/refunds arrive as App Store Server Notifications V2 at `POST /api/v1/subscription/apple/notifications` (JWS verified against the Apple Root CA - G3 chain; `apple_iap_events` dedupes by `notificationId`). Rail columns: `apple_original_transaction_id`.
- **Android** (`flutter/`): Play Billing. The app calls the same `/iap/transaction` with the Play purchase token; the backend verifies via the Play Developer API v3 (service-account JWT → OAuth token) and acknowledges the purchase. Play Real-time Developer Notifications arrive at `POST /api/v1/subscription/google/notifications` (Pub/Sub push, OIDC bearer verified against `GOOGLE_RTDN_AUDIENCE`; `google_rtdn_events` dedupes by `messageId`). Rail columns: `google_purchase_token`, `google_order_id`.

Rules:

- A purchase is only ever granted from provider-verified data (transaction lookup / JWS-verified webhook), never from the client payload alone; the client-reported `product_id` is cross-checked against the verified transaction.
- `GET /api/v1/subscription/plans` returns `store_products` (per-variant product IDs per store) plus the display plans; product IDs are never hardcoded in the apps.
- Rails are exclusive: store sync clears the other rails' identity columns, and Stripe checkout/cancel fail closed on store-billed rows (a store-billed account must not be steered to Stripe — App Store Guideline 3.1.1).
- Webhook handlers return 500 on processing failure so the store retries; signature failures are acknowledged without processing.
- `cancel_at_period_end` comes only from a notification's `signedRenewalInfo`; a payload without it means *unknown* (`None`) and leaves the stored flag alone, so Restore Purchases cannot un-cancel a subscription.
- Store snapshots are ordered by purchase recency (`current_period_start`), not period end — an upgrade legitimately shortens the period (Plus yearly → Pro monthly). The period-end rule still applies when purchase dates are equal or unknown, which is the normal case on Google (`startTimeMillis` is constant across renewals).
- Sandbox transactions are accepted on a production backend by design (App Review runs in Sandbox) and logged with their `environment`; they are never rejected.
- Env: `APPLE_ISSUER_ID` / `APPLE_KEY_ID` / `APPLE_PRIVATE_KEY` / `APPLE_ENV`, `GOOGLE_SERVICE_ACCOUNT_JSON` / `GOOGLE_RTDN_AUDIENCE` (see `backend/.env.example`). The eight `APPLE_*_PRODUCT_ID` / `GOOGLE_*_PRODUCT_ID` settings default to the real store identifiers and normally need no env var; an override outside the bundle/package namespace is flagged by the startup config health check. Requires migration `030_mobile_iap.sql` (columns + webhook ledgers). Sandbox procedure: `docs/store/ios-sandbox-testing-runbook.md`.

### Promo codes (free grants)

Campaign codes (`/auth/register?promo=CODE`) grant Plus/Pro free for a fixed
number of months. `POST /api/v1/promo/validate` (public) and
`POST /api/v1/promo/redeem` (auth) wrap the atomic `redeem_promo_atomic` RPC
(migrations `031_promo_codes.sql` + `032_fix_redeem_promo_atomic_plan_type.sql`
— 032 adds the `::TEXT` casts the 031 version was missing, which 42804'd at
runtime), which writes the same `subscriptions` row as any other grant
(`plan_type` + `status='trial'` + `trial_end`) — entitlement, limits, and
expiry → free downgrade need no special-casing. One redemption per user; paid
subscribers are never overwritten. Codes are created by operators with
`backend/scripts/create_promo_code.py`.

## Route registration

Modules wired from `main.py` include: auth, users, items, outfits, shared_outfits, recommendations, calendar, weather, gamification (flagged), ai, ai_settings, batch_processing, photoshoot, feedback, waitlist, demo, subscription, referral, promo, social_import (flagged), blog, and the admin API (`app.api.v1.admin` under `/api/v1/admin`, see "Admin API & RBAC").

### Flagged routes — two different shapes

| Flag | Default | Shape when off |
|------|---------|----------------|
| `ENABLE_SOCIAL_IMPORT` | `true` | **Router not mounted.** The paths 404 and vanish from OpenAPI. |
| `ENABLE_GAMIFICATION` | `false` | **Router stays mounted.** Handlers return `200` with a neutral zeroed payload. |

The gamification asymmetry is deliberate and must not be "made consistent".
Unmounting the router would 404 `/api/v1/gamification/streak` while the shipped
Flutter home screen still calls it (see TD-034 in
`docs/exec-plans/tech-debt-tracker.md`, **resolved 2026-07-31**:
`flutter/lib/features/dashboard/controllers/dashboard_controller.dart` now
attaches a per-future `onError` handler, so a streak failure returns `null`
instead of rejecting the dashboard load). The flag is therefore enforced per
handler in `app/api/v1/gamification.py` (which returns a neutral zeroed payload
and also kills the write-on-GET that inserted a zeroed `user_streaks` row). Keep
the router mounted while the feature remains flag-gated. Guarded by
`backend/tests/test_gamification_flag.py`.

## Adding an endpoint

1. Route module in `app/api/v1/`  
2. Pydantic models in `app/models/`  
3. Logic in `app/services/`  
4. Register router in `main.py`  
5. Update `docs/references/api-spec.md` — it is generated from the live OpenAPI document (`scripts/generate_api_spec_doc.py`); regenerate it in the same change set (CI drift-checks it)

## Scripts (ops tooling)

`backend/scripts/` beyond the storage/matte ones above (read each module
docstring before running):

- `convert_account_to_free.py` — downgrade one account to the free plan
  app-side, leaving its billing rail untouched (provider dashboard must cancel it).
- `upgrade_free_users_to_pro.py` — one-off campaign: every still-free user gets a
  1-month Pro trial + email; conditional writes never overwrite paid/trial rows.
- `revert_expired_pro_trials.py` — undo expired `grant_free_pro_month` trials
  (reads the campaign audit file; no auto-expiry exists in the app).
- `seed_app_store_reviewer.py` — seed an App Store reviewer demo account with a
  body profile, ~12 items, and outfits via the public API.
- `girlfriend_day_campaign.py` — emails every user a shareable promo code
  (redeemed through the standard promo-code machinery; no DB writes).
- `fix_broken_blog_images.py` / `scan_live_blog_images.py` — remap 404 Unsplash
  featured images in `blog_posts` / scan the live blog API for broken ones
  (2026-08-07 PageSpeed RCA).
- `export_openapi.py` — dump the backend's OpenAPI schema (admin frontend contract).

## Environment (high level)

Required: `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`, `SUPABASE_SECRET_KEY`, `SUPABASE_JWT_SECRET`  

Storage: `OBJECT_STORAGE_ENDPOINT`, `OBJECT_STORAGE_REGION`, `OBJECT_STORAGE_ACCESS_KEY_ID`, `OBJECT_STORAGE_SECRET_ACCESS_KEY`, `OBJECT_STORAGE_BUCKET` (canonical only — no provider-specific aliases); `IMAGE_SERVING_MODE` (`presigned` default | `worker`), `IMAGE_CDN_BASE_URL`, `THUMBNAIL_SERVING`

AI: `AI_DEFAULT_PROVIDER`, `AI_GEMINI_*` (embeddings), `AI_CHAT_*`/`AI_VISION_*`/`AI_IMAGE_*` (per-leg, see `.env.example`), `AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE` (garment reference size, default 768), `AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES` (default 12), `AI_OUTFIT_ITEM_REFERENCE_DOWNLOAD_CONCURRENCY` (default 8), and `AI_MAX_OUTFIT_ITEMS` (default 100)

Optional: `PINECONE_*`, `STRIPE_*`, `WEATHER_API_KEY`, social import flags, `ENABLE_GAMIFICATION` (default `false`), `AI_ENCRYPTION_KEY`  

Full templates: `backend/.env.example`. Backend also loads repo root `.env`.

## Logging

- `app/core/logging_config.py`
- Files under `backend/logs/`
- `LOG_LEVEL` (default INFO)
- Correlation ID on requests for agent grepping

## API surface reference

Generated: `docs/references/api-spec.md` (regenerate with `scripts/generate_api_spec_doc.py`; CI drift-checks it)  
Live: OpenAPI when server runs  

## Tests

`backend/tests/` is a layered pytest suite (pytest + pytest-asyncio, strict mode):

- `tests/unit/` — pure unit tests (models, services, agents, core utils) with
  in-memory fakes and mocks; no HTTP, no network.
- `tests/integration/` — route/service behavior via direct handler calls with
  in-memory fakes (`tests/utils/fake_db.py` FakeDB).
- `tests/api/` — full-app ASGI contract tests (TestClient / httpx
  ASGITransport) against the real app: routing, middleware, exception
  handlers, CORS, correlation IDs, and the real `verify_token` auth wiring
  (dependency overrides only for the Supabase clients).
- `tests/factories/` — polyfactory model factories + DB row builders.
- `tests/utils/` — shared fakes, token/auth helpers, response assertions.

Isolation (see `tests/conftest.py`): every test gets a fresh in-memory
database, outbound TCP is blocked by an autouse guard (opt out with
`@pytest.mark.network`), and `app.dependency_overrides` is restored after
every test.

Single-command run (also what CI runs):

```bash
cd backend && source .venv/bin/activate && pytest
```

Bare `pytest` runs the whole suite with branch coverage and enforces the
**≥90% line+branch gate** (`.coveragerc` → `fail_under = 90`); relax for a
quick iteration with `pytest --cov-fail-under=0`. Async tests use
`@pytest.mark.asyncio`; async fixtures use `@pytest_asyncio.fixture`
(strict `asyncio_mode`). CI: `.github/workflows/backend-ci.yml`
(ruff + pytest + architecture check).
