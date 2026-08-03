"""
AI Provider Service - OpenAI-compatible API client for multiple AI providers.

This service provides a unified interface for AI operations using OpenAI-compatible
API format, supporting:
- OpenAI (direct)
- Custom OpenAI-compatible proxies

Features:
- Vision/chat for item extraction
- Image generation (response_modalities: ["TEXT", "IMAGE"])
- Provider abstraction for easy switching
- Per-user configuration with system defaults

Sample request format (Agnes chat/vision):
    curl --location 'https://apihub.agnes-ai.com/v1/chat/completions' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Bearer api-key' \
    --data '{
        "model": "gemini-3.6-flash",
        "messages": [
          {"role": "user", "content": "Describe this outfit"}
        ]
      }'
"""

import base64
import random
import time
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence, Tuple
from urllib.parse import urlparse

import httpx

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.models.ai import HealthCheckResult
from app.utils.image_processing import to_data_url
from app.utils.retry import with_retry
from app.services.ai_provider_health_service import _is_non_openai_host
from app.services.ai_provider_interface import (
    AIProvider,
    AIProviderClient,
    AIResponse,
    ChatMessage,
    build_user_multimodal_messages,
    get_provider_class,
    register_provider,
)
# No circularity: gemini_provider.py only imports ai_provider_interface.py,
# never this module. Imported at module scope (rather than the old bottom-of-
# file `import app.services.gemini_provider` side-effect trick) both to
# trigger @register_provider(AIProvider.GEMINI) and to give the hybrid vision
# leg below direct symbol access.
from app.services.gemini_provider import GeminiConfig, GeminiProvider

logger = get_context_logger(__name__)


# Default ceiling for AI output. Kept as a constant (not settings.AI_MAX_OUTPUT_TOKENS
# inline) so callers below default to the same value in one place, while
# from_settings() still reads the env-configured value for the system config.
DEFAULT_MAX_OUTPUT_TOKENS = settings.AI_MAX_OUTPUT_TOKENS


# =============================================================================
# DATA CLASSES
# =============================================================================
# AIProvider, ChatMessage, and AIResponse now live in ai_provider_interface.py
# (imported above) so gemini_provider.py can depend on them without a circular
# import back to this module. Re-imported here under the same names so every
# existing importer of `app.services.ai_provider_service` keeps working
# unchanged.


@dataclass
class ProviderConfig:
    """Configuration for a single AI provider.

    Each leg (chat, vision, vision-fallback, image, image-fallback) can have
    its own host/key/model. Per-leg url/key falls back to its parent when blank:
    vision -> chat; vision_fallback -> vision; image -> chat; image_fallback
    -> image. So a single-host setup only needs api_url/api_key/model.
    """
    # CHAT (root)
    api_url: str
    api_key: str
    model: str

    # VISION primary
    vision_api_url: Optional[str] = None
    vision_api_key: Optional[str] = None
    vision_model: Optional[str] = None
    # When set to GEMINI, chat_with_vision()'s primary call bypasses the
    # OpenAI-compatible HTTP path above entirely and goes straight to Google's
    # native SDK via an internal GeminiProvider - vision_model is then read as
    # a Gemini model name. None (default) preserves today's behavior. System-
    # config only in v1: from_user_dict() (BYOK) never sets this.
    vision_provider: Optional[AIProvider] = None
    # Gemini API key for the hybrid vision leg above, resolved once at
    # construction time (system settings only, not per-user/BYOK in v1).
    vision_gemini_api_key: Optional[str] = None
    # VISION fallback
    vision_fallback_api_url: Optional[str] = None
    vision_fallback_api_key: Optional[str] = None
    vision_fallback_model: Optional[str] = None

    # IMAGE primary
    image_api_url: Optional[str] = None
    image_api_key: Optional[str] = None
    image_gen_model: Optional[str] = None
    # "chat" (response_modalities on /chat/completions) | "images" (/images/generations)
    image_api_style: str = "chat"
    # IMAGE fallback
    image_fallback_api_url: Optional[str] = None
    image_fallback_api_key: Optional[str] = None
    image_fallback_model: Optional[str] = None

    max_tokens: int = DEFAULT_MAX_OUTPUT_TOKENS

    # Optimized timeout configuration (separate connect vs read)
    connect_timeout: float = 5.0     # 5s for connection establishment
    read_timeout: float = 120.0      # 2min for reading response
    write_timeout: float = 30.0      # 30s for sending request
    pool_timeout: float = 10.0       # 10s for acquiring connection from pool

    # Connection pool settings
    max_connections: int = 100       # Total connections in pool
    max_keepalive: int = 20          # Persistent connections to keep alive

    # Legacy timeout field for backward compatibility
    timeout: float = 600.0  # Deprecated - use specific timeouts above

    # --- VISION resolvers (inherit chat when blank) ---
    def get_vision_model(self) -> str:
        """Get the vision model, falling back to the default model."""
        return self.vision_model or self.model

    def get_vision_fallback_model(self) -> Optional[str]:
        """Get the vision fallback model (used when primary vision model fails)."""
        return self.vision_fallback_model

    def get_vision_api_url(self) -> str:
        """Get the vision endpoint, falling back to the chat api_url."""
        return self.vision_api_url or self.api_url

    def get_vision_api_key(self) -> str:
        """Get the vision API key, falling back to the chat api_key."""
        return self.vision_api_key or self.api_key

    def get_vision_fallback_api_url(self) -> str:
        """Get the vision-fallback endpoint, inheriting vision then chat."""
        return self.vision_fallback_api_url or self.get_vision_api_url()

    def get_vision_fallback_api_key(self) -> str:
        """Get the vision-fallback key, inheriting vision then chat."""
        return self.vision_fallback_api_key or self.get_vision_api_key()

    # --- IMAGE resolvers (inherit chat when blank) ---
    def get_image_gen_model(self) -> str:
        """Get the image generation model, falling back to the default model."""
        return self.image_gen_model or self.model

    def get_image_api_url(self) -> str:
        """Get the image endpoint, falling back to the chat api_url."""
        return self.image_api_url or self.api_url

    def get_image_api_key(self) -> str:
        """Get the image API key, falling back to the chat api_key."""
        return self.image_api_key or self.api_key

    def get_image_fallback_model(self) -> Optional[str]:
        """Get the image fallback model (used when primary image model fails)."""
        return self.image_fallback_model

    def get_image_fallback_api_url(self) -> str:
        """Get the image-fallback endpoint, inheriting image then chat."""
        return self.image_fallback_api_url or self.get_image_api_url()

    def get_image_fallback_api_key(self) -> str:
        """Get the image-fallback key, inheriting image then chat."""
        return self.image_fallback_api_key or self.get_image_api_key()

    @classmethod
    def from_settings(cls, provider: AIProvider, s) -> Optional["ProviderConfig"]:
        """System-level default configuration for OPENAI or CUSTOM (the two
        provider values this config type serves - Gemini has its own
        GeminiConfig). Body unchanged from the old get_system_provider_config()."""
        if provider == AIProvider.OPENAI:
            api_key = getattr(s, 'AI_OPENAI_API_KEY', None)
            if not api_key:
                return None
            return cls(
                api_url=getattr(s, 'AI_OPENAI_API_URL', 'https://api.openai.com/v1'),
                api_key=api_key,
                model=getattr(s, 'AI_OPENAI_CHAT_MODEL', 'gpt-4o'),
                vision_model=getattr(s, 'AI_OPENAI_VISION_MODEL', 'gpt-4o'),
                image_gen_model=getattr(s, 'AI_OPENAI_IMAGE_MODEL', 'dall-e-3'),
                max_tokens=getattr(s, "AI_MAX_OUTPUT_TOKENS", DEFAULT_MAX_OUTPUT_TOKENS),
            )
        elif provider == AIProvider.CUSTOM:
            return cls(
                api_url=s.AI_CHAT_API_URL,
                api_key=s.AI_CHAT_API_KEY,
                model=s.AI_CHAT_MODEL,
                vision_api_url=s.AI_VISION_API_URL,
                vision_api_key=s.AI_VISION_API_KEY,
                vision_model=s.AI_VISION_MODEL,
                vision_provider=(
                    AIProvider.GEMINI
                    if getattr(s, "AI_VISION_PROVIDER", "custom").lower() == "gemini"
                    else None
                ),
                vision_gemini_api_key=getattr(s, "AI_GEMINI_API_KEY", None),
                vision_fallback_api_url=s.AI_VISION_FALLBACK_API_URL,
                vision_fallback_api_key=s.AI_VISION_FALLBACK_API_KEY,
                vision_fallback_model=s.AI_VISION_FALLBACK_MODEL,
                image_api_url=s.AI_IMAGE_API_URL,
                image_api_key=s.AI_IMAGE_API_KEY,
                image_gen_model=s.AI_IMAGE_MODEL,
                image_api_style=s.AI_IMAGE_API_STYLE,
                image_fallback_api_url=s.AI_IMAGE_FALLBACK_API_URL,
                image_fallback_api_key=s.AI_IMAGE_FALLBACK_API_KEY,
                image_fallback_model=s.AI_IMAGE_FALLBACK_MODEL,
                max_tokens=getattr(s, "AI_MAX_OUTPUT_TOKENS", DEFAULT_MAX_OUTPUT_TOKENS),
            )
        return None

    @classmethod
    def from_user_dict(cls, raw: Dict[str, Any], api_key: str) -> Optional["ProviderConfig"]:
        """BYOK / per-call override configuration. Requires api_url (an
        OpenAI-compatible config has nowhere else to send requests); the
        caller resolves api_key (raw or decrypted) and its own presence check.
        Body unchanged from the old inline construction in get_ai_service()
        and AISettingsService.get_effective_provider_config()."""
        if not raw.get("api_url"):
            return None
        return cls(
            api_url=raw["api_url"],
            api_key=api_key,
            model=raw.get("model", settings.AI_CHAT_MODEL),
            vision_model=raw.get("vision_model"),
            vision_fallback_model=raw.get("vision_fallback_model"),
            vision_fallback_api_url=raw.get("vision_fallback_api_url"),
            vision_fallback_api_key=raw.get("vision_fallback_api_key"),
            image_gen_model=raw.get("image_gen_model"),
            image_api_style=raw.get("image_api_style", "images"),
            image_api_url=raw.get("image_api_url"),
            image_api_key=raw.get("image_api_key"),
            image_fallback_model=raw.get("image_fallback_model"),
            image_fallback_api_url=raw.get("image_fallback_api_url"),
            image_fallback_api_key=raw.get("image_fallback_api_key"),
            # BYOK configs inherit the same output ceiling as the system config.
            max_tokens=raw.get("max_tokens", settings.AI_MAX_OUTPUT_TOKENS),
        )

    @classmethod
    def for_test(cls, api_key: str, model: str, api_url: str) -> "ProviderConfig":
        """Minimal config for the 'Test connection' endpoint: just enough to
        reach the provider once with a short timeout. Mirrors what the old
        inline branch in AISettingsService.test_provider_config built."""
        return cls(
            api_url=api_url,
            api_key=api_key,
            model=model,
            timeout=30.0,
            image_api_style="images",
        )


# =============================================================================
# PROVIDER CONFIGURATION HELPERS
# =============================================================================


def get_system_provider_config(provider: AIProvider) -> Optional[Any]:
    """Get system-level default configuration for a provider, via the registry.

    Returns whatever config type that provider's implementation uses
    (ProviderConfig for OPENAI/CUSTOM, GeminiConfig for GEMINI) - callers that
    need a specific shape already know which provider they asked for.
    """
    provider_cls = get_provider_class(provider)
    return provider_cls.config_cls.from_settings(provider, settings)


def get_default_provider() -> AIProvider:
    """Get the system default provider."""
    provider_str = getattr(settings, 'AI_DEFAULT_PROVIDER', 'custom').lower()
    try:
        return AIProvider(provider_str)
    except ValueError:
        return AIProvider.CUSTOM


# =============================================================================
# AI PROVIDER SERVICE
# =============================================================================


@register_provider(AIProvider.OPENAI, AIProvider.CUSTOM)
class AIProviderService:
    """
    Main AI provider service using OpenAI-compatible API format.

    This service handles all AI operations by making HTTP requests to
    OpenAI-compatible endpoints (OpenAI, or custom proxies). Registered under
    both AIProvider.OPENAI and .CUSTOM - they differ only in config defaults
    (see ProviderConfig.from_settings), never in wire protocol, so one
    implementation serves both rather than two identical-body classes.
    """

    config_cls = ProviderConfig

    def __init__(self, config: ProviderConfig):
        """Initialize the service with a provider configuration."""
        self.config = config
        self._client: Optional[httpx.AsyncClient] = None
        # Lazily built only when config.vision_provider == AIProvider.GEMINI
        # (see _get_native_vision_provider / chat_with_vision).
        self._native_vision_provider: Optional[GeminiProvider] = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create the HTTP client with connection pooling."""
        if self._client is None:
            # Create client with connection pooling and optimized timeouts
            limits = httpx.Limits(
                max_connections=self.config.max_connections,
                max_keepalive_connections=self.config.max_keepalive,
                keepalive_expiry=30.0,  # Keep connections alive for 30s
            )

            timeout = httpx.Timeout(
                connect=self.config.connect_timeout,
                read=self.config.read_timeout,
                write=self.config.write_timeout,
                pool=self.config.pool_timeout,
            )

            # HTTP/1.1 by default: concurrent multi-MB base64 image bodies over
            # HTTP/2 routinely hit LocalProtocolError (e.g. ENHANCE_YOUR_CALM /
            # stream reset) against Agnes-style gateways. Multiplexing is not
            # worth the protocol flakiness for this workload.
            self._client = httpx.AsyncClient(
                timeout=timeout,
                limits=limits,
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.config.api_key}",
                },
                http2=False,
            )
        return self._client

    async def close(self):
        """Close the HTTP client (and the internal Gemini provider, if the
        hybrid vision leg constructed one)."""
        if self._client:
            await self._client.aclose()
            self._client = None
        if self._native_vision_provider is not None:
            await self._native_vision_provider.close()
            self._native_vision_provider = None

    def get_image_gen_model(self) -> str:
        """Resolved image-gen model name, without reaching into `.config`."""
        return self.config.get_image_gen_model()

    @staticmethod
    def _build_url(base_url: str, endpoint: str) -> str:
        """Build a full endpoint URL from a provider base URL."""
        base = base_url.rstrip("/")
        if base.endswith(f"/{endpoint}"):
            return base
        if base.endswith("/v1"):
            return f"{base}/{endpoint}"
        return f"{base}/v1/{endpoint}"

    def _build_chat_url(self, base_url: Optional[str] = None) -> str:
        """Build the chat completions URL."""
        return self._build_url(base_url or self.config.api_url, "chat/completions")

    def _build_images_url(self, base_url: Optional[str] = None) -> str:
        """Build the images generations URL."""
        return self._build_url(base_url or self.config.get_image_api_url(), "images/generations")

    @staticmethod
    def _extract_prompt_and_images(messages: List[ChatMessage]) -> tuple[str, List[str]]:
        """Split OpenAI-style multimodal chat messages back into a flat prompt
        string and reference image URLs, for providers whose image generation
        only exists behind /images/generations."""
        text_parts: List[str] = []
        images: List[str] = []
        for message in messages:
            content = message.content
            if isinstance(content, str):
                text_parts.append(content)
                continue
            for part in content:
                if not isinstance(part, dict):
                    continue
                if part.get("type") == "text":
                    text_parts.append(part.get("text", ""))
                elif part.get("type") == "image_url":
                    url = part.get("image_url", {}).get("url", "")
                    if url:
                        images.append(url)
        return "\n".join(t for t in text_parts if t), images

    @staticmethod
    def _count_image_inputs(messages: List[ChatMessage]) -> int:
        count = 0
        for message in messages:
            content = message.content
            if isinstance(content, list):
                for part in content:
                    if isinstance(part, dict) and part.get("type") == "image_url":
                        count += 1
        return count

    @staticmethod
    def _content_for_wire(content: Any) -> Any:
        """Serialize multimodal content for the OpenAI-compatible wire.

        Messages carry images as BARE base64 (see build_user_multimodal_messages
        and generate_image) to avoid a full-size data-URL copy per image for
        the lifetime of the request; the OpenAI-compatible contract requires
        `data:` URLs for inline images, so wrap here — at wire time — one
        transient copy per image that lives only for the request body.
        Data URLs (from legacy callers) pass through unchanged.
        """
        if not isinstance(content, list):
            return content
        wired = []
        for part in content:
            if isinstance(part, dict) and part.get("type") == "image_url":
                url = part.get("image_url", {}).get("url", "")
                if url and not url.startswith("data:"):
                    part = {**part, "image_url": {"url": to_data_url(url)}}
            wired.append(part)
        return wired

    @staticmethod
    def _format_exception_message(exc: Exception) -> str:
        detail = str(exc).strip()
        if detail:
            return f"{exc.__class__.__name__}: {detail}"
        return exc.__class__.__name__

    class _TransientImageAPIOverload(Exception):
        """Marks transient gateway status from /images/generations as retry-worthy.

        Used for 408/429/502/503 so with_retry can re-POST without treating
        permanent 4xx (auth/policy) as transient.
        """

        def __init__(self, message: str, retry_after_seconds: Optional[float] = None):
            super().__init__(message)
            self.retry_after_seconds = retry_after_seconds

    class _TransientChatAPIOverload(Exception):
        """Marks transient gateway HTTP status from /chat/completions as
        retry-worthy (408/429/500/502/503/504). Same pattern as
        _TransientImageAPIOverload but for the chat transport leg."""

        def __init__(self, message: str, retry_after_seconds: Optional[float] = None):
            super().__init__(message)
            self.retry_after_seconds = retry_after_seconds

    _TRANSIENT_TRANSPORT_ERRORS = (
        httpx.ReadError,
        httpx.ConnectError,
        httpx.RemoteProtocolError,
        httpx.LocalProtocolError,
        httpx.WriteError,
        httpx.PoolTimeout,
        httpx.ConnectTimeout,
        httpx.ReadTimeout,
    )

    _PROTOCOL_TRANSPORT_ERRORS = (
        httpx.RemoteProtocolError,
        httpx.LocalProtocolError,
    )

    # Chat/vision parity with image generation: these HTTP codes are worth
    # retrying (Agnes free/shared gateways 429/503 under concurrent vision load;
    # 500/504 are edge timeouts on slow multi-MB vision POSTs, equally transient
    # - failing them fast surfaces recoverable failures to users).
    _TRANSIENT_HTTP_STATUS_CODES = frozenset({408, 429, 500, 502, 503, 504})

    @classmethod
    def _is_transient_transport_error(cls, exc: Exception) -> bool:
        return isinstance(exc, cls._TRANSIENT_TRANSPORT_ERRORS)

    @classmethod
    def _is_transient_http_status(cls, status_code: int) -> bool:
        return status_code in cls._TRANSIENT_HTTP_STATUS_CODES

    @classmethod
    def _is_content_policy_rejection(cls, status_code: int, error_detail: str) -> bool:
        """True for a provider content-policy refusal of the prompt.

        Agnes (agnes-image-2.1-flash) answers prompt refusals with HTTP 400
        "Unable to generate this content. Please modify your prompt and try
        again." (observed 2026-08-03: every /ai/try-on 503'd after ~25s). A
        400 means nothing was generated or billed server-side, so falling
        through to the configured fallback model is safe - the refusal is
        model-specific (content policy), not a request-shape error that would
        fail identically everywhere.
        """
        if status_code != 400:
            return False
        lowered = (error_detail or "").lower()
        return "unable to generate this content" in lowered or "content policy" in lowered

    @staticmethod
    def _retry_delay_seconds(attempt: int) -> float:
        # Faster retry profile for better user experience
        base = 0.5 * (1.5 ** attempt)  # Reduced from 2^attempt
        jitter = random.random() * 0.3 * base  # Reduced jitter
        return min(base + jitter, 5.0)  # Cap at 5s instead of 8s

    @classmethod
    def _http_retry_delay_seconds(
        cls, response: httpx.Response, attempt: int
    ) -> float:
        """Prefer Retry-After when the provider sends it; else exponential backoff."""
        headers = getattr(response, "headers", {}) or {}
        retry_after = headers.get("Retry-After")
        if retry_after:
            try:
                return min(float(retry_after), 30.0)
            except ValueError:
                pass
        return cls._retry_delay_seconds(attempt)

    @staticmethod
    def _http_error_detail(response: httpx.Response) -> str:
        """Extract a short provider error body for logs and AIServiceError messages."""
        try:
            error_data = response.json()
            if isinstance(error_data, dict):
                err = error_data.get("error")
                if isinstance(err, dict):
                    return str(err.get("message") or err)[:500]
                if err is not None:
                    return str(err)[:500]
                return str(error_data)[:500]
            return str(error_data)[:500]
        except (KeyError, ValueError, TypeError):
            return (response.text or "")[:500]

    async def _execute_chat_attempt(
        self, attempt: Dict[str, Any]
    ) -> Tuple[Dict[str, Any], int]:
        """Single HTTP chat attempt.

        Raises raw transport/transient exceptions so with_retry can retry; a
        permanent HTTP status propagates as httpx.HTTPStatusError; a transient
        gateway status is signalled via _TransientChatAPIOverload so with_retry
        can re-POST without treating permanent 4xx as retryable.
        """
        client = attempt["client"]
        req_payload = attempt["req_payload"]
        url = attempt["url"]
        api_key = attempt["api_key"]
        base_url = attempt["base_url"]

        try:
            response = await client.post(
                url,
                json=req_payload,
                headers={"Authorization": f"Bearer {api_key}"},
            )
        except httpx.ConnectError:
            # Connection refused - mark provider as unhealthy before re-raise
            # so with_retry's retry attempt sees a cleared cache.
            from app.services.ai_provider_health_service import get_health_service
            get_health_service().clear_cache(base_url)
            raise
        except self._PROTOCOL_TRANSPORT_ERRORS:
            # Pooled connection is poisoned (peer GOAWAY / local framing error).
            # Drop it so the next retry gets a fresh client.
            await self.close()
            attempt["client"] = await self._get_client()
            raise
        except self._TRANSIENT_TRANSPORT_ERRORS:
            raise

        if self._is_transient_http_status(response.status_code):
            headers = getattr(response, "headers", {}) or {}
            raise self._TransientChatAPIOverload(
                f"status={response.status_code}: {self._http_error_detail(response)}",
                retry_after_seconds=(
                    self._http_retry_delay_seconds(response, 0)
                    if headers.get("Retry-After")
                    else None
                ),
            )
        response.raise_for_status()
        return response.json(), response.status_code

    async def _call_with_retry_and_fallback(
        self,
        attempts: Sequence[Dict[str, Any]],
    ) -> Tuple[Dict[str, Any], int]:
        """Loop attempts; each attempt uses with_retry internally.

        Behavior parity with the previous inline loop:
        - max_retries=1 (2 total attempts) per attempt
        - jitter=False (deterministic delay profile)
        - transient HTTP statuses and transient transport errors retry
        - permanent HTTP statuses propagate as AIServiceError(retryable=False)
        - exhausted transient failures fall through to the next attempt if any
        """
        last_exc: Optional[AIServiceError] = None

        for index, attempt in enumerate(attempts):
            try:
                return await with_retry(
                    lambda a=attempt: self._execute_chat_attempt(a),
                    max_retries=1,
                    initial_delay=0.5,
                    backoff_factor=1.5,
                    max_delay=5.0,
                    jitter=False,
                    retryable_exceptions=self._TRANSIENT_TRANSPORT_ERRORS + (
                        self._TransientChatAPIOverload,
                    ),
                    on_retry=lambda n, exc, delay: logger.warning(
                        "AI chat retry",
                        attempt=n,
                        max_retries=1,
                        delay_seconds=round(delay, 2),
                        error=self._format_exception_message(exc),
                        error_type=type(exc).__name__,
                    ),
                )
            except AIServiceError:
                raise
            except self._TransientChatAPIOverload as e:
                error_message = str(e)
                last_exc = AIServiceError(
                    f"AI chat request failed after retries: {error_message}",
                    retryable=True,
                    retry_after_seconds=e.retry_after_seconds,
                )
                logger.warning(
                    "AI chat attempt exhausted transient HTTP retries",
                    attempt_index=index,
                    total_attempts=len(attempts),
                    error=error_message,
                    exc_info=False,
                )
                if index < len(attempts) - 1:
                    continue
                raise last_exc
            except httpx.HTTPStatusError as e:
                error_detail = self._http_error_detail(e.response)
                status = e.response.status_code
                retryable = self._is_transient_http_status(status)
                last_exc = AIServiceError(
                    f"AI request failed ({status}): {error_detail}",
                    retryable=retryable,
                    provider_status=status,
                    provider_error_detail=error_detail,
                )
                if not retryable or index == len(attempts) - 1:
                    raise last_exc
                continue
            except self._TRANSIENT_TRANSPORT_ERRORS as e:
                error_message = self._format_exception_message(e)
                last_exc = AIServiceError(
                    f"AI transport request failed after retries: {error_message}",
                    retryable=True,
                )
                logger.warning(
                    "AI chat attempt exhausted transport retries",
                    attempt_index=index,
                    total_attempts=len(attempts),
                    error=error_message,
                    error_type=type(e).__name__,
                    exc_info=False,
                )
                if index < len(attempts) - 1:
                    continue
                raise last_exc
            except (httpx.RequestError, httpx.HTTPStatusError, ValueError, KeyError, TypeError) as e:
                error_message = self._format_exception_message(e)
                raise AIServiceError(
                    f"AI request failed: {error_message}",
                    retryable=False,
                )

        raise last_exc or AIServiceError("All AI chat attempts failed")

    async def chat(
        self,
        messages: List[ChatMessage],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: float = 0.7,
        response_modalities: Optional[List[str]] = None,
        response_format: Optional[Dict[str, Any]] = None,
        api_url: Optional[str] = None,
        api_key: Optional[str] = None,
    ) -> AIResponse:
        """
        Send a chat completion request.

        Args:
            messages: List of chat messages
            model: Model to use (defaults to config model)
            max_tokens: Maximum tokens in response
            temperature: Sampling temperature
            response_modalities: Response types ["TEXT", "IMAGE"] for image generation
            response_format: Optional structured output format
            api_url: Override the endpoint (resolves the per-leg url first when None)
            api_key: Override the API key (resolves the per-leg key first when None)

        Returns:
            AIResponse with text and/or images
        """
        is_image_request = bool(response_modalities)

        if is_image_request and self.config.image_api_style == "images":
            # Image-style providers (e.g. Agnes) generate images via
            # /images/generations, not response_modalities on /chat/completions.
            # Chat/vision still use /chat/completions. Every image-generation
            # caller reaches chat() with response_modalities (generate_image(),
            # photoshoot/outfit multi-image content), so intercepting here
            # fixes all of them at the root instead of duplicating per caller.
            prompt_text, reference_images = self._extract_prompt_and_images(messages)
            primary_model = model or self.config.get_image_gen_model()
            fallback_model = self.config.get_image_fallback_model()
            # (model, api_url, api_key) tuples - per-leg endpoint so the
            # fallback attempt uses the image-fallback host/key when set.
            attempts: List[tuple] = [
                (primary_model, self.config.get_image_api_url(), self.config.get_image_api_key())
            ]
            # Only substitute the configured fallback when the caller used the
            # system default model - an explicit non-default `model=` should
            # error, not silently swap in a model the caller never requested.
            if (
                fallback_model
                and fallback_model != primary_model
                and primary_model == self.config.get_image_gen_model()
            ):
                attempts.append(
                    (fallback_model, self.config.get_image_fallback_api_url(), self.config.get_image_fallback_api_key())
                )

            for i, (attempt_model, attempt_url, attempt_key) in enumerate(attempts):
                try:
                    return await self._generate_image_via_images_api(
                        prompt_text,
                        model=attempt_model,
                        reference_images=reference_images,
                        api_url=attempt_url,
                        api_key=attempt_key,
                    )
                except AIServiceError as e:
                    # Only fall through to the next model for errors documented
                    # as transient (429/503/timeout/no-images) or as a prompt
                    # content-policy refusal (fallback_eligible - a 400 where
                    # nothing was generated, so the fallback attempt cannot
                    # double-bill and can succeed where the primary refuses).
                    # Anything else (bad key, parse failure after a possibly
                    # successful generation) would either fail identically or
                    # risk a second billable request, so it should propagate.
                    if i == len(attempts) - 1 or not (e.retryable or e.fallback_eligible):
                        raise
                    logger.warning(
                        "Image generation failed, trying fallback model",
                        primary_model=primary_model,
                        fallback_model=attempts[i + 1][0],
                        error=str(e)[:200],
                    )

        # Endpoint/key resolution: explicit per-call override wins, then the
        # per-leg config (image vs chat) for response_modalities requests.
        active_base_url = api_url or (self.config.get_image_api_url() if is_image_request else self.config.api_url)
        active_api_key = api_key or (self.config.get_image_api_key() if is_image_request else self.config.api_key)

        client = await self._get_client()
        url = self._build_chat_url(active_base_url)
        use_model = model or self.config.model

        # Build request payload
        payload: Dict[str, Any] = {
            "model": use_model,
            "messages": [
                {"role": m.role, "content": self._content_for_wire(m.content)}
                for m in messages
            ],
            "max_tokens": max_tokens or self.config.max_tokens,
            "temperature": temperature,
        }

        # Add response_modalities for image generation
        if response_modalities:
            payload["response_modalities"] = response_modalities

        # Optional structured output contract
        if response_format:
            payload["response_format"] = response_format

        logger.debug(
            "Sending chat request",
            url=url,
            model=use_model,
            message_count=len(messages),
            image_inputs=self._count_image_inputs(messages),
            has_response_modalities=bool(response_modalities),
            has_response_format=bool(response_format),
        )

        parsed_url = urlparse(url)
        logger.info(
            "AI chat request started",
            provider_host=parsed_url.netloc,
            endpoint=parsed_url.path,
            model=use_model,
            message_count=len(messages),
            image_inputs=self._count_image_inputs(messages),
            has_response_modalities=bool(response_modalities),
            has_response_format=bool(response_format),
        )

        # Check provider health before first attempt (fail fast if unavailable)
        from app.services.ai_provider_health_service import get_health_service
        health_service = get_health_service()

        health_status = await health_service.check_provider_health(
            base_url=active_base_url,
            api_key=active_api_key,
            timeout_seconds=3.0,
        )

        if not health_status.available:
            # Provider is down - fail fast. Marked retryable so a configured
            # fallback host (vision/image fallback can have its own url) is
            # still attempted; same-host fallback fails identically on retry.
            error_msg = (
                f"AI provider {active_base_url} is unavailable. "
                f"Error: {health_status.error}. "
                "Please check if the service is running or configure an alternative provider."
            )
            logger.error(
                "Provider unavailable, failing fast",
                provider_url=active_base_url,
                error=health_status.error,
                consecutive_failures=health_status.consecutive_failures,
            )
            raise AIServiceError(error_msg, retryable=True)

        started_at = time.monotonic()
        chat_attempts: List[Dict[str, Any]] = [
            {
                "req_payload": payload,
                "url": url,
                "api_key": active_api_key,
                "client": client,
                "base_url": active_base_url,
            }
        ]

        try:
            data, status_code = await self._call_with_retry_and_fallback(chat_attempts)

            logger.info(
                "AI chat response received",
                status_code=status_code,
                latency_ms=round((time.monotonic() - started_at) * 1000, 2),
                choices_count=len(data.get("choices", [])) if isinstance(data, dict) else 0,
            )

            # A strict-JSON response cut off at max_tokens is broken JSON that
            # would parse to nothing and return silent empty results. Surface it
            # as a real error instead. Only for response_format callers: plain
            # chat and the max_tokens=10 health probe legitimately stop early.
            if response_format and isinstance(data, dict):
                choices = data.get("choices") or []
                if choices and isinstance(choices[0], dict) and choices[0].get("finish_reason") == "length":
                    raise AIServiceError(
                        f"AI response truncated at max_tokens={payload.get('max_tokens')} "
                        "(finish_reason=length); structured output is incomplete",
                        retryable=False,
                    )

            return self._parse_chat_response(data, use_model, active_base_url)

        except httpx.HTTPStatusError as e:
            error_detail = self._http_error_detail(e.response)
            status = e.response.status_code

            if response_format and self._should_retry_without_response_format(
                status_code=status,
                error_detail=error_detail,
            ):
                logger.warning(
                    f"Provider rejected response_format (status={status}), retrying without it",
                    status_code=status,
                    error=error_detail,
                )

                fallback_payload = dict(payload)
                fallback_payload.pop("response_format", None)
                fallback_attempts: List[Dict[str, Any]] = [
                    {
                        "req_payload": fallback_payload,
                        "url": url,
                        "api_key": active_api_key,
                        "client": client,
                        "base_url": active_base_url,
                    }
                ]
                try:
                    data, status_code = await self._call_with_retry_and_fallback(fallback_attempts)
                    logger.info(
                        "AI chat response received after response_format fallback",
                        status_code=status_code,
                        latency_ms=round((time.monotonic() - started_at) * 1000, 2),
                        choices_count=len(data.get("choices", [])) if isinstance(data, dict) else 0,
                    )
                    return self._parse_chat_response(data, use_model, active_base_url)
                except httpx.HTTPStatusError as fallback_error:
                    error_detail = self._http_error_detail(fallback_error.response)
                    e = fallback_error
                    status = e.response.status_code

            retryable = self._is_transient_http_status(status)
            # Put status + body in the message so Railway/log UIs that only
            # show `message` still surface the real failure cause.
            fail_msg = f"Chat request failed (status={status}): {error_detail}"
            logger.error(
                fail_msg,
                status_code=status,
                error=error_detail,
                retryable=retryable,
                exc_info=False,
            )
            raise AIServiceError(
                f"AI request failed ({status}): {error_detail}",
                retryable=retryable,
                provider_status=status,
                provider_error_detail=error_detail,
            )

        except AIServiceError as provider_error:
            # _call_with_retry_and_fallback converts permanent provider HTTP
            # failures into AIServiceError. Preserve the status/detail on that
            # exception so structured-output callers can still retry once
            # without response_format when the provider rejects that feature.
            if response_format and provider_error.provider_status is not None:
                if self._should_retry_without_response_format(
                    status_code=provider_error.provider_status,
                    error_detail=provider_error.provider_error_detail or str(provider_error),
                ):
                    logger.warning(
                        f"Provider rejected response_format (status={provider_error.provider_status}), retrying without it",
                        error=provider_error.provider_error_detail,
                    )
                    fallback_payload = dict(payload)
                    fallback_payload.pop("response_format", None)
                    fallback_attempts: List[Dict[str, Any]] = [{
                        "req_payload": fallback_payload,
                        "url": url,
                        "api_key": active_api_key,
                        "client": client,
                        "base_url": active_base_url,
                    }]
                    data, status_code = await self._call_with_retry_and_fallback(
                        fallback_attempts
                    )
                    return self._parse_chat_response(data, use_model, active_base_url)
            raise

        except (httpx.RequestError, httpx.TimeoutException, ValueError, KeyError, TypeError) as e:
            if self._is_transient_transport_error(e):
                error_message = self._format_exception_message(e)
                logger.error(
                    f"Chat transport error after retries: {error_message}",
                    timeout=self.config.timeout,
                    error=error_message,
                    exc_info=True,
                )
                raise AIServiceError(
                    f"AI transport request failed after retries: {error_message}",
                    retryable=True,
                )

            error_message = self._format_exception_message(e)
            logger.error(
                f"Chat request error: {error_message}",
                error=error_message,
                error_type=type(e).__name__,
                exc_info=True,
            )
            raise AIServiceError(f"AI request failed: {error_message}", retryable=False)

    def _parse_chat_response(
        self, data: Dict[str, Any], model: str, provider_url: Optional[str] = None
    ) -> AIResponse:
        """Parse the chat completion response."""
        def malformed(detail: str) -> None:
            raise AIServiceError(
                f"AI provider returned a malformed chat response: {detail}",
                retryable=False,
                error_kind="hard",
            )

        if not isinstance(data, dict):
            raise AIServiceError(
                "AI provider returned a malformed response object",
                retryable=False,
                error_kind="hard",
            )

        text = None
        images = []

        # Extract from choices
        choices = data.get("choices", [])
        if not isinstance(choices, list) or not choices or not isinstance(choices[0], dict):
            malformed("choices is missing or invalid")
        if not isinstance(choices[0].get("message"), dict):
            malformed("message is missing or invalid")
        logger.debug(
            "Parsing chat response - choices",
            choices_count=len(choices),
            choices_keys=[list(c.keys()) if isinstance(c, dict) else type(c).__name__ for c in choices],
        )
        if choices:
            message = choices[0].get("message", {})
            content = message.get("content")

            logger.debug(
                "Parsing chat response - content",
                content_type=type(content).__name__ if content else None,
                message_keys=list(message.keys()) if isinstance(message, dict) else None,
            )

            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                # Multimodal response (text + images)
                for part in content:
                    if not isinstance(part, dict):
                        malformed("content part is invalid")
                    if part.get("type") == "text":
                        part_text = part.get("text", "")
                        if not isinstance(part_text, str):
                            malformed("text content is invalid")
                        text = part_text
                    elif part.get("type") == "image_url":
                        image_url = part.get("image_url", {})
                        if not isinstance(image_url, dict):
                            malformed("image_url content is invalid")
                        url = image_url.get("url", "")
                        if not isinstance(url, str):
                            malformed("image URL is invalid")
                        # Extract base64 from data URL if present
                        if url.startswith("data:"):
                            # Format: data:image/png;base64,<data>
                            if ";base64," in url:
                                images.append(url.split(";base64,", 1)[1])
                            else:
                                images.append(url)
                        else:
                            images.append(url)
                    elif part.get("type") == "image":
                        # Alternative format with inline_data
                        inline_data = part.get("inline_data", {})
                        if not isinstance(inline_data, dict):
                            malformed("inline image data is invalid")
                        inline_value = inline_data.get("data")
                        if inline_value is not None and not isinstance(inline_value, str):
                            malformed("inline image data is invalid")
                        if inline_value:
                            images.append(inline_value)
            elif content is not None:
                malformed("message content is invalid")

            # Check for images array in message (custom provider format)
            message_images = message.get("images", [])
            if not isinstance(message_images, list):
                malformed("images is invalid")
            for img in message_images:
                if not isinstance(img, dict):
                    malformed("image entry is invalid")
                if img.get("type") == "image_url":
                    image_url = img.get("image_url", {})
                    if not isinstance(image_url, dict):
                        malformed("image_url image entry is invalid")
                    url = image_url.get("url", "")
                    if not isinstance(url, str):
                        malformed("image URL is invalid")
                    if url.startswith("data:"):
                        if ";base64," in url:
                            images.append(url.split(";base64,", 1)[1])
                        else:
                            images.append(url)
                    else:
                        images.append(url)

            if content is None and not message_images:
                malformed("message has no content or images")

        # Extract usage if present
        usage = None
        if "usage" in data:
            if not isinstance(data["usage"], dict):
                malformed("usage is invalid")
            usage = {
                "prompt_tokens": data["usage"].get("prompt_tokens", 0),
                "completion_tokens": data["usage"].get("completion_tokens", 0),
                "total_tokens": data["usage"].get("total_tokens", 0),
            }

        logger.debug(
            "Parsing chat response - result",
            has_text=text is not None,
            images_count=len(images),
        )

        return AIResponse(
            text=text,
            images=images if images else None,
            model=model,
            provider=provider_url or self.config.api_url,
            usage=usage,
            raw_response=data,
        )

    @staticmethod
    def _should_retry_without_response_format(status_code: int, error_detail: str) -> bool:
        """Detect provider incompatibility with response_format payload."""
        if status_code not in {400, 404, 415, 422}:
            return False

        text = (error_detail or "").lower()
        # Only an error that specifically names the response_format / json_schema
        # field justifies a duplicate request without it; generic wording
        # ("unsupported", "unknown field", ...) may be unrelated and retrying
        # would waste latency and provider quota.
        indicators = (
            "response_format",
            "json_schema",
        )
        return any(indicator in text for indicator in indicators)

    async def chat_with_vision(
        self,
        prompt: str,
        images: List[str],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        response_format: Optional[Dict[str, Any]] = None,
    ) -> AIResponse:
        """
        Send a chat completion request with images (vision).

        Attempts the primary vision model first. On retryable failure,
        retries once with the configured fallback vision model (e.g.
        agnes-2.5-flash), then raises the last error if that also fails.

        If config.vision_provider is AIProvider.GEMINI (AI_VISION_PROVIDER=gemini),
        delegates to _chat_with_vision_via_native_gemini() instead - the
        primary call goes straight to Google's native API, falling back to
        this same Agnes/OpenAI-compatible path on ANY failure (not just
        retryable ones).

        Args:
            prompt: Text prompt
            images: List of base64-encoded images
            model: Vision model to use (overrides config)
            max_tokens: Maximum tokens in response
            response_format: Optional structured output format

        Returns:
            AIResponse with text analysis
        """
        if self.config.vision_provider == AIProvider.GEMINI:
            return await self._chat_with_vision_via_native_gemini(
                prompt, images, model, max_tokens, response_format
            )

        primary_model = model or self.config.get_vision_model()
        fallback_model = self.config.get_vision_fallback_model()

        messages = build_user_multimodal_messages(prompt, images)

        primary_api_url = self.config.get_vision_api_url()
        # Non-OpenAI hosts (e.g. Google Generative Language API) do not
        # expose OpenAI-compatible /v1/chat/completions, so the request will
        # fail with a non-retryable 404. Treat any failure from such a host as
        # retryable so the configured fallback model/host (Agnes, which proxies
        # Gemini through an OpenAI-shaped API) is still attempted.
        primary_is_non_openai = _is_non_openai_host(primary_api_url)

        try:
            return await self.chat(
                messages=messages,
                model=primary_model,
                max_tokens=max_tokens,
                response_format=response_format,
                api_url=primary_api_url,
                api_key=self.config.get_vision_api_key(),
            )
        except AIServiceError as e:
            if not fallback_model or fallback_model == primary_model:
                raise
            # Retry on explicitly retryable errors, or when the primary host is
            # known to be non-OpenAI-compatible (the per-leg URL should normally
            # inherit the chat URL; a native Google URL is a misconfiguration
            # that must fall through to the Agnes gateway instead of 500-ing).
            if not e.retryable and not primary_is_non_openai:
                raise

            logger.warning(
                "Primary vision model failed, retrying with fallback",
                primary_model=primary_model,
                fallback_model=fallback_model,
                error=str(e)[:200],
            )
            return await self.chat(
                messages=messages,
                model=fallback_model,
                max_tokens=max_tokens,
                response_format=response_format,
                api_url=self.config.get_vision_fallback_api_url(),
                api_key=self.config.get_vision_fallback_api_key(),
            )

    def _get_native_vision_provider(self) -> GeminiProvider:
        """Lazily build the internal GeminiProvider used by the hybrid vision
        leg (AI_VISION_PROVIDER=gemini). One per AIProviderService instance,
        matching GeminiProvider's own not-shared-across-callers client policy."""
        if self._native_vision_provider is None:
            self._native_vision_provider = GeminiProvider(
                # Inherit the parent config's output ceiling instead of falling
                # back to GeminiConfig's own default, which previously left the
                # native Gemini vision leg pinned at 4096 while the OpenAI leg
                # had already been raised.
                GeminiConfig(
                    api_key=self.config.vision_gemini_api_key,
                    max_tokens=self.config.max_tokens,
                )
            )
        return self._native_vision_provider

    async def _chat_with_vision_via_native_gemini(
        self,
        prompt: str,
        images: List[str],
        model: Optional[str],
        max_tokens: Optional[int],
        response_format: Optional[Dict[str, Any]],
    ) -> AIResponse:
        """Vision leg routed directly to Google's native Gemini API
        (AI_VISION_PROVIDER=gemini), falling back to the configured Agnes/
        OpenAI-compatible vision-fallback leg on ANY failure - not just
        retryable ones. This is deliberately permissive (unlike every other
        fallback path in this file, which only retries on e.retryable):
        the fallback here is a genuinely different vendor, so even a Gemini
        safety-block or bad-request error is worth retrying against Agnes
        rather than surfacing immediately.

        Calls GeminiProvider.chat() directly, not .chat_with_vision() - the
        latter has its own Gemini-to-Gemini fallback (vision_fallback_model
        on GeminiConfig), which would silently insert a second hop nobody
        configured. This keeps it exactly one hop: Gemini -> Agnes.
        """
        if not self.config.vision_gemini_api_key:
            raise AIServiceError(
                "AI_GEMINI_API_KEY must be set when AI_VISION_PROVIDER=gemini",
                retryable=False,
            )

        primary_model = model or self.config.get_vision_model()
        messages = build_user_multimodal_messages(prompt, images)

        fallback_model = self.config.get_vision_fallback_model()
        try:
            return await self._get_native_vision_provider().chat(
                messages=messages,
                model=primary_model,
                max_tokens=max_tokens,
                response_format=response_format,
            )
        except AIServiceError as primary_err:
            if not fallback_model or fallback_model == primary_model:
                raise
            logger.warning(
                "Native Gemini vision call failed, falling back to Agnes",
                primary_model=primary_model,
                fallback_model=fallback_model,
                error_kind=primary_err.error_kind,
                error=str(primary_err)[:200],
            )
            try:
                result = await self.chat(
                    messages=messages,
                    model=fallback_model,
                    max_tokens=max_tokens,
                    response_format=response_format,
                    api_url=self.config.get_vision_fallback_api_url(),
                    api_key=self.config.get_vision_fallback_api_key(),
                )
            except AIServiceError as fallback_err:
                # Both legs failed: this is a capacity/provider problem ("on us"),
                # not the user's own plan limit. Tag it so the UI can show
                # "try again shortly" instead of a generic failure, and preserve
                # whichever retry hint was offered.
                raise AIServiceError(
                    "AI vision unavailable: primary and fallback providers both failed",
                    retryable=bool(fallback_err.retryable or primary_err.retryable),
                    error_kind=(
                        primary_err.error_kind or fallback_err.error_kind or "transient"
                    ),
                    retry_after_seconds=(
                        fallback_err.retry_after_seconds or primary_err.retry_after_seconds
                    ),
                ) from fallback_err
            logger.info(
                "Vision fallback to Agnes succeeded after Gemini failure",
                primary_model=primary_model,
                fallback_model=fallback_model,
                primary_error_kind=primary_err.error_kind,
            )
            return result

    async def generate_image(
        self,
        prompt: str,
        reference_image: Optional[str] = None,
        model: Optional[str] = None,
    ) -> AIResponse:
        """
        Generate an image using the chat completions API with response_modalities.

        Args:
            prompt: Image generation prompt
            reference_image: Optional base64 reference image for image-to-image generation
            model: Image generation model to use

        Returns:
            AIResponse with generated images
        """
        use_model = model or self.config.get_image_gen_model()

        # Build message content
        if reference_image:
            # Image-to-image: include reference image with the prompt. The
            # image travels BARE (or as a data URL if the caller wrapped it);
            # chat() wraps at the wire boundary, and GeminiProvider's
            # _decode_image_part sniffs the mime from the first decoded bytes,
            # so no full-size data-URL copy is created here.
            content: List[Dict[str, Any]] = [
                {"type": "image_url", "image_url": {"url": reference_image}},
                {"type": "text", "text": prompt},
            ]
            messages = [ChatMessage(role="user", content=content)]
        else:
            # Text-to-image: just the prompt
            messages = [ChatMessage(role="user", content=prompt)]

        return await self.chat(
            messages=messages,
            model=use_model,
            response_modalities=["TEXT", "IMAGE"],
        )

    async def _generate_image_via_images_api(
        self, prompt: str, model: str, size: str = "1024x1024",
        reference_images: Optional[List[str]] = None,
        api_url: Optional[str] = None,
        api_key: Optional[str] = None,
    ) -> AIResponse:
        """
        Generate an image using the real OpenAI-compatible /images/generations
        endpoint (e.g. agnes-ai.com, OpenAI).

        api_url/api_key override the configured image endpoint/key (used to
        route the fallback attempt at the image-fallback host).
        """
        image_url = api_url or self.config.get_image_api_url()
        image_key = api_key or self.config.get_image_api_key()
        url = self._build_images_url(image_url)

        from app.services.ai_provider_health_service import get_health_service
        health_service = get_health_service()

        health_status = await health_service.check_provider_health(
            base_url=image_url,
            api_key=image_key,
            timeout_seconds=3.0,
        )
        if not health_status.available:
            # Retryable so the image-fallback host (which can have its own
            # url/key) is attempted when the primary image host is down; a
            # same-host fallback fails identically on the second attempt.
            raise AIServiceError(
                f"AI image provider {image_url} is unavailable. Error: {health_status.error}. "
                "Please check if the service is running or configure an alternative provider.",
                retryable=True,
            )

        client = await self._get_client()
        payload: Dict[str, Any] = {
            "model": model,
            "prompt": prompt,
            "n": 1,
            "size": size,
            # ponytail: Agnes's gateway 400s if response_format sits at the top
            # level, and silently ignores a top-level "image" field (falls back
            # to text-to-image) - both must be nested under extra_body instead.
            # Real OpenAI wants them flat; this method is currently only used
            # in "images" style by Agnes, so hardcoding this is fine - add a
            # style variant if a second, flat-contract provider needs this path.
            "extra_body": {"response_format": "b64_json"},
        }
        if reference_images:
            # Sniffed mime per image; see to_data_url. A PNG/WebP reference
            # announced as JPEG is a lie the provider may act on.
            payload["extra_body"]["image"] = [to_data_url(img) for img in reference_images]

        logger.info(
            "AI image generation request started",
            provider_host=urlparse(url).netloc,
            model=model,
            # Outfit generation can send an avatar plus one reference per item;
            # log the count so a provider that silently honours only the first
            # is diagnosable from the payload side.
            reference_images=len(reference_images or []),
        )

        async def _post_image_request() -> httpx.Response:
            nonlocal client
            try:
                response = await client.post(
                    url,
                    json=payload,
                    headers={"Authorization": f"Bearer {image_key}"},
                )
            except self._PROTOCOL_TRANSPORT_ERRORS:
                # Poisoned pooled connection - drop it so the next retry gets a
                # fresh client (same pattern as chat() transport recovery).
                await self.close()
                client = await self._get_client()
                raise
            if self._is_transient_http_status(response.status_code):
                # Agnes free-tier gateway 429/503 (queue full / rate limit /
                # memory overloaded) is common under concurrent image gen —
                # same transient set as chat(). Permanent 4xx fail via
                # raise_for_status without entering with_retry.
                headers = getattr(response, "headers", {}) or {}
                raise self._TransientImageAPIOverload(
                    f"status={response.status_code}: {self._http_error_detail(response)}",
                    retry_after_seconds=(
                        self._http_retry_delay_seconds(response, 0)
                        if headers.get("Retry-After")
                        else None
                    ),
                )
            response.raise_for_status()
            return response

        try:
            response = await with_retry(
                _post_image_request,
                # ponytail: one internal retry; the call site's with_retry adds
                # one more round (kept low so a 429 storm isn't amplified).
                max_retries=1,
                initial_delay=0.5,
                backoff_factor=1.5,
                max_delay=5.0,
                retryable_exceptions=self._TRANSIENT_TRANSPORT_ERRORS + (self._TransientImageAPIOverload,),
            )
            data = response.json()
        except self._TransientImageAPIOverload as e:
            # Transient gateway status after exhausting retries: fallback-worthy.
            logger.warning(
                "Image generation provider overloaded after retries; raising fallback",
                error_message=str(e)[:500],
                exc_info=False,
            )
            raise AIServiceError(
                f"AI image provider overloaded after retries: {e}",
                retryable=True,
                retry_after_seconds=e.retry_after_seconds,
            )
        except httpx.HTTPStatusError as e:
            error_detail = self._http_error_detail(e.response)
            status = e.response.status_code
            # A content-policy refusal is NOT retryable at the agent level
            # (retrying the whole call would multiply multi-second generation
            # latency), but it IS eligible for the fallback MODEL: nothing was
            # generated, so the fallback attempt is safe and can succeed.
            content_policy = self._is_content_policy_rejection(status, error_detail)
            retryable = self._is_transient_http_status(status)
            # Status + model embedded in the message line itself (parity with
            # chat()) so message-only log views (Railway) can diagnose
            # image-gen failures without structured extras.
            logger.error(
                f"Image generation request failed (status={status}, model={model}): {error_detail}",
                status_code=status,
                model=model,
                error=error_detail,
                retryable=retryable,
                fallback_eligible=content_policy,
                exc_info=False,
            )
            # Permanent 4xx (or any status that escaped the transient branch).
            raise AIServiceError(
                f"AI image request failed ({status}): {error_detail}",
                retryable=retryable,
                provider_status=status,
                provider_error_detail=error_detail,
                fallback_eligible=content_policy,
            )
        except self._TRANSIENT_TRANSPORT_ERRORS as e:
            # Timeout/connection error that exhausted with_retry's internal
            # attempts: no response was ever received, so retrying the
            # fallback model can't double-bill a completed generation.
            error_msg = self._format_exception_message(e)
            logger.error(
                "Image generation request failed with transport error after retries",
                error=error_msg,
                error_type=type(e).__name__,
                exc_info=False,
            )
            raise AIServiceError(f"AI image request failed: {error_msg}", retryable=True)
        except (httpx.RequestError, httpx.HTTPStatusError, ValueError, KeyError, TypeError) as e:
            error_msg = self._format_exception_message(e)
            logger.error(
                "Image generation request failed with unexpected error",
                error=error_msg,
                error_type=type(e).__name__,
                exc_info=True,
            )
            # e.g. response.json() parse failure - the primary call may have
            # already generated (and billed) an image server-side, so this is
            # not safe to retry against the fallback model.
            raise AIServiceError(f"AI image request failed: {error_msg}")

        images = []
        for item in data.get("data", []):
            if item.get("b64_json"):
                images.append(item["b64_json"])
            elif item.get("url"):
                try:
                    # Fetch with a bare client (no Authorization header) - this is
                    # a provider-hosted asset URL, not the API endpoint, and
                    # shouldn't receive our API key.
                    async with httpx.AsyncClient(timeout=30.0) as asset_client:
                        image_response = await asset_client.get(item["url"])
                        image_response.raise_for_status()
                except (httpx.RequestError, httpx.HTTPStatusError, httpx.TimeoutException, httpx.HTTPError) as e:
                    # Not retryable: generation already succeeded server-side,
                    # so retrying against the fallback model would double-bill.
                    logger.exception(
                        "Failed to fetch generated image asset after generation succeeded",
                        asset_url=item.get("url"),
                    )
                    raise AIServiceError(
                        f"Failed to fetch generated image asset: {self._format_exception_message(e)}"
                    )
                images.append(base64.b64encode(image_response.content).decode())

        if not images:
            # Agnes returned 200 with no usable images - most commonly a silent
            # content-moderation refusal. Retryable so the fallback model gets
            # a chance, since no image was actually produced (nothing to double-bill).
            raise AIServiceError(
                f"AI image provider returned no images for model {model}", retryable=True
            )

        return AIResponse(
            text=None,
            images=images,
            model=model,
            provider=image_url,
            raw_response=data,
        )

    async def test_connection(self) -> HealthCheckResult:
        """
        Test the connection to the AI provider.

        Returns:
            HealthCheckResult with available flag, message, model and response.
        """
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
        except (httpx.RequestError, httpx.HTTPStatusError, ValueError, KeyError, TypeError) as e:
            return HealthCheckResult(
                available=False,
                message=f"Unexpected error: {str(e)}",
                error_type=e.__class__.__name__,
                latency_ms=round((time.monotonic() - started_at) * 1000, 2),
            )
        except Exception as e:
            # Catch any remaining unexpected exceptions (asyncio.TimeoutError,
            # MemoryError, AttributeError, etc.) so the health-check route
            # returns a graceful failure envelope instead of crashing.
            return HealthCheckResult(
                available=False,
                message=f"Unexpected error: {str(e)}",
                error_type=e.__class__.__name__,
                latency_ms=round((time.monotonic() - started_at) * 1000, 2),
            )


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================


async def get_ai_service(
    provider: Optional[AIProvider] = None,
    user_config: Optional[Dict[str, Any]] = None,
) -> AIProviderClient:
    """
    Get an AI service instance with the appropriate configuration, dispatched
    through the provider registry so adding a new provider doesn't require
    editing this function.

    Args:
        provider: Which provider to use (defaults to system default)
        user_config: Optional user-level configuration override

    Returns:
        Configured provider instance (AIProviderClient)

    Raises:
        AIServiceError: If no valid configuration is available
    """
    use_provider = provider or get_default_provider()
    provider_cls = get_provider_class(use_provider)

    # Check for user-level override first
    if user_config and use_provider.value in user_config:
        raw = user_config[use_provider.value]
        api_key = raw.get("api_key")
        if api_key:
            config = provider_cls.config_cls.from_user_dict(raw, api_key=api_key)
            if config:
                return provider_cls(config)

    # Fall back to system configuration
    config = provider_cls.config_cls.from_settings(use_provider, settings)
    if not config:
        raise AIServiceError(
            f"AI provider '{use_provider.value}' is not configured. "
            "Please configure the provider in settings or environment variables."
        )

    return provider_cls(config)
