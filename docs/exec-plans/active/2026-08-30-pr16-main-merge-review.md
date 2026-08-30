# Plan: PR16 main merge and review follow-up

Status: complete
Started: 2026-08-30
Owner: Codex

## Goal

Merge `origin/main` (`eac4815`) into `feat/dashboard-polish`, resolve the
content conflicts without losing dashboard work or main's gift and MCP
changes, and close every valid PR #16 review finding.

## Non-goals

- Push commits, modify PR comments, or deploy.
- Run Docker or local Supabase.

## Acceptance criteria

- [x] The merge has no unresolved paths and `git diff --check` passes.
- [x] Generated OpenAPI, admin API types, and API reference agree.
- [x] Every live Cubic and CodeRabbit inline finding has a disposition and evidence.
- [x] Backend, admin, frontend, docs, architecture, and E2E verification pass.

## Review disposition ledger

The GitHub comments API returned 49 live inline comments at execution time:
40 from Cubic and 9 from CodeRabbit. The earlier count of 28 CodeRabbit
findings did not match the live inline-comment result. The ledger below covers
every returned comment.

| Source and comment IDs | Disposition | Evidence / action |
|---|---|---|
| CodeRabbit 3888199585; Cubic 3888219826, 3888219829 | Fixed | Promo metrics are scoped to the selected page. The page no longer presents an invalid redemption-rate calculation. |
| CodeRabbit 3888199586, 3888199592; Cubic 3888219822, 3888219823, 3888219880 | Fixed | User-detail components use actual counts and translations, synchronize the selected outfit tab, and use plural-safe labels. |
| CodeRabbit 3888199588; Cubic 3888219808, 3888219846 | Fixed | Timeline filtering happens before limiting, is newest-first, and displays `use_case` metadata. |
| CodeRabbit 3888199596; Cubic 3888219838, 3888219852 | Fixed | User-detail errors are visible and trial extension is available only when the authenticated admin has the required permission. |
| CodeRabbit 3888199599; Cubic 3888219798, 3888219819, 3888219849 | Fixed | `060_atomic_admin_user_actions.sql` atomically extends trials from the later of expiry or now and validates integral trial days. |
| CodeRabbit 3888199602; Cubic 3888219836, 3888219839, 3888219863 | Fixed | Funnel sources paginate completely; retention excludes cohorts younger than seven days and labels the mature retention rate. |
| CodeRabbit 3888199603, 3888199607; Cubic 3888219813, 3888219816, 3888219878 | Fixed | Campaign rollback and partial verification return failure status; the sample-size check rejects negative values. |
| Cubic 3888219795, 3888219820 | Fixed | Daily AI-counter clearing is one RPC transaction and targets the current UTC billing period. |
| Cubic 3888219797, 3888219804 | Fixed | Quota responses expose effective extraction, generation, and embedding limits; utilization and remaining quota use the limiting operation. |
| Cubic 3888219818, 3888219837, 3888219856, 3888219867, 3888219859 | Fixed | Shared page headers retain semantic page headings without breaking dense layout; the top bar no longer creates a second page heading. |
| Cubic 3888219824, 3888219841 | Fixed | The user-detail subscription amount is calculated by the server; no client-side inherited-property lookup remains. |
| Cubic 3888219830, 3888219833 | Fixed | User detail includes support tickets and outfit cover images. |
| Cubic 3888219834, 3888219858 | Fixed | Subscription banners and filters share the same status logic; the IAP return flow preserves query state. |
| Cubic 3888219848, 3888219854, 3888219861, 3888219868, 3888219873, 3888219882 | Fixed | Dashboard responses are typed and covered by MSW. Query invalidation is scoped, virtual rows use their actual compact size, JSON helpers have scoped docstrings, and promo tooltips are keyboard accessible. |
| Cubic 3888219876 | Already fixed by main | The merged `BlogIndexPage` retains main's responsive category layout. Tests verify it and the loading/error layout; the branch fixed-height spacer was not restored. |

No live inline comment targeted a component or script deleted by `origin/main`.
Git history shows the branch-added user-detail components and campaign scripts
were never main-owned paths. Their live findings were fixed in place; no deleted
code was restored solely to satisfy an old comment.

## Merge decisions

| Area | Resolution |
|---|---|
| Generated contract artifacts | Regenerated OpenAPI, admin schema types, and API reference from the reconciled backend contract. |
| Dashboard tests | Preserved the branch redirect behavior and updated assertions to use current semantic labels. |
| Admin service and authorization | Combined main's service work with the branch admin operations and preserved both authorization test sets. |
| Blog and sitemap | Kept main's responsive category layout. Sitemap emits `lastmod` only from blog `updated_at` or `date`; static pages omit unverifiable timestamps. |
| Admin test isolation | Disabled file-level parallelism because the process-wide MSW/browser-state lifecycle caused full-suite cross-file failures. |

## Verification

| Command | Result |
|---|---|
| `git diff --check` | Passed. |
| `python scripts/check_architecture.py` | `Architecture check passed.` |
| `python scripts/check_docs_structure.py` | `Docs structure check passed.` |
| `cd backend && source .venv/bin/activate && ruff check .` | `All checks passed!` |
| Focused admin backend tests | `110 passed, 3 skipped` for trial, quota, funnel, retention, and authorization coverage. |
| `cd backend && source .venv/bin/activate && pytest` | `4152 passed, 4 skipped`; total coverage `95.39%`. |
| Campaign script tests | `9 passed`. |
| API artifact generation | OpenAPI export, API-reference generation, and admin schema generation completed; `npm run check:schema` passed. |
| `cd admin && npm run lint && npm run typecheck && npm test -- --reporter=dot && npm run check:schema && npm run build` | Passed; `33` test files and `230` tests passed. |
| `cd admin && npm run e2e` | `14 passed`. |
| `cd frontend && npm run lint && npm test -- --run && npm run build` | Passed; `61` test files and `308` tests passed. |
| Database schema reference generation | Regenerated `docs/generated/db-schema.md` after migration `060`; docs check passed. |

The passing browser-test output still includes non-fatal jsdom canvas and
Recharts sizing warnings. They do not fail a test or production build.

## Progress log

| Date | Note |
|---|---|
| 2026-08-30 | Merged `origin/main` into the working tree and resolved all seven conflicts. |
| 2026-08-30 | Added atomic admin operations, review fixes, generated artifacts, focused regression coverage, and stable admin test execution. |
| 2026-08-30 | Completed full backend, admin, frontend, architecture, docs, and E2E verification. |

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- None.
