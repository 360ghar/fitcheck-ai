"""
Health API routes.

Pure liveness probe for the hosting platform (Railway) plus the
/api/v1/health compatibility alias. Both must stay cheap and free of
DB/network I/O; schema/DB readiness lives on GET /ready in app.main.
"""

from fastapi import APIRouter

from app.core.config import settings

router = APIRouter()


@router.get("/health")
async def health_check():
    """Liveness probe for the hosting platform (Railway).

    Must stay cheap and free of DB/network I/O. Platform probes poll this
    path; any blocking work here can delay restarts or mark the deploy
    unhealthy while the process is still fine. Schema/DB readiness lives
    on GET /ready instead.
    """
    from app.utils.process_metrics import get_rss_mb

    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "commit": settings.RAILWAY_GIT_COMMIT_SHA,
        "rss_mb": get_rss_mb(),
    }


@router.get("/api/v1/health")
async def health_check_api_v1():
    """Compatibility alias for probes configured against /api/v1/health.

    The canonical liveness endpoint is /health. Probes pointed at
    /api/v1/health produced 404 noise (observed 2026-08-07); serve the same
    cheap payload instead. Operators should still fix the probe path - this
    only makes a misconfiguration harmless.
    """
    return await health_check()
