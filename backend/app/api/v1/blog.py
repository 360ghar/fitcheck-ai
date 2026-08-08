"""
Blog API endpoints for FitCheck AI.

Provides CRUD operations for blog posts with public read access
and admin-only write access.
"""

import asyncio
from typing import Any, Dict, Literal

from fastapi import APIRouter, Depends, Query, Response, status
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.exceptions import NotFoundError, PermissionDeniedError, ValidationError
from app.core.logging_config import get_context_logger
from app.models.blog import (
    BlogPost,
    BlogPostCreate,
    BlogPostListParams,
    BlogPostListResponse,
    BlogPostSummary,
    BlogPostUpdate,
)
from app.utils import maybe_single_data
from app.utils.db import safe_search_term

logger = get_context_logger(__name__)

router = APIRouter()


# =============================================================================
# ADMIN VERIFICATION
# =============================================================================


def verify_admin(user: Dict[str, Any]) -> None:
    """
    Verify that the user has admin privileges.

    Thin wrapper over the shared RBAC gate (app.core.permissions.get_user_role):
    an explicit admin ``role`` wins; otherwise the legacy ``is_admin`` flag
    grants admin (the email-domain bootstrap was removed 2026-08-08).
    """
    from app.core.permissions import ADMIN_ROLES, get_user_role

    if get_user_role(user) not in ADMIN_ROLES:
        logger.warning(f"Non-admin user {user.get('id')} attempted admin operation")
        raise PermissionDeniedError("Admin access required for this operation")


# =============================================================================
# PUBLIC ENDPOINTS
# =============================================================================

# Public blog content is static between deploys; let browsers (and any CDN in
# front of the API) serve it without a round trip for a few minutes. The
# client refetches on mount anyway (baked prerender data is stamped stale), so
# max-age only helps cold loads — the 2026-08-07 PSI measured this endpoint at
# 3.4 s on the mobile critical path.
BLOG_CACHE_CONTROL = "public, max-age=300, stale-while-revalidate=600"


@router.get("/posts", response_model=Dict[str, Any])
async def list_posts(
    params: BlogPostListParams = Depends(),
    db: Client = Depends(get_db),
    response: Response = None,
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

        # Apply pagination and execute ONCE: PostgREST returns the exact count
        # of the full filtered set alongside the page, so the previous
        # count-then-page pattern (two Supabase round trips) is halved. This
        # endpoint sat on the blog's mobile critical path (3.4 s in the
        # 2026-08-07 PSI run), so the round trip matters.
        offset = (params.page - 1) * params.page_size
        result = await asyncio.to_thread(
            query.range(offset, offset + params.page_size - 1).execute
        )
        total = result.count if hasattr(result, "count") else 0

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

        # Success path only: error responses must never inherit a cacheable
        # header (a cached 404 would linger for max-age after a post is
        # published).
        response.headers["Cache-Control"] = BLOG_CACHE_CONTROL
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
    response: Response = None,
):
    """
    Get a single blog post by slug.

    Returns the full blog post including content.
    Only returns published posts for public access.
    """
    try:
        result = await asyncio.to_thread(
            db.table("blog_posts")
            .select("*")
            .eq("slug", slug)
            .eq("is_published", True)
            .single()
            .execute
        )

        if not result.data:
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        post = BlogPost(**result.data)

        # Success path only — a NotFound 404 must not carry the cache header
        # (see list_posts).
        response.headers["Cache-Control"] = BLOG_CACHE_CONTROL
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
async def get_categories(
    db: Client = Depends(get_db),
    response: Response = None,
):
    """
    Get all unique categories from published blog posts.

    Returns a sorted list of category names.
    """
    try:
        # Get distinct categories from published posts
        result = await asyncio.to_thread(
            db.table("blog_posts")
            .select("category")
            .eq("is_published", True)
            .execute
        )

        categories = sorted(list(set(row["category"] for row in (result.data or []))))

        # Success path only (see list_posts).
        response.headers["Cache-Control"] = BLOG_CACHE_CONTROL
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
        existing = await asyncio.to_thread(
            db.table("blog_posts")
            .select("id")
            .eq("slug", post_data.slug)
            .maybe_single()
            .execute
        )

        if maybe_single_data(existing):
            raise ValidationError(
                message=f"A post with slug '{post_data.slug}' already exists",
                details={"field": "slug", "value": post_data.slug},
            )

        # Insert the new post
        insert_data = post_data.model_dump()
        result = await asyncio.to_thread(db.table("blog_posts").insert(insert_data).execute)

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
        existing = await asyncio.to_thread(
            db.table("blog_posts")
            .select("*")
            .eq("slug", slug)
            .maybe_single()
            .execute
        )

        if not maybe_single_data(existing):
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        # If changing slug, check new slug is unique
        if post_data.slug and post_data.slug != slug:
            slug_check = await asyncio.to_thread(
                db.table("blog_posts")
                .select("id")
                .eq("slug", post_data.slug)
                .maybe_single()
                .execute
            )

            if maybe_single_data(slug_check):
                raise ValidationError(
                    message=f"A post with slug '{post_data.slug}' already exists",
                    details={"field": "slug", "value": post_data.slug},
                )

        # Build update data - only fields the client actually sent, so a PATCH
        # that omits a field doesn't get conflated with explicitly clearing it.
        update_data = post_data.model_dump(exclude_unset=True)

        if not update_data:
            raise ValidationError(
                message="No fields provided for update",
                details={"fields": "At least one field must be provided"},
            )

        # Update the post
        result = await asyncio.to_thread(db.table("blog_posts").update(update_data).eq("slug", slug).execute)

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
        existing = await asyncio.to_thread(
            db.table("blog_posts")
            .select("id")
            .eq("slug", slug)
            .maybe_single()
            .execute
        )

        if not maybe_single_data(existing):
            raise NotFoundError(
                message=f"Blog post '{slug}' not found",
                resource_type="blog_post",
                resource_id=slug,
            )

        # Delete the post
        await asyncio.to_thread(db.table("blog_posts").delete().eq("slug", slug).execute)

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
    category: str | None = Query(None, min_length=1),
    search: str | None = Query(None, min_length=1),
    post_status: Literal["published", "draft", "all"] | None = Query(None, alias="status"),
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

        if category:
            query = query.eq("category", category)

        if search:
            # The term is interpolated into postgrest's .or_() filter syntax;
            # strip characters that would inject extra filter clauses (`,` ,
            # `(`, `)`, the `*` wildcard) or break the ilike value (`.` and
            # `:` are PostgREST-reserved separators) while keeping % and _ as
            # the intended ilike wildcards.
            safe_term = safe_search_term(search)
            search_term = f"%{safe_term}%"
            query = query.or_(
                f"title.ilike.{search_term},excerpt.ilike.{search_term},author.ilike.{search_term}"
            )

        if post_status == "published":
            query = query.eq("is_published", True)
        elif post_status == "draft":
            query = query.eq("is_published", False)

        # Order by updated_at descending
        query = query.order("updated_at", desc=True)

        # Get total count
        count_result = await asyncio.to_thread(query.execute)
        total = count_result.count if hasattr(count_result, "count") else 0

        # Apply pagination
        offset = (page - 1) * page_size
        query = query.range(offset, offset + page_size - 1)

        # Execute query
        result = await asyncio.to_thread(query.execute)

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
