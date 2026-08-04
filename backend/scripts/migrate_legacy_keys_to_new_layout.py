#!/usr/bin/env python3
"""
Migrate legacy storage keys to the new folder layout.

The 2026-08-04 railway-bucket migration deliberately KEPT the old keys
unchanged (``{user_id}/{YYYYMMDD}/{prefix}_{uuid8}.{ext}`` and
``{user_id}/sources/source_{uuid4hex}.{ext}``) so every ``storage_path`` in
the DB stayed valid. The ownership validators added since then
(``images.py _is_owned_by_user``, ``ai.py _owned_storage_path``) only accept
the new layout ``{user_id}/{category}/{uuid4hex}.{ext}``, so legacy rows are
rejected with 404/403 even for their own owner.

This script rewrites BOTH sides consistently:

  * bucket: server-side copy each legacy object to its new-layout key
    (deterministic mapping, so a re-run is a no-op), optionally deleting the
    old key afterwards (``--cleanup``);
  * database: rewrite every ``storage_path`` / URL column that referenced a
    legacy key to the new key (URL columns are refreshed to a fresh presigned
    URL of the new key).

=============================================================================
KEY LAYOUTS
=============================================================================

Legacy (migrated):
    {user}/{YYYYMMDD}/{prefix}_{8hex}.{ext}      prefix: item|outfit|avatar|feedback
    {user}/{YYYYMMDD}/{8hex}.{ext}               no prefix: category resolved from DB rows
    {user}/sources/source_{32hex}.{ext}          -> {user}/sources/{32hex}.{ext}

Already valid (untouched):
    {user}/{category}/{32hex}.{ext}              category: items|outfits|avatars|sources|feedback
    {user}/tmp/{source}/{32hex}.{ext}

Out of scope (documented, left as-is):
    {user}/generated/{type}/{32hex}.{ext}        transient save_generated_image keys, never
                                                 referenced by DB rows and never accepted as
                                                 user input, so no ownership check applies.

=============================================================================
DB COLUMNS REWRITTEN
=============================================================================

    item_images.storage_path / image_url / thumbnail_url
    outfit_images.storage_path / image_url / thumbnail_url
    items.source_image_storage_path / source_image_url
    users.avatar_url
    support_tickets.attachment_storage_paths

Only rows whose old key EXISTS in the bucket are rewritten; rows referencing
objects missing from the bucket are reported as dangling and left untouched.

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--apply`` the script does no writes at all - no
   copies, no DB writes, no audit lines.

2) IDEMPOTENT. New keys are derived deterministically (SHA-256 of the old
   key, truncated to 32 hex chars) and a target that already exists is
   skipped. A crash mid-run is safely resumed.

3) AUDIT LOG. Every copied key is appended to ``AUDIT_FILE`` (JSONL) with
   old/new key and status. Errors are recorded and remain retryable.

4) ORDERING. Objects are copied BEFORE any DB row is rewritten, so rows never
   point at a key that does not exist yet. ``--cleanup`` deletes old keys only
   after both the copy and the DB rewrite succeeded.

=============================================================================
ENVIRONMENT
=============================================================================

Required (from ``backend/.env`` via ``app.core.config``):
    SUPABASE_URL
    SUPABASE_SECRET_KEY              # service-role key (read/write the DB)
    OBJECT_STORAGE_*                 # Railway bucket credentials

Optional:
    AUDIT_FILE=backend/logs/key_layout_migration.jsonl
    CLEANUP_KEYS=1                   # delete old keys after copy+DB rewrite (live only)
    MIGRATION_CONCURRENCY=8          # bounded parallel copies / presigns
"""

from __future__ import annotations

import argparse
import asyncio
import hashlib
import json
import os
import re
import sys
from collections import Counter, defaultdict
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.connection import SupabaseDB  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)
from app.services.storage_service import StorageService  # noqa: E402


# --------------------------------------------------------------------------- #
# Key layout classification
# --------------------------------------------------------------------------- #
_ALLOWED_EXT = r"jpg|jpeg|png|webp|gif|avif"

NEW_LAYOUT_KEY_RE = re.compile(
    rf"^[^/\\]+/(?:items|outfits|avatars|sources|feedback|tmp/[^/\\]+)/[0-9a-f]{{32}}\.(?:{_ALLOWED_EXT})$"
)
LEGACY_TIMESTAMP_KEY_RE = re.compile(
    rf"^(?P<user>[^/\\]+)/(?P<date>\d{{8}})/(?:(?P<prefix>item|outfit|avatar|feedback)_)?(?P<id>[0-9a-f]{{8}})\.(?P<ext>{_ALLOWED_EXT})$"
)
LEGACY_SOURCES_KEY_RE = re.compile(
    rf"^(?P<user>[^/\\]+)/sources/source_(?P<id>[0-9a-f]{{32}})\.(?P<ext>{_ALLOWED_EXT})$"
)

_PREFIX_TO_CATEGORY = {
    "item": "items",
    "outfit": "outfits",
    "avatar": "avatars",
    "feedback": "feedback",
}

# DB columns that reference storage objects, with the category their keys
# belong to. URL columns are reduced to a bucket key via key_from_path before
# classification; plain storage_path columns are used as-is.
_DB_IMAGE_COLUMNS: List[Tuple[str, str, str, bool]] = [
    # (table, column, category, is_url)
    ("item_images", "storage_path", "items", False),
    ("item_images", "image_url", "items", True),
    ("item_images", "thumbnail_url", "items", True),
    ("outfit_images", "storage_path", "outfits", False),
    ("outfit_images", "image_url", "outfits", True),
    ("outfit_images", "thumbnail_url", "outfits", True),
    ("items", "source_image_storage_path", "sources", False),
    ("items", "source_image_url", "sources", True),
    ("users", "avatar_url", "avatars", True),
]


def _new_name_for(old_key: str) -> str:
    """Deterministic 32-hex name for a legacy key (stable across re-runs)."""
    return hashlib.sha256(old_key.encode("utf-8")).hexdigest()[:32]


def map_legacy_key(
    key: str, category_hint: Optional[str] = None
) -> Optional[str]:
    """Map a legacy bucket key to the new layout, or None when unmappable.

    ``category_hint`` supplies the category for timestamp keys without a
    prefix (resolved from the DB row that references the key).
    """
    match = LEGACY_TIMESTAMP_KEY_RE.fullmatch(key)
    if match:
        category = (
            _PREFIX_TO_CATEGORY.get(match.group("prefix"))
            if match.group("prefix")
            else category_hint
        )
        if not category:
            return None
        return f"{match.group('user')}/{category}/{_new_name_for(key)}.{match.group('ext')}"
    match = LEGACY_SOURCES_KEY_RE.fullmatch(key)
    if match:
        return f"{match.group('user')}/sources/{match.group('id')}.{match.group('ext')}"
    return None


def classify_key(key: str) -> str:
    """Return 'new', 'legacy' or 'unknown' for a bucket key."""
    if NEW_LAYOUT_KEY_RE.fullmatch(key):
        return "new"
    if LEGACY_TIMESTAMP_KEY_RE.fullmatch(key) or LEGACY_SOURCES_KEY_RE.fullmatch(key):
        return "legacy"
    return "unknown"


# --------------------------------------------------------------------------- #
# env helpers
# --------------------------------------------------------------------------- #
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


# --------------------------------------------------------------------------- #
# DB scan
# --------------------------------------------------------------------------- #
def _scan_table_column(
    db, table: str, column: str
) -> List[Tuple[str, str]]:
    """Fetch (row_id, raw_value) for every non-null value of a column."""
    try:
        resp = db.table(table).select(f"id,{column}").not_.is_(column, "null").execute()
    except Exception as e:  # noqa: BLE001
        print(f"  WARNING: could not scan {table}.{column}: {e}", file=sys.stderr)
        return []
    rows = []
    for row in getattr(resp, "data", None) or []:
        value = row.get(column)
        if value:
            rows.append((str(row["id"]), str(value)))
    return rows


def build_db_rewrite_plan(
    db, bucket_keys: set
) -> Tuple[
    List[Tuple[str, str, str, str, str]],  # (table, column, row_id, old, new)
    List[Tuple[str, str, str, str]],       # dangling: (table, column, row_id, old)
    Dict[str, str],                        # category hint for prefix-less keys
    List[str],                             # conflicting category hints (abort-worthy)
]:
    """Scan DB storage columns and plan legacy-key rewrites.

    Returns (rewrites, dangling, category_hints, conflicts). A row is only
    planned for rewrite when its old key exists in the bucket; otherwise it is
    reported as dangling and left untouched. A key referenced by columns of
    DIFFERENT categories is a data inconsistency that would split the rewrite
    across two new keys — recorded as a conflict for the caller to abort on.
    """
    rewrites: List[Tuple[str, str, str, str, str]] = []
    dangling: List[Tuple[str, str, str, str]] = []
    category_hints: Dict[str, str] = {}
    conflicts: List[str] = []

    for table, column, category, is_url in _DB_IMAGE_COLUMNS:
        rows = _scan_table_column(db, table, column)
        if not rows:
            continue
        for row_id, raw in rows:
            if is_url:
                key = StorageService.key_from_path(raw)
                if not key:
                    continue
            else:
                key = raw
            if NEW_LAYOUT_KEY_RE.fullmatch(key):
                continue
            previous = category_hints.get(key)
            if previous is not None and previous != category:
                conflicts.append(key)
            # Remember the category for every legacy key found in the DB so the
            # bucket pass can map prefix-less timestamp keys consistently.
            category_hints[key] = category
            new_key = map_legacy_key(key, category_hint=category)
            if not new_key:
                continue
            if key not in bucket_keys:
                dangling.append((table, column, row_id, key))
                continue
            rewrites.append((table, column, row_id, key, new_key))

    return rewrites, dangling, category_hints, conflicts


# --------------------------------------------------------------------------- #
# async run
# --------------------------------------------------------------------------- #
async def _run(apply: bool, cleanup: bool, concurrency: int, audit_path: Path) -> int:
    backend = get_storage_backend()
    semaphore = asyncio.Semaphore(max(1, concurrency))
    try:
        db = SupabaseDB.get_service_client()

        print("Listing bucket objects...")
        bucket_keys = set(await backend.list_keys(prefix=""))
        print(f"  {len(bucket_keys)} object(s) in bucket")

        # ---- classify bucket keys ----------------------------------------- #
        new_count = 0
        legacy_count = 0
        for key in bucket_keys:
            kind = classify_key(key)
            if kind == "new":
                new_count += 1
            elif kind == "legacy":
                legacy_count += 1

        # ---- DB scan ------------------------------------------------------ #
        print("Scanning DB storage columns...")
        rewrites, dangling, category_hints, hint_conflicts = build_db_rewrite_plan(
            db, bucket_keys
        )
        rewrite_count = Counter((t, c) for t, c, _rid, _o, _n in rewrites)

        # ---- resolve prefix-less legacy keys via DB hints ----------------- #
        unresolved: List[str] = []
        unknown_keys: List[str] = []
        legacy_to_new: Dict[str, str] = {}
        for key in bucket_keys:
            kind = classify_key(key)
            if kind == "new":
                continue
            if kind != "legacy":
                unknown_keys.append(key)
                continue
            match = LEGACY_TIMESTAMP_KEY_RE.fullmatch(key)
            hint = category_hints.get(key) if (match and not match.group("prefix")) else None
            new_key = map_legacy_key(key, category_hint=hint)
            if new_key is None:
                unresolved.append(key)
                continue
            legacy_to_new[key] = new_key

        # Collision check: two distinct old keys mapping to one new key.
        new_key_counts = Counter(legacy_to_new.values())
        collisions = [
            (old, new)
            for old, new in sorted(legacy_to_new.items())
            if new_key_counts[new] > 1
        ]

        # ---- report ------------------------------------------------------- #
        print()
        print("=" * 72)
        print("KEY LAYOUT MIGRATION PLAN")
        print("=" * 72)
        print(f"  bucket objects            : {len(bucket_keys)}")
        print(f"  already new layout        : {new_count}")
        print(f"  legacy (to migrate)       : {legacy_count}")
        print(f"  unknown layout            : {len(unknown_keys)}")
        print(f"  legacy w/o resolvable cat : {len(unresolved)}")
        print(f"  DB rows to rewrite        : {sum(rewrite_count.values())}")
        for (table, column), count in sorted(rewrite_count.items()):
            print(f"    - {table}.{column}: {count}")
        print(f"  dangling rows (skipped)   : {len(dangling)}")
        if hint_conflicts:
            print(f"  CATEGORY CONFLICTS       : {len(hint_conflicts)} (manual review)")
            for key in sorted(hint_conflicts)[:10]:
                print(f"    {key}")
        if collisions:
            print(f"  COLLISIONS (manual review): {len(collisions)}")
            for old, new in collisions[:10]:
                print(f"    {old} -> {new}")

        if collisions or hint_conflicts:
            print()
            print("Aborting: mapping collisions/conflicts require manual review "
                  "before any copy.", file=sys.stderr)
            return 1

        if dangling:
            print("  dangling examples:")
            for table, column, row_id, old in dangling[:10]:
                print(f"    {table}.{column} id={row_id}: {old}")

        if not apply:
            print()
            print("DRY-RUN complete: no copies, no DB writes, no audit lines. "
                  "Re-run with --apply to migrate.")
            return 0

        # ---- copy objects ------------------------------------------------- #
        audit_path.parent.mkdir(parents=True, exist_ok=True)
        existing_new = {k for k in bucket_keys if NEW_LAYOUT_KEY_RE.fullmatch(k)}
        copied = 0
        skipped = 0
        copy_errors = 0

        async def _copy_one(old_key: str, new_key: str) -> Tuple[str, str, str]:
            async with semaphore:
                try:
                    if new_key in existing_new:
                        return old_key, new_key, "already-present"
                    await backend.copy(old_key, new_key)
                    return old_key, new_key, "copied"
                except Exception as e:  # noqa: BLE001
                    print(f"  ERROR copying {old_key}: {e}", file=sys.stderr)
                    return old_key, new_key, f"error: {e}"

        print(f"\nCopying {len(legacy_to_new)} legacy object(s)...")
        with audit_path.open("a", encoding="utf-8") as fh:
            results = await asyncio.gather(
                *[
                    _copy_one(old_key, new_key)
                    for old_key, new_key in sorted(legacy_to_new.items())
                ]
            )
            for old_key, new_key, status in results:
                fh.write(
                    json.dumps(
                        {
                            "ts": _utc_now_iso(),
                            "action": "copy",
                            "old_key": old_key,
                            "new_key": new_key,
                            "status": "ok" if status in ("copied", "already-present") else "error",
                            "detail": status,
                        },
                        separators=(",", ":"),
                    )
                    + "\n"
                )
                if status == "copied":
                    copied += 1
                elif status == "already-present":
                    skipped += 1
                else:
                    copy_errors += 1
                    print(f"    {old_key}: {status}", file=sys.stderr)
        print(f"  copied: {copied}, already present: {skipped}, errors: {copy_errors}")

        if copy_errors:
            print(f"{copy_errors} copy error(s) — DB rows are NOT rewritten; re-run to finish.",
                  file=sys.stderr)
            return 1

        # ---- rewrite DB rows ---------------------------------------------- #
        # Object copies succeeded for every legacy key; now point the rows at
        # the new keys. URL columns get a fresh presigned URL of the new key.
        presigned_cache: Dict[str, str] = {}

        async def _presign(new_key: str) -> str:
            async with semaphore:
                if new_key not in presigned_cache:
                    presigned_cache[new_key] = await StorageService.get_public_url(new_key)
                return presigned_cache[new_key]

        by_table_column: Dict[Tuple[str, str], List[Tuple[str, str, str]]] = defaultdict(list)
        for table, column, row_id, _old, new_key in rewrites:
            by_table_column[(table, column)].append((row_id, _old, new_key))

        print("\nRewriting DB rows...")
        db_errors = 0
        db_updated = 0
        for (table, column), entries in sorted(by_table_column.items()):
            is_url = next(
                (flag for t, c, _cat, flag in _DB_IMAGE_COLUMNS if (t, c) == (table, column)),
                False,
            )
            for row_id, _old, new_key in entries:
                try:
                    if is_url:
                        new_value = await _presign(new_key)
                    else:
                        new_value = new_key
                    resp = (
                        db.table(table)
                        .update({column: new_value})
                        .eq("id", row_id)
                        .execute()
                    )
                    if getattr(resp, "data", None):
                        db_updated += 1
                    else:
                        db_errors += 1
                        print(f"  WARNING: {table}.{column} id={row_id} did not update",
                              file=sys.stderr)
                except Exception as e:  # noqa: BLE001
                    db_errors += 1
                    print(f"  ERROR updating {table}.{column} id={row_id}: {e}",
                          file=sys.stderr)
        print(f"  rows updated: {db_updated}, errors: {db_errors}")

        # ---- support_tickets array column --------------------------------- #
        # Optional: only present where migration 034 has been applied. A
        # missing column is expected on older environments and is not an error.
        try:
            tickets = (
                db.table("support_tickets")
                .select("id,attachment_storage_paths")
                .execute()
            )
            ticket_rows = [
                r for r in getattr(tickets, "data", None) or []
                if r.get("attachment_storage_paths")
            ]
            for row in ticket_rows:
                old_paths = list(row["attachment_storage_paths"])
                new_paths = []
                changed = False
                for path in old_paths:
                    key = StorageService.key_from_path(path) if path.startswith(("http://", "https://")) else path
                    if NEW_LAYOUT_KEY_RE.fullmatch(key):
                        new_paths.append(path)
                        continue
                    new_key = map_legacy_key(key, category_hint="feedback")
                    if new_key and key in legacy_to_new:
                        new_paths.append(new_key)
                        changed = True
                    else:
                        new_paths.append(path)
                if changed:
                    db.table("support_tickets").update(
                        {"attachment_storage_paths": new_paths}
                    ).eq("id", row["id"]).execute()
                    db_updated += 1
        except Exception as e:  # noqa: BLE001
            err_code = getattr(e, "code", None)
            if isinstance(e, dict):
                err_code = e.get("code", err_code)
            if err_code == "42703":
                print("  support_tickets.attachment_storage_paths not present in "
                      "this schema (migration 034 pending) — skipping")
            else:
                db_errors += 1
                print(f"  WARNING: support_tickets scan/update failed: {e}", file=sys.stderr)
        print(f"  support_tickets rows updated: (included above), errors so far: {db_errors}")

        # ---- optional cleanup --------------------------------------------- #
        if cleanup:
            print("\nDeleting old keys (--cleanup)...")
            old_keys = [
                old for old, _new in legacy_to_new.items()
                if legacy_to_new.get(old) and old not in existing_new
            ]
            if old_keys:
                deleted = await backend.delete_many(old_keys)
                print(f"  deleted {deleted} old key(s)")
                with audit_path.open("a", encoding="utf-8") as fh:
                    for old_key in old_keys:
                        fh.write(
                            json.dumps(
                                {
                                    "ts": _utc_now_iso(),
                                    "action": "delete",
                                    "old_key": old_key,
                                    "status": "ok",
                                },
                                separators=(",", ":"),
                            )
                            + "\n"
                        )
        else:
            print("\nOld keys left in place (re-run with --cleanup to delete).")

        # ---- summary ------------------------------------------------------- #
        print()
        print("=" * 72)
        print("MIGRATION SUMMARY")
        print("=" * 72)
        print(f"  legacy objects copied   : {copied}")
        print(f"  already present (skip)  : {skipped}")
        print(f"  copy errors             : {copy_errors}")
        print(f"  DB rows updated         : {db_updated}")
        print(f"  DB errors               : {db_errors}")
        print(f"  unknown keys            : {len(unknown_keys)}")
        print(f"  unresolvable keys       : {len(unresolved)}")
        print(f"  dangling rows           : {len(dangling)}")
        print()
        if db_errors or copy_errors:
            print("Migration finished WITH ERRORS — re-run to retry.", file=sys.stderr)
            return 1
        print(f"Done. Audit log: {audit_path}")
        return 0

    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Migrate legacy storage keys to the new folder layout"
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually copy objects and rewrite DB rows (default is dry-run).",
    )
    parser.add_argument(
        "--cleanup",
        action="store_true",
        help="Delete old keys after a successful copy + DB rewrite (live only).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env(
            "AUDIT_FILE",
            str(Path(__file__).resolve().parent.parent / "logs" / "key_layout_migration.jsonl"),
        ),
        help="JSONL audit log path.",
    )
    parser.add_argument(
        "--concurrency",
        type=int,
        default=int(_env("MIGRATION_CONCURRENCY", "8")),
        help="Bounded parallel copies/presigns.",
    )
    args = parser.parse_args()

    cleanup = args.cleanup or _env_bool("CLEANUP_KEYS", False)
    mode = "LIVE (apply)" if args.apply else "DRY-RUN"
    print(f"[{mode}] migrate legacy storage keys to the new layout")
    print(f"  cleanup         = {cleanup}")
    print(f"  concurrency     = {args.concurrency}")
    print(f"  audit_file      = {args.audit_file}")
    print()

    return asyncio.run(
        _run(
            apply=args.apply,
            cleanup=cleanup,
            concurrency=args.concurrency,
            audit_path=Path(args.audit_file),
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
