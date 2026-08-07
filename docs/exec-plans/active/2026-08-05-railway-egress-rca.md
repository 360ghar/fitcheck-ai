# Plan: Railway egress RCA — move image storage to R2 + cacheable serving

Status: active
Started: 2026-08-05
Owner: agent

## Goal

Eliminate the dominant Railway egress line (image bytes leaving the Railway S3
bucket to clients) and cut the per-fetch byte volume. Root cause, fix, and
rollout:

1. **Move object storage to Cloudflare R2** (S3-compatible, **$0 egress** to
   the internet). The S3 layer (`app/services/object_storage.py`) is already
   provider-agnostic, so this is an env repoint + object copy, no storage code
   change. Private-bucket + ownership-checked URL issuance (TD-036 posture) is
   preserved.
2. **Serve via stable, cacheable URLs** (Cloudflare Worker in front of R2,
   `IMAGE_SERVING_MODE=worker`): rotating presigned URLs bust every
   browser/CDN/disk cache, so full-size bytes re-stream on every wardrobe
   load. Stable path-only URLs make the Cloudflare edge, the browser HTTP
   cache and Flutter's disk cache all hit.
3. **Serve real thumbnails** (`{storage_path}_thumb` siblings) so grid/list
   tiles fetch ~5-10x fewer bytes.
4. **Client-side disk caching** (Flutter `CachedNetworkImage`, web
   `loading="lazy"`).

## RCA (why egress is high)

After the 2026-08-04 migration all images live in a **private Railway S3
bucket** served via **presigned GET URLs**. Three compounding factors:

1. **Rotating presigned URLs defeat caching (dominant driver).**
   `materialize_image_urls` mints a fresh presigned URL per image on every
   read. The URL embeds `X-Amz-Date` + `X-Amz-Signature`, so it changes on
   every list fetch. Browsers and Flutter's image cache key by **full URL
   including query string** → every refetch is a cache miss → the bucket
   re-streams the full image every time. The `cache-control: max-age=3600`
   stamped on objects is ineffective because the client never re-requests the
   same signed URL.
2. **No real thumbnails.** `thumbnail_url = image_url` at upload; grid/list
   tiles download multi-MB originals to render 44-160px tiles. Avg object
   ~0.94 MB (622 objects ≈ 584 MB): a 50-item wardrobe open ≈ ~50 MB,
   re-downloaded each time.
3. **No CDN, no client disk cache.** Nothing fronts the bucket (every fetch is
   billed Railway bucket→internet egress); Flutter uses raw `Image.network`
   (no disk cache); web tiles lack `loading="lazy"`.

Ruled out as drivers: the backend does **not** proxy images in read paths (no
double egress); `download_to_base64` is AI-write-path only; SSE streams carry
events + URLs, not bytes.

**Cost = (unique fetches) × (full-size bytes)**; both multipliers were
uncontrolled.

## Non-goals

- No change to the AI write path: provider-bound URLs (`ai.py`,
  `item_reference_service`) stay **presigned** (providers cannot send JWTs;
  with R2 those fetches are free egress anyway). Backend→R2 reference
  downloads remain Railway service egress — bounded per generation and
  downscaled; tracked as deferred debt.
- No DB schema change (thumbs derive keys deterministically; no new columns).
- No Docker, no local Supabase; DB/Postgres/Auth stay on Supabase.

## Acceptance criteria

- [x] `OBJECT_STORAGE_PROVIDER`, `IMAGE_SERVING_MODE`, `IMAGE_CDN_BASE_URL`,
      `THUMBNAIL_SERVING` + `R2_*` aliases land in `config.py` /
      `.env.example`.
- [x] `S3StorageBackend` accepts explicit endpoint/keys/bucket (second client
      for the R2 migration script); process singleton behavior unchanged.
- [x] `backend/scripts/migrate_storage_to_r2.py` — dry-run + `--apply`, header
      preserving (content-type/cache-control), idempotent, JSONL audit.
- [x] Thumbnails: `thumb_key_for` (canonical categories only), created at
      upload (all image categories), at promote, deleted with originals and in
      account deletion; backfill script `backend/scripts/generate_thumbnails.py`.
- [x] `materialize_image_urls` honors `THUMBNAIL_SERVING` + worker mode;
      `serve_url` helper; avatar read path routes through it.
- [x] `storage_inventory.py` treats `_thumb` siblings as referenced (never
      orphaned/deleted).
- [x] Flutter: `AppNetworkImage` (CachedNetworkImage drop-in with auth
      headers, presigned-safe), all 20 raw `Image.network` sites converted,
      `AppImage`/`AppImageViewer`/PhotoView providers carry headers; web:
      `loading="lazy" decoding="async"` on 20 user-data `<img>` tags.
- [x] Cloudflare Worker `infra/images-worker` (JWT HS256 + JWKS verification,
      path-ownership check, R2 binding, edge cache) + deploy docs.
- [x] Backend tests green (999 passed, 1 skipped), ruff clean, `flutter
      analyze` clean, frontend `lint` + `build` green.
- [x] **Review pass (2026-08-05, second):** see "Review findings" below — 3 live
      bugs, 8 cutover blockers and 7 correctness items found and fixed.
- [ ] **Ops (out of repo):** create R2 bucket + keys **+ a CORS policy for the web
      origins** → run `migrate_storage_to_r2.py --apply` → apply migration
      `036_widen_image_url_columns.sql` → deploy backend with `OBJECT_STORAGE_*`
      (or the full `R2_*` group) → verify reads → clean the OLD bucket by
      targeting it explicitly (`storage_inventory.py --endpoint … --bucket …
      --access-key-id … --secret-access-key … --delete`; a bare `--delete` now
      inspects R2) → deploy Worker + custom domain (set `ALLOWED_ORIGINS`) →
      **frontend: set the domain-scoped `sb-<ref>-auth-token` cookie (TD-068;
      worker-mode web images 404 without it)** → flip `IMAGE_SERVING_MODE=worker`
      + `IMAGE_CDN_BASE_URL` → run `DRY_RUN=0 generate_thumbnails.py` → flip
      `THUMBNAIL_SERVING=true`.
- [ ] **Note:** web can stay on presigned mode indefinitely (R2 egress is $0);
      worker mode on web only pays for the cookie step above. Flutter is
      worker-ready via `AppNetworkImage`.

## Review findings (2026-08-05, second pass) — all fixed

Measured, not estimated, where it mattered: presigned URL length is **397 chars
on Railway vs 429-447 on R2** (the 32-hex account host costs ~35), against a
`VARCHAR(500)` column — it fits, but headroom drops from ~100 to ~55.

**Live bugs (broken on the deployed Railway build, not introduced by R2):**

| # | Bug | Fix |
|---|-----|-----|
| A1 | `/gamification/leaderboard` returned `users.avatar_url` RAW. The column stores the presigned URL captured at upload time, so every leaderboard avatar older than 1h was a dead link. | `images.materialize_avatar_url(..., presigned=True)`; the guard that existed as two hand-synced copies (`users.py`, `ai.py`) is now one function. `presigned=True` is required — cross-user keys 404 on the Worker. |
| A2 | CSP went enforcing in this change set with `connect-src` missing every storage origin, so all four image `fetch()` paths (download, share, photoshoot, try-on) threw. `data:` was missing too, breaking `dataUrlToFile`. | `connect-src` now lists `*.storageapi.dev`, `*.r2.cloudflarestorage.com`, `images.fitcheckaiapp.com` and `data:`. R2 still needs a bucket CORS policy. |
| A3 | `{user}/generated/{type}/…` (saved try-on / outfit renders) was excluded from `_KEY_RE`, so `/images/presigned` 404'd and the 1h URL could never be refreshed — and the inventory script deleted the object after 2h. | Key allowlist covers `generated/`; `CATEGORY_MIN_AGE_HOURS` gives it a 30-day retention window. Making these DB-referenced is still open (see debt). |

**Cutover blockers:**

| # | Blocker | Fix |
|---|---------|-----|
| B1 | Alias resolution filled each `OBJECT_STORAGE_*` field independently, so one missing `R2_*` var spliced an R2 endpoint onto the Railway bucket name Railway keeps injecting — boots clean, reads the wrong bucket. | Provider groups resolve **atomically**; a partial group raises. Endpoint default is now `""`. 14 tests. |
| B2 | No `botocore.Config` at all: botocore ≥1.36 defaults checksums to `when_supported`, attaching `x-amz-checksum-crc32` to PutObject and requiring one on DeleteObjects — the classic S3-compatible-provider breakage. | Pinned `s3v4`, path addressing, `when_required` checksums, standard retries. Validated against the live bucket (1884 objects listed). |
| B3 | Five `VARCHAR(500)` URL columns written unvalidated with the live presigned URL. | Migration `036_widen_image_url_columns.sql` → `TEXT`. |
| B4 | Worker verified the JWT **signature only** — no `exp`. A leaked token was valid forever. | `exp` required + enforced (60s skew), `nbf` honoured, `iss` pinned to the project. |
| B5 | Worker authorized on a bare "first segment == sub" prefix test, so it served `{user}/export/data.json` — the personal-data export — and force-cached everything 24h `immutable`. | Backend's full key allowlist ported over; the object's own `cache-control` wins when present. |
| B6 | Worker's ownership rule 404s every *other* user's avatar, so the leaderboard would go blank on the worker flip. | Cross-user avatars stay presigned by design (A1), documented in the Worker README. |
| B7 | No CORS headers, `OPTIONS` → 405. | Preflight + `ALLOWED_ORIGINS` + `Vary: Origin`, re-applied on cache hits. |
| B8 | `storage_inventory.py --delete` could only target the configured bucket, so the documented post-cutover "empty the Railway bucket" step would have scanned R2. | `--endpoint/--bucket/--access-key-id/--secret-access-key`, refusing partial overrides; runbook corrected. |

**Correctness:**

- **C1** No `cacheKey` anywhere in Flutter, so `CachedNetworkImage` keyed on the rotating `X-Amz-Signature`: the disk cache never hit, and every load wrote a fresh entry that evicted reusable ones. `stableCacheKey` (host+path) at all 6 provider sites — this is what makes the disk-cache half of the RCA actually work, and it works in presigned mode too.
- **C2/C3** Thumbnails routed through the AI-bound downscaler, which flattens alpha onto **white** — background-removed cutouts would have shown a white block in every grid tile, inconsistently (the "keep the smaller" branch preserved some). Thumbs are now always alpha-preserving **WebP**, and the key extension matches the bytes (was `abc_thumb.webp` holding JPEG).
- **C4** `/images/presigned` bypassed `serve_url`, staying uncacheable in worker mode.
- **C5** `delete_many` echoed the request size as its result; now subtracts reported `Errors`. Account-deletion thumb dedupe was O(n²) on a list; now a set.
- **C6** `authHeadersForUrl` attached the session token to any non-presigned URL — a third-party CDN URL (social import, OAuth avatar) would have received a live credential. Now a host allowlist.
- **C7** `Content-Range` read `range.end`, which R2 omits for open-ended ranges → `bytes 500-undefined/…`. Ranged responses are also no longer edge-cached.
- **D** Removed dead `STORAGE_BACKEND` / `IS_SUPABASE_FALLBACK` / `OBJECT_STORAGE_PROVIDER` flags and the dead `_upload_options` helper plus the two tests asserting storage3 dict-mutation behaviour; corrected `generate_thumbnails.py` usage examples (every one was a silent dry run).

**New coverage:** `infra/images-worker/worker.test.mjs` (29 tests, Node built-in
runner, no deps — the Worker had none and it is an auth boundary), wired into
`scripts/check_all.sh`; `test_leaderboard_avatar_materialization.py`;
alpha-preservation tests; rewritten `test_config_storage_aliases.py`;
`app_network_image_test.dart`.

## Context / links

- Related docs: `docs/exec-plans/active/2026-08-04-railway-bucket-migration-contract.md`
  (storage contract + live migration log), `docs/SECURITY.md`, `docs/BACKEND.md`
  (Storage section), `ARCHITECTURE.md`, `docs/FRONTEND.md`, `docs/FLUTTER.md`.
- Related code: `backend/app/services/object_storage.py`,
  `backend/app/services/storage_service.py`, `backend/app/api/v1/images.py`,
  `backend/app/core/config.py`, `backend/scripts/{migrate_storage_to_r2,generate_thumbnails,storage_inventory}.py`,
  `flutter/lib/core/widgets/app_network_image.dart`, `infra/images-worker/`.
- Related issues: user question — Railway egress bill too high.

## Progress log

| Date | Note |
|------|------|
| 2026-08-05 | RCA written; both phases implemented (code + tests + docs); backend 999 passed, ruff clean; flutter analyze clean (1 pre-existing WIP test timeout in the user's untracked photoshoot controller test — pumps a bare Scaffold, unrelated to these changes); frontend lint+build green. |
| 2026-08-05 | Self-review pass: fixed the storage alias resolver (the built-in `https://storage.railway.app` endpoint default made `R2_ENDPOINT`/`ENDPOINT` aliases silently inapplicable — the R2 cutover would have mixed R2 keys with the Railway endpoint); `migrate_storage_to_r2.py` now aborts when source and destination resolve to the same bucket (R2_* feed the source config too); external OAuth avatar URLs pass through unmangled; docs corrected (web worker-mode cookie requirement TD-068, presign TTL 1h). |
| 2026-08-05 | Code-review pass (xhigh, 15 verified defects across the whole 2026-08-05 wave; 5 in this RCA's scope). **Cutover blockers fixed:** `generate_thumbnails.py` did not compile (`main()` declared `def` while awaiting — `SyntaxError`, so the mandatory pre-flag backfill could never run); `migrate_storage_to_r2.py` swallowed a listing failure and reported a clean 0-object "nothing to copy" **exit 0**, which the runbook reads as done immediately before emptying the source bucket — listing now raises and aborts non-zero, an empty source refuses to report success, and only the per-key HEAD stage may degrade. **Serving fixed:** thumb 404s now fall back client-side instead of rendering a permanently broken tile; the Worker's 24h `immutable` policy was unreachable because every upload stamps `max-age=3600`; the Worker cached an empty JWKS key set for a full hour and had no cache-bust on a `kid` miss (a Supabase signing-key rotation 404'd **every image for every user** for up to an hour, and the `alg`-only fallback made it worse by selecting the old key). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-05 | Move storage to Cloudflare R2 (not Cloudflare-CDN-in-front-of-Railway) | Only R2 makes bucket→client egress $0; the S3 layer is provider-agnostic so the move is an env repoint + copy, reusing the 2026-08-04 migration patterns. |
| 2026-08-05 | Keep presigned serving as the default; worker mode is opt-in (`IMAGE_SERVING_MODE=worker`) | Phase 1 (R2 + presigned) already kills the bill with zero client risk; worker URLs (stable + cacheable) roll out independently after the Worker is deployed. |
| 2026-08-05 | Auth headers only attach to non-presigned URLs (no `X-Amz-` query params) | S3 presigned requests reject any other auth mechanism ("Only one auth mechanism allowed"); worker URLs require the bearer token. |
| 2026-08-05 | Thumbnails are always written at upload (smaller of downscaled JPEG / original bytes) | `thumbnail_url` can then be emitted unconditionally for canonical keys — no per-object HEAD, no 404 tiles; backfill covers the legacy corpus before `THUMBNAIL_SERVING=true`. |
| 2026-08-05 | **Superseded:** "always written" is not guaranteed, so clients fall back on a thumb 404 instead of the read path proving existence | `_upload_thumbnail` is best-effort by contract and returns False without writing when the bytes cannot be decoded or the PUT fails, so the read path CAN emit a URL for an object that was never written — and mid-rollout the un-backfilled corpus is in the same state. A per-object HEAD on every list is the cost this design exists to avoid, and a `thumbnail_path` column means a schema change plus a backfill. A client-side retry of the full size closes every case (failed encode, legacy object, mid-rollout race) for free: `useImageWithFallback` / `thumbnailErrorFallback` on web, `AppNetworkImage.fallbackUrl` on Flutter. |
| 2026-08-05 | Worker takes the 24h `immutable` policy for write-once keys, overriding the object's own `cache-control` unless it is more restrictive | Every upload stamps `max-age=3600` (`DEFAULT_CACHE_CONTROL`), so preferring the object's own value made the immutable policy **unreachable in production** — 24x the origin fetches this cutover exists to remove, and no `immutable` means browsers revalidate on every reload. Canonical + `_thumb` keys are UUID-named and write-once, which is exactly what `immutable` asserts. `no-store`/`private`/`no-cache`/`max-age=0` still win, and short-lived `tmp/`+`generated/` previews always keep their own TTL. |
| 2026-08-05 | New `AppNetworkImage` (thin CachedNetworkImage wrapper) instead of routing the 20 stragglers through `AppImage` | Drop-in `Image.network` semantics (no shimmer/zoom/background tint) = zero visual/layout change; `AppImage`/`AppImageViewer` also gain headers for worker mode. |
| 2026-08-05 | Worker edge cache keyed on path only, accepting edge-level caching of authenticated objects | Objects are unguessable (`{user_id}/{uuid}`), URLs are only ever issued by ownership-checked API responses, and objects are write-once per key; hard per-request auth at the edge would defeat caching entirely (documented in `infra/images-worker/README.md`). |
| 2026-08-05 | Web stays on presigned mode until the frontend sets a domain-scoped `sb-<ref>-auth-token` cookie (TD-068) | `createClient` (browser default) sets no cookies and `<img>` can't set headers, so worker URLs 404 on web today; the cookie step is a small frontend change tracked as TD-068. R2 egress is $0, so presigned-on-web costs nothing — worker mode on web only adds cache hits. |

## Verification

```bash
cd backend && source .venv/bin/activate
pytest                      # 999 passed, 1 skipped (pre-existing WIP test timeout)
ruff check app/ scripts/ tests/

cd flutter && flutter analyze && flutter test   # 145 passed; 1 pre-existing WIP timeout
cd frontend && npm run lint && npm run build

python scripts/check_architecture.py
python scripts/check_docs_structure.py
```

Ops runbook (not repo-verifiable): see `infra/images-worker/README.md` and the
migration script docstrings for the exact order — R2 copy → cutover env →
Railway bucket empty → Worker deploy → `IMAGE_SERVING_MODE=worker` →
thumbnail backfill → `THUMBNAIL_SERVING=true`.

## Deferred debt

Items pushed to `docs/exec-plans/tech-debt-tracker.md`:
- Backend (on Railway) reading R2 for AI reference images is Railway→Cloudflare
  service egress (bounded, downscaled). Options: cache reference bytes
  server-side, or accept; revisit if the bill shifts to the AI path.
- Worker-edge cache serves any caller who knows the path until TTL; if hard
  per-request auth is ever required, move to signed cookies + path-only cache
  key (documented trade-off, accepted today).
- **TD-068:** worker-mode web images 404 until the frontend sets a
  domain-scoped `sb-<ref>-auth-token` cookie; web stays presigned until then.
