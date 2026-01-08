"""
AI Provider Service - OpenAI-compatible API client for multiple AI providers.

This service provides a unified interface for AI operations using OpenAI-compatible
API format, supporting:
- Gemini (via OpenAI-compatible proxy or direct)
- OpenAI (direct)
- Custom OpenAI-compatible proxies

Features:
- Vision/chat for item extraction
- Image generation (response_modalities: ["TEXT", "IMAGE"])
- Provider abstraction for easy switching
- Per-user configuration with system defaults

Sample request format:
    curl --location 'http://localhost:8317/v1/chat/completions' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Bearer api-key' \
    --data '{
        "model": "gemini-3-pro-image-preview",
        "messages": [
          {"role": "user", "content": "A sleek futuristic cityscape"}
        ],
        "response_modalities": ["TEXT","IMAGE"]
      }'
"""

import base64
import json
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional, Union

import httpx

from app.core.config import settings
from app.core.logging_config import get_context_logger, sanitize_for_logging
from app.core.exceptions import AIServiceError

logger = get_context_logger(__name__)


# =============================================================================
# ENUMS AND DATA CLASSES
# =============================================================================


class AIProvider(str, Enum):
    """Supported AI providers."""
    GEMINI = "gemini"
    OPENAI = "openai"
    CUSTOM = "custom"


@dataclass
class ProviderConfig:
    """Configuration for a single AI provider."""
    api_url: str
    api_key: str
    model: str
    vision_model: Optional[str] = None
    image_gen_model: Optional[str] = None
    max_tokens: int = 64096
    timeout: float = 600.0  # 10 minutes

    def get_vision_model(self) -> str:
        """Get the vision model, falling back to the default model."""
        return self.vision_model or self.model

    def get_image_gen_model(self) -> str:
        """Get the image generation model, falling back to the default model."""
        return self.image_gen_model or self.model


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


# =============================================================================
# PROVIDER CONFIGURATION HELPERS
# =============================================================================


def get_system_provider_config(provider: AIProvider) -> Optional[ProviderConfig]:
    """Get system-level default configuration for a provider."""
    if provider == AIProvider.GEMINI:
        if not settings.GEMINI_API_KEY:
            return None
        return ProviderConfig(
            api_url=getattr(settings, 'AI_GEMINI_API_URL', 'https://generativelanguage.googleapis.com/v1beta'),
            api_key=settings.GEMINI_API_KEY,
            model=getattr(settings, 'AI_GEMINI_CHAT_MODEL', 'gemini-3-flash-preview'),
            vision_model=getattr(settings, 'AI_GEMINI_VISION_MODEL', 'gemini-3-flash-preview'),
            image_gen_model=getattr(settings, 'AI_GEMINI_IMAGE_MODEL', 'gemini-3-pro-image-preview'),
        )
    elif provider == AIProvider.OPENAI:
        api_key = getattr(settings, 'AI_OPENAI_API_KEY', None)
        if not api_key:
            return None
        return ProviderConfig(
            api_url=getattr(settings, 'AI_OPENAI_API_URL', 'https://api.openai.com/v1'),
            api_key=api_key,
            model=getattr(settings, 'AI_OPENAI_CHAT_MODEL', 'gpt-4o'),
            vision_model=getattr(settings, 'AI_OPENAI_VISION_MODEL', 'gpt-4o'),
            image_gen_model=getattr(settings, 'AI_OPENAI_IMAGE_MODEL', 'dall-e-3'),
        )
    elif provider == AIProvider.CUSTOM:
        api_url = getattr(settings, 'AI_CUSTOM_API_URL', None)
        api_key = getattr(settings, 'AI_CUSTOM_API_KEY', None)
        if not api_url or not api_key:
            return None
        return ProviderConfig(
            api_url=api_url,
            api_key=api_key,
            model=getattr(settings, 'AI_CUSTOM_CHAT_MODEL', 'gemini-3-flash-preview'),
            vision_model=getattr(settings, 'AI_CUSTOM_VISION_MODEL', 'gemini-3-flash-preview'),
            image_gen_model=getattr(settings, 'AI_CUSTOM_IMAGE_MODEL', 'gemini-3-pro-image-preview'),
        )
    return None


def get_default_provider() -> AIProvider:
    """Get the system default provider."""
    provider_str = getattr(settings, 'AI_DEFAULT_PROVIDER', 'gemini').lower()
    try:
        return AIProvider(provider_str)
    except ValueError:
        return AIProvider.GEMINI


# =============================================================================
# AI PROVIDER SERVICE
# =============================================================================


class AIProviderService:
    """
    Main AI provider service using OpenAI-compatible API format.

    This service handles all AI operations by making HTTP requests to
    OpenAI-compatible endpoints (OpenAI, Gemini proxies, or custom proxies).
    """

    def __init__(self, config: ProviderConfig):
        """Initialize the service with a provider configuration."""
        self.config = config
        self._client: Optional[httpx.AsyncClient] = None

    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create the HTTP client."""
        if self._client is None:
            self._client = httpx.AsyncClient(
                timeout=httpx.Timeout(self.config.timeout),
                headers={
                    "Content-Type": "application/json",
                    "Authorization": f"Bearer {self.config.api_key}",
                },
            )
        return self._client

    async def close(self):
        """Close the HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None

    def _build_chat_url(self) -> str:
        """Build the chat completions URL."""
        base_url = self.config.api_url.rstrip("/")
        # Ensure we have the /chat/completions endpoint
        if not base_url.endswith("/chat/completions"):
            if base_url.endswith("/v1"):
                return f"{base_url}/chat/completions"
            else:
                return f"{base_url}/v1/chat/completions"
        return base_url

    async def chat(
        self,
        messages: List[ChatMessage],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
        temperature: float = 0.7,
        response_modalities: Optional[List[str]] = None,
    ) -> AIResponse:
        """
        Send a chat completion request.

        Args:
            messages: List of chat messages
            model: Model to use (defaults to config model)
            max_tokens: Maximum tokens in response
            temperature: Sampling temperature
            response_modalities: Response types ["TEXT", "IMAGE"] for image generation

        Returns:
            AIResponse with text and/or images
        """
        client = await self._get_client()
        url = self._build_chat_url()
        use_model = model or self.config.model

        # Build request payload
        payload: Dict[str, Any] = {
            "model": use_model,
            "messages": [
                {"role": m.role, "content": m.content}
                for m in messages
            ],
            "max_tokens": max_tokens or self.config.max_tokens,
            "temperature": temperature,
        }

        # Add response_modalities for image generation
        if response_modalities:
            payload["response_modalities"] = response_modalities

        logger.debug(
            "Sending chat request",
            url=url,
            model=use_model,
            message_count=len(messages),
            has_response_modalities=bool(response_modalities),
        )

        # Log full request payload for debugging
        logger.info(
            "AI chat request payload",
            url=url,
            payload=sanitize_for_logging(payload),
        )

        try:
            response = await client.post(url, json=payload)
            response.raise_for_status()
            data = response.json()

            # Log full response for debugging
            logger.info(
                "AI chat response received",
                response_data=sanitize_for_logging(data),
            )

            return self._parse_chat_response(data, use_model)

        except httpx.HTTPStatusError as e:
            error_detail = ""
            try:
                error_data = e.response.json()
                error_detail = error_data.get("error", {}).get("message", str(error_data))
            except Exception:
                error_detail = e.response.text[:500]

            logger.error(
                "Chat request failed",
                status_code=e.response.status_code,
                error=error_detail,
            )
            raise AIServiceError(f"AI request failed ({e.response.status_code}): {error_detail}")

        except httpx.TimeoutException:
            logger.error("Chat request timed out", timeout=self.config.timeout)
            raise AIServiceError("AI request timed out. Please try again.")

        except Exception as e:
            logger.error("Chat request error", error=str(e))
            raise AIServiceError(f"AI request failed: {str(e)}")

    def _parse_chat_response(self, data: Dict[str, Any], model: str) -> AIResponse:
        """Parse the chat completion response."""
        text = None
        images = []

        # Extract from choices
        choices = data.get("choices", [])
        logger.info(
            "Parsing chat response - choices",
            choices_count=len(choices),
            choices_keys=[list(c.keys()) if isinstance(c, dict) else type(c).__name__ for c in choices],
        )
        if choices:
            message = choices[0].get("message", {})
            content = message.get("content")

            logger.info(
                "Parsing chat response - content",
                content_type=type(content).__name__ if content else None,
                message_keys=list(message.keys()) if isinstance(message, dict) else None,
            )

            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                # Multimodal response (text + images)
                for part in content:
                    if isinstance(part, dict):
                        if part.get("type") == "text":
                            text = part.get("text", "")
                        elif part.get("type") == "image_url":
                            image_url = part.get("image_url", {})
                            url = image_url.get("url", "")
                            # Extract base64 from data URL if present
                            if url.startswith("data:"):
                                # Format: data:image/png;base64,<data>
                                if ";base64," in url:
                                    images.append(url.split(";base64,")[1])
                                else:
                                    images.append(url)
                            else:
                                images.append(url)
                        elif part.get("type") == "image":
                            # Alternative format with inline_data
                            inline_data = part.get("inline_data", {})
                            if inline_data.get("data"):
                                images.append(inline_data["data"])

            # Check for images array in message (custom provider format)
            message_images = message.get("images", [])
            for img in message_images:
                if img.get("type") == "image_url":
                    image_url = img.get("image_url", {})
                    url = image_url.get("url", "")
                    if url.startswith("data:"):
                        if ";base64," in url:
                            images.append(url.split(";base64,")[1])
                        else:
                            images.append(url)
                    else:
                        images.append(url)

        # Extract usage if present
        usage = None
        if "usage" in data:
            usage = {
                "prompt_tokens": data["usage"].get("prompt_tokens", 0),
                "completion_tokens": data["usage"].get("completion_tokens", 0),
                "total_tokens": data["usage"].get("total_tokens", 0),
            }

        logger.info(
            "Parsing chat response - result",
            has_text=text is not None,
            images_count=len(images),
        )

        return AIResponse(
            text=text,
            images=images if images else None,
            model=model,
            provider=self.config.api_url,
            usage=usage,
            raw_response=data,
        )

    async def chat_with_vision(
        self,
        prompt: str,
        images: List[str],
        model: Optional[str] = None,
        max_tokens: Optional[int] = None,
    ) -> AIResponse:
        """
        Send a chat completion request with images (vision).

        Args:
            prompt: Text prompt
            images: List of base64-encoded images
            model: Vision model to use
            max_tokens: Maximum tokens in response

        Returns:
            AIResponse with text analysis
        """
        use_model = model or self.config.get_vision_model()

        # Build multimodal content
        content: List[Dict[str, Any]] = [
            {"type": "text", "text": prompt}
        ]

        for img in images:
            # Ensure we have a proper data URL
            if not img.startswith("data:"):
                # Assume JPEG if no prefix, but try to detect
                img = f"data:image/jpeg;base64,{img}"

            content.append({
                "type": "image_url",
                "image_url": {"url": img}
            })

        messages = [ChatMessage(role="user", content=content)]

        return await self.chat(
            messages=messages,
            model=use_model,
            max_tokens=max_tokens,
        )

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
            # Image-to-image: include reference image with the prompt
            if not reference_image.startswith("data:"):
                reference_image = f"data:image/jpeg;base64,{reference_image}"

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

    async def test_connection(self) -> Dict[str, Any]:
        """
        Test the connection to the AI provider.

        Returns:
            Dict with success status and message
        """
        try:
            messages = [ChatMessage(role="user", content="Hello, respond with 'OK' only.")]
            response = await self.chat(messages=messages, max_tokens=10)

            return {
                "success": True,
                "message": "Connection successful",
                "model": response.model,
                "response": response.text,
            }
        except AIServiceError as e:
            return {
                "success": False,
                "message": str(e),
            }
        except Exception as e:
            return {
                "success": False,
                "message": f"Unexpected error: {str(e)}",
            }


# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================


async def get_ai_service(
    provider: Optional[AIProvider] = None,
    user_config: Optional[Dict[str, Any]] = None,
) -> AIProviderService:
    """
    Get an AI service instance with the appropriate configuration.

    Args:
        provider: Which provider to use (defaults to system default)
        user_config: Optional user-level configuration override

    Returns:
        Configured AIProviderService instance

    Raises:
        AIServiceError: If no valid configuration is available
    """
    use_provider = provider or get_default_provider()

    # Check for user-level override first
    if user_config and use_provider.value in user_config:
        user_provider_config = user_config[use_provider.value]
        if user_provider_config.get("api_key") and user_provider_config.get("api_url"):
            config = ProviderConfig(
                api_url=user_provider_config["api_url"],
                api_key=user_provider_config["api_key"],
                model=user_provider_config.get("model", "gemini-3-flash-preview"),
                vision_model=user_provider_config.get("vision_model"),
                image_gen_model=user_provider_config.get("image_gen_model"),
            )
            return AIProviderService(config)

    # Fall back to system configuration
    config = get_system_provider_config(use_provider)
    if not config:
        raise AIServiceError(
            f"AI provider '{use_provider.value}' is not configured. "
            "Please configure the provider in settings or environment variables."
        )

    return AIProviderService(config)


async def quick_chat(
    prompt: str,
    provider: Optional[AIProvider] = None,
) -> str:
    """
    Quick helper for simple chat requests.

    Args:
        prompt: The prompt to send
        provider: Which provider to use

    Returns:
        The text response
    """
    service = await get_ai_service(provider)
    try:
        response = await service.chat([ChatMessage(role="user", content=prompt)])
        return response.text or ""
    finally:
        await service.close()


async def quick_vision(
    prompt: str,
    image_base64: str,
    provider: Optional[AIProvider] = None,
) -> str:
    """
    Quick helper for vision requests.

    Args:
        prompt: The analysis prompt
        image_base64: Base64-encoded image
        provider: Which provider to use

    Returns:
        The text analysis
    """
    service = await get_ai_service(provider)
    try:
        response = await service.chat_with_vision(prompt, [image_base64])
        return response.text or ""
    finally:
        await service.close()


async def quick_image_gen(
    prompt: str,
    provider: Optional[AIProvider] = None,
) -> Optional[str]:
    """
    Quick helper for image generation.

    Args:
        prompt: The generation prompt
        provider: Which provider to use

    Returns:
        Base64-encoded image or None
    """
    service = await get_ai_service(provider)
    try:
        response = await service.generate_image(prompt)
        if response.images:
            return response.images[0]
        return None
    finally:
        await service.close()
