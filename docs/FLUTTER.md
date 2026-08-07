# Flutter

Last updated: 2026-08-08

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
`flutter build` is permanently unpatchable, so every store upload must come from
the paths below. `flutter/scripts/build_ios_release.sh` is *not* one of them and
warns loudly at runtime.

| Platform | Release | Patch |
|----------|---------|-------|
| Android | `flutter/scripts/shorebird_release_android.sh` (local, then upload the `.aab` to Play) | `flutter/scripts/shorebird_patch_android.sh [release-version] [track]` (local) |
| iOS | `.github/workflows/build-ios.yml` (`workflow_dispatch` or a `v*` tag) | `.github/workflows/shorebird-patch-ios.yml` (`workflow_dispatch`) |

### Release and patch must run in the same place

`flutter/.env` is a bundled Flutter asset, so it is part of every patch diff.
Android releases are cut on the Mac from the local `.env`; iOS releases are cut in
CI from GitHub secrets. **Patch from wherever you released** — a cross-environment
patch produces an asset diff and is rejected. This is why Android has scripts and
iOS has workflows rather than one shared mechanism.

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

### iOS minimum deployment target is 15.0

App Store Connect rejects uploads with a `MinimumOSVersion` below 15.0 starting Spring 2027. The target lives in **two places that must stay in lock-step**: `IPHONEOS_DEPLOYMENT_TARGET` in `flutter/ios/Runner.xcodeproj/project.pbxproj` (every Runner build configuration) and `platform :ios` in `flutter/ios/Podfile`. Never lower either. `scripts/check_ios_deployment_target.py` enforces this in `scripts/check_all.sh`, `flutter-ci.yml`, and `build-ios.yml`.

### Image URLs are short-lived (presigned)

Image URLs are served from the private S3-compatible bucket (R2 since the 2026-08-05 egress RCA) in one of two modes, driven by backend config:

- **Presigned mode (default):** URLs are **short-lived presigned GET URLs** (~1h, `OBJECT_STORAGE_PRESIGN_TTL=3600`) that **rotate on every read** (the signature is in the query string) — they defeat disk caching, so treat them as ephemeral and re-fetch as needed.
- **Worker mode (`IMAGE_SERVING_MODE=worker`):** URLs are **stable and path-only** with `Cache-Control: public, max-age=86400, immutable`, so `CachedNetworkImage`'s disk cache and the Cloudflare edge cache both hit.

Use `AppNetworkImage` (`core/widgets/app_network_image.dart`) instead of raw
`Image.network` — it is a `CachedNetworkImage` drop-in with `authHeadersForUrl()`,
which attaches the bearer token ONLY to non-presigned URLs (S3 presigned
requests reject any other auth mechanism). Grid/list tiles should use
`thumbnail_url` when returned (`THUMBNAIL_SERVING=true` serves `_thumb`
siblings). The DB stores a bucket key, not a URL, so the backend materializes
a fresh URL at read time.
