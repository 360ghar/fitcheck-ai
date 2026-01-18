"""
FitCheck AI - Main Application Entry Point
"""

import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException as StarletteHTTPException
from contextlib import asynccontextmanager

from app.core.config import settings
from app.core.logging_config import setup_session_logging
from app.core.exceptions import FitCheckException
from app.core.middleware import CorrelationIdMiddleware, RequestLoggingMiddleware, get_correlation_id
from app.api.v1 import auth, items, outfits, recommendations, users, calendar, weather, gamification, shared_outfits, ai, ai_settings, waitlist, demo, batch_processing, subscription, referral, feedback, photoshoot
from app.db.connection import SupabaseDB
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
    "body_profiles",
    # Planning + gamification + generation tracking (docs-aligned MVP)
    "outfit_generations",
    "calendar_connections",
    "calendar_events",
    # Sharing + feedback
    "shared_outfits",
    "share_feedback",
    "user_streaks",
    "user_achievements",
    # Subscription + referral
    "subscriptions",
    "subscription_usage",
    "referral_codes",
    "referral_redemptions",
    # Support tickets
    "support_tickets",
)

REQUIRED_COLUMNS = (
    # Preference profile (recommendations)
    ("user_preferences", "preferred_occasions"),
    # Wardrobe enrichment (recommendations/categorization)
    ("items", "material"),
    ("item_images", "storage_path"),
    # Sharing + enhanced outfit metadata
    ("outfits", "is_public"),
    ("outfit_images", "storage_path"),
    ("outfit_collections", "is_favorite"),
)


def _schema_missing(db) -> list[str]:
    missing: list[str] = []

    # Required tables
    for table in REQUIRED_TABLES:
        try:
            db.table(table).select("*").limit(1).execute()
        except PostgrestAPIError as e:
            if getattr(e, "code", None) == "PGRST205":
                missing.append(table)
            else:
                missing.append(table)
        except Exception:
            missing.append(table)

    # Required columns (guarding against partial migrations)
    for table, column in REQUIRED_COLUMNS:
        try:
            db.table(table).select(column).limit(1).execute()
        except PostgrestAPIError as e:
            code = getattr(e, "code", None)
            if code in {"PGRST205", "42703"}:
                missing.append(f"{table}.{column}")
            else:
                missing.append(f"{table}.{column}")
        except Exception:
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


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Initialize session logging first
    log_file = setup_session_logging()
    logger = logging.getLogger(__name__)

    # Startup
    logger.info(f"{settings.PROJECT_NAME} starting up...")
    logger.info(f"Session log file: {log_file}")
    logger.info(f"API v1 endpoint: {settings.API_V1_STR}")
    logger.info(f"Debug mode: {settings.DEBUG}")

    # Best-effort schema readiness check to help local setup.
    try:
        db = SupabaseDB.get_service_client()
        missing = _schema_missing(db)
        if missing:
            logger.warning(
                "Supabase schema not initialized/complete. Run `backend/db/supabase/migrations/001_full_schema.sql` in Supabase SQL Editor."
            )
            logger.warning(f"Missing: {', '.join(missing[:8])}{'…' if len(missing) > 8 else ''}")
    except Exception as e:
        logger.warning(f"Supabase schema check failed: {e}")
    yield
    # Shutdown
    logger.info(f"{settings.PROJECT_NAME} shutting down...")


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

# Gamification routes (requires auth)
app.include_router(gamification.router, prefix="/api/v1/gamification", tags=["Gamification"])

# Waitlist routes (public, no auth required)
app.include_router(waitlist.router, prefix="/api/v1/waitlist", tags=["Waitlist"])

# Demo routes (public, no auth required - IP rate limited)
app.include_router(demo.router, prefix="/api/v1/demo", tags=["Demo"])

# Subscription routes (requires auth, except webhook)
app.include_router(subscription.router, prefix="/api/v1/subscription", tags=["Subscription"])

# Referral routes (requires auth, except validate)
app.include_router(referral.router, prefix="/api/v1/referral", tags=["Referral"])

# Feedback routes (public for submit, auth for ticket history)
app.include_router(feedback.router, prefix="/api/v1/feedback", tags=["Feedback"])

# Photoshoot routes (auth for generate, public for demo and use-cases)
app.include_router(photoshoot.router, prefix="/api/v1/photoshoot", tags=["Photoshoot"])


# ============================================================================
# HEALTH CHECK & ROOT ENDPOINTS
# ============================================================================


@app.get("/")
async def root():
    """Root endpoint."""
    return {
        "message": f"Welcome to {settings.PROJECT_NAME}",
        "version": settings.VERSION,
        "docs": "/api/v1/docs"
    }


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring."""
    try:
        db = SupabaseDB.get_service_client()
        missing = _schema_missing(db)
        schema_ready = len(missing) == 0
    except Exception:
        missing = []
        schema_ready = False
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "schema_ready": schema_ready,
        "missing_tables": missing,
    }


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
        loc = ".".join(str(l) for l in error.get("loc", []))
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
