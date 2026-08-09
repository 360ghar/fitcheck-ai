# Plan: Closet image URLs break — presigned-expiry RCA + stable-URL cutover prep

Status: active
Started: 2026-08-09
Owner: agent

## Goal

Stop closet (and every other) images from rendering permanently broken tiles.
Root cause: images are served from a private R2 bucket via **1-hour presigned
GET URLs** (`OBJECT_STORAGE_PRESIGN_TTL=3600`, `IMAGE_SERVING_MODE=presigned`),
and any URL held longer than an hour — a session-cached Flutter model, an open
web tab, a DB-persisted value — returns 403 and renders a broken tile with no
recovery. The designed durable fix (stable, cacheable, non-expiring Worker
URLs) was coded and tested but **never deployed**; the web prerequisite
(TD-068 auth cookie) was unimplemented; and legacy rows with NULL
`storage_path` were unrecoverable client-side. This plan ships the remaining
code, the repair tooling, the interim TTL bump, and the cutover runbook.

## RCA

| # | Finding | Evidence |
|---|---------|----------|
| 1 | Production serves images through **1h presigned GET URLs** from a private R2 bucket; URLs rotate on every refetch and die at TTL | `IMAGE_SERVING_MODE=presigned` (config default, no override in any env file), `OBJECT_STORAGE_PRESIGN_TTL=3600`, `serve_url`/`materialize_image_urls` in `backend/app/api/v1/images.py` |
| 2 | Any client holding a URL past TTL renders a **403 broken tile**; the Flutter Aug-8 fix (re-mint via `GET /api/v1/images/presigned`, refresh-on-open; shipped in Shorebird release 1.0.5+10) covers expiry **only when** the image row has `storage_path` AND the object still exists AND the installed build has the fix | `flutter/lib/core/widgets/app_image.dart` / `app_network_image.dart` (one-shot re-mint), `item_repository.remintImageUrl`, commit `c5fdf9d` |
| 3 | **The durable fix is not deployed**: `images.fitcheckaiapp.com` has **no DNS record** (curl: "Could not resolve host"); no `wrangler.toml` was committed; the egress-RCA ops checklist (worker deploy, `IMAGE_SERVING_MODE=worker`, cookie step) is still unchecked | DNS check 2026-08-09; `docs/exec-plans/active/2026-08-05-railway-egress-rca.md` ops items all `[ ]`; TD-068 open in tech-debt-tracker |
| 4 | **Legacy rows are permanently broken and unrecoverable client-side**: `item_images.storage_path` is nullable; Supabase-era rows hold dead Supabase/Railway URLs in `image_url` (NOT NULL, never cleared — TD-071); `materialize_image_urls` skips rows without `storage_path`, so they surface a dead URL forever and the re-mint endpoint cannot be called | `001_full_schema.sql` (`storage_path TEXT` nullable), migration contract (2026-08-04) "stale columns hold dead Supabase URLs", no backfill script existed |
| 5 | **Cutover blocker (found during this RCA)**: `GET /api/v1/outfits/public/{id}` is anonymous (share page + `og:image` for crawlers) and materializes via `serve_url` — in worker mode it would emit Worker URLs that 404 for anyone without a JWT | `backend/app/api/v1/outfits.py:get_public_outfit` → `materialize_image_urls` (mode-driven); Worker requires `Authorization: Bearer` or auth cookie |
| 6 | Web has no re-mint fallback, but its request cache is fresh for only 30s, so web breakage is limited to long-open tabs; the web also lacks the worker-mode cookie (TD-068) | `frontend/src/lib/requestCache.ts` (`DEFAULT_FRESHNESS_MS = 30_000`), `frontend/src/lib/supabase.ts` (localStorage persistence, no cookies) |

## Changes shipped in this plan

### Backend

- **Public share stays presigned in worker mode**: `materialize_image_urls` /
  `materialize_parent_images` gained a `presigned: bool = False` flag that
  bypasses `serve_url`; `get_public_outfit` passes `presigned=True` (same rule
  as cross-user avatars). Tests: unit (flag behavior, passthrough) +
  integration (public outfit returns a signed URL in worker mode).
- **Legacy repair script** `backend/scripts/backfill_storage_paths.py`
  (dry-run default, `--apply` to write, JSONL audit): scans
  `item_images`/`outfit_images`/`items.source_image_storage_path` rows with a
  NULL/empty key, derives the key from the stored URL via the app's own
  `StorageService.key_from_path`, validates the canonical layout, writes it.
  External/junk URLs (OAuth pictures, `example.com/a.jpg`) are reported and
  left untouched. Scans in id-ordered pages (PostgREST caps a single select at
  1000 rows), so large tables are fully examined. Tests: 9 (key derivation,
  candidate collection incl. pagination past the row cap, dry-run no writes,
  apply + audit).
- **Interim TTL bump** 3600 → **604800** (7 days — the maximum AWS S3 *and*
  Cloudflare R2 accept for a presigned URL) in `config.py` default +
  `.env.example` + rationale comment. Shrinks the broken window to near-zero
  for every surface until worker mode lands. Note: `backend/.env` (local dev)
  still pins 3600 and is deliberately left — the runbook's Railway env var is
  what production reads.

### Frontend (web) — TD-068

- New `frontend/src/lib/sessionCookie.ts`: sets/clears the domain-scoped
  `sb-<ref>-auth-token` cookie from the token store (login/register/refresh/
  restore all flow through `setTokens`/`clearTokens` in `lib/auth.ts`, which
  now also write/clear the cookie); Max-Age derived from the JWT `exp` claim.
- URL-based credential rules: `imageFetchOptions(url)` /
  `imageCrossOrigin(url)` attach credentials **only** for our own hosts
  (`images.…fitcheckaiapp.com`), never for presigned R2 URLs (the bucket CORS
  policy has no `Access-Control-Allow-Credentials`, so a credentialed fetch is
  browser-rejected) or third-party hosts.
- Wired into the four image `fetch()` paths (`lib/utils.ts` download,
  `ShareOutfitDialog`, `PhotoshootResultsStep`, `TryOnPage`) and the
  bounding-box cropper (`crop-from-bounding-box.ts`).
- Tests: 10 (cookie lifecycle incl. Max-Age/floor, URL rules, token-store sync).

### Infra

- `infra/images-worker/wrangler.toml` scaffolded from the example (custom-domain route, `ALLOWED_ORIGINS` incl. admin, R2 binding) so the deploy is: secrets → `npx wrangler deploy`.
- Worker README updated: "Cross-user / anonymous images stay presigned" now
  lists the public shared-outfit page.

### Docs

- This plan; tech-debt-tracker updated (TD-068 resolved, TD-071 note).

## Ops runbook (you execute; order matters)

1. **Interim TTL** — Railway: set `OBJECT_STORAGE_PRESIGN_TTL=604800`. Applies
   within a deploy/restart; immediately widens the valid-URL window to 7 days.
2. **Repair legacy rows** — `cd backend && source .venv/bin/activate`:
   `python scripts/backfill_storage_paths.py` (dry-run, review the samples),
   then `--apply`. Then `python scripts/storage_inventory.py` and review the
   MISSING list — rows whose key has no object in R2 are genuinely lost (the
   object never existed or was purged) and cannot be recovered by URL work;
   decide per item (re-upload or accept the placeholder tile).
3. **Deploy the Worker** —
   `cd infra/images-worker && npx wrangler secret put SUPABASE_URL &&
   npx wrangler secret put SUPABASE_JWT_SECRET && npx wrangler deploy`.
   Add the `images.fitcheckaiapp.com` custom-domain route in the Cloudflare
   dashboard if not covered by `[routes]`. Confirm DNS resolves before step 4.
4. **Flip serving mode** — Railway: `IMAGE_SERVING_MODE=worker` +
   `IMAGE_CDN_BASE_URL=https://images.fitcheckaiapp.com`; redeploy.
5. **Verify** (from `infra/images-worker/README.md`): backend list endpoint
   returns `image_url` starting with the CDN base; `curl -sI
   https://images.fitcheckaiapp.com/<user>/items/<name> -H "Authorization:
   Bearer <token>"` → 200 then `cf-cache-status: HIT` on repeat; no token →
   404; another user's path → 404; the public share page still renders (it is
   forced presigned); the leaderboard still renders other users' avatars
   (presigned by design).
6. **Rollback** — flip `IMAGE_SERVING_MODE` back to `presigned`. The presigned
   read path is unchanged; no client change is needed to revert.

## Non-goals

- No Flutter changes (the Aug-8 re-mint + refresh-on-open fix is already
  shipped in 1.0.5+10; it remains the client-side safety net).
- No schema changes; `image_url`/`thumbnail_url` NOT NULL columns stay (TD-071
  cleanup is separate).
- No thumbnail rollout (`THUMBNAIL_SERVING` stays off; the backfill of
  `_thumb` objects is the egress RCA's separate step).
- No web re-mint hook: with 7-day TTL and then stable worker URLs, the 30s
  request cache keeps web surfaces fresh; a re-mint hook would be dead code
  post-cutover.

## Acceptance criteria

- [x] Public shared-outfit endpoint emits presigned URLs even in worker mode
      (unit + integration tests).
- [x] `backfill_storage_paths.py` reports in dry-run, writes keys + audit in
      `--apply`, never touches external/junk URLs, never touches rows that
      already have a key, and scans past the PostgREST row cap in id-ordered
      pages (9 tests).
- [x] Web sets/clears the `sb-<ref>-auth-token` cookie from the token store;
      the four image fetch paths and the cropper use credential rules that
      only attach cookies to our own worker host (10 tests).
- [x] `OBJECT_STORAGE_PRESIGN_TTL` default + `.env.example` = 604800 with the
      trade-off documented.
- [x] `wrangler.toml` scaffolded; worker README updated.
- [x] Backend pytest (changed modules), ruff clean; frontend lint + tsc +
      full vitest (256) green; worker `npm test` green.

## Context / links

- Related docs: `docs/exec-plans/active/2026-08-05-railway-egress-rca.md`
  (Phase 2 = this cutover), `2026-08-08-item-outfit-image-rca.md` (Flutter
  re-mint), `docs/exec-plans/completed/2026-08-04-railway-bucket-migration-contract.md`
  (legacy rows), `docs/SECURITY.md`, `docs/BACKEND.md`
- Related code: `backend/app/api/v1/images.py`, `backend/app/api/v1/outfits.py`,
  `backend/scripts/backfill_storage_paths.py`, `backend/app/core/config.py`,
  `frontend/src/lib/sessionCookie.ts`, `frontend/src/lib/auth.ts`,
  `frontend/src/lib/utils.ts`, `frontend/src/components/social/ShareOutfitDialog.tsx`,
  `frontend/src/pages/photoshoot/components/PhotoshootResultsStep.tsx`,
  `frontend/src/pages/try-on/TryOnPage.tsx`,
  `frontend/src/lib/crop-from-bounding-box.ts`, `infra/images-worker/*`
- Related issues: user report — closet item links broken / images don't load
  (2026-08-09); TD-068, TD-071

## Progress log

| Date | Note |
|------|------|
| 2026-08-09 | RCA complete (DNS check, read-path audit, cutover-blocker found); plan approved; all code + tests shipped |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-09 | Interim TTL 3600 → 604800 (7 days) | 1h is shorter than real client caches; 7d (the S3/R2 presigned-URL maximum) shrinks the broken window to near-zero at zero code risk while worker mode rolls out. URLs are unguessable and ownership-checked, so the longer access window is acceptable; TTL becomes irrelevant once worker mode is live |
| 2026-08-09 | Fix the public share endpoint in-repo before the flip instead of documenting it | It would have broken every share link + og:image after `IMAGE_SERVING_MODE=worker`; forcing presigned matches the established avatar rule |
| 2026-08-09 | Web cookie is set from `setTokens`/`clearTokens`, not a supabase-js `onAuthStateChange` | The web's auth is the custom localStorage token store (supabase-js is used only for OAuth); the token store's write/clear points are the single source of truth and cover login/register/refresh/restore/logout |
| 2026-08-09 | Credentials attach by host + presign detection, not unconditionally | R2's CORS policy has no `Access-Control-Allow-Credentials`; a credentialed fetch to a presigned URL is rejected by the browser. Only our worker host gets `credentials: 'include'` / `use-credentials` |

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest tests/unit/test_scripts/test_backfill_storage_paths.py \
  tests/unit/test_services/test_thumbnails_and_serving.py \
  tests/integration/test_outfits_routes_coverage.py --no-cov   # 210 passed
ruff check app/api/v1/images.py app/api/v1/outfits.py scripts/backfill_storage_paths.py

cd frontend && npm run lint && npx tsc --noEmit && npx vitest run   # 256 passed

cd infra/images-worker && npm test     # worker authorization boundary

python scripts/check_architecture.py && python scripts/check_docs_structure.py
```

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- None new. (TD-068 closed. TD-071 — the persisted-URL columns — is unchanged
  and separate; the backfill script makes legacy rows readable without touching
  those columns.)
