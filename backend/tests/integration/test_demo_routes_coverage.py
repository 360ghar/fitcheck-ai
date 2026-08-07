"""
Coverage for demo routes (public, unauthenticated landing-page endpoints).

Covers both handlers end to end with patched AI services/agents and a no-op
rate limiter (the real limiter is in-memory but shared process-wide; patching
keeps tests deterministic): extraction success/timeout/generic-error/
rate-limit, try-on success/retry/failure, and request-model validation.

No HTTP and no real AI calls: get_ai_service, the agent classes and the
rate-limit context manager are patched (tests/conftest.py blocks the network).
"""
import asyncio
from contextlib import asynccontextmanager
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import pytest
from pydantic import ValidationError

import app.api.v1.demo as demo_module
from app.api.v1.demo import demo_extract_items, demo_try_on
from app.core.exceptions import AIServiceError, RateLimitError
from app.models.demo import DemoExtractItemsRequest, DemoTryOnRequest

# 1x1 transparent PNG, base64 — passes the demo models' inline-image validator.
_PNG_B64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ"
    "AAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
)


@asynccontextmanager
async def _noop_rate_limit(request, operation_type):
    yield {"allowed": True, "current_count": 0, "limit": 3, "remaining": 3}


@asynccontextmanager
async def _deny_rate_limit(request, operation_type):
    raise RateLimitError(
        f"Demo {operation_type.replace('_', ' ')} limit (3 per day) exceeded."
    )
    yield  # pragma: no cover - unreachable, keeps the generator valid


def _make_request(ip="203.0.113.10"):
    request = Mock()
    request.client = Mock()
    request.client.host = ip
    return request


def _patch_extraction(monkeypatch, *, extract_result=None, extract_error=None):
    ai_service = AsyncMock()
    agent = Mock()
    agent.extract_multiple_items = AsyncMock(
        return_value=extract_result, side_effect=extract_error
    )
    monkeypatch.setattr(demo_module, "get_ai_service", AsyncMock(return_value=ai_service))
    monkeypatch.setattr(demo_module, "ItemExtractionAgent", lambda service: agent)
    monkeypatch.setattr(demo_module, "ip_rate_limited_operation", _noop_rate_limit)
    return ai_service, agent


def _patch_try_on(monkeypatch, *, gen_result=None, gen_error=None):
    ai_service = AsyncMock()
    agent = Mock()
    agent.generate_try_on = AsyncMock(return_value=gen_result, side_effect=gen_error)
    monkeypatch.setattr(demo_module, "get_ai_service", AsyncMock(return_value=ai_service))
    monkeypatch.setattr(demo_module, "ImageGenerationAgent", lambda service: agent)
    monkeypatch.setattr(demo_module, "ip_rate_limited_operation", _noop_rate_limit)
    return ai_service, agent


# =============================================================================
# demo_extract_items
# =============================================================================


@pytest.mark.asyncio
async def test_extract_items_success(monkeypatch):
    ai_service, agent = _patch_extraction(
        monkeypatch,
        extract_result={
            "items": [
                {
                    "category": "tops",
                    "sub_category": "t-shirt",
                    "colors": ["red"],
                    "material": "cotton",
                    "pattern": "solid",
                    "confidence": 0.95,
                    "detailed_description": "Red t-shirt",
                    "temp_id": "temp-1",
                }
            ],
            "overall_confidence": 0.93,
            "image_description": "A red t-shirt",
        },
    )

    result = await demo_extract_items(
        request_body=DemoExtractItemsRequest(image=_PNG_B64),
        request=_make_request(),
        db=Mock(),
    )

    assert result["message"] == "Items extracted successfully"
    assert result["data"]["item_count"] == 1
    assert result["data"]["items"][0]["category"] == "tops"
    assert result["data"]["overall_confidence"] == 0.93
    agent.extract_multiple_items.assert_awaited_once()
    ai_service.close.assert_awaited_once()


@pytest.mark.asyncio
async def test_extract_items_timeout_raises_retryable_error(monkeypatch):
    ai_service, agent = _patch_extraction(
        monkeypatch, extract_error=asyncio.TimeoutError
    )

    with pytest.raises(AIServiceError) as exc_info:
        await demo_extract_items(
            request_body=DemoExtractItemsRequest(image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )

    assert "timed out" in exc_info.value.message
    assert exc_info.value.retryable is True
    ai_service.close.assert_awaited_once()


@pytest.mark.asyncio
async def test_extract_items_generic_error_wrapped(monkeypatch):
    _patch_extraction(monkeypatch, extract_error=RuntimeError("boom"))

    with pytest.raises(AIServiceError) as exc_info:
        await demo_extract_items(
            request_body=DemoExtractItemsRequest(image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )

    assert exc_info.value.message == "Failed to extract items: boom"


@pytest.mark.asyncio
async def test_extract_items_rate_limit_reraises(monkeypatch):
    monkeypatch.setattr(demo_module, "ip_rate_limited_operation", _deny_rate_limit)

    with pytest.raises(RateLimitError):
        await demo_extract_items(
            request_body=DemoExtractItemsRequest(image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )


# =============================================================================
# demo_try_on
# =============================================================================


@pytest.mark.asyncio
async def test_try_on_success(monkeypatch):
    ai_service, agent = _patch_try_on(
        monkeypatch,
        gen_result=SimpleNamespace(
            image_base64="data:image/png;base64,generated", prompt="studio white"
        ),
    )

    result = await demo_try_on(
        request_body=DemoTryOnRequest(person_image=_PNG_B64, clothing_image=_PNG_B64),
        request=_make_request(),
        db=Mock(),
    )

    assert result["message"] == "Try-on image generated successfully"
    assert result["data"]["image_base64"] == "data:image/png;base64,generated"
    assert result["data"]["prompt"] == "studio white"
    agent.generate_try_on.assert_awaited_once()
    ai_service.close.assert_awaited_once()


@pytest.mark.asyncio
async def test_try_on_non_retryable_error_fails_fast(monkeypatch):
    agent_calls = []

    class _CountingAgent:
        def __init__(self, service):
            self.generate_try_on = AsyncMock(
                side_effect=AIServiceError("provider rejected", retryable=False)
            )
            agent_calls.append(self)

    monkeypatch.setattr(demo_module, "get_ai_service", AsyncMock(return_value=AsyncMock()))
    monkeypatch.setattr(demo_module, "ImageGenerationAgent", _CountingAgent)
    monkeypatch.setattr(demo_module, "ip_rate_limited_operation", _noop_rate_limit)

    with pytest.raises(AIServiceError) as exc_info:
        await demo_try_on(
            request_body=DemoTryOnRequest(person_image=_PNG_B64, clothing_image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )

    assert "provider rejected" in exc_info.value.message
    assert len(agent_calls) == 1
    # A non-retryable error must not be retried: exactly one agent call.
    assert agent_calls[0].generate_try_on.await_count == 1


@pytest.mark.asyncio
async def test_try_on_retries_retryable_error_then_succeeds(monkeypatch):
    calls = {"n": 0}

    async def flaky_generate(**kwargs):
        calls["n"] += 1
        if calls["n"] == 1:
            raise AIServiceError("quota exceeded", retryable=True)
        return SimpleNamespace(image_base64="img", prompt="p")

    ai_service = AsyncMock()
    agent = Mock()
    agent.generate_try_on = AsyncMock(side_effect=flaky_generate)
    monkeypatch.setattr(demo_module, "get_ai_service", AsyncMock(return_value=ai_service))
    monkeypatch.setattr(demo_module, "ImageGenerationAgent", lambda service: agent)
    monkeypatch.setattr(demo_module, "ip_rate_limited_operation", _noop_rate_limit)

    with patch.object(asyncio, "sleep", new=AsyncMock()):
        result = await demo_try_on(
            request_body=DemoTryOnRequest(person_image=_PNG_B64, clothing_image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )

    assert calls["n"] == 2
    assert result["data"]["image_base64"] == "img"
    ai_service.close.assert_awaited_once()


@pytest.mark.asyncio
async def test_try_on_generic_error_wrapped(monkeypatch):
    _patch_try_on(monkeypatch, gen_error=RuntimeError("boom"))

    with pytest.raises(AIServiceError) as exc_info:
        await demo_try_on(
            request_body=DemoTryOnRequest(person_image=_PNG_B64, clothing_image=_PNG_B64),
            request=_make_request(),
            db=Mock(),
        )

    assert exc_info.value.message == "Failed to generate try-on: boom"


# =============================================================================
# Request-model validation
# =============================================================================


def test_extract_request_rejects_invalid_image():
    with pytest.raises(ValidationError):
        DemoExtractItemsRequest(image="not-base64!")


def test_try_on_request_rejects_invalid_person_image():
    with pytest.raises(ValidationError):
        DemoTryOnRequest(person_image="not-base64!", clothing_image=_PNG_B64)
