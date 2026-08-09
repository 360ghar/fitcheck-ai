"""Shared vocabulary, minting, parsing and URL reduction for storage keys.

This module is the SINGLE owner of the object-storage key grammar. Storage keys
are minted as ``{user_id}/{category}/{uuid4hex}.{ext}``, so the first path
segment is always the owning user's id. Several layers need to decide "is this
first segment a user id?" — the routes (to know whether a stored
``avatar_url`` is one of our own objects and may be re-minted) and the services
(to recognise, and drop, a legacy path-style bucket segment without depending
on the bucket's current NAME).

That predicate lives here rather than in either caller because ``app/core`` is
the one layer both routes and services may import (ARCHITECTURE.md). It was
previously two hand-synced copies, one per layer, and the two guarded different
decisions against the same rule — if the key layout ever admits a non-UUID first
segment, a single updated copy means either avatars stop refreshing or the
storage-inventory sweep mis-classifies live objects as orphans and deletes them.
One copy makes that class of divergence impossible.

Everything that builds, validates, parses, or URL-reduces a key converges
here: the mint helpers (``mint_key`` / ``mint_preview_key`` / ``mint_export_key``),
the predicates (``is_owned_storage_key`` / ``is_preview_key`` /
``normalize_preview_key``), the structural parser (``parse_key``), the URL
reducer (``key_from_path``) and the object-URL composer (``build_object_url``).
``StorageService`` re-exports these so long-standing callers keep working, but
no key-shape logic lives outside this module.

``infra/images-worker/worker.js`` enforces an equivalent allowlist at the
edge; the two must stay in step (worker.test.mjs pins it).

Layouts (all regexes are built from the constants below so they cannot drift):

- canonical:      ``{user}/{items|outfits|avatars|sources|feedback}/{hex}.{ext}``
- thumb:          ``{user}/{category}/{hex}_thumb.webp``  (always .webp)
- preview:        ``{tmp|generated}/{user}/{sub}/{hex}.{ext}``  (top-level folders)
- legacy preview: ``{user}/{tmp|generated}/{sub}/{hex}.{ext}``  (pre-migration)
- export:         ``{user}/export/data.json``  (deterministic per-user archive)
"""

import re
import uuid
from typing import NamedTuple, Optional
from urllib.parse import urlparse

from app.core.config import settings

# Canonical categories that can back a DB-referenced image row (and their
# ``_thumb.webp`` siblings). The same set backs storage_inventory / the worker
# allowlist / the backfill scripts.
CANONICAL_CATEGORIES = frozenset({"items", "outfits", "avatars", "sources", "feedback"})

# Preview folders. Top-level layout shares ONE common prefix per folder so the
# whole folder can be listed / migrated / cleared in a single pass
# (scripts/cleanup_temp_assets.py, admin ops, provider lifecycle rules).
TEMP_FOLDER = "tmp"
GENERATED_FOLDER = "generated"
PREVIEW_FOLDERS = frozenset({TEMP_FOLDER, GENERATED_FOLDER})

# The data-export archive is a single deterministic key per user
# (``POST /users/export`` overwrites it): ``{user}/export/data.json``.
EXPORT_CATEGORY = "export"

# Thumbnail sibling objects are always WebP whatever the parent's format.
THUMB_SUFFIX = "_thumb"
THUMB_EXTENSION = ".webp"

# Extensions the ownership regexes accept. The set mirrors StorageService's
# EXTENSION_BY_MIME/ALLOWED_IMAGE_EXTENSIONS: HEIC/TIFF/BMP are accepted at
# upload and usually transcoded to WebP, but the best-effort transcode can
# fail and store the ORIGINAL bytes (storage_service._normalize_upload_bytes),
# minting a key with the non-web extension — the ownership check must not
# reject a key StorageService itself can mint.
ALLOWED_IMAGE_EXTS = "jpg|jpeg|png|webp|gif|avif|bmp|tif|tiff|heic|heif"

# A bare UUID, with or without dashes — the shape of every key's first segment.
# Match with ``.fullmatch`` against a single segment (callers split the key first).
USER_ID_SEGMENT_RE = re.compile(
    r"^[0-9a-f]{32}$|^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)

_CATEGORY_ALT = "|".join(sorted(CANONICAL_CATEGORIES))
_FOLDER_ALT = "|".join(sorted(PREVIEW_FOLDERS))
_NAME = r"[0-9a-f]{32}"

# Canonical two-segment keys, ``{user}/{category}/{name}.{ext}``, where the
# category is one of the DB-referenced object kinds and the name is the UUID
# hex of the minted object.
_KEY_RE = re.compile(
    rf"^(?P<user>[^/\\]+)/(?P<category>{_CATEGORY_ALT})/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
# Thumbnail siblings, ``{stem}_thumb.webp``. Always .webp whatever the parent's
# format — see THUMB_EXTENSION. Servable so this endpoint and the Worker
# (infra/images-worker, which allows the same set) agree on what a valid key is.
_THUMB_KEY_RE = re.compile(
    rf"^(?P<user>[^/\\]+)/(?P<category>{_CATEGORY_ALT})/"
    rf"(?P<name>{_NAME}){re.escape(THUMB_SUFFIX)}\.{THUMB_EXTENSION[1:]}$"
)
# Four-segment preview keys under the shared top-level folders,
# ``{folder}/{user}/{sub}/{name}.{ext}``, where the ``sub`` segment is:
#   tmp/{source}          - upload_temp_generated_image (social-import, batch,
#                           photoshoot review flows) and the staged upload
#                           (tmp/{user}/upload/...)
#   generated/{image_type}- image_generation_agent.save_generated_image, i.e. a
#                           try-on or outfit render the user asked to keep
# The top-level folder means every temp preview in the bucket shares ONE common
# prefix, so scripts/cleanup_temp_assets.py can list or clear the whole folder
# in a single pass.
_NESTED_KEY_RE = re.compile(
    rf"^(?P<folder>{_FOLDER_ALT})/(?P<user>[^/\\]+?)/(?P<sub>[^/\\]+?)/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
# Pre-migration preview keys, ``{user}/{folder}/{sub}/{name}.{ext}``.
# Accepted ONLY until scripts/migrate_temp_keys_layout.py has rewritten every
# old key (delete this regex and the Worker's copy once the migration is
# verified complete). Keeping it during the migration window means a stored
# storage_path minted before the deploy keeps serving instead of 404ing.
_LEGACY_NESTED_KEY_RE = re.compile(
    rf"^(?P<user>[^/\\]+?)/(?P<folder>{_FOLDER_ALT})/(?P<sub>[^/\\]+?)/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
# Deterministic per-user data export, ``{user}/export/data.json``.
_EXPORT_KEY_RE = re.compile(rf"^(?P<user>[^/\\]+)/{EXPORT_CATEGORY}/data\.json$")


def mint_key(user_id: str, category: str, ext: str) -> str:
    """Mint a canonical ``{user_id}/{category}/{uuid4hex}.{ext}`` key.

    ``ext`` is derived from the sniffed content type (``EXTENSION_BY_MIME``);
    a leading ``.`` is normalized so callers may pass ``.png`` or ``png``.
    Raises ValueError for a category outside ``CANONICAL_CATEGORIES`` so a
    typo fails loudly instead of minting an unservable key.
    """
    if category not in CANONICAL_CATEGORIES:
        raise ValueError(f"not a canonical storage category: {category!r}")
    ext = ext if ext.startswith(".") else f".{ext}"
    return f"{user_id}/{category}/{uuid.uuid4().hex}{ext}"


def mint_preview_key(folder: str, user_id: str, sub: str, ext: str) -> str:
    """Mint a preview key ``{folder}/{user_id}/{sub}/{uuid4hex}.{ext}``.

    ``folder`` must be one of ``PREVIEW_FOLDERS`` (``tmp`` / ``generated``);
    ``sub`` is the source or image type (``social-import``, ``batch``,
    ``photoshoot``, ``upload``, ``outfit``, ``product``, ``try-on``, ...).
    """
    if folder not in PREVIEW_FOLDERS:
        raise ValueError(f"not a preview folder: {folder!r}")
    ext = ext if ext.startswith(".") else f".{ext}"
    return f"{folder}/{user_id}/{sub}/{uuid.uuid4().hex}{ext}"


def mint_export_key(user_id: str) -> str:
    """Mint the deterministic per-user export key ``{user}/export/data.json``."""
    return f"{user_id}/{EXPORT_CATEGORY}/data.json"


def thumb_key_for(storage_path: Optional[str]) -> Optional[str]:
    """Derive the thumbnail object key for a canonical ``storage_path``.

    Thumbnails are sibling objects named ``{stem}_thumb.webp`` (e.g.
    ``u/items/abc.jpg`` -> ``u/items/abc_thumb.webp``), so the read path can
    materialize a thumb URL from the durable ``storage_path`` with no schema
    change and no per-object lookup. The extension is ALWAYS ``.webp``
    because that is what is actually stored there — see THUMB_EXTENSION.

    Returns None for non-canonical keys (``tmp/`` previews, keys without an
    extension, ``_thumb`` keys themselves) — those images are served
    full-size.
    """
    if not storage_path:
        return None
    parts = storage_path.split("/")
    if len(parts) < 2 or parts[1] not in CANONICAL_CATEGORIES:
        return None
    name = parts[-1]
    if not name or THUMB_SUFFIX in name:
        return None
    stem, dot, _ext = name.rpartition(".")
    if not dot:
        return None
    parts[-1] = f"{stem}{THUMB_SUFFIX}{THUMB_EXTENSION}"
    return "/".join(parts)


class KeyRef(NamedTuple):
    """Structural parse of a storage key (see ``parse_key``)."""

    layout: str  # canonical | thumb | preview | legacy_preview | export
    user: Optional[str] = None
    category: Optional[str] = None
    folder: Optional[str] = None
    sub: Optional[str] = None
    name: Optional[str] = None
    ext: Optional[str] = None


def parse_key(key: Optional[str]) -> Optional[KeyRef]:
    """Parse a storage key into its structural parts, or None.

    Returns a ``KeyRef`` for canonical / thumb / preview / legacy-preview /
    export keys. Bare keys only — reduce a URL with ``key_from_path`` first.
    Unknown or malformed keys return None (never a partial guess).
    """
    if not key:
        return None
    key = key.strip()
    if not key:
        return None
    m = _EXPORT_KEY_RE.fullmatch(key)
    if m:
        return KeyRef(
            layout="export", user=m.group("user"), category=EXPORT_CATEGORY,
            name="data.json", ext="json",
        )
    for regex, layout, is_preview in (
        (_KEY_RE, "canonical", False),
        (_THUMB_KEY_RE, "thumb", False),
        (_NESTED_KEY_RE, "preview", True),
        (_LEGACY_NESTED_KEY_RE, "legacy_preview", True),
    ):
        m = regex.fullmatch(key)
        if not m:
            continue
        d = m.groupdict()
        name = d["name"]
        ext = key.rpartition(".")[2]
        if is_preview:
            return KeyRef(
                layout=layout, user=d["user"], folder=d["folder"],
                sub=d["sub"], name=name, ext=ext,
            )
        return KeyRef(
            layout=layout, user=d["user"], category=d.get("category"),
            name=name, ext=ext,
        )
    return None


def key_from_path(value: Optional[str]) -> Optional[str]:
    """Extract the bucket object key from a storage key or a served URL.

    Accepts a bare bucket key (``user/items/abc.png``) or a URL that embeds
    one (a Supabase ``/storage/v1/object/public/<bucket>/<key>`` URL, or an
    S3 presigned ``/<bucket>/<key>`` URL) and returns the key. Returns None
    for empty/None input.

    Used by the download helpers so they only ever fetch known bucket keys
    via the S3 backend (SSRF-safe): a caller-provided string is reduced to
    a key and then read from the bucket, never from the arbitrary URL.

    BUCKET NAMES ARE NOT ASSUMED TO BE CURRENT. Matching only the configured
    bucket name was a latent data-loss bug that a provider cutover activates:
    DB columns persist presigned URLs containing whatever bucket was live at
    upload time, so after repointing ``OBJECT_STORAGE_BUCKET`` at R2 an old
    Railway URL resolved to ``railway-bucket/{user}/avatars/x.png``. The real
    object then looks unreferenced, and ``storage_inventory.py --delete``
    would delete users' avatars as orphans. Every key we mint either begins
    with a user UUID (canonical ``{user}/{category}/...``) or with a
    top-level ``tmp|generated`` folder whose SECOND segment is the user
    UUID (preview keys), so a leading segment that is neither is a
    path-style bucket name and is dropped whatever it is called.
    Worker-mode CDN URLs (``IMAGE_SERVING_MODE=worker``) carry no bucket
    segment: the path is the key, so a leading ``tmp|generated`` preview
    folder or user UUID is returned as-is (the preview folder is never
    dropped). A URL that reduces to none of our key shapes returns None —
    it is never reshaped into a garbage key.
    """
    if not value:
        return None
    candidate = value.strip()
    if not candidate:
        return None
    if candidate.startswith(("http://", "https://")):
        parsed = urlparse(candidate)
        parts = [part for part in parsed.path.split("/") if part]
        if len(parts) >= 5 and parts[:4] == ["storage", "v1", "object", "public"]:
            # Legacy Supabase public object URL:
            # /storage/v1/object/public/<bucket>/<key...> — pre-R2 rows
            # (item_images/support_tickets) still store this shape; the
            # bucket segment is dropped to recover the R2 key.
            return "/".join(parts[5:])
        if len(parts) >= 2 and parts[0] == settings.OBJECT_STORAGE_BUCKET:
            return "/".join(parts[1:])
        # Top-level preview folders (``tmp/`` and ``generated/`` — see
        # upload_temp_generated_image / save_generated_image) embed the
        # owning user in the SECOND segment, so a URL from a bucket that is
        # no longer the configured one has a non-UUID first segment (the
        # bucket name) followed by ``tmp|generated``, not a UUID. Same
        # only-drop-when-it-looks-like-ours rule: parts[2] must be
        # UUID-shaped.
        if (
            len(parts) >= 4
            and parts[1] in PREVIEW_FOLDERS
            and USER_ID_SEGMENT_RE.fullmatch(parts[2])
        ):
            return "/".join(parts[1:])
        # Worker-mode CDN URL (IMAGE_SERVING_MODE=worker): the CDN serves
        # keys directly at the path root with no bucket segment, so a
        # leading top-level preview folder (``tmp|generated``) whose
        # SECOND segment is the user UUID is PART of the key — return the
        # path as-is or the preview folder is lost (observed: worker CDN
        # ``tmp/{uuid}/batch/{hex}.webp`` URLs fell into the bucket-drop
        # branch below and came back as ``{uuid}/batch/{hex}.webp``).
        if (
            len(parts) >= 3
            and parts[0] in PREVIEW_FOLDERS
            and USER_ID_SEGMENT_RE.fullmatch(parts[1])
        ):
            return "/".join(parts)
        # Worker-mode CDN URL for a canonical key: a leading user UUID
        # means the path IS the key (no bucket segment to drop).
        if (
            len(parts) >= 3
            and USER_ID_SEGMENT_RE.fullmatch(parts[0])
        ):
            return "/".join(parts)
        # Path-style URL from a bucket that is no longer the configured one
        # (a pre-cutover URL persisted in the DB). Canonical keys begin with
        # a user UUID, so a leading segment that is neither a preview
        # folder nor a UUID is the bucket name. Only drop it when what
        # remains still looks like one of our keys, so an unrelated
        # external URL is never silently reshaped into a key.
        if (
            len(parts) >= 3
            and parts[0] not in PREVIEW_FOLDERS
            and not USER_ID_SEGMENT_RE.fullmatch(parts[0])
        ):
            if USER_ID_SEGMENT_RE.fullmatch(parts[1]):
                return "/".join(parts[1:])
        return None
    return candidate


def build_object_url(key: str) -> str:
    """Build the canonical S3 object URL for a key.

    NOTE: the app does NOT serve public URLs; the read path uses
    ``get_public_url`` (a short-lived presigned GET URL) instead. This
    helper exists for callers that need a stable object locator (e.g.
    inventory scripts) and for URL/key round-tripping.
    """
    base = settings.OBJECT_STORAGE_ENDPOINT.rstrip("/")
    return f"{base}/{settings.OBJECT_STORAGE_BUCKET}/{key.lstrip('/')}"


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
    return parts[0] in PREVIEW_FOLDERS or (
        len(parts) > 1 and parts[1] in PREVIEW_FOLDERS
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
    if len(parts) >= 3 and parts[1] in PREVIEW_FOLDERS:
        head = f"{parts[1]}/{parts[0]}/{parts[2]}"
        return f"{head}/{parts[3]}" if len(parts) > 3 else head
    return key
