"""
FitCheck AI - Main Application Entry Point
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager

from app.core.config import settings
from app.api.v1 import auth, items, outfits, recommendations, users


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager."""
    # Startup
    print(f"{settings.PROJECT_NAME} starting up...")
    print(f"API v1 endpoint: {settings.API_V1_STR}")
    yield
    # Shutdown
    print(f"{settings.PROJECT_NAME} shutting down...")


app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Virtual closet with AI-powered outfit visualization",
    version=settings.VERSION,
    docs_url="/api/v1/docs",
    redoc_url="/api/v1/redoc",
    openapi_url="/api/v1/openapi.json",
    lifespan=lifespan
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================================
# ROUTE REGISTRATION
# ============================================================================

# Authentication routes (no auth required)
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])

# Items routes (requires auth)
app.include_router(items.router, prefix="/api/v1/items", tags=["Items"])

# Outfits routes (requires auth)
app.include_router(outfits.router, prefix="/api/v1/outfits", tags=["Outfits"])

# Recommendations routes (requires auth)
app.include_router(recommendations.router, prefix="/api/v1/recommendations", tags=["Recommendations"])

# User routes (requires auth)
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])


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
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION
    }


# ============================================================================
# ERROR HANDLERS
# ============================================================================


@app.exception_handler(ValueError)
async def value_error_handler(request, exc):
    """Handle ValueError exceptions."""
    return {
        "error": str(exc),
        "code": "VALIDATION_ERROR"
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True
    )
