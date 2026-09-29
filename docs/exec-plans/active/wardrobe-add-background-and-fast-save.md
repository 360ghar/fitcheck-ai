# Plan: wardrobe add background jobs + streaming progress + fast batch save

Status: active
Started: 2026-09-26
Owner: agent

## Goal

Single-photo and batch wardrobe adds run as app-scoped background jobs that survive
navigation and app kills (persisted jobIds, status-poll restore, local notification
on terminal state). Progress pages stream intermediate state: bounding boxes over the
source photo on `image_extraction_complete`, per-piece metadata immediately, and
progressive studio images with correct per-card loaders. Saving review pieces is one
`POST /items/batch-from-extraction` call with server-side image promotion instead of
N sequential create + download/re-upload + refetch loops.

## Non-goals

- Outfit builder preview generation (untouched).
- Web frontend adoption of the batch endpoint (kept compatible, adopted later).
- Push notifications (local only); OCR/crop features; new AI models.

## Acceptance criteria

- [ ] Start single/batch extraction, leave the page (back button, tab switch): job
      keeps running; Wardrobe banner + `/wardrobe/jobs` list show live progress.
- [ ] Kill + restart app with a running job: job restores from persistence, resumes
      progress display; terminal transition fires a local notification.
- [ ] During extraction, source photo shows boxes with labels; piece rows show
      name/category/colors/confidence as soon as detected (before studio images).
- [ ] Studio images stream in per piece (skeleton while pending, source-photo
      fallback + retry on failure); no fake timers; no bare spinners.
- [ ] Review save = 1 HTTP call; 10 pieces save in seconds; partial failures retry
      only the failed subset; re-tap never duplicates (idempotency keys).
- [ ] Legacy sequential save remains as fallback when the backend 404s the new route.
- [ ] `pytest`, `flutter analyze`, `flutter test`, `check_architecture.py` green.

## Context / links

- Related docs: `docs/FLUTTER.md` (batch/SSE section), `docs/BACKEND.md`
  (storage promotion, idempotency TD-109), `ARCHITECTURE.md` (routes thin).
- Related code: `flutter/lib/features/wardrobe/providers/{item_add,batch_extraction}_provider.dart`,
  `flutter/lib/features/wardrobe/widgets/{ai_extraction_widget,extraction_progress_card,bounding_box_painter}.dart`,
  `backend/app/api/v1/items.py` (`create_item`, `_normalize_create_image_row`),
  `backend/app/api/v1/batch_processing.py` (SSE/status/cancel contract).

## Progress log

| Date | Note |
|------|------|
| 2026-09-26 | Started. Spec approved: wardrobe single+batch scope, full background, new batch endpoint. |
| 2026-09-26 | Implemented + verified. Backend `item_save_service` + `POST /items/batch-from-extraction` (136 tests incl. 6 new batch tests, ruff + arch clean). Flutter: `extractionJobsProvider` registry + shade notifications + jobs page + banner, single/batch resume + streaming boxes, `saveBatch` with staged-source batching + legacy fallback, 6 new widget/model tests. `flutter analyze` clean. Docs: FLUTTER.md background pattern, BACKEND.md batch contract. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-26 | Registry owns SSE streams; page providers attach/detach | Leaving a page must not cancel; single broadcast per job avoids duplicate streams. |
| 2026-09-26 | New `POST /items/batch-from-extraction`, sequential server-side | Reuses `client_request_id` replay + tmp-promote COPY path; sequential avoids Supabase pool races; 1 round trip is the dominant win. |
| 2026-09-26 | Pass generated URL (not base64) as the image ref | `_normalize_create_image_row` already derives the key and promotes server-side; zero re-upload bytes. |
| 2026-09-26 | `flutter_local_notifications` for terminal alerts | Dart logic stays patchable; only manifest/permission config is native. |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest
cd backend && source .venv/bin/activate && ruff check .
python scripts/check_architecture.py
cd flutter && flutter analyze
cd flutter && flutter test
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
-
