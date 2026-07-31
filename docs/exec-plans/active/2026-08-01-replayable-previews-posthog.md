# Plan: replayable previews for PostHog session recordings

Status: active  
Started: 2026-08-01  
Owner: Droid

## Goal

Make user-uploaded media visible in PostHog session recordings (web app, core flows). Today every upload preview is a `blob:` object URL; PostHog's recorder (rrweb) serializes the DOM `src` attribute, but blob URLs only exist in the originating browser session, so the replay player renders blank/broken images.

## Root cause

`URL.createObjectURL(file)` → `blob:https://…` → recorded as a string → unresolvable at replay time. This is a PostHog limitation; there is no capture-side toggle (masking was already off; no displayed canvases involved).

## Fix

Render previews from **downscaled data URLs** (`canvas` → JPEG, longest edge ≤ 512px, quality 0.8; small files pass through as raw data URLs). Data URLs are self-contained in the recorded DOM and replay everywhere. Upload paths are untouched (they always use the `File` object, never the preview), so upload fidelity is unaffected. Any decode/encode failure falls back to a blob URL (status quo).

## Files changed

- `frontend/src/lib/replayable-preview.ts` — new helper `fileToReplayablePreview(file): Promise<string>` (data URL, blob fallback, 10s decode timeout).
- `frontend/src/lib/__tests__/replayable-preview.test.ts` — 4 unit tests (small pass-through, canvas downscale, decode failure → blob, encode failure → blob).
- `frontend/src/pages/try-on/TryOnPage.tsx` — clothing preview via helper; `clothingFileRef` (the `File`) still drives the API call.
- `frontend/src/pages/photoshoot/components/PhotoshootUploadStep.tsx` — per-photo async conversion to replayable previews (local state map keyed by `File`).
- `frontend/src/stores/photoshootStore.ts` — generating-surface previews built via `Promise.all(photos.map(fileToReplayablePreview))`.
- `frontend/src/hooks/useBatchExtraction.ts` — previews start blank, upgraded to data URLs when ready; upload still uses `img.file`.

## Out of scope

- Landing-page demos (chosen scope: core flows only).
- Flutter (`posthog_flutter` replay serializes the widget tree; local-file images cannot be reproduced at replay time — would require persist-first, a separate larger change).
- Result images (already replayable: HTTPS Supabase URLs / `data:` base64).

## Verification

```bash
cd frontend && npm run lint && npm test -- --run && npm run build
```

All passed: 29 test files / 91 tests, ESLint clean, production build clean (pre-existing chunk-size warning only).

## Deferred debt

- The 512px cap is a heuristic for recording fidelity vs. DOM size; revisit if recordings need larger previews.
- Batch-extraction crops (`crop-from-bounding-box`) and generated results are already replayable; landing demos remain blob-based (out of scope per decision).
