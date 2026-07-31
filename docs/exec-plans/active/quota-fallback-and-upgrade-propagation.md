# Quota fallback + upgrade propagation

Status: **active** · Branch: `chore/cleanup-bugfixes-jul28` · Created: 2026-07-31

## Problem

Production logs (Railway, 2026-07-29/30) showed a Gemini free-tier 429 storm, 503
overload spikes, a recurring opaque "Config issue at startup" line, and silent
"Extraction failed for image …" user-facing failures. Root cause: the server's
`AI_GEMINI_API_KEY` is on Google's **free tier** (5 req/min, 20 req/day for
`gemini-3.6-flash`). Two distinct user-facing conditions were indistinguishable:

- **Upstream/server key problems ("on us")** — the server's Gemini free tier.
- **The user's own plan limit** — where an upgrade CTA belongs.

The Gemini provider collapsed every `APIError` into one `AIServiceError(retryable=…)`
by status code only, the Agnes fallback was configured but not absorbing load in
prod, and no machine-readable signal reached the UI.

## Operator root fix (not code)

Provision a valid **Agnes key** (`AI_CHAT_API_KEY`) so the existing Gemini→Agnes
fallback actually absorbs free-tier 429s, or move Gemini to a **paid tier**. The
fallback code path already engaged; this is what makes extraction keep working.
The new config-health check (#7) now warns when this key is missing.

## Changes

### Backend
- **`app/services/gemini_provider.py`** — `classify_gemini_error()` parses
  `code`/`status`/`message`/`details`: daily free-tier quota → not retryable
  (forces immediate Agnes fallback); per-minute quota → retryable after the
  parsed `RetryInfo.retryDelay`; 503/5xx → transient; else hard. Used in
  `chat()`.
- **`app/core/exceptions.py`** — `AIServiceError` now carries `error_kind`
  (`upstream_quota`/`transient`/`hard`) + `retry_after_seconds`, and
  `to_dict()` serializes `retryable`/`error_kind`/`retry_after_seconds` so the
  client can distinguish "try again shortly" from a hard failure.
- **`app/services/ai_provider_service.py`** — `_chat_with_vision_via_native_gemini`
  logs when the Gemini→Agnes fallback **succeeds**, and tags the final error with
  `error_kind` when both legs fail.
- **`app/services/batch_extraction_service.py`** — `image_extraction_failed` SSE
  payload now carries `code`/`error_kind`/`retry_after_seconds`; a new
  `extraction_capacity_exhausted` event + per-instance flag stops the remaining
  images from grinding through guaranteed-to-fail calls; `with_retry` bumped to
  `max_retries=2`.
- **`app/services/social_import_pipeline_service.py`** — `photo_failed` payload
  enriched; `capacity_exhausted` event + flag stops the queue grinding remaining
  photos.
- **`app/utils/retry.py`** — `with_retry` honours a provider-advised
  `retry_after_seconds` as the delay floor.
- **`app/api/v1/ai.py`** — `/extract-items`, `/extract-single-item` retries → 2.
- **`app/core/config_health.py` + `app/main.py`** — startup log now names the
  offending key in plain text; new check #7 warns when Gemini-primary has no
  Agnes fallback key.

### Web (`frontend/`)
- New `stores/upgradePromptStore.ts` + `components/common/UpgradePromptDialog.tsx`
  (mounted in `main.tsx`). `rate_limit` → "Upgrade to Pro" (reuses
  `subscriptionStore.startCheckout` → Stripe); `capacity` → "try again shortly",
  never an upgrade.
- `api/client.ts` interceptor routes `RATE_LIMIT_EXCEEDED` → upgrade prompt;
  `errorKind` → friendly "AI busy" warning.
- `useBatchExtraction.ts` handles `extraction_capacity_exhausted` and stores
  `errorKind` per failed image; `useSocialImportQueue.ts` opens the upgrade
  prompt on `paused_rate_limited`. Types extended (`types/index.ts`).

### Flutter (`flutter/`)
- `item_add_controller.dart` — structured `errorCode == 'RATE_LIMIT_EXCEEDED'`
  check (with string fallback for SSE paths) drives the existing upgrade dialog
  (gated by `EnvConfig.paywallEnabled`); new capacity branch shows "AI busy, try
  again shortly" with no upsell.

## Tests
- `tests/test_gemini_provider.py` — daily (not retryable)/per-minute
  (retryable, retry_after)/503 (transient)/hard classification + `to_dict()`.
- `tests/test_config_health.py` — Gemini-primary without/with Agnes fallback key.

## Verification
- Backend: `cd backend && pytest` (gemini + config_health + batch/social green).
- Web: `npm run lint && npm run build`.
- Flutter: `flutter analyze`.
- Architecture: `python scripts/check_architecture.py`.

## Out of scope / follow-ups
- Embeddings (`ai_service.py`) share the Gemini free-tier key with no Agnes
  fallback — a hidden contributor as volume grows.
- The upgrade CTA is only reachable once the Agnes fallback works (otherwise free
  users hit the server's 20/day wall before their app-plan limit).
