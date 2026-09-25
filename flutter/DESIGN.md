# DESIGN.md — FitCheck AI (Mobile / Flutter)

Design reference for the Flutter client. Direction: **paper-cut diorama**.
Every screen is cut from coloured paper: flat sheets stacked over solid,
offset paper slabs, a fine grain, torn edges where a surface is a signature
piece, and layered paper scenes at a few signature moments. Photos stay the
hero; the paper frames them.

Mobile now diverges from web (`frontend/DESIGN.md`) on purpose. Shared with
web: brand red for primary actions, the processing-status vocabulary (§09),
product intent (`docs/DESIGN.md`).

> Code: tokens `lib/core/theme/paper_tokens.dart`, theme
> `lib/core/theme/paper_theme.dart`, borders `paper_borders.dart`, widgets
> `lib/core/widgets/` (`paper.dart`, `paper_scene.dart`, `app_states.dart`,
> `skeletons.dart`, `app_bottom_navigation_bar.dart`). Architecture and the
> screen-state rule: `docs/FLUTTER.md`.

---

## 01 — Colour: paper stocks

Five stocks. Each main tab owns one, and every screen of that feature uses
it through `PaperStockScope`. The whole Material `ColorScheme` follows the
stock, so components need no per-widget colours.

| Stock | Used by | Light page / accent | Dark page / accent |
|-------|---------|---------------------|--------------------|
| ink | Home, auth, splash, recommendations | `#E3E9F1` / `#2E4A6E` | `#0F1B30` / `#A7C0E2` |
| clay | Photoshoot, try-on, calendar | `#F1E0D6` / `#8C4026` | `#22150F` / `#E9A487` |
| moss | Closet and item flows | `#E2E9DA` / `#3F5E36` | `#151D13` / `#A9C79A` |
| marigold | Outfits, collections, gifts | `#F5E6BF` / `#6E510C` | `#211A0A` / `#E8C66A` |
| stone | More, settings, sheets, dialogs | `#E7E6E1` / `#3A3A35` | `#1A1917` / `#D6D2C8` |

Each stock also defines `card` (raised sheet), `sunk` (skeletons, image
wells), `tint` (selected), `edge` (hairline), `shadow` (the slab) and
`onAccent`.

- **Brand red** `#E00016` is only for filled buttons and the FAB (the theme
  styles them; slab `#9E0010` light, `#7A000C` dark). Everything else uses
  the stock's tonal accent.
- **Text**: primary `#1C1B17` / `#F1EFE9`, secondary `#45433C` / `#CFCBC1`,
  muted `#5B5951` / `#A8A49A`.
- **Status**: success `#285E37` / `#8FD0A0`, warning `#7F5300` / `#F0C060`,
  error `#A3140F` / `#FF9B92`.
- **Contrast**: `test/core/theme/paper_tokens_test.dart` checks WCAG AA for
  every text role and accent on every stock surface, in both modes.
- No gradients (scrims over photos excepted), no glows, no purple.

## 02 — Type

- **Display and headlines**: Basteleur (Velvetyne, SIL OFL,
  `assets/fonts/`). Bold (700) for `display*` (tab titles, big figures),
  Moonlight (400) for `headline*` (screen and section titles, app bar).
- **Body**: the platform font (SF Pro / Roboto).
- Basteleur's zero is slashed: show a lone zero figure with
  `paperFigure(value)`, which renders a dash.
- Sentence case everywhere. No tracked uppercase labels.

## 03 — Surfaces and components

- **PaperSurface** (`AppGlassCard` is an alias): a sheet in the stock's card
  colour over a solid slab offset (1.5, 3). No blur. With `onTap` it presses
  down onto its slab. `grain: false` when a photo covers it; `deckle:` tears
  one edge for signature pieces (banners, collections, empty states).
- **Buttons**: filled = red with a darker slab; outlined = card-coloured
  sheet with an edge-coloured slab; text buttons for secondary actions. One
  primary action per screen. Never a filled + outlined pair as the default
  action row.
- **Bottom sheets**: torn top edge (`DeckleBorder`). Dialogs: card sheet
  with a slab.
- **Bottom navigation**: a full-width paper strip with a torn top edge in
  the active tab's stock; a tint chip slides under the selected tab; filled
  icon when active, outlined when not. No red, no dots.
- **Chips**: filter chips only for real filters. Selected = tint fill +
  accent label. Metadata is plain text, not pills.
- **Icons**: bare Material rounded/outlined icons in the accent or text
  colour, never in a tinted tile. Garment placeholders use `GarmentGlyph`,
  cut-paper silhouettes drawn from the scene shapes.

## 04 — Scenes (signature moments)

`PaperScene` stacks cut-paper layers (torn ridges, a sun, a washing line of
garments) with scroll parallax and a slow garment sway. Presets:
`home`, `closet`, `outfits`, `studio`, `offline`, `oops`, `auth`. Use them
only for tab headers, empty and error states, auth and splash.

## 05 — Screen states

Loading = skeleton (`Skeleton*`, a slow tone pulse, never a bare spinner).
Error with nothing loaded = `AppErrorState` (copy and scene follow the error
type). Empty = `AppEmptyState` (first-run action, or "No … match" with Clear
filters). Stale data + failed refresh = `AppErrorBanner` with Retry.

## 06 — Layout, spacing, radius

- Spacing tokens in `AppConstants` (4, 6, 8, 12, 16, 20, 24, 32). 16px page
  gutters, 20px for tab titles.
- Radius 12 for surfaces and buttons, 16 for cards, 24 for dialogs and
  sheets.
- Grids leave 3px extra run spacing for the paper slab.
- Content is capped at 720px on tablets (`AppPageBackground`).
- Closet rows (the default Closet view): one horizontal row per category in
  dressing order (tops, bottoms, accessories, shoes, then the rest). A row is
  the category name plus its count in secondary text, then the bare item
  images: no card, border, background or name. Cells are 104×128 with a 12px
  gap and a 20px gutter, so the 4th piece peeks at the right edge of a 390pt
  phone. A filter or a search shows the grid of matches instead.

## 07 — Motion

Motion only on visible content: press-down on paper, the sliding nav chip,
scene parallax and sway, the skeleton tone pulse. Never gate content behind
an entrance animation. Everything honours `MediaQuery.disableAnimations`.

---

## 08 — Accessibility

- **WCAG AA** contrast on all text.
- **Touch targets:** 44px minimum (Material min tap target). Buttons ~40px with
  inline padding extend to 44px.
- Semantic labels on icon-only `IconButton`s (`tooltip` / `Semantics`).
- Visible focus on interactive elements.

---

## 09 — Processing-status vocabulary (AI jobs)

Every flow that waits on a backend job aligns its copy to this table. Never
fabricate progress or completion. Drives batch upload, photoshoot, try-on,
outfit generation, social import, avatar upload.

| Phase | When | Copy pattern |
|-------|------|--------------|
| Uploading | Client sending image bytes | "Uploading photo…" (+ real byte % if available, else indeterminate) |
| Queued | Backend genuinely queued (batch, photoshoot, social import) | "Queued…" |
| Processing (phase-specific) | Backend reports a real sub-phase via SSE | Backend's own strings: "Extracting items…", "Generating photos…", "3 of 10 processed" |
| Processing (opaque) | Single sync call, no phases (try-on, outfit gen, avatar) | "Processing… (Ns elapsed)" — elapsed only, never fake % |
| Done | Terminal success | Brief confirmation |
| Failed | Terminal failure | Real error message + retry action |

Prefer backend batch extract JSON base64 start endpoint from Flutter; SSE for
progress (see `docs/BACKEND.md` batch section and `docs/FLUTTER.md`).

---

## Related

- `docs/DESIGN.md` — product intent + canonical processing-status source.
- `frontend/DESIGN.md` — web design (mobile diverges visually; brand red and status copy are shared).
- `docs/FLUTTER.md` — mobile architecture, commands, conventions.
