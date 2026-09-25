#!/usr/bin/env bash
# Render every brand raster (app icons, launch marks, favicons) from the SVG
# masters in docs/brand/. Needs rsvg-convert and ImageMagick (`brew install
# librsvg imagemagick`). After it runs, regenerate the platform icon sets:
#   cd flutter && dart run flutter_launcher_icons
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/docs/brand"
ICONS="$ROOT/flutter/assets/icons"
IOS_LAUNCH="$ROOT/flutter/ios/Runner/Assets.xcassets/LaunchImage.imageset"
ANDROID_RES="$ROOT/flutter/android/app/src/main/res"
WEB="$ROOT/frontend/public"
ADMIN="$ROOT/admin/public"

command -v rsvg-convert >/dev/null || { echo "rsvg-convert not found" >&2; exit 1; }
command -v magick >/dev/null || { echo "magick not found" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# svg width out.png: render at a width, keep alpha.
svg() { rsvg-convert -w "$2" "$1" -o "$3"; }

# centered src.png canvas mark-width out.png: place a transparent mark on a
# square transparent canvas.
centered() {
  magick -size "$2x$2" xc:none \( "$1" -resize "$3x" \) -gravity center -composite "$4"
}

# Full-bleed icon: 1024 RGB with no alpha (App Store rule).
svg "$SRC/app-icon.svg" 1024 "$TMP/icon.png"
magick "$TMP/icon.png" -background '#E3E9F1' -alpha remove -alpha off "$ICONS/app_icon.png"

# Android adaptive layers. flutter_launcher_icons insets the foreground by
# 16%; a 720px mark keeps the fan inside the 66dp safe circle.
svg "$SRC/mark.svg" 1440 "$TMP/mark.png"
centered "$TMP/mark.png" 1024 720 "$ICONS/app_icon_foreground.png"
# Themed icons are one flat colour, so drop the slab (it reads as a lip).
sed '/class="slab"/d' "$SRC/mark-simple.svg" > "$TMP/sheet.svg"
svg "$TMP/sheet.svg" 1440 "$TMP/simple.png"
magick "$TMP/simple.png" -fill white -colorize 100 "$TMP/simple-white.png"
centered "$TMP/simple-white.png" 1024 600 "$ICONS/app_icon_monochrome.png"

# In-app mark (Flutter picks the scale from the rendered size).
magick "$TMP/mark.png" -resize 480x "$ROOT/flutter/assets/images/brand_mark.png"

# Launch screens: iOS 1x/2x/3x at 160pt wide, Android xxxhdpi at 160dp.
magick "$TMP/mark.png" -resize 160x "$IOS_LAUNCH/LaunchImage.png"
magick "$TMP/mark.png" -resize 320x "$IOS_LAUNCH/LaunchImage@2x.png"
magick "$TMP/mark.png" -resize 480x "$IOS_LAUNCH/LaunchImage@3x.png"
magick "$TMP/mark.png" -resize 640x "$ANDROID_RES/drawable-xxxhdpi/launch_mark.png"

# Web and admin.
cp "$SRC/mark-simple.svg" "$WEB/favicon.svg"
cp "$SRC/mark-simple.svg" "$ADMIN/favicon.svg"
cp "$SRC/mark.svg" "$ADMIN/brand-mark.svg"
for s in 16 32 48; do svg "$SRC/mark-simple.svg" "$s" "$TMP/fav-$s.png"; done
magick "$TMP/fav-16.png" "$TMP/fav-32.png" "$TMP/fav-48.png" "$WEB/favicon.ico"
magick "$TMP/icon.png" -alpha off -resize 180x180 "$WEB/apple-touch-icon.png"
cp "$WEB/apple-touch-icon.png" "$ADMIN/apple-touch-icon.png"
magick "$TMP/icon.png" -alpha off -resize 192x192 "$WEB/icon-192.png"
magick "$TMP/icon.png" -alpha off -resize 512x512 "$WEB/icon-512.png"

echo "Brand assets rendered. Next: cd flutter && dart run flutter_launcher_icons"
