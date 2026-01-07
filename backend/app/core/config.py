"""
Application configuration using Pydantic BaseSettings.
All settings can be overridden via environment variables.
"""

from pydantic_settings import BaseSettings
from typing import Optional, List


class Settings(BaseSettings):
    """Application settings."""

    # Application
    PROJECT_NAME: str = "FitCheck AI"
    API_V1_STR: str = "/api/v1"
    VERSION: str = "0.1.0"
    DEBUG: bool = False

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost:8000",
    ]

    # Supabase
    SUPABASE_URL: str
    SUPABASE_KEY: str
    SUPABASE_JWT_SECRET: str
    SUPABASE_STORAGE_BUCKET: str = "fitcheck-images"

    # Pinecone
    PINECONE_API_KEY: str
    PINECONE_INDEX_NAME: str = "fitcheck-items"
    PINECONE_ENVIRONMENT: Optional[str] = None
    PINECONE_DIMENSION: int = 768  # Gemini embeddings dimension

    # Google Gemini AI
    GEMINI_API_KEY: str
    GEMINI_MODEL: str = "gemini-2.0-flash-exp"
    GEMINI_EMBEDDING_MODEL: str = "text-embedding-004"

    # Frontend URL (for redirects)
    FRONTEND_URL: str = "http://localhost:5173"

    # File Upload
    MAX_UPLOAD_SIZE_MB: int = 10
    ALLOWED_IMAGE_TYPES: List[str] = ["image/jpeg", "image/png", "image/webp"]

    # Pagination
    ITEMS_PER_PAGE: int = 20
    OUTFITS_PER_PAGE: int = 20

    # AI Generation
    MAX_OUTFIT_ITEMS: int = 10
    MAX_GENERATION_VARIATIONS: int = 3

    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
