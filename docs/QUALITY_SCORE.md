# Quality score

Last updated: 2026-07-22

Grades are honest snapshots for agents: where to be careful, where tests are strong, where docs lag. Update when a domain materially improves or regresses.

Scale: **A** solid · **B** workable · **C** fragile · **D** high risk

| Domain | Grade | Last reviewed | Strengths | Top gaps |
|--------|-------|---------------|-----------|----------|
| Auth / users | B | 2026-07-22 | JWT deps, tests for user resolution | Keep auth-flow doc in sync with code |
| Wardrobe / items | B | 2026-07-22 | CRUD + extraction paths | Edge cases on images/tags |
| Batch AI extract | B+ | 2026-07-22 | Overlap pipeline tests, SSE jobs | Load/ops under large batches |
| Outfits / generation | B | 2026-07-22 | Core flows present | Response model coverage uneven |
| Recommendations | B- | 2026-07-22 | Service + astrology hooks tested partially | Vector path optional/config-sensitive |
| Photoshoot | B- | 2026-07-22 | Service tests | Job UX parity web/mobile |
| Social import | B | 2026-07-22 | Pipeline + XSS-oriented tests | Feature-flagged; ops complexity |
| Subscriptions / Stripe | B | 2026-07-22 | Webhook tests | Full billing matrix not fully graded |
| Web frontend | C+ | 2026-07-22 | Solid structure, lint/build | No formal unit/e2e suite |
| Flutter | B- | 2026-07-22 | Feature modules, CI builds | Deeper architecture docs thin |
| Docs / harness | B | 2026-07-22 | Agent map + checks introduced | Generated schema must stay fresh |
| Infra / CI | B- | 2026-07-22 | Backend lint/test CI | Frontend CI missing; docker-compose vestige vs no-docker rule |

## How to use

- Before large work in a **C/D** domain, read related tests and open an exec plan.  
- After improving a domain, bump the grade and date.  
- Link deferred work to `exec-plans/tech-debt-tracker.md`.
