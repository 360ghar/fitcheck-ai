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
    PINECONE_DIMENSION: int = 768  # Gemini embeddings dimension

    # ==========================================================================
    # AI Provider Configuration (Multi-provider support)
    # ==========================================================================

    # Default AI Provider (openai, custom, gemini)
    AI_DEFAULT_PROVIDER: str = "custom"

    # AI_GEMINI_API_KEY is dual-purpose: ai_service.py's embeddings client
    # (google.genai SDK) AND the native chat/vision/image provider below
    # (app/services/gemini_provider.py) - both use the same key, different
    # models. Native Gemini is opt-in (AI_DEFAULT_PROVIDER=gemini, or a user
    # selecting it via BYOK settings); it has NO per-leg URL fields the way
    # AI_CHAT_*/AI_VISION_*/AI_IMAGE_* below do - the SDK always talks
    # directly to Google, so only model names are configurable.
    AI_GEMINI_API_KEY: Optional[str] = None
    AI_GEMINI_EMBEDDING_MODEL: str = "gemini-embedding-001"
    AI_GEMINI_CHAT_MODEL: str = "gemini-3.6-flash"
    AI_GEMINI_VISION_MODEL: Optional[str] = None            # inherits AI_GEMINI_CHAT_MODEL when blank
    AI_GEMINI_VISION_FALLBACK_MODEL: Optional[str] = None
    AI_GEMINI_IMAGE_MODEL: str = "gemini-3.1-flash-image"
    AI_GEMINI_IMAGE_FALLBACK_MODEL: Optional[str] = None

    # OpenAI Provider Defaults
    AI_OPENAI_API_URL: str = "https://api.openai.com/v1"
    AI_OPENAI_API_KEY: Optional[str] = None
    AI_OPENAI_CHAT_MODEL: str = "gpt-4o"
    AI_OPENAI_VISION_MODEL: str = "gpt-4o"
    AI_OPENAI_IMAGE_MODEL: str = "dall-e-3"

    # Custom provider defaults: Agnes AI OpenAI-compatible gateway.
    # Chat/vision: /v1/chat/completions | Images: /v1/images/generations
    #
    # Each leg (chat, vision, vision-fallback, image, image-fallback) can have
    # its own host/key/model. Per-leg url/key falls back to its parent when
    # blank: vision -> chat; vision_fallback -> vision; image -> chat;
    # image_fallback -> image. So a single-host setup only needs the CHAT trio.
    AI_CHAT_API_URL: str = "https://apihub.agnes-ai.com/v1"
    AI_CHAT_API_KEY: Optional[str] = None
    AI_CHAT_MODEL: str = "agnes-2.5-flash"

    # "custom": vision stays OpenAI-compatible, uses AI_VISION_API_URL above.
    # "gemini" (default): the vision leg's primary call is routed directly to
    # Google's native SDK (app/services/gemini_provider.py) instead - AI_VISION_MODEL
    # is then read as a Gemini model name, and AI_VISION_API_URL must be left
    # blank (config_health.py flags the combination as a startup error, since
    # the URL would otherwise be silently dead once the leg is redirected).
    # Production runs Gemini-primary/Agnes-fallback by default; local dev
    # without a Gemini key should override to AI_VISION_PROVIDER=custom.
    AI_VISION_PROVIDER: str = "gemini"
    AI_VISION_API_URL: Optional[str] = None
    AI_VISION_API_KEY: Optional[str] = None
    AI_VISION_MODEL: str = "gemini-3.6-flash"

    AI_VISION_FALLBACK_API_URL: Optional[str] = None
    AI_VISION_FALLBACK_API_KEY: Optional[str] = None
    AI_VISION_FALLBACK_MODEL: str = "agnes-2.5-flash"

    AI_IMAGE_API_URL: Optional[str] = None
    AI_IMAGE_API_KEY: Optional[str] = None
    AI_IMAGE_MODEL: str = "agnes-image-2.1-flash"
    # "chat" (response_modalities on /chat/completions) | "images" (/images/generations)
    AI_IMAGE_API_STYLE: str = "images"

    AI_IMAGE_FALLBACK_API_URL: Optional[str] = None
    AI_IMAGE_FALLBACK_API_KEY: Optional[str] = None
    AI_IMAGE_FALLBACK_MODEL: str = "agnes-image-2.0-flash"

    # Max output tokens per AI call. Both current providers comfortably exceed
    # this: gemini-3.6-flash caps at 64K output, the Agnes gateway (agnes-2.5-
    # flash / agnes-3.5-pro-alpha) at 65.5K. The old hardcoded 4096 default
    # truncated large structured extractions and surfaced as "finish_reason=
    # length / MAX_TOKENS" errors to users.
    AI_MAX_OUTPUT_TOKENS: int = 32768

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
    STRIPE_PLUS_MONTHLY_PRICE_ID: Optional[str] = None
    STRIPE_PLUS_YEARLY_PRICE_ID: Optional[str] = None
    STRIPE_PRO_MONTHLY_PRICE_ID: Optional[str] = None
    STRIPE_PRO_YEARLY_PRICE_ID: Optional[str] = None

    # Plan Limits (monthly)
    PLAN_FREE_MONTHLY_EXTRACTIONS: int = 25
    PLAN_FREE_MONTHLY_GENERATIONS: int = 50
    PLAN_FREE_MONTHLY_EMBEDDINGS: int = 200

    PLAN_PLUS_MONTHLY_EXTRACTIONS: int = 100
    PLAN_PLUS_MONTHLY_GENERATIONS: int = 350
    PLAN_PLUS_MONTHLY_EMBEDDINGS: int = 2000

    PLAN_PRO_MONTHLY_EXTRACTIONS: int = 200
    PLAN_PRO_MONTHLY_GENERATIONS: int = 1000
    PLAN_PRO_MONTHLY_EMBEDDINGS: int = 5000

    # Plan Pricing (for display purposes)
    PLAN_PLUS_MONTHLY_PRICE: float = 10.00
    PLAN_PLUS_YEARLY_PRICE: float = 100.00
    PLAN_PRO_MONTHLY_PRICE: float = 20.00
    PLAN_PRO_YEARLY_PRICE: float = 200.00

    # Referral Configuration
    REFERRAL_CREDIT_MONTHS: int = 1  # Months of Pro given to both referrer and referred

    # Photoshoot Generator Configuration
    PLAN_FREE_DAILY_PHOTOSHOOT_IMAGES: int = 10
    PLAN_PLUS_DAILY_PHOTOSHOOT_IMAGES: int = 30
    PLAN_PRO_DAILY_PHOTOSHOOT_IMAGES: int = 50
    PHOTOSHOOT_CONCURRENCY_LIMIT: int = 2  # Max concurrent image generations (lower = fewer protocol/OOM failures)

    # Process-wide asyncio.Semaphore caps for the batch extract+generate
    # pipeline (batch_extraction_service.py) and the variation fan-out
    # (image_generation_agent.generate_variations). Shared across ALL
    # concurrent jobs on this worker — NOT per-job. Each in-flight request
    # holds a multi-MB base64 buffer, and shared AI gateways can 429/503
    # under high parallelism, so raise cautiously.
    AI_EXTRACTION_CONCURRENCY: int = 30
    AI_GENERATION_CONCURRENCY: int = 30

    # Outfit generation sends every selected item's own stored image to the
    # image model as a labelled garment reference (see
    # item_reference_service.resolve_outfit_item_references). Those references
    # are flat studio product shots — 768px preserves color, print, and
    # hardware while keeping the payload sane when an outfit has many items.
    # The avatar keeps the larger image_processing default: identity needs
    # more pixels than a garment does.
    AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE: int = 768

    # Gamification
    #
    # Deliberately defaults to the OPPOSITE of ENABLE_SOCIAL_IMPORT below.
    # Nothing in this backend ever WRITES user_streaks or user_achievements --
    # the only insert is the zeroed row at gamification.py:96 -- so every user
    # sees a permanent 0-day streak and an all-zero leaderboard. Shipping that
    # is worse than not shipping it, hence off by default.
    #
    # NOTE: when this is False the gamification router stays MOUNTED (see the
    # comment at main.py's include_router call); only the handler bodies are
    # short-circuited to a neutral zeroed 200. Never turn this into a 404.
    ENABLE_GAMIFICATION: bool = False

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

    # Upload size/type limits live in storage_service.py (MAX_FILE_SIZE,
    # ALLOWED_IMAGE_EXTENSIONS); page sizes are per-route Query() defaults; and
    # outbound AI timeouts are ProviderConfig field defaults in
    # ai_provider_service.py. Do not re-add settings mirrors of those here -
    # nothing reads them, so an operator who sets them is silently ignored.

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_DIR: str = "logs"

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
