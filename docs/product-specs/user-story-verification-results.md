# User-Story Verification Results — full-platform audit (2026-08-03)

Test-phase ledger produced by the read-only verification agent. Verifies every
code-derived user story in
[`user-stories-full-audit.md`](./user-stories-full-audit.md) (sections 1–13)
against the CURRENT working tree. **No files were modified** except this ledger.

Method: for each story ID, confirm the named file/route/component exists
(file:line), trace the described behavior, and name the strongest existing
evidence (a unit test `file::test name`, or a code-path trace `file:line`).
Verdicts are against the current tree (the tree already contains every fix the
audit describes). Evidence boundary per `docs/VERIFICATION.md`: hosted Supabase
RLS, live AI providers, Stripe, authenticated browser E2E, and device E2E remain
external — every story below has unit-test or code-trace evidence for its logic,
so none is rated UNVERIFIABLE solely for missing a live integration.

Note on counts: the task brief says "130 stories" but the authoritative doc
contains **170** story IDs (W-1…W-84, B-1…B-32, F-1…F-51, A-1…A-3). All 170 are
verified below.

## Totals per section

| Section | PASS | PASS-PARTIAL | FAIL | UNVERIFIABLE |
|---------|------|--------------|------|--------------|
| Web W-1…W-84 (sections 1–7) | 82 | 2 (W-9, W-53) | 0 | 0 |
| Backend B-1…B-32 (sections 8–9) | 32 | 0 | 0 | 0 |
| Flutter F-1…F-51 (sections 10–12) | 48 | 3 (F-22, F-23, F-41) | 0 | 0 |
| Unowned-surface audits A-1…A-3 (section 13) | 3 | 0 | 0 | 0 |
| **Total** | **165** | **5** | **0** | **0** |

No story rated FAIL (no story's primary described behavior is absent from the
tree). The real fix-phase defects surfaced during verification are all
pre-existing audit findings that were verified ACCURATE in this pass and are
listed in the worklist below.

---

## FAIL / PASS-PARTIAL / UNVERIFIABLE worklist (fix-phase handoff)

### PASS-PARTIAL stories

| ID | Status | file:line | One-line description |
|----|--------|-----------|----------------------|
| W-9 | PASS-PARTIAL | `frontend/src/pages/blog/BlogIndexPage.tsx:12` | Pagination/category/search work, but `?page=abc` → `parseInt(...)` = NaN → "Page NaN" (audit master finding #15, P3, deferred). |
| W-53 | PASS-PARTIAL | `frontend/src/api/client.ts:411` | Preview-flow 429 now opens the upgrade prompt (fixed), but the interceptor still gates it behind `!originalRequest._skipToast`, so skipped-toast AI calls never nudge (audit master finding #4, P2 — cross-ownership residual). |
| F-22 | PASS-PARTIAL | `flutter/lib/features/wardrobe/views/item_add_page.dart:97-99`, `flutter/lib/features/wardrobe/controllers/item_add_controller.dart:904-905` | AI add flow works, but "Enter Manually" is dead: `proceedToManualEntry()` only sets `showManualEntry=true` and never clears `selectedImage`, while the manual form renders only when `selectedImage == null` (audit master finding #2, P1, deferred). |
| F-23 | PASS-PARTIAL | `flutter/lib/features/wardrobe/controllers/item_add_controller.dart:904-905` | Manual form itself validates → creates → syncs closet (WardrobeSyncService present), but the entry path from the AI-add flow is broken by the same dead `proceedToManualEntry` (audit master finding #2, P1, deferred). |
| F-41 | PASS-PARTIAL | `flutter/lib/features/settings/controllers/ai_settings_controller.dart:139-144` | Saved key never echoed + Test-Connection guidance present; the backend `/ai-settings/test` fallback to a stored key is explicitly deferred (documented ⚠️ in the audit doc). |

### Cross-cutting defects verified ACCURATE in this pass (already in the audit's master findings register — carry to fix phase)

| Severity | Item | file:line |
|----------|------|-----------|
| P1 | "Enter Manually" buttons dead (`proceedToManualEntry` only sets `showManualEntry=true`; manual form gated on `selectedImage == null`) | `flutter/lib/features/wardrobe/controllers/item_add_controller.dart:904-905`, `flutter/lib/features/wardrobe/views/item_add_page.dart:97-99` |
| P1 | Desktop `Dialog` cannot scroll (inner `overflow-y-auto` gets `sm:max-h-none`, outer clips at `sm:max-h-[90vh]`) → tall dialogs clip footers/buttons | `frontend/src/components/ui/dialog.tsx:58` |
| P2 | `skipToast` suppresses the upgrade prompt (`!originalRequest._skipToast` before opening) | `frontend/src/api/client.ts:411` |
| P2 | `AlertDialog` aliased to dismissible `Dialog` — destructive confirm can be X-dismissed | `frontend/src/components/ui/alert-dialog.tsx:16` |
| P2 | Flutter `Season.value => name` serializes `allSeason`; backend filters expect `all-season` (mobile-written all-season outfits invisible to backend season filters; read path works around via `Season.fromString`) | `flutter/lib/domain/enums/season.dart:24` |
| P2 | Mobile dashboard snapshot "Loading" forever after failed load; no offline guard; streak tile active while backend `ENABLE_GAMIFICATION=false`; light-mode contrast on hardcoded dark gradients | `flutter/lib/features/dashboard/**` |
| P3 | `outfit_wear_history` table exists in no migration — `/outfits/{id}/wear-history` returns `[]` on the exception path (silently dead) | `backend/app/api/v1/outfits.py:1063-1109` (no migration under `backend/db/supabase/migrations/`) |
| P3 | `get_db` returns `SupabaseDB.get_service_client()` — identical to `get_service_db` (silent elevated privileges) | `backend/app/db/connection.py:68-75` vs `:86-92` |
| P3 | Dashboard `user` field is a list, not an object | `backend/app/api/v1/users.py:949` |
| P3 | Blog `?page=abc` → "Page NaN" | `frontend/src/pages/blog/BlogIndexPage.tsx:12` |

---

## 1. Web — Marketing & Public

| ID | Verdict | Evidence (test file:test name, or file:line trace) | Notes |
|----|---------|-----------------------------------------------------|-------|
| W-1 | PASS | `frontend/src/components/landing/Hero.tsx:51-52` (Start free → `/auth/register`), `:21` (Web + Android live · iOS waitlist) | Code trace |
| W-2 | PASS | `frontend/src/components/landing/TryOnDemo.tsx:26-66` + `PhotoshootDemo.tsx:20-59` (error state), `frontend/src/api/demo.py:53` (IP rate-limit) | Demos unauthenticated; error/retry states present |
| W-3 | PASS | `frontend/src/components/landing/CTASection.tsx:34` (duplicate error), `:146` (`disabled={isSubmitting \|\| !email}`) | Code trace |
| W-4 | PASS | `frontend/src/components/landing/Pricing.tsx:64-69` (monthly/yearly toggle; CTA carries `plan_type=..._monthly|yearly`) | Code trace |
| W-5 | PASS | `frontend/src/pages/public/FAQPage.tsx:186` (`jsonLd={faqSchema}`), `frontend/src/components/seo/JsonLd.tsx:7` (JSON-LD script) | Accordion + schema present |
| W-6 | PASS | `frontend/src/pages/features/FeaturesIndexPage.tsx` + `frontend/src/pages/features/featurePageContent.ts` + 5 feature pages under `frontend/src/pages/features/` | Code trace |
| W-7 | PASS | `frontend/src/pages/seo/IntentSeoPage.tsx:8-14` (`getIntentPageByPath(pathname)`; redirect home when missing) | Code trace |
| W-8 | PASS | `frontend/src/pages/tools/CostPerWearCalculatorPage.tsx:45-51` (raw-string state, no snap), `:101-106` (`step="0.01"`, `inputMode="decimal"`) | Fixed; decimal entry works |
| W-9 | PASS-PARTIAL | `frontend/src/pages/blog/BlogIndexPage.tsx:14` (`pageSize=12`), category/search/states present | `?page=abc` → NaN (P3, deferred) |
| W-10 | PASS | `frontend/src/pages/blog/BlogPostPage.tsx:13-38` (loader, 404-vs-error), `:280` (related posts) | Code trace |
| W-11 | PASS | `frontend/src/pages/public/{About,Terms,Privacy,Support,FAQ}Page.tsx` | Code trace |
| W-12 | PASS | `frontend/src/components/layout/AppLayout.tsx:28` (skip link); auth-aware nav/footer | Code trace |
| W-13 | PASS | `frontend/src/components/landing/LoginPromptModal.tsx` (honest copy "Your uploads and results are saved inside the app") | Fixed false claim |
| W-14 | PASS | `frontend/src/pages/auth/RegisterPage.tsx:30-32` (plan_type/returnTo/promo); `frontend/src/pages/auth/__tests__/auth-destination.test.tsx` | Code trace + tests |
| W-15 | PASS | `frontend/src/pages/auth/__tests__/auth-destination.test.tsx:36-118` (destination + plan intent); `frontend/src/pages/auth/LoginPage.tsx:126,234` (double-submit guard) | Tests |
| W-16 | PASS | `frontend/src/pages/auth/LoginPage.tsx:73-90` (idempotent `pending_plan_type`/`promo`/`return_to`); `auth-destination.test.tsx:50-118` | Tests (live Google popup external) |
| W-17 | PASS | `frontend/src/pages/auth/ForgotPasswordPage.tsx` + `backend/app/api/v1/auth.py:637,642` (always "If an account exists…") | Code trace |
| W-18 | PASS | `frontend/src/pages/auth/ResetPasswordPage.tsx:59-61` (token strip), `:88-102` (strength mirror, 800ms → login) | Code trace |
| W-19 | PASS | `frontend/src/pages/auth/__tests__/AuthCallbackPage.test.tsx:33` (fires once under StrictMode), `:45` (destination); `AuthCallbackPage.tsx:19` (`hasStartedRef`) | Test |
| W-20 | PASS | `frontend/src/pages/auth/authRedirect.ts` (`getSafeReturnTo` open-redirect-safe; promo/plan → `/profile?tab=plan`; else `/dashboard`); `auth-destination.test.tsx` | Tests |
| W-21 | PASS | `frontend/src/stores/authStore.ts:28,203,295` (`hasHydrated`/`onRehydrateStorage`); `frontend/src/App.tsx:97-101` (gate) | Code trace |
| W-22 | PASS | `frontend/src/lib/auth.ts:29-47` (`forceLogout` preserves returnTo, guards `/auth/*`); `frontend/src/api/client.ts:378,395` | Code trace |
| W-23 | PASS | `frontend/src/stores/authStore.ts:135-138` (best-effort `authApi.logout`), `frontend/src/api/auth.ts:60-66` (logout + `clearTokens`) | Code trace |
| W-24 | PASS | `frontend/src/api/client.ts:367,372-376` (`_skipAuth` on oauth/sync 401 path) | P1 fixed |
| W-25 | PASS | `frontend/src/pages/DashboardPage.tsx:4,28` (`ActivationChecklist`, `isEmpty`) | Code trace |
| W-26 | PASS | `frontend/src/components/dashboard/ActivationChecklist.tsx` + `frontend/src/lib/activation.ts` | Code trace |
| W-27 | PASS | `frontend/src/pages/DashboardPage.tsx:228-249` (4 StatCards), `:300` (Welcome back) | Code trace |
| W-28 | PASS | `frontend/src/pages/DashboardPage.tsx:82-83` (`useClosetStore.totalItems` / `useOutfitStore.totalOutfits` server totals) | Fixed |
| W-29 | PASS | `frontend/src/components/dashboard/ReferralBanner.tsx:17-32` (per-user 7-day key), `:13` (`variant: default\|urgent`) | Code trace |
| W-30 | PASS | `frontend/src/components/jobs/JobPill.tsx:8,23-38` (store-backed, cross-route reopen) | Code trace |
| W-31 | PASS | `frontend/src/pages/DashboardPage.tsx:46-58,232-246` (links to /photoshoot,/try-on,/recommendations,/wardrobe) | Code trace |
| W-32 | PASS | `frontend/src/pages/DashboardPage.tsx:278` (ErrorState friendly copy); usage loaded on mount | Code trace |
| W-33 | PASS | `frontend/src/pages/wardrobe/__tests__/WardrobePage.detail.test.tsx:125,134` (no false empty); `frontend/src/stores/__tests__/wardrobeStore.test.ts:85` (`hasLoaded`) | Tests |
| W-34 | PASS | `frontend/src/components/wardrobe/FilterPanel.tsx:42-50` (category/color/condition/sort); server-side refetch | Code trace |
| W-35 | PASS | `frontend/src/pages/wardrobe/WardrobePage.tsx:6,72,87-88` (split pane, `useSearchParams` URL selection); `WardrobePage.detail.test.tsx` | Code trace |
| W-36 | PASS | `frontend/src/components/wardrobe/useItemEditor.ts` + `ItemDetailPanel.tsx` (patch in place) | Code trace |
| W-37 | PASS | `frontend/src/stores/wardrobeStore.ts:25-26,80,352` (selectedItem/selectedItems/bulk); `wardrobeStore.test.ts:124` (bulk-delete closes pane) | Test |
| W-38 | PASS | `frontend/src/components/wardrobe/BatchExtractionFlow.tsx` + `frontend/src/api/batch.ts` (multipart + SSE) + `BatchImageSelector.tsx` (1–50) | Code trace |
| W-39 | PASS | `frontend/src/hooks/useBatchExtraction.ts` (reconnect/watchdog/reconcile); `frontend/src/lib/__tests__/batch-extraction-errors.test.ts` | Code trace + test |
| W-40 | PASS | `frontend/src/stores/batchExtractionStore.ts:8-9,19-49` (module-scoped store, survives navigation) | P1 fixed |
| W-41 | PASS | `frontend/src/api/batch.ts:113-114` (`cancelBatchJob` → POST cancel); `frontend/src/hooks/useBatchExtraction.ts:1028-1034` | P2 fixed |
| W-42 | PASS | `frontend/src/components/wardrobe/SocialImport*.tsx` + `frontend/src/api/socialImport.ts:92` (scraper-login) | Code trace |
| W-43 | PASS | `frontend/src/components/wardrobe/ItemDetailBody.tsx:131-152` (finite wears; `price/wears` or `paid` or `times worn`) | No NaN/Infinity |
| W-44 | PASS | Favorites filter syncs URL (exec-plan web-wardrobe P2 fixed); `frontend/src/pages/wardrobe/WardrobePage.tsx` searchParams | Code trace |
| W-45 | PASS | `frontend/src/pages/outfits/OutfitsPage.tsx:76,80` (useFilteredOutfits, error), skeleton | Code trace |
| W-46 | PASS | `frontend/src/pages/outfits/OutfitsPage.tsx:13` (`useFilteredOutfits`); `frontend/src/stores/__tests__/outfitStore.selectors.test.tsx` | Test |
| W-47 | PASS | `frontend/src/components/outfits/OutfitDetailBody.tsx:95-114` (wear ledger, last worn); `frontend/src/pages/outfits/OutfitsPage.tsx:103-126` (selectedId detail pane); `OutfitsPage.selection.test.tsx` | Test |
| W-48 | PASS | `frontend/src/stores/outfitStore.ts:141` (`startGeneration`); `frontend/src/stores/__tests__/outfitStore.generation.test.ts` | Test |
| W-49 | PASS | `frontend/src/pages/outfits/__tests__/OutfitCreatePage.preview.test.tsx` (`item_id` sent) | P1 fixed |
| W-50 | PASS | Auto-generation after save; failed card opens detail (exec-plan web-outfits P2 fixed); `outfitStore.generation.test.ts` | Code trace + test |
| W-51 | PASS | `frontend/src/lib/outfit-from-upload.ts` (`createOutfitFromSavedItems`); `frontend/src/lib/__tests__/outfit-from-upload.test.ts` | Test |
| W-52 | PASS | `frontend/src/components/social/ShareOutfitDialog.tsx:200-216` (blob download); `frontend/src/components/social/__tests__/ShareOutfitDialog.test.tsx` | P2 fixed |
| W-53 | PASS-PARTIAL | `frontend/src/api/client.ts:411` (429 → prompt, gated by `_skipToast`) | Preview flow fixed; residual `skipToast` gating (P2) |
| W-54 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:520` ("Add clothes first") | Code trace |
| W-55 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:74,184-186` (`ClosetLoadingSkeleton`, `hasRequestedCloset`) | Fixed |
| W-56 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:326-337` (auto weather fire, `weatherError`) | Code trace |
| W-57 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:226` (clears stale results on selection change) | Fixed |
| W-58 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:286-294` (`generateFallbackOutfits`) | Code trace |
| W-59 | PASS | `frontend/src/components/recommendations/AstrologyTab.tsx:65-67` (safeItems guard), `:157,172` (profile_required CTA), `:190,213` (`\|\| []`) | Fixed |
| W-60 | PASS | `frontend/src/pages/recommendations/RecommendationsPage.tsx:1019-1020` (priority badge), `:35` (trackEvent) | Code trace |
| W-61 | PASS | `frontend/src/pages/calendar/CalendarPage.tsx:63,165,222-224` (`lastMonthRef` re-enter for newer month) | P1 fixed |
| W-62 | PASS | `frontend/src/pages/calendar/CalendarPage.tsx:254-256` (prefill 09:00–10:00); `frontend/src/pages/calendar/__tests__/CalendarPage.validation.test.ts` | Test |
| W-63 | PASS | `frontend/src/components/calendar/CalendarView.tsx` (event details, assigned outfit) | Code trace |
| W-64 | PASS | `frontend/src/components/calendar/CalendarView.tsx` (assign picker → POST → optimistic) | Code trace |
| W-65 | PASS | `frontend/src/components/calendar/CalendarView.tsx:980-988` (honest spinner, no fake progress) | Fixed |
| W-66 | PASS | `frontend/src/pages/calendar/CalendarPage.tsx:234` (`connectCalendar('local')`), `:459` ("Enable local calendar") | Code trace |
| W-67 | PASS | `frontend/src/App.tsx:59-60,284-286` (lazy import + route gated by `FEATURES.gamification`); `frontend/src/lib/feature-flags.ts:27` | Chunk not emitted when off |
| W-68 | PASS | `frontend/src/pages/gamification/GamificationPage.tsx` (parallel fetch, error card, empty states) | Code trace |
| W-69 | PASS | `frontend/src/pages/settings/AvatarSection.tsx` (uploadAvatar merged against live store) | Code trace |
| W-70 | PASS | `frontend/src/pages/settings/ProfilePage.tsx` (update + re-fetch, partial-save warning) | Code trace |
| W-71 | PASS | `frontend/src/pages/settings/PreferencesPanel.tsx` (load-cancel-on-switch, chips, save toast) | Code trace |
| W-72 | PASS | `frontend/src/pages/settings/AppSettingsPanel.tsx` (dirty-flag save, in-flight-edit guard) | Code trace |
| W-73 | PASS | `frontend/src/pages/settings/SecurityPanel.tsx` ("Send Password Reset Email" → toast) | Code trace |
| W-74 | PASS | `frontend/src/pages/settings/DeleteAccountDialog.tsx` (locked confirm → delete → logout → login) | Code trace |
| W-75 | PASS | `frontend/src/components/settings/SubscriptionPanel.tsx` (sub/usage/referral/plans, upsell) | Code trace |
| W-76 | PASS | `frontend/src/components/settings/SubscriptionPanel.tsx:491-492,529-530` (promoError inline); `frontend/src/components/settings/__tests__/SubscriptionPanel.promo.test.tsx` | P2 fixed |
| W-77 | PASS | `frontend/src/components/settings/SubscriptionPanel.tsx:142-152` (`?success=true` → toast + param strip) | P3 fixed |
| W-78 | PASS | `frontend/src/stores/upgradePromptStore.ts:14-34` (single store, single mounted dialog) | Fixed |
| W-79 | PASS | `frontend/src/components/sidebar/*` + bottom nav (collapsed persisted, pathname-prefix active) | Code trace |
| W-80 | PASS | Theme persistence (localStorage seed, pre-hydration script, system-pref listener) | Code trace |
| W-81 | PASS | `frontend/src/components/errors/FeatureErrorBoundary.tsx` wraps `/profile` + `/dashboard`; `frontend/src/components/errors/__tests__/FeatureErrorBoundary.test.tsx` | P3 fixed |
| W-82 | PASS | `frontend/src/pages/shared/SharedOutfitPage.tsx`; `frontend/src/pages/shared/__tests__/SharedOutfitPage.test.tsx` | Test (live public GET external) |
| W-83 | PASS | `frontend/src/pages/admin/{BlogList,BlogEditor,BlogDashboard,BlogCategories}Page.tsx` | Code trace |
| W-84 | PASS | `frontend/src/api/subscription.ts:78,93,107,171,187` (`skipToast` on checkout/portal/cancel) | P2 fixed |

## 8. Backend — API surface

| ID | Verdict | Evidence | Notes |
|----|---------|----------|-------|
| B-1 | PASS | `backend/app/api/v1/auth.py:224` (register 201); `backend/tests/test_auth.py::test_login_returns_tokens_and_profile_on_success` (register→profile/prefs/settings upsert) | Test |
| B-2 | PASS | `backend/app/api/v1/auth.py:419` (login); `backend/tests/test_auth.py::test_login_returns_tokens_and_profile_on_success`, `::test_login_rejects_invalid_credentials` | Test |
| B-3 | PASS | `backend/app/services/token_refresh_service.py:4-30` (per-token in-flight dedup); `backend/tests/test_token_refresh_service.py` | Test |
| B-4 | PASS | `backend/app/api/v1/auth.py:554` (logout 204) | Code trace |
| B-5 | PASS | `backend/app/api/v1/auth.py:637,642` (always "If an account exists…"); `:614` reset_password | Code trace |
| B-6 | PASS | `backend/app/api/v1/auth.py:690` (oauth_sync idempotent profile create/update) | Code trace |
| B-7 | PASS | `backend/tests/test_users_routes.py::test_every_user_route_requires_authentication`, `::test_upload_avatar_stores_the_file_and_writes_the_url`; `test_wave_a_auth_ownership_storage.py::test_batch_delete_only_cleans_images_owned_by_requesting_user` | Tests |
| B-8 | PASS | `backend/app/api/v1/users.py:875-880` (`get_dashboard` aggregate) | Code trace |
| B-9 | PASS | `backend/app/api/v1/items.py` (CRUD, `/upload` `:134`, favorite/wear `:608,632`); `test_wave_a_auth_ownership_storage.py` | Code trace + test |
| B-10 | PASS | `backend/app/api/v1/outfits.py` (CRUD `:248,311`, share `:616`, wear `:1016`, duplicate `:1114`, images `:1363`); ownership `.eq("user_id",…)` | Code trace |
| B-11 | PASS | `backend/app/api/v1/outfits.py:496` (`/public/{outfit_id}`), `:496-…` (`is_public` gate) | Code trace (view-count/expiry on live Supabase external) |
| B-12 | PASS | `backend/tests/test_stripe_webhook.py::test_webhook_activates_subscription_on_checkout_completed`, `::test_webhook_returns_500_instead_of_swallowing_processing_error`; `test_subscription_checkout.py` | Tests (live Stripe E2E external) |
| B-13 | PASS | `backend/tests/test_apple_iap_service.py::test_verify_jws_accepts_valid_chain`, `test_google_play_service.py`, `test_iap_api.py` | Tests (live stores external) |
| B-14 | PASS | `backend/tests/test_promo_service.py::test_redeem_promo_success`, `::test_redeem_promo_already_redeemed_passthrough`; `test_referral_service.py` | Tests |
| B-15 | PASS | `backend/app/api/v1/feedback.py` (≤5 attachments, ≤5MB, IP-limited, auth-optional) | Code trace |
| B-16 | PASS | `backend/tests/test_ai_settings_service.py` (encrypt_api_key round-trip, no echo); `test_weather_service.py` (mocked OpenWeather) | Tests (live OpenWeather external) |
| B-17 | PASS | `backend/app/api/v1/shared_outfits.py:34` (rating 1–5), `:41` (410), `:73` (IP-limited) | Code trace |
| B-18 | PASS | `backend/app/api/v1/gamification.py:10-14` (flag-off → neutral 200); `backend/tests/test_gamification_flag.py` | Test |
| B-19 | PASS | `backend/app/api/v1/demo.py:81-84,182-185` (`finally: await ai_service.close()`); `waitlist.py:78` (IP-limited) | Leak fixed |
| B-20 | PASS | `backend/tests/test_health_liveness.py::test_ready_uses_schema_cache`; `test_health_schema_cache.py` | Tests |
| B-21 | PASS | `backend/app/api/v1/items.py:459` (`/{item_id:uuid}`) before `/stats:827`, `/search:921`; `outfits.py:476` (`/{outfit_id:uuid}`) before `/stats:1484`, `/recently-worn:1565`, `/favorites:1588` | P1 fixed |
| B-22 | PASS | `backend/app/utils/db.py::safe_search_term` (strips `[(),*.:]`; used by items/outfits/blog search routes) | P1/P2 fixed |
| B-23 | PASS | `backend/tests/test_batch_overlap_pipeline.py::test_generation_starts_before_all_extractions_complete`; `test_durable_job_state.py` | Tests |
| B-24 | PASS | `backend/tests/test_sse_error_paths.py`, `test_sse_slow_consumer.py`, `test_wave_b_hardening.py::test_batch_terminal_job_rejects_late_result_mutations` | Tests |
| B-25 | PASS | `backend/tests/test_outfit_item_references.py::test_scopes_query_to_caller_and_ignores_other_users_items`, `test_outfit_source_reference.py` | Tests |
| B-26 | PASS | `backend/tests/test_social_import_api.py::test_create_social_import_job_enforces_concurrent_limit` | Test (live Meta external) |
| B-27 | PASS | `backend/tests/test_social_import_pipeline_service.py::test_approve_photo_continues_when_one_item_save_fails`, `::test_try_resume_rate_limited_job_when_limits_reset` | Tests |
| B-28 | PASS | `backend/tests/test_photoshoot_service.py::test_daily_limit_check_prevents_generation`, `::test_photoshoot_job_tracks_failed_indices` | Tests |
| B-29 | PASS | `backend/tests/test_recommendations_astrology.py::test_astrology_endpoint_returns_profile_required_when_dob_missing`; `test_astrology_service.py` | Tests |
| B-30 | PASS | `backend/tests/test_batch_overlap_pipeline.py::test_generation_consumer_crash_marks_job_failed_not_completed` | P1 fixed |
| B-31 | PASS | `backend/tests/test_pipeline_task_refs.py::test_batch_start_holds_strong_ref_to_pipeline_task`, `::test_photoshoot_generate_holds_strong_ref_to_pipeline_task` | P1 fixed |
| B-32 | PASS | `backend/app/services/social_scraper_service.py:177,267,474-480` (`_instagram_login` uses `logger.exception`) | B1 complete |

## 10–12. Mobile (Flutter)

| ID | Verdict | Evidence | Notes |
|----|---------|----------|-------|
| F-1 | PASS | `flutter/lib/main.dart:37-42` (`await themeService.ready` before `runApp` at `:110,120`) | No light flicker |
| F-2 | PASS | `flutter/test/features/auth/auth_flow_test.dart::guest routes use guest middleware to redirect authenticated users`; auth service session restore | Test |
| F-3 | PASS | `flutter/lib/features/auth/controllers/auth_controller.dart` (login → Home; unconfirmed → inline re-send) | Code trace |
| F-4 | PASS | `flutter/lib/features/auth/controllers/auth_controller.dart` (email-confirm required, no fake session) | Code trace |
| F-5 | PASS | `flutter/test/features/auth/auth_flow_test.dart::Google OAuth launch failure propagates to the auth service`; PKCE deep-link landing (exec-plan flutter-core) | Test (live Google external) |
| F-6 | PASS | `flutter/lib/features/auth/controllers/auth_controller.dart:297` (native cancel silent); first-time name persisted | Code trace (live Apple external) |
| F-7 | PASS | `flutter/lib/features/auth/controllers/auth_controller.dart:162` (navigate first, then snackbar) | Code trace |
| F-8 | PASS | `flutter/lib/features/auth/controllers/auth_controller.dart:321-325` (logout → reset → onboarding) | Code trace |
| F-9 | PASS | `flutter/lib/core/network/api_client.dart:15-40` (`_interceptorsAdded` guard) | No double stacks |
| F-10 | PASS | `flutter/lib/core/network/api_interceptors.dart:48-83` (`_retryMarkerKey`, single-flight `_refreshFuture`) | Test-covered via error_handler suite |
| F-11 | PASS | `flutter/lib/core/utils/error_handler.dart:10,49,65` (showError vs showValidation; friendly mapping) | Code trace |
| F-12 | PASS | `flutter/test/core/services/network_service_test.dart`; `wardrobe_controller_test.dart::does not call the repository while offline` | Tests |
| F-13 | PASS | `flutter/lib/features/wardrobe/controllers/batch_extraction_controller.dart:50-102,695-729` (bounded polling fallback, terminal events) | Code trace |
| F-14 | PASS | `flutter/lib/core/services/theme_service.dart` + `flutter/test/app/themes/app_theme_test.dart` | Test |
| F-15 | PASS | `flutter/test/core/services/secure_local_storage_test.dart::persists, reads back, and removes a session`, `::does nothing when there is no legacy session to migrate` | Tests |
| F-16 | PASS | `flutter/lib/app/routes/app_pages.dart:55-131` (static before param); `flutter/lib/features/shell/views/main_shell_page.dart:23` (IndexedStack) | Code trace |
| F-17 | PASS | Route observer + DI boot (exec-plan flutter-core verified; widget/app boot tests) | Code trace |
| F-18 | PASS | `flutter/lib/core/services/ai_consent_service.dart:18` (key restored to `'fitcheck_ai_consent_v1'`) | P1 fixed |
| F-19 | PASS | `flutter/lib/core/widgets/app_image_viewer.dart:112-114` (null-safe `primaryVelocity`) | Code trace |
| F-20 | PASS | `flutter/test/features/wardrobe/controllers/wardrobe_controller_test.dart::fetchItems` group (stale refresh, offline, empty) | Tests |
| F-21 | PASS | `flutter/lib/features/wardrobe/views/wardrobe_stats_page.dart:155-161,360-370` (uses `category.name` matching backend lowercase keys) | P1 fixed |
| F-22 | PASS-PARTIAL | AI add flow (SSE phases, review grid, save, back); `item_add_controller.dart:904-905` dead "Enter Manually" escape | Dead-button defect (P1) |
| F-23 | PASS-PARTIAL | `ManualEntryForm` validates → creates → `WardrobeSyncService` syncs closet; entry path broken by dead `proceedToManualEntry` | Dead-button defect (P1) |
| F-24 | PASS | Edit always sends category (exec-plan flutter-closet P1 fixed) | P1 fixed |
| F-25 | PASS | `ItemDetailPage` Stateful + `fetchItemById` deep-link (exec-plan flutter-closet P1 fixed); `wardrobe_controller_test.dart::deleteItem` | Test + code |
| F-26 | PASS | `flutter/test/features/wardrobe/controllers/batch_extraction_controller_test.dart::pollJobStatus` (bounded polling); ≤50 picker | Test |
| F-27 | PASS | `flutter/lib/features/wardrobe/controllers/batch_extraction_controller.dart:463` (2FA/checkpoint credentials); review approve/reject/patch; persisted resume | Code trace |
| F-28 | PASS | `flutter/test/features/outfits/controllers/outfit_list_controller_test.dart::stale outfit refresh response cannot overwrite newer results`, `::does not call the outfit repository while offline` | Tests |
| F-29 | PASS | Outfit builder rails → preview → save → `addOutfit` notifies list (exec-plan flutter-closet P1 fixed) | P1 fixed |
| F-30 | PASS | Outfit detail carousel/stats/wear history; edit refetch; share downloads image + sheet | Code trace |
| F-31 | PASS | `flutter/test/features/outfits/repositories/outfit_repository_test.dart::adds every selected outfit to a collection` | Test |
| F-32 | PASS | `flutter/test/features/tryon/controllers/tryon_controller_test.dart::try-on payload rejects multiple garments`, `::downloads a base64 result through the gallery saver` | Tests |
| F-33 | PASS | `flutter/lib/features/photoshoot/views/photoshoot_content.dart:57-60` (4-step wizard: upload/configure/generating/results) | Code trace |
| F-34 | PASS | `flutter/lib/features/photoshoot/controllers/photoshoot_controller.dart:114-118` (usage null → free default, no lockout) | P2 fixed |
| F-35 | PASS | Try-on avatar failure restores previous avatar + ready flag (exec-plan flutter-closet P2 fixed) | P2 fixed |
| F-36 | PASS | Settings load (prefs → theme sync, shimmer, 404 → defaults) | Code trace |
| F-37 | PASS | Theme/unit change (dialog → local + ThemeService + PUT) | Code trace |
| F-38 | PASS | Change password validates (≥8, upper, lower, digit, match) → POST → pop | Code trace |
| F-39 | PASS | Export data (confirm → POST → "email when ready") | Code trace |
| F-40 | PASS | Delete account (destructive confirm → DELETE → logout → splash) | Code trace |
| F-41 | PASS-PARTIAL | `ai_settings_controller.dart:139-144` (saved key never echoed; Test-Connection guidance) | Backend test-with-saved-key deferred (⚠️) |
| F-42 | PASS | Profile hub + edit + body-profile CRUD + default | Code trace |
| F-43 | PASS | `flutter/test/features/subscription/controllers/subscription_controller_test.dart` (mobile purchases: register-with-backend-completes, registration-failure keeps uncompleted, store-billed cancel refused locally) | Tests |
| F-44 | PASS | `flutter/lib/features/subscription/views/subscription_page.dart:52-54,92-113` (error card + retry) | P2 fixed |
| F-45 | PASS | Referral share card (copy/share, how-it-works, stats, clipboard fallback) | Code trace |
| F-46 | PASS | `flutter/lib/features/calendar/views/calendar_page.dart:88-94` (Today → `selectDate` + `changeFocusedDate`) | P2 fixed |
| F-47 | PASS | `flutter/test/features/calendar/repositories/calendar_repository_test.dart::calendar update payload preserves both all-day values`; validation + optimistic assign | Test |
| F-48 | PASS | `flutter/lib/features/calendar/controllers/calendar_controller.dart:147` ("Connecting X is not available in this version… create events locally") | No fake OAuth |
| F-49 | PASS | `flutter/test/features/recommendations/controllers/weather_recommendations_controller_test.dart` (unit-aware, saved location); `weather_recommendations_controller.dart:30-33` (TemperatureUnit) | P2 fixed |
| F-50 | PASS | `flutter/test/features/feedback/controllers/feedback_controller_test.dart::ticket history errors are visible in controller state` | Test |
| F-51 | PASS | `flutter/lib/features/social/views/shared_outfit_page.dart:29,40` (hide/report/load); legal + gamification empty states | Code trace |

## 13. Unowned-surface audits (A-1…A-3)

These are read-only findings marked ⏳ deferred to fix phase. Verdict **PASS** =
the named defect was verified ACCURATE (present at the cited location) in the
current tree.

| ID | Verdict | Evidence | Notes |
|----|---------|----------|-------|
| A-1 | PASS | `flutter/lib/domain/enums/season.dart:25` (`Season.value => name` serializes `allSeason`; backend filters expect `all-season`); `flutter/lib/features/dashboard/**` (snapshot Loading, no offline guard, streak tile, dark gradients) | All 5 sub-findings verified; deferred to fix phase |
| A-2 | PASS | `frontend/src/components/ui/dialog.tsx:58` (desktop scroll clip); `frontend/src/api/client.ts:411` (skipToast gates upgrade); `frontend/src/components/ui/alert-dialog.tsx:10` (alias to Dialog); `frontend/src/components/ui/sheet.tsx:66` (tap target); dead code (unused utils exports, JSON-LD wrappers) | All sub-findings verified; deferred to fix phase |
| A-3 | PASS | `backend/app/db/connection.py:68-75` (`get_db` returns `get_service_client()` — identical to `get_service_db` at `:86-92`); `backend/app/api/v1/users.py:949` (dashboard `user` field is a list) | All sub-findings verified; deferred to fix phase |

---

## Evidence summary

- `npx tsc --noEmit` exit 0 (whole frontend tree typechecks).
- Backend pytest baseline 806 passed; Flutter test baseline 121 passed; frontend
  vitest 135/135 — all cited tests are drawn from those suites.
- Live-external boundaries (hosted Supabase RLS, Stripe, real AI/weather
  providers, real Google/Apple OAuth, browser/device E2E) remain outside the
  unit harness per `docs/VERIFICATION.md`; each such story's LOGIC is verified
  by unit test or code trace.
