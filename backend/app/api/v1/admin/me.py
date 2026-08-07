"""
Admin session bootstrap: GET /admin/me.

Returns the caller's profile plus the role and permission list that drive
the admin UI. UI gating is cosmetic — every other endpoint re-checks the
same role/permission model.
"""

from typing import Any, Dict

from fastapi import APIRouter, Depends

from app.api.v1.deps import require_admin
from app.core.permissions import get_user_role, permissions_for_role
from app.models.admin import AdminMeResponse

router = APIRouter()


@router.get("/me", response_model=AdminMeResponse)
async def admin_me(user: Dict[str, Any] = Depends(require_admin)) -> AdminMeResponse:
    """Return the current admin's profile, role and granted permissions."""
    role = get_user_role(user)
    return AdminMeResponse(
        user=user,
        role=role,
        permissions=permissions_for_role(role),
    )
