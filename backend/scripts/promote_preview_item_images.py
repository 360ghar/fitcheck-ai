#!/usr/bin/env python3
"""
Promote preview-keyed item images to canonical item objects + durable rows.

WHY
---

The web batch save flow (before 2026-08-09) persisted the AI pipeline's
SHORT-LIVED presigned URL as ``item_images.image_url`` with a NULL
``storage_path``. Read paths can only re-mint URLs from the durable key, so
those rows render a broken tile as soon as the URL expires and nothing can
ever fix them client-side — the 2026-08-09 closet-image RCA follow-up.

The stored URL does embed the key (a presigned ``/<bucket>/<key>`` URL), and
the key lives under the TEMP layout (``tmp/{user}/batch/{uuid}.webp``). Two
things make a bare key write insufficient:

1. ``materialize_image_urls`` can re-mint a ``tmp/`` key (it is servable),
   but the weekly temp cleanup (``scripts/cleanup_temp_assets.py``) deletes
   the object, so the row would break again at the next cleanup.
2. ``scripts/backfill_storage_paths.py`` deliberately refuses preview keys —
   by design, preview keys are never DB-referenced.

The durable fix is what the social-import save flow already does at save
time: PROMOTE the temp object to a canonical ``{user}/items/...`` object
(server-side copy, ``StorageService.promote_temp_image_to_item``), then write
the canonical ``storage_path`` plus fresh URLs back to the row.

This script scans ``item_images`` rows whose ``storage_path`` is missing or
still a preview key, derives the key from the stored URL, promotes the temp
object (with ``--apply``), and updates the row. Rows whose key is canonical
are skipped (``backfill_storage_paths.py`` owns those); rows whose URL does
not reduce to one of our keys, or whose object no longer exists in the
bucket, are reported unrecoverable and left untouched.

=============================================================================
USAGE (routine: dry-run, review, then --apply)
=============================================================================

    cd backend && source .venv/bin/activate
    python scripts/promote_preview_item_images.py            # dry-run report
    python scripts/promote_preview_item_images.py --apply    # promote + write

Env: AUDIT_FILE (default backend/logs/preview_promotions.jsonl).
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _utc_now_iso  # noqa: E402
from app.core.storage_keys import is_preview_key  # noqa: E402
from app.db.connection import SupabaseDB  # noqa: E402
from app.services.object_storage import close_storage_backend  # noqa: E402
from app.services.storage_service import StorageService  # noqa: E402

_PAGE_SIZE = 1000


def _preview_owner(key: Optional[str]) -> Optional[str]:
    """Return the owning user segment of a preview key, or None.

    Owner is segment 1 for ``tmp|generated/{user}/...`` and segment 0 for the
    legacy ``{user}/tmp|generated/...`` layout.
    """
    if not key:
        return None
    parts = key.split("/")
    if len(parts) < 3:
        return None
    if parts[0] in ("tmp", "generated"):
        return parts[1]
    if parts[1] in ("tmp", "generated"):
        return parts[0]
    return None


def collect_candidates(db) -> List[Dict[str, Any]]:
    """Fetch item_images rows lacking a durable canonical reference.

    Includes rows with a NULL/empty ``storage_path`` AND rows whose path is
    still a preview key (a client or earlier deploy persisted one). The
    owning user comes from the parent ``items`` row via an embedded select
    (PostgREST returns it as ``row["items"]["user_id"]``); it is required to
    validate key ownership before promoting.

    Scans in id order, ``_PAGE_SIZE`` rows per request (PostgREST's per-
    request cap), so tables larger than one page are fully examined.
    """
    out: List[Dict[str, Any]] = []
    offset = 0
    while True:
        try:
            resp = (
                db.table("item_images")
                .select(
                    "id,item_id,image_url,thumbnail_url,storage_path,"
                    "items(user_id)"
                )
                .order("id")
                .range(offset, offset + _PAGE_SIZE - 1)
                .execute()
            )
        except Exception as e:  # noqa: BLE001
            print(f"ERROR: could not read item_images: {e}", file=sys.stderr)
            raise
        rows = resp.data or []
        for row in rows:
            storage_path = row.get("storage_path")
            if storage_path and not is_preview_key(storage_path):
                continue  # already durable-canonical (or foreign); not ours
            nested = row.get("items")
            user_id = (
                nested.get("user_id")
                if isinstance(nested, dict)
                else row.get("user_id")
            )
            url = row.get("image_url") or row.get("thumbnail_url")
            out.append(
                {
                    "id": str(row.get("id") or ""),
                    "item_id": str(row.get("item_id") or ""),
                    "user_id": str(user_id or ""),
                    "storage_path": storage_path,
                    "url": url,
                }
            )
        if len(rows) < _PAGE_SIZE:
            break
        offset += _PAGE_SIZE
    return out


async def _promote_one(
    db,
    row: Dict[str, Any],
    key: str,
) -> Dict[str, Any]:
    """Promote a preview object to a canonical item path and mint fresh URLs.

    Raises on any failure (missing object, storage error) so the caller can
    report the row unrecoverable.
    """
    promoted = await StorageService.promote_temp_image_to_item(
        db=db,
        user_id=row["user_id"],
        temp_storage_path=key,
        filename_hint="generated.png",
    )
    return {
        "storage_path": promoted["storage_path"],
        "image_url": promoted["image_url"],
        "thumbnail_url": promoted["thumbnail_url"],
    }


def _update_row(db, row_id: str, fresh: Dict[str, Any]) -> None:
    """Sync write of the durable keys back to the item_images row."""
    (
        db.table("item_images")
        .update(
            {
                "storage_path": fresh["storage_path"],
                "image_url": fresh["image_url"],
                "thumbnail_url": fresh["thumbnail_url"],
            }
        )
        .eq("id", row_id)
        .execute()
    )


async def run_promotion(
    db,
    *,
    apply: bool = False,
    audit_path: Optional[Path] = None,
) -> Dict[str, Any]:
    """Scan item_images and (with ``apply``) promote + write durable rows.

    Returns ``{"candidates": n, "promoted": n, "unrecoverable": n,
    "samples": [...]}``. Dry-run performs no storage or DB writes. The audit
    log records every promoted row as JSONL: ``{"ts", "action", "row_id",
    "item_id", "user_id", "old_key", "new_key", "source_url"}``.
    """
    candidates = collect_candidates(db)
    promoted = 0
    unrecoverable = 0
    samples: List[Dict[str, Any]] = []
    audit_lines: List[Dict[str, Any]] = []

    for row in candidates:
        key = StorageService.key_from_path(row["url"])
        if not is_preview_key(key):
            unrecoverable += 1
            if len(samples) < 5:
                samples.append(
                    {
                        "row_id": row["id"],
                        "url": (row["url"] or "")[:160],
                        "status": "unrepairable",
                        "reason": "URL does not reduce to a preview key",
                    }
                )
            continue
        owner = _preview_owner(key)
        if not owner or owner != row["user_id"]:
            unrecoverable += 1
            if len(samples) < 5:
                samples.append(
                    {
                        "row_id": row["id"],
                        "url": (row["url"] or "")[:160],
                        "status": "unrepairable",
                        "reason": "preview key is not owned by the row's item user",
                    }
                )
            continue

        if len(samples) < 5:
            samples.append(
                {
                    "row_id": row["id"],
                    "item_id": row["item_id"],
                    "old_key": key,
                    "status": "repairable",
                }
            )
        if not apply:
            promoted += 1
            continue

        try:
            fresh = await _promote_one(db, row, key)
        except Exception as e:  # noqa: BLE001
            print(
                f"ERROR: promotion failed for row {row['id']} "
                f"(key {key}): {e}",
                file=sys.stderr,
            )
            unrecoverable += 1
            continue

        try:
            await asyncio.to_thread(_update_row, db, row["id"], fresh)
        except Exception as e:  # noqa: BLE001
            print(
                f"ERROR: failed to update row {row['id']}: {e}",
                file=sys.stderr,
            )
            unrecoverable += 1
            continue

        promoted += 1
        audit_lines.append(
            {
                "ts": _utc_now_iso(),
                "action": "promote_preview_item_image",
                "row_id": row["id"],
                "item_id": row["item_id"],
                "user_id": row["user_id"],
                "old_key": key,
                "new_key": fresh["storage_path"],
                "source_url": (row["url"] or "")[:160],
            }
        )

    if apply and audit_path is not None and audit_lines:
        audit_path.parent.mkdir(parents=True, exist_ok=True)
        with audit_path.open("a", encoding="utf-8") as fh:
            for line in audit_lines:
                fh.write(json.dumps(line, separators=(",", ":")) + "\n")

    return {
        "candidates": len(candidates),
        "promoted": promoted,
        "unrecoverable": unrecoverable,
        "samples": samples,
    }


def _print_report(report: Dict[str, Any], apply: bool) -> None:
    mode = "APPLY" if apply else "DRY-RUN"
    print(f"[{mode}] preview item-image promotion")
    print(f"  candidates    = {report['candidates']}")
    print(f"  promotable    = {report['promoted']}")
    print(f"  unrecoverable = {report['unrecoverable']}")
    for sample in report["samples"]:
        if sample.get("status") == "repairable":
            print(f"    + {sample['old_key']}  (row {sample['row_id']})")
        else:
            print(f"    ? {sample.get('reason')}  (row {sample.get('row_id')})")
    if apply:
        print(f"\nTOTAL: {report['promoted']} promoted and written.")
    else:
        print(f"\nTOTAL: {report['promoted']} would be promoted (dry-run; "
              f"re-run with --apply to write).")


async def _run(apply: bool, audit_path: Optional[Path]) -> int:
    db = SupabaseDB.get_service_client()
    try:
        report = await run_promotion(db, apply=apply, audit_path=audit_path)
        _print_report(report, apply=apply)
        return 0
    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Promote preview-keyed item images to canonical item "
        "objects and durable rows (dry-run by default)."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually promote the temp objects and write the rows "
        "(default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/preview_promotions.jsonl"),
        help="JSONL audit log path for promoted rows.",
    )
    args = parser.parse_args()
    return asyncio.run(
        _run(
            apply=args.apply,
            audit_path=Path(args.audit_file) if args.apply else None,
        )
    )


if __name__ == "__main__":
    raise SystemExit(main())
