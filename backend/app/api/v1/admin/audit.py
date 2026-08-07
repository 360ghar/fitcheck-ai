"""
Admin audit trail explorer: filtered list + per-entity history.
"""

from typing import Any, Dict, List, Literal, Optional
from datetime import datetime

from fastapi import APIRouter, Depends, Query
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import AdminAuditEventItem, PageResponse
from app.services.admin_service import entity_audit_events, list_audit_events

router = APIRouter()


@router.get("/audit", response_model=PageResponse[AdminAuditEventItem])
async def list_admin_audit(
    actor_id: Optional[str] = Query(None),
    action: Optional[str] = Query(None, min_length=1, max_length=100),
    entity_type: Optional[str] = Query(None, min_length=1, max_length=100),
    entity_id: Optional[str] = Query(None),
    created_from: Optional[datetime] = Query(None, alias="from"),
    created_to: Optional[datetime] = Query(None, alias="to"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_dir: Literal["asc", "desc"] = Query("desc"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("audit.read")),
) -> PageResponse[AdminAuditEventItem]:
    """Paginated audit trail with filters + actor email join."""
    result = await list_audit_events(
        db,
        actor_id=actor_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        created_from=created_from.isoformat() if created_from else None,
        created_to=created_to.isoformat() if created_to else None,
        page=page,
        page_size=page_size,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminAuditEventItem](
        items=[AdminAuditEventItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.get("/audit/entity/{entity_type}/{entity_id}", response_model=List[AdminAuditEventItem])
async def admin_entity_audit(
    entity_type: str,
    entity_id: str,
    limit: int = Query(100, ge=1, le=500),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("audit.read")),
) -> List[AdminAuditEventItem]:
    """Full audit history for one entity (e.g. a user or subscription)."""
    rows = await entity_audit_events(db, entity_type, entity_id, limit=limit)
    return [AdminAuditEventItem(**row) for row in rows]
