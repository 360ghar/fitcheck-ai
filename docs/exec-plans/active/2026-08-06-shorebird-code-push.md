# Plan: Shorebird code push (OTA updates)

Status: active  
Started: 2026-08-06  
Owner: agent / human

## Goal

Ship Dart-only fixes to the Flutter app over the air instead of through a full
store release. Before this, the app had no update mechanism of any kind — no force
update, no remote config, no version check — so every one-line Dart fix cost an App
Store review cycle plus a Play rollout, and users who never updated stayed broken.
Success is: a Dart-only hotfix reaches Android and iOS users within minutes of
merging, with the patch number visible in-app and attributed on Sentry crashes.

## Non-goals

- Patching native code, plugins, or assets. Those still require a store release,
  and Shorebird correctly refuses them.
- Retrofitting code push onto builds already on the stores. Only binaries produced
  by `shorebird release` are patchable, so code push starts at the next release.
- Moving Android signing into CI. The keystore stays on the Mac; Android releases
  and patches both run there.
- Web/macOS/Windows code push. Android + iOS only.
- A force-update / minimum-version gate. Still absent, still worth having, tracked
  separately.

## Acceptance criteria

- [x] `flutter/shorebird.yaml` committed and listed in `pubspec.yaml` `assets:`
- [x] Flutter pinned to 3.44.6 in every Shorebird call site (verified supported)
- [x] `flutter/android/local.properties` version drift (1.0.4+6 vs pubspec 1.0.3+8)
      resolved, with a preflight guard so it cannot silently return
- [x] `CodePushService` reports the patch number to Sentry `dist` and Settings,
      and is provably inert when the updater is unavailable (9 unit tests)
- [x] Android release/patch scripts with `.env`, signing, and version preflight
- [x] `build-ios.yml` builds with `shorebird release ios` so every TestFlight build
      is patchable
- [x] `shorebird-patch-ios.yml` reproduces that build exactly and ships patches
- [x] `build_ios_release.sh` warns at runtime that its output is unpatchable
- [x] `docs/FLUTTER.md` documents the workflow and the lock-step invariants
- [x] `pubspec.yaml` bumped to `1.0.4+9` for the first Shorebird release, above
      every build number evidenced anywhere in the repo
- [ ] `SHOREBIRD_TOKEN` created and added as a GitHub repo secret (**human**)
- [ ] End-to-end Android release → patch → two launches verified on a device
- [ ] End-to-end iOS release → patch verified on a **physical** arm64 device

## Context / links

- Related docs: `docs/FLUTTER.md` (Code push section)
- Related code: `flutter/shorebird.yaml`,
  `flutter/lib/core/services/code_push_service.dart`,
  `flutter/scripts/_shorebird_common.sh`,
  `flutter/scripts/shorebird_release_android.sh`,
  `flutter/scripts/shorebird_patch_android.sh`,
  `.github/workflows/build-ios.yml`,
  `.github/workflows/shorebird-patch-ios.yml`
- External: https://docs.shorebird.dev — Shorebird CLI 1.6.115, app_id
  `525158a1-b148-4745-83ce-8e189e3334d3`, free tier (5,000 patch installs/month)

## Progress log

| Date | Note |
|------|------|
| 2026-08-06 | Verified Flutter 3.44.6 is Shorebird-supported; CLI already installed and authenticated |
| 2026-08-06 | Ran `shorebird init`; it also added two entitlements to `flutter/macos/Runner/Release.entitlements` (unshipped scaffold target, kept to avoid churning against `shorebird doctor`) |
| 2026-08-06 | Shorebird's Flutter ran the standard Gradle migrator, adding `android.builtInKotlin=false` / `android.newDsl=false` to `flutter/android/gradle.properties`; kept and committed so local and CI builds match |
| 2026-08-06 | Implemented service + scripts + both workflows + docs |
| 2026-08-06 | Bumped `pubspec.yaml` to `1.0.4+9`, backfilled `flutter/CHANGELOG.md` (stale since `1.0.3+5`), and replaced the Profile dialog's hardcoded `Version 1.0.0` with a shared `AppVersionLabel` used by Settings too |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-06 | Pin `--flutter-version=3.44.6` rather than adopt Shorebird's 3.44.8 default | Keeps the toolchain identical to the three existing workflows; a Flutter bump would need its own release and regression pass |
| 2026-08-06 | Android release + patch run locally; iOS release + patch run in CI | `.env` is a bundled asset and part of every patch diff. Android's keystore is Mac-only and iOS's signing is CI-only, so each platform patches from wherever it releases |
| 2026-08-06 | Convert `build-ios.yml` in place instead of adding a parallel workflow | Two iOS release paths would eventually ship an unpatchable build by accident |
| 2026-08-06 | Pass `--no-tree-shake-icons` on every release and patch | Otherwise adding one Material icon in a patch changes the tree-shaken font, reads as an asset diff, and blocks the patch. Costs ~1MB |
| 2026-08-06 | Use Sentry `options.dist`, not a modified `options.release` | `dist` is Sentry's own "distribution within a release" field; changing `release` per patch would fragment release tracking |
| 2026-08-06 | Drop `subosito/flutter-action` and the standalone `pod install --repo-update` from `build-ios.yml` | Two Flutter installs on one runner is the documented cause of `Invalid Podfile` / FLUTTER_ROOT mismatch; Shorebird runs pub get and CocoaPods itself, and `Podfile.lock` is committed |
| 2026-08-06 | Unsigned CI path uses `shorebird release ios --dry-run` | Validates the build on forks without creating junk releases |
| 2026-08-06 | Preflight compares local.properties against pubspec rather than rejecting the keys outright | Flutter's Gradle tooling regenerates those keys from pubspec on every build, so their presence is normal — only a mismatch is dangerous |
| 2026-08-06 | First Shorebird release is `1.0.4+9` | Build 9 is strictly above 8, the highest number evidenced anywhere (git tops out at `1.0.3+8`; ASC rejected build 7 and has nothing live; builds 6 and 7 never existed in git). `1.0.4` was already the intended next name — it had been hand-set in `local.properties`. Confirmed with the user that nothing above 8 was uploaded out-of-band |
| 2026-08-06 | One `AppVersionLabel` widget instead of two `PackageInfo` call sites | The Profile dialog hardcoded `Version 1.0.0` for three releases. A single formatting path means Settings and Profile cannot disagree and neither can go stale, and both pick up the patch number for free |

## Verification

```bash
# Repo harness
python scripts/check_docs_structure.py
python scripts/check_architecture.py

# Flutter
cd flutter && flutter pub get && flutter analyze --no-fatal-infos --no-fatal-warnings && flutter test

# Shorebird toolchain
shorebird doctor -v
cd flutter && ./scripts/shorebird_release_android.sh --dry-run   # builds, uploads nothing
```

End-to-end (Android first — no device signing dance, and emulators are supported):

1. `./scripts/shorebird_release_android.sh`, then
   `shorebird releases get-apks --release-version <v>` and install.
2. Confirm `adb logcat | grep -i shorebird` shows the updater. Its absence means
   the binary is not patchable.
3. Confirm Settings → About shows the version with no patch segment.
4. Make a trivial visible Dart change; `./scripts/shorebird_patch_android.sh`.
5. Relaunch **twice**; confirm the change is live and Settings reads `· patch 1`.
6. Force a crash; confirm Sentry tags it `dist = 1`.

iOS needs a physical arm64 device (the Simulator is unsupported): run
`build-ios.yml` → TestFlight → install → run `shorebird-patch-ios.yml` → relaunch
twice.

Negative checks that must fail loudly: bumping a plugin version, or changing an
image under `assets/`, must both be refused when patching.

## Deferred debt

Tracked in `docs/exec-plans/tech-debt-tracker.md` as **TD-075** (Flutter 3.44.6
duplicated across five files), **TD-076** (`build-apk.yml` produces a debug-signed,
unpatchable APK), and **TD-077** (no force-update / minimum-version gate).

Resolved on 2026-08-06, no longer debt:

- ~~Store version numbers are unverified.~~ `pubspec.yaml` is now `1.0.4+9` and
  `flutter/CHANGELOG.md` is caught up. The residual unknown — whether a
  `1.0.4+6` build ever actually reached Play — does not affect correctness:
  Play only requires the version *code* to increase, and 9 > 6.
