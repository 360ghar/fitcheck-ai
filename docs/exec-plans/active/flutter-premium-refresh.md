# Plan: Flutter fashion editorial refresh

Status: UI refinement verified; source-image and device release gates remain  
Started: 2026-09-05  
Owner: agent

## Goal

Apply the approved fashion magazine design and muted palette throughout mobile, reorganize
navigation around daily use, fix verified reliability defects, and retain GetX.

## Non-goals

No backend/schema changes, new state framework, production purchases, or store
publication. Preserve product functionality and existing workspace work.

## Acceptance criteria

- [x] Trusted-host authentication, transient refresh errors, bounded SSE framing and optional analytics startup are safe.
- [x] Stale jobs, failed outfit refresh, extra-photo upload and image taps have regression tests.
- [x] Home, Closet, Outfits, Studio, Profile preserve legacy links and tab/job state.
- [x] All screen families use the new theme; automated narrow/tablet, large-text, dark-mode and reduced-motion checks cover representative states.
- [x] Analyzer, Flutter tests and repository checks pass; visual evidence and device release gates are recorded.

## Screen coverage

| Family | Surfaces | Implementation / evidence |
|---|---|---|
| Entry/home | splash, onboarding, login, register, reset, Home | Static startup; themed auth headers/forms/native Back; keyboard, validation, route and semantics tests. Home fixed-image light/dark goldens, 320px/200% and tablet checks. Native iOS onboarding/login inspected. |
| Closet | browse/filter, add, extraction/import/progress/review, detail/edit/stats | Transparent image-only grid/list, primary-photo selection, details on image tap, accessible names and selection states. Secondary layout suite covers capture/manual/social import, extraction, review, detail/edit/stats in both themes; upload, partial-save and route tests. |
| Outfits/Studio | browse, builder, detail/edit/collections, photoshoot stages, try-on | Composition grids and builder links; secondary form/detail/collection layouts. Studio state/ticker/legacy-route checks; single garment and safe replacement tests. Photoshoot result download/report actions separated from zoom; failed slots scroll at 200% text. |
| Planning/account | calendar, recommendations, gamification, profile/body profiles, settings/AI settings | Adaptive calendar/native picker, all-day labels; all five recommendation tools with empty/populated/error fixtures, including corrected generated-look state. Account/rewards/profile/settings retry and sheet tests at 320px/200%, keyboard, and tablet. |
| Commercial/support | subscriptions, referrals, gifts, sharing/reporting, feedback/help/legal | 15 layout/retry checks across both themes at 320px/200%; native share origin and failure-route tests; keyboard-safe report sheet. Existing purchase/controller tests retained. No live purchase performed. |

## Progress log

| Date | Note |
|---|---|
| 2026-09-05 | Planning baseline: 39 page/content files, 272 passing tests, one analyzer warning and two infos. Runtime visual/physical-device checks pending. Workspace clean at implementation start. |
| 2026-09-05 | Added external-host authentication regression first. Fixed trusted-destination policy, single-flight refresh, transient failures, split SSE CRLF/UTF-8 frames, and analytics startup isolation. |
| 2026-09-05 | Added request-generation guards for photoshoot/extraction; retained outfit pagination on refresh failure; saved the second manual photo and corrected save-route ownership. |
| 2026-09-05 | Updated `flutter/DESIGN.md` before UI changes; bundled Bodoni Moda and its OFL licence. Centralized both themes and native component styles; replaced fixed product grids with lazy natural-height rows. |
| 2026-09-05 | Added retained five-tab shell and tablet rail; preserved legacy links. Consolidated Try-on into one body, removed unused controller/binding and unsupported multi-garment UI, retained the API's single-garment capability. |
| 2026-09-05 | Eight fixed-image goldens pass for Home/Closet/Outfits/Studio, plus 320px/200% and tablet checks. Shared image regressions reproduce and fix stale re-mint results and data-URI preview support. |
| 2026-09-05 | Independent review reproduced and fixed empty-Outfits overflow, long Closet list categories, missing Home photo URL recovery, and popup label constraints. Repository architecture/docs/theme/iOS-target checks pass. |
| 2026-09-05 | iOS simulator debug build passed on Flutter 3.44.6; app installed and opened on iPhone 17 Pro / iOS 26.5. Inspected onboarding and login through native screenshot/accessibility tree. Final rebuild passed; native Back, single field labels and empty-form validation were inspected successfully. |

## Decision log

| Date | Decision | Why |
|---|---|---|
| 2026-09-05 | Colourful magazine: white/charcoal, cobalt actions, substantial pink/yellow/coral panels, Bodoni Moda headings. | Explicit user approval. |
| 2026-09-05 | Home → Closet → Outfits → Studio → Profile; Photoshoot/Try-on in Studio. | Explicit user choice. |
| 2026-09-05 | Keep GetX, existing repositories/services and Flutter controls. | Smallest maintainable implementation. |

## Verification results

| Check | Result |
|---|---|
| Full Flutter suite | **424 passed**, 2026-09-05; baseline was 272. No skipped tests or hit-test warnings in the final run. |
| Strict analyzer | **No issues**; baseline warning/two notices cleared. CI uses fatal default warnings/notices. |
| Architecture, documentation, theme tokens, iOS target | **All pass**. Stale documentation headers now reflect the 2026-09-05 source changes. The repository theme-token check covers web; Flutter contrast has its own theme test. |
| Visual fixtures | Fourteen reviewed local-image goldens: all five tabs and welcome in light/dark, plus Home at 320px and 1024px. Lazy tab images must decode before capture. Real shell, fixed images, pinned SDK fonts and Bodoni Moda. Twenty visual/layout cases pass. |
| iOS simulator (before visual revision) | Debug build **passes**, installed on iPhone 17 Pro / iOS 26.5. Native onboarding, Login, Back affordance, accessible field labels and validation inspected. |
| Android ARM64 debug (before visual revision) | **Pass** (`flutter build apk --debug --no-pub --target-platform android-arm64`, 259s). Native Settings handoff has a method-channel regression test. APK: `flutter/build/app/outputs/flutter-apk/app-debug.apk`. |

Visual files are under `flutter/test/visual/goldens/`. Layout and interaction
suites are `test/features/auth/auth_layout_test.dart`,
`test/features/wardrobe/views/wardrobe_form_layout_test.dart`,
`test/features/account_recommendations_layout_test.dart`,
`test/features/subscription/commercial_layout_test.dart`,
`test/features/shell/studio_navigation_test.dart`, and
`test/features/photoshoot/photoshoot_results_test.dart`.

## Verification commands

```bash
cd flutter
flutter analyze --no-pub
flutter test --no-pub
cd ..
python3 scripts/check_architecture.py
python3 scripts/check_docs_structure.py
python3 scripts/check_theme_tokens.py
python3 scripts/check_ios_deployment_target.py
```

## Release gates

Physical-device camera/permissions, VoiceOver/TalkBack, background/reconnect,
profile-mode frame timing, and store-sandbox purchase/restore require the relevant
device/session. Record actual verification. Font assets and the Android Settings channel need a full Shorebird
store release. Publication is outside this change.

No physical Android or iOS device was available during this pass. No test account
or store-sandbox purchase session was used. Authenticated end-to-end journeys,
camera/permission paths, background/resume, screen-reader operation, and profile
frame timing must be verified before store submission. Widget tests exercise
fixture data and controller/service behavior; they are not evidence of successful
live generation, billing or production API integration.

### Known limits to close before release

- Android `image_picker.retrieveLostData` has no startup consumer. Ordinary
  cancel/denial/retry is covered; selected images can still be lost if Android
  destroys the process while the external picker is open. Track as TD-106 and
  test with the device's activity-destruction option before release.
- Android build tooling reports future-support warnings for the existing
  Gradle/AGP/Kotlin versions. iOS uses CocoaPods fallback for plugins that do not
  yet support Swift Package Manager. No dependency upgrade was included.
- Exact Linux golden raster parity must be confirmed on the first CI run;
  source and fonts are pinned, but this execution ran on macOS.

## Deferred debt

TD-091 through TD-096 are resolved. TD-084 records the mobile refresh fix while web remains separate. TD-105 tracks physical-device release gates; TD-106 tracks Android picker process-death recovery. Existing unrelated debt stays in the shared tracker.

## Visual revision — 2026-09-05

User review: the first rendered design is basic and dull. The stronger visual
pass is implemented and verified. The previous implementation passed 409 tests
and both native builds; this revision passes 424 tests and strict analysis.

1. Inspect the incumbent renders and external design references (complete).
2. Replace repetitive panels with photographic editorial compositions (complete).
3. Render light/dark phone and tablet states; independently review and fix gaps (complete).
4. Run strict analysis, focused layouts and the full regression suite; record proof (complete).

Keep existing features, security fixes, backend contracts and release gates.
The revised visual contract is in `flutter/DESIGN.md`.

The revision replaces equal pastel cards with a portrait feature, compact tools,
visible catalogue search, lookbook compositions, an inset native dock, and an
example-led Studio. Home uses two columns on tablet. Welcome/Profile and shared
section headings use the same type system. The duplicated daily-outfit section
was removed; its feature stays at the top of Home.

Independent review fixed header alignment, misleading decorative controls,
button font inheritance and photo proportions. Studio checks additionally found
and fixed a 320×640 / 200% / keyboard layout that blocked the Generate action.

The original screenshot helper captured blank lazy-tab image frames. A failing
regression confirmed the cause: its timer ran before the tab mounted. It now
settles the selected tab, awaits mounted image providers and checks decoded
pixels. Production image widgets did not need a change.

Review gallery: `flutter/test/visual/preview.html`. The fourteen images are widget
renders with fixture data, not live account or physical-device screenshots.
Native builds above predate this second visual pass; repeat platform builds with
the final assets during release preparation. Physical-device gates stay open.

Final revision verification: **424 tests pass** (56 seconds), strict analysis has
**no issues**, and architecture/docs/theme/iOS-target checks pass. The full suite
found an old filter-sheet test that matched both the new catalogue search and the
sheet field. The selector now targets the labelled sheet input, with unconditional
fixture teardown; all keyboard and viewport assertions remain. No skipped tests
or hit-test warnings occur in the final run.

## Muted palette and image-only Closet — 2026-09-05

User accepts the composition but finds the colours flashy. Replace bright fields
with muted rose, linen, sage and slate; use deep moss for primary controls.
Closet listings must show garment images only, with transparent backgrounds and
no visible names/descriptions/metadata. Retain accessible labels and details.

1. Trace source transparency and update the design contract (complete).
2. Apply muted tokens and image-only Closet tiles in both display modes (complete).
3. Review cutout fixtures, rerun regression/visual checks, and refresh gallery (complete).

The shared palette now uses warm off-white, charcoal, deep moss and four muted
editorial fields. Home, Closet, Outfits, Studio, Profile, auth and secondary
screens consume those tokens. The remaining referral gradient, extraction brand
purple, Pro/About icons and decorative stats colours were removed. Narrow Home
uses a compact headline so the contained portrait has no extra bands at 320px.

Closet now reuses one image tile in its lazy grid and list. Primary photos take
priority, with the first photo as fallback; URL/storage/remint stay together.
Tiles have transparent Material and image surfaces with no visible name, brand,
category or favourite badge. Tap opens details; long-press keeps the existing
options. Screen-reader names, loading/error states and active selection remain.
An interaction regression found that a second selected lazy tile did not update
its tick. Each mounted tile now observes selection; two-item select/deselect is
covered. Native Material and scrolling also fix the options/sort sheet ink path.

Four synthetic RGBA garment cutouts exercise actual transparency in the Closet
renders. Their generation source and prompts are in
`flutter/test/fixtures/garment-fixtures.md`; none are shipped app assets or user
photos. Fourteen light/dark/size renders were independently inspected and the
existing review gallery was refreshed in both themes.

The dark palette check replaced white foregrounds on pale primary/secondary
surfaces in import/review buttons, active segments, outfit selection and collection
favourites. Theme tests cover AA text contrast for primary, secondary and their
containers; existing form tests assert rendered selection-icon contrast. Four
additional banner cases cover normal/urgent Home referrals in both themes at
320px/200%, including Copy, Share origin and Dismiss semantics.

Final muted revision verification: **433 tests pass** (38 seconds), strict
analysis reports **no issues**, and architecture/docs/theme/iOS-target plus diff
checks pass. No tests are skipped and the final run has no hit-test warnings.
The fourteen goldens match the reviewed renders. Native builds and physical
device release gates above still require verification with these final assets.

### Source-image limit

Generated product images already use the backend's best-effort matte-to-alpha
WebP path. Manual uploads and older/fallback photos can still contain embedded
background pixels, and matte rejection preserves the original. Transparent
tiles cannot remove those pixels. There is no verified-alpha metadata or exact
arbitrary-photo segmentation endpoint. This pass does not convert existing user
photos or claim that all stored images are cutouts. The existing backfill script
overwrites originals and leaves thumbnail siblings unchanged, so it was not run.
Uniform cutouts for those stored photos require a separate image-processing step.

## Approved design integration — 2026-09-05

User approved the muted preview and requested implementation with dark mode.
The gallery already renders the real Flutter screens; retain that implementation.
Verify the runtime theme choice, persistence and platform chrome, then build with
the final assets where local capacity permits. Keep store publication separate.

1. Compare approved renders with the app and trace runtime theme behavior (complete).
2. Fix confirmed theme integration gaps and add focused regressions (complete).
3. Run the full suite, strict analysis and available native checks (complete; native rebuild blocked by disk capacity).

The runtime audit found a fixed light status-bar style on pages without AppBar.
The preferences API also lacks the client's three-state theme field; local
Light/Dark/System choices need to remain authoritative instead of being replaced
by an absent field. No backend contract change is required.

The implementation now shares the theme's system-bar style across root, auth
and splash surfaces. The image viewer uses a native annotated region over its
dark backdrop; closing it automatically restores the underlying route's style.
Settings preserves the device-local Light/Dark/System choice during preference
fetch/save failures and concurrent saves. The unsupported theme field is omitted
from preference API writes. Cached startup, OS theme changes, rapid choices,
offline selection and viewer open/close have focused regression coverage.

Final verification: **442 Flutter tests pass** (29 seconds), including the fourteen
approved light/dark/size goldens. Strict analysis and repository architecture,
docs, theme-token, iOS-target and diff checks pass. The fresh iOS simulator build
failed during Sentry Swift Package Manager extraction because the disk filled;
it did not reach compilation. Only FitCheck's generated Xcode intermediates and
the failed test compiler temporary directory were removed to restore test space.
Source, stored images and release archives were retained. Native rebuilds remain
open until more disk capacity is available; no store publication was performed.

## Follow-up review and listing images — 2026-09-05

The [completed review](../completed/2026-09-05-flutter-review-store-assets.md)
fixes filter-refresh pagination, secondary keyboard/large-text surfaces, SDK
refresh rate-limit handling and stale login rejection. **458 tests pass** and
strict analysis is clean. All 14 goldens pass; only the tablet Home baseline
changed for the corrected favourite-outfit label.

The final Android ARM64 debug and iOS simulator builds now pass with the new
assets and authentication dependencies. This supersedes the disk-capacity build
block above. Signed releases, physical-device journeys, screen readers and
sandbox purchase/restore remain open.

[31 store images](../../store/premium-refresh/README.md) cover iPhone, iPad,
Android phone and both Play tablet groups, plus the feature graphic. These are
real Flutter widget renders with documented synthetic data. All exports and the
download archive pass validation. Manual/legacy source-image backgrounds and
Android picker process-death recovery remain explicit debt (TD-107 and TD-106).
