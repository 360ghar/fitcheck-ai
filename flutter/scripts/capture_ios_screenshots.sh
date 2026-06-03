#!/usr/bin/env bash
#
# capture_ios_screenshots.sh
# ---------------------------------------------------------------------------
# Helper to capture App Store screenshots for FitCheck AI from iOS simulators.
#
# WHAT IT DOES
#   * Boots the two required simulator device classes:
#       - iPhone 6.9"  -> App Store requires 1320 x 2868 px screenshots
#       - iPad  13"    -> App Store requires 2064 x 2752 px screenshots
#   * Pauses so YOU can drive the running app to the screen you want.
#   * Captures the current simulator screen with `xcrun simctl io ... screenshot`.
#   * Post-processes each capture to the EXACT required pixel size and STRIPS the
#     alpha channel (App Store rejects screenshots with an alpha channel or with
#     dimensions even 1px off-spec).
#
# THIS IS A SCAFFOLD. It does not build or launch the Flutter app for you.
# Run it AFTER you have the app building, with the app already running on the
# target simulator (e.g. via `flutter run -d "iPhone 16 Pro Max"`), signed in
# with the seeded demo account (see docs/app-store-listing.md section 5).
#
# See docs/app-store-screenshots.md for the prioritized list of screens to grab.
#
# USAGE
#   chmod +x flutter/scripts/capture_ios_screenshots.sh
#   ./flutter/scripts/capture_ios_screenshots.sh iphone     # capture iPhone 6.9" set
#   ./flutter/scripts/capture_ios_screenshots.sh ipad       # capture iPad 13" set
#   ./flutter/scripts/capture_ios_screenshots.sh list       # list available simulators
#
# REQUIREMENTS: macOS, Xcode + command line tools (xcrun simctl), sips (built-in).
# ---------------------------------------------------------------------------

set -euo pipefail

# --- Configuration ---------------------------------------------------------

# Output directory (relative to repo root). One subfolder per device family.
OUT_ROOT="${OUT_ROOT:-fitcheck_appstore_screenshots}"

# Target device NAMES. Adjust to whatever is installed on your machine
# (run `./capture_ios_screenshots.sh list` to see exact names). Any device in
# the right size class works; ASC down-scales to smaller shelves in the family.
IPHONE_DEVICE_NAME="${IPHONE_DEVICE_NAME:-iPhone 16 Pro Max}"   # 6.9" class
IPAD_DEVICE_NAME="${IPAD_DEVICE_NAME:-iPad Pro 13-inch (M4)}"   # 13" class

# Required App Store pixel sizes (portrait). WIDTH x HEIGHT.
IPHONE_W=1320; IPHONE_H=2868
IPAD_W=2064;   IPAD_H=2752

# How many screenshots to take per family (App Store allows up to 10; aim 8-10).
SHOT_COUNT="${SHOT_COUNT:-10}"

# --- Helpers ---------------------------------------------------------------

die() { echo "ERROR: $*" >&2; exit 1; }

list_sims() {
  echo "Available simulators:"
  xcrun simctl list devices available
}

# Find the UDID of an available device by name; create/boot if needed.
udid_for_device() {
  local name="$1"
  # Grab the first available device matching the name.
  local udid
  udid="$(xcrun simctl list devices available \
    | grep -F "$name (" \
    | head -n1 \
    | sed -E 's/.*\(([0-9A-Fa-f-]{36})\).*/\1/')" || true
  [ -n "${udid:-}" ] || die "No available simulator named '$name'. Run '$0 list' and set IPHONE_DEVICE_NAME / IPAD_DEVICE_NAME."
  echo "$udid"
}

boot_sim() {
  local udid="$1"
  # 'boot' errors if already booted; ignore that specific case.
  xcrun simctl boot "$udid" 2>/dev/null || true
  open -a Simulator || true
  echo "Waiting for simulator to finish booting..."
  xcrun simctl bootstatus "$udid" -b || true
}

# Capture one screenshot from the booted device, then normalize to spec.
# args: <udid> <out_dir> <index> <target_w> <target_h>
capture_one() {
  local udid="$1" out_dir="$2" idx="$3" tw="$4" th="$5"
  local raw="${out_dir}/raw_${idx}.png"
  local final="${out_dir}/screenshot_${idx}.png"

  xcrun simctl io "$udid" screenshot "$raw" \
    || die "screenshot failed for $udid (is the device booted and unlocked?)"

  # Normalize: force EXACT target dimensions and strip alpha by re-encoding to a
  # white-background PNG. App Store requires exact size + no alpha channel.
  # --resampleHeightWidth takes HEIGHT then WIDTH.
  sips -s format png \
       --resampleHeightWidth "$th" "$tw" \
       "$raw" --out "$final" >/dev/null

  # Re-flatten to guarantee no alpha (sips keeps alpha on some inputs).
  # Composite over white, then re-export.
  sips -s format png -s formatOptions best \
       --setProperty hasAlpha no \
       "$final" --out "$final" >/dev/null 2>&1 || true

  rm -f "$raw"

  # Verify and report.
  local dims_alpha
  dims_alpha="$(sips -g pixelWidth -g pixelHeight -g hasAlpha "$final" 2>/dev/null \
    | awk '/pixelWidth|pixelHeight|hasAlpha/{print $2}' | paste -sd' ' -)"
  echo "  saved $final  (W H alpha = $dims_alpha)  [target ${tw}x${th}, alpha=no]"
}

# Drive the full capture loop for one device family.
# args: <device_name> <out_subdir> <target_w> <target_h>
run_family() {
  local name="$1" sub="$2" tw="$3" th="$4"
  local out_dir="${OUT_ROOT}/${sub}"
  mkdir -p "$out_dir"

  echo "============================================================"
  echo "Device family : $sub"
  echo "Device name   : $name"
  echo "Target size   : ${tw} x ${th} px (portrait), no alpha"
  echo "Output dir    : $out_dir"
  echo "============================================================"

  local udid; udid="$(udid_for_device "$name")"
  echo "UDID: $udid"
  boot_sim "$udid"

  cat <<EOF

NEXT STEPS (manual):
  1) In another terminal, run the app on THIS simulator, e.g.:
       flutter run -d "$name" \\
         --dart-define=API_BASE_URL=https://api.fitcheckaiapp.com \\
         --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  2) Sign in with the seeded demo account (docs/app-store-listing.md section 5).
  3) Navigate to each target screen IN ORDER (see docs/app-store-screenshots.md section 3):
        1 Wardrobe   2 AI extraction   3 Virtual try-on   4 AI photoshoot
        5 Recommendations   6 Calendar/planner   7 Analytics/stats
        8 Outfit detail   9 Dashboard   10 Gamification
  4) When the screen you want is on display, press ENTER here to capture it.

EOF

  local i=1
  while [ "$i" -le "$SHOT_COUNT" ]; do
    read -r -p "Press ENTER to capture screenshot #$i of $SHOT_COUNT (or type 's' to skip, 'q' to finish family): " ans
    case "${ans:-}" in
      q|Q) echo "Finishing $sub early."; break ;;
      s|S) echo "  skipped #$i"; i=$((i+1)); continue ;;
      *)   capture_one "$udid" "$out_dir" "$i" "$tw" "$th"; i=$((i+1)) ;;
    esac
  done

  echo "Done with $sub. Files in: $out_dir"
  echo
}

# --- Main ------------------------------------------------------------------

cmd="${1:-help}"
case "$cmd" in
  list)   list_sims ;;
  iphone) run_family "$IPHONE_DEVICE_NAME" "iphone_6.9" "$IPHONE_W" "$IPHONE_H" ;;
  ipad)   run_family "$IPAD_DEVICE_NAME"   "ipad_13"    "$IPAD_W"   "$IPAD_H" ;;
  all)
    run_family "$IPHONE_DEVICE_NAME" "iphone_6.9" "$IPHONE_W" "$IPHONE_H"
    run_family "$IPAD_DEVICE_NAME"   "ipad_13"    "$IPAD_W"   "$IPAD_H"
    ;;
  help|-h|--help|*)
    cat <<EOF
capture_ios_screenshots.sh — capture App Store screenshots from iOS simulators.

Usage:
  $0 list      List available simulators (find exact device names).
  $0 iphone    Capture the iPhone 6.9" set  (-> ${IPHONE_W}x${IPHONE_H}).
  $0 ipad      Capture the iPad 13" set      (-> ${IPAD_W}x${IPAD_H}).
  $0 all       Capture both families, one after the other.

Env overrides:
  IPHONE_DEVICE_NAME (default: "$IPHONE_DEVICE_NAME")
  IPAD_DEVICE_NAME   (default: "$IPAD_DEVICE_NAME")
  OUT_ROOT           (default: "$OUT_ROOT")
  SHOT_COUNT         (default: $SHOT_COUNT)

Run AFTER the app builds. This script boots the simulator and captures the
CURRENT screen on ENTER — you drive the app to each screen yourself.
See docs/app-store-screenshots.md for dimensions, screen list, and workflow.
EOF
    ;;
esac
