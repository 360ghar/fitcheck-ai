# RCA: "Upgrade" under a plan does nothing (Flutter mobile)

Status: active (code + tests landed; store setup is a human ops step below)
Started: 2026-08-05
Owner: agent

## Goal

Tapping "Upgrade" on a plan card (Plus/Pro x Monthly/Yearly) on the
Subscription page must always produce a visible outcome: the store purchase
sheet on success, or a clear message on failure. A tap that silently does
nothing is gone. (Original goal text also said dev/sandbox builds should
reach the store flow before backend product IDs are configured — superseded
by the follow-up below: an unconfigured rail fails closed by design.)

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
- ~~**Dev/sandbox fallback restored**~~ — reverted same-day, see the
  follow-up below: the plan-type fallback made StoreKit answer every Upgrade
  tap on an unconfigured rail with `storekit_no_response`.
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

## Follow-up 2026-08-05: storekit_no_response on Upgrade (RC + fix)

A test run hit `Store product lookup failed: IAPError(code:
storekit_no_response, source: app_store, message: StoreKit: Failed to get
response from platform., details: null)` on every Upgrade tap. Two defects.

**RC1 — raw platform error leaked to the user.** `IapService.fetchProducts`
threw `IapException('Store product lookup failed: ${response.error}')`, and
`ErrorHandler.extractMessage` returned that string verbatim, so the
"Purchase failed" snackbar showed the raw `IAPError(...)` dump.
`storekit_no_response` is the plugin's StoreKit 2 wrapper throwing when
`Product.products(for:)` resolves **zero products for a non-empty ID list**
(StoreKit 1 throws the same on request failure). Products were absent
because the auto-renewable subscriptions are not created in App Store
Connect yet, and a CLI `flutter run` does not apply the scheme's
`FitCheck.storekit` config.

**RC2 — plan-type fallback guaranteed the error on an unconfigured rail.**
The fallback landed above sent the plan type (e.g. `plus_monthly`) as the
store product ID whenever the backend published an all-null Apple map.
Plan-type strings match nothing in App Store Connect or the repo's StoreKit
configuration file (real IDs `com.fitcheckaiapp.fitcheckai.*`), so that
path always ended in `storekit_no_response` — and it contradicted the
backend's own fail-closed contract (`config_health.py`: "the iOS app shows
'not available for purchase yet'").

**Fixes (landed in this follow-up):**

- `IapException` now extends `AppException` with `errorCode` + `details`;
  `fetchProducts` throws a stable friendly message ("The store couldn't be
  reached for this plan right now. Please try again in a moment.") and keeps
  the raw `IAPError` in `details` / `toString()` for Sentry only, so on
  this lookup path a raw platform error can never reach a user-visible
  string. (The pre-existing purchase-result path — `PurchaseStatus.error`
  in `_handlePurchaseUpdate` — still surfaces `details.error?.message`
  verbatim; unchanged by this PR.)
- The plan-type fallback in `productIdFor` is **removed**: an unconfigured
  store rail returns `null` and the app fails closed with "This plan is not
  available for purchase yet." — the exact behavior `config_health.py` and
  ops step 4 below already promised. StoreKit is never queried with a
  made-up identifier.
- Tests: model tests now assert fail-closed (all-null map -> `null`);
  new `iap_service_test.dart` asserts `fetchProducts` maps
  `storekit_no_response` to a friendly `IapException` (raw text only in
  `details`); controller test asserts the snackbar shows the friendly
  message, never "APError"/"StoreKit", and no purchase is started.

## Code

- `flutter/lib/features/subscription/models/subscription_model.dart` —
  `productIdFor` all-null fallback fix (landed, then **reverted** in the
  follow-up above — the fallback now returns `null`); `PlansResponse.billingConfigured`
  (+ regenerated `.freezed.dart` / `.g.dart`)
- `flutter/lib/features/subscription/services/iap_service.dart` (follow-up) —
  `IapException` extends `AppException` with `errorCode` + `details`;
  `fetchProducts` never interpolates the raw platform error into the message
- `flutter/lib/features/subscription/controllers/subscription_controller.dart`
  — `checkingOutPlanType` / `isCheckingOutPlan`; snackbar on every checkout
  failure; `showError` in the catch passes the exception object so Sentry
  keeps the raw store payload (`IapException.details`); manage-subscription
  failures surfaced
- `flutter/lib/features/subscription/views/subscription_page.dart` —
  per-card `isLoading`

## Tests

- `flutter/test/features/subscription/models/subscription_model_test.dart` —
  all-null map fails closed (returns null), partial map never falls back,
  `billing_configured` parse + default
- `flutter/test/features/subscription/controllers/subscription_controller_test.dart`
  — unavailable product / unavailable billing surface a snackbar
  (`Get.isSnackbarOpen`) without launching a purchase; store lookup failure
  surfaces a friendly message and never the raw StoreKit error; only the
  tapped plan shows checkout loading (fetch-gated); localized price resolves
  by plan type for real product IDs; end-to-end page test (real
  `SubscriptionPage`, real Upgrade button, empty store) asserts the tap
  surfaces the "not available in the store yet" snackbar instead of doing
  nothing
- `flutter/test/features/subscription/services/iap_service_test.dart` (new)
  — `storekit_no_response` maps to a friendly `IapException` (raw detail
  only in `details`); `ErrorHandler.extractMessage` surfaces only the
  friendly message; success path returns product details; empty ID sets
  never touch the platform

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
2. **Backend env**: set `APPLE_ISSUER_ID` / `APPLE_KEY_ID` /
   `APPLE_PRIVATE_KEY` only. **Superseded 2026-08-07:** the four
   `APPLE_*_PRODUCT_ID` vars now default to those exact IDs in
   `backend/app/core/config.py`, so leaving them unset is correct. Sandbox
   transaction verification with production fallback already exists
   (`backend/app/services/apple_iap_service.py`); leave `APPLE_ENV=production`.
   Full procedure: `docs/store/ios-sandbox-testing-runbook.md`.
3. **Local sandbox without App Store Connect**: the existing
   `flutter/ios/StoreKit/FitCheck.storekit` (referenced by the Runner
   scheme) already defines the four products with the real
   `com.fitcheckaiapp.fitcheckai.*` identifiers — the app queries exactly
   the ID the backend serves, so set the backend env vars to those
   identifiers and StoreKit Testing resolves them. Launch from Xcode so the
   scheme applies the `.storekit` file (a CLI `flutter run` may not).
   Plan-type identifiers (`.storekit` files or backend maps that mirror the
   plan type) are **not** supported: the app never queries the store with a
   made-up identifier and fails closed instead.
4. Until the env is set, tapping Upgrade shows a clear
   "This plan is not available for purchase yet." snackbar instead of
   doing nothing.
5. **TestFlight / Release archive builds query the REAL App Store sandbox**
   and ignore `flutter/ios/StoreKit/FitCheck.storekit` entirely (that file
   only applies to an Xcode Debug launch via the scheme). So on a distributed
   build, `storekit_no_response` recurs as long as Apple is not yet serving
   the products: the **Paid Applications Agreement is not Active** (Agreements,
   Tax, and Banking — the #1 silent blocker; products can be "Ready to Submit"
   yet unresolvable until it is signed), the products are still **under review
   / Missing Metadata** (a subscription screenshot + localization are
   required), or no **sandbox tester** account is configured. None of these
   are fixable in code. Resolution order: confirm the Paid Apps agreement is
   Active -> products are fetchable (not Missing Metadata) -> sandbox tester
   created + signed in (Settings > App Store > Sandbox Account) -> reinstall
   the TestFlight build (propagation can take hours). Code-side hardening
   landed anyway: see the progress log below.

## Progress log

| Date | Note |
|------|------|
| 2026-08-05 | RCA complete: silent checkout failures (error only surfaced when the subscription fetch failed) + dead productIdFor dev fallback. Fix landed: snackbar on every checkout failure, all-null store map falls back to plan type, per-card loading state, `billing_configured` parsed. Analyzer clean; 131 flutter tests green. |
| 2026-08-05 | Follow-up: plan-type fallback reverted (it guaranteed `storekit_no_response` on an unconfigured rail); `IapException` extends `AppException` and `fetchProducts` never leaks the raw `IAPError` into user-visible text (raw detail kept for Sentry). Fail-closed behavior restored per `config_health.py` contract. New `iap_service_test.dart` + controller/model regression tests. Analyzer clean; full flutter test suite green. |
| 2026-08-05 | Second follow-up (TestFlight RCA): repro on a TestFlight/Release build. A distributed build queries the REAL App Store sandbox and ignores `FitCheck.storekit`, so `storekit_no_response` ("store couldn't be reached") recurs while the 4 subscriptions are under review, the Paid Apps agreement is not Active, or no sandbox tester is set — none fixable in code. Code hardening landed anyway (improves transient failures, does not fix the TestFlight-under-review case): `fetchProducts` retries a transient `storekit_no_response` (max 2 attempts, 500ms) before throwing, and tags `IapException.details` with the queried IDs; `_startStorePurchase` is now cache-first (reuses the page-load `storeProductDetails[planType]` and only queries the store on a miss, so a transient store error at the tap no longer hard-fails when valid details are on hand). New retry/cache tests + existing tests pinned to `maxRetries: 1`. Real fix = App Store Connect checklist (ops step 5). |
