"""
Common interface for AI provider implementations, plus a registry mapping
AIProvider -> concrete class.

Shared data types (AIProvider, ChatMessage, AIResponse) live here rather than in
ai_provider_service.py so a second implementation (gemini_provider.py, using the
native google-genai SDK instead of an OpenAI-compatible HTTP client) can depend
on this module without creating a circular import with the first one.
app/services/ai_provider_service.py re-exports these names for backward
compatibility - existing call sites keep importing from there unchanged.
"""

from dataclasses import dataclass
from enum import Enum
from typing import Any, Dict, List, Optional, Protocol, Type, Union, runtime_checkable

from app.core.exceptions import AIServiceError
from app.models.ai import HealthCheckResult


class AIProvider(str, Enum):
    """Supported AI providers."""
    OPENAI = "openai"
    CUSTOM = "custom"
    GEMINI = "gemini"


@dataclass
class AIResponse:
    """Unified response from AI operations."""
    text: Optional[str] = None
    images: Optional[List[str]] = None  # Base64 encoded images
    model: str = ""
    provider: str = ""
    usage: Optional[Dict[str, int]] = None
    raw_response: Optional[Dict[str, Any]] = None


@dataclass
class ChatMessage:
    """A single chat message."""
    role: str  # "user", "assistant", "system"
    content: Union[str, List[Dict[str, Any]]]  # String or multimodal content


def build_user_multimodal_messages(prompt: str, images: List[str]) -> List[ChatMessage]:
    """Build a single user message holding a text prompt plus images, in the
    OpenAI-style multimodal shape every provider consumes (a list of
    {"type": "text"|"image_url", ...} dicts).

    Images travel as BARE base64 (or a data URL when the caller already
    wrapped one) — deliberately NOT wrapped into `data:` URLs here: wrapping
    would create a full-size copy of every image string that then lives for
    the whole request (including retries and fallback attempts). Each consumer
    wraps at its own wire boundary instead:
    - ``AIProviderService.chat`` wraps `image_url` entries when building the
      OpenAI-compatible JSON body (one transient copy per image).
    - ``GeminiProvider._decode_image_part`` sniffs the mime from the first
      decoded bytes and builds ``Part.from_bytes`` directly (no copy at all).
    """
    content: List[Dict[str, Any]] = [{"type": "text", "text": prompt}]
    for img in images:
        content.append({"type": "image_url", "image_url": {"url": img}})
    return [ChatMessage(role="user", content=content)]


@runtime_checkable
class AIProviderClient(Protocol):
    """Structural contract every provider implementation satisfies.

    Callers (agents, photoshoot_service, demo routes) hold an instance typed to
    this Protocol and never branch on which concrete provider they got. Only
    parameters real external callers use are part of this contract - e.g. the
    api_url/api_key overrides on the OpenAI-compatible client's internal fallback
    routing are deliberately not here, since no caller outside that
    implementation passes them.
    """

    async def chat(
        self,
        messages: List[ChatMessage],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: float = 0.7,
        response_modalities: Optional[List[str]] = None,
        response_format: Optional[Dict[str, Any]] = None,
    ) -> AIResponse: ...

    async def chat_with_vision(
        self,
        prompt: str,
        images: List[str],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        response_format: Optional[Dict[str, Any]] = None,
    ) -> AIResponse: ...

    async def generate_image(
        self,
        prompt: str,
        reference_image: Optional[str] = None,
        model: Optional[str] = None,
    ) -> AIResponse: ...

    def get_image_gen_model(self) -> str:
        """Resolved image-gen model name, without reaching into `.config`."""
        ...

    async def test_connection(self) -> HealthCheckResult: ...

    async def close(self) -> None: ...


# Maps AIProvider -> concrete class. Populated by @register_provider decorators
# on each implementation (ai_provider_service.AIProviderService for OPENAI/CUSTOM,
# gemini_provider.GeminiProvider for GEMINI) at import time.
PROVIDER_REGISTRY: Dict[AIProvider, Type[AIProviderClient]] = {}


def register_provider(*providers: AIProvider):
    """Class decorator: registers a concrete provider implementation under one
    or more AIProvider values (OPENAI and CUSTOM share one implementation -
    they differ only in config defaults, never in wire protocol).

    A provider's config dataclass is looked up via `cls.config_cls`, so the
    factory functions in ai_provider_service.py can build the right config
    type without an if/elif branch per provider - adding provider #3 later
    means writing one class and registering it, not editing the factory again.
    """
    def _decorator(cls: Type[AIProviderClient]) -> Type[AIProviderClient]:
        for provider in providers:
            PROVIDER_REGISTRY[provider] = cls
        return cls
    return _decorator


def get_provider_class(provider: AIProvider) -> Type[AIProviderClient]:
    cls = PROVIDER_REGISTRY.get(provider)
    if cls is None:
        raise AIServiceError(f"No provider implementation registered for '{provider.value}'")
    return cls


def valid_provider_values() -> List[str]:
    """Provider strings with a registered implementation - used to validate
    `default_provider` in the AI settings API instead of a hand-duplicated list."""
    return [p.value for p in PROVIDER_REGISTRY]
