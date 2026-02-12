"""
Social profile scraping service for image discovery.

This service intentionally uses lightweight HTTP scraping to discover photo URLs.
It supports pagination semantics (offset cursor) and auth-required signalling.
"""

from __future__ import annotations

import logging
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

    _logger = logging.getLogger(__name__)
    _META_GRAPH_BASE = "https://graph.facebook.com/v23.0"

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

    @staticmethod
    def _extract_facebook_attachment_urls(node: Dict[str, object], urls: List[str]) -> None:
        media = node.get("media")
        if isinstance(media, dict):
            image = media.get("image")
            if isinstance(image, dict):
                src = image.get("src")
                if isinstance(src, str) and src.startswith(("http://", "https://")):
                    urls.append(src)

        subattachments = node.get("subattachments")
        if isinstance(subattachments, dict):
            children = subattachments.get("data")
            if isinstance(children, list):
                for child in children:
                    if isinstance(child, dict):
                        SocialScraperService._extract_facebook_attachment_urls(child, urls)

    @classmethod
    def _extract_facebook_post_urls(cls, post: Dict[str, object]) -> List[str]:
        urls: List[str] = []

        full_picture = post.get("full_picture")
        if isinstance(full_picture, str) and full_picture.startswith(("http://", "https://")):
            urls.append(full_picture)

        attachments = post.get("attachments")
        if isinstance(attachments, dict):
            data = attachments.get("data")
            if isinstance(data, list):
                for entry in data:
                    if isinstance(entry, dict):
                        cls._extract_facebook_attachment_urls(entry, urls)

        deduped: List[str] = []
        seen = set()
        for url in urls:
            if url in seen:
                continue
            seen.add(url)
            deduped.append(url)
        return deduped

    @classmethod
    async def _discover_with_meta_api(
        cls,
        *,
        platform: SocialPlatform,
        auth_session: Dict[str, object],
        cursor: Optional[str],
        page_size: int,
    ) -> Optional[DiscoverPhotosResult]:
        payload = auth_session.get("session_payload")
        if not isinstance(payload, dict):
            return None

        access_token = payload.get("provider_access_token")
        if not isinstance(access_token, str) or not access_token:
            return None

        if platform == SocialPlatform.INSTAGRAM:
            return await cls._discover_instagram_via_meta_api(
                payload=payload,
                cursor=cursor,
                page_size=page_size,
            )

        return await cls._discover_facebook_via_meta_api(
            payload=payload,
            cursor=cursor,
            page_size=page_size,
        )

    @classmethod
    async def _discover_instagram_via_meta_api(
        cls,
        *,
        payload: Dict[str, object],
        cursor: Optional[str],
        page_size: int,
    ) -> Optional[DiscoverPhotosResult]:
        ig_user_id = payload.get("provider_user_id")
        if not isinstance(ig_user_id, str) or not ig_user_id:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"reason": "missing_instagram_user_id"},
            )

        access_token = payload.get("provider_page_access_token") or payload.get("provider_access_token")
        if not isinstance(access_token, str) or not access_token:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"reason": "missing_access_token"},
            )

        params: Dict[str, object] = {
            "fields": "id,media_type,media_url,thumbnail_url,timestamp,permalink",
            "limit": page_size,
            "access_token": access_token,
        }
        if cursor:
            params["after"] = cursor

        try:
            async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
                response = await client.get(f"{cls._META_GRAPH_BASE}/{ig_user_id}/media", params=params)
        except Exception:
            return None

        if response.status_code in {400, 401, 403}:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"source": "meta_api", "http_status": response.status_code},
            )
        if not response.is_success:
            return None

        try:
            payload_data = response.json()
        except Exception:
            return None

        rows = payload_data.get("data") or []
        photos: List[ScrapedPhotoRef] = []
        for index, row in enumerate(rows):
            if not isinstance(row, dict):
                continue
            media_type = str(row.get("media_type") or "").upper()
            if media_type not in {"IMAGE", "CAROUSEL_ALBUM", "VIDEO"}:
                continue

            image_url = row.get("media_url") or row.get("thumbnail_url")
            if not isinstance(image_url, str) or not image_url.startswith(("http://", "https://")):
                continue

            source_photo_id = row.get("id")
            if not isinstance(source_photo_id, str) or not source_photo_id:
                source_photo_id = f"instagram-{index}"

            source_thumb_url = row.get("thumbnail_url")
            if not isinstance(source_thumb_url, str):
                source_thumb_url = image_url

            photos.append(
                ScrapedPhotoRef(
                    source_photo_id=source_photo_id,
                    source_photo_url=image_url,
                    source_thumb_url=source_thumb_url,
                    source_taken_at=row.get("timestamp"),
                    metadata={
                        "platform": SocialPlatform.INSTAGRAM.value,
                        "source": "meta_api",
                        "media_type": media_type,
                        "permalink": row.get("permalink"),
                    },
                )
            )

        next_cursor = (
            ((payload_data.get("paging") or {}).get("cursors") or {}).get("after")
            if isinstance(payload_data, dict)
            else None
        )
        if next_cursor is not None:
            next_cursor = str(next_cursor)

        return DiscoverPhotosResult(
            requires_auth=False,
            photos=photos,
            next_cursor=next_cursor,
            exhausted=not bool(next_cursor),
            metadata={
                "source": "meta_api",
                "returned": len(photos),
            },
        )

    @classmethod
    async def _discover_facebook_via_meta_api(
        cls,
        *,
        payload: Dict[str, object],
        cursor: Optional[str],
        page_size: int,
    ) -> Optional[DiscoverPhotosResult]:
        access_token = payload.get("provider_access_token")
        if not isinstance(access_token, str) or not access_token:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"reason": "missing_access_token"},
            )

        params: Dict[str, object] = {
            "fields": "id,created_time,full_picture,attachments{media,subattachments}",
            "limit": page_size,
            "access_token": access_token,
        }
        if cursor:
            params["after"] = cursor

        try:
            async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
                response = await client.get(f"{cls._META_GRAPH_BASE}/me/posts", params=params)
        except Exception:
            return None

        if response.status_code in {400, 401, 403}:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"source": "meta_api", "http_status": response.status_code},
            )
        if not response.is_success:
            return None

        try:
            payload_data = response.json()
        except Exception:
            return None

        rows = payload_data.get("data") or []
        photos: List[ScrapedPhotoRef] = []
        for row in rows:
            if not isinstance(row, dict):
                continue

            post_id = row.get("id")
            if not isinstance(post_id, str) or not post_id:
                post_id = "facebook-post"
            image_urls = cls._extract_facebook_post_urls(row)

            for index, image_url in enumerate(image_urls):
                photos.append(
                    ScrapedPhotoRef(
                        source_photo_id=f"{post_id}-{index}",
                        source_photo_url=image_url,
                        source_thumb_url=image_url,
                        source_taken_at=row.get("created_time"),
                        metadata={
                            "platform": SocialPlatform.FACEBOOK.value,
                            "source": "meta_api",
                            "post_id": post_id,
                        },
                    )
                )

        next_cursor = (
            ((payload_data.get("paging") or {}).get("cursors") or {}).get("after")
            if isinstance(payload_data, dict)
            else None
        )
        if next_cursor is not None:
            next_cursor = str(next_cursor)

        return DiscoverPhotosResult(
            requires_auth=False,
            photos=photos,
            next_cursor=next_cursor,
            exhausted=not bool(next_cursor),
            metadata={
                "source": "meta_api",
                "returned": len(photos),
            },
        )

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

        if auth_session and auth_session.get("session_payload"):
            meta_result = await cls._discover_with_meta_api(
                platform=platform,
                auth_session=auth_session,
                cursor=cursor,
                page_size=limit,
            )
            if meta_result is not None:
                max_allowed = max(1, settings.SOCIAL_IMPORT_MAX_PHOTOS_PER_JOB)
                meta_result.photos = meta_result.photos[:max_allowed]
                return meta_result

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
