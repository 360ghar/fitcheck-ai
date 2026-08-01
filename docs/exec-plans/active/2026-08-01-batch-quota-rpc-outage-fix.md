# Plan: Batch extract quota-RPC outage fix (2026-07-31)

Status: active
Started: 2026-08-01
Owner: agent

## Goal

Production `POST /api/v1/ai/batch-extract-multipart` returned 500 ("Failed to
reserve AI usage") and 503 ("Failed to ensure AI settings row") on
2026-07-31 21:15 UTC because the deployed backend (a124226) enforces quotas
through hosted-Supabase RPCs created by migrations 022/024/026, which had
never been applied to the hosted project. This change (1) makes every quota
reservation failure a **friendly 503** for the client (`AI_SERVICE_ERROR`)
while logging the actionable detail (which function, which migrations) for
operators — raw DB/RPC text is never sent to users, (2) adds a retry hint for
the new-user FK race that caused the 503s, and (3) fixes the web UI to show
friendly copy instead of Axios's generic "Request failed with status code 503".
The actual fix is operational: apply the three migrations and set
`AI_ENCRYPTION_KEY` (runbook below).

## Non-goals

- No retry loops or circuit breakers for the missing-RPC case (a retry cannot
  apply migrations; fail fast and name the fix).
- No changes to the quota limits, reservation semantics, or SQL migrations
  themselves (they are correct; they were simply never applied).
- No frontend redesign; only the error-message rendering in the upload flow.
- The Gemini quota-breaker work in `stash@{0}` remains stashed (superseded by
  a124226's stateless classification, per TD-028 note in
  `docs/exec-plans/tech-debt-tracker.md`).

## RCA

| # | Finding | Evidence | Fix |
|---|---------|----------|-----|
| RC1 | Migrations 022/024/026 never applied to hosted Supabase → `reserve_ai_usage` / `release_ai_usage` / `reserve_usage` missing → every admission fails with `DatabaseError` (500) | Live PostgREST OpenAPI listing shows only pre-022 RPCs; logs show `Failed to reserve AI usage` ×2 per request (concurrent extraction+generation reservations) then 500 | Ops: apply migrations; code: PGRST202 → friendly 503 + operator log hint (this change) |
| RC2 | `ensure_ai_settings_row` row-provisioning upsert fails (new-user FK race on `users(id)` 23503, or transient PostgREST error) → `AIServiceError` 503 with opaque message | Logs show `Failed to ensure AI settings row` ×2 then 503 | Code: 503 kept, FK case gets a friendly "account still being set up, retry" message; detail logged |
| RC3 | `AI_ENCRYPTION_KEY` empty in prod → BYOK key saves raise at request time | Startup `Config issue at startup: AI_ENCRYPTION_KEY` on every boot | Ops: set `AI_ENCRYPTION_KEY=$(openssl rand -hex 32)` |
| RC4 | Web UI shows Axios's generic "Request failed with status code 503" | `useBatchExtraction.ts` used `error.message` directly | Code: friendly-copy helper keyed on `code`/`status`/`errorKind` + leak-guard tests |

## Code changes

1. `backend/app/utils/db.py` (new helpers): `is_pgrst202_missing_rpc` /
   `missing_rpc_log_hint` (PGRST202 / "could not find the function") shared by
   every quota-admission path, plus `QUOTA_UNAVAILABLE_CLIENT_MESSAGE` (the
   friendly client copy).
2. `backend/app/services/ai_settings_service.py`:
   - `reserve_usage` / `release_usage`: missing RPC → **log** the actionable
     hint (function + migrations), raise a friendly retryable `AIServiceError`
     503; other RPC failures → log detail, same friendly 503 (no opaque 500,
     no raw DB text to clients).
   - `ensure_ai_settings_row`: 23503 / `users_id_fkey` → friendly
     "account still being set up" 503 with detail logged.
3. `backend/app/services/subscription_service.py` `increment_usage`: same
   PGRST202-aware friendly 503 (covers single-extract / embeddings /
   recommendations / photoshoot monthly-quota paths).
4. `backend/app/api/v1/items.py`: duplicate-check and find-similar endpoints
   re-raise `AIServiceError` instead of folding it into a generic
   `DatabaseError` 500, so the friendly 503 survives.
5. `backend/tests/test_wave_b_hardening.py`: 4 regression tests asserting the
   client sees friendly copy (no `reserve_ai_usage` / `022/024/026` in the
   message) while the detail is present in the server log (`caplog`).
6. `frontend/src/lib/batch-extraction-errors.ts` (new):
   `getBatchExtractionErrorMessage` maps `code`/`status`/`errorKind` to
   friendly copy (network / service / fallback) and never renders the backend
   body; `frontend/src/hooks/useBatchExtraction.ts` uses it;
   `frontend/src/lib/__tests__/batch-extraction-errors.test.ts` (new,
   5 cases including a leak guard).
7. `docs/BACKEND.md`: "Quota reservation migrations" section (friendly 503 +
   logged detail).

## Ops runbook (human — the actual fix)

1. Supabase (hosted project `ckzpgfibnqmwzrndsvcx.supabase.co`) → SQL editor.
   **Verify before applying** (migrations may already be applied; re-running a
   migration that is already applied must not fail — 023 is now re-runnable
   via drop-then-create guards, but verify anyway to keep the DB honest):
   ```sql
   SELECT proname FROM pg_proc WHERE proname IN
    ('create_social_import_job','reserve_usage','apply_referral_credit_atomic','redeem_referral_atomic',
     'reserve_ai_usage','release_ai_usage','reserve_daily_photoshoot_usage','release_daily_photoshoot_usage');
   SELECT to_regclass('public.extraction_jobs') AS extraction_jobs,
          to_regclass('public.photoshoot_jobs') AS photoshoot_jobs,
          to_regclass('public.stripe_webhook_events') AS stripe_webhook_events,
          to_regclass('public.apple_iap_events') AS apple_iap_events,
          to_regclass('public.google_rtdn_events') AS google_rtdn_events;
   SELECT conname, pg_get_constraintdef(oid) FROM pg_constraint
   WHERE conrelid = 'public.extraction_jobs'::regclass AND conname = 'valid_batch_size';
   ```
2. Apply **all** unapplied migrations **in order** (each is idempotent except
   where noted; verify-then-run keeps the SQL editor from aborting):
   - `016_extraction_jobs.sql` (if `extraction_jobs` is absent)
   - `022_wave_b_hardening.sql` (stripe_webhook_events + quota/referral RPCs)
   - `023_durable_job_state.sql` (durable job rows + CHECK ≤50; re-runnable)
   - `024_atomic_daily_quota_reservations.sql` (daily quota RPCs)
   - `025_calendar_all_day_events.sql`
   - `026_harden_rpc_privileges.sql` (service_role-only RPC execution)
   - `027_stripe_webhook_processing_state.sql`
   - `028_configurable_social_import_limit.sql`
   - `029_pr9_hardening.sql` (raises valid_batch_size CHECK to ≤100)
   - `030_mobile_iap.sql`
3. Railway backend service → Variables:
   `AI_ENCRYPTION_KEY=$(openssl rand -hex 32)`; restart.
4. Deploy updated main. After boot, confirm the new startup probes log no
   `Quota reservation RPCs missing` error and no `Config issue at startup:
   AI_ENCRYPTION_KEY` line.

## Progress log

| Date | Note |
|------|------|
| 2026-08-01 | Started; pull a124226 onto main (user work stashed, restoration handled in parallel session). Backend + frontend fixes implemented with regression tests; backend tests 28/28 targeted, frontend 4/4. |
| 2026-08-01 | Client-error policy tightened: backend logs the actionable detail (missing RPC + migrations), clients get friendly copy only (never raw DB text). Backend tests updated to pin the friendly message + `caplog` detail; frontend helper rewritten as a friendly mapper with a leak guard. |
| 2026-08-01 | Rerun of 023 on hosted Supabase aborted with `42710 trigger "photoshoot_jobs_updated_at" already exists` — confirmed 023 was already applied (its constraint block is idempotent, the trigger/policies were not). 023 made re-runnable (`DROP TRIGGER/POLICY IF EXISTS` guards). |
| 2026-08-01 | Second failure class found after the RPC fix: raw postgrest errors from the durable-job write (`extraction_jobs`/`photoshoot_jobs` upsert, migrations 016/023) escaped `JobPersistenceStore.create` as opaque 500s ("Failed to start multipart batch extraction"). `create_job` in both job services now wraps them into the friendly retryable 503 + logged migration hint (`job_persistence_migration_hint`), with the exception type in the message text (Railway's drain drops `extra`). Regression tests added (22/22 in test_wave_b_hardening.py; 706/706 backend). |
| 2026-08-01 | Deferred-debt item implemented: boot-time `missing_quota_rpcs` probe (non-mutating nil-UUID RPC calls) logs a runbook hint in `_seed_schema_status_in_thread`; `extraction_jobs`/`photoshoot_jobs` added to the `/ready` table check. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-01 | Missing-RPC errors are a friendly 503 + retryable; detail goes to server logs only | Clients should never see DB/RPC/migration internals — a user cannot fix a migration gap, so the message must be friendly copy while operators get the actionable detail in logs |
| 2026-08-01 | Do not port the stashed Gemini stateful breaker | a124226's stateless classification already fails fast to the fallback (TD-028 superseded) |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest tests/test_wave_b_hardening.py tests/test_ai_settings_service.py
cd frontend && npx vitest run src/lib/__tests__/batch-extraction-errors.test.ts
cd frontend && npx eslint src/hooks/useBatchExtraction.ts src/lib/batch-extraction-errors.ts src/lib/__tests__/batch-extraction-errors.test.ts
python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

## Deferred debt

- `AI_ENCRYPTION_KEY` still empty in prod until the runbook is executed.
- ~~Migrations 022/024/026 application is not verifiable from code; add a
  boot-time RPC-presence check if this class of failure recurs.~~ **Done
  2026-08-01** — `missing_quota_rpcs` (non-mutating nil-UUID probes) runs at
  boot in `main._seed_schema_status_in_thread` and logs the runbook hint when
  any quota RPC is absent; `extraction_jobs`/`photoshoot_jobs` added to the
  `/ready` table check. Remaining migration state (016/023 tables, CHECK
  bounds) is covered by the verify-before-apply queries in the runbook above.
