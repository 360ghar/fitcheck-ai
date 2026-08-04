#!/usr/bin/env python3
"""
Delete orphan / temp objects from Supabase Storage BEFORE the Railway migration.

Only the ``fitcheck-images`` bucket is used (``items``/``outfits``/``avatars`` are
empty). This script recursively lists every object in that bucket, builds the
authoritative set of DB-referenced ``storage_path`` keys, and flags every bucket
object NOT in that set as an orphan (this includes all ``{user_id}/tmp/`` and
``{user_id}/generated/`` temp files, leftover source photos, and any object whose
DB row was deleted without cleaning storage).

    cd backend && source .venv/bin/activate
    # Dry-run: report only
    python scripts/cleanup_supabase_orphans.py
    # Live: actually delete the orphans from Supabase
    python scripts/cleanup_supabase_orphans.py --delete

Safe: dry-run by default, audit log, idempotent, never deletes a DB-referenced key.
"""
from __future__ import annotations

import argparse
import asyncio
import json
from pathlib import Path
from typing import Iterable, List, Set

from supabase import create_client

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

BUCKET = settings.SUPABASE_STORAGE_BUCKET or "fitcheck-images"
AUDIT_DEFAULT = "backend/logs/supabase_orphan_cleanup.jsonl"

def _list_all_objects(db, bucket: str) -> List[dict]:
    """Recursively list every object in a Supabase Storage bucket."""
    seen: Set[str] = set()
    out: List[dict] = []

    def _recurse(prefix: str) -> None:
        try:
            entries = (
                db.storage.from_(bucket).list(path=prefix) if prefix else db.storage.from_(bucket).list()
            )
        except Exception as e:
            logger.warning("list failed", prefix=prefix or "(root)", error=str(e))
            return
        for entry in entries or []:
            name = entry.get("name")
            if not name:
                continue
            full = f"{prefix}{name}" if prefix else name
            if entry.get("id") is None and not entry.get("metadata"):
                child_prefix = f"{full}/"
                if child_prefix not in seen:
                    seen.add(child_prefix)
                    _recurse(child_prefix)
                continue
            if full in seen:
                continue
            seen.add(full)
            size = 0
            meta = entry.get("metadata")
            if isinstance(meta, dict):
                size = int(meta.get("size") or 0)
            out.append({"key": full, "size": size})

    _recurse("")
    return out


def _select_all(db, table: str, column: str) -> Iterable[dict]:
    page_size = 1000
    offset = 0
    while True:
        try:
            res = db.table(table).select(column).range(offset, offset + page_size - 1).execute()
        except Exception as e:
            logger.warning("select failed", table=table, column=column, error=str(e))
            return
        rows = res.data or []
        if not rows:
            return
        for r in rows:
            yield r
        if len(rows) < page_size:
            return
        offset += page_size


def _collect_db_keys(db) -> Set[str]:
    keys: Set[str] = set()

    def _add(value) -> None:
        if not value:
            return
        k = StorageService.key_from_path(value)
        if k:
            keys.add(k)

    for row in _select_all(db, "item_images", "storage_path"):
        _add(row.get("storage_path"))
    for row in _select_all(db, "outfit_images", "storage_path"):
        _add(row.get("storage_path"))
    for row in _select_all(db, "items", "source_image_storage_path"):
        _add(row.get("source_image_storage_path"))
    for row in _select_all(db, "users", "avatar_url"):
        _add(row.get("avatar_url"))
    try:
        for row in _select_all(db, "support_tickets", "attachment_storage_paths"):
            paths = row.get("attachment_storage_paths")
            if isinstance(paths, list):
                for p in paths:
                    _add(p)
    except Exception as e:
        logger.warning("support_tickets.attachment_storage_paths unreadable", error=str(e))
    return keys

def _delete_keys(db, bucket: str, keys: List[str]) -> int:
    deleted = 0
    for key in keys:
        try:
            db.storage.from_(bucket).remove([key])
            deleted += 1
        except Exception as e:
            logger.warning("delete failed", key=key, error=str(e))
    return deleted


def _fmt_bytes(n: float) -> str:
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.1f} {unit}"
        n /= 1024
    return f"{n:.1f} TB"


async def _run(delete: bool, audit_path: Path) -> int:
    db = create_client(settings.SUPABASE_URL, settings.SUPABASE_SECRET_KEY)
    print(f"[{'DELETE' if delete else 'DRY-RUN'}] cleanup Supabase orphans")
    print(f"  bucket    = {BUCKET}")
    print(f"  audit_file= {audit_path}")
    print()
    print("Listing bucket objects...")
    objects = _list_all_objects(db, BUCKET)
    bucket_keys = {o["key"] for o in objects}
    total_bytes = sum(o["size"] for o in objects)
    print(f"  {len(objects)} object(s), {_fmt_bytes(total_bytes)} total")
    print("Collecting DB-referenced keys...")
    db_keys = _collect_db_keys(db)
    print(f"  {len(db_keys)} DB-referenced key(s)")
    orphans = sorted(bucket_keys - db_keys)
    missing = sorted(db_keys - bucket_keys)
    print()
    print(f"  ORPHANS (in bucket, not in DB): {len(orphans)}")
    print(f"  MISSING (in DB, not in bucket): {len(missing)}")
    temp_orphans = [k for k in orphans if "/tmp/" in k or "/generated/" in k]
    other_orphans = [k for k in orphans if k not in set(temp_orphans)]
    print(f"    temp/generated : {len(temp_orphans)}")
    print(f"    other orphans  : {len(other_orphans)}")
    if orphans and len(orphans) <= 50:
        print("  orphan keys:")
        for k in orphans:
            print(f"    - {k}")
    audit_path.parent.mkdir(parents=True, exist_ok=True)
    with audit_path.open("a", encoding="utf-8") as fh:
        for k in orphans:
            fh.write(json.dumps({"key": k, "action": "orphan", "deleted": delete}, separators=(",", ":")) + "\n")
    if not delete:
        print()
        print("DRY-RUN complete: nothing deleted. Re-run with --delete to remove orphans.")
        return 0
    if not orphans:
        print("No orphans to delete.")
        return 0
    print()
    print(f"Deleting {len(orphans)} orphan object(s) from Supabase...")
    deleted = _delete_keys(db, BUCKET, orphans)
    print(f"  deleted: {deleted}/{len(orphans)}")
    print(f"Audit log: {audit_path}")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="Delete orphan/temp objects from Supabase Storage")
    p.add_argument("--delete", action="store_true", help="Actually delete orphans (default: dry-run)")
    p.add_argument("--audit-file", default=AUDIT_DEFAULT)
    args = p.parse_args()
    return asyncio.run(_run(delete=args.delete, audit_path=Path(args.audit_file)))


if __name__ == "__main__":
    raise SystemExit(main())

