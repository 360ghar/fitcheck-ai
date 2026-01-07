"""
Outfits API routes.
Handles outfit CRUD operations and AI outfit generation.
"""

import uuid
import logging
from typing import Optional, List
from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends, status, Query
from pydantic import BaseModel
from supabase import Client

from app.db.connection import get_db
from app.core.security import get_current_user_id
from app.models.outfit import (
    OutfitCreate, OutfitUpdate, OutfitResponse, OutfitListResponse,
    OutfitDetailResponse, OutfitItem, GenerationRequest, GenerationResponse,
    GenerationStatusResponse, OutfitCollectionCreate, OutfitCollectionUpdate,
    OutfitCollectionResponse, VALID_STYLES, VALID_SEASONS, GenerationStatus
)
from app.services.ai_service import AIService
from app.services.storage_service import StorageService

logger = logging.getLogger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST MODELS
# ============================================================================


class OutfitCreateRequest(BaseModel):
    """Request for creating an outfit."""
    name: str
    description: Optional[str] = None
    items: List[OutfitItem]
    style: Optional[str] = None
    season: Optional[str] = None
    occasion: Optional[str] = None
    tags: List[str] = []
    is_favorite: bool = False
    is_public: bool = False
    generate_ai_image: bool = False


# ============================================================================
# OUTFIT CRUD ENDPOINTS
# ============================================================================


@router.post("/", response_model=OutfitResponse, status_code=status.HTTP_201_CREATED)
async def create_outfit(
    request: OutfitCreateRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Create a new outfit from selected items.
    """
    try:
        # Verify all items exist and belong to user
        item_ids = [item.item_id for item in request.items]

        if not item_ids:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Outfit must contain at least one item"
            )

        # Verify items exist and belong to user
        items_check = db.table("items").select("id").eq("user_id", user_id).execute()

        user_item_ids = {item["id"] for item in items_check.data}

        for item_id in item_ids:
            if str(item_id) not in user_item_ids:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Item {item_id} not found or doesn't belong to you"
                )

        # Create outfit
        outfit_id = str(uuid.uuid4())

        outfit_data = {
            "id": outfit_id,
            "user_id": user_id,
            "name": request.name,
            "description": request.description,
            "style": request.style,
            "season": request.season,
            "occasion": request.occasion,
            "tags": request.tags,
            "is_favorite": request.is_favorite,
            "is_public": request.is_public,
            "times_worn": 0,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        result = db.table("outfits").insert(outfit_data).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create outfit"
            )

        # Create outfit-item relationships
        for i, item_ref in enumerate(request.items):
            outfit_item_data = {
                "outfit_id": outfit_id,
                "item_id": str(item_ref.item_id),
                "position": item_ref.position or _infer_position(item_ref.item_id, db),
                "notes": item_ref.notes,
                "sort_order": i
            }
            db.table("outfit_items").insert(outfit_item_data).execute()

        # Generate AI image if requested
        image_url = None
        if request.generate_ai_image:
            # Fetch item details for AI
            items_details = db.table("items").select("*").in_("id", item_ids).execute()
            generation = await AIService.generate_outfit_image(
                items=items_details.data,
                style=request.style or "casual"
            )
            image_url = generation.get("image_url")

            if image_url:
                # Create outfit image record
                outfit_image_data = {
                    "id": str(uuid.uuid4()),
                    "outfit_id": outfit_id,
                    "image_url": image_url,
                    "thumbnail_url": image_url,
                    "generation_type": "ai",
                    "is_primary": True,
                    "created_at": datetime.now().isoformat()
                }
                db.table("outfit_images").insert(outfit_image_data).execute()

        # Return complete outfit
        response_data = result.data[0]
        response_data["items"] = request.items
        response_data["image_url"] = image_url
        response_data["images"] = []

        return response_data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating outfit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the outfit"
        )


@router.get("/", response_model=OutfitListResponse)
async def list_outfits(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    style: Optional[str] = None,
    season: Optional[str] = None,
    is_favorite: Optional[bool] = None,
    search: Optional[str] = None,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    List outfits with filtering and pagination.
    """
    try:
        # Build query
        query = db.table("outfits").select("*, outfit_images(*)")

        # Apply filters
        query = query.eq("user_id", user_id)

        if style:
            if style not in VALID_STYLES:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid style. Must be one of: {', '.join(VALID_STYLES)}"
                )
            query = query.eq("style", style)

        if season:
            if season not in VALID_SEASONS:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid season. Must be one of: {', '.join(VALID_SEASONS)}"
                )
            query = query.eq("season", season)

        if is_favorite is not None:
            query = query.eq("is_favorite", is_favorite)

        if search:
            query = query.or_(f"name.ilike.%{search}%,description.ilike.%{search}%")

        # Get total count
        count_result = query.copy().select("id", count="exact").execute()
        total = count_result.count if hasattr(count_result, 'count') else len(count_result.data)

        # Apply pagination
        start = (page - 1) * page_size
        end = start + page_size - 1
        query = query.range(start, end).order("created_at", desc=True)

        result = query.execute()

        outfits = result.data if result.data else []
        total_pages = (total + page_size - 1) // page_size if total > 0 else 1

        # Add items to each outfit
        for outfit in outfits:
            outfit_items = db.table("outfit_items").select("*").eq("outfit_id", outfit["id"]).execute()
            outfit["items"] = outfit_items.data

        return OutfitListResponse(
            outfits=outfits,
            total=total,
            page=page,
            total_pages=total_pages,
            has_next=page < total_pages,
            has_prev=page > 1
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error listing outfits: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching outfits"
        )


@router.get("/{outfit_id}", response_model=OutfitDetailResponse)
async def get_outfit(
    outfit_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Get details of a specific outfit with full item details.
    """
    try:
        result = db.table("outfits").select(
            "*, outfit_images(*)"
        ).eq("id", outfit_id).eq("user_id", user_id).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Outfit not found"
            )

        outfit = result.data

        # Get outfit items with details
        outfit_items = db.table("outfit_items").select("*").eq("outfit_id", outfit_id).execute()

        # Get full item details
        item_ids = [oi["item_id"] for oi in outfit_items.data]
        items_details = []
        if item_ids:
            items_result = db.table("items").select("*, item_images(*)").in_("id", item_ids).execute()
            items_details = items_result.data

        outfit["items_details"] = items_details
        outfit["items"] = outfit_items.data

        return outfit

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting outfit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Outfit not found"
        )


@router.put("/{outfit_id}", response_model=OutfitResponse)
async def update_outfit(
    outfit_id: str,
    outfit: OutfitUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Update an outfit.

    Only include fields you want to update.
    """
    try:
        # Verify ownership
        existing = db.table("outfits").select("id").eq("id", outfit_id).eq("user_id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Outfit not found"
            )

        # Prepare update data
        update_data = outfit.model_dump(exclude_unset=True)
        update_data["updated_at"] = datetime.now().isoformat()

        # Update outfit
        result = db.table("outfits").update(update_data).eq("id", outfit_id).eq("user_id", user_id).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update outfit"
            )

        # Update items if provided
        if outfit.items is not None:
            # Delete existing outfit-item relationships
            db.table("outfit_items").delete().eq("outfit_id", outfit_id).execute()

            # Create new relationships
            for i, item_ref in enumerate(outfit.items):
                outfit_item_data = {
                    "outfit_id": outfit_id,
                    "item_id": str(item_ref.item_id),
                    "position": item_ref.position or _infer_position(str(item_ref.item_id), db),
                    "notes": item_ref.notes,
                    "sort_order": i
                }
                db.table("outfit_items").insert(outfit_item_data).execute()

        # Return updated outfit
        result = db.table("outfits").select("*, outfit_images(*)").eq("id", outfit_id).single().execute()

        outfit_items = db.table("outfit_items").select("*").eq("outfit_id", outfit_id).execute()
        result.data["items"] = outfit_items.data

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating outfit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the outfit"
        )


@router.delete("/{outfit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_outfit(
    outfit_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Delete an outfit.
    """
    try:
        # Verify ownership
        existing = db.table("outfits").select("id").eq("id", outfit_id).eq("user_id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Outfit not found"
            )

        # Delete outfit (RLS handles cascading deletes)
        db.table("outfits").delete().eq("id", outfit_id).eq("user_id", user_id).execute()

        return None

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting outfit: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while deleting the outfit"
        )


@router.post("/{outfit_id}/wear", response_model=OutfitResponse)
async def mark_outfit_worn(
    outfit_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Mark an outfit as worn (increments usage counter).

    Also increments usage for all items in the outfit.
    """
    try:
        # Get current outfit
        result = db.table("outfits").select("times_worn").eq("id", outfit_id).eq("user_id", user_id).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Outfit not found"
            )

        current_count = result.data.get("times_worn", 0)

        # Update outfit
        update_data = {
            "times_worn": current_count + 1,
            "last_worn": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        db.table("outfits").update(update_data).eq("id", outfit_id).execute()

        # Update all items in the outfit
        outfit_items = db.table("outfit_items").select("item_id").eq("outfit_id", outfit_id).execute()

        for item_ref in outfit_items.data:
            item_id = item_ref["item_id"]
            item_result = db.table("items").select("usage_times_worn").eq("id", item_id).single().execute()

            if item_result.data:
                item_count = item_result.data.get("usage_times_worn", 0)
                db.table("items").update({
                    "usage_times_worn": item_count + 1,
                    "usage_last_worn": datetime.now().isoformat()
                }).eq("id", item_id).execute()

        # Return updated outfit
        result = db.table("outfits").select("*, outfit_images(*)").eq("id", outfit_id).single().execute()
        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error marking outfit as worn: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the outfit"
        )


# ============================================================================
# AI GENERATION ENDPOINTS
# ============================================================================


@router.post("/{outfit_id}/generate", response_model=GenerationResponse)
async def generate_outfit_image(
    outfit_id: str,
    request: GenerationRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Start AI generation for an outfit visualization.

    Returns a generation_id for checking status.
    """
    try:
        # Verify ownership
        existing = db.table("outfits").select("id, name, style, season").eq("id", outfit_id).eq("user_id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Outfit not found"
            )

        outfit = existing.data

        # Get outfit items
        outfit_items = db.table("outfit_items").select("item_id").eq("outfit_id", outfit_id).execute()

        if not outfit_items.data:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Outfit has no items to generate"
            )

        item_ids = [oi["item_id"] for oi in outfit_items.data]

        # Fetch item details
        items_details = db.table("items").select("*").in_("id", item_ids).execute()

        # Generate AI image
        generation = await AIService.generate_outfit_image(
            items=items_details.data,
            prompt=request.prompt,
            style=request.style or outfit.get("style") or "casual",
            background=request.background,
            include_model=request.include_model,
            model_gender=request.model_gender
        )

        # Create generation record
        generation_id = generation.get("generation_id", str(uuid.uuid4()))

        # For MVP, return the generation response
        # In production, this would be a background task with status polling
        return GenerationResponse(
            generation_id=generation_id,
            outfit_id=outfit_id,
            status=GenerationStatus.PROCESSING,
            estimated_time=30,
            created_at=datetime.now()
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error generating outfit image: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while generating the outfit image"
        )


@router.get("/generation/{generation_id}", response_model=GenerationStatusResponse)
async def get_generation_status(
    generation_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Check the status of an outfit generation.
    """
    try:
        # Check generation status
        status = await AIService.get_generation_status(generation_id)

        return GenerationStatusResponse(
            generation_id=generation_id,
            outfit_id=status.get("outfit_id", ""),
            status=GenerationStatus(status.get("status", "pending")),
            progress=status.get("progress"),
            image_url=status.get("image_url"),
            error=status.get("error"),
            started_at=status.get("started_at"),
            completed_at=status.get("completed_at")
        )

    except Exception as e:
        logger.error(f"Error getting generation status: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching generation status"
        )


# ============================================================================
# OUTFIT COLLECTIONS ENDPOINTS
# ============================================================================


@router.post("/collections", response_model=OutfitCollectionResponse, status_code=status.HTTP_201_CREATED)
async def create_collection(
    request: OutfitCollectionCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Create a new outfit collection."""
    try:
        collection_id = str(uuid.uuid4())

        collection_data = {
            "id": collection_id,
            "user_id": user_id,
            "name": request.name,
            "description": request.description,
            "is_favorite": request.is_favorite,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        result = db.table("outfit_collections").insert(collection_data).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create collection"
            )

        # Add outfits to collection
        if request.outfit_ids:
            for outfit_id in request.outfit_ids:
                # Verify outfit ownership
                outfit_check = db.table("outfits").select("id").eq("id", str(outfit_id)).eq("user_id", user_id).single().execute()

                if outfit_check.data:
                    db.table("outfit_collection_items").insert({
                        "collection_id": collection_id,
                        "outfit_id": str(outfit_id)
                    }).execute()

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating collection: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the collection"
        )


@router.get("/collections", response_model=List[OutfitCollectionResponse])
async def list_collections(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """List all outfit collections."""
    try:
        result = db.table("outfit_collections").select("*").eq("user_id", user_id).order("created_at", desc=True).execute()

        collections = result.data if result.data else []

        # Add outfit count to each collection
        for collection in collections:
            count_result = db.table("outfit_collection_items").select("outfit_id", count="exact").eq("collection_id", collection["id"]).execute()
            collection["outfit_count"] = count_result.count if hasattr(count_result, 'count') else len(count_result.data)

        return collections

    except Exception as e:
        logger.error(f"Error listing collections: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching collections"
        )


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================


def _infer_position(item_id: str, db: Client) -> str:
    """Infer position of an item based on its category."""
    try:
        item = db.table("items").select("category").eq("id", item_id).single().execute()

        if item.data:
            category = item.data.get("category", "")

            position_map = {
                "tops": "top",
                "bottoms": "bottom",
                "shoes": "shoes",
                "accessories": "accessory",
                "outerwear": "outerwear",
                "swimwear": "top",
                "activewear": "top"
            }

            return position_map.get(category, "accessory")

        return "accessory"

    except Exception:
        return "accessory"
