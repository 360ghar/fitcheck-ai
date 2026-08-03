# Plan: 512 MB memory-budget optimization (Railway worker)

Status: active
Started: 2026-08-03
Owner: agent

## Goal

Keep the backend alive on the current Railway allotment (0.5 vCPU / 0.5 GB
RAM) by removing every *non-input* memory cost from the AI image pipeline:
duplicate payload copies, unbounded concurrent decodes, payloads pinned by
job state, SSE backlogs, and allocator fragmentation. Peak RSS under real
workloads must fit under ~450 MB with NO user-facing limit changes
(concurrency defaults 30/30/8, `--limit-concurrency 50`, per-image caps,
50-image batch cap, 2-job cap, all rate limits stay identical).

## Non-goals

- No user-facing limit/concurrency/cap changes (explicitly rejected).
- No separate AI worker process.
- No change to the live SSE event schema (live events still carry base64).
- No Docker-based local dev.
- Reducing the Python baseline floor (~150-250 MB).

## Acceptance criteria

- [ ] `/health` and `log_memory` report CURRENT RSS (VmRSS), not `ru_maxrss` peak.
- [ ] All CPU-bound image ops (downscale, crop, matte, storage validation)
      run on the bounded executor (default 4 workers, env-tunable), never the
      default to_thread pool or the event loop.
- [ ] No full-size `to_data_url` copy per reference image: images travel bare
      in messages; OpenAI path wraps at wire serialization, Gemini sniffs mime
      from the first bytes. `_decode_image_part` accepts bare base64 AND data
      URLs (backward compat).
- [ ] `_hash_image` hashes incrementally (no full-payload `encode()` copy).
- [ ] Exceptions stored in `ParallelResult.error` have `__traceback__ = None`.
- [ ] Batch generation uploads generated images to a storage URL at
      generation time; terminal job state nulls `generated_image_base64` for
      items WITH a URL (upload failure keeps base64). Status polls return URL.
- [ ] Per-image source base64 released as each extraction finishes
      (`release_single_image_payload`), not only at phase end.
- [ ] `photo_cache` in the batch generation consumer releases a URL's base64
      when its last pending item is dispatched (refcount).
- [ ] SSE `event_history` stores base64-stripped events, bounded; subscriber
      queues enforce the byte budget (`SSE_QUEUE_MAX_BUFFERED_BYTES`) in
      addition to the 100-event cap; overflow drops the subscriber with the
      existing `stream_overflow` terminal event.
- [ ] Flutter save path handles the reload-after-completion edge: a real
      `generated_image_url` (not data URL) is downloaded and uploaded.
- [ ] Dockerfile sets `MALLOC_ARENA_MAX=2` and `MALLOC_TRIM_THRESHOLD_=0`.
- [ ] Startup runs `gc.freeze()` + `gc.set_threshold(700, 5, 5)` and one
      `gc.collect()` after background startup completes (all best-effort).
- [ ] Docs updated: this plan file, `docs/RELIABILITY.md` memory section.

## Context / links

- Related docs: `docs/RELIABILITY.md` (memory section), `docs/exec-plans/tech-debt-tracker.md` (TD-044).
- Related code:
  - `backend/app/utils/process_metrics.py` (current RSS)
  - `backend/app/core/image_executor.py` (bounded executor, new)
  - `backend/app/utils/sse_queue.py` (byte budget)
  - `backend/app/services/batch_job_service.py`, `photoshoot_job_service.py` (lifecycle)
  - `backend/app/services/batch_extraction_service.py` (per-image release, URL upload, photo_cache refcount)
  - `backend/app/services/ai_provider_interface.py`, `ai_provider_service.py`, `gemini_provider.py` (bare-base64 message shape)
  - `backend/app/utils/image_processing.py` (draft decode)
  - `backend/app/services/storage_service.py` (`download_and_downscale_to_base64`)
  - `flutter/lib/features/wardrobe/repositories/item_repository.dart`, `controllers/batch_extraction_controller.dart` (URL fallback)
- Related issues: Railway 512 MB worker OOM during try-on/image-gen storm (2026-08-03).

## Progress log

| Date | Note |
|------|------|
| 2026-08-03 | Spec approved (specs/2026-08-03-512-mb-memory-budget-optimization-deep-pass-no-user-facing-limit-changes.md). Implementation complete; verification in progress. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-03 | No limit/concurrency changes | Explicit user requirement; all previous limit-lowering specs rejected. |
| 2026-08-03 | Live SSE events keep base64; only history/status are URL-only | In-flow client saves must work unchanged; only terminal state is slimmed. |
| 2026-08-03 | Upload failure keeps base64 in memory | Degrade gracefully (photoshoot pattern); memory is the price of delivering the image. |
| 2026-08-03 | Bare base64 + provider-side mime handling instead of shared `to_data_url` | Kills one full-size string copy per reference image per call; mime sniffing preserves the earlier correctness fix. |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest
cd backend && ruff check app tests
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd flutter && flutter analyze
# Manual: local storm test (uvicorn app.main:app, concurrent batch/single
# extract with 8-12 MP images) — /health rss_mb is now CURRENT RSS; peak must
# stay < ~450 MB and return to baseline after jobs finish.
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None new. TD-044 (semaphore) already fixed; this plan closes the remaining
  memory sources.
