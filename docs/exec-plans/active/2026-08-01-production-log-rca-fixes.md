# Plan: 2026-08-01 production log RCA + fixes

Status: active
Started: 2026-08-01
Owner: agent

## Goal

RCA and fix every error class in the 2026-08-01 production log drain (Railway
backend): startup config errors, `/auth/oauth/sync` and `/items` 500s, Gemini
429 storms, `generate-outfit` image-generation 400s, promo redemption 500s,
and `/subscription/checkout` 503s.

## RCA

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `Config issue at startup: AI_ENCRYPTION_KEY - Empty in production` | Env var unset in Railway | **Ops**: `openssl rand -hex 32` → set `AI_ENCRYPTION_KEY` (boot check already exists) |
| 2 | `Config issue at startup: APPLE_ISSUER_ID - Apple IAP verification is not configured` | `APPLE_ISSUER_ID`/`APPLE_KEY_ID`/`APPLE_PRIVATE_KEY` unset | **Ops**: create ASC API key (In-App Purchase permission), set the three vars (boot check already exists) |
| 3 | `OAuth sync error` → `/auth/oauth/sync 500` | Dead pooled Supabase HTTP/2 connection (`ConnectionTerminated`) on the singleton client; never rebuilt → every request 500s until process restart | **Code**: `is_db_connection_error` + `execute_with_reconnect`/`run_sync_with_reconnect` in `app/utils/db.py`; wired into `oauth_sync`, `_require_schema`, `list_items`, `create_outfit`, `get_current_user`, `check_limit`/`increment_usage`, `get_user_ai_settings`/`ensure_ai_settings_row` |
| 4 | `List items error` → `/items 500` ×10 (13:15–13:16, healed only by the 13:51 redeploy) | Same dead pooled connection (#3) after ~30 min idle | Same as #3 |
| 5 | `Gemini request failed: 429 RESOURCE_EXHAUSTED` ×8 in one second + `503 UNAVAILABLE` | Free-tier key (5 req/min/model) exhausted by concurrent extraction bursts; 429 logged at ERROR → drain flood | **Code**: optional `AI_GEMINI_MAX_REQUESTS_PER_MINUTE` spacing in `GeminiProvider` (default 0 = unlimited); retryable Gemini failures downgraded to WARN (the hybrid vision leg already falls back to Agnes). **Ops**: paid tier or set the knob + Agnes fallback key |
| 6 | `Create outfit error` 500 + `Failed to get user AI settings` + `increment usage … ConnectionTerminated` + `generate-outfit 503` | Same dead pooled connection (#3) on outfit/usage/AI-settings paths | Same as #3 |
| 7 | `Image generation … 400: too many input images: 7 provided, at most 6 allowed` | avatar(1) + source photo(1) + 5 garment refs = 7 > model cap 6 (`AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES=12` allowed 12) | **Code**: new `AI_IMAGE_GEN_MAX_INPUT_IMAGES=6` total cap; `generate_outfit` derives the garment budget (avatar/source photo take slots), truncates excess refs (items render from description, numbering stays consistent), and `_generate_with_references` fails fast with a non-retryable config error instead of a wasted provider 400 |
| 8 | `promo/redeem 500: 42804 - Returned type character varying(20) does not match expected type text in column 3` | `redeem_promo_atomic` declares `RETURNS TABLE(plan_type TEXT)` but the two runtime `RETURN QUERY` branches select `promo_row.plan_type`/`redemption_row.plan_type` (varchar(20)) without a cast | **Code**: migration `032_fix_redeem_promo_atomic_plan_type.sql` (`CREATE OR REPLACE` with `::TEXT` casts; also fixed in-place in `031` for fresh installs) |
| 9 | `/subscription/checkout 503` (dozens) | `STRIPE_SECRET_KEY`/price IDs unset → `ServiceError(503)` at request time; no boot check existed | **Ops**: set `STRIPE_SECRET_KEY` + 4 `STRIPE_*_PRICE_ID` vars. **Code**: new boot check #10 in `config_health.py` (same posture as the Apple IAP checks) |

## Code changes

1. `backend/app/utils/db.py`: `is_db_connection_error` (httpx transport errors
   + embedded `<ConnectionTerminated …>` string fallback), `execute_with_reconnect`
   (async builder support, rebuilds the Supabase singleton and retries once),
   `run_sync_with_reconnect` (sync twin for `_require_schema`).
2. `backend/app/api/v1/items.py` `list_items`: count + page queries rebuilt
   through `execute_with_reconnect` (filters factored into `_apply_filters`).
3. `backend/app/api/v1/auth.py`: `_require_schema` delegates to
   `_check_schema_tables` via `run_sync_with_reconnect`; every `oauth_sync` DB
   step wrapped.
4. `backend/app/api/v1/outfits.py` `create_outfit` + `backend/app/api/v1/deps.py`
   `get_current_user`: hot-path lookups wrapped.
5. `backend/app/services/subscription_service.py`: `check_limit` now uses the
   shared predicate; `increment_usage` runs the whole reservation through
   `execute_with_reconnect`.
6. `backend/app/services/ai_settings_service.py`: `get_user_ai_settings` and
   `ensure_ai_settings_row` wrapped (select + reset-update + default insert).
7. `backend/app/services/gemini_provider.py`: `max_requests_per_minute` on
   `GeminiConfig` (+ `from_settings`/`from_user_dict`), `_wait_for_rate_slot`
   called at the top of `chat()`, retryable upstream failures logged at WARN.
8. `backend/app/agents/image_generation_agent.py`: `_collect_garment_references`
   gains a `max_images` budget; `generate_outfit` computes the budget from
   `AI_IMAGE_GEN_MAX_INPUT_IMAGES` minus avatar/source-photo slots;
   `_generate_with_references` hard guard.
9. `backend/app/core/config.py` + `backend/.env.example`:
   `AI_GEMINI_MAX_REQUESTS_PER_MINUTE` (0), `AI_IMAGE_GEN_MAX_INPUT_IMAGES` (6).
10. `backend/app/core/config_health.py`: check #10 - Stripe keys/price IDs
    required in production.
11. Migrations: `031_promo_codes.sql` fixed in place (`::TEXT` casts),
    new `032_fix_redeem_promo_atomic_plan_type.sql` for hosted Supabase.

## Ops runbook (Railway env) - REQUIRED for the config-missing errors

```bash
# 1. Encryption key for user BYOK AI keys
AI_ENCRYPTION_KEY=$(openssl rand -hex 32)

# 2. Apple IAP (App Store Connect > Users and Access > Integrations, key with
#    In-App Purchase permission; .p8 contents go in APPLE_PRIVATE_KEY)
APPLE_ISSUER_ID=...
APPLE_KEY_ID=...
APPLE_PRIVATE_KEY=...

# 3. Stripe web billing (https://dashboard.stripe.com/test|live/products ->
#    create subscription prices, copy the price_ ids)
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PLUS_MONTHLY_PRICE_ID=price_...
STRIPE_PLUS_YEARLY_PRICE_ID=price_...
STRIPE_PRO_MONTHLY_PRICE_ID=price_...
STRIPE_PRO_YEARLY_PRICE_ID=price_...

# 4. Gemini free-tier: either move to a paid tier, or keep free tier and set
#    AI_GEMINI_MAX_REQUESTS_PER_MINUTE=5 + an Agnes fallback key
#    (AI_CHAT_API_KEY / AI_VISION_FALLBACK_API_KEY) so quota bursts fall back.
```

Apply `032_fix_redeem_promo_atomic_plan_type.sql` on hosted Supabase to fix
promo redemption (the function already exists there - 031 was applied - but
its varchar(20) vs TEXT mismatch 42804s at runtime).

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest -q                                   # 788 passed
ruff check app tests
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```
