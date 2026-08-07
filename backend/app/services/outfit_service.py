"""
Outfit domain service: persistence orchestration for outfit lifecycle.

Keeps routes thin per the repo rule "routes thin, logic in services"
(ARCHITECTURE.md / CLAUDE.md). Delete orchestration lives here: an
ownership-scoped row delete plus best-effort cleanup of the outfit's owned
image storage paths. Storage failures are logged, never fatal — the DB row
is the source of truth and the delete is idempotent.
"""

from typing import Any, List

from app.core.exceptions import OutfitNotFoundError
from app.core.logging_config import get_context_logger
from app.services.storage_service import StorageService
from app.utils.db import execute_with_reconnect

logger = get_context_logger(__name__)


async def delete_outfit(db: Any, *, user_id: str, outfit_id: str) -> None:
    """Delete a user's outfit and best-effort remove its images from storage.

    Ownership is enforced by scoping every query to ``user_id`` (the caller
    uses a service-role client with RLS bypassed, so ``outfit_id`` alone must
    not be trusted). Raises ``OutfitNotFoundError`` when no owned row exists;
    the route maps it to 404.

    Storage paths are resolved BEFORE the row is deleted: deleting the row
    first leaks the objects forever (measured: 296 orphans / 192MB in the
    bucket). Path resolution and deletion are best-effort — a failure is
    logged with context and never fails the request.
    """
    outfit_id_str = str(outfit_id)
    existing = await execute_with_reconnect(
        lambda d: d.table("outfits")
        .select("id")
        .eq("id", outfit_id_str)
        .eq("user_id", user_id)
        .single()
        .execute(),
        db,
        extra={"operation": "delete_outfit.load", "outfit_id": outfit_id_str},
    )
    if not existing.data:
        raise OutfitNotFoundError(outfit_id=outfit_id_str)

    # Collect owned outfit-image storage paths (with _thumb siblings)
    # BEFORE the row is gone; deleting the row without this leaks the
    # objects forever (measured: 296 orphans / 192MB in the bucket).
    storage_paths: List[str] = []
    try:
        owned = await StorageService.resolve_owned_storage_paths(
            db, user_id, outfit_ids=[outfit_id_str]
        )
        storage_paths = owned["storage_paths"]
    except Exception as e:
        logger.warning(
            "Failed to resolve storage paths for outfit delete",
            outfit_id=outfit_id_str,
            error=str(e),
        )

    # Idempotent delete: a retry after a lost response is a no-op, so a
    # dead pooled Supabase connection is healed by one rebuild + retry
    # instead of surfacing a 500 (observed 2026-08-07: DELETE /outfits
    # failed with DATABASE_ERROR in a gateway-blip window; the library
    # only retries GET/HEAD, never DELETE).
    await execute_with_reconnect(
        lambda d: d.table("outfits")
        .delete()
        .eq("id", outfit_id_str)
        .eq("user_id", user_id)
        .execute(),
        db,
        extra={"operation": "delete_outfit.delete", "outfit_id": outfit_id_str},
    )

    if storage_paths:
        try:
            await StorageService.delete_multiple_images(db=db, storage_paths=storage_paths)
        except Exception as e:
            logger.warning(
                "Failed to delete outfit images from storage",
                outfit_id=outfit_id_str,
                object_count=len(storage_paths),
                error=str(e),
            )
