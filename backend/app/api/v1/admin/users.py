"""
Admin users: list/search, detail, role/suspend edits, activity.
"""

from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, Query, Request
from pydantic import BaseModel, Field
from supabase import Client

from app.api.v1.deps import get_current_user, get_db, require_permission
from app.core.exceptions import PermissionDeniedError
from app.core.permissions import has_permission
from app.models.admin import (
    AdminUserActivity,
    AdminUserDetail,
    AdminUserListItem,
    AdminUserPatch,
    PageResponse,
)
from app.services.admin_service import (
    clear_daily_ai_counters,
    extend_user_trial,
    get_user_detail,
    list_users,
    update_user,
    user_activity,
)
from app.services.audit_service import record_audit


class ExtendTrialRequest(BaseModel):
    """POST /admin/users/{id}/subscription/extend-trial body."""

    days: int = Field(..., ge=1, le=90, description="Days to extend trial (1..90)")


def _require_either(*permissions: str):
    """Dependency: require any of the listed permissions (OR).

    Used for the extend-trial endpoint where the spec allows either
    ``subscriptions.write`` or ``users.write`` (the latter is the existing
    users.write holder set: support/ops/admin). Falls back to 403 if none
    match, mirroring ``require_permission``.
    """

    async def _dep(user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
        if not any(has_permission(user, perm) for perm in permissions):
            raise PermissionDeniedError(f"Permission required: {' or '.join(permissions)}")
        return user

    return _dep

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


@router.post("/users/{user_id}/subscription/extend-trial", response_model=Dict[str, Any])
async def admin_extend_trial(
    user_id: str,
    body: ExtendTrialRequest,
    http_request: Request,
    actor: Dict[str, Any] = Depends(_require_either("subscriptions.write", "users.write")),
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """Extend a user's trial by ``days`` (1..90).

    If ``subscriptions.trial_end`` is set it is moved forward; otherwise
    ``now + days`` becomes the new trial end. Writes audit
    ``user.trial_extended`` with ``{days, before, after}`` and
    invalidates the cached profile (service helper).
    """
    result = await extend_user_trial(db, user_id, days=body.days)
    await record_audit(
        db,
        actor_id=actor.get("id"),
        action="user.trial_extended",
        entity_type="user",
        entity_id=user_id,
        payload={"days": body.days, "before": result.get("before"), "after": result.get("after")},
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result


@router.post("/users/{user_id}/ai/clear-daily", response_model=Dict[str, Any])
async def admin_clear_daily(
    user_id: str,
    http_request: Request,
    actor: Dict[str, Any] = Depends(require_permission("users.write")),
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """Reset a user's daily AI counters (extractions/generations/embeddings + photoshoot).

    Sets ``user_ai_settings.daily_*_count`` to 0 and ``last_reset_date`` to
    today, plus ``subscription_usage.daily_photoshoot_images`` to 0 for the
    active monthly usage period. Writes audit ``user.ai_daily_cleared`` and invalidates
    the cached profile.
    """
    result = await clear_daily_ai_counters(db, user_id)
    await record_audit(
        db,
        actor_id=actor.get("id"),
        action="user.ai_daily_cleared",
        entity_type="user",
        entity_id=user_id,
        payload={"today": result.get("today")},
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result
