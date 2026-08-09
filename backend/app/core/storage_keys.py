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
from typing import Optional

# A bare UUID, with or without dashes — the shape of every key's first segment.
# Match with ``.fullmatch`` against a single segment (callers split the key first).
USER_ID_SEGMENT_RE = re.compile(
    r"^[0-9a-f]{32}$|^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)

# Canonical two-segment keys, ``{user}/{category}/{name}.{ext}``, where the
# category is one of the DB-referenced object kinds and the name is the UUID
# hex of the minted object.
_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?:items|outfits|avatars|sources|feedback)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
# Thumbnail siblings, ``{stem}_thumb.webp``. Always .webp whatever the parent's
# format — see ``StorageService.THUMB_EXTENSION``. Servable so this endpoint and
# the Worker (infra/images-worker, which allows the same set) agree on what a
# valid key is.
_THUMB_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+)/(?:items|outfits|avatars|sources|feedback)/"
    r"(?P<name>[0-9a-f]{32})_thumb\.webp$"
)
# Four-segment preview keys under the shared top-level folders,
# ``{tmp|generated}/{user}/{sub}/{name}.{ext}``, where the ``sub`` segment is:
#   tmp/{source}          - upload_temp_generated_image (social-import, batch,
#                           photoshoot review flows)
#   generated/{image_type}- image_generation_agent.save_generated_image, i.e. a
#                           try-on or outfit render the user asked to keep
# The top-level folder means every temp preview in the bucket shares ONE common
# prefix, so scripts/cleanup_temp_assets.py can list or clear the whole folder
# in a single pass.
_NESTED_KEY_RE = re.compile(
    r"^(?:tmp|generated)/(?P<user>[^/\\]+?)/(?P<sub>[^/\\]+?)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)
# Pre-migration preview keys, ``{user}/{tmp|generated}/{sub}/{name}.{ext}``.
# Accepted ONLY until scripts/migrate_temp_keys_layout.py has rewritten every
# old key (delete this regex and the Worker's copy once the migration is
# verified complete). Keeping it during the migration window means a stored
# storage_path minted before the deploy keeps serving instead of 404ing.
_LEGACY_NESTED_KEY_RE = re.compile(
    r"^(?P<user>[^/\\]+?)/(?:tmp|generated)/(?P<sub>[^/\\]+?)/"
    r"(?P<name>[0-9a-f]{32})\.(?:jpg|jpeg|png|webp|gif|avif)$"
)


def is_owned_storage_key(storage_path: str, user_id: str) -> bool:
    """Validate a canonical StorageService key and its user ownership.

    Do not use a prefix-only check: encoded separators are decoded by the
    framework before this function, and ``../`` or a user-id prefix trick must
    never reach the presigner. Valid keys are the canonical two-segment form,
    its ``_thumb.webp`` sibling, or the four-segment preview form under the
    top-level ``tmp/`` and ``generated/`` folders (plus the pre-migration
    ``{user}/{tmp|generated}/{type}`` form, see _LEGACY_NESTED_KEY_RE).

    ``infra/images-worker/worker.js`` enforces this same allowlist at the edge;
    the two must stay in step.

    Lives here rather than in ``app.api.v1.images`` because both the routes
    (to decide whether a stored key may be re-minted) and the services (to
    re-verify ownership of a key at deletion resolution time, A2-01) guard
    against the same rule, and ``app/core`` is the one layer both may import
    (ARCHITECTURE.md).
    """
    if not isinstance(storage_path, str) or not isinstance(user_id, str):
        return False
    if storage_path != storage_path.strip() or any(c in storage_path for c in "\\\r\n"):
        return False
    if ".." in storage_path:
        return False
    match = (
        _KEY_RE.fullmatch(storage_path)
        or _THUMB_KEY_RE.fullmatch(storage_path)
        or _NESTED_KEY_RE.fullmatch(storage_path)
        or _LEGACY_NESTED_KEY_RE.fullmatch(storage_path)
    )
    return bool(match and match.group("user") == user_id)

# Preview folders that moved to the shared top-level layout
# (``scripts/migrate_temp_keys_layout.py``): legacy keys nested them under the
# user id (``{user_id}/tmp/...``, ``{user_id}/generated/...``); the canonical
# layout is ``tmp/{user_id}/...`` / ``generated/{user_id}/...`` so every
# preview shares ONE common prefix (listable/clearable in a single pass).
_PREVIEW_FOLDER_SEGMENTS = frozenset({"tmp", "generated"})


def is_preview_key(key: Optional[str]) -> bool:
    """True when ``key`` lives in a preview folder (either layout).

    Preview keys are ``{tmp|generated}/{user}/{source}/...`` (current
    top-level layout) or ``{user}/{tmp|generated}/{source}/...`` (legacy
    per-user layout); canonical keys are ``{user}/{category}/...`` where the
    category is never ``tmp``/``generated``, so checking the first two
    segments is exact for both layouts. Used by the item-create normalize
    path and the preview-promotion repair script to decide whether a key
    needs promotion before it can back a DB row (previews are never
    DB-referenced and are cleaned up weekly).
    """
    if not key:
        return False
    parts = key.split("/", 2)
    return parts[0] in _PREVIEW_FOLDER_SEGMENTS or (
        len(parts) > 1 and parts[1] in _PREVIEW_FOLDER_SEGMENTS
    )


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
