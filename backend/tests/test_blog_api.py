"""Public blog endpoints: caching headers + single-round-trip pagination.

Found during the 2026-08-07 /blog PageSpeed RCA: `GET /api/v1/blog/posts`
cost 3.4 s on the mobile critical path, partly because `list_posts` ran TWO
Supabase round trips per request (a count query, then the page query).
PostgREST returns the exact count of the full filtered set alongside any page,
so one execute suffices. The public endpoints also now send `Cache-Control`
so browsers/CDNs can serve repeat requests without hitting the API.
"""
from unittest.mock import Mock

import pytest
from fastapi import Response

from app.api.v1 import blog as blog_module
from app.core.exceptions import NotFoundError
from app.models.blog import BlogPostListParams

USER_ID = "11111111-1111-1111-1111-111111111111"
CACHE_CONTROL = "public, max-age=300, stale-while-revalidate=600"


def _post_row(slug: str) -> dict:
    return {
        "id": "11111111-1111-1111-1111-111111111111",
        "slug": slug,
        "title": "Test Post",
        "excerpt": "Excerpt",
        "content": "Full markdown content",
        "category": "Style Guide",
        "date": "2026-08-01",
        "read_time": "5 min read",
        "emoji": "👖",
        "keywords": ["style"],
        "author": "FitCheck AI",
        "author_title": None,
        "featured_image_url": None,
        "created_at": "2026-08-01T00:00:00Z",
        "updated_at": "2026-08-01T00:00:00Z",
    }


def _chain_db(data, count=1):
    """A Supabase query chain where every builder returns the same query mock.

    `db.table(...).select(...).eq(...).order(...).range(...).execute` must
    resolve to one `execute` call returning an object with `.data` / `.count`.
    """
    query = Mock()
    query.data = data
    query.count = count
    query.select.return_value = query
    query.eq.return_value = query
    query.or_.return_value = query
    query.order.return_value = query
    query.range.return_value = query
    query.execute.return_value = query
    db = Mock()
    db.table.return_value = query
    return db, query


@pytest.mark.asyncio
async def test_list_posts_single_round_trip_and_cache_header():
    db, query = _chain_db([_post_row("first-post"), _post_row("second-post")], count=2)
    response = Response()

    result = await blog_module.list_posts(
        params=BlogPostListParams(page=1, page_size=12),
        db=db,
        response=response,
    )

    # The 2026-08-07 fix: exactly one execute (count + page in one request).
    assert query.execute.call_count == 1
    # Pagination applied before the single execute.
    query.range.assert_called_once_with(0, 11)
    # Count comes from the same response as the page.
    assert result["data"]["total"] == 2
    assert result["data"]["has_next"] is False
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_list_posts_applies_filters_and_page_two():
    db, query = _chain_db([_post_row("third-post")], count=25)
    response = Response()

    result = await blog_module.list_posts(
        params=BlogPostListParams(page=2, page_size=12, category="Style Guide", search="jeans"),
        db=db,
        response=response,
    )

    assert query.execute.call_count == 1
    query.range.assert_called_once_with(12, 23)
    assert result["data"]["total"] == 25
    assert result["data"]["has_next"] is True
    assert result["data"]["has_prev"] is True
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_categories_sorted_unique_and_cached():
    db, query = _chain_db(
        [
            {"category": "Trends"},
            {"category": "Style Guide"},
            {"category": "Trends"},
            {"category": "Men"},
        ]
    )
    response = Response()

    result = await blog_module.get_categories(db=db, response=response)

    assert query.execute.call_count == 1
    assert result["data"]["categories"] == ["Men", "Style Guide", "Trends"]
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_get_post_sets_cache_header():
    # get_post uses `.single()` and expects a row DICT (not a list) back.
    single_result = Mock()
    single_result.data = _post_row("some-post")
    query = Mock()
    query.select.return_value = query
    query.eq.return_value = query
    query.single.return_value = query
    query.execute.return_value = single_result
    db = Mock()
    db.table.return_value = query
    response = Response()

    result = await blog_module.get_post(slug="some-post", db=db, response=response)

    assert result["data"]["slug"] == "some-post"
    assert query.execute.call_count == 1
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_get_post_missing_is_not_cacheable():
    """A 404 must never carry the public cache header.

    With the header set at the top of the handler, a not-found response would
    be cached for max-age=300 — a stale 404 for a slug that gets published in
    that window. The header is applied on the success path only.
    """
    single_result = Mock()
    single_result.data = None
    query = Mock()
    query.select.return_value = query
    query.eq.return_value = query
    query.single.return_value = query
    query.execute.return_value = single_result
    db = Mock()
    db.table.return_value = query
    response = Response()

    with pytest.raises(NotFoundError):
        await blog_module.get_post(slug="missing-post", db=db, response=response)

    assert "Cache-Control" not in response.headers
