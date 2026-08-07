#!/usr/bin/env bash
#
# shorebird_release_android.sh
# ---------------------------------------------------------------------------
# Cut a Shorebird Android release: a signed .aab that you upload to Google Play
# and that can subsequently receive over-the-air Dart patches.
#
# WHY THIS EXISTS INSTEAD OF `flutter build appbundle`
#   Only a binary produced by `shorebird release` contains the Shorebird engine.
#   An .aab built by plain `flutter build` can NEVER be patched, no matter what
#   you do later. Every store upload must come from this script (or from the
#   equivalent CI path on iOS) or code push is dead for that version.
#
# WHERE THIS RUNS
#   On your Mac, not in CI. The upload keystore lives only here, and the `.env`
#   asset baked into the release must be byte-identical in the release and in
#   every patch of it - so release and patch both run from this machine.
#   iOS is the mirror image: both its release and its patches run in CI.
#
# USAGE
#   ./scripts/shorebird_release_android.sh              # build and publish
#   ./scripts/shorebird_release_android.sh --dry-run    # build and validate only
#
#   --dry-run builds the bundle and runs every check but uploads nothing, so no
#   release is created on the Shorebird account. Use it to verify the toolchain.
#
# AFTER IT SUCCEEDS
#   1. Upload the .aab to Play Console.
#   2. Do NOT edit the version code or version name in Play Console. Shorebird
#      resolves patches against the version recorded at release time; changing
#      it there breaks patching for that release permanently.
#   3. Ship Dart-only fixes with ./scripts/shorebird_patch_android.sh
# ---------------------------------------------------------------------------

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_shorebird_common.sh"

RELEASE_FLAGS=()
DRY_RUN=false
if [ "${1:-}" = '--dry-run' ]; then
  RELEASE_FLAGS+=(--dry-run)
  DRY_RUN=true
elif [ -n "${1:-}" ]; then
  die "Unknown argument '${1}'. Usage: $0 [--dry-run]"
fi

shorebird_preflight
shorebird_require_signing

log "Releasing FitCheck AI ${APP_VERSION} (Android, Flutter ${SHOREBIRD_FLUTTER_VERSION})"
log "Build args: ${SHOREBIRD_BUILD_ARGS[*]}"
[ "${DRY_RUN}" = true ] && warn "--dry-run: nothing will be uploaded."

# --artifact defaults to aab, which is what Play requires. Note that
# --split-per-abi is NOT supported by Shorebird: split APKs each get a
# different release version than pubspec declares, which patching cannot model.
shorebird release android \
  --flutter-version="${SHOREBIRD_FLUTTER_VERSION}" \
  "${RELEASE_FLAGS[@]}" \
  -- "${SHOREBIRD_BUILD_ARGS[@]}"

if [ "${DRY_RUN}" = true ]; then
  log "Dry run complete - no release was created."
  exit 0
fi

AAB_PATH='build/app/outputs/bundle/release/app-release.aab'

if [ ! -f "${AAB_PATH}" ]; then
  die "Expected bundle not found at ${AAB_PATH} despite a successful release."
fi

log "Release complete."
printf '\n'
printf '  Bundle   %s (%s)\n' "${AAB_PATH}" "$(du -h "${AAB_PATH}" | cut -f1)"
printf '  Version  %s\n' "${APP_VERSION}"
printf '\n'
printf '  Next:\n'
printf '    1. Upload %s to Play Console.\n' "${AAB_PATH}"
printf '    2. Leave the version code/name in Play Console untouched.\n'
printf '    3. To test on a device before shipping:\n'
printf '         shorebird preview --release-version %s\n' "${APP_VERSION}"
printf '    4. To hotfix Dart code later:\n'
printf '         ./scripts/shorebird_patch_android.sh %s\n' "${APP_VERSION}"
printf '\n'
