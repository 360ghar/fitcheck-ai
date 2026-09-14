# FitCheck AI — Store screenshots

**Last updated:** 2026-09-05

Use the [premium refresh asset pack](premium-refresh/README.md) for the current
screenshots, gallery, source fixtures, export commands, and validation steps. This
pack replaces the previous capture plan and the older low-resolution assets.

## Current exports

Each screenshot set contains six portrait JPEGs. The feature graphic is separate.
All paths below are relative to `docs/store/premium-refresh/`.

| Store / device | Dimensions | Files | Export directory |
|---|---|---|---|
| App Store — iPhone 6.9-inch | 1320 × 2868 | 6 | `exports/app-store-iphone/` |
| App Store — iPad 13-inch | 2064 × 2752 | 6 | `exports/app-store-ipad/` |
| Google Play — phone | 1080 × 1920 | 6 | `exports/play-store-phone/` |
| Google Play — 7-inch tablet | 1440 × 2560 | 6 | `exports/play-store-tablet-7/` |
| Google Play — 10-inch tablet | 1800 × 3200 | 6 | `exports/play-store-tablet-10/` |

Google Play feature graphic: **1024 × 500**, at
[`exports/play-store-feature.jpg`](premium-refresh/exports/play-store-feature.jpg).

The selected iPhone and iPad dimensions are accepted portrait sizes in
[Apple's screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/).
Apple accepts one to ten JPEG or PNG screenshots, without alpha or transparency.
These are the dimensions chosen for this pack, not the only sizes Apple accepts.

The Play screenshot sets use 9:16 portrait images. Google allows up to eight
screenshots per device type; its large-screen guidance calls for at least four
images and no added text outside the app. Phone taglines in this pack occupy less
than 20% of the image. The feature graphic uses the required 1024 × 500 size.
See [Google Play's preview asset specifications](https://support.google.com/googleplay/android-developer/answer/9866151?hl=en).

## Screen order and content

| File stem | App screen | Content shown |
|---|---|---|
| `01-closet` | Closet | Garment images, search, categories, and Add item |
| `02-home` | Home | Daily outfit and wardrobe shortcuts |
| `03-outfits` | Outfits / Lookbook | Saved outfit compositions and Create outfit |
| `04-tryon` | Studio / Try-on | Sample portrait and one garment selected as inputs |
| `05-photoshoot` | Studio / Photoshoot | Labelled example and photo upload actions |
| `06-dark-closet` | Closet, dark mode | Garment images and dark interface controls |

The screen pixels come from the actual Flutter views rendered with deterministic
sample data in a widget-test fixture. They are not native device captures or live
account sessions. Try-on shows inputs; Photoshoot shows its labelled example and
setup screen. Neither presents a fabricated AI result as a completed generation.

Exports follow the muted palette and image-only Closet in
[`flutter/DESIGN.md`](../../flutter/DESIGN.md). Google tablet exports contain raw
app UI without added marketing text or device frames. Phone exports keep the app
visible with a short tagline. The [manifest](premium-refresh/manifest.json) records
file dimensions and alt text.

## Before upload

1. Review the [gallery](premium-refresh/gallery.html) against the release build,
   including the tablet layout and Studio labels.
2. Run the validation command in the [asset pack README](premium-refresh/README.md)
   to check all 31 JPEGs, exact dimensions, RGB mode, and alt text.
3. Confirm sample content and feature descriptions match the release. These
   fixture renders do not replace native device or live backend verification.
4. Upload the six images to each matching device section, in the order above,
   and upload the separate Play feature graphic.
5. Check store previews and alt text before submitting. Account, review, and
   pricing records remain in the [Apple listing](app-store-listing.md) and
   [Google Play listing](play-store-aso.md).
