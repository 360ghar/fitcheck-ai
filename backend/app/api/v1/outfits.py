"""
Outfits API routes.

Implements outfit CRUD and a lightweight generation-tracking flow.

AI image generation is performed server-side via the AI provider service. The backend
stores generated images in Supabase Storage and records metadata for retrieval.
"""

import asyncio
import uuid
from typing import Any, Dict, List, Optional, Tuple
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
from app.api.v1.deps import get_active_user_id
from app.core.uploads import read_upload_capped
from app.core.config import settings
from app.db.connection import get_db
from app.models.common import DataResponse
from app.models.outfit import (
    GenerationRequest,
    GenerationStatus,
    OutfitCreate,
    OutfitListResponse,
    OutfitResponse,
    OutfitUpdate,
    OutfitCollectionCreate,
    OutfitCollectionUpdate,
)
from app.services.outfit_service import delete_outfit as delete_outfit_service
from app.services.storage_service import MAX_FILE_SIZE, StorageService
from app.utils.datetime_util import utcnow, utcnow_iso, parse_utc_datetime
from app.utils.db import execute_with_reconnect, jsonb_contains, safe_search_term
from app.api.v1.images import materialize_image_urls, materialize_parent_images

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


class AddCollectionOutfitRequest(BaseModel):
    outfit_id: str = Field(..., min_length=1)


def _now() -> str:
    return utcnow_iso()


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


async def _owned_collection_or_404(db: Client, collection_id: str, user_id: str) -> None:
    """Verify a collection exists under the caller's ownership (RLS bypassed)."""
    existing = await asyncio.to_thread(
        db.table("outfit_collections")
        .select("id")
        .eq("id", collection_id)
        .eq("user_id", user_id)
        .single()
        .execute
    )
    if not existing.data:
        raise CollectionNotFoundError(collection_id=collection_id)


async def _collection_member_ids(db: Client, collection_id: str) -> List[str]:
    """Ordered outfit_ids currently in a collection (for response decoration)."""
    member_res = await asyncio.to_thread(
        db.table("outfit_collection_items")
        .select("outfit_id")
        .eq("collection_id", collection_id)
        .execute
    )
    return [
        str(member.get("outfit_id"))
        for member in (member_res.data or [])
        if member.get("outfit_id")
    ]


async def _collection_count(db: Client, collection_id: str) -> int:
    """Member count for a single collection."""
    counts = await asyncio.to_thread(_collection_counts, db, [collection_id])
    return counts.get(collection_id, 0)


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


@router.post("", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_outfit(
    request: OutfitCreate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id = str(uuid.uuid4())
        now = _now()

        # Verify items exist and belong to user
        item_ids = [str(i) for i in request.item_ids]
        items_res = await execute_with_reconnect(
            lambda d: d.table("items").select("id").eq("user_id", user_id).in_("id", item_ids).execute(),
            db,
            extra={"operation": "create_outfit.verify_items", "user_id": user_id},
        )
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

        res = await execute_with_reconnect(
            lambda d: d.table("outfits").insert(insert).execute(),
            db,
            extra={"operation": "create_outfit.insert", "user_id": user_id},
        )
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


@router.get("", response_model=DataResponse[OutfitListResponse])
async def list_outfits(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    is_favorite: Optional[bool] = Query(None),
    style: Optional[str] = Query(None),
    season: Optional[str] = Query(None),
    styles: Optional[str] = Query(None, description="Comma-separated style filters"),
    seasons: Optional[str] = Query(None, description="Comma-separated season filters"),
    favorites_only: Optional[bool] = Query(None),
    drafts_only: Optional[bool] = Query(None),
    search: Optional[str] = Query(None),
    tags: Optional[str] = Query(None, description="Comma-separated tags"),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        styles_value = styles if isinstance(styles, str) else None
        seasons_value = seasons if isinstance(seasons, str) else None
        favorites_value = favorites_only if isinstance(favorites_only, bool) else None
        drafts_value = drafts_only if isinstance(drafts_only, bool) else None
        effective_favorite = is_favorite if is_favorite is not None else favorites_value
        effective_styles = [value.strip() for value in (styles_value or "").split(",") if value.strip()]
        effective_seasons = [value.strip() for value in (seasons_value or "").split(",") if value.strip()]
        if style:
            effective_styles = [style]
        if season:
            effective_seasons = [season]
        tag_list = [t.strip() for t in tags.split(",") if t.strip()] if tags else []

        # Shared filter application for both the count and the page query.
        # Rebuilding from the passed client `d` lets execute_with_reconnect
        # replay the whole query through a fresh client when the pooled
        # Supabase connection is dead (ConnectionTerminated 500s observed on
        # /outfits 2026-08-03; one list took 121s before failing).
        def _apply_outfit_filters(q: Any) -> Any:
            if effective_favorite is not None:
                q = q.eq("is_favorite", effective_favorite)
            if effective_styles:
                q = q.in_("style", effective_styles)
            if effective_seasons:
                q = q.in_("season", effective_seasons)
            if drafts_value is not None:
                q = q.eq("is_draft", drafts_value)
            if tag_list:
                # JSONB array contains: jsonb_contains emits a JSON array
                # literal - plain contains(list) sends a Postgres array
                # literal ({a,b}) and PostgREST answers 22P02 for the jsonb
                # `tags` column (2026-08-07 /items occasion-filter incident,
                # same latent pattern).
                q = jsonb_contains(q, "tags", tag_list)
            if search:
                like = f"%{safe_search_term(search)}%"
                q = q.or_(f"name.ilike.{like},description.ilike.{like}")
            return q

        def _build_list_query(d: Any, *, count_only: bool = False, page_range: bool = False) -> Any:
            if count_only:
                q = d.table("outfits").select("id", count="exact").eq("user_id", user_id)
            else:
                q = d.table("outfits").select("*, outfit_images(*)").eq("user_id", user_id)
            q = _apply_outfit_filters(q)
            if page_range:
                q = q.order("created_at", desc=True).range(start, end)
            return q

        # The whole read (count + page + item batch) runs in ONE wrapped
        # coroutine so a dead pooled Supabase connection triggers a single
        # client rebuild and the retry replays every query through the fresh
        # client - instead of each query self-healing separately (which would
        # leave the later queries on the original dead client for one more
        # failed round-trip). ConnectionTerminated 500s observed on /outfits
        # 2026-08-03 (one list took 121s before failing).
        start = (page - 1) * page_size
        end = start + page_size - 1

        async def _list_outfits_data(d: Any) -> Tuple[Any, int, Dict[str, Dict[str, Any]]]:
            # Count + page are independent reads; run them concurrently so a
            # list response waits on the slower of the two, not their sum.
            count_res, res = await asyncio.gather(
                asyncio.to_thread(_build_list_query(d, count_only=True).execute),
                asyncio.to_thread(_build_list_query(d, page_range=True).execute),
            )
            total = getattr(count_res, "count", len(count_res.data or []))

            outfits = [_normalize_outfit_images(o) for o in (res.data or [])]

            # Fetch all items for all outfits in a single batch query
            all_item_ids: List[str] = []
            for outfit in outfits:
                all_item_ids.extend(outfit.get("item_ids") or [])
            all_item_ids = list(set(all_item_ids))  # dedupe

            items_map: Dict[str, Dict[str, Any]] = {}
            if all_item_ids:
                items_res = await asyncio.to_thread(
                    d.table("items").select("*, item_images(*)").in_("id", all_item_ids).execute
                )
                for item in (items_res.data or []):
                    # Transform item_images to have 'url' field for Flutter compatibility
                    item_images = item.get("item_images") or []
                    for img in item_images:
                        img["url"] = img.get("image_url") or img.get("thumbnail_url") or ""
                    items_map[str(item["id"])] = item

            return outfits, total, items_map

        outfits, total, items_map = await execute_with_reconnect(
            lambda d: _list_outfits_data(d),
            db,
            extra={"operation": "list_outfits", "user_id": user_id},
        )

        # Private buckets: materialize fresh short-lived presigned URLs from
        # storage_path at read time (the DB stores keys, not URLs) for both the
        # outfit images and the nested item images.
        await asyncio.gather(
            materialize_parent_images(outfits),
            materialize_parent_images(list(items_map.values())),
        )

        # Attach items to each outfit
        for outfit in outfits:
            outfit["items"] = [
                items_map.get(str(iid))
                for iid in (outfit.get("item_ids") or [])
                if str(iid) in items_map
            ]

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Return simplified items list suitable for outfit-building UIs."""
    try:
        res = await asyncio.to_thread(
            db.table("items")
            .select("id,name,category,colors,item_images(storage_path,image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("created_at", desc=True)
            .limit(500)
            .execute
        )
        items = []
        for row in res.data or []:
            images = row.get("item_images") or []
            # Private buckets: materialize a fresh presigned URL per row from
            # storage_path so picker grids never render stale/expired URLs.
            await materialize_image_urls(images)
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


@router.get("/{outfit_id:uuid}", response_model=DataResponse[OutfitResponse])
async def get_outfit(
    outfit_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        outfit = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str, include_items=True)
        if not outfit:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)
        # Private buckets: materialize fresh presigned URLs at read time.
        outfit = (await materialize_parent_images([outfit]))[0]
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
        result = await asyncio.to_thread(
            db.table("outfits")
            .select("id,name,description,style,season,occasion,tags,is_public,created_at,updated_at,item_ids,outfit_images(*)")
            .eq("id", outfit_id_str)
            .eq("is_public", True)
            .single()
            .execute
        )
        if not result.data:
            raise NotFoundError(
                "Shared outfit not found",
                resource_type="shared_outfit",
                resource_id=outfit_id_str
            )

        outfit = result.data
        share = await asyncio.to_thread(
            db.table("shared_outfits")
            .select("id, expires_at, view_count")
            .eq("outfit_id", outfit_id_str)
            .order("created_at", desc=True)
            .limit(1)
            .execute
        )
        share_row = (share.data or [None])[0]
        if share_row:
            expires_at = parse_utc_datetime(share_row.get("expires_at"))
            if expires_at and expires_at < utcnow():
                raise SharedOutfitNotFoundError(share_id=outfit_id_str)
            views = int(share_row.get("view_count") or 0) + 1
            await asyncio.to_thread(db.table("shared_outfits").update({"view_count": views}).eq("id", share_row["id"]).execute)

        item_ids = outfit.get("item_ids") or []
        items_summary: List[Dict[str, Any]] = []
        if item_ids:
            items_res = await asyncio.to_thread(
                db.table("items")
                .select("id,name,category,colors,brand")
                .in_("id", item_ids)
                .execute
            )
            items_summary = items_res.data or []

        # Private buckets: materialize fresh short-lived presigned URLs at read
        # time so the share link never serves an expired stored URL.
        await materialize_image_urls(outfit.get("outfit_images") or [])

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = await asyncio.to_thread(db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute)
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        if "item_ids" in update_dict and update_dict["item_ids"] is not None:
            item_ids = [str(i) for i in update_dict["item_ids"]]
            items_res = await asyncio.to_thread(db.table("items").select("id").eq("user_id", user_id).in_("id", item_ids).execute)
            found_ids = {row["id"] for row in (items_res.data or [])}
            missing = [iid for iid in item_ids if iid not in found_ids]
            if missing:
                raise ValidationError(
                    "One or more items not found",
                    details={"missing_item_ids": missing}
                )
            update_dict["item_ids"] = item_ids

        update_dict["updated_at"] = _now()
        result = await asyncio.to_thread(db.table("outfits").update(update_dict).eq("id", outfit_id_str).eq("user_id", user_id).execute)
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")

        outfit = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not outfit:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        # Private buckets: materialize fresh presigned URLs at read time.
        outfit = (await materialize_parent_images([outfit]))[0]
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Enable public sharing for an outfit and return a share URL.

    MVP: visibility/expires_at are accepted but only `public` visibility is enforced.
    """
    try:
        outfit_id_str = str(outfit_id)
        existing = await asyncio.to_thread(
            db.table("outfits")
            .select("id")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        now = _now()
        is_public = request.visibility == "public"
        await asyncio.to_thread(db.table("outfits").update({"is_public": is_public, "updated_at": now}).eq("id", outfit_id_str).execute)

        share_url = f"{settings.FRONTEND_URL.rstrip('/')}/shared/outfits/{outfit_id_str}"

        # Use upsert to avoid race conditions between check and insert
        upsert_payload = {
            "user_id": user_id,
            "outfit_id": outfit_id_str,
            "visibility": request.visibility,
            "expires_at": request.expires_at,
            "caption": request.custom_caption,
            "allow_feedback": request.allow_feedback,
            "share_url": share_url,
            "created_at": now,
            "updated_at": now,
        }

        upsert_result = await asyncio.to_thread(
            db.table("shared_outfits")
            .upsert(upsert_payload, on_conflict="outfit_id,user_id")
            .execute
        )
        share_row = (upsert_result.data or [{}])[0]

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete an outfit and best-effort remove its images from storage."""
    try:
        await delete_outfit_service(db, user_id=user_id, outfit_id=str(outfit_id))
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
    user_id: str = Depends(get_active_user_id),
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
        res = await asyncio.to_thread(db.table("outfit_collections").insert(insert).execute)
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create collection", operation="insert")

        outfit_ids = [str(i) for i in (request.outfit_ids or [])]
        if outfit_ids:
            _sync_collection_items(db, user_id=user_id, collection_id=collection_id, outfit_ids=outfit_ids)

        row["outfit_count"] = len(outfit_ids)
        row["outfit_ids"] = outfit_ids
        return {"data": row, "message": "Created"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Create collection error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to create collection", operation="insert")


@router.get("/collections", response_model=Dict[str, Any])
async def list_collections(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = await asyncio.to_thread(
            db.table("outfit_collections")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute
        )
        rows = res.data or []
        collection_ids = [str(r.get("id")) for r in rows if r.get("id")]
        # Counts and member ids are derived from ONE member-row download; the
        # previous count query re-downloaded the same rows.
        counts: Dict[str, int] = {}
        members: Dict[str, List[str]] = {}
        if collection_ids:
            member_res = await asyncio.to_thread(
                db.table("outfit_collection_items")
                .select("collection_id, outfit_id")
                .in_("collection_id", collection_ids)
                .execute
            )
            for member in member_res.data or []:
                cid = str(member.get("collection_id") or "")
                if not cid:
                    continue
                counts[cid] = counts.get(cid, 0) + 1
                outfit_id = member.get("outfit_id")
                if outfit_id:
                    members.setdefault(cid, []).append(str(outfit_id))
        for row in rows:
            collection_id = str(row.get("id"))
            row["outfit_count"] = counts.get(collection_id, 0)
            row["outfit_ids"] = members.get(collection_id, [])
        return {"data": {"collections": rows}, "message": "OK"}
    except Exception as e:
        logger.error("List collections error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch collections", operation="select")


@router.put("/collections/{collection_id}", response_model=Dict[str, Any])
async def update_collection(
    collection_id: UUID,
    update: OutfitCollectionUpdate,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        await _owned_collection_or_404(db, collection_id_str, user_id)

        update_dict = update.model_dump(exclude_unset=True)
        outfit_ids = update_dict.pop("outfit_ids", None)
        if update_dict:
            update_dict["updated_at"] = _now()
            await asyncio.to_thread(db.table("outfit_collections").update(update_dict).eq("id", collection_id_str).execute)

        if outfit_ids is not None:
            _sync_collection_items(
                db,
                user_id=user_id,
                collection_id=collection_id_str,
                outfit_ids=[str(i) for i in outfit_ids],
            )

        row = (await asyncio.to_thread(
            db.table("outfit_collections")
            .select("*")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )).data
        if not row:
            raise DatabaseError("Failed to fetch collection", operation="select")

        row["outfit_count"] = await _collection_count(db, collection_id_str)
        row["outfit_ids"] = (
            [str(i) for i in outfit_ids]
            if outfit_ids is not None
            else await _collection_member_ids(db, collection_id_str)
        )
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        await _owned_collection_or_404(db, collection_id_str, user_id)

        _sync_collection_items(
            db,
            user_id=user_id,
            collection_id=collection_id_str,
            outfit_ids=[str(i) for i in (request.outfit_ids or [])],
        )

        row = (await asyncio.to_thread(
            db.table("outfit_collections")
            .select("*")
            .eq("id", collection_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )).data
        row["outfit_count"] = await _collection_count(db, collection_id_str)
        row["outfit_ids"] = await _collection_member_ids(db, collection_id_str)
        return {"data": row, "message": "Updated"}
    except (CollectionNotFoundError, ValidationError):
        raise
    except Exception as e:
        logger.error("Replace collection outfits error", collection_id=str(collection_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update collection outfits", operation="update")


@router.post("/collections/{collection_id}/outfits", response_model=Dict[str, Any])
async def add_collection_outfit(
    collection_id: UUID,
    request: AddCollectionOutfitRequest,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Add one owned outfit to a collection without replacing existing members."""
    collection_id_str = str(collection_id)
    try:
        await _owned_collection_or_404(db, collection_id_str, user_id)

        outfit = await asyncio.to_thread(
            db.table("outfits")
            .select("id")
            .eq("id", request.outfit_id)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not outfit.data:
            raise ValidationError("Outfit not found", details={"outfit_id": request.outfit_id})

        membership = await asyncio.to_thread(
            db.table("outfit_collection_items")
            .select("outfit_id")
            .eq("collection_id", collection_id_str)
            .eq("outfit_id", request.outfit_id)
            .maybe_single()
            .execute
        )
        if not membership.data:
            # Upsert (not insert): two concurrent add/retry requests can both
            # pass the membership read above, and the junction PK conflict
            # would otherwise 500 one of them. The upsert is idempotent.
            await asyncio.to_thread(
                db.table("outfit_collection_items")
                .upsert(
                    {"collection_id": collection_id_str, "outfit_id": request.outfit_id},
                    on_conflict="collection_id,outfit_id",
                )
                .execute
            )

        count = await _collection_count(db, collection_id_str)
        return {
            "data": {
                "collection_id": collection_id_str,
                "outfit_id": request.outfit_id,
                "outfit_count": count,
            },
            "message": "Added",
        }
    except (CollectionNotFoundError, ValidationError):
        raise
    except Exception as e:
        logger.error("Add collection outfit error", collection_id=collection_id_str, user_id=user_id, error=str(e))
        raise DatabaseError("Failed to add outfit to collection", operation="insert")


@router.delete("/collections/{collection_id}/outfits/{outfit_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_collection_outfit(
    collection_id: UUID,
    outfit_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Remove one outfit from an owned collection."""
    collection_id_str = str(collection_id)
    outfit_id_str = str(outfit_id)
    try:
        await _owned_collection_or_404(db, collection_id_str, user_id)

        await asyncio.to_thread(
            db.table("outfit_collection_items")
            .delete()
            .eq("collection_id", collection_id_str)
            .eq("outfit_id", outfit_id_str)
            .execute
        )
        return None
    except CollectionNotFoundError:
        raise
    except Exception as e:
        logger.error("Remove collection outfit error", collection_id=collection_id_str, user_id=user_id, error=str(e))
        raise DatabaseError("Failed to remove outfit from collection", operation="delete")


@router.delete("/collections/{collection_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_collection(
    collection_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        collection_id_str = str(collection_id)
        await _owned_collection_or_404(db, collection_id_str, user_id)

        await asyncio.to_thread(db.table("outfit_collections").delete().eq("id", collection_id_str).eq("user_id", user_id).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = await asyncio.to_thread(
            db.table("outfits")
            .select("is_favorite")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)
        new_value = not bool(existing.data.get("is_favorite", False))
        await asyncio.to_thread(db.table("outfits").update({"is_favorite": new_value, "updated_at": _now()}).eq("id", outfit_id_str).execute)
        return {"data": {"id": outfit_id_str, "is_favorite": new_value}, "message": "OK"}
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Toggle outfit favorite error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to toggle favorite", operation="update")


@router.post("/{outfit_id}/wear", response_model=Dict[str, Any])
async def mark_worn(
    outfit_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = await asyncio.to_thread(
            db.table("outfits")
            .select("worn_count")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not existing.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        current = int(existing.data.get("worn_count") or 0)
        now = _now()

        # Update outfit
        await asyncio.to_thread(db.table("outfits").update({"worn_count": current + 1, "last_worn_at": now, "updated_at": now}).eq("id", outfit_id_str).execute)

        # Insert wear history record
        wear_record = {
            "id": str(uuid.uuid4()),
            "outfit_id": outfit_id_str,
            "user_id": user_id,
            "worn_at": now,
            "created_at": now,
        }
        try:
            await asyncio.to_thread(db.table("outfit_wear_history").insert(wear_record).execute)
        except Exception as hist_err:
            # Log but don't fail if wear history table doesn't exist yet
            logger.warning("Could not insert wear history record", outfit_id=outfit_id_str, error=str(hist_err))

        return {"data": {"id": outfit_id_str, "worn_count": current + 1, "last_worn_at": now}, "message": "OK"}
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Mark outfit worn error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update wear count", operation="update")


@router.get("/{outfit_id}/wear-history", response_model=Dict[str, Any])
async def get_wear_history(
    outfit_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Get wear history for an outfit."""
    try:
        outfit_id_str = str(outfit_id)

        # Verify outfit exists and belongs to user
        outfit = await asyncio.to_thread(
            db.table("outfits")
            .select("id")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        # Get wear history
        try:
            history = await asyncio.to_thread(
                db.table("outfit_wear_history")
                .select("*")
                .eq("outfit_id", outfit_id_str)
                .order("worn_at", desc=True)
                .limit(100)
                .execute
            )
            wear_history = history.data or []
        except Exception as e:
            # Table might not exist yet
            logger.warning("Failed to fetch wear history", outfit_id=outfit_id_str, error=str(e))
            wear_history = []

        return {
            "data": {
                "wear_history": wear_history
            },
            "message": "OK"
        }
    except OutfitNotFoundError:
        raise
    except Exception as e:
        logger.error("Get wear history error", outfit_id=str(outfit_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch wear history", operation="select")


@router.post("/{outfit_id}/duplicate", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def duplicate_outfit(
    outfit_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        existing = await asyncio.to_thread(
            db.table("outfits")
            .select("*")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
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
        res = await asyncio.to_thread(db.table("outfits").insert(insert).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        outfit = await asyncio.to_thread(
            db.table("outfits")
            .select("id,item_ids")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        item_id = request.item_id
        item = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id).eq("user_id", user_id).single().execute)
        if not item.data:
            raise ItemNotFoundError(item_id=item_id)

        item_ids = list(outfit.data.get("item_ids") or [])
        if item_id in item_ids:
            current = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
            if current:
                # Private buckets: materialize fresh presigned URLs at read time.
                current = (await materialize_parent_images([current]))[0]
            return {"data": current or {"id": outfit_id_str, "item_ids": item_ids, "images": []}, "message": "OK"}
        item_ids.append(item_id)

        now = _now()
        res = await asyncio.to_thread(db.table("outfits").update({"item_ids": item_ids, "updated_at": now}).eq("id", outfit_id_str).eq("user_id", user_id).execute)
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")
        updated = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not updated:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        # Private buckets: materialize fresh presigned URLs at read time.
        updated = (await materialize_parent_images([updated]))[0]
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        outfit_id_str = str(outfit_id)
        item_id_str = str(item_id)
        outfit = await asyncio.to_thread(
            db.table("outfits")
            .select("id,item_ids")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        item_ids = [str(i) for i in (outfit.data.get("item_ids") or [])]
        if item_id_str not in item_ids:
            current = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
            if current:
                # Private buckets: materialize fresh presigned URLs at read time.
                current = (await materialize_parent_images([current]))[0]
            return {"data": current or {"id": outfit_id_str, "item_ids": item_ids, "images": []}, "message": "OK"}

        new_item_ids = [i for i in item_ids if i != item_id_str]
        if not new_item_ids:
            raise ValidationError(
                "Outfit must contain at least one item",
                details={"outfit_id": outfit_id_str}
            )

        now = _now()
        res = await asyncio.to_thread(db.table("outfits").update({"item_ids": new_item_ids, "updated_at": now}).eq("id", outfit_id_str).eq("user_id", user_id).execute)
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update outfit", operation="update")
        updated = _fetch_outfit(db=db, user_id=user_id, outfit_id=outfit_id_str)
        if not updated:
            raise DatabaseError("Failed to fetch updated outfit", operation="select")
        # Private buckets: materialize fresh presigned URLs at read time.
        updated = (await materialize_parent_images([updated]))[0]
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Create a generation record and return a generation_id.

    The frontend performs generation via the backend AI service and then uploads the
    resulting image(s) to `/outfits/{outfit_id}/images` including the returned
    generation_id to mark completion.
    """
    try:
        outfit_id_str = str(outfit_id)
        outfit = await asyncio.to_thread(db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute)
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
        await asyncio.to_thread(db.table("outfit_generations").insert(insert).execute)

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        generation_id_str = str(generation_id)
        result = await asyncio.to_thread(
            db.table("outfit_generations")
            .select("*")
            .eq("id", generation_id_str)
            .eq("user_id", user_id)
            .single()
            .execute
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Upload an outfit image and create an outfit_images record."""
    try:
        outfit_id_str = str(outfit_id)
        outfit = await asyncio.to_thread(db.table("outfits").select("id").eq("id", outfit_id_str).eq("user_id", user_id).single().execute)
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError()

        file_bytes = await read_upload_capped(file, MAX_FILE_SIZE)
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

        # Insert new image first, then clear is_primary on other images
        # This minimizes the race window where no primary exists
        insert_result = await asyncio.to_thread(db.table("outfit_images").insert(img_row).execute)
        new_image_id = insert_result.data[0]["id"] if insert_result.data else None

        if is_primary and new_image_id:
            # Clear is_primary on all OTHER images for this outfit
            await asyncio.to_thread(db.table("outfit_images").update({"is_primary": False}).eq("outfit_id", outfit_id_str).neq("id", new_image_id).execute)

        # Mark generation complete if provided
        if generation_id:
            await asyncio.to_thread(db.table("outfit_generations").update(
                {
                    "status": GenerationStatus.COMPLETED.value,
                    "progress": 100,
                    "image_urls": [img_row["image_url"]],
                    "completed_at": now,
                }
            ).eq("id", generation_id).eq("user_id", user_id).execute)

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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Delete an outfit image and best-effort remove it from storage."""
    try:
        outfit_id_str = str(outfit_id)
        image_id_str = str(image_id)

        outfit = await execute_with_reconnect(
            lambda d: d.table("outfits")
            .select("id")
            .eq("id", outfit_id_str)
            .eq("user_id", user_id)
            .single()
            .execute(),
            db,
            extra={"operation": "delete_outfit_image.load_outfit", "outfit_id": outfit_id_str},
        )
        if not outfit.data:
            raise OutfitNotFoundError(outfit_id=outfit_id_str)

        img = await execute_with_reconnect(
            lambda d: d.table("outfit_images")
            .select("id, storage_path")
            .eq("id", image_id_str)
            .eq("outfit_id", outfit_id_str)
            .single()
            .execute(),
            db,
            extra={"operation": "delete_outfit_image.load_image", "outfit_id": outfit_id_str, "image_id": image_id_str},
        )
        if not img.data:
            raise ImageNotFoundError(image_id=image_id_str)

        storage_path = img.data.get("storage_path")
        if storage_path:
            try:
                await StorageService.delete_image(db=db, storage_path=storage_path)
            except Exception as e:
                logger.warning("Failed to delete outfit image from storage", storage_path=storage_path, error=str(e))

        # Idempotent delete (see delete_outfit): heal a dead pooled
        # Supabase connection with one rebuild + retry instead of a 500.
        await execute_with_reconnect(
            lambda d: d.table("outfit_images")
            .delete()
            .eq("id", image_id_str)
            .eq("outfit_id", outfit_id_str)
            .execute(),
            db,
            extra={"operation": "delete_outfit_image.delete", "outfit_id": outfit_id_str, "image_id": image_id_str},
        )
        return {"data": {"deleted": True}, "message": "OK"}
    except (OutfitNotFoundError, ImageNotFoundError):
        raise
    except Exception as e:
        logger.error("Delete outfit image error", outfit_id=str(outfit_id), image_id=str(image_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete outfit image", operation="delete")


@router.get("/stats", response_model=Dict[str, Any])
async def get_outfit_stats(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Compute outfit statistics for analytics/dashboard."""
    try:
        outfits = (
            (await asyncio.to_thread(db.table("outfits")
            .select("id,name,style,season,worn_count,created_at")
            .eq("user_id", user_id)
            .execute))
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Batch delete outfits and best-effort remove their images from storage."""
    outfit_ids = list(dict.fromkeys([i for i in request.outfit_ids if i]))
    if not outfit_ids:
        raise ValidationError("outfit_ids is required", details={"field": "outfit_ids"})

    try:
        # Resolve owned parent rows before reading child image paths. This API
        # uses the service-role client, so the child query must not trust
        # outfit_id alone for authorization.
        owned = await StorageService.resolve_owned_storage_paths(
            db, user_id, outfit_ids=outfit_ids
        )
        storage_paths = owned["storage_paths"]
        if storage_paths:
            try:
                await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
            except Exception as e:
                # object_count, not image_count: storage_paths includes the
                # derived _thumb siblings, so this is ~2x the image count.
                logger.warning("Failed to delete outfit images from storage", object_count=len(storage_paths), error=str(e))

        delete_res = await asyncio.to_thread(db.table("outfits").delete().eq("user_id", user_id).in_("id", outfit_ids).execute)
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
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = await asyncio.to_thread(
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .not_.is_("last_worn_at", "null")
            .order("last_worn_at", desc=True)
            .limit(limit)
            .execute
        )
        outfits = [_normalize_outfit_images(o) for o in (res.data or [])]
        # Private buckets: materialize fresh presigned URLs at read time.
        outfits = await materialize_parent_images(outfits)
        return {"data": {"outfits": outfits}, "message": "OK"}
    except Exception as e:
        logger.error("Recently worn outfits error", user_id=user_id, limit=limit, error=str(e))
        raise DatabaseError("Failed to fetch recently worn outfits", operation="select")


@router.get("/favorites", response_model=Dict[str, Any])
async def favorites(
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        res = await asyncio.to_thread(
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .eq("is_favorite", True)
            .order("updated_at", desc=True)
            .limit(100)
            .execute
        )
        outfits = [_normalize_outfit_images(o) for o in (res.data or [])]
        # Private buckets: materialize fresh presigned URLs at read time.
        outfits = await materialize_parent_images(outfits)
        return {"data": {"outfits": outfits}, "message": "OK"}
    except Exception as e:
        logger.error("Favorite outfits error", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch favorite outfits", operation="select")


@router.get("/suggestions/weather", response_model=Dict[str, Any])
async def weather_suggestions(
    temperature: float = Query(..., description="Current temperature in Celsius"),
    weather_condition: Optional[str] = Query(None),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Return simple outfit suggestions based on temperature and seasonal tags."""
    try:
        season = "all-season"
        if temperature < 5:
            season = "winter"
        elif temperature > 25:
            season = "summer"

        outfits_res = await asyncio.to_thread(
            db.table("outfits")
            .select("*, outfit_images(*)")
            .eq("user_id", user_id)
            .order("updated_at", desc=True)
            .limit(50)
            .execute
        )
        outfits = outfits_res.data or []
        outfits = [_normalize_outfit_images(o) for o in outfits]
        # Private buckets: materialize fresh presigned URLs at read time.
        outfits = await materialize_parent_images(outfits)

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
