#!/usr/bin/env bash
#
# _shorebird_common.sh
# ---------------------------------------------------------------------------
# Shared preflight for the Shorebird Android release/patch scripts. Not
# executable on its own - source it:
#
#   source "$(dirname "${BASH_SOURCE[0]}")/_shorebird_common.sh"
#
# Everything here exists to protect the single invariant that makes code push
# work: a patch is only accepted if the binary it is diffed against is byte-for
# -byte reproducible from this machine. Any drift in the Flutter version, the
# bundled `.env` asset, or the icon tree-shaking setting turns a patch into
# either a hard "asset diff detected" rejection or, worse, a silently broken
# app on user devices.

set -euo pipefail

# ---------------------------------------------------------------------------
# Pinned Flutter version.
#
# Shorebird ships its own Flutter fork and defaults to the LATEST version it
# supports (3.44.8 at time of writing), which is NOT what CI builds. Pin it so
# a local release matches `.github/workflows/build-apk.yml`,
# `build-ios.yml`, and `flutter-ci.yml`.
#
# Keep this in lock-step with those three workflows. If you bump it, you must
# cut a NEW store release - the Flutter version of a release can never be
# changed by a patch.
# ---------------------------------------------------------------------------
SHOREBIRD_FLUTTER_VERSION='3.44.6'

# ---------------------------------------------------------------------------
# Build flags forwarded to `flutter build` after the `--` separator.
#
# --no-tree-shake-icons: Flutter normally strips MaterialIcons-Regular.otf down
# to the codepoints in use. Any patch that adds or removes an icon therefore
# changes a bundled asset, which Shorebird refuses to patch. Shipping the whole
# font (~1MB) keeps icon changes patchable and removes a known source of
# false-positive asset diffs.
#
# THIS MUST BE IDENTICAL FOR A RELEASE AND EVERY PATCH OF THAT RELEASE. Drop it
# from both or from neither - never from just one.
# ---------------------------------------------------------------------------
SHOREBIRD_BUILD_ARGS=(--no-tree-shake-icons)

# Repo paths, resolved from this file's location so the scripts work from any cwd.
SHOREBIRD_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_DIR="$(cd "${SHOREBIRD_SCRIPT_DIR}/.." && pwd)"

log()  { printf '\033[0;36m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[0;33m WARN\033[0m %s\n' "$1" >&2; }
die()  { printf '\033[0;31mERROR\033[0m %s\n' "$1" >&2; exit 1; }

shorebird_preflight() {
  cd "${FLUTTER_DIR}"

  # --- shorebird on PATH -----------------------------------------------------
  if ! command -v shorebird >/dev/null 2>&1; then
    if [ -x "${HOME}/.shorebird/bin/shorebird" ]; then
      export PATH="${HOME}/.shorebird/bin:${PATH}"
    else
      die "shorebird CLI not found. Install it with:
    curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash"
    fi
  fi

  # --- authenticated ---------------------------------------------------------
  if ! shorebird account whoami >/dev/null 2>&1; then
    die "Not logged in to Shorebird. Run: shorebird login"
  fi

  # --- shorebird.yaml present and bundled ------------------------------------
  [ -f shorebird.yaml ] || die "shorebird.yaml is missing. Run: shorebird init"
  grep -q '^\s*-\s*shorebird\.yaml\s*$' pubspec.yaml \
    || die "shorebird.yaml is not listed under 'assets:' in pubspec.yaml. The
       updater reads it at runtime and cannot find the app without it."

  # --- .env asset ------------------------------------------------------------
  # `.env` is a bundled Flutter asset (pubspec.yaml `assets: - .env`), so it is
  # baked into the binary AND into every patch diff. A localhost value here
  # ships a dead app; a value that changes between release and patch makes the
  # patch unusable.
  [ -f .env ] || die ".env is missing. Copy .env.example and fill in PRODUCTION values."

  # Match assignments only. `.env.example`-style comments legitimately mention
  # localhost, and flagging those would make this guard cry wolf.
  local local_urls
  local_urls="$(grep -nE '^[A-Za-z_][A-Za-z0-9_]*=.*(localhost|127\.0\.0\.1)' .env || true)"
  if [ -n "${local_urls}" ]; then
    die ".env points at localhost. A store release must use production values.
       Offending lines:
$(printf '%s\n' "${local_urls}" | sed 's/^/         /')"
  fi

  for key in API_BASE_URL SUPABASE_URL SUPABASE_ANON_KEY; do
    grep -qE "^${key}=.+" .env || die ".env is missing a value for ${key}."
  done

  APP_VERSION="$(grep -E '^version:' pubspec.yaml | head -1 | awk '{print $2}')"
  [ -n "${APP_VERSION}" ] || die "Could not read 'version:' from pubspec.yaml."
  export APP_VERSION

  # --- version is single-sourced from pubspec.yaml ---------------------------
  # Shorebird resolves patches by exact release version, so local builds and CI
  # builds must agree on what the version is.
  #
  # Note the Flutter Gradle tooling REGENERATES flutter.versionName/versionCode
  # in local.properties from pubspec on every build, so their presence is normal
  # and expected. What is dangerous is a hand-edited value that no longer
  # matches pubspec (this repo shipped 1.0.4+6 locally and 1.0.3+8 in CI for a
  # while) - so compare, don't just detect.
  if [ -f android/local.properties ]; then
    local want_name="${APP_VERSION%%+*}"
    local want_code="${APP_VERSION##*+}"
    local got_name got_code
    got_name="$(grep -E '^flutter\.versionName=' android/local.properties | cut -d= -f2- || true)"
    got_code="$(grep -E '^flutter\.versionCode=' android/local.properties | cut -d= -f2- || true)"

    if { [ -n "${got_name}" ] && [ "${got_name}" != "${want_name}" ]; } \
      || { [ -n "${got_code}" ] && [ "${got_code}" != "${want_code}" ]; }; then
      die "android/local.properties disagrees with pubspec.yaml about the version:
         pubspec.yaml      ${want_name}+${want_code}
         local.properties  ${got_name:-<unset>}+${got_code:-<unset>}
       Delete the flutter.versionName/flutter.versionCode lines from
       android/local.properties (Flutter rewrites them from pubspec on the next
       build). Shipping a mismatched version makes patches unresolvable."
    fi
  fi
}

# Signing is only required for a release (the artifact goes to Play). A patch
# still builds an app to diff against, so it wants the same signing config to
# keep the build reproducible.
shorebird_require_signing() {
  # android/app/build.gradle.kts silently falls back to the DEBUG signing config
  # when key.properties is absent, which produces an unshippable artifact that
  # looks successful.
  [ -f android/key.properties ] \
    || die "android/key.properties is missing, so the release build would fall back
       to DEBUG signing (see android/app/build.gradle.kts). Restore it before
       building a store artifact."

  local store_file
  store_file="$(grep -E '^storeFile=' android/key.properties | cut -d= -f2- || true)"
  if [ -n "${store_file}" ] && [ ! -f "${store_file}" ]; then
    die "Keystore not found at '${store_file}' (from android/key.properties)."
  fi
}
