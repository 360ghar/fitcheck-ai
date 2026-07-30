# Auto-generate outfit from uploaded photo

> Status: **Implemented** (client orchestration; zero new backend endpoints).
> Goal: after a user uploads a photo and we extract its closet items, automatically
> create **one outfit per source image** (named after the pieces) and kick off a single
> AI render of the person wearing it — exactly like manually selecting the same items
> in the outfit builder.

## Decision: orchestrate on the client, reuse existing APIs

The batch-extraction pipeline is **already client-orchestrated** (`BatchExtractionFlow`
runs per-image detection/generation over SSE, then saves items via `createItem` +
`uploadItemImages`). No backend batch-save endpoint exists. Therefore the auto-outfit is
created **client-side immediately after items are persisted**, grouping saved items by
`DetectedItem.sourceImageId`. This needs **no new endpoint or migration**.

The social-import pipeline (`useSocialImportQueue` → `approveSocialImportPhoto`) is the
one place that saves server-side; the backend `approve_photo` writes `saved_item_id` per
item and the status refresh returns it, so the client can group those per photo too.

## Reused building blocks
- `outfitsApi.createOutfit({ name, item_ids, tags })` — creates outfit + links items.
- `useOutfitStore.createOutfit()` — POSTs then **auto-fires** `startGenerationForNewOutfit()`
  → exactly one render of the person wearing the selected items.
- `DetectedItem.sourceImageId` — per-image grouping key (batch flow).
- `SocialImportItem.saved_item_id` + photo grouping (social flow).

## Implementation

### New helper — `frontend/src/lib/outfit-from-upload.ts`
- `categoryDisplayName(category)` — title-cased label for outfit naming.
- `buildOutfitName(ids, all)` — `"<Top> + <Bottom> look"` / `"<Top> look"` (dedup by
  category, up to 2 pieces), fallback `"Uploaded look"`.
- `createOutfitsFromUploads({ groups, generateId, max })` — for each non-empty group:
  `useOutfitStore.getState().createOutfit()` (fire-and-forget; `generateId()` seeds the
  optimistic generating-outfit entry). Wrapped in try/catch so a failed outfit never
  breaks the item-save path.

### Batch flow — `BatchExtractionFlow.tsx`
- After all items saved, build `savedTempIds` (tempId → real id), group by
  `sourceImageId` (only `includeInWardrobe !== false`, non-deleted, successfully saved),
  then `createOutfitsFromUploads` (fire-and-forget) before the completion toast.
- Review step shows an info line: “We’ll auto-create an outfit from each photo …”.

### Social flow (backend returns saved items)
- Backend `approve_photo` now collects each saved item’s `{id, category}` and returns
  `saved_items`; the approve endpoint surfaces it in `data.saved_items` (additive, no
  contract break). This is the **only** backend change — needed because the job-status
  payload omits the just-approved photo.
- `approveSocialImportPhoto` returns `saved_items`; `useSocialImportQueue.approveAwaiting`
  resolves with them; `BatchExtractionFlow.handleSocialApprove` creates the outfit from
  that photo’s saved items.

### Render path
Auto-created outfits reuse the **same** render the outfit builder uses: the outfit is added
to `useOutfitStore` (marked `pending` in `generatingOutfits`), then
`startGenerationForNewOutfit(outfitId)` runs the single-look, `use_body_profile`, clean-bg
generation and uploads the primary image. One look per outfit — matching the “only 1 outfit
generated” goal.

## Out of scope
- No new backend endpoint/migration (not needed for the client-orchestrated path).
- Flutter auto-outfit (follow-up); Flutter builder already generates one look per outfit.

## Verification
- `tsc --noEmit` 0 errors · `eslint` clean · `npm run build` ✓ · `vitest` 25/25 ·
  backend `pytest` 416 ✓ · `check_architecture.py` / `check_docs_structure.py` ✓.
