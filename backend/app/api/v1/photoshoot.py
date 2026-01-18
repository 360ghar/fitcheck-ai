"""
API routes for AI Photoshoot Generator feature.

Provides endpoints for:
- Generating photoshoots for authenticated users
- Demo photoshoot for anonymous users (landing page trial)
- Usage statistics
- Available use cases
"""

import logging
import uuid
from typing import Any, Dict

from fastapi import APIRouter, Depends, Request, status
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import AIServiceError, FitCheckException, ValidationError
from app.core.ip_rate_limit import ip_rate_limited_operation
from app.models.photoshoot import (
    StartPhotoshootRequest,
    DemoPhotoshootRequest,
    PhotoshootResultResponse,
    DemoPhotoshootResponse,
    PhotoshootUsage,
    UseCasesResponse,
    PhotoshootUseCase,
    PhotoshootStatus,
)
from app.services.photoshoot_service import PhotoshootService

logger = logging.getLogger(__name__)

router = APIRouter()


# =============================================================================
# Public Endpoints
# =============================================================================


@router.get("/use-cases", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def get_use_cases():
    """
    Get all available photoshoot use cases.

    Returns list of use cases with names, descriptions, and example prompts.
    No authentication required.
    """
    use_cases = PhotoshootService.get_use_cases()
    return {
        "data": UseCasesResponse(use_cases=use_cases).model_dump(mode="json"),
        "message": "OK",
    }


@router.post("/demo", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def demo_photoshoot(
    request: Request,
    body: DemoPhotoshootRequest,
):
    """
    Generate a demo photoshoot for anonymous users.

    Rate limited to 1 demo per IP per day (generates 2 images).
    Used for landing page trial experience.
    Custom prompts are not allowed in demo mode.
    """
    # Validate no custom use case in demo
    if body.use_case == PhotoshootUseCase.CUSTOM:
        body.use_case = PhotoshootUseCase.AESTHETIC

    try:
        async with ip_rate_limited_operation(request, "photoshoot") as rate_check:
            # Generate prompts for 2 images
            prompts = await PhotoshootService.generate_prompts(
                use_case=body.use_case,
                num_prompts=2,
                reference_photo=body.photo,
            )

            # Generate images
            images = await PhotoshootService.generate_images(
                reference_photos=[body.photo],
                prompts=prompts,
            )

            session_id = f"demo_{uuid.uuid4().hex[:8]}"

            response = DemoPhotoshootResponse(
                session_id=session_id,
                status=PhotoshootStatus.COMPLETE,
                images=images,
                remaining_today=max(0, rate_check["remaining"] - 1),
                signup_cta="Sign up for 10 free images per day!",
            )

            return {"data": response.model_dump(mode="json"), "message": "OK"}
    except FitCheckException:
        raise
    except Exception as e:
        logger.exception(f"Demo photoshoot failed: {e}")
        raise AIServiceError(f"Failed to generate demo photoshoot: {str(e)}")


# =============================================================================
# Authenticated Endpoints
# =============================================================================


@router.post("/generate", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def generate_photoshoot(
    body: StartPhotoshootRequest,
    db: Client = Depends(get_db),
    user = Depends(get_current_user),
):
    """
    Generate a full photoshoot for authenticated users.

    - Upload 1-4 reference photos
    - Select a use case or provide custom prompt
    - Choose number of images (1-10, default 10)
    - Returns all generated images in a single response

    Daily limits:
    - Free: 10 images/day
    - Pro: 50 images/day
    """
    user_id = user["id"]

    # Validate custom prompt requirement
    if body.use_case == PhotoshootUseCase.CUSTOM and not body.custom_prompt:
        raise ValidationError("Custom prompt is required when use case is 'custom'")

    result = await PhotoshootService.generate_photoshoot(
        user_id=user_id,
        photos=body.photos,
        use_case=body.use_case,
        num_images=body.num_images,
        db=db,
        custom_prompt=body.custom_prompt,
    )

    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/usage", response_model=Dict[str, Any], status_code=status.HTTP_200_OK)
async def get_usage(
    db: Client = Depends(get_db),
    user = Depends(get_current_user),
):
    """
    Get the current user's photoshoot usage for today.

    Returns:
    - used_today: Images generated today
    - limit_today: Daily limit based on plan
    - remaining: Images remaining today
    - plan_type: Current subscription plan
    - resets_at: When the daily limit resets (midnight UTC)
    """
    user_id = user["id"]
    usage = await PhotoshootService.get_usage(user_id, db)
    return {"data": usage.model_dump(mode="json"), "message": "OK"}
