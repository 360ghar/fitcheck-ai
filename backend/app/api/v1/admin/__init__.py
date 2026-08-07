"""
Admin API package (``/api/v1/admin``).

Aggregates the per-domain admin routers. Mounted once in ``app.main``::

    app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])

Every endpoint is behind ``require_admin`` or ``require_permission(...)``
(see ``app.api.v1.deps``); all authorization is backend-enforced.
"""

from fastapi import APIRouter

from app.api.v1.admin import (
    audit,
    dashboards,
    feedback,
    iap,
    me,
    ops,
    promo,
    quotas,
    search,
    settings as settings_routes,
    subscriptions,
    users,
)

router = APIRouter()

router.include_router(me.router)
router.include_router(users.router)
router.include_router(subscriptions.router)
router.include_router(iap.router)
router.include_router(quotas.router)
router.include_router(dashboards.router)
router.include_router(promo.router)
router.include_router(feedback.router)
router.include_router(ops.router)
router.include_router(audit.router)
router.include_router(search.router)
router.include_router(settings_routes.router)
