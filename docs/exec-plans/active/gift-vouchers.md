# Plan: FitCheck Pro gift vouchers

Status: implementation complete; production launch gated
Started: 2026-08-27
Owner: Codex

## Goal

Ship web, admin, and native mobile support for Pro gift vouchers. New vouchers
use a named recipient email, have a premium downloadable image and safe share
link, and use atomic first-claim redemption. Gift access coexists with Stripe,
Apple, Google, promo, and referral entitlements.

## Non-goals

- Native Flutter paid purchasing, Stripe Checkout, or external paid CTAs.
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
- [x] New web, mobile, and admin vouchers require recipient name and normalized
      recipient email; legacy link-only vouchers remain claimable.
- [x] The dashboard priority is incoming gift, then free invitation, then
      referral. A gift summary failure leaves referral available.
- [x] Flutter has a native gift inbox and free-invitation route. It supports
      named paid gift claims but never starts paid checkout.

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
| 2026-08-30 | Added migration 061 for normalized named recipients, an indexed incoming-gift summary, an authenticated assigned-claim action, and private recipient matching. |
| 2026-08-30 | Added web/admin recipient fields, dashboard priority cards, and native Flutter free-send/incoming-claim support. |
| 2026-08-30 | Review repair: fixed dashboard referral flashes and stale mobile summaries, expiry and sender-deletion edges in incoming-gift selection, Unicode recipient comparison, malformed Unicode claim credentials, and database enforcement for new recipient emails. Removed claim credentials from artwork and put replacement artwork in a new cache namespace. |
| 2026-08-30 | Final local verification passed: backend 4,165 passed/4 skipped at 95.44% coverage; admin 230 tests; Flutter 271 tests; web lint, tests, and build passed; the flag-enabled admin build, migration, architecture, docs, and diff checks passed. Hosted launch work remains gated below. |
| 2026-08-30 | Enabled gift voucher issuance and web, admin, and Flutter visibility by default. An explicit `false` remains an emergency rollback. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-27 | Store gift grants outside `subscriptions`. | Billing-provider webhooks must not erase gift value. |
| 2026-08-27 | Put the claim secret in the URL fragment. | Crawlers, servers, and analytics do not receive fragments. |
| 2026-08-27 | Use the same truthful retail-value artwork for all sources. | Complimentary gifts remain premium without a false payment claim. |
| 2026-08-29 | Treat unmatched gift payment events as retryable. | Stripe event ordering is not guaranteed; checkout fulfillment may not have persisted the payment-intent link yet. |
| 2026-08-30 | Match new gifts to a verified recipient email. | A link credential alone is not sufficient for a new named voucher. Existing NULL-recipient vouchers retain legacy behavior. |
| 2026-08-30 | Keep mobile gifts free-send and claim only. | Mobile must not open an external payment path for digital voucher sales. |

## Verification

```bash
cd backend && source .venv/bin/activate && ruff check . && pytest
cd frontend && npm run lint && npm test && npm run build
cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema
cd flutter && flutter test
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:

- Recipient email delivery.

## Production launch gates

1. Apply migrations 056 and 061 to hosted Supabase, then verify the tables,
   RPCs, index, and RLS. If 056 portrait cache objects exist, remove them
   after deploying the credential-free artwork layout.
2. Create the three one-time Stripe Prices. Configure Checkout, asynchronous
   payment, refund, and dispute webhook events.
3. Set the price IDs and dedicated gift token secret. Backend creation is
   enabled by default.
4. Build staging admin. Verify /gifts with an account that has gifts.read
   before production deployment.
5. Rebuild and deploy web, admin, and Flutter. Do not set a gift-voucher flag
   to false unless performing a rollback.
6. Run restricted-account paid and complimentary web/mobile claim smoke tests.
