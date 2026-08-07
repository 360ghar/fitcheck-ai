"""
FitCheck AI - Main Application Entry Point
"""

import logging
from datetime import timedelta
from app.utils.datetime_util import utcnow
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse, PlainTextResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.logging_config import setup_session_logging
from app.core.exceptions import FitCheckException
from app.core.middleware import CorrelationIdMiddleware, RequestLoggingMiddleware, get_correlation_id
from app.api.v1 import auth, items, outfits, recommendations, users, calendar, weather, gamification, shared_outfits, ai, ai_settings, waitlist, demo, batch_processing, subscription, iap, referral, feedback, photoshoot, social_import, blog, promo, images, admin, health
from app.db.connection import SupabaseDB
from app.utils.db import missing_quota_rpcs, missing_referral_rpcs, probe_valid_batch_size_bound
from postgrest.exceptions import APIError as PostgrestAPIError

REQUIRED_TABLES = (
    # Core user + wardrobe/outfits
    "users",
    "user_preferences",
    "user_settings",
    "user_ai_settings",
    "items",
    "item_images",
    "outfits",
    "outfit_images",
    "outfit_collections",
    "outfit_collection_items",
    # Wear history (migration 042): POST /outfits/{id}/wear writes it and GET
    # /outfits/{id}/wear-history reads it. Without the table both degrade
    # silently (empty wear history), so readiness fails closed until 042 is
    # applied (same rationale as the webhook ledgers below).
    "outfit_wear_history",
    "body_profiles",
    # Planning + generation tracking (docs-aligned MVP)
    "outfit_generations",
    "calendar_connections",
    "calendar_events",
    # Sharing + feedback
    "shared_outfits",
    "share_feedback",
    # Durable job state (batch/photoshoot mirror rows here; migrations 016/023)
    "extraction_jobs",
    "photoshoot_jobs",
    # Subscription + referral
    "subscriptions",
    "subscription_usage",
    "referral_codes",
    "referral_redemptions",
    # Promo codes (shareable campaign grants)
    "promo_codes",
    "promo_redemptions",
    # Support tickets
    "support_tickets",
    # Store webhook event ledgers: without these tables the App Store / Play /
    # Stripe webhook endpoints fail every delivery (500 on the webhook insert),
    # so readiness fails closed until the migration is applied. stripe_webhook_events
    # comes from migration 027; apple_iap_events / google_rtdn_events from 030.
    "stripe_webhook_events",
    "apple_iap_events",
    "google_rtdn_events",
)

# Only required when ENABLE_GAMIFICATION is on. With the flag off the handlers
# never touch these tables (they return a neutral zeroed payload before any
# query), so demanding them would make /ready fail-closed over a feature that
# is deliberately dark.
GAMIFICATION_TABLES = (
    "user_streaks",
    "user_achievements",
)

SOCIAL_IMPORT_TABLES = (
    "social_import_jobs",
    "social_import_photos",
    "social_import_items",
    "social_import_auth_sessions",
    "social_import_events",
)

REQUIRED_COLUMNS = (
    # Preference profile (recommendations)
    ("user_preferences", "preferred_occasions"),
    # Astrology profile base field (legacy-compatible via REQUIRED_COLUMN_ALTERNATIVES)
    ("users", "birth_date"),
    # Wardrobe enrichment (recommendations/categorization)
    ("items", "material"),
    ("item_images", "storage_path"),
    # Sharing + enhanced outfit metadata
    ("outfits", "is_public"),
    ("outfit_images", "storage_path"),
    ("outfit_collections", "is_favorite"),
    # Photoshoot job failure detail (migration 035): without the column every
    # POST /photoshoot/generate fails with PGRST204 at request time
    # (observed 2026-08-07), so readiness fails closed until 035 is applied.
    ("photoshoot_jobs", "image_failures"),
)

REQUIRED_COLUMN_ALTERNATIVES = {
    # Backward compatibility for environments that still use legacy DOB column.
    ("users", "birth_date"): (("users", "date_of_birth"),),
}


# PostgREST/Postgres codes that genuinely mean "this table or column is not
# in the schema". PGRST204 is the schema-cache lookup failure PostgREST
# returns for a missing column on writes (observed 2026-08-07:
# photoshoot_jobs.image_failures) - a persistent PGRST204 means the column
# is absent, not merely that the cache is stale. Anything else
# (permissions, connectivity, timeouts) is an infrastructure failure
# wearing a schema failure's clothes.
_SCHEMA_ABSENT_CODES = {"PGRST205", "PGRST204", "42703"}


def _column_exists(db, table: str, column: str) -> bool:
    """Report whether a column is present, logging *why* when it is not.

    Both failure paths still return False - readiness stays fail-closed - but
    a permissions or connectivity failure used to be reported to /ready as
    "column missing", which sends whoever is on call after the wrong problem.
    """
    log = logging.getLogger(__name__)
    try:
        db.table(table).select(column).limit(1).execute()
        return True
    except PostgrestAPIError as e:
        if getattr(e, "code", None) in _SCHEMA_ABSENT_CODES:
            log.info("Schema check: %s.%s is absent from the schema", table, column)
        else:
            log.warning(
                "Schema check for %s.%s failed for a non-schema reason "
                "(code=%s): %s. Reporting as missing, but the cause is not a "
                "missing column.",
                table, column, getattr(e, "code", None), e,
            )
        return False
    except Exception as e:
        log.warning(
            "Schema check for %s.%s failed before reaching PostgREST: %s. "
            "Reporting as missing, but the cause is not a missing column.",
            table, column, e,
        )
        return False


def _schema_missing(db) -> list[str]:
    missing: list[str] = []
    required_tables = list(REQUIRED_TABLES)
    if settings.ENABLE_GAMIFICATION:
        required_tables.extend(GAMIFICATION_TABLES)
    if settings.ENABLE_SOCIAL_IMPORT:
        required_tables.extend(SOCIAL_IMPORT_TABLES)

    # Required tables
    log = logging.getLogger(__name__)
    for table in required_tables:
        try:
            db.table(table).select("*").limit(1).execute()
        except PostgrestAPIError as e:
            if getattr(e, "code", None) in _SCHEMA_ABSENT_CODES:
                log.info("Schema check: table %s is absent from the schema", table)
            else:
                log.warning(
                    "Schema check for table %s failed for a non-schema reason "
                    "(code=%s): %s. Reporting as missing, but the cause is not "
                    "a missing table.",
                    table, getattr(e, "code", None), e,
                )
            missing.append(table)
        except Exception as e:
            log.warning(
                "Schema check for table %s failed before reaching PostgREST: "
                "%s. Reporting as missing, but the cause is not a missing table.",
                table, e,
            )
            missing.append(table)

    # Required columns (guarding against partial migrations)
    for table, column in REQUIRED_COLUMNS:
        if _column_exists(db, table, column):
            continue

        alternatives = REQUIRED_COLUMN_ALTERNATIVES.get((table, column), ())
        has_alternative = any(_column_exists(db, alt_table, alt_column) for alt_table, alt_column in alternatives)
        if has_alternative:
            continue

        missing.append(f"{table}.{column}")

    # De-dupe while preserving order
    seen = set()
    deduped: list[str] = []
    for item in missing:
        if item in seen:
            continue
        seen.add(item)
        deduped.append(item)
    return deduped


_SCHEMA_STATUS_CACHE = {"missing": None, "checked_at": None}
_SCHEMA_STATUS_TTL = timedelta(minutes=5)


def _get_cached_schema_status() -> tuple[bool, list[str]]:
    """Schema readiness, refreshed at most every _SCHEMA_STATUS_TTL.

    Used by GET /ready and startup seeding. /health is pure liveness and does
    not call this. Cache avoids re-running ~30-40 sequential table/column
    existence queries on every readiness poll.
    """
    now = utcnow()
    cached_at = _SCHEMA_STATUS_CACHE["checked_at"]
    if cached_at is not None and now - cached_at < _SCHEMA_STATUS_TTL:
        missing = _SCHEMA_STATUS_CACHE["missing"]
        return len(missing) == 0, missing

    try:
        db = SupabaseDB.get_service_client()
        missing = _schema_missing(db)
    except Exception:
        if _SCHEMA_STATUS_CACHE["missing"] is not None:
            # A prior check succeeded - keep serving that rather than
            # flipping to "not ready" on a transient DB hiccup during the
            # health check itself.
            missing = _SCHEMA_STATUS_CACHE["missing"]
        else:
            # No prior successful check to fall back on - fail closed,
            # matching the pre-caching behavior (report not-ready rather
            # than silently reporting healthy when the check itself failed).
            missing = ["schema_check_failed"]

    _SCHEMA_STATUS_CACHE["missing"] = missing
    _SCHEMA_STATUS_CACHE["checked_at"] = now
    return len(missing) == 0, missing


async def _seed_schema_status_in_thread() -> None:
    """Run the expensive schema check off the event loop, then seed the cache.

    Must never be awaited on the critical path before uvicorn accepts
    connections: Railway health probes /health as soon as the port binds.

    Also probes the hosted DB for the quota reservation RPCs (migrations
    022/024/026) and the extraction_jobs.valid_batch_size CHECK bound
    (migrations 023/029) the deployed backend requires. Gaps are logged with
    the runbook hint at boot - the deferred-debt follow-ups from the
    2026-07-31 batch-quota outage and the 2026-08-01 single-extract outage -
    so a migration gap is caught when the deploy lands instead of at request
    time.
    """
    import asyncio

    def _check():
        db = SupabaseDB.get_service_client()
        return (
            _schema_missing(db),
            missing_quota_rpcs(db),
            missing_referral_rpcs(db),
            probe_valid_batch_size_bound(db),
        )

    try:
        missing, missing_rpcs, missing_referral_rpcs_list, (bound_level, bound_message) = await asyncio.to_thread(
            _check
        )
        _SCHEMA_STATUS_CACHE["missing"] = missing
        _SCHEMA_STATUS_CACHE["checked_at"] = utcnow()
        log = logging.getLogger(__name__)
        if missing_rpcs:
            log.error(
                "Quota reservation RPCs missing from hosted Supabase: "
                f"{', '.join(sorted(missing_rpcs))}. Apply migrations "
                "022_wave_b_hardening.sql, 024_atomic_daily_quota_reservations.sql "
                "and 026_harden_rpc_privileges.sql to restore AI admission "
                "(every quota-backed request fails closed until then)."
            )
        if missing_referral_rpcs_list:
            log.error(
                "Referral redemption RPCs missing from hosted Supabase: "
                f"{', '.join(sorted(missing_referral_rpcs_list))}. Apply migrations "
                "022_wave_b_hardening.sql and 026_harden_rpc_privileges.sql to "
                "restore referral grants (every redemption fails silently and "
                "the user + referrer stay on free until then)."
            )
        if bound_level == "critical":
            log.error(f"AI job persistence will fail for every job: {bound_message}")
        elif bound_level == "warn":
            log.warning(f"AI job persistence bound drift: {bound_message}")
        elif bound_level == "missing":
            log.error(f"AI job persistence unavailable: {bound_message}")
        elif bound_level == "unknown":
            log.warning(f"AI job persistence probe inconclusive: {bound_message}")
        else:
            log.info(f"AI job persistence bound check: {bound_message}")
        if missing:
            log.warning(
                "Supabase schema not initialized/complete. Run "
                "`backend/db/supabase/migrations/001_full_schema.sql` in Supabase SQL Editor."
            )
            log.warning(
                f"Missing: {', '.join(missing[:8])}{'…' if len(missing) > 8 else ''}"
            )
        else:
            log.info("Schema readiness check complete (ready)")
    except Exception as e:
        logging.getLogger(__name__).warning(f"Supabase schema check failed: {e}")


async def _init_pinecone_in_thread() -> None:
    """Best-effort Pinecone index init off the event loop."""
    import asyncio

    if not settings.PINECONE_API_KEY:
        return
    try:
        from app.services.vector_service import get_vector_service

        def _init():
            get_vector_service().create_index()

        await asyncio.to_thread(_init)
        logging.getLogger(__name__).info("Pinecone index init complete")
    except Exception as e:
        logging.getLogger(__name__).warning(f"Pinecone index initialization failed: {e}")


async def _background_startup(logger: logging.Logger) -> None:
    """Schema + Pinecone after the server is already accepting traffic.

    Never raises: failures are logged so the create_task caller does not
    leave a "Task exception was never retrieved" on the event loop.
    """
    import asyncio

    try:
        results = await asyncio.gather(
            _seed_schema_status_in_thread(),
            _init_pinecone_in_thread(),
            return_exceptions=True,
        )
        for result in results:
            if isinstance(result, Exception):
                # gather(return_exceptions=True) surfaces step failures if a
                # helper ever stops swallowing them; helpers log themselves today.
                logger.warning(
                    "Background startup step failed: %s: %s",
                    type(result).__name__,
                    result,
                )
        try:
            from app.utils.process_metrics import log_memory
            log_memory("background_startup_complete", force=True)
        except Exception:  # pragma: no cover - best-effort telemetry
            pass
        # One full collection after the import-time + startup churn settles:
        # frees any cyclic garbage the frozen threshold tuning left behind so
        # the steady-state RSS baseline is measured on clean ground.
        try:
            import gc
            gc.collect()
        except Exception:  # pragma: no cover - defensive gc guard
            pass
        logger.info(
            "Background startup finished",
            extra={"commit": settings.RAILWAY_GIT_COMMIT_SHA},
        )
    except asyncio.CancelledError:
        raise
    except Exception:
        logger.exception("Background startup crashed")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager.

    Yield as soon as logging is configured so uvicorn binds the port and
    /health answers immediately. Schema and Pinecone run as a background
    task so a slow Supabase/Pinecone call cannot delay deploy healthchecks.
    """
    import asyncio

    # GC tuning for the single-worker memory budget (512 MB Railway):
    # - gc.freeze() moves import-time objects into the permanent generation so
    #   the collector never rescans them (they are static and never collected).
    # - Lower gen1/gen2 thresholds collect older generations more often, so
    #   short-lived request/job objects do not accumulate between full cycles.
    # Best-effort; a GC API change must never block startup.
    import gc
    try:
        gc.freeze()
        gc.set_threshold(700, 5, 5)
    except Exception:  # pragma: no cover - a GC API change must never block startup
        pass

    # Initialize session logging first
    log_file = setup_session_logging()
    logger = logging.getLogger(__name__)

    # Fast path only — no network I/O before yield
    logger.info(
        f"{settings.PROJECT_NAME} starting up "
        f"(commit={settings.RAILWAY_GIT_COMMIT_SHA})"
    )
    if log_file:
        logger.info(f"Session log file: {log_file}")
    logger.info(f"API v1 endpoint: {settings.API_V1_STR}")
    logger.info(f"Debug mode: {settings.DEBUG}")

    try:
        from app.utils.process_metrics import log_memory
        log_memory("startup", force=True)
    except Exception:  # pragma: no cover - best-effort telemetry
        pass

    # Surface mis-set production env vars (empty AI_ENCRYPTION_KEY, wrong
    # FRONTEND_URL, non-OpenAI vision host, etc.) on every boot so Railway's
    # log drain catches them before they bite at request time. Never raises;
    # see app/core/config_health.py.
    try:
        from app.core.config_health import validate_production_config
        for issue in validate_production_config():
            # Put the key + message in the human-readable text too: Railway's
            # plain-text log drain does not render the structured `extra` fields,
            # so "Config issue at startup" alone gave no clue WHICH key was bad.
            getattr(logger, "error" if issue.severity == "error" else "warning")(
                f"Config issue at startup: {issue.key} - {issue.message}",
                extra={
                    "config_key": issue.key,
                    "config_severity": issue.severity,
                    "config_message": issue.message,
                },
            )
    except Exception:  # pragma: no cover - defensive; config_health never raises
        logger.exception("Config health check itself failed; continuing")

    # Schedule heavy init without blocking the accept path
    bg_task = asyncio.create_task(
        _background_startup(logger),
        name="background_startup",
    )

    logger.info("Accepting traffic; background init scheduled")
    yield

    # Shutdown (Railway "Stopping Container" / SIGTERM reaches here)
    logger.info(
        f"{settings.PROJECT_NAME} shutting down "
        f"(commit={settings.RAILWAY_GIT_COMMIT_SHA})"
    )
    try:
        from app.utils.process_metrics import log_memory
        log_memory("shutdown", force=True)
    except Exception:  # pragma: no cover - best-effort telemetry
        pass

    # Stop the bounded image executor (see app/core/image_executor.py).
    try:
        from app.core.image_executor import shutdown as shutdown_image_executor
        shutdown_image_executor()
    except Exception:  # pragma: no cover - defensive teardown
        pass

    # Release the pooled storage download client (see storage_service.py).
    try:
        from app.services.storage_service import close_download_client
        await close_download_client()
    except Exception:  # pragma: no cover - defensive teardown
        pass

    # Always retrieve the task result so a failed background init cannot
    # leave "Task exception was never retrieved" on the loop at process exit.
    if not bg_task.done():
        bg_task.cancel()
    try:
        await bg_task
    except asyncio.CancelledError:
        pass
    except Exception:
        logger.exception("Background startup task ended with error")


app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Virtual closet with AI-powered outfit visualization",
    version=settings.VERSION,
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc",
    openapi_url="/api/v1/openapi.json",
    lifespan=lifespan,
    redirect_slashes=True,
)

# ============================================================================
# MIDDLEWARE (order matters - first added = outermost)
# ============================================================================

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_origin_regex=settings.BACKEND_CORS_ORIGIN_REGEX,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["X-Correlation-ID"],  # Allow frontend to read correlation ID
)

# Request logging (logs requests with timing)
app.add_middleware(RequestLoggingMiddleware)

# Correlation ID (generates unique ID per request)
app.add_middleware(CorrelationIdMiddleware)


# ============================================================================
# ROUTE REGISTRATION
# ============================================================================

# Authentication routes (no auth required)
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])

# Items routes (requires auth)
app.include_router(items.router, prefix="/api/v1/items", tags=["Items"])

# Outfits routes (requires auth)
app.include_router(outfits.router, prefix="/api/v1/outfits", tags=["Outfits"])

# Shared outfits feedback (public/auth)
app.include_router(shared_outfits.router, prefix="/api/v1/shared-outfits", tags=["Shared Outfits"])

# Recommendations routes (requires auth)
app.include_router(recommendations.router, prefix="/api/v1/recommendations", tags=["Recommendations"])

# User routes (requires auth)
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])

# AI operations routes (requires auth)
app.include_router(ai.router, prefix="/api/v1/ai", tags=["AI Operations"])

# AI settings routes (requires auth)
app.include_router(ai_settings.router, prefix="/api/v1/ai/settings", tags=["AI Settings"])

# Batch processing routes (requires auth) - SSE endpoints for multi-image extraction
app.include_router(batch_processing.router, prefix="/api/v1/ai", tags=["Batch Processing"])

# Calendar integration routes (requires auth)
app.include_router(calendar.router, prefix="/api/v1/calendar", tags=["Calendar"])

# Weather integration routes (requires auth)
app.include_router(weather.router, prefix="/api/v1/weather", tags=["Weather"])

# Gamification routes (requires auth).
#
# DO NOT WRAP THIS IN `if settings.ENABLE_GAMIFICATION:`. This is deliberately
# NOT the social-import pattern used below, and "making it consistent" will
# break the shipped Flutter app on its home screen.
#
# flutter/lib/features/dashboard/controllers/dashboard_controller.dart:60-67
# runs an UNGUARDED `Future.wait([fetchDashboard(), fetchStreak()])` under a
# single catch. fetchStreak() hits /api/v1/gamification/streak and
# dashboard_repository.dart rethrows a 404 as NotFoundException. A 404 there
# rejects the whole wait, so `dashboard.value` is never assigned even though
# fetchDashboard() succeeded -- while `isLoading` still goes false. Then
# dashboard_content.dart:48-63 skips the shimmer and renders a permanent error
# banner plus a toast against null data, on every launch, forever.
#
# So the router stays mounted and the FLAG IS ENFORCED INSIDE THE HANDLERS
# (app/api/v1/gamification.py), which return 200 with a neutral zeroed payload.
# Unmounting this only becomes safe once that Future.wait is made per-future
# fault-tolerant (tracked as TD-034 in docs/exec-plans/tech-debt-tracker.md).
app.include_router(gamification.router, prefix="/api/v1/gamification", tags=["Gamification"])

# Waitlist routes (public, no auth required)
app.include_router(waitlist.router, prefix="/api/v1/waitlist", tags=["Waitlist"])

# Demo routes (public, no auth required - IP rate limited)
app.include_router(demo.router, prefix="/api/v1/demo", tags=["Demo"])

# Subscription routes (requires auth, except webhook)
app.include_router(subscription.router, prefix="/api/v1/subscription", tags=["Subscription"])
# Mobile in-app purchase routes (register + store webhooks); mounted under
# /api/v1/subscription via its own prefix.
app.include_router(iap.router, prefix="/api/v1", tags=["Subscription", "IAP"])

# Referral routes (requires auth, except validate)
app.include_router(referral.router, prefix="/api/v1/referral", tags=["Referral"])

# Promo code routes (validate is public, redeem requires auth)
app.include_router(promo.router, prefix="/api/v1/promo", tags=["Promo"])

# Feedback routes (public for submit, auth for ticket history)
app.include_router(feedback.router, prefix="/api/v1/feedback", tags=["Feedback"])

# Photoshoot routes (auth for generate, public for demo and use-cases)
app.include_router(photoshoot.router, prefix="/api/v1/photoshoot", tags=["Photoshoot"])

# Social import routes (feature-flagged); the flag is read once at
# import time and defaults to on, so the off-arc only exists in
# deployments that disable the feature via env.
if settings.ENABLE_SOCIAL_IMPORT:  # pragma: no cover - env-dependent feature flag
    app.include_router(social_import.router, prefix="/api/v1/ai", tags=["Social Import"])

# Blog routes (public read, admin write)
app.include_router(blog.router, prefix="/api/v1/blog", tags=["Blog"])

# Admin panel (all endpoints behind require_admin / require_permission)
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])

# Presigned-URL read path (auth; caller-owned objects only)
app.include_router(images.router, prefix="/api/v1/images", tags=["Images"])

# Health endpoints: canonical /health + /api/v1/health compatibility alias.
# The routes carry full paths, so no prefix is applied here.
app.include_router(health.router, tags=["Health"])


# ============================================================================
# ROOT & READINESS ENDPOINTS
# ============================================================================


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": f"Welcome to {settings.PROJECT_NAME}",
        "version": settings.VERSION,
        "docs": "/api/v1/docs"
    }


@app.get("/robots.txt", response_class=PlainTextResponse)
async def robots_txt():
    """Serve a permissive robots.txt at the API origin.

    The frontend host serves its own SEO robots.txt; this only answers direct
    hits to the backend origin (scanners, misrouted ingress) so they stop
    producing 404 noise. API endpoints should not be crawled.
    (RCA 2026-08-05: GET /robots.txt 404.)
    """
    return "User-agent: *\nDisallow: /\n"


@app.get("/ready")
async def readiness_check():
    """Readiness: schema cache status (no live multi-table scan on every hit).

    Uses the 5-minute schema cache so operators can see migration state
    without hammering Supabase. Cache misses run in a worker thread so the
    event loop is not blocked. Not used by Railway restarts (/health is).
    """
    import asyncio

    try:
        schema_ready, missing = await asyncio.to_thread(_get_cached_schema_status)
    except Exception:
        missing = []
        schema_ready = False

    response = {
        "status": "ready" if schema_ready else "not_ready",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "commit": settings.RAILWAY_GIT_COMMIT_SHA,
        "schema_ready": schema_ready,
    }

    if settings.DEBUG and missing:
        response["missing_tables"] = missing

    return response


# ============================================================================
# ERROR HANDLERS
# ============================================================================

logger = logging.getLogger(__name__)


@app.exception_handler(FitCheckException)
async def fitcheck_exception_handler(request: Request, exc: FitCheckException):
    """Handle custom FitCheck exceptions with proper error codes."""
    correlation_id = get_correlation_id()
    
    # Log the error
    logger.warning(
        f"FitCheckException: {exc.error_code} - {exc.message}",
        extra={"error_code": exc.error_code, "details": exc.details}
    )
    
    response_content = exc.to_dict()
    response_content["correlation_id"] = correlation_id
    
    return JSONResponse(
        status_code=exc.status_code,
        content=response_content,
    )


@app.exception_handler(StarletteHTTPException)
async def http_exception_handler(request: Request, exc: StarletteHTTPException):
    """Handle HTTP exceptions."""
    correlation_id = get_correlation_id()
    
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail,
            "code": "HTTP_ERROR",
            "details": {},
            "correlation_id": correlation_id,
        },
    )


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Handle request validation errors."""
    correlation_id = get_correlation_id()
    
    # Format validation errors for readability
    formatted_errors = []
    for error in exc.errors():
        loc = ".".join(str(part) for part in error.get("loc", []))
        msg = error.get("msg", "Invalid value")
        formatted_errors.append({"field": loc, "message": msg})
    
    return JSONResponse(
        status_code=422,
        content={
            "error": "Invalid request data",
            "code": "VALIDATION_ERROR",
            "details": {"errors": formatted_errors},
            "correlation_id": correlation_id,
        },
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    """Catch-all handler for unhandled exceptions.
    
    Logs the full traceback and returns a generic error response with
    correlation ID for debugging.
    """
    correlation_id = get_correlation_id()
    
    # Log the full exception with traceback
    logger.error(
        f"Unhandled exception: {type(exc).__name__}: {str(exc)}",
        exc_info=True,
    )
    
    # Return a generic error response (don't leak internal details)
    return JSONResponse(
        status_code=500,
        content={
            "error": "An unexpected error occurred",
            "code": "INTERNAL_ERROR",
            "details": {},
            "correlation_id": correlation_id,
        },
    )


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
