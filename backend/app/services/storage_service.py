"""
Storage service for managing file uploads to Supabase Storage.
Handles item images, outfit images, and user avatars.
"""

import os
import uuid
from typing import Optional, List, Tuple
from datetime import datetime

from supabase import Client
from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    StorageServiceError,
    FileTooLargeError,
    UnsupportedMediaTypeError,
)

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
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            # Get public URL
            image_url = db.storage.from_(bucket).get_public_url(storage_path)

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
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            image_url = db.storage.from_(bucket).get_public_url(storage_path)

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
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            logger.info(
                "Uploaded avatar",
                user_id=user_id,
                storage_path=storage_path,
                file_size=len(file_data),
            )

            return db.storage.from_(bucket).get_public_url(storage_path)

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
            db.storage.from_(bucket).remove([storage_path])
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
            db.storage.from_(bucket).remove(storage_paths)
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
            file_data = db.storage.from_(bucket).download(old_path)
            db.storage.from_(bucket).upload(path=new_path, file=file_data)
            db.storage.from_(bucket).remove([old_path])

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
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            image_url = db.storage.from_(bucket).get_public_url(storage_path)

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
    ) -> dict:
        """Upload raw bytes to Supabase Storage with an explicit destination path."""
        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            db.storage.from_(bucket).upload(
                path=file_path,
                file=file_data,
                file_options={"content-type": content_type, "upsert": str(upsert).lower()},
            )
            return {
                "public_url": db.storage.from_(bucket).get_public_url(file_path),
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
        """Upload temporary AI-generated image for review workflows."""
        ext = extension if extension.startswith(".") else f".{extension}"
        temp_name = f"{user_id}/tmp/{source}/{uuid.uuid4().hex}{ext}"
        upload = await StorageService.upload_file(
            db=db,
            file_data=file_data,
            file_path=temp_name,
            content_type="image/png",
        )
        return {
            "image_url": upload["public_url"],
            "thumbnail_url": upload["public_url"],
            "storage_path": upload["storage_path"],
        }

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


# ============================================================================
# IMAGE PROCESSING UTILITIES
# ============================================================================


class ImageProcessingService:
    """Utilities for processing images (thumbnails, resizing, etc.).

    For MVP, this is a placeholder. In production, you'd use:
    - Pillow for image processing
    - Background tasks for async processing
    - CDN integration for delivery
    """

    @staticmethod
    async def generate_thumbnail(
        file_data: bytes,
        size: Tuple[int, int] = (300, 300)
    ) -> bytes:
        """Generate a thumbnail from an image.

        Args:
            file_data: Original image bytes
            size: Target size (width, height)

        Returns:
            Thumbnail image bytes
        """
        # MVP: Return original data
        # Production: Use Pillow to resize
        return file_data

    @staticmethod
    async def get_image_dimensions(file_data: bytes) -> Tuple[int, int]:
        """Get image dimensions.

        Args:
            file_data: Image bytes

        Returns:
            Tuple of (width, height)
        """
        # MVP: Return None values
        # Production: Use Pillow to get dimensions
        return (None, None)

    @staticmethod
    def optimize_for_web(file_data: bytes) -> bytes:
        """Optimize image for web delivery.

        Args:
            file_data: Original image bytes

        Returns:
            Optimized image bytes
        """
        # MVP: Return original
        # Production: Compress, convert to WebP, etc.
        return file_data
