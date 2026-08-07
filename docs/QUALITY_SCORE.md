# Quality score

Last updated: 2026-08-08

Grades are honest snapshots for agents: where to be careful, where tests are strong, where docs lag. Update when a domain materially improves or regresses.

The [user-story ledger](./product-specs/user-story-ledger.md) separates code
evidence from executable verification. These grades do not imply hosted
Supabase, real-provider, Stripe, browser-E2E, or production-load validation.

Scale: **A** solid · **B** workable · **C** fragile · **D** high risk

| Domain | Grade | Last reviewed | Strengths | Top gaps |
|--------|-------|---------------|-----------|----------|
| Auth / users | B | 2026-07-22 | JWT deps, tests for user resolution | Keep auth-flow doc in sync with code |
| Wardrobe / items | B | 2026-07-25 | CRUD + extraction paths, controller DI + tests | Edge cases on images/tags |
| Batch AI extract | B+ | 2026-07-25 | Overlap pipeline tests, SSE jobs, SSE error-path tests | Load/ops under large batches |
| Outfits / generation | B | 2026-07-25 | Core flows present, bounded polling on mobile | Response model coverage uneven |
| Recommendations | B- | 2026-07-22 | Service + astrology hooks tested partially | Vector path optional/config-sensitive |
| Photoshoot | B | 2026-07-25 | Service tests, SSE error-path tests, bounded mobile polling | Job UX parity web/mobile |
| Social import | B | 2026-07-25 | Pipeline + XSS-oriented tests, SSE error events | Feature-flagged; ops complexity |
| Subscriptions / Stripe | B | 2026-07-31 | Webhook tests (incl. Plus activation), plan-limit/entitlement tests | Three tiers live; Stripe Plus price IDs must be set in env |
| Web frontend | B- | 2026-08-08 | 44 Vitest files / 229 test cases, API retry, feature error boundaries, Sentry, global error handlers | No authenticated browser E2E; build writes tracked `public/sitemap.xml` |
| Admin panel | B | 2026-08-08 | Server-enforced RBAC (113 backend admin tests: authz 403s, predicates, CRUD, suspend, refund, audit, dashboards, quotas, revenue trends), 28 Vitest files / 215 app tests (MSW, typed against generated OpenAPI), OpenAPI codegen + CI drift check, audit trail on every mutation, URL-synced table state, i18n + axe in tests | Playwright e2e specs landed (6 files / 8 journeys) but not wired into CI; token-refresh end-to-end verification pending hardening report; hand-written `types.ts` partially superseded by `schema.d.ts`; role-level permissions only (no field-level) |
| Flutter | B | 2026-07-31 | Full Flutter suite (106 tests), offline queue hardening, bounded polling, error zone, Sentry | No `integration_test/` suite; SDK cache must be writable for local verification |
| Docs / harness | B- | 2026-08-08 | Story ledger, architecture/docs/theme checks, conditional repo-wide runner | Curated API/schema docs can drift; unavailable toolchains need explicit follow-up |
| Infra / CI | B- | 2026-07-31 | Backend + frontend + Flutter CI, Sentry on web + mobile | Backend missing `sentry-sdk`; no hosted smoke/load gate; public storage URL debt remains |

## How to use

- Before large work in a **C/D** domain, read related tests and open an exec plan.  
- After improving a domain, bump the grade and date.  
- Link deferred work to `exec-plans/tech-debt-tracker.md`.
- A green unit or static check is boundary evidence only. Run
  `./scripts/check_all.sh` and inspect the ledger before calling a story
  verified.
