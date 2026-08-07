# App Store Readiness Review — FitCheck AI (2026-08-05)

Status: complete (code side). Owner actions remain before Submit for Review.
Owner: orchestrator (6-agent parallel review + fix waves)

## Executive verdict

**The codebase is submission-ready on the code side after this review.** Every
`[x]` checkmark in `flutter/metadata/app_store_checklist.md` now verifies true
against the working tree — three were false as implemented (data export
endpoint missing, consent not gated on the single-photo extraction path,
PrivacyInfo.xcprivacy not wired into the Xcode target) and were fixed in this
review. Full harness is green: **141 Flutter tests, 972 backend tests, zero
analyzer issues, architecture/docs/deployment-target checks pass, and a real
`flutter build ios` archive contains the privacy manifest, correct bundle ID,
version 1.0.3 (8), MinimumOSVersion 15.0, and all usage descriptions.**

Remaining blockers before submit are **human/owner actions** (App Store
Connect setup, seeding the demo account, committing the working tree) — listed
in §6. No code-level BLOCKERs remain.

## 1. Checklist verification (code-readiness `[x]` items)

| # | Item | Verdict | Evidence (post-fix) |
|---|---|---|---|
| 1 | Bundle ID `com.fitcheckaiapp.fitcheckai` | VERIFIED | pbxproj:512/696/720 (all 3 configs); built app Info.plist `CFBundleIdentifier` |
| 2 | Camera / photo usage descriptions | VERIFIED | `flutter/ios/Runner/Info.plist:44-49`; confirmed in built bundle |
| 3 | `NSPhotoLibraryAddUsageDescription` | VERIFIED | Info.plist:46-47; built bundle |
| 4 | `ITSAppUsesNonExemptEncryption` = false | VERIFIED | Info.plist:40-41 (truthful: HTTPS-only, no crypto packages beyond SHA-256 nonce) |
| 5 | `PrivacyInfo.xcprivacy` present | **FIXED → VERIFIED** | Was orphaned on disk (not in Xcode target → would not ship, ITMS-91053 risk). Now wired into pbxproj (file ref + Resources phase) and **confirmed inside the built `Runner.app`** with 9 declared data types, tracking=false |
| 6 | SIWA entitlement | VERIFIED | Runner.entitlements + CODE_SIGN_ENTITLEMENTS in all 3 configs; sign_in_with_apple plugin wired end-to-end with nonce exchange (login + register) |
| 7 | ExportOptions.plist team ID | VERIFIED | teamID HMWGCVU4SV; CI generates its own manual/export plist |
| 8 | build_ios_release.sh prod dart-defines + Sentry | VERIFIED | 7 dart-defines incl. SENTRY_DSN, obfuscation + split-debug-info |
| 9 | build-ios.yml Team ID | VERIFIED | env `DEVELOPMENT_TEAM: HMWGCVU4SV` |
| 10 | CI prod dart-defines + SENTRY_DSN | VERIFIED | signed + unsigned paths; .env asset from secrets |
| 11 | Apple IAP only (no Stripe on iOS) | VERIFIED | `in_app_purchase` only; Stripe is `kIsWeb`-gated; tests assert checkoutCalls==0 on iOS; backend `/checkout` rejects store-billed rows |
| 12 | Restore Purchases button | **FIXED → VERIFIED** | Was hidden for Pro/cancelled paid users (inside upgrade section). Now rendered for every mobile user (`subscription_page.dart:75-80`), re-verifies server-side, tests cover Pro path |
| 13 | "Manage in Store" for store-billed | VERIFIED | `isStoreBilled` → manage section → apps.apple.com/account/subscriptions; in-app cancel refused |
| 14 | PAYWALL_ENABLED=false strip | VERIFIED | env_config parse + hard guard in startCheckout + page/CTA gating (photoshoot, extraction, settings) |
| 15 | No AI provider keys in client | VERIFIED | zero matches; only anon Supabase key / PostHog key / Sentry DSN (public by design) |
| 16 | Sign in with Apple implemented | VERIFIED | end-to-end (plugin, entitlement, nonce, both auth screens); Google exists → SIWA mandatory and present |
| 17 | Account deletion in Settings | VERIFIED | Settings → Delete Account → confirm dialog → `DELETE /api/v1/users/me` → storage + vectors + DB cascade + Supabase auth user. **Fixed additionally:** `support_tickets` rows (incl. content reports) and the export archive are now purged with the account |
| 18 | Data export path | **FIXED → VERIFIED** | Was checked but 404 (no endpoint). `POST /api/v1/users/export` implemented: 7 data sections → JSON → deterministic storage key → fresh presigned URL; client unwraps envelope and opens the download; 4 new backend tests |
| 19 | AI third-party consent before first AI use | **FIXED → VERIFIED** | Was enforced on photoshoot/try-on/batch extraction but NOT on the single-photo Add Item flow (the reviewer's first AI step). `ensureConsent('AI Wardrobe Extraction')` now gates `ItemAddController.processImage` before any bytes are read |
| 20 | UGC report flow | VERIFIED | Report sheet on shared outfits + generated images → persisted `support_tickets` (open status); anonymous reporting supported |
| 21 | Hide shared content on-device | VERIFIED | HiddenSharedContentStore persists hides; re-render to "Content hidden" state; report path offered |
| 22 | Privacy policy names OpenAI, Supabase, PostHog, Sentry + deletion | VERIFIED | PrivacyPage.tsx §4/§6; **live URLs match repo** (LIVE-CURRENT) |
| 23 | Terms cover UGC reporting + free iOS v1 pricing | VERIFIED | TermsPage.tsx §4/§6; live = repo |
| 24 | Public /support page | VERIFIED | SupportPage.tsx routed at exact `/support`; live 200 |

## 2. Additional submission-critical checks

- **Version**: `1.0.3+8` — strictly greater than the ASC-rejected build 7; built app reports CFBundleShortVersionString 1.0.3, CFBundleVersion 8.
- **MinimumOSVersion**: 15.0 in all 3 pbxproj configs + Podfile; enforcement script wired into local harness + both CI workflows; passes.
- **StoreKit product IDs**: `com.fitcheckaiapp.fitcheckai.{plus,pro}.{monthly,yearly}` — exact match across `FitCheck.storekit`, checklist table, and `backend/.env.example` (now with literal IDs pasted); single group FITCHECK_SUBSCRIPTIONS; scheme wired.
- **StoreKit checkout correctness**: fail-closed on unconfigured rail (never queries store with made-up ID); every failure surfaces a snackbar (RCA claims all verified); per-card loading; restore re-verifies server-side; completePurchase only after backend verification; purchase stream listened at controller init.
- **App Store Server Notifications**: JWS-verified (ES256 + x5c chain anchored to Apple Root CA G3), deduped via PK ledger, idempotent.
- **App Privacy posture**: no ATT/AdSupport/IDFA anywhere; no ad SDKs; token storage in keychain; release builds can never fall back to localhost; session replay now masks all text/images.
- **EULA / Terms presentation**: signup and login screens link "Terms of service" + "Privacy Policy" (`flutter/lib/features/auth/views/widgets/auth_ui.dart:294-295,331-339`) to the live `https://fitcheckaiapp.com/terms` / `/privacy` URLs (verified 200, content = repo). Owner action: set the ASC custom EULA field to the Terms URL (or keep Apple's standard EULA).
- **iOS build validation**: `flutter build ios --debug --no-codesign` succeeded (Xcode 26.6); bundle contains PrivacyInfo.xcprivacy with all 9 declared types.

## 3. Findings fixed in this review (code)

| Severity | Fix | Where |
|---|---|---|
| BLOCKER | PrivacyInfo.xcprivacy wired into Xcode target (was absent from bundle) | project.pbxproj + verified in built app |
| BLOCKER | `POST /api/v1/users/export` implemented (client 404'd) | backend/app/api/v1/users.py + settings client flow |
| HIGH | App Store webhook ignored `notificationType`: DID_FAIL_TO_RENEW / PRICE_INCREASE downgraded active subscriptions to free | backend/app/api/v1/iap.py + 3 new tests |
| HIGH | Consent gate added to single-photo AI extraction | item_add_controller.dart |
| HIGH | Body measurements (Other User Content) added to privacy manifest | PrivacyInfo.xcprivacy |
| HIGH | Session replay masking (maskAllTexts/Images = true) | analytics_service.dart |
| MEDIUM | Restore Purchases now visible to Pro/cancelled paid users | subscription_page.dart |
| MEDIUM | Purchase-error path no longer leaks raw platform text; friendly message + Sentry keeps details | subscription_controller.dart |
| MEDIUM | Cross-card checkout re-entry guard | subscription_controller.dart |
| MEDIUM | /cancel rejects store-billed rows server-side | subscription.py + test |
| MEDIUM | support_tickets + export archive purged on account deletion | users.py + test |
| MEDIUM | Settings → Change Password routed to Supabase updateUser (was 404) | settings_repository/controller |
| MEDIUM | Privacy manifest/ASC answer-sheet lock-step (Device ID, Performance Data rows) | PrivacyInfo.xcprivacy + app-store-listing.md §2 |
| MEDIUM | CI runner macos-14 → macos-15 (Xcode 26 cannot run on macOS 14; ASC requires Xcode 26 builds since 2026-04-28) + comment correction | build-ios.yml |
| MEDIUM | Flutter version drift: CI pinned 3.41.1 vs local/lockfile 3.44.6 → all workflows bumped to 3.44.6 | build-ios.yml, build-apk.yml, flutter-ci.yml |
| LOW | Free-downgrade no longer wipes apple/google transaction identity (webhook resolution) | subscription_service.py |
| BLOCKER* | Keywords 113 chars > ASC 100 limit → trimmed to 97 | app_store_keywords.txt + listing doc |
| MEDIUM | Description doc/txt divergence resolved (txt = source of truth) + wrong char-count claims fixed | app-store-listing.md |
| LOW | Stale checklist version row (1.0.3+5 → 1.0.3+8); stale script header; altool comment; screenshot guide iPad label; .env.example literal IDs | checklist, scripts, docs |

## 4. Remaining findings (accepted / non-blocking / owner)

| Severity | Item | Recommendation |
|---|---|---|
| MEDIUM | No moderation tooling for content reports; Terms claim "review within 24 hours" is unbacked | Build a reports queue (frontend admin or Supabase query + notification) or soften the Terms SLA. Owner decision. |
| MEDIUM | PostHog `$device_id` declared now, but verify the ASC questionnaire mirrors the manifest (Device ID row added to listing §2) | Owner: tick Identifiers → Device ID, Linked, No tracking, Analytics in ASC |
| LOW | `support_tickets` FK remains SET NULL for anonymous tickets (fine); tmp/ generated images TTL-only cleanup | Optional: include `{user_id}/tmp/` in deletion (needs bucket listing) |
| LOW | CI signed build lacks `--obfuscate --split-debug-info` parity with the local script; TestFlight upload step is `continue-on-error` | Add flags + debug-info artifact; add a hard-fail notify step |
| LOW | Committed ExportOptions.plist `destination=upload` + automatic signing vs CI manual/export | Consider `destination=export` for local script; upload via CI |
| LOW | altool deprecated (works on Xcode 26.6 today) | Migrate upload to iTMSTransporter/Transporter |
| LOW | Homepage still says "Web + Android live · iOS waitlist" | Update at launch (owner) |
| NIT | Consent sheet names OpenAI + Gemini now; provider list should be kept in sync with backend config | Ongoing |

## 5. Verification results (final pass)

- `flutter analyze` (full): **No issues found** (0 errors/warnings/infos)
- `flutter test`: **141 passed**
- backend `pytest`: **972 passed, 1 skipped**
- `scripts/check_ios_deployment_target.py`, `check_architecture.py`, `check_docs_structure.py`, `check_all.sh`: **pass**
- `flutter build ios --debug --no-codesign` (Xcode 26.6): **success**; bundle verified (privacy manifest, bundle ID, version, MinimumOSVersion 15.0, usage descriptions, no ATT keys)
- Workflow YAML: all three parse

## 6. Owner actions before Submit for Review (not code)

1. **Commit the working tree** — `scripts/check_ios_deployment_target.py` and `flutter/test/features/subscription/services/` are untracked; CI invokes the script, so a clean checkout fails the deployment-target step until committed. Include all 53 changed files (note: `docs/exec-plans/active/2026-08-05-double-extraction-limits.md` + frontend plan-limit changes are a parallel workstream — confirm intended before committing).
2. **App Store Connect**: create the app record + subscription group + 4 products (IDs in `backend/.env.example`), IAP capability, App Store Server API key + backend env (`APPLE_ISSUER_ID`/`APPLE_KEY_ID`/`APPLE_PRIVATE_KEY` — the 4 product IDs now default correctly and need no env vars), sandbox tester, App Store Server Notifications URL `https://api.fitcheckaiapp.com/api/v1/subscription/apple/notifications`, App Privacy questionnaire (mirror §2 incl. new Device ID row), Age Rating (UGC=Yes, AI=Yes, ~13+), **EULA** (standard or custom = Terms URL; Terms and Privacy are now also linked directly on the paywall per 3.1.2), screenshots (iPhone 6.9" 1320×2868, iPad 13" 2064×2752 — capture script ready), icon (`flutter/assets/icons/app_icon.png` verified 1024 no-alpha).
   - **2a. Hard gate — subscription group and rank order.** All four products in **one** group, with **Pro ranked above Plus**. Wrong rank makes Plus → Pro a deferred crossgrade (StoreKit accepts it, charges nothing, changes nothing until the next renewal — the reviewer sees a dead button); separate groups produce two live subscriptions and a double charge. Editable only while the products are unapproved.
   - **2b. Hard gate — the *Sandbox* App Store Server Notifications URL**, a separate ASC field from Production. Without it no `DID_RENEW` arrives; sandbox compresses a month to ~5 minutes, so the reviewer's entitlement lapses mid-review.
   - Full procedure: `docs/store/ios-sandbox-testing-runbook.md`.
3. **Seed the demo reviewer account** (`backend/scripts/seed_app_store_reviewer.py`) and paste real credentials into ASC Review Notes (replace placeholders in the checklist template).
4. **Backend env on Railway**: Apple IAP vars + Supabase Apple provider enabled; migration `030_mobile_iap.sql` applied.
5. **Paste metadata** from `flutter/metadata/*.txt` (keywords now 97 chars; description = txt version 2,785 chars).
6. **Verify the sandbox purchase loop** end-to-end on a dev-signed device build or TestFlight — buy Plus **Yearly** → upgrade to Pro **Monthly** (must apply immediately and *shorten* `current_period_end`) → cancel → restore → renew. The one flow that cannot be verified from the repo. Script: `docs/store/ios-sandbox-testing-runbook.md` §4.
7. Update homepage "iOS waitlist" messaging at launch.

## 7. What the checklist misses (add for future reviews)

- Post-build assertions: privacy manifest inside the IPA, CFBundleVersion read-back, `codesign -d --entitlements` on the signed archive.
- Manifest ↔ ASC questionnaire diff (enumeration of `NSPrivacyCollectedDataTypes` vs §2).
- Analytics data-minimization audit (replay masking, device ID, traces sampling).
- A hard gate that CI-referenced scripts/tests are committed.
