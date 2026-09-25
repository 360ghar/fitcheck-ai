# Plan: Cross-client reliability audit

Status: completed  
Started: 2026-09-22  
Owner: agent

## Goal

Audit the public web app, admin console, Flutter client, and FastAPI backend for reproducible reliability defects, prioritizing missing loading/error states and unsafe exception handling. Fix confirmed high-impact issues with regression coverage, while recording findings that cannot responsibly fit in one bounded change set.

## Non-goals

- Redesigning complete product surfaces or changing product behavior without evidence.
- Exercising paid/external providers or mutating hosted production data.
- Claiming exhaustive production verification from repository-level tests.

## Acceptance criteria

- [x] Existing architecture, lint, type, and automated test checks were run for every available app toolchain.
- [x] Client async flows were statically reviewed for missing loading, empty, and error states.
- [x] Backend exception boundaries were reviewed for swallowed errors and inconsistent public responses.
- [x] Confirmed high-impact defects are covered by regression tests and fixed at their root cause.
- [x] The completed plan records verification limits and deferred findings.

## Context / links

- Related docs: `ARCHITECTURE.md`, `docs/FRONTEND.md`, `docs/FLUTTER.md`, `docs/BACKEND.md`, `docs/RELIABILITY.md`
- Related code: `frontend/src`, `admin/src`, `flutter/lib`, `backend/app`
- Related issues: `docs/exec-plans/tech-debt-tracker.md`

## Progress log

| Date | Note |
|------|------|
| 2026-09-22 | Started repository-wide static and automated verification audit. |
| 2026-09-22 | Found admin navigation tests failing because jsdom AbortSignals were incompatible with Node Request; fixed the shared test environment and restored coverage of filters, pagination, auth redirects, and editor navigation. |
| 2026-09-22 | Hardened the web gamification page with content skeletons, friendly error copy, and stale/unmounted request guards; added focused regression tests. |
| 2026-09-22 | Reviewed Flutter loading/error patterns and ran the available harness; the container has no Flutter executable, so mobile runtime verification remains an environment limitation. |
| 2026-09-22 | Backend suite collected 4,308 tests with explicit non-production settings: 4,302 passed, 4 skipped, 2 pre-existing failures (async RPC call-order assertion and environment-sensitive matte performance budget). Re-run 2026-09-23: 4,304 passed, 4 skipped, 0 failed — both failures are flaky/host-dependent and are tracked as TD-115 and TD-116. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-22 | Prioritize reproducible defects over broad speculative refactors. | The repository is large; regression-backed root-cause fixes are safer and independently verifiable. |
| 2026-09-22 | Fix the admin test realm rather than weakening navigation assertions. | The failures shared one root cause: jsdom's AbortSignal was rejected by Node's native Request, so production route behavior was not actually under test. |
| 2026-09-22 | Do not surface raw gamification API errors. | Repository client policy treats backend diagnostics as telemetry-only; stable recovery copy is safer and more actionable. |

## Verification

```bash
./scripts/check_all.sh
(cd frontend && npm run build)
(cd admin && npm run typecheck && npm run build && npm run check:schema)
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-115: make the dashboard-trends RPC-order test assert the RPC set (or explicitly serialize the implementation) rather than relying on concurrent task scheduling order.
- TD-116: calibrate the background-removal performance gate on the supported Python/runtime runner; this host measured ~579 ms against a 400 ms ceiling.

Environment limits (not tracker items): Flutter is unavailable in this container; backend performance timing is host-sensitive; hosted Supabase and paid provider behavior require integration environments.
