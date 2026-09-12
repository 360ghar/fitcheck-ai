# Flutter

Last updated: 2026-09-05

Mobile client under `flutter/` using GetX feature modules.

## Commands

```bash
cd flutter
flutter pub get
flutter test
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000 \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_ANON_KEY=...
```

Env can also load via asset `.env` through `lib/core/config/env_config.dart`. Template: `flutter/.env.example`.

## Structure

```text
lib/
├── main.dart
├── app/           # routes, bindings, theme
├── core/          # config, network, shared services/utils/widgets
└── features/      # auth, wardrobe, outfits, photoshoot, recommendations, …
```

## Conventions

- Feature-first modules under `features/`
- GetX routes + bindings under `app/`
- Shared infra only under `core/`
- Talk to the same FastAPI backend as web (`API_BASE_URL`)

## Mobile design and navigation

`flutter/DESIGN.md` is the mobile design source of truth. The magazine theme uses
Bodoni Moda headings, system body text, deep moss controls, and muted rose, linen,
sage and slate section fields. The bundled font and its OFL licence are under
`flutter/assets/fonts/`. Use the existing theme and shared widgets for controls,
opaque text colours, loading, and natural-height product grids.

Closet grid and list tiles show contained garment images only, without opaque
cards or visible item metadata. Names remain in screen-reader labels and details.
Use the primary image, then the first image as fallback. Keep loading/error and
selection states visible. Generated product images already support alpha, which
the tiles preserve. Manual and older photos can contain embedded backgrounds;
transparent tiles do not remove those pixels. Do not infer cutout quality from
filenames or silently process stored user images.

`MainShellPage` owns Home → Closet → Outfits → Studio → Profile. It creates tab
bodies on first use and retains their state. At 840 logical pixels it uses a
navigation rail. Hidden tabs and hidden Studio tools disable their tickers;
controllers continue tracking active backend jobs. Photoshoot and Try-on share
Studio. Try-on accepts one garment, as required by the existing API.

Settings → Theme offers Light, Dark and System. The choice is stored on this
device, applies immediately while offline, and is loaded before the first frame.
System follows OS appearance changes. The preferences endpoint does not accept
this three-state field, so fetching or saving other preferences must preserve the
local theme. Platform system bars use the active app theme; the dark image viewer
temporarily uses light icons and restores the underlying route style on close.

| Existing link | Destination |
|---|---|
| `/photoshoot` | Studio → Photoshoot |
| `/try-on` | Studio → Try-on |
| `/more`, `/profile` | Profile |
| Item, outfit, auth and public share routes | Existing destinations retained |

Push task screens onto the native route stack with a visible Back button. Do not
add another global navigation bar to those pages or clear history for tab changes.
Use the shell controller when linking to another main tab from inside the shell.

## Verification

`flutter analyze` treats warnings and notices as failures in Flutter CI. Run the
full `flutter test` suite for shared changes. `test/visual/` contains fixed-image
goldens for all five tabs and the welcome screen in both themes, plus Home at
320px and 1024px. The visual tests load pinned SDK fonts and Bodoni Moda, settle
lazy tab selection, and await decoded image pixels before capture. They make no
live API requests. Review the rendered images before accepting a changed golden:

```bash
flutter test test/visual/magazine_screens_test.dart
# After an intentional visual change and image review:
flutter test test/visual/magazine_screens_test.dart --update-goldens
```

Open `test/visual/preview.html` to compare the real widget renders. For a local
browser review, run this from `flutter/` and open `/preview.html` on port 8765:

```bash
python3 -m http.server 8765 --bind 127.0.0.1 --directory test/visual
```

The gallery labels fixture data and switches between light and dark snapshots.
Closet renders use four synthetic RGBA garment cutouts documented in
`test/fixtures/garment-fixtures.md`; these are test assets, not user wardrobe data.

Layout suites cover 320px phones, tablet widths, 200% text, keyboard insets and
reduced motion. These checks do not replace native screen-reader, camera, billing,
or physical-device frame-time checks. Coverage and release gates are in
`docs/exec-plans/active/flutter-premium-refresh.md`.

## Batch / AI

Prefer backend batch extract JSON base64 start endpoint from Flutter; SSE for progress. Align with `docs/BACKEND.md` batch section.

## CI

- `.github/workflows/flutter-ci.yml`
- Mobile build workflows for APK/iOS under `.github/workflows/`

Authentication is attached only to the configured API origin and the trusted
HTTPS API/image hosts in `core/network/auth_url_policy.dart`. External and
presigned requests do not carry session credentials or trigger token refresh.
Concurrent 401 responses share a refresh. Temporary refresh failures keep the
session; a confirmed rejected session signs out. Optional analytics setup starts
after the first frame and cannot stop app startup.

`supabase_flutter` is pinned to 2.15.1 (GoTrue 2.23.0) for protection against a
stale refresh replacing a newer login. The API interceptor also preserves that
new session when the old refresh is rejected. `AuthRefreshHttpClient`, passed
through `Supabase.initialize`, makes HTTP 429 retryable only on the configured
refresh-token endpoint. It uses the SDK's bounded backoff; the SDK does not
support `Retry-After`. Invalid credentials still sign out. Auth stream errors
are handled without changing the user state outside auth events.

Picker callbacks use `PermissionHelper` to distinguish denial, device restrictions,
and temporary picker failures. Android opens application settings through the
small `fitcheck/permissions` channel in `MainActivity`; iOS uses `app-settings:`.
A failed handoff shows manual recovery guidance. Process-death image recovery
remains tracked as TD-106.

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

`flutter/lib/core/services/code_push_service.dart` is registered in `main.dart`
(not `InitialBinding`, which runs too late for Sentry). It reads the running patch
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

The native gift feature is under features/gifts. It has a GetX binding,
repository, models, controller, /gifts route, and gift page. The home tab
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
which attaches the bearer token only to trusted, non-presigned destinations.
`AppImage` and `AppNetworkImage` also render generated data-URI previews and ignore
late URL refreshes after a tile changes items. Grid/list tiles should use
`thumbnail_url` when returned (`THUMBNAIL_SERVING=true` serves `_thumb`
siblings). The DB stores a bucket key, not a URL, so the backend materializes
a fresh URL at read time.
