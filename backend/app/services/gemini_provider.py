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

import base64
import re
import time
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Tuple

from google import genai
from google.genai import errors as genai_errors
from google.genai import types

from app.core.exceptions import AIServiceError
from app.core.logging_config import get_context_logger
from app.core.config import settings
from app.models.ai import HealthCheckResult
from app.services.ai_provider_interface import (
    AIProvider,
    AIResponse,
    ChatMessage,
    build_user_multimodal_messages,
    register_provider,
)

logger = get_context_logger(__name__)


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
        )

    @classmethod
    def for_test(cls, api_key: str, model: str, api_url: str) -> "GeminiConfig":
        """Minimal config for the 'Test connection' endpoint. ``api_url`` is
        accepted for signature parity with ``ProviderConfig.for_test`` but is
        not used - Gemini has no per-config URL (the SDK talks to Google
        directly), so only the key + a model name are needed."""
        return cls(api_key=api_key, chat_model=model)


_TRANSIENT_CODES = frozenset({408, 429, 500, 502, 503, 504})


def _parse_retry_delay_seconds(details: Any) -> Optional[int]:
    """Extract the advised retry delay (seconds) from a Gemini APIError payload.

    RESOURCE_EXHAUSTED responses carry a google.rpc.RetryInfo whose retryDelay
    looks like "56s". ``details`` is the raw response_json the SDK stored on the
    error; str() it and scan rather than recursing the nested dict shape, which
    varies across SDK versions.
    """
    try:
        text = str(details or "")
    except Exception:
        return None
    # Match either JSON ("retryDelay": "56s") or Python dict repr
    # ('retryDelay': '56s') - the SDK stores the parsed dict, so str() yields
    # single-quoted repr, but defend against a JSON string form too.
    match = re.search(r"retryDelay[\"']?\s*:\s*[\"']?(\d+)\s*s", text)
    return int(match.group(1)) if match else None


def classify_gemini_error(e: Exception) -> Tuple[bool, Optional[str], Optional[int]]:
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

    def _get_client(self) -> genai.Client:
        if self._client is None:
            self._client = genai.Client(api_key=self.config.api_key)
        return self._client

    @staticmethod
    def _decode_image_part(img: str) -> types.Part:
        """Decode a base64 string or `data:<mime>;base64,<b64>` URL (the same
        shape callers already pass to the OpenAI-compatible provider) into a
        Gemini Part."""
        if img.startswith("data:"):
            header, _, b64_data = img.partition(",")
            mime_type = header[5:].split(";")[0] or "image/jpeg"
        else:
            b64_data = img
            mime_type = "image/jpeg"
        return types.Part.from_bytes(data=base64.b64decode(b64_data), mime_type=mime_type)

    @classmethod
    def _messages_to_contents(
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
                            parts.append(cls._decode_image_part(url))

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
        client = self._get_client()
        use_model = model or self.config.chat_model
        system_instruction, contents = self._messages_to_contents(messages)

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
            logger.error(
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
