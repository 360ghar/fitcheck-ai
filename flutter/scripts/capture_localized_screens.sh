#!/usr/bin/env bash
#
# capture_localized_screens.sh
# ---------------------------------------------------------------------------
# Produce localized App Store screen sources, one directory per locale.
#
#   store/creative/source/screens/<locale>/{closet,today,more,tryon,photoshoot,matches}.png
#
# The Node renderer looks for a locale-specific screen first and falls back to
# the shared English capture, so a locale that has not been captured here simply
# keeps the English screenshot inside its frame.
#
# HOW IT WORKS
#   The `test/visual/*_golden_test.dart` suite already renders every screen with
#   a fixed demo wardrobe through fake repositories - deterministic, offline, no
#   account. With `--dart-define=STORE_CAPTURE_LOCALE=<asc>` those same renders
#   run in the requested locale and are written to `build/store_capture/<asc>/`
#   instead of over the committed English goldens. A post-process pass maps the
#   six screens we need onto 760x1643 and drops them in the store tree.
#
#   Nothing here touches `flutter/lib/**`: locale injection happens in the test
#   harness only, and non-Latin scripts swap in a single system face because the
#   Flutter test shell has no platform font fallback.
#
# USAGE
#   ./scripts/capture_localized_screens.sh ja
#   ./scripts/capture_localized_screens.sh ja ar-SA hi de
#   ./scripts/capture_localized_screens.sh --all-latin    # the Latin-script set
#
# Non-interactive: safe to run in a loop, a Makefile or CI. Re-running a locale
# overwrites its six files and leaves other locales alone.
#
# REQUIREMENTS: flutter on PATH, python3 with Pillow (`pip install pillow`).
# ---------------------------------------------------------------------------

set -euo pipefail

cd "$(dirname "$0")/.."

# Locales whose script Roboto already covers, so the capture renders with the
# app's own Basteleur headlines and Roboto body: every one that is not in
# `scriptFallbackFontFor()` in test/visual/store_capture.dart.
LATIN_LOCALES=(
  en-US en-GB en-AU en-CA es-ES es-MX pt-BR pt-PT fr-FR fr-CA
  de-DE it nl-NL sv no da fi pl cs sk sl-SI hr ro hu el tr id ms vi ca
)

TESTS=(
  test/visual/wardrobe_golden_test.dart
  test/visual/dashboard_golden_test.dart
  test/visual/more_golden_test.dart
  test/visual/photoshoot_golden_test.dart
  test/visual/plan_golden_test.dart
)

if [ "$#" -eq 0 ]; then
  sed -n '3,30p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
fi

if [ "${1:-}" = "--all-latin" ]; then
  set -- "${LATIN_LOCALES[@]}"
fi

python3 -c 'import PIL' 2>/dev/null || {
  echo "ERROR: python3 Pillow is required (pip install pillow)" >&2
  exit 1
}

failures=0
for locale in "$@"; do
  start=$(date +%s)
  echo "== $locale"

  # --dart-define is the whole mechanism; the comparator installed by the
  # harness writes to build/store_capture/<locale>/ and always passes.
  if ! flutter test --dart-define=STORE_CAPTURE_LOCALE="$locale" "${TESTS[@]}"; then
    echo "ERROR: capture failed for $locale" >&2
    failures=$((failures + 1))
    continue
  fi

  python3 scripts/store_capture_post.py "$locale"
  echo "   $locale done in $(( $(date +%s) - start ))s"
done

if [ "$failures" -ne 0 ]; then
  echo "ERROR: $failures locale(s) failed" >&2
  exit 1
fi
