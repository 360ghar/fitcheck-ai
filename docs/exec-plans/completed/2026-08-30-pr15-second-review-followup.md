# Plan: PR 15 second review follow-up

Status: complete
Started: 2026-08-30
Owner: Codex

## Goal

Validate every finding added after commit `18aeb74` on PR 15, then fix each
confirmed defect with focused regression coverage.

## Non-goals

- Do not alter the active checkout or its uncommitted files.
- Do not change behavior for a finding that does not reproduce.

## Acceptance criteria

- [x] Record a disposition for all 20 new inline findings.
- [x] Add or strengthen focused regressions for confirmed defects.
- [x] Pass backend, frontend, admin, widget, Flutter, architecture, and docs checks.
- [x] Push the reviewed follow-up to PR 15.

## Context / links

- Related PR: <https://github.com/360ghar/fitcheck-ai/pull/15>
- Baseline commit: `18aeb74ad546da5655f82f88ed77edd32ed2eb4e`

## Progress log

| Date | Note |
|------|------|
| 2026-08-30 | Cubic added 20 findings after the first review follow-up. |
| 2026-08-30 | Validated all 20 findings and added focused fixes and regressions. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-30 | Reproduce each new finding before implementation. | The new review includes code, test, and documentation findings. |
| 2026-08-30 | Fix all 20 findings. | Each finding reproduced or had a direct static correctness defect. |

## Finding dispositions

All 20 findings were valid and fixed.

1. `3888290316`, `3888290321`, `3888290349`: restore, full-picker, and
   wardrobe-refresh state races now preserve usable state.
2. `3888290317`, `3888290323`, `3888290324`, `3888290348`, `3888290355`,
   `3888290367`: Flutter parsing, preference persistence, image-limit, and
   referral regressions are covered.
3. `3888290327`, `3888290331`, `3888290334`, `3888290364`, `3888290369`:
   CSP, SSE replay, OAuth redirects, MCP naming, and gift-migration contracts
   now reject or preserve the reported edge cases.
4. `3888290337`, `3888290352`, `3888290358`, `3888290361`, `3888290372`,
   `3888290375`: web test order, generated widgets, test cleanup, setup docs,
   and malformed OAuth-token handling are corrected.

## Verification

```bash
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd backend && pytest
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
cd widgets && npm run build
cd flutter && flutter test --reporter compact
```

Results: all commands passed. Backend: 4,128 passed, 4 skipped, 95.71%
coverage. Frontend: 304 tests. Admin: 231 tests. Flutter: 259 tests.

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- None.
