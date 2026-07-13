"""
Tests for AIProviderService LLM/image endpoint routing.

Covers the one new branch introduced for split LLM/image OpenAI-compatible
configs (e.g. agnes-ai.com): chat() must route plain requests to the LLM
endpoint/key and response_modalities (image) requests to the image
endpoint/key.
"""

import httpx
import pytest
from unittest.mock import AsyncMock, patch

from app.services.ai_provider_service import AIProviderService, ChatMessage, ProviderConfig
from app.services.ai_provider_health_service import HealthStatus


def _make_config() -> ProviderConfig:
    return ProviderConfig(
        api_url="https://llm.example.com/v1",
        api_key="llm-key",
        model="llm-model",
        image_api_url="https://image.example.com/v1",
        image_api_key="image-key",
        image_gen_model="image-model",
    )


class _FakeResponse:
    def __init__(self, payload):
        self._payload = payload
        self.status_code = 200

    def raise_for_status(self):
        pass

    def json(self):
        return self._payload


class _FakeClient:
    def __init__(self):
        self.calls = []

    async def post(self, url, json=None, headers=None):
        self.calls.append({"url": url, "headers": headers})
        return _FakeResponse({"choices": [{"message": {"content": "ok"}}]})


@pytest.fixture(autouse=True)
def _mock_health_check():
    healthy = HealthStatus(available=True, last_check=0, consecutive_failures=0)
    with patch(
        "app.services.ai_provider_health_service.AIProviderHealthService.check_provider_health",
        AsyncMock(return_value=healthy),
    ):
        yield


@pytest.mark.asyncio
async def test_chat_uses_llm_endpoint_and_key():
    service = AIProviderService(_make_config())
    fake_client = _FakeClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert len(fake_client.calls) == 1
    call = fake_client.calls[0]
    assert call["url"].startswith("https://llm.example.com")
    assert call["headers"]["Authorization"] == "Bearer llm-key"


@pytest.mark.asyncio
async def test_image_request_uses_image_endpoint_and_key():
    service = AIProviderService(_make_config())
    fake_client = _FakeClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        await service.chat(
            messages=[ChatMessage(role="user", content="a cat")],
            response_modalities=["TEXT", "IMAGE"],
        )

    assert len(fake_client.calls) == 1
    call = fake_client.calls[0]
    assert call["url"].startswith("https://image.example.com")
    assert call["headers"]["Authorization"] == "Bearer image-key"


@pytest.mark.asyncio
async def test_chat_falls_back_to_main_config_when_no_image_config():
    config = ProviderConfig(api_url="https://only.example.com/v1", api_key="only-key", model="m")
    service = AIProviderService(config)
    fake_client = _FakeClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        await service.chat(
            messages=[ChatMessage(role="user", content="a cat")],
            response_modalities=["TEXT", "IMAGE"],
        )

    call = fake_client.calls[0]
    assert call["url"].startswith("https://only.example.com")
    assert call["headers"]["Authorization"] == "Bearer only-key"


class _FlakyThenOkClient:
    """Fails once with a transient transport error, then succeeds."""

    def __init__(self):
        self.call_count = 0

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        if self.call_count == 1:
            raise httpx.ReadError("connection reset")
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


@pytest.mark.asyncio
async def test_generate_image_via_images_api_retries_transient_transport_error():
    """Regression test: this path previously made a single attempt with no
    retry at all (see the removed ponytail comment), unlike chat()'s
    _post_chat. It now shares app/utils/retry.py's with_retry."""
    service = AIProviderService(_make_config())
    fake_client = _FlakyThenOkClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service._generate_image_via_images_api(
            "a cat", model="image-model"
        )

    assert fake_client.call_count == 2
    assert result.images == ["ZmFrZQ=="]


class _CapturingClient:
    """Records the JSON payload sent, always returns a fake success response."""

    def __init__(self):
        self.payloads = []

    async def post(self, url, json=None, headers=None):
        self.payloads.append(json)
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


@pytest.mark.asyncio
async def test_generate_image_via_images_api_nests_response_format_and_image():
    """Regression test: Agnes's gateway 400s if response_format is top-level
    and silently ignores a top-level "image" field - both must live under
    extra_body (see the ponytail comment in _generate_image_via_images_api)."""
    service = AIProviderService(_make_config())
    fake_client = _CapturingClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        await service._generate_image_via_images_api(
            "a cat", model="image-model", reference_images=["abc123"]
        )

    payload = fake_client.payloads[0]
    assert "response_format" not in payload
    assert "image" not in payload
    assert payload["extra_body"] == {
        "response_format": "b64_json",
        "image": ["data:image/jpeg;base64,abc123"],
    }


@pytest.mark.asyncio
async def test_generate_image_routes_reference_image_through_images_api_when_style_is_images():
    """Regression test: this used to always route reference-image requests
    through chat()+response_modalities, which is wrong for image-style Agnes routing.
    "images" style must handle both text-to-image and image-to-image."""
    config = _make_config()
    config.image_api_style = "images"
    service = AIProviderService(config)

    with patch.object(
        AIProviderService, "_generate_image_via_images_api", AsyncMock(return_value="sentinel")
    ) as mock_images_api:
        result = await service.generate_image(prompt="a cat", reference_image="abc123")

    mock_images_api.assert_awaited_once_with(
        "a cat", model="image-model", reference_images=["data:image/jpeg;base64,abc123"]
    )
    assert result == "sentinel"


@pytest.mark.asyncio
async def test_chat_routes_multi_image_content_through_images_api_when_style_is_images():
    """Regression test: photoshoot_service.py (both the sync and SSE streaming
    paths) never calls generate_image() - it builds multi-image ChatMessage
    content directly and calls chat() with response_modalities itself. That
    path 404d on Agnes just as badly and must be fixed at the chat() level,
    not just in generate_image(), or the actual photoshoot feature stays broken."""
    config = _make_config()
    config.image_api_style = "images"
    service = AIProviderService(config)

    content = [
        {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,ref1"}},
        {"type": "image_url", "image_url": {"url": "data:image/jpeg;base64,ref2"}},
        {"type": "text", "text": "put them in a park"},
    ]
    messages = [ChatMessage(role="user", content=content)]

    with patch.object(
        AIProviderService, "_generate_image_via_images_api", AsyncMock(return_value="sentinel")
    ) as mock_images_api:
        result = await service.chat(
            messages=messages,
            model="image-model",
            response_modalities=["TEXT", "IMAGE"],
        )

    mock_images_api.assert_awaited_once_with(
        "put them in a park",
        model="image-model",
        reference_images=["data:image/jpeg;base64,ref1", "data:image/jpeg;base64,ref2"],
    )
    assert result == "sentinel"


class _FlakyThenOk503Client:
    """Returns a 503 once, then succeeds - simulates Agnes's observed overload."""

    def __init__(self):
        self.call_count = 0

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        if self.call_count == 1:
            response = _FakeResponse({"error": {"message": "system memory overloaded"}})
            response.status_code = 503
            response.text = '{"error": "system memory overloaded"}'
            return response
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


@pytest.mark.asyncio
async def test_generate_image_via_images_api_retries_on_503_then_succeeds():
    service = AIProviderService(_make_config())
    fake_client = _FlakyThenOk503Client()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 2
    assert result.images == ["ZmFrZQ=="]


@pytest.mark.asyncio
async def test_generate_image_via_images_api_does_not_retry_http_status_error():
    from app.core.exceptions import AIServiceError

    class _AlwaysBadStatusClient:
        def __init__(self):
            self.call_count = 0

        async def post(self, url, json=None, headers=None):
            self.call_count += 1
            request = httpx.Request("POST", url)
            response = httpx.Response(400, request=request, json={"error": {"message": "bad request"}})
            raise httpx.HTTPStatusError("Bad Request", request=request, response=response)

    service = AIProviderService(_make_config())
    fake_client = _AlwaysBadStatusClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        with pytest.raises(AIServiceError):
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 1
