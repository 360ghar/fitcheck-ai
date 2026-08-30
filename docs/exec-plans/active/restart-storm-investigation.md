# Plan: Production restart-storm investigation

Status: active
Started: 2026-08-21
Owner: agent / human

## Goal

Identify why the production backend container restarted 14 times between
2026-08-20T18:50Z and 2026-08-21T08:26Z (intervals of roughly 20-90 min),
and eliminate the cause. Every restart drops in-flight photoshoot/batch AI
jobs and forces all clients through a token-refresh burst (observed 401
clusters at 20:03 and 22:17 on Aug 20).

## Evidence from the Aug 20-21 logs

- "Stopping Container" at: 19:05, 19:41, 20:27, 21:58, 22:38, 23:04,
  23:44, 00:20, 01:16, 02:57, 04:08, 04:44, 06:20, 07:27, 08:22 (UTC).
- Same commit (`8772cb5`) across every start → not deploy churn from new
  code; either platform-level restarts or repeated redeploys of the same
  build.
- Memory is NOT obviously the cause: `process_memory` peaks at ~224 MB RSS
  during the heaviest photoshoot+batch session (07:56-08:11), well under
  typical small-container limits. Startup baseline is steady at ~152 MB.
- One `WARNING: Exceeded concurrency limit.` burst at 18:50:29 during an
  automated scanner flood (~200 rapid 404s from one IP) — separate issue,
  but shows concurrency ceilings are reachable.

## Non-goals

- No changes to the job queue implementation until the restart cause is
  confirmed.
- No client-side retry logic changes.

## Acceptance criteria

- [ ] Root cause classified: OOM kill vs platform redeploy vs crash-loop.
- [ ] If OOM: memory ceiling identified and job payloads bounded or moved
      off-process. If platform: restart policy/deploy pipeline documented.
- [ ] In-flight photoshoot/batch jobs survive restarts OR fail fast with a
      client-visible status instead of hanging until cleanup.

## Context / links

- Related docs: `docs/RELIABILITY.md`, `docs/BACKEND.md` (job SSE model)
- Related code: `backend/app/services/photoshoot_service.py`,
  `backend/app/services/ai_extraction_service.py` (in-memory job state)
- Log source: Railway container logs, Aug 20 18:50 - Aug 21 08:26 UTC

## Progress log

| Date | Note |
|------|------|
| 2026-08-21 | Opened after log triage; evidence section filled from pasted logs |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-21 | Investigate before coding | Cause unknown; guessing risks churn |

## Verification

```bash
# After fix lands:
cd backend && source .venv/bin/activate && pytest tests/unit -q
# Manual: restart the container mid-photoshoot; client must see job fail
# fast or resume, never hang.
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Jobs live in process memory only; a restart orphans them until the
  periodic cleaner expires them.
