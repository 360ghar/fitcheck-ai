# Plan: backend efficiency (no-cache): indexes + query/API optimisations

Status: active
Started: 2026-09-14
Owner: agent

## Goal

Make the hottest backend reads cheaper without any caching layer (serverless Railway, no Redis): composite covering indexes for the wardrobe/outfit/calendar/leaderboard/share queries both clients hit on every app open, an optional `ids` filter on `GET /outfits/available-items` so generation flows stop fetching the whole closet, SQL-side aggregation for `GET /items/stats` instead of a 1000-row Python rollup, and removal of the known sequential per-row awaits and the `complete-look` double pool fetch.

## Non-goals

- Any caching (in-process TTL, Redis, CDN) — explicitly out per serverless deployment constraint.
- Auth hot-path changes (`get_active_user_id` stays uncached).
- Changing list pagination, response shapes, or mobile client code.
- Embedding persistence, trigram/full-text search, dashboard counts endpoint, `AsyncClient` migration (deferred).

## Acceptance criteria

- [ ] Migration `064_efficiency_indexes.sql` applies cleanly on hosted Supabase (7 indexes + `get_item_stats_aggregate` RPC). *(SQL parse-validated with pglast; migration-prefix check green. NOT yet applied on hosted Supabase — the criterion stays unchecked until the manual apply lands and the post-apply EXPLAIN check passes.)*
- [ ] `GET /items`, `GET /outfits` list queries filter + sort via the new composite indexes (EXPLAIN shows index scan, no Sort node, on a representative user). *(Post-apply check on live Supabase.)*
- [x] `GET /outfits/available-items?ids=<n ids>` returns only those rows; no `ids` → unchanged behavior (recency order kept in both branches).
- [x] `GET /items/stats` returns the identical response shape with no 1000-row fetch (RPC + PGRST202/empty-payload fallback to the legacy Python rollup).
- [x] Leaderboard + available-items materialization loops run concurrently (`asyncio.gather`).
- [x] `POST /recommendations/complete-look` fetches the candidate pool once (`_fetch_match_pool`, shared with `match_items`).
- [x] `pytest` 4218 passed / 4 skipped / 0 failed (final PR-#19 review-fix run; supersedes the stale "4214 passed, 1 pre-existing failure" note, which mixed two different runs), ruff green; arch + docs + migrations checks green (schema doc regenerated); frontend eslint clean, 356/356 tests, build green.

## Context / links

- Related docs: `docs/BACKEND.md`, `ARCHITECTURE.md`, `docs/generated/db-schema.md`
- Related code:
  - `backend/app/api/v1/items.py` (`_list_and_count`, `get_item_stats`)
  - `backend/app/api/v1/outfits.py` (`list_outfits`, `available_items`)
  - `backend/app/api/v1/gamification.py` (leaderboard)
  - `backend/app/api/v1/recommendations.py` (`match_items`, `complete_look`)
  - `backend/app/api/v1/calendar.py` (month-range events)
  - `backend/db/supabase/migrations/001_full_schema.sql:425-492` (existing single-column indexes)
- Evidence: 3 parallel explorer reports (backend API+DB, React frontend data fetching, Flutter GetX controllers) + direct reads of `deps.py:230-275`, `outfits.py:562-597`, `gamification.py:266-324`, `items.py:1415-1474`. Key client facts: lists are paginated 24 (web) / 20 (mobile) with server-side filters hit on open + every debounced filter change + pull-to-refresh; `available-items` is fetched whole-closet per generation (web) and up to 1000 rows via paged loop (mobile pickers); dashboard mounts `fetchItems + fetchOutfits + fetchUsage` just to read totals.
- Migrations: apply on hosted Supabase only (never local/Docker per AGENTS.md).

## Progress log

| Date | Note |
|------|------|
| 2026-09-14 | Plan approved (no-cache scope). Implementing. |
| 2026-09-14 | All changes landed: migration 064, available-items `ids` filter (+ web call sites pass `outfit.item_ids`), stats RPC with migration-gap fallback, gather-parallelized leaderboard/picker materialization, shared `_fetch_match_pool` for match + complete-look. Regression tests added (ids filter x2, RPC stats + fallback). Backend 4214 passed / ruff clean; frontend tsc + lint + 352/352. `check_architecture`/`check_migrations`/`check_docs_structure` green, `db-schema.md` regenerated. |
| 2026-09-14 | Self-review fixes: FastAPI `Query()` ParamInfo guard for direct handler calls (same gotcha as match_items), empty-RPC-payload → legacy fallback, recency order preserved in the `ids` branch, legacy rollup keeps the original no-`is_deleted` scope for exact pre-migration parity. (That parity scope was superseded later the same day by the PR #19 review pass — see next row: both the rollup and the endpoint reads are scoped to non-deleted rows to match the RPC.) |
| 2026-09-14 | PR #19 review pass (50 bot comments validated): migration 064 → `CREATE INDEX CONCURRENTLY` outside a transaction + `jsonb_typeof` colors guard; stats endpoint + legacy fallback scoped to non-deleted rows; stats RPC unwrap accepts PostgREST v10+ bare scalar-JSONB payloads (not just the keyed row); `?ids=` empty string short-circuits to `[]`; try-on restores inline-clothing precedence and keeps failed own-storage avatar URLs on the 502 path (only true external OAuth URLs pass through); batch extraction deletes the source photo on EVERY failure (nothing server-side consumes a retained copy); shared `_rank_candidates` for match/complete-look scoring; similar-items endpoint filters `is_deleted`. Criterion 1 unchecked again (hosted apply still pending). Route-thinness findings logged as TD-107. Final: backend 4218 passed / 0 failed, ruff green; frontend 356/356 + lint + build green. |
| 2026-09-14 | PR #19 review pass 2 (12 open bot comments validated, all valid): migration 064 → dropped the dangling trailing `COMMIT;`, added an INVALID-index recovery pass so re-runs rebuild failed concurrent builds, and normalized `items.is_deleted` (guarded DO block: backfill NULL → FALSE + `SET NOT NULL`) so the RPC's predicate is a plain `is_deleted = FALSE`, exactly matching every PostgREST read (no NULL-tolerance asymmetry); `ItemCard` keyboard: Shift+Enter is now checked first and terminal, so it no longer also fires the open/toggle action; `client.ts` short-circuits canceled requests (`axios.isCancel`) before the retry/toast interceptors (plus a no-config guard in the 401/toast interceptor), so aborting a stale similar-items request neither re-issues the config nor toasts "Connection Error"; docs: TD-107 relabeled to route-layer workflows + header bumped, stale parity-scope note above annotated. Regression tests: client cancel (no retry/toast), ItemCard Shift+Enter. Verified: backend 4218 passed / 0 failed + ruff green; frontend 358/358 + lint + build green; `check_architecture`/`check_migrations`/`check_docs_structure` green; `db-schema.md` regenerated. Migration 064 dry-run on a scratch PostgreSQL 17: applied twice cleanly, legacy NULL row backfilled and visible to RPC + strict read (parity), simulated INVALID index (failed concurrent build) dropped + rebuilt on rerun, planner uses the composite index. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-14 | No caching of any kind (profile cache reuse, weather TTL, embedding cache all dropped). | Serverless Railway deployment with no external Redis; per-process caches reset on every cold start / replica, so they add complexity without durable wins. |
| 2026-09-14 | `get_item_stats_aggregate` RPC aggregates category/condition + totals in SQL; colors unnested in SQL. | `/items/stats` currently fetches 1000 rows to count in Python; response shape is preserved so clients need no change. |
| 2026-09-14 | `ids` filter on `available-items` is opt-in, comma-separated, capped at 100. | Backward compatible: mobile + old web keep working; new web call sites pass `outfit.item_ids`. |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest
ruff check backend/app/api/v1 backend/db 2>/dev/null || cd backend && ruff check app
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd frontend && npm run lint && npm test
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Dashboard counts endpoint (dashboard mounts two full list fetches just to read `total`).
- Trigram / full-text index for `items`/`outfits` search (`or_(name.ilike, brand.ilike)` sent on every list page).
- `/users/me` refresh on every web route change beyond the 30s request cache (lighter avatar-URL endpoint or longer freshness).
- `outfits.worn_count` read-modify-write → atomic RPC (in-process lock only; unsafe across replicas).
- Batch quota admission: collapse `reserve_usage` ensure-row + limit-read + RPC into one RPC.
- `supabase-py` `AsyncClient` migration (documented in `app/db/connection.py`) to drop the thread-pool hop.
- Persist item embeddings or hash-keyed cache (recomputed AI call per check-duplicates/similar).
