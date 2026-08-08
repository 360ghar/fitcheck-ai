#!/usr/bin/env bash
#
# build_ios_release.sh
# ---------------------------------------------------------------------------
# Build a production, Shorebird-patchable iOS release IPA for FitCheck AI and
# prepare it for App Store upload.
#
# WHY THIS USES `shorebird release` INSTEAD OF `flutter build ipa`
#   Only a binary produced by `shorebird release` contains the Shorebird
#   engine, so it can receive over-the-air Dart patches. An IPA built by
#   plain `flutter build ipa` - including any archive made from the Xcode
#   GUI - can NEVER be patched, no matter what you do later. This script is
#   the local equivalent of `.github/workflows/build-ios.yml`, with the same
#   pinned Flutter version, the same dart-defines, and the same
#   --no-tree-shake-icons flag, so every store upload from here is patchable.
#
# WHERE THIS RUNS
#   On your Mac. The bundled `.env` asset is part of the release AND of every
#   patch diff, so release and patch builds must use the same `.env`. This
#   script never rewrites `.env` - keep it production-clean (the preflight
#   refuses localhost values) and identical across release and patch builds.
#
# USAGE
#   ./scripts/build_ios_release.sh               # build and publish
#   ./scripts/build_ios_release.sh --dry-run     # build and validate only
#
#   --dry-run builds and signs the IPA but uploads nothing, so no release is
#   created on the Shorebird account. Use it to verify the toolchain and
#   signing before the real release.
#
# SIGNING
#   ios/ExportOptions.plist uses automatic signing (team HMWGCVU4SV). Xcode
#   must be signed in to an Apple account with App Manager access
#   (Xcode > Settings > Accounts) so the App Store provisioning profile can
#   be fetched during export.
#
# PATCHES
#   A Dart-only hotfix for a release cut here must ALSO be cut here (same
#   machine, same .env, same dart-defines, same flags) so the diff is clean:
#
#     shorebird patch ios \
#       --release-version="${APP_VERSION}" \
#       --export-options-plist="ios/ExportOptions.plist" \
#       --dart-define=API_BASE_URL="${API_BASE_URL}" \
#       --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
#       --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
#       -- --no-tree-shake-icons
#
#   (`.github/workflows/shorebird-patch-ios.yml` patches CI releases; mixing
#   a local release with a CI patch only works if the .env and defines match
#   byte-for-byte.)
#
# FLAGS
#   No --obfuscate / --split-debug-info here on purpose: CI builds (and
#   therefore CI patches) do not use them, and a release whose build flags
#   differ from the patch flags is rejected or produces an unusable patch.
#   ExportOptions.plist sets uploadSymbols=false for the Sentry SPM stub
#   dSYM; upload real dSYMs with sentry-cli if you need native symbolication.
#
# REQUIREMENTS: macOS, Xcode, valid Apple Developer account, shorebird CLI.
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

# ios/ExportOptions.plist must exist and carry the real Team ID, not a
# placeholder. It is the signing + upload contract for the export.
EXPORT_OPTIONS_PLIST='ios/ExportOptions.plist'
if [ ! -f "${EXPORT_OPTIONS_PLIST}" ]; then
  die "${EXPORT_OPTIONS_PLIST} not found."
fi
if grep -q 'YOUR_TEAM_ID' "${EXPORT_OPTIONS_PLIST}"; then
  die "${EXPORT_OPTIONS_PLIST} still contains 'YOUR_TEAM_ID'. Replace it with the Apple Developer Team ID."
fi

# Production config comes from the bundled .env asset (same source the app
# falls back to at runtime), mirroring what CI writes from GitHub secrets.
API_BASE_URL="$(grep -E '^API_BASE_URL=' .env | head -1 | cut -d= -f2-)"
SUPABASE_URL="$(grep -E '^SUPABASE_URL=' .env | head -1 | cut -d= -f2-)"
SUPABASE_ANON_KEY="$(grep -E '^SUPABASE_ANON_KEY=' .env | head -1 | cut -d= -f2-)"

log "Releasing FitCheck AI ${APP_VERSION} (iOS, Flutter ${SHOREBIRD_FLUTTER_VERSION})"
log "Build args: ${SHOREBIRD_BUILD_ARGS[*]}"
[ "${DRY_RUN}" = true ] && warn "--dry-run: nothing will be uploaded."

# NOTE: the ${RELEASE_FLAGS[@]+...} guard is required on macOS bash 3.2, where
# expanding an EMPTY array under `set -u` aborts with "unbound variable".
# Flags after `--` go straight to `flutter build`; keep --no-tree-shake-icons
# identical to the CI release and patch workflows.
shorebird release ios \
  --flutter-version="${SHOREBIRD_FLUTTER_VERSION}" \
  "${RELEASE_FLAGS[@]+"${RELEASE_FLAGS[@]}"}" \
  --export-options-plist="${EXPORT_OPTIONS_PLIST}" \
  --dart-define=API_BASE_URL="${API_BASE_URL}" \
  --dart-define=SUPABASE_URL="${SUPABASE_URL}" \
  --dart-define=SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY}" \
  -- "${SHOREBIRD_BUILD_ARGS[@]}"

if [ "${DRY_RUN}" = true ]; then
  log "Dry run complete - no release was created."
  exit 0
fi

IPA_PATH="$(ls build/ios/ipa/*.ipa 2>/dev/null | head -n1 || true)"
if [ -z "${IPA_PATH}" ]; then
  die "No IPA found in build/ios/ipa/ despite a successful release."
fi

log "Release complete."
printf '\n'
printf '  IPA      %s (%s)\n' "${IPA_PATH}" "$(du -h "${IPA_PATH}" | cut -f1)"
printf '  Version  %s\n' "${APP_VERSION}"
printf '\n'
printf '  Next:\n'
printf '    1. Upload %s via Xcode Organizer or Transporter.\n' "${IPA_PATH}"
printf '    2. Leave the version/build number in App Store Connect untouched.\n'
printf '    3. To hotfix Dart code later, run the `shorebird patch ios`\n'
printf '       command from the header of this script.\n'
printf '\n'
