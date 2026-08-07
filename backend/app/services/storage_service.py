"""
Storage service for managing file uploads to the S3-compatible object store
(Cloudflare R2 / Railway Bucket — the endpoint decides). Handles item images,
outfit images, user avatars, source photos, feedback attachments, and temporary
generated images.

The service keeps the same public method signatures and return shapes as the
Supabase Storage implementation so callers change as little as possible; the
internals talk to ``S3StorageBackend`` (see ``app/services/object_storage.py``).
Image URLs returned by uploads are SHORT-LIVED presigned GET URLs; every read
path re-materializes them (``images.serve_url``), and the DB stores the
``storage_path`` (bucket key) as the durable reference, never a URL.
"""

import asyncio
import base64
import os
import uuid
from typing import Iterable, Optional, List
from urllib.parse import urlparse

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    StorageServiceError,
    FileTooLargeError,
    UnsupportedMediaTypeError,
)
from app.utils.datetime_util import utcnow_iso
from app.utils.db import execute_with_reconnect
from app.utils.image_processing import (
    DEFAULT_MAX_EDGE,
    DEFAULT_QUALITY,
    EXTENSION_BY_MIME,
    SUPPORTED_UPLOAD_MIME_TYPES,
    downscale_image_bytes_to_base64,
    downscale_image_bytes_to_webp,
    sniff_image_mime,
    sniff_image_mime_from_magic,
    transcode_to_webp,
    validate_image_bytes,
)
from app.core.image_executor import run_image_op
from app.core.storage_keys import USER_ID_SEGMENT_RE, normalize_preview_key
from app.services.object_storage import (
    get_storage_backend,
    close_storage_backend,
)

logger = get_context_logger(__name__)


# Legacy bucket names (fallbacks). With the S3 backend the single configured
# bucket (OBJECT_STORAGE_BUCKET) is used for every upload; these are kept for
# backward compatibility with callers that still reference a bucket name.
BUCKET_ITEMS = "items"
BUCKET_OUTFITS = "outfits"
BUCKET_AVATARS = "avatars"
BUCKET_FEEDBACK = "feedback"

# Allowed file extensions
ALLOWED_IMAGE_EXTENSIONS = {
    '.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif',
    # Accepted but transcoded to WebP on the way in (browsers cannot render
    # HEIC/TIFF); see _TRANSCODE_TO_WEBP_MIMES and _normalize_upload_bytes.
    '.heic', '.heif', '.bmp', '.tif', '.tiff',
}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# MIME types that are accepted at upload but NEVER stored as-is: they decode in
# PIL but browsers cannot render HEIC/TIFF, so the canonical object is always
# re-encoded to a browser-safe WebP before the key/content-type are minted.
_TRANSCODE_TO_WEBP_MIMES = frozenset({
    "image/heif", "image/heic", "image/bmp", "image/tiff",
})

# Storage compression profile. Every stored image is downscaled to at most
# STORAGE_MAX_EDGE on its longest edge and re-encoded as WebP at
# STORAGE_QUALITY — unless that would make it BIGGER (keep-smaller; a small
# PNG/WebP passes through unchanged) or it is an animated GIF (Pillow would
# flatten it to a single frame). Sources are stored at full upload resolution
# today (items up to ~10MB), but nothing downstream consumes more than 2048px:
# AI references are capped at DEFAULT_MAX_EDGE=1568 before leaving the app and
# no phone/desktop screen renders beyond ~2048px. Measured bucket: 1.09GB with
# items at median 0.75MB / max 10.4MB; WebP q82 @ 2048px shrinks photos ~3-4x
# with no visible loss at display sizes. Alpha survives (WebP), so
# background-removed cutouts stay transparent.
STORAGE_MAX_EDGE = 2048
STORAGE_QUALITY = 82

# Browser/CDN cache lifetime stamped on every upload, in seconds. Encoded on
# the S3 object as `cache-control: max-age=<v>`.
DEFAULT_CACHE_CONTROL = "3600"

# Thumbnail variant sizing. List/grid surfaces render tiles at ~44-160px, so a
# 512px-longest-edge tile is ~10-20x smaller than the full-size original
# (avg object ~0.94 MB). This is the egress-per-fetch multiplier for every
# grid/list load (see docs/exec-plans/active/2026-08-05-railway-egress-rca.md).
THUMB_MAX_EDGE = 512
THUMB_QUALITY = 75

# Thumbnails are ALWAYS WebP, whatever the original's format.
#
# Two reasons, both load-bearing:
#  1. Alpha survives. Item images are routinely background-removed cutouts
#     (transparent WebP/PNG); a JPEG thumb flattens them onto white, so grid
#     tiles would show a white block behind every garment while the full-size
#     image the card opens is transparent.
#  2. The key is honest and predictable. The read path derives a thumb's key
#     from its parent's key with no per-object lookup, so the format must be
#     inferable from the key alone. One fixed format keeps the key extension,
#     the stored bytes and the Content-Type in agreement — previously the key
#     inherited the parent's extension (`abc_thumb.webp`) while the body was
#     JPEG.
THUMB_EXTENSION = ".webp"
THUMB_CONTENT_TYPE = "image/webp"

# Categories that get a thumbnail sibling object. Canonical durable images
# only: `tmp/` generated previews are short-lived review flows and stay
# full-size (they are deleted or promoted within their TTL), and `_thumb`
# keys themselves must never re-derive.
THUMB_CATEGORIES = frozenset({"items", "outfits", "avatars", "sources", "feedback"})


def _with_thumb_siblings(storage_paths: Iterable[str]) -> List[str]:
    """Return ``storage_paths`` in order, each followed by its ``_thumb`` sibling.

    Every path that leaves this service for a delete or a cleanup sweep must carry
    its derived thumbnail, or the `_thumb` object orphans in the bucket (thumbs are
    never DB-referenced, so nothing else will ever find it again). Shared by the
    batch-delete and account-deletion paths so the two cannot drift.

    Falsy paths are dropped and the result is deduped. Membership is tested against
    a set, not the output list: a heavy account carries thousands of paths and
    ``in list`` made this quadratic.
    """
    expanded: List[str] = []
    seen: set[str] = set()
    for path in storage_paths:
        if not path or path in seen:
            continue
        # Legacy per-user preview keys ({user_id}/tmp|generated/...) are
        # normalized to the shared top-level layout so deletes resolve the
        # object where it now lives (see app/core/storage_keys.py).
        path = normalize_preview_key(path)
        seen.add(path)
        expanded.append(path)
        thumb_key = StorageService.thumb_key_for(path)
        if thumb_key and thumb_key not in seen:
            seen.add(thumb_key)
            expanded.append(thumb_key)
    return expanded


async def close_download_client() -> None:
    """Release the S3 backend session (app shutdown; idempotent).

    Kept module-level for the app's shutdown hook (main.py) even though the
    pooled httpx download client is gone — downloads now go through the S3
    backend, which is closed here.
    """
    await close_storage_backend()


class StorageService:
    """Service for managing object-storage operations."""

    @staticmethod
    def _build_key(user_id: str, category: str, ext: str) -> str:
        """Build a storage key under the new folder layout (no timestamps).

        Layout: ``{user_id}/{category}/{uuid4hex}.{ext}``. ``ext`` is derived
        from the sniffed content type (``EXTENSION_BY_MIME``). The ``tmp``
        category is handled separately by ``upload_temp_generated_image`` (it
        carries a ``source`` sub-path).
        """
        ext = ext if ext.startswith(".") else f".{ext}"
        return f"{user_id}/{category}/{uuid.uuid4().hex}{ext}"

    @staticmethod
    def thumb_key_for(storage_path: str) -> Optional[str]:
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
        if len(parts) < 2 or parts[1] not in THUMB_CATEGORIES:
            return None
        name = parts[-1]
        if not name or "_thumb" in name:
            return None
        stem, dot, _ext = name.rpartition(".")
        if not dot:
            return None
        parts[-1] = f"{stem}_thumb{THUMB_EXTENSION}"
        return "/".join(parts)

    @staticmethod
    async def _upload_thumbnail(
        backend,
        storage_path: str,
        file_data: bytes,
    ) -> bool:
        """Create the ``_thumb`` sibling object for an uploaded image.

        Best-effort by contract: a thumbnail is a serving optimization, so a
        failure here must never fail the upload itself (the client already has
        its presigned URL). The variant object is ALWAYS written when the key
        is canonical so that, once ops has flipped ``THUMBNAILS_BACKFILLED``,
        the read path can emit ``thumbnail_url`` without per-object existence
        checks. CPU-bound Pillow work runs on the bounded image executor.
        Returns True when the thumb object was written.

        Always WebP, always ``image/webp`` (see THUMB_EXTENSION): transparency
        survives, and the key/bytes/Content-Type cannot disagree.

        A None return from the encoder means no thumbnail could be produced
        (undecodable bytes, or an encode failure), so NO object is written and
        the read path falls back to the full-size image. It deliberately does
        not fall back to storing ``file_data``: that would put the full-size
        object under the thumb key and serve full-size bytes to every grid tile
        — the exact cost this variant exists to avoid — and would put non-WebP
        bytes under a ``.webp`` key.

        Read-path fallback: while ``THUMBNAILS_BACKFILLED`` is off the read
        path mirrors ``image_url`` for every object, so this best-effort write
        failing has no visible effect. The residual gap is a post-backfill
        upload whose thumb encode fails here: the read path then emits a thumb
        URL for a missing object and the tile 404s — the frontend's
        ``thumbnail_url || image_url`` hook covers that case, so the gap is
        bounded and accepted (re-encoding on read is not worth the latency).
        """
        thumb_key = StorageService.thumb_key_for(storage_path)
        if not thumb_key:
            return False
        try:
            thumb = await run_image_op(
                downscale_image_bytes_to_webp, file_data, THUMB_MAX_EDGE, THUMB_QUALITY
            )
            if thumb is None:
                logger.warning(
                    "Could not encode thumbnail; serving full-size for this object",
                    storage_path=storage_path,
                    thumb_key=thumb_key,
                )
                return False
            await backend.upload(
                key=thumb_key,
                data=thumb,
                content_type=THUMB_CONTENT_TYPE,
                cache_control=DEFAULT_CACHE_CONTROL,
            )
            return True
        except Exception as e:
            logger.warning(
                "Failed to upload thumbnail",
                storage_path=storage_path,
                thumb_key=thumb_key,
                error=str(e),
            )
            return False

    @staticmethod
    def _sniff_content_type(file_data: bytes, filename: str = "") -> str:
        """Resolve the real content type of image bytes. Never raises.

        The bytes decide, not the filename: the batch web client names its
        upload `${tempId}.png` regardless of what the generator actually
        returned, and since `background_removal.py` landed that is frequently a
        WebP. The extension is only consulted when the bytes are unreadable.
        """
        return sniff_image_mime(file_data, filename)

    @staticmethod
    def _validate_image(file_data: bytes, filename: str) -> None:
        """Validate an image file.

        Args:
            file_data: Raw file bytes
            filename: Original filename

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
        """
        # Check file size
        if len(file_data) > MAX_FILE_SIZE:
            logger.warning(
                "File size exceeds limit",
                file_name=filename,
                file_size=len(file_data),
                max_size=MAX_FILE_SIZE,
            )
            raise FileTooLargeError(max_size_mb=MAX_FILE_SIZE // (1024 * 1024))

        # Check file extension
        ext = os.path.splitext(filename)[1].lower() or filename.strip().lower()
        if ext not in ALLOWED_IMAGE_EXTENSIONS:
            logger.warning(
                "Unsupported file type",
                file_name=filename,
                extension=ext,
                allowed_extensions=list(ALLOWED_IMAGE_EXTENSIONS),
            )
            raise UnsupportedMediaTypeError(
                allowed_types=list(ALLOWED_IMAGE_EXTENSIONS),
                message=f"Invalid file type '{ext}'. Allowed: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}"
            )

        # The extension and multipart content type are caller-controlled.
        # `validate_image_bytes` decodes and verifies the actual bytes with
        # Pillow, then requires a MIME type from the magic bytes (never the
        # filename), so spoofed payloads are rejected before reaching storage.
        try:
            validate_image_bytes(file_data, max_bytes=MAX_FILE_SIZE)
        except ValueError as error:
            logger.warning(
                "Uploaded bytes are not a valid image",
                file_name=filename,
                error=str(error),
            )
            raise UnsupportedMediaTypeError(
                allowed_types=sorted(SUPPORTED_UPLOAD_MIME_TYPES),
                message="File contents are not a valid supported image",
            ) from error

    @staticmethod
    def _normalize_upload_bytes(file_data: bytes) -> bytes:
        """Normalize accepted upload bytes to the storage compression profile.

        Runs after ``_validate_image`` and before ``_sniff_content_type``, so the
        sniff then resolves the (possibly new WebP) bytes to ``image/webp`` and
        the key/content-type are minted as ``.webp`` / ``image/webp``.

        Two steps, every stored image goes through both:
          1. HEIC/HEIF, BMP and TIFF are accepted at the boundary but browsers
             cannot render them, so they are transcoded to browser-safe WebP.
          2. Storage compression: downscale to ``STORAGE_MAX_EDGE`` (2048px)
             and re-encode as WebP at ``STORAGE_QUALITY`` (82). Web-native
             formats (JPEG/PNG/WebP/AVIF) are NOT passed through anymore — a
             10MB phone photo is stored as a ~200-400KB WebP with no visible
             loss at display sizes. Keep-smaller: when the WebP output is not
             smaller than the input, the original bytes are kept (a small PNG
             logo or an already-compressed WebP is not inflated). Animated
             GIFs pass through untouched (Pillow would flatten them to a
             single frame). Alpha survives (WebP), so background-removed
             cutouts stay transparent.

        Sync by design; callers run it on the bounded image executor
        (``run_image_op``) alongside ``_validate_image``. Best-effort: on any
        failure the input is returned unchanged rather than dropping the
        upload (the prior ``validate_image_bytes`` already ran
        ``Image.verify()`` on these bytes, so a real photo that verifies also
        re-encodes — failures need verify() to pass yet a full decode+reencode
        to fail).
        """
        mime = sniff_image_mime_from_magic(file_data[:32])
        if mime in _TRANSCODE_TO_WEBP_MIMES:
            webp = transcode_to_webp(file_data)
            if webp is not None:
                file_data = webp
            else:
                logger.warning(
                    "Accepted non-web-native image failed to transcode to WebP; "
                    "storing original bytes (may not render in all browsers)",
                    mime=mime,
                )
                return file_data
        if mime != "image/gif":
            webp = downscale_image_bytes_to_webp(
                file_data,
                max_edge=STORAGE_MAX_EDGE,
                quality=STORAGE_QUALITY,
            )
            if webp is not None and len(webp) < len(file_data):
                file_data = webp
        return file_data

    @staticmethod
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
                # Supabase public object URL: /storage/v1/object/public/<bucket>/<key...>
                return "/".join(parts[5:])
            if len(parts) >= 2 and parts[0] == settings.SUPABASE_STORAGE_BUCKET:
                return "/".join(parts[1:])
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
                and parts[1] in ("tmp", "generated")
                and USER_ID_SEGMENT_RE.fullmatch(parts[2])
            ):
                return "/".join(parts[1:])
            # Path-style URL from a bucket that is no longer the configured one
            # (a pre-cutover URL persisted in the DB). Canonical keys begin with
            # a user UUID, so a non-UUID leading segment is the bucket name.
            # Only drop it when what remains still looks like one of our keys, so
            # an unrelated external URL is never silently reshaped into a key.
            if len(parts) >= 3 and not USER_ID_SEGMENT_RE.fullmatch(parts[0]):
                if USER_ID_SEGMENT_RE.fullmatch(parts[1]):
                    return "/".join(parts[1:])
            return "/".join(parts)
        return candidate

    @staticmethod
    def build_object_url(key: str) -> str:
        """Build the canonical S3 object URL for a key.

        NOTE: the app does NOT serve public URLs; the read path uses
        ``get_public_url`` (a short-lived presigned GET URL) instead. This
        helper exists for callers that need a stable object locator (e.g.
        inventory scripts) and for URL/key round-tripping.
        """
        base = settings.OBJECT_STORAGE_ENDPOINT.rstrip("/")
        return f"{base}/{settings.OBJECT_STORAGE_BUCKET}/{key.lstrip('/')}"

    @staticmethod
    async def upload_item_image(
        db,
        user_id: str,
        filename: str,
        file_data: bytes,
        is_primary: bool = False
    ) -> dict:
        """Upload an item image to the object store.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            user_id: User ID who owns the item
            filename: Original filename
            file_data: Raw file bytes
            is_primary: Whether this is the primary image

        Returns:
            Dict with image_url (presigned GET), thumbnail_url, storage_path,
            and metadata

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure). Pillow decode is CPU-bound
        # (up to ~7MB per image); never block the event loop during request
        # handling. Runs on the bounded image executor.
        await run_image_op(StorageService._validate_image, file_data, filename)

        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )

        content_type = StorageService._sniff_content_type(file_data, filename)
        ext = EXTENSION_BY_MIME.get(content_type, os.path.splitext(filename)[1].lower() or ".jpg")
        storage_path = StorageService._build_key(user_id, "items", ext)

        try:
            backend = get_storage_backend()
            await backend.upload(
                key=storage_path,
                data=file_data,
                content_type=content_type,
                cache_control=DEFAULT_CACHE_CONTROL,
            )
            # Thumbnail sibling (best-effort; never fails the upload).
            await StorageService._upload_thumbnail(backend, storage_path, file_data)
            image_url = await StorageService.get_public_url(storage_path)
            thumbnail_url = image_url

            logger.info(
                "Uploaded item image",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
                is_primary=is_primary,
            )

            return {
                "image_url": image_url,
                "thumbnail_url": thumbnail_url,
                "storage_path": storage_path,
                "is_primary": is_primary,
                "width": None,  # Would be populated by image processing
                "height": None
            }

        except Exception as e:
            logger.error(
                "Failed to upload item image",
                user_id=user_id,
                file_name=filename,
                file_size=len(file_data),
                error=str(e),
            )
            raise StorageServiceError(f"Failed to upload image: {str(e)}")

    @staticmethod
    async def upload_outfit_image(
        db,
        user_id: str,
        filename: str,
        file_data: bytes,
        generation_type: str = "ai"
    ) -> dict:
        """Upload an outfit image (AI-generated or manual).

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            user_id: User ID who owns the outfit
            filename: Original filename
            file_data: Raw file bytes
            generation_type: 'ai' or 'manual'

        Returns:
            Dict with image_url (presigned GET), thumbnail_url, storage_path,
            and metadata

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure). Pillow decode is CPU-bound
        # (up to ~7MB per image); never block the event loop during request
        # handling. Runs on the bounded image executor.
        await run_image_op(StorageService._validate_image, file_data, filename)

        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )

        content_type = StorageService._sniff_content_type(file_data, filename)
        ext = EXTENSION_BY_MIME.get(content_type, os.path.splitext(filename)[1].lower() or ".jpg")
        storage_path = StorageService._build_key(user_id, "outfits", ext)

        try:
            backend = get_storage_backend()
            await backend.upload(
                key=storage_path,
                data=file_data,
                content_type=content_type,
                cache_control=DEFAULT_CACHE_CONTROL,
            )
            # Thumbnail sibling (best-effort; never fails the upload).
            await StorageService._upload_thumbnail(backend, storage_path, file_data)
            image_url = await StorageService.get_public_url(storage_path)

            logger.info(
                "Uploaded outfit image",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
                generation_type=generation_type,
            )

            return {
                "image_url": image_url,
                "thumbnail_url": image_url,
                "storage_path": storage_path,
                "generation_type": generation_type,
                "is_primary": True,
                "width": None,
                "height": None,
                "metadata": {
                    "uploaded_at": utcnow_iso()
                }
            }

        except Exception as e:
            logger.error(
                "Failed to upload outfit image",
                user_id=user_id,
                file_name=filename,
                file_size=len(file_data),
                generation_type=generation_type,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to upload outfit image: {str(e)}")

    @staticmethod
    async def upload_avatar(
        db,
        user_id: str,
        filename: str,
        file_data: bytes
    ) -> str:
        """Upload a user avatar image.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            user_id: User ID
            filename: Original filename
            file_data: Raw file bytes

        Returns:
            Presigned GET URL of the uploaded avatar

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure). Pillow decode is CPU-bound
        # (up to ~7MB per image); never block the event loop during request
        # handling. Runs on the bounded image executor.
        await run_image_op(StorageService._validate_image, file_data, filename)

        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )

        content_type = StorageService._sniff_content_type(file_data, filename)
        ext = EXTENSION_BY_MIME.get(content_type, os.path.splitext(filename)[1].lower() or ".jpg")
        storage_path = StorageService._build_key(user_id, "avatars", ext)

        try:
            backend = get_storage_backend()
            await backend.upload(
                key=storage_path,
                data=file_data,
                content_type=content_type,
                cache_control=DEFAULT_CACHE_CONTROL,
            )
            # Thumbnail sibling (best-effort; never fails the upload).
            await StorageService._upload_thumbnail(backend, storage_path, file_data)

            logger.info(
                "Uploaded avatar",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
            )

            return await StorageService.get_public_url(storage_path)

        except Exception as e:
            logger.error(
                "Failed to upload avatar",
                user_id=user_id,
                file_name=filename,
                file_size=len(file_data),
                error=str(e),
            )
            raise StorageServiceError(f"Failed to upload avatar: {str(e)}")

    @staticmethod
    async def delete_image(
        db,
        storage_path: str,
        bucket: Optional[str] = None
    ) -> bool:
        """Delete an image from the object store.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            storage_path: Path (bucket key) within the bucket
            bucket: Bucket name (unused with S3; kept for signature compatibility)

        Returns:
            True if deleted successfully

        Raises:
            StorageServiceError: If deletion fails
        """
        try:
            backend = get_storage_backend()
            # Legacy per-user preview keys are normalized to the shared
            # top-level layout so the delete resolves the object where it now
            # lives (see app/core/storage_keys.py).
            storage_path = normalize_preview_key(storage_path)
            # Deliberately NOT delete_many: that call is best-effort (it logs
            # per-key errors instead of raising), so batching these two would
            # downgrade a failed PRIMARY delete from an exception to a warning.
            # Callers rely on this raising. The thumb stays best-effort.
            await backend.delete(storage_path)
            thumb_key = StorageService.thumb_key_for(storage_path)
            if thumb_key:
                try:
                    await backend.delete(thumb_key)
                except Exception as e:
                    logger.warning(
                        "Failed to delete thumbnail",
                        thumb_key=thumb_key,
                        error=str(e),
                    )
            logger.info(
                "Deleted image",
                storage_path=storage_path,
                bucket=bucket,
            )
            return True

        except Exception as e:
            logger.error(
                "Failed to delete image",
                storage_path=storage_path,
                bucket=bucket,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to delete image: {str(e)}")

    @staticmethod
    async def delete_multiple_images(
        db,
        storage_paths: List[str],
        bucket: Optional[str] = None
    ) -> int:
        """Delete multiple images from the object store.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            storage_paths: List of paths (bucket keys) to delete
            bucket: Bucket name (unused with S3; kept for signature compatibility)

        Returns:
            Number of successfully deleted images

        Raises:
            StorageServiceError: If deletion fails
        """
        if not storage_paths:
            return 0

        expanded = _with_thumb_siblings(storage_paths)

        try:
            backend = get_storage_backend()
            return await backend.delete_many(expanded)

        except Exception as e:
            logger.error(
                "Failed to delete multiple images",
                count=len(storage_paths),
                bucket=bucket,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to delete images: {str(e)}")

    @staticmethod
    async def resolve_owned_storage_paths(
        db,
        user_id: str,
        *,
        item_ids: Optional[List[str]] = None,
        outfit_ids: Optional[List[str]] = None,
    ) -> dict:
        """Resolve a user's owned parent rows and their child image storage paths.

        The backend uses a service-role client (RLS bypassed), so child image
        rows cannot be authorized by image id alone: owned parent ids are
        resolved under ``user_id`` first, then child ``storage_path`` rows are
        collected under those ids. Pass ``item_ids``/``outfit_ids`` to scope to
        a subset (batch deletes); omit them to include everything a user owns
        (account deletion).

        Returns ``{"item_ids": [...], "outfit_ids": [...], "storage_paths": [...]}``.
        ``storage_paths`` includes the derived ``_thumb`` siblings so account
        deletion never orphans a thumbnail object.
        Callers own the deletion and its error policy (best-effort for batch
        deletes, fail-loudly for account deletion). DB query behavior is
        unchanged (used by account deletion).
        """
        owned_item_ids: List[str] = []
        owned_outfit_ids: List[str] = []
        storage_paths: List[str] = []

        # Sentinel DBs used by tests/direct callers have no query surface;
        # skip resolution entirely rather than failing on an invalid client.
        can_query_rows = hasattr(db.table("items"), "select")

        scopes = (
            ("items", "item_images", "item_id", item_ids),
            ("outfits", "outfit_images", "outfit_id", outfit_ids),
        )
        # The two parent queries are independent; run them concurrently.
        # Both queries are built INSIDE the wrapped callable so a reconnect
        # retry rebuilds them against the fresh client (a query bound to the
        # dead client cannot be replayed). Reads only - retry is safe.
        parent_scopes = [
            (parent_table, scoped_ids)
            for parent_table, _child_table, _fk_column, scoped_ids in scopes
            if (scoped_ids is None or scoped_ids) and can_query_rows
        ]

        def _run_parent_query(d, parent_table, scoped_ids):
            # Source photos are stored once per photo and referenced from the
            # parent `items` row (not a child image table), so they must be
            # collected from the parent query itself.
            select_cols = "id,source_image_storage_path" if parent_table == "items" else "id"
            query = d.table(parent_table).select(select_cols).eq("user_id", user_id)
            if scoped_ids is not None:
                query = query.in_("id", scoped_ids)
            return query.execute()

        parent_results = await asyncio.gather(
            *(
                execute_with_reconnect(
                    lambda d, _t=parent_table, _s=scoped_ids: _run_parent_query(d, _t, _s),
                    db,
                    extra={"operation": f"resolve_owned_storage_paths.{parent_table}", "user_id": user_id},
                )
                for parent_table, scoped_ids in parent_scopes
            )
        ) if parent_scopes else []

        for (parent_table, _scoped_ids), parent_rows in zip(parent_scopes, parent_results):
            rows = getattr(parent_rows, "data", None) or []
            owned_ids = [
                str(row.get("id"))
                for row in rows
                if row.get("id")
            ]
            if parent_table == "items":
                owned_item_ids.extend(owned_ids)
                child_table, fk_column = "item_images", "item_id"
                # The item's source photo (the original upload it was
                # extracted from) lives in Storage, not in item_images.
                storage_paths.extend(
                    str(row["source_image_storage_path"])
                    for row in rows
                    if row.get("source_image_storage_path")
                )
            else:
                owned_outfit_ids.extend(owned_ids)
                child_table, fk_column = "outfit_images", "outfit_id"
            if not owned_ids:
                continue
            # Chunk the IN clause so account deletion (a user's entire
            # wardrobe) never exceeds PostgREST URL length limits. Built
            # inside the wrapped callable so a reconnect retry rebuilds it
            # against the fresh client (read-only, safe to retry). The chunks
            # are independent reads; run them concurrently instead of
            # serializing every 500-row batch.
            chunk_queries = []
            for start in range(0, len(owned_ids), 500):
                chunk = owned_ids[start:start + 500]
                chunk_queries.append(
                    execute_with_reconnect(
                        lambda d, _t=child_table, _f=fk_column, _c=chunk: (
                            d.table(_t).select("storage_path").in_(_f, _c).execute()
                        ),
                        db,
                        extra={"operation": f"resolve_owned_storage_paths.{child_table}", "user_id": user_id},
                    )
                )
            for child_rows in await asyncio.gather(*chunk_queries):
                storage_paths.extend(
                    str(row["storage_path"])
                    for row in (getattr(child_rows, "data", None) or [])
                    if row.get("storage_path")
                )

        return {
            "item_ids": owned_item_ids,
            "outfit_ids": owned_outfit_ids,
            # Include the derived thumbnail siblings so account deletion cleans
            # them too.
            "storage_paths": _with_thumb_siblings(storage_paths),
        }

    @staticmethod
    async def get_public_url(storage_path: str, bucket: Optional[str] = None) -> str:
        """Return a short-lived presigned GET URL for a stored object.

        The DB stores ``storage_path`` (bucket key); URLs are materialized at
        read time so they are never persisted and never expire server-side.
        ``bucket`` is kept for signature compatibility (the S3 backend uses the
        single configured bucket).
        """
        backend = get_storage_backend()
        return await backend.presign_get(
            storage_path, expires=settings.OBJECT_STORAGE_PRESIGN_TTL
        )

    @staticmethod
    async def move_image(
        db,
        old_path: str,
        new_path: str,
        bucket: Optional[str] = None
    ) -> bool:
        """Move an image within the bucket (server-side copy via S3).

        Unlike Supabase (which had no server-side move), this uses an S3
        server-side ``copy`` followed by a ``delete`` — no bytes are
        downloaded/re-uploaded, so the stored content type is preserved.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            old_path: Current path (bucket key)
            new_path: New path (bucket key)
            bucket: Bucket name (unused with S3; kept for signature compatibility)

        Returns:
            True if moved successfully

        Raises:
            StorageServiceError: If move fails
        """
        try:
            backend = get_storage_backend()
            await backend.copy(old_path, new_path)
            await backend.delete(old_path)

            logger.info(
                "Moved image",
                old_path=old_path,
                new_path=new_path,
                bucket=bucket,
            )
            return True

        except Exception as e:
            logger.error(
                "Failed to move image",
                old_path=old_path,
                new_path=new_path,
                bucket=bucket,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to move image: {str(e)}")

    @staticmethod
    async def upload_feedback_attachment(
        db,
        user_id: str,
        filename: str,
        file_data: bytes,
    ) -> dict:
        """Upload a feedback attachment to the object store.

        Args:
            db: Supabase client (kept for signature compatibility; unused by S3)
            user_id: User ID or 'anonymous'
            filename: Original filename
            file_data: Raw file bytes

        Returns:
            Dict with image_url (presigned GET) and storage_path

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure). Pillow decode is CPU-bound
        # (up to ~7MB per image); never block the event loop during request
        # handling. Runs on the bounded image executor.
        await run_image_op(StorageService._validate_image, file_data, filename)

        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )

        content_type = StorageService._sniff_content_type(file_data, filename)
        ext = EXTENSION_BY_MIME.get(content_type, os.path.splitext(filename)[1].lower() or ".jpg")
        storage_path = StorageService._build_key(user_id, "feedback", ext)

        try:
            backend = get_storage_backend()
            await backend.upload(
                key=storage_path,
                data=file_data,
                content_type=content_type,
                cache_control=DEFAULT_CACHE_CONTROL,
            )
            # Thumbnail sibling (best-effort; never fails the upload).
            await StorageService._upload_thumbnail(backend, storage_path, file_data)
            image_url = await StorageService.get_public_url(storage_path)

            logger.info(
                "Uploaded feedback attachment",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
            )

            return {
                "image_url": image_url,
                "storage_path": storage_path,
            }

        except Exception as e:
            logger.error(
                "Failed to upload feedback attachment",
                user_id=user_id,
                file_name=filename,
                file_size=len(file_data),
                error=str(e),
            )
            raise StorageServiceError(f"Failed to upload attachment: {str(e)}")

    @staticmethod
    async def upload_file(
        db,
        file_data: bytes,
        file_path: str,
        content_type: str = "application/octet-stream",
        bucket: Optional[str] = None,
        upsert: bool = True,
        cache_control: Optional[str] = None,
    ) -> dict:
        """Upload raw bytes to the S3 bucket with an explicit destination path.

        ``cache_control`` is seconds as a string; encoded on the object as
        ``cache-control: max-age=<v>``. Defaults to DEFAULT_CACHE_CONTROL. Pass
        a short value (e.g. "60") when overwriting an existing key so a CDN
        cannot keep serving the old bytes for an hour.

        ``upsert`` is accepted for signature compatibility (S3 PUT is naturally
        idempotent — a retry after a committed-but-lost response overwrites the
        same path instead of erroring on a now-existing key).

        Returns ``{"public_url": <presigned GET URL>, "storage_path": <key>,
        "bucket": <bucket>}``.
        """
        try:
            backend = get_storage_backend()
            await backend.upload(
                key=file_path,
                data=file_data,
                content_type=content_type,
                cache_control=cache_control or DEFAULT_CACHE_CONTROL,
            )
            # Create the thumbnail sibling for canonical image categories
            # (items/outfits/avatars/sources/feedback). Skipped internally for
            # tmp/generated/export paths (thumb_key_for returns None) and
            # never fails the upload (best-effort by contract).
            await StorageService._upload_thumbnail(backend, file_path, file_data)
            public_url = await StorageService.get_public_url(file_path)
            return {
                "public_url": public_url,
                "storage_path": file_path,
                "bucket": bucket or settings.OBJECT_STORAGE_BUCKET,
            }
        except Exception as e:
            logger.error(
                "Failed to upload file",
                storage_path=file_path,
                bucket=bucket,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to upload file: {str(e)}")

    @staticmethod
    async def upload_temp_generated_image(
        db,
        user_id: str,
        file_data: bytes,
        source: str = "social-import",
        extension: str = ".png",
    ) -> dict:
        """Upload temporary AI-generated image for review workflows.

        Temp images live under the shared top-level ``tmp/`` folder
        (``tmp/{user_id}/{source}/...``) so every temp preview in the bucket
        shares ONE common prefix: the whole folder can be listed, migrated or
        cleared in a single pass (``scripts/cleanup_temp_assets.py``, admin ops,
        provider lifecycle rules) instead of one folder per user. `extension`
        is only a hint: the real format is sniffed from the bytes, because
        generated images are no longer always PNG (matted product shots come
        back as WebP) and a mislabelled object is served with the wrong content
        type for as long as it lives.
        """
        ext = extension if extension.startswith(".") else f".{extension}"
        # Pillow decode is CPU-bound (up to ~7MB per image); never block the
        # event loop during request handling. Runs on the bounded image
        # executor (see app/core/image_executor.py).
        await run_image_op(StorageService._validate_image, file_data, ext)
        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )
        content_type = StorageService._sniff_content_type(file_data, ext)
        ext = EXTENSION_BY_MIME.get(content_type, ext)
        temp_name = f"tmp/{user_id}/{source}/{uuid.uuid4().hex}{ext}"
        upload = await StorageService.upload_file(
            db=db,
            file_data=file_data,
            file_path=temp_name,
            content_type=content_type,
        )
        return {
            "image_url": upload["public_url"],
            "thumbnail_url": upload["public_url"],
            "storage_path": upload["storage_path"],
        }

    @staticmethod
    async def upload_source_image(
        db,
        user_id: str,
        file_data: bytes,
        extension: str = ".jpg",
    ) -> dict:
        """Upload the ORIGINAL source photo an item was extracted from.

        Stored once per source photo (the caller dedupes multi-item photos).
        URL is attached to every item extracted from that photo so the image
        generation pipeline can re-fetch it as a reference image without
        pinning source bytes in process memory.

        Returns {image_url, storage_path} under {user_id}/sources/.
        """
        ext = extension if extension.startswith(".") else f".{extension}"
        # Pillow decode is CPU-bound (up to ~7MB per image); never block the
        # event loop during request handling. Runs on the bounded image
        # executor (see app/core/image_executor.py).
        await run_image_op(StorageService._validate_image, file_data, ext)
        # Normalize to the storage compression profile (WebP q82 @ 2048px,
        # keep-smaller) before the storage key/content-type are minted.
        file_data = await run_image_op(
            StorageService._normalize_upload_bytes, file_data
        )
        # Sniffed from the bytes, with the caller's extension only as a fallback.
        content_type = StorageService._sniff_content_type(file_data, ext)
        ext = EXTENSION_BY_MIME.get(content_type, ext)
        path = StorageService._build_key(user_id, "sources", ext)
        upload = await StorageService.upload_file(
            db=db,
            file_data=file_data,
            file_path=path,
            content_type=content_type,
        )
        return {
            "image_url": upload["public_url"],
            "storage_path": upload["storage_path"],
        }

    @staticmethod
    async def _download_bytes(
        url: str, timeout: float = 10.0, purpose: str = "storage image"
    ) -> Optional[bytes]:
        """Download a stored object to raw bytes via the S3 backend. None on failure.

        The input is reduced to a bucket key via ``key_from_path`` and fetched
        from the bucket — never from an arbitrary URL (SSRF-safe: only known
        bucket keys are ever read). ``timeout`` is accepted for signature
        compatibility; the S3 client has its own connect/read timeouts.
        """
        if not url:
            return None
        key = StorageService.key_from_path(url)
        if not key:
            return None
        try:
            backend = get_storage_backend()
            content = await backend.download(key)
            if not content or len(content) > MAX_FILE_SIZE:
                return None
            return content
        except Exception as e:
            logger.warning(
                f"Failed to download {purpose}",
                url=str(url)[:120],
                error=str(e),
            )
            return None

    @staticmethod
    async def download_and_downscale_to_base64(
        url: str,
        max_edge: int = DEFAULT_MAX_EDGE,
        quality: int = DEFAULT_QUALITY,
        timeout: float = 10.0,
    ) -> Optional[str]:
        """Download a stored image and return a DOWNSIZED base64 JPEG in one pass.

        Memory: unlike ``download_to_base64`` (full-size base64 in, then a
        separate downscale), the response bytes go straight to a reduced-size
        draft decode and re-encode, so a 12 MP reference never exists in
        memory as full-size base64 + full-size decoded pixels. Peak per
        reference: raw response bytes + small JPEG — instead of raw bytes +
        full base64 + full decode + downscaled base64.

        Same SSRF-safe contract as ``download_to_base64`` (returns None on any
        failure so callers degrade gracefully).
        """
        content = await StorageService._download_bytes(
            url, timeout, purpose="source image for reference"
        )
        if content is None:
            return None
        # Downscale is CPU-bound and can allocate tens of MB transiently;
        # run it on the bounded image executor.
        return await run_image_op(
            downscale_image_bytes_to_base64,
            content,
            max_edge,
            quality,
        )

    @staticmethod
    async def download_to_base64(url: str, timeout: float = 10.0) -> Optional[str]:
        """Download a stored image back to base64 for image-gen reference.

        Fetches via the S3 backend by bucket key (see ``key_from_path``), never
        from arbitrary URLs — this keeps the previous SSRF-safe guarantee. This
        helper is used on user-controlled item/avatar records, so following
        arbitrary URLs would turn image generation into an SSRF primitive.

        Returns base64-encoded, decoded image bytes (no data: prefix) or None
        on any failure so callers can fall back gracefully.
        """
        content = await StorageService._download_bytes(
            url, timeout, purpose="source image for reference"
        )
        if content is None:
            return None
        validate_image_bytes(content, max_bytes=MAX_FILE_SIZE)
        return base64.b64encode(content).decode("utf-8")

    @staticmethod
    async def promote_temp_image_to_item(
        db,
        user_id: str,
        temp_storage_path: str,
        filename_hint: str = "generated.png",
    ) -> dict:
        """Move a temporary generated image into the canonical item image path.

        Uses an S3 server-side copy (``tmp/{user_id}/...`` ->
        ``{user_id}/items/...``), then creates the ``_thumb`` sibling for the
        promoted object (tmp objects never carry one). Best-effort thumb: a
        failure only costs the variant, never the promotion.
        """
        ext = os.path.splitext(filename_hint)[1].lower() or ".png"
        new_path = StorageService._build_key(user_id, "items", ext)
        # Legacy per-user preview keys ({user_id}/tmp/{sub}/... held in DB rows
        # from before the temp-key migration) are normalized to the shared
        # top-level layout before the move, mirroring the delete paths (see
        # app/core/storage_keys.py): after the migration script moved the
        # bytes, the legacy key no longer exists and the copy would raise
        # NoSuchKey. Idempotent for canonical keys, so a fresh
        # tmp/{user_id}/{sub}/... path passes through unchanged.
        source_path = normalize_preview_key(temp_storage_path)
        await StorageService.move_image(
            db=db,
            old_path=source_path,
            new_path=new_path,
        )
        try:
            backend = get_storage_backend()
            content = await backend.download(new_path)
            if content:
                await StorageService._upload_thumbnail(backend, new_path, content)
        except Exception as e:
            logger.warning(
                "Failed to thumbnail promoted item image",
                storage_path=new_path,
                error=str(e),
            )
        image_url = await StorageService.get_public_url(new_path)
        return {
            "image_url": image_url,
            "thumbnail_url": image_url,
            "storage_path": new_path,
        }

    @staticmethod
    async def cleanup_temp_images(
        db,
        storage_paths: List[str],
    ) -> int:
        """Delete temporary generated images (best-effort)."""
        if not storage_paths:
            return 0
        try:
            return await StorageService.delete_multiple_images(
                db=db,
                storage_paths=storage_paths,
            )
        except Exception as e:
            logger.warning(
                "Failed to cleanup temp images",
                count=len(storage_paths),
                error=str(e),
            )
            return 0

    # =========================================================================
    # Admin ops: temp-object inventory + cleanup (bounded scan)
    #
    # Temp previews live under the shared top-level ``tmp/`` folder
    # (``tmp/{user_id}/{source}/...``, see upload_temp_generated_image) — they
    # are never DB-referenced, so the only way to find them is a bucket scan.
    # ``scan_keys`` bounds the scan by page count so an admin call cannot walk
    # an unbounded bucket.
    # =========================================================================

    @staticmethod
    async def list_temp_objects(max_pages: int = 50) -> dict:
        """Bounded scan for temp preview objects (``tmp/...``).

        Matches both the current layout (``tmp/{user_id}/{source}/...``) and
        the pre-migration one (``{user_id}/tmp/{source}/...``) so the admin
        inventory stays accurate while scripts/migrate_temp_keys_layout.py is
        still converting old keys.

        Returns::

            {
                "scanned_keys": int,   # keys examined across the scanned pages
                "count": int,          # temp objects found in the scanned range
                "total_bytes": int,
                "oldest": {key,size,last_modified} | None,
                "newest": {key,size,last_modified} | None,
                "items": [ {key,size,last_modified}, ... ],  # ALL found (route
                                                             # truncates payload)
                "truncated": bool,     # True when the page cap cut the scan short
            }
        """
        backend = get_storage_backend()
        objects = await backend.scan_keys(prefix="", max_pages=max_pages)
        temp = [
            o
            for o in objects
            if (o.get("key") or "").startswith("tmp/") or "/tmp/" in (o.get("key") or "")
        ]
        count = len(temp)
        total_bytes = sum(int(o.get("size") or 0) for o in temp)
        dated = [o for o in temp if o.get("last_modified")]
        oldest = min(dated, key=lambda o: o["last_modified"]) if dated else None
        newest = max(dated, key=lambda o: o["last_modified"]) if dated else None
        return {
            "scanned_keys": len(objects),
            "count": count,
            "total_bytes": total_bytes,
            "oldest": oldest,
            "newest": newest,
            "items": temp,
            "truncated": len(objects) >= max_pages * 1000,
        }

    @staticmethod
    async def delete_temp_objects(keys: List[str]) -> int:
        """Delete temp objects by key; returns the number deleted (best-effort).

        The caller applies the per-call safety cap (see
        ``admin_service.TEMP_DELETE_MAX_OBJECTS``); this method just deletes.
        """
        if not keys:
            return 0
        backend = get_storage_backend()
        return await backend.delete_many(keys)
