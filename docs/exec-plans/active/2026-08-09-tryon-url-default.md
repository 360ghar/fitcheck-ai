# Plan: URL-first image generation — fix try-on blank render + default all generation endpoints to storage URLs

Status: active
Started: 2026-08-09
Owner: agent

## Goal

Fix the web "Try My Look" flow (backend returns a multi-MB inline `image_base64`
PNG, nothing renders) and make **URL-first** the default for every image
generation endpoint: `/api/v1/ai/try-on`, `/api/v1/ai/generate-outfit`,
`/api/v1/ai/generate-product-image`. Generated renders are persisted to object
storage and returned as `image_url` + `storage_path`; the inline base64 payload
stops riding API responses (Railway egress + RAM on both ends — the exact cost
class the 2026-08-05 R2 egress RCA and the 512MB memory-budget plan eliminated
for every other image path).

## RCA (why try-on rendered nothing)

1. Both clients never asked for persistence: web `generateTryOn` defaulted
   `save_to_storage` to `false` and `TryOnPage.handleGenerate` did not pass it;
   Flutter `tryon_controller.dart` hardcoded `'save_to_storage': false`.
2. The backend therefore returned `image_base64` (multi-MB PNG) inline with
   `image_url: null`, `storage_path: null` — the only generation flow still
   doing this. Outfit/product endpoints already emit `image_base64=""` when
   persisted ("the durable URL is the canonical payload").
3. The web render path has a base64 fallback, so the failure is the giant
   inline payload itself (multi-MB JSON + giant data URL through the proxy and
   browser). Eliminating the inline payload removes the failure class.
4. `save_generated_image` already normalizes to WebP q82 @ 2048px and writes
   under `generated/{user}/{image_type}/...`; the endpoints' existing guard
   (`image_base64="" if image_url else ...`) keeps the inline fallback when a
   storage write fails (verified: `save_generated_image` returns empty strings
   on failure, which are falsy → base64 retained).

## Non-goals

- No DB schema change; `generated/` objects stay non-DB-referenced (TD-070:
  1h presign TTL + 30-day retention accepted for the one-shot result screen).
- Demo endpoints (`/demo/try-on`, `/demo/extract-items`) keep inline base64 —
  public/unauthenticated, no storage writes without auth.
- Photoshoot/batch flows are unchanged (already URL-based).
- The 1h presign expiry for saved renders is accepted; making renders
  durable/re-materializable is TD-070, still open.

## Acceptance criteria

- [x] `GenerateOutfitRequest`, `GenerateProductImageRequest`, `TryOnRequest`
      default `save_to_storage=True` (`backend/app/models/ai.py`).
- [x] Web `generateOutfit` / `generateProductImage` / `generateTryOn` default
      `save_to_storage` to `true`; `TryOnPage.handleGenerate` passes it
      explicitly (`frontend/src/api/ai.ts`, `frontend/src/pages/try-on/TryOnPage.tsx`).
- [x] Flutter try-on payload sends `save_to_storage: true`; product-image
      repository default flips to `true`; outfit-builder result handling treats
      an empty `image_url` as missing so the base64 fallback survives a failed
      storage write (Dart `??` only covers null)
      (`flutter/lib/features/tryon/controllers/tryon_controller.dart`,
      `flutter/lib/features/wardrobe/repositories/item_repository.dart`,
      `flutter/lib/features/outfits/controllers/outfit_builder_controller.dart`).
- [x] Legacy inline path stays supported and covered (tests pass
      `save_to_storage=False` explicitly); URL-first default + storage-failure
      fallback pinned by new tests (`tests/integration/test_ai_routes_coverage.py`).
- [x] Admin OpenAPI contract re-exported (`backend/scripts/export_openapi.py`),
      types regenerated, `check:schema` green.
- [x] Docs updated: this plan, `docs/BACKEND.md` key-layout wording,
      TD-070 annotation in `docs/exec-plans/tech-debt-tracker.md`.

## Context / links

- Related docs: `docs/exec-plans/active/2026-08-05-railway-egress-rca.md`,
  `docs/exec-plans/active/2026-08-03-512mb-memory-budget.md`,
  `docs/exec-plans/tech-debt-tracker.md` (TD-044, TD-070),
  `docs/BACKEND.md` (Storage section).
- Related code: `backend/app/models/ai.py`, `backend/app/api/v1/ai.py`,
  `backend/app/agents/image_generation_agent.py` (`save_generated_image`,
  `_validated_image`), `backend/app/services/ai_provider_service.py`
  (`_parse_chat_response`), `frontend/src/api/ai.ts`,
  `frontend/src/api/images.ts` (`getPresignedUrl`),
  `frontend/src/pages/try-on/TryOnPage.tsx`,
  `flutter/lib/features/tryon/controllers/tryon_controller.dart`,
  `flutter/lib/features/wardrobe/repositories/item_repository.dart`.
- Related issues: web try-on returns success with `image_base64` but nothing
  renders; user asked whether base64 or a storage URL is better (egress +
  memory). Answer: storage URL wins on every axis (R2 egress $0, no 33%
  base64 overhead, backend frees RAM after PUT, cacheable, browser-safe).

## Progress log

| Date | Note |
|------|------|
| 2026-08-09 | RCA + implementation; backend 3632 passed / 99.92% coverage, ruff clean; frontend lint + 233 tests + build green; flutter analyze clean + 225 tests green; admin contract re-exported + check:schema green. |
| 2026-08-09 | Self-review pass: verified all `generateOutfit` / `generateProductImage` / try-on consumers handle URL-first responses (web `outfitStore` preview/save/generate paths and Flutter try-on were already safe; `image_url \|\| data:...` in JS treats `""` as falsy). Found and fixed one gap my change introduced: the Flutter **outfit builder** used `imageUrl ?? base64`, and Dart's `??` does not catch the empty-string `image_url` the backend returns on a failed storage write — the base64 fallback was dropped and the outfit saved imageless. Now treats empty as missing; flutter analyze + 225 tests re-verified. |
| 2026-08-09 | Follow-up report ("try-on still shows nothing after deploy") — see Addendum below. Verified the DEPLOYED backend pipeline end-to-end (objects on R2 at the request timestamps, presigned GET serves 200 image/webp, response 200 with truthy `image_url` + empty `image_base64`), so the backend was not the failure; the client result path had no load-failure handling at all. Hardened web result rendering (never silent) + backend can no longer emit empty/garbage image payloads. Backend touched files 210 passed, ruff clean; frontend 246 tests + lint + tsc + build green. |
| 2026-08-09 | Follow-up report #2 ("after step 3 completes it goes back to step 2") — see Addendum 2. Root-caused the wizard bounce: response-shape drift (user's captured production response was an ARRAY wrapper, `[{data:...}]`) made `response.data.data` undefined → the hardened result path threw → Options; PLUS a silent remount race existed in every version. Also verified the LIVE web bundle is stale (sends `save_to_storage: false`, zero hardening) — nothing was ever deployed. Frontend 263 tests + lint + tsc + build green; flutter 7 controller tests + analyze green. |

## Addendum 2 (2026-08-09: "still, it goes back to step 2")

### RCA (three compounding causes)

1. **Response-shape drift, client-side fragility.** The user captured the live
   API response as an ARRAY — `[{"data": {"image_base64":"", "image_url":...}}]` —
   while every client unwraps the canonical envelope `{data: T, message}`.
   Array → `response.data.data` = `undefined` → (post-hardening) the result
   check threw → catch → `setStep('options')`: the exact "step 3 → step 2" the
   user sees. Production's own OpenAPI still declares `type: object` for the
   same route, so this is wrapper drift between deployments, not a contract
   change this repo can reproduce — which is why the fix must be
   **shape-immune rather than shape-specific**.
2. **Silent remount race (pre-existing, in every version).** If TryOnPage
   unmounts mid-flight (navigation, HMR) the response resolves on the dead
   instance; the live instance's unwedge effect then bounced to Options with
   no result and no error.
3. **Nothing was deployed.** The live web bundle (verified byte-level:
   `TryOnPage-29dgB4Z-.js`) sends `save_to_storage: false` and contains none
   of the hardening; the live backend's OpenAPI still shows
   `save_to_storage` default `false`. Local fixes cannot change the user's
   runtime until a deploy happens.

### Fixes

- **Shape-immune unwrap** (`frontend/src/lib/unwrap-generation-result.ts`):
  `unwrapGenerationResult` accepts envelope / array-of-envelope /
  array-of-result / bare object and throws a coded
  `UNEXPECTED_RESPONSE_FORMAT` error otherwise; wired into `generateTryOn`,
  `generateOutfit`, `generateProductImage`, and all four landing demo calls
  (`demoTryOn`, `demoExtractItems`, `demoPhotoshoot`,
  `getDemoPhotoshootStatus`). Lives in `lib/` (pure, zero imports) so the
  public landing bundle never pulls the API client. The page maps that code
  to a real message ("The server returned an unexpected response format.
  Please try again.") — never a generic silent failure.
- **Remount-safe landing** (`TryOnPage.tsx`): module-level `lastTryOnResult`
  (run-id-guarded) — a remounted page lands the render instead of bouncing.
- **Flutter tolerance** (`tryon_controller.dart`): `extractDataMap` accepts
  envelope / array / bare (fails visibly otherwise).
- Tests: `ai-unwrap.test.ts` (5), TryOnPage array-shape + remount-race tests
  (7 total in the file), Flutter `extractDataMap` group (5).

### Deploy checklist (the actual delivery — nothing is live until this runs)

- [ ] Backend: deploy current code (URL-first defaults + image validation).
- [ ] Web: rebuild + deploy (stale bundle verified live on 2026-08-09).
- [ ] Flutter: next Shorebird release.
- [ ] After deploy: retest on fitcheckaiapp.com with a HARD refresh (stale
      bundle reproduces old behavior indefinitely).

## Addendum (2026-08-09, follow-up: "still nothing shows")

### Diagnosis

- Environment trap: the local frontend runs against the **deployed** backend
  (`frontend/.env` → `VITE_API_BASE_URL=https://api.fitcheckaiapp.com`), which
  is older than the local checkout — verifying a fix in the local web app
  exercises the PRODUCTION API, not the local one.
- Deployed backend verified working for this flow: R2 objects exist at the
  request timestamps, presigned GET returns 200 image/webp, the API returned
  200 with a full `image_url` and empty `image_base64`.
- The real gap was client-side and silent: `TryOnPage`'s result path had no
  handling for an unloadable image. A 200 with a URL that the browser fails to
  fetch (expired presign, transient fetch failure, 0-byte object, stale
  HMR/module state) rendered a broken/blank result with no error, no retry, no
  re-mint — the user ended up back on Options with no feedback. jsdom/browser
  img failures do not raise; only `onerror` observes them, and nothing listened.

### Fixes (defense-in-depth — every layer, so the class cannot recur)

Frontend (`frontend/src/pages/try-on/TryOnPage.tsx`, `frontend/src/api/images.ts`):
- Result source resolved once: `image_url` → base64 data URL → `null`.
- Response with NEITHER (empty everything) → visible error on the Options step
  ("The generated image came back empty") — never a broken Result step.
- Result `<img onError>` self-heal: re-mint a fresh URL ONCE from the durable
  `storage_path` via the existing `GET /api/v1/images/presigned` (new
  `getPresignedUrl` client); if that still fails (or no `storage_path`),
  render a visible error card with a Regenerate action and disable the image —
  never a silent broken image. Download uses the current (possibly re-minted) src.

Backend (`backend/app/agents/image_generation_agent.py`,
`backend/app/services/ai_provider_service.py`):
- `_validated_image` at every generation site (try-on, image, references):
  strict base64 decode (`validate=True` after whitespace strip); empty →
  `AIServiceError(retryable=True)` (nothing was generated, retry is free);
  undecodable/hosted-URL/garbage → hard, non-retryable (contract mismatch —
  retrying fails identically); valid base64 that is NOT an image (a 200 HTML
  error page, a fetched asset serving non-image bytes) → retryable (magic-byte
  sniff via `sniff_image_mime_from_magic`). Previously `[""]` sailed through to
  a 200 with an unloadable result, and lenient decode silently turned
  `https://...` into garbage bytes.
- `save_generated_image` refuses empty/whitespace base64 before the S3 PUT —
  no 0-byte objects (a 0-byte object is worse than no save: its presigned URL
  is truthy, suppressing the endpoint's base64 fallback).
- `_parse_chat_response` drops empty data-URLs (`data:...;base64,`) instead of
  appending `""`, and raises a hard error for non-inline images (hosted URLs,
  non-base64 data URLs) instead of appending them as base64 garbage. (The
  `/images/generations` path still fetches hosted URLs; chat style must carry
  inline base64.)

### Environment note for the user

- `frontend/.env` points the dev web app at production. Either run
  `./run-dev.sh` with `VITE_API_BASE_URL=http://localhost:8000` (and the
  backend) to test against local code, or accept that dev exercises prod.
- If the old web bundle is still open in the browser (HMR/module state), a
  hard refresh is required to pick up any of this — a stale session can still
  reproduce the silent result even after the deploy.

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-09 | Flip the backend request-model default to True (not just clients) | "URL as default for Try on and any other service": every current and future consumer gets the URL-first response without remembering the flag; the legacy inline path remains opt-in and covered. |
| 2026-08-09 | Keep the inline base64 render fallback in web + Flutter | Free resilience: the backend's storage-failure path returns base64, and both render paths already prefer `image_url`. |
| 2026-08-09 | Accept the 1h presign TTL / TD-070 for now | The try-on result screen is ephemeral by design; closing TD-070 (DB-referenced generated renders) is a separate, larger change. |
| 2026-08-09 | Result-image failures are never silent: one automatic re-mint, then a visible error card | A blank result with no feedback was the actual observed failure mode. Presigned URLs are short-lived, so one re-mint from the durable `storage_path` covers the common expiry case; a visible error + Regenerate beats an infinite retry loop. |
| 2026-08-09 | Generation responses are unwrapped shape-immunely (envelope / array / bare), and a 200 that still yields nothing fails with a real message | The user's captured production response was array-wrapped while the contract says object; the client must not depend on which wrapper a given deployment emits. |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest                       # 3632 passed, 4 skipped, 99.92% coverage
ruff check app/ tests/

cd frontend && npm run lint && npm test && npm run build   # 233 tests, build green

cd flutter && flutter analyze && flutter test              # 225 tests

cd admin && npm run lint && npm run typecheck && npm test && npm run check:schema

python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

## Deferred debt

- TD-070 stays open: saved renders (`generated/...`) are not DB-referenced;
  their presigned URLs expire after `OBJECT_STORAGE_PRESIGN_TTL` (1h). All
  generation endpoints now persist by default, so this now affects every
  render — worth prioritizing (a `generated_images` table + re-mint read path).
- Every outfit preview / product render now writes an object to R2 (~100KB
  avg post-normalization, 30-day retention). Bucket growth is covered by the
  2026-08-07 R2 storage budget routine (`cleanup_temp_assets.py` +
  `storage_inventory.py` weekly sweep).
