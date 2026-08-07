"""
Admin promo codes: list + create + edit (audited mutations).
"""

from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import (
    AdminPromoCodeCreate,
    AdminPromoCodeUpdate,
    PageResponse,
)
from app.services.admin_service import (
    create_promo_code,
    list_promo_codes,
    update_promo_code,
)
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/promo-codes", response_model=PageResponse[Dict[str, Any]])
async def list_admin_promo_codes(
    q: Optional[str] = Query(None, min_length=1, max_length=100),
    active: Optional[bool] = Query(None),
    plan_type: Optional[str] = Query(None, min_length=1, max_length=20),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_dir: str = Query("desc", pattern="^(asc|desc)$"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("promo.read")),
) -> PageResponse[Dict[str, Any]]:
    """Paginated promo codes with redemption counts."""
    result = await list_promo_codes(
        db,
        q=q,
        active=active,
        plan_type=plan_type,
        page=page,
        page_size=page_size,
        sort_dir=sort_dir,
    )
    return PageResponse[Dict[str, Any]](**result)


@router.post("/promo-codes", response_model=Dict[str, Any], status_code=201)
async def create_admin_promo_code(
    body: AdminPromoCodeCreate,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("content.write")),
) -> Dict[str, Any]:
    """Create a promo code (validates format + duplicates). Audit: promo.created."""
    created = await create_promo_code(db, body.model_dump(exclude_unset=True))
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="promo.created",
        entity_type="promo_code",
        entity_id=created.get("id"),
        payload={
            "code": created.get("code"),
            "plan_type": created.get("plan_type"),
            "months": created.get("months"),
            "max_uses": created.get("max_uses"),
        },
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return created


@router.patch("/promo-codes/{code_id}", response_model=Dict[str, Any])
async def update_admin_promo_code(
    code_id: str,
    body: AdminPromoCodeUpdate,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("content.write")),
) -> Dict[str, Any]:
    """Activate/deactivate + edit-safe subset of a promo code. Audit: promo.updated."""
    result = await update_promo_code(db, code_id, body.model_dump(exclude_unset=True))
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="promo.updated",
        entity_type="promo_code",
        entity_id=code_id,
        payload={"before": result["before"], "after": result["after"]},
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result["after"]
