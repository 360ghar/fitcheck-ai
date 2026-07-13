# App Store Submission Checklist — FitCheck AI

> Source of truth for paste-ready ASC fields: `docs/app-store-listing.md`.
> This checklist tracks status for launch on branch `ios-app-store-launch`.

## App Information

| Field | Value |
|---|---|
| App Name (ASC) | FitCheck AI: Wardrobe Stylist |
| Display name (device) | FitCheck AI |
| Bundle ID | `com.fitcheck.fitcheckAi` |
| Version | 1.0.3+5 |
| Primary Language | English (U.S.) |
| Category | Lifestyle / Photo & Video |
| Support Email | support@fitcheckaiapp.com |
| Support URL | https://fitcheckaiapp.com/support |
| Privacy Policy | https://fitcheckaiapp.com/privacy |
| Terms of Service | https://fitcheckaiapp.com/terms |
| Team ID | `HMWGCVU4SV` |

---

## Code readiness (done in repo)

### Native / config

- [x] Bundle ID set to `com.fitcheck.fitcheckAi`
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
- [x] iOS free v1: paywall / Stripe CTAs gated off (`EnvConfig.paywallEnabled`)
- [x] No AI provider API keys in the client (backend-only)

### Legal web pages (deploy frontend to go live)

- [x] Privacy Policy names Google Gemini, OpenAI, Supabase, PostHog, Sentry
- [x] Privacy Policy describes in-app account deletion
- [x] Terms cover UGC reporting / free iOS v1 pricing
- [x] Public `/support` page added (must be deployed)

### Build / CI

- [x] `flutter/scripts/build_ios_release.sh` production dart-defines + Sentry
- [x] `.github/workflows/build-ios.yml` uses Team ID `HMWGCVU4SV`
- [x] CI passes production dart-defines and optional `SENTRY_DSN` secret

### Metadata drafts

- [x] Description / subtitle / keywords / promo / release notes synced under `flutter/metadata/`
- [x] Full ASC answers in `docs/app-store-listing.md`

---

## External / App Store Connect (owner)

### App Store Connect setup

- [ ] App record created with Bundle ID `com.fitcheck.fitcheckAi`
- [ ] App name, subtitle, description pasted from `docs/app-store-listing.md` / `flutter/metadata/`
- [ ] Keywords (max 100 chars, no spaces after commas)
- [ ] Promotional text
- [ ] What's New / release notes
- [ ] Privacy Policy URL + Support URL live after Netlify deploy
- [ ] App Privacy questionnaire (no tracking — see listing doc §2)
- [ ] Age rating (UGC Yes, GenAI Yes — expect ~13+)
- [ ] App icon 1024×1024 uploaded (`flutter/assets/icons/app_icon.png`)
- [ ] Screenshots for iPhone 6.9" and iPad 13" (see `docs/app-store-screenshots.md`)
- [ ] Pricing: Free
- [ ] App Review contact + demo account credentials

### Auth / backend ops

- [ ] Supabase Apple provider enabled for production
- [ ] Demo reviewer account seeded (`backend/scripts/seed_app_store_reviewer.py`)
- [ ] Production API reachable: `https://api.fitcheckaiapp.com`
- [ ] GitHub secrets for signing + ASC API (see `build-ios.yml` header)

### Before Submit for Review

- [ ] Deploy frontend so `/privacy`, `/terms`, `/support` show updated copy
- [ ] Signed IPA uploaded (CI workflow_dispatch or `build_ios_release.sh`)
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
Free v1 — no in-app purchases or subscriptions on iOS.

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
| External payment steering | Paywall off on iOS |
| Empty demo account | Seed script + checklist |
| UGC without report | Report + hide + support email |
| Missing usage descriptions | Info.plist camera/photos |
