# RCA: photoshoot job completes with 0 images while the daily quota is deducted

Status: active (fixes landed; provider-side cause still needs the new logs after deploy)
Started: 2026-08-04
Owner: agent

## Goal

On the mobile app a photoshoot run could end at a "0 images generated"
results screen while the daily quota was already deducted — the user paid
(quota) for nothing, with no error and no retry affordance. This RCA covers
the failure chain, the pipeline/UI defects that made a provider failure look
like a silent quota burn, and the fixes that make zero-image runs fail
loudly with a retry path (matching the sync path).

## Root cause

Production logs (2026-08-04 22:53–22:57 UTC, jobs `ba355896` / `eeb83cf6`)
show: prompt generation started, 5/3 image-generation requests started, then
cleanup (`photoshoot_refs_released`, `event_history_cleared`,
`generated_payloads_released`) and repeated `/events` polling connections —
with **no completion or failure lines** for the image requests and **no
fallback-model attempts** (one attempt per image). The pipeline then marked
the job COMPLETE with 0 images.

Confirmed defects in the code path:

1. **Zero-image runs were marked COMPLETE, not FAILED.** `run_pipeline`
   broadcast `job_complete` regardless of `generated_count`, so the mobile
   app landed on a results screen with an empty gallery and no error or retry.
2. **`job_complete` carried stale, pre-release usage.** The payload was
   assembled from the reservation-time snapshot; `release_daily_usage` had
   already reconciled the DB, so the client's displayed quota was wrong
   (appeared "deducted" even after release restored it).
3. **No info-level visibility on the images API path.** The images API
   (`_generate_image_via_images_api`) logged the request start but nothing on
   response — a provider failure was invisible in Railway's `[inf]`-only
   drain, and with a single non-retryable attempt there was no fallback
   trail either. (Provider failure itself is the primary, unconfirmed cause;
   see Follow-ups.)
4. **SSE replay stripped base64 only for try-on keys.** `strip_history_base64`
   handled `generated_image_base64` but not photoshoot's `image_base64`, so
   replay history could re-deliver full-size base64 events and blow the
   mobile client's 512KB SSE buffer cap — which can also drop the remaining
   `image_complete` events mid-stream.
5. **Mobile results screen depended solely on `image_complete` events.** The
   gallery was built only from SSE events; a dropped/never-received
   `image_complete` (flaky stream, buffer overflow, reconnect) left the
   results step empty even when the job actually produced images. The
   `job_complete` event carries counts but no images, so there was no
   recovery path.

## Fixes (landed)

- **Zero images ⇒ FAILED.** `run_pipeline` now broadcasts `job_failed`
  (with `error`, post-release `usage`, `failed_indices`, and the first
  per-index provider error) instead of `job_complete` when
  `generated_count == 0`, after cleanup. The mobile app already maps
  `job_failed` to an error dialog + return to configure step (retry path).
  Partial runs still complete, but with reconciled state.
- **Post-release usage in `job_complete` / `job_failed`.** After
  `release_daily_usage`, `run_pipeline` re-reads usage via `get_usage` and
  sends that snapshot, so the client's quota display matches the DB.
- **First-error surfaced.** `PhotoshootJob` now records per-index
  `image_failures` (persisted with the job, 500-char bounded) and
  `get_first_error` / `get_job_status` expose it; the `job_failed` payload
  and `GET /photoshoot/usage` / status paths include it for support
  triage.
- **Visibility.** `_generate_image_via_images_api` logs an info-level
  "AI image generation response received" with latency and count, so a
  provider failure (status/error) is visible in Railway `[inf]` drains and
  the absence of the line times the failure window precisely.
- **SSE replay fix.** `strip_history_base64` walks keys and strips
  `image_base64` when an `image_url` is present (kept only when the image
  has no URL), matching the try-on behavior.
- **Mobile reconcile.** `PhotoshootController` now reconciles the gallery
  from `GET /status` after `job_complete` (idempotent dedupe), so a missed
  `image_complete` can never produce an empty results screen for a complete
  job; the SSE buffer cap was raised 512KB → 4MB.

## Code

- `backend/app/services/photoshoot_service.py` — zero-image ⇒ `job_failed`;
  post-release usage re-read for `set_usage` / `job_complete` / `job_failed`
  (falls back to the reservation snapshot if the usage re-read fails, so a
  usage-endpoint blip can never kill the terminal event or double-release
  quota)
- `backend/app/services/photoshoot_job_service.py` — `image_failures`,
  `get_first_error`, `get_job_status.first_error`
- `backend/db/supabase/migrations/035_add_photoshoot_jobs_image_failures.sql`
  — **required**: adds the `image_failures` column the persisted payload
  writes; without it PostgREST rejects the payload key (PGRST204) and every
  job create / terminal transition fails
- `backend/app/utils/sse_queue.py` — `strip_history_base64` strips
  `image_base64` when `image_url` present
- `backend/app/services/ai_provider_service.py` — "AI image generation
  response received" info log (latency + count)
- `flutter/lib/features/photoshoot/controllers/photoshoot_controller.dart` —
  repository injection, `_reconcileStatus`, `_reconcileAfterComplete`,
  async `_handleJobComplete` awaits the status reconcile before opening
  results
- `flutter/lib/core/services/sse_service.dart` — SSE buffer cap 512KB → 4MB

## Tests

- `backend/tests/test_photoshoot_service.py` — zero-image run broadcasts
  `job_failed` with first error; partial run completes with post-release
  usage; quota-reservation test asserts FAILED status + restored usage;
  `mark_image_failed` retains error detail; usage re-read failure falls
  back to the reservation snapshot without double-releasing quota
- `backend/tests/test_sse_slow_consumer.py` — `image_base64` stripped when
  URL present; kept when URL-less
- `backend/tests/test_job_payload_schema_sync.py` — new: every
  `_build_persisted_payload` key must have a `photoshoot_jobs` column in
  the migration SQL (the guard that would have caught the missing
  `image_failures` column; found in self-review)
- `flutter/test/features/photoshoot/controllers/photoshoot_controller_test.dart`
  — new: `job_complete` reconciles the gallery from status when an
  `image_complete` event was missed (regression for the empty results
  screen); photo file IO runs under `tester.runAsync` (real IO never
  completes under FakeAsync), snackbar closed via `Get.closeAllSnackbars()`
  so the overlay ticker is disposed before teardown (pattern from
  `wardrobe_controller_test.dart`)

## Verification

- Backend: targeted photoshoot/SSE/schema-sync tests pass; full suite
  **999 passed, 1 skipped** (the earlier 6 storage-migration failures in
  the uncommitted storage work are gone from the current tree);
  `ruff check` clean.
- Flutter: `flutter analyze` clean; full `flutter test` 146 passed.

## Follow-ups (operator)

- **Apply migration 035 on hosted Supabase BEFORE/with the backend deploy**
  (idempotent). Without the `image_failures` column, PostgREST rejects the
  persisted payload key and every photoshoot job create / terminal
  transition fails.
- The primary provider failure is still unconfirmed — error-level lines were
  never captured. After deploy, the new `job_failed` dialog and the
  "AI image generation response received" / error logs will name the
  provider status. If it persists, check Railway env
  `AI_IMAGE_FALLBACK_MODEL` / `AI_IMAGE_API_KEY` (a rotated/expired key
  produces exactly this "request started, no response, no fallback" pattern)
  and the image gateway status.
- Verify `GET /api/v1/photoshoot/usage` shows restored quota for the two
  2026-08-04 jobs (`ba355896`, `eeb83cf6`).
