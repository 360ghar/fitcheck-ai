# UI/UX Improvements — Plan

> Status: **Phases 1, 3, 4 implemented** (see §7–§8). Phase 2 single-look/no-background done;
> the "auto-generate an outfit from an uploaded pic" sub-item is **deferred** (needs a backend
> pipeline change — see §8 Phase 2).
> Source reference: `video.mp4` (Alta-style wardrobe/outfit UX, 28 s, tablet UI).
> Scope: Web (`frontend/`), Mobile (`flutter/`), API (`backend/`).
> Decisions (locked): **routes stay the same** (`/wardrobe`, `Routes.wardrobe`, file
> names — only user-facing copy changes to "Closet"); SEO keeps **both "wardrobe" and
> "closet"** plus related keywords; the store hook was renamed `useWardrobeStore` →
> `useClosetStore` (file name `wardrobeStore.ts` kept).

---

## 1. Video analysis (what we're matching)

| Screen | Frames | UX pattern to copy |
|---|---|---|
| Outfits grid | 1, 3, 12 | Very dense grid (6–7 cols), image-only tiles, model on clean/no background, no text overlays, tiny filter pills on top |
| Closet tab | 2, 13, 14 | "Closet"/"Wishlist" tabs; dense product **cutout** grid; only name + brand under each item; category chips (Tops, Bottoms, Shoes, Bags, Accessories…) + Search/Select |
| Outfit detail | 4, 5, 9, 10 | Single large render, plain background, minimal chrome; name + date bottom-left; **"Regenerate" pill** bottom-right; **"Other Pieces" horizontal strip** of contained items; "Saved look" toast |
| Outfit builder | 6, 7, 8 | Dark theme; small selection preview + "+ Add" at top; per-category **horizontally scrollable rails** (Tops/Bottoms/Shoes) of small cutout thumbnails; selected item highlighted; "Save" pill top-right |
| Daily view | 11 | Calendar day strip + outfit of the day (out of scope) |

---

## 2. Current state (verified in codebase)

### Web (`frontend/`)
- Wardrobe page: `src/pages/wardrobe/WardrobePage.tsx` — grid 2→6 cols (`gap-4`), `ItemCard` shows category/sub-category/brand/material/season/favorite overlays (too heavy).
- Outfits page: `src/pages/outfits/OutfitsPage.tsx` — grid 2→4 cols, `OutfitCard` has heavy gradient overlay (name/description/item-count over image). Detail opens centered `Dialog`.
- Outfit builder: `src/components/outfits/OutfitCreateDialog.tsx` — form-heavy (name/description/style/season/occasion/tags) + square grid multi-select; auto-generates after create.
- Nav labels "Wardrobe": `src/components/sidebar/navigation-config.ts`, `src/components/navigation/BottomNav.tsx`.
- Generation: `src/stores/outfitStore.ts` `startGeneration()` — single image client-side, `background: 'studio white'`; `src/api/ai.ts` still exports `MultiPoseOutfitResult` (multi-pose, unused in UI).

### Mobile (`flutter/`)
- Wardrobe: `lib/features/wardrobe/views/wardrobe_content.dart` — app-bar title `'Wardrobe'`, grid `crossAxisCount: 3`, tiles with name + category + color dots.
- Bottom nav label: `lib/core/widgets/app_bottom_navigation_bar.dart` (`label: 'Wardrobe'`).
- Outfits: `lib/features/outfits/views/outfits_content.dart`; detail = full page `outfit_detail_page.dart`.
- Builder: `lib/features/outfits/views/outfit_builder_page.dart` — light theme, vertical grouped item grid + "Generate AI Preview" bottom bar.
- Try-On picker: `lib/features/tryon/views/tryon_content.dart` — `'From Wardrobe'`, `'Wardrobe item picker'` sheet.

### Backend (`backend/`)
- `app/api/v1/outfits.py` — `POST /outfits/{id}/generate` (`GenerationRequest.variations` 1–3), `POST /outfits/{id}/images`, `GET /outfits/generation/{id}`.
- `app/agents/image_generation_agent.py` — `generate_outfit_image()` (default `background: "studio white"`).
- Batch extraction: `app/services/batch_extraction_service.py` + `app/agents/item_extraction_agent.py` — already detects **people** (`person_id`, `is_current_user_person`) → hook for photo→outfit.

---

## 3. Workstreams

### A — Rename Wardrobe → Closet (copy only; routes/identifiers unchanged) ✅ Phase 1
- **Web**: nav labels (`navigation-config.ts`, `BottomNav.tsx`), `WardrobePage` title/header/empty-state/tooltips/dialog copy, `components/wardrobe/*` user-facing strings (batch flow, extracted grid, item detail "Add to Wardrobe"), Dashboard onboarding checklist, Try-On picker copy.
- **Flutter**: `app_bottom_navigation_bar.dart` label, `wardrobe_content.dart` app-bar title + semantics, Try-On picker (`'From Wardrobe'` → `'From Closet'`, sheet title), auth/onboarding strings.
- **Keep unchanged**: routes (`/wardrobe`, `Routes.wardrobe`), store/file names (`wardrobeStore`, `WardrobeController`), API paths, DB tables.
- **Backend**: user-facing message strings only; no schema/route changes.

### B — Outfit image output: single + no background (Phase 2)
- Force `variations: 1`; remove multi-pose/variation entry points; deprecate `MultiPoseOutfitResult`.
- Prompt change in `image_generation_agent.py` and `outfitStore.ts`: `background` → *"isolated subject on a plain pure-white background, no scenery, no props, no floor shadow"*.
- Phase 2.5 (optional): true transparent PNG via post-processing (e.g. rembg) behind a flag.

### C — Outfits list: dense grid + side panel (web) / modal (app) (Phase 2)
- Web: grid → `grid-cols-3 sm:grid-cols-4 md:grid-cols-6 xl:grid-cols-7`; minimal `OutfitCard` (image only, heart on hover, no gradient/name). Detail `Dialog` → right-side **Sheet** panel: large render, name + date, **Other Pieces** horizontal strip, **Regenerate** pill, overflow actions. Keep `/outfits/:id` deep link.
- Flutter: `outfits_content.dart` denser grid (crossAxisCount 4–5, image-only tiles); `outfit_detail_page.dart` → draggable modal bottom sheet with same contents + Regenerate.

### D — Closet items page density ✅ Phase 1
- Web `ItemCard`: minimal variant — cutout image + name + brand only; denser columns; category chip row (Tops/Bottoms/Shoes/Bags/Accessories) above grid driven by existing `FilterPanel` state.
- Flutter `wardrobe_content.dart`: `crossAxisCount` 3→4, minimal tile (image, name, brand; drop color dots).

### E — Outfit builder revamp (Phase 3)
- Shared pattern (web dialog + flutter page): dark surface; top = current-selection preview strip + "+ Add"; body = per-category **horizontal rails** (Tops, Bottoms, Shoes, …) of small borderless cutout thumbnails, tap-to-toggle with highlight ring; **Save** pill (auto-name "Saved look · {date}"); on save → single no-bg generation (B) → open detail panel/modal.
- Web: replace `OutfitCreateDialog` form (metadata collapsible/optional). Flutter: revamp `outfit_builder_page.dart`.

### F — Photo → auto Outfit generation (Phase 4)
- Backend: after batch extraction, for each source image with a detected person wearing ≥2 items, group by `person_id` and emit new SSE event `outfit_suggestion` (items + auto-generated clean outfit image via `ImageGenerationAgent`, source photo as visual reference where provider supports it, else text-only from dense descriptions). Gate on AI consent + generation quota.
- Web/Flutter review step: "Outfit detected" card with generated preview, **Save to Outfits default ON**; on save → create items → `POST /outfits` → upload generated image → appears in Outfits grid.

---

## 4. SEO plan (keep "wardrobe" + add "closet" + related keywords) ✅ Phase 1
- In-app UI uses **Closet**; public marketing/SEO pages intentionally keep **wardrobe** and add **closet** so we rank for both.
- `frontend/index.html`: keywords meta extended with `digital closet, virtual closet, closet organizer app, outfit maker, outfit generator, capsule wardrobe, wardrobe organizer`.
- `frontend/src/components/seo/seo-config.ts` `/wardrobe` entry: title **"Your Closet — Digital Wardrobe Organizer"**, description mentions both "closet" and "wardrobe".
- Landing FAQ / HowItWorks / Features copy: naturally include "closet" alongside "wardrobe" where a user-facing feature name appears.
- No new public routes in Phase 1 (intent/compare pages already target "virtual closet", "digital wardrobe", "outfit planner").

---

## 5. Phasing & verification

| Phase | Workstreams | Status |
|---|---|---|
| **P1** | A (rename), D (density), SEO | ✅ implemented (see §7) |
| **P2** | B (single no-bg image) | ✅ implemented (see §8) |
| **P3** | C (dense outfits grid + side panel/modal) | ✅ implemented (see §8) |
| **P4** | E (builder revamp web + flutter) | ✅ implemented (see §8) |

> F (photo→outfit pipeline): deferred — see header and the §8 Phase 2 note.

Per-phase checks:
```bash
cd frontend && npm run lint && npm run build
cd flutter && flutter analyze && flutter test
cd backend && source .venv/bin/activate && pytest
python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

---

## 6. Explicitly out of scope (Phase 1)
- No route renames (`/wardrobe` stays; no `/closet` redirect yet).
- No backend schema/route changes.
- No changes to Remotion marketing compositions or store-listing assets.
- Public SEO/marketing pages keep "wardrobe" keywords (closet added, not replaced).

---

## 7. Phase 1 change log (implemented)

### Web (`frontend/`)
- `src/components/sidebar/navigation-config.ts` — nav name `Wardrobe` → `Closet`.
- `src/components/navigation/BottomNav.tsx` — label `Wardrobe` → `Closet`.
- `src/pages/wardrobe/WardrobePage.tsx` — title `My Wardrobe` → `My Closet`; empty-state `Start Your Wardrobe` → `Start Your Closet`; dialog/tooltip copy updated; grid → `grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-7` with `gap-3`; `ItemCard` gets `compact` prop; category chip row added above grid.
- `src/components/wardrobe/ItemCard.tsx` — new `compact` prop (default `false`): hides category/brand/material/season + favorite overlay, keeps name (+ brand), smaller padding/text.
- `src/components/wardrobe/{ExtractedItemsGrid,ExtractedItemCard,BatchExtractionFlow}.tsx`, `src/components/wardrobe/ItemDetailModal.tsx` — "wardrobe" → "closet" in user-facing copy.
- `src/pages/DashboardPage.tsx` — onboarding checklist wardrobe copy → closet.
- `src/pages/TryOnPage.tsx` — picker copy `Select from your wardrobe` → `closet`.
- `index.html` — keywords extended (closet + related terms).
- `src/components/seo/seo-config.ts` — `/wardrobe` title/description now mention closet + wardrobe.
- `src/components/landing/FAQ.tsx` — "virtual closet and outfit planner … build a digital wardrobe **or closet**".

### Mobile (`flutter/`)
- `lib/core/widgets/app_bottom_navigation_bar.dart` — label `Wardrobe` → `Closet`.
- `lib/features/wardrobe/views/wardrobe_content.dart` — app-bar title `Wardrobe` → `Closet`; semantics hints updated; grid `crossAxisCount` 3→4, tile simplified to image + name + brand.
- `lib/features/tryon/views/tryon_content.dart` — `'From Wardrobe'` → `'From Closet'`; picker sheet title/comments updated.

### Backend
- No changes required for Phase 1.

> Note: internal identifiers (`WardrobeController`, `WardrobeBinding`,
> `Routes.wardrobe`, `/wardrobe` path, API/DB names) intentionally unchanged per locked decision.

---

## 8. Phases 2–4 change log (implemented)

### Phase 2 — Single outfit, no blank background
- `src/stores/outfitStore.ts` — `createOutfit()` fires `startGenerationForNewOutfit()`, so every
  newly created outfit produces exactly **one** AI look (no variant grids). Generation prompt
  `background` changed `studio white` → `seamless clean light background` (both manual + auto paths).
- **Deferred (needs product decision + backend work):** "on uploaded pic, auto-extract the items
  AND auto-generate a default outfit of the person wearing it." The current batch upload flow
  (`BatchExtractionFlow`) only saves extracted closet items — it does **not** auto-create an
  outfit. Auto-creating an outfit per uploaded image (grouping that image's items + synthesizing
  a worn render) requires a backend pipeline change and a UX decision on grouping; flagged as a
  follow-up rather than silently half-implemented on the client.

### Phase 3 — Denser list + detail in side panel (web) / modal (app)
- `src/components/outfits/OutfitDetailPanel.tsx` (**new**) — right-side `Sheet` (full-screen
  on mobile) showing the generated look (`ZoomableImage`), name/description, generating/
  failed states, composition items (`ItemImage` chips), and actions (Generate/Retry, Share,
  Mark worn, Duplicate, Delete).
- `src/pages/outfits/OutfitsPage.tsx` — old center `Dialog` replaced with `OutfitDetailPanel`;
  grid made denser `grid-cols-2 sm:3 md:4 lg:5 xl:6` (skeleton grid + count matched); removed
  the page-local composition memo + unused `GeneratingSurface` import.
- `flutter/lib/features/outfits/views/outfits_content.dart` — tapping an outfit card now opens
  `OutfitDetailPage` inside a `Get.bottomSheet` modal (`_openOutfitDetailModal`, 90% height,
  rounded top) instead of pushing a route; long-press still shows the quick-actions sheet;
  the `/outfits/:id` named route is kept for deep links.

### Phase 4 — Outfit generation UI (dense closet + horizontal rails)
- `src/components/outfits/OutfitCreateDialog.tsx` — item picker changed from a 4-col grid to
  per-category **horizontally scrollable rails** (`groupedItems` by category, snap-x, compact
  28×28 tiles, name only); loading copy "wardrobe items" → "closet items".
- `flutter/lib/features/outfits/views/outfit_builder_page.dart` — available-items grid
  replaced with per-category horizontal `ListView` rails (100-wide cards, category header
  with count) + `_categoryLabel()` helper; selected-thumbnail strip at top was already
  horizontal (unchanged).

### Verification (all green)
- Web: `tsc --noEmit` 0 errors · `eslint --max-warnings 0` clean · `npm run build` ✓ ·
  `vitest run` 25/25 (incl. `outfitStore.generation.test.ts`).
- Mobile: `flutter analyze` 0 errors.
- Repo harness: `check_architecture.py` ✓ · `check_docs_structure.py` ✓ · backend `pytest` 416 ✓.
