"""
Social URL normalization and platform detection.
"""

from __future__ import annotations

from dataclasses import dataclass
from urllib.parse import urlparse

from app.core.exceptions import SocialImportInvalidUrlError
from app.models.social_import import SocialPlatform


@dataclass
class NormalizedSocialUrl:
    platform: SocialPlatform
    username_or_profile: str
    source_url: str
    normalized_url: str


class SocialURLService:
    """Parse and normalize Instagram/Facebook profile URLs."""

    _INSTAGRAM_HOSTS = {"instagram.com", "www.instagram.com", "m.instagram.com"}
    _FACEBOOK_HOSTS = {
        "facebook.com",
        "www.facebook.com",
        "m.facebook.com",
        "fb.com",
        "www.fb.com",
    }

    @classmethod
    def normalize_profile_url(cls, source_url: str) -> NormalizedSocialUrl:
        if not source_url or not source_url.strip():
            raise SocialImportInvalidUrlError("Profile URL is required")

        cleaned = source_url.strip()
        if not cleaned.startswith("http://") and not cleaned.startswith("https://"):
            cleaned = f"https://{cleaned}"

        parsed = urlparse(cleaned)
        host = parsed.netloc.lower()
        path_parts = [part for part in parsed.path.split("/") if part]

        if host in cls._INSTAGRAM_HOSTS:
            return cls._normalize_instagram(cleaned, path_parts)

        if host in cls._FACEBOOK_HOSTS:
            return cls._normalize_facebook(cleaned, path_parts)

        raise SocialImportInvalidUrlError(
            "Only Instagram and Facebook profile URLs are supported"
        )

    @staticmethod
    def _normalize_instagram(source_url: str, path_parts: list[str]) -> NormalizedSocialUrl:
        if not path_parts:
            raise SocialImportInvalidUrlError("Instagram profile URL is missing username")

        username = path_parts[0].lstrip("@").strip()
        if not username:
            raise SocialImportInvalidUrlError("Instagram profile URL is missing username")

        normalized = f"https://www.instagram.com/{username}/"
        return NormalizedSocialUrl(
            platform=SocialPlatform.INSTAGRAM,
            username_or_profile=username,
            source_url=source_url,
            normalized_url=normalized,
        )

    @staticmethod
    def _normalize_facebook(source_url: str, path_parts: list[str]) -> NormalizedSocialUrl:
        if not path_parts:
            raise SocialImportInvalidUrlError("Facebook profile URL is missing profile slug")

        if path_parts[0] == "profile.php":
            raise SocialImportInvalidUrlError(
                "Facebook profile.php links are not supported for import; use a profile username URL"
            )

        profile_slug = path_parts[0].strip()
        if not profile_slug:
            raise SocialImportInvalidUrlError("Facebook profile URL is missing profile slug")

        normalized = f"https://www.facebook.com/{profile_slug}/"
        return NormalizedSocialUrl(
            platform=SocialPlatform.FACEBOOK,
            username_or_profile=profile_slug,
            source_url=source_url,
            normalized_url=normalized,
        )
