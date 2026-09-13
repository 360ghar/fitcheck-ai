# Plan: PR 15 review follow-up

Status: completed
Started: 2026-08-29
Owner: Codex

## Goal

Validate all 40 inline findings on pull request 15. Fix every confirmed defect
without changing unrelated behavior. Keep the PR branch isolated from the
active checkout.

## Non-goals

- Do not change the active checkout or its uncommitted files.
- Do not implement findings that do not reproduce or contradict the current
  contracts.

## Acceptance criteria

- [x] Record a disposition for all 40 inline findings.
- [x] Add regression coverage for every confirmed defect where practical.
- [x] Pass focused checks for backend, frontend, widgets, Flutter, and the
  architecture checker.
- [x] Push one reviewed follow-up commit to PR 15.

## Context / links

- Related PR: <https://github.com/360ghar/fitcheck-ai/pull/15>
- Related code: backend MCP and OAuth, web OAuth and gift flows, Flutter
  client reliability, widgets, and architecture checks.

## Progress log

| Date | Note |
|------|------|
| 2026-08-29 | Collected 40 inline findings and created an isolated worktree. |
| 2026-08-29 | All 40 findings reproduced or merged into a duplicate root cause; fixes and regressions completed. |
| 2026-08-29 | Full backend, frontend, admin, widget, Flutter, architecture, and documentation checks passed. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-29 | Validate by scenario and tests before changing code. | Review comments can be stale or incomplete. |
| 2026-08-29 | Keep OAuth redirects at origin and path boundaries. | Raw prefix checks permit lookalike redirect URIs. |
| 2026-08-29 | Move first-login profile creation inside the cache single-flight loader. | Concurrent OAuth requests must not each provision a user profile. |

## Finding dispositions

All findings were valid. Duplicate comments are grouped with their shared
root cause below.

| PR finding IDs | Confirmed defect and remedy |
|---|---|
| 3887961292, 3887961306, 3887961324, 3887961329, 3887961406, 3887961412, 3887961413 | OAuth bridge now uses hydrated app tokens as a fallback; redirects use parsed origin/path boundaries; scopes, expiry, concurrent completion, and direct OAuth error responses are enforced. |
| 3887961295, 3887961301, 3887961304, 3887961337, 3887961338, 3887961395 | Account deletion now enumerates owned storage; the profile cache supports negative entries and retries a load invalidated during an in-flight request; provisioning shares the same single-flight lock. |
| 3887961326, 3887961328, 3887961342, 3887961375 | Gift admin transitions and entitlement revocation now use one database RPC; stale claim-page responses are ignored; API error messages are normalized safely. |
| 3887961319, 3887961334, 3887961345, 3887961354, 3887961366, 3887961371, 3887961373, 3887961390, 3887961392, 3887961396, 3887961403 | MCP widgets parse each API response shape and image arrays; CSP field names/origins, tool naming, form denylisting, SSE resume, forwarded client IP, weather text, and architecture checks are corrected. |
| 3887961317, 3887961322, 3887961332, 3887961349, 3887961357, 3887961361, 3887961368, 3887961382, 3887961388, 3887961399, 3887961414 | Flutter now preserves definitive referral failures, serializes preference writes, validates image sizes, loads a full outfit-picker wardrobe, resets stale image fallback state, clears match loading, restores pagination, parses quoted env values, processes login referrals, and blocks restore during checkout. |
| 3887961411 | Product text-only image prompts no longer prohibit caller-requested shadows or gradients. |

## Verification

```bash
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd backend && pytest --no-cov -q --disable-warnings
cd frontend && npm run lint && npm test -- --run && npm run build
cd admin && npm run lint && npm run typecheck && npm test -- --run && npm run check:schema
cd widgets && npm run build
cd flutter && flutter test --reporter compact
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- None.
