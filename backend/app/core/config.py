"""
Application configuration using Pydantic BaseSettings.
All settings can be overridden via environment variables.
"""

import json
import re
from pathlib import Path
from typing import List, Optional

from pydantic import field_validator, model_validator
from pydantic_settings import BaseSettings

_BACKEND_DIR = Path(__file__).resolve().parents[2]
_REPO_ROOT_DIR = Path(__file__).resolve().parents[3]
_BACKEND_ENV_FILE = _BACKEND_DIR / ".env"
_ROOT_ENV_FILE = _REPO_ROOT_DIR / ".env"


class Settings(BaseSettings):
    """Application settings."""

    # Application
    PROJECT_NAME: str = "FitCheck AI"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "0.1.0"
    DEBUG: bool = False
    # Railway sets this automatically on every build; exposed via /health so
    # a deployed instance can be traced back to the exact commit that's
    # running (VERSION alone never changes deploy-to-deploy).
    RAILWAY_GIT_COMMIT_SHA: str = "unknown"

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

    # Default AI Provider (openai, custom)
    AI_DEFAULT_PROVIDER: str = "custom"

    # Gemini is not a selectable chat/vision/image provider - these two fields
    # are used only by ai_service.py's embeddings client (google.genai SDK).
    AI_GEMINI_API_KEY: Optional[str] = None
    AI_GEMINI_EMBEDDING_MODEL: str = "gemini-embedding-001"

    # OpenAI Provider Defaults
    AI_OPENAI_API_URL: str = "https://api.openai.com/v1"
    AI_OPENAI_API_KEY: Optional[str] = None
    AI_OPENAI_CHAT_MODEL: str = "gpt-4o"
    AI_OPENAI_VISION_MODEL: str = "gpt-4o"
    AI_OPENAI_IMAGE_MODEL: str = "dall-e-3"

    # Custom provider defaults: Agnes AI OpenAI-compatible gateway
    # Chat/vision: /v1/chat/completions | Images: /v1/images/generations
    AI_CUSTOM_API_URL: str = "https://apihub.agnes-ai.com/v1"
    AI_CUSTOM_API_KEY: Optional[str] = None
    AI_CUSTOM_CHAT_MODEL: str = "agnes-2.0-flash"
    AI_CUSTOM_VISION_MODEL: str = "agnes-2.0-flash"
    AI_CUSTOM_IMAGE_MODEL: str = "agnes-image-2.1-flash"
    AI_CUSTOM_IMAGE_FALLBACK_MODEL: str = "agnes-image-2.0-flash"

    # Generic OpenAI-compatible overrides for the "custom" provider (Agnes, etc.)
    # All optional; unset values fall back to AI_CUSTOM_* above. LLM and Image
    # can point at different hosts/keys if needed.
    OPENAI_LLM_URL: Optional[str] = None
    OPENAI_LLM_API_KEY: Optional[str] = None
    OPENAI_LLM_MODEL: Optional[str] = None
    OPENAI_LLM_VISION_MODEL: Optional[str] = None

    OPENAI_IMAGE_URL: Optional[str] = None
    OPENAI_IMAGE_API_KEY: Optional[str] = None
    OPENAI_IMAGE_MODEL: Optional[str] = None
    # "chat" (response_modalities on /chat/completions, legacy proxy-style trick)
    # "images" (real OpenAI-compatible /images/generations endpoint, e.g. Agnes)
    OPENAI_IMAGE_API_STYLE: str = "images"

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
    PHOTOSHOOT_CONCURRENCY_LIMIT: int = 2  # Max concurrent image generations (lower = fewer protocol/OOM failures)

    # Social Import
    ENABLE_SOCIAL_IMPORT: bool = True
    SOCIAL_IMPORT_MAX_CONCURRENT_JOBS: int = 1
    SOCIAL_IMPORT_MAX_PHOTOS_PER_JOB: int = 2000
    SOCIAL_IMPORT_AUTH_SESSION_TTL_MINUTES: int = 120
    SOCIAL_IMPORT_DISCOVERY_PAGE_SIZE: int = 50

    # Meta OAuth (optional for social import)
    META_OAUTH_CLIENT_ID: Optional[str] = None
    META_OAUTH_CLIENT_SECRET: Optional[str] = None

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

    # Timeout Configuration (seconds)
    AI_CONNECT_TIMEOUT: float = 5.0      # Connection establishment
    AI_READ_TIMEOUT: float = 120.0       # Reading response
    AI_WRITE_TIMEOUT: float = 30.0       # Sending request
    AI_POOL_TIMEOUT: float = 10.0        # Pool acquisition

    class Config:
        # Load env keys regardless of whether process is started from repo root
        # or from the backend folder.
        env_file = (str(_BACKEND_ENV_FILE), str(_ROOT_ENV_FILE))
        case_sensitive = True
        enable_decoding = False
        extra = "ignore"

    @model_validator(mode="after")
    def _include_frontend_origin(self):
        frontend_url = (self.FRONTEND_URL or "").strip().rstrip("/")
        origins = [
            origin.strip().rstrip("/") for origin in (self.BACKEND_CORS_ORIGINS or [])
        ]
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
