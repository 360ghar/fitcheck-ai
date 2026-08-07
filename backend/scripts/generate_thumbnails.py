#!/usr/bin/env python3
"""
Backfill thumbnail sibling objects (``{key}_thumb``) onto the existing corpus.

Read paths materialize ``thumbnail_url`` to a separate downscaled object when
``THUMBNAIL_SERVING=1`` (see ``StorageService.thumb_key_for`` /
``_upload_thumbnail``). Uploads create the thumb automatically, but objects
that predate the feature have no thumb — this script walks the bucket and
creates the missing variant for every canonical key
(``{user_id}/{items|outfits|avatars|sources|feedback}/{name}.{ext}``).

    cd backend && source .venv/bin/activate
    python scripts/generate_thumbnails.py                    # measure only (default)
    DRY_RUN=0 ONLY_USER_ID=<your-uuid> python scripts/generate_thumbnails.py
    DRY_RUN=0 CONCURRENCY=4 python scripts/generate_thumbnails.py   # then everyone

NOTE ``DRY_RUN`` DEFAULTS TO 1 — a command without ``DRY_RUN=0`` writes nothing.

Run it BEFORE flipping ``THUMBNAIL_SERVING=true``: a legacy object without a
thumb would otherwise 404 on its ``thumbnail_url`` (clients fall back to
``thumbnail_url || image_url`` only when the field is empty, not on HTTP 404).
A non-zero exit means some keys could not be thumbnailed; re-run to retry, and
do NOT flip the flag while any remain.

Thumbnails are WebP with transparency preserved (``THUMB_EXTENSION``), so a
background-removed cutout keeps its alpha in the grid tile.

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``DRY_RUN=0`` the script does no writes.

2) IDEMPOTENT + RESUMABLE. Keys whose thumb already exists are skipped; a
   JSONL audit log records every write, and a key whose last action is
   ``written`` is never revisited.

3) SOURCE IS READ-ONLY. Only NEW ``_thumb`` objects are uploaded; originals
   are never modified.

=============================================================================
ENVIRONMENT
=============================================================================

Required (from ``backend/.env`` via ``app.core.config``):
    SUPABASE_URL / SUPABASE_SECRET_KEY  (unused by this script — kept out of
    the config import path; only OBJECT_STORAGE_* matter)

Optional:
    DRY_RUN=1                  # 1 = measure only, write nothing
    ONLY_USER_ID=              # restrict to one user's keys (key prefix)
    LIMIT=0                    # 0 = unbounded
    CONCURRENCY=4              # parallel download+downscale+upload workers
    AUDIT_FILE=backend/logs/thumbnail_backfill.jsonl
"""

from __future__ import annotations

import asyncio
import json
import os
import sys
from pathlib import Path
from typing import Dict, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)
from app.services.storage_service import StorageService  # noqa: E402
from scripts._common import _env, _env_bool, _env_int, _utc_now_iso  # noqa: E402


def load_audit(path: Path) -> set[str]:
    """Keys already written (never revisited).

    ``written`` is the only terminal action ``process`` produces — an error is
    deliberately retryable — so it is the only one recorded here.
    """
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
    return {k for k, a in latest.items() if a == "written"}


async def _amain() -> int:
    dry_run = _env_bool("DRY_RUN", True)
    only_user_id = _env("ONLY_USER_ID", "").strip()
    limit = max(0, _env_int("LIMIT", 0))
    concurrency = max(1, _env_int("CONCURRENCY", 4))
    audit_path = Path(_env("AUDIT_FILE", "backend/logs/thumbnail_backfill.jsonl"))

    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] backfill thumbnails")
    print(f"  only_user_id = {only_user_id or '(all users)'}")
    print(f"  limit        = {limit or 'unbounded'}")
    print(f"  concurrency  = {concurrency}")
    print(f"  audit_file   = {audit_path}")
    print()

    backend = get_storage_backend()
    try:
        print("Listing bucket keys...")
        keys = await backend.list_keys(prefix=only_user_id)
        existing_thumbs = {
            key for key in keys if "_thumb" in key.split("/")[-1]
        }
        # `thumb_key_for` returns None for precisely the non-candidates (unknown
        # category, `tmp/` preview, `_thumb` key, no extension), so it IS the
        # predicate — a local copy of those rules would let the backfill select a
        # different key set than the upload and read paths, which is the very
        # split this script exists to close.
        candidates = [key for key in keys if StorageService.thumb_key_for(key)]
        missing = [
            key
            for key in candidates
            if StorageService.thumb_key_for(key) not in existing_thumbs
        ]
        if limit:
            missing = missing[:limit]
        print(f"  bucket objects     : {len(keys)}")
        print(f"  canonical keys     : {len(candidates)}")
        print(f"  thumbs to create   : {len(missing)}")

        if not missing:
            print("\nNothing to do — every canonical key already has a thumbnail.")
            return 0

        if dry_run:
            for key in missing[:20]:
                print(f"    would create {StorageService.thumb_key_for(key)}")
            if len(missing) > 20:
                print(f"    ... and {len(missing) - 20} more")
            print("\nDRY-RUN: no writes. Re-run with DRY_RUN=0 to create thumbnails.")
            return 0

        done = load_audit(audit_path)
        pending = [key for key in missing if key not in done]
        print(f"  audit: {len(missing) - len(pending)} already done, "
              f"{len(pending)} to process")

        if not pending:
            return 0

        audit_path.parent.mkdir(parents=True, exist_ok=True)
        sem = asyncio.Semaphore(concurrency)
        written = errors = 0

        async def process(key: str) -> Tuple[str, str, int]:
            async with sem:
                try:
                    content = await backend.download(key)
                    ok = await StorageService._upload_thumbnail(
                        backend, key, content
                    )
                    if ok:
                        return key, "written", len(content)
                    # _upload_thumbnail already logged the failure; a False
                    # return means no variant was written (error case), so the
                    # key stays retryable on the next run.
                    return key, "error: thumb write failed", len(content)
                except Exception as e:  # noqa: BLE001
                    return key, f"error: {e}"[:200], 0

        with audit_path.open("a", encoding="utf-8") as fh:
            results = await asyncio.gather(*(process(key) for key in pending))
            for key, action, size in results:
                if action == "written":
                    written += 1
                else:
                    errors += 1
                fh.write(
                    json.dumps(
                        {
                            "ts": _utc_now_iso(),
                            "key": key,
                            "thumb_key": StorageService.thumb_key_for(key),
                            "action": action,
                            "size": size,
                        },
                        separators=(",", ":"),
                    )
                    + "\n"
                )

        print()
        print("=" * 64)
        print("THUMBNAIL BACKFILL SUMMARY")
        print("=" * 64)
        print(f"  written : {written}")
        print(f"  errors  : {errors}")
        print("=" * 64)
        if errors:
            print(
                f"{errors} key(s) errored and remain retryable; re-run to finish.",
                file=sys.stderr,
            )
            return 1
        print("Done. Flip THUMBNAIL_SERVING=true to serve the variants.")
        return 0

    finally:
        await close_storage_backend()


def main() -> int:
    """Sync entrypoint. The body is async (bucket IO), so it needs its own loop."""
    return asyncio.run(_amain())


if __name__ == "__main__":
    raise SystemExit(main())
