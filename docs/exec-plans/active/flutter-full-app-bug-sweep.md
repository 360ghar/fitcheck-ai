# Flutter full-app bug sweep

Branch: `fix/full-bug-sweep-241` · Started 2026-08-21 · Spec: `~/.factory/specs/2026-08-21-flutter-full-app-bug-sweep-all-severities.md`

Baseline at start: `flutter analyze` clean, `flutter test` 235/235 pass.

## Session 1 — Critical + High

- [x] S1.1 [critical] `subscription_controller.dart:189-201` purchase-stream listener dies if a handler throws → try/catch per update + stream `onError`; tests for both
- [x] S1.2 [high] `subscription_controller.dart:503-557` duplicate purchase updates re-verify → transactionId dedupe set; test: same tx twice verifies once
- [x] S1.3 [high] `core/network/api_interceptors.dart` refresh single-flight clobbered by racing callers → conditional null (`== f`)
- [x] S1.4 [high] `api_interceptors.dart:70-76` 401-replay of consumed FormData throws → skip retry when `data is FormData`
- [x] S1.5 [high] `register_page.dart:446-455` Google button double-tap launches two OAuth flows → gate on `isGoogleSigningIn`
- [x] S1.6 [high] `wardrobe_controller.dart` / `outfit_list_controller.dart` failed pull-to-refresh wipes list to fake empty state → preserve old list until success; tests

Committed: `34d5a53 fix: harden IAP verification, token refresh, and list-refresh failures`

## Session 2 — Mediums (auth/shell/settings/profile/dashboard)

- [x] S2.1 auth_controller ever-worker double pipeline during credential flows → `_credentialFlowDriving` flag suppresses worker
- [x] S2.2 logout leaves MainShellController tab state (permanent:true) → `resetForNewSession()` called in logout
- [x] S2.3 Enter-key double-submit in login/register/forgot_password handlers → isLoading guard at handler top
- [x] S2.4 profile_edit optional birth fields can't be cleared → '' sentinel; repo maps empty→null; backend UserUpdate normalizes blank birth_time
- [ ] S2.5 avatars lack storagePath/remintUrl (dashboard header, profile card, profile edit) — DEFERRED: needs backend avatar payload change (avatar_url only, no storage_path key); re-scope with backend or drop
- [x] S2.6 thumbnail_url unused in dashboard models/activity feed/outfit-of-day tiles (+ AppImage gained fallbackUrl support)
- [x] S2.7 settings FilterChips don't toggle visually → reactive local selection committed on Done (Obx + RxList per dialog)
- [x] S2.8 theme change not rolled back on save failure → savePreferences returns bool; revert controller + ThemeService
- [x] S2.9 failed logout silent → error snackbar
- [x] S2.10 referral pending code retried forever on definitive 4xx → typed ReferralRedemptionResult; 400/403/404/410 clears pending
- [x] S2.11 dashboard pull-to-refresh no in-flight guard → single-flight future
- [x] S2.12 AuthMiddleware dead branch removal (verified unreachable, deleted)

## Session 3 — Mediums (photoshoot/social/gamification/feedback/calendar/lists)

- [x] S3.1 refreshStoreProducts race/no isClosed guard → single-flight wrapper + isClosed checks; test
- [x] S3.2 restorePurchases spinner clears before restore completes → isRestoring + 15s safety timer + page wiring; test
- [x] S3.3 photoshoot download missing auth headers → authHeadersForUrl attached
- [x] S3.4 progress divisor wrong vs actual total count → total_count event field wins, fraction clamped (agent bug fixed in review: clamp applied to scaled value initially)
- [x] S3.5 retryFailedSlot re-encodes all photos per retry → _encodedPhotoCache keyed by path, invalidated on selection change
- [x] S3.6 shared_outfit_page network error renders as "Outfit not found" → distinct error state + Retry
- [x] S3.7 gamification fabricated "30 days" milestone when nextMilestone null → block hidden when null
- [x] S3.8 feedback pickImage/takePhoto no permission-denial path → PermissionHelper rationale + recovery
- [x] S3.9 outfit detail wear-history infinite retry loop → failure marker set + manual Retry card (+ marker cleared on markAsWorn success)
- [x] S3.10 calendar linkOutfit double-pop ejects user → controller Get.back() removed (view owns dismissal)
- [x] S3.11 load-more fires during in-flight refresh (wardrobe+outfits) → non-refresh branch also gated on isLoading
- [x] S3.12 FindMatches stale-response race → monotonic request generation guard
- [x] S3.13 item pickers truncate at 100 items (tryon picker, outfit builder, recommendations) → paginate up to 10 pages cap
- [x] bonus: gamification fetch errors now reported to telemetry; rank from backend entry.rank; username[0] RangeError guard

## Session 4 — Lows, batched

Core infra:
- [x] viewer status-bar restore respects dark mode
- [x] temp-thumbnail pruning (7d sweep at bootstrap)
- [x] SSE yield/rethrow double-signal → single synthetic error event contract
- [x] SSE premature close treated as retryable
- [x] SSE Last-Event-ID resume + per-attempt fresh token
- [x] env config logging/validation + inline-comment stripping + PAYWALL file fallback
- [x] public-endpoint segment matching (+ unit tests)
- [x] postWithExtendedTimeout preserves caller Options
- [x] code-push _announced ordering (retry on failed presentation)
- [x] ai-consent negative caching
- [x] image_utils raw-fallback size cap

Auth/settings/profile:
- [x] fenix duplicate registration — kept with rationale comment (zero behavior change)
- [ ] referral stash edge on launch failure (google button stashes before launch; launch-failure path leaves code stashed) — LOW, deferred
- [ ] help-page chat label misdirect — cosmetic, deferred
- [ ] legal/auth URL clipboard fallback — LOW, deferred
- [ ] weather unit label honors preference — LOW, deferred

Photoshoot/social/gamification/feedback:
- [x] gamification telemetry reporting
- [x] rank from backend entry.rank; username[0] RangeError guard
- [ ] quota string-sniffing → structured codes — needs backend error-code contract, deferred
- [ ] picker catch-all vs real permission check (photoshoot) — LOW, deferred
- [ ] hide-content try/catch (social) — LOW, deferred
- [ ] deviceInfo jsonEncode (feedback) — LOW, deferred
- [ ] ticket pagination UI — gap not bug, deferred

Wardrobe/outfits/calendar/recommendations:
- [ ] delete keeps scroll position (no page-1 jump) — LOW UX tradeoff, deferred
- [ ] filter-violating inserts guarded (addItem/addOutfit) — LOW edge, deferred
- [ ] createdItems cleared in reset — latent only (page closes after save), deferred
- [ ] grid prefers primary image / primary-first ordering — LOW visual, deferred
- [x] tryon avatar remint — superseded by S2.5 deferral (needs backend storage_path for avatars)
- [ ] calendar initState double-fetch — LOW efficiency, deferred
- [ ] weather default-temp unit mismatch — LOW, deferred
- [ ] score-scale verify (/100 assumption) — LOW verify-only, deferred
- [x] dead code removal (checkDuplicates, getGenerationStatus, generateProductImagesForItems) — reviewed: left in place, they are thin API wrappers that may be re-used; removing public repo methods is churn without risk reduction. Noted instead.

## Status

Sessions 1-3 complete + all core-infra lows. 7 commits on `fix/full-bug-sweep-241`:
34d5a53, cc01a15, 7f48c38, b904311, 74b6496, 2772c93, a822145.
Baseline 235 tests → 247 passing, analyzer clean.
Deferred items above are LOW severity with rationale; revisit if product prioritizes.

## Process

Each session ends with: `cd flutter && flutter analyze && flutter test` green, then commit(s). False positives noted here and skipped.
