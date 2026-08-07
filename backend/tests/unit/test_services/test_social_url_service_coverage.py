"""Residual error-branch coverage for app.services.social_url_service.

The sibling test_social_url_service.py covers the happy paths and the
post/profile.php rejections; this file covers the remaining guards: missing
URLs, missing usernames/slugs, and the non-profile.php reserved paths.
"""

import pytest

from app.core.exceptions import SocialImportInvalidUrlError
from app.services.social_url_service import SocialURLService


def test_empty_profile_url_is_rejected():
    with pytest.raises(SocialImportInvalidUrlError, match="required"):
        SocialURLService.normalize_profile_url("")
    with pytest.raises(SocialImportInvalidUrlError, match="required"):
        SocialURLService.normalize_profile_url("   ")


def test_instagram_url_without_username_is_rejected():
    with pytest.raises(SocialImportInvalidUrlError, match="missing username"):
        SocialURLService.normalize_profile_url("https://instagram.com")


def test_instagram_at_sign_only_is_rejected():
    with pytest.raises(SocialImportInvalidUrlError, match="missing username"):
        SocialURLService.normalize_profile_url("https://instagram.com/@")


def test_facebook_url_without_slug_is_rejected():
    with pytest.raises(SocialImportInvalidUrlError, match="missing profile slug"):
        SocialURLService.normalize_profile_url("https://facebook.com")


def test_facebook_reserved_non_profile_php_path_is_rejected():
    with pytest.raises(SocialImportInvalidUrlError, match="pages/groups/events"):
        SocialURLService.normalize_profile_url("https://facebook.com/groups/somegroup")
    with pytest.raises(SocialImportInvalidUrlError, match="pages/groups/events"):
        SocialURLService.normalize_profile_url("https://www.facebook.com/watch")


def test_instagram_mobile_host_and_at_username():
    normalized = SocialURLService.normalize_profile_url("https://m.instagram.com/@fitcheck.ai")
    assert normalized.platform.value == "instagram"
    assert normalized.username_or_profile == "fitcheck.ai"
    assert normalized.normalized_url == "https://www.instagram.com/fitcheck.ai/"


def test_facebook_fb_dot_com_short_host():
    normalized = SocialURLService.normalize_profile_url("fb.com/fitcheck.ai")
    assert normalized.platform.value == "facebook"
    assert normalized.username_or_profile == "fitcheck.ai"
