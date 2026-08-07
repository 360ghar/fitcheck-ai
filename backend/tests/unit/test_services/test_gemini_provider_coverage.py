"""Coverage-completing tests for GeminiProvider.

Sibling to test_gemini_provider.py: this file covers the branches that file
misses - the SSRF host guard's empty-host case, the daily-quota reset epoch
timezone fallback, lazy lock/client creation, the RetryInfo parser's str
failure, remote-image size limits and AVIF conversion, the bare-base64 mime
sniff failure fallback, message-part skipping, the no-candidates response
parse, usage-metadata extraction, and test_connection's generic-error
envelope.
"""

import sys
from types import SimpleNamespace
from unittest.mock import AsyncMock, patch

import pytest

from app.services.ai_provider_interface import ChatMessage
from app.services.gemini_provider import (
    GeminiConfig,
    GeminiProvider,
    _daily_quota_reset_at,
    _daily_quota_reset_epoch,
    _hash_api_key,
    _is_safe_remote_url,
    _parse_retry_delay_seconds,
    clear_daily_quota_latch,
)
import app.services.gemini_provider as gp_module


@pytest.fixture(autouse=True)
def _clear_latch():
    """A daily-quota 429 in one test latches a key and would make later
    calls fail fast; clear the latch before and after each test (mirrors the
    sibling test_gemini_provider.py fixture)."""
    clear_daily_quota_latch()
    yield
    clear_daily_quota_latch()


class _FakeRemoteClient:
    """httpx.AsyncClient stand-in for the remote-image download path."""

    def __init__(self, response=None, *args, **kwargs):
        self._response = response

    def stream(self, *args, **kwargs):
        return self._response

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return None


def _remote_response(headers=None, chunks=()):
    class _Response:
        def raise_for_status(self):
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, *args):
            return None

        async def aiter_bytes(self):
            for chunk in chunks:
                yield chunk

    resp = _Response()
    resp.headers = headers or {}
    return resp


def test_is_safe_remote_url_empty_host_is_refused():
    # Scheme + netloc present, but no hostname -> must be refused.
    assert _is_safe_remote_url("http://:80/x.png") is False


def test_daily_quota_reset_epoch_falls_back_to_utc_without_zoneinfo(monkeypatch):
    monkeypatch.setitem(sys.modules, "zoneinfo", None)
    assert isinstance(_daily_quota_reset_epoch(), float)


@pytest.mark.asyncio
async def test_latch_daily_quota_creates_lock_when_missing(monkeypatch):
    monkeypatch.setattr(gp_module, "_daily_quota_lock", None)
    monkeypatch.setattr(gp_module, "_daily_quota_reset_at", {})
    await gp_module._latch_daily_quota("key-A")
    assert _hash_api_key("key-A") in gp_module._daily_quota_reset_at
    # Point the module back at a fresh dict so nothing latched leaks.
    monkeypatch.setattr(gp_module, "_daily_quota_reset_at", {})


def test_clear_daily_quota_latch_single_key():
    clear_daily_quota_latch()
    _daily_quota_reset_at[_hash_api_key("key-A")] = 123.0
    clear_daily_quota_latch("key-A")
    assert _daily_quota_reset_at == {}


def test_parse_retry_delay_seconds_none_when_str_raises():
    class _BadStr:
        def __str__(self):
            raise RuntimeError("boom")

    assert _parse_retry_delay_seconds(_BadStr()) is None


def test_parse_retry_delay_seconds_none_without_match():
    assert _parse_retry_delay_seconds({"details": "no retry info here"}) is None


def test_get_client_creates_real_sdk_client_once():
    provider = GeminiProvider(GeminiConfig(api_key="test-key"))
    client1 = provider._get_client()
    client2 = provider._get_client()
    assert client1 is client2


@pytest.mark.asyncio
async def test_decode_image_part_rejects_oversized_content_length(monkeypatch):
    monkeypatch.setattr(gp_module, "_MAX_REMOTE_IMAGE_BYTES", 100)
    response = _remote_response(headers={"content-length": "200"}, chunks=(b"x",))
    with patch("app.services.gemini_provider.httpx.AsyncClient", lambda *a, **k: _FakeRemoteClient(response)):
        with pytest.raises(ValueError, match="size limit"):
            await GeminiProvider._decode_image_part("https://remote.example.com/x.png")


@pytest.mark.asyncio
async def test_decode_image_part_rejects_oversized_stream(monkeypatch):
    monkeypatch.setattr(gp_module, "_MAX_REMOTE_IMAGE_BYTES", 100)
    response = _remote_response(chunks=(b"x" * 60, b"y" * 60))
    with patch("app.services.gemini_provider.httpx.AsyncClient", lambda *a, **k: _FakeRemoteClient(response)):
        with pytest.raises(ValueError, match="size limit"):
            await GeminiProvider._decode_image_part("https://remote.example.com/x.png")


@pytest.mark.asyncio
async def test_decode_image_part_converts_avif_to_jpeg():
    response = _remote_response(headers={"content-type": "image/avif"}, chunks=(b"\x00\x00\x00\x18ftypavif",))
    with patch("app.services.gemini_provider.httpx.AsyncClient", lambda *a, **k: _FakeRemoteClient(response)), \
         patch("app.services.gemini_provider.sniff_image_mime_from_magic", return_value="image/avif"), \
         patch("app.services.gemini_provider.ensure_provider_safe_base64", side_effect=lambda s: s):
        part = await GeminiProvider._decode_image_part("https://remote.example.com/x.avif")
    assert part.inline_data.mime_type == "image/jpeg"
    assert part.inline_data.data == b"\x00\x00\x00\x18ftypavif"


@pytest.mark.asyncio
async def test_decode_image_part_bare_base64_sniff_failure_defaults_jpeg():
    import base64

    img = base64.b64encode(b"raw-bytes").decode()
    with patch("app.services.gemini_provider.sniff_image_mime_from_magic", side_effect=RuntimeError("boom")):
        part = await GeminiProvider._decode_image_part(img)
    assert part.inline_data.mime_type == "image/jpeg"
    assert part.inline_data.data == b"raw-bytes"


@pytest.mark.asyncio
async def test_messages_to_contents_skips_invalid_parts():
    messages = [ChatMessage(role="user", content=[
        {"type": "text", "text": "hello"},
        {"type": "image_url", "image_url": {"url": ""}},
        "not-a-dict",
        {"type": "other"},
    ])]
    system, contents = await GeminiProvider._messages_to_contents(messages)
    assert system is None
    assert len(contents) == 1
    assert contents[0].role == "user"
    assert len(contents[0].parts) == 1


def test_parse_response_without_candidates_and_with_usage():
    provider = GeminiProvider(GeminiConfig(api_key="k"))
    response = SimpleNamespace(
        prompt_feedback=None,
        candidates=[],
        parts=[SimpleNamespace(inline_data=None, text="plain answer")],
        text="plain answer",
        usage_metadata=SimpleNamespace(
            prompt_token_count=5, candidates_token_count=3, total_token_count=8,
        ),
        model_dump=lambda: {},
    )
    result = provider._parse_response(response, "gemini-3.6-flash", structured_output_requested=False)
    assert result.text == "plain answer"
    assert result.images is None
    assert result.usage == {"prompt_tokens": 5, "completion_tokens": 3, "total_tokens": 8}


@pytest.mark.asyncio
async def test_test_connection_unexpected_error_envelope():
    provider = GeminiProvider(GeminiConfig(api_key="k"))
    with patch.object(GeminiProvider, "chat", AsyncMock(side_effect=RuntimeError("boom"))):
        result = await provider.test_connection()
    assert result.available is False
    assert result.error_type == "RuntimeError"
    assert "boom" in result.message
