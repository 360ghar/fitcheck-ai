"""
Global admin search: GET /admin/search.

Top-5 hits each for users, blog posts, support tickets and promo codes
(case-insensitive contains via ilike).
"""

from fastapi import APIRouter, Depends, Query
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import AdminSearchResponse
from app.services.admin_service import search_all

router = APIRouter()


@router.get("/search", response_model=AdminSearchResponse)
async def search(
    q: str = Query(..., min_length=1, max_length=200),
    db: Client = Depends(get_db),
    user=Depends(require_permission("search")),
) -> AdminSearchResponse:
    """Search users, blog posts, support tickets and promo codes (top 5 each)."""
    result = await search_all(db, q)
    return AdminSearchResponse(**result)
