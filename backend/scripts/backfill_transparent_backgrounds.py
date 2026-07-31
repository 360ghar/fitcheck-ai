#!/usr/bin/env python3
"""
Backfill alpha transparency onto the existing generated-image corpus.

`app/utils/background_removal.py` cuts the flat white studio backdrop out of
newly generated item and flat-lay images. Every image generated BEFORE that
landed is still an opaque JPEG on white. This script re-mattes those objects
in place so the historical corpus matches new writes.

    cd backend && source .venv/bin/activate
    DRY_RUN=1 python scripts/backfill_transparent_backgrounds.py

=============================================================================
READ THIS BEFORE YOU "FIX" ANYTHING HERE
=============================================================================

1) THE FILE EXTENSION WILL DISAGREE WITH THE BYTES. ON PURPOSE.
   A matted object is WebP, but the storage key stays exactly as it was -
   usually `.jpg` or `.png`. This is deliberate and correct. The whole point of
   overwriting in place is that `image_url` and `thumbnail_url` stay
   byte-identical, so no DB row, no denormalised copy in
   `outfit_generations.image_urls`, no cached client payload and no shared-link
   URL goes stale. Supabase serves the object with the `content-type` recorded
   at upload (`image/webp`), and every browser plus Flutter's `Image.network`
   honours the response header over the URL suffix. Renaming keys to `.webp`
   would churn every URL in the product to fix a cosmetic mismatch nobody can
   see. Do not do it.

2) `thumbnail_url` IS NOT REGENERATED.
   A real thumbnail needs a NEW storage key, which is exactly the URL churn
   above; it would also double the runtime and orphan the old object forever,
   because every delete path in the app tracks only `storage_path`. The right
   long-term fix is Supabase's `render/image` transform endpoint
   (`/storage/v1/render/image/public/<bucket>/<key>?width=...`), which resizes
   on read and needs zero new keys. Out of scope here.

3) ON A GUARD REJECTION THIS SCRIPT DOES NOTHING AT ALL.
   No upload, no CDN invalidation, no wasted storage write. `skipped_*` is the
   "this image needs no work" fast path (a user photo, a scene shot, an
   already-transparent object), NOT a failure. Expect a large skip rate on
   `outfit_images`: most of those are model shots, which are deliberately never
   matted (a Pillow threshold cannot cut hair) and so land on `skipped_*`.

=============================================================================
CDN STALENESS - THE RESEARCHED ANSWER
=============================================================================

Verified against current Supabase docs, 2026-07:

* Default TTL. If an uploader does not pass `cacheControl`, Supabase applies
  `Cache-Control: max-age=3600`. Every object in our bucket predating the
  `cache_control` parameter on `StorageService.upload_file` carries that.
  ("Defaults to 3600 seconds." - storage-js `FileOptions`, and
  https://supabase.com/docs/reference/javascript/storage-from-upload)

* Pro and above get the Smart CDN, which self-purges on mutation.
  "With Smart CDN caching enabled, the asset metadata in your database is
  synchronized to the edge. This automatically revalidates the cache when the
  asset is changed or deleted." ... "It can take up to 60 seconds for the CDN
  cache to be invalidated as the asset metadata has to propagate across all
  the data-centers around the globe."
  (https://supabase.com/docs/guides/storage/cdn/smart-cdn)
  Smart CDN "is automatically enabled for Pro Plan and above"; the pricing
  matrix lists Free as Basic CDN. So on Pro+, an upsert is self-purging within
  ~60s and no cache busting is required.

* Free tier gets the basic CDN, where an overwrite serves stale bytes until the
  TTL expires. This is only stated in Supabase's 2022 launch blog, not in the
  current docs: the basic CDN "works by adding a 1-hour cache header to every
  request"; "if you update an image in S3, users will continue to see the old,
  stale image for one hour."
  (https://supabase.com/blog/storage-image-resizing-smart-cdn)

* There is NO manual purge API. The docs prescribe either a cache-busting query
  string or a new path. We use neither by default - see BUST_CACHE below.

* BROWSER caches are never invalidated, on any plan. "When an asset is
  invalidated at the CDN level, browsers may not update its cache."
  (smart-cdn, above.) So a user whose browser already holds an object keeps the
  old opaque bytes until its own `max-age=3600` lapses, regardless of plan.
  That is the real staleness ceiling here, and it is <= 1 hour.

Therefore: we always stamp `cache-control: 60` on re-upload, which caps FUTURE
staleness at a minute, and we accept up to ~1 hour of stale bytes for clients
already holding the old object. That is acceptable for a purely cosmetic
change. Verify with:

    curl -sI '<image_url>' | grep -i 'content-type\\|age\\|cache'

`BUST_CACHE=1` appends `?v=<epoch>` to `image_url` AND `thumbnail_url`, which
does defeat both caches - but it is URL churn, which the approved design
explicitly ruled out, so it stays OFF by default. Reach for it only if
measurement shows stale bytes you cannot wait out. It is safe if you do:
nothing in the backend, web or Flutter client parses these URLs (the API's
image normalisers pass them through untouched, and every delete path keys off
the `storage_path` column, never a URL).

=============================================================================
GRADUATED PRODUCTION RUN ORDER
=============================================================================

Never jump to the last line. Step 2 is the real visual check, bounded to your
own account before anyone else's wardrobe is touched.

    cd backend && source .venv/bin/activate

    # 1. Measure. Downloads and mattes DRY_RUN_SAMPLE images, writes nothing.
    DRY_RUN=1 python scripts/backfill_transparent_backgrounds.py

    # 2. Your own wardrobe only. Then LOOK at the images in the web app.
    ONLY_USER_ID=<your-uuid> LIMIT=20 python scripts/backfill_transparent_backgrounds.py

    # 3. A small real slice, gently.
    LIMIT=200 CONCURRENCY=4 python scripts/backfill_transparent_backgrounds.py

    # 4. The rest of item_images.
    CONCURRENCY=8 python scripts/backfill_transparent_backgrounds.py

    # 5. Outfit looks. Expect a very high skip rate; that is correct.
    TABLES=outfit_images python scripts/backfill_transparent_backgrounds.py

Also documented in `docs/BACKEND.md` under "Generated image transparency".

=============================================================================
ENVIRONMENT
=============================================================================

Required:
    SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    SUPABASE_SECRET_KEY=eyJ...          # service-role key (bypasses RLS)

Optional:
    DRY_RUN=0                           # 1 = measure only, write nothing
    TABLES=item_images                  # comma list; item_images,outfit_images
    PAGE_SIZE=500                       # DB page size
    LIMIT=0                             # 0 = unbounded, per table
    ONLY_USER_ID=                       # restrict to one user's images
    CONCURRENCY=8                       # download+matte+upload worker threads
    THROTTLE_MS=0                       # per-worker sleep after each image
    AUDIT_FILE=backend/logs/transparent_backfill.jsonl
    CACHE_CONTROL=60                    # seconds, stamped on every re-upload
    BUST_CACHE=0                        # 1 = append ?v=<epoch> to the URLs
    UPDATE_DIMENSIONS=1                 # write real width/height (see below)
    DRY_RUN_SAMPLE=20                   # images to matte during a dry run
    SUPABASE_STORAGE_BUCKET=fitcheck-images

WIDTH/HEIGHT: NULL on every row ever written, and both `ItemCard` and
`OutfitCard` already forward them to `<img>`, so today every card renders with
no intrinsic size and shifts layout on load. We have the decoded image in hand,
so backfilling them fixes a real CLS bug for free. They are written even on
skipped and rejected rows - we decoded those too and the dimensions are correct
regardless of whether the matte applied.

RESUME: one JSONL line per image. On startup every `row_id` whose last recorded
action is terminal (`matted` / `skipped` / `rejected` / `unresolvable`) is
skipped; `error` stays retryable. Safe to Ctrl-C or lose the host mid-run.
"""
from __future__ import annotations

import json
import os
import statistics
import sys
import threading
import time
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterator, NamedTuple, Optional

from supabase import create_client

# DELIBERATE EXCEPTION to the self-contained style of grant_free_pro_month.py /
# revert_expired_pro_trials.py: the matte algorithm is IMPORTED, never vendored.
# Copying 120 lines of pixel logic would guarantee that the day someone retunes
# WHITE_MIN_CHANNEL or the alpha ramp, the backfilled corpus silently stops
# matching new writes - which is the one thing this script exists to prevent.
# The import is cheap and safe: app/utils/ may only depend on app.core and the
# stdlib (enforced by scripts/check_architecture.py), and background_removal
# reaches for nothing but PIL, so this pulls in no Settings and no DB layer.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.utils.background_removal import (  # noqa: E402
    STATUS_ERROR,
    STATUS_MATTED,
    STATUS_REJECTED_ATE_SUBJECT,
    STATUS_REJECTED_CENTER_TRANSPARENT,
    STATUS_SKIPPED_NO_BACKGROUND,
    MatteResult,
    remove_white_background,
)

# --------------------------------------------------------------------------- #
# audit actions
# --------------------------------------------------------------------------- #
ACTION_MATTED = "matted"
ACTION_SKIPPED = "skipped"
ACTION_REJECTED = "rejected"
ACTION_ERROR = "error"
ACTION_UNRESOLVABLE = "unresolvable"

# An image whose last audit line carries one of these is never revisited.
# `error` is deliberately absent: a transient download failure must be retried
# on the next run, and re-running the matte on a row is harmless anyway.
TERMINAL_ACTIONS = frozenset({ACTION_MATTED, ACTION_SKIPPED, ACTION_REJECTED, ACTION_UNRESOLVABLE})

_STATUS_TO_ACTION = {
    STATUS_MATTED: ACTION_MATTED,
    STATUS_SKIPPED_NO_BACKGROUND: ACTION_SKIPPED,
    STATUS_REJECTED_ATE_SUBJECT: ACTION_REJECTED,
    STATUS_REJECTED_CENTER_TRANSPARENT: ACTION_REJECTED,
    STATUS_ERROR: ACTION_ERROR,
}

# Above this share of REJECTED images the guards are disagreeing with the
# generation prompts, and the fix is retuning the algorithm, not grinding
# through the corpus. See the warning in render_summary().
REJECT_WARN_RATIO = 0.10


class TableSpec(NamedTuple):
    """One backfill target.

    `parent_table` / `parent_fk` exist only for ONLY_USER_ID: neither image
    table carries a `user_id` column, which is precisely why the normal path
    needs no join at all - `storage_path` already embeds the user
    (`{user_id}/{YYYYMMDD}/item_{uuid8}{ext}`).
    """

    table: str
    parent_table: str
    parent_fk: str
    # Column filter applied to every query, e.g. {"generation_type": "ai"}.
    row_filter: dict[str, str]


TABLE_SPECS: dict[str, TableSpec] = {
    # Primary target: product shots generated on a white studio backdrop.
    "item_images": TableSpec("item_images", "items", "item_id", {}),
    # Secondary: only AI-generated looks. Most are model shots and will land on
    # `skipped_no_background` (G1) - that is the designed outcome, not a bug.
    "outfit_images": TableSpec("outfit_images", "outfits", "outfit_id", {"generation_type": "ai"}),
}

# Explicitly NOT targets, so nobody adds them later without reading why:
#   social_import_items  - temporary review-queue objects under
#                          {user_id}/tmp/..., promoted or deleted inside their
#                          TTL. Churn with no payoff.
#   items.source_image_url - the ORIGINAL user or social photo. It has a real
#                          background. Never matte a source photo.
#   outfit_generations.image_urls - denormalised copies of
#                          outfit_images.image_url; overwrite-in-place keeps
#                          them valid for free.
#   extraction_jobs      - dead table, zero Python references (verified by
#                          grep across backend/app).

SELECT_COLUMNS = "id,image_url,thumbnail_url,storage_path,width,height"

_PUBLIC_URL_MARKER = "/object/public/"

# Parent ids per `.in_()` clause. Keeps the querystring well under PostgREST's
# URL length ceiling for a user with a large wardrobe.
_ID_CHUNK = 200


# --------------------------------------------------------------------------- #
# env helpers (mirrors grant_free_pro_month.py)
# --------------------------------------------------------------------------- #
def _env(name: str, default: str | None = None, *, required: bool = False) -> str:
    value = os.environ.get(name, default)
    if required and not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value or ""


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {"1", "true", "yes", "on"}


def _env_int(name: str, default: int) -> int:
    raw = os.environ.get(name, str(default)).strip()
    try:
        return int(raw)
    except ValueError:
        print(f"WARNING: {name}={raw!r} is not an int, using {default}", file=sys.stderr)
        return default


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


# --------------------------------------------------------------------------- #
# storage key resolution
# --------------------------------------------------------------------------- #
def storage_key_from_public_url(url: str | None, bucket: str) -> Optional[str]:
    """Recover an object key from a Supabase public URL, or None.

    storage3 builds public URLs deterministically as
    `{base}/object/public/{bucket}/{key}` (`storage3/_sync/file_api.py`,
    `get_public_url`), so the split is exact rather than a guess. Any query
    string is stripped, which also makes this tolerant of a URL that a previous
    BUST_CACHE=1 run stamped with `?v=<epoch>`.
    """
    if not url:
        return None
    marker = f"{_PUBLIC_URL_MARKER}{bucket}/"
    _, _, tail = url.partition(marker)
    if not tail:
        return None
    key = tail.split("?", 1)[0].split("#", 1)[0].strip()
    return key or None


def resolve_storage_key(row: dict[str, Any], bucket: str) -> Optional[str]:
    """Object key for an image row: `storage_path`, else derived from the URL.

    `storage_path` is nullable - it was retrofitted onto both tables with
    `ADD COLUMN IF NOT EXISTS` - so rows written before that are NULL and have
    to be recovered from `image_url`.
    """
    path = (row.get("storage_path") or "").strip()
    if path:
        return path.lstrip("/") or None
    return storage_key_from_public_url(row.get("image_url"), bucket)


def with_version(url: str | None, version: int) -> Optional[str]:
    """Append `?v=<version>` to a URL, replacing any existing `v=` stamp."""
    if not url:
        return url
    base, sep, query = url.partition("?")
    if not sep:
        return f"{base}?v={version}"
    kept = [p for p in query.split("&") if p and not p.startswith("v=")]
    kept.append(f"v={version}")
    return f"{base}?{'&'.join(kept)}"


# --------------------------------------------------------------------------- #
# decisions (pure - unit tested)
# --------------------------------------------------------------------------- #
def action_for_status(status: str) -> str:
    """Map a MatteResult.status onto an audit action."""
    return _STATUS_TO_ACTION.get(status, ACTION_ERROR)


def should_upload(action: str) -> bool:
    """Only a successful matte produces new bytes worth writing.

    Rewriting identical bytes on a skip or a rejection would burn a storage
    write and a CDN invalidation for exactly zero visible change.
    """
    return action == ACTION_MATTED


def upload_options(content_type: str, cache_control: int) -> dict[str, str]:
    """`file_options` for the overwrite, mirroring StorageService.upload_file.

    `upsert` defaults to **False** in both `StorageService.upload_file` and
    storage3's `upload()`, so overwriting an existing key REQUIRES passing it
    explicitly or the request 409s. storage3 wraps `cache-control` into
    `Cache-Control: max-age=<value>`, so the value is seconds-as-a-string.

    We call storage3 directly rather than `StorageService.upload_file` because
    the latter is `async` and importing it would drag `app.core.config.Settings`
    and the whole service layer into a standalone script. The contract mirrored
    here is three header keys wide; the matte algorithm, which is the part that
    would actually rot if duplicated, is imported.
    """
    return {
        "content-type": content_type,
        "cache-control": str(cache_control),
        "upsert": "true",
    }


def build_row_update(
    row: dict[str, Any],
    result: MatteResult,
    *,
    update_dimensions: bool,
    bust_cache: bool,
    version: int,
) -> dict[str, Any]:
    """DB patch for one image row. Empty dict means "do not touch the row".

    Dimensions are written on skipped and rejected rows too: we decoded the
    image either way, so the values are correct regardless of whether the matte
    applied, and they are NULL today for every row in both tables.
    """
    update: dict[str, Any] = {}
    if update_dimensions and result.width and result.height:
        if row.get("width") != result.width or row.get("height") != result.height:
            update["width"] = result.width
            update["height"] = result.height
    if bust_cache and result.status == STATUS_MATTED:
        update["image_url"] = with_version(row.get("image_url"), version)
        if row.get("thumbnail_url"):
            update["thumbnail_url"] = with_version(row.get("thumbnail_url"), version)
    return update


# --------------------------------------------------------------------------- #
# audit
# --------------------------------------------------------------------------- #
def load_audit(path: Path) -> set[str]:
    """Row ids whose LAST recorded action is terminal.

    Last-wins, not first-wins: a row that errored and was later matted must not
    stay in the retry set, and a row matted in an earlier run must not be
    re-matted because a later `error` line exists for a different reason.
    """
    latest: dict[str, str] = {}
    if not path.exists():
        return set()
    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            row_id = rec.get("row_id")
            action = rec.get("action")
            if row_id and action:
                latest[row_id] = action
    return {row_id for row_id, action in latest.items() if action in TERMINAL_ACTIONS}


def append_audit(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, separators=(",", ":")) + "\n")


def make_record(
    *,
    table: str,
    row_id: str,
    storage_path: Optional[str],
    action: str,
    status: str,
    result: Optional[MatteResult] = None,
    bytes_before: int = 0,
    bytes_after: int = 0,
    decoded: bool = False,
) -> dict[str, Any]:
    """One audit line. Shape is fixed; downstream analysis depends on it."""
    return {
        "ts": _utc_now_iso(),
        "table": table,
        "row_id": row_id,
        "storage_path": storage_path,
        "action": action,
        "status": status,
        "transparent_fraction": round(result.transparent_fraction, 4) if result else None,
        "center_opacity": round(result.center_opacity, 4) if result else None,
        "bytes_before": bytes_before,
        "bytes_after": bytes_after,
        "decoded": decoded,
        "width": result.width if result else None,
        "height": result.height if result else None,
    }


# --------------------------------------------------------------------------- #
# summary (pure - unit tested)
# --------------------------------------------------------------------------- #
def summarize(records: list[dict[str, Any]]) -> dict[str, Any]:
    """Aggregate audit records into counts, byte totals and a reject ratio.

    The ratio denominator is every image we actually DECODED (i.e. excluding
    `unresolvable`, where we never got bytes to judge). Counting unresolvable
    rows would dilute the very signal the threshold exists to catch.
    """
    actions: dict[str, int] = {}
    statuses: dict[str, int] = {}
    before = after = 0
    for rec in records:
        action = rec.get("action") or ACTION_ERROR
        actions[action] = actions.get(action, 0) + 1
        status = rec.get("status") or ""
        if status:
            statuses[status] = statuses.get(status, 0) + 1
        if action == ACTION_MATTED:
            before += int(rec.get("bytes_before") or 0)
            after += int(rec.get("bytes_after") or 0)

    # Older audit files predate the explicit flag. Their terminal matte
    # actions imply decoding; new records use the flag so download errors do
    # not inflate the denominator.
    decoded = sum(
        1
        for rec in records
        if rec.get("decoded") is True
        or (
            "decoded" not in rec
            and rec.get("action") in {ACTION_MATTED, ACTION_SKIPPED, ACTION_REJECTED}
        )
    )
    rejected = actions.get(ACTION_REJECTED, 0)
    return {
        "total": len(records),
        "actions": actions,
        "statuses": statuses,
        "decoded": decoded,
        "bytes_before": before,
        "bytes_after": after,
        "bytes_delta": after - before,
        "reject_ratio": (rejected / decoded) if decoded else 0.0,
    }


def _fmt_bytes(value: int) -> str:
    sign = "-" if value < 0 else ""
    size = float(abs(value))
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            return f"{sign}{size:.1f} {unit}"
        size /= 1024
    return f"{sign}{size:.1f} GB"


def render_summary(summary: dict[str, Any]) -> str:
    """Human summary table plus the retune warning when rejects run high."""
    lines = ["", "=" * 64, "SUMMARY", "=" * 64]
    lines.append(f"  images seen           : {summary['total']}")
    for action in (ACTION_MATTED, ACTION_SKIPPED, ACTION_REJECTED, ACTION_ERROR, ACTION_UNRESOLVABLE):
        count = summary["actions"].get(action, 0)
        share = (count / summary["total"] * 100.0) if summary["total"] else 0.0
        lines.append(f"    {action:<18}: {count:>6}  ({share:5.1f}%)")

    if summary["statuses"]:
        lines.append("")
        lines.append("  matte status breakdown:")
        for status, count in sorted(summary["statuses"].items(), key=lambda kv: -kv[1]):
            lines.append(f"    {status:<32}: {count:>6}")

    lines.append("")
    lines.append(f"  bytes before (matted) : {_fmt_bytes(summary['bytes_before'])}")
    lines.append(f"  bytes after  (matted) : {_fmt_bytes(summary['bytes_after'])}")
    lines.append(f"  storage delta         : {_fmt_bytes(summary['bytes_delta'])}")

    if summary["reject_ratio"] > REJECT_WARN_RATIO:
        pct = summary["reject_ratio"] * 100.0
        lines.extend(
            [
                "",
                "!" * 64,
                f"!! WARNING: {pct:.1f}% of decoded images were REJECTED by the guards",
                f"!! (threshold {REJECT_WARN_RATIO * 100:.0f}%). STOP and retune before continuing.",
                "!!",
                "!! A high reject rate means the generation prompts are landing",
                "!! differently than app/utils/background_removal.py assumes - most",
                "!! likely the backdrop is not flat #FFFFFF. Inspect a few rejected",
                "!! storage_paths from the audit file, then retune WHITE_MIN_CHANNEL",
                "!! (and MAX_CHROMA) rather than grinding through the rest of the",
                "!! corpus. Rejections cost nothing - no bytes were written.",
                "!" * 64,
            ]
        )
    lines.append("=" * 64)
    return "\n".join(lines)


def render_dry_run_report(records: list[dict[str, Any]], corpus_total: Optional[int]) -> str:
    """The whole point of DRY_RUN: what will the guards do to the real corpus.

    Extrapolates the sampled per-image byte delta to the full row count so the
    operator can see the projected storage change before touching anything.
    """
    lines = ["", "=" * 64, "DRY RUN REPORT (nothing was written)", "=" * 64]
    if not records:
        lines.append("  no images sampled.")
        lines.append("=" * 64)
        return "\n".join(lines)

    lines.append(f"  sampled               : {len(records)} image(s)")
    if corpus_total is not None:
        lines.append(f"  corpus (rows to visit): {corpus_total}")

    lines.append("")
    lines.append("  status distribution:")
    statuses: dict[str, int] = {}
    for rec in records:
        statuses[rec.get("status") or "unknown"] = statuses.get(rec.get("status") or "unknown", 0) + 1
    for status, count in sorted(statuses.items(), key=lambda kv: -kv[1]):
        share = count / len(records) * 100.0
        bar = "#" * int(round(share / 4))
        lines.append(f"    {status:<32}: {count:>4}  ({share:5.1f}%) {bar}")

    # Per-status metric spread. The two numbers ARE the guards, so seeing where
    # the real corpus sits relative to them is the decision the operator makes.
    lines.append("")
    lines.append("  guard metrics by status (min / median / max):")
    for status in sorted(statuses):
        subset = [r for r in records if (r.get("status") or "unknown") == status]
        for metric in ("transparent_fraction", "center_opacity"):
            values = [r[metric] for r in subset if r.get(metric) is not None]
            if not values:
                continue
            lines.append(
                f"    {status:<32} {metric:<20}: "
                f"{min(values):.3f} / {statistics.median(values):.3f} / {max(values):.3f}"
            )

    lines.append("")
    lines.append("  byte-size histogram (source images):")
    buckets = [(0, 32), (32, 64), (64, 128), (128, 256), (256, 512), (512, 1 << 30)]
    for low, high in buckets:
        count = sum(1 for r in records if low * 1024 <= (r.get("bytes_before") or 0) < high * 1024)
        if not count:
            continue
        label = f"{low}-{high}KB" if high < (1 << 30) else f"{low}KB+"
        lines.append(f"    {label:<12}: {count:>4}  {'#' * count}")

    matted = [r for r in records if r.get("action") == ACTION_MATTED]
    lines.append("")
    if matted:
        before = sum(int(r.get("bytes_before") or 0) for r in matted)
        after = sum(int(r.get("bytes_after") or 0) for r in matted)
        delta_per_matted = (after - before) / len(matted)
        matte_rate = len(matted) / len(records)
        lines.append(f"  would matte           : {len(matted)}/{len(records)} ({matte_rate * 100:.1f}%)")
        lines.append(f"  sampled bytes         : {_fmt_bytes(before)} -> {_fmt_bytes(after)}")
        lines.append(f"  mean delta per matte  : {_fmt_bytes(int(delta_per_matted))}")
        if corpus_total is not None:
            projected = int(delta_per_matted * matte_rate * corpus_total)
            lines.append(f"  PROJECTED corpus delta: {_fmt_bytes(projected)} over {corpus_total} row(s)")
    else:
        lines.append("  would matte           : 0 - the guards reject or skip every sampled image.")

    summary = summarize(records)
    if summary["reject_ratio"] > REJECT_WARN_RATIO:
        lines.append("")
        lines.append(f"  !! {summary['reject_ratio'] * 100:.1f}% of the sample was REJECTED - retune before a live run.")
    lines.append("=" * 64)
    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# DB paging
# --------------------------------------------------------------------------- #
def _apply_filters(query: Any, spec: TableSpec) -> Any:
    for column, value in spec.row_filter.items():
        query = query.eq(column, value)
    return query


def parent_ids_for_user(db: Any, spec: TableSpec, user_id: str, page_size: int) -> list[str]:
    """ids of the user's parent rows (items / outfits) for ONLY_USER_ID mode.

    Walking user -> parent -> images is far cheaper than fetching every image
    and joining backwards, and a single user's wardrobe is bounded.
    """
    ids: list[str] = []
    offset = 0
    while True:
        res = (
            db.table(spec.parent_table)
            .select("id")
            .eq("user_id", user_id)
            .order("id")
            .range(offset, offset + page_size - 1)
            .execute()
        )
        rows = res.data or []
        ids.extend(row["id"] for row in rows if row.get("id"))
        if len(rows) < page_size:
            return ids
        offset += page_size


def count_rows(db: Any, spec: TableSpec, parent_ids: Optional[list[str]]) -> Optional[int]:
    """Exact row count, or None when the client cannot report one.

    Only used to print a corpus size and to project the storage delta in a dry
    run, so a client that cannot count is never fatal.
    """
    try:
        if parent_ids is None:
            query = _apply_filters(db.table(spec.table).select("id", count="exact"), spec)
            return getattr(query.limit(1).execute(), "count", None)
        if not parent_ids:
            return 0
        total = 0
        for i in range(0, len(parent_ids), _ID_CHUNK):
            query = _apply_filters(db.table(spec.table).select("id", count="exact"), spec)
            query = query.in_(spec.parent_fk, parent_ids[i : i + _ID_CHUNK])
            count = getattr(query.limit(1).execute(), "count", None)
            if count is None:
                return None
            total += count
        return total
    except Exception:
        return None


def page_rows(
    db: Any,
    spec: TableSpec,
    page_size: int,
    parent_ids: Optional[list[str]] = None,
) -> Iterator[dict[str, Any]]:
    """Yield image rows, offset-paginated, optionally scoped to parent ids."""
    chunks: list[Optional[list[str]]]
    if parent_ids is None:
        chunks = [None]
    else:
        chunks = [parent_ids[i : i + _ID_CHUNK] for i in range(0, len(parent_ids), _ID_CHUNK)]

    for chunk in chunks:
        offset = 0
        while True:
            query = _apply_filters(db.table(spec.table).select(SELECT_COLUMNS), spec)
            if chunk is not None:
                query = query.in_(spec.parent_fk, chunk)
            res = query.order("id").range(offset, offset + page_size - 1).execute()
            rows = res.data or []
            yield from rows
            if len(rows) < page_size:
                break
            offset += page_size


# --------------------------------------------------------------------------- #
# per-image work
# --------------------------------------------------------------------------- #
class Config(NamedTuple):
    bucket: str
    dry_run: bool
    cache_control: int
    bust_cache: bool
    update_dimensions: bool
    throttle_ms: int
    version: int


def process_row(db: Any, spec: TableSpec, row: dict[str, Any], cfg: Config) -> dict[str, Any]:
    """Download, matte, and (unless dry-run or non-matted) overwrite in place.

    Returns the audit record. Never raises: a per-image failure is logged as
    `error` and stays retryable on the next run.
    """
    row_id = str(row.get("id") or "")
    key = resolve_storage_key(row, cfg.bucket)
    if not key:
        # Neither storage_path nor a parseable image_url. Nothing to overwrite.
        return make_record(
            table=spec.table,
            row_id=row_id,
            storage_path=None,
            action=ACTION_UNRESOLVABLE,
            status="no_storage_key",
            decoded=False,
        )

    storage = db.storage.from_(cfg.bucket)
    try:
        # Downloading through the authenticated object API rather than the
        # public URL deliberately bypasses the CDN, so we always matte the
        # authoritative bytes and never a stale cached copy.
        original = storage.download(key)
    except Exception as exc:
        return make_record(
            table=spec.table,
            row_id=row_id,
            storage_path=key,
            action=ACTION_ERROR,
            status=f"download_failed: {exc}"[:200],
            decoded=False,
        )

    result = remove_white_background(original, key)
    action = action_for_status(result.status)
    record = make_record(
        table=spec.table,
        row_id=row_id,
        storage_path=key,
        action=action,
        status=result.status,
        result=result,
        bytes_before=len(original),
        bytes_after=len(result.image_bytes) if action == ACTION_MATTED else len(original),
        # remove_white_background is best-effort and returns STATUS_ERROR when
        # Pillow cannot decode the bytes. Only its successful/guarded outcomes
        # prove that an image was actually decoded for rejection metrics.
        decoded=action in {ACTION_MATTED, ACTION_SKIPPED, ACTION_REJECTED},
    )

    if cfg.dry_run:
        return record

    if should_upload(action):
        try:
            storage.upload(
                path=key,
                file=result.image_bytes,
                file_options=upload_options(result.content_type, cfg.cache_control),
            )
        except Exception as exc:
            record["action"] = ACTION_ERROR
            record["status"] = f"upload_failed: {exc}"[:200]
            return record

    update = build_row_update(
        row,
        result,
        update_dimensions=cfg.update_dimensions,
        bust_cache=cfg.bust_cache,
        version=cfg.version,
    )
    if update:
        try:
            db.table(spec.table).update(update).eq("id", row_id).execute()
        except Exception as exc:
            # The bytes are already correct; only the metadata patch failed.
            # Keep it retryable so the next run finishes the job.
            record["action"] = ACTION_ERROR
            record["status"] = f"row_update_failed: {exc}"[:200]

    if cfg.throttle_ms > 0:
        time.sleep(cfg.throttle_ms / 1000.0)
    return record


# --------------------------------------------------------------------------- #
# main
# --------------------------------------------------------------------------- #
def main() -> int:
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)

    dry_run = _env_bool("DRY_RUN", False)
    tables_raw = _env("TABLES", "item_images")
    table_names = [t.strip() for t in tables_raw.split(",") if t.strip()]
    unknown = [t for t in table_names if t not in TABLE_SPECS]
    if unknown:
        print(
            f"ERROR: unknown TABLES entries {unknown}; valid: {sorted(TABLE_SPECS)}",
            file=sys.stderr,
        )
        return 1

    page_size = max(1, _env_int("PAGE_SIZE", 500))
    limit = max(0, _env_int("LIMIT", 0))
    only_user_id = _env("ONLY_USER_ID", "").strip()
    concurrency = max(1, _env_int("CONCURRENCY", 8))
    dry_run_sample = max(1, _env_int("DRY_RUN_SAMPLE", 20))
    audit_path = Path(_env("AUDIT_FILE", "backend/logs/transparent_backfill.jsonl"))

    cfg = Config(
        bucket=_env("SUPABASE_STORAGE_BUCKET", "fitcheck-images"),
        dry_run=dry_run,
        cache_control=_env_int("CACHE_CONTROL", 60),
        bust_cache=_env_bool("BUST_CACHE", False),
        update_dimensions=_env_bool("UPDATE_DIMENSIONS", True),
        throttle_ms=max(0, _env_int("THROTTLE_MS", 0)),
        version=int(time.time()),
    )

    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] backfill transparent backgrounds")
    print(f"  tables            = {', '.join(table_names)}")
    print(f"  bucket            = {cfg.bucket}")
    print(f"  page_size         = {page_size}   limit = {limit or 'unbounded'}")
    print(f"  concurrency       = {concurrency}   throttle_ms = {cfg.throttle_ms}")
    print(f"  only_user_id      = {only_user_id or '(all users)'}")
    print(f"  cache_control     = {cfg.cache_control}s   bust_cache = {cfg.bust_cache}")
    print(f"  update_dimensions = {cfg.update_dimensions}")
    print(f"  audit_file        = {audit_path}")
    if dry_run:
        print(f"  dry_run_sample    = {dry_run_sample}")
    print()

    db = create_client(supabase_url, supabase_key)

    done = load_audit(audit_path) if not dry_run else set()
    if not dry_run:
        print(f"audit: {len(done)} image(s) already terminal, will be skipped")

    audit_lock = threading.Lock()
    all_records: list[dict[str, Any]] = []
    corpus_total = 0

    for name in table_names:
        spec = TABLE_SPECS[name]
        parent_ids: Optional[list[str]] = None
        if only_user_id:
            parent_ids = parent_ids_for_user(db, spec, only_user_id, page_size)
            print(f"[{name}] user {only_user_id} owns {len(parent_ids)} {spec.parent_table} row(s)")
            if not parent_ids:
                continue

        table_count = count_rows(db, spec, parent_ids)
        if table_count is not None:
            corpus_total += table_count
        print(f"[{name}] rows matching filters: {table_count if table_count is not None else 'unknown'}")

        budget = dry_run_sample if dry_run else (limit or None)
        pending: list[dict[str, Any]] = []
        for row in page_rows(db, spec, page_size, parent_ids):
            if str(row.get("id") or "") in done:
                continue
            pending.append(row)
            if budget is not None and len(pending) >= budget:
                break

        print(f"[{name}] {len(pending)} image(s) to process")
        if not pending:
            continue

        processed = 0
        with ThreadPoolExecutor(max_workers=concurrency) as pool:
            for record in pool.map(lambda r: process_row(db, spec, r, cfg), pending):
                all_records.append(record)
                if not dry_run:
                    with audit_lock:
                        append_audit(audit_path, record)
                processed += 1
                if processed % 25 == 0:
                    print(f"  [{name}] {processed}/{len(pending)}")
        print(f"  [{name}] {processed}/{len(pending)} done")

    if dry_run:
        print(render_dry_run_report(all_records, corpus_total or None))
        print("\nDRY-RUN: no uploads, no DB writes, no audit lines.")
        return 0

    summary = summarize(all_records)
    print(render_summary(summary))
    errors = summary["actions"].get(ACTION_ERROR, 0)
    if errors:
        print(f"{errors} image(s) errored and remain retryable; re-run to finish.", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
