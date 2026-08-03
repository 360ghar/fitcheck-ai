# Plan: Photoshoot speed — wall time + live generation experience

Status: active
Started: 2026-08-03
Owner: agent

## Goal

Cut AI Photoshoot wall time (a 10-image run was ~3–4.5 min) by raising
per-job image-generation concurrency 2 → 4, and make the wait feel fast by
showing the generation process live in every client: which scene is being
generated, thumbnails as each image completes, a rolling ETA, and a visible
cancel. The web app migrates off the sync endpoint (TD-019) to the async
job + SSE flow the backend already supports, and the anonymous landing demo
becomes a polled job instead of one long HTTP request. No caching.

## Non-goals

- No prompt/subject caching of any kind.
- No change to quota limits, plans, or rate limits.
- No memory-guard on the concurrency bump (user-approved plain raise).
- No migration to the photoshoot DB schema (demo jobs stay in-memory).

## Acceptance criteria

- [ ] `PHOTOSHOOT_CONCURRENCY_LIMIT` default 4 (config + test).
- [ ] SSE `batch_started` carries `scene_labels` (index → label); `image_complete`
      and `image_failed` carry `label` (backend service + tests).
- [ ] `POST /photoshoot/demo` returns a `job_id` (202) and runs under an
      IP-derived pseudo-user with quota reservation skipped; new
      `GET /photoshoot/demo/{job_id}/status` validates the same IP (route +
      tests).
- [ ] Web `generate()` runs the async job + SSE flow: live partial gallery,
      real progress, current-scene label, ETA, cancel button, bounded poll
      fallback; `retryFailedSlot` uses the async flow. Sync path untouched for
      other callers (kept as legacy).
- [ ] Landing demo card polls the demo job and shows partial images while
      generating.
- [ ] Flutter generating step shows live thumbnails with skeleton placeholders,
      ETA, current scene, and a cancel button.
- [ ] TD-019 marked fixed; docs updated (BACKEND, FRONTEND, RELIABILITY,
      photoshoot feature spec).

## Context / links

- Related docs: `docs/BACKEND.md`, `docs/RELIABILITY.md` (memory), `docs/product-specs/features/photoshoot.md`
- Related code:
  - `backend/app/core/config.py` (concurrency default)
  - `backend/app/services/photoshoot_service.py` (is_demo, scene labels)
  - `backend/app/api/v1/photoshoot.py` (demo job + status endpoint)
  - `frontend/src/api/batch.ts` (generalized SSE helper), `api/photoshoot.ts`,
    `stores/photoshootStore.ts`, `components/landing/PhotoshootDemo.tsx`
  - `flutter/lib/features/photoshoot/controllers/photoshoot_controller.dart`,
    `views/photoshoot_generating_step.dart`, `models/photoshoot_models.dart`
- Related issues: TD-019 (web sync path), TD-044 context (image-gen memory), 2026-08-03 512MB memory budget

## Progress log

| Date | Note |
|------|------|
| 2026-08-03 | Spec approved; backend + web + flutter implemented; verification in progress |
| 2026-08-03 | Verification green: backend pytest 846 + ruff clean, frontend lint/build + 135 vitest tests, flutter analyze + 121 tests, architecture + docs checks, check_all.sh |
| 2026-08-04 | **Self-review fixes**: (1) demo pseudo-user now derives from `get_client_ip` (`request.client.host`, uvicorn proxy-resolved) instead of hand-parsed `X-Forwarded-For` — the header is client-spoofable and would have let a caller mint a fresh pseudo-user per request to bypass the per-IP demo limit (regression vs `app/core/ip_rate_limit.py` policy; new regression test); (2) web store no longer double-tracks `photoshoot_session_failed` when the SSE/poll `job_failed` terminal path rejects into the outer catch — terminal handlers now resolve; (3) `cancelGeneration` settles the in-flight `generate()` promise via `_settleGeneration` so an SSE abort racing the `job_cancelled` event cannot leave the promise pending forever; (4) Flutter `job_failed` clears ETA/scene state. Re-verified: backend 847 pytest + ruff, frontend lint/build/135 vitest, flutter analyze clean |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-03 | Concurrency raised plainly to 4, no RSS guard | User-approved; per-image URL upload + payload release + global cap bound memory |
| 2026-08-03 | Demo jobs in-memory (no DB persistence) | `photoshoot_jobs.user_id` is FK-constrained to `users`; a pseudo-user cannot persist, and 2-image jobs are short-lived |
| 2026-08-03 | Demo uses polling, not SSE | Keeps the anonymous surface auth-free and simple |
| 2026-08-03 | No prompt caching | User explicitly removed caching from the approved spec |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest && ruff check app tests
cd frontend && npm run lint && npm run build && npx vitest run
cd flutter && flutter analyze && flutter test
python scripts/check_architecture.py
python scripts/check_docs_structure.py
./scripts/check_all.sh
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None new. TD-019 closed by this pass (web migrated to async + SSE).
