# Plan: Fix PR #9 regressions

Status: completed  
Started: 2026-07-31  
Owner: agent

## Goal

Close the confirmed billing, entitlement, AI reliability, image-processing,
campaign-script, frontend, SEO, calendar, accessibility, and Flutter regressions
identified while reviewing PR #9. Preserve existing new-customer Stripe Checkout
behavior while updating existing subscriptions in place.

## Non-goals

- Auditing or automatically cancelling historical duplicate Stripe subscriptions.
- Introducing Docker or local Supabase development.
- Changing unrelated pre-existing technical debt.

## Acceptance criteria

- [x] Paid subscription changes update an existing Stripe subscription instead of creating a duplicate.
- [x] Expired, cancelled, and past-due plans no longer receive paid quotas/features.
- [x] AI, social discovery, reference-image, campaign, and matte failures have bounded, tested behavior.
- [x] Web, Flutter, calendar, SEO, accessibility, and editor regressions are fixed.
- [x] Backend, frontend, Flutter, architecture, docs, theme, and diff checks pass.

## Context / links

- PR: `https://github.com/360ghar/fitcheck-ai/pull/9`
- Related code: `backend/app/services/subscription_service.py`, `backend/app/api/v1/subscription.py`, `backend/app/services/ai_provider_service.py`, `frontend/src/components/wardrobe/`, `flutter/lib/app/themes/`

## Progress log

| Date | Note |
|------|------|
| 2026-07-31 | Started from branch `8b129aa`; preserved pre-existing untracked `video.mp4`. |
| 2026-07-31 | Implemented backend billing/entitlement, AI, image, social, campaign, backfill, and calendar fixes with regression coverage. |
| 2026-07-31 | Implemented web accessibility, editor, pricing/auth, SEO, calendar, lightbox, and responsive-layout fixes. |
| 2026-07-31 | Implemented Flutter dark-theme and direct-subscription-update client support with generated model updates and tests. |
| 2026-07-31 | Verified: backend 590 passed; frontend lint/build and 43 tests passed; Flutter analyze and 92 tests passed; architecture/docs/diff checks passed. |
| 2026-07-31 | Second-pass review fixed cached-image recovery and stale-editor timing windows, added explicit focus rings to custom controls, tightened campaign eligibility/documentation, and hardened malformed AI payload handling. Final verification: backend 598 passed; frontend lint/build and 50 tests passed; Flutter analyze and 92 tests passed; architecture/docs/diff checks passed. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-31 | Modify existing Stripe subscriptions in place | Prevents duplicate billing and avoids requiring Stripe Portal configuration. |
| 2026-07-31 | Paid entitlement requires active/trial status and an unexpired period | Makes backend quota/access decisions fail closed when billing state is stale. |
| 2026-07-31 | Keep up to the configurable 100 outfit items but cap stored image references at 12 | Preserves large flat-lay inventories while bounding provider payload and memory. |

## Verification

```bash
cd backend && .venv/bin/pytest -q
python scripts/check_architecture.py
python scripts/check_docs_structure.py
cd frontend && npm run lint && npm run build
cd frontend && npm test -- --run
cd flutter && flutter analyze && flutter test
git diff --check
```

All listed checks passed on 2026-07-31.

## Deferred debt

- Historical duplicate Stripe subscriptions require a separate operator audit.
