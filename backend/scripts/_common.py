"""Shared helpers for the operational scripts in this directory.

Every script here is a standalone entrypoint driven by environment variables (or
argparse) and prints a human-readable report, so they all need the same handful of
primitives: read an env var, coerce it to a bool or an int without exploding on a
typo, stamp a UTC timestamp on an audit line, and format a byte count. Those five
functions were byte-identical copies in five scripts; a fix to any one of them (a
new truthy spelling, a different warning channel) reached only the copy someone
happened to be editing.

Import as ``from scripts._common import ...`` when run from the repo root, or via
the sys.path shim each script already installs for ``app`` imports.
"""

import os
import sys
from datetime import datetime, timezone
from typing import Dict


def _env(name: str, default: str = "") -> str:
    return os.environ.get(name, default)


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {
        "1",
        "true",
        "yes",
        "on",
    }


def _env_int(name: str, default: int) -> int:
    raw = os.environ.get(name, str(default)).strip()
    try:
        return int(raw)
    except ValueError:
        print(f"WARNING: {name}={raw!r} is not an int, using {default}", file=sys.stderr)
        return default


def _utc_now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _fmt_bytes(value: int) -> str:
    size = float(abs(value))
    for unit in ("B", "KB", "MB", "GB"):
        if size < 1024 or unit == "GB":
            return f"{size:.1f} {unit}"
        size /= 1024
    return f"{size:.1f} GB"


async def list_keys_with_mtime(backend) -> Dict[str, datetime]:
    """List every bucket key with its ``LastModified`` timestamp (UTC).

    Mirrors ``storage_inventory.py``'s ``_list_with_mtime``: paginates
    ``list_objects_v2`` directly so the object mtime is captured in the same
    listing pass (no per-object HEAD), via the backend's aioboto3 client. The
    backend's public ``scan_keys`` is page-bounded for admin calls, while the
    cleanup/migration scripts need the whole bucket. On any failure the map is
    empty — callers must treat "nothing known" as "delete nothing".
    """
    mtimes: Dict[str, datetime] = {}
    try:
        client = await backend._get_client()  # noqa: SLF001 - script-only reach-in
        paginator = client.get_paginator("list_objects_v2")
        async for page in paginator.paginate(Bucket=backend.bucket, Prefix=""):
            for obj in page.get("Contents", []):
                key = obj.get("Key")
                mtime = obj.get("LastModified")
                if key and mtime is not None:
                    mtimes[key] = mtime
    except Exception as e:  # noqa: BLE001
        print(
            f"WARNING: mtime-aware listing failed (no keys listed): {e}",
            file=sys.stderr,
        )
    return mtimes
