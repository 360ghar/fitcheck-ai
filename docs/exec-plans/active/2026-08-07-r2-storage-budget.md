# R2 storage budget — stay under 10GB long-term

Date: 2026-08-07 · Status: active (implementation done; ops run pending user execution)

## Problem

Cloudflare R2 free tier is 10GB. Measured on 2026-08-07: the bucket held
**1.09GB / 1326 objects** with the R2 migration barely weeks old, and the
user had already hit 2GB before the temp-preview cleanup. Three structural
causes:

1. **Uploads stored at full original resolution.** Nothing downscaled or
   re-encoded JPEG/PNG/WebP/AVIF on the way in (only HEIC/BMP/TIFF were
   transcoded). Measured: items median 0.75MB / max **10.4MB**, avatars up to
   6.3MB, sources up to 3.6MB. Nothing consumes more than 2048px downstream
   (AI references are capped at 1568px), so this was pure waste.
2. **Storage leaks in delete/replace paths.** `delete_item` and
   `delete_outfit` (single deletes) removed only the DB row; `upload_avatar`
   never removed the previous avatar object. Measured impact: **296 orphan
   objects / 192MB (17.6% of the bucket)** — 207 orphan sources (109MB), 47
   orphan avatars (53MB), 6 orphan items, 6 orphan outfits, 30 `generated/`.
3. **Thumbnails are a recent feature with no backfill** — only ~51 of ~1296
   canonical objects had a `_thumb` sibling (grids fetch full-size images).

## Decisions (user-approved)

- Compression profile: **WebP everywhere, q82, 2048px longest-edge cap,
  keep-smaller** (visually lossless on screens; ~3-4x smaller).
- **Backfill the existing corpus**: recompress in place + backfill missing
  thumbs (1.09GB → ~400-450MB one-time).
- **No per-user quota** — rely on compression + cleanup for now.

## Implementation

### Phase A — stop the leaks (code)

- `app/api/v1/items.py` `delete_item` — resolves owned storage paths
  (source photo + item images + `_thumb` siblings) BEFORE deleting the row,
  then best-effort `delete_multiple_images` (same contract as
  `batch_delete_items`).
- `app/api/v1/outfits.py` `delete_outfit` — same for outfit images.
- `app/api/v1/users.py` `upload_avatar` — captures the current `avatar_url`
  before the row update; after success, deletes the previous object only
  when it is the caller's own bucket key (`{user_id}/avatars/...`;
  external OAuth URLs pass through untouched).
- Social-import/batch reject paths already clean temp previews; sources for
  fully-rejected photos remain an edge covered by the weekly orphan sweep.

### Phase B — compress at upload (code)

- `StorageService._normalize_upload_bytes` (the chokepoint every upload path
  routes through: item, outfit, avatar, feedback, source, temp) now applies
  the storage compression profile after the HEIC transcode:
  `downscale_image_bytes_to_webp(data, STORAGE_MAX_EDGE=2048,
  STORAGE_QUALITY=82)`, keep-smaller (original kept when WebP is not
  strictly smaller), animated GIF passthrough, alpha preserved.
- `image_generation_agent.save_generated_image` (user-saved renders) routes
  through the same normalization before the key/content-type are sniffed.
- Keys/Content-Types are minted from the sniffed final bytes, so converted
  objects carry `.webp` / `image/webp` automatically.

### Phase C — one-time backfill script (new)

- `backend/scripts/recompress_assets.py` — lists canonical keys
  (`{user}/{items|outfits|avatars|sources|feedback}/...`) plus `generated/`
  (both layouts); downloads, re-encodes (keep-smaller), overwrites the SAME
  key in place (no URL churn), regenerates/backfills `_thumb.webp`; dry-run
  default, `--apply`, JSONL audit, resume-safe (terminal actions skipped),
  `--only-category` / `--limit` / `--concurrency`. Never touches `tmp/`,
  `_thumb` keys, exports, or anything that would grow. Overwrites stamp
  `cache-control: 60` (CDN staleness ceiling ~1 min).
- Overlaps `generate_thumbnails.py` only on the thumb backfill; both are
  idempotent and write the same derived key.

## Verification

- Backend suite: **1251 passed, 4 skipped** (was 1216; +35 new tests).
- New tests: compression profile (large JPEG→smaller WebP, downscale to
  2048px, keep-smaller passthrough of optimized WebP, PNG alpha survival,
  animated GIF passthrough) in `test_storage_content_type.py`; single
  item/outfit delete + avatar-replace leak regressions in
  `test_wave_a_auth_ownership_storage.py`; script pure functions + fake-
  backend `_run` in `test_recompress_assets.py`.
- ruff clean on all touched code (one pre-existing F401 in the parallel
  session's untracked `app/api/v1/admin/users.py` left to them).
- Worker tests unaffected (serving layer unchanged; keys unchanged).

### Real-bucket dry-run (2026-08-07, read-only, full corpus)

`python scripts/recompress_assets.py` (dry-run) over all 1326 objects:

| Metric | Value |
|---|---|
| reencoded | 1203 |
| thumb backfilled | 99 |
| unchanged | 24 |
| errors | 0 |
| bytes (reencoded only) | 1.0GB → 119.2MB |
| projected savings | **~912MB** (bucket ~1.09GB → ~180-200MB incl. thumbs) |

(The run also surfaced and fixed a concurrency bug: the S3 backend caches one
client bound to its creating event loop, so per-thread `asyncio.run` crashes
with a cross-loop Future error — the script now uses a single loop with an
`asyncio.Semaphore` and `asyncio.to_thread` for the CPU-bound encode.
`backfill_transparent_backgrounds.py` has the same latent pattern and should
be migrated if it is ever run again.)

### Post-apply review (2026-08-07)

Found and fixed in `recompress_assets.py` after the live run:
- A failed thumb write was recorded as the terminal `thumb_backfilled` action
  (the `_upload_thumbnail` False return was ignored), so resume would never
  retry it; now a failed thumb records a retryable `error` while the parent
  overwrite still succeeds.
- Error records (download/upload/thumb failures) were returned to the in-memory
  summary but never appended to the audit file, contradicting the docstring;
  they are now persisted so failures leave a durable trail.
- Verified serving correctness for WebP-bytes-under-`.jpg/.png` keys: the
  Cloudflare Worker serves Content-Type from R2 object metadata (spot-checked
  real objects: `image/webp`), all `backend.upload()` call sites route through
  `_normalize_upload_bytes` or the thumb writer, and `save_generated_image` /
  temp-upload helpers sniff the final bytes before minting keys.

## Ops run (user executes, in order)

```bash
cd backend && source .venv/bin/activate
python scripts/storage_inventory.py                  # dry-run: ~296 orphans / ~192MB
python scripts/storage_inventory.py --delete         # reclaim the orphans now
python scripts/recompress_assets.py                  # dry-run (already measured: ~912MB)
python scripts/recompress_assets.py --apply          # 1.09GB -> ~180-200MB (incl. thumbs)
python scripts/storage_inventory.py                  # verify: 0 orphans, new totals
```

Manual QA after deploy: one extraction + one background-removal run to
confirm 2048px sources don't regress quality.

## Keeping it under 10GB (weekly routine, documented in docs/BACKEND.md)

```bash
python scripts/cleanup_temp_assets.py --delete       # temp previews (both layouts)
python scripts/storage_inventory.py --delete         # orphans from leaks/failures
```

- `generated/` (user-saved renders) keeps the 30-day retention.
- Growth math: the recompressed corpus averages ~100KB per canonical object
  (1.0GB → 119MB across 1203 re-encoded objects); at the recent heavy-test
  rate (~125 items/day), that's ~12MB/day (~375MB/month) of durable growth,
  with tmp churn reclaimed weekly — comfortably inside 10GB.

## Deferred

- R2 lifecycle rule on `tmp/` for automated expiry once the top-level layout
  is deployed (belt-and-braces on top of the weekly cleanup).
- Make `generated/` DB-referenced so saved renders stop being orphans
  (already tracked as debt in storage_inventory.py).
- Per-user storage quota if usage grows past ~5GB.
