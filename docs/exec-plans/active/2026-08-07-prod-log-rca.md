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
   `NOTIFY pgrst, 'reload schema';` afterwards.
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
