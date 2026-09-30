# Brand mark

Status: active  
Last updated: 2026-09-25

FitCheck AI uses Facet F: a jade folded stem and top arm, with a mint middle
arm. The user selected concept 03. `facet-f-reference.png` preserves that
approved image. `mark.svg` reconstructs its geometry as four clean vector
faces so it stays sharp at every size.

## Files

| File | Use |
|------|-----|
| `mark.svg` | Authoritative vector master; transparent, square canvas. |
| `mark-simple.svg` | Generated flat faces for favicons; adapts to dark browser themes. |
| `mark-monochrome.svg` | Generated continuous silhouette for Android themed icons. |
| `app-icon.svg` | Generated 1024 square with a dark ink background; no rounded corners or alpha. |
| `facet-f-reference.png` | Approved concept reference; not a runtime asset. |

Edit the master, then regenerate all platforms:

```bash
./scripts/render_brand_assets.sh
(cd flutter && dart run flutter_launcher_icons)
```

The first script derives SVG variants through `scripts/prepare_brand_svg.py`
and renders web/admin favicons, touch/PWA icons, Flutter sources, and launch
marks. Flutter generates iOS, Android, web, macOS, and Windows icon sets.

## Colours and placement

Jade `#078675`, mint `#74DEC0`, deep crease `#065B50`, app-icon background
`#111916`. Gradients belong only to the full mark; favicons use flat faces.
App UI colour systems and wordmark typefaces retain their existing tokens.

Use the transparent mark beside the wordmark. Its canvas is square: web and
Flutter must reserve equal width and height. The app-icon F fits within the
central maskable safe circle; operating systems apply corner masks. Native
launch screens retain their light paper background to match the Flutter splash.

Web/admin references use `?v=facet-f-1` to refresh cached favicons. Update that
revision when the artwork changes. In-app web logos load the shared SVG rather
than duplicate paths. New mobile assets require a store build, not a Shorebird
patch. This update targets version `1.2.0`, build `14`.
