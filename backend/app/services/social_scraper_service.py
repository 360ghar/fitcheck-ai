"""
Social profile scraping service for image discovery.

This service intentionally uses lightweight HTTP scraping to discover photo URLs.
It supports pagination semantics (offset cursor) and auth-required signalling.
"""

from __future__ import annotations

import re
from html import unescape
from typing import Dict, List, Optional
from urllib.parse import quote

import httpx

from app.core.config import settings
from app.models.social_import import DiscoverPhotosResult, ScrapedPhotoRef, SocialPlatform


_IMAGE_URL_PATTERNS = [
    r'"display_url":"(https:\\/\\/[^\"]+)"',
    r'"image"\s*:\s*\{\s*"uri"\s*:\s*"(https:\\/\\/[^\"]+)"',
    r'"src"\s*:\s*"(https:\\/\\/[^\"]+\.(?:jpg|jpeg|png|webp)(?:[^\"]*)?)"',
    r'<meta[^>]+property=["\']og:image["\'][^>]+content=["\']([^"\']+)["\']',
]

_PRIVATE_MARKERS = [
    "this account is private",
    "private account",
    "log in to view",
    "you must log in",
]


class SocialScraperService:
    """Discover social profile photos via public scraping and optional auth fallback."""

    @staticmethod
    def _decode_url(raw: str) -> str:
        decoded = raw.replace("\\/", "/")
        decoded = unescape(decoded)
        return decoded

    @classmethod
    def _extract_image_urls(cls, html: str) -> List[str]:
        urls: List[str] = []
        for pattern in _IMAGE_URL_PATTERNS:
            matches = re.findall(pattern, html, flags=re.IGNORECASE)
            for match in matches:
                url = cls._decode_url(match)
                if not url.startswith("http://") and not url.startswith("https://"):
                    continue
                if "profile_pic" in url.lower():
                    continue
                urls.append(url)

        deduped: List[str] = []
        seen = set()
        for url in urls:
            if url in seen:
                continue
            seen.add(url)
            deduped.append(url)
        return deduped

    @staticmethod
    def _is_private_or_blocked(html: str) -> bool:
        lowered = html.lower()
        return any(marker in lowered for marker in _PRIVATE_MARKERS)

    @staticmethod
    def _build_headers(auth_session: Optional[Dict]) -> Dict[str, str]:
        headers = {
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/122.0.0.0 Safari/537.36"
            ),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        }

        if auth_session and auth_session.get("session_payload"):
            payload = auth_session["session_payload"]
            cookie_header = payload.get("cookie_header")
            bearer_token = payload.get("provider_access_token")
            if cookie_header:
                headers["Cookie"] = cookie_header
            if bearer_token:
                headers["Authorization"] = f"Bearer {bearer_token}"

        return headers

    @classmethod
    async def discover_profile_photos(
        cls,
        *,
        normalized_url: str,
        platform: SocialPlatform,
        auth_session: Optional[Dict] = None,
        cursor: Optional[str] = None,
        page_size: Optional[int] = None,
    ) -> DiscoverPhotosResult:
        """Discover profile photos with offset-cursor pagination semantics."""
        limit = page_size or settings.SOCIAL_IMPORT_DISCOVERY_PAGE_SIZE
        limit = max(1, min(limit, 200))

        headers = cls._build_headers(auth_session)

        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            response = await client.get(normalized_url, headers=headers)
            html = response.text or ""

        if response.status_code in (401, 403):
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"http_status": response.status_code},
            )

        private_detected = cls._is_private_or_blocked(html)
        if private_detected and not auth_session:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"reason": "private_profile"},
            )

        all_urls = cls._extract_image_urls(html)

        max_allowed = max(1, settings.SOCIAL_IMPORT_MAX_PHOTOS_PER_JOB)
        all_urls = all_urls[:max_allowed]

        try:
            offset = int(cursor) if cursor else 0
        except ValueError:
            offset = 0

        offset = max(0, offset)
        slice_urls = all_urls[offset : offset + limit]
        next_offset = offset + len(slice_urls)
        exhausted = next_offset >= len(all_urls)

        photos = [
            ScrapedPhotoRef(
                source_photo_id=f"{platform.value}-{offset + index}",
                source_photo_url=url,
                source_thumb_url=url,
                source_taken_at=None,
                metadata={"platform": platform.value},
            )
            for index, url in enumerate(slice_urls)
        ]

        return DiscoverPhotosResult(
            requires_auth=False,
            photos=photos,
            next_cursor=None if exhausted else str(next_offset),
            exhausted=exhausted,
            metadata={
                "total_discovered": len(all_urls),
                "returned": len(slice_urls),
                "offset": offset,
            },
        )

    @staticmethod
    async def fetch_photo_as_base64(photo_url: str) -> str:
        """Download a photo URL and return base64 content without data URL prefix."""
        import base64

        encoded_url = photo_url
        if " " in photo_url:
            encoded_url = quote(photo_url, safe=":/?&=#%")

        async with httpx.AsyncClient(timeout=30.0, follow_redirects=True) as client:
            response = await client.get(encoded_url)
            response.raise_for_status()
            content = response.content

        return base64.b64encode(content).decode("utf-8")
