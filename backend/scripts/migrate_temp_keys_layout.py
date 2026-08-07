#!/usr/bin/env python3
"""
Migrate per-user preview keys to the shared top-level ``tmp/`` and
``generated/`` folders.

OLD layout (per-user — every user's previews live under their own prefix, so
no single prefix covers all temp images):

    {user_id}/tmp/{source}/{32hex}.{ext}
    {user_id}/generated/{image_type}/{32hex}.{ext}

NEW layout (top-level folder — every preview shares ONE common prefix):

    tmp/{user_id}/{source}/{32hex}.{ext}
    generated/{user_id}/{image_type}/{32hex}.{ext}

Why: with the per-user layout, "clear the temp folder" requires a full-bucket
scan and a provider lifecycle rule is impossible (rules match key prefixes,
and every user's tmp folder is a different prefix). With the top-level folder,
``scripts/cleanup_temp_assets.py`` lists everything under ``tmp/`` in one pass
and a lifecycle rule on that prefix becomes possible.

The rewrite is an S3 server-side ``copy`` followed by a ``delete`` of the old
key — no bytes are downloaded or re-uploaded. Dry-run is the default: without
``--apply`` the script performs NO writes at all.

=============================================================================
SAFETY GUARANTEES
=============================================================================

1) DRY-RUN FIRST. Without ``--apply`` nothing is copied, deleted, or logged.

2) ONLY legacy preview keys are rewritten. A key must match the exact legacy
   layout (``{user}/{tmp|generated}/{sub}/{32hex}.{ext}`` with an image
   extension) to be touched. Canonical ``{user}/{category}/...`` keys, thumb
   siblings, exports, and already-migrated top-level keys never match and are
   never moved.

3) COPY-THEN-DELETE. A failed copy leaves the old key untouched, so the
   object is never lost.

4) NEVER OVERWRITE. If the target key already exists (a partial prior run),
   the key is skipped and reported instead of clobbered. Collisions are
   effectively impossible (names are uuid4 hex) — this guards the re-run case.

5) IDEMPOTENT. New-layout keys do not match the legacy pattern, so re-running
   after a completed migration reports nothing to move.

6) AUDIT LOG. Every move/skip/failure is appended to ``AUDIT_FILE`` (JSONL).

=============================================================================
RUN WHEN REVIEW FLOWS ARE QUIET
=============================================================================

Social-import review rows store ``generated_storage_path`` pointing at tmp
keys while a job is mid-review. This script rewrites bucket keys only, so an
old key referenced by a live review row would 404 on refetch after the move.
Run it outside active import/review periods (or accept the tiny window).

    cd backend && source .venv/bin/activate
    python scripts/migrate_temp_keys_layout.py          # dry-run report
    python scripts/migrate_temp_keys_layout.py --apply  # actually move

Afterwards verify: ``python scripts/storage_inventory.py`` — the per-category
report should show zero objects under the legacy layout, and ``tmp`` /
``generated`` should appear as FIRST-segment categories.

Env: AUDIT_FILE (default backend/logs/migrate_temp_keys_layout.jsonl).
"""

from __future__ import annotations

import argparse
import asyncio
import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Make the backend package importable when run from the backend dir.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from scripts._common import _env, _utc_now_iso, list_keys_with_mtime  # noqa: E402
from app.services.object_storage import (  # noqa: E402
    close_storage_backend,
    get_storage_backend,
)


# Legacy per-user preview keys: {user}/{tmp|generated}/{sub}/{32hex}.{ext}
_LEGACY_PREVIEW_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?P<folder>tmp|generated)/(?P<sub>[^/\\]+)/"
    r"(?P<name>[0-9a-f]{32})(?P<ext>\.(?:jpg|jpeg|png|webp|gif|avif))$"
)


def legacy_to_new_key(key: str) -> Optional[str]:
    """Map a legacy per-user preview key to the top-level-folder layout.

    Returns None for anything that is not a legacy preview key — canonical
    keys, thumbnails, exports, and new-layout keys are never rewritten.
    """
    match = _LEGACY_PREVIEW_KEY_RE.fullmatch(key)
    if not match:
        return None
    return (
        f"{match.group('folder')}/{match.group('user')}/"
        f"{match.group('sub')}/{match.group('name')}{match.group('ext')}"
    )


def _fmt_pair_count(pairs: List[Tuple[str, str]]) -> str:
    """Per-folder counts (``tmp/`` vs ``generated/``) for the report."""
    folders: Dict[str, int] = {}
    for _old, new in pairs:
        folder = new.split("/", 1)[0]
        folders[folder] = folders.get(folder, 0) + 1
    if not folders:
        return "  (none)"
    return "\n".join(
        f"    {folder}/: {count}" for folder, count in sorted(folders.items())
    )


async def _run(apply: bool, audit_path: Path) -> int:
    backend = get_storage_backend()
    try:
        print("Listing bucket objects (with mtime)...")
        mtime_map = await list_keys_with_mtime(backend)
        print(f"  {len(mtime_map)} object(s) in bucket")

        pairs = sorted(
            (key, new_key)
            for key in mtime_map
            if (new_key := legacy_to_new_key(key)) is not None
        )
        print(f"  {len(pairs)} legacy preview key(s) to migrate")
        print("  by folder:")
        print(_fmt_pair_count(pairs))

        if not pairs:
            print(
                "\nNo legacy preview keys to migrate "
                "(bucket already on the top-level layout)."
            )
            return 0

        # A target that already exists means a partial prior run; skipping it
        # is the safe choice (copy_object would silently overwrite).
        existing_keys = set(mtime_map)
        collisions = [(old, new) for old, new in pairs if new in existing_keys]
        if collisions:
            print(
                f"\n  WARNING: {len(collisions)} target key(s) already exist "
                f"(partial prior run?); those pairs will be skipped."
            )

        audit_path.parent.mkdir(parents=True, exist_ok=True)

        def _audit(action: str, old: str, new: str, error: str = "") -> None:
            with audit_path.open("a", encoding="utf-8") as fh:
                fh.write(
                    json.dumps(
                        {
                            "ts": _utc_now_iso(),
                            "action": action,
                            "old_key": old,
                            "new_key": new,
                            "folder": new.split("/", 1)[0],
                            "error": error or None,
                        },
                        separators=(",", ":"),
                    )
                    + "\n"
                )

        if not apply:
            print(
                f"\nDRY-RUN: {len(pairs)} key(s) would be moved "
                f"({len(collisions)} collision(s) skipped). "
                f"Re-run with --apply to execute."
            )
            return 0

        print(f"\nMOVING {len(pairs)} key(s) (server-side copy + delete)...")

        # Bounded concurrency: with tens of thousands of legacy keys, a
        # per-key sequential copy+delete is 2xN S3 round trips. Each key's
        # copy-then-delete stays sequential within its own task (a failed
        # copy still leaves the old key untouched); only independent keys
        # run in parallel. Outcomes are reported in the original pair order
        # so the audit log and console stay deterministic.
        semaphore = asyncio.Semaphore(8)

        async def _move_pair(old: str, new: str) -> Tuple[str, str, str, str]:
            """Return (action, old, new, error) for one key pair."""
            if new in existing_keys:
                return ("skip", old, new, "target already exists")
            try:
                async with semaphore:
                    await backend.copy(old, new)
                    await backend.delete(old)
                return ("move", old, new, "")
            except Exception as e:  # noqa: BLE001
                return ("fail", old, new, str(e))

        results = await asyncio.gather(*(_move_pair(old, new) for old, new in pairs))
        moved = failed = skipped = 0
        for action, old, new, error in results:
            if action == "skip":
                skipped += 1
                _audit("skip", old, new, error)
                print(f"  SKIP   {old} -> {new} (target exists)")
            elif action == "fail":
                failed += 1
                _audit("fail", old, new, error)
                print(f"  FAILED {old} -> {new}: {error}")
            else:
                moved += 1
                _audit("move", old, new)
        print(f"  moved={moved} failed={failed} skipped={skipped} audit={audit_path}")
        return 0
    finally:
        await close_storage_backend()


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Migrate per-user tmp/generated keys to the top-level "
        "tmp/ and generated/ folders (dry-run by default)."
    )
    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually copy+delete the legacy keys (default is dry-run).",
    )
    parser.add_argument(
        "--audit-file",
        default=_env("AUDIT_FILE", "backend/logs/migrate_temp_keys_layout.jsonl"),
        help="JSONL audit log path for moved/skipped/failed keys.",
    )
    args = parser.parse_args()

    mode = "LIVE (apply)" if args.apply else "DRY-RUN"
    print(f"[{mode}] temp-key layout migration")
    print(f"  target     = {get_storage_backend().endpoint_url}/{get_storage_backend().bucket}")
    print(f"  audit_file = {args.audit_file}")
    print()

    return asyncio.run(_run(apply=args.apply, audit_path=Path(args.audit_file)))


if __name__ == "__main__":
    raise SystemExit(main())
