# Plan: 2026-08-05 production log RCA + fixes

Status: active
Started: 2026-08-05
Owner: agent

## Goal

RCA and fix every error class in the 2026-08-05 production log drain (Railway
backend). Continuation of the 08-01 / 08-03 production-log RCAs. The dominant
failure this round is the Supabase pooled-connection 500 family again, but on
three handlers the prior passes never wrapped (`POST /items`, `GET /items/{id}`,
OAuth-sync upsert), plus a new class of frontend-driven noise (billing 503
retry spam, upload client-abort 400s) and an AI-provider misconfiguration
(`default_provider='openai'` hard-fail).

## RCA

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `GET /api/v1/items` + `POST /api/v1/items` (Create item error) + `GET /api/v1/items/{id}` (Get item error) -> 500 `DATABASE_ERROR` (bursts every few minutes) | Dead pooled Supabase HTTP/2 connection (same class as 08-01/08-03). `list_items` was already wrapped, but `create_item` (item + image inserts) and `get_item` were raw `asyncio.to_thread`, so a single dropped connection surfaced as an immediate 500. | **Code**: wrap the item insert, image insert, and `get_item` select in `execute_with_reconnect`. Inserts are PK-gated by client uuids, so a lost-response retry cannot duplicate. |
| 2 | `OAuth sync error` -> `POST /auth/oauth/sync` 500 (16 s) | The OAuth-sync profile upsert (`_upsert_user_profile`) only retried FK errors, not connection-class errors. Registration wraps the same helper; OAuth sync did not. | **Code**: wrap the OAuth-sync upsert in `execute_with_reconnect` (idempotent `on_conflict="id"`), mirroring registration. |
| 3 | Concurrent rebuild races (`deque mutated during iteration`) amplifying the 500 bursts | Every concurrent failing request independently called `SupabaseDB.reset()` + `get_service_client()`, tearing the singleton down N times and racing httpcore's pool bookkeeping. | **Code**: `connection.py` adds a `threading.Lock` + `rebuild_service_client()` that atomically resets + recreates under the lock (double-checked locking in `get_service_client`). The reconnect wrappers and the `subscription_service` bespoke retry now call it, so a failure wave shares ONE fresh client. |
| 4 | `AI provider 'openai' is not configured` -> `POST /ai/generate-outfit` 503 (burst at 12:27) | Affected user(s) had `user_ai_settings.default_provider='openai'`; production has no system OpenAI key and no user BYOK key, so `get_effective_provider_config` raised hard. | **Code**: `get_ai_service_for_user` falls back to the system default provider (`custom`/Agnes) instead of raising; save-time validation in `/ai_settings` rejects selecting a provider with no resolvable config. **Ops**: one-time `UPDATE user_ai_settings SET default_provider='custom' WHERE default_provider='openai'`. |
| 5 | `Image generation ... trying fallback model` -> 400 on BOTH `agnes-image-2.1-flash` and `agnes-image-2.0-flash` (repeated all day) | A content-policy 400 was marked `fallback_eligible`, so the image loop re-POSTed the identical blocked prompt to the fallback model. Both image models resolve to the same Agnes gateway (verified: `get_image_api_url() == get_image_fallback_api_url() == https://apihub.agnes-ai.com/v1`) behind one upstream safety policy, so it 400'd identically and cost ~double latency. | **Code**: a content-policy refusal now earns the fallback attempt only when the fallback is a **different host**; transient (429/503) errors still swap models on any host. This kills the same-gateway waste while preserving the cross-vendor retry the 08-03 pass intended (`AI_IMAGE_FALLBACK_API_URL` pointed elsewhere re-enables it). Both branches are tested. |
| 6 | `POST /subscription/checkout|portal` -> 503 in rapid bursts | Fail-closed 503 is correct (Stripe unset), but it is a *permanent* 503 that the frontend's transport-retry interceptor retried 3x, and the Manage Billing button rendered for Pro-via-promo users regardless of `billing_configured`. | **Code**: new `BillingNotConfiguredError` (distinct `BILLING_NOT_CONFIGURED` code, same 503 status); frontend skips retry on that code and the panel gates Manage Billing/Upgrade on `billing_configured !== false`. |
| 7 | `POST /items/upload`, `/users/me/avatar`, `/outfits/{id}/images` -> 400 after 60-200 s | These upload paths are not in the frontend `LONG_RUNNING_PREFIXES`, so the axios client aborted at the 30 s default while the server kept doing Pillow validation + S3 PUTs through the 4-worker image executor; the late disconnect surfaced as a multipart 400. | **Code (frontend)**: add the three upload paths to `LONG_RUNNING_PREFIXES`. **Ops follow-up**: raise `IMAGE_PROCESS_WORKERS` if batch-extract + upload concurrency is high (see tech-debt-tracker). |
| 8 | `POST /photoshoot/generate` -> 400 @ ~300000 ms | The `sync=True` (React) path has no end-to-end deadline; the Railway proxy cut it at ~300 s with an opaque 400. | **Code**: wrap the sync generation in `asyncio.wait_for(timeout=270)` -> clean `ServiceError` 503. Follow-up: move the React client to the `202 + SSE` flow Flutter already uses. |
| 9 | `POST /referral/validate` -> 422 | `ValidateReferralRequest.code min_length=3`; the register page validates as the user types (same bug already fixed for promo). | **Code**: `min_length=1`, mirroring `ValidatePromoRequest`. |
| 10 | `GET /api/v1/items` -> 422 (intermittent) | Invalid `category`/`condition` filter value raised `ValidationError` on a browse endpoint. | **Code**: unknown filter values are now dropped (logged) and the query proceeds, rather than 422-ing the whole page. |
| 11 | `GET /api/v1/calendar` -> 404, `GET /robots.txt` -> 404 | Calendar router has no root handler; backend has no `/robots.txt` (scanners / stale clients / misrouted ingress). | **Code**: calendar root GET returns a status/links object; backend serves a permissive `robots.txt`. |
| 12 | Gemini `503 UNAVAILABLE` / `429 RESOURCE_EXHAUSTED`, `register`/batch/`SERVER_BUSY` 429, `415 invalid-image`, refresh-token `"already used"` | Upstream provider quota / correct rate-limiting / bad input / Supabase token rotation. | **By design** — no code change. The native-Gemini->Agnes fallback, rate limiters, Pillow validation, and refresh single-flight+latch all work as intended. |

## Code changes

1. `backend/app/db/connection.py`: module-level `threading.Lock`; double-checked
   locking in `get_client`/`get_service_client`/`reset`; new
   `rebuild_service_client()` (atomic reset + recreate under the lock).
2. `backend/app/utils/db.py`: `execute_with_reconnect` and
   `run_sync_with_reconnect` rebuild via `SupabaseDB.rebuild_service_client()`
   (off-thread for the async variant) instead of bare `reset()` +
   `get_service_client()`.
3. `backend/app/api/v1/items.py`: `create_item` item/image inserts and
   `get_item` wrapped in `execute_with_reconnect`; `category`/`condition`
   filters degrade gracefully (drop unknown values, log) instead of 422.
4. `backend/app/api/v1/auth.py`: OAuth-sync `_upsert_user_profile` wrapped in
   `execute_with_reconnect`.
5. `backend/app/services/subscription_service.py`: bespoke `check_limit`
   rebuild now uses `rebuild_service_client()`.
6. `backend/app/services/ai_settings_service.py`:
   `get_ai_service_for_user` falls back to the system default provider when the
   requested provider has no resolvable config (instead of raising).
7. `backend/app/api/v1/ai_settings.py`: `_provider_has_usable_config` validates
   on save that the chosen `default_provider` has a system key, a BYOK key in
   the request, or an existing stored BYOK key.
8. `backend/app/services/ai_provider_service.py`: image model-fallback loop
   gates a content-policy refusal on a cross-host fallback
   (`e.retryable or (e.fallback_eligible and next_url != attempt_url)`), so the
   same-gateway double-400 stops while a genuinely different vendor is still
   tried.
9. `backend/app/core/exceptions.py`: `BillingNotConfiguredError(ServiceError)`
   with `error_code="BILLING_NOT_CONFIGURED"`.
10. `backend/app/api/v1/subscription.py`: `/checkout` and `/portal` raise
    `BillingNotConfiguredError` when Stripe is unset.
11. `backend/app/api/v1/photoshoot.py`: `sync=True` generation wrapped in
    `asyncio.wait_for(timeout=270)` -> `ServiceError` on timeout.
12. `backend/app/models/subscription.py`: `ValidateReferralRequest.code`
    `min_length=1`.
13. `backend/app/api/v1/calendar.py`: root `GET ""` handler.
14. `backend/app/main.py`: `/robots.txt` route + `PlainTextResponse` import.
15. `frontend/src/api/client.ts`: retry interceptor skips
    `BILLING_NOT_CONFIGURED` 503s.
16. `frontend/src/components/settings/SubscriptionPanel.tsx`: Manage Billing /
    Upgrade gated on `plans?.billing_configured !== false`.
17. `frontend/src/lib/endpoints.ts`: `LONG_RUNNING_PREFIXES` gains
    `/items/upload` and `/users/me/avatar`, plus an exported
    `UPLOAD_TIMEOUT_MS`; `frontend/src/api/outfits.ts` sets that timeout on the
    templated `/outfits/{id}/images` upload at the call site.

## Self-review findings (caught and fixed before hand-off)

Two defects in this pass's own work, found by re-reading each edit against its
surrounding code rather than trusting the green suite:

1. **`.execute` without call parens (critical, would have broken every request).**
   The three new `execute_with_reconnect` builders in `items.py` were written
   `lambda d: ....execute` instead of `....execute()`. `asyncio.to_thread`
   happily returns the *uncalled bound method*, so `inserted.data` /
   `result.data` would raise on **every** `POST /items` and `GET /items/{id}`,
   not only during a connection blip — strictly worse than the bug being fixed.
   The existing `test_small_routes_async.py` guard cannot catch this (it treats
   everything inside `execute_with_reconnect(...)` as correctly offloaded).
   Fixed, and locked with two new tests in `test_db_connection_retry.py`:
   a behavioral one and an AST guard over all `app/` builders. The AST guard was
   verified to fail when the bug is reintroduced (`items.py:276`) and to pass on
   the fixed tree — note it must NOT flag the opposite-but-correct
   `asyncio.to_thread(chain.execute)` convention, which an earlier regex version
   wrongly did.
2. **Over-broad upload timeout.** Adding `ENDPOINTS.OUTFITS.BASE` to
   `LONG_RUNNING_PREFIXES` gave *every* outfit read a 10-minute ceiling
   (matching is `url.includes(prefix)`), defeating the documented "fail fast so
   the UI doesn't freeze" intent. Replaced with a call-site timeout on the one
   templated upload path.

## Verification

- `ruff check app/ tests/`: clean.
- `python scripts/check_architecture.py`: passed.
- `pytest` (full backend suite): **1030 passed, 1 skipped** (was 1020 before the
  4 new regression tests). Updated `test_db_connection_retry.py`,
  `test_outfits_response_models.py`, `test_promo_service.py`,
  `test_referral_connection_retry.py`, `test_subscription_service.py`,
  `test_wave_a_auth_ownership_storage.py` for the `rebuild_service_client` API;
  `test_ai_provider_service.py` now covers BOTH fallback branches (cross-host
  retry allowed, same-host refusal not retried).
- Behavioral checks beyond the suite: drove `execute_with_reconnect` against a
  dead-then-fresh mock to prove the fixed insert builder returns a real response
  object; confirmed the pre-fix shape raises; verified the production config
  resolves primary and fallback image URLs to the *same* host (so fix #5 applies
  to the real deployment); verified the filter-sanitizing closure observes the
  cleaned values and never indexes an empty category list.
- `npm run lint` + `npm run build` (frontend): clean (`tsc` typecheck passed).
  The `[indexnow] 422` in postbuild is a pre-existing SEO-ping issue, unrelated.
- Known pre-existing failure, untouched by this pass:
  `scripts/check_docs_structure.py` reports `docs/generated/db-schema.md` stale
  vs migration `036_widen_image_url_columns.sql` (predates this session; needs
  `generate_db_schema_doc.py` against the DB).

## Follow-ups (tech-debt-tracker)

- The React photoshoot client already migrated to the `202 + SSE` flow
  (TD-019, 2026-08-03), yet the 08-05 logs still show `sync=true` calls timing
  out at ~300 s — so an unidentified caller (stale build / direct API use) is
  still hitting sync mode. The `asyncio.wait_for(270)` deadline added this pass
  is the defensive mitigation; identify and retire that remaining caller.
- Raise `IMAGE_PROCESS_WORKERS` above 4 if batch-extract + upload concurrency
  stays high (root cause of the long server-side upload durations, TD-069).
- Optional observability: a distinct `AUTH_REFRESH_TOKEN_REUSED` code from the
  refresh service so the frontend could one day distinguish rotation-reuse from
  a hard refresh failure (no behavior change now; force-logout stays correct).
