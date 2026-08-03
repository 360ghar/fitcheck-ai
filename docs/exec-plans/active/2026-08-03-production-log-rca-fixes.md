# Plan: 2026-08-03 production log RCA + fixes

Status: active
Started: 2026-08-03
Owner: agent

## Goal

RCA and fix every error class in the 2026-08-03 production log drain (Railway
backend). This is the follow-up to the 2026-08-01 RCA (`2026-08-01-production-log-rca-fixes.md`).
The config-missing boot warnings and checkout 503s persisted because the ops
runbook from 08-01 was not applied; the `ConnectionTerminated` family spread to
endpoints not covered by 08-01's reconnect wiring; and the Agnes image gateway
began rejecting try-on/photoshoot/outfit content with 400.

## RCA

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `POST /api/v1/subscription/checkout \| 503` and `/portal \| 503` (dozens across the whole day) | `STRIPE_SECRET_KEY` + 4 `STRIPE_*_PRICE_ID` still unset in production (boot check #10 fires every startup). 08-01's runbook was never applied. Fail-closed 503 is correct posture. | **Ops**: set the five Stripe vars (runbook below). No code change - the boot check + fail-closed path already exist. |
| 2 | `Config issue at startup: AI_ENCRYPTION_KEY / APPLE_ISSUER_ID / STRIPE_SECRET_KEY` | Same missing env as #1 and 08-01 #1/#2. | **Ops**: apply the 08-01 runbook (openssl key, ASC API key, Stripe keys). |
| 3 | `Error getting subscription for user: <ConnectionTerminated ...>` -> `/subscription 500`, `/referral/stats 500`, `/referral/code 500`, `/users/dashboard 500`, `/users/me 500`, `/users/settings 500` | Dead pooled Supabase HTTP/2 connection again (same class as 08-01 #3/#4), but on paths 08-01 did not wrap: `get_subscription` itself, referral service, users `/me`/`/settings`/`/dashboard`. `check_limit` retried internally but the top-level endpoints call `get_subscription` directly. | **Code**: route the reads through `execute_with_reconnect` / `run_sync_with_reconnect` - `get_subscription` (the shared choke point behind subscription/referral/dashboard/usage), referral service queries, users `/me`, `_get_or_create_record`/`_upsert_record` (settings/preferences), and the whole `get_dashboard` body. |
| 4 | `List outfits error` -> `/outfits 500` (5x; one took 121 s) | Same dead pooled connection; `list_outfits` was never wrapped (08-01 wrapped `create_outfit` only). | **Code**: count/page/items queries in `list_outfits` rebuilt through `execute_with_reconnect` via a shared `_apply_outfit_filters` helper. |
| 5 | `Error checking limit for user ... deque mutated during iteration` -> `/ai/generate-outfit 500` | `RuntimeError` from httpcore's HTTP/2 pool when the same shared Supabase client is used concurrently (iterating the pool deque while another coroutine mutates it). Not an httpx transport subclass and not covered by the string markers, so `check_limit`'s one-shot retry never fired. | **Code**: add `"deque mutated during iteration"` + `"list changed size during iteration"` to `_DB_CONNECTION_TEXT_MARKERS` so the existing reconnect retry fires. |
| 6 | `Failed to reserve AI usage` burst (08:16) + `Failed to upload file` / `Failed to upload item image` (08:14) | Same dead pooled connection hitting the `reserve_ai_usage` RPC and Supabase Storage uploads during a multi-item upload while the gateway restarted. | **Code**: wrap `reserve_ai_usage`/`release_ai_usage` RPCs and the item/outfit/file storage uploads with `execute_with_reconnect`. Storage uploads are same-path overwrites, so the retry is exact-once safe. |
| 7 | `Duplicate check error` -> `/items/check-duplicates 500` (08:15) | Coincident with the dead-connection window (#6): the items batch fetch in the duplicate handler was an unwrapped read. Lower volume; same class. | **Code**: wrap the `items ... in_()` fetch in the duplicate handler with `execute_with_reconnect`. |
| 8 | `Gemini request failed: 429 RESOURCE_EXHAUSTED` (free-tier, limit 20/day on gemini-3.6-flash) -> `Extraction failed for image`, `Generation failed for item`, `Generate outfit error` | Gemini API key is on the free tier: the daily per-model quota (20) is exhausted. `classify_gemini_error` already treats daily-quota 429 as non-retryable so the hybrid vision leg falls over to Agnes, but Agnes also fails under this load, so extractions/generations still fail. 08-01's `AI_GEMINI_MAX_REQUESTS_PER_MINUTE` knob spaces bursts but cannot raise a daily cap. | **Ops**: move Gemini to a paid tier, or accept the free-tier daily cap and ensure the Agnes vision/image fallback key is configured (`AI_VISION_FALLBACK_API_KEY`, `AI_IMAGE_FALLBACK_API_KEY`). No code change - the classification + fallback + spacing already exist. |
| 9 | `Image generation request failed (status=400, model=agnes-image-2.1-flash): Unable to generate this content` (persistent, every try-on/photoshoot/outfit; one 402 `subscription pre-verify unavailable`) | Agnes image gateway returns an OpenAI-style content-policy refusal for the photorealistic person-in-garment generations (try-on uses the user's real photo as reference A). It is a provider-side rejection, non-retryable by design (a same-model retry fails identically; 08-01 documented the "no fallback on content-policy" rule to avoid double-billing). The 30-45 s request time is the model itself before refusing, not retries. | **Code (fixed in this pass)**: a 400 with the "Unable to generate this content" body is now classified content-policy via `AIProviderService._is_content_policy_rejection` and raised with the new `fallback_eligible` flag (NOT `retryable`, so the agent-level `with_retry` does not amplify multi-second latency). The image-attempts loop falls through to the configured fallback MODEL once - safe because a 400 generated/billed nothing. If the fallback also refuses, the user gets the 503 after ~2 calls instead of 1, and the log names both models. **Ops still applies** for the model that actually accepts person+garment image-to-image (options below). |
| 10 | `Killed` (05:33) then server restart | Container OOM during the try-on/image-gen storm (each request buffers multi-MB base64 images; `PHOTOSHOOT_CONCURRENCY_LIMIT=2` bounds photoshoot but try-on/outfit requests are unbounded). | **Code (fixed in this pass)**: `app/core/concurrency.py` gains `image_gen_slot()` - a reentrant per-task wrapper over the process-wide `GENERATION_SEMAPHORE` (AI_GENERATION_CONCURRENCY, default 30). Every image-generation caller (try-on, outfit, product, batch items, variations, photoshoot) acquires it; entry points nest (variations -> generate_outfit -> _generate_with_references), so reentrancy is tracked via a ContextVar and nested acquisitions are no-ops. Photoshoot keeps its local `PHOTOSHOOT_CONCURRENCY_LIMIT` fan-out cap AND the shared slot. `_generate_image` / `_generate_with_references` / `generate_try_on` / both photoshoot sites are wired; batch and variations were converted from the raw semaphore to the slot. |
| 11 | `Failed to fetch settings` (06:22) | `GET /users/settings` on the dead pooled connection (#3); fixed by the `_get_or_create_record` reconnect wrap. | Same as #3. |
| 12 | `Error getting subscription/usage/referral stats for user: 11` / `41` / `45` / `79` / `81` (bare integers), `Invalid input StreamInputs.SEND_HEADERS in state 5`, `Invalid input ConnectionInputs.RECV_DATA in state ConnectionState.CLOSED`, `Server disconnected` | Same dead pooled connection, but the error text was NOT matched by `is_db_connection_error`: some h2/httpcore versions collapse `ConnectionTerminated` to the bare `error_code` (numeric-only), and the `ProtocolError` state-machine strings / plain "Server disconnected" were not in the marker list - so the retry never fired on those calls. | **Code (fixed in this pass)**: `is_db_connection_error` now treats a numeric-only `str(exc)` as connection-class, and the marker list gains `"invalid input"` and `"server disconnected"`. Tests in `test_db_connection_retry.py` cover all three shapes. |
| 13 | `Error validating referral code ony-77ee88`, `POST /referral/redeem`, `POST /promo/validate`, `POST /promo/redeem`, `Error getting daily usage for user ...: 45` -> photoshoot 500 | The last unwrapped hot paths: `validate_referral_code`/`redeem_referral` (raw `to_thread`), `PromoService.validate_promo`/`redeem_promo`, `SubscriptionService.get_or_create_usage_record` (the remaining unwrapped call inside `get_usage` - the "Error getting usage" 500s), and `PhotoshootService.get_or_create_daily_usage`. | **Code (fixed in this pass)**: all wrapped in `execute_with_reconnect`. The redeem RPCs (`redeem_referral_atomic`, `redeem_promo_atomic`) are single transactions, so a reconnect retry cannot double-grant - the second attempt returns already-redeemed. The usage-record insert became an `upsert on_conflict="user_id,period_start"` (unique key from migration 007) so the retry is exact-once. |
| 14 | `POST /subscription/checkout | 503` UX: users tap upgrade and get an error toast | Stripe env still unset (#1). The fail-closed 503 is correct, but the UI offered buttons that could only fail. | **Code (fixed in this pass)**: `GET /subscription/plans` now returns `billing_configured` (true only when the Stripe key + all four price IDs are set). `SubscriptionPanel` renders a "payments are being set up" notice instead of upgrade buttons when it is false; the promo-code card stays the working path. **Ops env change still required** for real checkout. |

## Code changes

1. `backend/app/utils/db.py`: `_DB_CONNECTION_TEXT_MARKERS` gains
   `"deque mutated during iteration"` and `"list changed size during iteration"`
   (httpcore HTTP/2 pool `RuntimeError` under concurrent shared-client use).
2. `backend/app/services/subscription_service.py`: `get_subscription` runs both
   reads and `create_default_subscription` (idempotent `on_conflict` upsert)
   through `execute_with_reconnect` - heals `/subscription` and every caller
   that reaches `get_subscription` directly.
3. `backend/app/api/v1/outfits.py`: `list_outfits` count/page/items queries
   rebuilt through `execute_with_reconnect` via a shared `_apply_outfit_filters`
   helper (replaces the duplicated filter block).
4. `backend/app/services/referral_service.py`: `get_or_create_referral_code`
   and `get_referral_stats` reads wrapped (`referral_codes`, `users`,
   `referral_redemptions`).
5. `backend/app/api/v1/users.py`: `/me` select wrapped; `_get_or_create_record`
   and `_upsert_record` select/update wrapped via `run_sync_with_reconnect`
   (heals `/settings`, `/preferences`, body-profile reads); `get_dashboard`
   body factored into `_dashboard_data(d)` and replayed through
   `execute_with_reconnect`.
6. `backend/app/services/ai_settings_service.py`: `reserve_ai_usage` and
   `release_ai_usage` RPCs wrapped.
7. `backend/app/services/storage_service.py`: item/outfit/raw `upload_file`
   uploads wrapped (retried upload overwrites the same path - exact-once).
8. `backend/app/api/v1/items.py`: `/items/check-duplicates` items batch fetch
   wrapped.
9. Tests: `tests/test_db_connection_retry.py` +3 (deque-mutation marker match,
   `get_subscription` reconnect wiring, `list changed size` marker) and
   `tests/test_outfits_response_models.py` +1 (`list_outfits` reconnect).

### Second pass (this session) - closes the follow-ups from the first pass

10. `backend/app/utils/db.py`: `is_db_connection_error` additionally matches
    numeric-only error text (bare h2 `error_code`: `11`/`41`/`45`/`79`/`81`),
    `"invalid input"` (h2 `ProtocolError` state strings like `Invalid input
    StreamInputs.SEND_HEADERS in state 5`), and `"server disconnected"`.
    Tests +3 in `tests/test_db_connection_retry.py`.
11. `backend/app/services/subscription_service.py`:
    `get_or_create_usage_record` (the last unwrapped call behind the
    "Error getting usage" 500s) now selects through `execute_with_reconnect`
    and creates via idempotent `upsert on_conflict="user_id,period_start"`.
12. `backend/app/services/referral_service.py`: `validate_referral_code` and
    `redeem_referral` (RPC) wrapped. New `tests/test_referral_connection_retry.py`
    covers both.
13. `backend/app/services/promo_service.py`: `validate_promo` and
    `redeem_promo` (RPC) wrapped. `tests/test_promo_service.py` +2 retry cases.
14. `backend/app/services/photoshoot_service.py`:
    `get_or_create_daily_usage` reset RPC + read wrapped.
15. `backend/app/core/concurrency.py`: new `image_gen_slot()` reentrant
    per-task context manager over `GENERATION_SEMAPHORE` (TD-044). Wired into
    `_generate_image`, `_generate_with_references`, `generate_try_on`
    (`image_generation_agent.py`), both photoshoot generation sites
    (`photoshoot_service.py`, alongside the local fan-out cap), and batch
    items / variations converted from the raw semaphore to the slot.
    New `tests/test_concurrency_slot.py` (acquire/release, reentrancy,
    serialization, exception release).
16. `backend/app/services/ai_provider_service.py`: content-policy 400
    ("Unable to generate this content") on the images API is raised with the
    new `fallback_eligible` flag on `AIServiceError` (added in
    `app/core/exceptions.py`) - the attempts loop tries the fallback model
    once without making the agent-level retry fire. Tests +3 in
    `tests/test_ai_provider_service.py`.
17. `backend/app/api/v1/subscription.py` + `frontend`: `/plans` returns
    `billing_configured`; `SubscriptionPanel` shows a setup notice instead of
    upgrade buttons when false.

## Ops runbook (Railway env) - REQUIRED, carried over from 08-01 and still unapplied

```bash
# 1. Encryption key for user BYOK AI keys
AI_ENCRYPTION_KEY=$(openssl rand -hex 32)

# 2. Apple IAP (App Store Connect > Users and Access > Integrations, key with
#    In-App Purchase permission; .p8 contents go in APPLE_PRIVATE_KEY)
APPLE_ISSUER_ID=...
APPLE_KEY_ID=...
APPLE_PRIVATE_KEY=...

# 3. Stripe web billing (dashboard.stripe.com -> create subscription prices)
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PLUS_MONTHLY_PRICE_ID=price_...
STRIPE_PLUS_YEARLY_PRICE_ID=price_...
STRIPE_PRO_MONTHLY_PRICE_ID=price_...
STRIPE_PRO_YEARLY_PRICE_ID=price_...

# 4. Gemini 429 free-tier storm: use a PAID Gemini key (removes the 20/day
#    cap), or keep free tier + configure the Agnes fallback keys:
#    AI_VISION_FALLBACK_API_KEY, AI_IMAGE_FALLBACK_API_KEY
#    (optionally AI_GEMINI_MAX_REQUESTS_PER_MINUTE=5 to space bursts).

# 5. Image-gen 400 content-policy storm (try-on/photoshoot dead on
#    agnes-image-2.1-flash): the backend now retries the fallback model once
#    (code change 16), but for the feature to actually work the primary image
#    provider must accept person+garment image-to-image: point
#    AI_IMAGE_API_URL/AI_IMAGE_API_KEY at a dedicated virtual-try-on /
#    less-restrictive image provider, or wire Gemini image gen for try-on
#    (AI_DEFAULT_PROVIDER=gemini with AI_GEMINI_API_KEY set).
```

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest -q                                   # see pytest run below
ruff check app tests
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Follow-up debt (not in this change set)

- TD-031 (no in-app expiry for paid plans) and TD-041 (lazy re-verification of
  stored store transactions) remain open; TD-044 (app-wide image-gen
  concurrency cap) is CLOSED by code change 15.
- The content-policy fallback (change 16) softens the 400 storm, but the
  provider/model choice that actually accepts person+garment image-to-image
  is still an ops decision (see runbook #5).

## Review follow-up (2026-08-03, same change set)

Post-review hardening of the reconnect/retry changes above:

- **users.py `_get_or_create_record` / `_upsert_record`** — the inserts were
  still running on the stale (dead) request-scoped client after the wrapped
  SELECT healed; both now go through `run_sync_with_reconnect` as an
  `upsert(on_conflict="user_id")` (exact-once; the settings/preferences
  tables have `user_id` as PK). `_get_or_create_record` re-reads the row
  after the upsert.
- **subscription_service.py `get_or_create_usage_record`** — the create is
  now an insert-only upsert (`ignore_duplicates=True`, DO NOTHING) followed
  by a re-select. A merge-upsert re-applied the zeroed payload as an UPDATE,
  which could wipe a concurrent caller's increments (TOCTOU on month
  rollover, widened by the reconnect retry).
- **storage_service.py** — `_upload_options` now sends `upsert: "true"`, and
  `upload_file` defaults `upsert=True`, so a reconnect retry after a
  committed-but-lost response overwrites the SAME path instead of 409ing
  "Duplicate" (which surfaced as "Failed to upload item image" while the
  object actually existed). Paths are unique uuid4 keys, so upsert only
  affects the retry.
- **promo_service.py `redeem_promo`** — the RPC returns success=FALSE +
  already_redeemed=TRUE on a replay; the service now maps that to success
  (the user IS entitled by then) instead of reporting a failed redemption.
- **ai_settings_service.py `reserve_usage`** — the `execute_with_reconnect`
  wrap was REMOVED (single-shot RPC again, fail-closed via the existing
  retryable 503). `reserve_ai_usage` is a non-idempotent conditional counter
  increment: an automatic retry after a lost response would double-reserve
  quota (daily limit consumed 2x) or return false against the inflated
  counter while the first reservation stays consumed. `release_usage` KEEPS
  the wrap (release is `GREATEST(0, …)`-bounded, so retry is harmless).
  Revisit with an idempotency-key RPC if the dead-connection reserve bursts
  recur (TD candidate).

## Third pass (2026-08-03 evening window, 17:49–20:24 UTC)

A new log window surfaced the failure modes below. The Stripe-env and
Gemini-free-tier items were already documented as **ops** (runbook still
unapplied) — this pass adds the code fixes that were still missing, plus
regression tests and tech-debt entries (TD-054–TD-061).

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `Gemini request failed: 429 RESOURCE_EXHAUSTED ... limit: 20` then `Native Gemini vision call failed, falling back to Agnes` (17:49–20:24, the dominant volume) | Free-tier key's 20/day cap exhausted; EVERY request still burned one Gemini call + an `[err]`-level log line before the Agnes fallback, and retry loops amplified the latency. | **Code**: `gemini_provider.py` gains a process-local daily-quota circuit breaker keyed by API-key hash — once a `perday` 429 is seen, `chat()` fails fast with `upstream_quota` until the next midnight reset, so the hybrid leg falls to Agnes with zero wasted calls. Quota failures log at WARN (expected once the cap is hit, not errors). Tests: `test_gemini_provider.py`. **Ops still applies**: paid key or `AI_VISION_FALLBACK_API_KEY` / `AI_IMAGE_FALLBACK_API_KEY`. |
| 2 | `POST /auth/register \| 422` (~40× across 18:01–20:00) | Web form gates only on 8+ chars ("strength checklist is guidance"); mobile signs up via Supabase with no rule; backend hard-required upper+lower+digit+special. | **Code**: `RegisterRequest` length-gated only (password RESET keeps full strength). Tests: `test_auth.py`. |
| 3 | `Failed to get user AI settings ... duplicate key value violates unique constraint "user_ai_settings_pkey"` -> `/ai/settings 503` (20:02:24) | `get_user_settings` created the default row with a plain `insert` while `ensure_ai_settings_row` upserted; concurrent first admissions raced a select-miss into 23505. | **Code**: default-row creation is now `upsert(on_conflict="user_id")` + re-select. Tests: `test_ai_settings_service.py`. |
| 4 | `Asymmetric JWT verify failed (will refresh JWKS once) ... Signature has expired` + `Token verification failed` bursts (18:06/18:39/19:23/19:53) | Every expired access token triggered a JWKS re-fetch (cannot help — expiry is checked against `exp`) plus two warn lines per request on app resume. | **Code**: `_decode_asymmetric` skips the JWKS reset for `ExpiredSignatureError`; expiry logs at DEBUG. Unknown-kid still re-fetches once. Tests: `test_auth.py`. |
| 5 | `Uploaded bytes are not a valid image` -> `All 4 attempts failed` -> `Failed to upload file after retries` (18:10) | `parallel_with_retry` retried every exception type, so a permanent 415 (`UnsupportedMediaTypeError`) ran 3 extra decode/upload cycles per file. | **Code**: `parallel_with_retry` accepts `should_retry`; the items upload excludes `UnsupportedMediaTypeError`. Tests: `test_parallel_retry.py`. |
| 6 | `RATE_LIMIT_EXCEEDED - Server is busy processing 2 batch jobs` -> `/batch-extract-multipart 429` (18:08/18:26) + `Daily generation limit would be exceeded for approximately 39 images. Consider disabling auto_generate.` (18:26/18:27) | (a) Server-capacity 429 shared the user-plan-limit code, so the web client treated it as deterministic + upgrade prompt. (b) Developer copy ("auto_generate") leaked into the API response. | **Code**: the cap raises the new `SERVER_BUSY` code (429, retry_after=60, user-facing message); web retries it with backoff; Flutter Dio mapper preserves backend code/message on 429 and routes `SERVER_BUSY` to the capacity dialog (never the paywall CTA). Daily-limit rejection message is user-facing; the hint moved to a structured log line. Tests: `test_batch_job_memory_lifecycle.py`. |
| 7 | `POST /subscription/portal \| 503`, `/checkout \| 503` — `Stripe is not configured` (18:02/18:03/18:31) | Ops env gap (runbook still unapplied) — fail-closed is correct. But `/checkout`/`/portal` only checked the secret key while `/plans` required 5 vars, and the message said "contact support" for an env gap. | **Code**: shared `_stripe_billing_configured()` gates `/plans`, `/checkout`, `/portal`; 503 message points at promo codes as the working path. **Ops still applies** (the five Stripe vars). |
| 8 | `POST /promo/validate \| 422` (18:38) | `ValidatePromoRequest.code` `min_length=3` while pages validate as the user types; the service already returns a friendly `valid=False`. | **Code**: `min_length=1`. Test: `test_promo_api.py`. |
| 9 | `Refresh token already used` -> `AUTH_REFRESH_FAILED`; `GET /items \| 422` (1×); `GET /wordpress \| 404` scans | Expected one-time refresh-token semantics (client force-logouts on refresh failure; server dedups in-flight refreshes); single stray/legacy client; WordPress scanner bots. | **No code change** — documented behavior. |
| 10 | `Empty response from AI for item extraction`, `Failed to parse item extraction response`, `Extraction failed for image` | Symptoms of the Gemini storm (#1): the fallback leg is slower/less reliable under load, and extraction responses time out/come back empty. | Covered by #1 (circuit breaker) + the ops fallback-key items. |
| 11 | Referral redemption transient failures (missing RPC migration, dead pooled connection) | `redeem_referral` persists `users.referred_by_code` before the RPC, so a transient failure leaves a pending grant. Registration/`oauth/sync` now build a "will retry on next sign-in" fallback response, and login/`oauth/sync` call `ReferralService.process_pending_referral` to complete it (idempotent atomic RPC). | **Code**: `auth.py` import `RedeemReferralResponse` (was referenced without importing — the fallback path raised NameError → 500; found by ruff during verification, fixed 2026-08-04). Regression test: `test_register_transient_referral_failure_returns_will_retry_message` (endpoint-level, mocks Supabase auth + `redeem_referral` raising). |

### Verification (third pass)

```bash
cd backend && source .venv/bin/activate
python -m pytest -q
ruff check app tests
cd ../frontend && npm run lint && npm run build
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```
