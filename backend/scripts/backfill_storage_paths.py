#!/usr/bin/env python3
"""
Backfill NULL ``storage_path`` on legacy image rows.

WHY
---

The durable reference for every stored image is the bucket key
(``storage_path``); read paths materialize fresh short-lived URLs from it
(``materialize_image_urls``) and the mobile app re-mints on a stale URL via
``GET /api/v1/images/presigned?storage_path=...``. Rows created before the
object-storage cutover (2026-08-04, Supabase Storage -> Railway/R2) may have a
NULL ``storage_path`` while ``image_url`` holds a *dead* Supabase public URL or
an expired presigned URL. ``materialize_image_urls`` skips rows without a
``storage_path`` and the re-mint endpoint cannot be called without one, so
those images are broken with no client-side recovery — exactly the "closet
images never load" class of failures.

The URL is not garbage, though: it embeds the same key the object now lives
under in R2 (``/storage/v1/object/public/<bucket>/<key>``, a path-style
presigned URL ``/<bucket>/<key>``, or a bare key). This script extracts the
key with the app's own ``key_from_path`` (the SSRF-safe
reducer the read paths use), validates it against the canonical layout
(``{user-uuid}/{items|outfits|sources|...}/...``), and writes it back — after
which read paths materialize fresh URLs and the client re-mint works.

Tables covered:

- ``item_images.storage_path``  (derived from ``image_url``/``thumbnail_url``)
- ``outfit_images.storage_path`` (derived from ``image_url``/``thumbnail_url``)
- ``items.source_image_storage_path`` (derived from ``source_image_url``; the
  source photo is referenced by outfit-generation, so a dead source URL breaks
  "use source photo as reference" flows too)

``users.avatar_url`` is deliberately NOT touched: its read path
(``materialize_avatar_url``) already derives the key from the stored URL on
every read, so avatars self-heal without a backfill.

Rows whose URL does not reduce to one of our canonical keys (external OAuth
pictures, junk like ``https://example.com/a.jpg``) are reported as
unrepairable and left untouched — the object never existed in our bucket, so
there is no key to write.

=============================================================================
USAGE (routine: dry-run, review, then --apply)
=============================================================================

    cd backend && source .venv/bin/activate
    python scripts/backfill_storage_paths.py              # dry-run report
    python scripts/backfill_storage_paths.py --apply      # write the keys

Env: AUDIT_FILE (default backend/logs/storage_paths_backfill.jsonl).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _utc_now_iso  # noqa: E402
from app.core.storage_keys import (  # noqa: E402
    CANONICAL_CATEGORIES,
    key_from_path,
    parse_key,
)
from app.db.connection import SupabaseDB  # noqa: E402

# Canonical categories that can back a DB-referenced image row come from the
# shared grammar (app.core.storage_keys). Preview keys (``tmp/``,
# ``generated/``) are never DB-referenced, so a derived key that lands there
# means the URL is not one of ours and must NOT be written.

# (table, storage column to fill, URL columns to derive from, label)
_TABLES: Tuple[Tuple[str, str, Tuple[str, ...], str], ...] = (
    ("item_images", "storage_path", ("image_url", "thumbnail_url"), "item image"),
    ("outfit_images", "storage_path", ("image_url", "thumbnail_url"), "outfit image"),
    ("items", "source_image_storage_path", ("source_image_url",), "source photo"),
)


def derive_storage_path(value: Optional[str]) -> Optional[str]:
    """Reduce a stored URL or bare key to a canonical storage key, or None.

    Conservative by design: ``key_from_path`` already refuses to reshape
    unrelated external URLs into keys, and this function additionally requires
    the canonical ``{user}/{category}/...`` shape (current ``users/{user}/...``
    or legacy ``{user}/...``, category one of ours). Anything else — an OAuth
    picture, a junk URL, a preview key — returns None and the row is reported
    unrepairable.
    """
    if not value:
        return None
    key = key_from_path(value)
    if not key:
        return None
    ref = parse_key(key)
    if ref is None or ref.layout not in ("canonical", "legacy_canonical"):
        return None
    if ref.category not in CANONICAL_CATEGORIES:
        return None
    return key


# PostgREST caps a single SELECT at this many rows (hosted Supabase default),
# so a bare select would silently stop scanning past row 1000. Pages of id
# order; rows beyond the cap are otherwise never examined and the report
# under-counts candidates without any error.
_PAGE_SIZE = 1000


def collect_candidates(db, table: str, storage_col: str, url_cols: Tuple[str, ...]) -> List[Dict[str, Any]]:
    """Fetch rows lacking a storage key, with the URL(s) to derive from.

    Rows that already carry a ``storage_path`` are skipped (nothing to do);
    rows with an empty-string key are treated as missing (legacy writes could
    store ``""``). Fails loud on a missing column so an operator sees the
    error instead of a silently partial backfill.

    Scans in id order, ``_PAGE_SIZE`` rows per request (PostgREST's per-request
    cap), so tables larger than one page are fully examined.
    """
    select_cols = ", ".join(("id", storage_col, *url_cols))
    out: List[Dict[str, Any]] = []
    offset = 0
    while True:
        try:
            resp = (
                db.table(table)
                .select(select_cols)
                .order("id")
                .range(offset, offset + _PAGE_SIZE - 1)
                .execute()
            )
        except Exception as e:  # noqa: BLE001
            print(f"ERROR: could not read {table}: {e}", file=sys.stderr)
            raise
        rows = resp.data or []
        for row in rows:
            if row.get(storage_col):
                continue  # already durable-referenced
            url = next((row.get(c) for c in url_cols if row.get(c)), None)
            out.append(
                {
                    "id": str(row.get("id") or ""),
                    "url": url,
                }
            )
        if len(rows) < _PAGE_SIZE:
            break
        offset += _PAGE_SIZE
    return out


def run_backfill(
    db,
    *,
    apply: bool = False,
    audit_path: Optional[Path] = None,
) -> Dict[str, Any]:
    """Scan the three tables and (with ``apply``) write derived keys.

    Returns a report dict:

    ``{"tables": {<table>: {"candidates": n, "repaired": n, "unrepairable": n,
    "samples": [...]}}, "repaired_total": n, "unrepairable_total": n}``

    Dry-run (``apply=False``) performs no writes. The audit log records every
    written key as JSONL: ``{"ts", "action", "table", "row_id",
    "storage_path", "source_url"}``.
    """
    report: Dict[str, Any] = {"tables": {}, "repaired_total": 0, "unrepairable_total": 0}
    audit_lines: List[Dict[str, Any]] = []

    for table, storage_col, url_cols, label in _TABLES:
        candidates = collect_candidates(db, table, storage_col, url_cols)
        repaired = 0
        unrepairable = 0
        samples: List[Dict[str, Any]] = []

        for row in candidates:
            key = derive_storage_path(row["url"])
            if not key:
                unrepairable += 1
                if len(samples) < 5:
                    samples.append(
                        {"row_id": row["id"], "url": (row["url"] or "")[:160], "status": "unrepairable"}
                    )
                continue
            repaired += 1
            if len(samples) < 5:
                samples.append(
                    {"row_id": row["id"], "url": (row["url"] or "")[:160], "storage_path": key, "status": "repairable"}
                )
            if not apply:
                continue
            try:
                db.table(table).update({storage_col: key}).eq("id", row["id"]).execute()
            except Exception as e:  # noqa: BLE001
                print(f"ERROR: failed to update {table} row {row['id']}: {e}", file=sys.stderr)
                unrepairable += 1
                repaired -= 1
                continue
            audit_lines.append(
                {
                    "ts": _utc_now_iso(),
                    "action": "backfill_storage_path",
                    "table": table,
                    "row_id": row["id"],
                    "storage_path": key,
                    "source_url": (row["url"] or "")[:160],
                }
            )

        report["tables"][table] = {
            "label": label,
            "candidates": len(candidates),
            "repaired": repaired,
            "unrepairable": unrepairable,
            "samples": samples,
        }
        report["repaired_total"] += repaired
        report["unrepairable_total"] += unrepairable

    if apply and audit_path is not None and audit_lines:
        audit_path.parent.mkdir(parents=True, exist_ok=True)
        with audit_path.open("a", encoding="utf-8") as fh:
            for line in audit_lines:
                fh.write(json.dumps(line, separators=(",", ":")) + "\n")

    return report


def _print_report(report: Dict[str, Any], apply: bool) -> None:
    mode = "APPLY" if apply else "DRY-RUN"
    print(f"[{mode}] storage_path backfill")
    for table, info in report["tables"].items():
        print(f"\n{table} ({info['label']}):")
        print(f"  candidates  = {info['candidates']}")
        print(f"  repaired    = {info['repaired']}")
        print(f"  unrepairable= {info['unrepairable']}")
        for sample in info["samples"]:
            if sample["status"] == "repairable":
                print(f"    + {sample['storage_path']}")
            else:
                print(f"    ? {sample['url']}")
    print(
        f"\nTOTAL: {report['repaired_total']} repairable, "
        f"{report['unrepairable_total']} unrepairable "
        f"({'would be written' if not apply else 'written'})."
    )


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Backfill NULL storage_path on item_images / outfit_images "
        "/ items.source_image_storage_path rows from their stored URLs "
        "(dry-run by default)."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually write the derived keys (default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/storage_paths_backfill.jsonl"),
        help="JSONL audit log path for written keys.",
    )
    args = parser.parse_args()

    db = SupabaseDB.get_service_client()
    report = run_backfill(
        db,
        apply=args.apply,
        audit_path=Path(args.audit_file) if args.apply else None,
    )
    _print_report(report, apply=args.apply)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
