# iOS Sandbox Testing Runbook — Subscriptions

**Last updated:** 2026-08-07

Subscriptions do **not** need to be approved — or even submitted — to be tested.
Your own testing and Apple's App Review both run in the **Sandbox**, where
products work as soon as they exist in App Store Connect and are configured
correctly. This runbook is how to prove the buy → upgrade → cancel → restore
loop end to end before submitting.

Companion docs: `docs/store/app-store-listing.md` (§4 review notes, §5 demo
account), `flutter/metadata/app_store_checklist.md` (submission checklist).

---

## 1. Prerequisites that silently break product loading

If products fail to load in Sandbox, the cause is almost always in this list.
The symptom is identical for every one of them: a paywall with prices from the
backend `/plans` fallback and no localized store prices, or "This plan is not
available in the store yet."

| Prerequisite | Where | Why it breaks products |
|---|---|---|
| **Paid Applications Agreement** active | ASC → Business | No agreement, no products, in any environment |
| Banking + tax complete | ASC → Business | Same |
| All 4 products exist with the exact IDs | ASC → Monetization → Subscriptions | The app queries exactly the IDs the backend publishes |
| All 4 in **one** subscription group | Same | Separate groups ⇒ buying Pro while Plus is active creates two live subscriptions and double-charges |
| **Pro ranked above Plus** in the group | Same, drag to reorder | Wrong rank ⇒ "Upgrade" is a *deferred crossgrade*: StoreKit accepts it, charges nothing, and changes nothing until the next renewal. The reviewer sees a button that does nothing |
| Each product has a price and ≥1 localization | Same | An incomplete product never resolves |
| Products at least "Ready to Submit" | Same | Draft products do not resolve |

The four product IDs (must match everywhere — ASC, `FitCheck.storekit`, and the
backend, which now defaults to exactly these):

| Plan | Product ID | Rank |
|---|---|---|
| Pro Monthly | `com.fitcheckaiapp.fitcheckai.pro.monthly` | 1 (highest) |
| Pro Yearly | `com.fitcheckaiapp.fitcheckai.pro.yearly` | 1 |
| Plus Monthly | `com.fitcheckaiapp.fitcheckai.plus.monthly` | 2 |
| Plus Yearly | `com.fitcheckaiapp.fitcheckai.plus.yearly` | 2 |

### Backend prerequisites

Only the three credentials must be set — the product IDs default correctly:

- `APPLE_ISSUER_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY` (App Store Connect API
  key with the **In-App Purchase** permission). Without them every purchase
  registration fails closed and the startup config health check logs an error.
- `APPLE_ENV=production` is correct even for sandbox testing:
  `AppleIAPService.verify_transaction` tries the configured environment and
  then the other one, so a Sandbox transaction verifies against a production
  backend by design. This is required for App Review and is never rejected —
  it is logged with `environment: "Sandbox"` so reviewer/tester activity stays
  distinguishable from real revenue.
- Migration `030_mobile_iap.sql` applied.

### App Store Server Notifications — set BOTH URLs

ASC → Monetization → App Store Server Notifications exposes a **Production
Server URL** and a **Sandbox Server URL** as separate fields. Both must point
at:

```
https://api.fitcheckaiapp.com/api/v1/subscription/apple/notifications
```

Version **V2**.

Missing the *Sandbox* URL is the subtlest failure in this whole document.
Sandbox compresses a month into ~5 minutes, and `effective_plan_type`
(`backend/app/services/subscription_service.py`) gates entitlement on
`current_period_end > now`. Without `DID_RENEW` arriving, a reviewer who buys
Pro Monthly is silently back on Free five minutes later, mid-review.

"Request a Test Notification" arrives as `notificationType: "TEST"` and is
acked with the log line *"Ignoring App Store notification with unrecognized
type"*. That is a successful round trip, not a failure.

---

## 2. Sandbox time compression

| Real duration | Sandbox duration |
|---|---|
| 1 week | 3 minutes |
| 1 month | 5 minutes |
| 2 months | 10 minutes |
| 3 months | 15 minutes |
| 6 months | 30 minutes |
| 1 year | 1 hour |

A sandbox subscription auto-renews a maximum of **6 times**, then expires.
Plan a test session around that: a monthly plan is fully exercised (buy →
renew → renew → … → expire) in about half an hour.

---

## 3. Running a Sandbox build

1. **Create a Sandbox Apple Account** — ASC → Users and Access → Sandbox →
   Test Accounts. Use an email address that is not an existing Apple ID.
2. **Sign in on the device** — Settings → Developer → **Sandbox Apple Account**
   (iOS 16+). This is *not* Settings → App Store; signing the sandbox tester
   into the real App Store burns the account.
3. **Run a development-signed build on a real device**, or install via
   TestFlight. Both use the Sandbox.
   ```bash
   cd flutter && flutter run --release   # or run the Runner scheme from Xcode
   ```
4. Point the app at a backend that has the three Apple credentials set.

---

## 3a. Testing the paywall on the Simulator

**The Simulator has no App Store.** It cannot sign into a Sandbox Apple Account
and cannot fetch real products, so the *only* source of products there is the
local StoreKit configuration file. Without one, `queryProductDetails` errors and
the app shows **"The store couldn't be reached for this plan right now."**

Two separate things have to be true, and missing either produces that error:

1. **Use the `Runner (Local StoreKit)` scheme.** The default `Runner` scheme has
   no StoreKit configuration on purpose — with one attached, every Xcode launch
   produces local transactions the backend cannot verify, which silently breaks
   real sandbox testing. `Runner (Local StoreKit)` is a shared scheme that
   points at `ios/StoreKit/FitCheck.storekit`.
2. **Launch from Xcode, not `flutter run`.** A scheme's StoreKit configuration
   is injected by Xcode at launch. `flutter run` installs and launches through
   its own path and does **not** apply it — the app comes up with no products
   and the same error.

Steps:

```bash
open flutter/ios/Runner.xcworkspace
```
Scheme selector (top bar) → **Runner (Local StoreKit)** → pick a simulator → ⌘R.

> Historical note: the reference used to live on the default scheme with the
> path `../../StoreKit/FitCheck.storekit`. Xcode resolves that path relative to
> the **`.xcodeproj` directory**, so it pointed at `flutter/StoreKit/` — a file
> that does not exist. The configuration was therefore never applied and the
> Simulator always failed with the store-unreachable error. The correct path is
> `../StoreKit/FitCheck.storekit`.

### What the Simulator can and cannot prove

| Works on Simulator | Needs a real device + ASC products |
|---|---|
| Localized prices render on all four cards | Backend verification of the purchase |
| Disclosure, Terms / Privacy links, Restore button | The entitlement actually flipping to Pro |
| The native purchase sheet | Renewal / expiry / refund notifications |
| **The Plus → Pro upgrade sheet**, including proration and immediate-vs-deferred behaviour (this is what `groupNumber` 1 = Pro, 2 = Plus controls) | `cancel_at_period_end` round trip |

Local StoreKit transactions exist only on the device and are invisible to the
App Store Server API, so `GET /inApps/v1/transactions/{id}` 404s. **Expect the
purchase to complete in StoreKit and then fail backend verification** — that is
correct behaviour, not a bug. The transaction is deliberately left unfinished,
so a second attempt at the same product reports "This purchase is still being
processed"; relaunching the app clears it.

Keep the file's four product IDs, prices, and `groupNumber` ranks in sync with
App Store Connect.

---

## 4. The test script

Run all of it. Step 5 is the one App Review exercises and the one that used to
fail silently.

1. **Load** — More → Plan & Billing. Four localized store prices render (not
   the backend fallbacks), the auto-renew disclosure with Terms of Use and
   Privacy Policy links is under the plan cards, and Restore Purchases is
   present. If a price is missing, check the backend logs for
   *"Store product IDs not found"* — that names exactly which IDs the store
   did not recognize.
2. **Buy Plus Yearly** — sign in with the Sandbox account at the StoreKit
   sheet. The row becomes `plan_type=plus_yearly`, `billing_provider=apple`.
3. **Verify server-side** — the backend logs *"Apple transaction verified"*
   with `environment: "Sandbox"`.
4. **Check the entitlement** — `GET /api/v1/subscription` returns the Plus
   plan and its limits.
5. **Upgrade to Pro Monthly** — StoreKit must show an *immediate* upgrade
   sheet (a proration/refund line), not "your plan will change on…". The row
   must flip to `pro_monthly` with a **shorter** `current_period_end` than the
   Plus Yearly one it replaces.
   - If nothing changes: the backend dropped the write. Check for *"Skipping
     stale store snapshot"* in the logs.
   - If StoreKit says the change is deferred: the ASC rank order is wrong
     (§1) — Pro must sit above Plus in the group.
6. **Cancel** — Settings → Apple ID → Subscriptions → cancel. Within a minute
   `DID_CHANGE_RENEWAL_STATUS` sets `cancel_at_period_end = true` and the app
   shows the access-until date.
7. **Re-enable** auto-renew in the same place; the flag clears.
8. **Restore** — delete and reinstall the app, sign in, tap Restore Purchases.
   The Pro entitlement returns.
9. **Renewal** — wait ~5 minutes. `DID_RENEW` arrives on the Sandbox URL and
   `current_period_end` advances. If it does not, the Sandbox Server URL is
   not set (§1).
10. **Expiry** — after 6 renewals the subscription expires; `EXPIRED`
    downgrades the row to free.

---

## 5. Submitting

Create **one** draft submission containing the app version **plus** all four
subscriptions **plus** the subscription group. Subscriptions attached to the
same submission are available to the reviewer in Sandbox and go live when the
app is approved; they do not need to be approved first.

Before hitting Submit:

- Review notes carry the literal path to the upgrade page and a **working**
  demo account (see `docs/store/app-store-listing.md` §4 — the credentials
  there are placeholders until seeded with
  `backend/scripts/seed_app_store_reviewer.py`).
- Optionally attach a short screen recording of the upgrade flow. It is the
  cheapest insurance against an "I couldn't find the feature" rejection.

---

## 6. Troubleshooting

| Symptom | Cause |
|---|---|
| **"The store couldn't be reached for this plan right now"** on the **Simulator** | No StoreKit configuration applied. Use the `Runner (Local StoreKit)` scheme **and launch from Xcode** — `flutter run` does not apply it (§3a) |
| Same message on a **real device** | Not signed into a Sandbox Apple Account (Settings → Developer), or §1 prerequisites incomplete |
| No prices on the paywall | §1 prerequisites; check logs for "Store product IDs not found" |
| "This plan is not available for purchase yet" | `/plans` published a null product ID — the backend override is set to something outside the bundle namespace (the startup health check warns about this) |
| Purchase succeeds, no entitlement | Backend missing `APPLE_ISSUER_ID`/`KEY_ID`/`PRIVATE_KEY`, or the build used the local StoreKit file (§3) |
| "Transaction … was not found by the App Store at https://api.storekit…" (both URLs) | Local StoreKit transaction, or the API key lacks the In-App Purchase permission |
| Entitlement lapses ~5 min after purchase | Sandbox ASSN URL not set (§1) |
| Upgrade button changes nothing | ASC rank order (§1 step 5) |
| "This purchase is still being processed" | A prior purchase failed backend verification and was left unfinished; relaunching the app redelivers and completes it |
