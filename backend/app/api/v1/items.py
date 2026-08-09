"""
Items API routes.

Implements wardrobe item CRUD + image upload.
AI item extraction is performed server-side via the AI provider service, while the backend
stores items/images and maintains embeddings for recommendations.
"""

import asyncio
import json
import uuid
from app.utils.datetime_util import utc_today, utcnow_iso
from datetime import date
from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, Query, UploadFile, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from supabase import Client

from app.core.logging_config import get_context_logger
from app.core.storage_keys import is_preview_key
from app.core.exceptions import (
    AIServiceError,
    ItemNotFoundError,
    ImageNotFoundError,
    ValidationError,
    FileTooLargeError,
    StorageServiceError,
    DatabaseError,
    SchemaNotInitializedError,
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
from app.utils.db import (
    execute_with_reconnect,
    escape_ilike_literal,
    is_pgrst202_missing_rpc,
    items_schema_migration_hint,
    jsonb_contains,
    safe_search_term,
)
from app.utils.parallel import parallel_with_retry
from app.api.v1.images import _is_owned_by_user, materialize_parent_images

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


def _is_unique_violation(error: Exception) -> bool:
    """True when a postgrest error reports a unique-constraint violation (23505)."""
    error_info = getattr(error, "json", lambda: {})() or {}
    code = error_info.get("code") or getattr(error, "code", None)
    if code == "23505":
        return True
    text = str(error).lower()
    return "duplicate key" in text or "unique constraint" in text


async def _find_item_by_client_request_id(
    db: Client, user_id: str, client_request_id: str
) -> Optional[Dict[str, Any]]:
    """Fetch the caller's non-deleted item created with an idempotency key.

    Returns the item with the same ``images`` shape a fresh create returns
    (row + ``item_images`` normalized to ``images``). ``None`` when no replay
    target exists — the create proceeds normally.
    """
    result = await execute_with_reconnect(
        lambda d: (
            d.table("items")
            .select("*, item_images(*)")
            .eq("user_id", user_id)
            .eq("client_request_id", client_request_id)
            .eq("is_deleted", False)
            .maybe_single()
            .execute()
        ),
        db,
        extra={"operation": "create_item.replay_lookup", "user_id": user_id},
        max_retries=1,
    )
    if not result or not result.data:
        return None
    return _normalize_item_images(result.data)


async def _normalize_create_image_row(img, db, user_id: str) -> Dict[str, Any]:
    """Normalize a client-supplied image reference into a durable DB row.

    Clients historically stored the AI pipeline's SHORT-LIVED presigned URL as
    ``image_url`` with a NULL ``storage_path`` (the web batch save's
    "remote studio photo already persisted" branch); read paths can only
    re-mint from the durable key, so the tile 403'd at TTL with no recovery —
    the 2026-08-09 closet-image RCA follow-up. Every image reference is
    therefore normalized here:

    - preview key owned by the caller (``tmp/...``, ``generated/...``, legacy
      ``{user}/tmp/...``) -> promoted to a canonical ``{user}/items/...``
      object (server-side copy, see ``promote_temp_image_to_item``) and fresh
      URLs minted, so the reference survives the weekly temp cleanup;
    - canonical key owned by the caller -> kept, URLs left as supplied (they
      were minted at upload time);
    - no ``storage_path`` but ``image_url`` reduces to a key -> the key is
      derived (same rule as ``materialize_image_urls``) and promoted/stored,
      or rejected with a 400 when it is not owned by the caller;
    - a key that is NOT owned by the caller (explicit ``storage_path`` or
      derived from ``image_url``) -> 400: persisting it would make
      every read path re-mint fresh presigned URLs for another user's object;
    - anything else (external/junk URL, e.g. an OAuth picture) -> legacy
      passthrough unchanged (no key to promote or re-mint from).

    Returns the row dict to insert (``image_url``/``thumbnail_url``/
    ``storage_path`` plus id/item_id/is_primary/width/height/created_at are
    added by the caller).
    """
    storage_path = getattr(img, "storage_path", None)
    image_url = getattr(img, "image_url", None) or ""
    thumbnail_url = getattr(img, "thumbnail_url", None)

    if not storage_path:
        derived = StorageService.key_from_path(image_url)
        if derived:
            # With key_from_path now returning None for true external URLs,
            # "derived" reliably means the URL embeds one of our key shapes —
            # so an unowned derived key must be rejected exactly like an
            # explicit unowned storage_path (persisting it would let every
            # read path re-mint fresh presigned URLs for another user's
            # object).
            if not _is_owned_by_user(derived, user_id):
                raise ValidationError(
                    "image URL must reference the caller's own objects",
                    details={"field": "images.image_url"},
                )
            # The URL embeds the key (a presigned ``/<bucket>/<key>`` URL);
            # use the key as the durable reference and mint fresh URLs.
            storage_path = derived
            image_url = ""
            thumbnail_url = None
    elif not _is_owned_by_user(storage_path, user_id):
        raise ValidationError(
            "image storage_path must reference the caller's own objects",
            details={"field": "images.storage_path"},
        )

    if not storage_path:
        # Nothing we can key or promote (external URL or absent image).
        return {
            "image_url": image_url,
            "thumbnail_url": thumbnail_url,
            "storage_path": None,
        }

    if is_preview_key(storage_path):
        # Preview key (tmp/generated, either layout): promote to a canonical
        # item object so the reference survives the weekly temp cleanup.
        promoted = await StorageService.promote_temp_image_to_item(
            db=db,
            user_id=user_id,
            temp_storage_path=storage_path,
            filename_hint="generated.png",
        )
        return {
            "image_url": promoted["image_url"],
            "thumbnail_url": promoted["thumbnail_url"],
            "storage_path": promoted["storage_path"],
        }

    # Canonical owned key: fresh URLs for the create response (local signing,
    # no network round trip) so the caller never receives a stale URL.
    fresh_url = await StorageService.get_public_url(storage_path)
    return {
        "image_url": fresh_url,
        "thumbnail_url": fresh_url,
        "storage_path": storage_path,
    }


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
            # Stage under tmp/{user_id}/upload/... instead of a canonical
            # {user_id}/items/... key: this endpoint runs BEFORE any item row
            # exists, so a canonical object would orphan forever if the client
            # never creates the item (abandoned uploads). Preview keys are
            # promoted to canonical item objects by the create flow
            # (promote_temp_image_to_item) and the weekly temp cleanup covers
            # the abandoned ones.
            res = await StorageService.upload_item_image(
                db=db,
                user_id=user_id,
                filename=file.filename or "upload.jpg",
                file_data=file_bytes,
                is_primary=(index == 0),  # First file is primary
                stage=True,
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
            # A rejected file (invalid image bytes, unsupported type, or an
            # oversized body that read_upload_capped rejects before buffering)
            # can never succeed on retry - fail it once instead of burning 3
            # extra decode/upload cycles (observed 2026-08-03: "Uploaded
            # bytes are not a valid image" -> "All 4 attempts failed" per
            # file; an oversized file likewise burns 3 futile attempts).
            # FileTooLargeError subclasses ValidationError, so excluding
            # ValidationError covers both. Transient storage errors still
            # retry.
            should_retry=lambda e: not isinstance(
                e, (UnsupportedMediaTypeError, FileTooLargeError, ValidationError)
            ),
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

        if uploaded:
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

        # Every file failed: a 202 "partial" would lie about the outcome (the
        # upload produced nothing). Return 400 with the envelope's status
        # "failed"; mixed results keep "partial" and all-good keeps
        # "completed", so the status field stays the single source of truth.
        logger.warning(
            "All uploads failed; returning 400",
            user_id=user_id,
            file_count=len(files),
        )
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "data": {
                    "upload_id": str(uuid.uuid4()),
                    "status": "failed",
                    "uploaded_count": 0,
                    "failed_count": len(failed),
                    "images": [],
                },
                "message": "Upload failed",
            },
        )

    except (UnsupportedMediaTypeError, StorageServiceError):
        raise
    except Exception as e:
        logger.error(f"Upload error ({type(e).__name__}): {e}", user_id=user_id, file_count=len(files), error=str(e))
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

        # F1-07: client idempotency. The save flow retries createItem on
        # transport failures (408/429/5xx/network); when the first attempt
        # committed but the response was lost, the retry used to insert a
        # duplicate item (and duplicate promoted image objects). A repeated
        # client_request_id replays the original row — same response shape
        # as a fresh create — instead of inserting again.
        if item.client_request_id:
            existing = await _find_item_by_client_request_id(db, user_id, item.client_request_id)
            if existing:
                logger.info(
                    "Create item replay via client_request_id",
                    user_id=user_id,
                    item_id=existing["id"],
                )
                return {"data": existing, "message": "Created"}

        # A2-01: the client-supplied source photo key is collected verbatim by
        # the delete paths (delete_item / batch_delete / account deletion) and
        # deleted from Storage with no further ownership check. Reject a key
        # the caller does not own at create time, exactly like images do.
        if item.source_image_storage_path and not _is_owned_by_user(
            item.source_image_storage_path, user_id
        ):
            raise ValidationError(
                "source_image_storage_path must reference the caller's own objects",
                details={"field": "source_image_storage_path"},
            )

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
            "client_request_id": item.client_request_id,
            "created_at": now,
            "updated_at": now,
            "is_deleted": False,
        }

        try:
            inserted = await execute_with_reconnect(
                lambda d: d.table("items").insert(item_data).execute(),
                db,
                extra={"operation": "create_item.insert", "user_id": user_id},
                max_retries=1,
            )
        except Exception as e:
            # Two concurrent requests with the SAME client_request_id can both
            # miss the replay lookup above and race to insert; the loser hits
            # the unique index (23505). Replay the winner's row rather than
            # surfacing a 500 the client would retry into the same dead end
            # (F1-07).
            if item.client_request_id and _is_unique_violation(e):
                winner = await _find_item_by_client_request_id(
                    db, user_id, item.client_request_id
                )
                if winner:
                    logger.info(
                        "Create item race collapsed onto client_request_id winner",
                        user_id=user_id,
                        item_id=winner["id"],
                    )
                    return {"data": winner, "message": "Created"}
            raise
        row = (inserted.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create item", operation="insert")

        # From here on the item row exists and every step is individually
        # reversible: image promotion writes storage objects, the image batch
        # insert writes rows, and the embedding upsert is best-effort. On ANY
        # failure the attempt must be rolled back (delete the item row +
        # already-promoted objects, each step logged) so a client retry
        # cannot duplicate the item while the first attempt's partial state
        # (row + orphaned objects) is left behind (A2-04).
        #
        # Only objects THIS request promoted are rollback-eligible: a
        # canonical storage_path passed through untouched points at a
        # pre-existing object the caller owns (e.g. from a previous upload)
        # and must never be deleted by the rollback.
        promoted_storage_paths: List[str] = []
        images: List[Dict[str, Any]] = []
        try:
            # Insert images in a single batch. Each reference is normalized
            # first: preview (tmp/generated) keys are promoted to canonical
            # item objects and URL-only references get their key derived, so a
            # row never stores a short-lived presigned URL as its durable
            # image reference.
            if item.images:
                image_rows = []
                for img in item.images:
                    img_id = str(uuid.uuid4())
                    reference = getattr(img, "storage_path", None)
                    if not reference:
                        reference = StorageService.key_from_path(
                            getattr(img, "image_url", None) or ""
                        )
                    img_row = await _normalize_create_image_row(img, db, user_id)
                    if reference and is_preview_key(reference):
                        promoted_storage_paths.append(img_row.get("storage_path"))
                    img_row.update({
                        "id": img_id,
                        "item_id": item_id,
                        "is_primary": bool(img.is_primary),
                        "width": img.width,
                        "height": img.height,
                        "created_at": now,
                    })
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
        except Exception:
            # Best-effort reverse: delete the item row, then every object this
            # attempt promoted, logging each step so a leftover orphan is
            # recoverable by operators.
            try:
                await asyncio.to_thread(
                    db.table("items")
                    .delete()
                    .eq("id", item_id)
                    .eq("user_id", user_id)
                    .execute
                )
            except Exception as rollback_error:
                logger.error(
                    "Create item rollback: failed to delete item row",
                    item_id=item_id,
                    error=str(rollback_error),
                )
            for storage_path in promoted_storage_paths:
                try:
                    await StorageService.delete_image(db=db, storage_path=storage_path)
                except Exception as rollback_error:
                    logger.warning(
                        "Create item rollback: failed to delete promoted object",
                        item_id=item_id,
                        storage_path=storage_path,
                        error=str(rollback_error),
                    )
            raise

        # Return full item with images
        row["images"] = images
        return {"data": row, "message": "Created"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        # A hosted-schema gap (migrations 019/036 not applied) must never
        # surface as an opaque 500: log the actionable hint (LOGS ONLY,
        # exception type in the message text because Railway's plain-text
        # drain does not render structured `extra` fields) and raise the
        # friendly 503, matching the job-persistence migration-gap policy.
        hint = items_schema_migration_hint(e)
        if hint:
            logger.error(
                f"Create item error ({type(e).__name__}): {hint}",
                user_id=user_id,
                item_name=item.name,
                error=str(e),
            )
            raise SchemaNotInitializedError() from e
        logger.error(
            f"Create item error ({type(e).__name__}): {e}",
            user_id=user_id,
            item_name=item.name,
            error=str(e),
        )
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
    sort_by: Optional[str] = Query(None, description="created_at | name | worn_count"),
    sort_order: Optional[str] = Query("desc", description="asc | desc"),
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    """Browse items with filtering and pagination."""
    try:
        # A10b-02: the app's sort sheet sends sort_by/sort_order; unknown
        # params were silently dropped by FastAPI and every sort rendered as
        # newest-first. Allowlist columns so a bogus value degrades to the
        # default instead of erroring.
        _SORT_COLUMNS = {"created_at", "name", "worn_count"}
        effective_sort_by = sort_by if sort_by in _SORT_COLUMNS else "created_at"
        # isinstance guard: direct-call tests pass the raw Query(...) default,
        # which FastAPI resolves to a string only at request time.
        effective_sort_order = (
            sort_order.lower()
            if isinstance(sort_order, str) and sort_order.lower() in {"asc", "desc"}
            else "desc"
        )
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
        if condition:
            condition_values = [c.strip().lower() for c in condition.split(",") if c.strip()]
            invalid_conditions = [c for c in condition_values if c not in VALID_CONDITIONS]
            if invalid_conditions:
                logger.warning(
                    "Ignoring unknown condition filter values",
                    extra={"condition": condition, "user_id": user_id},
                )
                ignored_filters["condition"] = invalid_conditions
                return _empty_item_page(page, page_size, ignored_filters)

        def _apply_filters(q):
            """Apply every optional filter to a base query builder."""
            if category:
                categories = [c.strip().lower() for c in category.split(",") if c.strip()]
                q = q.in_("category", categories) if len(categories) > 1 else q.eq("category", categories[0])
            if condition:
                condition_values = [c.strip().lower() for c in condition.split(",") if c.strip()]
                q = (
                    q.in_("condition", condition_values)
                    if len(condition_values) > 1
                    else q.eq("condition", condition_values[0])
                )
            if is_favorite is not None:
                q = q.eq("is_favorite", is_favorite)
            if brand:
                q = q.ilike("brand", f"%{brand}%")
            if color:
                # JSONB array contains: jsonb_contains emits a JSON array
                # literal (["red"]) - plain contains(list) would send a
                # Postgres array literal ({red}) and PostgREST answers 22P02
                # "invalid input syntax for type jsonb" (2026-08-07 /items
                # 500 burst). A comma-joined value (multi-select) ORs the
                # containments so an item matching ANY chosen color shows
                # (A10b-12).
                colors = [c.strip().lower() for c in color.split(",") if c.strip()]
                if len(colors) > 1:
                    q = q.or_(
                        ",".join(f"colors.cs.{json.dumps([c])}" for c in colors)
                    )
                elif colors:
                    q = jsonb_contains(q, "colors", [colors[0]])
            if occasion_filter:
                q = jsonb_contains(q, "occasion_tags", [occasion_filter])
            if search:
                # escape_ilike_literal AFTER safe_search_term: a term's own
                # %/_ must match literally, not widen into wildcards (A2-19).
                like = f"%{escape_ilike_literal(safe_search_term(search))}%"
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
                    .order(effective_sort_by, desc=(effective_sort_order == "desc"))
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
        # storage_path at read time (the DB stores keys, not URLs). The owner
        # enables the URL-derivation fallback for legacy rows whose image_url
        # is the only key carrier (see materialize_image_urls).
        items = await materialize_parent_images(items, owner_user_id=user_id)

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
        logger.error(f"List items error ({type(e).__name__}): {e}", user_id=user_id, page=page, error=str(e))
        raise DatabaseError("Failed to fetch items", operation="select")


@router.get("/{item_id:uuid}", response_model=Dict[str, Any])
async def get_item(
    item_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        # maybe_single (not single): postgrest-py's single() RAISES APIError
        # (406/PGRST116) when the query matches zero rows, so the not-found
        # branch below was dead code and a deleted or not-owned item 500'd
        # instead of 404ing (observed 2026-08-09 on GET /items/{id}).
        result = await execute_with_reconnect(
            lambda d: (
                d.table("items")
                .select("*, item_images(*)")
                .eq("id", item_id_str)
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            ),
            db,
            extra={"operation": "get_item", "user_id": user_id, "item_id": item_id_str},
            max_retries=2,
        )
        if not result or not result.data:
            raise ItemNotFoundError(item_id=item_id_str)
        item = _normalize_item_images(result.data)
        # Private buckets: materialize fresh presigned URLs at read time.
        item = (await materialize_parent_images([item], owner_user_id=user_id))[0]
        return {"data": item, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        # Belt-and-suspenders for the single -> maybe_single migration: a
        # missing/not-owned row surfacing as a structured PGRST116 (e.g. a
        # builder drift or a proxy answering 406) must 404, never 500.
        if getattr(e, "code", None) == "PGRST116":
            raise ItemNotFoundError(item_id=item_id_str) from e
        logger.error(f"Get item error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
        # Both writes below go through execute_with_reconnect like the rest of
        # this file: a dead pooled HTTP/2 connection must not turn the update
        # into a permanent 500 until a process restart (A2-11).
        existing = await execute_with_reconnect(
            lambda d: (
                d.table("items")
                .select("id")
                .eq("id", item_id_str)
                .eq("user_id", user_id)
                .maybe_single()
                .execute()
            ),
            db,
            extra={"operation": "update_item.exists", "user_id": user_id, "item_id": item_id_str},
        )
        if not existing or not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update_dict = update.model_dump(exclude_unset=True)
        if not update_dict:
            return await get_item(item_id=item_id, user_id=user_id, db=db)

        if "purchase_date" in update_dict and update_dict["purchase_date"] is not None:
            update_dict["purchase_date"] = update_dict["purchase_date"].date().isoformat()
        update_dict["updated_at"] = _now()

        result = await execute_with_reconnect(
            lambda d: (
                d.table("items")
                .update(update_dict)
                .eq("id", item_id_str)
                .eq("user_id", user_id)
                .execute()
            ),
            db,
            extra={"operation": "update_item.update", "user_id": user_id, "item_id": item_id_str},
        )
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")

        # Refresh item with images
        item_result = await asyncio.to_thread(
            db.table("items")
            .select("*, item_images(*)")
            .eq("id", item_id_str)
            .eq("user_id", user_id)
            .maybe_single()
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
        item = (await materialize_parent_images([item], owner_user_id=user_id))[0]
        return {"data": item, "message": "Updated"}

    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Update item error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
        existing = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).maybe_single().execute)
        if not existing or not existing.data:
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
        logger.error(f"Delete item error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
        existing = await asyncio.to_thread(db.table("items").select("is_favorite").eq("id", item_id_str).eq("user_id", user_id).maybe_single().execute)
        if not existing or not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)
        new_value = not bool(existing.data.get("is_favorite", False))
        result = await asyncio.to_thread(db.table("items").update({"is_favorite": new_value, "updated_at": _now()}).eq("id", item_id_str).eq("user_id", user_id).execute)
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update item", operation="update")
        return {"data": {"id": item_id_str, "is_favorite": new_value}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Toggle favorite error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
        raise DatabaseError("Failed to toggle favorite", operation="update")


@router.post("/{item_id}/wear", response_model=Dict[str, Any])
async def mark_worn(
    item_id: UUID,
    user_id: str = Depends(get_active_user_id),
    db: Client = Depends(get_db),
):
    try:
        item_id_str = str(item_id)
        # Atomic increment via the service-role RPC (migration 044): the old
        # Python read-modify-write lost increments under concurrency (two
        # requests both read N and both wrote N+1). The RPC performs the +1
        # inside one UPDATE under the row lock and returns the updated row
        # (RETURNING *), so the response's count is the true post-increment
        # value with no second read.
        try:
            result = await asyncio.to_thread(
                db.rpc(
                    "increment_item_worn",
                    {"item_uuid": item_id_str, "user_uuid": user_id},
                ).execute
            )
        except Exception as e:
            if not is_pgrst202_missing_rpc(e):
                raise
            # Migration 044 not applied on the hosted DB: fall back to the
            # legacy read-modify-write so the endpoint keeps working during
            # the gap. The lost-increment window only exists until 044 lands
            # (the fallback is deliberately non-atomic, mirroring
            # set_primary_item_image's fallback policy).
            logger.warning(
                "increment_item_worn RPC missing (migration 044 not applied); "
                "falling back to read-modify-write wear increment",
                item_id=item_id_str,
                user_id=user_id,
            )
            existing = await asyncio.to_thread(
                db.table("items")
                .select("usage_times_worn")
                .eq("id", item_id_str)
                .eq("user_id", user_id)
                .maybe_single()
                .execute
            )
            if not existing or not existing.data:
                raise ItemNotFoundError(item_id=item_id_str)
            current = int(existing.data.get("usage_times_worn", 0))
            update = {"usage_times_worn": current + 1, "usage_last_worn": _now(), "updated_at": _now()}
            await asyncio.to_thread(db.table("items").update(update).eq("id", item_id_str).eq("user_id", user_id).execute)
            return {"data": {"id": item_id_str, "usage_times_worn": current + 1}, "message": "OK"}

        row = (getattr(result, "data", None) or [None])[0]
        if not row:
            # The RPC returns zero rows when the item is missing or not owned
            # by the caller.
            raise ItemNotFoundError(item_id=item_id_str)
        # `or 0` also coerces a NULL count (defensive: the column is NOT NULL
        # DEFAULT 0, but an old row may have slipped through) so the response
        # never surfaces a None count.
        new_count = int(row.get("usage_times_worn") or 0)
        return {"data": {"id": item_id_str, "usage_times_worn": new_count}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Mark worn error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
        item = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).maybe_single().execute)
        if not item or not item.data:
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

        # Insert new image first, then flip the primary flag atomically.
        # Insert-then-clear minimizes the window with NO primary; the old
        # second UPDATE (clear is_primary on the other rows) left a window
        # where TWO images were primary, or both stayed set if the process
        # died between the statements. set_primary_item_image (migration 044)
        # flips every flag for the item inside ONE statement/transaction:
        # is_primary = (id = image_uuid). The two-step clear survives only as
        # the fallback for the migration gap (RPC missing -> PGRST202).
        insert_result = await asyncio.to_thread(db.table("item_images").insert(img_row).execute)
        new_image_id = insert_result.data[0]["id"] if insert_result.data else None

        if is_primary and new_image_id:
            try:
                await asyncio.to_thread(
                    db.rpc(
                        "set_primary_item_image",
                        {"item_uuid": item_id_str, "image_uuid": new_image_id},
                    ).execute
                )
            except Exception as e:
                if not is_pgrst202_missing_rpc(e):
                    # A2-04: the image row was already inserted with
                    # is_primary=True — if the RPC fails for any reason other
                    # than the migration gap, clear the flag on the
                    # just-inserted row (best-effort) before raising, so the
                    # item can never be left with two primary images.
                    try:
                        await asyncio.to_thread(
                            db.table("item_images")
                            .update({"is_primary": False})
                            .eq("id", new_image_id)
                            .execute
                        )
                    except Exception:
                        logger.error(
                            "Failed to clear is_primary on inserted image after "
                            "set_primary_item_image failure",
                            item_id=item_id_str,
                            image_id=new_image_id,
                        )
                    raise
                logger.warning(
                    "set_primary_item_image RPC missing (migration 044 not "
                    "applied); falling back to two-step primary clear",
                    item_id=item_id_str,
                    image_id=new_image_id,
                )
                # Clear is_primary on all OTHER images for this item
                await asyncio.to_thread(db.table("item_images").update({"is_primary": False}).eq("item_id", item_id_str).neq("id", new_image_id).execute)

        return {"data": img_row, "message": "Created"}
    except (ItemNotFoundError, ImageNotFoundError, ValidationError, UnsupportedMediaTypeError, StorageServiceError, DatabaseError):
        raise
    except ValueError as e:
        raise ValidationError(str(e), details={"field": "file"})
    except Exception as e:
        logger.error(f"Upload item image error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
            .maybe_single()
            .execute
        )
        if not img or not img.data:
            raise ImageNotFoundError(image_id=image_id_str)

        # Ensure the item belongs to the current user
        item = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).maybe_single().execute)
        if not item or not item.data:
            raise ItemNotFoundError(item_id=item_id_str)

        # Delete the DB row FIRST, then best-effort the storage object (A2-08):
        # the old order deleted the object before the row, so a row-delete
        # failure left a permanently broken tile (row referencing a missing
        # object) with no recovery path. With the row gone first, a storage
        # failure only orphans an object, which the weekly temp/bucket cleanup
        # can reclaim.
        await asyncio.to_thread(db.table("item_images").delete().eq("id", image_id_str).eq("item_id", item_id_str).execute)

        storage_path = img.data.get("storage_path")
        if storage_path:
            try:
                await StorageService.delete_image(db=db, storage_path=storage_path)
            except Exception as e:
                logger.warning("Failed to delete image from storage", storage_path=storage_path, error=str(e))

        return {"data": {"deleted": True}, "message": "OK"}
    except (ItemNotFoundError, ImageNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Delete item image error ({type(e).__name__}): {e}", item_id=str(item_id), image_id=str(image_id), user_id=user_id, error=str(e))
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
        # child query cannot be authorized by item_id alone. This MUST run
        # before the delete: the source photo path lives on the items row
        # itself, which is gone after the delete.
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

        # Delete items FIRST (FK cascade removes item_images), then run the
        # storage/embedding cleanup best-effort (A2-09): the old order deleted
        # objects/embeddings before the DB rows, so a failed DB delete left
        # the rows pointing at already-deleted objects — permanently broken
        # tiles with no recovery. With the rows gone first, a cleanup failure
        # only orphans objects, which bucket cleanup can reclaim.
        delete_res = await asyncio.to_thread(db.table("items").delete().eq("user_id", user_id).in_("id", item_ids).execute)
        deleted_count = len(delete_res.data or [])

        # Storage and vector cleanup are independent; both are best-effort
        # (failures are logged inside, never raised).
        await asyncio.gather(_delete_storage(), _delete_embeddings())

        return {"data": {"deleted_count": deleted_count}, "message": "OK"}
    except (ItemNotFoundError, ValidationError, StorageServiceError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Batch delete items error ({type(e).__name__}): {e}", user_id=user_id, item_count=len(item_ids), error=str(e))
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
        logger.error(f"Item stats error ({type(e).__name__}): {e}", user_id=user_id, error=str(e))
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
        items = await materialize_parent_images(items, owner_user_id=user_id)
        return {"data": {"items": items}, "message": "OK"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Items by category error ({type(e).__name__}): {e}", user_id=user_id, category=cat, error=str(e))
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
        # escape_ilike_literal AFTER safe_search_term: a term's own %/_ must
        # match literally, not widen into wildcards (A2-19).
        like = f"%{escape_ilike_literal(safe_search_term(q))}%"
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
        items = await materialize_parent_images(items, owner_user_id=user_id)
        return {"data": {"items": items}, "message": "OK"}
    except (ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Search items error ({type(e).__name__}): {e}", user_id=user_id, query=q, error=str(e))
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
            .maybe_single()
            .execute
        )
        if not item or not item.data:
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
        logger.error(f"Categorize item error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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
        existing = await asyncio.to_thread(db.table("items").select("id").eq("id", item_id_str).eq("user_id", user_id).maybe_single().execute)
        if not existing or not existing.data:
            raise ItemNotFoundError(item_id=item_id_str)

        update = request.model_dump(exclude_unset=True)
        if "category" in update and update["category"] is not None:
            # Match ItemCreate/ItemUpdate validation (A2-06): an off-list
            # category persists and the item then disappears from
            # category-filtered lists while staying in unfiltered ones.
            category = update["category"].strip().lower()
            if category not in VALID_CATEGORIES:
                raise ValidationError(
                    "Invalid category",
                    details={"valid_categories": VALID_CATEGORIES},
                )
            update["category"] = category
        if "sub_category" in update and update["sub_category"] is not None:
            update["sub_category"] = update["sub_category"]
        # Tag lists go through the same normalization as ItemCreate/ItemUpdate:
        # raw mixed-case values evade the case-sensitive jsonb_contains
        # filters used by list_items (A2-06).
        for list_field in ("colors", "materials", "seasonal_tags", "occasion_tags"):
            if list_field in update and update[list_field] is not None:
                update[list_field] = normalize_tag_list(update[list_field])

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
            .maybe_single()
            .execute
        )
        # Private buckets: materialize fresh presigned URLs at read time.
        item = _normalize_item_images((item.data if item else None) or {})
        item = (await materialize_parent_images([item], owner_user_id=user_id))[0]
        return {"data": item, "message": "Updated"}
    except (ItemNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error(f"Update item categories error ({type(e).__name__}): {e}", item_id=str(item_id), user_id=user_id, error=str(e))
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

        # The slot stays reserved until the whole search flow finishes: a
        # vector-search or detail-fetch failure previously leaked the
        # reservation (the release only ran on the embedding-generation error
        # path), so the finally below releases on EVERY exit (A2-05). The
        # embedding is never persisted by this endpoint, so the slot is
        # released on success too — embedding_stored mirrors the
        # create/update pattern and stays False here.
        embedding_stored = False
        reservation_released = False
        try:
            # Generate embedding for the new item
            try:
                embedding = await AIService.generate_item_embedding(item_data)
            except Exception as e:
                logger.warning(
                    "Failed to generate embedding for duplicate check, falling back to text search",
                    error=str(e),
                    user_id=user_id,
                )
                # Release BEFORE the text fallback search (the slot is not
                # needed there); the finally skips the double release.
                await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)
                reservation_released = True
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

            # Fetch full item details for matches (read-only; rebuild + retry
            # once on a dead pooled connection - the 2026-08-03
            # /items/check-duplicates 500s happened during the same
            # gateway-restart window as the other ConnectionTerminated
            # bursts).
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
            await materialize_parent_images(normalized_items, owner_user_id=user_id)
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
        finally:
            if not embedding_stored and not reservation_released:
                await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)

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
            .maybe_single()
            .execute
        )

        if not item_result or not item_result.data:
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

        # The slot stays reserved until the whole search flow finishes: a
        # vector-search or detail-fetch failure previously leaked the
        # reservation (the release only ran on the embedding-generation error
        # path), so the finally below releases on EVERY exit (A2-05). The
        # embedding is never persisted by this endpoint, so the slot is
        # released on success too.
        embedding_stored = False
        reservation_released = False
        try:
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
                reservation_released = True
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
            await materialize_parent_images(normalized_items, owner_user_id=user_id)
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
        finally:
            if not embedding_stored and not reservation_released:
                await _release_embedding_reservation(user_id, db, reserved_on=reserved_on)

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
        # Search by name similarity and same category. escape_ilike_literal:
        # a name containing %/_ must match literally (A2-19).
        name_pattern = f"%{escape_ilike_literal(request.name)}%"

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
        await materialize_parent_images(rows, owner_user_id=user_id)

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
        logger.error(f"Fallback duplicate check error ({type(e).__name__}): {e}", error=str(e))
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
