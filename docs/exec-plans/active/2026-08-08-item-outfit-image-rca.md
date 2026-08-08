# Plan: 2026-08-08 extracted-item and outfit image loss — Flutter RCA + fixes

Status: active
Started: 2026-08-08
Owner: agent

## Goal

Fix two user-visible image-loss bugs in the FitCheck AI mobile app (Flutter):
(1) AI-extracted items saved from the batch add-outfits flow persist with **no
image at all**; (2) an outfit's images disappear after opening the outfit and
navigating back, permanently (never recover). Both fixes are client-side; the
backend was audited and confirmed correct.

## RCA

| # | Symptom | Root cause | Fix |
|---|---------|------------|-----|
| 1 | Save persisted 4 extracted items, all image-less (`POST /api/v1/items` → 201 with **zero** `POST /api/v1/items/{id}/images` calls) | `BatchExtractionController.saveSelectedItems()` treated any non-empty `generatedImageUrl` as base64: `generatedImageBase64 ?? generatedImageUrl.replaceFirst(data-URI regex, '')`. A real presigned URL passed `base64Decode` → `FormatException`, swallowed silently by `uploadImageFromBase64` (returned null on every error). The `uploadImageFromUrl` branch was dead code: the backend ships `generated_image_base64: null` + `generated_image_url` at `job_complete` and frees base64 at job end, so URL-backed items always took the broken path | Rewrote the upload chain in `saveSelectedItems`: (1) in-memory base64, (2) data-URI only when `startsWith('data:image')`, (3) real URL via `uploadImageFromUrl` (download + re-upload), (4) source photo the item was extracted from. Failure is tracked (`imageUploaded`) and reported via `ErrorHandler.reportError` when a saved item ends image-less |
| 2 | Outfit images render fine, then after opening the outfit and going back the tiles are permanently broken | Images are served through **1-hour presigned GET URLs** (`OBJECT_STORAGE_PRESIGN_TTL=3600`, `IMAGE_SERVING_MODE=presigned`); the app caches the URLs on the model at list-fetch time. `OutfitDetailPage._loadOutfit` was cache-first, so opening the page after expiry rendered an expired URL, and `CachedNetworkImage`'s error tile had no retry. Disk-cache eviction (flutter_cache_manager object cap / iOS purge) made the retry-with-same-URL useless anyway | (a) `_loadOutfit` now **always** calls `refreshOutfitById()` when the outfit is cached — fresh presigned URLs on every open, and the list entry is replaced so the card is fresh after back-navigation. (b) New one-shot re-mint fallback in `AppImage`: on load failure with a `storagePath` + `remintUrl`, request a fresh URL from `GET /api/v1/images/presigned?storage_path=…` and retry once (post-frame, so no setState-during-build). Wired into outfit detail header + item tiles, outfit cards, and wardrobe list/grid cards |

Backend behavior confirmed correct and **unchanged**:
`batch_extraction_service._broadcast_job_complete` intentionally ships
`generated_image_base64: null` + `generated_image_url` (in-memory base64 is
freed at job end); all outfit list/detail/update endpoints materialize fresh
presigned URLs; `storage_path` is already persisted on `item_images` /
`outfit_images` rows; `GET /api/v1/images/presigned` (auth-protected) already
existed for client re-minting.

## Non-goals

- No backend changes, no migrations, no schema changes.
- No new upload endpoint; `uploadImageFromUrl` (download bytes → upload to
  item) reuses the existing items-images upload API.
- No change to `IMAGE_SERVING_MODE` / TTL (still presigned; the app now
  tolerates expiry instead).

## Acceptance criteria

- [x] `saveSelectedItems` routes: base64 → data-URI → URL → source photo;
      URL-only items reach `uploadImageFromUrl` (regression test).
- [x] Upload helpers report failures via `ErrorHandler.reportError` instead of
      returning null silently.
- [x] Opening an outfit detail always refreshes the outfit from the server
      when a cached copy exists (widget test).
- [x] `AppImage` re-mints and retries exactly once on load failure when
      `storagePath` + `remintUrl` are present (widget tests: remint+retry,
      no-storagePath, null-remint).
- [x] `flutter analyze` clean; full `flutter test` (209 tests) green.

## Context / links

- Related code:
  - `flutter/lib/features/wardrobe/controllers/batch_extraction_controller.dart`
  - `flutter/lib/features/wardrobe/repositories/item_repository.dart`
  - `flutter/lib/features/outfits/repositories/outfit_repository.dart`
  - `flutter/lib/features/outfits/views/outfit_detail_page.dart`
  - `flutter/lib/features/outfits/views/outfits_content.dart`
  - `flutter/lib/features/wardrobe/views/wardrobe_content.dart`
  - `flutter/lib/core/widgets/app_image.dart`
  - `flutter/lib/features/wardrobe/models/item_model.dart`,
    `flutter/lib/features/outfits/models/outfit_model.dart` (+ regenerated `.g.dart`)
  - `flutter/lib/core/constants/api_constants.dart`
- Related backend (read-only audit): `batch_extraction_service.py`,
  `storage_service.py`, `api/v1/images.py`, `api/v1/outfits.py`, `api/v1/items.py`
- Related docs: `docs/exec-plans/active/2026-08-05-railway-egress-rca.md`
  (presigned-mode serving), `flutter/metadata/release_notes.txt`
- Production evidence: 2026-08-08 03:24–06:11Z logs (commit 378bc727) — 4×
  `POST /api/v1/items → 201` with no `/items/{id}/images` calls after
  `job_complete` SSE events.

## Progress log

| Date | Note |
|------|------|
| 2026-08-08 | RCA complete (read-only audit of backend + Flutter pipeline); plan approved |
| 2026-08-08 | Implemented all Flutter fixes; regenerated freezed/json models; tests added; analyze clean; full test suite green (209) |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-08 | Fix client-side only | Backend contract is intentional (base64 freed at job end, presigned serving is the design); client must handle both states |
| 2026-08-08 | `AppImage` re-mint is one-shot | A second failure means the object is genuinely unreadable; looping would burn requests |
| 2026-08-08 | Make `ItemRepository` injectable into `BatchExtractionController` (mirrors `batchRepository`) | Unit-test the save image strategy without network |
| 2026-08-08 | `AppImage` gains an injectable `cacheManager`; `flutter_cache_manager` promoted to a direct dependency; `file` added as dev dep | Widget tests need a channel-free cache manager (no path_provider/sqflite in the test host); the 400-mock `MockClient` makes the failure deterministic |
| 2026-08-08 | `OutfitDetailPage` refreshes on open instead of re-minting everything | One cheap request per open replaces stale URLs globally (header, tiles, and the card after back); re-mint remains the safety net for list surfaces and races |

## Verification

```bash
cd flutter
dart run build_runner build --delete-conflicting-outputs
flutter analyze                      # No issues found
flutter test                         # 209 tests, all pass
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None discovered. (Pre-existing unrelated log noise: `photoshoot_jobs.image_failures`
  schema warning, Stripe/AI_ENCRYPTION_KEY unset — tracked elsewhere.)

---

# Part 2 — sibling-bug sweep (same two mechanisms, every remaining surface)

Status: active
Started: 2026-08-08 (continuation; same RCA family)

## Goal

After review of Part 1, sweep the rest of the app for the same two failure
mechanisms — (1) save-time image handling misrouting a presigned URL into
`base64Decode` / skipping the upload, and (2) stale 1h-presigned URLs served
blind from cached models without a re-mint fallback — and fix every surface.
Includes one small **additive** backend change so dashboard images become
re-mintable (approved by user: full Tier 1 + Tier 2 sweep).

## Findings

| # | Surface | Mechanism | Severity | Resolution |
|---|---------|-----------|----------|------------|
| 1 | `ItemAddController.saveGeneratedItems()` (single-item extraction) | Bug 1: URL-only `generatedImageUrl` → `base64Decode` throws → swallowed → item saved image-less and counted as saved | REAL, high | Rewrote strategy chain (data-URI → URL → source photo), `imageUploaded` tracking, `ErrorHandler.reportError` on image-less save; `ItemRepository` injectable for tests |
| 2 | `OutfitBuilderController.saveOutfit()` | Bug 1 latent: URL-valued `generatedImageUrl` skipped with a `debugPrint` | Latent (contract-supported) | New `OutfitRepository.uploadOutfitImageFromUrl` (download → re-upload); URL branch now uploads; telemetry when no image strategy succeeds; repositories injectable for tests |
| 3 | `extracted_item_card.dart`, `batch_image_selector_page.dart` (live-generation previews) | Data-URI passed to `CachedNetworkImage` (can't decode) → broken thumbnails mid-generation | Transient glitch | `AppNetworkImage` now routes `data:image` URLs through `Image.memory` (central fix, incl. try-on previews); malformed payload → error widget |
| 4 | `item_detail_page.dart` | Bug 2: cache-first `_loadItem`, header `AppImage` without re-mint | REAL, high | `_loadItem` calls new `WardrobeController.refreshItemById` when cached; header wired with `storagePath` + `remintUrl` |
| 5 | `outfit_edit_page.dart` | Bug 2: cache-first `fetchOutfitById`, thumbnails without re-mint | REAL, high | `_loadOutfit` refreshes via `refreshOutfitById` when cached (falls back to cached on failure); per-image `storagePath` + `remintUrl` wired |
| 6 | `item_edit_page.dart`, `outfit_builder_page.dart` (canvas + picker), `outfit_canvas_item_card.dart`, `duplicate_detection_widget.dart` | Bug 2: item images from cached models, no re-mint | Medium | All wired with `storagePath` + `remintUrl` |
| 7 | Recommendations (all 5 tabs) | Bug 2: item images w/o re-mint | Medium | Wired `storagePath` + `remintUrl` in `find_matches_tab`, `complete_look_tab`, `weather_based_tab`, `astrology_tab`, `recommendations_page`; `AppNetworkImage` gained the same one-shot re-mint as `AppImage` |
| 8 | Dashboard suggestions + activity feed | Bug 2: models dropped `storage_path` server-side → no re-mint possible | Low-med | **Backend (additive):** `users.py` `_get_outfit_of_the_day` + `_build_recent_activity` now include `storage_path`; Flutter `DashboardOutfitOfTheDay`/`DashboardActivity` parse it; tiles wired with re-mint |
| 9 | `shared_outfit_page.dart` | Bug 2 | Low | **Verified fresh-at-fetch:** `GET /outfits/public/{id}` materializes fresh presigned URLs on every read — no change |
| 10 | Avatars (dashboard header, profile edit) | Presigned avatar URL cached in session `user` model | Cosmetic | Deferred (Tier 3): breaks only after 1h open session; try-on generation uses the server-side avatar |
| 11 | `createItemWithImage()` / `batchCreateItems()` | Upload failure throws leaving an orphan item; dead code with silent image-loss | Debt | Deferred (Tier 3): visible failure, not silent loss |

## Acceptance criteria

- [x] Single-item extraction save routes URL-only images via
      `uploadImageFromUrl` (regression test), data-URI via base64, falls back
      to source photo, and never misroutes a URL into `base64Decode`
      (`item_add_controller_test.dart`, 6 tests).
- [x] Outfit builder save uploads URL-valued visualizations via
      `uploadOutfitImageFromUrl` (regression test, 3 tests).
- [x] Item detail + outfit edit pages refresh the cached model on open
      (widget tests) and render re-mint-capable images.
- [x] `AppNetworkImage` renders data-URI previews (`Image.memory`), surfaces
      malformed payloads via the error widget, and re-mints once on failure
      when `storagePath` + `remintUrl` are present (tests in
      `app_network_image_test.dart`).
- [x] Dashboard backend payloads include `storage_path`; backend tests
      updated (legacy rows → `null`, materialized rows → durable key).
- [x] `flutter analyze` clean; full `flutter test` (223 tests) green;
      backend users-route tests green; `./scripts/check_all.sh` green
      (backend coverage 99.92%).

## Additional files touched (Part 2)

- `flutter/lib/features/wardrobe/controllers/item_add_controller.dart`,
  `wardrobe_controller.dart` (+`refreshItemById`), `views/item_detail_page.dart`,
  `views/item_edit_page.dart`, `widgets/duplicate_detection_widget.dart`
- `flutter/lib/features/outfits/controllers/outfit_builder_controller.dart`
  (+injectable repos), `repositories/outfit_repository.dart`
  (+`uploadOutfitImageFromUrl`), `views/outfit_builder_page.dart`,
  `views/outfit_edit_page.dart`, `widgets/outfit_canvas_item_card.dart`
- `flutter/lib/core/widgets/app_network_image.dart` (data-URI rendering +
  one-shot re-mint, mirrors `AppImage`)
- `flutter/lib/features/recommendations/*` (5 tabs + page), `features/dashboard/*`
  (models + `suggestions_section.dart` + `activity_feed.dart`)
- `flutter/test/...` — `item_add_controller_test.dart` (new),
  `outfit_builder_controller_test.dart` (new), `item_detail_page_test.dart` (new),
  `app_network_image_test.dart` (extended)
- `backend/app/api/v1/users.py` (dashboard `storage_path`, additive),
  `backend/tests/integration/test_users_routes.py` (updated assertions)

## Post-sweep review (self-review pass)

Re-audited every image surface after the sweep (grep of `AppImage(` /
`AppNetworkImage(` / `appImageProvider(` / `CachedNetworkImage(` /
`Image.network(` across `flutter/lib`). Three residual gaps found and fixed:

1. **Try-on wardrobe picker** (`tryon_content.dart`, 2 sites) — the
   selected-items strip and the picker grid tiles rendered cached `ItemModel`
   URLs with no re-mint; stale URLs showed a permanent
   `Icons.image_not_supported`. Wired `storagePath` + `remintUrl` at both
   (the sheet's existing `_itemRepository` + a `static final` in
   `_WardrobeItemTile`).
2. **Recommendations selection chips** (`recommendations_page.dart`,
   `SelectedItemsChips`) — chip avatars used `CircleAvatar(backgroundImage:
   appImageProvider(url))`, which has no error/retry hook: a stale URL painted
   a silently blank avatar. Replaced with `ClipOval` + `AppNetworkImage`
   (re-mint wired, icon fallback).
3. **`AppImage._openViewer` zoom gap** — the full-screen `AppImageViewer`
   received the ORIGINAL `galleryUrls`, so after a tile re-minted (Part 1
   mechanism), tapping to zoom still opened the stale URL. `_openViewer` now
   substitutes the tile's `_activeUrl` at the initial index.

Verified non-issues in the same pass: `gamification_page` leaderboard avatars
(fresh per fetch, initial-letter fallback), `batch_image_selector_page` social
import previews (third-party stable URLs / data URIs, no storage key),
try-on generated-result previews (session-fresh, not persisted), photoshoot
gallery (job-fresh), `tryon_content` PhotoView full-screen viewer (taps capture
the post-re-mint URL from the rebuilt tile).

## Notes / decision log (Part 2)

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-08 | `AppNetworkImage` gains re-mint (mirrors `AppImage`) instead of swapping call sites to `AppImage` | Keeps the minimal widget minimal; recommendations tiles keep their custom error widgets |
| 2026-08-08 | Dashboard backend change is additive only | One field per payload; no behavior change for existing clients |
| 2026-08-08 | Outfit-edit page has no widget test | Pre-existing debug-mode framework assertion ("ListTile background color or ink splashes may be invisible", ListTile in AppGlassCard) fires on every render of the edit page; the refresh-on-open logic is covered at the controller level (`refreshOutfitById`/`fetchOutfitById` tests). Tracked in tech-debt tracker |
| 2026-08-08 | Shared-outfit page untouched | Backend materializes fresh URLs per read; model carries no `storagePath` — genuinely fresh-at-fetch |

## Deferred debt (Tier 3, tracked in tech-debt tracker)

- Session-cached presigned avatar URL (cosmetic after 1h; refresh user on
  profile/dashboard open as follow-up)
- `createItemWithImage` orphan item when image upload throws
- `batchCreateItems` dead code with silent image-loss baked in
- Outfit edit page ListTile-in-DecoratedBox debug assertion
