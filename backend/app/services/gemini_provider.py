"""
Native Google Gemini provider - chat/vision/image via the async google-genai
SDK (client.aio.models.generate_content), not the OpenAI-compatible HTTP path
in ai_provider_service.py.

Why a separate implementation instead of another ProviderConfig/api_url entry:
Google's Generative Language API authenticates via an `x-goog-api-key` header
and speaks a request/response shape (`generate_content`, `types.Part`,
`response_schema`) that has nothing in common with the OpenAI-compatible
Bearer-auth /v1/chat/completions contract. A prior attempt at "Gemini support"
(removed in commit 74ce4d2) sent Gemini requests through that same
OpenAI-shaped HTTP client and never really worked because of exactly this
mismatch. This implementation talks to Google's SDK directly and satisfies the
same AIProviderClient interface every other provider does.
"""

import asyncio
import base64
import hashlib
import ipaddress
import re
import time
from urllib.parse import urlparse

import httpx
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional, Tuple

from google import genai
from google.genai import errors as genai_errors
from google.genai import types

from app.core.exceptions import AIServiceError
from app.core.logging_config import get_context_logger
from app.core.config import settings
from app.models.ai import HealthCheckResult
from app.utils.image_processing import ensure_provider_safe_base64, sniff_image_mime_from_magic
from app.services.ai_provider_interface import (
    AIProvider,
    AIResponse,
    ChatMessage,
    build_user_multimodal_messages,
    register_provider,
)

logger = get_context_logger(__name__)

# Remote image references are downloaded only at this provider boundary because
# google-genai's Part.from_uri accepts provider-managed file URIs (for example
# gs://), not arbitrary presigned HTTPS URLs. Keep this bounded so a malformed
# or hostile URL cannot make a request consume unbounded memory.
_MAX_REMOTE_IMAGE_BYTES = 10 * 1024 * 1024
_REMOTE_IMAGE_TIMEOUT = httpx.Timeout(20.0, connect=5.0)

# Host suffixes that must never be fetched from the backend: cloud metadata
# (``*.internal``), mDNS (``*.local``) and the loopback name itself.
_PRIVATE_URL_HOST_SUFFIX_RE = re.compile(r"(?:^|\.)(?:local|internal|localhost)$", re.IGNORECASE)


def _is_safe_remote_url(url: str) -> bool:
    """Refuse provider fetches of URLs that could target internal networks.

    This boundary downloads http(s) image URLs (avatars, chat image parts).
    A caller-supplied URL must never make the backend reach loopback,
    link-local (``169.254.x``), RFC1918 private ranges, multicast or cloud
    metadata hosts. Literal IP addresses are range-checked; bare hostnames are
    allowed (DNS-rebinding protection is out of scope for this guard). The
    configured object-storage endpoint is always allowed: it serves our own
    presigned URLs, and local development points it at a private MinIO-like
    endpoint.
    """
    parsed = urlparse(url)
    if parsed.scheme not in ("http", "https") or not parsed.netloc:
        return False
    host = parsed.hostname or ""
    if not host:
        return False
    # The configured object-storage endpoint is always allowed: it serves our
    # own presigned URLs, and local development points it at a private
    # MinIO-like endpoint. Compared on full netloc (host[:port]) so a
    # look-alike on another port of the same host is still refused.
    storage_netloc = urlparse(settings.OBJECT_STORAGE_ENDPOINT).netloc
    if storage_netloc and parsed.netloc == storage_netloc:
        return True
    if _PRIVATE_URL_HOST_SUFFIX_RE.search(host):
        return False
    try:
        ip = ipaddress.ip_address(host)
    except ValueError:
        # A DNS name, not a literal address.
        return True
    return not (
        ip.is_private
        or ip.is_loopback
        or ip.is_link_local
        or ip.is_multicast
        or ip.is_reserved
        or ip.is_unspecified
    )


# =============================================================================
# Daily-quota circuit breaker
# =============================================================================
# Free-tier Gemini keys (observed: limit 20/day on gemini-3.6-flash) exhaust
# their DAILY cap for hours at a time. Once the provider tells us the daily
# quota is gone, every further request is guaranteed to 429 until the cap
# resets, so attempting the call is pure waste: the hybrid vision leg should
# fall over to Agnes immediately (zero wasted Gemini calls) and other callers
# should fail fast with a friendly "try again later" instead of hammering
# Google for the rest of the day.
#
# The latch is keyed by API-key hash so one BYOK user's free-tier key cannot
# trip the latch for users on a different (paid) key. It is a process-local
# optimization only: a wrong latch at worst skips Gemini for one day, and the
# first call after the reset re-trips it if the cap is still exhausted.
_daily_quota_reset_at: Dict[str, float] = {}
_daily_quota_lock: Optional[asyncio.Lock] = None


def _hash_api_key(api_key: str) -> str:
    """Short SHA-256 of the API key for latch keys (never log the key)."""
    return hashlib.sha256(api_key.encode()).hexdigest()[:16]


def _daily_quota_reset_epoch() -> float:
    """Epoch seconds of the next daily-quota reset.

    Google's free-tier daily quotas reset at midnight Pacific Time; fall back
    to midnight UTC if the system has no IANA timezone data. An early/late
    unlatch is self-healing: the next real 429 simply re-trips the latch.
    """
    try:
        from zoneinfo import ZoneInfo

        tz = ZoneInfo("America/Los_Angeles")
    except Exception:
        tz = timezone.utc
    now = datetime.now(tz)
    nxt = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
    return nxt.timestamp()


async def _is_daily_quota_latched(api_key: str) -> bool:
    """True when this key's daily quota is latched and the reset has not
    passed. Expired latches are cleared lazily on read."""
    global _daily_quota_lock
    if _daily_quota_lock is None:
        _daily_quota_lock = asyncio.Lock()
    key = _hash_api_key(api_key)
    async with _daily_quota_lock:
        reset_at = _daily_quota_reset_at.get(key)
        if reset_at is None:
            return False
        if time.time() >= reset_at:
            _daily_quota_reset_at.pop(key, None)
            return False
        return True


async def _latch_daily_quota(api_key: str) -> None:
    """Record that this key's daily quota is exhausted until the next reset."""
    global _daily_quota_lock
    if _daily_quota_lock is None:
        _daily_quota_lock = asyncio.Lock()
    key = _hash_api_key(api_key)
    reset_at = _daily_quota_reset_epoch()
    async with _daily_quota_lock:
        _daily_quota_reset_at[key] = reset_at


def clear_daily_quota_latch(api_key: Optional[str] = None) -> None:
    """Clear the daily-quota latch for one key (or all keys when omitted).
    Exposed for tests and for ops after a key is upgraded to a paid tier."""
    if api_key is None:
        _daily_quota_reset_at.clear()
        return
    _daily_quota_reset_at.pop(_hash_api_key(api_key), None)


# Default Gemini model names. Referenced from the GeminiConfig field defaults
# AND the from_settings/from_user_dict fallbacks, so a model bump is one edit
# instead of a find-and-replace across three sites each.
DEFAULT_GEMINI_CHAT_MODEL = "gemini-3.6-flash"
DEFAULT_GEMINI_IMAGE_MODEL = "gemini-3.1-flash-image"

# Shared output ceiling (also used by ProviderConfig). gemini-3.6-flash supports
# up to 64K output tokens, so 32K is a safe default well under the cap.
DEFAULT_MAX_OUTPUT_TOKENS = settings.AI_MAX_OUTPUT_TOKENS


@dataclass
class GeminiConfig:
    """Configuration for the native Gemini provider.

    No per-leg URLs (unlike ProviderConfig) - there is nothing to inherit or
    override; the SDK always talks directly to Google's endpoint, so the only
    per-leg knobs are model names.
    """
    api_key: str
    chat_model: str = DEFAULT_GEMINI_CHAT_MODEL
    vision_model: Optional[str] = None            # inherits chat_model when blank
    vision_fallback_model: Optional[str] = None    # Gemini-to-Gemini fallback only
    image_gen_model: str = DEFAULT_GEMINI_IMAGE_MODEL
    image_fallback_model: Optional[str] = None
    max_tokens: int = DEFAULT_MAX_OUTPUT_TOKENS
    # Requests per minute allowed through this provider instance; 0 = unlimited.
    # Free-tier Gemini keys are limited to ~5 rpm per model - bursts of
    # concurrent extractions exhaust the quota in one second (observed
    # 2026-08-01: 8 parallel 429 RESOURCE_EXHAUSTED). When set, chat() spaces
    # requests so the hybrid vision leg falls back to Agnes while the bucket
    # refills instead of hammering the quota with retries.
    max_requests_per_minute: int = 0

    def get_vision_model(self) -> str:
        """Get the vision model, falling back to the default chat model."""
        return self.vision_model or self.chat_model

    def get_image_gen_model(self) -> str:
        """Get the image generation model (has its own default, unlike chat/vision)."""
        return self.image_gen_model

    @classmethod
    def from_settings(cls, provider: AIProvider, s) -> Optional["GeminiConfig"]:
        """System-level default configuration, read from AI_GEMINI_* settings."""
        api_key = getattr(s, "AI_GEMINI_API_KEY", None)
        if not api_key:
            return None
        return cls(
            api_key=api_key,
            chat_model=getattr(s, "AI_GEMINI_CHAT_MODEL", None) or DEFAULT_GEMINI_CHAT_MODEL,
            vision_model=getattr(s, "AI_GEMINI_VISION_MODEL", None) or None,
            vision_fallback_model=getattr(s, "AI_GEMINI_VISION_FALLBACK_MODEL", None) or None,
            image_gen_model=getattr(s, "AI_GEMINI_IMAGE_MODEL", None) or DEFAULT_GEMINI_IMAGE_MODEL,
            image_fallback_model=getattr(s, "AI_GEMINI_IMAGE_FALLBACK_MODEL", None) or None,
            max_tokens=getattr(s, "AI_MAX_OUTPUT_TOKENS", DEFAULT_MAX_OUTPUT_TOKENS),
            max_requests_per_minute=getattr(s, "AI_GEMINI_MAX_REQUESTS_PER_MINUTE", 0) or 0,
        )

    @classmethod
    def from_user_dict(cls, raw: Dict[str, Any], api_key: str) -> "GeminiConfig":
        """BYOK configuration - reads ONLY the keys this config understands
        (model/vision_model/image_gen_model/*_fallback_model) and ignores
        everything else. A stale pre-migration-018 "gemini" BYOK row (which
        was OpenAI-shaped: api_url, api_key_encrypted) becomes harmless rather
        than wrong, since api_url is simply never read here."""
        return cls(
            api_key=api_key,
            chat_model=raw.get("model") or DEFAULT_GEMINI_CHAT_MODEL,
            vision_model=raw.get("vision_model"),
            vision_fallback_model=raw.get("vision_fallback_model"),
            image_gen_model=raw.get("image_gen_model") or DEFAULT_GEMINI_IMAGE_MODEL,
            image_fallback_model=raw.get("image_fallback_model"),
            # BYOK configs inherit the same output ceiling as the system config.
            max_tokens=raw.get("max_tokens") or DEFAULT_MAX_OUTPUT_TOKENS,
            max_requests_per_minute=raw.get("max_requests_per_minute") or 0,
        )

    @classmethod
    def for_test(cls, api_key: str, model: str, api_url: str) -> "GeminiConfig":
        """Minimal config for the 'Test connection' endpoint. ``api_url`` is
        accepted for signature parity with ``ProviderConfig.for_test`` but is
        not used - Gemini has no per-config URL (the SDK talks to Google
        directly), so only the key + a model name are needed."""
        return cls(api_key=api_key, chat_model=model)


_TRANSIENT_CODES = frozenset({408, 429, 500, 502, 503, 504})


def _parse_retry_delay_seconds(details: Any) -> Optional[float]:
    """Extract the advised retry delay (seconds) from a Gemini APIError payload.

    RESOURCE_EXHAUSTED responses carry a google.rpc.RetryInfo whose retryDelay
    is a Go duration string - protobuf Duration serializes to decimal seconds,
    e.g. "56s" or the sub-second-precision form seen in real quota errors,
    "30.857471809s". ``details`` is the raw response_json the SDK stored on the
    error; str() it and scan rather than recursing the nested dict shape, which
    varies across SDK versions.
    """
    try:
        text = str(details or "")
    except Exception:
        return None
    # Match either JSON ("retryDelay": "56s") or Python dict repr
    # ('retryDelay': '30.857471809s') - the SDK stores the parsed dict, so str()
    # yields single-quoted repr, but defend against a JSON string form too.
    # Decimal seconds are required, not optional: the live Gemini quota errors
    # carry sub-second precision ("Please retry in 30.857471809s").
    match = re.search(r"retryDelay[\"']?\s*:\s*[\"']?(\d+(?:\.\d+)?)\s*s", text)
    return float(match.group(1)) if match else None


def classify_gemini_error(e: Exception) -> Tuple[bool, Optional[str], Optional[float]]:
    """Bucket a google-genai APIError into (retryable, error_kind, retry_after_seconds).

    Why this exists: the SDK exposes code/status/message/details, but the old
    handler looked only at ``e.code`` and collapsed a daily free-tier quota
    (pointless to retry today), a per-minute quota (retryable after ~60s), and a
    503 overload into the same retryable flag. Splitting them lets the caller
    fall over to the configured fallback immediately for daily quota, back off
    for per-minute/transient, and fail fast for auth/parse errors.

    error_kind values (surfaced to the UI via AIServiceError.to_dict()):
      - "upstream_quota": provider free-tier/billing quota exhausted. This is
        "on us" (the server's key), NOT the user's plan limit, so the UI shows
        "try again shortly", never an upgrade prompt.
      - "transient": 5xx overload / timeout. Retryable.
      - "hard": 4xx auth/content/parse. Not retryable.
    """
    code = getattr(e, "code", None)
    status_str = (getattr(e, "status", None) or "")
    message = (getattr(e, "message", None) or "")
    details = getattr(e, "details", None)
    combined = f"{message} {details}".lower()
    # Normalise so "PerDay" / "Per-Day" / "Per_Day" all match a single token.
    combined_compact = combined.replace("_", "").replace("-", "")

    is_quota = code == 429 or status_str == "RESOURCE_EXHAUSTED"
    if is_quota:
        retry_after = _parse_retry_delay_seconds(details)
        # A daily quota will not reset until tomorrow, so retrying Gemini is
        # futile -> not retryable, which forces the configured fallback provider
        # (Agnes) to take over immediately instead of burning the retry.
        if "perday" in combined_compact:
            return (False, "upstream_quota", None)
        # Per-minute quota (or indeterminate): retryable after the advised delay.
        return (True, "upstream_quota", retry_after)

    if code in _TRANSIENT_CODES or status_str == "UNAVAILABLE":
        return (True, "transient", None)

    return (False, "hard", None)


# finish_reason values that mean the response was blocked, not just short.
_BLOCKED_FINISH_REASONS = (
    types.FinishReason.SAFETY,
    types.FinishReason.PROHIBITED_CONTENT,
    types.FinishReason.RECITATION,
    types.FinishReason.BLOCKLIST,
    types.FinishReason.SPII,
)


@register_provider(AIProvider.GEMINI)
class GeminiProvider:
    """Native Gemini provider, implementing the AIProviderClient interface."""

    config_cls = GeminiConfig

    def __init__(self, config: GeminiConfig):
        self.config = config
        # Lazy, one client per instance - NOT cached/shared by API key. BYOK
        # means per-user keys, and callers (photoshoot_service.py, demo.py)
        # call `await ai_service.close()` in `finally` blocks; a client shared
        # across instances would get torn down by one caller while another is
        # still using it.
        self._client: Optional[genai.Client] = None
        # Rate-limiting state (see _wait_for_rate_slot). Lock is created
        # lazily so provider construction never binds to an event loop.
        self._rate_lock: Optional[asyncio.Lock] = None
        self._next_allowed_at: float = 0.0

    async def _wait_for_rate_slot(self) -> None:
        """Space requests to `max_requests_per_minute` when configured
        (0 = unlimited). The wait happens BEFORE the request is sent, so a
        burst of concurrent extractions cannot slam a free-tier quota in one
        second (observed 2026-08-01: 8 parallel 429 RESOURCE_EXHAUSTED);
        callers that exceed the bucket simply back off and the hybrid vision
        leg falls back to Agnes while they wait."""
        rpm = self.config.max_requests_per_minute
        if rpm <= 0:
            return
        interval = 60.0 / rpm
        if self._rate_lock is None:
            self._rate_lock = asyncio.Lock()
        async with self._rate_lock:
            now = time.monotonic()
            wait = self._next_allowed_at - now
            if wait > 0:
                await asyncio.sleep(wait)
            self._next_allowed_at = max(now, self._next_allowed_at) + interval

    def _get_client(self) -> genai.Client:
        if self._client is None:
            self._client = genai.Client(api_key=self.config.api_key)
        return self._client

    @staticmethod
    async def _decode_image_part(img: str) -> types.Part:
        """Build a Gemini Part from legacy base64 or a remote HTTP(S) URL.

        ``Part.from_uri`` is for URIs already understood by Google's file API;
        it does not fetch arbitrary presigned HTTPS URLs. Download those here,
        asynchronously and with a hard byte limit, then send inline bytes.
        """
        parsed = urlparse(img)
        if parsed.scheme in ("http", "https") and parsed.netloc:
            if not _is_safe_remote_url(img):
                raise ValueError("Remote image URL is not fetchable by the provider boundary")
            data = bytearray()
            async with httpx.AsyncClient(timeout=_REMOTE_IMAGE_TIMEOUT, follow_redirects=True) as client:
                async with client.stream("GET", img) as response:
                    response.raise_for_status()
                    content_length = response.headers.get("content-length")
                    if content_length and int(content_length) > _MAX_REMOTE_IMAGE_BYTES:
                        raise ValueError("Remote image exceeds Gemini provider size limit")
                    async for chunk in response.aiter_bytes():
                        data.extend(chunk)
                        if len(data) > _MAX_REMOTE_IMAGE_BYTES:
                            raise ValueError("Remote image exceeds Gemini provider size limit")
            raw = bytes(data)
            mime_type = sniff_image_mime_from_magic(raw[:96]) or response.headers.get("content-type", "").split(";", 1)[0] or "image/jpeg"
            # Keep the existing AVIF/HEIF provider safety behavior. This path
            # necessarily makes transient base64 copies only for those formats.
            if mime_type in ("image/avif", "image/heif", "image/heic"):
                safe = ensure_provider_safe_base64(base64.b64encode(raw).decode())
                raw = base64.b64decode(safe.partition(",")[-1] if safe.startswith("data:") else safe)
                mime_type = "image/jpeg"
            return types.Part.from_bytes(data=raw, mime_type=mime_type)

        img = ensure_provider_safe_base64(img)
        if img.startswith("data:"):
            header, _, b64_data = img.partition(",")
            mime_type = header[5:].split(";")[0] or "image/jpeg"
        else:
            b64_data = img
            mime_type = None
        data = base64.b64decode(b64_data)
        if mime_type is None:
            try:
                head = base64.b64decode(b64_data[:96])
                mime_type = sniff_image_mime_from_magic(head) or "image/jpeg"
            except Exception:
                mime_type = "image/jpeg"
        return types.Part.from_bytes(data=data, mime_type=mime_type)

    @classmethod
    async def _messages_to_contents(
        cls, messages: List[ChatMessage]
    ) -> "tuple[Optional[str], List[types.Content]]":
        """Translate the shared ChatMessage shape (str or list of
        {"type": "text"|"image_url", ...} dicts, OpenAI-style) into Gemini's
        `contents` list plus an optional `system_instruction` string - Gemini
        has no "system" role inside `contents`, and uses "model" rather than
        "assistant" for the model's own turns."""
        system_parts: List[str] = []
        contents: List[types.Content] = []

        for message in messages:
            content = message.content
            parts: List[types.Part] = []
            text_parts: List[str] = []

            if isinstance(content, str):
                parts.append(types.Part.from_text(text=content))
                text_parts.append(content)
            else:
                for part in content:
                    if not isinstance(part, dict):
                        continue
                    if part.get("type") == "text":
                        text = part.get("text", "")
                        parts.append(types.Part.from_text(text=text))
                        text_parts.append(text)
                    elif part.get("type") == "image_url":
                        url = part.get("image_url", {}).get("url", "")
                        if url:
                            parts.append(await cls._decode_image_part(url))

            if message.role == "system":
                system_parts.extend(t for t in text_parts if t)
                continue

            role = "model" if message.role == "assistant" else message.role
            contents.append(types.Content(role=role, parts=parts))

        system_instruction = "\n".join(system_parts) if system_parts else None
        return system_instruction, contents

    async def chat(
        self,
        messages: List[ChatMessage],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: float = 0.7,
        response_modalities: Optional[List[str]] = None,
        response_format: Optional[Dict[str, Any]] = None,
    ) -> AIResponse:
        # Fail fast (before building a request) when this key's DAILY quota is
        # known-exhausted: the call is guaranteed to 429, and the hybrid
        # vision leg will fall back to Agnes with zero wasted Gemini calls.
        # Per-minute quota is NOT latched - it clears in seconds and the rate
        # limiter + retry metadata already handle it.
        if await _is_daily_quota_latched(self.config.api_key):
            raise AIServiceError(
                "Gemini daily quota exhausted; using the configured fallback "
                "provider until the quota resets",
                retryable=False,
                error_kind="upstream_quota",
            )
        await self._wait_for_rate_slot()
        client = self._get_client()
        use_model = model or self.config.chat_model
        system_instruction, contents = await self._messages_to_contents(messages)

        is_image_request = bool(response_modalities and "IMAGE" in response_modalities)
        # No response_schema translation in v1 - every current caller passes
        # either {"type": "json_object"} or a json_schema contract designed
        # for OpenAI's structured-output shape, which doesn't map cleanly onto
        # Gemini's OpenAPI-3.0-subset schema (e.g. ["string","null"] unions,
        # additionalProperties: false are both invalid there). Both request
        # shapes get the weaker but always-valid `response_mime_type` instead;
        # callers already tolerantly parse JSON-ish text (see
        # photoshoot_service.py's own manual JSON-retry loop).
        wants_json = bool(response_format and response_format.get("type") in ("json_object", "json_schema"))

        config_kwargs: Dict[str, Any] = {
            "max_output_tokens": max_tokens or self.config.max_tokens,
            "temperature": temperature,
        }
        if system_instruction:
            config_kwargs["system_instruction"] = system_instruction
        if is_image_request:
            # response_modalities and response_mime_type are mutually
            # exclusive on Gemini's config - never set both.
            config_kwargs["response_modalities"] = ["TEXT", "IMAGE"]
        elif wants_json:
            config_kwargs["response_mime_type"] = "application/json"

        logger.info(
            "AI chat request started",
            provider_host="generativelanguage.googleapis.com",
            model=use_model,
            message_count=len(messages),
            has_response_modalities=is_image_request,
            has_response_format=bool(response_format),
        )

        try:
            response = await client.aio.models.generate_content(
                model=use_model,
                contents=contents,
                config=types.GenerateContentConfig(**config_kwargs),
            )
        except genai_errors.APIError as e:
            retryable, error_kind, retry_after = classify_gemini_error(e)
            # A DAILY-quota failure (non-retryable upstream_quota) means every
            # subsequent call this day will also 429: latch it so later calls
            # fail fast without touching the network (see module docstring).
            if error_kind == "upstream_quota" and not retryable:
                await _latch_daily_quota(self.config.api_key)
            # Handled upstream failures (quota 429 / 5xx overload) that the
            # hybrid vision leg will absorb via the Agnes fallback are WARN
            # level - error-level logging here turned every free-tier burst
            # into a log-drain flood. Hard failures (auth/blocked/parse) stay
            # at error level. Quota failures are WARN even when classified
            # non-retryable: a latched daily cap is expected, not an error.
            log_fn = logger.warning if error_kind == "upstream_quota" else (
                logger.error if not retryable else logger.warning
            )
            log_fn(
                f"Gemini request failed: {e}",
                model=use_model,
                retryable=retryable,
                error_kind=error_kind,
                retry_after_seconds=retry_after,
                exc_info=False,
            )
            raise AIServiceError(
                f"Gemini request failed: {e}",
                retryable=retryable,
                error_kind=error_kind,
                retry_after_seconds=retry_after,
            )

        return self._parse_response(response, use_model, structured_output_requested=wants_json)

    def _parse_response(
        self, response: types.GenerateContentResponse, model: str, structured_output_requested: bool
    ) -> AIResponse:
        feedback = getattr(response, "prompt_feedback", None)
        if feedback is not None and getattr(feedback, "block_reason", None):
            raise AIServiceError(
                f"Gemini blocked the prompt: {feedback.block_reason}", retryable=False
            )

        candidates = response.candidates or []
        if candidates:
            finish_reason = candidates[0].finish_reason
            if finish_reason in _BLOCKED_FINISH_REASONS:
                raise AIServiceError(
                    f"Gemini blocked the response: {finish_reason}", retryable=False
                )
            # A JSON response cut off at max_output_tokens is broken JSON that
            # would parse to nothing - surface it as a real error instead.
            # Mirrors ai_provider_service.py's finish_reason=="length" guard.
            # Only for structured-output callers: a plain-text vision answer
            # can legitimately stop at MAX_TOKENS without being "broken".
            if finish_reason == types.FinishReason.MAX_TOKENS and structured_output_requested:
                raise AIServiceError(
                    f"Gemini response truncated at max_output_tokens="
                    f"{self.config.max_tokens} (finish_reason=MAX_TOKENS); "
                    "structured output is incomplete",
                    retryable=False,
                )

        images: List[str] = []
        for part in (response.parts or []):
            inline = getattr(part, "inline_data", None)
            if inline is not None and inline.data:
                data = inline.data
                images.append(base64.b64encode(data).decode() if isinstance(data, bytes) else data)

        usage = None
        um = getattr(response, "usage_metadata", None)
        if um is not None:
            usage = {
                "prompt_tokens": getattr(um, "prompt_token_count", 0) or 0,
                "completion_tokens": getattr(um, "candidates_token_count", 0) or 0,
                "total_tokens": getattr(um, "total_token_count", 0) or 0,
            }

        logger.info(
            "AI chat response received",
            model=model,
            has_text=response.text is not None,
            images_count=len(images),
        )

        return AIResponse(
            text=response.text,
            images=images or None,
            model=model,
            provider="google-genai",
            usage=usage,
            raw_response=response.model_dump() if hasattr(response, "model_dump") else None,
        )

    async def chat_with_vision(
        self,
        prompt: str,
        images: List[str],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        response_format: Optional[Dict[str, Any]] = None,
    ) -> AIResponse:
        """Same primary -> fallback-model pattern as the OpenAI-compatible
        provider's chat_with_vision, narrowed to Gemini-model-to-Gemini-model
        only - there is no cross-provider fallback here (see plan §7)."""
        primary_model = model or self.config.get_vision_model()
        fallback_model = self.config.vision_fallback_model

        messages = build_user_multimodal_messages(prompt, images)

        try:
            return await self.chat(
                messages=messages,
                model=primary_model,
                max_tokens=max_tokens,
                response_format=response_format,
            )
        except AIServiceError as e:
            if not fallback_model or fallback_model == primary_model or not e.retryable:
                raise
            logger.warning(
                "Primary Gemini vision model failed, retrying with fallback",
                primary_model=primary_model,
                fallback_model=fallback_model,
                error=str(e)[:200],
            )
            return await self.chat(
                messages=messages,
                model=fallback_model,
                max_tokens=max_tokens,
                response_format=response_format,
            )

    async def generate_image(
        self,
        prompt: str,
        reference_image: Optional[str] = None,
        model: Optional[str] = None,
    ) -> AIResponse:
        """Reuses chat() with response_modalities=["TEXT","IMAGE"] - no
        separate images-endpoint concept exists for Gemini."""
        use_model = model or self.config.get_image_gen_model()
        if reference_image:
            content: List[Dict[str, Any]] = [
                {"type": "image_url", "image_url": {"url": reference_image}},
                {"type": "text", "text": prompt},
            ]
            messages = [ChatMessage(role="user", content=content)]
        else:
            messages = [ChatMessage(role="user", content=prompt)]

        return await self.chat(
            messages=messages,
            model=use_model,
            response_modalities=["TEXT", "IMAGE"],
        )

    def get_image_gen_model(self) -> str:
        return self.config.get_image_gen_model()

    async def test_connection(self) -> HealthCheckResult:
        started_at = time.monotonic()
        try:
            messages = [ChatMessage(role="user", content="Hello, respond with 'OK' only.")]
            response = await self.chat(messages=messages, max_tokens=10)
            return HealthCheckResult(
                available=True,
                message="Connection successful",
                model=response.model,
                response=response.text,
                latency_ms=round((time.monotonic() - started_at) * 1000, 2),
            )
        except AIServiceError:
            raise
        except Exception as e:
            return HealthCheckResult(
                available=False,
                message=f"Unexpected error: {str(e)}",
                error_type=e.__class__.__name__,
                latency_ms=round((time.monotonic() - started_at) * 1000, 2),
            )

    async def close(self) -> None:
        if self._client is not None:
            await self._client.aio.aclose()
            self._client = None
