"""Shared vocabulary for object-storage key shapes.

Storage keys are minted as ``{user_id}/{category}/{uuid4hex}.{ext}``, so the
first path segment is always the owning user's id. Several layers need to decide
"is this first segment a user id?" — the routes (to know whether a stored
``avatar_url`` is one of our own objects and may be re-minted) and the services
(to recognise, and drop, a legacy path-style bucket segment without depending on
the bucket's current NAME).

That predicate lives here rather than in either caller because ``app/core`` is
the one layer both routes and services may import (ARCHITECTURE.md). It was
previously two hand-synced copies, one per layer, and the two guarded different
decisions against the same rule — if the key layout ever admits a non-UUID first
segment, a single updated copy means either avatars stop refreshing or the
storage-inventory sweep mis-classifies live objects as orphans and deletes them.
One copy makes that class of divergence impossible.
"""

import re

# A bare UUID, with or without dashes — the shape of every key's first segment.
# Match with ``.fullmatch`` against a single segment (callers split the key first).
USER_ID_SEGMENT_RE = re.compile(
    r"^[0-9a-f]{32}$|^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)

# Preview folders that moved to the shared top-level layout
# (``scripts/migrate_temp_keys_layout.py``): legacy keys nested them under the
# user id (``{user_id}/tmp/...``, ``{user_id}/generated/...``); the canonical
# layout is ``tmp/{user_id}/...`` / ``generated/{user_id}/...`` so every
# preview shares ONE common prefix (listable/clearable in a single pass).
_PREVIEW_FOLDER_SEGMENTS = frozenset({"tmp", "generated"})


def normalize_preview_key(key: str) -> str:
    """Map a legacy per-user preview key to the top-level-folder layout.

    Legacy layout: ``{user_id}/{tmp|generated}/{sub}/...``
    Canonical:     ``{tmp|generated}/{user_id}/{sub}/...``

    Only keys whose SECOND segment is ``tmp`` or ``generated`` are rewritten
    (canonical ``{user_id}/{category}/...`` keys never have a preview folder
    in that position, so they pass through unchanged). Delete paths use this
    so a stale legacy path still held in a DB row resolves to the object that
    now lives under the shared top-level folder — after the migration script
    has moved the bytes, the old key no longer exists.
    """
    parts = key.split("/", 3)
    if len(parts) >= 3 and parts[1] in _PREVIEW_FOLDER_SEGMENTS:
        head = f"{parts[1]}/{parts[0]}/{parts[2]}"
        return f"{head}/{parts[3]}" if len(parts) > 3 else head
    return key
