# Plan: extraction jobs and batch save review fixes

Status: active  
Started: 2026-09-29  
Owner: agent / human

## Goal

Fix the 15 findings from the `/code-review xhigh` pass on the uncommitted extraction-jobs, batch-save and job-notification change, so backend and Flutter tests are green.

## Non-goals

- Concurrent batch saves (Supabase pool races; documented in `docs/BACKEND.md`).
- Backend `index` field on `/items/upload` (Flutter pairs by `filename`).

## Acceptance criteria

- [x] Gemini `chat_with_vision` and the provider protocol accept `temperature`.
- [x] Batch save keeps a shared `tmp/` source until the batch ends.
- [x] `saveBatch` rethrows `BatchSaveUnsupported`; callers release `saving` on unexpected throws.
- [x] Saved rows match review pieces by echoed `temp_id`.
- [x] `stageSourceImages` never pairs a photo with another photo's key.
- [x] No `ref.read` inside `onDispose`.
- [x] Dropped SSE streams resubscribe (capped); failed cancel and expired jobs end locally.
- [x] Completion notification shows when the app is backgrounded.
- [x] Progress counters are absolute and unit-correct.
- [x] Android desugaring, notification id range, iOS permission and delegate.
- [x] Durable photo copies are unique per photo and deleted with the job.
- [ ] Device check: notification while backgrounded; iOS foreground/tap callbacks; kill and restore mid-job.

## Context / links

- Related docs: `docs/FLUTTER.md` (extraction background pattern), `docs/BACKEND.md` (batch save)
- Related code: `flutter/lib/features/wardrobe/providers/extraction_jobs_provider.dart`, `backend/app/services/item_save_service.py`

## Progress log

| Date | Note |
|------|------|
| 2026-09-29 | All code fixes and tests landed; device checks pending |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-29 | Foreground check reads `WidgetsBinding.lifecycleState` at notify time | No observer needed for a one-shot decision |
| 2026-09-29 | Docs dir and persistence are provider-injected | Unmocked plugin channels hang tests |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest && ruff check .
cd flutter && dart analyze && flutter test
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```
