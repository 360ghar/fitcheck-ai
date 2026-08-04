# Plan: legacy storage key migration + review fixes

Status: active  
Started: 2026-08-04  
Owner: agent

## Goal

Migrate every legacy storage key to the new folder layout
(`{user_id}/{category}/{uuid4hex}.{ext}`) in BOTH the bucket and the DB, so the
strict ownership validators added in the storage-path PR (`_is_owned_by_user`,
`_owned_storage_path`) stop rejecting owned legacy rows with 404/403. Also land
the remaining review fixes from that PR: refresh expiring stored avatar URLs
before handing them to AI providers (try-on was passing 1-hour presigned URLs
that had expired), fix the `TryOnRequest` validator that rejected explicit
`null` for the optional `clothing_image`, and add an SSRF guard at the Gemini
provider download boundary.

## Non-goals

- Rewriting `{user_id}/generated/{type}/...` keys (transient `save_generated_image`
  keys; never DB-referenced, never user input, so no ownership check applies).
- Broaden the ownership regexes to accept legacy layouts (migration is the
  chosen fix; validators stay strict).
- Running the migration against production (script ships dry-run-first;
  operator runs `--apply`).

## Acceptance criteria

- [x] `backend/scripts/migrate_legacy_keys_to_new_layout.py` classifies bucket
      keys and DB storage columns, plans legacy rewrites, and is idempotent
      (deterministic mapping, re-run is a no-op). Collision and cross-category
      conflicts abort before any copy.
- [x] Dry-run (default) performs no writes; `--apply` copies objects before
      rewriting DB rows; `--cleanup` deletes old keys only afterwards.
- [x] Try-on re-materializes stored avatar URLs from their bucket key; external
      https OAuth avatars pass through; non-https / non-owned URLs are refused.
- [x] Gemini remote-image downloads refuse loopback / link-local / private /
      metadata hosts before any fetch (storage-endpoint allowlist exempted).
- [x] `TryOnRequest` accepts explicit `null` `clothing_image` when a
      `clothing_storage_path` is supplied.
- [x] Backend suite green (`pytest` 952 passed / 1 skipped in fixed and random
      order), `ruff check`, architecture + docs-structure checks.

## Context / links

- Related docs: `docs/BACKEND.md` (storage layout, migration scripts),
  `docs/SECURITY.md` (storage serving model, SSRF).
- Related code: `backend/app/api/v1/ai.py`, `backend/app/api/v1/images.py`,
  `backend/app/models/ai.py`, `backend/app/services/gemini_provider.py`,
  `backend/scripts/migrate_legacy_keys_to_new_layout.py`.
- Related issues: review findings on the storage-path/SSE PR (expired avatar
  URL P1, legacy key rejection P2, TryOnRequest validator P2, SSRF P2).

## Progress log

| Date | Note |
|------|------|
| 2026-08-04 | Implemented migration script + avatar refresh + validator + SSRF guard; tests green |
| 2026-08-05 | Self-review fixes: `except HTTPException: raise` on 4 AI routes (400/403 were wrapped into 500s; `AVATAR_REQUIRED` 400 is a frontend contract); removed function-local `from fastapi import HTTPException` that shadowed the module import (UnboundLocalError); SSRF guard now allows the configured storage endpoint before the private-host rejection and compares full netloc (host:port); migration script aborts on cross-category hint conflicts. Regression tests added for all. Full suite 952 passed / 1 skipped in both fixed and pytest-randomly order (fixed a settings-pollution test that patched `app.core.config.settings` after `test_concurrency_config` reloaded it). |
| 2026-08-05 | LIVE MIGRATION EXECUTED (operator): dry-run → `--apply` → `--apply --cleanup`. 634 legacy keys copied + 1870 DB rows rewritten (item_images ×3, items.source_image_* ×2, outfit_images ×3, users.avatar_url), then 634 old keys deleted. Verified post-run: bucket 776/776 new layout, 0 DB rows to rewrite, 0 dangling/unknown. Audit: `backend/logs/key_layout_migration.jsonl` (2536 copy + 634 delete entries). `support_tickets.attachment_storage_paths` not in live schema (migration 034 pending) — script now skips that column gracefully; re-run once 034 is applied. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-04 | Migrate keys instead of broadening regexes | Strict validators keep the security boundary; migration rewrites both bucket and DB consistently |
| 2026-08-04 | Deterministic new names (SHA-256 of old key, 32 hex) | Idempotent re-runs; no collision risk |
| 2026-08-04 | Avatar refresh keyed on UUID-shaped first path segment | Distinguishes our bucket keys from external (OAuth) URLs without host allowlists |
| 2026-08-04 | SSRF guard at the provider fetch boundary | Blocks loopback/link-local/private/metadata hosts regardless of caller |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest
cd backend && source .venv/bin/activate && ruff check app scripts tests
cd .. && python scripts/check_architecture.py
python scripts/migrate_legacy_keys_to_new_layout.py   # dry-run first
```

## Deferred debt

- DNS-rebinding protection for provider-bound URL fetches (hostname literals
  only are range-checked today).
