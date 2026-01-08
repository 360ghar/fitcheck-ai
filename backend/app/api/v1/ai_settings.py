"""
AI Settings API routes.

Provides endpoints for managing per-user AI provider configuration.
"""

from typing import Any, Dict

from fastapi import APIRouter, Depends, status
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError, ValidationError
from app.core.security import get_current_user_id
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

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# SETTINGS CRUD
# =============================================================================


@router.get(
    "",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def get_ai_settings(
    user_id: str = Depends(get_current_user_id),
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
            default_provider=settings.get("default_provider", "gemini"),
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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Update AI settings for the current user.

    Can update the default provider and provider-specific configurations.
    API keys are encrypted before storage.
    """
    try:
        updates: Dict[str, Any] = {}

        if request.default_provider is not None:
            valid_providers = ["gemini", "openai", "custom"]
            if request.default_provider not in valid_providers:
                raise ValidationError(
                    "Invalid provider",
                    details={"valid_providers": valid_providers},
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
    user_id: str = Depends(get_current_user_id),
):
    """
    Test an AI provider configuration.

    Sends a simple test request to verify the API URL and key are valid.
    """
    try:
        result = await AISettingsService.test_provider_config(
            api_url=request.api_url,
            api_key=request.api_key,
            model=request.model,
        )

        response = TestProviderResponse(
            success=result.get("success", False),
            message=result.get("message", "Unknown error"),
            model=result.get("model"),
            response=result.get("response"),
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
    user_id: str = Depends(get_current_user_id),
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
    user_id: str = Depends(get_current_user_id),
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
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Reset a provider configuration to defaults.

    Removes any user-specific API key and URL for the specified provider.
    """
    try:
        valid_providers = ["gemini", "openai", "custom"]
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
            db.table("user_ai_settings").update({
                "provider_configs": provider_configs,
            }).eq("user_id", user_id).execute()

        return {
            "data": {"provider": provider, "reset": True},
            "message": f"Provider '{provider}' configuration reset to defaults",
        }

    except (ValidationError, AIServiceError):
        raise
    except Exception as e:
        logger.error("Reset provider error", user_id=user_id, provider=provider, error=str(e))
        raise AIServiceError(f"Failed to reset provider: {str(e)}")
