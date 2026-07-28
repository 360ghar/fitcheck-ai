"""
Extraction Result Caching Service.

Caches extraction results by image hash to avoid redundant AI processing.
Uses SHA256 hash of image content as cache key with 24-hour TTL.
"""

import asyncio
import hashlib
from datetime import datetime, timedelta, timezone
from app.utils.datetime_util import utcnow, utcnow_iso
from typing import Any, Dict, Optional

from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)

# In-memory cache (in production, use Redis for multi-instance deployments)
_cache: Dict[str, Dict[str, Any]] = {}


class ExtractionCacheService:
    """Service for caching extraction results by image hash."""

    # Cache TTL: 24 hours. Enforced lazily on read only (get_cached_result drops
    # an entry it finds expired); nothing sweeps the dict on a timer.
    CACHE_TTL_HOURS = 24
    # Hard cap so the process-local dict cannot grow without bound under
    # heavy wardrobe import traffic (each result may hold large item lists).
    # This overflow eviction in set_cached_result is the real bound on cache
    # size - an entry that is never read again is only ever freed by this cap.
    MAX_ENTRIES = 200

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
            # Stale entries from before the UTC migration store naive ISO
            # strings; coerce to aware so comparison doesn't raise TypeError.
            if expiry.tzinfo is None:
                expiry = expiry.replace(tzinfo=timezone.utc)
            if utcnow() > expiry:
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

            expiry = utcnow() + timedelta(hours=cls.CACHE_TTL_HOURS)

            _cache[cache_key] = {
                "result": result,
                "expiry": expiry.isoformat(),
                "cached_at": utcnow_iso(),
            }

            # Evict oldest entries when over the hard cap (simple LRU-by-age).
            if len(_cache) > cls.MAX_ENTRIES:
                ordered = sorted(
                    _cache.items(),
                    key=lambda kv: kv[1].get("cached_at", ""),
                )
                overflow = len(_cache) - cls.MAX_ENTRIES
                for key, _ in ordered[:overflow]:
                    _cache.pop(key, None)

            logger.info(
                "Cache set",
                extra={
                    "image_hash": image_hash[:16],
                    "user_id": user_id,
                    "item_count": len(result.get("items", [])),
                    "expiry": expiry.isoformat(),
                    "cache_size": len(_cache),
                },
            )

        except Exception as e:
            logger.error("Cache set failed", extra={"error": str(e)})
