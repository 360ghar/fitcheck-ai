from app.core.exceptions import SocialImportInvalidUrlError
from app.models.social_import import SocialPlatform
from app.services.social_url_service import SocialURLService


def test_normalize_instagram_profile_url():
    normalized = SocialURLService.normalize_profile_url("instagram.com/fitcheck.ai")

    assert normalized.platform == SocialPlatform.INSTAGRAM
    assert normalized.username_or_profile == "fitcheck.ai"
    assert normalized.normalized_url == "https://www.instagram.com/fitcheck.ai/"


def test_normalize_facebook_profile_url():
    normalized = SocialURLService.normalize_profile_url("https://facebook.com/fitcheck.ai")

    assert normalized.platform == SocialPlatform.FACEBOOK
    assert normalized.username_or_profile == "fitcheck.ai"
    assert normalized.normalized_url == "https://www.facebook.com/fitcheck.ai/"


def test_profile_php_is_rejected():
    try:
        SocialURLService.normalize_profile_url("https://facebook.com/profile.php?id=123")
        assert False, "Expected SocialImportInvalidUrlError"
    except SocialImportInvalidUrlError as exc:
        assert "profile.php" in str(exc).lower()


def test_instagram_post_url_is_rejected():
    try:
        SocialURLService.normalize_profile_url("https://instagram.com/p/abc123/")
        assert False, "Expected SocialImportInvalidUrlError"
    except SocialImportInvalidUrlError as exc:
        assert "profile" in str(exc).lower()


def test_unsupported_host_is_rejected():
    try:
        SocialURLService.normalize_profile_url("https://example.com/user")
        assert False, "Expected SocialImportInvalidUrlError"
    except SocialImportInvalidUrlError as exc:
        assert "instagram" in str(exc).lower() or "facebook" in str(exc).lower()
