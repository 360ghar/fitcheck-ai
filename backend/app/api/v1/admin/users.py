"""
Admin users: list/search, detail, role/suspend edits, activity.
"""

from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import (
    AdminUserActivity,
    AdminUserDetail,
    AdminUserListItem,
    AdminUserPatch,
    PageResponse,
)
from app.services.admin_service import get_user_detail, list_users, update_user, user_activity
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/users", response_model=PageResponse[AdminUserListItem])
async def list_admin_users(
    q: Optional[str] = Query(None, min_length=1, max_length=200),
    status: Optional[Literal["active", "suspended"]] = Query(None),
    role: Optional[str] = Query(None, min_length=1, max_length=50),
    plan: Optional[str] = Query(None, min_length=1, max_length=20),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: Literal["created_at", "last_login_at", "email", "full_name"] = Query("created_at"),
    sort_dir: Literal["asc", "desc"] = Query("desc"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("users.read")),
) -> PageResponse[AdminUserListItem]:
    """Paginated user list with subscription plan + outfits/items counts."""
    result = await list_users(
        db,
        q=q,
        status=status,
        role=role,
        plan=plan,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminUserListItem](
        items=[AdminUserListItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.get("/users/{user_id}", response_model=AdminUserDetail)
async def admin_user_detail(
    user_id: str,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("users.read")),
) -> AdminUserDetail:
    """Full user detail: profile + subscription + usage + counts + recent jobs."""
    result = await get_user_detail(db, user_id)
    return AdminUserDetail(**result)


@router.patch("/users/{user_id}", response_model=Dict[str, Any])
async def admin_user_patch(
    user_id: str,
    body: AdminUserPatch,
    http_request: Request,
    actor: Dict[str, Any] = Depends(require_permission("users.write")),
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """Edit role / is_admin / is_active with self-demotion + last-admin guards.

    Role changes and status changes are audit-logged per field.
    """
    result = await update_user(
        db,
        actor=actor,
        user_id=user_id,
        is_admin=body.is_admin,
        role=body.role,
        is_active=body.is_active,
    )
    for change in result["changes"]:
        await record_audit(
            db,
            actor_id=actor.get("id"),
            action=change["action"],
            entity_type="user",
            entity_id=user_id,
            payload={
                "field": change["field"],
                "before": change["before"],
                "after": change["after"],
            },
            ip=http_request.client.host if http_request.client else None,
            user_agent=http_request.headers.get("user-agent"),
        )
    return {"user": result["user"], "changes": result["changes"]}


@router.get("/users/{user_id}/activity", response_model=AdminUserActivity)
async def admin_user_activity(
    user_id: str,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("users.read")),
) -> AdminUserActivity:
    """Recent audit events + recent jobs for one user (limit 25 each)."""
    result = await user_activity(db, user_id)
    return AdminUserActivity(**result)
