# App Store Submission Checklist — FitCheck AI

> Source of truth for paste-ready ASC fields: `docs/store/app-store-listing.md`.
> This checklist tracks status for launch on branch `ios-app-store-launch`.

## App Information

| Field | Value |
|---|---|
| App Name (ASC) | FitCheck AI: Wardrobe Stylist |
| Display name (device) | FitCheck AI |
| Bundle ID | `com.fitcheckaiapp.fitcheckai` |
| Version | 1.0.3+5 |
| Primary Language | English (U.S.) |
| Category | Lifestyle / Photo & Video |
| Support Email | support@fitcheckaiapp.com |
| Support URL | https://fitcheckaiapp.com/support |
| Privacy Policy | https://fitcheckaiapp.com/privacy |
| Terms of Service | https://fitcheckaiapp.com/terms |
| Team ID | `HMWGCVU4SV` |

> **The `: Wardrobe Stylist` suffix on the ASC name is required for App Store uniqueness, not optional.**
> A bare "FitCheck AI" (or "FitCheck AI App") collides with an existing app — ASC rejects it with
> "The app name you entered is already being used." Do not strip the suffix. If the full string also
> collides at submit time, try `FitCheck AI: Closet & Try-On`, then `FitCheck AI Studio`. The device
> display name (`CFBundleDisplayName = FitCheck AI`) is separate and unchanged — home-screen names have
> no uniqueness rule. See `docs/store/app-store-listing.md` §1.

---

## Code readiness (done in repo)

### Native / config

- [x] Bundle ID set to `com.fitcheckaiapp.fitcheckai`
- [x] Camera / photo library usage descriptions in `Info.plist`
- [x] `NSPhotoLibraryAddUsageDescription` for saving generated images
- [x] `ITSAppUsesNonExemptEncryption` = false (standard HTTPS)
- [x] `PrivacyInfo.xcprivacy` present
- [x] Sign in with Apple entitlement (`Runner.entitlements`)
- [x] `ExportOptions.plist` team ID set

### Auth & compliance

- [x] Sign in with Apple implemented (required with Google sign-in)
- [x] Account deletion in Settings → Delete Account
- [x] Data export path available
- [x] AI third-party processing consent before first AI use
- [x] UGC report flow on shared outfits / generated images
- [x] Hide shared outfit content on-device (Guideline 1.2)
- [x] Subscriptions sold through Apple In-App Purchase only (`in_app_purchase` plugin; no Stripe/other purchase mechanism reachable from iOS)
- [x] In-App Purchase entitlement (`com.apple.InAppPurchase`) in `Runner.entitlements`
- [x] "Restore Purchases" button on the Subscription page
- [x] Store-billed subscriptions show "Manage in Store" (no in-app cancellation of store billing)
- [x] `PAYWALL_ENABLED=false` dart-define available to strip all monetization CTAs from a build (App Review fallback)
- [x] No AI provider API keys in the client (backend-only)

### Legal web pages (deploy frontend to go live)

- [x] Privacy Policy names OpenAI, Supabase, PostHog, Sentry
- [x] Privacy Policy describes in-app account deletion
- [x] Terms cover UGC reporting / free iOS v1 pricing
- [x] Public `/support` page added (must be deployed)

### Build / CI

- [x] `flutter/scripts/build_ios_release.sh` production dart-defines + Sentry
- [x] `.github/workflows/build-ios.yml` uses Team ID `HMWGCVU4SV`
- [x] CI passes production dart-defines and optional `SENTRY_DSN` secret

### Metadata drafts

- [x] Description / subtitle / keywords / promo / release notes synced under `flutter/metadata/`
- [x] Full ASC answers in `docs/store/app-store-listing.md`

---

## External / App Store Connect (owner)

### App Store Connect setup

- [ ] App record created with Bundle ID `com.fitcheckaiapp.fitcheckai`
- [ ] App name, subtitle, description pasted from `docs/store/app-store-listing.md` / `flutter/metadata/`
- [ ] Keywords (max 100 chars, no spaces after commas)
- [ ] Promotional text
- [ ] What's New / release notes
- [ ] Privacy Policy URL + Support URL live after Netlify deploy
- [ ] App Privacy questionnaire (no tracking — see listing doc §2)
- [ ] Age rating (UGC Yes, GenAI Yes — expect ~13+)
- [ ] App icon 1024×1024 uploaded (`flutter/assets/icons/app_icon.png`)
- [ ] Screenshots for iPhone 6.9" and iPad 13" (see `docs/store/app-store-screenshots.md`)
- [ ] Pricing: Free with In-App Purchases
- [ ] App Review contact + demo account credentials

### In-App Purchase (monetization)

- [ ] **In-App Purchase capability** enabled for the app ID in ASC (entitlement already in `Runner.entitlements`)
- [ ] **4 auto-renewable subscription products** created in ASC > Monetization > Subscriptions, matching `APPLE_*_PRODUCT_ID` in backend env:
  - `plus_monthly` / `plus_yearly` / `pro_monthly` / `pro_yearly` (choose the store-facing names; the IDs must match backend env exactly)
- [ ] Prices set per territory; review the "Save X%" yearly badge against actual store prices
- [ ] **App Store Server API key** created (ASC > Users and Access > Integrations > App Store Connect API, "In-App Purchase" permission) and its issuer ID / key ID / `.p8` contents set in backend env: `APPLE_ISSUER_ID`, `APPLE_KEY_ID`, `APPLE_PRIVATE_KEY`
- [ ] **Sandbox tester** created in ASC (Users and Access > Sandbox) for TestFlight sandbox purchases
- [ ] TestFlight sandbox purchase verified end-to-end (buy → backend grants entitlement → renew/expire via App Store Server Notifications)
- [ ] Backend migration `030_mobile_iap.sql` applied on hosted Supabase

### Auth / backend ops

- [ ] Supabase Apple provider enabled for production
- [ ] Demo reviewer account seeded (`backend/scripts/seed_app_store_reviewer.py`)
- [ ] Production API reachable: `https://api.fitcheckaiapp.com`
- [ ] GitHub secrets for signing + ASC API (see `build-ios.yml` header)

### Before Submit for Review

- [ ] Deploy frontend so `/privacy`, `/terms`, `/support` show updated copy
- [ ] `pubspec.yaml` build number (`version: x.y.z+N`) is **strictly greater** than the last upload on App Store Connect (ASC rejected build `7` → repo is at `+8` or higher)
- [ ] Fresh archive after any version bump (old Organizer archives keep old `CFBundleVersion`)
- [ ] Signed IPA uploaded (CI workflow_dispatch or `build_ios_release.sh`)
- [ ] Archive includes UUID-matched framework dSYMs via `ios/generate_missing_dsyms.sh` (fixes Organizer Sentry.framework symbol upload)
- [ ] Optional: Sentry auth secrets set so CI uploads real dSYMs for crash symbolication
- [ ] Build selected for the version in ASC
- [ ] Review notes include working demo account (not placeholders)

---

## Reviewer testing notes (template)

```
APP OVERVIEW
FitCheck AI is an AI-powered wardrobe and personal-styling app. Core AI features
require backend connectivity to https://api.fitcheckaiapp.com and Supabase.

DEMO ACCOUNT
Email:    review@fitcheckaiapp.com   <-- set after seeding
Password: <strong password>          <-- set after seeding

HOW TO TEST
1. Sign in with the demo account (or Sign in with Apple).
2. Wardrobe: browse pre-loaded items; try Add Item + photo.
3. Outfits / Try-On / Photoshoot / Recommendations / Calendar.
4. Shared outfit: open a share link → Report or Hide.
5. Settings → Delete Account is available (use a throwaway user, not this demo).

PRICING
Free to download. Subscriptions (Plus / Pro, monthly and yearly) are sold
through Apple In-App Purchase. Purchases are verified server-side; sandbox
testers can buy at zero cost. See "Restore Purchases" on the Subscription page.

CONTACT
support@fitcheckaiapp.com
```

---

## Common rejection reasons

| Issue | How we address it |
|---|---|
| Missing privacy policy detail | Privacy names AI processors + deletion path |
| Broken Support URL | Dedicated `/support` page |
| Missing SIWA | Implemented + entitlement |
| External payment steering | Purchases go through Apple IAP only on iOS; Stripe is web-only and never launched from the app |
| Subscriptions without restore | "Restore Purchases" button on the Subscription page |
| Empty demo account | Seed script + checklist |
| UGC without report | Report + hide + support email |
| Missing usage descriptions | Info.plist camera/photos |
