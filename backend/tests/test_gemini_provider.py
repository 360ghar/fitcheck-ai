"""
Tests for GeminiProvider - the native google-genai SDK based provider.

Mocks at the `client.aio.models.generate_content` boundary (not real network),
mirroring how test_ai_provider_service.py mocks httpx for the OpenAI-compatible
provider.
"""

import base64
from types import SimpleNamespace
from unittest.mock import AsyncMock, patch

import pytest
from google.genai import errors as genai_errors
from google.genai import types

from app.core.exceptions import AIServiceError
from app.services.ai_provider_interface import AIProvider, ChatMessage
from app.services.gemini_provider import GeminiConfig, GeminiProvider, classify_gemini_error


def _make_config(**overrides) -> GeminiConfig:
    defaults = dict(api_key="test-key")
    defaults.update(overrides)
    return GeminiConfig(**defaults)


def _fake_response(
    text=None,
    images=None,
    finish_reason=types.FinishReason.STOP,
    block_reason=None,
    usage=None,
):
    """A minimal stand-in for google.genai.types.GenerateContentResponse
    exposing exactly the attributes GeminiProvider._parse_response reads."""
    parts = []
    if images:
        for img_bytes in images:
            parts.append(SimpleNamespace(inline_data=SimpleNamespace(data=img_bytes), text=None))
    candidate = SimpleNamespace(finish_reason=finish_reason)
    return SimpleNamespace(
        prompt_feedback=SimpleNamespace(block_reason=block_reason) if block_reason else None,
        candidates=[candidate],
        text=text,
        parts=parts,
        usage_metadata=usage,
        model_dump=lambda: {},
    )


def _patched_client(provider: GeminiProvider, generate_content):
    """Patches provider._get_client() to return a fake client whose
    aio.models.generate_content is `generate_content` (an AsyncMock or plain
    async callable)."""
    mock_client = SimpleNamespace(aio=SimpleNamespace(models=SimpleNamespace(generate_content=generate_content)))
    return patch.object(provider, "_get_client", return_value=mock_client)


class TestChat:
    @pytest.mark.asyncio
    async def test_plain_text_chat(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="hello"))
        with _patched_client(provider, gen):
            result = await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert result.text == "hello"
        assert result.provider == "google-genai"
        assert gen.call_args.kwargs["model"] == "gemini-3.6-flash"

    @pytest.mark.asyncio
    async def test_system_message_becomes_system_instruction(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="ok"))
        with _patched_client(provider, gen):
            await provider.chat(messages=[
                ChatMessage(role="system", content="Be concise."),
                ChatMessage(role="user", content="hi"),
            ])
        config = gen.call_args.kwargs["config"]
        assert config.system_instruction == "Be concise."
        # System message must not leak into `contents` as its own turn.
        assert len(gen.call_args.kwargs["contents"]) == 1

    @pytest.mark.asyncio
    async def test_assistant_role_maps_to_model(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="ok"))
        with _patched_client(provider, gen):
            await provider.chat(messages=[
                ChatMessage(role="user", content="hi"),
                ChatMessage(role="assistant", content="hello back"),
            ])
        contents = gen.call_args.kwargs["contents"]
        assert contents[0].role == "user"
        assert contents[1].role == "model"

    @pytest.mark.asyncio
    async def test_vision_bare_base64_and_data_url_images(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="a shirt"))
        bare_b64 = base64.b64encode(b"raw-bytes").decode()
        data_url = f"data:image/png;base64,{base64.b64encode(b'png-bytes').decode()}"
        with _patched_client(provider, gen):
            result = await provider.chat_with_vision("describe", [bare_b64, data_url])
        assert result.text == "a shirt"
        contents = gen.call_args.kwargs["contents"]
        image_parts = [p for p in contents[0].parts if p.inline_data is not None]
        assert len(image_parts) == 2
        assert image_parts[0].inline_data.data == b"raw-bytes"
        assert image_parts[0].inline_data.mime_type == "image/jpeg"  # bare base64 defaults to jpeg
        assert image_parts[1].inline_data.data == b"png-bytes"
        assert image_parts[1].inline_data.mime_type == "image/png"

    @pytest.mark.asyncio
    async def test_generate_image_sets_response_modalities(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(images=[b"imgbytes"]))
        with _patched_client(provider, gen):
            result = await provider.generate_image("a shirt on white background")
        assert result.images == [base64.b64encode(b"imgbytes").decode()]
        config = gen.call_args.kwargs["config"]
        assert config.response_modalities == ["TEXT", "IMAGE"]
        assert gen.call_args.kwargs["model"] == "gemini-3.1-flash-image"

    @pytest.mark.asyncio
    async def test_generate_image_with_reference_image(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(images=[b"out"]))
        ref = base64.b64encode(b"ref-bytes").decode()
        with _patched_client(provider, gen):
            await provider.generate_image("try this on", reference_image=ref)
        contents = gen.call_args.kwargs["contents"]
        assert any(p.inline_data is not None for p in contents[0].parts)


class TestResponseFormatMapping:
    @pytest.mark.asyncio
    async def test_json_object_maps_to_mime_type_without_schema(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="{}"))
        with _patched_client(provider, gen):
            await provider.chat(
                messages=[ChatMessage(role="user", content="hi")],
                response_format={"type": "json_object"},
            )
        config = gen.call_args.kwargs["config"]
        assert config.response_mime_type == "application/json"
        assert config.response_schema is None

    @pytest.mark.asyncio
    async def test_json_schema_also_maps_to_mime_type_without_schema(self):
        """v1 does not translate OpenAI json_schema contracts to Gemini's
        response_schema (incompatible schema dialects) - guard against a
        future change silently reintroducing this without reading the note."""
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="{}"))
        with _patched_client(provider, gen):
            await provider.chat(
                messages=[ChatMessage(role="user", content="hi")],
                response_format={"type": "json_schema", "json_schema": {"name": "x", "schema": {}}},
            )
        config = gen.call_args.kwargs["config"]
        assert config.response_mime_type == "application/json"
        assert config.response_schema is None

    @pytest.mark.asyncio
    async def test_image_modalities_take_precedence_over_response_format(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(images=[b"x"]))
        with _patched_client(provider, gen):
            await provider.chat(
                messages=[ChatMessage(role="user", content="hi")],
                response_modalities=["TEXT", "IMAGE"],
                response_format={"type": "json_object"},
            )
        config = gen.call_args.kwargs["config"]
        assert config.response_modalities == ["TEXT", "IMAGE"]
        assert config.response_mime_type is None


class TestErrorClassification:
    @pytest.mark.asyncio
    @pytest.mark.parametrize("code", [408, 429, 500, 502, 503, 504])
    async def test_transient_status_codes_are_retryable(self, code):
        provider = GeminiProvider(_make_config())
        err = genai_errors.APIError(code, {"message": "transient"})
        gen = AsyncMock(side_effect=err)
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert exc_info.value.retryable is True

    @pytest.mark.asyncio
    @pytest.mark.parametrize("code", [400, 401, 403, 404])
    async def test_permanent_status_codes_are_not_retryable(self, code):
        provider = GeminiProvider(_make_config())
        err = genai_errors.APIError(code, {"message": "permanent"})
        gen = AsyncMock(side_effect=err)
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert exc_info.value.retryable is False


class TestFreeTierQuotaClassification:
    """The whole point of classify_gemini_error: split a daily free-tier quota
    (pointless to retry today -> forces the Agnes fallback) from a per-minute
    quota (retryable after the advised delay) from a 503 overload."""

    def test_free_tier_daily_quota_is_not_retryable_and_forces_fallback(self):
        # Mirrors the real payload: quotaId ...PerDay...FreeTier, no retryDelay.
        err = genai_errors.APIError(429, {
            "status": "RESOURCE_EXHAUSTED",
            "message": (
                "You exceeded your current quota. Quota exceeded for metric "
                "generativelanguage.googleapis.com/generate_content_free_tier_requests, "
                "limit: 20, model: gemini-3.6-flash. "
                "GenerateRequestsPerDayPerProjectPerModel-FreeTier"
            ),
            "details": [{"@type": "type.googleapis.com/google.rpc.QuotaFailure"}],
        })
        retryable, error_kind, retry_after = classify_gemini_error(err)
        assert retryable is False
        assert error_kind == "upstream_quota"
        assert retry_after is None

    def test_free_tier_per_minute_quota_is_retryable_after_advised_delay(self):
        err = genai_errors.APIError(429, {
            "status": "RESOURCE_EXHAUSTED",
            "message": (
                "Quota exceeded for generativelanguage.googleapis.com/"
                "generate_content_free_tier_requests, limit: 5. "
                "GenerateRequestsPerMinutePerProjectPerModel-FreeTier"
            ),
            "details": [{"@type": "type.googleapis.com/google.rpc.RetryInfo", "retryDelay": "56s"}],
        })
        retryable, error_kind, retry_after = classify_gemini_error(err)
        assert retryable is True
        assert error_kind == "upstream_quota"
        assert retry_after == 56

    def test_per_minute_quota_retry_delay_with_decimal_seconds_is_parsed(self):
        """Live Gemini quota errors carry sub-second precision - the observed
        prod payload said 'Please retry in 30.857471809s'. The parser must
        handle decimal seconds, not just the integer '56s' form."""
        err = genai_errors.APIError(429, {
            "status": "RESOURCE_EXHAUSTED",
            "message": (
                "Quota exceeded for generativelanguage.googleapis.com/"
                "generate_content_free_tier_requests, limit: 5. "
                "GenerateRequestsPerMinutePerProjectPerModel-FreeTier"
            ),
            "details": [
                {"@type": "type.googleapis.com/google.rpc.RetryInfo", "retryDelay": "30.857471809s"},
            ],
        })
        retryable, error_kind, retry_after = classify_gemini_error(err)
        assert retryable is True
        assert error_kind == "upstream_quota"
        assert retry_after == pytest.approx(30.857471809)

    def test_503_unavailable_is_transient_retryable(self):
        err = genai_errors.APIError(503, {
            "status": "UNAVAILABLE",
            "message": "This model is currently experiencing high demand.",
        })
        retryable, error_kind, retry_after = classify_gemini_error(err)
        assert retryable is True
        assert error_kind == "transient"
        assert retry_after is None

    def test_hard_4xx_is_neither_retryable_nor_quota(self):
        err = genai_errors.APIError(403, {"message": "Permission denied"})
        retryable, error_kind, retry_after = classify_gemini_error(err)
        assert retryable is False
        assert error_kind == "hard"

    @pytest.mark.asyncio
    async def test_daily_quota_error_propagates_through_chat_as_upstream_quota(self):
        """The chat() handler must stamp error_kind/retryable onto the raised
        AIServiceError so the SSE/HTTP layer can show 'try again shortly'."""
        provider = GeminiProvider(_make_config())
        err = genai_errors.APIError(429, {
            "status": "RESOURCE_EXHAUSTED",
            "message": "free_tier limit: 20 GenerateRequestsPerDayPerProjectPerModel-FreeTier",
        })
        gen = AsyncMock(side_effect=err)
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert exc_info.value.retryable is False
        assert exc_info.value.error_kind == "upstream_quota"
        body = exc_info.value.to_dict()
        assert body["retryable"] is False
        assert body["error_kind"] == "upstream_quota"


class TestSafetyAndTruncationGuards:
    @pytest.mark.asyncio
    async def test_prompt_blocked_raises_non_retryable(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(block_reason="SAFETY"))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert exc_info.value.retryable is False

    @pytest.mark.asyncio
    async def test_response_blocked_by_finish_reason_raises_non_retryable(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(finish_reason=types.FinishReason.SAFETY))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert exc_info.value.retryable is False

    @pytest.mark.asyncio
    async def test_max_tokens_with_structured_output_raises(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(finish_reason=types.FinishReason.MAX_TOKENS))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.chat(
                    messages=[ChatMessage(role="user", content="hi")],
                    response_format={"type": "json_object"},
                )
        assert exc_info.value.retryable is False
        assert "truncated" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_max_tokens_without_structured_output_does_not_raise(self):
        """A plain-text vision answer can legitimately stop at MAX_TOKENS
        without being 'broken' the way a cut-off JSON payload is."""
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(
            text="a long answer that got cut off", finish_reason=types.FinishReason.MAX_TOKENS,
        ))
        with _patched_client(provider, gen):
            result = await provider.chat(messages=[ChatMessage(role="user", content="hi")])
        assert result.text == "a long answer that got cut off"


class TestVisionFallback:
    @pytest.mark.asyncio
    async def test_falls_back_on_retryable_error(self):
        config = _make_config(vision_fallback_model="gemini-2.5-flash")
        provider = GeminiProvider(config)

        call_count = {"n": 0}

        async def gen(**kwargs):
            call_count["n"] += 1
            if call_count["n"] == 1:
                raise genai_errors.APIError(503, {"message": "overloaded"})
            return _fake_response(text="fallback worked")

        with _patched_client(provider, gen):
            result = await provider.chat_with_vision("describe", ["aGVsbG8="])
        assert result.text == "fallback worked"
        assert call_count["n"] == 2

    @pytest.mark.asyncio
    async def test_does_not_fall_back_on_non_retryable_error(self):
        config = _make_config(vision_fallback_model="gemini-2.5-flash")
        provider = GeminiProvider(config)
        gen = AsyncMock(side_effect=genai_errors.APIError(400, {"message": "bad request"}))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError):
                await provider.chat_with_vision("describe", ["aGVsbG8="])
        assert gen.await_count == 1

    @pytest.mark.asyncio
    async def test_no_fallback_configured_raises_immediately(self):
        provider = GeminiProvider(_make_config())  # vision_fallback_model=None
        gen = AsyncMock(side_effect=genai_errors.APIError(503, {"message": "overloaded"}))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError):
                await provider.chat_with_vision("describe", ["aGVsbG8="])
        assert gen.await_count == 1


class TestConfigResolution:
    def test_get_image_gen_model_resolves_to_configured_value(self):
        provider = GeminiProvider(_make_config(image_gen_model="custom-image-model"))
        assert provider.get_image_gen_model() == "custom-image-model"

    def test_vision_model_falls_back_to_chat_model(self):
        config = _make_config(chat_model="gemini-3.6-flash", vision_model=None)
        assert config.get_vision_model() == "gemini-3.6-flash"

    def test_vision_model_explicit_override(self):
        config = _make_config(vision_model="gemini-3-pro-preview")
        assert config.get_vision_model() == "gemini-3-pro-preview"

    def test_from_settings_returns_none_without_api_key(self):
        fake_settings = SimpleNamespace(AI_GEMINI_API_KEY=None)
        assert GeminiConfig.from_settings(AIProvider.GEMINI, fake_settings) is None

    def test_from_settings_builds_config(self):
        fake_settings = SimpleNamespace(
            AI_GEMINI_API_KEY="k",
            AI_GEMINI_CHAT_MODEL="gemini-3.6-flash",
            AI_GEMINI_VISION_MODEL=None,
            AI_GEMINI_VISION_FALLBACK_MODEL=None,
            AI_GEMINI_IMAGE_MODEL="gemini-3.1-flash-image",
            AI_GEMINI_IMAGE_FALLBACK_MODEL=None,
        )
        config = GeminiConfig.from_settings(AIProvider.GEMINI, fake_settings)
        assert config.api_key == "k"
        assert config.chat_model == "gemini-3.6-flash"

    def test_max_tokens_default_is_raised_above_4096(self):
        """GeminiConfig.max_tokens must default well above the old 4096 cap
        that truncated large structured extractions."""
        assert GeminiConfig(api_key="k").max_tokens >= 32768

    def test_from_settings_reads_ai_max_output_tokens(self):
        """from_settings must honor AI_MAX_OUTPUT_TOKENS when present."""
        fake_settings = SimpleNamespace(
            AI_GEMINI_API_KEY="k",
            AI_GEMINI_CHAT_MODEL="gemini-3.6-flash",
            AI_GEMINI_VISION_MODEL=None,
            AI_GEMINI_VISION_FALLBACK_MODEL=None,
            AI_GEMINI_IMAGE_MODEL="gemini-3.1-flash-image",
            AI_GEMINI_IMAGE_FALLBACK_MODEL=None,
            AI_MAX_OUTPUT_TOKENS=16384,
        )
        config = GeminiConfig.from_settings(AIProvider.GEMINI, fake_settings)
        assert config.max_tokens == 16384

    def test_from_user_dict_reads_only_understood_keys(self):
        config = GeminiConfig.from_user_dict(
            {"model": "gemini-3.6-flash", "vision_model": "gemini-3-pro-preview"},
            api_key="user-key",
        )
        assert config.api_key == "user-key"
        assert config.chat_model == "gemini-3.6-flash"
        assert config.vision_model == "gemini-3-pro-preview"

    def test_from_user_dict_ignores_stale_pre_migration_018_openai_shaped_row(self):
        """A BYOK 'gemini' row saved before commit 74ce4d2 removed Gemini as
        an OpenAI-compatible provider would be shaped like {api_url,
        api_key_encrypted, model} - api_url must simply be ignored (not
        misread as if it meant something), so the stale row is harmless
        rather than actively wrong."""
        stale_row = {
            "api_url": "https://generativelanguage.googleapis.com/v1beta",
            "api_key_encrypted": "irrelevant-already-decrypted-by-caller",
            "model": "gemini-3-flash-preview",
        }
        config = GeminiConfig.from_user_dict(stale_row, api_key="decrypted-key")
        assert config.api_key == "decrypted-key"
        assert config.chat_model == "gemini-3-flash-preview"
        assert not hasattr(config, "api_url")


class TestLifecycle:
    @pytest.mark.asyncio
    async def test_close_calls_aio_aclose_and_clears_client(self):
        provider = GeminiProvider(_make_config())
        provider._client = SimpleNamespace(aio=SimpleNamespace(aclose=AsyncMock()))
        client_ref = provider._client
        await provider.close()
        client_ref.aio.aclose.assert_awaited_once()
        assert provider._client is None

    @pytest.mark.asyncio
    async def test_close_is_a_noop_when_never_used(self):
        provider = GeminiProvider(_make_config())
        await provider.close()  # must not raise

    @pytest.mark.asyncio
    async def test_test_connection_success(self):
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(return_value=_fake_response(text="OK"))
        with _patched_client(provider, gen):
            result = await provider.test_connection()
        assert result.success is True
        assert result.response == "OK"
        assert result.available is True

    @pytest.mark.asyncio
    async def test_test_connection_failure_propagates_domain_error(self):
        """Domain errors (AIServiceError) must propagate from test_connection
        rather than being flattened into a failure envelope, so callers can
        branch on retryable/classification."""
        provider = GeminiProvider(_make_config())
        gen = AsyncMock(side_effect=genai_errors.APIError(401, {"message": "invalid key"}))
        with _patched_client(provider, gen):
            with pytest.raises(AIServiceError) as exc_info:
                await provider.test_connection()
        assert exc_info.value.retryable is False
