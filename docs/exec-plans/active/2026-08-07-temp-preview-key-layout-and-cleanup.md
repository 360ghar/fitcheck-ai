# Plan: Temp-preview key layout + weekly cleanup script

Status: active
Started: 2026-08-07
Owner: agent

## Goal

Temporary generated previews (photoshoot / batch / social-import generated images)
are never referenced by any DB row and are served only via short-lived presigned
URLs — once the generating flow ends the user can no longer see them, yet the
objects accumulate in the bucket forever. This plan makes every temp preview share
one top-level folder (`tmp/`), adds a manual weekly cleanup script, and keeps a
one-time migration script that rewrites the existing per-user keys.

## Non-goals

- No scheduled/cron cleanup — the user explicitly wants manual weekly invocation.
- No age gating by default in the cleanup script — weekly runs may delete live-TTL
  previews, which is harmless (flows are minutes long; jobs re-upload on retry).
- No change to the `generated/` retention policy (user-requested saves stay
  30 days via `storage_inventory.py` until they become DB-referenced).
- No change to per-flow lifecycle cleanup that already works (social-import
  reject/promote/cancel/complete deletes).

## Acceptance criteria

- [x] Temp previews are minted under `tmp/{user_id}/{source}/...`; user-saved
      renders under `generated/{user_id}/{image_type}/...` (top-level folders).
- [x] Serving allowlists (backend `images.py`, `ai.py`, Worker) accept both the
      top-level form and the legacy per-user form — permanently, since the
      migration is optional and legacy objects keep serving either way.
- [x] `scripts/cleanup_temp_assets.py` lists every temp object, dry-runs by
      default, deletes with `--delete`, and writes a JSONL audit; it never touches
      canonical or `generated/` objects. Matches BOTH layouts, so legacy-layout
      tmp objects are removed by the weekly routine without any migration.
- [x] `scripts/migrate_temp_keys_layout.py` (OPTIONAL) rewrites legacy keys
      copy-then-delete (dry-run default, `--apply` to execute), never
      overwrites, idempotent.
- [x] Delete paths resolve stale legacy keys after migration
      (`storage_keys.normalize_preview_key`).
- [x] Backend tests (1215 passed), Worker tests (43 passed), ruff clean.

## Context / links

- Related code: `backend/app/services/storage_service.py`,
  `backend/app/api/v1/images.py`, `backend/app/api/v1/ai.py`,
  `backend/scripts/{storage_inventory,cleanup_temp_assets,migrate_temp_keys_layout}.py`,
  `infra/images-worker/worker.js`, `backend/scripts/_common.py`.
- The pre-existing orphan/age tooling: `backend/scripts/storage_inventory.py`
  (full-bucket orphan audit, age-gated, manual).
- Concurrent work in the working tree: `storage_keys.normalize_preview_key`
  (added by a parallel session; delete paths use it — reconciled, not duplicated).

## Progress log

| Date | Note |
|------|------|
| 2026-08-07 | Layout change + regex/Worker allowlists + two scripts + tests landed; full suite green |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-07 | Cleanup is a manual script, not a cron/background task | User preference: weekly manual run; live-TTL deletion is acceptable |
| 2026-08-07 | Keep legacy per-user preview keys servable permanently (dual-layout allowlists) | The migration is optional: legacy keys keep serving and are removed by the weekly cleanup (`tmp/`) or the 30-day retention (`generated/`); the legacy branches are only removable if the migration is ever run and verified |
| 2026-08-07 | No age gate by default in the cleanup script | Temp previews are unreachable after ~1h; weekly runs make precision moot |
| 2026-08-07 | Known transient: delete paths normalize legacy keys unconditionally (`storage_keys.normalize_preview_key`, parallel-session code) | Between app deploy and the migration run, a delete of a legacy key targets the not-yet-existing top-level key (S3 delete of a missing key is a success). No data loss; those objects are swept by the next `cleanup_temp_assets.py --delete` run. Re-checked against the weekly routine |

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest -q                                   # 1216 passed
ruff check app/ scripts/ tests/                       # clean
cd ../infra/images-worker && npm test                 # 43 passed
# Ops (user-run, after review):
python scripts/cleanup_temp_assets.py                 # dry-run
python scripts/cleanup_temp_assets.py --delete        # weekly cleanup (removes BOTH layouts)
python scripts/storage_inventory.py                   # optional cross-check of orphans/ages
# Optional — only if you want a single-layout bucket (e.g. future lifecycle rules):
python scripts/migrate_temp_keys_layout.py            # dry-run
python scripts/migrate_temp_keys_layout.py --apply    # execute during a quiet period
```

## Deferred debt

- Keep `_LEGACY_NESTED_KEY_RE` (backend + Worker) while legacy-layout objects
  exist (default: forever, since the migration is optional). If the migration
  is ever run and verified complete, the legacy branches can be removed.
- `generated/` objects still have no DB row (30-day retention policy in
  `storage_inventory.py`); the durable fix is to make them DB-referenced.
