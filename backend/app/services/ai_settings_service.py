"""
AI Settings Service - Manages per-user AI provider configuration.

This service handles:
- Get effective config (user override or system default)
- Encrypt/decrypt user API keys
- Validate provider configurations
- Rate limit checking and tracking
- Reset rate limits daily
"""

import asyncio
from datetime import date
from typing import Any, Dict, Optional

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.models.ai import HealthCheckResult
from app.services.ai_provider_service import (
    AIProvider,
    get_system_provider_config,
    get_default_provider,
)
from app.services.ai_provider_interface import AIProviderClient, get_provider_class
from app.utils.crypto import derive_fernet_key, legacy_derive_fernet_key
from app.utils.db import (
    QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
    execute_with_reconnect,
    is_pgrst202_missing_rpc,
    maybe_single_data,
    missing_rpc_log_hint,
    unwrap_rpc_bool,
)

logger = get_context_logger(__name__)

_KEY_PURPOSE = b"fitcheck-ai-settings-api-key-v1"

# Quota admission depends on hosted-Supabase RPCs created by migrations
# 022/024/026. When those migrations were not applied, PostgREST answers every
# rpc() call with PGRST202 ("Could not find the function ... in the schema
# cache") and admission fails closed with a 503. The missing-RPC detail is
# LOGGED (see app/utils/db.py missing_rpc_log_hint) so operators can diagnose
# it; clients only ever see the friendly message, never the raw DB text.
# Observed 2026-07-31: every batch-extract returned 500 for exactly this reason.

# Friendly copy for a new-user FK race on user_ai_settings.user_id (profile
# row not propagated yet). Raw FK detail stays in the logs.
_ACCOUNT_NOT_READY_CLIENT_MESSAGE = (
    "Your account is still being set up. Please try again in a few seconds."
)


# =============================================================================
# ENCRYPTION HELPERS
# =============================================================================


def _get_encryption_key() -> Optional[bytes]:
    """Get the purpose-scoped Fernet encryption key for user AI-provider API keys."""
    key = settings.AI_ENCRYPTION_KEY
    if not key:
        return None

    try:
        return derive_fernet_key(key, _KEY_PURPOSE)
    except Exception as e:
        logger.error("Failed to derive encryption key", error=str(e))
        return None


def _get_legacy_encryption_key() -> Optional[bytes]:
    """Pre-domain-separation key, tried only as a decrypt fallback so
    already-encrypted API keys stay readable across the migration window."""
    key = settings.AI_ENCRYPTION_KEY
    if not key:
        return None
    try:
        return legacy_derive_fernet_key(key)
    except (ValueError, TypeError, ImportError):
        logger.error("Failed to derive encryption key", exc_info=True)
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
        if not settings.DEBUG:
            # In production, encryption key is required for API key storage
            raise AIServiceError(
                "AI_ENCRYPTION_KEY must be configured in production to store user API keys"
            )
        logger.warning("Encryption key not configured, storing API key in plaintext (DEBUG mode only)")
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

    # Try the current purpose-scoped key first, then the legacy
    # (pre-domain-separation) key for API keys encrypted before this change.
    for key in (fernet_key, _get_legacy_encryption_key()):
        if not key:
            continue
        try:
            decrypted = Fernet(key).decrypt(encrypted_key.encode())
            return decrypted.decode()
        except InvalidToken:
            continue
        except Exception as e:
            logger.error("Failed to decrypt API key", error=str(e))
            return None

    logger.error("Failed to decrypt API key: invalid token")
    return None


# =============================================================================
# AI SETTINGS SERVICE
# =============================================================================


def _default_settings_row(user_id: str) -> Dict[str, Any]:
    """Default user_ai_settings row, shared by read-path provisioning and the
    lightweight reservation pre-check."""
    return {
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
            result = await execute_with_reconnect(
                lambda d: d.table("user_ai_settings").select("*").eq("user_id", user_id).execute(),
                db,
                extra={"operation": "get_user_ai_settings.select", "user_id": user_id},
            )

            if result.data and len(result.data) > 0:
                settings_row = result.data[0]

                # Check if daily reset is needed
                last_reset = settings_row.get("last_reset_date")
                if last_reset:
                    if isinstance(last_reset, str):
                        last_reset = date.fromisoformat(last_reset)
                    if last_reset < date.today():
                        # Reset daily counts
                        await execute_with_reconnect(
                            lambda d: d.table("user_ai_settings").update({
                                "daily_extraction_count": 0,
                                "daily_generation_count": 0,
                                "daily_embedding_count": 0,
                                "last_reset_date": date.today().isoformat(),
                            }).eq("user_id", user_id).execute(),
                            db,
                            extra={"operation": "get_user_ai_settings.reset", "user_id": user_id},
                        )
                        settings_row["daily_extraction_count"] = 0
                        settings_row["daily_generation_count"] = 0
                        settings_row["daily_embedding_count"] = 0

                return settings_row

            # Create default settings if not exists. Must be an upsert (not a
            # plain insert): get_user_settings and ensure_ai_settings_row run
            # concurrently on a user's first admission (observed 2026-08-03:
            # duplicate key user_ai_settings_pkey 23505 -> 503 from a
            # select-miss race). The upsert is exact-once on the PK; re-select
            # so the row reflects whatever the winning writer stored.
            default_settings = _default_settings_row(user_id)

            await execute_with_reconnect(
                lambda d: d.table("user_ai_settings")
                .upsert(default_settings, on_conflict="user_id")
                .execute(),
                db,
                extra={"operation": "get_user_ai_settings.upsert_default", "user_id": user_id},
            )
            row = await execute_with_reconnect(
                lambda d: d.table("user_ai_settings")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "get_user_ai_settings.reselect_default", "user_id": user_id},
            )
            return maybe_single_data(row) or default_settings

        except Exception as e:
            logger.error("Failed to get user AI settings", user_id=user_id, error=str(e))
            raise AIServiceError(f"Failed to get AI settings: {str(e)}")

    @staticmethod
    async def update_user_settings(
        user_id: str,
        updates: Dict[str, Any],
        db,
        current_settings: Optional[Dict[str, Any]] = None,
    ) -> Dict[str, Any]:
        """
        Update AI settings for a user.

        Args:
            user_id: The user's ID
            updates: Settings updates (may include provider configs)
            db: Supabase client
            current_settings: Already-fetched settings row, if the caller has one.
                The route's default-provider guard reads the same row, so passing
                it here saves a redundant Supabase round-trip per save.

        Returns:
            Updated settings dict
        """
        try:
            current = (
                current_settings
                if current_settings is not None
                else await AISettingsService.get_user_settings(user_id, db)
            )

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
            result = await asyncio.to_thread(db.table("user_ai_settings").update(updates).eq("user_id", user_id).execute)

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
    ) -> Any:
        """
        Get the effective provider configuration (user override or system default).

        Args:
            user_id: The user's ID
            provider: Which provider to get config for
            db: Supabase client

        Returns:
            Provider config for the specified provider (ProviderConfig for
            OPENAI/CUSTOM, GeminiConfig for GEMINI) - dispatched via the
            provider registry so adding a new provider doesn't require
            editing this function.

        Raises:
            AIServiceError: If no valid configuration is available
        """
        # Get user settings
        user_settings = await AISettingsService.get_user_settings(user_id, db)
        provider_configs = user_settings.get("provider_configs", {})
        user_config = provider_configs.get(provider.value, {})
        provider_cls = get_provider_class(provider)

        # Check for user-level override. Completeness (e.g. an OpenAI-
        # compatible config also needs api_url) is decided by
        # config_cls.from_user_dict(), which returns None if incomplete -
        # Gemini has no such requirement beyond the key.
        if user_config.get("api_key_encrypted"):
            api_key = decrypt_api_key(user_config["api_key_encrypted"])
            if api_key:
                config = provider_cls.config_cls.from_user_dict(user_config, api_key=api_key)
                if config:
                    return config

        # Fall back to system configuration
        system_config = get_system_provider_config(provider)
        if not system_config:
            raise AIServiceError(
                f"AI provider '{provider.value}' is not configured. "
                "Please configure the provider in your AI settings."
            )

        return system_config

    @staticmethod
    def has_stored_byok_key(user_settings: dict, provider: AIProvider) -> bool:
        """True when the user stored their OWN key for ``provider``.

        A stored key is the signal that the provider choice is deliberate, which
        is what separates "stale default nobody set on purpose" (safe to fall
        back) from "the provider this user picked for their data" (never
        silently substitute). Reads an already-fetched settings dict so callers
        pay no extra query.

        Twin of the write-side guard ``_provider_has_usable_config`` in
        ``app/api/v1/ai_settings.py``, which also considers a key submitted in
        the same request.
        """
        stored = (user_settings.get("provider_configs") or {}).get(provider.value, {})
        return bool(isinstance(stored, dict) and stored.get("api_key_encrypted"))

    @staticmethod
    async def get_ai_service_for_user(
        user_id: str,
        db,
        provider: Optional[AIProvider] = None,
    ) -> AIProviderClient:
        """
        Get an AI service instance configured for a specific user.

        Args:
            user_id: The user's ID
            db: Supabase client
            provider: Optional provider override (uses user default if not specified)

        Returns:
            Configured provider instance (AIProviderClient)
        """
        # Get user settings to determine default provider
        user_settings = await AISettingsService.get_user_settings(user_id, db)

        if provider is None:
            provider_str = user_settings.get("default_provider", "custom")
            try:
                provider = AIProvider(provider_str)
            except ValueError:
                provider = AIProvider.CUSTOM

        try:
            config = await AISettingsService.get_effective_provider_config(user_id, provider, db)
        except AIServiceError:
            # The user's selected provider has no resolvable config - most
            # commonly a stale ``default_provider='openai'`` row left over from
            # an old BYOK setup, with no system OpenAI key. Rather than hard-
            # fail the AI call, fall back to the system default provider (the
            # Agnes 'custom' gateway in production) so the user can still use
            # the feature. See RCA 2026-08-05 (POST /ai/generate-outfit 503s).
            #
            # NOT when the user supplied their OWN key for this provider: the
            # key existing means they deliberately chose where their prompts and
            # body photos go, and it is merely unresolvable right now (key
            # deleted, encryption key rotated). Silently re-routing that traffic
            # to the system gateway would send their images to a provider they
            # did not pick, with only a server-side log. Fail loudly instead so
            # they are told their provider is broken.
            if AISettingsService.has_stored_byok_key(user_settings, provider):
                logger.warning(
                    "User's own provider key is unusable; refusing to re-route "
                    "to the system default",
                    user_id=user_id,
                    requested_provider=provider.value,
                )
                raise
            fallback_provider = get_default_provider()
            if fallback_provider == provider:
                raise
            logger.warning(
                "AI provider not configured, falling back to system default",
                user_id=user_id,
                requested_provider=provider.value,
                fallback_provider=fallback_provider.value,
            )
            provider = fallback_provider
            config = await AISettingsService.get_effective_provider_config(user_id, provider, db)

        return get_provider_class(provider)(config)

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
    async def ensure_ai_settings_row(user_id: str, db) -> None:
        """Ensure a ``user_ai_settings`` row exists before an RPC reservation.

        Daily-counter resets happen atomically inside ``reserve_ai_usage``
        (migration 024) under a row lock, so reservations only need the row to
        exist for the RPC's UPDATE to match. Selects ``user_id`` (the table's
        primary key) only - the full-row ``get_user_settings`` read (which also
        returns encrypted provider keys) is for read paths, not admission.
        """
        try:
            result = await execute_with_reconnect(
                lambda d: d.table("user_ai_settings")
                .select("user_id")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "ensure_ai_settings_row.select", "user_id": user_id},
            )
            if result and result.data:
                return
            # Upsert on the PK: extraction + generation reservations run
            # concurrently, so a user's very first admission can race two
            # select-misses into a duplicate-key insert.
            await execute_with_reconnect(
                lambda d: d.table("user_ai_settings")
                .upsert(_default_settings_row(user_id), on_conflict="user_id")
                .execute(),
                db,
                extra={"operation": "ensure_ai_settings_row.upsert", "user_id": user_id},
            )
        except Exception as e:
            if "23503" in str(e) or "users_id_fkey" in str(e):
                # user_ai_settings.user_id references public.users(id); a brand-
                # new auth user whose profile row has not propagated yet hits
                # this FK race (auth.py retries the same condition on login).
                # The raw FK detail stays in the log (message + error field);
                # clients get the friendly account-setup message.
                logger.error(
                    "AI settings provisioning FK race: user profile not ready "
                    "(users_id_fkey 23503)",
                    user_id=user_id,
                    error=str(e),
                )
                raise AIServiceError(
                    _ACCOUNT_NOT_READY_CLIENT_MESSAGE,
                    retryable=True,
                ) from e
            logger.error("Failed to ensure AI settings row", user_id=user_id, error=str(e))
            raise AIServiceError(
                QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
                retryable=True,
            ) from e

    @staticmethod
    async def reserve_usage(
        user_id: str,
        operation_type: str,
        db,
        count: int = 1,
    ) -> bool:
        """Atomically reserve a daily AI quota before starting provider work."""
        operation = getattr(operation_type, "value", operation_type)
        if count <= 0:
            raise ValueError("count must be positive")
        limits = {
            "extraction": settings.AI_DAILY_EXTRACTION_LIMIT,
            "generation": settings.AI_DAILY_GENERATION_LIMIT,
            "embedding": settings.AI_DAILY_EMBEDDING_LIMIT,
        }
        if operation not in limits:
            raise ValueError(f"Unknown AI operation type: {operation_type}")

        # Ensure the row exists before the RPC; the function intentionally
        # fails closed when the hosted migration or row is unavailable.
        await AISettingsService.ensure_ai_settings_row(user_id, db)
        try:
            # Deliberately NOT wrapped in execute_with_reconnect: reserve_ai_usage
            # is a non-idempotent conditional counter increment. If the first
            # call committed server-side but the response was lost on the dead
            # pooled connection, an automatic retry would reserve the same
            # admission twice (double daily quota + inflated totals) or return
            # false against the now-inflated counter while the first
            # reservation stays consumed. Fail closed instead: the connection
            # error below becomes the friendly retryable 503, and callers
            # (batch/photoshoot/try-on routes) already retry admission at a
            # higher layer. release_usage KEEPS the reconnect wrap because
            # release is GREATEST(0, …)-bounded — a retry there is harmless.
            result = await asyncio.to_thread(
                db.rpc(
                    "reserve_ai_usage",
                    {
                        "p_user_id": user_id,
                        "p_operation": operation,
                        "p_count": count,
                        "p_limit": limits[operation],
                    },
                ).execute
            )
        except Exception as error:
            if is_pgrst202_missing_rpc(error):
                # Migration gap, not a transient provider hiccup: log the
                # actionable hint (function + migrations) for operators. The
                # client-facing message stays friendly — never raw DB text.
                logger.error(
                    missing_rpc_log_hint("reserve_ai_usage"),
                    user_id=user_id,
                    function="reserve_ai_usage",
                    migrations="022/024/026",
                    rpc_error=str(error),
                )
            else:
                logger.error("Failed to reserve AI usage", user_id=user_id, error=str(error))
            raise AIServiceError(
                QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
                retryable=True,
            ) from error

        # `reserve_ai_usage` returns a scalar BOOLEAN, so PostgREST keys the
        # result by the function name rather than a column name.
        return unwrap_rpc_bool(result, "reserve_ai_usage")

    @staticmethod
    async def release_usage(
        user_id: str,
        operation_type: str,
        db,
        count: int = 1,
    ) -> None:
        """Compensate a reservation when a multi-quota admission fails."""
        operation = getattr(operation_type, "value", operation_type)
        try:
            await execute_with_reconnect(
                lambda d: d.rpc(
                    "release_ai_usage",
                    {
                        "p_user_id": user_id,
                        "p_operation": operation,
                        "p_count": count,
                    },
                ).execute(),
                db,
                extra={"operation": "release_ai_usage", "user_id": user_id},
            )
        except Exception as error:
            if is_pgrst202_missing_rpc(error):
                logger.error(
                    missing_rpc_log_hint("release_ai_usage"),
                    user_id=user_id,
                    function="release_ai_usage",
                    migrations="022/024/026",
                    rpc_error=str(error),
                )
            else:
                logger.error(
                    "Failed to release AI usage reservation",
                    user_id=user_id,
                    error=str(error),
                )
            raise AIServiceError(
                QUOTA_UNAVAILABLE_CLIENT_MESSAGE,
                retryable=True,
            ) from error

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
                "vision_fallback_model": config.get("vision_fallback_model", ""),
                "image_gen_model": config.get("image_gen_model", ""),
                "api_key_set": bool(config.get("api_key_encrypted")),
            }
            display_configs[provider_name] = display_config

        return display_configs

    @staticmethod
    async def test_provider_config(
        api_key: str,
        model: str,
        api_url: Optional[str] = None,
        provider: AIProvider = AIProvider.CUSTOM,
    ) -> HealthCheckResult:
        """
        Test a provider configuration.

        Args:
            api_key: The API key to test
            model: The model to test with
            api_url: The API URL to test (required for openai/custom, ignored for gemini)
            provider: Which provider implementation to test against

        Returns:
            Test result with success status and message
        """
        provider_cls = get_provider_class(provider)
        config = provider_cls.config_cls.for_test(api_key=api_key, model=model, api_url=api_url)

        service = provider_cls(config)
        try:
            result = await service.test_connection()
            return result
        finally:
            await service.close()
