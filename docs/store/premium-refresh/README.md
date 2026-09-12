# FitCheck AI store listing images

Created 2026-09-05. English. Muted editorial palette with Bodoni Moda headings.

Open [the review gallery](gallery.html) through a local HTTP server. Download
[the complete image pack](fitcheck-store-listing-images.zip) for the 31 JPEGs,
manifest and these notes. Editable sources and original UI renders remain here.

## Deliverables

| Directory in `exports/` | Images | Pixels | Layout |
|---|---:|---|---|
| `app-store-iphone/` | 6 | 1320 × 2868 | iPhone, editorial captions |
| `app-store-ipad/` | 6 | 2064 × 2752 | iPad, navigation rail and captions |
| `play-store-phone/` | 6 | 1080 × 1920 | Android phone, short captions |
| `play-store-tablet-7/` | 6 | 1440 × 2560 | Android tablet, app UI only |
| `play-store-tablet-10/` | 6 | 1800 × 3200 | Android tablet, navigation rail, app UI only |

`exports/play-store-feature.jpg` is the 1024 × 500 feature graphic. All exports
are opaque RGB JPEGs. The six-image order is Closet, Home, Outfits, Try-on,
Photoshoot, then dark Closet. `manifest.json` contains dimensions and alt text.

The selected Apple sizes match the iPhone 6.9-inch and iPad 13-inch options.
Apple accepts up to ten images per set. [Apple screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/)

Google Play supports up to eight screenshots per device type. This pack uses
9:16 screenshots, four or more for each tablet group, no added tablet marketing
text, and phone captions confined to the top 20%. The feature graphic has no
store badges or device-brand frames. [Google Play preview asset requirements](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en)

## What the images show

The app panels are **actual Flutter widget renders with deterministic sample
data**, using the production shell, pages, theme and responsive layouts. These
are not native simulator screenshots or proof of authenticated device journeys.
No app UI was painted over, reconstructed in HTML or replaced by an AI mockup.
HTML adds only the surrounding marketing layout and type.

Try-on shows a sample person photo and one selected garment as inputs. It does
not claim to show a generated result. Photoshoot shows the app's labelled example
and upload flow. Visible account names, outfit records and garment records are
fixtures. No private account data, live AI job, purchase or store upload was used.

The cutout garments are synthetic OpenAI imagegen artwork. Their original files
and prompts are in [the garment provenance record](../../../flutter/test/fixtures/garment-fixtures.md).
The person/flatlay fixtures match the repository's existing editorial assets;
see [the mobile design record](../../../flutter/DESIGN.md). The feature graphic
uses the same synthetic ecru shirt and charcoal trousers. Bodoni Moda is bundled
with [its SIL Open Font License](source/fonts/OFL-BodoniModa.txt).

Transparent sample garments demonstrate the app's cutout rendering. Existing
manual or legacy photos with opaque backgrounds still need image processing;
the listing work does not modify stored user images.

## Reproduce

From the repository root, with Flutter, Node, Playwright/Chromium and Pillow available:

```sh
cd flutter
flutter test --no-pub --dart-define=STORE_EXPORTS=true test/visual/magazine_screens_test.dart
cd ..
node docs/store/premium-refresh/source/render.mjs
python3 docs/store/premium-refresh/source/validate.py
python3 -m http.server 8766 --bind 127.0.0.1 --directory docs/store/premium-refresh
```

Open `http://127.0.0.1:8766/gallery.html`. Edit captions and presets in
`source/screens.json`; edit marketing layout in `source/poster.html`. Raw exports
live in `raw/`; compact inspection sheets live in `review/`. Rebuild the ZIP after
changing exports or notes. The opt-in capture run does not alter the normal
visual test or golden baseline.

## Review and release boundary

The renderer checks caption placement. The validator checks all 31 filenames,
dimensions, JPEG/RGB encoding, file sizes and alt text. Visual review covers all
five sets, with full-size inspection of phone, tablet, Try-on and dark mode.
`review/native-ios-welcome-light.png` is separate native simulator startup
evidence; it is not part of the 31-image listing pack.

Before store submission, compare the pack with the final signed release on iOS
and Android and complete the native/account/accessibility/purchase release gates
in [the review plan](../../exec-plans/completed/2026-09-05-flutter-review-store-assets.md).
New bundled fonts require a full store release through the existing Shorebird
release process. Store acceptance and publication have not been performed.
