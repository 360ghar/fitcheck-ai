"""
Extraction Result Caching Service.

Caches extraction results by image hash to avoid redundant AI processing.
Uses SHA256 hash of image content as cache key with 24-hour TTL.
"""

import asyncio
import hashlib
import json
from datetime import datetime, timedelta
from typing import Any, Dict, Optional

from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# In-memory cache (in production, use Redis for multi-instance deployments)
_cache: Dict[str, Dict[str, Any]] = {}


class ExtractionCacheService:
    """Service for caching extraction results by image hash."""

    # Cache TTL: 24 hours
    CACHE_TTL_HOURS = 24

    @staticmethod
    async def _hash_image(image_base64: str) -> str:
        """
        Generate SHA256 hash of image content (async, non-blocking).

        Args:
            image_base64: Base64-encoded image data

        Returns:
            Hex digest of SHA256 hash
        """
        # Hash the base64 content (not the data URL prefix)
        # Strip any data URL prefix if present
        if "base64," in image_base64:
            image_data = image_base64.split("base64,", 1)[1]
        else:
            image_data = image_base64

        # Run blocking hash computation in thread pool to avoid blocking event loop
        loop = asyncio.get_event_loop()
        image_bytes = image_data.encode()
        hash_hex = await loop.run_in_executor(
            None,
            lambda: hashlib.sha256(image_bytes).hexdigest()
        )
        return hash_hex

    @classmethod
    async def get_cached_result(
        cls,
        image_base64: str,
        user_id: str,
    ) -> Optional[Dict[str, Any]]:
        """
        Get cached extraction result for an image.

        Args:
            image_base64: Base64-encoded image data
            user_id: User ID for cache key scoping

        Returns:
            Cached result dict or None if not found/expired
        """
        try:
            image_hash = await cls._hash_image(image_base64)
            cache_key = f"{user_id}:{image_hash}"

            cached = _cache.get(cache_key)
            if not cached:
                return None

            # Check expiry
            expiry = datetime.fromisoformat(cached["expiry"])
            if datetime.utcnow() > expiry:
                # Expired - remove from cache
                del _cache[cache_key]
                logger.info(
                    "Cache expired",
                    extra={"image_hash": image_hash[:16], "user_id": user_id},
                )
                return None

            logger.info(
                "Cache hit",
                extra={
                    "image_hash": image_hash[:16],
                    "user_id": user_id,
                    "item_count": len(cached["result"].get("items", [])),
                },
            )
            return cached["result"]

        except Exception as e:
            logger.error("Cache get failed", extra={"error": str(e)})
            return None

    @classmethod
    async def set_cached_result(
        cls,
        image_base64: str,
        user_id: str,
        result: Dict[str, Any],
    ) -> None:
        """
        Store extraction result in cache.

        Args:
            image_base64: Base64-encoded image data
            user_id: User ID for cache key scoping
            result: Extraction result to cache
        """
        try:
            image_hash = await cls._hash_image(image_base64)
            cache_key = f"{user_id}:{image_hash}"

            expiry = datetime.utcnow() + timedelta(hours=cls.CACHE_TTL_HOURS)

            _cache[cache_key] = {
                "result": result,
                "expiry": expiry.isoformat(),
                "cached_at": datetime.utcnow().isoformat(),
            }

            logger.info(
                "Cache set",
                extra={
                    "image_hash": image_hash[:16],
                    "user_id": user_id,
                    "item_count": len(result.get("items", [])),
                    "expiry": expiry.isoformat(),
                },
            )

        except Exception as e:
            logger.error("Cache set failed", extra={"error": str(e)})

    @classmethod
    async def clear_cache(cls, user_id: Optional[str] = None) -> int:
        """
        Clear cache entries.

        Args:
            user_id: If provided, only clear entries for this user.
                    If None, clear all entries.

        Returns:
            Number of entries cleared
        """
        try:
            if user_id:
                # Clear entries for specific user
                keys_to_delete = [k for k in _cache.keys() if k.startswith(f"{user_id}:")]
                for key in keys_to_delete:
                    del _cache[key]
                count = len(keys_to_delete)
                logger.info("User cache cleared", extra={"user_id": user_id, "count": count})
            else:
                # Clear all entries
                count = len(_cache)
                _cache.clear()
                logger.info("All cache cleared", extra={"count": count})

            return count

        except Exception as e:
            logger.error("Cache clear failed", extra={"error": str(e)})
            return 0

    @classmethod
    async def cleanup_expired(cls) -> int:
        """
        Remove expired entries from cache.

        Returns:
            Number of entries removed
        """
        try:
            now = datetime.utcnow()
            expired_keys = []

            for key, value in _cache.items():
                expiry = datetime.fromisoformat(value["expiry"])
                if now > expiry:
                    expired_keys.append(key)

            for key in expired_keys:
                del _cache[key]

            if expired_keys:
                logger.info("Expired cache entries removed", extra={"count": len(expired_keys)})

            return len(expired_keys)

        except Exception as e:
            logger.error("Cache cleanup failed", extra={"error": str(e)})
            return 0

    @classmethod
    def get_cache_stats(cls) -> Dict[str, Any]:
        """
        Get cache statistics.

        Returns:
            Dict with cache stats (total_entries, oldest_entry, etc.)
        """
        try:
            if not _cache:
                return {
                    "total_entries": 0,
                    "oldest_entry": None,
                    "newest_entry": None,
                }

            cached_times = [
                datetime.fromisoformat(v["cached_at"]) for v in _cache.values()
            ]
            oldest = min(cached_times)
            newest = max(cached_times)

            return {
                "total_entries": len(_cache),
                "oldest_entry": oldest.isoformat(),
                "newest_entry": newest.isoformat(),
            }

        except Exception as e:
            logger.error("Cache stats failed", extra={"error": str(e)})
            return {"error": str(e)}
