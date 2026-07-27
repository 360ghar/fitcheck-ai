# Plan: Single-item product image isolation fix

Status: completed
Started: 2026-07-27
Completed: 2026-07-27

## Goal

Stop AI-generated per-item product photos from ignoring the "isolate one
item only" instruction — the model was returning the source photo
essentially unchanged, or bleeding in other garments from a multi-item
outfit photo.

## Non-goals

- No post-generation validation/retry loop (e.g. an extra AI call to verify
  the output really is one isolated item) — deferred; ship the structural
  fix first since it directly addresses the confirmed root cause.
- No changes to the `/generate-product-image` REST endpoint or its request
  schema — confirmed no current caller (web Regenerate, Flutter) populates
  `reference_image` on it, so it was out of scope.

## Root cause

`ImageGenerationAgent.generate_product_image()`
(`backend/app/agents/image_generation_agent.py`) was always given the
**entire, uncropped source photo** as the reference image whenever one was
available, asking the model to visually search a busy multi-garment photo
and self-select the target item purely from a text description — an
unreliable instruction-following task for image-editing models.

Confirming evidence: the web app's "Regenerate" button
(`frontend/src/components/wardrobe/BatchExtractionFlow.tsx`) already
reliably isolates a single item correctly — because it never sends a
reference image at all (pure text-to-image from the dense
`detailed_description`). This proved the description alone is sufficient;
the full-photo reference image was what sabotaged isolation.

A per-item `bounding_box` was already computed/persisted end-to-end
(`DetectedItemData.bounding_box`) but never read at the generation call
site. The user confirmed from real-world use that this bbox is often
inaccurate, ruling out a naive "always crop to bbox" fix.

## Acceptance criteria

- [x] `crop_base64_image_to_box` utility added to
      `backend/app/utils/image_processing.py`
- [x] `resolve_product_reference_image` shared decision function added to
      the same module (used by both call sites, not duplicated)
- [x] `batch_extraction_service.py::_generate_single_item` never sends the
      full uncropped photo for a multi-item source photo
- [x] `social_import_pipeline_service.py::_process_single_photo` gets the
      same fix
- [x] Stale/misleading comments corrected
      (`batch_extraction_service.py`'s "bbox pins the region",
      `image_generation_agent.py`'s bbox-rejection rationale)
- [x] New tests for the crop utility and the three-way decision; existing
      tests unaffected
- [x] `pytest` and `ruff check` clean on all changed files

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-27 | Never send the full uncropped multi-item photo as reference | Confirmed root cause via Regenerate comparison |
| 2026-07-27 | Three-way strategy: full / crop / text-only, not just crop-or-full | User reported bbox is often inaccurate — a wrong-region crop is worse than no crop, so untrustworthy bboxes fall back to the proven-safe text-only mode instead of the broken full-photo mode |
| 2026-07-27 | `MAX_BBOX_AREA_RATIO = 0.90` (not a lower value like 0.70) | A source photo can legitimately BE one large garment (dress/jumpsuit) filling most of the frame — user flagged this; only near-total-frame boxes (>90%) are treated as the model having given up |
| 2026-07-27 | No post-generation validation/retry pass in this change | Ship the structural fix first; it directly addresses the confirmed root cause, revisit only if issues persist |
| 2026-07-27 | `resolve_product_reference_image` lives in `app/utils/image_processing.py`, imported by both service call sites | Avoids one service importing a private helper from an unrelated service |

## Verification

```bash
cd backend
source .venv/bin/activate
pytest tests/test_image_processing.py tests/test_batch_extraction_reference_image.py tests/test_image_generation_agent.py -q
pytest -q   # full suite — 4 pre-existing unrelated failures in
            # test_phase2e_hardening.py / test_photoshoot_service.py,
            # confirmed present before this change via git stash
ruff check app/utils/image_processing.py app/services/batch_extraction_service.py \
  app/services/social_import_pipeline_service.py app/agents/image_generation_agent.py
```

Manual follow-up recommended: run a batch extraction job against a real
multi-item outfit photo and check logs for the `"Resolved product-image
reference strategy"` line per item (`strategy`: `full` / `crop` /
`text_only`) to observe real-world threshold behavior.

## Deferred debt

- Post-generation validation/retry pass (see Non-goals) — revisit if
  isolation issues persist after this fix ships.
- `MIN_BBOX_CONFIDENCE` / `MAX_BBOX_AREA_RATIO` / `CROP_PADDING_RATIO` are
  best-effort defaults, not empirically tuned yet — the new per-item
  strategy log line exists specifically to support tuning them later.
