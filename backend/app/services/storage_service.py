"""
Storage service for managing file uploads to Supabase Storage.
Handles item images, outfit images, and user avatars.
"""

import os
import uuid
from typing import Optional, List, Tuple
from datetime import datetime
import logging

from supabase import Client
from app.core.config import settings

logger = logging.getLogger(__name__)


# Storage bucket names
BUCKET_ITEMS = "fitcheck-item-images"
BUCKET_OUTFITS = "fitcheck-outfit-images"
BUCKET_AVATARS = "fitcheck-avatars"

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
    def _validate_image(file_data: bytes, filename: str) -> Tuple[bool, Optional[str]]:
        """Validate an image file.

        Args:
            file_data: Raw file bytes
            filename: Original filename

        Returns:
            Tuple of (is_valid, error_message)
        """
        # Check file size
        if len(file_data) > MAX_FILE_SIZE:
            return False, f"File size exceeds {MAX_FILE_SIZE // (1024*1024)}MB limit"

        # Check file extension
        ext = os.path.splitext(filename)[1].lower()
        if ext not in ALLOWED_IMAGE_EXTENSIONS:
            return False, f"Invalid file type. Allowed: {', '.join(ALLOWED_IMAGE_EXTENSIONS)}"

        return True, None

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
            ValueError: If validation fails
        """
        # Validate the image
        is_valid, error_msg = StorageService._validate_image(file_data, filename)
        if not is_valid:
            raise ValueError(error_msg)

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

            return {
                "image_url": image_url,
                "thumbnail_url": thumbnail_url,
                "storage_path": storage_path,
                "is_primary": is_primary,
                "width": None,  # Would be populated by image processing
                "height": None
            }

        except Exception as e:
            logger.error(f"Error uploading item image: {str(e)}")
            raise ValueError(f"Failed to upload image: {str(e)}")

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
        """
        is_valid, error_msg = StorageService._validate_image(file_data, filename)
        if not is_valid:
            raise ValueError(error_msg)

        storage_path = StorageService._generate_filename(user_id, filename, "outfit")

        try:
            bucket = BUCKET_OUTFITS
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            image_url = db.storage.from_(bucket).get_public_url(storage_path)

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
            logger.error(f"Error uploading outfit image: {str(e)}")
            raise ValueError(f"Failed to upload outfit image: {str(e)}")

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
        """
        is_valid, error_msg = StorageService._validate_image(file_data, filename)
        if not is_valid:
            raise ValueError(error_msg)

        storage_path = StorageService._generate_filename(user_id, filename, "avatar")

        try:
            bucket = BUCKET_AVATARS
            db.storage.from_(bucket).upload(
                path=storage_path,
                file=file_data
            )

            return db.storage.from_(bucket).get_public_url(storage_path)

        except Exception as e:
            logger.error(f"Error uploading avatar: {str(e)}")
            raise ValueError(f"Failed to upload avatar: {str(e)}")

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
        """
        if bucket is None:
            # Try to determine bucket from path
            if "item" in storage_path.lower():
                bucket = BUCKET_ITEMS
            elif "outfit" in storage_path.lower():
                bucket = BUCKET_OUTFITS
            elif "avatar" in storage_path.lower():
                bucket = BUCKET_AVATARS
            else:
                bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            db.storage.from_(bucket).remove([storage_path])
            logger.info(f"Deleted image: {storage_path}")
            return True

        except Exception as e:
            logger.error(f"Error deleting image {storage_path}: {str(e)}")
            return False

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
        """
        if not storage_paths:
            return 0

        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            db.storage.from_(bucket).remove(storage_paths)
            logger.info(f"Deleted {len(storage_paths)} images")
            return len(storage_paths)

        except Exception as e:
            logger.error(f"Error deleting multiple images: {str(e)}")
            return 0

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
        """
        if bucket is None:
            bucket = settings.SUPABASE_STORAGE_BUCKET

        try:
            # Download and re-upload (Supabase doesn't have direct move)
            file_data = db.storage.from_(bucket).download(old_path)
            db.storage.from_(bucket).upload(path=new_path, file=file_data)
            db.storage.from_(bucket).remove([old_path])
            return True

        except Exception as e:
            logger.error(f"Error moving image: {str(e)}")
            return False


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
