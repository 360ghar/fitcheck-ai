#!/usr/bin/env python3
"""
Migrate existing objects from Supabase Storage to the Railway S3-compatible Bucket.

This is a TWO-PHASE migration. Phase A (dry-run, the default) lists every
object in the configured Supabase Storage bucket(s), compares against what is
already present in the Railway bucket, and reports exactly what WOULD be copied
and what DB rows would need their URLs rewritten. Phase B (live, ``--apply``)
downloads each missing object from Supabase and uploads it to the Railway
bucket, then — optionally — clears the stale public ``image_url`` /
``thumbnail_url`` columns.

    cd backend && source .venv/bin/activate
    # Phase A: measure only, writes nothing
    python scripts/migrate_storage_to_railway.py

    # Phase B: actually copy objects into the Railway bucket
    python scripts/migrate_storage_to_railway.py --apply

    # Phase B + clear stale public URL columns (see KEY MAPPING / URL columns)
    CLEAR_URL_COLUMNS=1 python scripts/migrate_storage_to_railway.py --apply

=============================================================================
KEY MAPPING DECISION — KEEP THE EXISTING KEYS AS-IS
=============================================================================

The old keys are ``{user_id}/{timestamp}/{prefix}_{uuid}{ext}`` (and
``{user_id}/sources/...``, ``{user_id}/tmp/...``, ``{user_id}/generated/...``).
The NEW layout is ``{user_id}/{category}/{uuid4hex}.{ext}``. For this migration
we deliberately KEEP the existing keys unchanged and copy each object to the
SAME key in the Railway bucket.

Why: rewriting every key would churn every URL and every ``storage_path`` and
risk breaking references. By copying to the same key we guarantee that:

  * every ``storage_path`` in the DB remains valid (keys are unchanged),
  * no DB row needs its ``storage_path`` rewritten,
  * the object bytes are preserved byte-for-byte.

Consequence: the Railway bucket will contain OLD-style keys until the separate
folder-structure hardening pass is applied (that is a separate step, out of
scope here). This is documented and expected.

=============================================================================
URL COLUMNS (image_url / thumbnail_url)
=============================================================================

``image_url`` / ``thumbnail_url`` historically held PUBLIC Supabase URLs
(``.../storage/v1/object/public/<bucket>/<key>``). With PRIVATE buckets the
canonical serving path is now a short-lived presigned GET URL materialized at
read time from ``storage_path``, so these stored URLs are stale and should not
be trusted. The SOURCE OF TRUTH is ``storage_path``.

This script does NOT rewrite ``storage_path`` (keys are unchanged). It also
does NOT touch the URL columns by default - clearing them is optional and
controlled by ``CLEAR_URL_COLUMNS=1``. When enabled, live mode sets
``image_url``/``thumbnail_url`` to NULL on ``item_images`` and ``outfit_images``
rows whose ``storage_path`` was successfully migrated. This is safe because the
serving layer regenerates URLs from ``storage_path`` at read time; but it is
destructive to the stored (stale) URLs, so it stays OFF unless you opt in.

=============================================================================
SUPABASE BUCKETS
=============================================================================

The primary bucket is ``SUPABASE_STORAGE_BUCKET`` (default ``fitcheck-images``).
The schema also inserted legacy buckets ``items``, ``outfits``, ``avatars``.
All of them are migrated by default. Override with ``SOURCE_BUCKETS=``
(comma-separated) to target a subset.

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--apply`` the script does no writes at all - no
   uploads, no DB writes, no audit lines.

2) IDEMPOTENT. A key already present in the Railway bucket is skipped. A
   re-run only copies keys that are still missing, so a crash or Ctrl-C
   mid-run is safely resumed.

3) AUDIT LOG. Every copied key is appended to ``AUDIT_FILE`` (JSONL) with the
   source bucket, key, size, and a status. Errors are recorded as ``error``
   rows and remain retryable on the next run.

=============================================================================
ENVIRONMENT
=============================================================================

Required (from ``backend/.env`` via ``app.core.config``):
    SUPABASE_URL
    SUPABASE_SECRET_KEY              # service-role key (read Supabase storage)
    OBJECT_STORAGE_*                 # or Railway BUCKET/ENDPOINT/REGION/... aliases

Optional:
    SOURCE_BUCKETS=                  # comma list; default = fitcheck-images,items,outfits,avatars
    CLEAR_URL_COLUMNS=0             # 1 = NULL the stale image_url/thumbnail_url (live only)
    AUDIT_FILE=backend/logs/storage_migration.jsonl
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.connection import SupabaseDB  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)

from app.core.config import settings  # noqa: E402

# Cache-Control stamped on every migrated object (matches StorageService).
DEFAULT_CACHE_CONTROL = "3600"
DEFAULT_CONTENT_TYPE = "application/octet-stream"

# Supabase buckets migrated by default: the primary bucket (from config) plus
# the legacy buckets the schema inserted.
DEFAULT_SOURCE_BUCKETS = [
    settings.SUPABASE_STORAGE_BUCKET or "fitcheck-images",
    "items",
    "outfits",
    "avatars",
]


# --- env helpers ------------------------------------------------------------ #
def _env(name: str, default: str = "") -> str:
    return os.environ.get(name, default)


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {
        "1",
        "true",
        "yes",
        "on",
    }


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _fmt_bytes(value: int) -> str:
    size = float(abs(value))
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} GB"


# --------------------------------------------------------------------------- #
# Supabase storage listing (recursive)
# --------------------------------------------------------------------------- #
def _walk_supabase(fb, prefix: str = "") -> List[Tuple[str, int, str]]:
    """Recursively list all objects under a Supabase storage bucket.

    ``db.storage.from_(bucket).list(path)`` is NOT recursive: it returns the
    immediate children of a folder. A folder entry has no ``metadata.size``; a
    file entry has ``metadata.size`` (and usually ``metadata.mimetype``). We
    walk folders depth-first and return ``(key, size, mimetype)`` tuples.
    """
    results: List[Tuple[str, int, str]] = []
    items = fb.list(prefix or None)
    for item in items or []:
        name = item.get("name")
        if not name:
            continue
        key = f"{prefix}/{name}" if prefix else name
        metadata = item.get("metadata")
        if metadata and isinstance(metadata, dict) and "size" in metadata:
            mimetype = metadata.get("mimetype") or ""
            results.append((key, int(metadata.get("size") or 0), mimetype))
        else:
            # A folder - recurse.
            results.extend(_walk_supabase(fb, key))
    return results


def list_supabase_objects(db, bucket: str) -> List[Tuple[str, int, str]]:
    """List every object in a Supabase storage bucket as ``(key, size, mimetype)``."""
    try:
        fb = db.storage.from_(bucket)
        return _walk_supabase(fb)
    except Exception as e:  # noqa: BLE001
        print(f"WARNING: could not list bucket '{bucket}': {e}", file=sys.stderr)
        return []


# --------------------------------------------------------------------------- #
# DB URL column clearing (optional, live only)
# --------------------------------------------------------------------------- #
def clear_url_columns(db, migrated_keys: List[str]) -> None:
    """Set image_url/thumbnail_url to NULL on rows whose storage_path migrated.

    Best-effort; only runs when CLEAR_URL_COLUMNS=1 and --apply. The serving
    layer regenerates URLs from storage_path at read time, so NULLing the stale
    public URLs is safe but destructive to the stored values.
    """
    for table in ("item_images", "outfit_images"):
        try:
            resp = (
                db.table(table)
                .update({"image_url": None, "thumbnail_url": None})
                .in_("storage_path", migrated_keys)
                .execute()
            )
            print(f"  [url-clear] {table}: {len(resp.data or [])} row(s) cleared")
        except Exception as e:  # noqa: BLE001
            print(
                f"  [url-clear] WARNING: {table} update failed: {e}",
                file=sys.stderr,
            )


# --------------------------------------------------------------------------- #
# async run
# --------------------------------------------------------------------------- #
async def _run(
    apply: bool,
    source_buckets: List[str],
    clear_url_columns_flag: bool,
    audit_path: Path,
) -> int:
    backend = get_storage_backend()
    try:
        db = SupabaseDB.get_service_client()

        print("Listing existing Railway bucket objects...")
        existing = set(await backend.list_keys(prefix=""))
        print(f"  {len(existing)} object(s) already in Railway bucket")

        total_objects = 0
        total_bytes = 0
        to_copy_total = 0
        skipped_total = 0
        error_total = 0
        migrated_keys: List[str] = []

        for bucket in source_buckets:
            print(f"\n[{bucket}] listing Supabase objects...")
            objects = list_supabase_objects(db, bucket)
            print(f"  {len(objects)} object(s) in Supabase bucket '{bucket}'")

            to_copy = [
                (key, size, mimetype) for key, size, mimetype in objects if key not in existing
            ]
            skipped = [key for key, _, _ in objects if key in existing]

            total_objects += len(objects)
            total_bytes += sum(size for _, size, _ in objects)
            to_copy_total += len(to_copy)
            skipped_total += len(skipped)

            print(f"  to copy  : {len(to_copy)}")
            print(f"  already  : {len(skipped)} (skipped)")
            if to_copy:
                print(f"  total bytes to copy: {_fmt_bytes(sum(s for _, s, _ in to_copy))}")

            if not apply:
                # Dry run: report what would be copied, do nothing.
                if to_copy:
                    print(f"  DRY-RUN: would copy {len(to_copy)} object(s) from '{bucket}':")
                    for key, size, _ in to_copy[:20]:
                        print(f"    {key}  ({_fmt_bytes(size)})")
                    if len(to_copy) > 20:
                        print(f"    ... and {len(to_copy) - 20} more")
                continue

            # Live: download + upload each missing object.
            audit_path.parent.mkdir(parents=True, exist_ok=True)
            with audit_path.open("a", encoding="utf-8") as fh:
                for key, size, mimetype in to_copy:
                    try:
                        data = await asyncio.to_thread(
                            db.storage.from_(bucket).download, key
                        )
                        content_type = mimetype or DEFAULT_CONTENT_TYPE
                        await backend.upload(
                            key,
                            data,
                            content_type=content_type,
                            cache_control=DEFAULT_CACHE_CONTROL,
                        )
                        migrated_keys.append(key)
                        fh.write(
                            json.dumps(
                                {
                                    "ts": _utc_now_iso(),
                                    "action": "copy",
                                    "source_bucket": bucket,
                                    "key": key,
                                    "size": size,
                                    "status": "ok",
                                },
                                separators=(",", ":"),
                            )
                            + "\n"
                        )
                        print(f"  copied {key} ({_fmt_bytes(size)})")
                    except Exception as e:  # noqa: BLE001
                        error_total += 1
                        fh.write(
                            json.dumps(
                                {
                                    "ts": _utc_now_iso(),
                                    "action": "copy",
                                    "source_bucket": bucket,
                                    "key": key,
                                    "size": size,
                                    "status": "error",
                                    "error": str(e),
                                },
                                separators=(",", ":"),
                            )
                            + "\n"
                        )
                        print(f"  ERROR copying {key}: {e}", file=sys.stderr)

        # ------------------------------------------------------------------ #
        # summary
        # ------------------------------------------------------------------ #
        print()
        print("=" * 72)
        print("MIGRATION SUMMARY")
        print("=" * 72)
        print(f"  source buckets       : {', '.join(source_buckets)}")
        print(f"  supabase objects     : {total_objects}")
        print(f"  supabase bytes       : {_fmt_bytes(total_bytes)}")
        print(f"  to copy (missing)    : {to_copy_total}")
        print(f"  already present      : {skipped_total}")
        print(f"  errors               : {error_total}")
        print(f"  migrated (this run)  : {len(migrated_keys)}")
        print()

        if not apply:
            print(
                "DRY-RUN complete: no uploads, no DB writes, no audit lines. "
                "Re-run with --apply to actually copy objects."
            )
            return 0

        if clear_url_columns_flag and migrated_keys:
            print("Clearing stale public URL columns (CLEAR_URL_COLUMNS=1)...")
            clear_url_columns(db, migrated_keys)

        if error_total:
            print(
                f"{error_total} object(s) errored and remain retryable; re-run to finish.",
                file=sys.stderr,
            )
            return 1
        print(f"Done. Audit log: {audit_path}")
        return 0

    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Migrate objects from Supabase Storage to the Railway bucket"
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually copy objects (default is dry-run).",
    )
    parser.add_argument(
        "--buckets",
        default=_env("SOURCE_BUCKETS", ""),
        help="Comma-separated Supabase source buckets (default: all).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/storage_migration.jsonl"),
        help="JSONL audit log path for copied keys.",
    )
    args = parser.parse_args()

    if args.buckets.strip():
        source_buckets = [b.strip() for b in args.buckets.split(",") if b.strip()]
    else:
        source_buckets = list(DEFAULT_SOURCE_BUCKETS)

    clear_url = _env_bool("CLEAR_URL_COLUMNS", False)
    mode = "LIVE (apply)" if args.apply else "DRY-RUN"
    print(f"[{mode}] migrate storage to railway bucket")
    print(f"  source buckets    = {', '.join(source_buckets)}")
    print(f"  clear_url_columns = {clear_url}")
    print(f"  audit_file        = {args.audit_file}")
    print()

    return asyncio.run(
        _run(
            apply=args.apply,
            source_buckets=source_buckets,
            clear_url_columns_flag=clear_url,
            audit_path=Path(args.audit_file),
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
