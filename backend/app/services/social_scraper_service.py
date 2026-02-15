"""
Social profile scraping service for image discovery.

This service intentionally uses lightweight HTTP scraping to discover photo URLs.
It supports pagination semantics (offset cursor) and auth-required signalling.
"""

from __future__ import annotations

import base64
import json
import logging
import re
import time
from dataclasses import dataclass
from html import unescape
from typing import Dict, List, Optional
from urllib.parse import quote, urlencode

import httpx

from app.core.config import settings
from app.models.social_import import DiscoverPhotosResult, ScrapedPhotoRef, SocialPlatform


@dataclass
class InstagramLoginResult:
    """Result of Instagram login attempt."""
    success: bool
    sessionid: Optional[str] = None
    csrftoken: Optional[str] = None
    ds_user_id: Optional[str] = None
    requires_otp: bool = False
    otp_identifier: Optional[str] = None
    checkpoint_url: Optional[str] = None
    error_message: Optional[str] = None


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

    # Instagram web constants
    _INSTAGRAM_BASE = "https://www.instagram.com"
    _INSTAGRAM_LOGIN_URL = "https://www.instagram.com/accounts/login/"
    _INSTAGRAM_LOGIN_AJAX = "https://www.instagram.com/api/v1/web/accounts/login/ajax/"
    _INSTAGRAM_APP_ID = "936619743392459"

    @classmethod
    async def _instagram_login(
        cls,
        username: str,
        password: str,
        otp_code: Optional[str] = None,
        two_factor_identifier: Optional[str] = None,
    ) -> InstagramLoginResult:
        """
        Login to Instagram web using username/password.

        Args:
            username: Instagram username
            password: Instagram password
            otp_code: Optional OTP code for 2FA
            two_factor_identifier: Optional identifier from previous 2FA challenge

        Returns:
            InstagramLoginResult with session cookies or error info
        """
        try:
            async with httpx.AsyncClient(
                timeout=30.0,
                follow_redirects=True,
                headers={
                    "User-Agent": (
                        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                        "AppleWebKit/537.36 (KHTML, like Gecko) "
                        "Chrome/122.0.0.0 Safari/537.36"
                    ),
                    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                    "Accept-Language": "en-US,en;q=0.9",
                    "Accept-Encoding": "gzip, deflate, br",
                },
            ) as client:
                # Step 1: Get login page to extract CSRF token
                login_page = await client.get(cls._INSTAGRAM_LOGIN_URL)
                csrftoken = cls._extract_csrftoken(login_page)

                if not csrftoken:
                    return InstagramLoginResult(
                        success=False,
                        error_message="Failed to get CSRF token from Instagram",
                    )

                # Update client with CSRF token
                client.headers["X-CSRFToken"] = csrftoken
                client.headers["X-IG-App-ID"] = cls._INSTAGRAM_APP_ID
                client.headers["Referer"] = cls._INSTAGRAM_LOGIN_URL

                # Step 2: Attempt login
                if two_factor_identifier and otp_code:
                    # Handle 2FA completion
                    return await cls._complete_two_factor(
                        client, two_factor_identifier, otp_code, csrftoken
                    )

                # Regular login
                enc_password = cls._encrypt_password(password)

                login_data = {
                    "username": username,
                    "enc_password": enc_password,
                    "queryParams": "{}",
                    "optIntoOneTap": "false",
                    "trustedDeviceRecords": "{}",
                }

                response = await client.post(
                    cls._INSTAGRAM_LOGIN_AJAX,
                    data=login_data,
                    headers={
                        "Content-Type": "application/x-www-form-urlencoded",
                        "X-Requested-With": "XMLHttpRequest",
                    },
                )

                return cls._parse_login_response(response, csrftoken)

        except httpx.RequestError as e:
            cls._logger.error(
                "Network error during Instagram login",
                extra={"error": str(e)},
            )
            return InstagramLoginResult(
                success=False,
                error_message=f"Network error: {str(e)}",
            )
        except Exception as e:
            cls._logger.error(
                "Unexpected error during Instagram login",
                extra={"error": str(e)},
            )
            return InstagramLoginResult(
                success=False,
                error_message=f"Login failed: {str(e)}",
            )

    @staticmethod
    def _extract_csrftoken(response: httpx.Response) -> Optional[str]:
        """Extract CSRF token from response cookies or headers."""
        # Try cookies first
        csrftoken = response.cookies.get("csrftoken")
        if csrftoken:
            return csrftoken

        # Try to extract from Set-Cookie header
        set_cookie = response.headers.get("set-cookie", "")
        match = re.search(r'csrftoken=([^;]+)', set_cookie)
        if match:
            return match.group(1)

        return None

    @staticmethod
    def _encrypt_password(password: str) -> str:
        """
        Encrypt password for Instagram login.

        Uses a simplified legacy format for compatibility.
        Format: #PWD_INSTAGRAM_BROWSER:0:{timestamp}:{base64_password}
        """
        timestamp = int(time.time())
        # Simple base64 encoding for legacy format
        encoded = base64.b64encode(password.encode()).decode()
        return f"#PWD_INSTAGRAM_BROWSER:0:{timestamp}:{encoded}"

    @classmethod
    def _parse_login_response(
        cls, response: httpx.Response, csrftoken: str
    ) -> InstagramLoginResult:
        """Parse Instagram login response."""
        try:
            data = response.json()
        except json.JSONDecodeError:
            return InstagramLoginResult(
                success=False,
                error_message="Invalid response from Instagram",
            )

        # Check for authentication success
        if data.get("authenticated") is True:
            sessionid = response.cookies.get("sessionid")
            ds_user_id = response.cookies.get("ds_user_id")

            if sessionid:
                return InstagramLoginResult(
                    success=True,
                    sessionid=sessionid,
                    csrftoken=csrftoken,
                    ds_user_id=ds_user_id,
                )

        # Check for two-factor authentication
        if data.get("two_factor_required"):
            two_factor_info = data.get("two_factor_info", {})
            identifier = two_factor_info.get("two_factor_identifier")

            return InstagramLoginResult(
                success=False,
                requires_otp=True,
                otp_identifier=identifier,
                error_message="Two-factor authentication required",
            )

        # Check for checkpoint/challenge
        if data.get("checkpoint_url"):
            return InstagramLoginResult(
                success=False,
                checkpoint_url=data["checkpoint_url"],
                error_message="Security checkpoint required. Please log in via browser first.",
            )

        # Check for specific error messages
        if data.get("user") is True and data.get("authenticated") is False:
            return InstagramLoginResult(
                success=False,
                error_message="Incorrect password",
            )

        if data.get("user") is False:
            return InstagramLoginResult(
                success=False,
                error_message="Username not found",
            )

        # Generic error
        message = data.get("message", "Login failed")
        return InstagramLoginResult(
            success=False,
            error_message=message,
        )

    @classmethod
    async def _complete_two_factor(
        cls,
        client: httpx.AsyncClient,
        two_factor_identifier: str,
        otp_code: str,
        csrftoken: str,
    ) -> InstagramLoginResult:
        """Complete two-factor authentication."""
        tf_url = "https://www.instagram.com/api/v1/accounts/two_factor_authentication/"

        data = {
            "verificationCode": otp_code,
            "identifier": two_factor_identifier,
            "queryParams": "{}",
        }

        response = await client.post(
            tf_url,
            data=data,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "X-Requested-With": "XMLHttpRequest",
            },
        )

        return cls._parse_login_response(response, csrftoken)

    @classmethod
    async def _discover_with_instagram_scraper(
        cls,
        *,
        normalized_url: str,
        auth_session: Dict[str, object],
        cursor: Optional[str],
        page_size: int,
    ) -> DiscoverPhotosResult:
        """
        Discover Instagram photos using authenticated session cookies.

        Args:
            normalized_url: The Instagram profile URL
            auth_session: Auth session with session cookies
            cursor: Pagination cursor
            page_size: Number of photos to fetch

        Returns:
            DiscoverPhotosResult with photos
        """
        payload = auth_session.get("session_payload", {})
        sessionid = payload.get("sessionid")
        csrftoken = payload.get("csrftoken")
        ds_user_id = payload.get("ds_user_id")

        if not sessionid or not csrftoken:
            return DiscoverPhotosResult(
                requires_auth=True,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"reason": "invalid_session"},
            )

        try:
            # Extract username from URL
            username = cls._extract_username_from_url(normalized_url)
            if not username:
                return DiscoverPhotosResult(
                    requires_auth=False,
                    photos=[],
                    next_cursor=None,
                    exhausted=True,
                    metadata={"reason": "invalid_url"},
                )

            # If we don't have ds_user_id, we need to get it from the profile page
            if not ds_user_id:
                ds_user_id = await cls._get_user_id_from_profile(
                    username, sessionid, csrftoken
                )
                if ds_user_id:
                    # Update the payload for future calls
                    payload["ds_user_id"] = ds_user_id

            if not ds_user_id:
                return DiscoverPhotosResult(
                    requires_auth=True,
                    photos=[],
                    next_cursor=None,
                    exhausted=True,
                    metadata={"reason": "user_id_not_found"},
                )

            # Fetch feed using Instagram's API
            return await cls._fetch_instagram_feed(
                ds_user_id=ds_user_id,
                sessionid=sessionid,
                csrftoken=csrftoken,
                cursor=cursor,
                page_size=page_size,
            )

        except Exception as e:
            cls._logger.error(
                "Error discovering Instagram photos",
                extra={
                    "error": str(e),
                    "username": username if "username" in locals() else None,
                },
            )
            return DiscoverPhotosResult(
                requires_auth=False,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"error": str(e)},
            )

    @staticmethod
    def _extract_username_from_url(url: str) -> Optional[str]:
        """Extract Instagram username from profile URL."""
        patterns = [
            r'instagram\.com/([^/?]+)',
            r'instagram\.com/([^/?]+)/',
        ]
        for pattern in patterns:
            match = re.search(pattern, url, re.IGNORECASE)
            if match:
                username = match.group(1)
                # Filter out non-usernames
                if username and username not in ['accounts', 'api', 'explore', 'p']:
                    return username
        return None

    @classmethod
    async def _get_user_id_from_profile(
        cls,
        username: str,
        sessionid: str,
        csrftoken: str,
    ) -> Optional[str]:
        """Get Instagram user ID from profile page."""
        try:
            async with httpx.AsyncClient(
                timeout=20.0,
                follow_redirects=True,
                headers={
                    "User-Agent": (
                        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                        "AppleWebKit/537.36 (KHTML, like Gecko) "
                        "Chrome/122.0.0.0 Safari/537.36"
                    ),
                    "Cookie": f"sessionid={sessionid}; csrftoken={csrftoken}",
                    "X-CSRFToken": csrftoken,
                    "X-IG-App-ID": cls._INSTAGRAM_APP_ID,
                },
            ) as client:
                response = await client.get(f"{cls._INSTAGRAM_BASE}/{username}/")

                # Try to extract user ID from HTML
                # Look for "profile_id" or user ID in embedded JSON
                text = response.text

                # Pattern 1: profile_id in meta or scripts
                match = re.search(r'"profile_id":"(\d+)"', text)
                if match:
                    return match.group(1)

                # Pattern 2: user ID in data structure
                match = re.search(r'"user_id":"(\d+)"', text)
                if match:
                    return match.group(1)

                # Pattern 3: Look in shared data
                match = re.search(r'"id":"(\d+)"[^}]*"username":"' + re.escape(username) + '"', text)
                if match:
                    return match.group(1)

                return None

        except Exception as e:
            cls._logger.error(
                "Error getting user ID",
                extra={"error": str(e), "username": username},
            )
            return None

    @classmethod
    async def _fetch_instagram_feed(
        cls,
        ds_user_id: str,
        sessionid: str,
        csrftoken: str,
        cursor: Optional[str],
        page_size: int,
    ) -> DiscoverPhotosResult:
        """Fetch user's feed using Instagram's private API."""
        try:
            params: Dict[str, object] = {
                "count": min(page_size, 50),
            }
            if cursor:
                params["max_id"] = cursor

            async with httpx.AsyncClient(
                timeout=20.0,
                follow_redirects=True,
                headers={
                    "User-Agent": (
                        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                        "AppleWebKit/537.36 (KHTML, like Gecko) "
                        "Chrome/122.0.0.0 Safari/537.36"
                    ),
                    "Accept": "*/*",
                    "Accept-Language": "en-US,en;q=0.9",
                    "Cookie": f"sessionid={sessionid}; csrftoken={csrftoken}; ds_user_id={ds_user_id}",
                    "X-CSRFToken": csrftoken,
                    "X-IG-App-ID": cls._INSTAGRAM_APP_ID,
                    "X-Requested-With": "XMLHttpRequest",
                    "Referer": f"{cls._INSTAGRAM_BASE}/",
                },
            ) as client:
                url = f"{cls._INSTAGRAM_BASE}/api/v1/feed/user/{ds_user_id}/"
                if params:
                    url += "?" + urlencode(params)

                response = await client.get(url)

                if response.status_code == 401:
                    # Session expired or invalid
                    return DiscoverPhotosResult(
                        requires_auth=True,
                        photos=[],
                        next_cursor=None,
                        exhausted=True,
                        metadata={"reason": "session_expired"},
                    )

                response.raise_for_status()
                data = response.json()

                return cls._parse_instagram_feed(data, ds_user_id)

        except httpx.HTTPStatusError as e:
            cls._logger.error(
                "HTTP error fetching feed",
                extra={
                    "status_code": e.response.status_code,
                    "error": str(e),
                },
            )
            if e.response.status_code in (401, 403):
                return DiscoverPhotosResult(
                    requires_auth=True,
                    photos=[],
                    next_cursor=None,
                    exhausted=True,
                    metadata={"reason": "auth_error", "status": e.response.status_code},
                )
            return DiscoverPhotosResult(
                requires_auth=False,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"error": str(e)},
            )
        except Exception as e:
            cls._logger.error(
                "Error fetching feed",
                extra={"error": str(e)},
            )
            return DiscoverPhotosResult(
                requires_auth=False,
                photos=[],
                next_cursor=None,
                exhausted=True,
                metadata={"error": str(e)},
            )

    @classmethod
    def _parse_instagram_feed(
        cls,
        data: Dict,
        ds_user_id: str,
    ) -> DiscoverPhotosResult:
        """Parse Instagram feed response into ScrapedPhotoRef objects."""
        photos: List[ScrapedPhotoRef] = []
        items = data.get("items", [])

        for item in items:
            if not isinstance(item, dict):
                continue

            # Get the best image URL
            image_url = cls._extract_image_url_from_item(item)
            if not image_url:
                continue

            # Get post ID
            post_id = item.get("id", "")
            # Get timestamp
            taken_at = item.get("taken_at")

            photos.append(
                ScrapedPhotoRef(
                    source_photo_id=post_id,
                    source_photo_url=image_url,
                    source_thumb_url=image_url,
                    source_taken_at=cls._timestamp_to_iso(taken_at),
                    metadata={
                        "platform": SocialPlatform.INSTAGRAM.value,
                        "source": "instagram_web_scraper",
                        "user_id": ds_user_id,
                        "code": item.get("code"),
                        "media_type": item.get("media_type"),
                    },
                )
            )

        # Check for more items
        next_max_id = data.get("next_max_id")
        more_available = data.get("more_available", False)

        return DiscoverPhotosResult(
            requires_auth=False,
            photos=photos,
            next_cursor=next_max_id if more_available else None,
            exhausted=not more_available,
            metadata={
                "total_returned": len(photos),
                "has_more": more_available,
            },
        )

    @staticmethod
    def _extract_image_url_from_item(item: Dict) -> Optional[str]:
        """Extract the best image URL from a feed item."""
        # Try image_versions2 first (standard posts)
        image_versions = item.get("image_versions2", {})
        candidates = image_versions.get("candidates", [])

        if candidates and isinstance(candidates, list):
            # Get the highest resolution image
            best = max(candidates, key=lambda x: x.get("width", 0) * x.get("height", 0))
            return best.get("url")

        # Try carousel_media for multi-photo posts
        carousel = item.get("carousel_media", [])
        if carousel and isinstance(carousel, list):
            first = carousel[0]
            image_versions = first.get("image_versions2", {})
            candidates = image_versions.get("candidates", [])
            if candidates and isinstance(candidates, list):
                best = max(candidates, key=lambda x: x.get("width", 0) * x.get("height", 0))
                return best.get("url")

        # Try thumbnail for videos
        return item.get("thumbnail_url")

    @staticmethod
    def _timestamp_to_iso(timestamp: Optional[int]) -> Optional[str]:
        """Convert Unix timestamp to ISO format."""
        if not timestamp:
            return None
        from datetime import datetime, timezone
        return datetime.fromtimestamp(timestamp, tz=timezone.utc).isoformat()

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
            payload = auth_session["session_payload"]

            # Check if this is OAuth (Meta API) auth
            if payload.get("provider_access_token"):
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

            # Check if this is scraper (username/password) auth for Instagram
            if platform == SocialPlatform.INSTAGRAM and payload.get("username") and payload.get("password"):
                # Check if we already have a valid session
                if not payload.get("sessionid"):
                    # Need to login first
                    login_result = await cls._instagram_login(
                        username=payload["username"],
                        password=payload["password"],
                        otp_code=payload.get("otp_code"),
                        two_factor_identifier=payload.get("two_factor_identifier"),
                    )

                    if login_result.requires_otp:
                        # Store the identifier for the next attempt
                        payload["two_factor_identifier"] = login_result.otp_identifier
                        return DiscoverPhotosResult(
                            requires_auth=True,
                            photos=[],
                            next_cursor=None,
                            exhausted=True,
                            metadata={
                                "reason": "two_factor_required",
                                "two_factor_identifier": login_result.otp_identifier,
                                "message": "Two-factor authentication code required",
                            },
                        )

                    if login_result.checkpoint_url:
                        return DiscoverPhotosResult(
                            requires_auth=True,
                            photos=[],
                            next_cursor=None,
                            exhausted=True,
                            metadata={
                                "reason": "checkpoint_required",
                                "checkpoint_url": login_result.checkpoint_url,
                                "message": "Security checkpoint required. Please log in via browser first.",
                            },
                        )

                    if not login_result.success:
                        return DiscoverPhotosResult(
                            requires_auth=True,
                            photos=[],
                            next_cursor=None,
                            exhausted=True,
                            metadata={
                                "reason": "login_failed",
                                "message": login_result.error_message or "Login failed",
                            },
                        )

                    # Store session cookies in the payload for reuse
                    payload["sessionid"] = login_result.sessionid
                    payload["csrftoken"] = login_result.csrftoken
                    payload["ds_user_id"] = login_result.ds_user_id
                    payload["cookie_header"] = (
                        f"sessionid={login_result.sessionid}; "
                        f"csrftoken={login_result.csrftoken}; "
                        f"ds_user_id={login_result.ds_user_id}"
                    )

                # Now use the authenticated session to discover photos
                scraper_result = await cls._discover_with_instagram_scraper(
                    normalized_url=normalized_url,
                    auth_session=auth_session,
                    cursor=cursor,
                    page_size=limit,
                )
                max_allowed = max(1, settings.SOCIAL_IMPORT_MAX_PHOTOS_PER_JOB)
                scraper_result.photos = scraper_result.photos[:max_allowed]
                return scraper_result

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
