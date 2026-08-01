# Plan: Shareable promo codes (free Plus/Pro grants)

Status: active
Started: 2026-08-01
Owner: agent

## Goal

Let the operator roll out **promo codes** that grant Plus or Pro for free for a
fixed number of months, shared as campaign URLs (`/auth/register?promo=CODE`)
so recipients — new or existing users — land on the upgrade page with the code
pre-filled and redeem it in one tap. Redemption writes the standard
`subscriptions` row (`plan_type` + `status='trial'` + `trial_end`), so
entitlement, expiry → free downgrade, and plan limits flow through the existing
`effective_plan_type` machinery with zero new entitlement code.

## Non-goals

- **Flutter** promo input — mobile deep-link + store-billing interplay needs its
  own design; the web shareable URL is the primary rollout vector.
- Promo management **admin UI** — the operator creates codes with the CLI script
  (`backend/scripts/create_promo_code.py`).
- Promo stacking / discounted billing — codes are all-or-nothing free grants,
  one per user, free-plan-only (paid subscribers are never overwritten, same
  rule as `grant_free_pro_month.py` and referral credits).
- Stripe coupon integration — grants write the subscriptions table directly.

## Acceptance criteria

- [x] Migration `031_promo_codes.sql`: `promo_codes` (code unique
      case-insensitively, plan variant, months, max_uses, expires_at, active,
      used_count) + `promo_redemptions` (one per user) + atomic
      `redeem_promo_atomic` RPC with row locks, hardened privileges
      (service_role only), and RLS policies.
- [x] `POST /api/v1/promo/validate` (public) returns validity, plan, months,
      share URL; `POST /api/v1/promo/redeem` (auth) applies the grant and
      surfaces code-level rejections ("expired", "usage limit", "already
      redeemed", "already have an active plan") as friendly messages.
- [x] Missing migration (PGRST202) maps to a friendly retryable 503 with an
      operator-facing log hint naming `031_promo_codes.sql`.
- [x] `backend/scripts/create_promo_code.py` CLI creates codes
      (`--code --plan --months --max-uses --expires`), idempotent, DRY_RUN-safe.
- [x] Web plan page (`SubscriptionPanel`) shows a promo card to **free** users:
      manual entry, inline validation errors, and a redeem banner for valid
      codes; redemption refreshes the subscription so the plan card flips and
      upgrade offers disappear.
- [x] Shared links work for new and existing users: `promo` query param is
      stashed through register/login (incl. Google OAuth via localStorage,
      same pattern as `pending_referral_code`); post-auth navigation lands on
      the plan page (`/profile?tab=plan`) where the code is consumed once,
      pre-filled and validated; register page shows a "will be applied after
      signup" notice.
- [x] Backend tests (`test_promo_service.py`, `test_promo_api.py`,
      `test_promo_scripts.py`) and frontend tests (store actions + panel UI)
      cover success and rejection paths.
- [ ] **Manual (human):** apply `031_promo_codes.sql` to hosted Supabase, then
      create the first code: `cd backend && python scripts/create_promo_code.py
      --code LAUNCH30 --plan pro_monthly --months 1 --max-uses 100`.

## Context / links

- Related docs: `docs/BACKEND.md` (subscriptions), `docs/generated/db-schema.md`
- Related code:
  - `backend/db/supabase/migrations/031_promo_codes.sql` — tables + RPC
  - `backend/app/services/promo_service.py`, `backend/app/api/v1/promo.py`
  - `backend/app/models/subscription.py` — promo request/response models
  - `frontend/src/components/settings/SubscriptionPanel.tsx` — promo card
  - `frontend/src/lib/promo.ts`, `frontend/src/stores/subscriptionStore.ts`
  - `frontend/src/pages/auth/RegisterPage.tsx`, `LoginPage.tsx` — param stashing
- Pattern source: referral codes (`referral_service.py`,
  `redeem_referral_atomic` in `022_wave_b_hardening.sql`).

## Progress log

| Date | Note |
|------|------|
| 2026-08-01 | Implemented backend (migration, service, API, CLI, tests) + web (panel, store, auth pages, tests); regenerated `docs/generated/db-schema.md`. Backend: 670 tests pass, Ruff clean. Frontend: 115 tests pass, lint + build clean. Architecture + docs checks pass. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-01 | Grant via `status='trial'` + `trial_end` instead of a new entitlement field | Reuses `effective_plan_type`; expiry downgrades to free automatically; identical to referral/trial grants. |
| 2026-08-01 | One redemption per user; free-plan-only | Small abuse surface; never overwrites a paying subscriber. |
| 2026-08-01 | Promo card only on the plan page, free users only | Paid users can't redeem anyway; hiding the card avoids a guaranteed error path. |
| 2026-08-01 | Code creation via CLI script, not admin UI | v1 rollout is operator-driven; UI can come later. |

## Verification

```bash
cd backend && source .venv/bin/activate && python -m pytest
cd frontend && npm run lint && npm run build && npx vitest run
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

- Flutter promo input (see Non-goals) — track in `tech-debt-tracker.md` when
  mobile promo links are prioritized.
