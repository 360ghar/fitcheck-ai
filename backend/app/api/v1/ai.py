"""
AI Operations API routes.

Provides endpoints for AI-powered item extraction and image generation.
All AI processing is done server-side using configurable providers.
"""

from typing import Any, Dict, List, Optional

import base64
import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError, FitCheckException, RateLimitError
from app.core.rate_limit import rate_limited_operation
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
from app.services.ai_service import EmbeddingService
from app.services.vector_service import get_vector_service

logger = get_context_logger(__name__)

router = APIRouter()


async def _fetch_user_avatar_base64(user_id: str, db: Client) -> Optional[str]:
    """Best-effort avatar fetch for profile-aware extraction and generation."""
    try:
        user_result = db.table("users").select("avatar_url").eq("id", user_id).single().execute()
        if not user_result or not user_result.data:
            return None

        avatar_url = user_result.data.get("avatar_url")
        if not avatar_url:
            return None

        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(avatar_url)
            response.raise_for_status()
            return base64.b64encode(response.content).decode("utf-8")
    except Exception as e:
        logger.warning(
            "Failed to fetch user avatar for extraction",
            user_id=user_id,
            error=str(e),
        )
        return None


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
        async with rate_limited_operation(user_id, "extraction", db):
            # Get extraction agent
            agent = await get_item_extraction_agent(user_id=user_id, db=db)
            user_avatar_base64 = await _fetch_user_avatar_base64(user_id=user_id, db=db)

            # Extract items with retry
            result = await with_retry(
                lambda: agent.extract_multiple_items(
                    image_base64=request.image,
                    user_profile_image_base64=user_avatar_base64,
                ),
                max_retries=3,
                initial_delay=2.0,
                backoff_factor=2.0,
                retryable_exceptions=(AIServiceError,),
                on_retry=lambda attempt, error, delay: logger.warning(
                    "Retrying extract_multiple_items",
                    attempt=attempt,
                    delay=delay,
                    error=str(error),
                ),
            )

        return {
            "data": ExtractItemsResponse(**result).model_dump(),
            "message": "Items extracted successfully",
        }

    except FitCheckException:
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
        async with rate_limited_operation(user_id, "extraction", db):
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
                retryable_exceptions=(AIServiceError,),
                on_retry=lambda attempt, error, delay: logger.warning(
                    "Retrying extract_single_item",
                    attempt=attempt,
                    delay=delay,
                    error=str(error),
                ),
            )

        return {
            "data": ExtractSingleItemResponse(**result).model_dump(),
            "message": "Item extracted successfully",
        }

    except FitCheckException:
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
    If include_user_face is True and user has an avatar, generates with the user's face.
    """
    try:
        async with rate_limited_operation(user_id, "generation", db):
            # Fetch user avatar and body profile if include_user_face is enabled
            user_avatar_base64 = None
            body_profile = None

            if request.include_user_face:
                # Fetch user avatar_url and body_profile_id
                user_result = (
                    db.table("users")
                    .select("avatar_url, body_profile_id")
                    .eq("id", user_id)
                    .single()
                    .execute()
                )

                if user_result.data and user_result.data.get("avatar_url"):
                    avatar_url = user_result.data["avatar_url"]
                    try:
                        async with httpx.AsyncClient(timeout=30.0) as client:
                            resp = await client.get(avatar_url)
                            resp.raise_for_status()
                            user_avatar_base64 = base64.b64encode(resp.content).decode("utf-8")
                    except Exception as e:
                        logger.warning(
                            "Failed to fetch user avatar, falling back to generic model",
                            user_id=user_id,
                            error=str(e),
                        )

                # Fetch body profile if available and requested
                if request.use_body_profile:
                    body_profile_id = (
                        user_result.data.get("body_profile_id") if user_result.data else None
                    )
                    if body_profile_id:
                        bp_result = (
                            db.table("body_profiles")
                            .select("height_cm, weight_kg, body_shape, skin_tone")
                            .eq("id", body_profile_id)
                            .single()
                            .execute()
                        )
                        if bp_result.data:
                            body_profile = bp_result.data

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
                    user_avatar_base64=user_avatar_base64,
                    body_profile=body_profile,
                ),
                max_retries=3,
                initial_delay=2.0,
                backoff_factor=2.0,
                retryable_exceptions=(AIServiceError,),
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

    except FitCheckException:
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
        async with rate_limited_operation(user_id, "generation", db):
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
                retryable_exceptions=(AIServiceError,),
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

    except FitCheckException:
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
    try:
        # 1. Fetch user's avatar_url from database
        user_result = db.table("users").select("avatar_url").eq("id", user_id).single().execute()
        if not user_result or not user_result.data:
            from fastapi import HTTPException
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "User not found",
                    "code": "USER_NOT_FOUND",
                    "message": "User profile not found",
                }
            )
        user_data = user_result.data

        if not user_data.get("avatar_url"):
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

        async with rate_limited_operation(user_id, "generation", db):
            # 2. Fetch avatar image and convert to base64
            async with httpx.AsyncClient(timeout=30.0) as client:
                response = await client.get(avatar_url)
                response.raise_for_status()
                avatar_base64 = base64.b64encode(response.content).decode("utf-8")

            # 3. Get generation agent
            agent = await get_image_generation_agent(user_id=user_id, db=db)

            # 4. Generate try-on image with retry
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
                retryable_exceptions=(AIServiceError,),
                on_retry=lambda attempt, error, delay: logger.warning(
                    "Retrying generate_try_on",
                    attempt=attempt,
                    delay=delay,
                    error=str(error),
                ),
            )

            # 5. Optionally save to storage
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

    except FitCheckException:
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


# =============================================================================
# EMBEDDINGS
# =============================================================================


class EmbeddingRequest(BaseModel):
    """Request to generate a single embedding."""
    text: str = Field(..., min_length=1, max_length=10000, description="Text to generate embedding for")
    model: Optional[str] = None


class EmbeddingResult(BaseModel):
    """Result of embedding generation."""
    embedding: List[float]
    model: str
    dimensions: int
    provider: str


class BatchEmbeddingRequest(BaseModel):
    """Request to generate batch embeddings."""
    texts: List[str] = Field(..., min_length=1, max_length=100, description="List of texts to generate embeddings for")
    model: Optional[str] = None


class BatchEmbeddingResult(BaseModel):
    """Result of batch embedding generation."""
    embeddings: List[List[float]]
    model: str
    dimensions: int
    provider: str
    count: int


class SimilaritySearchRequest(BaseModel):
    """Request to search for similar items."""
    text: Optional[str] = None
    embedding: Optional[List[float]] = None
    category: Optional[str] = None
    colors: Optional[List[str]] = None
    top_k: int = 10
    min_score: float = 0.5


class SimilarItem(BaseModel):
    """A similar item from vector search."""
    item_id: str
    score: float
    metadata: Dict[str, Any]


class SimilaritySearchResult(BaseModel):
    """Result of similarity search."""
    items: List[SimilarItem]
    query_embedding_dimensions: int


class TestEmbeddingRequest(BaseModel):
    """Request to test embedding model."""
    provider: str
    model: str


class TestEmbeddingResult(BaseModel):
    """Result of embedding model test."""
    success: bool
    message: str
    model: Optional[str] = None


@router.post(
    "/embeddings",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def generate_embedding(
    request: EmbeddingRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Generate an embedding for a single text.

    Used for similarity matching and semantic search.
    """
    try:
        async with rate_limited_operation(user_id, "embedding", db):
            # Generate embedding
            embedding = await EmbeddingService.generate_embedding(request.text)

        return {
            "data": EmbeddingResult(
                embedding=embedding,
                model=settings.AI_GEMINI_EMBEDDING_MODEL,
                dimensions=len(embedding),
                provider="gemini",
            ).model_dump(),
            "message": "Embedding generated successfully",
        }

    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Generate embedding error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to generate embedding: {str(e)}")


@router.post(
    "/embeddings/batch",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def generate_batch_embeddings(
    request: BatchEmbeddingRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Generate embeddings for multiple texts in batch.

    More efficient than calling single embedding endpoint multiple times.
    """
    try:
        if not request.texts:
            return {
                "data": BatchEmbeddingResult(
                    embeddings=[],
                    model=settings.AI_GEMINI_EMBEDDING_MODEL,
                    dimensions=0,
                    provider="gemini",
                    count=0,
                ).model_dump(),
                "message": "No texts provided",
            }

        async with rate_limited_operation(user_id, "embedding", db, count=len(request.texts)):
            # Generate batch embeddings
            embeddings = await EmbeddingService.batch_generate_embeddings(request.texts)

        return {
            "data": BatchEmbeddingResult(
                embeddings=embeddings,
                model=settings.AI_GEMINI_EMBEDDING_MODEL,
                dimensions=len(embeddings[0]) if embeddings else 0,
                provider="gemini",
                count=len(embeddings),
            ).model_dump(),
            "message": "Batch embeddings generated successfully",
        }

    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Generate batch embeddings error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to generate batch embeddings: {str(e)}")


@router.post(
    "/embeddings/search",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def search_similar_items(
    request: SimilaritySearchRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Search for similar items using text or embedding.

    Uses vector similarity to find matching items in the user's wardrobe.
    """
    try:
        # Need either text or embedding
        if not request.text and not request.embedding:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Either 'text' or 'embedding' must be provided",
            )

        # Generate embedding from text if not provided
        if request.embedding:
            query_embedding = request.embedding
        else:
            # Rate limit only applies when generating embedding from text
            async with rate_limited_operation(user_id, "embedding", db):
                query_embedding = await EmbeddingService.generate_embedding(request.text)

        # Get vector service and search
        vector_service = get_vector_service()
        results = await vector_service.find_similar(
            embedding=query_embedding,
            user_id=user_id,
            category=request.category,
            colors=request.colors,
            top_k=request.top_k,
            min_score=request.min_score,
        )

        # Convert results to response format
        items = [
            SimilarItem(
                item_id=r.get("id", ""),
                score=r.get("score", 0.0),
                metadata=r.get("metadata", {}),
            )
            for r in results
        ]

        return {
            "data": SimilaritySearchResult(
                items=items,
                query_embedding_dimensions=len(query_embedding),
            ).model_dump(),
            "message": f"Found {len(items)} similar items",
        }

    except HTTPException:
        raise
    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Search similar items error", user_id=user_id, error=str(e))
        raise AIServiceError(f"Failed to search similar items: {str(e)}")


@router.post(
    "/embeddings/test",
    response_model=Dict[str, Any],
    status_code=status.HTTP_200_OK,
)
async def test_embedding_model(
    request: TestEmbeddingRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """
    Test an embedding model configuration.

    Generates a test embedding to verify the model is working correctly.
    """
    try:
        async with rate_limited_operation(user_id, "embedding", db):
            # Generate test embedding
            test_embedding = await EmbeddingService.generate_embedding("test embedding")

        return {
            "data": TestEmbeddingResult(
                success=True,
                message=f"Embedding model working ({len(test_embedding)} dimensions)",
                model=settings.AI_GEMINI_EMBEDDING_MODEL,
            ).model_dump(),
            "message": "Embedding model test successful",
        }

    except RateLimitError:
        raise
    except AIServiceError as e:
        return {
            "data": TestEmbeddingResult(
                success=False,
                message=str(e),
                model=request.model,
            ).model_dump(),
            "message": "Embedding model test failed",
        }
    except Exception as e:
        logger.error("Test embedding model error", user_id=user_id, error=str(e))
        return {
            "data": TestEmbeddingResult(
                success=False,
                message=str(e),
                model=request.model,
            ).model_dump(),
            "message": "Embedding model test failed",
        }
