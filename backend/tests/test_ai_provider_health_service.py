"""Tests for app/services/ai_provider_health_service.py.

Covers the non-OpenAI host detection used to skip Bearer auth on native
Google (Gemini) endpoints, which otherwise 401 and force a needless fallback.
Also covers the auth-specific (401/403) diagnostic surfaced on
HealthStatus.error so the next key problem points at the key, not at
'service not running'.
"""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest
import httpx

from app.services.ai_provider_health_service import (
    AIProviderHealthService,
    _is_non_openai_host,
)


@pytest.mark.parametrize(
    "url,expected",
    [
        ("https://generativelanguage.googleapis.com/v1", True),
        ("https://generativelanguage.googleapis.com/", True),
        ("https://sub.generativelanguage.googleapis.com/v1", True),
        ("https://apihub.agnes-ai.com/v1", False),
        ("https://api.openai.com/v1", False),
        ("https://llm.example.com/v1", False),
        (None, False),
        ("", False),
    ],
)
def test_is_non_openai_host(url, expected):
    assert _is_non_openai_host(url) is expected


def _mock_response(status_code: int) -> MagicMock:
    resp = MagicMock(spec=httpx.Response)
    resp.status_code = status_code
    resp.headers = {}
    return resp


@pytest.mark.asyncio
async def test_auth_rejected_401_points_at_api_key():
    """A 401 from the /models probe must produce an error message that names
    the API key, so the downstream AIServiceError is self-explanatory instead
    of the generic 'Status 401 / service not running'."""
    svc = AIProviderHealthService()
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    fake_client.get = AsyncMock(return_value=_mock_response(401))

    with patch(
        "app.services.ai_provider_health_service.httpx.AsyncClient",
        return_value=fake_client,
    ):
        status = await svc.check_provider_health(
            base_url="https://apihub.agnes-ai.com/v1",
            api_key="bad-key",
            timeout_seconds=1.0,
        )

    assert status.available is False
    assert status.error is not None
    assert "401" in status.error
    assert "API key" in status.error
    assert "AI_CHAT_API_KEY" in status.error


@pytest.mark.asyncio
async def test_auth_rejected_403_points_at_api_key():
    """Same diagnostic contract for 403 Forbidden (revoked key / scope)."""
    svc = AIProviderHealthService()
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    fake_client.get = AsyncMock(return_value=_mock_response(403))

    with patch(
        "app.services.ai_provider_health_service.httpx.AsyncClient",
        return_value=fake_client,
    ):
        status = await svc.check_provider_health(
            base_url="https://api.openai.com/v1",
            api_key="revoked",
            timeout_seconds=1.0,
        )

    assert status.available is False
    assert status.error is not None
    assert "403" in status.error
    assert "API key" in status.error


@pytest.mark.asyncio
async def test_non_auth_failure_keeps_generic_status_message():
    """Non-auth failures (e.g. 500, 503) keep the generic 'Status NNN' shape
    so they aren't misread as a key problem."""
    svc = AIProviderHealthService()
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    fake_client.get = AsyncMock(return_value=_mock_response(503))

    with patch(
        "app.services.ai_provider_health_service.httpx.AsyncClient",
        return_value=fake_client,
    ):
        status = await svc.check_provider_health(
            base_url="https://apihub.agnes-ai.com/v1",
            api_key="real-key",
            timeout_seconds=1.0,
        )

    assert status.available is False
    assert status.error == "Status 503"
    assert "API key" not in status.error


@pytest.mark.asyncio
async def test_healthy_provider_returns_no_error():
    """200/404 are healthy: error is None and the cache reflects it."""
    svc = AIProviderHealthService()
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    fake_client.get = AsyncMock(return_value=_mock_response(200))

    with patch(
        "app.services.ai_provider_health_service.httpx.AsyncClient",
        return_value=fake_client,
    ):
        status = await svc.check_provider_health(
            base_url="https://apihub.agnes-ai.com/v1",
            api_key="real-key",
            timeout_seconds=1.0,
        )

    assert status.available is True
    assert status.error is None
