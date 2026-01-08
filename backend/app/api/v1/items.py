"""
Items API routes.

Implements wardrobe item CRUD + image upload.
AI item extraction is performed server-side via the AI provider service, while the backend
stores items/images and maintains embeddings for recommendations.
"""

import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    ItemNotFoundError,
    ImageNotFoundError,
    ValidationError,
    StorageServiceError,
    DatabaseError,
    UnsupportedMediaTypeError,
)
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.models.item import (
    ItemCreate,
    ItemListResponse,
    ItemResponse,
    ItemUpdate,
    VALID_CATEGORIES,
    VALID_CONDITIONS,
)
from app.services.ai_service import AIService
from app.services.storage_service import StorageService
from app.services.vector_service import get_vector_service
from app.utils.parallel import parallel_with_retry

logger = get_context_logger(__name__)

router = APIRouter()


class BatchDeleteItemsRequest(BaseModel):
    item_ids: List[str] = Field(default_factory=list, min_length=1)


class UpdateItemCategoriesRequest(BaseModel):
    category: Optional[str] = None
    sub_category: Optional[str] = None
    colors: Optional[List[str]] = None
    style: Optional[str] = None
    materials: Optional[List[str]] = None
    seasonal_tags: Optional[List[str]] = None
    occasion_tags: Optional[List[str]] = None


def _now() -> str:
    return datetime.utcnow().isoformat()

def _normalize_item_images(item: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize nested images field to the public API contract.

    Supabase returns related images under `item_images`; the frontend/docs use `images`.
    """
    if not isinstance(item, dict):
        return item
    images = item.pop("item_images", None)
    if images is None:
        images = item.get("images")
    item["images"] = images or []
    return item


# ============================================================================
# UPLOADS
# ============================================================================


@router.post("/upload", response_model=Dict[str, Any], status_code=status.HTTP_202_ACCEPTED)
async def upload_item_images(
    files: List[UploadFile] = File(...),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Upload one or more images to Supabase Storage for later item creation."""
    try:
        # Validate all files first
        for file in files:
            if not file.content_type or not file.content_type.startswith("image/"):
                raise UnsupportedMediaTypeError(allowed_types=["image/jpeg", "image/png", "image/webp"])

        # Define upload function for each file
        async def upload_single_file(file: UploadFile, index: int) -> Dict[str, Any]:
            file_bytes = await file.read()
            res = await StorageService.upload_item_image(
                db=db,
                user_id=user_id,
                filename=file.filename or "upload.jpg",
                file_data=file_bytes,
                is_primary=(index == 0),  # First file is primary
            )
            return {
                "image_url": res.get("image_url"),
                "thumbnail_url": res.get("thumbnail_url"),
                "storage_path": res.get("storage_path"),
                "filename": file.filename,
            }

        # Upload all files in parallel with retry
        logger.debug(
            "Uploading images in parallel",
            user_id=user_id,
            file_count=len(files),
        )

        results = await parallel_with_retry(
            files,
            upload_single_file,
            max_retries=3,
            initial_delay=1.0,
            backoff_factor=2.0,
            retryable_exceptions=(StorageServiceError, Exception),
        )

        # Collect successful uploads
        uploaded = [r.data for r in results if r.success]

        # Log any failures
        failed = [r for r in results if not r.success]
        if failed:
            for r in failed:
                logger.warning(
                    "Failed to upload file after retries",
                    index=r.index,
                    error=str(r.error),
                )

        logger.info(
            "Parallel upload completed",
            user_id=user_id,
            successful=len(uploaded),
            failed=len(failed),
            total=len(files),
        )

        return {
            "data": {
                "upload_id": str(uuid.uuid4()),
                "status": "completed" if not failed else "partial",
                "uploaded_count": len(uploaded),
                "failed_count": len(failed),
                "images": uploaded,
            },
            "message": "Uploaded",
        }

    except (UnsupportedMediaTypeError, StorageServiceError):
        raise
    except Exception as e:
        logger.error("Upload error", user_id=user_id, file_count=len(files), error=str(e))
        raise StorageServiceError("Failed to upload images")


# ============================================================================
# CRUD
# ============================================================================


@router.post("", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_item(
    item: ItemCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Create a new wardrobe item."""
    try:
        item_id = str(uuid.uuid4())
        now = _now()

        item_data = {
            "id": item_id,
            "user_id": user_id,
            "name": item.name,
            "category": item.category,
            "sub_category": item.sub_category,
            "brand": item.brand,
            "colors": item.colors,
            "style": item.style,
            "material": item.material,
            "materials": item.materials,
            "pattern": item.pattern,
            "seasonal_tags": item.seasonal_tags,
            "occasion_tags": item.occasion_tags,
            "size": item.size,
            "price": item.price,
            "purchase_date": item.purchase_date.date().isoformat() if item.purchase_date else None,
            "purchase_location": item.purchase_location,
            "tags": item.tags,
            "notes": item.notes,
            "condition": item.condition,
            "is_favorite": item.is_favorite,
            "usage_times_worn": 0,
            "usage_last_worn": None,
            "cost_per_wear": None,
            "created_at": now,
            "updated_at": now,
            "is_deleted": False,
        }

        inserted = db.table("items").insert(item_data).execute()
        row = (inserted.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create item", operation="insert")

        # Insert images in a single batch (URLs already uploaded)
        images: List[Dict[str, Any]] = []
        if item.images:
            image_rows = []
            for img in item.images:
                img_id = str(uuid.uuid4())
                img_row = {
                    "id": img_id,
                    "item_id": item_id,
                    "image_url": img.image_url,
                    "thumbnail_url": img.thumbnail_url,
                    "storage_path": getattr(img, "storage_path", None),
                    "is_primary": bool(img.is_primary),
                    "width": img.width,
                    "height": img.height,
                    "created_at": now,
                }
                image_rows.append(img_row)

            # Single batch insert for all images
            db.table("item_images").insert(image_rows).execute()
            images = image_rows

        # Generate embedding + upsert to Pinecone (best-effort)
        try:
            embedding = await AIService.generate_item_embedding({**item_data, "images": images})
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
                        "name": item.name,
                    },
                )
        except Exception as e:
            logger.warning("Embedding generation failed", item_id=item_id, error=str(e))

        # Return full item with images
        row["images"] = images
        return {"data": row, "message": "Created"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Create item error", user_id=user_id, item_name=item.name, error=str(e))
        raise DatabaseError("Failed to create item", operation="insert")


@router.get("", response_model=Dict[str, Any])
async def list_items(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None),
    color: Optional[str] = Query(None),
    condition: Optional[str] = Query(None),
    brand: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    is_favorite: Optional[bool] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Browse items with filtering and pagination."""
    try:
        query = db.table("items").select("*, item_images(*)").eq("user_id", user_id).eq("is_deleted", False)

        if category:
            categories = [c.strip().lower() for c in category.split(",") if c.strip()]
            invalid = [c for c in categories if c not in VALID_CATEGORIES]
            if invalid:
                raise ValidationError("Invalid category", details={"invalid_categories": invalid})
            if len(categories) == 1:
                query = query.eq("category", categories[0])
            else:
                query = query.in_("category", categories)

        if condition:
            if condition not in VALID_CONDITIONS:
                raise ValidationError("Invalid condition", details={"condition": condition, "valid_conditions": list(VALID_CONDITIONS)})
            query = query.eq("condition", condition)

        if is_favorite is not None:
            query = query.eq("is_favorite", is_favorite)

        if brand:
            query = query.ilike("brand", f"%{brand}%")

        if color:
            # JSONB array contains
            query = query.contains("colors", [color])

        if search:
            like = f"%{search}%"
            query = query.or_(f"name.ilike.{like},brand.ilike.{like}")

        # Count
        count_q = db.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_deleted", False)
        if category:
            categories = [c.strip().lower() for c in category.split(",") if c.strip()]
            if len(categories) == 1:
                count_q = count_q.eq("category", categories[0])
            else:
                count_q = count_q.in_("category", categories)
        if condition:
            count_q = count_q.eq("condition", condition)
        if is_favorite is not None:
            count_q = count_q.eq("is_favorite", is_favorite)
        if brand:
            count_q = count_q.ilike("brand", f"%{brand}%")
        if color:
            count_q = count_q.contains("colors", [color])
        if search:
            like = f"%{search}%"
            count_q = count_q.or_(f"name.ilike.{like},brand.ilike.{like}")
        count_res = count_q.execute()
        total = getattr(count_res, "count", len(count_res.data or []))

        start = (page - 1) * page_size
        end = start + page_size - 1

        res = query.order("created_at", desc=True).range(start, end).execute()
        items = [_normalize_item_images(i) for i in (res.data or [])]

        total_pages = max(1, (total + page_size - 1) // page_size)
        return {
            "data": {
                "items": items,
                "total": total,
                "page": page,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_prev": page > 1,
            },
            "message": "OK",
        }

    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("List items error", user_id=user_id, page=page, error=str(e))
        raise DatabaseError("Failed to fetch items", operation="select")


@router.get("/{item_id}", response_model=Dict[str, Any])
async def get_item(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        result = (
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not result.data:
            raise ItemNotFoundError(item_id=item_id_str)
        return {"data": _normalize_item_images(result.data), "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Get item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch item", operation="select")


@router.put("/{item_id}", response_model=Dict[str, Any])
async def update_item(
    item_id: UUID,
    update: ItemUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        if not update_dict:
            return await get_item(item_id=item_id, user_id=user_id, db=db)

        if "purchase_date" in update_dict and update_dict["purchase_date"] is not None:
            update_dict["purchase_date"] = update_dict["purchase_date"].date().isoformat()
        update_dict["updated_at"] = _now()

        result = db.table("items").update(update_dict).eq("id", item_id_str).eq("user_id", user_id).execute()
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")

        # Refresh item with images
        item = (
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        ).data

        # Update embedding (best-effort) if relevant fields changed
        if any(k in update_dict for k in ("name", "category", "colors", "brand", "tags", "sub_category", "material")):
            try:
                embedding = await AIService.generate_item_embedding(item)
                if embedding:
                    vector_service = get_vector_service()
                    await vector_service.upsert_item(
                        item_id=item_id_str,
                        embedding=embedding,
                        metadata={
                            "user_id": user_id,
                            "category": item.get("category"),
                            "colors": item.get("colors", []),
                            "brand": item.get("brand") or "",
                            "name": item.get("name"),
                        },
                    )
            except Exception as e:
                logger.warning("Embedding update failed", item_id=item_id_str, error=str(e))

        return {"data": _normalize_item_images(item or {}), "message": "Updated"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update item", operation="update")


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Delete an item (hard delete)."""
    try:
        item_id_str = str(item_id)
        existing = db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        # Best-effort delete embedding
        try:
            vector_service = get_vector_service()
            await vector_service.delete_item(item_id_str)
        except Exception:
            pass

        db.table("items").delete().eq("id", item_id_str).eq("user_id", user_id).execute()
        return None
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Delete item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete item", operation="delete")


# ============================================================================
# EXTRA ACTIONS
# ============================================================================


@router.post("/{item_id}/favorite", response_model=Dict[str, Any])
async def toggle_favorite(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = db.table("items").select("is_favorite").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)
        new_value = not bool(existing.data.get("is_favorite", False))
        result = db.table("items").update({"is_favorite": new_value, "updated_at": _now()}).eq("id", item_id_str).execute()
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")
        return {"data": {"id": item_id_str, "is_favorite": new_value}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Toggle favorite error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to toggle favorite", operation="update")


@router.post("/{item_id}/wear", response_model=Dict[str, Any])
async def mark_worn(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = (
            db.table("items")
            .select("usage_times_worn")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)
        current = int(existing.data.get("usage_times_worn", 0))
        update = {"usage_times_worn": current + 1, "usage_last_worn": _now(), "updated_at": _now()}
        db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute()
        return {"data": {"id": item_id_str, "usage_times_worn": current + 1}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Mark worn error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update wear count", operation="update")


# ============================================================================
# IMAGES
# ============================================================================


@router.post("/{item_id}/images", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def upload_item_image(
    item_id: UUID,
    file: UploadFile = File(...),
    is_primary: bool = Form(False),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Upload an additional image for an existing item."""
    try:
        item_id_str = str(item_id)
        item = db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError(allowed_types=["image/jpeg", "image/png", "image/webp"])

        file_bytes = await file.read()
        upload = await StorageService.upload_item_image(
            db=db,
            user_id=user_id,
            filename=file.filename or "item.jpg",
            file_data=file_bytes,
            is_primary=bool(is_primary),
        )

        now = _now()
        image_id = str(uuid.uuid4())
        img_row = {
            "id": image_id,
            "item_id": item_id_str,
            "image_url": upload.get("image_url"),
            "thumbnail_url": upload.get("thumbnail_url"),
            "storage_path": upload.get("storage_path"),
            "is_primary": bool(is_primary),
            "width": upload.get("width"),
            "height": upload.get("height"),
            "created_at": now,
        }

        if is_primary:
            db.table("item_images").update({"is_primary": False}).eq("item_id", item_id_str).execute()

        db.table("item_images").insert(img_row).execute()

        return {"data": img_row, "message": "Created"}
    except (ItemNotFoundError, ImageNotFoundError, ValidationError, UnsupportedMediaTypeError, StorageServiceError, DatabaseError):
        raise
    except ValueError as e:
        raise ValidationError(str(e), details={"field": "file"})
    except Exception as e:
        logger.error("Upload item image error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise StorageServiceError("Failed to upload item image")


@router.delete("/{item_id}/images/{image_id}", response_model=Dict[str, Any])
async def delete_item_image(
    item_id: UUID,
    image_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Delete an item image and best-effort remove it from storage."""
    try:
        item_id_str = str(item_id)
        image_id_str = str(image_id)
        img = (
            db.table("item_images")
            .select("id, storage_path")
            .eq("id", image_id_str)
            .eq("item_id", item_id_str)
            .single()
            .execute()
        )
        if not img.data:
            raise ImageNotFoundError(image_id=image_id_str)

        # Ensure the item belongs to the current user
        item = db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        storage_path = img.data.get("storage_path")
        if storage_path:
            try:
                await StorageService.delete_image(db=db, storage_path=storage_path)
            except Exception:
                pass

        db.table("item_images").delete().eq("id", image_id_str).eq("item_id", item_id_str).execute()
        return {"data": {"deleted": True}, "message": "OK"}
    except (ItemNotFoundError, ImageNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Delete item image error", item_id=str(item_id), image_id=str(image_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete item image", operation="delete")


# ============================================================================
# BULK + STATS + SEARCH
# ============================================================================


@router.post("/batch-delete", response_model=Dict[str, Any])
async def batch_delete_items(
    request: BatchDeleteItemsRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Batch delete items (and best-effort remove embeddings/images)."""
    item_ids = list(dict.fromkeys([i for i in request.item_ids if i]))
    if not item_ids:
        raise ValidationError("item_ids is required", details={"field": "item_ids"})

    try:
        # Fetch storage paths for cleanup
        imgs_res = (
            db.table("item_images")
            .select("id, item_id, storage_path")
            .in_("item_id", item_ids)
            .execute()
        )
        storage_paths = [row.get("storage_path") for row in (imgs_res.data or []) if row.get("storage_path")]
        if storage_paths:
            try:
                await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
            except Exception:
                pass

        # Best-effort delete embeddings
        try:
            vector_service = get_vector_service()
            await vector_service.batch_delete(item_ids)
        except Exception:
            pass

        # Delete items (FK cascade removes item_images)
        delete_res = db.table("items").delete().eq("user_id", user_id).in_("id", item_ids).execute()
        deleted_count = len(delete_res.data or [])

        return {"data": {"deleted_count": deleted_count}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Batch delete items error", user_id=user_id, item_count=len(item_ids), error=str(e))
        raise DatabaseError("Failed to batch delete items", operation="delete")


@router.get("/stats", response_model=Dict[str, Any])
async def get_item_stats(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Compute wardrobe item statistics for dashboard/analytics."""
    try:
        items = db.table("items").select("id,name,category,colors,condition,price,usage_times_worn").eq("user_id", user_id).execute().data or []

        total_items = len(items)
        items_by_category: Dict[str, int] = {}
        items_by_condition: Dict[str, int] = {}
        items_by_color: Dict[str, int] = {}
        total_value = 0.0

        for item in items:
            cat = (item.get("category") or "other").lower()
            items_by_category[cat] = items_by_category.get(cat, 0) + 1

            cond = (item.get("condition") or "clean").lower()
            items_by_condition[cond] = items_by_condition.get(cond, 0) + 1

            for c in item.get("colors") or []:
                ckey = str(c).lower()
                items_by_color[ckey] = items_by_color.get(ckey, 0) + 1

            if item.get("price") is not None:
                try:
                    total_value += float(item["price"])
                except Exception:
                    pass

        most_worn = sorted(items, key=lambda i: int(i.get("usage_times_worn") or 0), reverse=True)[:5]
        least_worn = sorted(items, key=lambda i: int(i.get("usage_times_worn") or 0))[:5]

        return {
            "data": {
                "total_items": total_items,
                "items_by_category": items_by_category,
                "items_by_color": items_by_color,
                "items_by_condition": items_by_condition,
                "total_value": round(total_value, 2),
                "most_worn_items": [
                    {"id": i["id"], "name": i.get("name"), "times_worn": int(i.get("usage_times_worn") or 0)}
                    for i in most_worn
                ],
                "least_worn_items": [
                    {"id": i["id"], "name": i.get("name"), "times_worn": int(i.get("usage_times_worn") or 0)}
                    for i in least_worn
                ],
            },
            "message": "OK",
        }
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Item stats error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch item stats", operation="select")


@router.get("/by-category/{category}", response_model=Dict[str, Any])
async def get_items_by_category(
    category: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    cat = category.lower().strip()
    if cat not in VALID_CATEGORIES:
        raise ValidationError("Invalid category", details={"category": cat, "valid_categories": list(VALID_CATEGORIES)})
    try:
        res = (
            db.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .eq("category", cat)
            .order("created_at", desc=True)
            .execute()
        )
        items = [_normalize_item_images(i) for i in (res.data or [])]
        return {"data": {"items": items}, "message": "OK"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Items by category error", user_id=user_id, category=cat, error=str(e))
        raise DatabaseError("Failed to fetch items", operation="select")


@router.get("/search", response_model=Dict[str, Any])
async def search_items(
    q: str = Query(..., min_length=1),
    limit: int = Query(10, ge=1, le=50),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Search items by name/brand (best-effort; Supabase full-text can be added later)."""
    try:
        like = f"%{q}%"
        res = (
            db.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .or_(f"name.ilike.{like},brand.ilike.{like},notes.ilike.{like}")
            .limit(limit)
            .execute()
        )
        items = [_normalize_item_images(i) for i in (res.data or [])]
        return {"data": {"items": items}, "message": "OK"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Search items error", user_id=user_id, query=q, error=str(e))
        raise DatabaseError("Failed to search items", operation="select")


# ============================================================================
# CATEGORIZATION (server-side metadata only; AI optional)
# ============================================================================


@router.post("/{item_id}/categorize", response_model=Dict[str, Any])
async def categorize_item(
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Run lightweight categorization and persist derived fields.

    Item extraction is server-side via the AI provider service. This endpoint focuses on
    deriving metadata (style/materials/seasonal_tags) that powers recommendations.
    """
    try:
        item_id_str = str(item_id)
        item = (
            db.table("items")
            .select("*")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        row = item.data
        tags = [str(t).lower() for t in (row.get("tags") or [])]
        colors = [str(c).lower() for c in (row.get("colors") or [])]
        category = (row.get("category") or "other").lower()
        sub_category = (row.get("sub_category") or "").lower()

        known_styles = {"casual", "formal", "business", "sporty", "bohemian", "streetwear", "vintage", "minimalist"}
        style = next((t for t in tags if t in known_styles), row.get("style"))

        seasonal_tags: List[str] = []
        if any(k in tags for k in ("winter", "coat", "sweater")) or category == "outerwear":
            seasonal_tags.append("winter")
        if any(k in tags for k in ("summer", "shorts", "tank")) or "short" in sub_category:
            seasonal_tags.append("summer")
        if not seasonal_tags and category in {"tops", "bottoms", "shoes", "accessories"}:
            seasonal_tags.append("all-season")

        materials = row.get("materials") or []
        if isinstance(materials, str):
            materials = [materials]
        if not materials and row.get("material"):
            materials = [row.get("material")]

        update = {
            "style": style,
            "seasonal_tags": seasonal_tags,
            "materials": materials,
            "updated_at": _now(),
        }
        db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute()

        return {
            "data": {
                "category": category,
                "sub_category": sub_category or None,
                "colors": colors,
                "style": style,
                "materials": materials,
                "seasonal_tags": seasonal_tags,
                "confidence": 0.7,
            },
            "message": "OK",
        }
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Categorize item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to categorize item", operation="update")


@router.put("/{item_id}/categories", response_model=Dict[str, Any])
async def update_item_categories(
    item_id: UUID,
    request: UpdateItemCategoriesRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Update item category-related fields (user override)."""
    try:
        item_id_str = str(item_id)
        existing = db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update = request.model_dump(exclude_unset=True)
        if "category" in update and update["category"] is not None:
            update["category"] = update["category"].lower()
        if "sub_category" in update and update["sub_category"] is not None:
            update["sub_category"] = update["sub_category"]

        update["updated_at"] = _now()
        res = db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")

        item = (
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        return {"data": _normalize_item_images(item.data or {}), "message": "Updated"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update item categories error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update item categories", operation="update")
