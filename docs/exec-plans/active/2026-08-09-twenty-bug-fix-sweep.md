# Plan: 20-bug codebase-wide fix sweep

Status: active  
Started: 2026-08-09  
Owner: agent (orchestrated across 5 parallel workers)

## Goal

Find and fix 20 real bugs across the whole monorepo (backend, frontend, admin, Flutter, infra/images-worker) with zero regressions: every change is covered by a test, all suites stay green, and the user's uncommitted batch image-reliability work is preserved (it was committed mid-session as `63320ae`, so the fix diff sits on top of it).

## Non-goals

- No new features, no refactors beyond the minimal fix shape.
- No git writes (no commits/pushes) — the change set stays in the working tree.
- No schema changes, no migrations, no environment/config changes.

## Acceptance criteria

- [x] All 20 bugs fixed (7 backend, 3 frontend, 2 admin, 5 Flutter, 3 infra).
- [x] Every fix pinned by a test (new or strengthened).
- [x] Backend: ruff clean; full `pytest` 3674 passed / 4 skipped / 0 failed, 99.82% coverage.
- [x] Frontend: lint 0 errors; 269 tests / 50 files pass; production build OK.
- [x] Admin: lint, typecheck, 230 tests / 32 files, `check:schema` pass.
- [x] Flutter: `flutter analyze` no issues; 233 tests pass.
- [x] Infra: `node --test` 46/46 pass.

## Fixes

### Backend (7)

1. `api/v1/ai.py` — `search_similar_items` read `r.get("id")` but `find_similar` rows are `{"item_id", ...}` → always-empty `item_id`. Now maps `item_id`; mock/test updated to the real row shape.
2. `api/v1/recommendations.py` — `_build_complete_look_response` set `"position": item.get("category")` (string) ignoring its `position: int` param (bug since e4f73c2). Now emits `position`; `capsule_wardrobe` passes `enumerate` index; frontend `SuggestedItem.position` widened `string → number`.
3. `services/ai_service.py` + `agents/image_generation_agent.py` — `retryable_exceptions=(AIServiceError, Exception)` collapsed to `(Exception,)`, retrying PERMANENT failures 3x with backoff. Both now use `(AIServiceError,)` + `should_retry=is_retryable_error`.
4. `services/photoshoot_service.py` — completion payload reused the reservation-time usage snapshot; a failed run that released quota broadcast stale "limit deducted" numbers. Now re-reads post-release usage with a try/except fallback to the snapshot (parity with the streaming pipeline's re-read).
5. `services/storage_service.py` `key_from_path` — worker-CDN `tmp/{uuid}/...` URLs were reshaped into `{uuid}/...` (preview folder eaten) and OAuth/external URLs were reshaped into garbage keys. Now: preview-folder and UUID-first worker URLs returned as-is, bucket-drop guarded, true external URLs return `None`.
6. `api/v1/items.py` `_normalize_create_image_row` — derived unowned keys silently passed through despite the docstring promising 400. Now raises `ValidationError` for any unowned key (explicit or derived). New test file `test_item_create_image_normalization.py` pins the contract.
7. `services/storage_service.py` `_download_bytes` SSRF path — with `key_from_path` returning `None` for external URLs, nothing is fetched for non-key URLs; SSRF test updated to assert the stronger contract (bucket-only fetches, `None` for garbage URLs).

### Frontend (3)

8. `stores/outfitStore.ts` + `wardrobeStore.ts` — plain `fetchOutfits`/`fetchItems` appended page N onto an already-loaded list (duplicate tiles) after `fetchMore` advanced `page`. Entry points now always fetch page 1 and replace; `fetchMore` still appends (independent `page + 1`).
9. `hooks/useBatchExtraction.ts` — completion handler always built `data:image/png;base64,${base64}` even when the backend sent a URL instead of base64 (post-cleanup). Now falls back to `generated_image_url` and persists `generated_image_storage_path`; `generated_image_base64` optional in `ItemGenerationCompleteData`.
10. `Dockerfile` — `npm ci --only=production` made the image build fail (tsc/vite need devDependencies). Now `npm ci`.

### Admin (2)

11. `SettingsPage.tsx` — rendered `limits.free` while the backend emits `limits.free_monthly`, so the Free card showed all dashes. Now iterates backend keys `free_monthly`/`plus_monthly`/`pro_monthly` with an i18n-label map; new `SettingsPage.test.tsx` pins it.
12. `test/msw/handlers/iap.ts` — fixtures used cents (`1999`) while the backend serves dollars (`19.99`), and the detail handler dropped row fields. Fixtures corrected to dollars; handler merges `...row`.

### Flutter (5)

13. `dashboard_content.dart` — referral banner ignored a persisted dismissal for near-limit users (`!dismissed || isNearLimit`), making the dismiss button pointless. Dismissal now always honored; `isUrgent` styling still drives near-limit emphasis.
14. `photoshoot_controller.dart` — successful slot retry surfaced via `showError`. Now `showSuccess`.
15. `tryon_controller.dart` — `removeWardrobeItem` removed `clothingImages[index]`, which points at the WRONG image once camera/gallery photos are mixed in. Now resolves the item's temp file by id via a `_wardrobeItemFiles` map.
16. `tryon_controller.dart` — removing the current image left the wardrobe item selected ("already in your selection" on re-add) and leaked the temp file. Removal now also drops the item from the selection, cleans the temp file, and re-derives `selectedWardrobeItem` from the actual current image.
17. `tryon_controller.dart` — next/previous kept a stale `selectedWardrobeItem` when cycling past camera/gallery photos. Now re-derived from the current image; map cleared on reset.

### Infra / images-worker (3)

18. `worker.js` `claimsAreValid` — `aud` claim was not required (backend `security.py` requires `audience="authenticated"`). Now `aud === 'authenticated'` is mandatory; `iss` is required, not just checked-when-present.
19. `worker.test.mjs` — mint helpers now default `aud: 'authenticated'`; 3 new tests pin missing/wrong `iss` and `aud` → 404.
20. `README.md` — documented the stale "object's own cache-control always wins" behavior; corrected to match `cacheControlFor` (immutable default on write-once canonical/`_thumb` keys unless the object value is more restrictive; `tmp/`/`generated/` preview keys keep their own value).

## Context / links

- Related docs: `docs/BACKEND.md`, `docs/RELIABILITY.md`, `infra/images-worker/README.md`
- Related code: as listed per fix above
- The batch image-reliability work this sweep built on was committed mid-session by the user: `63320ae` (and `acc5e55` docs).

## Progress log

| Date | Note |
|------|------|
| 2026-08-09 | 20 bugs reported (phase 1); plan approved; 5 parallel fix agents (7+3+2+5+3); orchestrator re-review of every diff; full validation matrix re-run by orchestrator |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-09 | `key_from_path` returns `None` for external URLs instead of a garbage key | Callers (materialize, `_download_bytes`) get a safe no-op; SSRF surface removed |
| 2026-08-09 | Unowned derived keys rejected 400 like explicit ones | `key_from_path` `None` makes "derived" reliably mean "one of our key shapes"; persisting a cross-user key would re-mint presigned URLs for another user's objects |
| 2026-08-09 | `test_storage_source_image.py` updated | It pinned the removed garbage-key reshape; new assertions verify bucket-only fetches and `None` for non-key URLs (SSRF guarantee preserved/strengthened) |
| 2026-08-09 | Post-release usage re-read with snapshot fallback | A failed re-read must not kill the completion payload (parity with `run_pipeline`) |
| 2026-08-09 | Plain store fetches always replace with page 1 | Entry points are never pagers; `fetchMore` owns page advancement; removes duplicate-tile bug without touching infinite scroll |

## Verification

```bash
cd backend && source .venv/bin/activate && ruff check app tests && pytest -q
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
cd flutter && flutter analyze && flutter test
cd infra/images-worker && node --test
```

All green (see acceptance criteria). Note: `test_matte_is_fast_enough_for_the_generation_concurrency_budget` is timing-sensitive and can flake under heavy parallel CPU load; it passes in isolation and on an idle full run.

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None. (One observation, not debt: `isCacheable` treats any non-`no-store|private|no-cache|max-age=0` object value as replaceable by the immutable default — a hypothetical `max-age=1` stamp would be overridden; the app never writes such a value.)
