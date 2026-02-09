import pytest

from app.models.social_import import SocialPlatform
from app.services.social_scraper_service import SocialScraperService


class _FakeResponse:
    def __init__(self, *, status_code: int, text: str):
        self.status_code = status_code
        self.text = text

    def raise_for_status(self) -> None:
        return None


class _FakeAsyncClient:
    def __init__(self, response: _FakeResponse):
        self._response = response

    async def __aenter__(self):
        return self

    async def __aexit__(self, exc_type, exc, tb):
        return None

    async def get(self, *_args, **_kwargs):
        return self._response


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
