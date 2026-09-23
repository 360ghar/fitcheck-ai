# Plan: Mobile paper diorama redesign + Riverpod migration

Status: completed 2026-09-23  
Started: 2026-09-23  
Owner: agent

## Goal

The Flutter app gets a paper-cut diorama visual language (multi-stock paper palette, Basteleur display type, offset paper slabs, layered paper scenes at signature moments). State management and routing move from GetX to Riverpod 3 + go_router. Known correctness bugs are fixed, and every page has consistent loading (skeleton), empty and error (retry) states. Ships as store release 1.1.0+11, because it adds a font and a texture asset.

## Non-goals

- Web or admin UI changes. Mobile diverges from web visually; see `flutter/DESIGN.md`.
- Backend API changes.
- Folding the ~100 repeated `handleDioException` wrappers into `ApiClient` (tracked as debt).

## Acceptance criteria

- [x] Section 1: framework-independent P0 fixes (auth sign-out, token refresh, deep-link flags, per-user AI consent, retry policy) with tests
- [x] Section 2a: `ProviderScope` + go_router (`StatefulShellRoute`) replace `GetMaterialApp`, bindings and middlewares; no `Get.back/to/off/snackbar/dialog` in `lib/`
- [x] Section 2b: paper tokens, theme, shared widgets (`PaperSurface`, `PaperScene`, `AppEmptyState`, `AppErrorState`, `AsyncValueView`, skeletons, nav)
- [x] Section 3: every feature ported to Riverpod and restyled; controller bugs fixed with tests
- [x] Section 4: `get` dependency removed; dead code deleted; image decode sizing
- [x] Section 5: docs updated (`flutter/DESIGN.md`, `docs/FLUTTER.md`, `AGENTS.md`, `ARCHITECTURE.md`, `flutter/README.md`)
- [x] `flutter analyze` has no new issues; `flutter test` passes

## Context / links

- Full plan and audit findings: this file plus `flutter/DESIGN.md`
- Related code: `flutter/lib/`

## Progress log

| Date | Note |
|------|------|
| 2026-09-23 | Started. Baseline: 313 tests pass, 9 analyze issues (pre-existing). |
| 2026-09-23 | Section 1 done (sign-out, token refresh, deep-link flags, per-user consent, retry policy, avatar cast, connectivity guard) with tests. |
| 2026-09-23 | Snackbars moved to ScaffoldMessenger (fixes `Get.back()` closing only the snackbar at all call sites). ProviderScope via `appContainer`; parallel startup; no zone wrappers. |
| 2026-09-23 | Design system landed: paper tokens (5 stocks, WCAG AA test), paper theme, PaperSurface, PaperScene + presets, AppEmptyState/AppErrorState/AsyncValueView/AppErrorBanner, skeletons (Shimmer* renamed Skeleton*), bottom nav, Basteleur font, grain texture, golden harness. |
| 2026-09-23 | Ported: auth (AuthNotifier), splash, auth screens, dashboard (DashboardNotifier). 331 tests pass. |
| 2026-09-23 | Ported: wardrobe (PagedNotifier, filters, detail, edit, stats), outfits (list, detail, edit, builder with visible AI preview and double-save guard, collections with capped loader). Fixed unawaited returns in try blocks (DioException escaped mapping). Image widgets decode at laid-out width; data-URI bytes memoised. Photoshoot + try-on ported (agent). Recommendations/calendar, profile/settings/misc, subscription/gifts, item add/batch in progress (agents). |

| 2026-09-23 | All features ported. go_router switch: `lib/app/router.dart` (auth redirect, `StatefulShellRoute` with per-tab navigators and stock scopes); bindings, middlewares, `MainShellController`, `app_pages.dart` deleted. GetX services became plain singletons with `ValueNotifier`s; `get` removed from pubspec. `sessionUserIdProvider` resets per-user providers on account switch. Guard tests: no `package:get/`, no raw colours. 360 tests pass, 0 analyze issues; 79 goldens regenerated. |
| 2026-09-23 | Design-law pass on all 79 goldens (three reviewers). Fixed: header grain seam (transparent app bar, grain under it), scene seam (opaque sky, hard clip), empty-state frame edge, pinned action bars (`PaperActionBar`), selected chip/segment/switch/calendar contrast, disabled button in dark mode, builder chips overflowing the gutter, duplicate detail titles, Google "G" on the sign-in button, auth back arrow over the scene, paywall Upgrade disabled with no store products, dark clay/marigold lifted. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-23 | Migrate GetX → Riverpod 3 (no codegen) + go_router | GetX causes real bugs: `Get.back()` only closes an open snackbar (get 4.7.3), plus DI lifecycle bugs (shared/eager controllers, stacked shells). `autoDispose`, `AsyncValue` and `StatefulShellRoute` remove these bug classes. |
| 2026-09-23 | Multi-stock paper palette, brand red for primary actions only | User decision |
| 2026-09-23 | Bundle Gambarino + paper grain PNG; version 1.1.0+11 | Shorebird cannot patch assets; user approved a store release |
| 2026-09-23 | Disable Flutter deep linking | Stops the OAuth callback URL from being pushed as a route; app_links handles callbacks |
| 2026-09-23 | Display face Basteleur (Velvetyne, OFL) instead of Gambarino | The repo is public; the Fontshare FFL forbids distribution on public servers. OFL allows it. |
| 2026-09-23 | Riverpod automatic retry off (`noRetry`) | Screens show errors with explicit retry; repositories retry transient network errors |
| 2026-09-23 | Slashed-zero figures shown as a dash (`paperFigure`) | Basteleur's lone "0" reads as a symbol |
| 2026-09-23 | Port features before the go_router switch | GetX disposes controllers on route pop; switching routing first would stop onInit fetches on page re-open. Riverpod autoDispose does not depend on the router. |

| 2026-09-23 | No post-login return to a pending deep link | Deep linking is off, so no signed-out user can open a protected link; add a pending location to `authRedirect` if deep links return |
| 2026-09-23 | Wardrobe/outfit sub-pages are top-level routes, not shell-branch children | A push from another tab must not switch the shell branch under the page |
| 2026-09-23 | Dark ink stock stays navy | It is the ink paper of the Home stock (dark-blue construction paper); the other four dark stocks are warm or green. Scene and surface tones were lifted instead. |
| 2026-09-23 | Splash has no 900 ms minimum | The router leaves the splash when the session is restored; the native launch screen already covers the start |

## Verification

```bash
cd flutter && flutter analyze && flutter test
flutter test --tags golden   # local only; CI excludes goldens
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Repeated `on DioException catch (e) { throw handleDioException(e); }` blocks in repositories
