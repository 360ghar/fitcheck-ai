"""
Items API routes.
Handles wardrobe item CRUD operations, image upload, and AI item extraction.
"""

import uuid
import logging
from typing import Optional, List
from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends, status, UploadFile, File, Form, Query
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from supabase import Client

from app.db.connection import get_db
from app.core.security import get_current_user_id
from app.models.item import (
    ItemCreate, ItemUpdate, ItemResponse, ItemListResponse,
    ItemImage, ItemImageBase, ItemUploadResponse, ExtractedItem,
    VALID_CATEGORIES, VALID_CONDITIONS
)
from app.services.ai_service import AIService
from app.services.storage_service import StorageService
from app.services.vector_service import get_vector_service

logger = logging.getLogger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST MODELS
# ============================================================================


class ItemUploadRequest(BaseModel):
    """Request for uploading images for AI extraction."""
    process_with_ai: bool = True
    auto_save: bool = False  # If true, automatically save extracted items


class ManualItemCreate(BaseModel):
    """Request for manually creating an item."""
    name: str
    category: str
    sub_category: Optional[str] = None
    brand: Optional[str] = None
    colors: List[str] = []
    size: Optional[str] = None
    price: Optional[float] = None
    purchase_date: Optional[str] = None  # ISO date string
    purchase_location: Optional[str] = None
    tags: List[str] = []
    notes: Optional[str] = None
    condition: str = "clean"
    is_favorite: bool = False
    images: List[ItemImageBase] = []


# ============================================================================
# CRUD ENDPOINTS
# ============================================================================


@router.post("/", response_model=ItemResponse, status_code=status.HTTP_201_CREATED)
async def create_item(
    item: ManualItemCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Create a new item manually.

    All fields except name are optional. Images can be included as URLs.
    """
    try:
        # Generate item ID
        item_id = str(uuid.uuid4())

        # Prepare item data
        item_data = {
            "id": item_id,
            "user_id": user_id,
            "name": item.name,
            "category": item.category,
            "sub_category": item.sub_category,
            "brand": item.brand,
            "colors": item.colors,
            "size": item.size,
            "price": item.price,
            "purchase_date": item.purchase_date,
            "purchase_location": item.purchase_location,
            "tags": item.tags,
            "notes": item.notes,
            "condition": item.condition,
            "is_favorite": item.is_favorite,
            "usage_times_worn": 0,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        # Insert item
        result = db.table("items").insert(item_data).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create item"
            )

        # Handle images
        images = []
        for img in item.images:
            image_data = {
                "id": str(uuid.uuid4()),
                "item_id": item_id,
                "image_url": img.image_url,
                "thumbnail_url": img.thumbnail_url,
                "is_primary": img.is_primary,
                "width": img.width,
                "height": img.height,
                "created_at": datetime.now().isoformat()
            }
            db.table("item_images").insert(image_data).execute()
            images.append(image_data)

        # Generate embedding and upsert to Pinecone
        try:
            embedding = await AIService.generate_item_embedding(item_data)
            if embedding:
                vector_service = get_vector_service()
                await vector_service.upsert_item(
                    item_id=item_id,
                    embedding=embedding,
                    metadata={
                        "user_id": user_id,
                        "category": item.category,
                        "colors": item.colors,
                        "brand": item.brand or "",
                        "name": item.name
                    }
                )
        except Exception as e:
            logger.warning(f"Failed to generate embedding for item {item_id}: {str(e)}")

        # Return complete item
        response_data = result.data[0]
        response_data["images"] = images
        return response_data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating item: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the item"
        )


@router.post("/upload", response_model=ItemUploadResponse)
async def upload_for_extraction(
    file: UploadFile = File(...),
    process_with_ai: bool = Form(True),
    auto_save: bool = Form(False),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Upload an image for AI item extraction.

    Returns extracted items from the image. Optionally auto-saves them.
    """
    # Validate file
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )

    try:
        # Read image data
        image_data = await file.read()

        # Upload to storage
        upload_result = await StorageService.upload_item_image(
            db=db,
            user_id=user_id,
            filename=file.filename or "upload.jpg",
            file_data=image_data,
            is_primary=True
        )

        # Extract items with AI if requested
        extracted_items = []
        if process_with_ai:
            extraction_result = await AIService.extract_items(
                image_data=image_data,
                filename=file.filename or "upload.jpg"
            )

            for item_data in extraction_result.get("items", []):
                extracted_item = ExtractedItem(
                    id=str(uuid.uuid4()),
                    image_url=upload_result["image_url"],
                    category=item_data.get("category", "other"),
                    sub_category=item_data.get("sub_category"),
                    colors=item_data.get("colors", []),
                    confidence=item_data.get("confidence", 0.5),
                    bounding_box=item_data.get("bounding_box")
                )

                # Auto-save if requested
                if auto_save:
                    item_create = ManualItemCreate(
                        name=f"{item_data.get('sub_category', 'Item')} from upload",
                        category=item_data.get("category", "other"),
                        sub_category=item_data.get("sub_category"),
                        colors=item_data.get("colors", []),
                        condition="clean"
                    )

                    # Create item with the uploaded image
                    item_result = await create_item(
                        item=ManualItemCreate(
                            **item_create.model_dump(),
                            images=[ItemImageBase(
                                image_url=upload_result["image_url"],
                                thumbnail_url=upload_result["thumbnail_url"],
                                is_primary=True
                            )]
                        ),
                        user_id=user_id,
                        db=db
                    )
                    extracted_item.id = item_result.id

                extracted_items.append(extracted_item)

        return ItemUploadResponse(
            upload_id=str(uuid.uuid4()),
            status="completed",
            uploaded_count=len(extracted_items),
            extracted_items=extracted_items
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error uploading image: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while processing the upload"
        )


@router.get("/", response_model=ItemListResponse)
async def list_items(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category: Optional[str] = None,
    color: Optional[str] = None,
    condition: Optional[str] = None,
    search: Optional[str] = None,
    is_favorite: Optional[bool] = None,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    List items with filtering and pagination.

    Filters:
    - category: Filter by item category
    - color: Filter by color (items must have this color)
    - condition: Filter by condition
    - search: Search in name, brand, tags
    - is_favorite: Filter favorite items
    """
    try:
        # Build query
        query = db.table("items").select("*, item_images(*)")

        # Apply filters
        filters = {"user_id": f"eq.{user_id}"}

        if category:
            if category not in VALID_CATEGORIES:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid category. Must be one of: {', '.join(VALID_CATEGORIES)}"
                )
            filters["category"] = f"eq.{category}"

        if condition:
            if condition not in VALID_CONDITIONS:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"Invalid condition. Must be one of: {', '.join(VALID_CONDITIONS)}"
                )
            filters["condition"] = f"eq.{condition}"

        if is_favorite is not None:
            filters["is_favorite"] = f"eq.{is_favorite}"

        # Apply filters
        for key, value in filters.items():
            query = query.filter(key, value.split(".", 1)[1])

        # Color filter (requires jsonb contains query)
        if color:
            query = query.filter("colors", "cs", f'["{color}"]')

        # Search filter (requires text search)
        if search:
            query = query.or_(f"name.ilike.%{search}%,brand.ilike.%{search}%,tags.cs.{search}")

        # Get total count
        count_query = db.table("items").select("id", count="exact")
        for key, value in filters.items():
            count_query = count_query.filter(key, value.split(".", 1)[1])
        count_result = count_query.execute()
        total = count_result.count if hasattr(count_result, 'count') else len(count_result.data)

        # Apply pagination
        start = (page - 1) * page_size
        end = start + page_size - 1
        query = query.range(start, end).order("created_at", desc=True)

        result = query.execute()

        items = result.data if result.data else []
        total_pages = (total + page_size - 1) // page_size if total > 0 else 1

        return ItemListResponse(
            items=items,
            total=total,
            page=page,
            total_pages=total_pages,
            has_next=page < total_pages,
            has_prev=page > 1
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error listing items: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching items"
        )


@router.get("/{item_id}", response_model=ItemResponse)
async def get_item(
    item_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Get details of a specific item.
    """
    try:
        result = db.table("items").select(
            "*, item_images(*)"
        ).eq("id", item_id).eq("user_id", user_id).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting item: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )


@router.put("/{item_id}", response_model=ItemResponse)
async def update_item(
    item_id: str,
    item: ItemUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Update an item.

    Only include fields you want to update. All fields are optional.
    """
    try:
        # Verify ownership
        existing = db.table("items").select("id").eq("id", item_id).eq("user_id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        # Prepare update data (exclude None values)
        update_data = item.model_dump(exclude_unset=True)
        update_data["updated_at"] = datetime.now().isoformat()

        # Update item
        result = db.table("items").update(update_data).eq("id", item_id).eq("user_id", user_id).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update item"
            )

        # Update embedding if significant fields changed
        if any(key in update_data for key in ["name", "category", "colors", "brand", "tags"]):
            try:
                # Get full item data
                full_item = db.table("items").select("*").eq("id", item_id).single().execute()

                embedding = await AIService.generate_item_embedding(full_item.data)
                if embedding:
                    vector_service = get_vector_service()
                    await vector_service.upsert_item(
                        item_id=item_id,
                        embedding=embedding,
                        metadata={
                            "user_id": user_id,
                            "category": full_item.data.get("category"),
                            "colors": full_item.data.get("colors", []),
                            "brand": full_item.data.get("brand") or "",
                            "name": full_item.data.get("name")
                        }
                    )
            except Exception as e:
                logger.warning(f"Failed to update embedding: {str(e)}")

        # Get updated item with images
        result = db.table("items").select("*, item_images(*)").eq("id", item_id).single().execute()
        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating item: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the item"
        )


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Delete an item (soft delete by setting condition to 'donate' or hard delete).

    Use query parameter `?permanent=true` for hard delete.
    """
    try:
        # Verify ownership
        existing = db.table("items").select("id, condition").eq("id", item_id).eq("user_id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        # Delete embedding from Pinecone
        try:
            vector_service = get_vector_service()
            await vector_service.delete_item(item_id)
        except Exception as e:
            logger.warning(f"Failed to delete embedding: {str(e)}")

        # Delete item (Supabase RLS handles cascading deletes for images)
        db.table("items").delete().eq("id", item_id).eq("user_id", user_id).execute()

        return None

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error deleting item: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while deleting the item"
        )


# ============================================================================
# BATCH OPERATIONS
# ============================================================================


@router.post("/batch", response_model=List[ItemResponse])
async def create_items_batch(
    items: List[ManualItemCreate],
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Create multiple items at once.

    Maximum 50 items per batch.
    """
    if len(items) > 50:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Maximum 50 items per batch"
        )

    try:
        created_items = []
        vector_items = []

        for item in items:
            item_id = str(uuid.uuid4())

            item_data = {
                "id": item_id,
                "user_id": user_id,
                "name": item.name,
                "category": item.category,
                "sub_category": item.sub_category,
                "brand": item.brand,
                "colors": item.colors,
                "size": item.size,
                "price": item.price,
                "purchase_date": item.purchase_date,
                "purchase_location": item.purchase_location,
                "tags": item.tags,
                "notes": item.notes,
                "condition": item.condition,
                "is_favorite": item.is_favorite,
                "usage_times_worn": 0,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }

            # Insert images
            images = []
            for img in item.images:
                image_data = {
                    "id": str(uuid.uuid4()),
                    "item_id": item_id,
                    "image_url": img.image_url,
                    "thumbnail_url": img.thumbnail_url,
                    "is_primary": img.is_primary,
                    "width": img.width,
                    "height": img.height,
                    "created_at": datetime.now().isoformat()
                }
                db.table("item_images").insert(image_data).execute()
                images.append(image_data)

            item_data["images"] = images
            created_items.append(item_data)
            vector_items.append((item_data, item_id))

        # Batch insert items
        items_to_insert = [
            {k: v for k, v in item.items() if k != "images"}
            for item in created_items
        ]

        result = db.table("items").insert(items_to_insert).execute()

        # Batch generate embeddings
        vector_service = get_vector_service()
        for item_data, item_id in vector_items:
            try:
                embedding = await AIService.generate_item_embedding(item_data)
                if embedding:
                    await vector_service.upsert_item(
                        item_id=item_id,
                        embedding=embedding,
                        metadata={
                            "user_id": user_id,
                            "category": item_data.get("category"),
                            "colors": item_data.get("colors", []),
                            "brand": item_data.get("brand") or "",
                            "name": item_data.get("name")
                        }
                    )
            except Exception as e:
                logger.warning(f"Failed to generate embedding: {str(e)}")

        return created_items

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error in batch create: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating items"
        )


@router.post("/{item_id}/wear", response_model=ItemResponse)
async def mark_item_worn(
    item_id: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Mark an item as worn (increments usage counter).

    Call this when tracking outfit usage.
    """
    try:
        # Get current item
        result = db.table("items").select("usage_times_worn").eq("id", item_id).eq("user_id", user_id).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Item not found"
            )

        current_count = result.data.get("usage_times_worn", 0)

        # Update
        update_data = {
            "usage_times_worn": current_count + 1,
            "usage_last_worn": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        db.table("items").update(update_data).eq("id", item_id).execute()

        # Return updated item
        result = db.table("items").select("*, item_images(*)").eq("id", item_id).single().execute()
        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error marking item as worn: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the item"
        )


# ============================================================================
# STATS ENDPOINTS
# ============================================================================


@router.get("/stats/summary")
async def get_items_stats(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """
    Get statistics about user's items.
    """
    try:
        # Total items
        total_result = db.table("items").select("id", count="exact").eq("user_id", user_id).execute()
        total_items = total_result.count if hasattr(total_result, 'count') else len(total_result.data)

        # Items by category
        category_result = db.table("items").select("category").eq("user_id", user_id).execute()
        items_by_category = {}
        for item in category_result.data:
            cat = item.get("category", "other")
            items_by_category[cat] = items_by_category.get(cat, 0) + 1

        # Items by condition
        condition_result = db.table("items").select("condition").eq("user_id", user_id).execute()
        items_by_condition = {}
        for item in condition_result.data:
            cond = item.get("condition", "clean")
            items_by_condition[cond] = items_by_condition.get(cond, 0) + 1

        # Most/least worn items
        worn_result = db.table("items").select("name, usage_times_worn").eq("user_id", user_id).order("usage_times_worn", desc=True).limit(10).execute()

        # Calculate total cost
        price_result = db.table("items").select("price, usage_times_worn").eq("user_id", user_id).not_.is_("price").execute()

        total_cost = sum(item.get("price", 0) for item in price_result.data)
        total_wears = sum(item.get("usage_times_worn", 0) for item in price_result.data)
        avg_cost_per_wear = total_cost / total_wears if total_wears > 0 else 0

        return {
            "total_items": total_items,
            "items_by_category": items_by_category,
            "items_by_condition": items_by_condition,
            "most_worn_items": worn_result.data[:5],
            "total_cost": total_cost,
            "avg_cost_per_wear": avg_cost_per_wear
        }

    except Exception as e:
        logger.error(f"Error getting stats: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching statistics"
        )
