# Flutter full-app bug sweep

Branch: `fix/full-bug-sweep-241` · Started 2026-08-21 · Spec: `~/.factory/specs/2026-08-21-flutter-full-app-bug-sweep-all-severities.md`

Baseline at start: `flutter analyze` clean, `flutter test` 235/235 pass.

## Session 1 — Critical + High

- [ ] S1.1 [critical] `subscription_controller.dart:189-201` purchase-stream listener dies if a handler throws → try/catch per update + stream `onError`; tests for both
- [ ] S1.2 [high] `subscription_controller.dart:503-557` duplicate purchase updates re-verify → transactionId dedupe set; test: same tx twice verifies once
- [ ] S1.3 [high] `core/network/api_interceptors.dart` refresh single-flight clobbered by racing callers → conditional null (`== f`)
- [ ] S1.4 [high] `api_interceptors.dart:70-76` 401-replay of consumed FormData throws → skip retry when `data is FormData`
- [ ] S1.5 [high] `register_page.dart:446-455` Google button double-tap launches two OAuth flows → gate on `isGoogleSigningIn`
- [ ] S1.6 [high] `wardrobe_controller.dart` / `outfit_list_controller.dart` failed pull-to-refresh wipes list to fake empty state → preserve old list until success; tests

Commit: `fix: harden IAP verification, token refresh, and list-refresh failures`

## Session 2 — Mediums (auth/shell/settings/profile/dashboard)

- [ ] S2.1 auth_controller ever-worker double pipeline during credential flows → suppress worker while credential flow drives
- [ ] S2.2 logout leaves MainShellController tab state (permanent:true) → reset index/tabs on logout
- [ ] S2.3 Enter-key double-submit in login/register/forgot_password handlers → isLoading guard
- [ ] S2.4 profile_edit optional birth fields can't be cleared → explicit clear sentinel
- [ ] S2.5 avatars lack storagePath/remintUrl (dashboard header, profile card, profile edit)
- [ ] S2.6 thumbnail_url unused in dashboard models/activity feed/outfit-of-day tiles
- [ ] S2.7 settings FilterChips don't toggle visually → reactive local selection committed on Done
- [ ] S2.8 theme change not rolled back on save failure
- [ ] S2.9 failed logout silent → error snackbar
- [ ] S2.10 referral pending code retried forever on definitive 4xx
- [ ] S2.11 dashboard pull-to-refresh no in-flight guard → shared future
- [ ] S2.12 AuthMiddleware dead branch removal

## Session 3 — Mediums (photoshoot/social/gamification/feedback/calendar/lists)

- [ ] S3.1 refreshStoreProducts race/no isClosed guard
- [ ] S3.2 restorePurchases spinner clears before restore completes → isRestoring
- [ ] S3.3 photoshoot download missing auth headers (worker mode fails) → authHeadersForUrl
- [ ] S3.4 progress divisor wrong vs actual total count
- [ ] S3.5 retryFailedSlot re-encodes all photos per retry → cache encodings
- [ ] S3.6 shared_outfit_page network error renders as "Outfit not found" → distinct error+Retry
- [ ] S3.7 gamification fabricated "30 days" milestone when nextMilestone null → hide block
- [ ] S3.8 feedback pickImage/takePhoto no permission-denial path → PermissionHelper pattern
- [ ] S3.9 outfit detail wear-history infinite retry loop
- [ ] S3.10 calendar linkOutfit double-pop ejects user → remove controller Get.back()
- [ ] S3.11 load-more fires during in-flight refresh (wardrobe+outfits) → guard
- [ ] S3.12 FindMatches stale-response race → generation counter
- [ ] S3.13 item pickers truncate at 100 items (tryon picker, outfit builder, recommendations)

## Session 4 — Lows, batched

Core infra:
- [ ] viewer status-bar restore respects dark mode · temp-thumbnail pruning · SSE yield/rethrow double-signal · SSE premature close retryable · SSE Last-Event-ID resume + per-attempt token · env config logging/validation + inline-comment stripping + PAYWALL file fallback · public-endpoint segment matching · postWithExtendedTimeout preserves extra · code-push _announced ordering · ai-consent cache · image_utils raw-fallback size cap

Auth/settings/profile:
- [ ] fenix duplicate registration cleanup · referral stash edge on launch failure · help-page chat label · legal/auth URL clipboard fallback · weather unit label honors preference

Photoshoot/social/gamification/feedback:
- [ ] quota string-sniffing → structured codes · picker catch-all vs real permission check · hide-content try/catch · gamification telemetry + rank from backend + username guard · deviceInfo jsonEncode · ticket pagination

Wardrobe/outfits/calendar/recommendations:
- [ ] delete keeps scroll position · filter-violating inserts guarded · createdItems cleared in reset · grid prefers primary image · primary-first ordering · tryon avatar remint · calendar initState double-fetch · weather default-temp unit mismatch · score-scale verify · dead code removal (checkDuplicates, getGenerationStatus, generateProductImagesForItems)

## Process

Each session ends with: `cd flutter && flutter analyze && flutter test` green, then commit(s). False positives noted here and skipped.
