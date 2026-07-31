# Simplify Review — FitCheck AI Codebase

Review date: 2026-07-28
Scope: backend, frontend, flutter, remotion, scripts
Status: **Read-only audit; no files modified.**

---

## Tier 0 — Fix immediately (highest risk/value)

### F1 — Remove derived `filteredOutfits` state
- **Package:** Frontend (`frontend/src/stores/outfitStore.ts`)
- **Severity:** HIGH
- **Problem:** `filteredOutfits` is mutated after every filter/sort/update/delete operation, but is just `applyFiltersAndSort(outfits, filters, sortBy, sortOrder)`. Eight mutation sites keep it in sync, which risks stale UI and duplicates filtering logic.
- **Recommended fix:** Delete `filteredOutfits` from store state. Expose a selector:
  ```ts
  export const useFilteredOutfits = () =>
    useOutfitStore((s) => applyFiltersAndSort(s.outfits, s.filters, s.sortBy, s.sortOrder));
  ```

### B1 — Replace broad `except Exception` in scrape/discovery flows
- **Package:** Backend (`backend/app/services/social_scraper_service.py`)
- **Severity:** HIGH
- **Locations:** `_discover_with_instagram_scraper`, `_fetch_instagram_feed`, plus partial catches in batch extraction, ai_provider_service, weather_service, astrology_service
- **Problem:** Real exceptions are converted into fake `"exhausted=True"` results or single-line error strings, erasing traceback/class information in production failures.
- **Recommended fix:** Catch specific exception classes. When fallback results are needed, log with `logger.exception(...)` and return typed failure envelopes rather than overloading the exhausted sentinel.

### FL1 — Centralize date formatting
- **Package:** Flutter (`flutter/lib`)
- **Severity:** HIGH
- **Locations:** Custom `_formatDate` methods in at least three view files
- **Problem:** Multiple views implement their own date formatting. Display formats diverge as edits happen in different features, and localization updates must be applied repeatedly.
- **Recommended fix:** Add `lib/core/utils/date_utils.dart` with one set of reusable formatting functions; all views/controllers call it.

### FL2 — Wrap SharedPreferences behind a persistence abstraction
- **Package:** Flutter (`flutter/lib`)
- **Severity:** HIGH
- **Locations:** 10+ controllers/views call `SharedPreferences.getInstance()` directly
- **Problem:** Persistence logic is scattered through feature code. Any change to storage semantics (encryption, migration, prefixing, test injection) must be replicated across many call sites.
- **Recommended fix:** Create a `PersistenceService` under `lib/core/services/`; every feature depends on it rather than touching SharedPreferences directly.

### B4 — Introduce `OperationType` enum/union
- **Package:** Backend (`backend/app/models/subscription.py` + callers)
- **Severity:** MEDIUM
- **Locations:** `subscription_service.py:333,400`, `services/rate_limit.py:19`, route call sites
- **Problem:** Rate-limit keys are free-form strings (`"extraction"`, `"generation"`, `"embedding"`) checked against local dicts. Callers must spell exact literals or receive opaque `ValueError("Unknown operation type: ...")`.
- **Recommended fix:** Define `OperationType(str, Enum)` (or a narrow `Literal` union) in `app.models.subscription`; pass it through `rate_limited_operation`, `SubscriptionService`, and route callers. Use `.value` only at DB boundaries.

---

## Tier 1 — Structural cleanup

### F2 — Move auth token/logout out of `src/api/client.ts`
- **Package:** Frontend
- **Severity:** HIGH
- **Location:** `src/api/client.ts:130-146`
- **Problem:** Axios client owns raw token CRUD and performs `window.location.href = '/auth/login'`, mixing transport concerns with auth-flow decisions.
- **Recommended fix:** Create `src/lib/auth.ts` for token plumbing and forced-logout redirects; keep `client.ts` focused on HTTP transport, retries, and interceptors.

### F3 — Extract API error normalization helper
- **Package:** Frontend
- **Severity:** HIGH
- **Locations:** `outfitStore.ts`, `photoshootStore.ts`, `wardrobeStore.ts`, `subscriptionStore.ts` import `getApiError`/`ApiError` from `@/api/client`
- **Problem:** Zustand stores depend on the HTTP-layer error typing, violating the frontend architecture (`stores` should import from `lib/types` and `api`, not each other).
- **Recommended fix:** Export a slim `parseApiError`/`isApiError` from `src/lib/errors.ts`; both api client and stores consume it.

### F4 — Split massive `ProfilePage.tsx`
- **Package:** Frontend
- **Severity:** MEDIUM
- **Location:** `src/pages/settings/ProfilePage.tsx` (~914 LoC)
- **Problem:** One page manages avatar, profile, preferences, theme, location, referral, support, subscription, delete-account dialogs, and ~16 local states.
- **Recommended fix:** Extract `AvatarSection`, `PreferencesPanel`, `AppSettingsPanel`, `SecurityPanel`, `DeleteAccountDialog` into sibling components under `src/pages/settings/`. Keep `ProfilePage` as a layout/wiring shell.

### B2 — Make async concurrency tests deterministic
- **Package:** Backend tests
- **Severity:** HIGH
- **Locations:** `test_token_refresh_service.py:31,77,99,122,135,144`; `test_batch_overlap_pipeline.py:300,316`
- **Problem:** Tests rely on real `time.sleep`/`asyncio.sleep` windows. The suite becomes slow, flaky under CI load, and order-sensitive if another async test borrows the event loop.
- **Recommended fix:** Inject controllable delay/future via constructor or monkeypatch (e.g., `await asyncio.Event.wait()` / passed `leader_wait_event`); assert ordering deterministically.

### B6 — Add UTC datetime utility
- **Package:** Backend
- **Severity:** MEDIUM
- **Locations:** Services/APIs call `datetime.utcnow().isoformat()`, `datetime.now(timezone.utc).isoformat()`, and `datetime.utcnow() + timedelta(...)` ad hoc
- **Problem:** Naive/aware mix can produce subtly different strings and drift across modules.
- **Recommended fix:** Add `app.utils.datetime_util` with `utcnow_iso()`, `utcnow()`, `utc_today()`; prefer timezone-aware datetimes.

### R1 — Data-drive remotion timeline
- **Package:** Remotion (`remotion/src/fitcheck/FitCheckPromo.tsx`)
- **Severity:** MEDIUM
- **Problem:** Six scenes and six transitions are wired by hand, repeating identical structure. Future scene edits easily desync transition chains.
- **Recommended fix:** Define a scene list like:
  ```ts
  const SCENES = [
    { component: SceneBrand, duration: SCENE_DURATION },
    { component: SceneHero,  duration: SCENE_DURATION },
    // ...
    { component: SceneCTA,   duration: CTA_DURATION },
  ] as const;
  ```
  Then map it once inside `<TransitionSeries>` with transitions injected between entries.

---

## Tier 2 — Hygiene and harness tightening

### B3 — Compose AI retry loop over existing `utils.retry.with_retry`
- **Package:** Backend (`services/ai_provider_service.py`)
- **Severity:** MEDIUM
- **Problem:** `AIProviderService.chat()` reinvents retry/backoff/fallback behavior that already exists as `utils.retry.with_retry` (with predicate hook and on-retry callback).
- **Recommended fix:** Keep provider-specific model fallback, but build a private `_call_with_retry_and_fallback` helper over the generic utility.

### B5 — Document provider error contracts
- **Package:** Backend (`ai_service.py`, `gemini_provider.py`, `photoshoot_service.py`)
- **Severity:** MEDIUM
- **Problem:** Internal service boundaries mix raised domain exceptions and dict-return envelopes. `GeminiProvider.test_connection()` returns a raw dict shaped like an API health envelope rather than a named result.
- **Recommended fix:** Convert API-facing health envelopes to a named `HealthCheckResult` model. Document each boundary: domain errors raise `AIServiceError`/`DatabaseError`; UI envelopes return typed models.

### B7 — Bound or extend `SocialPlatform`
- **Package:** Backend (`models/social_import.py`)
- **Severity:** MEDIUM
- **Problem:** Enum lists only Instagram/Facebook while product/docs reference TikTok/Pinterest/Threads. Unknown platform values fall through silently.
- **Recommended fix:** Extend deliberately or add a `_SUPPORTED_PLATFORMS` set and raise `ValidationError`/`SocialImportJobNotFoundError` at job creation.

### F5 — Reuse landing feature/CTA layouts
- **Package:** Frontend
- **Severity:** MEDIUM
- **Locations:** Four public feature pages repeat hero -> CTAs -> benefit grid -> stat cards
- **Problem:** Only copy and icons differ; duplicated JSX makes brand/copy changes multiply.
- **Recommended fix:** Build `LandingFeatureSection`, `BenefitGrid`, `CtaBand` in `src/components/landing/`; each page declares content as data.

### F6 — Centralize endpoint and route constants
- **Package:** Frontend
- **Severity:** MEDIUM
- **Locations:** `LONG_RUNNING_PREFIXES`, `AUTH_ENDPOINTS`, per-module strings, `ReferralBanner`, `LEGACY_TAB_MAP`
- **Problem:** Route/endpoint fragments appear verbatim in multiple layers, creating string drift.
- **Recommended fix:** Single `ENDPOINTS` object in `src/lib/endpoints.ts`; derive `LONG_RUNNING_PREFIXES` from it. Also declare a small `routes` helper map for navigable tabs.

### F7 — Wrap polling timers in `usePolling`
- **Package:** Frontend (`hooks/useSocialImportQueue.ts`, `hooks/useBatchSSE.ts`)
- **Severity:** LOW/MEDIUM
- **Problem:** Watchdog intervals persist or restart unconditionally; cleanup is fragile when called inside success/failure branches.
- **Recommended fix:** Abstract a `usePolling({ intervalMs, shouldStop, onTick })` hook with proper `AbortController` / `clearInterval` cleanup.

### F8 — Wrap runtime logging in a logger
- **Package:** Frontend
- **Severity:** LOW
- **Locations:** 12+ files have unguarded `console.*` calls
- **Problem:** Production logging escapes Sentry/error-policy gates and bloats browser console output.
- **Recommended fix:** Add `src/lib/logger.ts`:
  ```ts
  export const logger = {
    warn: (...args: unknown[]) => import.meta.env.DEV && console.warn(...args),
    error: (...args: unknown[]) => console.error(...args),
  };
  ```
  Route production-log calls through it. Reserve plain `console` for tests/build scripts.

### FL3 — Reduce `Get.find()` service locator coupling
- **Package:** Flutter
- **Severity:** MEDIUM
- **Locations:** ~50 instances throughout `lib/`
- **Problem:** Heavy reliance on `Get.find<>()` makes dependencies implicit, harder to test, and couples views/controllers to GetX internals.
- **Recommended fix:** Keep bindings for setup; pass dependencies via constructors where practical.

### FL4 — Remove cross-feature imports in auth controller
- **Package:** Flutter (`features/auth/controllers/auth_controller.dart`)
- **Severity:** MEDIUM
- **Problem:** Auth feature imports subscription repository directly.
- **Recommended fix:** Move shared user/subscription initialization to a core service or an auth-specific abstraction.

### FL5 — Stop controllers from calling other controllers
- **Package:** Flutter (`ItemAddController`, `BatchExtractionController`)
- **Severity:** MEDIUM
- **Problem:** Controllers reach into each other, producing hidden dependency chains and making testing brittle.
- **Recommended fix:** Extract shared operations into repositories/services consumed independently by each controller.

### FL6 — Don't swallow exceptions in critical flows
- **Package:** Flutter (`DashboardController`, catch blocks)
- **Severity:** LOW/MEDIUM
- **Problem:** Some catch blocks fail silently without Sentry/reporting path, hiding real mobile bugs.
- **Recommended fix:** Require every production catch to rethrow, surface UI, or report telemetry.

### FL7 — Trim oversized `AuthController`
- **Package:** Flutter
- **Severity:** LOW
- **Problem:** 496-LOC controller owns authentication, user-profile merging, referral codes, and navigation.
- **Recommended fix:** Split pure ops into dedicated service classes; controller stays orchestration only.

### S1 — Tighten architecture checker
- **Package:** Scripts (`scripts/check_architecture.py`)
- **Severity:** MEDIUM
- **Problem:** Frontend rule scan uses substring matching, missing relative, aliased, dynamic, and barrel re-export imports.
- **Recommended fix:** Switch to AST-based TypeScript parsing, or document exactly which import forms are intentionally excluded. Resolve backend relative imports using `ast` plus package lookup rather than skipping them.

### S2 — Make `check_all.sh` fail when pytest missing
- **Package:** Scripts (`scripts/check_all.sh`)
- **Severity:** LOW
- **Problem:** A fresh checkout passes architecture/doc checks and exits cleanly even though backend pytest did not run.
- **Recommended fix:** Default invocation fails unless pytest actually ran; add `--allow-no-pytest` for local convenience.

### S3 — Document SQL regex parser limitation
- **Package:** Scripts (`scripts/generate_db_schema_doc.py`)
- **Severity:** LOW
- **Problem:** Heuristic regexes may miss PostgreSQL-quoted identifiers, schemas, materialized views, or multi-line statements.
- **Recommended fix:** Keep the caveat prominent at file top, or replace with a real SQL parser if schema docs become higher-value orientation artifacts.

---

## What was clean

- **Backend layering holds:** No forbidden imports from `core`/`utils`/`models`/`db` into services/api.
- **Remotion is tidy:** No component >250 LOC; no `console.*`/`debugger`; linear flow.
- **Backend tests avoid real network:** All mocked httpx/Supabase clients confirmed.
- **Docs structure harness is sound** beyond a minor mtime grace window.

---

## Suggested rollout

1. Apply Tier 0 first as focused pull requests.
2. Verify after each PR:
   - `cd backend && pytest`
   - `cd frontend && npm run lint && npm run build`
   - `python scripts/check_architecture.py`
   - `python scripts/check_docs_structure.py`
3. Continue with Tier 1 structural changes, then Tier 2 hygiene/harness tightening.
