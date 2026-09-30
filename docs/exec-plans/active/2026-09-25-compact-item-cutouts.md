# Plan: Compact item cutouts

Status: active  
Started: 2026-09-25  
Owner: agent

## Goal

Item cutouts are cropped to the item plus a small transparent pad, the matte and the backfill script run faster, and the web and mobile item grids show more items per screen.

## Non-goals

- Cropping outfit flat-lays (outfit tiles use `object-cover`).
- Switching Flutter grids to thumbnails (`ItemImage` has no `thumbnailUrl`).

## Acceptance criteria

- [x] `remove_white_background(crop=True)` trims to content plus a pad. A re-run is a no-op.
- [x] The product-image path passes `crop=True`. The flat-lay path stays full-frame.
- [x] The backfill runs on one event loop, crops `item_images`, and rewrites the `_thumb` sibling before the main object.
- [x] Web grids: 4 columns on phones, 6 at md, 7 at lg, 8 at xl, 9 at 2xl.
- [x] Flutter grids: 4 columns on phones. Shelves and tile text are smaller.
- [ ] Backfill run on production (graduated order in `docs/BACKEND.md`).

## Context / links

- Related docs: `docs/BACKEND.md` "Generated image transparency"
- Related code: `backend/app/utils/background_removal.py`, `backend/scripts/backfill_transparent_backgrounds.py`, `frontend/src/hooks/useColumnCount.ts`, `flutter/lib/features/wardrobe/views/wardrobe_content.dart`

## Progress log

| Date | Note |
|------|------|
| 2026-09-25 | Started. Matte 217ms to 86ms full frame, 69ms cropped (1024px test shot, best of 10). |
| 2026-09-25 | Review pass: switched the remaining item-image `cover` sites to `contain` (web dashboard recent items, batch generation progress, outfit generating previews, admin items grid, Flutter activity feed, MCP `wardrobe-grid` widget). Confirmed pre-encode output is pixel-identical to the old matte on all fixtures. Smoke-ran the backfill end to end with fakes. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-09-25 | Tight crop, native aspect ratio, ~3% pad | User choice. Tiles use `contain`, so every aspect fills its tile. |
| 2026-09-25 | Crop items only | Outfit tiles use `object-cover` for opaque model shots. |
| 2026-09-25 | Upload the thumb before the main object | A retry after a thumb failure would otherwise see a tight image, skip it, and never fix the thumb. |
| 2026-09-25 | New audit file `transparent_backfill_v2.jsonl` | Rows marked terminal by the pre-crop run need a second visit. |

## Verification

```bash
(cd backend && source .venv/bin/activate && ruff check . && pytest)
(cd frontend && npm run lint && npm test && npm run build)
(cd flutter && flutter test)
./scripts/check_all.sh
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- TD-073 (Flutter grids load full-size images) noted as higher priority at 4 columns.
- Crop box counts every opaque pixel; a stray speck widens it (`ponytail:` note in `_content_box`). Check the backfill audit widths before tightening.
