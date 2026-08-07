"""
Admin settings: GET /admin/settings.

Read-only deployment info for the settings page. Strict whitelist — never
exposes keys, tokens or customer data (see admin_service.deployment_settings).
"""

from typing import Any, Dict

from fastapi import APIRouter, Depends

from app.api.v1.deps import require_admin
from app.models.admin import AdminSettingsResponse
from app.services.admin_service import deployment_settings

router = APIRouter()


@router.get("/settings", response_model=AdminSettingsResponse)
async def admin_settings(user: Dict[str, Any] = Depends(require_admin)) -> AdminSettingsResponse:
    """Return safe deployment info: version, env, feature toggles, billing flags."""
    return AdminSettingsResponse(**deployment_settings())
