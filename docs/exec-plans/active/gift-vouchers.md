# Plan: FitCheck Pro gift vouchers

Status: implementation complete; production launch gated
Started: 2026-08-27
Owner: Codex

## Goal

Ship web and admin support for paid, complimentary, and admin-issued Pro gift
vouchers. Each voucher has a premium downloadable image, a safe share link,
atomic first-claim redemption, and gift access that coexists with Stripe,
Apple, Google, promo, and referral entitlements.

## Non-goals

- Native Flutter purchase or gift-management screens.
- Recipient email delivery.
- Customer or admin initiated refunds.
- Anonymous voucher creation or redemption.

## Acceptance criteria

- [x] Verified accounts receive permanent one-time allowances of three 1-month,
      one 3-month, and one 12-month complimentary vouchers.
- [x] Paid vouchers use one-time Stripe Checkout at $20, $60, and $200 and are
      issued only after idempotent payment verification.
- [x] First verified claimant wins; self-claim fails; claims can stack without
      a recipient cap; paid value never expires before claim.
- [x] Pro gifts activate or queue without replacing the subscription billing
      row, and Plus members receive the Pro upgrade immediately.
- [x] Web users can create, personalize, download, share, edit, rotate, claim,
      and inspect sent or received gifts.
- [x] Admin users can inspect metrics and voucher history and use explicit,
      audited manual actions without silently destroying paid value.

## Context / links

- Related docs: `docs/PRODUCT_SENSE.md`, `docs/BACKEND.md`,
  `docs/FRONTEND.md`, `frontend/DESIGN.md`
- Related code: `backend/app/services/subscription_service.py`,
  `backend/app/api/v1/subscription.py`, `admin/src/features/subscriptions/`
- Product decision: complimentary vouchers expire six months after issue;
  paid vouchers do not expire; no automatic allowance restoration.

## Progress log

| Date | Note |
|------|------|
| 2026-08-27 | Started implementation from the approved decision-complete plan. |
| 2026-08-27 | Added migration 056, atomic issuance/claim/resolver RPCs, backend APIs, Stripe fulfillment, entitlement overlay, artwork, and readiness checks. |
| 2026-08-27 | Added the responsive customer studio, fragment-safe public claim page, share/download flow, social metadata, and disabled-by-default rollout flag. |
| 2026-08-27 | Added the RBAC-protected admin dashboard, filters, CSV, artwork preview, and audited explicit actions. |
| 2026-08-27 | Verification passed: backend 4,056 passed/4 skipped at 96% coverage; web 290 tests; admin 231 tests; lint, builds, schema, architecture, docs, bundle, and browser checks at 375/768/1440 pixels passed. Production setup remains gated below. |
| 2026-08-27 | Second-pass review fixed recipient/admin credential exposure, raw-table browser access, asynchronous payment recovery, partial refunds and inquiry closure, idempotency races, claim-fragment analytics exposure, complete server CSV export, and UI fallbacks. Added focused regression tests. |
| 2026-08-29 | Review repair: printed claim codes are excluded from session replay; refund and dispute events that precede checkout fulfillment stay retryable. Focused and full backend/frontend checks passed. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-27 | Store gift grants outside `subscriptions`. | Billing-provider webhooks must not erase gift value. |
| 2026-08-27 | Put the claim secret in the URL fragment. | Crawlers, servers, and analytics do not receive fragments. |
| 2026-08-27 | Use the same truthful retail-value artwork for all sources. | Complimentary gifts remain premium without a false payment claim. |
| 2026-08-29 | Treat unmatched gift payment events as retryable. | Stripe event ordering is not guaranteed; checkout fulfillment may not have persisted the payment-intent link yet. |

## Verification

```bash
cd backend && source .venv/bin/activate && ruff check . && pytest
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- Native Flutter gift-management and purchase screens.
- Recipient email delivery.

## Production launch gates

- Apply migration 056 to hosted Supabase.
- Create and configure the three one-time Stripe Prices and webhook events.
- Set the price IDs and a dedicated gift token secret.
- Complete legal review and internal paid/complimentary claim checks.
- Enable backend creation first, then the web and admin flags.
