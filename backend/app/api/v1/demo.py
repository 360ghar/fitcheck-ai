"""
Demo API routes.

Public endpoints for landing page demo features.
No authentication required - uses IP-based rate limiting.
"""

import asyncio
from typing import Any, Dict

from fastapi import APIRouter, Depends, Request, status
from supabase import Client

from app.core.exceptions import AIServiceError, FitCheckException
from app.core.ip_rate_limit import get_client_ip, ip_rate_limited_operation
from app.core.logging_config import get_context_logger
from app.db.connection import get_db
from app.utils.retry import is_retryable_error, with_retry
from app.models.demo import (
    DemoExtractItemsRequest,
    DemoExtractItemsResponse,
    DemoDetectedItem,
    DemoTryOnRequest,
    DemoTryOnResponse,
)
from app.agents.item_extraction_agent import ItemExtractionAgent
from app.agents.image_generation_agent import ImageGenerationAgent
from app.services.ai_provider_service import get_ai_service

logger = get_context_logger(__name__)

router = APIRouter()


# Hard ceiling for ONE demo extraction attempt (seconds).
#
# The provider layer already retries internally (one in-transport retry per
# leg plus the Gemini -> Agnes fallback in chat_with_vision), so this budget
# exists only to stop a single public demo request from holding a worker +
# proxy connection for minutes while providers hang. Observed 2026-08-07
# 17:37: POST /api/v1/demo/extract-items took 169 028 ms and ended in a 400
# (edge rejection of an already-churning request) while Gemini 503'd and the
# fallback leg crawled against its 120 s read timeout. A healthy demo
# extraction finishes in 10-40 s, so 90 s is generous; on expiry the caller
# gets a fast retryable 503 instead of a multi-minute hang.
DEMO_EXTRACT_TIMEOUT_SECONDS = 90.0


# =============================================================================
# ITEM EXTRACTION DEMO
# =============================================================================


@router.post(
    "/extract-items",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def demo_extract_items(
    request_body: DemoExtractItemsRequest,
    request: Request,
    db: Client = Depends(get_db),
):
    """
    Extract clothing items from an image (demo mode).

    Public endpoint - no authentication required.
    Rate limited to 3 requests per day per IP.
    """
    ip = get_client_ip(request)

    try:
        async with ip_rate_limited_operation(request, "extraction"):
            logger.info("Demo extraction started", ip=ip)

            # Get system AI service (no user-specific config)
            ai_service = await get_ai_service()
            try:
                agent = ItemExtractionAgent(ai_service)

                # Single attempt under a hard time budget. The provider layer
                # ALREADY retries internally (one in-transport retry plus the
                # Gemini -> Agnes fallback in chat_with_vision), so the old
                # outer with_retry here doubled the worst-case latency of the
                # whole chain (observed 2026-08-07 17:37: 169 s for a single
                # failed demo extraction). asyncio.wait_for caps the total;
                # on expiry the finally still closes the pooled client.
                result = await asyncio.wait_for(
                    agent.extract_multiple_items(image_base64=request_body.image),
                    timeout=DEMO_EXTRACT_TIMEOUT_SECONDS,
                )
            except asyncio.TimeoutError:
                logger.warning(
                    "Demo extraction timed out",
                    timeout_seconds=DEMO_EXTRACT_TIMEOUT_SECONDS,
                    ip=ip,
                )
                raise AIServiceError(
                    "Demo item extraction timed out. Please try again in a few moments.",
                    retryable=True,
                ) from None
            finally:
                # Close the pooled HTTP client even when the call fails, so a
                # burst of failed demos cannot leak connections until GC.
                await ai_service.close()

        # Convert to demo response format (remove internal fields like temp_id)
        demo_items = [
            DemoDetectedItem(
                category=item.get("category", "other"),
                sub_category=item.get("sub_category"),
                colors=item.get("colors", []),
                material=item.get("material"),
                pattern=item.get("pattern"),
                confidence=item.get("confidence", 0.0),
                detailed_description=item.get("detailed_description"),
            )
            for item in result.get("items", [])
        ]

        response = DemoExtractItemsResponse(
            items=demo_items,
            overall_confidence=result.get("overall_confidence", 0.0),
            image_description=result.get("image_description", ""),
            item_count=len(demo_items),
        )

        logger.info(
            "Demo extraction completed",
            ip=ip,
            item_count=len(demo_items),
        )

        return {
            "data": response.model_dump(),
            "message": "Items extracted successfully",
        }

    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Demo extraction error", error=str(e), ip=ip)
        raise AIServiceError(f"Failed to extract items: {str(e)}")


# =============================================================================
# VIRTUAL TRY-ON DEMO
# =============================================================================


@router.post(
    "/try-on",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def demo_try_on(
    request_body: DemoTryOnRequest,
    request: Request,
    db: Client = Depends(get_db),
):
    """
    Generate a virtual try-on visualization (demo mode).

    Public endpoint - no authentication required.
    Rate limited to 2 requests per day per IP.
    User provides both person photo and clothing photo.
    """
    ip = get_client_ip(request)

    try:
        async with ip_rate_limited_operation(request, "try_on"):
            logger.info("Demo try-on started", ip=ip)

            # Get system AI service
            ai_service = await get_ai_service()
            try:
                agent = ImageGenerationAgent(ai_service)

                # Generate try-on using both provided images
                result = await with_retry(
                    lambda: agent.generate_try_on(
                        user_avatar_base64=request_body.person_image,
                        clothing_image_base64=request_body.clothing_image,
                        clothing_description=request_body.clothing_description,
                        style=request_body.style,
                        background="studio white",
                        pose="standing front",
                        lighting="professional studio lighting",
                    ),
                    max_retries=1,
                    initial_delay=2.0,
                    backoff_factor=2.0,
                    retryable_exceptions=(AIServiceError,),
                    should_retry=is_retryable_error,
                    on_retry=lambda attempt, error, delay: logger.warning(
                        "Retrying demo try-on",
                        attempt=attempt,
                        delay=delay,
                        error=str(error),
                        ip=ip,
                    ),
                )
            finally:
                # Close the pooled HTTP client even when the call fails, so a
                # burst of failed demos cannot leak connections until GC.
                await ai_service.close()

        response = DemoTryOnResponse(
            image_base64=result.image_base64,
            prompt=result.prompt,
        )

        logger.info("Demo try-on completed", ip=ip)

        return {
            "data": response.model_dump(),
            "message": "Try-on image generated successfully",
        }

    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Demo try-on error", error=str(e), ip=ip)
        raise AIServiceError(f"Failed to generate try-on: {str(e)}")
