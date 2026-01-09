"""
AI Settings Service - Manages per-user AI provider configuration.

This service handles:
- Get effective config (user override or system default)
- Encrypt/decrypt user API keys
- Validate provider configurations
- Rate limit checking and tracking
- Reset rate limits daily
"""

import base64
import hashlib
import os
from datetime import date
from typing import Any, Dict, Optional

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import (
    AIProvider,
    AIProviderService,
    ProviderConfig,
    get_system_provider_config,
    get_default_provider,
)

logger = get_context_logger(__name__)


# =============================================================================
# ENCRYPTION HELPERS
# =============================================================================


def _get_encryption_key() -> Optional[bytes]:
    """Get the Fernet encryption key from settings."""
    key = settings.AI_ENCRYPTION_KEY
    if not key:
        return None

    # If the key is a hex string, convert to bytes and derive a Fernet key
    try:
        if len(key) == 64:  # Hex-encoded 32-byte key
            raw_key = bytes.fromhex(key)
        else:
            raw_key = key.encode()

        # Derive a proper Fernet key (32 bytes, base64-encoded)
        derived = hashlib.sha256(raw_key).digest()
        return base64.urlsafe_b64encode(derived)
    except Exception as e:
        logger.error("Failed to derive encryption key", error=str(e))
        return None


def encrypt_api_key(api_key: str) -> Optional[str]:
    """
    Encrypt an API key for storage.

    Args:
        api_key: The plaintext API key

    Returns:
        Encrypted, base64-encoded string or None if encryption unavailable
    """
    fernet_key = _get_encryption_key()
    if not fernet_key:
        logger.warning("Encryption key not configured, storing API key in plaintext")
        # Return a marker so we know it's not encrypted
        return f"__PLAINTEXT__{api_key}"

    try:
        fernet = Fernet(fernet_key)
        encrypted = fernet.encrypt(api_key.encode())
        return encrypted.decode()
    except Exception as e:
        logger.error("Failed to encrypt API key", error=str(e))
        return None


def decrypt_api_key(encrypted_key: str) -> Optional[str]:
    """
    Decrypt an API key from storage.

    Args:
        encrypted_key: The encrypted, base64-encoded string

    Returns:
        Decrypted API key or None if decryption fails
    """
    # Handle plaintext marker
    if encrypted_key.startswith("__PLAINTEXT__"):
        return encrypted_key[13:]

    fernet_key = _get_encryption_key()
    if not fernet_key:
        logger.error("Cannot decrypt: encryption key not configured")
        return None

    try:
        fernet = Fernet(fernet_key)
        decrypted = fernet.decrypt(encrypted_key.encode())
        return decrypted.decode()
    except InvalidToken:
        logger.error("Failed to decrypt API key: invalid token")
        return None
    except Exception as e:
        logger.error("Failed to decrypt API key", error=str(e))
        return None


# =============================================================================
# AI SETTINGS SERVICE
# =============================================================================


class AISettingsService:
    """Service for managing user AI settings."""

    @staticmethod
    async def get_user_settings(user_id: str, db) -> Dict[str, Any]:
        """
        Get AI settings for a user.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            User's AI settings dict
        """
        try:
            result = db.table("user_ai_settings").select("*").eq("user_id", user_id).execute()

            if result.data and len(result.data) > 0:
                settings_row = result.data[0]

                # Check if daily reset is needed
                last_reset = settings_row.get("last_reset_date")
                if last_reset:
                    if isinstance(last_reset, str):
                        last_reset = date.fromisoformat(last_reset)
                    if last_reset < date.today():
                        # Reset daily counts
                        db.table("user_ai_settings").update({
                            "daily_extraction_count": 0,
                            "daily_generation_count": 0,
                            "daily_embedding_count": 0,
                            "last_reset_date": date.today().isoformat(),
                        }).eq("user_id", user_id).execute()
                        settings_row["daily_extraction_count"] = 0
                        settings_row["daily_generation_count"] = 0
                        settings_row["daily_embedding_count"] = 0

                return settings_row

            # Create default settings if not exists
            default_settings = {
                "user_id": user_id,
                "provider_configs": {},
                "default_provider": get_default_provider().value,
                "daily_extraction_count": 0,
                "daily_generation_count": 0,
                "daily_embedding_count": 0,
                "last_reset_date": date.today().isoformat(),
                "total_extractions": 0,
                "total_generations": 0,
                "total_embeddings": 0,
            }

            db.table("user_ai_settings").insert(default_settings).execute()
            return default_settings

        except Exception as e:
            logger.error("Failed to get user AI settings", user_id=user_id, error=str(e))
            raise AIServiceError(f"Failed to get AI settings: {str(e)}")

    @staticmethod
    async def update_user_settings(
        user_id: str,
        updates: Dict[str, Any],
        db,
    ) -> Dict[str, Any]:
        """
        Update AI settings for a user.

        Args:
            user_id: The user's ID
            updates: Settings updates (may include provider configs)
            db: Supabase client

        Returns:
            Updated settings dict
        """
        try:
            # Get current settings first
            current = await AISettingsService.get_user_settings(user_id, db)

            # Process provider configs - encrypt any API keys
            if "provider_configs" in updates:
                new_configs = updates["provider_configs"]
                current_configs = current.get("provider_configs", {})

                for provider_name, config in new_configs.items():
                    if isinstance(config, dict) and "api_key" in config:
                        api_key = config["api_key"]
                        if api_key:
                            # Encrypt the new API key
                            encrypted = encrypt_api_key(api_key)
                            if encrypted:
                                config["api_key_encrypted"] = encrypted
                            del config["api_key"]

                    # Merge with existing config
                    if provider_name in current_configs:
                        current_configs[provider_name].update(config)
                    else:
                        current_configs[provider_name] = config

                updates["provider_configs"] = current_configs

            # Update in database
            result = db.table("user_ai_settings").update(updates).eq("user_id", user_id).execute()

            if result.data and len(result.data) > 0:
                return result.data[0]

            return await AISettingsService.get_user_settings(user_id, db)

        except Exception as e:
            logger.error("Failed to update user AI settings", user_id=user_id, error=str(e))
            raise AIServiceError(f"Failed to update AI settings: {str(e)}")

    @staticmethod
    async def get_effective_provider_config(
        user_id: str,
        provider: AIProvider,
        db,
    ) -> ProviderConfig:
        """
        Get the effective provider configuration (user override or system default).

        Args:
            user_id: The user's ID
            provider: Which provider to get config for
            db: Supabase client

        Returns:
            ProviderConfig for the specified provider

        Raises:
            AIServiceError: If no valid configuration is available
        """
        # Get user settings
        user_settings = await AISettingsService.get_user_settings(user_id, db)
        provider_configs = user_settings.get("provider_configs", {})

        # Check for user-level override
        user_config = provider_configs.get(provider.value, {})
        if user_config.get("api_key_encrypted") and user_config.get("api_url"):
            api_key = decrypt_api_key(user_config["api_key_encrypted"])
            if api_key:
                return ProviderConfig(
                    api_url=user_config["api_url"],
                    api_key=api_key,
                    model=user_config.get("model", "gemini-3-flash-preview"),
                    vision_model=user_config.get("vision_model"),
                    image_gen_model=user_config.get("image_gen_model"),
                )

        # Fall back to system configuration
        system_config = get_system_provider_config(provider)
        if not system_config:
            raise AIServiceError(
                f"AI provider '{provider.value}' is not configured. "
                "Please configure the provider in your AI settings."
            )

        return system_config

    @staticmethod
    async def get_ai_service_for_user(
        user_id: str,
        db,
        provider: Optional[AIProvider] = None,
    ) -> AIProviderService:
        """
        Get an AI service instance configured for a specific user.

        Args:
            user_id: The user's ID
            db: Supabase client
            provider: Optional provider override (uses user default if not specified)

        Returns:
            Configured AIProviderService instance
        """
        # Get user settings to determine default provider
        user_settings = await AISettingsService.get_user_settings(user_id, db)

        if provider is None:
            provider_str = user_settings.get("default_provider", "gemini")
            try:
                provider = AIProvider(provider_str)
            except ValueError:
                provider = AIProvider.GEMINI

        config = await AISettingsService.get_effective_provider_config(user_id, provider, db)
        return AIProviderService(config)

    @staticmethod
    async def check_rate_limit(
        user_id: str,
        operation_type: str,
        db,
        count: int = 1,
    ) -> Dict[str, Any]:
        """
        Check if user has exceeded rate limits.

        Args:
            user_id: The user's ID
            operation_type: "extraction", "generation", or "embedding"
            db: Supabase client
            count: Number of operations the user wants to perform (default: 1)

        Returns:
            Dict with allowed, current_count, and limit
        """
        user_settings = await AISettingsService.get_user_settings(user_id, db)

        if operation_type == "extraction":
            current = user_settings.get("daily_extraction_count", 0)
            limit = settings.AI_DAILY_EXTRACTION_LIMIT
        elif operation_type == "embedding":
            current = user_settings.get("daily_embedding_count", 0)
            limit = settings.AI_DAILY_EMBEDDING_LIMIT
        else:  # generation
            current = user_settings.get("daily_generation_count", 0)
            limit = settings.AI_DAILY_GENERATION_LIMIT

        requested = max(0, int(count))
        return {
            "allowed": (current + requested) <= limit,
            "current_count": current,
            "limit": limit,
            "remaining": max(0, limit - current),
        }

    @staticmethod
    async def increment_usage(
        user_id: str,
        operation_type: str,
        db,
        count: int = 1,
    ) -> None:
        """
        Increment usage counter for a user.

        Args:
            user_id: The user's ID
            operation_type: "extraction", "generation", or "embedding"
            db: Supabase client
            count: Number of operations to increment by (default: 1)
        """
        try:
            # Get current settings
            user_settings = await AISettingsService.get_user_settings(user_id, db)

            if operation_type == "extraction":
                updates = {
                    "daily_extraction_count": user_settings.get("daily_extraction_count", 0) + count,
                    "total_extractions": user_settings.get("total_extractions", 0) + count,
                }
            elif operation_type == "embedding":
                updates = {
                    "daily_embedding_count": user_settings.get("daily_embedding_count", 0) + count,
                    "total_embeddings": user_settings.get("total_embeddings", 0) + count,
                }
            else:  # generation
                updates = {
                    "daily_generation_count": user_settings.get("daily_generation_count", 0) + count,
                    "total_generations": user_settings.get("total_generations", 0) + count,
                }

            db.table("user_ai_settings").update(updates).eq("user_id", user_id).execute()

        except Exception as e:
            logger.error("Failed to increment usage", user_id=user_id, error=str(e))
            # Don't raise - this shouldn't block the operation

    @staticmethod
    async def get_usage_stats(user_id: str, db) -> Dict[str, Any]:
        """
        Get usage statistics for a user.

        Args:
            user_id: The user's ID
            db: Supabase client

        Returns:
            Usage statistics dict
        """
        user_settings = await AISettingsService.get_user_settings(user_id, db)

        return {
            "daily": {
                "extractions": user_settings.get("daily_extraction_count", 0),
                "generations": user_settings.get("daily_generation_count", 0),
                "embeddings": user_settings.get("daily_embedding_count", 0),
            },
            "total": {
                "extractions": user_settings.get("total_extractions", 0),
                "generations": user_settings.get("total_generations", 0),
                "embeddings": user_settings.get("total_embeddings", 0),
            },
            "limits": {
                "daily_extractions": settings.AI_DAILY_EXTRACTION_LIMIT,
                "daily_generations": settings.AI_DAILY_GENERATION_LIMIT,
                "daily_embeddings": settings.AI_DAILY_EMBEDDING_LIMIT,
            },
            "remaining": {
                "extractions": max(0, settings.AI_DAILY_EXTRACTION_LIMIT - user_settings.get("daily_extraction_count", 0)),
                "generations": max(0, settings.AI_DAILY_GENERATION_LIMIT - user_settings.get("daily_generation_count", 0)),
                "embeddings": max(0, settings.AI_DAILY_EMBEDDING_LIMIT - user_settings.get("daily_embedding_count", 0)),
            },
        }

    @staticmethod
    def get_provider_display_config(
        provider_configs: Dict[str, Any],
    ) -> Dict[str, Any]:
        """
        Get provider configs for display (mask API keys).

        Args:
            provider_configs: Raw provider configs from database

        Returns:
            Configs with masked API keys
        """
        display_configs = {}

        for provider_name, config in provider_configs.items():
            display_config = {
                "api_url": config.get("api_url", ""),
                "model": config.get("model", ""),
                "vision_model": config.get("vision_model", ""),
                "image_gen_model": config.get("image_gen_model", ""),
                "api_key_set": bool(config.get("api_key_encrypted")),
            }
            display_configs[provider_name] = display_config

        return display_configs

    @staticmethod
    async def test_provider_config(
        api_url: str,
        api_key: str,
        model: str,
    ) -> Dict[str, Any]:
        """
        Test a provider configuration.

        Args:
            api_url: The API URL to test
            api_key: The API key to test
            model: The model to test with

        Returns:
            Test result with success status and message
        """
        config = ProviderConfig(
            api_url=api_url,
            api_key=api_key,
            model=model,
            timeout=30.0,  # Shorter timeout for testing
        )

        service = AIProviderService(config)
        try:
            result = await service.test_connection()
            return result
        finally:
            await service.close()
