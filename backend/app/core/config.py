"""
Application configuration using Pydantic BaseSettings.
All settings can be overridden via environment variables.
"""

import json
import re
from typing import List, Optional

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""

    # Application
    PROJECT_NAME: str = "FitCheck AI"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "0.1.0"
    DEBUG: bool = False

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "https://www.fitcheckaiapp.com",
        "https://fitcheckaiapp.com",
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost:8000",
    ]
    BACKEND_CORS_ORIGIN_REGEX: Optional[str] = r"^https://.*\.netlify\.app$"

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def _parse_cors_origins(cls, value):
        if value is None:
            return value

        if isinstance(value, str):
            value = value.strip()
            if not value:
                return []

            # Accept either JSON array or comma-separated list.
            if value.startswith("["):
                try:
                    parsed = json.loads(value)
                    if isinstance(parsed, list):
                        return [str(v).strip() for v in parsed if str(v).strip()]
                except Exception:
                    pass

            return [v.strip() for v in re.split(r"[,\s]+", value) if v.strip()]

        return value

    # Supabase API Keys (sb_publishable_... and sb_secret_...)
    SUPABASE_URL: str
    SUPABASE_PUBLISHABLE_KEY: str

    @field_validator("SUPABASE_URL", mode="after")
    @classmethod
    def _ensure_supabase_url_trailing_slash(cls, value: str) -> str:
        if value and not value.endswith("/"):
            return value + "/"
        return value
    SUPABASE_SECRET_KEY: str
    SUPABASE_JWT_SECRET: str
    SUPABASE_STORAGE_BUCKET: str = "fitcheck-images"

    # Pinecone
    PINECONE_API_KEY: Optional[str] = None
    PINECONE_INDEX_NAME: str = "fitcheck-items"
    PINECONE_ENVIRONMENT: Optional[str] = None
    PINECONE_DIMENSION: int = 768  # Gemini embeddings dimension

    # ==========================================================================
    # AI Provider Configuration (Multi-provider support)
    # ==========================================================================

    # Default AI Provider (gemini, openai, custom)
    AI_DEFAULT_PROVIDER: str = "custom"

    # Gemini Provider Defaults
    AI_GEMINI_API_URL: str = "https://generativelanguage.googleapis.com/v1beta"
    AI_GEMINI_API_KEY: Optional[str] = None
    AI_GEMINI_CHAT_MODEL: str = "gemini-3-flash-preview"
    AI_GEMINI_VISION_MODEL: str = "gemini-3-flash-preview"
    AI_GEMINI_IMAGE_MODEL: str = "gemini-3-pro-image-preview"
    AI_GEMINI_EMBEDDING_MODEL: str = "gemini-embedding-001"

    # OpenAI Provider Defaults
    AI_OPENAI_API_URL: str = "https://api.openai.com/v1"
    AI_OPENAI_API_KEY: Optional[str] = None
    AI_OPENAI_CHAT_MODEL: str = "gpt-4o"
    AI_OPENAI_VISION_MODEL: str = "gpt-4o"
    AI_OPENAI_IMAGE_MODEL: str = "dall-e-3"

    # Custom Proxy Defaults (e.g., local proxy at localhost:8317)
    AI_CUSTOM_API_URL: str = "http://localhost:8317/v1"
    AI_CUSTOM_API_KEY: str = "***REMOVED***"
    AI_CUSTOM_CHAT_MODEL: str = "gemini-3-flash-preview"
    AI_CUSTOM_VISION_MODEL: str = "gemini-3-flash-preview"
    AI_CUSTOM_IMAGE_MODEL: str = "gemini-3-pro-image-preview"

    # Rate Limiting (legacy daily limits - used as fallback)
    AI_DAILY_EXTRACTION_LIMIT: int = 100
    AI_DAILY_GENERATION_LIMIT: int = 50
    AI_DAILY_EMBEDDING_LIMIT: int = 500

    # Encryption key for storing user API keys (generate with: openssl rand -hex 32)
    AI_ENCRYPTION_KEY: Optional[str] = None

    # ==========================================================================
    # Subscription Plan Configuration
    # ==========================================================================

    # Stripe Configuration
    STRIPE_SECRET_KEY: Optional[str] = None
    STRIPE_WEBHOOK_SECRET: Optional[str] = None
    STRIPE_PRO_MONTHLY_PRICE_ID: Optional[str] = None
    STRIPE_PRO_YEARLY_PRICE_ID: Optional[str] = None

    # Plan Limits (monthly)
    PLAN_FREE_MONTHLY_EXTRACTIONS: int = 25
    PLAN_FREE_MONTHLY_GENERATIONS: int = 50
    PLAN_FREE_MONTHLY_EMBEDDINGS: int = 200

    PLAN_PRO_MONTHLY_EXTRACTIONS: int = 200
    PLAN_PRO_MONTHLY_GENERATIONS: int = 1000
    PLAN_PRO_MONTHLY_EMBEDDINGS: int = 5000

    # Plan Pricing (for display purposes)
    PLAN_PRO_MONTHLY_PRICE: float = 20.00
    PLAN_PRO_YEARLY_PRICE: float = 200.00

    # Referral Configuration
    REFERRAL_CREDIT_MONTHS: int = 1  # Months of Pro given to both referrer and referred

    # Photoshoot Generator Configuration
    PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES: int = 10
    PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES: int = 50

    # Weather (OpenWeatherMap)
    WEATHER_API_KEY: Optional[str] = None

    # Frontend URL (for redirects)
    FRONTEND_URL: str = "http://localhost:3000"

    # File Upload
    MAX_UPLOAD_SIZE_MB: int = 10
    ALLOWED_IMAGE_TYPES: List[str] = ["image/jpeg", "image/png", "image/webp"]

    # Pagination
    ITEMS_PER_PAGE: int = 20
    OUTFITS_PER_PAGE: int = 20

    # AI Generation
    MAX_OUTFIT_ITEMS: int = 10
    MAX_GENERATION_VARIATIONS: int = 3

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_DIR: str = "logs"

    class Config:
        env_file = ".env"
        case_sensitive = True
        enable_decoding = False
        extra = "ignore"

    @model_validator(mode="after")
    def _include_frontend_origin(self):
        frontend_url = (self.FRONTEND_URL or "").strip().rstrip("/")
        origins = [origin.strip().rstrip("/") for origin in (self.BACKEND_CORS_ORIGINS or [])]
        if frontend_url:
            origins.append(frontend_url)

        deduped = []
        seen = set()
        for origin in origins:
            if not origin or origin in seen:
                continue
            seen.add(origin)
            deduped.append(origin)

        self.BACKEND_CORS_ORIGINS = deduped
        return self


settings = Settings()
