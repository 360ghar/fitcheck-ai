"""Coverage-completing tests for AIProviderHealthService.

Sibling to test_ai_provider_health_service.py: this file covers the cache /
circuit-breaker state machine (TTL hit, open circuit, expired circuit), the
non-OpenAI host branch that skips the Bearer header, the ConnectError /
ConnectTimeout / generic-exception handlers (including consecutive-failure
increments), and clear_cache.
"""

import time
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from app.services.ai_provider_health_service import (
    AIProviderHealthService,
    HealthStatus,
)


def _make_fake_client(status_code: int = 200, exc: Exception = None):
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    if exc is not None:
        fake_client.get = AsyncMock(side_effect=exc)
    else:
        resp = MagicMock(spec=httpx.Response)
        resp.status_code = status_code
        resp.headers = {}
        fake_client.get = AsyncMock(return_value=resp)
    return fake_client


def _patch_client(exc: Exception = None, status_code: int = 200):
    return patch(
        "app.services.ai_provider_health_service.httpx.AsyncClient",
        return_value=_make_fake_client(status_code=status_code, exc=exc),
    )


# =============================================================================
# Cache / circuit breaker state machine
# =============================================================================


@pytest.mark.asyncio
async def test_returns_cached_status_within_ttl():
    svc = AIProviderHealthService()
    cached = HealthStatus(available=True, last_check=time.time(), consecutive_failures=0)
    svc._health_cache["https://apihub.agnes-ai.com/v1"] = cached

    with patch("app.services.ai_provider_health_service.httpx.AsyncClient") as client_cls:
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result is cached
    client_cls.assert_not_called()


@pytest.mark.asyncio
async def test_circuit_breaker_open_returns_cached_failure():
    svc = AIProviderHealthService()
    cached = HealthStatus(
        available=False, last_check=time.time() - 90, consecutive_failures=3, error="Status 503",
    )
    svc._health_cache["https://apihub.agnes-ai.com/v1"] = cached

    with patch("app.services.ai_provider_health_service.httpx.AsyncClient") as client_cls:
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result is cached
    client_cls.assert_not_called()


@pytest.mark.asyncio
async def test_circuit_breaker_resets_after_timeout_and_rechecks():
    svc = AIProviderHealthService()
    svc._health_cache["https://apihub.agnes-ai.com/v1"] = HealthStatus(
        available=False, last_check=time.time() - 300, consecutive_failures=5, error="Status 503",
    )

    with _patch_client(status_code=200):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result.available is True
    assert result.consecutive_failures == 0
    assert result.error is None
    assert result.latency_ms is not None


@pytest.mark.asyncio
async def test_404_is_considered_healthy():
    svc = AIProviderHealthService()
    with _patch_client(status_code=404):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")
    assert result.available is True


# =============================================================================
# Non-OpenAI hosts skip the Bearer header
# =============================================================================


@pytest.mark.asyncio
async def test_non_openai_host_check_skips_auth_header():
    svc = AIProviderHealthService()
    captured = {}
    fake_client = AsyncMock()
    fake_client.__aenter__.return_value = fake_client
    fake_client.__aexit__.return_value = None
    resp = MagicMock(spec=httpx.Response)
    resp.status_code = 200
    resp.headers = {}

    async def _get(url, headers=None):
        captured["headers"] = headers
        return resp

    fake_client.get = _get
    with patch("app.services.ai_provider_health_service.httpx.AsyncClient", return_value=fake_client):
        result = await svc.check_provider_health(
            "https://generativelanguage.googleapis.com/v1beta", "k"
        )

    assert result.available is True
    assert captured["headers"] == {}


# =============================================================================
# Failure handlers
# =============================================================================


@pytest.mark.asyncio
async def test_connect_error_marks_unavailable_and_counts_failures():
    svc = AIProviderHealthService()
    with _patch_client(exc=httpx.ConnectError("refused")):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result.available is False
    assert result.consecutive_failures == 1
    assert result.error == "Connection error: ConnectError"
    assert svc._health_cache["https://apihub.agnes-ai.com/v1"] is result


@pytest.mark.asyncio
async def test_connect_timeout_increments_prior_failures():
    svc = AIProviderHealthService()
    # Seeded entry must be past the TTL (and under the circuit-breaker
    # threshold) so the check actually re-probes instead of returning cache.
    svc._health_cache["https://apihub.agnes-ai.com/v1"] = HealthStatus(
        available=False, last_check=time.time() - 200, consecutive_failures=2, error="Status 503",
    )

    with _patch_client(exc=httpx.ConnectTimeout("timed out")):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result.available is False
    assert result.consecutive_failures == 3
    assert "Connection error" in (result.error or "")


@pytest.mark.asyncio
async def test_generic_exception_marks_unavailable():
    svc = AIProviderHealthService()
    with _patch_client(exc=ValueError("weird failure")):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result.available is False
    assert result.error == "weird failure"
    assert result.consecutive_failures == 1


@pytest.mark.asyncio
async def test_generic_exception_increments_prior_failures():
    svc = AIProviderHealthService()
    svc._health_cache["https://apihub.agnes-ai.com/v1"] = HealthStatus(
        available=False, last_check=time.time() - 200, consecutive_failures=1, error="Status 503",
    )

    with _patch_client(exc=RuntimeError("boom")):
        result = await svc.check_provider_health("https://apihub.agnes-ai.com/v1", "k")

    assert result.available is False
    assert result.consecutive_failures == 2


# =============================================================================
# clear_cache
# =============================================================================


def test_clear_cache_specific_and_all():
    svc = AIProviderHealthService()
    svc._health_cache["a"] = HealthStatus(available=True, last_check=0, consecutive_failures=0)
    svc._health_cache["b"] = HealthStatus(available=True, last_check=0, consecutive_failures=0)

    svc.clear_cache("a")
    assert "a" not in svc._health_cache
    assert "b" in svc._health_cache

    svc.clear_cache()
    assert svc._health_cache == {}
