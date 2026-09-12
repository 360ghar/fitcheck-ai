# FitCheck Mobile — Quiet Fashion Editorial

Direction: 2026-09-05. Visual refinement requested after the first rendered pass.
Mobile has its own visual identity. Product behaviour and
honest processing vocabulary continue to follow `docs/DESIGN.md`.

## Intent

A personal fashion magazine users can operate: expressive headings, real wardrobe
photography, muted colour fields, and familiar controls. Home presents the user's
wardrobe as an editorial feature. Closet and outfit tools prioritize scanning,
selection and saving. Never invent recommendations, images or progress.

## Visual refinement contract

The first pass was too basic: equal pastel cards, small display type, oversized
introductory panels and weak photo framing concealed the fashion content.
Keep the magazine composition. The latest user direction replaces bright colour
with muted premium shades and makes the Closet listing image-only.

- Home opens with a compact FitCheck masthead and a large “The daily edit” title.
  A portrait-format outfit feature pairs real photography with a muted rose editorial
  column. The action is directly below the image. Functional shortcuts use compact
  rows and varied proportions instead of four identical icon cards.
- Closet is a garment catalogue: compact title/count, visible search, quiet category
  controls and garment cutouts on transparent, unframed tiles. Item names, brands,
  categories and descriptions appear only in details; screen-reader labels remain. Colour introduces the
  collection without pushing its contents out of the first viewport.
- Outfits is a lookbook: composition-first frames, a clear creation action and
  concise metadata. It shares Closet controls without copying its introduction.
- Studio uses a muted sage identity, a clear tool selector and a photographic example
  next to the upload task. Examples are labelled and never represented as results.
- Native navigation retains labels and states inside a compact inset dock. Forms
  keep visible labels, strong headings, calm fields and one dominant action.

References inspected: [Capsule by Chisom C-E, shared on X](https://selectedscreens.com/s/chisom-capsule-wardrobe/)
for visible outfit content and compact utilities; [Vogue Mobile Layout by Emma Choe](https://dribbble.com/shots/26137721-Vogue-Mobile-Layout)
for photographic scale and type hierarchy; [Style Lab by Exploda](https://dribbble.com/shots/27249531-Style-Lab-Fashion-Mobile-App-UI-UX-Design)
for a wardrobe-to-outfit workflow. These guide hierarchy; FitCheck keeps its own
colour and typographic identity. X blocked direct retrieval; the Capsule images
were inspected through the linked curator. No reference artwork is copied into
the app. Studio and welcome imagery reuse existing FitCheck landing assets and
are labelled as inspiration or examples, never as a user result.

## Colour

| Role | Light | Dark |
|---|---|---|
| Canvas | `#FBFAF7` | `#1F2321` |
| Surface | `#FFFFFF` | `#282D29` |
| Photo/input surface | `#F0EFE9` | `#343A35` |
| Primary action | `#3F5148` with white | `#C5CEBB` with `#1F2321` |
| Main text | `#2C302D` | `#F5F5EF` |
| Supporting text | `#646960` | `#BFC6BD` |
| Hairline | `#DEDFD5` | `#485047` |

Editorial fields use muted rose `#E6DED7`, linen `#E6E4D8`, sage `#D7DFD4`,
and slate `#DDE2E3`, with charcoal `#2C302D` text in both appearances. Rose
belongs to personal style, linen to Closet, sage to Studio and slate to Outfits.
These shades support the photography. Saturated pink, yellow, coral and cobalt
are retired. Error/warning/success retain their semantic roles. Supporting text
is opaque and meets 4.5:1 contrast. Closet tiles have no opaque card or frame.
Transparent garment pixels show the page surface through them.

## Typography and components

Bundle Bodoni Moda with its OFL licence for display/headline roles (24–44px,
weight 600). Use platform sans-serif for body, navigation, forms and controls.
Body is 14–16px with 1.4–1.5 line height; supporting labels are at least 12px.
Consume the complete ThemeData.textTheme instead of separate screen styles.

Reuse AppUiTokens, AppPageBackground, AppGlassCard and section widgets; the legacy
card name does not imply glass. Flat surfaces, 16px card/control radii, 24px sheets,
8/12/16/24/32px spacing and 48px touch targets. Use native Flutter buttons, fields
and sheets, opaque skeleton colours, clear focus and recoverable error states.

## Navigation and layout

Home → Closet → Outfits → Studio → Profile. Studio contains Photoshoot and Try-on.
The shell owns global navigation; secondary screens use an AppBar with Back.
Keep `/photoshoot`, `/try-on`, `/more`, `/profile` and feature links valid. Retain
tab scroll/input state and active jobs. Tablets use a navigation rail.

Home: editorial title, real photographic feature, muted task sections. At
640px content width the feature and tools sit side by side; large text stacks
them. The content remains capped at the existing 720px reading width.
Closet: two phone columns of contained garment images, without visible item
metadata or card backgrounds. Keep accessible item names and native detail/selection
actions. Grid and list presentations both show images only. Increase columns for
tablets; text scaling applies to the surrounding controls. Outfits: composition
frames and clear edit/wear/plan actions. Studio: tool selector, upload/configure/
progress/results and one main action. Profile/forms: grouped native controls.

## Accessibility and motion

Support 320px phones, tablets, 200% text and both appearances without clipped
controls. Label icon actions and calendar dates. Honour safe areas, keyboard
insets, native back gestures and reduced motion. Disable hidden tab tickers
without stopping job tracking. State transitions last 150–220ms. Content never
waits for a decorative entrance to become visible.

## Processing status

Use real upload bytes, backend job phases/counts, or elapsed time for opaque
operations. Never fabricate progress. Preserve results during recoverable
failures; make retry/cancel and partial success clear.

## Verification and release

Representative widget/visual tests cover Home, Closet, Studio and shared forms
with local images. Device gestures, permissions, screen readers, store-sandbox
purchases and profile frame timing are separate release checks. New font assets
require a full store release through the existing Shorebird process.
