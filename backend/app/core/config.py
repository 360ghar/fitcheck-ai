"""
Application configuration using Pydantic BaseSettings.
All settings can be overridden via environment variables.
"""

import json
import os
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

    # ==========================================================================
    # Object storage (Railway S3-compatible Bucket)
    # ==========================================================================
    # Primary storage path for the app (DB + Auth stay on Supabase). Railway
    # provides these as variable references: BUCKET, ENDPOINT, REGION,
    # ACCESS_KEY_ID, SECRET_ACCESS_KEY (plus AWS_* aliases); the model_validator
    # below maps them onto the OBJECT_STORAGE_* names when the canonical field
    # is unset.
    STORAGE_BACKEND: str = "railway"  # "railway" (S3) or "supabase" (cutover fallback)
    OBJECT_STORAGE_ENDPOINT: str = "https://storage.railway.app"
    OBJECT_STORAGE_REGION: str = "auto"
    OBJECT_STORAGE_ACCESS_KEY_ID: str = ""
    OBJECT_STORAGE_SECRET_ACCESS_KEY: str = ""
    OBJECT_STORAGE_BUCKET: str = ""
    # Presigned GET URL lifetime for served images (seconds). Short-lived URLs
    # (default 3600s / 1h) keep the bucket private while giving the web/mobile
    # clients a long enough window that a cached list or an open tab still
    # renders before the URL rotates on the next refetch. Railway allows up to
    # 90 days; keep this moderate — it is the access window for anyone holding
    # the URL.
    OBJECT_STORAGE_PRESIGN_TTL: int = 3600

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
    # Per-provider rate control for the NATIVE Gemini leg. 0 = unlimited.
    # Free-tier Gemini keys are limited to ~5 requests/minute/model; bursts of
    # concurrent extractions exhaust the quota in one second (observed
    # 2026-08-01: 8 parallel 429 RESOURCE_EXHAUSTED). Setting this spaces
    # Gemini calls so the hybrid vision leg falls back to Agnes while the
    # bucket refills instead of hammering the quota with retries.
    AI_GEMINI_MAX_REQUESTS_PER_MINUTE: int = 0

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

    # Stripe Configuration (web purchases only; mobile uses store billing)
    STRIPE_SECRET_KEY: Optional[str] = None
    STRIPE_WEBHOOK_SECRET: Optional[str] = None
    STRIPE_PLUS_MONTHLY_PRICE_ID: Optional[str] = None
    STRIPE_PLUS_YEARLY_PRICE_ID: Optional[str] = None
    STRIPE_PRO_MONTHLY_PRICE_ID: Optional[str] = None
    STRIPE_PRO_YEARLY_PRICE_ID: Optional[str] = None

    # ==========================================================================
    # Mobile In-App Purchase Configuration (Apple App Store + Google Play)
    # ==========================================================================
    #
    # Apple App Store Server API (https://developer.apple.com/documentation/appstoreserverapi).
    # APPLE_PRIVATE_KEY is the contents of the .p8 key downloaded from App Store
    # Connect (In-App Purchase permission), used to sign the ES256 JWT that
    # authenticates every server API call. APPLE_ENV selects the base URL:
    # "sandbox" -> https://api.storekit-sandbox.itunes.apple.com, anything
    # else -> https://api.storekit.itunes.apple.com. Production code should
    # verify against the production API and fall back to sandbox on 404/401
    # (TestFlight purchases do not exist in the production store).
    APPLE_BUNDLE_ID: str = "com.fitcheckaiapp.fitcheckai"
    APPLE_ISSUER_ID: Optional[str] = None
    APPLE_KEY_ID: Optional[str] = None
    APPLE_PRIVATE_KEY: Optional[str] = None
    APPLE_ENV: str = "production"
    APPLE_PLUS_MONTHLY_PRODUCT_ID: Optional[str] = None
    APPLE_PLUS_YEARLY_PRODUCT_ID: Optional[str] = None
    APPLE_PRO_MONTHLY_PRODUCT_ID: Optional[str] = None
    APPLE_PRO_YEARLY_PRODUCT_ID: Optional[str] = None

    # Google Play Developer API (service account). GOOGLE_SERVICE_ACCOUNT_JSON
    # is the full contents of the service-account JSON key file downloaded from
    # Google Cloud Console (Play Developer API enabled for the service account).
    # GOOGLE_RTDN_AUDIENCE is the Pub/Sub topic resource name of the
    # Real-time Developer Notifications push subscription (the OIDC token's
    # audience); the notifications endpoint refuses pushes when it is unset.
    GOOGLE_PACKAGE_NAME: str = "com.fitcheckaiapp.fitcheckai"
    GOOGLE_SERVICE_ACCOUNT_JSON: Optional[str] = None
    GOOGLE_RTDN_AUDIENCE: Optional[str] = None
    GOOGLE_PLUS_MONTHLY_PRODUCT_ID: Optional[str] = None
    GOOGLE_PLUS_YEARLY_PRODUCT_ID: Optional[str] = None
    GOOGLE_PRO_MONTHLY_PRODUCT_ID: Optional[str] = None
    GOOGLE_PRO_YEARLY_PRODUCT_ID: Optional[str] = None

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
    # Max concurrent image generations within a single photoshoot job.
    # Raised 2 -> 4 on 2026-08-03 (photoshoot speed pass) to cut image-gen
    # wall time roughly in half; the process-wide AI_GENERATION_CONCURRENCY
    # cap (image_gen_slot) and per-image durable-URL upload + payload release
    # bound worst-case memory (2 jobs x 4 = 8 in-flight generations).
    PHOTOSHOOT_CONCURRENCY_LIMIT: int = 4

    # Process-wide asyncio.Semaphore caps for the batch extract+generate
    # pipeline (batch_extraction_service.py) and the variation fan-out
    # (image_generation_agent.generate_variations). Shared across ALL
    # concurrent jobs on this worker — NOT per-job. Each in-flight request
    # holds a multi-MB base64 buffer, and shared AI gateways can 429/503
    # under high parallelism, so raise cautiously.
    AI_EXTRACTION_CONCURRENCY: int = 30
    AI_GENERATION_CONCURRENCY: int = 30
    AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES: int = 12
    # Hard cap on TOTAL inline input images per image-generation call. The
    # Agnes image gateway (agnes-image-2.1-flash) rejects requests with more
    # than 6 ("too many input images: 7 provided, at most 6 allowed"). Outfit
    # generation sends avatar (1) + source photo (1) + garment references, so
    # image_generation_agent.py derives the garment budget from this cap.
    AI_IMAGE_GEN_MAX_INPUT_IMAGES: int = 6
    AI_OUTFIT_ITEM_REFERENCE_DOWNLOAD_CONCURRENCY: int = 8
    AI_MAX_OUTFIT_ITEMS: int = 100

    # Outfit generation sends every selected item's own stored image to the
    # image model as a labelled garment reference (see
    # item_reference_service.resolve_outfit_item_references). Those references
    # are flat studio product shots — 768px preserves color, print, and
    # hardware while keeping the payload sane when an outfit has many items.
    # The avatar keeps the larger image_processing default: identity needs
    # more pixels than a garment does.
    AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE: int = 768

    # Upload flow only (GenerateOutfitRequest.use_source_photo ->
    # item_reference_service.resolve_outfit_source_reference): the original
    # uploaded photo the outfit's items were extracted from, sent to the image
    # model as ONE extra "as worn" reference so the render reproduces real fit
    # and draping instead of compounding loss from the item shots. The
    # coherence gate requires at least MIN_SHARED_ITEMS of the outfit's items
    # to come from that photo (the auto-outfit flow groups one photo per
    # outfit, so the default 1 always passes there); MAX_IMAGES caps how many
    # photos are ever sent (a tie for most-shared is skipped entirely, so 1 is
    # the real ceiling). Reuses AI_OUTFIT_ITEM_REFERENCE_MAX_EDGE for the
    # downscale.
    AI_OUTFIT_SOURCE_REFERENCE_MAX_IMAGES: int = 1
    AI_OUTFIT_SOURCE_REFERENCE_MIN_SHARED_ITEMS: int = 1

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

    # ==========================================================================
    # Internal resource bounds (memory-budget knobs — NOT user-facing limits)
    # ==========================================================================
    #
    # These bound PROCESS-internal resources so the single Railway worker stays
    # under its 512 MB budget. They do not change any API contract, quota, or
    # concurrency cap exposed to clients; they only cap internal buffering.
    #
    # Dedicated thread-pool width for CPU-bound Pillow work (downscale, crop,
    # matte, upload validation). asyncio.to_thread's default executor allows
    # min(32, host_cpu+4) concurrent decodes — Railway exposes the HOST's core
    # count to the guest, so a 32-core host gave this process up to 32
    # concurrent full-res decodes, each buffering tens of MB. Bounding the
    # pool caps the multiplier while preserving all existing behavior.
    IMAGE_PROCESS_WORKERS: int = 4
    # Max buffered bytes per SSE subscriber queue. Events carrying generated
    # base64 are multi-MB; the event-count cap alone lets one stalled client
    # pin 100 x 5 MB = 500 MB. Crossing this budget drops the subscriber with
    # the existing stream_overflow terminal event (client reconnects + replays).
    SSE_QUEUE_MAX_BUFFERED_BYTES: int = 16 * 1024 * 1024

    # Logging
    LOG_LEVEL: str = "INFO"
    LOG_DIR: str = "logs"

    @field_validator("AI_GENERATION_CONCURRENCY", "AI_EXTRACTION_CONCURRENCY", mode="after")
    @classmethod
    def _cap_process_concurrency(cls, value: int) -> int:
        """Clamp process-wide concurrency caps.

        ``extraction_jobs.generation_batch_size`` (migration 023) is bounded
        by a DB CHECK, and the API mirrors the configured cap into that
        column; an uncapped config could therefore persist a value the
        database rejects. 100 is a generous ceiling — the shared AI gateways
        start failing well below it — and keeps config and DB in agreement.
        Values below 1 floor at 1 (a zero-cap semaphore would deadlock), which
        matches the historical behavior in app.core.concurrency.
        """
        if value < 1:
            return 1
        return min(value, 100)

    class Config:
        # Load env keys regardless of whether process is started from repo root
        # or from the backend folder.
        env_file = (str(_BACKEND_ENV_FILE), str(_ROOT_ENV_FILE))
        case_sensitive = True
        enable_decoding = False
        extra = "ignore"

    @model_validator(mode="after")
    def _resolve_object_storage_from_railway_aliases(self):
        """Map Railway Bucket's generic env names onto the OBJECT_STORAGE_* fields.

        Railway exposes the bucket credentials as BUCKET / ENDPOINT / REGION /
        ACCESS_KEY_ID / SECRET_ACCESS_KEY (plus AWS_* aliases). Only fill the
        canonical OBJECT_STORAGE_* field when it is unset, so a hand-set value
        always wins.
        """
        if not self.OBJECT_STORAGE_ENDPOINT:
            self.OBJECT_STORAGE_ENDPOINT = (
                os.getenv("ENDPOINT")
                or os.getenv("AWS_ENDPOINT_URL")
                or self.OBJECT_STORAGE_ENDPOINT
            )
        if not self.OBJECT_STORAGE_REGION:
            self.OBJECT_STORAGE_REGION = (
                os.getenv("REGION") or os.getenv("AWS_REGION") or self.OBJECT_STORAGE_REGION
            )
        if not self.OBJECT_STORAGE_ACCESS_KEY_ID:
            self.OBJECT_STORAGE_ACCESS_KEY_ID = (
                os.getenv("ACCESS_KEY_ID")
                or os.getenv("AWS_ACCESS_KEY_ID")
                or self.OBJECT_STORAGE_ACCESS_KEY_ID
            )
        if not self.OBJECT_STORAGE_SECRET_ACCESS_KEY:
            self.OBJECT_STORAGE_SECRET_ACCESS_KEY = (
                os.getenv("SECRET_ACCESS_KEY")
                or os.getenv("AWS_SECRET_ACCESS_KEY")
                or self.OBJECT_STORAGE_SECRET_ACCESS_KEY
            )
        if not self.OBJECT_STORAGE_BUCKET:
            self.OBJECT_STORAGE_BUCKET = (
                os.getenv("BUCKET") or os.getenv("AWS_BUCKET") or self.OBJECT_STORAGE_BUCKET
            )
        return self

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
