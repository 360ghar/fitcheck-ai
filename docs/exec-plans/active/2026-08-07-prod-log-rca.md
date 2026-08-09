# Plan: 2026-08-07 production log RCA (admin dashboard/quotas + photoshoot schema gaps)

Status: active
Started: 2026-08-07
Owner: agent

## Goal

RCA and fix the 2026-08-07 production log errors: admin revenue/quotas 500s,
`POST /photoshoot/generate` 503s, `/items` 500 bursts, config gaps, and the
401 refresh cascade. Root theme: **hosted Supabase is behind the repo's
migrations again** (same failure class as 2026-07-31, 08-01, 08-04) plus one
genuine query-shape bug in the admin quota listing.

## RCA

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | 09:33 `GET /api/v1/admin/dashboards/revenue` 500 `APIError: column stripe_webhook_events.id does not exist` (42703) at `admin_service.py` `dashboard_revenue` churn count | The then-deployed code selected `id` from `stripe_webhook_events`; the table's primary key is `event_id` (migration 022: `event_id TEXT PRIMARY KEY`, no `id` column). PostgREST `count=exact` counts via the PK, so every churn count failed. | **Already fixed in HEAD** (`d19d9af`, committed 18:57 after the log window): churn queries now select the webhook-ledger PKs (`event_id` / `notification_id` / `message_id`), regression-tested in `test_admin_revenue_trends.py`. Deploy HEAD (requires migration 042 — readiness now fails closed on `outfit_wear_history`). |
| 2 | 10:01–10:02 `POST /api/v1/photoshoot/generate` 503 ×4 `APIError: Could not find the 'image_failures' column of 'photoshoot_jobs' in the schema cache` (PGRST204) | Migration `035_add_photoshoot_jobs_image_failures.sql` never applied to hosted Supabase. The migration header explicitly says "apply BEFORE deploying the 2026-08-05 backend" — the apply-before-deploy discipline was missed again. | Ops: apply 035 (idempotent) + any other pending migrations. Code hardening (this change): PGRST204 is now a schema-gap marker (the 10:01 logs lacked the operator hint because `_MISSING_SCHEMA_MARKERS` only matched PGRST205/42703) and readiness checks `photoshoot_jobs.image_failures`. |
| 3 | 15:38 `GET /api/v1/admin/quotas` 500 ×3 `APIError: Could not find a relationship between 'user_ai_settings' and 'subscriptions'` (PGRST200) | **Code bug, fails on any DB with the repo schema.** `_quota_usage_builder` embeds `subscriptions(plan_type,status)` directly off `user_ai_settings`, but no FK exists between those tables: `user_ai_settings.user_id → users.id` (003) and `subscriptions.user_id → users.id` (007). PostgREST only resolves embeds through FKs. | **Code (this change)**: embed subscriptions THROUGH users — select becomes `users(email,full_name,custom_daily_quota,subscriptions(plan_type,status))`, plan filter becomes `users.subscriptions.plan_type` (valid: `subscriptions.user_id` is UNIQUE). Row merging tolerates both single-object (PostgREST to-one via UNIQUE FK) and array shapes. Tests in `test_admin_quotas.py` (+ updated `test_admin_commerce.py`). |
| 4 | 15:32–15:34 `/items` 500 bursts (10+ requests, every ~3s, `DATABASE_ERROR`), plus 09:35/09:44/10:05 single blips and the 09:50 `DELETE /outfits` 500 | Transient Supabase gateway/pooler unavailability (~2 min window). `execute_with_reconnect` rebuild+retry fires correctly but cannot heal a sustained outage; the app's ~3s polling amplified it. Note: the concurrent 08-07 items-occasion RCA (TD-083) proved the 22P02 jsonb `contains` case separately; the bursts in this dump without `occasion` are genuine connection errors, not query errors. | No code fix (machinery works as designed). Monitor; the async-client migration (TD-043) remains the full fix. |
| 5 | Every boot: `AI_ENCRYPTION_KEY - Empty in production`; `STRIPE_SECRET_KEY` + four `STRIPE_*_PRICE_ID` missing | Prod env config gaps. Saving a user AI-provider key raises AIServiceError at request time; every web checkout fails closed with 503. | Ops: set Railway env vars (checklist below). |
| 6 | 09:47/15:33 Gemini 429 (free-tier `generate_content_free_tier_requests`, 20/day) and 503 high-demand → "falling back to Agnes" | Free-tier quota exhausted / model overload. The daily-quota latch (TD-054) prevents wasted calls; fallback is by design (WARN, not error). | Ops (optional): paid-tier Gemini key. |
| 7 | 15:17/15:18 `GET /api/v1/health` 404 | A probe hits `/api/v1/health`; the canonical liveness endpoint is `/health`. | Ops: fix Railway healthcheck path. Code (this change): `/api/v1/health` compatibility alias so a misconfigured probe is harmless. |
| 8 | 11:13/13:49 `Refresh token already used` → `/auth/refresh` 401 → downstream 401 cascade (`/items`, `/users/me`, `/subscription/usage`, `/referral/code`) | Client-side refresh-token race: two parallel refreshes use the same (rotated-once) refresh token. Backend behavior is correct; the fix is client-side single-flight. | Tracked as TD-084 (frontend + mobile follow-up). |
| 9 | 15:38 `Railway rate limit of 500 logs/sec reached… Messages dropped: 168` | Exception spam: each admin endpoint failure logged a full traceback twice (catch-all handler), ×3 concurrent requests. | Resolved by fixing errors #1/#3; residual traceback-spam mitigation tracked as TD-085. |

## Code changes (this commit)

1. `backend/app/services/admin_service.py` — `_quota_usage_builder` nests
   `subscriptions(plan_type,status)` inside the `users` embed; plan filter uses
   `users.subscriptions.plan_type`; `list_quota_usage` parses the nested shape
   (single-object + defensive list handling).
2. `backend/app/utils/db.py` — `pgrst204` added to `_MISSING_SCHEMA_MARKERS` so
   photoshoot/batch persist failures of this class log the migration hint; hint
   text names 035.
3. `backend/app/main.py` — readiness `REQUIRED_COLUMNS` gains
   `("photoshoot_jobs", "image_failures")`; `_SCHEMA_ABSENT_CODES` gains
   `PGRST204`; new `/api/v1/health` alias.
4. Tests — `backend/tests/test_admin_quotas.py` (new, 6 cases: embed shape, nested
   plan filter, single-object/list parsing, missing user/subscription defaults,
   empty state); `backend/tests/test_admin_commerce.py` quota test updated to the
   nested embed shape.

## Tests

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/test_admin_quotas.py tests/test_admin_revenue_trends.py tests/test_admin_dashboards.py tests/test_admin_commerce.py -q
python -m pytest -q          # full suite (1325 passed, 4 skipped, 2026-08-07)
ruff check app/services/admin_service.py app/utils/db.py app/main.py tests/
```

## Ops checklist (hosted Supabase + Railway — deploy/migrations/env owned by the operator)

1. **Apply pending migrations** in the Supabase SQL editor, verify-then-apply
   (per `docs/exec-plans/active/2026-08-01-batch-quota-rpc-outage-fix.md`):
   at minimum `035_add_photoshoot_jobs_image_failures.sql`; confirm `036`–`042`.
   `042_outfit_wear_history.sql` is REQUIRED before deploying HEAD (readiness
   fails closed without it). If applying outside the dashboard, run
   `NOTIFY pgrst, 'reload schema';` afterward.
2. **Verify** in the SQL editor:
   `SELECT image_failures FROM photoshoot_jobs LIMIT 1;`
   `SELECT event_id FROM stripe_webhook_events LIMIT 1;`
   `SELECT plan_type, status FROM user_ai_settings s JOIN users u ON u.id = s.user_id JOIN subscriptions sub ON sub.user_id = u.id LIMIT 1;`
3. **Deploy HEAD** (contains the revenue churn PK fix, the quota join fix, and
   this hardening).
4. **Railway env**: `AI_ENCRYPTION_KEY=$(openssl rand -hex 32)`,
   `STRIPE_SECRET_KEY`, `STRIPE_PLUS_MONTHLY_PRICE_ID`, `STRIPE_PLUS_YEARLY_PRICE_ID`,
   `STRIPE_PRO_MONTHLY_PRICE_ID`, `STRIPE_PRO_YEARLY_PRICE_ID`.
5. **Railway healthcheck path** → `/health` (the `/api/v1/health` alias is a
   belt-and-suspenders only).
6. Optional: paid-tier Gemini key (kills the 429/503 fallback noise); client-side
   refresh single-flight tracked as TD-084.

## Deferred debt

- TD-084 (refresh-token single-flight, client) and TD-085 (admin route error
  mapping to stop traceback spam) added to the tracker.
- TD-043 (async Supabase client) remains the full fix for pooled-connection
  outages; the 15:32–15:34 burst is infra, not code.

## Follow-up (self-review 2026-08-07)

- The 09:50 `DELETE /api/v1/outfits` 500 was re-examined: all outfit FKs
  cascade and `.single()` on zero rows returns falsy data (no latent 404/500
  bug), so the failure was a gateway blip — but the handler was one of the
  remaining **unwrapped** call sites (TD-043 class). `delete_outfit` and
  `delete_outfit_image` now run their ownership selects and row deletes
  through `execute_with_reconnect` (reads + idempotent deletes are retry-safe;
  postgrest-py's own retry only covers GET/HEAD on 503/520, never DELETE).
  Lambdas call `.execute()` per the repo convention enforced by
  `test_no_parenless_execute_builders_in_app_code`.

## Late-window RCA (16:00–19:01 UTC 2026-08-07) — follow-up pass

A second log window from the same day (16:00–19:01 UTC) was triaged after the
first pass. Most entries are already fixed by the 19:00 UTC deploy of HEAD
(378bc72) or are ops-only; exactly one code defect remained.

| # | Log signature | Root cause | Status |
|---|---------------|------------|--------|
| 1 | 16:00 `/items` 500 ×3 (~5s apart, `DATABASE_ERROR`, two "rebuilding client" warnings + "retries exhausted" each) | Same symptom class as TD-083: mobile ~3s polls with `?occasion=` sent `contains(list)` on a JSONB column → PostgREST `22P02 invalid input syntax for type jsonb`; the `invalid input` text marker misclassified it as a dead pooled connection, so each request burned 2 client rebuilds + 3 attempts before 500ing. A genuine gateway blip produces the identical log shape; both are now handled (22P02 no longer retries; real gateway 5xx/429s still rebuild+retry once). Ran on the pre-fix deploy (before 19:00 UTC). | **Fixed — deployed 19:00 UTC in 378bc72** (`jsonb_contains()` + APIError-aware `is_db_connection_error`). Verify: no `/items` 500 bursts in post-19:00 logs. |
| 2 | 17:02 Gemini 503 UNAVAILABLE + 17:59 Gemini 429 free-tier quota (20/day, `gemini-3.6-flash`) → "falling back to Agnes" | Provider overload / free-tier cap. Fallback is by design (WARN); the daily-quota latch (TD-054) fails fast from the first post-exhaustion call. | No code change. Optional ops: paid-tier Gemini key. |
| 3 | 17:37 `POST /api/v1/demo/extract-items` **400 after 169 028.88ms** | Gemini unhealthy all afternoon; the demo's outer `with_retry(max_retries=1)` doubled the entire Gemini→Agnes chain (each leg up to a 120s read timeout), so a single failed demo held a worker + proxy connection for ~3 minutes. The 400 itself cannot be produced by any version of the demo handler in git history (every error path maps to 503/422/429/500) — most plausibly an edge/ingress rejection of a request that had already been churning for ~169s. The unbounded latency was the defect. | **Fixed (this pass)** — single attempt capped by `DEMO_EXTRACT_TIMEOUT_SECONDS` (90s) via `asyncio.wait_for`; expiry raises a retryable `AIServiceError` → fast 503. Tests in `backend/tests/api/test_demo_extract_latency.py`. Try-on deliberately unchanged (image generation legitimately runs 60–120s). |
| 4 | 17:44 / 17:52 / 18:26 "Refresh token already used" → `/auth/refresh` 401 + downstream 401 cascades | Supabase rotates refresh tokens; a stale tab/session re-presents a rotated token. Backend dedup + web single-flight (`client.ts`, deployed 09:24 UTC) + Flutter single-flight (`api_interceptors.dart`, landed 08-03) are all live; the 18:26 burst (ONE refresh attempt + 5 fail-fast 401s in <3ms) is the designed behavior — the client bounces to login. | Fixed (TD-084, both clients). No further change. |
| 5 | 17:52 `GET /api/v1/items` 422 (91.42ms) | FastAPI query-param validation (RequestValidationError → 422) after the ~90ms `get_active_user_id` lookup; an unidentified client sent an out-of-range param (`page`/`page_size` bounds or a non-coercible `is_favorite`). Backend validation is correct. | Tracked as TD-089 (client-side audit). |
| 6 | 18:47 404s on `/api/v1/settings/sysadmin/connect-to-hub` + `/api/v1/info/server` | The endpoints don't exist anywhere in the repo (zero references across backend/frontend/flutter/docs). A client probes unshipped routes; 404 is correct. | No code change. |
| 7 | 19:00:57 boot: `AI_ENCRYPTION_KEY - Empty in production`; `STRIPE_SECRET_KEY` + four `STRIPE_*_PRICE_ID` missing | Prod env gaps (same as first-pass item #5). Saving a user AI-provider key raises at request time; every web checkout fails closed 503. | Ops: Railway env (checklist below). |
| 8 | 19:01:01 `Missing: photoshoot_jobs.image_failures`; schema not initialized | Migration 035 never applied to hosted Supabase (same as first-pass item #2). Readiness now fails closed (code landed). | Ops: apply migrations (checklist below). |

### Code changes (this pass)

1. `backend/app/api/v1/demo.py` — `demo_extract_items` runs ONE attempt of
   `ItemExtractionAgent.extract_multiple_items` under
   `asyncio.wait_for(timeout=DEMO_EXTRACT_TIMEOUT_SECONDS)` (90s) instead of
   `with_retry(max_retries=1)` around the whole Gemini→Agnes chain; a timeout
   raises a retryable `AIServiceError` (fast 503). The pooled client still
   closes in `finally`.
2. `backend/tests/api/test_demo_extract_latency.py` — new: timeout → fast 503
   + client closed; retryable failure → exactly ONE agent invocation; happy
   path → 200 envelope.

### Ops checklist (updated 2026-08-08; label = recorded live state)

Migration status on hosted Supabase, per the in-repo records
(`2026-08-07-admin-panel.md`, `2026-08-07-admin-revenue-trends-export.md`,
`2026-08-05-photoshoot-zero-images-rca.md`):

| Migration | State | Note |
|-----------|-------|------|
| 035 `photoshoot_jobs.image_failures` | **pending** | Blocker behind the 19:01:01 readiness warning; apply before/with the backend deploy. |
| 036 `widen_image_url_columns` | **pending** | R2 cutover dependency (TEXT columns for longer URLs); part of the egress RCA ops checklist. |
| 037 `admin_roles` | **applied** | Recorded applied to hosted Supabase in `2026-08-07-admin-panel.md`. |
| 038 `audit_events` | **applied** | Recorded applied to hosted Supabase in `2026-08-07-admin-panel.md`. |
| 039 `scope_service_policies` | **pending** | No applied record; apply and verify `/ready` + admin endpoints. |
| 040 `admin_dashboard_top_users` | **applied** | RPCs live-verified (42803/PGRST204 fixes); recorded in `2026-08-07-admin-panel.md`. |
| 041 `admin_trends` | **re-apply** | Applied, but corrected function bodies (qualify `day` with alias `s`; `p_days` signature unchanged) must be re-applied via `CREATE OR REPLACE`, then sanity-check `SELECT public.admin_trend_jobs(30)`. |
| 042 `outfit_wear_history` | **pending** | Ships with the `/outfits/{id}/wear` + `/wear-history` routes; apply before those routes go live. |

Also: set Railway env `AI_ENCRYPTION_KEY` + the five Stripe vars; optional
paid-tier Gemini key.

## Second follow-up window (2026-08-07 21:09 – 2026-08-08 18:49 UTC)

A new log window triaged after the first follow-up pass. Verdict: **the ops
checklist above was still not executed** — every boot still logs the
`AI_ENCRYPTION_KEY` / Stripe config gaps, photoshoot 503s continue at the
same rate, and one genuinely new item-write defect (opaque 500s) surfaced.

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `POST /subscription/checkout` + `/portal` 503 ×10+ (21:09 → 16:04) | `_stripe_billing_configured()` still false — Railway env still missing `STRIPE_SECRET_KEY` + the four `STRIPE_*_PRICE_ID` vars. Fail-closed by design (`BILLING_NOT_CONFIGURED`). | Ops only (checklist below). |
| 2 | `POST /photoshoot/generate` 503 ×30+ with `AI job persistence is unavailable: 'photoshoot_jobs' … 016/023/035 not applied` (22:48 → 16:45) | Hosted Supabase still missing the durable-job schema (at minimum 035; 036/039/041/042 still pending per the table above). Code already returns the friendly retryable 503 + logs the hint — correct. | Ops only: apply pending migrations. |
| 3 | `PUT /api/v1/ai/settings` 503 ×3 (13:49:18) | `AI_ENCRYPTION_KEY` still empty → fail-closed `AIServiceError` when saving a user AI-provider key. | Ops only: set `AI_ENCRYPTION_KEY`. |
| 4 | `POST /api/v1/items` 500 ×2 (15:46:12, ~1.1s/1.4s, `Create item error`) | Opaque: the real exception lives only in the structured `error=` field, which Railway's plain-text drain drops, and no "pooled connection, rebuilding" warnings preceded the 500s — so this is **not** the gateway-blip class. Deterministic PostgREST rejection is the fit: `create_item` always sends `items.source_image_url` / `source_image_storage_path` (migration 019, absent from 001) → PGRST204/42703; or a presigned/R2 URL >500 chars against the un-widened `item_images.image_url VARCHAR(500)` (migration 036 pending) → 22001. Both are the same schema-drift theme. | **Code (this commit)**: migration-gap detection in `create_item` → friendly 503 + hint in plain-text-visible log; readiness now fails closed on the 019 columns. Ops: apply migrations. |

### Code changes (this commit)

1. `backend/app/utils/db.py` — new `items_schema_migration_hint(error)` (LOGS
   ONLY): names migration 019 for PGRST205/42703/PGRST204 on item writes and
   migration 036 for SQLSTATE 22001 (value too long for
   `item_images.image_url`). Mirrors `job_persistence_migration_hint`.
2. `backend/app/api/v1/items.py` — `create_item` catch-all: on a schema gap,
   log the hint with the exception type in the message text (plain-text-drain
   safe) and raise `SchemaNotInitializedError` → friendly **503**
   `SCHEMA_NOT_INITIALIZED` instead of an opaque 500; all other unexpected
   errors keep the 500 `DATABASE_ERROR` but now log
   `Create item error (Type): …` so the cause survives the drain. The sibling
   catch-alls (upload, get/update/delete, item-image add/delete, categorize,
   update-categories) get the same exception-type-in-message logging.
3. `backend/app/main.py` — `REQUIRED_COLUMNS` gains
   `("items", "source_image_url")` and `("items", "source_image_storage_path")`
   so a missing 019 fails `/ready` with a clear boot log (same enforcement as
   `photoshoot_jobs.image_failures`).
4. Tests — `backend/tests/integration/test_items_schema_gap.py` (new, 7 cases:
   hint unit cases for 019/036/non-gap; create_item PGRST204/PGRST205 →
   503 with hint in logs and no raw DB text to the client; 22001 → 503 with
   the 036 hint; non-migration error → 500 with exception type in logs).

### Tests

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/integration/test_items_schema_gap.py tests/integration/test_items_routes_coverage.py tests/integration/test_wave_b_hardening.py tests/unit/test_core/test_config_health.py -q
python -m pytest -q          # full suite (3628 passed, 4 skipped, 2026-08-09)
ruff check app/utils/db.py app/api/v1/items.py app/main.py tests/integration/test_items_schema_gap.py
```

### Ops checklist (RE-EMPHASIS — still not executed as of 2026-08-08)

The window proves the apply-before-deploy discipline is still broken. Do all
of the following before the next backend deploy:

1. **Apply all pending migrations in order** in the Supabase SQL editor
   (each is idempotent): at minimum **016, 019, 023, 035, 036, 039, 041
   (re-apply), 042**; run anything else from 016→042 not yet applied. After
   applying, run `NOTIFY pgrst, 'reload schema';`.
2. **Verify** in the SQL editor:
   `SELECT image_failures FROM photoshoot_jobs LIMIT 1;`
   `SELECT source_image_url FROM items LIMIT 1;`
   `SELECT length(image_url) FROM item_images ORDER BY 1 DESC LIMIT 1;`
3. **Railway env**: `AI_ENCRYPTION_KEY=$(openssl rand -hex 32)`,
   `STRIPE_SECRET_KEY`, `STRIPE_PLUS_MONTHLY_PRICE_ID`,
   `STRIPE_PLUS_YEARLY_PRICE_ID`, `STRIPE_PRO_MONTHLY_PRICE_ID`,
   `STRIPE_PRO_YEARLY_PRICE_ID` (create the four Stripe prices first).
4. **Railway healthcheck path** → `/health`.

### Follow-up: all migrations made re-runnable (2026-08-08, evening)

The first apply attempt aborted with
`ERROR: 42710: trigger "extraction_jobs_updated_at" for relation
"extraction_jobs" already exists` — migration 016 had a plain `CREATE
TRIGGER`/`CREATE POLICY` with no drop guard, so re-running it after a prior
partial application failed (the hosted DB already had the table + trigger).
Postgres has no `CREATE TRIGGER/POLICY IF NOT EXISTS` and no `ADD CONSTRAINT
IF NOT EXISTS`, so every file was audited (script: drop-guard per
`CREATE POLICY|TRIGGER`/`ADD CONSTRAINT`, `ON CONFLICT` on top-level
`INSERT`s; 43 files) and the four unguarded files were fixed:

| File | Fix |
|------|-----|
| `016_extraction_jobs.sql` | `DROP TRIGGER IF EXISTS extraction_jobs_updated_at` + `DROP POLICY IF EXISTS` ×4 before the creates (the 42710 failure) |
| `017_blog_posts.sql` | `DROP POLICY IF EXISTS` ×3 + `DROP TRIGGER IF EXISTS trigger_update_blog_posts_updated_at` |
| `004_add_user_gender.sql` | `DROP CONSTRAINT IF EXISTS users_gender_check` before `ADD CONSTRAINT` |
| `011_shared_outfits_unique_constraint.sql` | `DROP CONSTRAINT IF EXISTS shared_outfits_outfit_user_unique` before `ADD CONSTRAINT` |

All other files already guarded (001 policies/triggers/storage-insert, 007/008
backfill `ON CONFLICT`, 002/014 DO-block constraint guards, 023 drop-then-
create, 027/029/030 constraint drops). Verified by applying **all 43
migrations twice in sequence** on a scratch PostgreSQL 17 with a stubbed
Supabase env (auth/storage schemas + anon/authenticated/service_role): both
passes clean, no duplicated seed rows, `valid_batch_size` keeps the 029
bound (<=100), triggers/policies exist exactly once. The operator can now
re-run any not-yet-applied migration in order without the 42710 abort;
`docs/references/local-setup.md` documents the re-runnability contract.

## Third follow-up window (2026-08-08 22:50 – 2026-08-09 04:45 UTC) — new defect found

A fresh log window was triaged after the second follow-up pass. Verdict:
**the ops checklist was still not executed** (photoshoot 503s + config gaps
continue at the same rate), the Agnes 400 and token-refresh entries are
known by-design behaviors, and ONE genuinely new code defect surfaced —
`GET /items/{id}` 500s for missing/not-owned items.

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `POST /photoshoot/generate` 503 ×30+ (22:50 → 03:26, `AI job persistence is unavailable … 016/023/035 not applied`) | Hosted Supabase still missing 016/023/035. The hint text in the logs proves the code-side handling (friendly retryable 503 + operator hint + readiness fail-closed on `photoshoot_jobs.image_failures`) is deployed and correct. | Ops only: apply pending migrations (checklist below). |
| 2 | Every boot (23:59 → 03:56): `AI_ENCRYPTION_KEY - Empty in production`; `STRIPE_SECRET_KEY` + four `STRIPE_*_PRICE_ID` missing | Railway env gaps (same as second window #1/#3). Fail-closed at request time by design. | Ops only: set the five env vars (+ `AI_ENCRYPTION_KEY`). |
| 3 | 03:26:50 `Image generation request failed (status=400, model=agnes-image-2.1-flash): Unable to generate this content` → `Generation failed for item item-29851209` | Provider content-policy refusal; classified non-retryable since 08-03, fallback only cross-host since 08-05. The item is recorded failed with the error; no retry storm. | By design. No code change. |
| 4 | 04:32:57 `Token refresh failed` (single event) | Generic backend refresh failure (not "already used") — an expired/revoked refresh token from one client. Single-flight (web + Flutter) and backend dedup are live (TD-084). Client bounces to login by design. | By design. No code change. |
| 5 | 04:44–04:45 `Get item error` → `GET /api/v1/items/{id}` 500 ×12 (4 distinct item IDs × 3 retries, ~160–550 ms each, no reconnect warnings, no other endpoint failing) | **NEW CODE DEFECT.** postgrest-py 2.31.0's `.single().execute()` RAISES `APIError` (406/PGRST116) when the query matches zero rows, so `get_item`'s `if not result.data: raise ItemNotFoundError` branch was dead code: a deleted or not-owned item (`eq user_id` filters it out) 500'd instead of 404ing. The fast, per-item, deterministic signature (vs. the slower rebuild-retry connection class) fits exactly. The test suite's `FakeDB` emulates `maybe_single` semantics for both builders, so the suite passed while production 500'd — the fake diverges from the real client exactly where the bug lived. Same dead-check shape at ~60 `.single()` call sites. | **Fixed (this pass)** — sweep `.single()` → `.maybe_single()` across items/outfits/shared-outfits/blog/calendar/weather/recommendations/ai/users + services (outfit delete, batch avatar, photoshoot usage, subscription usage records) so zero rows take the intended not-found/None/default path; `get_item` additionally maps a structured PGRST116 to 404 as belt-and-suspenders. `deps.get_current_user` deliberately KEEPS `.single()`: it depends on the PGRST116 raise for OAuth profile auto-provisioning. Regression test `test_get_item_maps_pgrst116_to_not_found` simulates the real client. Test fakes gained `maybe_single` aliases. |

### Code changes (this commit)

1. `.single()` → `.maybe_single()` + zero-row guards (`not result or not result.data`) at every call site whose `if not X.data` branch was dead:
   - `api/v1/items.py` — get/update/delete/favorite/wear/image add+delete/categorize/categories/similar (13 sites); `get_item` also maps PGRST116 → `ItemNotFoundError`.
   - `api/v1/outfits.py` — collection ownership + refetch, `_fetch_outfit`, public outfit, update/share/duplicate, add/remove item, generation status, image upload/delete, favorite/wear/wear-history (20 sites); collection refetch misses now 404 (`CollectionNotFoundError`) instead of 500.
   - `api/v1/shared_outfits.py` (feedback), `api/v1/blog.py` (slug), `api/v1/calendar.py` (disconnect/update/delete/assign + no-change refetch), `api/v1/weather.py` (`_resolve_location`), `api/v1/recommendations.py` (birth profile ×2, weather/astrology settings, similar, style), `api/v1/ai.py` (avatar fetch ×2, generate_outfit, try-on), `api/v1/users.py` (get/upsert body profile — first-time create previously 500'd), `services/outfit_service.py` (delete load), `services/batch_extraction_service.py` (avatar), `services/photoshoot_service.py` (daily usage), `services/subscription_service.py` (usage record select + reload).
   - `deps.py` `get_current_user` intentionally unchanged (PGRST116 raise is the designed missing-profile signal).
2. Tests — `test_get_item_maps_pgrst116_to_not_found` (real-client regression: PGRST116 → 404); test fakes/helpers updated to the `maybe_single` chain (`_error_db`, `_RefetchEmptyDB` expectation now `CollectionNotFoundError`, blog/astrology/phase2e/wave-a/outfits-models/users/subscription mocks).

### Self-review pass (same window) — two latent defects found and fixed

Reviewing the sweep (2026-08-09) surfaced two defects that the test harness
had been masking, plus one commit-hygiene error:

1. **`add_collection_outfit` was half-converted** (`outfits.py`): the
   membership probe used `.maybe_single()` but still read
   `if not membership.data` without the `not membership` guard. With the
   real client (bare `None` on zero rows) a FIRST-time add to a collection
   would 500 (AttributeError) instead of upserting. The pre-existing local
   fake override (`builder._bare_none = False`) made `maybe_single` return a
   falsy *response object* instead of bare `None`, so the suite passed.
   Fixed the guard and **removed the override** (the shared FakeDB's
   `maybe_single` already mirrors the real client). A follow-up scan across
   every `maybe_single` assignment in `app/` (113 call sites) found one
   further unguarded access — pre-existing, not sweep-introduced:
   `users.py` avatar-replace reads `row.data` before checking `row`, so a
   missing row hit AttributeError (swallowed by the local try/except, then
   the old avatar leaked). Guard fixed in the same pass. A committed-tree
   audit additionally caught one dropped hunk: `find_similar_items`' source
   fetch was converted in the working tree but a split-staging bug left
   `.single()` in the commit — the hardened FakeDB exposed it
   (`test_find_similar_raises_not_found`), and the hunk is now in the
   commit.
2. **Shared FakeDB `.single()` fidelity** (`tests/utils/fake_db.py`):
   `single()` returned a falsy result on zero rows, while the real client
   raises (406/PGRST116). That divergence is what let the original dead
   `if not result.data` guards ship. `FakeDB.single()` now raises
   `PGRST116Error` (code `PGRST116`, 406) on zero rows, matching
   postgrest-py; only `maybe_single()` returns `None`. No test currently
   exercises `single()` on the shared fake (deps.py keeps it and catches
   the raise by design), so a future misuse fails loudly instead of
   silently passing.
3. **Commit hygiene**: the fix commit initially included the user's
   UNCOMMITTED `get_public_outfit` `presigned=True` change (code + test +
   import) via whole-file staging. Worse, that hunk referenced a
   `presigned` kwarg that only exists in the user's uncommitted
   `images.py`, so the committed tree's public share-link endpoint would
   have TypeError'd. The commit was amended to exclude it; the user's
   change remains uncommitted in the working tree.

Also corrected from the first write-up: the 6 image-agent test failures
seen during the sweep were NOT caused by the uncommitted `models/ai.py`
`save_to_storage=True` flip. Re-running the identical source tree after
the harness fixes gives **3660 passed, 0 failed** with `models/ai.py`
still flipped; the failures were a stale pytest assertion-rewrite cache
artifact and do not reproduce.

### Tests

```bash
cd backend && source .venv/bin/activate
python -m pytest -q   # 3660 passed, 0 failed, 4 skipped (99.89% coverage)
ruff check app/ tests/
```

### Ops checklist (THIRD re-emphasis — still not executed as of 2026-08-09 04:45)

1. Apply pending migrations in order on hosted Supabase (016, 019, 023, 035, 036, 039, 041 re-apply, 042; everything 016→042 not yet applied), then `NOTIFY pgrst, 'reload schema';`.
2. Railway env: `AI_ENCRYPTION_KEY=$(openssl rand -hex 32)`, `STRIPE_SECRET_KEY`, the four `STRIPE_*_PRICE_ID` vars; healthcheck path → `/health`.
3. Deploy HEAD (this fix + the uncommitted 08-08 hardening once it is verified/committed).

### Deferred debt

- The uncommitted 08-08 evening hardening (item-write schema-gap 503s, migration re-runnability, exception-type logging, and the `get_public_outfit` presigned-URL + images.py `presigned` kwarg work) still awaits verification + commit. NOTE: the pending `get_public_outfit`/`images.py` presigned change is internally consistent and required together — the public share-link endpoint currently serves worker-mode URLs that 404 for anonymous viewers until both land.
- TD-043 (async Supabase client) remains the full fix for pooled-connection outages.
