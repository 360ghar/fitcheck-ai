"""Shared vocabulary, minting, parsing and URL reduction for storage keys.

This module is the SINGLE owner of the object-storage key grammar. Two
namespace roots decide ownership, so the serving rules are pure:

- ``users/{user_id}/...`` — PRIVATE user content. The owner is ALWAYS segment
  1 (``user_id``); nothing else decides. Categories under a user:
  ``items|outfits|avatars|sources|feedback`` (durable, DB-referenced),
  ``tmp|generated`` (preview/staging, never DB-referenced) and ``export``.
- ``public/{group}/...`` — PUBLIC assets owned by nobody (banners, landing
  images, blog, static). Served without auth; ``group`` must be one of
  ``PUBLIC_GROUPS``.

The ``users/`` layout migration is complete: the bucket holds only
``users/``/``public/`` keys now. ``key_from_path`` still reduces legacy URLs
and keys (``{user_id}/{category}/...``, top-level/per-user ``tmp|generated``
previews, ``{user}/export/data.json``) that survive in DB columns by mapping
them through ``migrate_key_to_users_layout`` to their ``users/`` home, so
stale rows self-heal on read.

Layouts (all regexes are built from the constants below so they cannot drift):

- canonical:       ``users/{user}/items|outfits|avatars|sources|feedback/{hex}.{ext}``
- thumb:           ``users/{user}/{category}/{hex}_thumb.webp``  (always .webp)
- preview:         ``users/{user}/tmp|generated/{sub}/{hex}.{ext}``
- export:          ``users/{user}/export/data.json``
- public:          ``public/banners|landing|blog|static/{slug}/{hex}.{ext}``
                   ``{user}/{tmp|generated}/{sub}/...``, ``{user}/export/data.json``

``infra/images-worker/worker.js`` enforces an equivalent allowlist at the
edge; the two must stay in step (worker.test.mjs pins it).
"""

import re
import uuid
from typing import NamedTuple, Optional
from urllib.parse import urlparse

from app.core.config import settings

# Namespace roots. ``users/`` is private (owner = segment 1); ``public/`` is
# owned by nobody and served without auth.
USERS_FOLDER = "users"
PUBLIC_FOLDER = "public"
PUBLIC_GROUPS = frozenset({"banners", "landing", "blog", "static"})

# Canonical categories that can back a DB-referenced image row (and their
# ``_thumb.webp`` siblings). The same set backs storage_inventory / the worker
# allowlist / the backfill scripts. ``tmp``/``generated`` are never here: they
# are preview/staging namespaces that must never be DB-referenced.
CANONICAL_CATEGORIES = frozenset({"items", "outfits", "avatars", "sources", "feedback"})

# Preview folders. Staging lives under the user (``users/{user}/tmp/...``,
# ``users/{user}/generated/...``) so every preview of one user shares a
# prefix, and the whole user's previews are clearable together.
TEMP_FOLDER = "tmp"
GENERATED_FOLDER = "generated"
PREVIEW_FOLDERS = frozenset({TEMP_FOLDER, GENERATED_FOLDER})

# The data-export archive is a single deterministic key per user
# (``POST /users/export`` overwrites it): ``users/{user}/export/data.json``.
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

# A bare UUID, with or without dashes — the shape of every owner segment.
USER_ID_SEGMENT_RE = re.compile(
    r"^[0-9a-f]{32}$|^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)

_CATEGORY_ALT = "|".join(sorted(CANONICAL_CATEGORIES))
_FOLDER_ALT = "|".join(sorted(PREVIEW_FOLDERS))
_PUBLIC_GROUP_ALT = "|".join(sorted(PUBLIC_GROUPS))
_NAME = r"[0-9a-f]{32}"
_SLUG = r"[^/\\]+"

# --------------------------------------------------------------------------- #
# Current layout (post ``users/`` restructure)
# --------------------------------------------------------------------------- #
_USERS_KEY_RE = re.compile(
    rf"^{USERS_FOLDER}/(?P<user>[^/\\]+)/(?P<category>{_CATEGORY_ALT})/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
_USERS_THUMB_KEY_RE = re.compile(
    rf"^{USERS_FOLDER}/(?P<user>[^/\\]+)/(?P<category>{_CATEGORY_ALT})/"
    rf"(?P<name>{_NAME}){re.escape(THUMB_SUFFIX)}\.{THUMB_EXTENSION[1:]}$"
)
_USERS_NESTED_KEY_RE = re.compile(
    rf"^{USERS_FOLDER}/(?P<user>[^/\\]+?)/(?P<folder>{_FOLDER_ALT})/(?P<sub>[^/\\]+?)/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
_USERS_EXPORT_KEY_RE = re.compile(
    rf"^{USERS_FOLDER}/(?P<user>[^/\\]+)/{EXPORT_CATEGORY}/data\.json$"
)
_PUBLIC_KEY_RE = re.compile(
    rf"^{PUBLIC_FOLDER}/(?P<group>{_PUBLIC_GROUP_ALT})/(?P<slug>{_SLUG})/"
    rf"(?P<name>{_NAME})\.(?:{ALLOWED_IMAGE_EXTS})$"
)
_PUBLIC_THUMB_KEY_RE = re.compile(
    rf"^{PUBLIC_FOLDER}/(?P<group>{_PUBLIC_GROUP_ALT})/(?P<slug>{_SLUG})/"
    rf"(?P<name>{_NAME}){re.escape(THUMB_SUFFIX)}\.{THUMB_EXTENSION[1:]}$"
)


def mint_key(user_id: str, category: str, ext: str) -> str:
    """Mint a canonical ``users/{user_id}/{category}/{uuid4hex}.{ext}`` key.

    ``ext`` is derived from the sniffed content type (``EXTENSION_BY_MIME``);
    a leading ``.`` is normalized so callers may pass ``.png`` or ``png``.
    Raises ValueError for a category outside ``CANONICAL_CATEGORIES`` so a
    typo fails loudly instead of minting an unservable key.
    """
    if category not in CANONICAL_CATEGORIES:
        raise ValueError(f"not a canonical storage category: {category!r}")
    ext = ext if ext.startswith(".") else f".{ext}"
    return f"{USERS_FOLDER}/{user_id}/{category}/{uuid.uuid4().hex}{ext}"


def mint_preview_key(folder: str, user_id: str, sub: str, ext: str) -> str:
    """Mint a preview key ``users/{user_id}/{folder}/{sub}/{uuid4hex}.{ext}``.

    ``folder`` must be one of ``PREVIEW_FOLDERS`` (``tmp`` / ``generated``);
    ``sub`` is the source or image type (``social-import``, ``batch``,
    ``photoshoot``, ``upload``, ``outfit``, ``product``, ``try-on``, ...).
    Previews are staging only — they must never be DB-referenced.
    """
    if folder not in PREVIEW_FOLDERS:
        raise ValueError(f"not a preview folder: {folder!r}")
    ext = ext if ext.startswith(".") else f".{ext}"
    return f"{USERS_FOLDER}/{user_id}/{folder}/{sub}/{uuid.uuid4().hex}{ext}"


def mint_export_key(user_id: str) -> str:
    """Mint the deterministic per-user export key ``users/{user}/export/data.json``."""
    return f"{USERS_FOLDER}/{user_id}/{EXPORT_CATEGORY}/data.json"


def mint_public_key(group: str, slug: str, ext: str) -> str:
    """Mint a public asset key ``public/{group}/{slug}/{uuid4hex}.{ext}``.

    Public assets are owned by nobody and served without auth (banners,
    landing-page images, blog art, static assets). ``group`` must be one of
    ``PUBLIC_GROUPS``.
    """
    if group not in PUBLIC_GROUPS:
        raise ValueError(f"not a public asset group: {group!r}")
    ext = ext if ext.startswith(".") else f".{ext}"
    return f"{PUBLIC_FOLDER}/{group}/{slug}/{uuid.uuid4().hex}{ext}"


def thumb_key_for(storage_path: Optional[str]) -> Optional[str]:
    """Derive the thumbnail object key for a canonical ``storage_path``.

    Thumbnails are sibling objects named ``{stem}_thumb.webp`` (e.g.
    ``users/u/items/abc.jpg`` -> ``users/u/items/abc_thumb.webp``), so the read
    path can materialize a thumb URL from the durable ``storage_path`` with no
    schema change and no per-object lookup. The extension is ALWAYS ``.webp``
    because that is what is actually stored there — see THUMB_EXTENSION.

    Returns None for non-canonical keys (``tmp/``/``generated/`` previews,
    keys without an extension, ``_thumb`` keys themselves, public assets) —
    those images are served full-size. Both the current ``users/`` layout and
    the legacy per-user layout are recognized so pre-migration rows keep
    deriving thumbs during the transition.
    """
    if not storage_path:
        return None
    parts = storage_path.split("/")
    # users/{user}/{category}/... (current) or {user}/{category}/... (legacy).
    if len(parts) >= 3 and parts[0] == USERS_FOLDER:
        if parts[2] not in CANONICAL_CATEGORIES:
            return None
    elif len(parts) >= 2 and parts[1] in CANONICAL_CATEGORIES:
        pass  # legacy per-user canonical
    else:
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

    layout: str  # canonical | thumb | preview | export | public
    user: Optional[str] = None
    category: Optional[str] = None
    folder: Optional[str] = None
    sub: Optional[str] = None
    group: Optional[str] = None
    slug: Optional[str] = None
    name: Optional[str] = None
    ext: Optional[str] = None


def parse_key(key: Optional[str]) -> Optional[KeyRef]:
    """Parse a storage key into its structural parts, or None.

    Returns a ``KeyRef`` for canonical / thumb / preview / export / public /
    legacy keys. Bare keys only — reduce a URL with ``key_from_path`` first.
    Unknown or malformed keys return None (never a partial guess).
    """
    if not key:
        return None
    key = key.strip()
    if not key:
        return None

    def _build(m, layout, is_preview=False):
        d = m.groupdict()
        if layout == "export":
            return KeyRef(
                layout=layout, user=d["user"], category=EXPORT_CATEGORY,
                name="data.json", ext="json",
            )
        name = d["name"]
        ext = key.rpartition(".")[2]
        if is_preview:
            return KeyRef(
                layout=layout, user=d.get("user"), folder=d.get("folder"),
                sub=d["sub"], name=name, ext=ext,
            )
        if layout == "public":
            return KeyRef(
                layout=layout, group=d["group"], slug=d["slug"],
                name=name, ext=ext,
            )
        return KeyRef(
            layout=layout, user=d["user"], category=d.get("category"),
            name=name, ext=ext,
        )

    for m in (_USERS_EXPORT_KEY_RE.fullmatch(key),):
        if m:
            return _build(m, "export")
    for m in (
        _USERS_KEY_RE.fullmatch(key),
        _USERS_THUMB_KEY_RE.fullmatch(key),
        _PUBLIC_KEY_RE.fullmatch(key),
        _PUBLIC_THUMB_KEY_RE.fullmatch(key),
    ):
        if m:
            layout = "public" if m.re is _PUBLIC_KEY_RE or m.re is _PUBLIC_THUMB_KEY_RE else (
                "thumb" if m.re is _USERS_THUMB_KEY_RE else "canonical"
            )
            return _build(m, layout)
    for m in (
        _USERS_NESTED_KEY_RE.fullmatch(key),
    ):
        if m:
            return _build(m, "preview", is_preview=True)
    return None


def migrate_key_to_users_layout(key: Optional[str]) -> Optional[str]:
    """Map any legacy key shape to its ``users/`` home, or None.

    Mapping is POSITION-BASED on the recognized legacy structures (the name
    segment is not re-validated — a legacy key held in a DB row must resolve
    to the object even when its name predates the 32-hex convention):
    - ``{user}/{category}/...``        -> ``users/{user}/{category}/...``
    - ``{user}/{tmp|generated}/{sub}/...`` -> ``users/{user}/{folder}/{sub}/...``
    - ``{tmp|generated}/{user}/{sub}/...`` -> ``users/{user}/{folder}/{sub}/...``
    - ``{user}/export/data.json``      -> ``users/{user}/export/data.json``

    Already-current keys are returned unchanged:
    - ``users/...`` and ``public/...`` pass through.
    Anything unrecognized (external junk, two-segment keys) returns None —
    callers treat that as "not ours".

    This NEVER promotes a preview to a durable category — the re-key script's
    promotion step (staging-only invariant) is separate.
    """
    if not key:
        return None
    candidate = key.strip()
    if not candidate:
        return None
    parts = candidate.split("/")
    # Already-current layouts pass through.
    if parts[0] in (USERS_FOLDER, PUBLIC_FOLDER):
        return candidate
    # {user}/export/data.json (exactly 3 segments).
    if len(parts) == 3 and parts[2] == "data.json" and parts[1] == EXPORT_CATEGORY:
        return f"{USERS_FOLDER}/{parts[0]}/{parts[1]}/{parts[2]}"
    # {user}/{category}/... (durable) — category is one of ours.
    if len(parts) >= 3 and parts[1] in CANONICAL_CATEGORIES:
        return f"{USERS_FOLDER}/{parts[0]}/{parts[1]}/{'/'.join(parts[2:])}"
    # {user}/{tmp|generated}/{sub}/... or {tmp|generated}/{user}/{sub}/...
    # Both are structurally unambiguous as BARE keys (callers reduce URLs via
    # key_from_path first, which is where the UUID/bucket heuristics live), so
    # the user segment is not re-validated — DB rows may hold legacy user ids
    # that are not UUID-shaped.
    if len(parts) >= 4 and parts[0] in PREVIEW_FOLDERS:
        # top-level preview: tmp/{user}/sub/...
        return f"{USERS_FOLDER}/{parts[1]}/{parts[0]}/{parts[2]}/{'/'.join(parts[3:])}"
    if len(parts) >= 4 and parts[1] in PREVIEW_FOLDERS:
        # per-user preview: {user}/tmp/sub/...
        return f"{USERS_FOLDER}/{parts[0]}/{parts[1]}/{parts[2]}/{'/'.join(parts[3:])}"
    return None


def key_from_path(value: Optional[str]) -> Optional[str]:
    """Extract the bucket object key from a storage key or a served URL.

    Accepts a bare bucket key (``users/u/items/abc.png`` or a legacy
    ``u/items/abc.png``) or a URL that embeds one (a Supabase
    ``/storage/v1/object/public/<bucket>/<key>`` URL, an S3 presigned
    ``/<bucket>/<key>`` URL, or a worker-CDN ``/<key>`` path) and returns the
    key. Returns None for empty/None input.

    Used by the download helpers so they only ever fetch known bucket keys
    via the S3 backend (SSRF-safe): a caller-provided string is reduced to
    a key and then read from the bucket, never from the arbitrary URL.

    BUCKET NAMES ARE NOT ASSUMED TO BE CURRENT. Matching only the configured
    bucket name was a latent data-loss bug that a provider cutover activates:
    DB columns persist presigned URLs containing whatever bucket was live at
    upload time, so after repointing ``OBJECT_STORAGE_BUCKET`` at R2 an old
    Railway URL resolved to ``railway-bucket/{user}/avatars/x.png``. The real
    object then looks unreferenced, and ``storage_inventory.py --delete``
    would delete users' avatars as orphans. A leading segment that is neither
    a known namespace (``users``/``public``/``tmp``/``generated``) nor a user
    UUID is a path-style bucket name and is dropped whatever it is called.

    The ``users/`` layout migration is complete, so the result is ALWAYS
    mapped through ``migrate_key_to_users_layout``: a legacy URL or key still
    held in a DB column resolves to the object's ``users/`` home. Current
    ``users/``/``public/`` keys and unrecognized values pass through.
    """
    if not value:
        return None
    candidate = value.strip()
    if not candidate:
        return None
    result = candidate
    if candidate.startswith(("http://", "https://")):
        parsed = urlparse(candidate)
        parts = [part for part in parsed.path.split("/") if part]
        if len(parts) >= 5 and parts[:4] == ["storage", "v1", "object", "public"]:
            # Legacy Supabase public object URL:
            # /storage/v1/object/public/<bucket>/<key...> — pre-R2 rows
            # (item_images/support_tickets) still store this shape; the
            # bucket segment is dropped to recover the key.
            result = "/".join(parts[5:])
        elif len(parts) >= 2 and parts[0] == settings.OBJECT_STORAGE_BUCKET:
            result = "/".join(parts[1:])
        elif (
            len(parts) >= 4
            and parts[1] in PREVIEW_FOLDERS
            and USER_ID_SEGMENT_RE.fullmatch(parts[2])
        ):
            # Path-style URL from a bucket that is no longer the configured
            # one, with the owning user in the SECOND segment of a top-level
            # preview folder (``{bucket}/tmp|generated/{user}/...``).
            result = "/".join(parts[1:])
        elif len(parts) >= 2 and parts[0] in (USERS_FOLDER, PUBLIC_FOLDER):
            # Worker-mode CDN URL (IMAGE_SERVING_MODE=worker): the path IS the
            # key for current-layout keys.
            result = "/".join(parts)
        elif (
            len(parts) >= 3
            and parts[0] in PREVIEW_FOLDERS
            and USER_ID_SEGMENT_RE.fullmatch(parts[1])
        ):
            # Worker-mode CDN URL for a legacy top-level preview
            # (``tmp/{user}/...``) — the path is the key.
            result = "/".join(parts)
        elif (
            len(parts) >= 3
            and USER_ID_SEGMENT_RE.fullmatch(parts[0])
        ):
            # Worker-mode CDN URL for a legacy canonical key: a leading user
            # UUID means the path IS the key (no bucket segment to drop).
            result = "/".join(parts)
        elif (
            len(parts) >= 3
            and parts[0] not in PREVIEW_FOLDERS | {USERS_FOLDER, PUBLIC_FOLDER}
            and not USER_ID_SEGMENT_RE.fullmatch(parts[0])
        ):
            # Path-style URL from a bucket that is no longer the configured
            # one (a pre-cutover URL persisted in the DB). The bucket segment
            # is dropped when what follows still looks like one of our keys —
            # a user UUID (legacy canonical) or the users//public/ namespace
            # (current layout) — so an unrelated external URL is never
            # silently reshaped into a key.
            if parts[1] in (USERS_FOLDER, PUBLIC_FOLDER):
                result = "/".join(parts[1:])
            elif USER_ID_SEGMENT_RE.fullmatch(parts[1]):
                result = "/".join(parts[1:])
            else:
                return None
        else:
            return None
    # Post-migration: map legacy keys to their ``users/`` home so stale
    # storage URLs/paths in DB columns keep resolving. Current-layout keys and
    # unrecognized values pass through unchanged.
    return migrate_key_to_users_layout(result) or result


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
    """Validate a storage key and its user ownership.

    Ownership is a pure structural rule: every ``users/{user_id}/...`` key is
    owned by ``user_id`` (segment 1); ``public/...`` keys are owned by nobody
    (never True here). Preview
    keys are owned exactly like canonical keys (the owner is still segment 1).
    The export key is deliberately NOT user-owned for serving: it is fetched
    only through the authenticated presigned path, never the worker.

    Do not use a prefix-only check: encoded separators are decoded by the
    framework before this function, and ``../`` or a user-id prefix trick must
    never reach the presigner.

    ``infra/images-worker/worker.js`` enforces this same allowlist at the edge;
    the two must stay in step.
    """
    if not isinstance(storage_path, str) or not isinstance(user_id, str):
        return False
    if storage_path != storage_path.strip() or any(c in storage_path for c in "\\\r\n"):
        return False
    if ".." in storage_path:
        return False
    ref = parse_key(storage_path)
    if ref is None:
        return False
    if ref.layout in ("public", "export"):
        return False
    return ref.user == user_id


def is_preview_key(key: Optional[str]) -> bool:
    """True when ``key`` lives in a preview folder (any layout).

    Preview keys are ``users/{user}/{tmp|generated}/...`` (current) or the
    legacy per-user / top-level ``tmp|generated`` shapes; canonical keys are
    ``users/{user}/{category}/...`` where the category is never ``tmp`` /
    ``generated``. Used by the item-create normalize path and the
    preview-promotion repair script to decide whether a key needs promotion
    before it can back a DB row (previews are never DB-referenced).
    """
    ref = parse_key(key)
    return ref is not None and ref.layout == "preview"


def is_public_key(key: Optional[str]) -> bool:
    """True when ``key`` is a public (no-auth) asset under ``public/``."""
    ref = parse_key(key)
    return ref is not None and ref.layout == "public"


def normalize_preview_key(key: str) -> str:
    """Map a legacy per-user preview key to the top-level-folder layout.

    Legacy layout: ``{user_id}/{tmp|generated}/{sub}/...``
    Top-level:     ``{tmp|generated}/{user_id}/{sub}/...``

    This predates the ``users/`` restructure and is retained for the
    transition window (the completed ``tmp`` layout migration and its callers).
    New code should use ``migrate_key_to_users_layout``, which maps every
    legacy shape straight to its ``users/`` home.
    """
    parts = key.split("/", 3)
    if len(parts) >= 3 and parts[1] in PREVIEW_FOLDERS:
        head = f"{parts[1]}/{parts[0]}/{parts[2]}"
        return f"{head}/{parts[3]}" if len(parts) > 3 else head
    return key
