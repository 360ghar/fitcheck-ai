"""
Blog API endpoints for FitCheck AI.

Provides CRUD operations for blog posts with public read access
and admin-only write access.
"""

import logging
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.config import settings
from app.core.exceptions import NotFoundError, PermissionDeniedError, ValidationError
from app.models.blog import (
    BlogPost,
    BlogPostCreate,
    BlogPostCategoriesResponse,
    BlogPostListParams,
    BlogPostListResponse,
    BlogPostSummary,
    BlogPostUpdate,
)

logger = logging.getLogger(__name__)

router = APIRouter()


# =============================================================================
# ADMIN VERIFICATION
# =============================================================================


def verify_admin(user: Dict[str, Any]) -> None:
    """
    Verify that the user has admin privileges.

    Admin check is based on email domain or specific admin flag.
    Adjust logic based on your admin requirements.
    """
    # Check for admin flag in user metadata
    is_admin = user.get("is_admin", False)

    # Or check email domain (example: only @fitcheckaiapp.com emails are admins)
    email = user.get("email", "")
    if email and email.endswith("@fitcheckaiapp.com"):
        is_admin = True

    if not is_admin:
        logger.warning(f"Non-admin user {user.get('id')} attempted admin operation")
        raise PermissionDeniedError("Admin access required for this operation")


# =============================================================================
# PUBLIC ENDPOINTS
# =============================================================================


@router.get("/posts", response_model=Dict[str, Any])
async def list_posts(
    params: BlogPostListParams = Depends(),
    db: Client = Depends(get_db),
):
    """
    List all published blog posts with pagination.

    Returns paginated list of blog post summaries.
    Supports filtering by category and searching by title/excerpt.
    """
    try:
        # Build base query for published posts
        query = db.table("blog_posts").select("*", count="exact").eq("is_published", True)

        # Apply category filter
        if params.category:
            query = query.eq("category", params.category)

        # Apply search filter
        if params.search:
            # Search in title and excerpt (case-insensitive)
            search_term = f"%{params.search}%"
            query = query.or_(f"title.ilike.{search_term},excerpt.ilike.{search_term}")

        # Order by date descending (newest first)
        query = query.order("date", desc=True)

        # Get total count first
        count_result = query.execute()
        total = count_result.count if hasattr(count_result, "count") else 0

        # Apply pagination
        offset = (params.page - 1) * params.page_size
        query = query.range(offset, offset + params.page_size - 1)

        # Execute query
        result = query.execute()

        # Convert to response models
        posts = [BlogPostSummary(**post) for post in (result.data or [])]

        # Calculate pagination metadata
        total_pages = (total + params.page_size - 1) // params.page_size if total > 0 else 1

        response_data = BlogPostListResponse(
            posts=posts,
            total=total,
            page=params.page,
            page_size=params.page_size,
            total_pages=total_pages,
            has_next=params.page < total_pages,
            has_prev=params.page > 1,
        )

        return {
            "data": response_data.model_dump(mode="json"),
            "message": "OK",
        }

    except Exception as e:
        logger.error(f"Error listing blog posts: {e}")
        raise


@router.get("/posts/{slug}", response_model=Dict[str, Any])
async def get_post(
    slug: str,
    db: Client = Depends(get_db),
):
    """
    Get a single blog post by slug.

    Returns the full blog post including content.
    Only returns published posts for public access.
    """
    try:
        result = (
            db.table("blog_posts")
            .select("*")
            .eq("slug", slug)
            .eq("is_published", True)
            .single()
            .execute()
        )

        if not result.data:
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        post = BlogPost(**result.data)

        return {
            "data": post.model_dump(mode="json"),
            "message": "OK",
        }

    except NotFoundError:
        raise
    except Exception as e:
        logger.error(f"Error fetching blog post {slug}: {e}")
        raise


@router.get("/categories", response_model=Dict[str, Any])
async def get_categories(db: Client = Depends(get_db)):
    """
    Get all unique categories from published blog posts.

    Returns a sorted list of category names.
    """
    try:
        # Get distinct categories from published posts
        result = (
            db.table("blog_posts")
            .select("category")
            .eq("is_published", True)
            .execute()
        )

        categories = sorted(list(set(row["category"] for row in (result.data or []))))

        return {
            "data": {"categories": categories},
            "message": "OK",
        }

    except Exception as e:
        logger.error(f"Error fetching blog categories: {e}")
        raise


# =============================================================================
# ADMIN ENDPOINTS
# =============================================================================


@router.post("/posts", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_post(
    post_data: BlogPostCreate,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Create a new blog post.

    **Admin only.** Creates a new blog post with the provided data.
    Slug must be unique.
    """
    verify_admin(user)

    try:
        # Check for duplicate slug
        existing = (
            db.table("blog_posts")
            .select("id")
            .eq("slug", post_data.slug)
            .maybe_single()
            .execute()
        )

        if existing.data:
            raise ValidationError(
                message=f"A post with slug '{post_data.slug}' already exists",
                details={"field": "slug", "value": post_data.slug},
            )

        # Insert the new post
        insert_data = post_data.model_dump()
        result = db.table("blog_posts").insert(insert_data).execute()

        if not result.data:
            raise Exception("Failed to create blog post")

        created_post = BlogPost(**result.data[0])

        logger.info(f"Admin {user.get('id')} created blog post: {post_data.slug}")

        return {
            "data": created_post.model_dump(mode="json"),
            "message": "Blog post created successfully",
        }

    except ValidationError:
        raise
    except Exception as e:
        logger.error(f"Error creating blog post: {e}")
        raise


@router.put("/posts/{slug}", response_model=Dict[str, Any])
async def update_post(
    slug: str,
    post_data: BlogPostUpdate,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Update an existing blog post.

    **Admin only.** Updates the blog post identified by slug.
    If slug is being changed, the new slug must be unique.
    """
    verify_admin(user)

    try:
        # Check if post exists
        existing = (
            db.table("blog_posts")
            .select("*")
            .eq("slug", slug)
            .maybe_single()
            .execute()
        )

        if not existing.data:
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        # If changing slug, check new slug is unique
        if post_data.slug and post_data.slug != slug:
            slug_check = (
                db.table("blog_posts")
                .select("id")
                .eq("slug", post_data.slug)
                .maybe_single()
                .execute()
            )

            if slug_check.data:
                raise ValidationError(
                    message=f"A post with slug '{post_data.slug}' already exists",
                    details={"field": "slug", "value": post_data.slug},
                )

        # Build update data (exclude None values)
        update_data = {k: v for k, v in post_data.model_dump().items() if v is not None}

        if not update_data:
            raise ValidationError(
                message="No fields provided for update",
                details={"fields": "At least one field must be provided"},
            )

        # Update the post
        result = db.table("blog_posts").update(update_data).eq("slug", slug).execute()

        if not result.data:
            raise Exception("Failed to update blog post")

        updated_post = BlogPost(**result.data[0])

        logger.info(f"Admin {user.get('id')} updated blog post: {slug}")

        return {
            "data": updated_post.model_dump(mode="json"),
            "message": "Blog post updated successfully",
        }

    except (NotFoundError, ValidationError):
        raise
    except Exception as e:
        logger.error(f"Error updating blog post {slug}: {e}")
        raise


@router.delete("/posts/{slug}", response_model=Dict[str, Any])
async def delete_post(
    slug: str,
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Delete a blog post.

    **Admin only.** Permanently deletes the blog post identified by slug.
    This action cannot be undone.
    """
    verify_admin(user)

    try:
        # Check if post exists
        existing = (
            db.table("blog_posts")
            .select("id")
            .eq("slug", slug)
            .maybe_single()
            .execute()
        )

        if not existing.data:
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        # Delete the post
        db.table("blog_posts").delete().eq("slug", slug).execute()

        logger.info(f"Admin {user.get('id')} deleted blog post: {slug}")

        return {
            "data": {"slug": slug, "deleted": True},
            "message": "Blog post deleted successfully",
        }

    except NotFoundError:
        raise
    except Exception as e:
        logger.error(f"Error deleting blog post {slug}: {e}")
        raise


# =============================================================================
# ADMIN LIST ENDPOINT (includes unpublished posts)
# =============================================================================


@router.get("/admin/posts", response_model=Dict[str, Any])
async def list_all_posts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    include_unpublished: bool = Query(True),
    user=Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    List all blog posts including unpublished ones.

    **Admin only.** Returns all blog posts with pagination.
    Useful for content management.
    """
    verify_admin(user)

    try:
        # Build query - include all posts
        query = db.table("blog_posts").select("*", count="exact")

        if not include_unpublished:
            query = query.eq("is_published", True)

        # Order by updated_at descending
        query = query.order("updated_at", desc=True)

        # Get total count
        count_result = query.execute()
        total = count_result.count if hasattr(count_result, "count") else 0

        # Apply pagination
        offset = (page - 1) * page_size
        query = query.range(offset, offset + page_size - 1)

        # Execute query
        result = query.execute()

        # Convert to response models (use full BlogPost for admin)
        posts = [BlogPost(**post) for post in (result.data or [])]

        # Calculate pagination
        total_pages = (total + page_size - 1) // page_size if total > 0 else 1

        return {
            "data": {
                "posts": [post.model_dump(mode="json") for post in posts],
                "total": total,
                "page": page,
                "page_size": page_size,
                "total_pages": total_pages,
                "has_next": page < total_pages,
                "has_prev": page > 1,
            },
            "message": "OK",
        }

    except Exception as e:
        logger.error(f"Error listing all blog posts: {e}")
        raise
