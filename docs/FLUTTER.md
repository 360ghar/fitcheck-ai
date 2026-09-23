# Flutter

Last updated: 2026-09-23

Mobile client under `flutter/`. State and dependency injection use Riverpod 3 (no code generation). Routing uses go_router. The paper-cut diorama design system lives in `lib/core/theme/` and `lib/core/widgets/`. The app has no GetX; `test/core/utils/snackbar_policy_test.dart` fails on a `package:get/` import.

## Commands

```bash
cd flutter
flutter pub get
flutter analyze
flutter test                                  # CI runs --exclude-tags golden
flutter test --tags golden --update-goldens   # screenshot tests, local only
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Env can also load via asset `.env` through `lib/core/config/env_config.dart`. Template: `flutter/.env.example`.

Run `dart format` only on files you create or rewrite. The existing code is not formatted with the current Dart version, so formatting a directory rewraps hundreds of untouched files.

## Structure

```text
lib/
├── main.dart            # parallel startup, UncontrolledProviderScope(appContainer)
├── app/                 # router.dart (go_router, auth redirect, shell), Routes, AppTheme
├── core/
│   ├── providers.dart   # appContainer, noRetry, rootNavigatorKey, sessionUserIdProvider
│   ├── state/           # PagedState, PagedNotifier, BusyIds, SelectedIds
│   ├── theme/           # PaperTokens, paperTheme, PaperSlabBorder, DeckleBorder
│   └── widgets/         # PaperSurface, PaperScene, app states, skeletons, nav
└── features/<feature>/
    ├── models/ repositories/     # unchanged API clients
    ├── providers/                # Riverpod notifiers (the "controllers")
    ├── views/ widgets/           # ConsumerWidget / ConsumerStatefulWidget
```

## State (Riverpod)

- **Repositories** are exposed as `Provider((ref) => XRepository())` so tests override them with `overrideWithValue(fake)`.
- **Screen data** is an `AsyncNotifier` (`.autoDispose` for pushed pages, `.family` for `:id` pages). Session-wide lists (closet, outfits, dashboard) stay alive.
- **Paged lists** extend `PagedNotifier<T>` (`lib/core/state/paged_state.dart`): `fetchPage(page)` is the only method to write. It gives `refresh()` (keeps items on screen, keeps them and the paging position on failure), `loadMore()`, `retryLoadMore()` and a `loadMoreError`. A rebuild (for example a filter change) drops the results of older requests.
- **Refresh without blanking**: set `state = const AsyncLoading()` then `state = await AsyncValue.guard(load)`. Riverpod 3.4 carries the previous value into loading and error states set this way.
- **Mutations** are notifier methods. They show the success or error snackbar through `ErrorHandler` and return a result (`bool` or the new model) or rethrow. Views await them, pop only on success, and never show a second toast. Per-row spinners use a `BusyIds` notifier; `BusyIds.run` also blocks double taps.
- **Filters** are a separate `Notifier` whose state the list `ref.watch`es in `build`, so one change sends one request.
- **Automatic retry is off** (`noRetry` on `appContainer` and on test containers). Screens offer an explicit retry; repositories use `RetryHelper` for transient network errors.
- **Per-user data**: a session-wide provider must `ref.watch(sessionUserIdProvider)` in `build`, so the next account never sees the previous account's data.
- **Services** (Supabase, network, theme, code push, persistence) are plain singletons (`X.instance`) with `ValueNotifier` fields. Use `listenValue(ref, notifier, onChange)` to react to one inside a provider.
- **No `ref`**: code outside the widget tree (interceptors, the router redirect) reads providers through `appContainer`. Tests that pump the whole app must use `UncontrolledProviderScope(container: appContainer)`.

## Routing (go_router)

- `lib/app/router.dart` holds the route table. Paths are in `Routes` (`lib/app/routes/app_routes.dart`); build id paths with `Routes.item(id)`, `Routes.itemEdit(id)`, `Routes.outfit(id)`, `Routes.outfitEdit(id)`.
- `authRedirect` is the only auth guard: splash until the session is restored, guest pages when signed out, the shell when signed in. `/legal` and `/shared/:id` are public. Sign-in and sign-out code does not navigate; the router reacts to the session.
- The five tabs are a `StatefulShellRoute` (one navigator per tab). Switch tabs with `context.go(Routes.wardrobe)`. Every other page is a top-level route on the root navigator: open it with `context.push(...)`, close it with `Navigator.pop(context, result)`.
- Dialogs and sheets opened from code without a `BuildContext` use `rootNavigatorKey.currentContext`.
- Deep linking is off (`FlutterDeepLinkingEnabled` / `flutter_deeplinking_enabled`); `app_links` handles the OAuth and social-import callbacks.

## Screen states

Every screen follows the same order (`AsyncValueView` in `lib/core/widgets/app_states.dart` implements it):

1. Loading with no data: a skeleton (`Skeleton*` widgets), never a bare spinner.
2. Error with no data: `AppErrorState(error:, onRetry:)`; copy and scene follow the error type (offline, server, not found, auth).
3. Empty: `AppEmptyState(scene:, title:, message:, actionLabel:, onAction:)`. A filtered list with no matches says "No … match" and offers "Clear filters"; a first-run list offers the first action.
4. Data, with `AppErrorBanner(error:, onRetry:)` on top when a refresh failed.

Paged lists end with `SliverLoadingMoreIndicator(isLoading:, error:, onRetry:)` inside an `InfiniteScrollWrapper(canLoadMore:)`.

## Design system (paper-cut diorama)

- **Stocks**: five paper stocks (`PaperStockId`: ink = Home, clay = Photoshoot, moss = Closet, marigold = Outfits, stone = More, sheets, dialogs). Each screen is wrapped in the `PaperStockScope` of its feature; the whole Material `ColorScheme` follows the stock. `test/core/theme/paper_tokens_test.dart` enforces WCAG AA for every stock in both modes.
- **Colour roles**: read `PaperTokens.of(context)` (or `AppUiTokens.of(context)`): `textPrimary/Secondary/Muted`, `stock.page/card/sunk/tint/edge/shadow/accent/onAccent`, `success/warning/error`. Brand red (`tokens.brand`) is only for filled buttons and the FAB, which the theme already styles. Do not use `Colors.*` except white or black over photos.
- **Surfaces**: `PaperSurface` (alias `AppGlassCard`) is a sheet of paper over a solid offset slab; `onTap` makes it press down. Set `grain: false` when a photo covers it. No blurred shadows, glows or gradients.
- **Page and bars**: wrap a page body in `AppPageBackground`; its grain runs up under the transparent app bar, so there is no seam. A pinned `SliverAppBar` uses `flexibleSpace: const PaperGrainFill()`. A pinned bottom action goes in `PaperActionBar` (torn top edge), never a bare `SafeArea`.
- **Type**: display and headline styles use Basteleur (Velvetyne, SIL OFL; `assets/fonts/`). Body text uses the platform font. Use `textTheme.displaySmall` for big figures and tab titles, `headlineSmall` for section titles.
- **Scenes**: `PaperScene(preset:)` draws layered cut paper with scroll parallax and a slow garment sway. Presets live in `PaperScenes` (`home`, `closet`, `outfits`, `studio`, `offline`, `oops`, `auth`). Use scenes only at signature moments: tab headers, empty and error states, auth, splash.
- **Icons**: bare icons, never inside a tinted tile. Garment placeholders use `GarmentGlyph(category:)`.
- **Motion**: never gate content on an animation. All motion respects `MediaQuery.disableAnimations`.
- **Copy**: sentence case, short, second person. No tracked uppercase labels.

## Testing

- Provider tests: `ProviderContainer(retry: noRetry, overrides: [...])`; add `container.listen(provider, ...)` where the screen would listen, because an invalidated provider rebuilds only while listened.
- Widget tests of screens with scenes or skeletons: set `MediaQueryData(disableAnimations: true)`, otherwise `pumpAndSettle` never settles.
- Goldens: `test/visual/visual_harness.dart` (`loadAppFonts`, `pumpPhone`). Tag files `@Tags(['golden'])`.

## Batch / AI

Prefer backend batch extract JSON base64 start endpoint from Flutter; SSE for progress. Align with `docs/BACKEND.md` batch section.

## CI

- `.github/workflows/flutter-ci.yml`
- Mobile build workflows for APK/iOS under `.github/workflows/`

## Code push (Shorebird)

Dart-only fixes ship over the air via [Shorebird](https://docs.shorebird.dev),
skipping App Store review. Config lives in `flutter/shorebird.yaml` (committed —
the `app_id` is not a secret and **must** stay in `pubspec.yaml` `assets:`, or the
updater cannot find the app at runtime).

**Only binaries built by `shorebird release` can ever be patched.** Anything from
plain `flutter build` — including any archive made from the Xcode GUI — is
permanently unpatchable, so every store upload must come from the paths below.

| Platform | Release | Patch |
|----------|---------|-------|
| Android | `flutter/scripts/shorebird_release_android.sh` (local, then upload the `.aab` to Play) | `flutter/scripts/shorebird_patch_android.sh [release-version] [track]` (local) |
| iOS | `.github/workflows/build-ios.yml` (`workflow_dispatch` or a `v*` tag) or `flutter/scripts/build_ios_release.sh` (local, with automatic signing) | `.github/workflows/shorebird-patch-ios.yml` (`workflow_dispatch`) for CI releases; the exact `shorebird patch ios` command is in `build_ios_release.sh`'s header for local releases |

### Release and patch must run in the same place

`flutter/.env` is a bundled Flutter asset, so it is part of every patch diff.
Android releases are cut on the Mac from the local `.env`; iOS releases are cut in
CI from GitHub secrets (or on the Mac from the same local `.env` when using
`build_ios_release.sh`). **Patch from wherever you released** — a cross-environment
patch produces an asset diff and is rejected. This is why Android has scripts and
iOS has workflows rather than one shared mechanism. If you release iOS locally,
also patch locally (same machine, same `.env`, same dart-defines).

### What a patch can and cannot carry

Dart code, pure-Dart pub packages, and generated `.freezed.dart`/`.g.dart` are
patchable. Native code, anything under `android/` or `ios/`, adding or upgrading a
plugin with native code, **any** asset file, and Flutter version changes are not —
they need a new store release. Shorebird detects native and asset diffs and
refuses. **Never pass `--allow-native-diffs` or `--allow-asset-diffs`**: the patch
installs and then crashes on device, because the native half is missing from the
store binary.

### Three settings that must stay in lock-step

- **Flutter `3.44.6`** lives in `.github/workflows/build-apk.yml`,
  `.github/workflows/build-ios.yml`, `.github/workflows/flutter-ci.yml`,
  `.github/workflows/shorebird-patch-ios.yml`, and
  `flutter/scripts/_shorebird_common.sh`. Shorebird defaults to a *newer* version,
  so it is pinned explicitly everywhere. A release's Flutter version can never be
  changed by a patch.
- **`--no-tree-shake-icons`** is passed to every release and every patch. Flutter
  otherwise strips `MaterialIcons-Regular.otf` to the icons in use, so adding one
  icon in a patch changes a bundled asset and gets rejected. Costs ~1MB. Drop it
  from all five call sites or none.
- **The version number.** `flutter/pubspec.yaml` is the only source. Do not
  hand-edit `flutter.versionName`/`flutter.versionCode` in
  `flutter/android/local.properties` (Flutter regenerates them from pubspec on each
  build, and the preflight fails on a mismatch), and never change the version in
  Play Console or let Xcode's *Manage Version and Build Number* touch it — patches
  resolve against the exact recorded release version.

### In-app surface

`flutter/lib/core/services/code_push_service.dart` is started in `main.dart`
before Sentry initializes. It reads the running patch
number into Sentry's `dist` so a crash can be attributed to the patch that caused
it, and drives the "restart to apply" prompt. It is fully inert when the updater
is unavailable, which is every debug build and every `flutter test` run.

The patch number is surfaced by `flutter/lib/core/widgets/app_version_label.dart`,
the single formatting path for the app version — used by both Settings → About and
the Profile → About dialog, so the two cannot disagree and neither can go stale.
It renders `1.0.4 (9)`, or `1.0.4 (9) · patch 3` once a patch is installed.

Patches apply on the launch **after** the background download finishes, so expect
two launches before a change is visible.

### Rollback

```bash
shorebird patches list --release-version <v>
shorebird patches promote --release-version <v> --patch-number <good-n>
```

Devices always jump to the newest active patch, so re-promoting a known-good patch
is the rollback.

### Account

Shorebird's free tier allows **5,000 patch installs/month** with overage disabled,
so a patch reaching a larger audience simply stops being served. Watch the counter
at console.shorebird.dev. CI needs a `SHOREBIRD_TOKEN` repo secret, created under
Account → API Keys (`shorebird login:ci` is deprecated).

## Notes

Deep feature behavior should be documented in `product-specs/` and implementation status. Expand this file when mobile-specific architecture decisions accumulate.

### Subscriptions & IAP

`features/subscription/` — `SubscriptionPage`, `ReferralPage` (referral codes),
and `IapService` (thin wrapper over `in_app_purchase`; iOS StoreKit / Android
Play Billing, every purchase verified server-side via
`POST /api/v1/subscription/iap/transaction`). `in_app_purchase: ^3.3.0` in
`pubspec.yaml`; `PAYWALL_ENABLED` in `flutter/.env.example` gates every
purchase CTA (default on). Social sharing and body profiles live under
`features/social/` and `features/profile/` (`body_profiles_page.dart`).

### Gift vouchers

The native gift feature is under features/gifts. It has a repository,
models, providers, a /gifts route (the intent is passed as `extra`) and a gift page. The home tab
uses the same priority as web: incoming gift, then a free invitation, then
referral. The form defaults to no occasion. Birthday and anniversary show
fixed greetings; Other requires a 1–80 character greeting. A private note is
always optional.

ENABLE_GIFT_VOUCHERS defaults to true in flutter/.env.example. Set it to false
only for a release rollback. The app can create and share a free named
invitation, show incoming named gifts, and claim them with the signed-in
verified account. The app does not show paid voucher purchase, Stripe Checkout,
or another external payment path. Paid vouchers remain available in web and
admin, and a named paid voucher can still be claimed in Flutter.

### iOS minimum deployment target is 15.0

App Store Connect rejects uploads with a `MinimumOSVersion` below 15.0 starting Spring 2027. The target lives in **two places that must stay in lock-step**: `IPHONEOS_DEPLOYMENT_TARGET` in `flutter/ios/Runner.xcodeproj/project.pbxproj` (every Runner build configuration) and `platform :ios` in `flutter/ios/Podfile`. Never lower either. `scripts/check_ios_deployment_target.py` enforces this in `scripts/check_all.sh`, `flutter-ci.yml`, and `build-ios.yml`.

### Image URLs are short-lived (presigned)

Image URLs are served from the private S3-compatible bucket (R2 since the 2026-08-05 egress RCA) in one of two modes, driven by backend config:

- **Presigned mode (default):** URLs are **short-lived presigned GET URLs** (~7 days, `OBJECT_STORAGE_PRESIGN_TTL=604800`) that **rotate on every read** (the signature is in the query string) — they defeat disk caching, so treat them as ephemeral and re-fetch as needed.
- **Worker mode (`IMAGE_SERVING_MODE=worker`):** URLs are **stable and path-only** with `Cache-Control: public, max-age=86400, immutable`, so `CachedNetworkImage`'s disk cache and the Cloudflare edge cache both hit.

Use `AppNetworkImage` (`core/widgets/app_network_image.dart`) instead of raw
`Image.network` — it is a `CachedNetworkImage` drop-in with `authHeadersForUrl()`,
which attaches the bearer token ONLY to non-presigned URLs (S3 presigned
requests reject any other auth mechanism). Grid/list tiles should use
`thumbnail_url` when returned (`THUMBNAIL_SERVING=true` serves `_thumb`
siblings). The DB stores a bucket key, not a URL, so the backend materializes
a fresh URL at read time.
