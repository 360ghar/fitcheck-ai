# Brand mark

Status: active  
Last updated: 2026-09-25

The FitCheck AI mark is three paper tees fanned from the hem. The collar of
the front tee is cut as a check mark, so the marigold tee behind shows through
as a check. The same mark is used on mobile, the web app, the landing site and
admin. Web and mobile keep their own visual systems (see `docs/DESIGN.md`).

## Files

| File | Use |
|------|-----|
| `mark.svg` | Full mark, transparent. In-app logos at 28 px wide and up. |
| `mark-simple.svg` | Front tee and slab only. Favicons and anything under 28 px. Has a dark-mode rule. |
| `app-icon.svg` | 1024 app icon: ink-stock page `#E3E9F1` with grain, mark centred. Full bleed, no pre-rounding. |

Do not edit rasters. Edit the SVG, then run:

```bash
./scripts/render_brand_assets.sh      # needs rsvg-convert + ImageMagick
cd flutter && dart run flutter_launcher_icons
```

The script writes the Flutter icon sources, the in-app mark
(`flutter/assets/images/brand_mark.png`), the iOS and Android launch marks,
the web favicon set (`favicon.svg`, `favicon.ico`, `apple-touch-icon.png`,
`icon-192.png`, `icon-512.png`) and the admin favicons. A new icon needs a
store build: Shorebird patches cannot change assets.

## Colours

| Layer | Sheet | Slab |
|-------|-------|------|
| Back tee | ink accent `#2E4A6E` | `#1B2E47` |
| Middle tee | marigold `#F2C75C` | `#6E510C` |
| Front tee | brand red `#E00016` | `#9E0010` |
| Icon page | ink stock `#E3E9F1` | none |

The slab is a hard offset copy (1.6, 2.8 in mark units), never a blur.

## Rules

- Set the mark bare. Never put it on a tile, a circle or a coloured box.
- Clear space: at least a quarter of the mark's height on every side.
- Minimum size: 28 px wide for `mark.svg`; use `mark-simple.svg` below that.
- The wordmark is "FitCheck AI". Mobile sets it in Basteleur ("FitCheck ai");
  web sets it in the web display font. The mark leads the wordmark.
- In code: web `frontend/src/components/brand/Logo.tsx` (`Logo`, `BrandMark`),
  mobile `flutter/lib/core/widgets/brand.dart` (`BrandMark`, `BrandWordmark`).
