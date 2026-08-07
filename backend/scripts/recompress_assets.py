#!/usr/bin/env python3
"""
Recompress canonical images in place to the storage compression profile
(WebP q82 @ 2048px longest edge, keep-smaller) and backfill missing ``_thumb``
siblings.

WHY: uploads were historically stored at full original resolution (measured:
1.09GB / 1326 objects; items at median 0.75MB, max 10.4MB), and thumbnails are
a recent feature that only ~51 of ~1296 canonical objects have. Since the
upload chokepoint now compresses everything new, this script brings the
existing corpus in line so the whole bucket fits comfortably under the R2
10GB free tier.

WHAT IT TOUCHES: every canonical key
(``{user}/{items|outfits|avatars|sources|feedback}/{32hex}.{ext}``) plus the
``generated/`` preview folder (both ``generated/{user}/{type}/...`` and the
legacy ``{user}/generated/{type}/...``). Each object is downloaded, downscaled
to ``STORAGE_MAX_EDGE`` and re-encoded as WebP at ``STORAGE_QUALITY`` — and
overwritten at the SAME key only when that actually shrinks it (keep-smaller:
a small PNG/WebP is never inflated). The ``_thumb.webp`` sibling is then
regenerated from the new bytes (or created when missing). Keys are unchanged,
so no DB row, presigned URL, or client-held path goes stale.

WHAT IT NEVER TOUCHES: ``tmp/`` (transient, weekly cleanup), ``_thumb`` keys
themselves, ``export/``, animated GIFs (Pillow would flatten them), and any
object whose re-encode would not be smaller.

    cd backend && source .venv/bin/activate
    python scripts/recompress_assets.py                 # dry-run report
    python scripts/recompress_assets.py --apply         # actually recompress

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--apply`` the script downloads and measures but
   writes nothing at all.

2) IN-PLACE OVERWRITE ONLY, NEVER A NEW KEY. S3 PUT is atomic, so a reader
   mid-fetch sees either the old bytes or the new bytes, never a mix. The
   object key, and therefore every stored URL, is byte-identical before and
   after.

3) KEEP-SMALLER. An object is only rewritten when the WebP re-encode at
   q82/2048px is strictly smaller than the stored bytes. Images that would
   grow are left byte-identical.

4) THUMB REGENERATION IS SAFE TO REPEAT. The thumb key is derived from the
   parent key (``{stem}_thumb.webp``) and overwritten in place; there is no
   orphan path. A thumb is written when the parent was re-encoded OR when the
   thumb is missing entirely.

5) RESUME. Every processed key gets a JSONL audit line; keys whose last
   action is terminal (``reencoded`` / ``unchanged`` / ``thumb_backfilled`` /
   ``skipped``) are skipped on the next run. ``error`` stays retryable.
   Safe to Ctrl-C or lose the host mid-run.

6) CDN STALENESS. Overwrites stamp ``cache-control: 60`` so any CDN or
   browser holding the old bytes refreshes within a minute (same approach as
   ``backfill_transparent_backgrounds.py``).

Env: AUDIT_FILE (default backend/logs/recompress_assets.jsonl),
     LIMIT, CONCURRENCY, ONLY_CATEGORY.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _fmt_bytes, _utc_now_iso, list_keys_with_mtime  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)
from app.services.storage_service import (  # noqa: E402
    STORAGE_MAX_EDGE,
    STORAGE_QUALITY,
    StorageService,
)
from app.utils.image_processing import (  # noqa: E402
    downscale_image_bytes_to_webp,
    sniff_image_mime,
    sniff_image_mime_from_magic,
)

# Short TTL on overwrites so CDN/browser caches holding the old bytes refresh
# quickly (see backfill_transparent_backgrounds.py for the staleness research).
REWRITE_CACHE_CONTROL = "60"

# Canonical durable images + the generated/ preview folder (both layouts).
# Thumb keys (``{32hex}_thumb.webp``) never match: the name regex requires the
# extension directly after the 32-hex name.
_KEY_RE = re.compile(
    r"^(?:[^/\\]+/(?:items|outfits|avatars|sources|feedback)|"
    r"generated/[^/\\]+/[^/\\]+|[^/\\]+/generated/[^/\\]+)/"
    r"[0-9a-f]{32}\.(?:jpg|jpeg|png|webp|gif|avif)$"
)

CATEGORIES = ("items", "outfits", "avatars", "sources", "feedback", "generated")

ACTION_REENCODED = "reencoded"
ACTION_UNCHANGED = "unchanged"
ACTION_THUMB_BACKFILLED = "thumb_backfilled"
ACTION_SKIPPED = "skipped"
ACTION_ERROR = "error"

# A key whose last audit line carries one of these is never revisited.
# `error` is deliberately absent: a transient download failure must be retried.
TERMINAL_ACTIONS = frozenset(
    {ACTION_REENCODED, ACTION_UNCHANGED, ACTION_THUMB_BACKFILLED, ACTION_SKIPPED}
)


def category_of(key: str) -> str:
    """Category of a key: second segment for canonical, first for top-level
    ``generated/`` (matches scripts/storage_inventory.py's classifier)."""
    parts = key.split("/")
    if parts and parts[0] in CATEGORIES:
        return parts[0]
    if len(parts) >= 2 and parts[1] in CATEGORIES:
        return parts[1]
    return "?"


def decide_reencode(data: bytes) -> Optional[bytes]:
    """WebP q82 @ 2048px bytes when strictly smaller, else None.

    ``None`` means "leave the object byte-identical": already within bounds
    (``downscale_image_bytes_to_webp`` returns the input for a within-bounds
    WebP), a re-encode that would grow, an undecodable payload, or an
    animated GIF (Pillow would flatten it to a single frame). Pure function
    (unit-tested without the bucket).
    """
    mime = sniff_image_mime_from_magic(data[:32])
    if mime == "image/gif":
        return None
    webp = downscale_image_bytes_to_webp(
        data, max_edge=STORAGE_MAX_EDGE, quality=STORAGE_QUALITY
    )
    if webp is None or len(webp) >= len(data):
        return None
    return webp


def load_audit(path: Path) -> set:
    """Keys whose LAST recorded action is terminal (last-wins)."""
    latest: Dict[str, str] = {}
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
            key = rec.get("key")
            action = rec.get("action")
            if key and action:
                latest[key] = action
    return {key for key, action in latest.items() if action in TERMINAL_ACTIONS}


def append_audit(path: Path, record: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, separators=(",", ":")) + "\n")


def make_record(
    *,
    key: str,
    action: str,
    bytes_before: int = 0,
    bytes_after: int = 0,
    error: str = "",
) -> dict:
    return {
        "ts": _utc_now_iso(),
        "action": action,
        "key": key,
        "category": category_of(key),
        "bytes_before": bytes_before,
        "bytes_after": bytes_after,
        "error": error or None,
    }


async def process_key(
    backend,
    key: str,
    existing_keys: set,
    *,
    dry_run: bool,
    audit_path: Path,
) -> dict:
    """Download, re-encode (keep-smaller), overwrite in place, fix the thumb.

    Runs on the script's single event loop (the S3 backend caches one client
    bound to whichever loop created it, so per-thread ``asyncio.run`` would
    crash with a cross-loop Future error — concurrency is an asyncio
    semaphore instead). The CPU-bound Pillow encode is offloaded via
    ``asyncio.to_thread`` so the loop stays responsive. Never raises — a
    per-key failure becomes an ``error`` audit line and stays retryable.
    Returns the audit record.
    """
    try:
        data = await backend.download(key)
    except Exception as exc:  # noqa: BLE001
        record = make_record(
            key=key, action=ACTION_ERROR, error=f"download_failed: {exc}"[:200]
        )
        if not dry_run:
            append_audit(audit_path, record)
        return record

    new_bytes = await asyncio.to_thread(decide_reencode, data)

    thumb_key = StorageService.thumb_key_for(key)
    thumb_missing = thumb_key is not None and thumb_key not in existing_keys
    thumb_needed = thumb_key is not None and (new_bytes is not None or thumb_missing)

    if dry_run:
        if new_bytes is not None:
            action = ACTION_REENCODED
        elif thumb_needed:
            action = ACTION_THUMB_BACKFILLED
        else:
            action = ACTION_UNCHANGED
        return make_record(
            key=key,
            action=action,
            bytes_before=len(data),
            bytes_after=len(new_bytes) if new_bytes is not None else len(data),
        )

    try:
        if new_bytes is not None:
            await backend.upload(
                key=key,
                data=new_bytes,
                content_type=sniff_image_mime(new_bytes),
                cache_control=REWRITE_CACHE_CONTROL,
            )
        thumb_ok = True
        if thumb_needed:
            # Regenerate (or create) the thumb from the NEW bytes when the
            # parent was re-encoded, else from the original bytes. Best-effort
            # by contract; a thumb failure never fails the parent. A failed
            # thumb must record an ERROR (retryable) rather than a terminal
            # action: resume would otherwise skip the key with no thumb.
            thumb_ok = await StorageService._upload_thumbnail(  # noqa: SLF001 - script-only
                backend, key, new_bytes if new_bytes is not None else data
            )
        if thumb_needed and not thumb_ok:
            record = make_record(
                key=key,
                action=ACTION_ERROR,
                bytes_before=len(data),
                error="thumb_failed",
            )
            append_audit(audit_path, record)
            return record
    except Exception as exc:  # noqa: BLE001
        record = make_record(
            key=key,
            action=ACTION_ERROR,
            bytes_before=len(data),
            error=f"upload_failed: {exc}"[:200],
        )
        append_audit(audit_path, record)
        return record

    if new_bytes is not None:
        action = ACTION_REENCODED
    elif thumb_missing:
        action = ACTION_THUMB_BACKFILLED
    else:
        action = ACTION_UNCHANGED
    record = make_record(
        key=key,
        action=action,
        bytes_before=len(data),
        bytes_after=len(new_bytes) if new_bytes is not None else len(data),
    )
    append_audit(audit_path, record)
    return record


def render_summary(records: List[dict], total: int, skipped_audit: int) -> str:
    counts: Dict[str, int] = {}
    before = after = 0
    for rec in records:
        action = rec.get("action") or ACTION_ERROR
        counts[action] = counts.get(action, 0) + 1
        if action == ACTION_REENCODED:
            before += int(rec.get("bytes_before") or 0)
            after += int(rec.get("bytes_after") or 0)
    lines = [
        "",
        "=" * 64,
        "SUMMARY",
        "=" * 64,
        f"  keys seen        : {total}",
        f"  keys processed   : {len(records)} ({skipped_audit} skipped from audit)",
        f"  reencoded        : {counts.get(ACTION_REENCODED, 0)}",
        f"  thumb backfilled : {counts.get(ACTION_THUMB_BACKFILLED, 0)}",
        f"  unchanged        : {counts.get(ACTION_UNCHANGED, 0)}",
        f"  errors           : {counts.get(ACTION_ERROR, 0)}",
        "",
        f"  bytes (reencoded): {_fmt_bytes(before)} -> {_fmt_bytes(after)}",
        f"  savings          : {_fmt_bytes(before - after)}",
        "=" * 64,
    ]
    return "\n".join(lines)


async def _run(
    apply: bool,
    audit_path: Path,
    concurrency: int,
    limit: int,
    only_category: Optional[str],
    listing: Optional[Dict[str, datetime]] = None,
) -> int:
    backend = get_storage_backend()
    try:
        if listing is None:
            print("Listing bucket objects...")
            listing = await list_keys_with_mtime(backend)
        keys = sorted(listing)
        print(f"  {len(keys)} object(s) in bucket")

        targets = [key for key in keys if _KEY_RE.fullmatch(key)]
        if only_category:
            targets = [key for key in targets if category_of(key) == only_category]
        if limit:
            targets = targets[:limit]
        print(f"  {len(targets)} canonical/generated object(s) are recompress candidates")

        if not targets:
            print("\nNothing to recompress.")
            return 0

        existing = set(keys)
        done = load_audit(audit_path) if apply else set()
        pending = [key for key in targets if key not in done]
        print(f"  {len(pending)} to process ({len(done)} already terminal in audit)")

        if not pending:
            print("\nAll candidates already processed.")
            return 0

        records: List[dict] = []
        processed = 0

        # Single event loop, bounded concurrency via a semaphore: the S3
        # backend caches ONE client bound to the loop that created it, so the
        # whole run (downloads + uploads) must stay on this loop. The
        # CPU-bound encode is offloaded per key in process_key.
        sem = asyncio.Semaphore(concurrency)

        async def process_one(key: str) -> dict:
            async with sem:
                return await process_key(
                    backend,
                    key,
                    existing,
                    dry_run=not apply,
                    audit_path=audit_path,
                )

        for coro in asyncio.as_completed([process_one(key) for key in pending]):
            records.append(await coro)
            processed += 1
            if processed % 50 == 0:
                print(f"  [{processed}/{len(pending)}]")

        print(render_summary(records, len(targets), len(done)))
        if not apply:
            print("\nDRY-RUN: no uploads, no writes. Re-run with --apply to execute.")
        return 0
    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Recompress canonical/generated images to WebP q82 @ 2048px "
        "(keep-smaller) and backfill missing thumbnails (dry-run by default)."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually overwrite the objects (default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/recompress_assets.jsonl"),
        help="JSONL audit log path for processed keys.",
    )
    parser.add_argument(
        "--concurrency",
        type=int,
        default=int(_env("CONCURRENCY", "8")),
        help="Bounded in-flight downloads/uploads (asyncio semaphore).",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=int(_env("LIMIT", "0")),
        help="Process at most this many keys (0 = unbounded).",
    )
    parser.add_argument(
        "--only-category",
        default=_env("ONLY_CATEGORY", "") or None,
        help="Only one category (items, outfits, avatars, sources, feedback, "
        "generated).",
    )
    args = parser.parse_args()

    mode = "LIVE (apply)" if args.apply else "DRY-RUN"
    print(f"[{mode}] asset recompression (WebP q{STORAGE_QUALITY} @ {STORAGE_MAX_EDGE}px)")
    print(f"  target       = {get_storage_backend().endpoint_url}/{get_storage_backend().bucket}")
    print(f"  only_category= {args.only_category or '(all)'}")
    print(f"  concurrency  = {args.concurrency}   limit = {args.limit or 'unbounded'}")
    print(f"  audit_file   = {args.audit_file}")
    print()

    return asyncio.run(
        _run(
            apply=args.apply,
            audit_path=Path(args.audit_file),
            concurrency=max(1, args.concurrency),
            limit=max(0, args.limit),
            only_category=args.only_category,
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
