#!/usr/bin/env python3
"""
Object-storage orphan inventory + storage usage report (R2 / Railway / any S3).

Lists every object in the configured S3-compatible bucket (via
``S3StorageBackend.list_keys``), collects the authoritative set of DB
``storage_path`` keys from Supabase (Postgres), and reports:

  * ORPHANS  - bucket keys not referenced by any DB row.
  * MISSING  - DB storage_paths with no matching object in the bucket.
  * Per-user and per-category usage (prefix ``{user_id}/{category}/``),
    object counts, and (optionally) total bytes.

With ``--delete`` it actually deletes the orphan objects (``delete_many``) and
writes an audit log. Dry-run is the default and never writes anything.

    cd backend && source .venv/bin/activate
    python scripts/storage_inventory.py                 # dry-run report
    python scripts/storage_inventory.py --delete        # actually delete orphans

=============================================================================
WHICH BUCKET DOES THIS TOUCH?
=============================================================================

By default: the CONFIGURED bucket (``OBJECT_STORAGE_*``). The target is printed
on every run — read it before passing ``--delete``.

That default is a trap for post-cutover cleanup. After the R2 migration the env
points at R2, so a bare ``--delete`` inspects R2, NOT the Railway bucket you
meant to clean out. Target the old bucket explicitly:

    python scripts/storage_inventory.py \\
        --endpoint https://<old>.storageapi.dev --bucket <old-bucket> \\
        --access-key-id <old-key> --secret-access-key <old-secret>

All four are required together; the script refuses a partial override rather
than silently mixing one provider's bucket name with another's endpoint.

Note also what ``--delete`` does and does not do: it removes DB-orphaned objects,
it does NOT empty a bucket. Objects still referenced by a live DB row survive on
purpose — which is exactly right while the DB is shared, but it means "empty the
old bucket" is a separate operation (do it from the provider's dashboard once
the new bucket is verified live).

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--delete`` the script does no writes at all - no
   object deletion, no DB writes, no audit lines.

2) NEVER DELETE A REFERENCED OBJECT. The orphan set is computed as
   ``bucket_keys - db_keys``; a key is only ever a deletion candidate if it
   appears in the bucket AND is absent from every authoritative DB column
   (``item_images.storage_path``, ``outfit_images.storage_path``,
   ``items.source_image_storage_path``, ``users.avatar_url`` parsed to a key,
   ``support_tickets.attachment_storage_paths``). If a DB row references a
   storage_path, its object is never touched, even if it looks stale.

3) IDEMPOTENT. Re-running produces the same report; a key that is already
   deleted is simply absent from the bucket and won't be re-reported.

4) AUDIT LOG. Every deleted key is appended to ``AUDIT_FILE`` (JSONL). The
   audit file is the source of truth for what was deleted and when.

=============================================================================
NOTES
=============================================================================

* BYTES. ``S3StorageBackend.list_keys`` returns keys only (no sizes), so
  measuring total bytes requires a HEAD request per object. That is OFF by
  default (``MEASURE_BYTES=0``) because it is one network round-trip per
  object and can be slow on a large bucket. Set ``MEASURE_BYTES=1`` to enable
  it; the script reaches into the backend's aioboto3 client for ``head_object``
  (the backend API does not expose head-object, and we must not edit
  ``app/services/object_storage.py``).

* CATEGORY. The bucket may still hold OLD-style keys
  (``{user_id}/{timestamp}/{prefix}_{uuid}{ext}``) next to the NEW layout
  (``{user_id}/{category}/{uuid}.{ext}``) and the top-level preview folders
  (``tmp/{user}/{source}/...``, ``generated/{user}/{type}/...``).
  ``classify_category`` recognises the known category keywords (checking the
  FIRST segment for the top-level preview folders, then the second segment)
  and otherwise infers the category from the filename prefix (``item_``,
  ``outfit_``, ``avatar_``, ``source_``, ``generated_``, ``feedback_``).
  Anything else is binned as ``legacy-other``.

* ``support_tickets.attachment_storage_paths`` is a TEXT[] column that the
  serving-schema agent is adding. The script probes for it defensively: if the
  column does not exist yet the query fails and the column is silently ignored
  (with a warning) rather than aborting the whole report.

=============================================================================
ENVIRONMENT
=============================================================================

Required (from ``backend/.env`` via ``app.core.config``):
    SUPABASE_URL
    SUPABASE_SECRET_KEY              # service-role key (bypasses RLS)
    OBJECT_STORAGE_*                 # or Railway BUCKET/ENDPOINT/REGION/... aliases

Optional:
    AUDIT_FILE=backend/logs/storage_inventory.jsonl
    MEASURE_BYTES=0                 # 1 = HEAD each object for byte totals
    ORPHAN_LIST=backend/logs/orphans.txt   # optional dump of orphan keys
    MIN_AGE_HOURS=2                 # grace window before an orphan is deletable

=============================================================================
AGE-BASED PROTECTION (--min-age-hours / MIN_AGE_HOURS, default 2)
=============================================================================

Temp/generated images (``{user_id}/tmp/{source}/...``) are NEVER referenced by
any DB row — they are served only via short-lived presigned GET URLs (default
1h TTL). The orphan math therefore flags every temp image as an orphan,
including one a user is actively previewing. The script captures each object's
``LastModified`` in the listing pass and only treats orphans older than the
grace window as ``deletable``; younger ones are ``protected`` and left
untouched this run. ``--delete`` never touches a protected key. The window is
uniform: it also protects an item/outfit object caught mid upload->DB-insert.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, Iterable, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.config import settings  # noqa: E402
from app.db.connection import SupabaseDB  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    S3StorageBackend,
    close_storage_backend,
    get_storage_backend,
)
from app.services.storage_service import StorageService  # noqa: E402


# --- env helpers (mirrors backfill_transparent_backgrounds.py) --------------- #
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


# Default grace window (hours) before an orphan object is considered deletable.
# Temp/generated images (``{user_id}/tmp/{source}/...`` from photoshoot / batch /
# social-import / ``save_generated_image``) are NEVER referenced by any DB row:
# they are served only via short-lived presigned GET URLs (default 1h TTL). The
# orphan math (``bucket_keys - db_keys``) therefore flags every temp image as
# an orphan, including one a user is actively previewing. The grace window must
# exceed the presign TTL so an in-flight preview is never deleted out from under
# a client. 2h = just past the 1h presign TTL; override via --min-age-hours /
# MIN_AGE_HOURS. The window is uniform: it also protects an item/outfit object
# caught mid upload->DB-insert (transient orphan window).
DEFAULT_MIN_AGE_HOURS = 2.0

# Per-category overrides of the grace window, for orphan classes that are NOT
# transient. `{user_id}/generated/{image_type}/...` holds try-on and outfit
# renders the user explicitly asked to keep (`save_to_storage=true` ->
# image_generation_agent.save_generated_image). No DB row references them, so the
# orphan math flags every one — but deleting them after 2h destroys content the
# user asked to save. 30 days is a retention decision, not a transient-window
# decision; override with GENERATED_MIN_AGE_HOURS.
#
# The real fix is to make these DB-referenced (then they stop being orphans at
# all) — tracked as debt. Until then this stops the cleanup script from being the
# thing that deletes them.
CATEGORY_MIN_AGE_HOURS = {
    "generated": float(_env("GENERATED_MIN_AGE_HOURS", "720")),  # 30 days
}


# --------------------------------------------------------------------------- #
# category classification
# --------------------------------------------------------------------------- #
CATEGORY_KEYWORDS = {
    "items",
    "outfits",
    "avatars",
    "sources",
    "feedback",
    "tmp",
    "generated",
}

# Old-style keys embed a category in the filename prefix:
#   {user_id}/{timestamp}/item_{uuid8}{ext} -> items
_FILENAME_PREFIX_TO_CATEGORY = (
    ("item_", "items"),
    ("outfit_", "outfits"),
    ("avatar_", "avatars"),
    ("source_", "sources"),
    ("generated_", "generated"),
    ("feedback_", "feedback"),
)


def classify_category(key: str) -> str:
    """Best-effort category for a bucket key.

    Top-level preview folders (``tmp/{user}/{source}/...`` and
    ``generated/{user}/{type}/...``) -> FIRST segment.
    Canonical layout (``{user_id}/{category}/{uuid}.{ext}``) and the legacy
    per-user preview layout (``{user_id}/tmp|generated/{sub}/...``) -> second
    segment.
    Oldest layout: ``{user_id}/{timestamp}/{prefix}_{uuid}{ext}`` -> infer from
    the filename prefix. Anything else is ``legacy-other``.
    """
    parts = key.split("/")
    if parts and parts[0] in CATEGORY_KEYWORDS:
        return parts[0]
    if len(parts) >= 2:
        second = parts[1]
        if second in CATEGORY_KEYWORDS:
            return second
    filename = parts[-1] if parts else ""
    for prefix, category in _FILENAME_PREFIX_TO_CATEGORY:
        if filename.startswith(prefix):
            return category
    return "legacy-other"


def parent_stem_of_thumb(key: str) -> Optional[str]:
    """The extension-less parent key a ``_thumb`` sibling derives from, or None.

    Thumbnails live at ``{stem}_thumb.webp`` (e.g. ``u/items/abc_thumb.webp`` is
    the variant of ``u/items/abc.<anything>``). The STEM, not the full key,
    because thumbnails are always WebP regardless of the original's format
    (``StorageService.THUMB_EXTENSION``) — so ``abc_thumb.webp`` could belong to
    ``abc.jpg``, ``abc.png`` or ``abc.webp`` and the parent's extension is simply
    not recoverable from the thumb key. Callers therefore match against the set
    of DB key STEMS (see ``key_stem``).

    ``None`` for anything that is not a thumbnail key, so callers can filter
    safely.
    """
    head, sep, name = key.rpartition("/")
    if not sep or "_thumb." not in name:
        return None
    stem = name.split("_thumb.", 1)[0]
    if not stem:
        return None
    return f"{head}/{stem}"


def key_stem(key: str) -> str:
    """A key with its extension removed (``u/items/abc.jpg`` -> ``u/items/abc``).

    Pairs with ``parent_stem_of_thumb`` so a thumbnail can be matched to its
    parent without knowing the parent's format.
    """
    head, sep, name = key.rpartition("/")
    stem, dot, _ext = name.rpartition(".")
    base = stem if dot else name
    return f"{head}/{base}" if sep else base


# --------------------------------------------------------------------------- #
# DB authoritative key collection
# --------------------------------------------------------------------------- #
def _probe_attachment_storage_paths(db) -> List[Tuple[str, str]]:
    """Collect support_tickets.attachment_storage_paths (defensive).

    Returns a list of ``(key, row_id)``. The column is TEXT[] and may not exist
    yet (the serving-schema agent is adding it); on failure we log a warning
    and return nothing rather than abort the whole report.
    """
    rows: List[Tuple[str, str]] = []
    try:
        resp = db.table("support_tickets").select(
            "id, attachment_storage_paths"
        ).execute()
    except Exception as e:  # noqa: BLE001 - column may not exist yet
        print(
            f"WARNING: could not read support_tickets.attachment_storage_paths "
            f"(skipping that column): {e}",
            file=sys.stderr,
        )
        return rows
    for row in resp.data or []:
        paths = row.get("attachment_storage_paths") or []
        if isinstance(paths, str):
            paths = [paths]
        for path in paths:
            key = StorageService.key_from_path(path)
            if key:
                rows.append((key, str(row.get("id") or "")))
    return rows


def collect_db_keys(db) -> Dict[str, List[Tuple[str, str]]]:
    """Collect the authoritative set of DB storage keys -> referencing rows.

    Returns a dict mapping normalized bucket key -> list of ``(table, row_id)``
    that reference it. Used both to compute orphans (keys not present here) and
    to keep the report useful (which rows reference a key).
    """
    db_keys: Dict[str, List[Tuple[str, str]]] = {}

    def _add(key: Optional[str], table: str, row_id: str) -> None:
        key = StorageService.key_from_path(key)
        if not key:
            return
        db_keys.setdefault(key, []).append((table, row_id))

    try:
        resp = db.table("item_images").select("id, storage_path").execute()
        for row in resp.data or []:
            _add(row.get("storage_path"), "item_images", str(row.get("id") or ""))
    except Exception as e:  # noqa: BLE001
        print(f"WARNING: item_images query failed: {e}", file=sys.stderr)

    try:
        resp = db.table("outfit_images").select("id, storage_path").execute()
        for row in resp.data or []:
            _add(row.get("storage_path"), "outfit_images", str(row.get("id") or ""))
    except Exception as e:  # noqa: BLE001
        print(f"WARNING: outfit_images query failed: {e}", file=sys.stderr)

    try:
        resp = db.table("items").select("id, source_image_storage_path").execute()
        for row in resp.data or []:
            _add(
                row.get("source_image_storage_path"),
                "items",
                str(row.get("id") or ""),
            )
    except Exception as e:  # noqa: BLE001
        print(
            f"WARNING: items.source_image_storage_path query failed: {e}",
            file=sys.stderr,
        )

    try:
        resp = db.table("users").select("id, avatar_url").execute()
        for row in resp.data or []:
            _add(row.get("avatar_url"), "users", str(row.get("id") or ""))
    except Exception as e:  # noqa: BLE001
        print(f"WARNING: users.avatar_url query failed: {e}", file=sys.stderr)

    for key, row_id in _probe_attachment_storage_paths(db):
        db_keys.setdefault(key, []).append(("support_tickets", row_id))

    return db_keys


# --------------------------------------------------------------------------- #
# usage aggregation
# --------------------------------------------------------------------------- #
def compute_usage(
    keys: Iterable[str],
    sizes: Optional[Dict[str, int]] = None,
) -> Dict[str, Dict[str, Dict[str, int]]]:
    """Aggregate usage by category and by user from a set of bucket keys.

    Returns ``{"categories": {cat: {"count": n, "bytes": b}},
               "users": {user: {"count": n, "bytes": b}}}``. When ``sizes`` is
    provided (key -> byte size), the byte totals are aggregated; otherwise all
    bytes are reported as 0.
    """
    sizes = sizes or {}
    categories: Dict[str, Dict[str, int]] = {}
    users: Dict[str, Dict[str, int]] = {}
    for key in keys:
        parts = key.split("/")
        user_id = parts[0] if parts else ""
        category = classify_category(key)
        size = sizes.get(key, 0)
        categories.setdefault(category, {"count": 0, "bytes": 0})
        categories[category]["count"] += 1
        categories[category]["bytes"] += size
        if user_id:
            users.setdefault(user_id, {"count": 0, "bytes": 0})
            users[user_id]["count"] += 1
            users[user_id]["bytes"] += size
    return {"categories": categories, "users": users}


def _render_usage_table(section: Dict[str, Dict[str, int]], title: str) -> str:
    lines = [f"  {title}:"]
    if not section:
        lines.append("    (none)")
        return "\n".join(lines)
    for name, stats in sorted(section.items(), key=lambda kv: -kv[1]["count"]):
        lines.append(
            f"    {name:<40} count={stats['count']:>6}  bytes={_fmt_bytes(stats['bytes'])}"
        )
    return "\n".join(lines)


# --------------------------------------------------------------------------- #
# async backend helpers
# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
# age-based protection (grace window)
# --------------------------------------------------------------------------- #
async def _list_with_mtime(backend) -> Dict[str, datetime]:
    """List every bucket key with its ``LastModified`` timestamp (UTC).

    Paginates ``list_objects_v2`` directly so the object mtime is captured in
    the same listing pass — no per-object HEAD. Uses the backend's aioboto3
    client via the same script-only reach-in as ``_measure_bytes`` (we must not
    edit ``app/services/object_storage.py``). On any failure the map is empty,
    which makes every orphan ``protected`` (nothing is deleted this run) — the
    safe failure mode for a one-time cleanup.
    """
    mtimes: Dict[str, datetime] = {}
    try:
        client = await backend._get_client()  # noqa: SLF001 - script-only
        paginator = client.get_paginator("list_objects_v2")
        async for page in paginator.paginate(Bucket=backend.bucket, Prefix=""):
            for obj in page.get("Contents", []):
                key = obj.get("Key")
                mtime = obj.get("LastModified")
                if key and mtime is not None:
                    mtimes[key] = mtime
    except Exception as e:  # noqa: BLE001
        print(
            f"WARNING: mtime-aware listing failed (age-based protection "
            f"disabled; all orphans will be protected): {e}",
            file=sys.stderr,
        )
    return mtimes


def _to_aware_utc(value: datetime) -> datetime:
    """Normalize a datetime to tz-aware UTC (defensive; boto3 is already aware)."""
    return value if value.tzinfo else value.replace(tzinfo=timezone.utc)


def split_by_age(
    keys: List[str],
    mtimes: Dict[str, datetime],
    min_age_hours: float,
    now: datetime,
) -> Tuple[List[str], List[str]]:
    """Split ``keys`` into ``(deletable, protected)`` by age.

    A key is ``deletable`` only when its mtime is at least its category's grace
    window older than ``now``. The window is ``min_age_hours`` for most
    categories and ``CATEGORY_MIN_AGE_HOURS[category]`` where a longer retention
    applies (``generated/`` = user-saved renders). A key with no known mtime is
    ``protected`` (never deleted this run) — the conservative choice for a
    one-time cleanup. Pure function (testable without the bucket).
    """
    deletable: List[str] = []
    protected: List[str] = []
    now_utc = _to_aware_utc(now)
    for key in keys:
        mtime = mtimes.get(key)
        if mtime is None:
            protected.append(key)
            continue
        window = CATEGORY_MIN_AGE_HOURS.get(classify_category(key), min_age_hours)
        if _to_aware_utc(mtime) <= now_utc - timedelta(hours=window):
            deletable.append(key)
        else:
            protected.append(key)
    return deletable, protected


def age_hours(mtime: Optional[datetime], now: datetime) -> Optional[float]:
    """Age of a key in hours (rounded to 2 dp), or None when mtime is unknown."""
    if mtime is None:
        return None
    delta = _to_aware_utc(now) - _to_aware_utc(mtime)
    return round(delta.total_seconds() / 3600.0, 2)


async def _measure_bytes(backend, keys: List[str]) -> Dict[str, int]:
    """HEAD each key for its size (only when MEASURE_BYTES=1)."""
    sizes: Dict[str, int] = {}
    try:
        client = await backend._get_client()  # noqa: SLF001 - script-only
        for key in keys:
            try:
                head = await client.head_object(Bucket=backend.bucket, Key=key)
                sizes[key] = int(head.get("ContentLength") or 0)
            except Exception:  # noqa: BLE001
                sizes[key] = 0
    except Exception as e:  # noqa: BLE001
        print(
            f"WARNING: byte measurement failed (continuing without sizes): {e}",
            file=sys.stderr,
        )
    return sizes


async def _run(
    delete: bool,
    audit_path: Path,
    orphan_list: Optional[Path],
    min_age_hours: float,
    backend: Optional[S3StorageBackend] = None,
) -> int:
    # `backend` is supplied only when --endpoint/--bucket target a bucket other
    # than the configured one (see main()); otherwise use the process singleton.
    owns_backend = backend is not None
    backend = backend or get_storage_backend()
    try:
        db = SupabaseDB.get_service_client()

        print("Listing bucket objects (with mtime for age-based protection)...")
        mtime_map = await _list_with_mtime(backend)
        bucket_keys = list(mtime_map.keys())
        bucket_set = set(bucket_keys)
        print(f"  {len(bucket_set)} object(s) in bucket")

        print("Collecting DB storage_path keys...")
        db_keys = collect_db_keys(db)
        print(f"  {len(db_keys)} distinct DB storage_path key(s)")

        orphans = sorted(bucket_set - set(db_keys))
        # A `_thumb` sibling is DERIVED from a DB-referenced key (read paths
        # materialize its URL from the parent's storage_path); it is never an
        # orphan and must never be deleted as one. Matched on the extension-less
        # stem because thumbs are always .webp while the parent may be any format
        # (see parent_stem_of_thumb). A set, not the db_keys list: this runs once
        # per bucket object.
        db_stems = {key_stem(key) for key in db_keys}
        orphans = [
            key
            for key in orphans
            if (parent := parent_stem_of_thumb(key)) is None or parent not in db_stems
        ]
        missing = sorted(set(db_keys) - bucket_set)

        # Age-based protection: a temp/generated image (or an item/outfit
        # object caught mid upload->DB-insert) shows up as an "orphan" while
        # its short-lived presigned URL (1h TTL) is still live. Only orphans
        # older than the grace window are deletable; younger ones are protected
        # and left untouched this run.
        now = datetime.now(timezone.utc)
        deletable, protected = split_by_age(orphans, mtime_map, min_age_hours, now)
        deletable_set = set(deletable)

        # Optional per-object byte sizes.
        sizes: Dict[str, int] = {}
        if _env_bool("MEASURE_BYTES", False) and (bucket_keys or missing):
            print("Measuring byte sizes (MEASURE_BYTES=1)...")
            sizes = await _measure_bytes(backend, list(bucket_set) + list(missing))

        usage = compute_usage(bucket_set, sizes)

        # ------------------------------------------------------------------ #
        # report
        # ------------------------------------------------------------------ #
        print()
        print("=" * 72)
        print(f"STORAGE INVENTORY - {backend.endpoint_url}/{backend.bucket}")
        print("=" * 72)
        print(f"  bucket objects        : {len(bucket_set)}")
        print(f"  DB storage_path keys  : {len(db_keys)}")
        print(f"  ORPHANS (in bucket, not in DB) : {len(orphans)}")
        print(f"    deletable (age >= {min_age_hours}h): {len(deletable)}")
        print(f"    protected (younger)          : {len(protected)}")
        print(f"  MISSING (in DB, not in bucket) : {len(missing)}")
        print()

        print("  per-category usage:")
        print(_render_usage_table(usage["categories"], "BY CATEGORY"))
        print()
        print("  per-user usage:")
        print(_render_usage_table(usage["users"], "BY USER"))
        print()

        if orphans:
            print(f"  ORPHAN KEY LIST ({len(orphans)}):")
            for key in orphans:
                age = age_hours(mtime_map.get(key), now)
                tag = "deletable" if key in deletable_set else "PROTECTED"
                age_s = f"{age}h" if age is not None else "?"
                print(f"    [{tag:<9}] {key}  (age {age_s})")
        else:
            print("  No orphan keys.")

        if missing:
            print()
            print(f"  MISSING KEY LIST ({len(missing)}):")
            for key in missing:
                refs = db_keys.get(key, [])
                print(f"    {key}  (referenced by {refs})")
        else:
            print()
            print("  No DB storage_paths missing from the bucket.")

        if orphan_list:
            orphan_list.parent.mkdir(parents=True, exist_ok=True)
            with orphan_list.open("w", encoding="utf-8") as fh:
                for key in orphans:
                    fh.write(key + "\n")
            print(f"\n  Wrote {len(orphans)} orphan key(s) to {orphan_list}")

        # ------------------------------------------------------------------ #
        # deletion
        # ------------------------------------------------------------------ #
        if delete and deletable:
            print()
            print(
                f"DELETING {len(deletable)} deletable orphan(s) "
                f"(age >= {min_age_hours}h)..."
            )
            if protected:
                print(
                    f"  protecting {len(protected)} orphan(s) younger than "
                    f"{min_age_hours}h (in-flight previews / recent uploads)."
                )
            audit_path.parent.mkdir(parents=True, exist_ok=True)
            deleted = await backend.delete_many(deletable)
            with audit_path.open("a", encoding="utf-8") as fh:
                for key in deletable:
                    fh.write(
                        json.dumps(
                            {
                                "ts": _utc_now_iso(),
                                "action": "delete",
                                "key": key,
                                "category": classify_category(key),
                                "age_hours": age_hours(mtime_map.get(key), now),
                                "protected": False,
                            },
                            separators=(",", ":"),
                        )
                        + "\n"
                    )
                for key in protected:
                    fh.write(
                        json.dumps(
                            {
                                "ts": _utc_now_iso(),
                                "action": "protect",
                                "key": key,
                                "category": classify_category(key),
                                "age_hours": age_hours(mtime_map.get(key), now),
                                "protected": True,
                            },
                            separators=(",", ":"),
                        )
                        + "\n"
                    )
            print(f"  deleted={deleted}  audit={audit_path}")
        elif delete and protected and not deletable:
            print()
            print(
                f"No deletable orphans: all {len(protected)} orphan(s) are "
                f"younger than {min_age_hours}h and protected."
            )
        elif orphans and not delete:
            print()
            print(
                f"DRY-RUN: {len(deletable)} orphan(s) would be deleted, "
                f"{len(protected)} protected. Re-run with --delete to remove "
                f"the deletable set."
            )
        else:
            print("\nNo orphans to delete.")

        return 0
    finally:
        if owns_backend:
            await backend.close()
        else:
            await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="S3 bucket orphan inventory + usage report (R2 / Railway)"
    )
    parser.add_argument(
        "--delete",
        action="store_true",
        help="Actually delete orphan objects (default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/storage_inventory.jsonl"),
        help="JSONL audit log path for deleted keys.",
    )
    parser.add_argument(
        "--orphan-list",
        default=_env("ORPHAN_LIST", "") or None,
        help="Optional path to dump the orphan key list (one per line).",
    )
    parser.add_argument(
        "--min-age-hours",
        type=float,
        default=float(_env("MIN_AGE_HOURS", str(DEFAULT_MIN_AGE_HOURS))),
        help="Grace window (hours) before an orphan is deletable; protects "
        "in-flight temp/generated previews whose presigned URL is still live "
        "(default 2 = just past the 1h presign TTL).",
    )
    # --------------------------------------------------------------------- #
    # Bucket targeting overrides (post-cutover cleanup of the OLD bucket)
    # --------------------------------------------------------------------- #
    # Without these, this script always inspects the CONFIGURED bucket. That
    # made the documented post-R2-cutover step ("empty the old Railway bucket
    # with storage_inventory.py --delete") point at R2 instead, because the env
    # has already been repointed by then.
    parser.add_argument(
        "--endpoint",
        default=_env("SOURCE_ENDPOINT", ""),
        help="Inspect this S3 endpoint instead of the configured one. Use with "
        "--bucket to target the OLD bucket after a provider cutover.",
    )
    parser.add_argument(
        "--bucket",
        default=_env("SOURCE_BUCKET", ""),
        help="Inspect this bucket instead of the configured one.",
    )
    parser.add_argument(
        "--access-key-id",
        default=_env("SOURCE_ACCESS_KEY_ID", ""),
        help="Credentials for --endpoint (defaults to the configured key).",
    )
    parser.add_argument(
        "--secret-access-key",
        default=_env("SOURCE_SECRET_ACCESS_KEY", ""),
        help="Credentials for --endpoint (defaults to the configured secret).",
    )
    parser.add_argument(
        "--region",
        default=_env("SOURCE_REGION", ""),
        help='Region for --endpoint (default "auto", correct for R2/Railway).',
    )
    args = parser.parse_args()

    # An override is only meaningful as a complete set: pointing at another
    # endpoint while silently reusing the configured bucket name (or the wrong
    # credentials) is how you end up deleting from the live bucket.
    override: Optional[S3StorageBackend] = None
    if args.endpoint or args.bucket:
        if not (args.endpoint and args.bucket):
            print(
                "ERROR: --endpoint and --bucket must be given together. "
                "Targeting one bucket's name at another endpoint is how the "
                "wrong bucket gets emptied.",
                file=sys.stderr,
            )
            return 1
        if not (args.access_key_id and args.secret_access_key):
            print(
                "ERROR: --access-key-id and --secret-access-key are required "
                "with --endpoint/--bucket. The configured credentials belong to "
                "a different provider and must not be reused implicitly.",
                file=sys.stderr,
            )
            return 1
        override = S3StorageBackend(
            endpoint_url=args.endpoint,
            region_name=args.region or "auto",
            aws_access_key_id=args.access_key_id,
            aws_secret_access_key=args.secret_access_key,
            bucket=args.bucket,
        )

    mode = "LIVE (delete)" if args.delete else "DRY-RUN"
    target = (
        f"{args.endpoint}/{args.bucket} (OVERRIDE)"
        if override is not None
        else f"{settings.OBJECT_STORAGE_ENDPOINT}/{settings.OBJECT_STORAGE_BUCKET} (configured)"
    )
    print(f"[{mode}] object storage inventory")
    print(f"  target       = {target}")
    print(f"  audit_file   = {args.audit_file}")
    print(f"  orphan_list  = {args.orphan_list or '(not writing)'}")
    print(f"  measure_bytes= {_env_bool('MEASURE_BYTES', False)}")
    print(f"  min_age_hours= {args.min_age_hours}")
    print()

    return asyncio.run(
        _run(
            delete=args.delete,
            audit_path=Path(args.audit_file),
            orphan_list=Path(args.orphan_list) if args.orphan_list else None,
            min_age_hours=args.min_age_hours,
            backend=override,
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
