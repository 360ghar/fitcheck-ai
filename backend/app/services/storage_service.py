"""
Storage service for managing file uploads to the S3-compatible object store
(Railway Bucket). Handles item images, outfit images, user avatars, source
photos, feedback attachments, and temporary generated images.

The service keeps the same public method signatures and return shapes as the
Supabase Storage implementation so callers change as little as possible; the
internals now talk to ``S3StorageBackend`` (see ``app/services/object_storage.py``).
Image URLs returned by uploads are SHORT-LIVED presigned GET URLs materialized
at read time; the DB stores the ``storage_path`` (bucket key), never a URL.
"""

import asyncio
import base64
import os
import uuid
from typing import Optional, List
from datetime import datetime
from urllib.parse import urlparse

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    StorageServiceError,
    FileTooLargeError,
    UnsupportedMediaTypeError,
)
from app.utils.db import execute_with_reconnect
from app.utils.image_processing import (
    DEFAULT_MAX_EDGE,
    DEFAULT_QUALITY,
    EXTENSION_BY_MIME,
    SUPPORTED_UPLOAD_MIME_TYPES,
    downscale_image_bytes_to_base64,
    sniff_image_mime,
    validate_image_bytes,
)
from app.core.image_executor import run_image_op
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
ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.gif', '.avif'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Browser/CDN cache lifetime stamped on every upload, in seconds. Encoded on
# the S3 object as `cache-control: max-age=<v>`.
DEFAULT_CACHE_CONTROL = "3600"


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
    def _sniff_content_type(file_data: bytes, filename: str = "") -> str:
        """Resolve the real content type of image bytes. Never raises.

        The bytes decide, not the filename: the batch web client names its
        upload `${tempId}.png` regardless of what the generator actually
        returned, and since `background_removal.py` landed that is frequently a
        WebP. The extension is only consulted when the bytes are unreadable.
        """
        return sniff_image_mime(file_data, filename)

    @staticmethod
    def _upload_options(file_data: bytes, filename: str = "") -> dict:
        """Upload metadata for a stored object (test-compat helper).

        Kept for unit-test compatibility (the returned dict carries a
        ``content-type`` key). The S3 upload path calls
        ``S3StorageBackend.upload`` directly with scalar ``content_type`` /
        ``cache_control``; ``upsert`` is retained for signature compatibility
        (an S3 PUT is naturally idempotent, so a reconnect retry overwrites the
        same path instead of erroring on a now-existing key).
        """
        return {
            "content-type": StorageService._sniff_content_type(file_data, filename),
            "cache-control": DEFAULT_CACHE_CONTROL,
            "upsert": "true",
        }

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
    def key_from_path(value: Optional[str]) -> Optional[str]:
        """Extract the bucket object key from a storage key or a served URL.

        Accepts a bare bucket key (``user/items/abc.png``) or a URL that embeds
        one (a Supabase ``/storage/v1/object/public/<bucket>/<key>`` URL, or an
        S3 presigned ``/<bucket>/<key>`` URL) and returns the key. Returns None
        for empty/None input.

        Used by the download helpers so they only ever fetch known bucket keys
        via the S3 backend (SSRF-safe): a caller-provided string is reduced to
        a key and then read from the bucket, never from the arbitrary URL.
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
                    "uploaded_at": datetime.now().isoformat()
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
            await backend.delete(storage_path)
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

        try:
            backend = get_storage_backend()
            return await backend.delete_many(storage_paths)

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
            # against the fresh client (read-only, safe to retry).
            for start in range(0, len(owned_ids), 500):
                chunk = owned_ids[start:start + 500]
                child_rows = await execute_with_reconnect(
                    lambda d, _t=child_table, _f=fk_column, _c=chunk: (
                        d.table(_t).select("storage_path").in_(_f, _c).execute()
                    ),
                    db,
                    extra={"operation": f"resolve_owned_storage_paths.{child_table}", "user_id": user_id},
                )
                storage_paths.extend(
                    str(row["storage_path"])
                    for row in (getattr(child_rows, "data", None) or [])
                    if row.get("storage_path")
                )

        return {
            "item_ids": owned_item_ids,
            "outfit_ids": owned_outfit_ids,
            "storage_paths": storage_paths,
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

        Behavior is UNCHANGED from the Supabase path: temp images stay under
        ``{user_id}/tmp/{source}/``. `extension` is only a hint: the real
        format is sniffed from the bytes, because generated images are no
        longer always PNG (matted product shots come back as WebP) and a
        mislabelled object is served with the wrong content type for as long as
        it lives.
        """
        ext = extension if extension.startswith(".") else f".{extension}"
        # Pillow decode is CPU-bound (up to ~7MB per image); never block the
        # event loop during request handling. Runs on the bounded image
        # executor (see app/core/image_executor.py).
        await run_image_op(StorageService._validate_image, file_data, ext)
        content_type = StorageService._sniff_content_type(file_data, ext)
        ext = EXTENSION_BY_MIME.get(content_type, ext)
        temp_name = f"{user_id}/tmp/{source}/{uuid.uuid4().hex}{ext}"
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

        Uses an S3 server-side copy (``{user_id}/tmp/...`` -> ``{user_id}/items/...``).
        """
        ext = os.path.splitext(filename_hint)[1].lower() or ".png"
        new_path = StorageService._build_key(user_id, "items", ext)
        await StorageService.move_image(
            db=db,
            old_path=temp_storage_path,
            new_path=new_path,
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
