#!/usr/bin/env bash
#
# shorebird_patch_android.sh
# ---------------------------------------------------------------------------
# Ship a Dart-only hotfix over the air to an existing Shorebird Android release.
#
# USAGE
#   ./scripts/shorebird_patch_android.sh [release-version] [track]
#
#   release-version  Defaults to `latest` (the most recently updated release).
#                    Pass an explicit "1.0.4+9" when several releases are live.
#   track            Defaults to `stable`. Use `staging` or `beta` to publish
#                    to testers first; verify with:
#                      shorebird preview --track=staging
#
# WHAT CAN AND CANNOT GO IN A PATCH
#   YES - Dart code, pure-Dart pub packages, generated .freezed/.g.dart files.
#   NO  - Native code, any change under android/ or ios/, adding or upgrading a
#         plugin that ships native code, ANY asset file (images, fonts, .env),
#         and Flutter version changes. All of those need a new store release.
#
#   Shorebird detects native and asset diffs and refuses the patch. Do NOT pass
#   --allow-native-diffs or --allow-asset-diffs to get around that: the patch
#   will build, install, and then crash on user devices, because the native
#   halves are missing from the store binary.
#
# WHY IT MUST RUN ON THIS MACHINE
#   The patch is diffed against the release artifact, which includes the bundled
#   `.env` asset. Patching from a different machine (or from CI) with a
#   different `.env` produces an asset diff and is rejected. Android releases
#   are cut here, so Android patches are too.
#
# ROLLBACK
#   Patches are not cumulative - a device jumps straight to the newest one. To
#   undo a bad patch, re-promote a known-good one:
#     shorebird patches list --release-version <v>
#     shorebird patches promote --release-version <v> --patch-number <n>
# ---------------------------------------------------------------------------

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_shorebird_common.sh"

RELEASE_VERSION="${1:-latest}"
TRACK="${2:-stable}"

shorebird_preflight
# The patch build is compiled and signed the same way the release was; a
# mismatch here shows up as a spurious native diff.
shorebird_require_signing

if [ "${RELEASE_VERSION}" != 'latest' ] && [ "${RELEASE_VERSION}" != "${APP_VERSION}" ]; then
  warn "Patching release ${RELEASE_VERSION} while pubspec.yaml says ${APP_VERSION}."
  warn "That is only correct if you deliberately checked out the released commit."
fi

log "Patching Android release ${RELEASE_VERSION} on track '${TRACK}'"
log "Build args: ${SHOREBIRD_BUILD_ARGS[*]}"

# No --flutter-version here on purpose: a patch always compiles with the Flutter
# version its release was built with, and passing one is rejected.
shorebird patch android \
  --release-version="${RELEASE_VERSION}" \
  --track="${TRACK}" \
  -- "${SHOREBIRD_BUILD_ARGS[@]}"

log "Patch published to track '${TRACK}'."
printf '\n'
printf '  Devices pick this up on their NEXT launch after the background\n'
printf '  download completes - so expect it to take two launches to appear.\n'
printf '\n'
printf '  Verify:  shorebird patches list --release-version %s\n' "${RELEASE_VERSION}"
printf '  In app:  Settings -> About -> App version shows the patch number.\n'
printf '\n'
