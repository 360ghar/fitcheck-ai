"""
AI Operations API routes.

Provides endpoints for AI-powered item extraction and image generation.
All AI processing is done server-side using configurable providers.
"""

from typing import Any, Dict

from fastapi import APIRouter, Depends, status
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError, RateLimitError
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.utils.retry import with_retry
from app.models.ai import (
    ExtractItemsRequest,
    ExtractItemsResponse,
    ExtractSingleItemRequest,
    ExtractSingleItemResponse,
    GenerateOutfitRequest,
    GenerateOutfitResponse,
    GenerateProductImageRequest,
    GenerateProductImageResponse,
    TryOnRequest,
    TryOnResponse,
    AvailableModelsResponse,
)
from app.agents.item_extraction_agent import get_item_extraction_agent
from app.agents.image_generation_agent import (
    get_image_generation_agent,
    save_generated_image,
)
from app.services.ai_settings_service import AISettingsService

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# ITEM EXTRACTION
# =============================================================================


@router.post(
    "/extract-items",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def extract_items(
    request: ExtractItemsRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Extract multiple clothing items from an image.

    Returns detected items with categories, colors, materials, bounding boxes,
    and detailed descriptions suitable for image generation.
    """
    try:
        # Check rate limit
        rate_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="extraction",
            db=db,
        )
        if not rate_check["allowed"]:
            raise RateLimitError(
                f"Daily extraction limit ({rate_check['limit']}) exceeded. "
                f"Resets at midnight UTC."
            )

        # Get extraction agent
        agent = await get_item_extraction_agent(user_id=user_id, db=db)

        # Extract items with retry
        result = await with_retry(
            lambda: agent.extract_multiple_items(image_base64=request.image),
            max_retries=3,
            initial_delay=2.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
            on_retry=lambda attempt, error, delay: logger.warning(
                "Retrying extract_multiple_items",
                attempt=attempt,
                delay=delay,
                error=str(error),
            ),
        )

        # Increment usage
        await AISettingsService.increment_usage(
            user_id=user_id,
            operation_type="extraction",
            db=db,
        )

        return {
            "data": ExtractItemsResponse(**result).model_dump(),
            "message": "Items extracted successfully",
        }

    except (AIServiceError, RateLimitError):
        raise
    except Exception as e:
        logger.error("Extract items error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to extract items: {str(e)}")


@router.post(
    "/extract-single-item",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def extract_single_item(
    request: ExtractSingleItemRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Extract a single clothing item from an image.

    Useful when the image contains only one item.
    """
    try:
        # Check rate limit
        rate_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="extraction",
            db=db,
        )
        if not rate_check["allowed"]:
            raise RateLimitError(
                f"Daily extraction limit ({rate_check['limit']}) exceeded."
            )

        # Get extraction agent
        agent = await get_item_extraction_agent(user_id=user_id, db=db)

        # Extract single item with retry
        result = await with_retry(
            lambda: agent.extract_single_item(
                image_base64=request.image,
                category_hint=request.category_hint,
            ),
            max_retries=3,
            initial_delay=2.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
            on_retry=lambda attempt, error, delay: logger.warning(
                "Retrying extract_single_item",
                attempt=attempt,
                delay=delay,
                error=str(error),
            ),
        )

        # Increment usage
        await AISettingsService.increment_usage(
            user_id=user_id,
            operation_type="extraction",
            db=db,
        )

        return {
            "data": ExtractSingleItemResponse(**result).model_dump(),
            "message": "Item extracted successfully",
        }

    except (AIServiceError, RateLimitError):
        raise
    except Exception as e:
        logger.error("Extract single item error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to extract item: {str(e)}")


# =============================================================================
# IMAGE GENERATION
# =============================================================================


@router.post(
    "/generate-outfit",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def generate_outfit(
    request: GenerateOutfitRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Generate an outfit visualization image.

    Creates a professional fashion photo or flat lay of the specified items.
    """
    try:
        # Check rate limit
        rate_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )
        if not rate_check["allowed"]:
            raise RateLimitError(
                f"Daily generation limit ({rate_check['limit']}) exceeded."
            )

        # Get generation agent
        agent = await get_image_generation_agent(user_id=user_id, db=db)

        # Convert items to dict format
        items = [item.model_dump() for item in request.items]

        # Generate outfit with retry
        result = await with_retry(
            lambda: agent.generate_outfit(
                items=items,
                style=request.style,
                background=request.background,
                pose=request.pose,
                lighting=request.lighting,
                view_angle=request.view_angle,
                include_model=request.include_model,
                model_gender=request.model_gender,
                custom_prompt=request.custom_prompt,
            ),
            max_retries=3,
            initial_delay=2.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
            on_retry=lambda attempt, error, delay: logger.warning(
                "Retrying generate_outfit",
                attempt=attempt,
                delay=delay,
                error=str(error),
            ),
        )

        # Optionally save to storage
        image_url = None
        storage_path = None
        if request.save_to_storage:
            saved = await save_generated_image(
                generated=result,
                user_id=user_id,
                image_type="outfit",
                db=db,
            )
            image_url = saved.get("image_url")
            storage_path = saved.get("storage_path")

        # Increment usage
        await AISettingsService.increment_usage(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )

        response = GenerateOutfitResponse(
            image_base64=result.image_base64,
            image_url=image_url,
            storage_path=storage_path,
            prompt=result.prompt,
            model=result.model,
            provider=result.provider,
        )

        return {
            "data": response.model_dump(),
            "message": "Outfit generated successfully",
        }

    except (AIServiceError, RateLimitError):
        raise
    except Exception as e:
        logger.error("Generate outfit error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to generate outfit: {str(e)}")


@router.post(
    "/generate-product-image",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def generate_product_image(
    request: GenerateProductImageRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Generate a clean e-commerce style product image.

    Creates a professional product photo suitable for catalog listings.
    """
    try:
        # Check rate limit
        rate_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )
        if not rate_check["allowed"]:
            raise RateLimitError(
                f"Daily generation limit ({rate_check['limit']}) exceeded."
            )

        # Get generation agent
        agent = await get_image_generation_agent(user_id=user_id, db=db)

        # Generate product image with retry
        result = await with_retry(
            lambda: agent.generate_product_image(
                item_description=request.item_description,
                category=request.category,
                sub_category=request.sub_category,
                colors=request.colors,
                material=request.material,
                background=request.background,
                view_angle=request.view_angle,
                include_shadows=request.include_shadows,
                reference_image=request.reference_image,
            ),
            max_retries=3,
            initial_delay=2.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
            on_retry=lambda attempt, error, delay: logger.warning(
                "Retrying generate_product_image",
                attempt=attempt,
                delay=delay,
                error=str(error),
            ),
        )

        # Optionally save to storage
        image_url = None
        storage_path = None
        if request.save_to_storage:
            saved = await save_generated_image(
                generated=result,
                user_id=user_id,
                image_type="product",
                db=db,
            )
            image_url = saved.get("image_url")
            storage_path = saved.get("storage_path")

        # Increment usage
        await AISettingsService.increment_usage(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )

        response = GenerateProductImageResponse(
            image_base64=result.image_base64,
            image_url=image_url,
            storage_path=storage_path,
            prompt=result.prompt,
            model=result.model,
            provider=result.provider,
        )

        return {
            "data": response.model_dump(),
            "message": "Product image generated successfully",
        }

    except (AIServiceError, RateLimitError):
        raise
    except Exception as e:
        logger.error("Generate product image error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to generate product image: {str(e)}")


# =============================================================================
# TRY-ON
# =============================================================================


@router.post(
    "/try-on",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def generate_try_on(
    request: TryOnRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Generate a virtual try-on image.

    Combines user's profile picture with uploaded clothing image
    to show how the user would look wearing those clothes.

    Requires user to have uploaded a profile picture (avatar).
    """
    import httpx
    import base64

    try:
        # 1. Fetch user's avatar_url from database
        user_result = db.table("users").select("avatar_url").eq("id", user_id).single().execute()
        user_data = user_result.data

        if not user_data or not user_data.get("avatar_url"):
            from fastapi import HTTPException
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "Profile picture required",
                    "code": "AVATAR_REQUIRED",
                    "message": "Please upload a profile picture before using Try My Look",
                }
            )

        avatar_url = user_data["avatar_url"]

        # 2. Check rate limit
        rate_check = await AISettingsService.check_rate_limit(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )
        if not rate_check["allowed"]:
            raise RateLimitError(
                f"Daily generation limit ({rate_check['limit']}) exceeded."
            )

        # 3. Fetch avatar image and convert to base64
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(avatar_url)
            response.raise_for_status()
            avatar_base64 = base64.b64encode(response.content).decode("utf-8")

        # 4. Get generation agent
        agent = await get_image_generation_agent(user_id=user_id, db=db)

        # 5. Generate try-on image with retry
        result = await with_retry(
            lambda: agent.generate_try_on(
                user_avatar_base64=avatar_base64,
                clothing_image_base64=request.clothing_image,
                clothing_description=request.clothing_description,
                style=request.style,
                background=request.background,
                pose=request.pose,
                lighting=request.lighting,
            ),
            max_retries=3,
            initial_delay=2.0,
            backoff_factor=2.0,
            retryable_exceptions=(AIServiceError, Exception),
            on_retry=lambda attempt, error, delay: logger.warning(
                "Retrying generate_try_on",
                attempt=attempt,
                delay=delay,
                error=str(error),
            ),
        )

        # 6. Optionally save to storage
        image_url = None
        storage_path = None
        if request.save_to_storage:
            saved = await save_generated_image(
                generated=result,
                user_id=user_id,
                image_type="try-on",
                db=db,
            )
            image_url = saved.get("image_url")
            storage_path = saved.get("storage_path")

        # 7. Increment usage
        await AISettingsService.increment_usage(
            user_id=user_id,
            operation_type="generation",
            db=db,
        )

        response_data = TryOnResponse(
            image_base64=result.image_base64,
            image_url=image_url,
            storage_path=storage_path,
            prompt=result.prompt,
            model=result.model,
            provider=result.provider,
        )

        return {
            "data": response_data.model_dump(),
            "message": "Try-on image generated successfully",
        }

    except RateLimitError:
        raise
    except AIServiceError:
        raise
    except Exception as e:
        logger.error("Generate try-on error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to generate try-on: {str(e)}")


# =============================================================================
# UTILITIES
# =============================================================================


@router.get(
    "/models",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def get_available_models(
    user_id: str = Depends(get_current_user_id),
):
    """
    Get available AI models by provider.

    Returns a list of recommended models for each provider type.
    """
    models = AvailableModelsResponse(
        gemini={
            "chat": [
                "gemini-3-flash-preview",
                "gemini-3-pro-preview",
            ],
            "vision": [
                "gemini-3-flash-preview",
                "gemini-3-pro-preview",
            ],
            "image_generation": [
                "gemini-3-pro-image-preview",
                "imagen-4.0-generate-preview-06-06",
            ],
        },
        openai={
            "chat": [
                "gpt-4o",
                "gpt-4o-mini",
                "gpt-4-turbo",
                "gpt-3.5-turbo",
            ],
            "vision": [
                "gpt-4o",
                "gpt-4o-mini",
                "gpt-4-turbo",
            ],
            "image_generation": [
                "dall-e-3",
                "dall-e-2",
            ],
        },
        custom={
            "chat": ["Use model names from your proxy"],
            "vision": ["Use model names from your proxy"],
            "image_generation": ["Use model names from your proxy"],
        },
    )

    return {
        "data": models.model_dump(),
        "message": "OK",
    }
