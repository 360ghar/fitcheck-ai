# Quality score

Last updated: 2026-07-25

Grades are honest snapshots for agents: where to be careful, where tests are strong, where docs lag. Update when a domain materially improves or regresses.

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
| Web frontend | B- | 2026-07-25 | Vitest suite (16 tests), API retry, feature error boundaries, Sentry, global error handlers | No e2e suite yet |
| Flutter | B | 2026-07-25 | 76 tests, offline queue hardening, bounded polling, error zone, Sentry | Architecture docs still thin |
| Docs / harness | B | 2026-07-22 | Agent map + checks introduced | Generated schema must stay fresh |
| Infra / CI | B | 2026-07-25 | Backend + frontend + flutter CI, Sentry on web + mobile | Backend missing sentry-sdk |

## How to use

- Before large work in a **C/D** domain, read related tests and open an exec plan.  
- After improving a domain, bump the grade and date.  
- Link deferred work to `exec-plans/tech-debt-tracker.md`.
