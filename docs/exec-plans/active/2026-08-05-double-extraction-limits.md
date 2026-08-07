# Plan: Double item extraction limits on all plans

Status: active
Started: 2026-08-05
Owner: agent

## Goal

Double the monthly **item extraction** limit on every plan so users can
digitize more of their wardrobe before hitting the cap:

| Plan | Extractions/mo (before → after) |
|------|---------------------------------|
| Free | 25 → **50** |
| Plus | 100 → **200** |
| Pro  | 200 → **400** |

Only extractions change. Generation, embedding, and photoshoot limits are
untouched. The backend `PLAN_*_MONTHLY_EXTRACTIONS` settings in
`backend/app/core/config.py` are the single source of truth; the frontend
`PLAN_LIMITS` mirror, Flutter model defaults, and marketing/SEO copy follow
them.

## Non-goals

- No change to generation / embedding / photoshoot limits or pricing.
- No schema or migration changes (limits are app-config, not DB columns).
- No store-listing / App Store Connect edits (limits are enforced and
  advertised server-side; the /plans contract publishes the new numbers
  automatically).
- Historical exec-plan records (`2026-07-31-plus-plan.md`) are left as
  point-in-time history.

## Acceptance criteria

- [x] `backend/app/core/config.py`: `PLAN_FREE_MONTHLY_EXTRACTIONS` 25→50,
      `PLAN_PLUS_MONTHLY_EXTRACTIONS` 100→200,
      `PLAN_PRO_MONTHLY_EXTRACTIONS` 200→400.
- [x] `/usage` and `/plans` responses reflect the new numbers (they read the
      settings, so no service/model edits needed).
- [x] Frontend `src/lib/plan-limits.ts` mirror updated (50 / 200 / 400);
      derived bullets, FAQ summary, and SubscriptionPanel follow.
- [x] Hardcoded marketing/SEO copy updated: Hero (`50`), features page
      (`50–400`), intent-pages stats + FAQ (`50` / `50–400`), `seo-content.mjs`,
      `public/llms.txt`.
- [x] Flutter fallback defaults updated (`@Default(50)` for
      `monthlyExtractionsLimit` and `PlanDetailsModel.monthlyExtractions`) and
      codegen regenerated.
- [x] Flutter upgrade-tier display fallbacks updated
      (`subscription_page.dart` `_buildTierRow` `fallbackExtractions`: Plus
      100→200, Pro 200→400) so the "N extractions, M visualizations" copy is
      correct before `/plans` resolves.
- [x] Docs updated: `docs/references/validation.md`,
      `docs/product-specs/overview.md`.
- [x] Verification green: backend pytest, frontend lint + build, flutter test,
      architecture/docs checks.

## Context / links

- Related code: `backend/app/core/config.py` (authoritative limits),
  `backend/app/services/subscription_service.py` + `backend/app/api/v1/subscription.py`
  (consume the settings), `frontend/src/lib/plan-limits.ts` (mirror),
  `flutter/lib/features/subscription/models/subscription_model.dart` (fallback
  defaults).
- Related docs: `docs/references/validation.md`, `docs/product-specs/overview.md`,
  `docs/exec-plans/active/2026-07-31-plus-plan.md` (original limit choices).
- No related issues.

## Progress log

| Date | Note |
|------|------|
| 2026-08-05 | Implemented: backend settings, frontend mirror + marketing/SEO copy, Flutter defaults + codegen, docs. Filed this plan per PLANS.md (cross-app change). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-05 | Only the extraction limit changes, doubled on all three plans | Explicit ask; keeps plan ordering (Free < Plus < Pro) intact and preserves the existing pricing/entitlement structure. |
| 2026-08-05 | Update marketing/SEO copy and `llms.txt` in the same change | Those files hardcode the old numbers and would otherwise contradict the live /plans contract. |
| 2026-08-05 | Leave `2026-07-31-plus-plan.md` untouched | Dated exec plans are point-in-time records; rewriting them loses history. |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest                          # subscription tests assert ordering only, still holds (50<200<400)
cd frontend && npm run lint && npm run build
cd flutter && flutter test
python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None.
