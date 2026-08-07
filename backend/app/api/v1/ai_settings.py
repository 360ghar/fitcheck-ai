"""
AI Settings API routes.

Provides endpoints for managing per-user AI provider configuration.
"""

import asyncio
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, status
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError, ValidationError
from app.api.v1.deps import get_active_user_id
from app.db.connection import get_db
from app.models.ai import (
    AISettingsUpdate,
    AISettingsResponse,
    ProviderConfigDisplay,
    TestProviderRequest,
    TestProviderResponse,
    UsageStatsResponse,
    RateLimitCheckResponse,
)
from app.services.ai_settings_service import AISettingsService
from app.services.ai_provider_interface import AIProvider, valid_provider_values
from app.services.ai_provider_service import get_system_provider_config

logger = get_context_logger(__name__)

router = APIRouter()


def _provider_has_usable_config(
    provider_value: str,
    request: "AISettingsUpdate",
    current_settings: Dict[str, Any],
) -> bool:
    """True if ``provider_value`` has a system key, a BYOK key in this request,
    or an existing stored BYOK key. Used to stop a user persisting a
    ``default_provider`` whose every AI call would 503 (e.g. 'openai' with no
    system key and no key of their own). See RCA 2026-08-05.

    Takes an already-fetched ``current_settings`` so the settings row is read once
    per request: this guard and ``update_user_settings`` both need it, and each
    fetching its own copy cost a redundant Supabase round-trip on every save.
    """
    try:
        provider = AIProvider(provider_value)
    except ValueError:
        return True  # the earlier valid-providers check handles malformed input

    if get_system_provider_config(provider):
        return True

    # BYOK key submitted in this same request?
    submitted = request.provider_configs or {}
    if provider_value in submitted:
        cfg = submitted[provider_value]
        if getattr(cfg, "api_key", None):
            return True

    # Existing stored BYOK key? Same predicate the runtime fallback uses, so the
    # write-side gate and the read-side fallback cannot disagree.
    return AISettingsService.has_stored_byok_key(current_settings, provider)


# =============================================================================
# SETTINGS CRUD
# =============================================================================


@router.get(
    "",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def get_ai_settings(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Get AI settings for the current user.

    Returns the default provider and configured provider settings (with masked API keys).
    """
    try:
        settings = await AISettingsService.get_user_settings(user_id=user_id, db=db)

        # Get display-safe provider configs
        provider_configs = settings.get("provider_configs", {})
        display_configs = AISettingsService.get_provider_display_config(provider_configs)

        # Get usage stats
        usage = await AISettingsService.get_usage_stats(user_id=user_id, db=db)

        response = AISettingsResponse(
            default_provider=settings.get("default_provider", "custom"),
            provider_configs={
                name: ProviderConfigDisplay(**config)
                for name, config in display_configs.items()
            },
            usage=usage,
        )

        return {
            "data": response.model_dump(),
            "message": "OK",
        }

    except AIServiceError:
        raise
    except Exception as e:
        logger.error("Get AI settings error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to get AI settings: {str(e)}")


@router.put(
    "",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def update_ai_settings(
    request: AISettingsUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Update AI settings for the current user.

    Can update the default provider and provider-specific configurations.
    API keys are encrypted before storage.
    """
    try:
        updates: Dict[str, Any] = {}
        # Fetched at most once and shared with update_user_settings below.
        current_settings: Optional[Dict[str, Any]] = None

        if request.default_provider is not None:
            valid_providers = valid_provider_values()
            if request.default_provider not in valid_providers:
                raise ValidationError(
                    "Invalid provider",
                    details={"valid_providers": valid_providers},
                )
            # Reject selecting a provider with no usable config, so the user
            # cannot persist e.g. default_provider='openai' and have every AI
            # call 503. The runtime get_ai_service_for_user still falls back to
            # the system default as a safety net.
            current_settings = await AISettingsService.get_user_settings(user_id, db)
            if not _provider_has_usable_config(
                request.default_provider, request, current_settings
            ):
                raise ValidationError(
                    f"The '{request.default_provider}' provider is not configured. "
                    "Add an API key for it first or choose a configured provider.",
                    details={"provider": request.default_provider},
                )
            updates["default_provider"] = request.default_provider

        if request.provider_configs is not None:
            # Convert Pydantic models to dicts
            updates["provider_configs"] = {
                name: config.model_dump(exclude_unset=True)
                for name, config in request.provider_configs.items()
            }

        if not updates:
            # Nothing to update, return current settings
            return await get_ai_settings(user_id=user_id, db=db)

        # Perform update
        await AISettingsService.update_user_settings(
            user_id=user_id,
            updates=updates,
            db=db,
            current_settings=current_settings,
        )

        # Return updated settings
        return await get_ai_settings(user_id=user_id, db=db)

    except (AIServiceError, ValidationError):
        raise
    except Exception as e:
        logger.error("Update AI settings error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to update AI settings: {str(e)}")


# =============================================================================
# PROVIDER TESTING
# =============================================================================


@router.post(
    "/test",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def test_provider_config(
    request: TestProviderRequest,
    user_id: str = Depends(get_active_user_id),
):
    """
    Test an AI provider configuration.

    Sends a simple test request to verify the API URL and key are valid
    (api_url is required for openai/custom, ignored for gemini).
    """
    try:
        valid_providers = valid_provider_values()
        if request.provider not in valid_providers:
            raise ValidationError(
                "Invalid provider",
                details={"valid_providers": valid_providers},
            )
        provider = AIProvider(request.provider)
        if provider != AIProvider.GEMINI and not request.api_url:
            raise ValidationError(
                "api_url is required for this provider",
                details={"provider": request.provider},
            )

        result = await AISettingsService.test_provider_config(
            api_url=request.api_url,
            api_key=request.api_key,
            model=request.model,
            provider=provider,
        )

        # test_provider_config returns a HealthCheckResult model (or a dict-shaped
        # envelope from older code paths/tests). Normalize via to_api_dict when the
        # typed model is returned; fall back to dict .get() for raw envelopes.
        if hasattr(result, "to_api_dict"):
            envelope = result.to_api_dict()
        else:
            envelope = result

        response = TestProviderResponse(
            success=envelope.get("success", False),
            message=envelope.get("message", "Unknown error"),
            model=envelope.get("model"),
            response=envelope.get("response"),
        )

        return {
            "data": response.model_dump(),
            "message": "Test completed",
        }

    except Exception as e:
        logger.error("Test provider error", user_id=user_id, error=str(e))
        return {
            "data": TestProviderResponse(
                success=False,
                message=str(e),
            ).model_dump(),
            "message": "Test failed",
        }


# =============================================================================
# USAGE STATISTICS
# =============================================================================


@router.get(
    "/usage",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def get_usage_stats(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Get AI usage statistics for the current user.

    Returns daily and total usage counts along with rate limits.
    """
    try:
        usage = await AISettingsService.get_usage_stats(user_id=user_id, db=db)

        response = UsageStatsResponse(
            daily=usage.get("daily", {}),
            total=usage.get("total", {}),
            limits=usage.get("limits", {}),
            remaining=usage.get("remaining", {}),
        )

        return {
            "data": response.model_dump(),
            "message": "OK",
        }

    except Exception as e:
        logger.error("Get usage stats error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to get usage stats: {str(e)}")


@router.get(
    "/rate-limit/{operation_type}",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def check_rate_limit(
    operation_type: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Check rate limit for a specific operation type.

    Returns whether the operation is allowed and remaining quota.
    """
    try:
        if operation_type not in ["extraction", "generation"]:
            raise ValidationError(
                "Invalid operation type",
                details={"valid_types": ["extraction", "generation"]},
            )

        result = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type=operation_type,
            db=db,
        )

        response = RateLimitCheckResponse(
            allowed=result["allowed"],
            current_count=result["current_count"],
            limit=result["limit"],
            remaining=result["remaining"],
        )

        return {
            "data": response.model_dump(),
            "message": "OK",
        }

    except (ValidationError, AIServiceError):
        raise
    except Exception as e:
        logger.error("Check rate limit error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to check rate limit: {str(e)}")


# =============================================================================
# RESET (Admin or Self-Service)
# =============================================================================


@router.post(
    "/reset-provider/{provider}",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def reset_provider_config(
    provider: str,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """
    Reset a provider configuration to defaults.

    Removes any user-specific API key and URL for the specified provider.
    """
    try:
        valid_providers = valid_provider_values()
        if provider not in valid_providers:
            raise ValidationError(
                "Invalid provider",
                details={"valid_providers": valid_providers},
            )

        # Get current settings
        settings = await AISettingsService.get_user_settings(user_id=user_id, db=db)
        provider_configs = settings.get("provider_configs", {})

        # Remove the provider config
        if provider in provider_configs:
            del provider_configs[provider]

            # Update settings
            await asyncio.to_thread(db.table("user_ai_settings").update({
                "provider_configs": provider_configs,
            }).eq("user_id", user_id).execute)

        return {
            "data": {"provider": provider, "reset": True},
            "message": f"Provider '{provider}' configuration reset to defaults",
        }

    except (ValidationError, AIServiceError):
        raise
    except Exception as e:
        logger.error("Reset provider error", user_id=user_id, provider=provider, error=str(e))
        raise AIServiceError(f"Failed to reset provider: {str(e)}")
