# Plan: Mobile IAP subscriptions (Apple App Store + Google Play)

Status: active  
Started: 2026-08-01  
Owner: Droid

## Goal

Subscriptions are purchasable through the stores on mobile: Apple In-App Purchase on iOS (StoreKit via `in_app_purchase`) and Google Play Billing on Android, with server-side verification and webhook reconciliation on the backend. Mobile users are never directed to Stripe or any other non-store purchase mechanism (App Store Guideline 3.1.1 / Play policy). Web (React) keeps Stripe checkout.

## Non-goals

- Changing the web purchase flow (Stripe stays).
- Lazily re-verifying stored store transactions on every `GET /subscription` (webhook + post-purchase sync cover the main flows).
- Apple's deprecated `verifyReceipt` endpoint (we use the modern App Store Server API).
- Google Play RTDN setup automation (owner does it in Play Console / GCP).

## Acceptance criteria

- [x] iOS app purchases subscriptions via StoreKit; no Stripe URL is reachable from the iOS app (plan cards call the IAP flow).
- [x] Android app purchases via Play Billing with the same flow.
- [x] Backend verifies every purchase with the App Store Server API / Play Developer API before granting entitlement.
- [x] Store webhooks (App Store Server Notifications V2, Play RTDN) reconcile renewals/expirations/refunds with signature verification + dedupe.
- [x] `/plans` exposes per-variant store product IDs; `subscriptions` rows carry `billing_provider`.
- [x] Store-billed rows refuse Stripe checkout / cancel paths (fail closed).
- [x] "Restore Purchases" available on mobile; store-billed subscriptions show "Manage in Store".
- [x] Backend pytest, ruff, Flutter analyze + test, architecture check all pass.

## Context / links

- Related docs: `docs/BACKEND.md`, `flutter/metadata/app_store_checklist.md`, `docs/store/app-store-listing.md`
- Related code: `backend/app/services/apple_iap_service.py`, `backend/app/services/google_play_service.py`, `backend/app/api/v1/iap.py`, `backend/app/services/subscription_service.py`, `backend/db/supabase/migrations/030_mobile_iap.sql`, `flutter/lib/features/subscription/`
- Guideline: App Store Review Guideline 3.1.1 (In-App Purchase; anti-steering)

## Progress log

| Date | Note |
|------|------|
| 2026-08-01 | Spec approved (App Store Server API chosen; Google Play in scope). Backend services + router + migration + tests done. Flutter IAP flow + tests done. Docs updated. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-01 | Verify with App Store Server API (transaction lookup) instead of legacy verifyReceipt | Modern, per-transaction verification, no shared-secret handling; sandbox fallback for TestFlight. |
| 2026-08-01 | Google Play in scope (not deferred) | User decision: implement Play Billing alongside Apple IAP. |
| 2026-08-01 | Store-billed rows are single-rail: IAP sync overwrites other rails' identity columns; Stripe checkout/cancel fail closed on store-billed rows | Prevents double billing and cross-rail entitlement drift; simplest correct state machine for v1. |
| 2026-08-01 | RTDN push verification via OIDC bearer (audience = Pub/Sub topic); endpoint 401s when `GOOGLE_RTDN_AUDIENCE` unset | Entitlement-granting webhook must fail closed, mirroring the Stripe webhook secret guard. |
| 2026-08-01 | Google OAuth token hand-rolled with `jose` (RS256 JWT → token endpoint) instead of adding `google-auth` | Zero new backend deps; ~30 lines, fully testable without network. |
| 2026-08-01 | App Store transaction lookup tries production then sandbox URL | TestFlight/sandbox purchases 404 on the production API; opposite order would fail for production. |
| 2026-08-01 | `PAYWALL_ENABLED` now defaults to true on all platforms | iOS monetization ships; the dart-define remains the kill switch for review builds. |

## Verification

```bash
cd backend && source .venv/bin/activate && pytest && ruff check .
cd flutter && flutter analyze && flutter test
python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

All passed (one pre-existing failure: `test_wave_b_hardening.py::test_ensure_ai_settings_row_fk_race_returns_friendly_503_and_logs_detail` — belongs to the user's in-flight AI-settings work, untouched by this change).

## Deferred debt

- Lazy server-side re-verification of stored transactions on `GET /subscription` (defense in depth for missed webhooks). → tech-debt-tracker.
- Play RTDN Pub/Sub + App Store Server API key creation are owner-side ops tasks (documented in the checklist, not code).
- TD-031 (no in-app expiry check for paid plans) remains open; store webhooks now downgrade on expiry, but a missed webhook still relies on the cron.
