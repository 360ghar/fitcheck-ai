# Plan: 2026-08-07 /items occasion-filter 500 RCA + fixes

Status: active
Started: 2026-08-07
Owner: agent

## Goal

RCA and fix the 2026-08-07 production burst where `GET /api/v1/items?occasion=informal&page=1&page_size=24`
500ed on every ~3s poll from the mobile app (`DATABASE_ERROR - Failed to fetch items`),
while `/outfits`, `/subscription/usage`, and `/outfits/available-items` returned 200 in
the same window.

## RCA

| # | Log signature | Root cause | Fix |
|---|---------------|------------|-----|
| 1 | `Supabase pooled connection error, rebuilding client and retrying once` x2 → `retries exhausted` → `List items error` → 500 `DATABASE_ERROR - Failed to fetch items` (every ~3s, client 202.191.122.169) | **Not a dead connection — a deterministic query error misclassified as one.** `list_items` filters the JSONB column `occasion_tags` with `contains("occasion_tags", [occasion_filter])`. postgrest-py 2.31.0 serializes a LIST argument as a Postgres ARRAY literal (`cs.{informal}`), which is valid only for native array columns; PostgREST casts it to jsonb and answers `22P02 invalid input syntax for type jsonb` (DETAIL: `Token "informal" is invalid.`). `APIError.__str__` embeds that text, and the `"invalid input"` text marker in `is_db_connection_error` (added 2026-08-03 for h2 `ProtocolError` state strings) classifies it as a dead pooled connection → 2 client rebuilds + 3 attempts → 500. Verified offline: the built query sends `occasion_tags=cs.%7Binformal%7D`. This explains why ONLY /items-with-occasion failed: the other endpoints sent no JSONB `contains` filter, and the shared client/pool was healthy (their 200s + the per-request users lookup prove it). | **Code (this plan)**: (1) new `jsonb_contains()` helper in `app/utils/db.py` JSON-encodes list values (`cs.["informal"]`); applied at `items.py` (`occasion_tags`, `colors`) and `outfits.py` (`tags`). (2) `is_db_connection_error` returns `False` for `postgrest.exceptions.APIError` (structured 4xx/5xx with a `code`); transport errors are never wrapped in `APIError`, so genuine dead-pool recovery is untouched. |
| 2 | Same latent pattern at `items.py` `contains("colors", [color])` and `outfits.py` `contains("tags", tag_list)` | Same jsonb-array-literal encoding; `colors` and `tags` are JSONB too (001_full_schema.sql). Any web/mobile filter on them 500s identically. | Same helper, all three call sites. |
| 3 | (Rejected) Dead pooled HTTP/2 connection (08-01/08-03/08-04/08-05 class) | Contradicted: other endpoints on the SAME singleton client returned 200 in the same window; the failure is 100% deterministic per request with `occasion=informal`; each attempt fails fast (~130–300ms), never a timeout. | None needed. |
| 4 | (Rejected) 08-07 R2 cutover regression in `materialize_parent_images` | R2/S3 presign errors would not match the connection markers → no rebuild logs; the log shows rebuilds firing on every attempt. | None needed. |

## Code changes

1. `backend/app/utils/db.py`:
   - New `jsonb_contains(builder, column, values)` — JSON-encodes list values so JSONB
     columns get `cs.["informal"]` instead of the invalid `cs.{informal}`.
   - `is_db_connection_error()` returns `False` for `postgrest.exceptions.APIError` whose
     `code` is a SQLSTATE/PGRST code (structured server responses: deterministic query/
     authorization errors — rebuilding the client cannot fix them, and retrying churns
     the shared pool, amplifying the real HTTP/2 races). The ONE retryable exception is
     a structured *gateway* error: when the 5xx/429 body is not PostgREST JSON,
     postgrest-py falls back to `generate_default_error_message`, so `code` is the bare
     HTTP status (429/500/502/503/520/521/522/524) — that is the transient gateway-blip
     class the retry mechanism exists for, so it still triggers one rebuild+retry.
     SQLSTATEs/PGRST codes (5-char) can never collide with 3-digit HTTP statuses, and
     h2 `ProtocolError` state-machine text arrives as plain `RuntimeError`s and keeps
     matching.
2. `backend/app/api/v1/items.py`: `colors` and `occasion_tags` filters use `jsonb_contains`.
3. `backend/app/api/v1/outfits.py`: `tags` filter uses `jsonb_contains`.

## Tests

- `backend/tests/test_jsonb_contains.py` (new):
  - `jsonb_contains` emits `cs.["informal"]` / `cs.["red"]` / `cs.["work", "smart"]` for
    the three JSONB columns (offline builder, never executed).
  - Documents that plain `contains(list)` emits `cs.{informal}` (the hazard).
  - Route-wiring test: `list_items(occasion="informal", color="red")` produces valid
    `cs.["informal"]` / `cs.["red"]` params on BOTH the count and page queries (captures
    the built chains via a faked `asyncio.to_thread`).
- `backend/tests/test_db_connection_retry.py`: new
  `test_is_db_connection_error_rejects_postgrest_api_errors` — the exact 22P02 incident
  shape, `PGRST202`, and generic 400 shapes are NOT connection errors; the h2
  `Invalid input StreamInputs.SEND_HEADERS` `RuntimeError` still is. New
  `test_is_db_connection_error_retries_gateway_status_errors` — a structured error whose
  `code` is a bare HTTP status (429/500/502/503/520/521/522/524, i.e. a non-PostgREST-JSON
  gateway body) stays retryable, while 404/401/None codes stay deterministic.

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/test_db_connection_retry.py tests/test_jsonb_contains.py tests/test_items_list_filters.py -q
python -m pytest -q          # full suite
ruff check app/utils/db.py app/api/v1/items.py app/api/v1/outfits.py tests/
```

Prod confirmation (pre-fix): the `db_error` extra on the "Supabase pooled connection
error" WARN lines should read `22P02` / `invalid input syntax for type jsonb`. Post-deploy:
`GET /api/v1/items?occasion=informal&page=1&page_size=24` returns 200 with occasion-filtered
items and no connection-rebuild logs.

## Deferred debt

- TD-043 stands: the async-client migration remains the full fix for the genuine HTTP/2
  pool races. The APIError code-based gate makes those races rarer (no more rebuild churn
  on every deterministic query error) while keeping the retry for structured gateway
  5xx/429 responses (bare HTTP-status `code`, i.e. a non-PostgREST-JSON body).
