"""Coverage-completing tests for AIProviderService.

Sibling to test_ai_provider_service.py: this file exercises the branches that
file misses - config resolution helpers (from_settings/from_user_dict/
get_default_provider), the real HTTP client construction path, the
_call_with_retry_and_fallback loop mechanics (fall-through between attempts),
chat()'s health fail-fast and error-classification handlers, the multimodal
response parser branches, the hybrid native-Gemini vision leg failure paths,
and the module-level get_ai_service() convenience factory.

All network boundaries are faked: httpx clients are patched, the health
service is stubbed via the module-level get_health_service() (the same seam
chat()/images-api use at call time), and retry sleeps are patched out.
"""

import base64
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import httpx
import pytest

from app.core.config import settings
from app.core.exceptions import AIServiceError
from app.services.ai_provider_health_service import HealthStatus
from app.services.ai_provider_interface import (
    AIProvider,
    AIResponse,
    ChatMessage,
    PROVIDER_REGISTRY,
    get_provider_class,
)
from app.services.ai_provider_service import (
    AIProviderService,
    ProviderConfig,
    get_ai_service,
    get_default_provider,
)
from app.services.gemini_provider import GeminiProvider


def _make_config(**overrides) -> ProviderConfig:
    defaults = dict(
        api_url="https://llm.example.com/v1",
        api_key="llm-key",
        model="llm-model",
        image_api_url="https://image.example.com/v1",
        image_api_key="image-key",
        image_gen_model="image-model",
    )
    defaults.update(overrides)
    return ProviderConfig(**defaults)


class _FakeResponse:
    """Minimal httpx.Response stand-in with json/text/status/headers."""

    def __init__(self, payload, status_code=200, text=None, headers=None):
        self._payload = payload
        self.status_code = status_code
        self.text = text if text is not None else str(payload)
        self.headers = headers or {}

    def raise_for_status(self):
        if self.status_code >= 400:
            request = httpx.Request("POST", "https://llm.example.com/v1/chat/completions")
            response = httpx.Response(
                self.status_code, request=request, json=self._payload, headers=self.headers
            )
            raise httpx.HTTPStatusError(f"HTTP {self.status_code}", request=request, response=response)

    def json(self):
        return self._payload


def _http_status_error(status: int, message: str) -> httpx.HTTPStatusError:
    request = httpx.Request("POST", "https://llm.example.com/v1/chat/completions")
    response = httpx.Response(status, request=request, json={"error": {"message": message}})
    return httpx.HTTPStatusError(f"HTTP {status}", request=request, response=response)


class _RaisingClient:
    """Client whose post() raises a fixed exception."""

    def __init__(self, exc):
        self._exc = exc

    async def post(self, url, json=None, headers=None):
        raise self._exc


def _attempt_dict() -> dict:
    return {
        "req_payload": {},
        "url": "https://x.example.com/v1/chat/completions",
        "api_key": "k",
        "client": None,
        "base_url": "https://x.example.com/v1",
    }


@pytest.fixture(autouse=True)
def _healthy_health_service():
    """Stub the module-level health-service singleton the provider service
    imports at call time (see chat()/_generate_image_via_images_api)."""
    status = HealthStatus(available=True, last_check=0, consecutive_failures=0)
    fake = SimpleNamespace(
        check_provider_health=AsyncMock(return_value=status),
        clear_cache=Mock(),
    )
    with patch("app.services.ai_provider_health_service.get_health_service", return_value=fake):
        yield fake


# =============================================================================
# ProviderConfig resolution helpers
# =============================================================================


def test_from_settings_openai_builds_full_config():
    s = SimpleNamespace(
        AI_OPENAI_API_KEY="openai-key",
        AI_OPENAI_API_URL="https://api.openai.com/v1",
        AI_OPENAI_CHAT_MODEL="gpt-4o-mini",
        AI_OPENAI_VISION_MODEL="gpt-4o",
        AI_OPENAI_IMAGE_MODEL="dall-e-3",
        AI_MAX_OUTPUT_TOKENS=8192,
    )
    cfg = ProviderConfig.from_settings(AIProvider.OPENAI, s)
    assert cfg.api_url == "https://api.openai.com/v1"
    assert cfg.api_key == "openai-key"
    assert cfg.model == "gpt-4o-mini"
    assert cfg.vision_model == "gpt-4o"
    assert cfg.image_gen_model == "dall-e-3"
    assert cfg.max_tokens == 8192


def test_from_settings_openai_missing_key_returns_none():
    assert ProviderConfig.from_settings(AIProvider.OPENAI, SimpleNamespace(AI_OPENAI_API_KEY=None)) is None


def test_from_settings_unknown_provider_returns_none():
    # Gemini has its own GeminiConfig - ProviderConfig must decline to build one.
    assert ProviderConfig.from_settings(AIProvider.GEMINI, SimpleNamespace()) is None


def test_get_default_provider_invalid_value_falls_back_to_custom(monkeypatch):
    monkeypatch.setattr(settings, "AI_DEFAULT_PROVIDER", "not-a-provider")
    assert get_default_provider() == AIProvider.CUSTOM


# =============================================================================
# Client lifecycle and URL/payload helpers
# =============================================================================


@pytest.mark.asyncio
async def test_get_client_builds_pooled_http_client_once():
    captured = {}

    class _FakeAsyncClient:
        def __init__(self, **kwargs):
            captured.update(kwargs)

    service = AIProviderService(_make_config())
    with patch("app.services.ai_provider_service.httpx.AsyncClient", _FakeAsyncClient):
        client1 = await service._get_client()
        client2 = await service._get_client()

    assert client1 is client2
    assert captured["headers"]["Authorization"] == "Bearer llm-key"
    assert captured["http2"] is False
    assert captured["timeout"].connect == 5.0
    assert captured["timeout"].read == 120.0
    assert captured["limits"].max_connections == 100
    assert captured["limits"].max_keepalive_connections == 20
    # The fake client has no aclose(); detach it so close() is not exercised.
    service._client = None


@pytest.mark.asyncio
async def test_close_closes_http_client():
    service = AIProviderService(_make_config())
    client = SimpleNamespace(aclose=AsyncMock())
    service._client = client
    await service.close()
    client.aclose.assert_awaited_once()
    assert service._client is None


def test_get_image_gen_model_delegates_to_config():
    service = AIProviderService(_make_config(image_gen_model="custom-image-model"))
    assert service.get_image_gen_model() == "custom-image-model"


def test_build_url_variants():
    service = AIProviderService(_make_config())
    assert (
        service._build_url("https://x.example.com/v1/chat/completions", "chat/completions")
        == "https://x.example.com/v1/chat/completions"
    )
    assert (
        service._build_url("https://x.example.com/v1", "chat/completions")
        == "https://x.example.com/v1/chat/completions"
    )
    assert (
        service._build_url("https://x.example.com/v1/", "chat/completions")
        == "https://x.example.com/v1/chat/completions"
    )
    assert (
        service._build_url("https://x.example.com", "chat/completions")
        == "https://x.example.com/v1/chat/completions"
    )
    assert service._build_chat_url() == "https://llm.example.com/v1/chat/completions"
    assert service._build_images_url() == "https://image.example.com/v1/images/generations"


def test_extract_prompt_and_images_mixed_content():
    messages = [
        ChatMessage(role="user", content="first"),
        ChatMessage(role="user", content=[
            {"type": "text", "text": "second"},
            {"type": "image_url", "image_url": {"url": "img1"}},
            {"type": "image_url", "image_url": {"url": ""}},
            "not-a-dict",
            {"type": "other"},
        ]),
        ChatMessage(role="user", content=[{"type": "image_url", "image_url": {"url": "img2"}}]),
    ]
    prompt, images = AIProviderService._extract_prompt_and_images(messages)
    assert prompt == "first\nsecond"
    assert images == ["img1", "img2"]


def test_format_exception_message_with_and_without_detail():
    assert AIProviderService._format_exception_message(ValueError("bad")) == "ValueError: bad"
    assert AIProviderService._format_exception_message(ValueError("   ")) == "ValueError"


def test_retry_delay_seconds_profile_and_cap():
    with patch("app.services.ai_provider_service.random.random", return_value=0.0):
        assert AIProviderService._retry_delay_seconds(0) == pytest.approx(0.5)
        assert AIProviderService._retry_delay_seconds(1) == pytest.approx(0.75)
        assert AIProviderService._retry_delay_seconds(20) == pytest.approx(5.0)


def test_http_retry_delay_seconds_prefers_retry_after():
    service = AIProviderService(_make_config())
    assert service._http_retry_delay_seconds(_FakeResponse({}, headers={"Retry-After": "7"}), 0) == 7.0
    assert service._http_retry_delay_seconds(_FakeResponse({}, headers={"Retry-After": "120"}), 0) == 30.0


def test_http_retry_delay_seconds_falls_back_on_bad_or_missing_header():
    service = AIProviderService(_make_config())
    with patch("app.services.ai_provider_service.random.random", return_value=0.0):
        assert service._http_retry_delay_seconds(_FakeResponse({}, headers={"Retry-After": "abc"}), 1) == pytest.approx(0.75)
        assert service._http_retry_delay_seconds(_FakeResponse({}), 1) == pytest.approx(0.75)


def test_http_error_detail_extracts_provider_message():
    service = AIProviderService(_make_config())
    assert service._http_error_detail(_FakeResponse({"error": {"message": "boom"}})) == "boom"
    assert service._http_error_detail(_FakeResponse({"error": "plain"})) == "plain"
    assert service._http_error_detail(_FakeResponse({"error": None})) == str({"error": None})
    assert service._http_error_detail(_FakeResponse(["a", "b"])) == str(["a", "b"])


def test_http_error_detail_falls_back_to_text_on_parse_failure():
    service = AIProviderService(_make_config())

    class _BadJsonResponse:
        text = "raw-body"

        def json(self):
            raise ValueError("no json")

    assert service._http_error_detail(_BadJsonResponse()) == "raw-body"


# =============================================================================
# _execute_chat_attempt transport handling
# =============================================================================


@pytest.mark.asyncio
async def test_execute_chat_attempt_connect_error_clears_health_cache(_healthy_health_service):
    service = AIProviderService(_make_config())
    attempt = dict(_attempt_dict(), client=_RaisingClient(httpx.ConnectError("refused")))
    with pytest.raises(httpx.ConnectError):
        await service._execute_chat_attempt(attempt)
    _healthy_health_service.clear_cache.assert_called_once_with("https://x.example.com/v1")


@pytest.mark.asyncio
async def test_execute_chat_attempt_protocol_error_rebuilds_client():
    service = AIProviderService(_make_config())
    attempt = dict(_attempt_dict(), client=_RaisingClient(httpx.LocalProtocolError(11)))
    fresh = Mock()
    with patch.object(service, "close", AsyncMock()) as close_mock, \
         patch.object(AIProviderService, "_get_client", AsyncMock(return_value=fresh)):
        with pytest.raises(httpx.LocalProtocolError):
            await service._execute_chat_attempt(attempt)
    close_mock.assert_awaited_once()
    assert attempt["client"] is fresh


@pytest.mark.asyncio
async def test_execute_chat_attempt_transient_error_reraises():
    service = AIProviderService(_make_config())
    attempt = dict(_attempt_dict(), client=_RaisingClient(httpx.ReadError("reset")))
    with pytest.raises(httpx.ReadError):
        await service._execute_chat_attempt(attempt)


# =============================================================================
# _call_with_retry_and_fallback loop mechanics
# =============================================================================


@pytest.mark.asyncio
async def test_call_with_retry_reraises_aiservice_error():
    service = AIProviderService(_make_config())
    with patch.object(
        AIProviderService, "_execute_chat_attempt",
        AsyncMock(side_effect=AIServiceError("boom")),
    ):
        with pytest.raises(AIServiceError, match="boom"):
            await service._call_with_retry_and_fallback([_attempt_dict()])


@pytest.mark.asyncio
async def test_call_with_retry_overload_falls_through_then_raises():
    service = AIProviderService(_make_config())
    overload = service._TransientChatAPIOverload("status=429: rate limited")
    with patch.object(
        AIProviderService, "_execute_chat_attempt",
        AsyncMock(side_effect=overload),
    ), patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service._call_with_retry_and_fallback([_attempt_dict(), _attempt_dict()])
    assert exc_info.value.retryable is True
    assert "429" in str(exc_info.value)


@pytest.mark.asyncio
async def test_call_with_retry_http_status_continues_then_raises():
    service = AIProviderService(_make_config())
    with patch.object(
        AIProviderService, "_execute_chat_attempt",
        AsyncMock(side_effect=[
            _http_status_error(503, "overloaded"),
            _http_status_error(401, "bad key"),
        ]),
    ), patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service._call_with_retry_and_fallback([_attempt_dict(), _attempt_dict()])
    assert exc_info.value.retryable is False
    assert exc_info.value.provider_status == 401


@pytest.mark.asyncio
async def test_call_with_retry_transport_continues_then_raises():
    service = AIProviderService(_make_config())
    with patch.object(
        AIProviderService, "_execute_chat_attempt",
        AsyncMock(side_effect=httpx.ReadError("reset")),
    ), patch("asyncio.sleep", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await service._call_with_retry_and_fallback([_attempt_dict(), _attempt_dict()])
    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_call_with_retry_unexpected_exception_is_non_retryable():
    service = AIProviderService(_make_config())
    with patch.object(
        AIProviderService, "_execute_chat_attempt", AsyncMock(side_effect=KeyError("k"))
    ):
        with pytest.raises(AIServiceError) as exc_info:
            await service._call_with_retry_and_fallback([_attempt_dict()])
    assert exc_info.value.retryable is False


@pytest.mark.asyncio
async def test_call_with_retry_no_attempts_raises_default():
    service = AIProviderService(_make_config())
    with pytest.raises(AIServiceError, match="All AI chat attempts failed"):
        await service._call_with_retry_and_fallback([])


# =============================================================================
# chat() health fail-fast and error-classification handlers
# =============================================================================


@pytest.mark.asyncio
async def test_chat_fails_fast_when_provider_unhealthy(_healthy_health_service):
    service = AIProviderService(_make_config())
    _healthy_health_service.check_provider_health.return_value = HealthStatus(
        available=False, last_check=0, consecutive_failures=2,
        error="Connection error: ConnectError",
    )
    with pytest.raises(AIServiceError) as exc_info:
        await service.chat(messages=[ChatMessage(role="user", content="hi")])
    assert exc_info.value.retryable is True
    assert "unavailable" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_structured_output_finish_reason_stop_not_truncated():
    class _Client:
        async def post(self, url, json=None, headers=None):
            return _FakeResponse({
                "choices": [{"message": {"content": '{"ok": true}'}, "finish_reason": "stop"}],
            })

    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=_Client())):
        result = await service.chat(
            messages=[ChatMessage(role="user", content="json")],
            response_format={"type": "json_object"},
        )
    assert result.text == '{"ok": true}'


@pytest.mark.asyncio
async def test_chat_http_status_error_surfaces_aiservice_error():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=_http_status_error(503, "busy")),
         ):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])
    assert exc_info.value.retryable is True
    assert exc_info.value.provider_status == 503
    assert "busy" in str(exc_info.value)


@pytest.mark.asyncio
async def test_chat_response_format_rejected_then_fallback_succeeds():
    service = AIProviderService(_make_config())
    err = _http_status_error(400, "response_format is not supported by this gateway")
    ok_payload = ({"choices": [{"message": {"content": "fallback text"}}]}, 200)
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=[err, ok_payload]),
         ):
        result = await service.chat(
            messages=[ChatMessage(role="user", content="json")],
            response_format={"type": "json_object"},
        )
    assert result.text == "fallback text"


@pytest.mark.asyncio
async def test_chat_response_format_rejected_then_fallback_also_rejected():
    service = AIProviderService(_make_config())
    err = _http_status_error(400, "response_format is not supported by this gateway")
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=[err, err]),
         ):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(
                messages=[ChatMessage(role="user", content="json")],
                response_format={"type": "json_object"},
            )
    assert exc_info.value.provider_status == 400


@pytest.mark.asyncio
async def test_chat_aiservice_error_with_response_format_not_retried_when_generic():
    service = AIProviderService(_make_config())
    err = AIServiceError(
        "AI request failed (400): generic",
        retryable=False, provider_status=400, provider_error_detail="generic",
    )
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback", AsyncMock(side_effect=err),
         ):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(
                messages=[ChatMessage(role="user", content="json")],
                response_format={"type": "json_object"},
            )
    assert exc_info.value.provider_status == 400


@pytest.mark.asyncio
async def test_chat_aiservice_error_propagates_without_response_format():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=AIServiceError("boom")),
         ):
        with pytest.raises(AIServiceError, match="boom"):
            await service.chat(messages=[ChatMessage(role="user", content="hi")])


@pytest.mark.asyncio
async def test_chat_transport_error_after_retries_is_retryable():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=httpx.ReadError("connection reset")),
         ):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])
    assert exc_info.value.retryable is True
    assert "transport" in str(exc_info.value).lower()


@pytest.mark.asyncio
async def test_chat_unexpected_error_is_non_retryable():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=Mock())), \
         patch.object(
             AIProviderService, "_call_with_retry_and_fallback",
             AsyncMock(side_effect=ValueError("bad payload")),
         ):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat(messages=[ChatMessage(role="user", content="hi")])
    assert exc_info.value.retryable is False
    assert "bad payload" in str(exc_info.value)


# =============================================================================
# _parse_chat_response branches
# =============================================================================


def test_parse_chat_response_non_dict_object_is_malformed():
    service = AIProviderService(_make_config())
    with pytest.raises(AIServiceError) as exc_info:
        service._parse_chat_response(["not", "a", "dict"], "model")
    assert exc_info.value.retryable is False
    assert exc_info.value.error_kind == "hard"


def test_parse_chat_response_missing_message_is_malformed():
    service = AIProviderService(_make_config())
    with pytest.raises(AIServiceError, match="message is missing or invalid"):
        service._parse_chat_response({"choices": [{"content": "x"}]}, "model")


def test_parse_chat_response_multimodal_content_and_message_images():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{
            "message": {
                "content": [
                    {"type": "text", "text": "here"},
                    {"type": "image_url", "image_url": {"url": "data:image/png;base64,AAAA"}},
                    {"type": "image", "inline_data": {"data": "QkJD"}},
                ],
                "images": [
                    {"type": "image_url", "image_url": {"url": "data:image/png;base64,BBBB"}},
                    {"type": "image_url", "image_url": {"url": "https://cdn.example.com/x.png"}},
                    {"type": "other"},
                ],
            },
        }],
        "usage": {"prompt_tokens": 1, "completion_tokens": 2, "total_tokens": 3},
    }
    result = service._parse_chat_response(data, "model", "https://provider.example.com")
    assert result.text == "here"
    assert result.images == ["AAAA", "QkJD", "BBBB", "https://cdn.example.com/x.png"]
    assert result.usage == {"prompt_tokens": 1, "completion_tokens": 2, "total_tokens": 3}
    assert result.provider == "https://provider.example.com"


def test_parse_chat_response_data_url_without_base64_segment_appends_raw():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{"message": {
            "content": [{"type": "image_url", "image_url": {"url": "data:image/png,RAW"}}],
        }}],
    }
    result = service._parse_chat_response(data, "model")
    assert result.images == ["data:image/png,RAW"]


def test_parse_chat_response_plain_url_content_part_appends_url():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{"message": {
            "content": [{"type": "image_url", "image_url": {"url": "https://cdn.example.com/x.png"}}],
        }}],
    }
    result = service._parse_chat_response(data, "model")
    assert result.images == ["https://cdn.example.com/x.png"]


def test_parse_chat_response_other_content_part_types_are_skipped():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{"message": {
            "content": [
                {"type": "text", "text": "keep"},
                {"type": "other"},
                {"type": "image", "inline_data": {"data": ""}},
            ],
        }}],
    }
    result = service._parse_chat_response(data, "model")
    assert result.text == "keep"
    assert result.images is None


def test_parse_chat_response_message_images_data_url_without_base64():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{"message": {
            "content": None,
            "images": [{"type": "image_url", "image_url": {"url": "data:image/png,RAW"}}],
        }}],
    }
    result = service._parse_chat_response(data, "model")
    assert result.images == ["data:image/png,RAW"]


def test_parse_chat_response_message_images_only_extracts_images():
    service = AIProviderService(_make_config())
    data = {
        "choices": [{"message": {
            "content": None,
            "images": [{"type": "image_url", "image_url": {"url": "data:image/png;base64,y"}}],
        }}],
    }
    result = service._parse_chat_response(data, "model")
    assert result.text is None
    assert result.images == ["y"]


@pytest.mark.parametrize(
    "payload,expected",
    [
        # content list with a non-dict part
        ({"choices": [{"message": {"content": [123]}}]}, "content part is invalid"),
        # text part with non-str text
        ({"choices": [{"message": {"content": [{"type": "text", "text": 123}]}}]}, "text content is invalid"),
        # image_url part whose image_url is not a dict
        ({"choices": [{"message": {"content": [{"type": "image_url", "image_url": None}]}}]}, "image_url content is invalid"),
        # image_url part whose url is not a string
        ({"choices": [{"message": {"content": [{"type": "image_url", "image_url": {"url": 123}}]}}]}, "image URL is invalid"),
        # "image" part with non-dict inline_data
        ({"choices": [{"message": {"content": [{"type": "image", "inline_data": None}]}}]}, "inline image data is invalid"),
        # "image" part with non-str inline data
        ({"choices": [{"message": {"content": [{"type": "image", "inline_data": {"data": 123}}]}}]}, "inline image data is invalid"),
        # non-list/non-str content
        ({"choices": [{"message": {"content": 123}}]}, "message content is invalid"),
        # message images not a list
        ({"choices": [{"message": {"content": "x", "images": "junk"}}]}, "images is invalid"),
        # message image entry not a dict
        ({"choices": [{"message": {"content": "x", "images": [123]}}]}, "image entry is invalid"),
        # message image_url entry with non-dict image_url
        ({"choices": [{"message": {"content": "x", "images": [{"type": "image_url", "image_url": None}]}}]}, "image_url image entry is invalid"),
        # message image_url entry with non-str url
        ({"choices": [{"message": {"content": "x", "images": [{"type": "image_url", "image_url": {"url": 123}}]}}]}, "image URL is invalid"),
        # no content and no images
        ({"choices": [{"message": {"content": None, "images": []}}]}, "message has no content or images"),
        # usage present but not a dict
        ({"choices": [{"message": {"content": "x"}}], "usage": None}, "usage is invalid"),
    ],
)
def test_parse_chat_response_malformed_nested_branches(payload, expected):
    service = AIProviderService(_make_config())
    with pytest.raises(AIServiceError, match=expected):
        service._parse_chat_response(payload, "model")


def test_should_retry_without_response_format():
    service = AIProviderService(_make_config())
    assert service._should_retry_without_response_format(400, "response_format is not supported") is True
    assert service._should_retry_without_response_format(422, "invalid json_schema contract") is True
    assert service._should_retry_without_response_format(400, "generic error") is False
    assert service._should_retry_without_response_format(500, "response_format") is False


# =============================================================================
# Hybrid native-Gemini vision leg failure paths
# =============================================================================


def test_get_native_vision_provider_caches_instance():
    config = _make_config()
    config.vision_provider = AIProvider.GEMINI
    config.vision_gemini_api_key = "gemini-key"
    service = AIProviderService(config)
    first = service._get_native_vision_provider()
    second = service._get_native_vision_provider()
    assert first is second
    assert first.config.api_key == "gemini-key"


@pytest.mark.asyncio
async def test_native_gemini_vision_no_fallback_raises():
    config = _make_config()
    config.vision_provider = AIProvider.GEMINI
    config.vision_gemini_api_key = "gemini-key"
    service = AIProviderService(config)
    with patch.object(GeminiProvider, "chat", AsyncMock(side_effect=AIServiceError("gemini down"))):
        with pytest.raises(AIServiceError, match="gemini down"):
            await service.chat_with_vision("describe", ["aGVsbG8="])


@pytest.mark.asyncio
async def test_native_gemini_vision_both_legs_fail_combine_error():
    config = _make_config()
    config.vision_provider = AIProvider.GEMINI
    config.vision_gemini_api_key = "gemini-key"
    config.vision_fallback_model = "agnes-2.5-flash"
    config.vision_fallback_api_url = "https://apihub.agnes-ai.com/v1"
    service = AIProviderService(config)
    primary_err = AIServiceError("quota", retryable=False, error_kind="upstream_quota")
    fallback_err = AIServiceError("overloaded", retryable=True, retry_after_seconds=12)
    with patch.object(GeminiProvider, "chat", AsyncMock(side_effect=primary_err)), \
         patch.object(AIProviderService, "chat", AsyncMock(side_effect=fallback_err)):
        with pytest.raises(AIServiceError) as exc_info:
            await service.chat_with_vision("describe", ["aGVsbG8="])
    assert exc_info.value.retryable is True
    assert exc_info.value.error_kind == "upstream_quota"
    assert exc_info.value.retry_after_seconds == 12
    assert "both failed" in str(exc_info.value)


# =============================================================================
# generate_image / images-api edge branches
# =============================================================================


@pytest.mark.asyncio
async def test_generate_image_without_reference_uses_text_prompt():
    service = AIProviderService(_make_config())
    mock_chat = AsyncMock(return_value=AIResponse(text=None, images=["x"], model="image-model"))
    with patch.object(AIProviderService, "chat", mock_chat):
        result = await service.generate_image("a cat")
    assert result.images == ["x"]
    call = mock_chat.await_args
    assert call.kwargs["response_modalities"] == ["TEXT", "IMAGE"]
    assert call.kwargs["messages"][0].content == "a cat"


@pytest.mark.asyncio
async def test_generate_image_via_images_api_fails_fast_when_unhealthy(_healthy_health_service):
    service = AIProviderService(_make_config())
    _healthy_health_service.check_provider_health.return_value = HealthStatus(
        available=False, last_check=0, consecutive_failures=1, error="Status 503",
    )
    with pytest.raises(AIServiceError) as exc_info:
        await service._generate_image_via_images_api("a cat", model="image-model")
    assert exc_info.value.retryable is True
    assert "unavailable" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_image_via_images_api_json_parse_failure_is_not_retryable():
    class _BadJsonClient:
        async def post(self, url, json=None, headers=None):
            response = _FakeResponse({})
            response.json = lambda: (_ for _ in ()).throw(ValueError("no json"))
            return response

    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=_BadJsonClient())):
        with pytest.raises(AIServiceError) as exc_info:
            await service._generate_image_via_images_api("a cat", model="image-model")
    assert exc_info.value.retryable is False


@pytest.mark.asyncio
async def test_generate_image_via_images_api_downloads_url_assets():
    class _AssetResponse:
        content = b"img-bytes"

        def raise_for_status(self):
            pass

    class _AssetClient:
        def __init__(self, *args, **kwargs):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return None

        async def get(self, url):
            return _AssetResponse()

    class _PostingClient:
        async def post(self, url, json=None, headers=None):
            return _FakeResponse({
                "data": [
                    {"url": "https://cdn.example.com/a.png"},
                    {"b64_json": "Zm9v"},
                    # Neither b64_json nor url -> skipped by the loop.
                    {"type": "ignored"},
                ],
            })

    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "_get_client", AsyncMock(return_value=_PostingClient())), \
         patch("app.services.ai_provider_service.httpx.AsyncClient", _AssetClient):
        result = await service._generate_image_via_images_api("a cat", model="image-model")

    assert result.images == [base64.b64encode(b"img-bytes").decode(), "Zm9v"]


# =============================================================================
# test_connection envelope branches
# =============================================================================


@pytest.mark.asyncio
async def test_test_connection_success():
    service = AIProviderService(_make_config())
    with patch.object(
        AIProviderService, "chat",
        AsyncMock(return_value=AIResponse(text="OK", model="m")),
    ):
        result = await service.test_connection()
    assert result.available is True
    assert result.model == "m"
    assert result.response == "OK"
    assert "successful" in result.message.lower()


@pytest.mark.asyncio
async def test_test_connection_http_error_envelope():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "chat", AsyncMock(side_effect=ValueError("bad"))):
        result = await service.test_connection()
    assert result.available is False
    assert result.error_type == "ValueError"


@pytest.mark.asyncio
async def test_test_connection_unexpected_error_envelope():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "chat", AsyncMock(side_effect=RuntimeError("boom"))):
        result = await service.test_connection()
    assert result.available is False
    assert result.error_type == "RuntimeError"
    assert "boom" in result.message


@pytest.mark.asyncio
async def test_test_connection_propagates_aiservice_error():
    service = AIProviderService(_make_config())
    with patch.object(AIProviderService, "chat", AsyncMock(side_effect=AIServiceError("down"))):
        with pytest.raises(AIServiceError, match="down"):
            await service.test_connection()


# =============================================================================
# get_ai_service convenience factory
# =============================================================================


@pytest.mark.asyncio
async def test_get_ai_service_user_config_override_wins():
    svc = await get_ai_service(
        provider=AIProvider.CUSTOM,
        user_config={
            "custom": {
                "api_key": "user-key",
                "api_url": "https://my-proxy.example.com/v1",
                "model": "my-model",
            },
        },
    )
    assert isinstance(svc, AIProviderService)
    assert svc.config.api_url == "https://my-proxy.example.com/v1"
    assert svc.config.api_key == "user-key"
    assert svc.config.model == "my-model"
    await svc.close()


@pytest.mark.asyncio
async def test_get_ai_service_incomplete_user_config_falls_back_to_system(monkeypatch):
    monkeypatch.setattr(settings, "AI_OPENAI_API_KEY", "system-key")
    # api_key present but api_url missing -> from_user_dict returns None.
    svc = await get_ai_service(
        provider=AIProvider.OPENAI,
        user_config={"openai": {"api_key": "user-key", "model": "m"}},
    )
    assert isinstance(svc, AIProviderService)
    assert svc.config.api_key == "system-key"
    assert svc.config.api_url == "https://api.openai.com/v1"
    await svc.close()


@pytest.mark.asyncio
async def test_get_ai_service_user_config_without_api_key_falls_back_to_system():
    # Entry present but no api_key -> user override skipped entirely.
    svc = await get_ai_service(
        provider=AIProvider.CUSTOM,
        user_config={"custom": {"api_url": "https://my-proxy.example.com/v1", "model": "m"}},
    )
    assert isinstance(svc, AIProviderService)
    assert svc.config.api_url == settings.AI_CHAT_API_URL
    await svc.close()


@pytest.mark.asyncio
async def test_get_ai_service_missing_system_config_raises(monkeypatch):
    monkeypatch.setattr(settings, "AI_OPENAI_API_KEY", None)
    with pytest.raises(AIServiceError, match="not configured"):
        await get_ai_service(provider=AIProvider.OPENAI)


@pytest.mark.asyncio
async def test_get_ai_service_default_provider_resolution(monkeypatch):
    monkeypatch.setattr(settings, "AI_DEFAULT_PROVIDER", "openai")
    monkeypatch.setattr(settings, "AI_OPENAI_API_KEY", "sys-key")
    svc = await get_ai_service()
    assert isinstance(svc, AIProviderService)
    assert svc.config.api_key == "sys-key"
    await svc.close()


def test_get_provider_class_fails_closed_when_unregistered():
    """A provider missing from the registry (e.g. an implementation that
    failed to import) must fail closed with a clear error, not return None."""
    saved = dict(PROVIDER_REGISTRY)
    try:
        PROVIDER_REGISTRY.clear()
        with pytest.raises(AIServiceError, match="No provider implementation registered"):
            get_provider_class(AIProvider.OPENAI)
    finally:
        PROVIDER_REGISTRY.clear()
        PROVIDER_REGISTRY.update(saved)
