"""Demo extract latency contract: single attempt under a hard time budget.

RCA 2026-08-07 17:37: ``POST /api/v1/demo/extract-items`` took 169 028 ms
(returned 400 via an edge rejection of the churning request) while Gemini
503'd and the fallback leg crawled against its 120 s read timeout. The
handler previously wrapped the WHOLE Gemini -> Agnes chain in
``with_retry(max_retries=1)``, doubling the worst-case latency on top of the
per-leg timeouts. Now the route runs exactly ONE attempt capped by
``DEMO_EXTRACT_TIMEOUT_SECONDS``: on expiry the caller gets a fast retryable
503 (``AI_SERVICE_ERROR``) instead of a multi-minute hang.

These tests replace ``demo.ItemExtractionAgent`` with stubs so they exercise
the route-level contract (budget, error mapping, single invocation, client
cleanup) without driving a real provider.
"""

from __future__ import annotations

import asyncio
import time

import pytest
from fastapi.testclient import TestClient

from app.core.exceptions import AIServiceError
from tests.utils.assertions import assert_error_envelope

# 1x1 transparent PNG, base64 - decodes and verifies under the 7MB demo cap.
_TINY_PNG_BASE64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk"
    "+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="
)


@pytest.fixture
def fake_ai_service():
    """A stub AI service recording ``close()`` calls, wired through
    ``demo.get_ai_service`` (the route's system-service resolution point)."""

    class _FakeService:
        def __init__(self):
            self.close_calls = 0

        async def close(self):
            self.close_calls += 1

    service = _FakeService()
    yield service
    service.close_calls = 0


def _patch_agent(monkeypatch, agent_instance):
    """Replace ``demo.ItemExtractionAgent`` with a stub class returning
    ``agent_instance`` (whose ``extract_multiple_items`` is awaited)."""
    monkeypatch.setattr(
        "app.api.v1.demo.ItemExtractionAgent",
        lambda service: agent_instance,
    )


def _post_extract(client: TestClient) -> object:
    return client.post("/api/v1/demo/extract-items", json={"image": _TINY_PNG_BASE64})


def test_extraction_times_out_fast_and_closes_client(
    client, db, monkeypatch, fake_ai_service
):
    """A hung provider must surface as a fast retryable 503, not a minutes-long
    hang, and the pooled client must still be closed."""
    from app.api.v1 import demo

    class _HangingAgent:
        async def extract_multiple_items(self, image_base64=None):
            await asyncio.sleep(5)
            return {}

    monkeypatch.setattr(demo, "DEMO_EXTRACT_TIMEOUT_SECONDS", 0.2)
    async def _get_ai_service():
        return fake_ai_service
    monkeypatch.setattr(demo, "get_ai_service", _get_ai_service)
    _patch_agent(monkeypatch, _HangingAgent())

    started = time.monotonic()
    response = _post_extract(client)
    elapsed = time.monotonic() - started

    assert elapsed < 2.0, f"timeout did not fire fast enough: {elapsed:.2f}s"
    body = assert_error_envelope(response, status_code=503, code="AI_SERVICE_ERROR")
    assert "timed out" in body["error"].lower()
    assert body.get("retryable") is True
    assert fake_ai_service.close_calls == 1


def test_extraction_makes_single_attempt_on_retryable_error(
    client, db, monkeypatch, fake_ai_service
):
    """A retryable provider failure is surfaced after EXACTLY ONE attempt -
    the old outer with_retry would have invoked the whole chain a second time,
    doubling the failure latency observed 2026-08-07."""
    from app.api.v1 import demo

    class _FailingAgent:
        def __init__(self):
            self.calls = 0

        async def extract_multiple_items(self, image_base64=None):
            self.calls += 1
            raise AIServiceError("AI busy", retryable=True)

    agent = _FailingAgent()
    async def _get_ai_service():
        return fake_ai_service
    monkeypatch.setattr(demo, "get_ai_service", _get_ai_service)
    _patch_agent(monkeypatch, agent)

    response = _post_extract(client)

    body = assert_error_envelope(response, status_code=503, code="AI_SERVICE_ERROR")
    assert agent.calls == 1
    assert body.get("retryable") is True
    assert fake_ai_service.close_calls == 1


def test_extraction_happy_path(client, db, monkeypatch, fake_ai_service):
    """A successful extraction still returns the standard 200 envelope."""
    from app.api.v1 import demo

    class _OkAgent:
        async def extract_multiple_items(self, image_base64=None):
            return {
                "items": [
                    {
                        "category": "tops",
                        "sub_category": "t-shirt",
                        "colors": ["blue"],
                        "material": "cotton",
                        "pattern": "solid",
                        "confidence": 0.9,
                        "detailed_description": "A blue cotton t-shirt",
                    }
                ],
                "people": [],
                "overall_confidence": 0.9,
                "image_description": "A blue t-shirt",
                "item_count": 1,
                "requires_review": False,
            }

    async def _get_ai_service():
        return fake_ai_service
    monkeypatch.setattr(demo, "get_ai_service", _get_ai_service)
    _patch_agent(monkeypatch, _OkAgent())

    response = _post_extract(client)

    assert response.status_code == 200
    data = response.json()["data"]
    assert data["item_count"] == 1
    assert data["items"][0]["category"] == "tops"
    assert data["items"][0]["confidence"] == 0.9
    assert fake_ai_service.close_calls == 1
