# Plan: Closet image 404s (legacy keys) + false "Connection Error" on check-duplicates

Status: active
Started: 2026-08-31
Owner: agent

## Goal

Two production symptoms reported while adding an item by upload on
fitcheckaiapp.com:

1. The closet list issues presigned GETs that 404 forever, e.g.
   `.../fitcheck-images/c8a067f7-.../items/dd4d86e7....png` (note: NO
   `users/` segment).
2. `POST /items/check-duplicates` fails with the generic "Connection Error —
   Unable to connect to the server" toast on every attempt.

## RCA

| # | Finding | Evidence |
|---|---------|----------|
| 1 | The `users/` key-layout migration **moved the objects** but a few `item_images.storage_path` values still hold the legacy `{user}/{category}/{hex}.png` shape | `storage_keys.py` module docstring ("migration is complete: the bucket holds only `users/`/`public/` keys now"); the 404 URLs in the user report are legacy-shaped |
| 2 | The read path signs a non-null `storage_path` **verbatim**: legacy keys get a freshly-signed URL pointing at a path the migration emptied → 404 on every refetch | `app/api/v1/images.py` `materialize_image_urls` (local `storage_path` variable used raw for minting); `key_from_path`/`migrate_key_to_users_layout` only ran on the NULL-path derivation branch |
| 3 | Same family: `_remint_parent_source_url`, `GET /images/presigned`, `_normalize_create_image_row`, `items` source-photo guard, and `ai._materialize_image_source` / the try-my-look avatar branch — `parse_key` only knows the current layout, so legacy keys fail ownership (400/403/404) | Ownership checks via `is_owned_storage_key` → `parse_key` (current layout only) |
| 4 | The "Connection Error" toast maps to **axios getting no HTTP response** (`client.ts` `notifyApiError` → `showNetworkError`), retried 3× | `frontend/src/api/client.ts`, `frontend/src/lib/toast-utils.ts` |
| 5 | check-duplicates is NOT in `LONG_RUNNING_PREFIXES` → 30s `DEFAULT_TIMEOUT_MS`; the server side has **no deadline** on the Gemini embedding call (`asyncio.to_thread(embed_content)`; the SDK retries 429/5xx with internal backoff), so a stalled provider blows past 30s and the client aborts with "Connection Error" | `endpoints.ts` prefix list; `ai_service.py` `EmbeddingService.generate_embedding`; observed 6-10s baseline per earlier code comments |
| 6 | Masking layer: the catch-all `unhandled_exception_handler` is registered for `Exception`, which runs on **ServerErrorMiddleware — OUTSIDE CORSMiddleware** — so any genuine 500 ships without CORS headers, the browser blocks it, and axios reports a network failure instead of a server error | `app/main.py` middleware order (CORS added before the Exception-handler layer) + handler |

## Decision (2026-09-01)

A migrate-on-read compat layer (mapping legacy keys to their `users/` home at
every presign/ownership site) was implemented and then **removed at user
direction**: no legacy-key shims are carried in the serving/ownership paths.
Rows still holding legacy keys are an accepted failure — those users' tiles
stay broken until they re-upload, or the optional one-time SQL rewrite below
is run. The code fixes that SHIP are the two that fix real bugs for everyone:
the embedding deadline (2) and the CORS-on-500 echo (6).

## Changes

### Shipped

- `app/services/ai_service.py` + `app/core/config.py`: new
  `AI_EMBEDDING_TIMEOUT_S` (default 10s); `EmbeddingService.generate_embedding`
  wraps the thread call in `asyncio.wait_for`. `TimeoutError` surfaces as
  `AIServiceError`, which check-duplicates already handles by falling back to
  text matching → the endpoint always answers <15s.
- `app/main.py`: the unhandled-500 response echoes
  `Access-Control-Allow-Origin` (+ credentials, `Vary: Origin`) when the
  request Origin passes the same allowlist/regex as `CORSMiddleware`
  (`re.fullmatch`, matching Starlette's semantics) — real 500s now surface as
  real 500s with a correlation ID instead of a fake "Connection Error".

### Explicitly NOT done (per decision)

- No `migrate_key_to_users_layout` calls in `images.py` / `items.py` / `ai.py`
  read or ownership paths; legacy keys are signed and validated literally.
- `storage_service.py`'s pre-existing legacy handling (delete/promote paths,
  `key_from_path`) is untouched — it predates this plan.

### Tests

- `test_ai_service_coverage.py`: a wedged `embed_content` fails bounded at
  `AI_EMBEDDING_TIMEOUT_S` with `AIServiceError`.
- Serving/materialization test expectations remain pinned to raw keys (the
  pre-existing contract); no legacy-migration tests.

## Ops runbook (you execute)

1. Deploy the backend (Railway). No env changes required
   (`AI_EMBEDDING_TIMEOUT_S` defaults to 10s).
2. check-duplicates: with a stalled/slow Gemini key the request must return
   within ~15s (text fallback) instead of toasting "Connection Error" at 30s.
3. Legacy-key tiles (the reported 404s) are **expected to stay broken** by
   decision. Remedies, pick per user:
   - the user re-uploads the affected items (self-service), or
   - one-time SQL rewrite of legacy `storage_path` shapes to
     `users/{user}/{category}/...` in `item_images`, `outfit_images`,
     `items.source_image_storage_path` (objects already live at the `users/`
     home; the rewrite repoints rows at them), or
   - accept the placeholder tiles.
4. `python scripts/storage_inventory.py` remains the tool to separate
   "legacy key shape" rows (fixable by 3b) from genuinely missing objects
   (re-upload or accept).

## Acceptance criteria

- [x] Embedding calls fail bounded; check-duplicates degrades to text
      fallback (timeout unit test + existing fallback coverage tests).
- [x] Unhandled 500s carry CORS headers for allowed origins (fullmatch
      parity with CORSMiddleware).
- [x] No legacy-key migration shims in the api/v1 serving/ownership paths
      (import scan clean; legacy rows fail loudly by design).
- [x] `pytest` (629 across impacted suites) + `ruff` +
      `scripts/check_architecture.py` green.

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-31 | `asyncio.wait_for` in `EmbeddingService` rather than adding check-duplicates to `LONG_RUNNING_PREFIXES` | The endpoint is contractually fast (text fallback); a longer client timeout would mask the slow provider instead of degrading |
| 2026-08-31 | Echo CORS headers in the catch-all handler rather than reordering middleware | Starlette runs the `Exception` handler on ServerErrorMiddleware regardless of middleware order; header echo is the standard fix |
| 2026-09-01 | Removed the migrate-on-read compat layer at user direction ("remove legacy/deprecated part, let it fail for few users") | Legacy-key rows are few and known; carrying permanent shims in every presign/ownership site buys little once the optional SQL rewrite exists. Failures are loud (404/400) and self-service repairable |

## Progress log

| Date | Note |
|------|------|
| 2026-08-31 | RCA complete (legacy-key presign + embedding deadline + CORS-on-500) |
| 2026-09-01 | Review pass: embedding deadline + CORS-on-500 shipped; migrate-on-read shims implemented then removed per user decision; legacy rows accepted-failure; 629 tests + ruff + architecture green |
