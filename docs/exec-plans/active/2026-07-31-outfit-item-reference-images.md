# Plan: outfit item reference images

Status: active  
Started: 2026-07-31  
Owner: agent

## Goal

Outfit generation described garments to the image model in **words only**, so
every generated outfit was a plausible lookalike rather than the user's actual
clothes. Each selected item's own stored image is now downloaded server-side and
sent to the model as a numbered, labelled garment reference alongside the avatar
identity reference, so the render reproduces the real garments' colors, prints,
cuts, and hardware.

## Non-goals

- Try-on (`generate_try_on`) — already sends a garment reference; untouched.
- Single-item product generation (`generate_product_image`) — its
  `resolve_product_reference_image` strategy is unchanged.
- No cap on the number of references, and no feature flag (explicit product
  decision; see Decision log).

## Acceptance criteria

- [x] `OutfitItemInput.item_id` accepted; backend resolves images user-scoped.
- [x] Every item with a stored image becomes a reference (no cap).
- [x] Prompt binds `IMAGE n` → `Item n`; items without an image say so.
- [x] `IDENTITY_LOCK` still precedes `GARMENT_REFERENCE_LOCK`.
- [x] All three `generate_outfit` branches (flat lay / avatar / generic model)
      carry references.
- [x] Backwards compatible: no `item_id` → byte-identical legacy prompt.
- [x] Web and Flutter send `item_id`.
- [ ] Provider probe confirms `agnes-image-2.1-flash` honours >2 inline images.

## Context / links

- Prior art: `docs/exec-plans/completed/2026-07-27-single-item-isolation-fix.md`
  — busy multi-item source photos poisoned generation. Safe here because
  `item_images.image_url` is normally the clean AI-generated studio product shot.
- Spec that asked for this: `docs/product-specs/features/try-on-visualization.md`
  ("Send selected item images to AI model").
- Code:
  - `backend/app/services/item_reference_service.py` (new)
  - `backend/app/agents/image_generation_agent.py`
    (`_collect_garment_references`, `_build_reference_map`,
    `_generate_with_references`)
  - `backend/app/agents/prompt_fidelity.py` (`GARMENT_REFERENCE_LOCK`)
  - `backend/app/api/v1/ai.py`, `backend/app/models/ai.py`
  - `frontend/src/stores/outfitStore.ts`, `frontend/src/api/ai.ts`
  - `flutter/lib/features/outfits/controllers/outfit_builder_controller.dart`

## Progress log

| Date | Note |
|------|------|
| 2026-07-31 | Verified the gap: only the avatar was ever sent; items were text-only. |
| 2026-07-31 | Implemented backend + web + Flutter, 17 new/extended tests green. |
| 2026-07-31 | Self-review caught three things: the `items` abuse guard was low enough to 422 a real outfit (30 → 60, since `createOutfitFromSavedItems` builds one outfit per photo's detected items); reference downloads were unbounded (now 8-wide); and the legacy avatar prompt gained a stray blank line, so it was not byte-identical as claimed — fixed and now locked by a test. |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-31 | `item_id`, never a client-sent URL or base64 | A URL the backend fetches is an SSRF primitive (`download_to_base64` follows redirects, no allow-list); base64 triples mobile payload; only an id can be ownership-checked. |
| 2026-07-31 | No cap on reference count | Product decision: fidelity over payload. Downscaling + anti-collage prompt + an `items` `max_length=60` abuse guard instead. 60 is deliberately above anything real: a genuine outfit that trips it would 422 with nothing the user can do. |
| 2026-07-31 | Bound reference downloads to 8 concurrent | Uncapped references meant uncapped simultaneous storage GETs, each holding a multi-MB buffer and its own connection. 8-wide over a 60-item worst case is negligible next to the 20-40s generation. |
| 2026-07-31 | No feature flag | Product decision: the text-only behaviour is the bug, not a mode. |
| 2026-07-31 | References live inside each item dict, not a parallel list | Label/image misalignment becomes structurally impossible, and `generate_flat_lay` / `generate_variations` inherit the feature with no signature change. |
| 2026-07-31 | Prefer `image_url` over `thumbnail_url` | Thumbnails are grid-sized and cannot carry print, weave, or hardware detail. |
| 2026-07-31 | Downscale the avatar too (1568) | It was being sent raw; the saving offsets several garment references. |
| 2026-07-31 | Resolve inside `rate_limited_operation` but outside `with_retry` | One generation charge regardless of reference count; a retry must not re-download. |

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/test_outfit_item_references.py tests/test_image_generation_agent.py -q
ruff check app/services/item_reference_service.py app/agents/image_generation_agent.py app/api/v1/ai.py
cd .. && python scripts/check_architecture.py
cd frontend && npx vitest run src/stores/__tests__/outfitStore.generation.test.ts && npm run build
cd flutter && flutter analyze
```

Manual provider probe (still open): generate an outfit from 3 items with
visually unmistakable garments, then inspect the echoed `data.prompt` for
`IMAGE 1 = the person` / `IMAGE 2..4 = Item n` and check whether the **last**
garment is reproduced faithfully. Grep logs for `Outfit item references resolved`
and `AI image generation request started` (`reference_images=`).

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Provider-side image-count limit for `agnes-image-2.1-flash` is unverified; if
  it truncates, route this endpoint to the Gemini image leg or
  `AI_IMAGE_API_STYLE=chat`.
