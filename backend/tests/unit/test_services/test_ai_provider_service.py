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

from app.core.exceptions import AIServiceError
from app.services.ai_provider_interface import AIProvider, AIResponse
from app.services.ai_provider_service import AIProviderService, ChatMessage, ProviderConfig
from app.services.ai_provider_health_service import HealthStatus
from app.services.gemini_provider import GeminiProvider


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

    # Images flow BARE to the wire boundary; _generate_image_via_images_api
    # wraps each reference at serialization time (see its "extra_body.image"
    # construction), so no full-size data-URL copy is created in generate_image.
    mock_images_api.assert_awaited_once_with(
        "a cat", model="image-model", reference_images=["abc123"],
        api_url="https://image.example.com/v1", api_key="image-key",
    )
    assert result == "sentinel"


@pytest.mark.asyncio
async def test_images_api_preserves_remote_reference_urls():
    config = _make_config()
    service = AIProviderService(config)
    captured = {}

    class _ImageCapturingClient:
        async def post(self, url, json=None, headers=None):
            captured["payload"] = json
            return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=_ImageCapturingClient())), \
         patch("app.services.ai_provider_health_service.get_health_service") as mock_health:
        mock_health.return_value.check_provider_health = AsyncMock(
            return_value=HealthStatus(available=True, last_check=0, consecutive_failures=0)
        )
        await service._generate_image_via_images_api(
            "a cat", model="image-model",
            reference_images=["https://storage.example/item.jpg"],
            api_url="https://image.example.com/v1", api_key="image-key",
        )

    assert captured["payload"]["extra_body"]["image"] == ["https://storage.example/item.jpg"]


@pytest.mark.asyncio
async def test_chat_wraps_bare_base64_to_data_url_at_wire_boundary():
    """Regression for the 2026-08-03 bare-base64 message shape: chat() must
    wrap bare base64 image_url entries to data URLs at wire serialization
    (one transient copy per image that lives only for the request body),
    while existing data URLs pass through unchanged. This is the entire point
    of avoiding a full-size copy per image per request."""
    config = _make_config()
    service = AIProviderService(config)

    class _ChatCapturingClient:
        def __init__(self):
            self.payloads = []
        async def post(self, url, json=None, headers=None):
            self.payloads.append(json)
            return _FakeResponse({"choices": [{"message": {"content": "ok"}, "finish_reason": "stop"}]})

    fake_client = _ChatCapturingClient()
    content = [
        {"type": "image_url", "image_url": {"url": "YmFyZQ=="}},  # bare base64
        {"type": "image_url", "image_url": {"url": "data:image/png;base64,Zm9v"}},  # already wrapped
        {"type": "text", "text": "describe these"},
    ]
    messages = [ChatMessage(role="user", content=content)]

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("app.services.ai_provider_health_service.get_health_service") as mock_health:
        mock_health.return_value.check_provider_health = AsyncMock(
            return_value=HealthStatus(available=True, last_check=0, consecutive_failures=0)
        )
        await service.chat(messages=messages, model="chat-model")

    sent_content = fake_client.payloads[0]["messages"][0]["content"]
    image_parts = [p for p in sent_content if p.get("type") == "image_url"]
    # Bare base64 was wrapped to a data URL with the correct sniffed mime.
    assert image_parts[0]["image_url"]["url"].startswith("data:")
    # Existing data URL passed through unchanged (no double-wrap).
    assert image_parts[1]["image_url"]["url"] == "data:image/png;base64,Zm9v"


@pytest.mark.asyncio
async def test_chat_preserves_remote_storage_image_urls():
    """Provider wire serialization must pass hosted image URLs through."""
    config = _make_config()
    service = AIProviderService(config)

    class _ChatCapturingClient:
        def __init__(self):
            self.payloads = []

        async def post(self, url, json=None, headers=None):
            self.payloads.append(json)
            return _FakeResponse({"choices": [{"message": {"content": "ok"}, "finish_reason": "stop"}]})

    fake_client = _ChatCapturingClient()
    messages = [ChatMessage(
        role="user",
        content=[{"type": "image_url", "image_url": {"url": "https://storage.example/item.jpg"}}],
    )]

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("app.services.ai_provider_health_service.get_health_service") as mock_health:
        mock_health.return_value.check_provider_health = AsyncMock(
            return_value=HealthStatus(available=True, last_check=0, consecutive_failures=0)
        )
        await service.chat(messages=messages, model="chat-model")

    assert fake_client.payloads[0]["messages"][0]["content"][0]["image_url"]["url"] == "https://storage.example/item.jpg"


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
        api_url="https://image.example.com/v1", api_key="image-key",
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
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 1
    assert exc_info.value.retryable is False


@pytest.mark.asyncio
async def test_generate_image_http_error_log_message_includes_status_and_model(caplog):
    """Image-gen failures embed status + model in the log message line itself
    (parity with chat) so message-only log views (Railway) can diagnose them -
    the 2026-07-31 photoshoot 4xx storm was invisible in exactly such a view."""
    from app.core.exceptions import AIServiceError

    class _ForbiddenClient:
        async def post(self, url, json=None, headers=None):
            request = httpx.Request("POST", url)
            response = httpx.Response(403, request=request, json={"error": {"message": "denied"}})
            raise httpx.HTTPStatusError("Forbidden", request=request, response=response)

    service = AIProviderService(_make_config())
    fake_client = _ForbiddenClient()
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        with pytest.raises(AIServiceError):
            await service._generate_image_via_images_api("a cat", model="image-model")

    records = [r for r in caplog.records if "Image generation request failed" in r.getMessage()]
    assert records, "expected an image-generation failure log record"
    message = records[0].getMessage()
    assert "(status=403, model=image-model)" in message
    assert "denied" in message


class _FlakyThenOk429Client:
    """Returns a 429 once (real httpx returns Response; raise_for_status is ours), then succeeds."""

    def __init__(self):
        self.call_count = 0

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        if self.call_count == 1:
            response = _FakeResponse({"error": {"message": "rate limited"}})
            response.status_code = 429
            response.text = '{"error": {"message": "rate limited"}}'
            response.headers = {"Retry-After": "1"}
            return response
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


@pytest.mark.asyncio
async def test_generate_image_via_images_api_retries_on_429_then_succeeds():
    """429 must retry on the same request (parity with chat), not only mark outer retryable."""
    service = AIProviderService(_make_config())
    fake_client = _FlakyThenOk429Client()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 2
    assert result.images == ["ZmFrZQ=="]


@pytest.mark.asyncio
async def test_generate_image_via_images_api_429_exhausted_is_retryable():
    from app.core.exceptions import AIServiceError

    class _Always429Client:
        def __init__(self):
            self.call_count = 0

        async def post(self, url, json=None, headers=None):
            self.call_count += 1
            response = _FakeResponse({"error": {"message": "rate limited"}})
            response.status_code = 429
            response.text = '{"error": {"message": "rate limited"}}'
            response.headers = {}
            return response

    service = AIProviderService(_make_config())
    fake_client = _Always429Client()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    # max_retries=1 → 2 attempts (one more round happens at the call site)
    assert fake_client.call_count == 2
    assert exc_info.value.retryable is True


class _AlwaysTransportErrorClient:
    """Always fails with a transient transport error - exhausts with_retry's internal attempts."""

    def __init__(self):
        self.call_count = 0

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        raise httpx.ReadError("connection reset")


class _LocalProtocolThenOkClient:
    """Fails once with LocalProtocolError (HTTP framing / ENHANCE_YOUR_CALM class), then succeeds."""

    def __init__(self):
        self.call_count = 0

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        if self.call_count == 1:
            raise httpx.LocalProtocolError(11)
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


@pytest.mark.asyncio
async def test_generate_image_via_images_api_retries_local_protocol_error():
    """Regression: LocalProtocolError was not in _TRANSIENT_TRANSPORT_ERRORS, so
    concurrent photoshoot image gen failed hard without retry (prod logs:
    'AI image request failed: LocalProtocolError: 11')."""
    service = AIProviderService(_make_config())
    fake_client = _LocalProtocolThenOkClient()
    close_mock = AsyncMock()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch.object(service, "close", close_mock), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 2
    assert result.images == ["ZmFrZQ=="]
    close_mock.assert_awaited()


@pytest.mark.asyncio
async def test_local_protocol_error_is_classified_transient():
    assert AIProviderService._is_transient_transport_error(httpx.LocalProtocolError(11))
    assert AIProviderService._is_transient_transport_error(httpx.RemoteProtocolError("goaway"))


@pytest.mark.asyncio
async def test_generate_image_via_images_api_raises_retryable_after_exhausting_transport_retries():
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    fake_client = _AlwaysTransportErrorClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert fake_client.call_count == 2  # max_retries=1 -> 2 total attempts
    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_generate_image_via_images_api_raises_retryable_when_no_images_returned():
    """Regression test for a 200 response with an empty data array (e.g. a
    silent content-moderation refusal) - must raise instead of returning a
    successful-looking empty result, so chat()'s fallback can fire."""
    from app.core.exceptions import AIServiceError

    class _EmptyImagesClient:
        async def post(self, url, json=None, headers=None):
            return _FakeResponse({"data": []})

    service = AIProviderService(_make_config())
    fake_client = _EmptyImagesClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_generate_image_via_images_api_wraps_asset_fetch_failure():
    """A url-style image item whose asset download fails must surface as
    AIServiceError (not a raw httpx exception) and must not be retryable,
    since the primary generation already succeeded server-side."""
    from app.core.exceptions import AIServiceError

    class _UrlOnlyClient:
        async def post(self, url, json=None, headers=None):
            return _FakeResponse({"data": [{"url": "https://cdn.example.com/img.png"}]})

    async def _failing_get(self, url, **kwargs):
        raise httpx.ConnectError("cdn unreachable")

    service = AIProviderService(_make_config())
    fake_client = _UrlOnlyClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch.object(httpx.AsyncClient, "get", _failing_get):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert exc_info.value.retryable is False


@pytest.mark.asyncio
async def test_chat_falls_back_to_fallback_model_on_retryable_error():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.image_api_style = "images"
    config.image_fallback_model = "fallback-model"
    service = AIProviderService(config)

    mock_images_api = AsyncMock(
        side_effect=[AIServiceError("overloaded", retryable=True), "sentinel"]
    )
    with patch.object(AIProviderService, "_generate_image_via_images_api", mock_images_api):
        result = await service.chat(
            messages=[ChatMessage(role="user", content="a cat")],
            response_modalities=["TEXT", "IMAGE"],
        )

    assert result == "sentinel"
    assert mock_images_api.await_args_list[0].kwargs["model"] == "image-model"
    assert mock_images_api.await_args_list[1].kwargs["model"] == "fallback-model"


@pytest.mark.asyncio
async def test_chat_does_not_fall_back_on_non_retryable_error():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.image_api_style = "images"
    config.image_fallback_model = "fallback-model"
    service = AIProviderService(config)

    mock_images_api = AsyncMock(side_effect=AIServiceError("bad api key", retryable=False))
    with patch.object(AIProviderService, "_generate_image_via_images_api", mock_images_api):
        with pytest.raises(AIServiceError):
            await service.chat(
                messages=[ChatMessage(role="user", content="a cat")],
                response_modalities=["TEXT", "IMAGE"],
            )

    mock_images_api.assert_awaited_once()


@pytest.mark.asyncio
async def test_chat_does_not_fall_back_when_explicit_non_default_model_requested():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.image_api_style = "images"
    config.image_fallback_model = "fallback-model"
    service = AIProviderService(config)

    mock_images_api = AsyncMock(side_effect=AIServiceError("overloaded", retryable=True))
    with patch.object(AIProviderService, "_generate_image_via_images_api", mock_images_api):
        with pytest.raises(AIServiceError):
            await service.chat(
                messages=[ChatMessage(role="user", content="a cat")],
                model="custom-override-model",
                response_modalities=["TEXT", "IMAGE"],
            )

    mock_images_api.assert_awaited_once_with(
        "a cat", model="custom-override-model", reference_images=[],
        api_url="https://image.example.com/v1", api_key="image-key",
    )


# ---------------------------------------------------------------------------
# Chat/vision transient HTTP retries (batch extraction path)
# ---------------------------------------------------------------------------


class _ChatHttpStatusClient:
    """Sequence of chat HTTP outcomes: int status codes raise HTTPStatusError;
    a dict payload is returned as a successful chat completion."""

    def __init__(self, outcomes, retry_after="0"):
        self.outcomes = list(outcomes)
        self.call_count = 0
        self.calls = []
        self.retry_after = retry_after

    async def post(self, url, json=None, headers=None):
        self.call_count += 1
        self.calls.append({"url": url, "json": json, "headers": headers})
        outcome = self.outcomes.pop(0) if self.outcomes else 500
        if isinstance(outcome, dict):
            return _FakeResponse(outcome)
        request = httpx.Request("POST", url)
        # AIProviderService calls raise_for_status() on the response object.
        class _StatusResponse:
            def __init__(self, status_code, payload, headers, request):
                self.status_code = status_code
                self._payload = payload
                self.headers = headers
                self.request = request
                self.text = str(payload)

            def raise_for_status(self):
                if self.status_code >= 400:
                    raise httpx.HTTPStatusError(
                        f"HTTP {self.status_code}",
                        request=self.request,
                        response=httpx.Response(
                            self.status_code,
                            request=self.request,
                            json=self._payload,
                            headers=self.headers,
                        ),
                    )

            def json(self):
                return self._payload

        return _StatusResponse(
            outcome,
            {"error": {"message": f"provider error {outcome}"}},
            {"Retry-After": self.retry_after} if outcome in (429, 503) else {},
            request,
        )


@pytest.mark.asyncio
async def test_chat_retries_429_then_succeeds():
    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient(
        [
            429,
            {"choices": [{"message": {"content": "recovered"}}]},
        ]
    )

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 2
    assert result.text == "recovered"


@pytest.mark.asyncio
async def test_chat_retries_503_then_succeeds():
    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient(
        [
            503,
            {"choices": [{"message": {"content": "ok after overload"}}]},
        ]
    )

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 2
    assert result.text == "ok after overload"


@pytest.mark.asyncio
async def test_chat_429_exhausted_raises_retryable_with_status_in_message():
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    # max_retries=1 → 2 internal attempts (the call site adds one more round)
    fake_client = _ChatHttpStatusClient([429, 429])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 2
    assert exc_info.value.retryable is True
    assert "429" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_504_gateway_timeout_is_retryable():
    """Regression: 504 (edge timeout on slow multi-MB vision POSTs) was left
    out of the transient set, so it failed fast with zero retries and skipped
    the fallback model, despite being exactly as transient as 502/503."""
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient([504, 504])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 2  # retried internally, not failed on first hit
    assert exc_info.value.retryable is True
    assert "504" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_401_fails_fast_non_retryable():
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient([401])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 1
    assert exc_info.value.retryable is False
    assert "401" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_400_fails_fast_non_retryable():
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient([400])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert fake_client.call_count == 1
    assert exc_info.value.retryable is False
    assert "400" in str(exc_info.value)


@pytest.mark.asyncio
async def test_structured_chat_retries_without_response_format_when_provider_rejects_it():
    """Some OpenAI-compatible gateways reject structured-output options even
    though the same model supports ordinary chat."""
    service = AIProviderService(_make_config())

    class _ResponseFormatClient:
        def __init__(self):
            self.payloads = []

        async def post(self, url, json=None, headers=None):
            self.payloads.append(json)
            if "response_format" in json:
                request = httpx.Request("POST", url)
                response = httpx.Response(
                    400,
                    request=request,
                    json={"error": {"message": "response_format is not supported"}},
                )
                raise httpx.HTTPStatusError("unsupported response format", request=request, response=response)
            return _FakeResponse({"choices": [{"message": {"content": "fallback text"}}]})

    client = _ResponseFormatClient()
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=client)):
        result = await service.chat(
            messages=[ChatMessage(role="user", content="return JSON")],
            response_format={"type": "json_object"},
        )

    assert result.text == "fallback text"
    assert len(client.payloads) == 2
    assert "response_format" in client.payloads[0]
    assert "response_format" not in client.payloads[1]


@pytest.mark.asyncio
async def test_chat_retry_honors_retry_after_header():
    service = AIProviderService(_make_config())
    fake_client = _ChatHttpStatusClient(
        [429, {"choices": [{"message": {"content": "recovered"}}]}],
        retry_after="4",
    )
    sleep = AsyncMock()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", sleep):
        result = await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert result.text == "recovered"
    assert sleep.await_args_list[0].args[0] == 4


def test_malformed_chat_payload_is_a_controlled_non_retryable_error():
    service = AIProviderService(_make_config())

    with pytest.raises(AIServiceError) as exc_info:
        service._parse_chat_response({"choices": []}, "model")

    assert exc_info.value.retryable is False
    assert exc_info.value.error_kind == "hard"


@pytest.mark.parametrize(
    "payload",
    [
        {"choices": [{"message": {"content": 123}}]},
        {"choices": [{"message": {"images": [{"type": "image_url", "image_url": None}]}}]},
        {"choices": [{"message": {"content": "ok"}}], "usage": None},
    ],
)
def test_malformed_nested_chat_payload_is_controlled_non_retryable_error(payload):
    service = AIProviderService(_make_config())

    with pytest.raises(AIServiceError) as exc_info:
        service._parse_chat_response(payload, "model")

    assert exc_info.value.retryable is False
    assert exc_info.value.error_kind == "hard"


@pytest.mark.asyncio
async def test_chat_truncated_structured_output_raises_instead_of_silent_empty():
    """A strict-JSON response cut off at max_tokens (finish_reason=length) is
    broken JSON; before this guard it parsed to nothing and callers returned
    silent empty results (e.g. zero extracted items on a dense group photo)."""
    from app.core.exceptions import AIServiceError

    service = AIProviderService(_make_config())
    truncated = {
        "choices": [
            {
                "message": {"content": '{"items": [{"name": "sho'},
                "finish_reason": "length",
            }
        ]
    }
    fake_client = _ChatHttpStatusClient([truncated])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(
                messages=[ChatMessage(role="user", content="extract")],
                response_format={"type": "json_object"},
            )

    assert exc_info.value.retryable is False  # retrying truncates identically
    assert "truncated" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_finish_reason_length_ignored_without_response_format():
    """Plain chat (and the max_tokens=10 health probe) may legitimately stop at
    finish_reason=length - only structured-output callers get the guard."""
    service = AIProviderService(_make_config())
    short = {
        "choices": [
            {
                "message": {"content": "pong"},
                "finish_reason": "length",
            }
        ]
    }
    fake_client = _ChatHttpStatusClient([short])

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)), \
         patch("asyncio.sleep", AsyncMock()):
        result = await service.chat(messages=[ChatMessage(role="user", content="hi")])

    assert result.text == "pong"


@pytest.mark.asyncio
async def test_with_retry_respects_should_retry_predicate():
    """Batch extraction uses should_retry so 401 does not burn 4 attempts."""
    from app.core.exceptions import AIServiceError
    from app.utils.retry import with_retry

    calls = {"n": 0}

    async def boom():
        calls["n"] += 1
        raise AIServiceError("AI request failed (401): bad key", retryable=False)

    from app.utils.retry import is_retryable_error

    with pytest.raises(AIServiceError):
        await with_retry(
            boom,
            max_retries=3,
            initial_delay=0.01,
            jitter=False,
            retryable_exceptions=(AIServiceError,),
            should_retry=is_retryable_error,
        )

    assert calls["n"] == 1


@pytest.mark.asyncio
async def test_with_retry_retries_when_should_retry_true():
    from app.core.exceptions import AIServiceError
    from app.utils.retry import with_retry

    calls = {"n": 0}

    async def flaky():
        calls["n"] += 1
        if calls["n"] < 3:
            raise AIServiceError("AI request failed (503): overloaded", retryable=True)
        return "ok"

    from app.utils.retry import is_retryable_error

    with patch("asyncio.sleep", AsyncMock()):
        result = await with_retry(
            flaky,
            max_retries=3,
            initial_delay=0.01,
            jitter=False,
            retryable_exceptions=(AIServiceError,),
            should_retry=is_retryable_error,
        )

    assert result == "ok"
    assert calls["n"] == 3


# ---------------------------------------------------------------------------
# Vision primary -> fallback model routing (chat_with_vision)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_chat_with_vision_falls_back_to_vision_fallback_model_on_retryable_error():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "vision-primary"
    config.vision_fallback_model = "vision-fallback"
    service = AIProviderService(config)

    mock_chat = AsyncMock(
        side_effect=[AIServiceError("overloaded", retryable=True), "sentinel"]
    )
    with patch.object(AIProviderService, "chat", mock_chat):
        result = await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    assert result == "sentinel"
    assert mock_chat.await_args_list[0].kwargs["model"] == "vision-primary"
    assert mock_chat.await_args_list[1].kwargs["model"] == "vision-fallback"


@pytest.mark.asyncio
async def test_chat_with_vision_does_not_fall_back_on_non_retryable_error():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "vision-primary"
    config.vision_fallback_model = "vision-fallback"
    service = AIProviderService(config)

    mock_chat = AsyncMock(side_effect=AIServiceError("bad api key", retryable=False))
    with patch.object(AIProviderService, "chat", mock_chat):
        with pytest.raises(AIServiceError):
            await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    mock_chat.assert_awaited_once()


@pytest.mark.asyncio
async def test_chat_with_vision_does_not_fall_back_when_no_fallback_configured():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "vision-primary"
    config.vision_fallback_model = None
    service = AIProviderService(config)

    mock_chat = AsyncMock(side_effect=AIServiceError("overloaded", retryable=True))
    with patch.object(AIProviderService, "chat", mock_chat):
        with pytest.raises(AIServiceError):
            await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    mock_chat.assert_awaited_once()


@pytest.mark.asyncio
async def test_chat_with_vision_does_not_fall_back_when_fallback_equals_primary():
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "vision-primary"
    config.vision_fallback_model = "vision-primary"
    service = AIProviderService(config)

    mock_chat = AsyncMock(side_effect=AIServiceError("overloaded", retryable=True))
    with patch.object(AIProviderService, "chat", mock_chat):
        with pytest.raises(AIServiceError):
            await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    mock_chat.assert_awaited_once()


@pytest.mark.asyncio
async def test_chat_with_vision_routes_to_per_leg_url_and_key():
    """Each vision leg uses its own url+key, with fallback inheriting vision."""
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "vision-primary"
    config.vision_api_url = "https://vision.example.com/v1"
    config.vision_api_key = "vision-key"
    config.vision_fallback_model = "vision-fallback"
    config.vision_fallback_api_url = "https://visionfb.example.com/v1"
    config.vision_fallback_api_key = "visionfb-key"
    service = AIProviderService(config)

    mock_chat = AsyncMock(
        side_effect=[AIServiceError("overloaded", retryable=True), "sentinel"]
    )
    with patch.object(AIProviderService, "chat", mock_chat):
        result = await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    assert result == "sentinel"
    # Primary vision attempt -> vision url/key
    assert mock_chat.await_args_list[0].kwargs["api_url"] == "https://vision.example.com/v1"
    assert mock_chat.await_args_list[0].kwargs["api_key"] == "vision-key"
    # Fallback attempt -> vision-fallback url/key
    assert mock_chat.await_args_list[1].kwargs["api_url"] == "https://visionfb.example.com/v1"
    assert mock_chat.await_args_list[1].kwargs["api_key"] == "visionfb-key"


@pytest.mark.asyncio
async def test_chat_with_vision_inherits_chat_url_when_vision_url_blank():
    """Vision url/key blank -> inherits the chat api_url/api_key."""
    config = _make_config()
    config.vision_model = "vision-primary"
    # vision_api_url / vision_api_key intentionally unset
    service = AIProviderService(config)

    mock_chat = AsyncMock(return_value="ok")
    with patch.object(AIProviderService, "chat", mock_chat):
        await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    assert mock_chat.await_args_list[0].kwargs["api_url"] == config.api_url
    assert mock_chat.await_args_list[0].kwargs["api_key"] == config.api_key


def test_vision_model_config_defaults():
    """Vision policy defaults: gemini-3.6-flash primary, agnes-2.5-flash fallback.

    Non-vision chat must remain on agnes-2.5-flash.
    """
    from app.core.config import Settings

    fields = Settings.model_fields
    assert fields["AI_VISION_MODEL"].default == "gemini-3.6-flash"
    assert fields["AI_VISION_FALLBACK_MODEL"].default == "agnes-2.5-flash"
    assert fields["AI_CHAT_MODEL"].default == "agnes-2.5-flash"


def test_ai_env_per_leg_url_key_inheritance_defaults():
    """Per-leg url/key fields default to None so they inherit their parent leg."""
    from app.core.config import Settings

    f = Settings.model_fields
    # All per-leg override URLs/keys must default to None (blank) so the
    # inheritance chain resolves them to the CHAT trio when unset.
    for name in (
        "AI_VISION_API_URL", "AI_VISION_API_KEY",
        "AI_VISION_FALLBACK_API_URL", "AI_VISION_FALLBACK_API_KEY",
        "AI_IMAGE_API_URL", "AI_IMAGE_API_KEY",
        "AI_IMAGE_FALLBACK_API_URL", "AI_IMAGE_FALLBACK_API_KEY",
    ):
        assert f[name].default is None, f"{name} should default to None"
    # CHAT root + image model/style carry real defaults.
    assert f["AI_CHAT_API_URL"].default == "https://apihub.agnes-ai.com/v1"
    assert f["AI_IMAGE_API_STYLE"].default == "images"


@pytest.mark.asyncio
async def test_chat_with_vision_falls_back_for_non_openai_host_on_non_retryable_error():
    """A native Google (non-OpenAI) vision URL must fall back on any error.

    gemini-3.6-flash is proxied through Agnes (OpenAI-shaped). If the primary
    vision leg is pointed directly at generativelanguage.googleapis.com it 404s
    on /v1/chat/completions; that 404 is non-retryable, so it must still fall
    through to the configured fallback host instead of 500-ing the request.
    """
    from app.core.exceptions import AIServiceError

    config = _make_config()
    config.vision_model = "gemini-3.6-flash"
    config.vision_api_url = "https://generativelanguage.googleapis.com/v1"
    config.vision_fallback_model = "agnes-2.5-flash"
    config.vision_fallback_api_url = "https://apihub.agnes-ai.com/v1"
    service = AIProviderService(config)

    mock_chat = AsyncMock(
        side_effect=[AIServiceError("404 not found", retryable=False), "sentinel"]
    )
    with patch.object(AIProviderService, "chat", mock_chat):
        result = await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

    assert result == "sentinel"
    assert mock_chat.await_args_list[0].kwargs["api_url"] == "https://generativelanguage.googleapis.com/v1"
    assert mock_chat.await_args_list[1].kwargs["api_url"] == "https://apihub.agnes-ai.com/v1"


class TestHybridGeminiVisionLeg:
    """AI_VISION_PROVIDER=gemini: the vision leg's primary call is routed to
    an internal native GeminiProvider instance, falling back to Agnes (via
    self.chat()) on ANY failure - not just retryable ones. This is the
    permissive semantics the user explicitly chose: the fallback is a
    genuinely different vendor, so even a Gemini safety-block or bad-request
    error is worth retrying against Agnes rather than surfacing immediately.
    """

    @staticmethod
    def _make_hybrid_config() -> ProviderConfig:
        config = _make_config()
        config.vision_provider = AIProvider.GEMINI
        config.vision_gemini_api_key = "gemini-key"
        config.vision_model = "gemini-3.6-flash"
        config.vision_fallback_model = "agnes-2.5-flash"
        config.vision_fallback_api_url = "https://apihub.agnes-ai.com/v1"
        config.vision_fallback_api_key = "agnes-key"
        return config

    @pytest.mark.asyncio
    async def test_primary_gemini_success_never_calls_agnes(self):
        service = AIProviderService(self._make_hybrid_config())
        gemini_response = AIResponse(text="red shirt", model="gemini-3.6-flash", provider="google-genai")
        mock_gemini_chat = AsyncMock(return_value=gemini_response)
        mock_agnes_chat = AsyncMock()

        with patch.object(GeminiProvider, "chat", mock_gemini_chat), \
             patch.object(AIProviderService, "chat", mock_agnes_chat):
            result = await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

        assert result is gemini_response
        mock_gemini_chat.assert_awaited_once()
        mock_agnes_chat.assert_not_awaited()
        assert mock_gemini_chat.await_args.kwargs["model"] == "gemini-3.6-flash"

    @pytest.mark.asyncio
    async def test_permissive_fallback_on_non_retryable_gemini_error(self):
        """Differs from every other fallback path in this file: those only
        retry on e.retryable. Here the fallback is a different vendor, so a
        non-retryable error (e.g. a Gemini safety-block) still falls through."""
        service = AIProviderService(self._make_hybrid_config())
        mock_gemini_chat = AsyncMock(side_effect=AIServiceError("safety block", retryable=False))
        mock_agnes_chat = AsyncMock(return_value="sentinel")

        with patch.object(GeminiProvider, "chat", mock_gemini_chat), \
             patch.object(AIProviderService, "chat", mock_agnes_chat):
            result = await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

        assert result == "sentinel"
        mock_agnes_chat.assert_awaited_once()
        kwargs = mock_agnes_chat.await_args.kwargs
        assert kwargs["model"] == "agnes-2.5-flash"
        assert kwargs["api_url"] == "https://apihub.agnes-ai.com/v1"
        assert kwargs["api_key"] == "agnes-key"

    @pytest.mark.asyncio
    async def test_missing_gemini_api_key_raises_before_any_call(self):
        config = self._make_hybrid_config()
        config.vision_gemini_api_key = None
        service = AIProviderService(config)
        mock_gemini_chat = AsyncMock()
        mock_agnes_chat = AsyncMock()

        with patch.object(GeminiProvider, "chat", mock_gemini_chat), \
             patch.object(AIProviderService, "chat", mock_agnes_chat):
            with pytest.raises(AIServiceError, match="AI_GEMINI_API_KEY"):
                await service.chat_with_vision("describe this outfit", ["aGVsbG8="])

        mock_gemini_chat.assert_not_awaited()
        mock_agnes_chat.assert_not_awaited()

    @pytest.mark.asyncio
    async def test_close_cleans_up_internal_gemini_provider(self):
        service = AIProviderService(self._make_hybrid_config())
        service._get_native_vision_provider()  # force lazy construction
        close_mock = AsyncMock()

        with patch.object(GeminiProvider, "close", close_mock):
            await service.close()

        close_mock.assert_awaited_once()
        assert service._native_vision_provider is None


class TestMaxOutputTokensConfig:
    """The old hardcoded max_tokens=4096 truncated large structured
    extractions and surfaced to users as "finish_reason=length" errors.
    These guard the raised default (32768) and the AI_MAX_OUTPUT_TOKENS env
    override path, so the regression can't silently return."""

    def test_config_field_default_is_raised_above_4096(self):
        """ProviderConfig.max_tokens must default well above the old 4096."""
        cfg = ProviderConfig(api_url="https://x/v1", api_key="k", model="m")
        assert cfg.max_tokens >= 32768

    def test_settings_default_is_32768(self):
        """AI_MAX_OUTPUT_TOKENS ships at 32K (under both providers' >=64K caps)."""
        from app.core.config import Settings

        assert Settings.model_fields["AI_MAX_OUTPUT_TOKENS"].default == 32768

    def test_from_settings_reads_ai_max_output_tokens_for_custom(self):
        """ProviderConfig.from_settings(CUSTOM) must honor the env value,
        not fall back to the hardcoded default."""
        from types import SimpleNamespace

        s = SimpleNamespace(
            AI_CHAT_API_URL="https://apihub.agnes-ai.com/v1",
            AI_CHAT_API_KEY="k",
            AI_CHAT_MODEL="agnes-2.5-flash",
            AI_VISION_API_URL=None,
            AI_VISION_API_KEY=None,
            AI_VISION_MODEL="gemini-3.6-flash",
            AI_VISION_PROVIDER="gemini",
            AI_GEMINI_API_KEY="gk",
            AI_VISION_FALLBACK_API_URL=None,
            AI_VISION_FALLBACK_API_KEY=None,
            AI_VISION_FALLBACK_MODEL="agnes-2.5-flash",
            AI_IMAGE_API_URL=None,
            AI_IMAGE_API_KEY=None,
            AI_IMAGE_MODEL="agnes-image-2.1-flash",
            AI_IMAGE_API_STYLE="images",
            AI_IMAGE_FALLBACK_API_URL=None,
            AI_IMAGE_FALLBACK_API_KEY=None,
            AI_IMAGE_FALLBACK_MODEL="agnes-image-2.0-flash",
            AI_MAX_OUTPUT_TOKENS=16384,
        )
        cfg = ProviderConfig.from_settings(AIProvider.CUSTOM, s)
        assert cfg.max_tokens == 16384

    def test_from_user_dict_inherits_system_ceiling(self):
        """BYOK configs get the same output ceiling as the system config."""
        cfg = ProviderConfig.from_user_dict({"api_url": "https://x/v1"}, api_key="k")
        from app.core.config import settings

        assert cfg.max_tokens == settings.AI_MAX_OUTPUT_TOKENS

    def test_hybrid_vision_gemini_config_inherits_parent_max_tokens(self):
        """Regression: the internal GeminiConfig built for the hybrid vision
        leg used to be constructed with max_tokens unset, pinning native
        Gemini vision at 4096 even after the OpenAI leg was raised. It must
        now inherit the parent ProviderConfig's value."""
        config = _make_config()
        config.max_tokens = 20480
        config.vision_provider = AIProvider.GEMINI
        config.vision_gemini_api_key = "gemini-key"
        service = AIProviderService(config)

        native = service._get_native_vision_provider()
        assert native.config.max_tokens == 20480


# =============================================================================
# Content-policy 400 fallback (2026-08-03 try-on outage class)
# =============================================================================


def _make_config_with_image_fallback() -> ProviderConfig:
    return ProviderConfig(
        api_url="https://llm.example.com/v1",
        api_key="llm-key",
        model="llm-model",
        image_api_url="https://image.example.com/v1",
        image_api_key="image-key",
        image_gen_model="image-model",
        image_api_style="images",
        image_fallback_api_url="https://image-fallback.example.com/v1",
        image_fallback_api_key="image-fallback-key",
        image_fallback_model="fallback-model",
    )


class _ContentRefusalClient:
    """Primary model answers with Agnes's content-policy 400; the fallback
    host answers with a real image."""

    def __init__(self):
        self.urls = []

    async def post(self, url, json=None, headers=None):
        self.urls.append(url)
        if len(self.urls) == 1:
            return httpx.Response(
                400,
                json={"error": {"message": "Unable to generate this content. Please modify your prompt and try again."}},
                request=httpx.Request("POST", url),
            )
        return _FakeResponse({"data": [{"b64_json": "ZmFrZQ=="}]})


def test_is_content_policy_rejection_matches_agnes_refusal():
    service = AIProviderService(_make_config())
    assert (
        service._is_content_policy_rejection(
            400, "Unable to generate this content. Please modify your prompt and try again."
        )
        is True
    )
    assert service._is_content_policy_rejection(400, "Some other provider error") is False
    assert service._is_content_policy_rejection(429, "Unable to generate this content") is False


@pytest.mark.asyncio
async def test_content_policy_400_marks_fallback_eligible_but_not_retryable():
    """A prompt refusal must reach the fallback MODEL (safe - nothing was
    generated/billed) without making the whole agent call retryable (which
    would multiply multi-second generation latency)."""
    service = AIProviderService(_make_config())
    fake_client = _ContentRefusalClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")

    assert exc_info.value.retryable is False
    assert exc_info.value.fallback_eligible is True


@pytest.mark.asyncio
async def test_chat_falls_through_to_fallback_model_on_content_policy_400():
    """Regression for the 2026-08-03 /ai/try-on outage: agnes-image-2.1-flash
    refused the prompt with a 400, and because 400 is not transient the
    fallback model was never tried - every try-on 503'd after ~25s.

    A content-policy refusal still earns the fallback attempt when the fallback
    is a DIFFERENT HOST (this fixture), since another vendor may accept what the
    primary refused and nothing was generated/billed."""
    service = AIProviderService(_make_config_with_image_fallback())
    fake_client = _ContentRefusalClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        result = await service.chat(
            messages=[ChatMessage(role="user", content="a cat")],
            response_modalities=["TEXT", "IMAGE"],
        )

    assert len(fake_client.urls) == 2
    assert fake_client.urls[0].startswith("https://image.example.com")
    assert fake_client.urls[1].startswith("https://image-fallback.example.com")
    assert result.images == ["ZmFrZQ=="]


@pytest.mark.asyncio
async def test_chat_does_not_retry_content_policy_400_on_same_host_fallback():
    """The PRODUCTION shape: primary and fallback image models live on the same
    gateway (agnes-image-2.1-flash -> agnes-image-2.0-flash, both
    apihub.agnes-ai.com), so they share one upstream safety policy. Re-POSTing
    the identical blocked prompt 400s again and costs the user ~double latency
    for the same error, which is exactly what the 2026-08-05 logs showed:

        Image generation request failed (status=400, model=agnes-image-2.1-flash)
        Image generation failed, trying fallback model
        Image generation request failed (status=400, model=agnes-image-2.0-flash)

    Same-host content-policy refusals must therefore raise after ONE attempt.
    Transient 429/503 errors still swap models regardless of host."""
    config = _make_config_with_image_fallback()
    # Same host for primary and fallback - the production topology.
    config.image_fallback_api_url = config.image_api_url
    service = AIProviderService(config)
    fake_client = _ContentRefusalClient()

    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fake_client)):
        with pytest.raises(AIServiceError):
            await service.chat(
                messages=[ChatMessage(role="user", content="a cat")],
                response_modalities=["TEXT", "IMAGE"],
            )

    # Only the primary was attempted; no wasted second call to the same gateway.
    assert len(fake_client.urls) == 1
    assert fake_client.urls[0].startswith("https://image.example.com")
