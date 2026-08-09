#!/usr/bin/env python3
"""
Migrate the R2 bucket to the ``users/{user_id}/...`` layout (+ ``public/``).

OLD (pre-restructure) vs NEW (current):

    {user_id}/{items|outfits|avatars|sources|feedback}/{hex}.{ext}
        -> users/{user_id}/{category}/{hex}.{ext}
    {user_id}/{tmp|generated}/{sub}/{hex}.{ext}
        -> users/{user_id}/{tmp|generated}/{sub}/{hex}.{ext}
    {tmp|generated}/{user_id}/{sub}/{hex}.{ext}
        -> users/{user_id}/{tmp|generated}/{sub}/{hex}.{ext}
    {user_id}/export/data.json
        -> users/{user_id}/export/data.json
    users/... and public/... (already current) are untouched.

DB-REFERENCED PREVIEW PROMOTION (staging-only invariant)

`generated/` and `tmp/` are staging namespaces — DB ``storage_path`` must
never reference them, only items|outfits|avatars|sources|feedback. Legacy
DB rows whose storage_path lands in a preview layout (e.g. the pre-migration
``{user}/generated/product/{hex}`` rows) are therefore PROMOTED to
``users/{user_id}/items/{hex}.{ext}`` instead of being re-keyed as staging,
and the DB column is rewritten to the promoted key.

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--apply`` nothing is copied, deleted, or written.

2) COPY -> HEAD-VERIFY -> DB REWRITE -> DELETE. Every object is server-side
   copied and HEAD-verified to exist at the target BEFORE any DB column is
   rewritten, and old keys are deleted only AFTER their DB references are
   rewritten. A failed copy leaves the old key untouched — nothing is ever
   lost (the 048 lesson: never delete-first).

3) NEVER OVERWRITE. If the target key already exists (a partial prior run),
   the pair is skipped and reported instead of clobbered.

4) ONLY OUR KEY SHAPES ARE TOUCHED. Unknown keys (external junk, objects
   that reduce to nothing) are reported and left alone.

5) AUDIT LOG. Every copy/promote/rewrite/delete/skip/failure is appended to
   ``AUDIT_FILE`` (JSONL).

=============================================================================
USAGE
=============================================================================

    cd backend && source .venv/bin/activate
    python scripts/migrate_storage_layout_users.py          # dry-run report
    python scripts/migrate_storage_layout_users.py --apply  # migrate

Env: AUDIT_FILE (default backend/logs/migrate_storage_layout_users.jsonl).

NOTE: run when review flows are quiet (a live review row holding a legacy
preview key could 404 on refetch during the window). After the migration,
the read path flip in ``key_from_path`` (apply ``migrate_key_to_users_layout``
to reduced keys) and the retirement of the legacy regexes land as a follow-up
commit — until then the worker still serves both layouts.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _utc_now_iso, list_keys_with_mtime  # noqa: E402
from app.core.storage_keys import (  # noqa: E402
    migrate_key_to_users_layout,
    mint_key,
    parse_key,
)
from app.db.connection import SupabaseDB  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)

# (table, storage column, label) — the DB columns that hold durable keys.
_DB_COLUMNS: Tuple[Tuple[str, str, str], ...] = (
    ("item_images", "storage_path", "item image"),
    ("outfit_images", "storage_path", "outfit image"),
    ("items", "source_image_storage_path", "source photo"),
    ("support_tickets", "attachment_storage_paths", "support attachment"),
)

_PAGE_SIZE = 1000


def _db_referenced_paths(db) -> Dict[str, List[Tuple[str, str, str]]]:
    """Collect every non-null DB storage_path, keyed by table.

    Returns {table: [(row_id, path), ...]}. ``attachment_storage_paths`` is a
    TEXT[] array, so each element is its own (row_id, path) entry.
    """
    out: Dict[str, List[Tuple[str, str, str]]] = {}
    for table, col, _label in _DB_COLUMNS:
        rows_list: List[Tuple[str, str, str]] = []
        offset = 0
        while True:
            resp = (
                db.table(table)
                .select("id," + col)
                .order("id")
                .range(offset, offset + _PAGE_SIZE - 1)
                .execute()
            )
            data = resp.data or []
            for row in data:
                value = row.get(col)
                row_id = str(row["id"])
                if isinstance(value, list):  # TEXT[] (attachment_storage_paths)
                    for item in value:
                        if item:
                            rows_list.append((row_id, str(item)))
                elif value:
                    rows_list.append((row_id, str(value)))
            if len(data) < _PAGE_SIZE:
                break
            offset += _PAGE_SIZE
        out[table] = rows_list
    return out


def _promotion_target(path: str, db_paths: set) -> Optional[str]:
    """Promotion target when a DB-referenced key lands in a preview layout.

    DB ``storage_path`` must only reference durable categories. A legacy
    preview key that a DB row references (e.g. ``{user}/generated/product/…``)
    is promoted to ``users/{user}/items/{hex}.{ext}`` — the staging-only
    invariant. Returns the promoted key, or None when the key is not a
    DB-referenced preview.
    """
    ref = parse_key(path)
    if ref is None:
        return None
    if ref.layout in ("preview", "legacy_preview") and path in db_paths:
        return mint_key(ref.user, "items", ref.ext)
    return None


async def _run(apply: bool, audit_path: Path) -> int:
    backend = get_storage_backend()
    db = SupabaseDB.get_service_client()
    try:
        print("Listing bucket objects (with mtime)...")
        mtime_map = await list_keys_with_mtime(backend)
        print(f"  {len(mtime_map)} object(s) in bucket")

        # DB-referenced storage_paths (for promotion + rewrite).
        db_by_table = _db_referenced_paths(db)
        db_paths: set = set()
        for rows in db_by_table.values():
            db_paths.update(path for _rid, path in rows)
        print("  DB-referenced storage_paths:")
        for table, rows in db_by_table.items():
            print(f"    {table}: {len(rows)}")

        # Build (old, new, promoted) tuples. Bucket-wide re-key via the grammar
        # mapper; DB-referenced preview keys get promoted instead of re-keyed.
        pairs: List[Tuple[str, str, bool]] = []
        unchanged = 0
        for key in mtime_map:
            mapped = migrate_key_to_users_layout(key)
            if mapped is None or mapped == key:
                if mapped is None:
                    print(f"  (unknown shape, left alone) {key}")
                else:
                    unchanged += 1
                continue
            promoted = _promotion_target(key, db_paths)
            pairs.append((key, promoted or mapped, promoted is not None))
        print(f"  {len(pairs)} key(s) to migrate, {unchanged} already current")

        if not pairs:
            print("\nNo legacy keys to migrate (bucket already on users/ layout).")
            return 0

        existing_keys = set(mtime_map)
        collisions = [(old, new) for old, new, _promoted in pairs if new in existing_keys]
        if collisions:
            print(
                f"\n  WARNING: {len(collisions)} target key(s) already exist "
                f"(partial prior run?); those pairs will be skipped."
            )

        audit_path.parent.mkdir(parents=True, exist_ok=True)

        def _audit(action: str, old: str, new: str, error: str = "", extra: Optional[dict] = None) -> None:
            record = {
                "ts": _utc_now_iso(),
                "action": action,
                "old_key": old,
                "new_key": new,
                "error": error or None,
            }
            if extra:
                record.update(extra)
            with audit_path.open("a", encoding="utf-8") as fh:
                fh.write(json.dumps(record, separators=(",", ":")) + "\n")

        if not apply:
            print(
                f"\nDRY-RUN: {len(pairs)} key(s) would be migrated "
                f"({len(collisions)} collision(s) skipped). "
                f"Re-run with --apply to execute."
            )
            return 0

        # ---- 1) COPY + HEAD-VERIFY every pair (nothing DB-side yet). ----
        print(f"\nCOPYING {len(pairs)} key(s) (server-side copy + HEAD verify)...")
        semaphore = asyncio.Semaphore(8)
        copied: List[Tuple[str, str, bool]] = []  # (old, new, promoted)

        async def _copy_pair(old: str, new: str, promoted: bool) -> Tuple[str, str, bool, str]:
            if new in existing_keys:
                return ("skip", old, new, "")
            try:
                async with semaphore:
                    await backend.copy(old, new)
                    if not await backend.exists(new):
                        raise RuntimeError("copy did not materialize (HEAD failed)")
                return ("copy", old, new, promoted)
            except Exception as e:  # noqa: BLE001
                return ("fail", old, new, str(e))

        results = await asyncio.gather(
            *(_copy_pair(old, new, promoted) for old, new, promoted in pairs)
        )
        copied = []
        failed = []
        for action, old, new, info in results:
            if action == "skip":
                _audit("skip", old, new, "target already exists")
                print(f"  SKIP   {old} -> {new} (target exists)")
            elif action == "fail":
                _audit("fail", old, new, info if isinstance(info, str) else "")
                failed.append((old, new))
                print(f"  FAILED {old} -> {new}: {info}")
            else:
                copied.append((old, new, bool(info)))
                _audit("copy", old, new)
                print(f"  COPIED {old} -> {new}")

        if failed:
            print(
                f"\nSTOPPING: {len(failed)} copy(ies) failed; DB rewrite and "
                f"delete skipped so nothing is half-migrated. Fix and re-run."
            )
            return 1

        # ---- 2) DB REWRITE (only after every copy verified). ----
        # Map old -> new per (table, row_id). Array columns (TEXT[]) map
        # element-wise; scalar columns are rewritten directly.
        print("\nRewriting DB storage_path columns...")
        scalar_targets: Dict[str, Dict[str, str]] = {t: {} for t, _c, _l in _DB_COLUMNS}
        array_targets: Dict[str, Dict[str, List[Tuple[str, str]]]] = {
            t: {} for t, _c, _l in _DB_COLUMNS
        }
        for old, new, _promoted in copied:
            for table, col, _label in _DB_COLUMNS:
                for row_id, path in db_by_table[table]:
                    if path != old:
                        continue
                    if col == "attachment_storage_paths":
                        array_targets[table].setdefault(row_id, []).append((old, new))
                    else:
                        scalar_targets[table][row_id] = new
                    _audit("db_rewrite", path, new, extra={"table": table, "row_id": row_id})

        for table, col, _label in _DB_COLUMNS:
            for row_id, new_path in scalar_targets[table].items():
                db.table(table).update({col: new_path}).eq("id", row_id).execute()
            for row_id, replacements in array_targets[table].items():
                row = (
                    db.table(table)
                    .select("id," + col)
                    .eq("id", row_id)
                    .maybe_single()
                    .execute()
                )
                current = (row.data or {}).get(col) or []
                replacement = {old: new for old, new in replacements}
                rewritten = [replacement.get(item, item) for item in current]
                db.table(table).update({col: rewritten}).eq("id", row_id).execute()
        print("  DB rewrite done.")

        # ---- 3) DELETE old keys (only those verified copied). ----
        print("\nDeleting migrated old keys...")
        for old, _new, _promoted in copied:
            await backend.delete(old)
            _audit("delete", old, "")
        print("  delete done.")

        print(
            f"\nmigrated={len(copied)} failed={len(failed)} audit={audit_path}"
        )
        return 0
    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Migrate bucket keys to the users/{user_id}/ layout "
        "(dry-run by default; DB storage_path rewritten only after every "
        "copy is verified)."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually copy/verify/rewrite/delete (default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/migrate_storage_layout_users.jsonl"),
        help="JSONL audit log path.",
    )
    args = parser.parse_args()
    return asyncio.run(_run(apply=args.apply, audit_path=Path(args.audit_file)))


if __name__ == "__main__":
    raise SystemExit(main())
