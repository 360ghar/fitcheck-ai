#!/usr/bin/env python3
"""
Delete temporary generated previews (the ``tmp/`` folder) from the bucket.

Temp previews — photoshoot, batch-extraction and social-import generated
images — are NEVER referenced by any DB row and are served only via
short-lived presigned GET URLs (``OBJECT_STORAGE_PRESIGN_TTL``, default 1h).
Once the generating job finishes (or the review flow ends), the user can no
longer see them, and the objects just sit in the bucket forever. This script
is the manual weekly cleanup: list every temp object, report it, and with
``--delete`` remove them all in one pass (S3 ``delete_objects`` batching).

The top-level ``tmp/`` folder (``tmp/{user_id}/{source}/...``) means every
temp preview in the bucket shares ONE common prefix; the script also
recognises the pre-migration per-user layout (``{user_id}/tmp/{source}/...``)
so it stays useful whether or not ``scripts/migrate_temp_keys_layout.py`` has
been run — the migration is optional, not a prerequisite for cleanup.

=============================================================================
USAGE (weekly routine: dry-run, review, then --delete)
=============================================================================

    cd backend && source .venv/bin/activate
    python scripts/cleanup_temp_assets.py                     # dry-run report
    python scripts/cleanup_temp_assets.py --delete            # actually delete
    python scripts/cleanup_temp_assets.py --source photoshoot --delete
    python scripts/cleanup_temp_assets.py --min-age-hours 2   # keep recent

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--delete`` the script performs no writes at all.

2) ONLY temp previews are ever deleted. A key must match the ``tmp/`` layouts
   exactly (``tmp/{user}/{source}/{32hex}.{ext}`` or the legacy
   ``{user}/tmp/{source}/{32hex}.{ext}``). Canonical item/outfit/avatar/source
   images never match and are never touched.

3) NO AGE GATE BY DEFAULT. Temp previews are unreachable to users once their
   1h presigned URL expires, and a weekly run deleting even a live-TTL preview
   is harmless (a job in flight re-uploads on retry, and flows are minutes
   long). ``--min-age-hours`` restores an age window for conservative runs.

4) ``generated/`` IS NEVER DELETED HERE. User-requested saves (try-on, outfit,
   product renders) are kept by policy — ``scripts/storage_inventory.py``
   applies its 30-day generated window to those.

5) AUDIT LOG. Every deleted key is appended to ``AUDIT_FILE`` (JSONL).

Env: AUDIT_FILE (default backend/logs/temp_cleanup.jsonl), MIN_AGE_HOURS.
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _utc_now_iso, list_keys_with_mtime  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)


# Both layouts, one regex: the source segment is index 2 in each
# (``tmp/{user}/{source}/...`` and ``{user}/tmp/{source}/...``).
_TMP_KEY_RE = re.compile(
    r"^(?:tmp/[^/\\]+/[^/\\]+|[^/\\]+/tmp/[^/\\]+)/"
    r"[0-9a-f]{32}\.(?:jpg|jpeg|png|webp|gif|avif)$"
)


def temp_source(key: str) -> str:
    """The source subfolder of a temp key (``photoshoot``, ``batch``, ...)."""
    return key.split("/")[2]


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

    With the default ``min_age_hours=0`` every key is deletable (the weekly
    cleanup deletes regardless of TTL, per policy). With a positive window, a
    key is deletable only when its mtime is at least that window old; a key
    with no known mtime is always protected (never delete what we cannot age
    verify). Pure function (testable without the bucket).
    """
    if min_age_hours <= 0:
        return keys, []
    deletable: List[str] = []
    protected: List[str] = []
    cutoff = _to_aware_utc(now) - timedelta(hours=min_age_hours)
    for key in keys:
        mtime = mtimes.get(key)
        if mtime is None:
            protected.append(key)
            continue
        if _to_aware_utc(mtime) <= cutoff:
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


async def _run(
    delete: bool,
    audit_path: Path,
    min_age_hours: float,
    source: Optional[str],
) -> int:
    backend = get_storage_backend()
    try:
        print("Listing bucket objects (with mtime for age gating)...")
        mtime_map = await list_keys_with_mtime(backend)
        print(f"  {len(mtime_map)} object(s) in bucket")

        temp_keys = sorted(
            key for key in mtime_map if _TMP_KEY_RE.fullmatch(key)
        )
        if source:
            temp_keys = [key for key in temp_keys if temp_source(key) == source]
        print(f"  {len(temp_keys)} temp preview object(s) found")

        if not temp_keys:
            print("\nNo temp preview objects to clean.")
            return 0

        by_source: Dict[str, int] = {}
        for key in temp_keys:
            by_source[temp_source(key)] = by_source.get(temp_source(key), 0) + 1
        print("  by source:")
        for src, count in sorted(by_source.items()):
            print(f"    {src:<24} count={count}")

        now = datetime.now(timezone.utc)
        deletable, protected = split_by_age(
            temp_keys, mtime_map, min_age_hours, now
        )
        if min_age_hours > 0:
            print(
                f"  age window: {min_age_hours}h -> "
                f"{len(deletable)} deletable, {len(protected)} protected"
            )

        if not delete:
            print(
                f"\nDRY-RUN: {len(deletable)} temp object(s) would be deleted"
                f" ({len(protected)} protected). Re-run with --delete to remove."
            )
            return 0

        if not deletable:
            print("\nNo deletable temp objects.")
            return 0

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
                            "source": temp_source(key),
                            "age_hours": age_hours(mtime_map.get(key), now),
                        },
                        separators=(",", ":"),
                    )
                    + "\n"
                )
        print(f"\n  deleted={deleted}  audit={audit_path}")
        return 0
    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Delete temporary generated previews (tmp/ folder) from "
        "the configured bucket (dry-run by default)."
    )
    parser.add_argument(
        "--delete",
        action="store_true",
        help="Actually delete the temp objects (default is dry-run).",
    )
    parser.add_argument(
        "--source",
        default=None,
        help="Only touch one source subfolder (e.g. photoshoot, batch, "
        "social-import).",
    )
    parser.add_argument(
        "--min-age-hours",
        type=float,
        default=float(_env("MIN_AGE_HOURS", "0")),
        help="Only delete objects older than this many hours. Default 0 = no "
        "age gate (weekly cleanup may delete live-TTL previews, which is "
        "harmless by policy).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/temp_cleanup.jsonl"),
        help="JSONL audit log path for deleted keys.",
    )
    args = parser.parse_args()

    mode = "LIVE (delete)" if args.delete else "DRY-RUN"
    print(f"[{mode}] temp preview cleanup")
    print(f"  target       = {get_storage_backend().endpoint_url}/{get_storage_backend().bucket}")
    print(f"  source       = {args.source or '(all)'}")
    print(f"  min_age_hours= {args.min_age_hours}")
    print(f"  audit_file   = {args.audit_file}")
    print()

    return asyncio.run(
        _run(
            delete=args.delete,
            audit_path=Path(args.audit_file),
            min_age_hours=args.min_age_hours,
            source=args.source,
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
