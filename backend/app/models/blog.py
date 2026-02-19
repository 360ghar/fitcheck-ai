"""
Blog post models for FitCheck AI.

Provides Pydantic models for blog post CRUD operations and API responses.
"""

from datetime import date as DateType, datetime
from typing import Optional, List
from uuid import UUID

from pydantic import BaseModel, Field, field_validator


# =============================================================================
# BASE MODELS
# =============================================================================


class BlogPostBase(BaseModel):
    """Base blog post model with common fields."""

    slug: str = Field(..., min_length=1, max_length=255, description="URL-friendly unique identifier")
    title: str = Field(..., min_length=1, max_length=255, description="Post title")
    excerpt: str = Field(..., min_length=1, max_length=500, description="Short summary for previews")
    content: str = Field(..., min_length=1, description="Full markdown content")
    category: str = Field(..., min_length=1, max_length=100, description="Post category")
    date: DateType = Field(..., description="Publication date")
    read_time: str = Field(..., min_length=1, max_length=50, description="Estimated reading time")
    emoji: str = Field(..., min_length=1, max_length=10, description="Category emoji")
    keywords: List[str] = Field(default_factory=list, description="SEO keywords")
    author: str = Field(..., min_length=1, max_length=100, description="Author name")
    author_title: Optional[str] = Field(None, max_length=100, description="Author title/role")
    is_published: bool = Field(default=True, description="Whether post is publicly visible")
    featured_image_url: Optional[str] = Field(None, max_length=500, description="Hero image URL")

    @field_validator("slug")
    @classmethod
    def validate_slug(cls, v: str) -> str:
        """Validate slug format - lowercase letters, numbers, hyphens only."""
        import re
        v = v.lower().strip()
        if not re.match(r"^[a-z0-9-]+$", v):
            raise ValueError("Slug must contain only lowercase letters, numbers, and hyphens")
        return v

    @field_validator("keywords")
    @classmethod
    def validate_keywords(cls, v: List[str]) -> List[str]:
        """Normalize keywords to lowercase and remove duplicates."""
        if not v:
            return []
        # Normalize and deduplicate
        normalized = [kw.lower().strip() for kw in v if kw.strip()]
        return list(dict.fromkeys(normalized))  # Preserves order while removing duplicates


# =============================================================================
# REQUEST MODELS
# =============================================================================


class BlogPostCreate(BlogPostBase):
    """Model for creating a new blog post."""

    pass


class BlogPostUpdate(BaseModel):
    """Model for updating an existing blog post. All fields are optional."""

    slug: Optional[str] = Field(None, min_length=1, max_length=255)
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    excerpt: Optional[str] = Field(None, min_length=1, max_length=500)
    content: Optional[str] = Field(None, min_length=1)
    category: Optional[str] = Field(None, min_length=1, max_length=100)
    date: Optional[DateType] = None
    read_time: Optional[str] = Field(None, min_length=1, max_length=50)
    emoji: Optional[str] = Field(None, min_length=1, max_length=10)
    keywords: Optional[List[str]] = None
    author: Optional[str] = Field(None, min_length=1, max_length=100)
    author_title: Optional[str] = Field(None, max_length=100)
    is_published: Optional[bool] = None
    featured_image_url: Optional[str] = Field(None, max_length=500)

    @field_validator("slug")
    @classmethod
    def validate_slug(cls, v: Optional[str]) -> Optional[str]:
        """Validate slug format if provided."""
        if v is None:
            return v
        import re
        v = v.lower().strip()
        if not re.match(r"^[a-z0-9-]+$", v):
            raise ValueError("Slug must contain only lowercase letters, numbers, and hyphens")
        return v

    @field_validator("keywords")
    @classmethod
    def validate_keywords(cls, v: Optional[List[str]]) -> Optional[List[str]]:
        """Normalize keywords if provided."""
        if v is None:
            return v
        normalized = [kw.lower().strip() for kw in v if kw.strip()]
        return list(dict.fromkeys(normalized))


# =============================================================================
# RESPONSE MODELS
# =============================================================================


class BlogPost(BlogPostBase):
    """Full blog post model including database fields."""

    id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class BlogPostSummary(BaseModel):
    """Simplified blog post for list views."""

    id: UUID
    slug: str
    title: str
    excerpt: str
    category: str
    date: DateType
    read_time: str
    emoji: str
    keywords: List[str]
    author: str
    author_title: Optional[str]
    featured_image_url: Optional[str]

    class Config:
        from_attributes = True


# =============================================================================
# PAGINATION MODELS
# =============================================================================


class BlogPostListResponse(BaseModel):
    """Paginated list of blog posts."""

    posts: List[BlogPostSummary]
    total: int
    page: int
    page_size: int
    total_pages: int
    has_next: bool
    has_prev: bool


class BlogPostCategoriesResponse(BaseModel):
    """List of unique blog categories."""

    categories: List[str]


# =============================================================================
# QUERY PARAMETER MODELS
# =============================================================================


class BlogPostListParams(BaseModel):
    """Query parameters for listing blog posts."""

    page: int = Field(default=1, ge=1, description="Page number (1-indexed)")
    page_size: int = Field(default=10, ge=1, le=50, description="Number of posts per page")
    category: Optional[str] = Field(None, description="Filter by category")
    search: Optional[str] = Field(None, description="Search in title and excerpt")


# =============================================================================
# MIGRATION MODEL (for importing static posts)
# =============================================================================


class BlogPostMigration(BaseModel):
    """Model for migrating static blog posts to database."""

    slug: str
    title: str
    excerpt: str
    content: str
    category: str
    date: str  # ISO format date string
    read_time: str
    emoji: str
    keywords: List[str]
    author: str
    author_title: Optional[str] = None
    is_published: bool = True
    featured_image_url: Optional[str] = None
