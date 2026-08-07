"""
Admin ops: health (liveness + schema readiness) and temp-storage cleanup.
"""

import asyncio
from typing import Any, Dict

from fastapi import APIRouter, Depends, Request
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.core.config import settings
from app.core.exceptions import StorageServiceError
from app.models.admin import (
    AdminOpsHealthResponse,
    AdminStorageCleanupResponse,
    AdminStorageResponse,
    AdminStorageTempItem,
)
from app.services.admin_service import (
    TEMP_DELETE_MAX_OBJECTS,
    storage_temp_cleanup,
    storage_temp_inventory,
)
from app.services.audit_service import record_audit

router = APIRouter()


async def _schema_readiness() -> Dict[str, Any]:
    """Schema readiness via main.py's cached check.

    Deferred import: app.main imports this package at startup, so importing
    it here at module scope would be circular. At call time app.main is fully
    loaded, so the import is cheap and safe.
    """
    import app.main as main_module  # noqa: PLC0415 - deferred to break the import cycle

    try:
        schema_ready, missing = await asyncio.to_thread(main_module._get_cached_schema_status)
        return {"schema_ready": schema_ready, "missing_tables": missing}
    except Exception:
        return {"schema_ready": False, "missing_tables": []}


@router.get("/ops/health", response_model=AdminOpsHealthResponse)
async def admin_ops_health(
    user: Dict[str, Any] = Depends(require_permission("ops.read")),
) -> AdminOpsHealthResponse:
    """Liveness (same shape as public /health) + schema readiness check."""
    from app.utils.process_metrics import get_rss_mb  # local import (cheap)

    schema = await _schema_readiness()
    return AdminOpsHealthResponse(
        status="healthy",
        service=settings.PROJECT_NAME,
        version=settings.VERSION,
        commit=settings.RAILWAY_GIT_COMMIT_SHA,
        rss_mb=get_rss_mb(),
        schema_ready=schema.get("schema_ready"),
    )


@router.get("/ops/storage", response_model=AdminStorageResponse)
async def admin_ops_storage(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("ops.read")),
) -> AdminStorageResponse:
    """Bounded inventory of temp preview objects (``{user_id}/tmp/...``).

    The scan is capped (see ``TEMP_SCAN_MAX_PAGES``); ``truncated`` is true
    when the page cap cut the scan short. Only the first 100 items are
    returned for display.
    """
    inventory = await storage_temp_inventory(db)
    display_items = [AdminStorageTempItem(**item) for item in inventory["items"][:100]]
    return AdminStorageResponse(
        bucket=settings.OBJECT_STORAGE_BUCKET,
        scanned_keys=inventory["scanned_keys"],
        count=inventory["count"],
        total_bytes=inventory["total_bytes"],
        oldest=inventory["oldest"],
        newest=inventory["newest"],
        items=display_items,
        truncated=inventory["truncated"],
    )


@router.delete("/ops/storage/temp", response_model=AdminStorageCleanupResponse)
async def admin_ops_storage_cleanup(
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("storage.cleanup")),
) -> AdminStorageCleanupResponse:
    """Delete temp objects up to a per-call safety cap (5,000). Audit logged.

    Deletes the oldest-first subset of the found temp keys, capped by
    ``TEMP_DELETE_MAX_OBJECTS``; ``truncated`` is true when more temp objects
    remain (call again to continue).
    """
    try:
        result = await storage_temp_cleanup(db)
    except Exception as exc:
        raise StorageServiceError(
            message="Storage cleanup failed",
        ) from exc
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="storage.temp_cleaned",
        entity_type="storage",
        entity_id="temp",
        payload={
            "deleted": result["deleted"],
            "bytes_freed": result["bytes_freed"],
            "remaining": result["remaining"],
            "max_objects_per_call": TEMP_DELETE_MAX_OBJECTS,
            "truncated": result["truncated"],
        },
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return AdminStorageCleanupResponse(**result)
