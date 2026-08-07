"""
Admin quotas: today's per-user AI usage + per-user daily limit overrides.
"""

from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_admin, require_permission
from app.models.admin import AdminQuotaOverride, AdminQuotaUsageItem, PageResponse
from app.services.admin_service import list_quota_usage, set_quota_override
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/quotas", response_model=PageResponse[AdminQuotaUsageItem])
async def list_admin_quotas(
    q: Optional[str] = Query(None, min_length=1, max_length=200),
    plan: Optional[str] = Query(None, min_length=1, max_length=20),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: Literal["extraction", "generation", "embedding", "user"] = Query("extraction"),
    sort_dir: Literal["asc", "desc"] = Query("desc"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("quotas.read")),
) -> PageResponse[AdminQuotaUsageItem]:
    """Today's AI usage per user (daily counters from user_ai_settings)."""
    result = await list_quota_usage(
        db,
        q=q,
        plan=plan,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminQuotaUsageItem](
        items=[AdminQuotaUsageItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.patch("/users/{user_id}/quota-override", response_model=Dict[str, Any])
async def admin_quota_override(
    user_id: str,
    body: AdminQuotaOverride,
    http_request: Request,
    db: Client = Depends(get_db),
    actor: Dict[str, Any] = Depends(require_admin),
) -> Dict[str, Any]:
    """Set (or clear with null) a per-user daily AI quota override.

    The override lives on ``users.custom_daily_quota`` (migration 037);
    null restores the plan default. Audit: ``quota.override``.
    """
    result = await set_quota_override(db, user_id, body.daily_limit)
    await record_audit(
        db,
        actor_id=actor.get("id"),
        action="quota.override",
        entity_type="user",
        entity_id=user_id,
        payload={"custom_daily_quota": result["custom_daily_quota"]},
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result
