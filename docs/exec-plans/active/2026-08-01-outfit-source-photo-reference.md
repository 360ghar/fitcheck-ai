# Plan: outfit generation uses the uploaded source photo (upload flow only)

Status: active
Started: 2026-08-01
Owner: agent

## Goal

After a user uploads a photo and we extract + save its items, the auto-created
outfit's AI render was generated from the **extracted/generated item shots
only** — each one already one lossy hop away from the original photo (bbox
crop + downscale + re-encode, or a full AI product-shot generation). The
outfit render then re-derived the clothes from those degraded references:
lossy². The fix: for the **auto-outfit-from-upload flow only**, the backend
now also resolves the **original uploaded source photo**
(`items.source_image_url`, persisted since migration 019) and sends it to the
image model as ONE extra "as worn" reference (fit, draping, layering), so the
render copies the real clothes instead of compounding the loss.

## Scope (explicit)

- **Enabled ONLY by** `frontend/src/lib/outfit-from-upload.ts`
  (`createOutfitFromSavedItems` → `startGenerationForNewOutfit(outfit.id,
  { useSourcePhoto: true })`) — the single call site for one-outfit-per-
  uploaded-photo (covers the web batch flow AND the social-import approve
  flow, which both route through that helper).
- **Never enabled for** the outfit builder, preview, or the OutfitsPage
  failed-card retry (`startGenerationForNewOutfit` called without options
  defaults to `useSourcePhoto: false`). With the flag off, prompts are
  byte-identical to before (locked by tests).

## Design

### Backend

- `GenerateOutfitRequest.use_source_photo: bool = False` (`app/models/ai.py`).
  Clients never send URLs/base64 — resolution is server-side and user-scoped,
  same SSRF posture as `item_id`.
- `resolve_outfit_source_reference` (`app/services/item_reference_service.py`):
  one batched, user-scoped query over `items(source_image_url)`; dedupe by
  URL; the URL shared by the most items wins; a tie for the top slot is
  skipped (ambiguity > no reference); winner must cover at least
  `AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS` (default 1 — the upload flow
  groups one photo per outfit); at most `AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES`
  (default 1). Download under `REFERENCE_DOWNLOAD_SEMAPHORE`, downscale to
  `AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE` (768). Every failure degrades to
  today's behavior (None → no source reference), never fails the request.
- `SOURCE_PHOTO_REFERENCE_LOCK` (`app/agents/prompt_fidelity.py`): copy every
  listed garment exactly as worn (colors, prints, weave, hardware, logos,
  cut, fit, draping, layering); change only scene; ignore other garments/
  people/props; face/body/hair/skin come only from the person reference image
  when present (the photo may show someone else's clothes).
- `generate_outfit(..., source_photo_base64=None)`
  (`app/agents/image_generation_agent.py`): image order avatar → source photo
  → garments; `_build_reference_map` labels it; lock wired into all three
  branches (flat lay / avatar / generic model). `None` → byte-identical
  prompts.
- Endpoint (`app/api/v1/ai.py`): resolve + forward only when the flag is on;
  inside the rate limit, outside `with_retry` (same rules as item refs).

### Frontend

- `api/ai.ts`: `GenerateOutfitOptions.useSourcePhoto` → payload
  `use_source_photo`.
- `outfitStore.ts`: `startGenerationForNewOutfit(outfitId, options?)` threads
  the flag; default `false`.
- `outfit-from-upload.ts`: the one enabling call site.
- **Plumbing** (web batch flow previously dropped the field): `DetectedItem`
  gains `sourceImageUrl`/`sourceImageStoragePath`, surfaced by
  `useBatchExtraction.convertToDetectedItem` from the SSE payload (which
  already carried it), and `BatchExtractionFlow.saveAllItems` persists both
  in `createItem`. Social-import items already persisted `source_image_url`
  server-side.

## Config (backend/.env.example, app/core/config.py)

- `AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES=1`
- `AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS=1`

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/test_outfit_source_reference.py tests/test_outfit_item_references.py tests/test_image_generation_agent.py -q
ruff check app/services/item_reference_service.py app/agents/image_generation_agent.py app/agents/prompt_fidelity.py app/api/v1/ai.py app/core/config.py app/models/ai.py
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
cd frontend && npx vitest run src/stores/__tests__/outfitStore.generation.test.ts && npm run lint && npm run build
```

Manual provider probe (still open): upload a photo of a person wearing a
visually unmistakable outfit, let the auto-outfit generate, then inspect the
echoed `data.prompt` for `IMAGE 2 = the original photo of this outfit as
worn` (with avatar) / `IMAGE 1 = …` (generic model) and whether the render
reproduces the as-worn fit. Grep logs for `Outfit source photo reference
resolved` (`resolved=true`, `candidate_selected=true`).

## Deferred debt

- Flutter parity for the plumbing (`DetectedItemData` freezed model +
  create payload): only matters when Flutter auto-outfit lands; the freezed
  `.g`/`.freezed.dart` regeneration was out of scope here.
- OutfitsPage failed-card retry keeps the flag off; if retries should mirror
  the original upload-flow generation, pass `{ useSourcePhoto:
  outfit.tags?.includes('from-upload') }` at `OutfitsPage.tsx:164`.
