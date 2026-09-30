# Plan: ten icon concepts

Status: superseded by user selection
Started: 2026-09-25
Owner: agent

## Goal

Generate ten distinct, polished FitCheck AI icon images for the user to select, with numbered previews and a local comparison gallery at large and favicon sizes.

## Non-goals

Production icons, application code, and public interfaces stay unchanged until a concept is selected. No deployment or store upload.

## Acceptance criteria

- [x] Ten separate generated images and their exact prompts saved in output/icon-concepts/.
- [ ] Each image reviewed for geometry, margins, artifacts, and small-size clarity.
- [ ] Numbered gallery shows each concept large and at 16, 32, and 64 CSS pixels.
- [ ] Delivery identifies any favicon simplification needed and allows selection by number.

## Context / links

- docs/brand/README.md
- output/icon-concepts/prompts.md
- scripts/render_brand_assets.sh (production asset pipeline)

## Progress log

| Date | Note |
|------|------|
| 2026-09-25 | Inspected current assets and approved ten-concept brief. Saved ten independent prompts. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-25 | Built-in image generation, one call per concept | User explicitly requested ten generated images. |
| 2026-09-25 | Display original images in an HTML gallery | Compare large and small sizes without altering source images. |

## Verification

Inspect all source images; verify image dimensions and gallery image loading; check gallery at desktop and mobile widths; run docs structure check.

## Deferred debt

None. Production vector reconstruction follows user selection and is outside this preview round.


## Selection

The user selected concept 03 (Facet F) before the comparison gallery was built.
All ten generated images were saved in output/icon-concepts/. The gallery is
no longer needed. Implementation is recorded in
docs/exec-plans/completed/2026-09-25-facet-f-brand.md.
