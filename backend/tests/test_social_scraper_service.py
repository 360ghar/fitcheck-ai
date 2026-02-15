import pytest

from app.models.social_import import SocialPlatform
from app.services.social_scraper_service import InstagramLoginResult, SocialScraperService


class _FakeResponse:
    def __init__(self, *, status_code: int, text: str, cookies=None, json_data=None):
        self.status_code = status_code
        self.text = text
        self.cookies = cookies or {}
        self._json = json_data

    def raise_for_status(self) -> None:
        return None

    def json(self):
        return self._json or {}


class _FakeAsyncClient:
    def __init__(self, response: _FakeResponse, post_response=None):
        self._response = response
        self._post_response = post_response
        self.headers = {}

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        return None

    async def get(self, *_args, **_kwargs):
        return self._response

    async def post(self, *_args, **_kwargs):
        return self._post_response or self._response


@pytest.mark.asyncio
async def test_discovery_does_not_enqueue_non_image_fallback_urls(monkeypatch):
    response = _FakeResponse(status_code=200, text="<html><body>No media here</body></html>")

    monkeypatch.setattr(
        "app.services.social_scraper_service.httpx.AsyncClient",
        lambda *args, **kwargs: _FakeAsyncClient(response),
    )

    result = await SocialScraperService.discover_profile_photos(
        normalized_url="https://www.instagram.com/example/",
        platform=SocialPlatform.INSTAGRAM,
        auth_session=None,
    )

    assert result.requires_auth is False
    assert result.photos == []
    assert result.exhausted is True


@pytest.mark.asyncio
async def test_instagram_login_with_2fa_required(monkeypatch):
    """Test that Instagram login properly handles 2FA requirement."""
    # Mock login page response with CSRF token
    login_page_response = _FakeResponse(
        status_code=200,
        text='<html><input name="csrf_token" value="testcsrf123"/></html>',
        cookies={"csrftoken": "testcsrf123"},
    )

    # Mock login AJAX response requiring 2FA
    login_ajax_response = _FakeResponse(
        status_code=200,
        text="{}",
        json_data={
            "two_factor_required": True,
            "two_factor_info": {
                "two_factor_identifier": "test-2fa-id-123",
            },
        },
    )

    class FakeClient:
        def __init__(self, *args, **kwargs):
            self.headers = {}

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb):
            return None

        async def get(self, url, **kwargs):
            if "login" in url:
                return login_page_response
            return _FakeResponse(status_code=200, text="{}")

        async def post(self, url, **kwargs):
            return login_ajax_response

    monkeypatch.setattr(
        "app.services.social_scraper_service.httpx.AsyncClient",
        FakeClient,
    )

    result = await SocialScraperService._instagram_login(
        username="testuser",
        password="testpass",
    )

    assert result.success is False
    assert result.requires_otp is True
    assert result.otp_identifier == "test-2fa-id-123"


@pytest.mark.asyncio
async def test_instagram_scraper_discovery_with_credentials(monkeypatch):
    """Test that scraper credentials trigger Instagram login flow."""
    login_page_response = _FakeResponse(
        status_code=200,
        text='<html></html>',
        cookies={"csrftoken": "testcsrf123"},
    )

    login_ajax_response = _FakeResponse(
        status_code=200,
        text="{}",
        json_data={"authenticated": True},
        cookies={
            "sessionid": "test_session_123",
            "ds_user_id": "12345678",
        },
    )

    feed_response = _FakeResponse(
        status_code=200,
        text="{}",
        json_data={
            "items": [
                {
                    "id": "post_1",
                    "taken_at": 1700000000,
                    "image_versions2": {
                        "candidates": [
                            {"url": "https://instagram.com/image1.jpg", "width": 1080, "height": 1080},
                        ]
                    },
                }
            ],
            "more_available": False,
        },
    )

    class FakeClient:
        def __init__(self, *args, **kwargs):
            self.headers = {}

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb):
            return None

        async def get(self, url, **kwargs):
            if "login" in url:
                return login_page_response
            elif "/feed/user/" in url or "/api/v1/feed" in url:
                return feed_response
            elif "testuser" in url:
                # Profile page for extracting user ID
                return _FakeResponse(status_code=200, text='"profile_id":"12345678"')
            return _FakeResponse(status_code=200, text="{}")

        async def post(self, url, **kwargs):
            return login_ajax_response

    monkeypatch.setattr(
        "app.services.social_scraper_service.httpx.AsyncClient",
        FakeClient,
    )

    auth_session = {
        "session_payload": {
            "username": "testuser",
            "password": "testpass",
        }
    }

    result = await SocialScraperService.discover_profile_photos(
        normalized_url="https://www.instagram.com/testuser/",
        platform=SocialPlatform.INSTAGRAM,
        auth_session=auth_session,
    )

    # Should successfully discover photos
    assert result.requires_auth is False
    assert len(result.photos) == 1
    assert result.photos[0].source_photo_url == "https://instagram.com/image1.jpg"
    assert result.photos[0].source_photo_id == "post_1"

    # Should have stored session cookies in the payload
    assert auth_session["session_payload"]["sessionid"] == "test_session_123"
    assert auth_session["session_payload"]["ds_user_id"] == "12345678"


def test_extract_username_from_url():
    """Test URL to username extraction."""
    test_cases = [
        ("https://www.instagram.com/username/", "username"),
        ("https://instagram.com/test.user/", "test.user"),
        ("https://www.instagram.com/example", "example"),
    ]

    for url, expected in test_cases:
        result = SocialScraperService._extract_username_from_url(url)
        assert result == expected, f"Failed for {url}: got {result}, expected {expected}"


def test_encrypt_password_format():
    """Test password encryption produces correct format."""
    password = "testpassword"
    encrypted = SocialScraperService._encrypt_password(password)

    # Should start with Instagram password format
    assert encrypted.startswith("#PWD_INSTAGRAM_BROWSER:0:")
    # Should contain base64 encoded password
    parts = encrypted.split(":")
    assert len(parts) == 4


def test_instagram_login_result_dataclass():
    """Test InstagramLoginResult dataclass."""
    result = InstagramLoginResult(
        success=True,
        sessionid="test123",
        csrftoken="csrf456",
        ds_user_id="789",
    )

    assert result.success is True
    assert result.sessionid == "test123"
    assert result.csrftoken == "csrf456"
    assert result.ds_user_id == "789"
    assert result.requires_otp is False
