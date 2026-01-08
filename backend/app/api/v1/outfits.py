"""
Outfits API routes.

Implements outfit CRUD and a lightweight generation-tracking flow.

AI image generation is performed server-side via the AI provider service. The backend
stores generated images in Supabase Storage and records metadata for retrieval.
"""

import uuid
from datetime import datetime, timezone
from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    OutfitNotFoundError,
    ItemNotFoundError,
    ValidationError,
    DatabaseError,
    CollectionNotFoundError,
    ImageNotFoundError,
    UnsupportedMediaTypeError,
    NotFoundError,
    SharedOutfitNotFoundError,
)
from app.core.security import get_current_user_id
from app.core.config import settings
from app.db.connection import get_db
from app.models.outfit import (
    GenerationRequest,
    GenerationStatus,
    OutfitCreate,
    OutfitUpdate,
    OutfitCollectionCreate,
    OutfitCollectionUpdate,
)
from app.services.storage_service import StorageService

logger = get_context_logger(__name__)

router = APIRouter()


class BatchDeleteOutfitsRequest(BaseModel):
    outfit_ids: List[str] = Field(default_factory=list, min_length=1)


class AddItemToOutfitRequest(BaseModel):
    item_id: str
    position: Optional[str] = None  # reserved for future visual canvas placement


class ShareOutfitRequest(BaseModel):
    visibility: str = Field(default="public", description="public|friends|private")
    expires_at: Optional[str] = Field(default=None, description="ISO8601 datetime (optional)")
    allow_feedback: bool = Field(default=True)
    custom_caption: Optional[str] = None


class UpdateCollectionOutfitsRequest(BaseModel):
    outfit_ids: List[str] = Field(default_factory=list)


def _now() -> str:
    return datetime.utcnow().isoformat()


def _parse_iso_datetime(value: Optional[str]) -> Optional[datetime]:
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
        if parsed.tzinfo is None:
            return parsed.replace(tzinfo=timezone.utc)
        return parsed
    except ValueError:
        return None

def _normalize_item_images(item: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize Supabase nested relation naming to API contract."""
    if not isinstance(item, dict):
        return item
    images = item.pop("item_images", None)
    if images is None:
        images = item.get("images")
    item["images"] = images or []
    return item


def _normalize_outfit_images(outfit: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize Supabase nested relation naming to API contract."""
    if not isinstance(outfit, dict):
        return outfit
    images = outfit.pop("outfit_images", None)
    if images is None:
        images = outfit.get("images")
    outfit["images"] = images or []
    return outfit


def _collection_counts(db: Client, collection_ids: List[str]) -> Dict[str, int]:
    if not collection_ids:
        return {}
    res = (
        db.table("outfit_collection_items")
        .select("collection_id")
        .in_("collection_id", collection_ids)
        .execute()
    )
    counts: Dict[str, int] = {}
    for row in res.data or []:
        cid = str(row.get("collection_id") or "")
        if cid:
            counts[cid] = counts.get(cid, 0) + 1
    return counts


def _sync_collection_items(
    db: Client,
    *,
    user_id: str,
    collection_id: str,
    outfit_ids: List[str],
):
    # Validate outfits belong to the user
    if outfit_ids:
        res = (
            db.table("outfits")
            .select("id")
            .eq("user_id", user_id)
            .in_("id", outfit_ids)
            .execute()
        )
        found = {str(row["id"]) for row in (res.data or [])}
        missing = [oid for oid in outfit_ids if oid not in found]
        if missing:
            raise ValidationError(
                "One or more outfits not found",
                details={"missing_outfit_ids": missing}
            )

    # Replace items
    db.table("outfit_collection_items").delete().eq("collection_id", collection_id).execute()
    if outfit_ids:
        rows = [{"collection_id": collection_id, "outfit_id": oid} for oid in outfit_ids]
        db.table("outfit_collection_items").insert(rows).execute()


def _fetch_outfit(
    db: Client,
    user_id: str,
    outfit_id: str,
    *,
    include_items: bool = False,
) -> Optional[Dict[str, Any]]:
    """Fetch an outfit with images, normalized for the API contract."""
    result = (
        db.table("outfits")
        .select("*, outfit_images(*)")
        .eq("id", outfit_id)
        .eq("user_id", user_id)
        .single()
        .execute()
    )
    if not result.data:
        return None

    outfit = _normalize_outfit_images(result.data)
    if include_items:
        item_ids = outfit.get("item_ids") or []
        if item_ids:
            items_res = db.table("items").select("*, item_images(*)").in_("id", item_ids).execute()
            outfit["items"] = [_normalize_item_images(i) for i in (items_res.data or [])]
        else:
            outfit["items"] = []
    return outfit


# ============================================================================
# CRUD
# ============================================================================


@router.post("/create", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
@router.post("", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_outfit(
    request: OutfitCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id = str(uuid.uuid4())
        now = _now()

        # Verify items exist and belong to user
        item_ids = [str(i) for i in request.item_ids]
        items_res = db.table("items").select("id").eq("user_id", user_id).in_("id", item_ids).execute()
        found_ids = {row["id"] for row in (items_res.data or [])}
        missing = [iid for iid in item_ids if iid not in found_ids]
        if missing:
            raise ValidationError(
                "One or more items not found",
                details={"missing_item_ids": missing}
            )

        insert = {
            "id": outfit_id,
            "user_id": user_id,
            "name": request.name,
            "description": request.description,
            "item_ids": item_ids,
            "style": request.style,
            "season": request.season,
            "occasion": request.occasion,
            "tags": request.tags,
            "is_favorite": request.is_favorite,
            "is_draft": request.is_draft,
            "is_public": request.is_public,
            "worn_count": 0,
            "last_worn_at": None,
            "created_at": now,
            "updated_at": now,
        }

        res = db.table("outfits").insert(insert).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create outfit", operation="insert")

        row["images"] = []
        return {"data": row, "message": "Created"}

    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Create outfit error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to create outfit", operation="insert")


@router.get("", response_model=Dict[str, Any])
async def list_outfits(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    is_favorite: Optional[bool] = Query(None),
    style: Optional[str] = Query(None),
    season: Optional[str] = Query(None),
    search: Optional[str] = Query(None),
    tags: Optional[str] = Query(None, description="Comma-separated tags"),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        query = db.table("outfits").select("*, outfit_images(*)").eq("user_id", user_id)
        if is_favorite is not None:
            query = query.eq("is_favorite", is_favorite)
        if style:
            query = query.eq("style", style)
        if season:
            query = query.eq("season", season)
        if tags:
            tag_list = [t.strip() for t in tags.split(",") if t.strip()]
            if tag_list:
                query = query.contains("tags", tag_list)
        if search:
            like = f"%{search}%"
            query = query.or_(f"name.ilike.{like},description.ilike.{like}")

        count_q = db.table("outfits").select("id", count="exact").eq("user_id", user_id)
        if is_favorite is not None:
            count_q = count_q.eq("is_favorite", is_favorite)
        if style:
            count_q = count_q.eq("style", style)
        if season:
            count_q = count_q.eq("season", season)
        if tags:
            tag_list = [t.strip() for t in tags.split(",") if t.strip()]
            if tag_list:
                count_q = count_q.contains("tags", tag_list)
        if search:
            like = f"%{search}%"
            count_q = count_q.or_(f"name.ilike.{like},description.ilike.{like}")
        count_res = count_q.execute()
        total = getattr(count_res, "count", len(count_res.data or []))

        start = (page - 1) * page_size
        end = start + page_size - 1
        res = query.order("created_at", desc=True).range(start, end).execute()
        outfits = [_normalize_outfit_images(o) for o in (res.data or [])]

        total_pages = max(1, (total + page_size - 1) // page_size)
        return {
            "data": {
                "outfits": outfits,
                "total": total,
                "page": page,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_prev": page > 1,
            },
            "message": "OK",
        }

    except Exception as e:
        logger.error("List outfits error", user_id=user_id, page=page, error=str(e))
        raise DatabaseError("Failed to fetch outfits", operation="select")


@router.get("/available-items", response_model=Dict[str, Any])
async def available_items(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return simplified items list suitable for outfit-building UIs."""
    try:
        res = (
            db.table("items")
            .select("id,name,category,colors,item_images(image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("created_at", desc=True)
            .limit(500)
            .execute()
        )
        items = []
        for row in res.data or []:
            images = row.get("item_images") or []
            primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
            items.append(
                {
                    "id": row["id"],
                    "name": row.get("name"),
                    "category": row.get("category"),
                    "colors": row.get("colors") or [],
                    "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
                }
            )
        return {"data": items, "message": "OK"}
    except Exception as e:
        logger.error("Available items error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch available items", operation="select")


@router.get("/{outfit_id}", response_model=Dict[str, Any])
async def get_outfit(
    outfit_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        outfit = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str, include_items=True)
        if not outfit:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)
        return {"data": outfit, "message": "OK"}

    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Get outfit error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch outfit", operation="select")


@router.get("/public/{outfit_id}", response_model=Dict[str, Any])
async def get_public_outfit(
    outfit_id: UUID,
    db: Client = Depends(get_db),
):
    """Public outfit view for share links (no auth).

    Only returns data when `is_public=true` on the outfit record.
    """
    try:
        outfit_id_str = str(outfit_id)
        result = (
            db.table("outfits")
            .select("id,name,description,style,season,occasion,tags,is_public,created_at,updated_at,item_ids,outfit_images(*)")
            .eq("id", outfit_id_str)
            .eq("is_public", True)
            .single()
            .execute()
        )
        if not result.data:
            raise NotFoundError(
                "Shared outfit not found",
                resource_type="shared_outfit",
                resource_id=outfit_id_str
            )

        outfit = result.data
        share = (
            db.table("shared_outfits")
            .select("id, expires_at, view_count")
            .eq("outfit_id", outfit_id_str)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        share_row = (share.data or [None])[0]
        if share_row:
            expires_at = _parse_iso_datetime(share_row.get("expires_at"))
            if expires_at and expires_at < datetime.now(timezone.utc):
                raise SharedOutfitNotFoundError(share_id=outfit_id_str)
            views = int(share_row.get("view_count") or 0) + 1
            db.table("shared_outfits").update({"view_count": views}).eq("id", share_row["id"]).execute()

        item_ids = outfit.get("item_ids") or []
        items_summary: List[Dict[str, Any]] = []
        if item_ids:
            items_res = (
                db.table("items")
                .select("id,name,category,colors,brand")
                .in_("id", item_ids)
                .execute()
            )
            items_summary = items_res.data or []

        public = {
            "id": outfit.get("id"),
            "name": outfit.get("name"),
            "description": outfit.get("description"),
            "style": outfit.get("style"),
            "season": outfit.get("season"),
            "occasion": outfit.get("occasion"),
            "tags": outfit.get("tags") or [],
            "created_at": outfit.get("created_at"),
            "updated_at": outfit.get("updated_at"),
            "images": outfit.get("outfit_images") or [],
            "items": items_summary,
        }
        return {"data": public, "message": "OK"}

    except (NotFoundError, SharedOutfitNotFoundError):
        raise
    except Exception as e:
        logger.error("Get public outfit error", outfit_id=str(outfit_id), error=str(e))
        raise DatabaseError("Failed to fetch shared outfit", operation="select")


@router.put("/{outfit_id}", response_model=Dict[str, Any])
async def update_outfit(
    outfit_id: UUID,
    update: OutfitUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        if "item_ids" in update_dict and update_dict["item_ids"] is not None:
            item_ids = [str(i) for i in update_dict["item_ids"]]
            items_res = db.table("items").select("id").eq("user_id", user_id).in_("id", item_ids).execute()
            found_ids = {row["id"] for row in (items_res.data or [])}
            missing = [iid for iid in item_ids if iid not in found_ids]
            if missing:
                raise ValidationError(
                    "One or more items not found",
                    details={"missing_item_ids": missing}
                )
            update_dict["item_ids"] = item_ids

        update_dict["updated_at"] = _now()
        result = db.table("outfits").update(update_dict).eq("id", outfit_id_str).eq("user_id", user_id).execute()
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")

        outfit = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not outfit:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        return {"data": outfit, "message": "Updated"}

    except (OutfitNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update outfit error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update outfit", operation="update")


@router.post("/{outfit_id}/share", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def share_outfit(
    outfit_id: UUID,
    request: ShareOutfitRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Enable public sharing for an outfit and return a share URL.

    MVP: visibility/expires_at are accepted but only `public` visibility is enforced.
    """
    try:
        outfit_id_str = str(outfit_id)
        existing = (
            db.table("outfits")
            .select("id")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        now = _now()
        is_public = request.visibility == "public"
        db.table("outfits").update({"is_public": is_public, "updated_at": now}).eq("id", outfit_id_str).execute()

        share_url = f"{settings.FRONTEND_URL.rstrip('/')}/shared/outfits/{outfit_id_str}"
        existing_share = (
            db.table("shared_outfits")
            .select("*")
            .eq("outfit_id", outfit_id_str)
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )
        share_row = (existing_share.data or [None])[0]
        payload = {
            "visibility": request.visibility,
            "expires_at": request.expires_at,
            "caption": request.custom_caption,
            "allow_feedback": request.allow_feedback,
            "share_url": share_url,
        }
        if share_row:
            updated = (
                db.table("shared_outfits")
                .update(payload)
                .eq("id", share_row["id"])
                .execute()
            )
            share_row = (updated.data or [share_row])[0]
        else:
            insert = {
                "user_id": user_id,
                "outfit_id": outfit_id_str,
                "share_url": share_url,
                "visibility": request.visibility,
                "expires_at": request.expires_at,
                "caption": request.custom_caption,
                "allow_feedback": request.allow_feedback,
                "created_at": now,
            }
            created = db.table("shared_outfits").insert(insert).execute()
            share_row = (created.data or [None])[0]

        return {
            "data": {
                "share_link": {
                    "url": share_url,
                    "qr_code_url": None,
                    "expires_at": (share_row or {}).get("expires_at"),
                    "views": (share_row or {}).get("view_count") or 0,
                }
            },
            "message": "Created",
        }
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Share outfit error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to share outfit", operation="insert")


@router.delete("/{outfit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_outfit(
    outfit_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute()
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)
        db.table("outfits").delete().eq("id", outfit_id_str).eq("user_id", user_id).execute()
        return None
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Delete outfit error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete outfit", operation="delete")


# ============================================================================
# COLLECTIONS
# ============================================================================


@router.post("/collections", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_collection(
    request: OutfitCollectionCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id = str(uuid.uuid4())
        now = _now()
        insert = {
            "id": collection_id,
            "user_id": user_id,
            "name": request.name,
            "description": request.description,
            "is_favorite": request.is_favorite,
            "created_at": now,
            "updated_at": now,
        }
        res = db.table("outfit_collections").insert(insert).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create collection", operation="insert")

        outfit_ids = [str(i) for i in (request.outfit_ids or [])]
        if outfit_ids:
            _sync_collection_items(db, user_id=user_id, collection_id=collection_id, outfit_ids=outfit_ids)

        row["outfit_count"] = len(outfit_ids)
        return {"data": row, "message": "Created"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Create collection error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to create collection", operation="insert")


@router.get("/collections", response_model=Dict[str, Any])
async def list_collections(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = (
            db.table("outfit_collections")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )
        rows = res.data or []
        counts = _collection_counts(db, [str(r.get("id")) for r in rows])
        for row in rows:
            row["outfit_count"] = counts.get(str(row.get("id")), 0)
        return {"data": {"collections": rows}, "message": "OK"}
    except Exception as e:
        logger.error("List collections error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch collections", operation="select")


@router.put("/collections/{collection_id}", response_model=Dict[str, Any])
async def update_collection(
    collection_id: UUID,
    update: OutfitCollectionUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        existing = (
            db.table("outfit_collections")
            .select("id")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise CollectionNotFoundError(collection_id=collection_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        outfit_ids = update_dict.pop("outfit_ids", None)
        if update_dict:
            update_dict["updated_at"] = _now()
            db.table("outfit_collections").update(update_dict).eq("id", collection_id_str).execute()

        if outfit_ids is not None:
            _sync_collection_items(
                db,
                user_id=user_id,
                collection_id=collection_id_str,
                outfit_ids=[str(i) for i in outfit_ids],
            )

        row = (
            db.table("outfit_collections")
            .select("*")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        ).data
        if not row:
            raise DatabaseError("Failed to fetch collection", operation="select")

        counts = _collection_counts(db, [collection_id_str])
        row["outfit_count"] = counts.get(collection_id_str, 0)
        return {"data": row, "message": "Updated"}
    except (CollectionNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Update collection error", collection_id=str(collection_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update collection", operation="update")


@router.put("/collections/{collection_id}/outfits", response_model=Dict[str, Any])
async def replace_collection_outfits(
    collection_id: UUID,
    request: UpdateCollectionOutfitsRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        existing = (
            db.table("outfit_collections")
            .select("id")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise CollectionNotFoundError(collection_id=collection_id_str)

        _sync_collection_items(
            db,
            user_id=user_id,
            collection_id=collection_id_str,
            outfit_ids=[str(i) for i in (request.outfit_ids or [])],
        )

        row = (
            db.table("outfit_collections")
            .select("*")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        ).data
        counts = _collection_counts(db, [collection_id_str])
        row["outfit_count"] = counts.get(collection_id_str, 0)
        return {"data": row, "message": "Updated"}
    except (CollectionNotFoundError, ValidationError):
        raise
    except Exception as e:
        logger.error("Replace collection outfits error", collection_id=str(collection_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update collection outfits", operation="update")


@router.delete("/collections/{collection_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_collection(
    collection_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        existing = (
            db.table("outfit_collections")
            .select("id")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise CollectionNotFoundError(collection_id=collection_id_str)

        db.table("outfit_collections").delete().eq("id", collection_id_str).eq("user_id", user_id).execute()
        return None
    except CollectionNotFoundError:
        raise
    except Exception as e:
        logger.error("Delete collection error", collection_id=str(collection_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete collection", operation="delete")


# ============================================================================
# EXTRA ACTIONS (favorite, wear, duplicate, composition)
# ============================================================================


@router.post("/{outfit_id}/favorite", response_model=Dict[str, Any])
async def toggle_favorite(
    outfit_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = (
            db.table("outfits")
            .select("is_favorite")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)
        new_value = not bool(existing.data.get("is_favorite", False))
        db.table("outfits").update({"is_favorite": new_value, "updated_at": _now()}).eq("id", outfit_id_str).execute()
        return {"data": {"id": outfit_id_str, "is_favorite": new_value}, "message": "OK"}
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Toggle outfit favorite error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to toggle favorite", operation="update")


@router.post("/{outfit_id}/wear", response_model=Dict[str, Any])
async def mark_worn(
    outfit_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = (
            db.table("outfits")
            .select("worn_count")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        current = int(existing.data.get("worn_count") or 0)
        now = _now()
        db.table("outfits").update({"worn_count": current + 1, "last_worn_at": now, "updated_at": now}).eq("id", outfit_id_str).execute()
        return {"data": {"id": outfit_id_str, "worn_count": current + 1, "last_worn_at": now}, "message": "OK"}
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Mark outfit worn error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update wear count", operation="update")


@router.post("/{outfit_id}/duplicate", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def duplicate_outfit(
    outfit_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = (
            db.table("outfits")
            .select("*")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        now = _now()
        new_id = str(uuid.uuid4())
        insert = {
            "id": new_id,
            "user_id": user_id,
            "name": f"Copy of {existing.data.get('name') or 'Outfit'}",
            "description": existing.data.get("description"),
            "item_ids": existing.data.get("item_ids") or [],
            "style": existing.data.get("style"),
            "season": existing.data.get("season"),
            "occasion": existing.data.get("occasion"),
            "tags": existing.data.get("tags") or [],
            "is_favorite": False,
            "is_draft": True,
            "is_public": False,
            "worn_count": 0,
            "last_worn_at": None,
            "created_at": now,
            "updated_at": now,
        }
        res = db.table("outfits").insert(insert).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to duplicate outfit", operation="insert")
        row["images"] = []
        return {"data": row, "message": "Created"}
    except (OutfitNotFoundError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Duplicate outfit error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to duplicate outfit", operation="insert")


@router.post("/{outfit_id}/items", response_model=Dict[str, Any])
async def add_item_to_outfit(
    outfit_id: UUID,
    request: AddItemToOutfitRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        outfit = (
            db.table("outfits")
            .select("id,item_ids")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        item_id = request.item_id
        item = db.table("items").select("id").eq("id", item_id).eq("user_id", user_id).single().execute()
        if not item.data:
            raise ItemNotFoundError(item_id=item_id)

        item_ids = list(outfit.data.get("item_ids") or [])
        if item_id in item_ids:
            current = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
            return {"data": current or {"id": outfit_id_str, "item_ids": item_ids, "images": []}, "message": "OK"}
        item_ids.append(item_id)

        now = _now()
        res = db.table("outfits").update({"item_ids": item_ids, "updated_at": now}).eq("id", outfit_id_str).eq("user_id", user_id).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")
        updated = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not updated:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        return {"data": updated, "message": "Updated"}
    except (OutfitNotFoundError, ItemNotFoundError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Add item to outfit error", outfit_id=str(outfit_id), item_id=request.item_id, user_id=user_id, error=str(e))
        raise DatabaseError("Failed to add item to outfit", operation="update")


@router.delete("/{outfit_id}/items/{item_id}", response_model=Dict[str, Any])
async def remove_item_from_outfit(
    outfit_id: UUID,
    item_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        item_id_str = str(item_id)
        outfit = (
            db.table("outfits")
            .select("id,item_ids")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        item_ids = [str(i) for i in (outfit.data.get("item_ids") or [])]
        if item_id_str not in item_ids:
            current = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
            return {"data": current or {"id": outfit_id_str, "item_ids": item_ids, "images": []}, "message": "OK"}

        new_item_ids = [i for i in item_ids if i != item_id_str]
        if not new_item_ids:
            raise ValidationError(
                "Outfit must contain at least one item",
                details={"outfit_id": outfit_id_str}
            )

        now = _now()
        res = db.table("outfits").update({"item_ids": new_item_ids, "updated_at": now}).eq("id", outfit_id_str).eq("user_id", user_id).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")
        updated = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not updated:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        return {"data": updated, "message": "Updated"}
    except (OutfitNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Remove item from outfit error", outfit_id=str(outfit_id), item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to remove item from outfit", operation="update")


# ============================================================================
# GENERATION TRACKING (client-side AI)
# ============================================================================


@router.post("/{outfit_id}/generate", response_model=Dict[str, Any], status_code=status.HTTP_202_ACCEPTED)
async def start_generation(
    outfit_id: UUID,
    request: GenerationRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Create a generation record and return a generation_id.

    The frontend performs generation via the backend AI service and then uploads the
    resulting image(s) to `/outfits/{outfit_id}/images` including the returned
    generation_id to mark completion.
    """
    try:
        outfit_id_str = str(outfit_id)
        outfit = db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute()
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        generation_id = str(uuid.uuid4())
        now = _now()

        insert = {
            "id": generation_id,
            "user_id": user_id,
            "outfit_id": outfit_id_str,
            "status": GenerationStatus.PROCESSING.value,
            "progress": 0,
            "pose": request.pose,
            "lighting": request.lighting,
            "body_profile_id": str(request.body_profile_id) if request.body_profile_id else None,
            "variations": request.variations,
            "image_urls": [],
            "error": None,
            "created_at": now,
            "started_at": now,
            "completed_at": None,
        }
        db.table("outfit_generations").insert(insert).execute()

        return {
            "data": {"generation_id": generation_id, "status": "processing", "estimated_time": 30},
            "message": "Accepted",
        }
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Start generation error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to start generation", operation="insert")


@router.get("/generation/{generation_id}", response_model=Dict[str, Any])
async def get_generation_status(
    generation_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        generation_id_str = str(generation_id)
        result = (
            db.table("outfit_generations")
            .select("*")
            .eq("id", generation_id_str)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if not result.data:
            raise NotFoundError(
                "Generation not found",
                resource_type="generation",
                resource_id=generation_id_str
            )

        row = result.data
        return {
            "data": {
                "status": row.get("status"),
                "progress": row.get("progress"),
                "images": row.get("image_urls") or [],
                "error": row.get("error"),
            },
            "message": "OK",
        }
    except NotFoundError:
        raise
    except Exception as e:
        logger.error("Get generation status error", generation_id=str(generation_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch generation status", operation="select")


# ============================================================================
# OUTFIT IMAGES
# ============================================================================


@router.post("/{outfit_id}/images", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def upload_outfit_image(
    outfit_id: UUID,
    file: UploadFile = File(...),
    pose: str = Form("front"),
    lighting: Optional[str] = Form(None),
    body_profile_id: Optional[str] = Form(None),
    generation_id: Optional[str] = Form(None),
    is_primary: bool = Form(True),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Upload an outfit image and create an outfit_images record."""
    try:
        outfit_id_str = str(outfit_id)
        outfit = db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute()
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError()

        file_bytes = await file.read()
        upload = await StorageService.upload_outfit_image(
            db=db,
            user_id=user_id,
            filename=file.filename or "outfit.png",
            file_data=file_bytes,
            generation_type="ai",
        )

        now = _now()
        img_row = {
            "id": str(uuid.uuid4()),
            "outfit_id": outfit_id_str,
            "image_url": upload.get("image_url"),
            "thumbnail_url": upload.get("thumbnail_url"),
            "storage_path": upload.get("storage_path"),
            "pose": pose,
            "lighting": lighting,
            "body_profile_id": body_profile_id,
            "generation_type": upload.get("generation_type") or "ai",
            "is_primary": bool(is_primary),
            "width": upload.get("width"),
            "height": upload.get("height"),
            "generation_metadata": upload.get("metadata"),
            "created_at": now,
        }
        if is_primary:
            db.table("outfit_images").update({"is_primary": False}).eq("outfit_id", outfit_id_str).execute()
        db.table("outfit_images").insert(img_row).execute()

        # Mark generation complete if provided
        if generation_id:
            db.table("outfit_generations").update(
                {
                    "status": GenerationStatus.COMPLETED.value,
                    "progress": 100,
                    "image_urls": [img_row["image_url"]],
                    "completed_at": now,
                }
            ).eq("id", generation_id).eq("user_id", user_id).execute()

        return {"data": img_row, "message": "Created"}

    except (OutfitNotFoundError, UnsupportedMediaTypeError):
        raise
    except Exception as e:
        logger.error("Upload outfit image error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to upload outfit image", operation="insert")


@router.delete("/{outfit_id}/images/{image_id}", response_model=Dict[str, Any])
async def delete_outfit_image(
    outfit_id: UUID,
    image_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Delete an outfit image and best-effort remove it from storage."""
    try:
        outfit_id_str = str(outfit_id)
        image_id_str = str(image_id)

        outfit = db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute()
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        img = (
            db.table("outfit_images")
            .select("id, storage_path")
            .eq("id", image_id_str)
            .eq("outfit_id", outfit_id_str)
            .single()
            .execute()
        )
        if not img.data:
            raise ImageNotFoundError(image_id=image_id_str)

        storage_path = img.data.get("storage_path")
        if storage_path:
            try:
                await StorageService.delete_image(db=db, storage_path=storage_path)
            except Exception:
                pass

        db.table("outfit_images").delete().eq("id", image_id_str).eq("outfit_id", outfit_id_str).execute()
        return {"data": {"deleted": True}, "message": "OK"}
    except (OutfitNotFoundError, ImageNotFoundError):
        raise
    except Exception as e:
        logger.error("Delete outfit image error", outfit_id=str(outfit_id), image_id=str(image_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete outfit image", operation="delete")


@router.get("/stats", response_model=Dict[str, Any])
async def get_outfit_stats(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Compute outfit statistics for analytics/dashboard."""
    try:
        outfits = (
            db.table("outfits")
            .select("id,name,style,season,worn_count,created_at")
            .eq("user_id", user_id)
            .execute()
            .data
            or []
        )

        total_outfits = len(outfits)
        outfits_by_style: Dict[str, int] = {}
        outfits_by_season: Dict[str, int] = {}
        for o in outfits:
            st = (o.get("style") or "other").lower()
            outfits_by_style[st] = outfits_by_style.get(st, 0) + 1
            se = (o.get("season") or "unknown").lower()
            outfits_by_season[se] = outfits_by_season.get(se, 0) + 1

        most_worn = sorted(outfits, key=lambda o: int(o.get("worn_count") or 0), reverse=True)[:5]
        recent = sorted(outfits, key=lambda o: o.get("created_at") or "", reverse=True)[:5]

        return {
            "data": {
                "total_outfits": total_outfits,
                "outfits_by_style": outfits_by_style,
                "outfits_by_season": outfits_by_season,
                "most_worn_outfits": [
                    {"id": o["id"], "name": o.get("name"), "times_worn": int(o.get("worn_count") or 0)}
                    for o in most_worn
                ],
                "recent_outfits": [{"id": o["id"], "name": o.get("name"), "created_at": o.get("created_at")} for o in recent],
            },
            "message": "OK",
        }
    except Exception as e:
        logger.error("Outfit stats error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch outfit stats", operation="select")


@router.post("/batch-delete", response_model=Dict[str, Any])
async def batch_delete_outfits(
    request: BatchDeleteOutfitsRequest,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Batch delete outfits and best-effort remove their images from storage."""
    outfit_ids = list(dict.fromkeys([i for i in request.outfit_ids if i]))
    if not outfit_ids:
        raise ValidationError("outfit_ids is required", details={"field": "outfit_ids"})

    try:
        imgs_res = db.table("outfit_images").select("outfit_id, storage_path").in_("outfit_id", outfit_ids).execute()
        storage_paths = [row.get("storage_path") for row in (imgs_res.data or []) if row.get("storage_path")]
        if storage_paths:
            try:
                await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
            except Exception:
                pass

        delete_res = db.table("outfits").delete().eq("user_id", user_id).in_("id", outfit_ids).execute()
        deleted_count = len(delete_res.data or [])
        return {"data": {"deleted_count": deleted_count}, "message": "OK"}
    except ValidationError:
        raise
    except Exception as e:
        logger.error("Batch delete outfits error", user_id=user_id, outfit_count=len(outfit_ids), error=str(e))
        raise DatabaseError("Failed to batch delete outfits", operation="delete")


@router.get("/recently-worn", response_model=Dict[str, Any])
async def recently_worn(
    limit: int = Query(5, ge=1, le=20),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = (
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .not_.is_("last_worn_at", "null")
            .order("last_worn_at", desc=True)
            .limit(limit)
            .execute()
        )
        outfits = [_normalize_outfit_images(o) for o in (res.data or [])]
        return {"data": {"outfits": outfits}, "message": "OK"}
    except Exception as e:
        logger.error("Recently worn outfits error", user_id=user_id, limit=limit, error=str(e))
        raise DatabaseError("Failed to fetch recently worn outfits", operation="select")


@router.get("/favorites", response_model=Dict[str, Any])
async def favorites(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = (
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .eq("is_favorite", True)
            .order("updated_at", desc=True)
            .limit(100)
            .execute()
        )
        outfits = [_normalize_outfit_images(o) for o in (res.data or [])]
        return {"data": {"outfits": outfits}, "message": "OK"}
    except Exception as e:
        logger.error("Favorite outfits error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch favorite outfits", operation="select")


@router.get("/suggestions/weather", response_model=Dict[str, Any])
async def weather_suggestions(
    temperature: float = Query(..., description="Current temperature in Celsius"),
    weather_condition: Optional[str] = Query(None),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Return simple outfit suggestions based on temperature and seasonal tags."""
    try:
        season = "all-season"
        if temperature < 5:
            season = "winter"
        elif temperature > 25:
            season = "summer"

        outfits_res = (
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .order("updated_at", desc=True)
            .limit(50)
            .execute()
        )
        outfits = outfits_res.data or []
        outfits = [_normalize_outfit_images(o) for o in outfits]

        tagged = [
            o
            for o in outfits
            if season in (o.get("tags") or []) or season == (o.get("season") or "").lower()
        ]
        selected = (tagged or outfits)[:3]

        reasoning = f"Suggested based on {temperature}°C and season '{season}'."
        if weather_condition:
            reasoning += f" Condition: {weather_condition}."

        return {
            "data": {"suggestions": {"items": [], "outfits": selected, "reasoning": reasoning}},
            "message": "OK",
        }
    except Exception as e:
        logger.error("Weather outfit suggestions error", user_id=user_id, temperature=temperature, weather_condition=weather_condition, error=str(e))
        raise DatabaseError("Failed to fetch weather suggestions", operation="select")
