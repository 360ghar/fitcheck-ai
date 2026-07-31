"""
Storage service for managing file uploads to Supabase Storage.
Handles item images, outfit images, and user avatars.
"""

import asyncio
import base64
import os
import uuid
from typing import Optional, List
from datetime import datetime

import httpx
from supabase import Client
from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    StorageServiceError,
    FileTooLargeError,
    UnsupportedMediaTypeError,
)
from app.utils.image_processing import EXTENSION_BY_MIME, sniff_image_mime

logger = get_context_logger(__name__)


# Storage bucket names (fallbacks).
# If `SUPABASE_STORAGE_BUCKET` is set, it is used for all uploads by default.
BUCKET_ITEMS = "items"
BUCKET_OUTFITS = "outfits"
BUCKET_AVATARS = "avatars"
BUCKET_FEEDBACK = "feedback"

# Allowed file extensions
ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp', '.gif'}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB

# Browser/CDN cache lifetime stamped on every upload, in seconds. storage3 turns
# a bare value into `cache-control: max-age=<v>` (see _upload_or_update in
# storage3/_sync/file_api.py). Matches storage3's own default; kept explicit
# because passing ANY file_options replaces the defaults wholesale.
DEFAULT_CACHE_CONTROL = "3600"


class StorageService:
    """Service for managing Supabase Storage operations."""

    @staticmethod
    def _generate_filename(
        user_id: str,
        original_filename: str,
        prefix: str = ""
    ) -> str:
        """Generate a unique filename for storage.

        Args:
            user_id: User ID for namespacing
            original_filename: Original file name
            prefix: Optional prefix for the file

        Returns:
            Unique filename path
        """
        ext = os.path.splitext(original_filename)[1].lower()
        unique_id = str(uuid.uuid4())[:8]
        timestamp = datetime.now().strftime('%Y%m%d')

        if prefix:
            return f"{user_id}/{timestamp}/{prefix}_{unique_id}{ext}"
        return f"{user_id}/{timestamp}/{unique_id}{ext}"

    @staticmethod
    def _sniff_content_type(file_data: bytes, filename: str = "") -> str:
        """Resolve the real content type of image bytes. Never raises.

        THIS IS NOT COSMETIC. storage3's `DEFAULT_FILE_OPTIONS` stamps
        `content-type: text/plain;charset=UTF-8` on any upload that passes no
        `file_options`, which is how every item, outfit and avatar object in the
        bucket ended up being served as text/plain.

        The bytes decide, not the filename: the batch web client names its
        upload `${tempId}.png` regardless of what the generator actually
        returned, and since `background_removal.py` landed that is frequently a
        WebP. The extension is only consulted when the bytes are unreadable.

        A consequence, and it is fine: the storage KEY may end in `.png` while
        holding WebP bytes. Supabase serves by stored content type, and browsers
        and Flutter's `Image.network` honour that over the suffix - so do not
        "fix" this by renaming keys, which would churn every stored URL.
        """
        return sniff_image_mime(file_data, filename)

    @staticmethod
    def _upload_options(file_data: bytes, filename: str = "") -> dict:
        """`file_options` for `storage.upload()` with a correct content type.

        A FRESH dict every call: storage3 mutates what it is handed (it pops
        cache-control and upsert out of it), so a shared constant would be
        emptied after the first upload.
        """
        return {
            "content-type": StorageService._sniff_content_type(file_data, filename),
            "cache-control": DEFAULT_CACHE_CONTROL,
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
        ext = os.path.splitext(filename)[1].lower()
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

    @staticmethod
    async def upload_item_image(
        db: Client,
        user_id: str,
        filename: str,
        file_data: bytes,
        is_primary: bool = False
    ) -> dict:
        """Upload an item image to Supabase Storage.

        Args:
            db: Supabase client
            user_id: User ID who owns the item
            filename: Original filename
            file_data: Raw file bytes
            is_primary: Whether this is the primary image

        Returns:
            Dict with image_url, thumbnail_url, and metadata

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure)
        StorageService._validate_image(file_data, filename)

        # Generate unique filename
        storage_path = StorageService._generate_filename(user_id, filename, "item")

        try:
            # Upload to Supabase Storage
            bucket = settings.SUPABASE_STORAGE_BUCKET or BUCKET_ITEMS
            storage = db.storage.from_(bucket)
            await asyncio.to_thread(
                storage.upload,
                path=storage_path,
                file=file_data,
                file_options=StorageService._upload_options(file_data, filename),
            )

            # Get public URL
            image_url = storage.get_public_url(storage_path)

            # For MVP, thumbnail_url is same as image_url
            # In production, you'd generate actual thumbnails
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
        db: Client,
        user_id: str,
        filename: str,
        file_data: bytes,
        generation_type: str = "ai"
    ) -> dict:
        """Upload an outfit image (AI-generated or manual).

        Args:
            db: Supabase client
            user_id: User ID who owns the outfit
            filename: Original filename
            file_data: Raw file bytes
            generation_type: 'ai' or 'manual'

        Returns:
            Dict with image_url and metadata

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure)
        StorageService._validate_image(file_data, filename)

        storage_path = StorageService._generate_filename(user_id, filename, "outfit")

        try:
            bucket = settings.SUPABASE_STORAGE_BUCKET or BUCKET_OUTFITS
            storage = db.storage.from_(bucket)
            await asyncio.to_thread(
                storage.upload,
                path=storage_path,
                file=file_data,
                file_options=StorageService._upload_options(file_data, filename),
            )

            image_url = storage.get_public_url(storage_path)

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
        db: Client,
        user_id: str,
        filename: str,
        file_data: bytes
    ) -> str:
        """Upload a user avatar image.

        Args:
            db: Supabase client
            user_id: User ID
            filename: Original filename
            file_data: Raw file bytes

        Returns:
            Public URL of the uploaded avatar

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure)
        StorageService._validate_image(file_data, filename)

        storage_path = StorageService._generate_filename(user_id, filename, "avatar")

        try:
            bucket = settings.SUPABASE_STORAGE_BUCKET or BUCKET_AVATARS
            storage = db.storage.from_(bucket)
            await asyncio.to_thread(
                storage.upload,
                path=storage_path,
                file=file_data,
                file_options=StorageService._upload_options(file_data, filename),
            )

            logger.info(
                "Uploaded avatar",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
            )

            return storage.get_public_url(storage_path)

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
        db: Client,
        storage_path: str,
        bucket: Optional[str] = None
    ) -> bool:
        """Delete an image from Supabase Storage.

        Args:
            db: Supabase client
            storage_path: Path within the bucket
            bucket: Bucket name (defaults to item images bucket)

        Returns:
            True if deleted successfully

        Raises:
            StorageServiceError: If deletion fails
        """
        if bucket is None:
            # Default to the configured bucket used for uploads.
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            await asyncio.to_thread(db.storage.from_(bucket).remove, [storage_path])
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
        db: Client,
        storage_paths: List[str],
        bucket: Optional[str] = None
    ) -> int:
        """Delete multiple images from Supabase Storage.

        Args:
            db: Supabase client
            storage_paths: List of paths to delete
            bucket: Bucket name

        Returns:
            Number of successfully deleted images

        Raises:
            StorageServiceError: If deletion fails
        """
        if not storage_paths:
            return 0

        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            await asyncio.to_thread(db.storage.from_(bucket).remove, storage_paths)
            logger.info(
                "Deleted multiple images",
                count=len(storage_paths),
                bucket=bucket,
            )
            return len(storage_paths)

        except Exception as e:
            logger.error(
                "Failed to delete multiple images",
                count=len(storage_paths),
                bucket=bucket,
                error=str(e),
            )
            raise StorageServiceError(f"Failed to delete images: {str(e)}")

    @staticmethod
    def get_public_url(storage_path: str, bucket: Optional[str] = None) -> str:
        """Get the public URL for a stored file.

        Args:
            storage_path: Path within the bucket
            bucket: Bucket name

        Returns:
            Public URL string
        """
        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        from app.db.connection import get_db
        db = get_db()
        return db.storage.from_(bucket).get_public_url(storage_path)

    @staticmethod
    async def move_image(
        db: Client,
        old_path: str,
        new_path: str,
        bucket: Optional[str] = None
    ) -> bool:
        """Move an image within a bucket.

        Because Supabase has no server-side move, this downloads and re-uploads,
        which means the content type has to be RE-SNIFFED from the downloaded
        bytes. Without that this path (used by `promote_temp_image_to_item`, i.e.
        social-import approve) silently discards the correct type that
        `upload_temp_generated_image` set and lands the object back on
        storage3's `text/plain;charset=UTF-8` default.

        Args:
            db: Supabase client
            old_path: Current path
            new_path: New path
            bucket: Bucket name

        Returns:
            True if moved successfully

        Raises:
            StorageServiceError: If move fails
        """
        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            # Download and re-upload (Supabase doesn't have direct move)
            storage = db.storage.from_(bucket)
            file_data = await asyncio.to_thread(storage.download, old_path)
            await asyncio.to_thread(
                storage.upload,
                path=new_path,
                file=file_data,
                file_options=StorageService._upload_options(file_data, new_path),
            )
            await asyncio.to_thread(storage.remove, [old_path])

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
        db: Client,
        user_id: str,
        filename: str,
        file_data: bytes,
    ) -> dict:
        """Upload a feedback attachment to Supabase Storage.

        Args:
            db: Supabase client
            user_id: User ID or 'anonymous'
            filename: Original filename
            file_data: Raw file bytes

        Returns:
            Dict with image_url and metadata

        Raises:
            FileTooLargeError: If file exceeds size limit
            UnsupportedMediaTypeError: If file type not allowed
            StorageServiceError: If upload fails
        """
        # Validate the image (raises on failure)
        StorageService._validate_image(file_data, filename)

        storage_path = StorageService._generate_filename(user_id, filename, "feedback")

        try:
            bucket = settings.SUPABASE_STORAGE_BUCKET or BUCKET_FEEDBACK
            storage = db.storage.from_(bucket)
            await asyncio.to_thread(
                storage.upload,
                path=storage_path,
                file=file_data,
                file_options=StorageService._upload_options(file_data, filename),
            )

            image_url = storage.get_public_url(storage_path)

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
        db: Client,
        file_data: bytes,
        file_path: str,
        content_type: str = "application/octet-stream",
        bucket: Optional[str] = None,
        upsert: bool = False,
        cache_control: Optional[str] = None,
    ) -> dict:
        """Upload raw bytes to Supabase Storage with an explicit destination path.

        `cache_control` is seconds as a string; storage3 turns it into
        `cache-control: max-age=<v>`. Defaults to DEFAULT_CACHE_CONTROL. Pass a
        short value (e.g. "60") when overwriting an existing key so a CDN cannot
        keep serving the old bytes for an hour.
        """
        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            storage = db.storage.from_(bucket)
            await asyncio.to_thread(
                storage.upload,
                path=file_path,
                file=file_data,
                file_options={
                    "content-type": content_type,
                    "cache-control": cache_control or DEFAULT_CACHE_CONTROL,
                    "upsert": str(upsert).lower(),
                },
            )
            return {
                "public_url": storage.get_public_url(file_path),
                "storage_path": file_path,
                "bucket": bucket,
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
        db: Client,
        user_id: str,
        file_data: bytes,
        source: str = "social-import",
        extension: str = ".png",
    ) -> dict:
        """Upload temporary AI-generated image for review workflows.

        `extension` is only a hint: the real format is sniffed from the bytes,
        because generated images are no longer always PNG (matted product shots
        come back as WebP) and a mislabelled object is served with the wrong
        content type for as long as it lives.
        """
        ext = extension if extension.startswith(".") else f".{extension}"
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
        db: Client,
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
        # Sniffed from the bytes, with the caller's extension only as a fallback:
        # the previous ext-based mapping labelled every non-.jpg source photo
        # `image/png`, so a .webp upload was served as PNG.
        content_type = StorageService._sniff_content_type(file_data, ext)
        path = f"{user_id}/sources/source_{uuid.uuid4().hex}{ext}"
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
    async def download_to_base64(url: str, timeout: float = 10.0) -> Optional[str]:
        """Download a stored image URL back to base64 for image-gen reference.

        Returns base64-encoded bytes (no data: prefix) or None on any failure
        so callers can fall back to text-only generation gracefully.
        """
        if not url:
            return None
        try:
            async with httpx.AsyncClient(
                timeout=httpx.Timeout(timeout),
                limits=httpx.Limits(max_connections=10),
                follow_redirects=True,
            ) as client:
                response = await client.get(url)
                response.raise_for_status()
                return base64.b64encode(response.content).decode("utf-8")
        except Exception as e:
            logger.warning(
                "Failed to download source image for reference",
                url=url[:120],
                error=str(e),
            )
            return None

    @staticmethod
    async def promote_temp_image_to_item(
        db: Client,
        user_id: str,
        temp_storage_path: str,
        filename_hint: str = "generated.png",
    ) -> dict:
        """Move a temporary generated image into the canonical item image path."""
        new_path = StorageService._generate_filename(user_id, filename_hint, "item")
        await StorageService.move_image(
            db=db,
            old_path=temp_storage_path,
            new_path=new_path,
            bucket=settings.SUPABASE_STORAGE_BUCKET,
        )
        image_url = db.storage.from_(settings.SUPABASE_STORAGE_BUCKET).get_public_url(new_path)
        return {
            "image_url": image_url,
            "thumbnail_url": image_url,
            "storage_path": new_path,
        }

    @staticmethod
    async def cleanup_temp_images(
        db: Client,
        storage_paths: List[str],
    ) -> int:
        """Delete temporary generated images (best-effort)."""
        if not storage_paths:
            return 0
        try:
            return await StorageService.delete_multiple_images(
                db=db,
                storage_paths=storage_paths,
                bucket=settings.SUPABASE_STORAGE_BUCKET,
            )
        except Exception as e:
            logger.warning(
                "Failed to cleanup temp images",
                count=len(storage_paths),
                error=str(e),
            )
            return 0
