"""Item save service: single + batch creation with server-side image attach.

Holds the create-item core moved out of ``app.api.v1.items`` so both the
single ``POST /items`` route and the batch ``POST /items/batch-from-extraction``
route share one implementation (routes stay thin per ARCHITECTURE.md).

Behavioral notes preserved from the route implementation:
- ``client_request_id`` replay (F1-07) and the concurrent-insert 23505 race
  collapse onto the winner.
- Image references are normalized the same way: owned preview keys
  (``tmp/``/``generated/``) are COPIED (not moved) to canonical item objects
  so a rolled-back attempt keeps the staged source alive for the client's
  retry (2026-09-17 NoSuchKey RCA); unowned keys are rejected with 400.
- Any failure after the item row exists rolls the row + promoted objects back
  (A2-04); staged tmp sources are deleted only after commit.
- Embedding generation stays best-effort with quota release.
"""

import uuid
from app.utils.datetime_util import utc_today, utcnow_iso
from datetime import date
from typing import Any, Dict, List, Optional, Tuple

from supabase import Client

from app.core.exceptions import (
    DatabaseError,
    FitCheckException,
    ItemNotFoundError,
    SchemaNotInitializedError,
    StorageServiceError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.core.storage_keys import is_owned_storage_key, is_preview_key, key_from_path
from app.models.item import ItemCreate
from app.models.subscription import OperationType
from app.services.ai_service import AIService
from app.services.ai_settings_service import AISettingsService
from app.services.storage_service import StorageService
from app.services.vector_service import get_vector_service
from app.utils.db import (
    execute_with_reconnect,
    items_schema_migration_hint,
)

logger = get_context_logger(__name__)


async def release_embedding_reservation(
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


def normalize_item_images(item: Dict[str, Any]) -> Dict[str, Any]:
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


def is_unique_violation(error: Exception) -> bool:
    """True when a postgrest error reports a unique-constraint violation (23505)."""
    error_info = getattr(error, "json", lambda: {})() or {}
    code = error_info.get("code") or getattr(error, "code", None)
    if code == "23505":
        return True
    text = str(error).lower()
    return "duplicate key" in text or "unique constraint" in text


async def find_item_by_client_request_id(
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
    return normalize_item_images(result.data)


async def normalize_create_image_row(img, db, user_id: str) -> Dict[str, Any]:
    """Normalize a client-supplied image reference into a durable DB row.

    Clients historically stored the AI pipeline's SHORT-LIVED presigned URL as
    ``image_url`` with a NULL ``storage_path`` (the web batch save's
    "remote studio photo already persisted" branch); read paths can only
    re-mint from the durable key, so the tile 403'd at TTL with no recovery —
    the 2026-08-09 closet-image RCA follow-up. Every image reference is
    therefore normalized here:

    - preview key owned by the caller (``tmp/...``, ``generated/...``, legacy
      ``{user}/tmp/...``) -> promoted to a canonical ``{user}/items/...``
      object (server-side copy, see ``copy_temp_image_to_item``) and fresh
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
        derived = key_from_path(image_url)
        if derived:
            # With key_from_path now returning None for true external URLs,
            # "derived" reliably means the URL embeds one of our key shapes —
            # so an unowned derived key must be rejected exactly like an
            # explicit unowned storage_path (persisting it would let every
            # read path re-mint fresh presigned URLs for another user's
            # object).
            if not is_owned_storage_key(derived, user_id):
                raise ValidationError(
                    "image URL must reference the caller's own objects",
                    details={"field": "images.image_url"},
                )
            # The URL embeds the key (a presigned ``/<bucket>/<key>`` URL);
            # use the key as the durable reference and mint fresh URLs.
            storage_path = derived
            image_url = ""
            thumbnail_url = None
    elif not is_owned_storage_key(storage_path, user_id):
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
        #
        # COPY, not move (2026-09-17 RCA): the staged tmp source must outlive
        # this attempt, because the create is rolled back on any later failure
        # and the caller's retry re-sends the same tmp key. A move deleted the
        # source up front, so the rollback destroyed the only copy and every
        # retry answered "Failed to move image: NoSuchKey" (503). create_item
        # deletes the source itself once its rows have committed.
        promoted = await StorageService.copy_temp_image_to_item(
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


async def cleanup_temp_sources(
    db: Client, paths: List[str], item_id: Optional[str] = None
) -> None:
    """Best-effort delete of staged tmp objects; each distinct path once."""
    for temp_path in dict.fromkeys(paths):
        try:
            await StorageService.delete_image(db=db, storage_path=temp_path)
        except Exception as cleanup_error:
            logger.warning(
                "Create item: failed to clean up promoted temp object",
                item_id=item_id,
                storage_path=temp_path,
                error=str(cleanup_error),
            )


async def create_item_core(
    db: Client,
    user_id: str,
    item: ItemCreate,
    defer_temp_cleanup: Optional[List[str]] = None,
) -> Dict[str, Any]:
    """Create one wardrobe item with its images. Returns the item dict.

    ``defer_temp_cleanup``: when a list is passed, the staged tmp sources this
    create promoted from are appended to it instead of deleted, so the caller
    can delete them once (batch saves share one tmp key across sibling pieces).

    Raises ``FitCheckException`` subclasses (replayed by the routes' error
    handlers); unexpected failures are mapped to ``DatabaseError``, and a
    hosted-schema gap to ``SchemaNotInitializedError`` (friendly 503).
    """
    try:
        item_id = str(uuid.uuid4())
        now = utcnow_iso()

        # F1-07: client idempotency. The save flow retries createItem on
        # transport failures (408/429/5xx/network); when the first attempt
        # committed but the response was lost, the retry used to insert a
        # duplicate item (and duplicate promoted image objects). A repeated
        # client_request_id replays the original row — same response shape
        # as a fresh create — instead of inserting again.
        if item.client_request_id:
            existing = await find_item_by_client_request_id(db, user_id, item.client_request_id)
            if existing:
                logger.info(
                    "Create item replay via client_request_id",
                    user_id=user_id,
                    item_id=existing["id"],
                )
                return existing

        # A2-01: the client-supplied source photo key is collected verbatim by
        # the delete paths (delete_item / batch_delete / account deletion) and
        # deleted from Storage with no further ownership check. Reject a key
        # the caller does not own at create time, exactly like images do.
        if item.source_image_storage_path and not is_owned_storage_key(
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
            # upsert-on-PK, not insert: this call is wrapped in the reconnect
            # retry, and a lost response (server committed, client never saw it)
            # makes the retry re-send the same row. With a plain insert that
            # retry answered ``duplicate key ... items_pkey`` and the request
            # 500ed (2026-09-17 production log); merging on the client-generated
            # id instead replays the committed row, so the retry is exact-once
            # in effect (see the write contract in app/utils/db.py).
            inserted = await execute_with_reconnect(
                lambda d: d.table("items").upsert(item_data, on_conflict="id").execute(),
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
            if item.client_request_id and is_unique_violation(e):
                winner = await find_item_by_client_request_id(
                    db, user_id, item.client_request_id
                )
                if winner:
                    logger.info(
                        "Create item race collapsed onto client_request_id winner",
                        user_id=user_id,
                        item_id=winner["id"],
                    )
                    return winner
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
        #
        # Promotion is a COPY, not a move (2026-09-17 production RCA): the
        # staged ``tmp/...`` source stays in place until this request has
        # committed, so a rollback can undo the canonical object without
        # destroying the only copy. The old move deleted the tmp source up
        # front, so a rolled-back create left the client holding a key that no
        # longer existed anywhere and its retry answered
        # ``Failed to move image: NoSuchKey`` (503) forever.
        promoted_storage_paths: List[str] = []
        temp_source_paths: List[str] = []
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
                        reference = key_from_path(
                            getattr(img, "image_url", None) or ""
                        )
                    img_row = await normalize_create_image_row(img, db, user_id)
                    if reference and is_preview_key(reference):
                        promoted_storage_paths.append(img_row.get("storage_path"))
                        temp_source_paths.append(reference)
                    img_row.update({
                        "id": img_id,
                        "item_id": item_id,
                        "is_primary": bool(img.is_primary),
                        "width": img.width,
                        "height": img.height,
                        "created_at": now,
                    })
                    image_rows.append(img_row)

                # Single batch upsert for all images: these ids are minted here
                # and the call is retried on a dead pooled connection, so a
                # lost response re-sends the same rows. A plain insert then
                # answered ``duplicate key ... item_images_pkey`` (2026-09-17
                # production log); merging on the id replays the committed rows
                # instead (write contract in app/utils/db.py).
                await execute_with_reconnect(
                    lambda d: d.table("item_images").upsert(image_rows, on_conflict="id").execute(),
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
                    await release_embedding_reservation(user_id, db, reserved_on=reserved_on)
        except Exception:
            # Best-effort reverse: delete the item row, then every object this
            # attempt promoted, logging each step so a leftover orphan is
            # recoverable by operators.
            #
            # The staged tmp sources are deliberately NOT deleted here: they are
            # the client's recovery path, because its retry re-sends the same
            # tmp key. Deleting canonical objects only (and keeping the source)
            # is what makes a failed create retryable instead of permanently
            # 503ing on NoSuchKey (2026-09-17 RCA). An abandoned tmp object is
            # covered by the weekly temp cleanup.
            try:
                await execute_with_reconnect(
                    lambda d: d.table("items")
                    .delete()
                    .eq("id", item_id)
                    .eq("user_id", user_id)
                    .execute(),
                    db,
                    extra={"operation": "create_item.rollback_delete", "user_id": user_id},
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

        # Committed: the item row and its image rows are durable, so the staged
        # tmp objects this request promoted from are now redundant. Cleanup runs
        # here, AFTER the rollback-eligible block, so any failure above still
        # leaves the source alive for the client's retry. Best-effort by design:
        # a failed delete only leaves an object the weekly temp cleanup takes.
        if defer_temp_cleanup is not None:
            defer_temp_cleanup.extend(temp_source_paths)
        else:
            await cleanup_temp_sources(db, temp_source_paths, item_id=item_id)

        # Return full item with images
        row["images"] = images
        return row

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


async def batch_create_items(
    db: Client,
    user_id: str,
    entries: List[Tuple[str, ItemCreate]],
) -> Dict[str, List[Dict[str, Any]]]:
    """Create many items in one request. Returns ``{"saved": [...], "failed": [...]}``.

    Items run SEQUENTIALLY: the shared Supabase client's pool has a history of
    races under concurrent use (see BACKEND.md), and one round trip for the
    whole batch is already the dominant win over the client's old
    create+upload+refetch loop. Each entry is isolated: a per-item failure is
    recorded in ``failed`` as ``{"temp_id", "error"}`` and the batch continues.
    ``SchemaNotInitializedError`` (hosted-schema gap) still fails the whole
    request — no per-item retry can clear it.
    """
    saved: List[Dict[str, Any]] = []
    failed: List[Dict[str, Any]] = []
    # Sibling pieces cut from one photo share one staged tmp key: keep it alive
    # until every entry has been tried, then delete it once.
    deferred_tmp: List[str] = []
    try:
        for temp_id, entry in entries:
            try:
                created = await create_item_core(
                    db, user_id, entry, defer_temp_cleanup=deferred_tmp
                )
                saved.append({"temp_id": temp_id, "item": created})
            except SchemaNotInitializedError:
                raise
            except FitCheckException as e:
                logger.warning(
                    "Batch save: item failed",
                    user_id=user_id,
                    temp_id=temp_id,
                    error=e.message,
                )
                failed.append({"temp_id": temp_id, "error": e.message})
            except Exception as e:
                logger.error(
                    f"Batch save: item failed ({type(e).__name__})",
                    user_id=user_id,
                    temp_id=temp_id,
                    error=str(e),
                )
                failed.append({"temp_id": temp_id, "error": "Failed to save this piece."})
    finally:
        await cleanup_temp_sources(db, deferred_tmp)
    return {"saved": saved, "failed": failed}
