# RCA: "Upgrade" under a plan does nothing (Flutter mobile)

Status: active (code + tests landed; store setup is a human ops step below)
Started: 2026-08-05
Owner: agent

## Goal

Tapping "Upgrade" on a plan card (Plus/Pro x Monthly/Yearly) on the
Subscription page must always produce a visible outcome: the store purchase
sheet on success, or a clear message on failure. A tap that silently does
nothing is gone, and dev/sandbox builds can reach the store purchase flow
even before backend product IDs are configured.

## Root cause

`PlanCard`'s Upgrade button calls `SubscriptionController.startCheckout` ->
`_startStorePurchase` (StoreKit / Play Billing on mobile). Every failure
path — store product IDs not published (`productIdFor` returns null), store
query returns no products, billing unavailable, purchase not started, or
any exception — only set `controller.error.value` and reported telemetry.
The Subscription page renders `error.value` in exactly one place: the
load-error card shown only when `subscription.value == null`
(added 2026-08-03). A logged-in user with a valid entitlement (the normal
case) never sees checkout errors: the button flashes the `isCheckingOut`
spinner and returns to normal — no sheet, no snackbar, no message.

Compounding bug: `StoreProductsModelX.productIdFor` fell back to the plan
type as the store product ID only when the store map was *empty*, but the
backend `/plans` endpoint always returns the full map (with `null` values
when the store rail env vars are unset). The fallback was dead code, so
dev/sandbox builds (Xcode StoreKit configuration files, stores mirroring
the plan type) could never resolve a product ID to query.

## Fixes (landed)

- **Every checkout failure is now visible.**
  - Expected config states ("In-app purchases are not available on this
    device.", "This plan is not available for purchase yet.", "This plan is
    not available in the store yet.", "The purchase could not be started.",
    Stripe link missing/unlaunchable, billing portal unavailable) ->
    `ErrorHandler.showValidation` snackbar ("Purchase unavailable"): shown
    to the user, no Sentry noise (config states, not defects).
  - Unexpected exceptions -> `ErrorHandler.showError` (snackbar + Sentry +
    PostHog), replacing the bare `reportError` in the `startCheckout` catch.
  - Same silent-dead-button class fixed for `openManageSubscription` /
    `_launchUrl`.
- **Dev/sandbox fallback restored**: `productIdFor` now treats a store map
  whose entries are ALL null/empty as "no map published" and falls back to
  the plan type (e.g. `plus_monthly`), so Xcode StoreKit config / unset
  backend env still reaches the store. A partially configured rail still
  returns `null` for missing variants (production behavior unchanged).
- **`PlansResponse` now parses `billing_configured`** (backend already
  sends it; reserved for web CTA gating later).
- **Per-card loading state**: only the tapped plan card shows the spinner;
  previously one checkout disabled every card in the tier (both monthly and
  yearly) via the shared `isCheckingOut` flag.
- **Localized store prices now resolve with real product IDs** (found in
  review): `refreshStoreProducts` keyed the price map by store product ID
  (e.g. `com.fitcheckaiapp.fitcheckai.plus.monthly`) while `storePriceFor`
  looked it up by plan type (`plus_monthly`) — the two only matched in dev
  fallback mode where the ID is the plan type. Prices are now keyed by plan
  type via a reverse lookup.

## Code

- `flutter/lib/features/subscription/models/subscription_model.dart` —
  `productIdFor` all-null fallback fix; `PlansResponse.billingConfigured`
  (+ regenerated `.freezed.dart` / `.g.dart`)
- `flutter/lib/features/subscription/controllers/subscription_controller.dart`
  — `checkingOutPlanType` / `isCheckingOutPlan`; snackbar on every checkout
  failure; `showError` in the catch; manage-subscription failures surfaced
- `flutter/lib/features/subscription/views/subscription_page.dart` —
  per-card `isLoading`

## Tests

- `flutter/test/features/subscription/models/subscription_model_test.dart` —
  all-null map falls back to plan type (regression), partial map never
  falls back, `billing_configured` parse + default
- `flutter/test/features/subscription/controllers/subscription_controller_test.dart`
  — unavailable product / unavailable billing surface a snackbar
  (`Get.isSnackbarOpen`) without launching a purchase; only the tapped plan
  shows checkout loading (fetch-gated)

## Verification

```bash
cd flutter && flutter analyze
cd flutter && flutter test            # 131 tests green
cd flutter && dart run build_runner build --delete-conflicting-outputs
python scripts/check_docs_structure.py
```

## Ops / config — sandbox purchase setup (required, human)

The code is fixed, but a store purchase can only succeed once the store
side exists. To test Upgrade in the StoreKit sandbox:

1. **App Store Connect** (manual; blocked on uploading a screenshot when
   creating the subscription group): create the subscription group, then
   the four auto-renewable subscriptions with product IDs per
   `backend/.env.example` (scheme `com.fitcheckaiapp.fitcheckai.<plan>.<period>`).
2. **Backend env**: set `APPLE_PLUS_MONTHLY_PRODUCT_ID`,
   `APPLE_PLUS_YEARLY_PRODUCT_ID`, `APPLE_PRO_MONTHLY_PRODUCT_ID`,
   `APPLE_PRO_YEARLY_PRODUCT_ID` to those IDs, plus `APPLE_ISSUER_ID` /
   `APPLE_KEY_ID` / `APPLE_BUNDLE_ID` (and `APPLE_ENV=sandbox` to verify
   sandbox-first). Sandbox transaction verification with production fallback
   already exists (`backend/app/services/apple_iap_service.py`).
3. **Local sandbox without App Store Connect**: the existing
   `flutter/ios/StoreKit/FitCheck.storekit` (referenced by the Runner
   scheme) already defines the four products with the real
   `com.fitcheckaiapp.fitcheckai.*` identifiers — the app queries exactly
   the ID the backend serves, so set the backend env vars to those
   identifiers and StoreKit Testing resolves them. A `.storekit` file with
   plan-type identifiers (`plus_monthly`, ...) also works through the
   restored fallback when the backend env is unset.
4. Until the env is set, tapping Upgrade shows a clear
   "This plan is not available for purchase yet." snackbar instead of
   doing nothing.

## Progress log

| Date | Note |
|------|------|
| 2026-08-05 | RCA complete: silent checkout failures (error only surfaced when the subscription fetch failed) + dead productIdFor dev fallback. Fix landed: snackbar on every checkout failure, all-null store map falls back to plan type, per-card loading state, `billing_configured` parsed. Analyzer clean; 131 flutter tests green. |
