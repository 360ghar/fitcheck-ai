#!/usr/bin/env bash
#
# build_ios_release.sh
# ---------------------------------------------------------------------------
# Build a production IPA for FitCheck AI and prepare it for App Store upload.
#
# WHAT IT DOES
#   1. Validates that required --dart-define flags are present (or reads from env).
#   2. Runs flutter clean for a fresh build.
#   3. Builds an obfuscated release IPA with debug symbols saved separately.
#   4. Verifies the build output exists.
#   5. Prints next steps for uploading to App Store Connect.
#
# PLACEHOLDERS YOU MUST REPLACE BEFORE RUNNING
#   Open this file and replace every <PLACEHOLDER_*> value, or export the
#   corresponding environment variable before invoking the script.
#
#   Variable                  Env fallback
#   ───────────────────────── ──────────────────────
#   SUPABASE_URL              $SUPABASE_URL
#   SUPABASE_ANON_KEY         $SUPABASE_ANON_KEY
#   SUPABASE_PUBLISHABLE_KEY  $SUPABASE_PUBLISHABLE_KEY
#   POSTHOG_API_KEY           $POSTHOG_API_KEY
#   POSTHOG_HOST              $POSTHOG_HOST
#   SENTRY_DSN                $SENTRY_DSN (optional)
#
# APPLE DEVELOPER TEAM ID
#   The ios/ExportOptions.plist file contains "YOUR_TEAM_ID". Replace it with
#   your actual Apple Developer Team ID before running this script.
#   Find it at: https://developer.apple.com/account  → Membership → Team ID
#   (a 10-character alphanumeric string, e.g. "ABC12DEF34").
#
# FLAGS EXPLAINED
#   --obfuscate
#       Obfuscates the Dart symbol names in the compiled AOT snapshot so that
#       reverse-engineering the binary is significantly harder. This is a
#       recommended security practice for production releases.
#
#   --split-debug-info=build/debug-info
#       Strips debug symbols out of the release binary (shrinking it) and
#       writes them to the specified directory. KEEP THESE FILES — you need
#       them to symbolicate crash reports from App Store Connect / TestFlight.
#       Do NOT commit this directory to version control.
#
# HOW TO UPLOAD TO APP STORE CONNECT AFTER BUILDING
#   Option A — Automatic (uses --export-options-plist with destination=upload):
#     If Xcode is signed in with an Apple account that has App Manager access,
#     the build step above may automatically upload the IPA after exporting.
#
#   Option B — Manual via Xcode:
#     1. Open Xcode → Organizer (Window > Organizer).
#     2. Select the build and click "Distribute App".
#     3. Follow the wizard to upload to App Store Connect.
#
#   Option C — Command line:
#     xcrun altool --upload-app \
#       --type ios \
#       --file build/ios/ipa/fitcheck_ai.ipa \
#       --apiKey YOUR_API_KEY \
#       --apiIssuer YOUR_ISSUER_ID
#
# USAGE
#   chmod +x flutter/scripts/build_ios_release.sh
#   ./flutter/scripts/build_ios_release.sh
#
# REQUIREMENTS: macOS, Xcode, Flutter SDK, valid Apple Developer account.
# ---------------------------------------------------------------------------

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — replace placeholders or export env vars before running.
# ---------------------------------------------------------------------------

API_BASE_URL="${API_BASE_URL:-https://api.fitcheckaiapp.com}"
SUPABASE_URL="${SUPABASE_URL:-<PLACEHOLDER_SUPABASE_URL>}"
SUPABASE_ANON_KEY="${SUPABASE_ANON_KEY:-<PLACEHOLDER_SUPABASE_ANON_KEY>}"
SUPABASE_PUBLISHABLE_KEY="${SUPABASE_PUBLISHABLE_KEY:-<PLACEHOLDER_SUPABASE_PUBLISHABLE_KEY>}"
POSTHOG_API_KEY="${POSTHOG_API_KEY:-<PLACEHOLDER_POSTHOG_API_KEY>}"
POSTHOG_HOST="${POSTHOG_HOST:-<PLACEHOLDER_POSTHOG_HOST>}"
SENTRY_DSN="${SENTRY_DSN:-}"

DEBUG_INFO_DIR="build/debug-info"
EXPORT_OPTIONS_PLIST="ios/ExportOptions.plist"

# Never package a local dev .env (e.g. localhost) into a release IPA.
# dart-defines below are the production source of truth; keep a minimal .env
# asset so Flutter asset bundling still resolves if the path is required.
if [ -f .env ]; then
  if grep -qE 'localhost|127\.0\.0\.1' .env 2>/dev/null; then
    echo "WARNING: flutter/.env contains localhost — writing a production-only .env for this build."
    cat > .env <<ENVFILE
API_BASE_URL=$API_BASE_URL
SUPABASE_URL=$SUPABASE_URL
SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY
POSTHOG_API_KEY=$POSTHOG_API_KEY
POSTHOG_HOST=$POSTHOG_HOST
SENTRY_DSN=$SENTRY_DSN
ENVFILE
  fi
fi

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------

echo "========================================"
echo " FitCheck AI — iOS Release Build"
echo "========================================"
echo

command -v flutter >/dev/null 2>&1 || { echo "ERROR: flutter not found on PATH." >&2; exit 1; }

# Verify no placeholders remain.
placeholders=()
for var_name in SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_PUBLISHABLE_KEY POSTHOG_API_KEY POSTHOG_HOST; do
  value="${!var_name}"
  if [[ "$value" == \<PLACEHOLDER_* ]]; then
    placeholders+=("$var_name")
  fi
done

if [ ${#placeholders[@]} -gt 0 ]; then
  echo "ERROR: The following variables still contain placeholder values:"
  for p in "${placeholders[@]}"; do
    echo "  - $p"
  done
  cat <<EOF

Set them via environment variables, e.g.:
  export SUPABASE_URL=https://your-project.supabase.co
  export SUPABASE_ANON_KEY=eyJ...
  ...
  ./flutter/scripts/build_ios_release.sh

Or edit the script directly to hardcode the production values.
EOF
  exit 1
fi

# Verify ExportOptions.plist exists and is not using the default team ID.
if [ ! -f "$EXPORT_OPTIONS_PLIST" ]; then
  echo "ERROR: $EXPORT_OPTIONS_PLIST not found."
  echo "Create it first (see ios/ExportOptions.plist in the repo) and set your Team ID."
  exit 1
fi

if grep -q "YOUR_TEAM_ID" "$EXPORT_OPTIONS_PLIST"; then
  echo "ERROR: $EXPORT_OPTIONS_PLIST still contains 'YOUR_TEAM_ID'."
  echo "Replace it with your actual Apple Developer Team ID:"
  echo "  https://developer.apple.com/account → Membership → Team ID"
  exit 1
fi

echo "Configuration:"
echo "  API_BASE_URL            = $API_BASE_URL"
echo "  SUPABASE_URL            = ${SUPABASE_URL:0:30}..."
echo "  SUPABASE_ANON_KEY       = ${SUPABASE_ANON_KEY:0:10}..."
echo "  SUPABASE_PUBLISHABLE_KEY= ${SUPABASE_PUBLISHABLE_KEY:0:10}..."
echo "  POSTHOG_API_KEY         = ${POSTHOG_API_KEY:0:6}..."
echo "  POSTHOG_HOST            = $POSTHOG_HOST"
echo "  SENTRY_DSN              = ${SENTRY_DSN:+set}"
echo "  Debug info dir          = $DEBUG_INFO_DIR"
echo "  Export options plist    = $EXPORT_OPTIONS_PLIST"
echo

# ---------------------------------------------------------------------------
# Clean
# ---------------------------------------------------------------------------

echo ">>> flutter clean"
flutter clean
echo

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

echo ">>> flutter build ipa --release"
flutter build ipa \
  --release \
  --obfuscate \
  --split-debug-info="$DEBUG_INFO_DIR" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="$SUPABASE_PUBLISHABLE_KEY" \
  --dart-define=POSTHOG_API_KEY="$POSTHOG_API_KEY" \
  --dart-define=POSTHOG_HOST="$POSTHOG_HOST" \
  --dart-define=SENTRY_DSN="$SENTRY_DSN" \
  --export-options-plist="$EXPORT_OPTIONS_PLIST"

echo

# ---------------------------------------------------------------------------
# Verify output
# ---------------------------------------------------------------------------

IPA_DIR="build/ios/ipa"
if ls "$IPA_DIR"/*.ipa 1>/dev/null 2>&1; then
  IPA_PATH="$(ls "$IPA_DIR"/*.ipa | head -n1)"
  echo "========================================"
  echo " BUILD SUCCEEDED"
  echo "========================================"
  echo "  IPA:           $IPA_PATH"
  echo "  Debug symbols: $DEBUG_INFO_DIR/"
  echo "  IPA size:      $(du -h "$IPA_PATH" | cut -f1)"
  echo
else
  echo "========================================"
  echo " BUILD FAILED — no IPA found in $IPA_DIR/"
  echo "========================================"
  exit 1
fi

# ---------------------------------------------------------------------------
# Next steps
# ---------------------------------------------------------------------------

cat <<EOF
NEXT STEPS — Upload to App Store Connect:

  Option A — Xcode Organizer:
    1. Open Xcode → Window → Organizer.
    2. Select this build and click "Distribute App".
    3. Follow the wizard to upload to App Store Connect.

  Option B — Command line (xcrun altool):
    xcrun altool --upload-app \\
      --type ios \\
      --file "$IPA_PATH" \\
      --apiKey YOUR_API_KEY \\
      --apiIssuer YOUR_ISSUER_ID

  IMPORTANT:
    - Keep the files in $DEBUG_INFO_DIR/ safe.
      You need them to symbolicate crash reports from TestFlight / App Store.
    - Do NOT commit debug-info files to version control.
    - After upload, configure TestFlight testing in App Store Connect before
      submitting for review.

Build complete. Good luck!
EOF
