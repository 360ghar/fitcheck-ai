"""
Items API routes.

Implements wardrobe item CRUD + image upload.
AI item extraction is performed server-side via the AI provider service, while the backend
stores items/images and maintains embeddings for recommendations.
"""

import asyncio
import uuid
from app.utils.datetime_util import utc_today, utcnow_iso
from datetime import date
from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    AIServiceError,
    ItemNotFoundError,
    ImageNotFoundError,
    ValidationError,
    StorageServiceError,
    DatabaseError,
    UnsupportedMediaTypeError,
    RateLimitError,
)
from app.api.v1.deps import get_active_user_id
from app.core.uploads import MAX_UPLOAD_FILES, read_upload_capped
from app.db.connection import get_db
from app.models.subscription import OperationType
from app.models.item import (
    ItemCreate,
    ItemUpdate,
    VALID_CATEGORIES,
    VALID_CONDITIONS,
    normalize_tag_list,
)
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.storage_service import MAX_FILE_SIZE, StorageService
from app.services.vector_service import get_vector_service
from app.utils.db import execute_with_reconnect, safe_search_term
from app.utils.parallel import parallel_with_retry
from app.api.v1.images import materialize_parent_images

logger = get_context_logger(__name__)

router = APIRouter()


async def _release_embedding_reservation(
    user_id: str, db: Client, *, reserved_on: Optional[date] = None
) -> None:
    """Best-effort return of an embedding reservation after a failed attempt.

    Embedding quotas are reserved before generation; a failure or an empty
    result must not silently consume the daily budget, but a failed release
    must also not mask the operation's original outcome. ``reserved_on`` is
    the UTC calendar day the reservation was made: release_usage() decrements
    whatever day's counter is current (the RPCs in migration 024 key on
    ``CURRENT_DATE``, i.e. UTC on hosted Supabase), so a release after the
    counter rolled over must be skipped or it would remove a slot reserved on
    the new day. Compared in UTC: server-local ``date.today()`` would disagree
    with the DB for hours around midnight on non-UTC hosts.
    """
    if reserved_on is not None and reserved_on != utc_today():
        return
    try:
        await AISettingsService.release_usage(
            user_id=user_id,
            operation_type=OperationType.EMBEDDING,
            db=db,
        )
    except Exception as error:
        logger.warning(
            "Failed to release embedding reservation",
            user_id=user_id,
            error=str(error),
        )


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
    return utcnow_iso()

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Upload one or more images to Supabase Storage for later item creation."""
    # Outside the try: the catch-all below would turn this into a 500. Without
    # a count cap, N unbounded files are read concurrently and all held at once.
    if len(files) > MAX_UPLOAD_FILES:
        raise ValidationError(f"Maximum {MAX_UPLOAD_FILES} files per upload")

    try:
        # Validate all files first
        for file in files:
            if not file.content_type or not file.content_type.startswith("image/"):
                raise UnsupportedMediaTypeError(allowed_types=["image/jpeg", "image/png", "image/webp", "image/gif", "image/avif", "image/heic", "image/bmp", "image/tiff"])

        # Define upload function for each file
        async def upload_single_file(file: UploadFile, index: int) -> Dict[str, Any]:
            # parallel_with_retry re-invokes this on failure, but the upload
            # stream is not rewound between attempts. Without this seek, a
            # rejected oversized file is re-read from wherever the previous
            # attempt stopped, so the last retry sees a small tail, passes the
            # cap, and stores a truncated image.
            await file.seek(0)
            # Capped read: reject oversized bodies before buffering them, not
            # after (StorageService._validate_image checks the same cap, but
            # only once the whole file is already resident).
            file_bytes = await read_upload_capped(file, MAX_FILE_SIZE)
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
            # A rejected file (invalid image bytes, unsupported type) can
            # never succeed on retry - fail it once instead of burning 3
            # extra decode/upload cycles (observed 2026-08-03: "Uploaded
            # bytes are not a valid image" -> "All 4 attempts failed" per
            # file). Transient storage errors still retry.
            should_retry=lambda e: not isinstance(e, UnsupportedMediaTypeError),
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
    user_id: str = Depends(get_active_user_id),
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
            "source_image_url": item.source_image_url,
            "source_image_storage_path": item.source_image_storage_path,
            "created_at": now,
            "updated_at": now,
            "is_deleted": False,
        }

        inserted = await execute_with_reconnect(
            lambda d: d.table("items").insert(item_data).execute(),
            db,
            extra={"operation": "create_item.insert", "user_id": user_id},
            max_retries=1,
        )
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
            await execute_with_reconnect(
                lambda d: d.table("item_images").insert(image_rows).execute(),
                db,
                extra={"operation": "create_item.insert_images", "user_id": user_id},
                max_retries=1,
            )
            images = image_rows

        # Generate embedding + upsert to Pinecone (best-effort)
        reserved = False
        embedding_stored = False
        # The day the slot was reserved: a release after midnight must not
        # decrement the new day's counter.
        reserved_on = utc_today()
        try:
            reserved = await AISettingsService.reserve_usage(
                user_id=user_id,
                operation_type=OperationType.EMBEDDING,
                db=db,
            )
            if not reserved:
                logger.info(
                    "Embedding rate limit exceeded for item create, skipping vector upsert",
                    user_id=user_id,
                    item_id=item_id,
                )
            else:
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
                    embedding_stored = True
        except Exception as e:
            logger.warning("Embedding generation failed", item_id=item_id, error=str(e))
        finally:
            if reserved and not embedding_stored:
                await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)

        # Return full item with images
        row["images"] = images
        return {"data": row, "message": "Created"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Create item error", user_id=user_id, item_name=item.name, error=str(e))
        raise DatabaseError("Failed to create item", operation="insert")


def _empty_item_page(
    page: int,
    page_size: int,
    ignored_filters: Dict[str, Any],
) -> Dict[str, Any]:
    """A zero-result page for a filter whose every value was unrecognised.

    Same envelope as a real page so clients need no special case; the
    ``ignored_filters`` key is what distinguishes "nothing matched" from
    "the filter you sent was not understood".
    """
    return {
        "data": {
            "items": [],
            "total": 0,
            "page": page,
            "total_pages": 1,
            "has_next": False,
            "has_prev": page > 1,
            "ignored_filters": ignored_filters,
        },
        "message": "OK",
    }


@router.get("", response_model=Dict[str, Any])
async def list_items(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    category: Optional[str] = Query(None),
    color: Optional[str] = Query(None),
    occasion: Optional[str] = Query(None),
    condition: Optional[str] = Query(None),
    brand: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    is_favorite: Optional[bool] = Query(None),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Browse items with filtering and pagination."""
    try:
        occasion_filter: Optional[str] = None
        if occasion is not None:
            normalized_occasion = normalize_tag_list([occasion])
            occasion_filter = normalized_occasion[0] if normalized_occasion else None

        # Unknown filter values are dropped rather than 422'd — a browse filter
        # should not hard-fail the page for a stale or typo'd value. But when
        # EVERY supplied value is unknown, dropping the filter entirely would
        # run the query unfiltered and return the user's whole wardrobe under an
        # active filter chip. That is worse than an error: the wrong data looks
        # authoritative. Hold the filter's intent and return an empty page,
        # reporting what was ignored so a client can tell "no matches" from
        # "your filter was not understood".
        ignored_filters: Dict[str, Any] = {}

        if category:
            categories = [c.strip().lower() for c in category.split(",") if c.strip()]
            invalid = [c for c in categories if c not in VALID_CATEGORIES]
            if invalid:
                logger.warning(
                    "Ignoring unknown category filter values",
                    extra={"invalid_categories": invalid, "user_id": user_id},
                )
                ignored_filters["category"] = invalid
            valid_categories = [c for c in categories if c in VALID_CATEGORIES]
            if categories and not valid_categories:
                return _empty_item_page(page, page_size, ignored_filters)
            category = ",".join(valid_categories) if valid_categories else None
        if condition and condition not in VALID_CONDITIONS:
            logger.warning(
                "Ignoring unknown condition filter value",
                extra={"condition": condition, "user_id": user_id},
            )
            ignored_filters["condition"] = [condition]
            return _empty_item_page(page, page_size, ignored_filters)

        def _apply_filters(q):
            """Apply every optional filter to a base query builder."""
            if category:
                categories = [c.strip().lower() for c in category.split(",") if c.strip()]
                q = q.in_("category", categories) if len(categories) > 1 else q.eq("category", categories[0])
            if condition:
                q = q.eq("condition", condition)
            if is_favorite is not None:
                q = q.eq("is_favorite", is_favorite)
            if brand:
                q = q.ilike("brand", f"%{brand}%")
            if color:
                # JSONB array contains
                q = q.contains("colors", [color])
            if occasion_filter:
                q = q.contains("occasion_tags", [occasion_filter])
            if search:
                like = f"%{safe_search_term(search)}%"
                q = q.or_(f"name.ilike.{like},brand.ilike.{like}")
            return q

        async def _list_and_count(d):
            """Run count + page queries concurrently against client `d` (rebuilt on retry)."""
            # The two reads are independent; running them in parallel halves
            # the page-load latency (count is often the slower of the two on
            # large wardrobes).
            start = (page - 1) * page_size
            end = start + page_size - 1
            count_res, list_res = await asyncio.gather(
                asyncio.to_thread(
                    _apply_filters(
                        d.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_deleted", False)
                    ).execute
                ),
                asyncio.to_thread(
                    _apply_filters(
                        d.table("items").select("*, item_images(*)").eq("user_id", user_id).eq("is_deleted", False)
                    )
                    .order("created_at", desc=True)
                    .range(start, end)
                    .execute
                ),
            )
            total = getattr(count_res, "count", len(count_res.data or []))
            return total, list_res

        # A dead pooled HTTP/2 connection (gateway restart/idle) previously
        # turned this endpoint into a permanent 500 until a process restart.
        # execute_with_reconnect rebuilds the client and retries; two retries
        # with a short backoff ride out a 1-2 s gateway blip (2026-08-04:
        # single-retry bursts still 500ed while the rebuilt client hit the
        # same dead gateway).
        total, res = await execute_with_reconnect(
            _list_and_count,
            db,
            extra={"operation": "list_items", "user_id": user_id},
            max_retries=2,
        )
        items = [_normalize_item_images(i) for i in (res.data or [])]
        # Private buckets: materialize fresh short-lived presigned URLs from
        # storage_path at read time (the DB stores keys, not URLs).
        items = await materialize_parent_images(items)

        total_pages = max(1, (total + page_size - 1) // page_size)
        return {
            "data": {
                "items": items,
                "total": total,
                "page": page,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_prev": page > 1,
                # Partially-invalid filter: the valid values were applied and
                # these were dropped. Always present so clients can read it
                # unconditionally.
                "ignored_filters": ignored_filters,
            },
            "message": "OK",
        }

    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("List items error", user_id=user_id, page=page, error=str(e))
        raise DatabaseError("Failed to fetch items", operation="select")


@router.get("/{item_id:uuid}", response_model=Dict[str, Any])
async def get_item(
    item_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        result = await execute_with_reconnect(
            lambda d: (
                d.table("items")
                .select("*, item_images(*)")
                .eq("id", item_id_str)
                .eq("user_id", user_id)
                .single()
                .execute()
            ),
            db,
            extra={"operation": "get_item", "user_id": user_id, "item_id": item_id_str},
            max_retries=2,
        )
        if not result.data:
            raise ItemNotFoundError(item_id=item_id_str)
        item = _normalize_item_images(result.data)
        # Private buckets: materialize fresh presigned URLs at read time.
        item = (await materialize_parent_images([item]))[0]
        return {"data": item, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Get item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch item", operation="select")


@router.put("/{item_id}", response_model=Dict[str, Any])
async def update_item(
    item_id: UUID,
    update: ItemUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        if not update_dict:
            return await get_item(item_id=item_id, user_id=user_id, db=db)

        if "purchase_date" in update_dict and update_dict["purchase_date"] is not None:
            update_dict["purchase_date"] = update_dict["purchase_date"].date().isoformat()
        update_dict["updated_at"] = _now()

        result = await asyncio.to_thread(db.table("items").update(update_dict).eq("id", item_id_str).eq("user_id", user_id).execute)
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")

        # Refresh item with images
        item_result = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not item_result or not item_result.data:
            raise ItemNotFoundError(item_id_str)
        item = item_result.data

        # Update embedding (best-effort) if relevant fields changed
        if any(k in update_dict for k in ("name", "category", "colors", "brand", "tags", "sub_category", "material")):
            reserved = False
            embedding_stored = False
            # The day the slot was reserved: a release after midnight must
            # not decrement the new day's counter.
            reserved_on = utc_today()
            try:
                reserved = await AISettingsService.reserve_usage(
                    user_id=user_id,
                    operation_type=OperationType.EMBEDDING,
                    db=db,
                )
                if not reserved:
                    logger.info(
                        "Embedding rate limit exceeded for item update, skipping vector upsert",
                        user_id=user_id,
                        item_id=item_id_str,
                    )
                else:
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
                        embedding_stored = True
            except Exception as e:
                logger.warning("Embedding update failed", item_id=item_id_str, error=str(e))
            finally:
                if reserved and not embedding_stored:
                    await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)

        # Private buckets: materialize fresh presigned URLs at read time so the
        # update response never carries a stale/expired URL.
        item = _normalize_item_images(item or {})
        item = (await materialize_parent_images([item]))[0]
        return {"data": item, "message": "Updated"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update item error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update item", operation="update")


@router.delete("/{item_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_item(
    item_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete an item (hard delete)."""
    try:
        item_id_str = str(item_id)
        existing = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        # Collect the owned storage paths (the source photo + every item image,
        # plus their _thumb siblings) BEFORE the row is gone: the source path
        # lives on the items row itself. Deleting the row without this leaks
        # the objects forever (measured: 296 orphans / 192MB in the bucket).
        storage_paths: List[str] = []
        try:
            owned = await StorageService.resolve_owned_storage_paths(
                db, user_id, item_ids=[item_id_str]
            )
            storage_paths = owned["storage_paths"]
        except Exception as e:
            logger.warning(
                "Failed to resolve storage paths for item delete",
                item_id=item_id_str,
                error=str(e),
            )

        # Best-effort delete embedding
        try:
            vector_service = get_vector_service()
            await vector_service.delete_item(item_id_str)
        except Exception as e:
            logger.warning("Failed to delete item embedding", item_id=item_id_str, error=str(e))

        await asyncio.to_thread(db.table("items").delete().eq("id", item_id_str).eq("user_id", user_id).execute)

        if storage_paths:
            try:
                await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
            except Exception as e:
                logger.warning(
                    "Failed to delete item images from storage",
                    item_id=item_id_str,
                    object_count=len(storage_paths),
                    error=str(e),
                )
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = await asyncio.to_thread(db.table("items").select("is_favorite").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)
        new_value = not bool(existing.data.get("is_favorite", False))
        result = await asyncio.to_thread(db.table("items").update({"is_favorite": new_value, "updated_at": _now()}).eq("id", item_id_str).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        existing = await asyncio.to_thread(
            db.table("items")
            .select("usage_times_worn")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)
        current = int(existing.data.get("usage_times_worn", 0))
        update = {"usage_times_worn": current + 1, "usage_last_worn": _now(), "updated_at": _now()}
        await asyncio.to_thread(db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Upload an additional image for an existing item."""
    try:
        item_id_str = str(item_id)
        item = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError(allowed_types=["image/jpeg", "image/png", "image/webp"])

        file_bytes = await read_upload_capped(file, MAX_FILE_SIZE)
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

        # Insert new image first, then clear is_primary on other images
        # This minimizes the race window where no primary exists
        insert_result = await asyncio.to_thread(db.table("item_images").insert(img_row).execute)
        new_image_id = insert_result.data[0]["id"] if insert_result.data else None

        if is_primary and new_image_id:
            # Clear is_primary on all OTHER images for this item
            await asyncio.to_thread(db.table("item_images").update({"is_primary": False}).eq("item_id", item_id_str).neq("id", new_image_id).execute)

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete an item image and best-effort remove it from storage."""
    try:
        item_id_str = str(item_id)
        image_id_str = str(image_id)
        img = await asyncio.to_thread(
            db.table("item_images")
            .select("id, storage_path")
            .eq("id", image_id_str)
            .eq("item_id", item_id_str)
            .single()
            .execute
        )
        if not img.data:
            raise ImageNotFoundError(image_id=image_id_str)

        # Ensure the item belongs to the current user
        item = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        storage_path = img.data.get("storage_path")
        if storage_path:
            try:
                await StorageService.delete_image(db=db, storage_path=storage_path)
            except Exception as e:
                logger.warning("Failed to delete image from storage", storage_path=storage_path, error=str(e))

        await asyncio.to_thread(db.table("item_images").delete().eq("id", image_id_str).eq("item_id", item_id_str).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Batch delete items (and best-effort remove embeddings/images)."""
    item_ids = list(dict.fromkeys([i for i in request.item_ids if i]))
    if not item_ids:
        raise ValidationError("item_ids is required", details={"field": "item_ids"})

    try:
        # Resolve the parent rows under the caller's ownership before reading
        # child image paths. The service-role client bypasses RLS, so the
        # child query cannot be authorized by item_id alone.
        owned = await StorageService.resolve_owned_storage_paths(
            db, user_id, item_ids=item_ids
        )
        owned_item_ids = owned["item_ids"]
        storage_paths = owned["storage_paths"]

        async def _delete_storage() -> None:
            if storage_paths:
                try:
                    await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
                except Exception as e:
                    # object_count, not image_count: storage_paths includes the
                    # derived _thumb siblings, so this is ~2x the image count.
                    logger.warning("Failed to delete images from storage", object_count=len(storage_paths), error=str(e))

        async def _delete_embeddings() -> None:
            # The request may contain IDs from another user. The database
            # ownership query above is the authorization boundary; never pass
            # the unfiltered request list to the external vector index.
            try:
                vector_service = get_vector_service()
                await vector_service.batch_delete(owned_item_ids)
            except Exception as e:
                logger.warning("Failed to delete item embeddings", item_count=len(item_ids), error=str(e))

        # Storage and vector cleanup are independent; both are best-effort.
        await asyncio.gather(_delete_storage(), _delete_embeddings())

        # Delete items (FK cascade removes item_images)
        delete_res = await asyncio.to_thread(db.table("items").delete().eq("user_id", user_id).in_("id", item_ids).execute)
        deleted_count = len(delete_res.data or [])

        return {"data": {"deleted_count": deleted_count}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Batch delete items error", user_id=user_id, item_count=len(item_ids), error=str(e))
        raise DatabaseError("Failed to batch delete items", operation="delete")


@router.get("/stats", response_model=Dict[str, Any])
async def get_item_stats(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Compute wardrobe item statistics for dashboard/analytics."""
    try:
        # Count, the aggregation payload, and the most/least-worn extremes are
        # independent reads; run them concurrently. The extremes are pushed
        # into SQL (ORDER BY + LIMIT) instead of sorting up to 1000 rows in
        # Python, and the aggregation query drops the columns only that Python
        # sort used.
        count_res, agg_res, most_res, least_res = await asyncio.gather(
            asyncio.to_thread(
                db.table("items").select("id", count="exact").eq("user_id", user_id).execute
            ),
            asyncio.to_thread(
                db.table("items")
                .select("category,colors,condition,price")
                .eq("user_id", user_id)
                .limit(1000)  # Limit to prevent fetching thousands of items
                .execute
            ),
            asyncio.to_thread(
                db.table("items")
                .select("id,name,usage_times_worn")
                .eq("user_id", user_id)
                # nullslast: a NULL wear count must rank as "never worn"
                # (Postgres puts NULLs first under DESC by default).
                .order("usage_times_worn", desc=True, nullsfirst=False)
                .limit(5)
                .execute
            ),
            asyncio.to_thread(
                db.table("items")
                .select("id,name,usage_times_worn")
                .eq("user_id", user_id)
                .order("usage_times_worn", nullsfirst=False)
                .limit(5)
                .execute
            ),
        )

        count = getattr(count_res, "count", None)
        items = agg_res.data or []
        total_items = count if count is not None else len(items)
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
                except Exception as e:
                    logger.debug("Could not parse item price", item_id=item.get("id"), price=item.get("price"), error=str(e))

        most_worn = most_res.data or []
        least_worn = least_res.data or []

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    cat = category.lower().strip()
    if cat not in VALID_CATEGORIES:
        raise ValidationError("Invalid category", details={"category": cat, "valid_categories": list(VALID_CATEGORIES)})
    try:
        res = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .eq("category", cat)
            .order("created_at", desc=True)
            .execute
        )
        items = [_normalize_item_images(i) for i in (res.data or [])]
        # Private buckets: materialize fresh presigned URLs at read time.
        items = await materialize_parent_images(items)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Search items by name/brand (best-effort; Supabase full-text can be added later)."""
    try:
        like = f"%{safe_search_term(q)}%"
        res = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .or_(f"name.ilike.{like},brand.ilike.{like},notes.ilike.{like}")
            .limit(limit)
            .execute
        )
        items = [_normalize_item_images(i) for i in (res.data or [])]
        # Private buckets: materialize fresh presigned URLs at read time.
        items = await materialize_parent_images(items)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Run lightweight categorization and persist derived fields.

    Item extraction is server-side via the AI provider service. This endpoint focuses on
    deriving metadata (style/materials/seasonal_tags) that powers recommendations.
    """
    try:
        item_id_str = str(item_id)
        item = await asyncio.to_thread(
            db.table("items")
            .select("*")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
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
        await asyncio.to_thread(db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute)

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Update item category-related fields (user override)."""
    try:
        item_id_str = str(item_id)
        existing = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).single().execute)
        if not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update = request.model_dump(exclude_unset=True)
        if "category" in update and update["category"] is not None:
            update["category"] = update["category"].lower()
        if "sub_category" in update and update["sub_category"] is not None:
            update["sub_category"] = update["sub_category"]
        if "occasion_tags" in update and update["occasion_tags"] is not None:
            update["occasion_tags"] = normalize_tag_list(update["occasion_tags"])

        update["updated_at"] = _now()
        res = await asyncio.to_thread(db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute)
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")

        item = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        # Private buckets: materialize fresh presigned URLs at read time.
        item = _normalize_item_images(item.data or {})
        item = (await materialize_parent_images([item]))[0]
        return {"data": item, "message": "Updated"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update item categories error", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update item categories", operation="update")


# ============================================================================
# DUPLICATE DETECTION
# ============================================================================


class DuplicateCheckRequest(BaseModel):
    """Request body for duplicate check."""
    name: str = Field(..., min_length=1)
    category: str
    colors: List[str] = Field(default_factory=list)
    brand: Optional[str] = None
    sub_category: Optional[str] = None
    material: Optional[str] = None
    tags: List[str] = Field(default_factory=list)


class DuplicateItem(BaseModel):
    """A potential duplicate item."""
    id: str
    name: str
    category: str
    sub_category: Optional[str] = None
    colors: List[str] = Field(default_factory=list)
    brand: Optional[str] = None
    similarity_score: float = Field(..., ge=0, le=1)
    image_url: Optional[str] = None
    reasons: List[str] = Field(default_factory=list)


class DuplicateCheckResponse(BaseModel):
    """Response for duplicate check."""
    has_duplicates: bool
    duplicates: List[DuplicateItem] = Field(default_factory=list)
    threshold: float = Field(default=0.75)


@router.post("/check-duplicates", response_model=Dict[str, Any])
async def check_duplicates(
    request: DuplicateCheckRequest,
    threshold: float = Query(0.75, ge=0.5, le=0.99, description="Similarity threshold (0.5-0.99)"),
    limit: int = Query(5, ge=1, le=20, description="Max duplicates to return"),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Check for potential duplicate items in the user's wardrobe.

    Uses AI embeddings to find items with similar attributes.
    Called before creating a new item to warn about potential duplicates.

    Args:
        request: Item attributes to check for duplicates
        threshold: Minimum similarity score to consider a duplicate (default 0.75)
        limit: Maximum number of duplicates to return (default 5)

    Returns:
        has_duplicates: Whether any duplicates were found
        duplicates: List of potential duplicate items with similarity scores
        threshold: The threshold used for matching
    """
    try:
        # Empty wardrobe: no duplicates possible. Skip embedding + Pinecone
        # (observed 6–10s per check during first-time batch saves).
        wardrobe_count_result = await asyncio.to_thread(
            db.table("items")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .limit(1)
            .execute
        )
        wardrobe_count = getattr(wardrobe_count_result, "count", None)
        if wardrobe_count is None:
            wardrobe_count = len(wardrobe_count_result.data or [])
        if wardrobe_count == 0:
            return {
                "data": {
                    "has_duplicates": False,
                    "duplicates": [],
                    "threshold": threshold,
                },
                "message": "No duplicates found",
            }

        # If embedding quota is exhausted, fall back to text-based matching
        reserved = await AISettingsService.reserve_usage(
            user_id=user_id,
            operation_type=OperationType.EMBEDDING,
            db=db,
        )
        # The day the slot was reserved: a release after midnight must not
        # decrement the new day's counter.
        reserved_on = utc_today()
        if not reserved:
            logger.info(
                "Embedding rate limit exceeded for duplicate check, using fallback",
                user_id=user_id,
            )
            return await _fallback_duplicate_check(db, user_id, request, threshold, limit)

        # Build text from item attributes for embedding
        item_data = {
            "name": request.name,
            "category": request.category,
            "sub_category": request.sub_category,
            "colors": request.colors,
            "brand": request.brand,
            "material": request.material,
            "tags": request.tags,
        }

        # Generate embedding for the new item
        try:
            embedding = await AIService.generate_item_embedding(item_data)
        except Exception as e:
            logger.warning(
                "Failed to generate embedding for duplicate check, falling back to text search",
                error=str(e),
                user_id=user_id,
            )
            # Fallback: simple text-based duplicate check
            await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)
            return await _fallback_duplicate_check(db, user_id, request, threshold, limit)

        # Search for similar items using vector service
        vector_service = get_vector_service()
        similar_items = await vector_service.find_similar(
            embedding=embedding,
            user_id=user_id,
            category=None,  # Search across all categories
            top_k=limit * 2,  # Get more than needed for filtering
            min_score=threshold,
        )

        if not similar_items:
            return {
                "data": {
                    "has_duplicates": False,
                    "duplicates": [],
                    "threshold": threshold,
                },
                "message": "No duplicates found"
            }

        # Fetch full item details for matches (read-only; rebuild + retry once
        # on a dead pooled connection - the 2026-08-03 /items/check-duplicates
        # 500s happened during the same gateway-restart window as the other
        # ConnectionTerminated bursts).
        item_ids = [item["item_id"] for item in similar_items]
        items_result = await execute_with_reconnect(
            lambda d: d.table("items")
            .select("*, item_images(*)")
            .in_("id", item_ids)
            .eq("user_id", user_id)
            .execute(),
            db,
            extra={"operation": "check_duplicates_items", "user_id": user_id},
        )

        normalized_items = [
            _normalize_item_images(item) for item in (items_result.data or [])
        ]
        # Private buckets: materialize fresh presigned URLs at read time.
        await materialize_parent_images(normalized_items)
        items_by_id = {item["id"]: item for item in normalized_items}

        # Build duplicate response with details
        duplicates = []
        for match in similar_items[:limit]:
            item_id = match["item_id"]
            if item_id not in items_by_id:
                continue

            item = items_by_id[item_id]
            score = match["score"]

            # Get primary image URL
            images = item.get("images", [])
            primary_image = next(
                (img for img in images if img.get("is_primary")),
                images[0] if images else None
            )
            image_url = primary_image.get("image_url") if primary_image else None

            # Generate reasons for similarity
            reasons = _generate_duplicate_reasons(request, item, score)

            duplicates.append({
                "id": item_id,
                "name": item.get("name", ""),
                "category": item.get("category", ""),
                "sub_category": item.get("sub_category"),
                "colors": item.get("colors", []),
                "brand": item.get("brand"),
                "similarity_score": round(score, 3),
                "image_url": image_url,
                "reasons": reasons,
            })

        has_duplicates = len(duplicates) > 0

        logger.info(
            "Duplicate check completed",
            user_id=user_id,
            item_name=request.name,
            duplicates_found=len(duplicates),
            threshold=threshold,
        )

        return {
            "data": {
                "has_duplicates": has_duplicates,
                "duplicates": duplicates,
                "threshold": threshold,
            },
            "message": f"Found {len(duplicates)} potential duplicate(s)" if has_duplicates else "No duplicates found"
        }

    except (ValidationError, DatabaseError, AIServiceError):
        raise
    except Exception as e:
        logger.error(
            "Duplicate check error",
            user_id=user_id,
            item_name=request.name,
            error=str(e),
        )
        raise DatabaseError("Failed to check for duplicates", operation="select")


@router.get("/{item_id}/similar", response_model=Dict[str, Any])
async def find_similar_items(
    item_id: UUID,
    limit: int = Query(5, ge=1, le=20),
    min_score: float = Query(0.6, ge=0.0, le=1.0),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Find items similar to the specified item.

    Uses AI embeddings for similarity matching. Useful for:
    - Finding duplicates in existing wardrobe
    - Discovering items that could be paired together
    - Identifying items to consolidate or declutter

    Args:
        item_id: The item to find similar items for
        limit: Maximum number of similar items to return
        min_score: Minimum similarity score (0-1)

    Returns:
        List of similar items with similarity scores
    """
    try:
        item_id_str = str(item_id)

        # Fetch the source item
        item_result = await asyncio.to_thread(
            db.table("items")
            .select("*")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )

        if not item_result.data:
            raise ItemNotFoundError(item_id=item_id_str)

        source_item = item_result.data

        # Check rate limit before generating the source embedding
        reserved = await AISettingsService.reserve_usage(
            user_id=user_id,
            operation_type=OperationType.EMBEDDING,
            db=db,
        )
        # The day the slot was reserved: a release after midnight must not
        # decrement the new day's counter.
        reserved_on = utc_today()
        if not reserved:
            raise RateLimitError(
                "Daily embedding limit exceeded. Requested 1 embedding."
            )

        # Generate embedding for source item
        try:
            embedding = await AIService.generate_item_embedding(source_item)
        except Exception as e:
            logger.warning(
                "Failed to generate embedding for similar items search",
                error=str(e),
                item_id=item_id_str,
            )
            await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)
            return {
                "data": {"items": [], "source_item_id": item_id_str},
                "message": "Similarity search unavailable - AI service error"
            }

        # Search for similar items
        vector_service = get_vector_service()
        similar_items = await vector_service.find_similar(
            embedding=embedding,
            user_id=user_id,
            exclude_item_ids=[item_id_str],  # Don't include the source item
            top_k=limit,
            min_score=min_score,
        )

        if not similar_items:
            return {
                "data": {"items": [], "source_item_id": item_id_str},
                "message": "No similar items found"
            }

        # Fetch full item details
        similar_ids = [item["item_id"] for item in similar_items]
        items_result = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .in_("id", similar_ids)
            .eq("user_id", user_id)
            .execute
        )

        normalized_items = [
            _normalize_item_images(item) for item in (items_result.data or [])
        ]
        # Private buckets: materialize fresh presigned URLs at read time.
        await materialize_parent_images(normalized_items)
        items_by_id = {item["id"]: item for item in normalized_items}

        # Build response with scores
        response_items = []
        for match in similar_items:
            item_id = match["item_id"]
            if item_id not in items_by_id:
                continue

            item = items_by_id[item_id]
            item["similarity_score"] = round(match["score"], 3)
            response_items.append(item)

        return {
            "data": {
                "items": response_items,
                "source_item_id": item_id_str,
            },
            "message": f"Found {len(response_items)} similar item(s)"
        }

    except (ItemNotFoundError, ValidationError, DatabaseError, RateLimitError, AIServiceError):
        raise
    except Exception as e:
        logger.error(
            "Find similar items error",
            item_id=str(item_id),
            user_id=user_id,
            error=str(e),
        )
        raise DatabaseError("Failed to find similar items", operation="select")


async def _fallback_duplicate_check(
    db: Client,
    user_id: str,
    request: DuplicateCheckRequest,
    threshold: float,
    limit: int,
) -> Dict[str, Any]:
    """Fallback duplicate check using text-based matching when embeddings unavailable."""
    try:
        # Search by name similarity and same category
        name_pattern = f"%{request.name}%"

        items_result = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .eq("category", request.category.lower())
            .ilike("name", name_pattern)
            .limit(limit)
            .execute
        )

        rows = [_normalize_item_images(item) for item in (items_result.data or [])]
        # Private buckets: materialize fresh presigned URLs at read time.
        await materialize_parent_images(rows)

        duplicates = []
        for item in rows:
            # Calculate a basic similarity score
            score = _calculate_text_similarity(request, item)

            if score >= threshold:
                images = item.get("images", [])
                primary_image = next(
                    (img for img in images if img.get("is_primary")),
                    images[0] if images else None
                )

                duplicates.append({
                    "id": item["id"],
                    "name": item.get("name", ""),
                    "category": item.get("category", ""),
                    "sub_category": item.get("sub_category"),
                    "colors": item.get("colors", []),
                    "brand": item.get("brand"),
                    "similarity_score": round(score, 3),
                    "image_url": primary_image.get("image_url") if primary_image else None,
                    "reasons": _generate_duplicate_reasons(request, item, score),
                })

        # Sort by score
        duplicates.sort(key=lambda x: x["similarity_score"], reverse=True)

        return {
            "data": {
                "has_duplicates": len(duplicates) > 0,
                "duplicates": duplicates[:limit],
                "threshold": threshold,
            },
            "message": "Fallback text-based duplicate check"
        }
    except Exception as e:
        logger.error("Fallback duplicate check error", error=str(e))
        return {
            "data": {
                "has_duplicates": False,
                "duplicates": [],
                "threshold": threshold,
            },
            "message": "Duplicate check unavailable"
        }


def _calculate_text_similarity(request: DuplicateCheckRequest, item: Dict[str, Any]) -> float:
    """Calculate a basic text similarity score."""
    score = 0.0

    # Name similarity (40%)
    req_name = request.name.lower()
    item_name = (item.get("name") or "").lower()
    if req_name == item_name:
        score += 0.4
    elif req_name in item_name or item_name in req_name:
        score += 0.3

    # Category match (20%)
    if request.category.lower() == (item.get("category") or "").lower():
        score += 0.2

    # Sub-category match (10%)
    if request.sub_category and request.sub_category.lower() == (item.get("sub_category") or "").lower():
        score += 0.1

    # Color overlap (15%)
    req_colors = set(c.lower() for c in request.colors)
    item_colors = set(c.lower() for c in (item.get("colors") or []))
    if req_colors and item_colors:
        overlap = len(req_colors & item_colors) / max(len(req_colors), len(item_colors))
        score += 0.15 * overlap

    # Brand match (15%)
    if request.brand and request.brand.lower() == (item.get("brand") or "").lower():
        score += 0.15

    return min(score, 1.0)


def _generate_duplicate_reasons(request: DuplicateCheckRequest, item: Dict[str, Any], score: float) -> List[str]:
    """Generate human-readable reasons for why items are similar."""
    reasons = []

    req_name = request.name.lower()
    item_name = (item.get("name") or "").lower()

    if req_name == item_name:
        reasons.append("Exact name match")
    elif req_name in item_name or item_name in req_name:
        reasons.append("Similar name")

    if request.category.lower() == (item.get("category") or "").lower():
        reasons.append(f"Same category ({request.category})")

    if request.sub_category and request.sub_category.lower() == (item.get("sub_category") or "").lower():
        reasons.append(f"Same sub-category ({request.sub_category})")

    req_colors = set(c.lower() for c in request.colors)
    item_colors = set(c.lower() for c in (item.get("colors") or []))
    common_colors = req_colors & item_colors
    if common_colors:
        reasons.append(f"Matching colors: {', '.join(common_colors)}")

    if request.brand and request.brand.lower() == (item.get("brand") or "").lower():
        reasons.append(f"Same brand ({request.brand})")

    if score >= 0.9:
        reasons.insert(0, "Very high similarity")
    elif score >= 0.8:
        reasons.insert(0, "High similarity")

    return reasons
