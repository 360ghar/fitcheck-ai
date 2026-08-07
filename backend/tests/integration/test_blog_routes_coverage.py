"""
Coverage for blog route branches the sibling test_blog_api.py misses.

Siblings cover the public list/get/categories success paths + cache headers
and the get-post NotFound path. This file covers verify_admin (allow + deny),
the public error branches, and the full admin surface: create/update/delete
posts and the admin list-all endpoint, including duplicate-slug, empty-update,
empty-write-result and generic-error branches.

All routes are called DIRECTLY with FakeDB / patched query builders — no HTTP
and no real DB. Query()-defaulted parameters are passed explicitly because a
bare Query object is truthy outside FastAPI's dependency resolution.
"""
from unittest.mock import Mock

import pytest
from fastapi import Response

import app.api.v1.blog as blog_module
from app.api.v1.blog import verify_admin
from app.core.exceptions import NotFoundError, PermissionDeniedError, ValidationError
from app.models.blog import BlogPostCreate, BlogPostListParams, BlogPostUpdate
from tests.utils.fake_db import FakeBuilder, FakeDB, FakeResult

ADMIN = {"id": "admin-1", "role": "admin"}
CACHE_CONTROL = "public, max-age=300, stale-while-revalidate=600"


def _post_row(slug="first-post", **overrides):
    row = {
        "id": "11111111-1111-1111-1111-111111111111",
        "slug": slug,
        "title": "Test Post",
        "excerpt": "Excerpt",
        "content": "Full markdown content",
        "category": "Style Guide",
        "date": "2026-08-01",
        "read_time": "5 min read",
        "emoji": "x",
        "keywords": ["style"],
        "author": "FitCheck AI",
        "author_title": None,
        "featured_image_url": None,
        "is_published": True,
        "created_at": "2026-08-01T00:00:00Z",
        "updated_at": "2026-08-01T00:00:00Z",
    }
    row.update(overrides)
    return row


def _create_data(slug="new-post"):
    return BlogPostCreate(
        slug=slug,
        title="New Post",
        excerpt="Excerpt",
        content="Content",
        category="Style Guide",
        date="2026-08-02",
        read_time="3 min read",
        emoji="y",
        keywords=["new", "style"],
        author="FitCheck AI",
    )


def _write_defaults():
    return {
        "id": "22222222-2222-2222-2222-222222222222",
        "created_at": "2026-08-02T00:00:00Z",
        "updated_at": "2026-08-02T00:00:00Z",
    }


class _EmptyInsertBuilder(FakeBuilder):
    """Insert returns zero rows (PostgREST echo empty) — for write-failure paths."""

    def execute(self):
        if self._mode == "insert":
            return FakeResult(data=[])
        return super().execute()


class _EmptyUpdateBuilder(FakeBuilder):
    """Update returns zero rows — for write-failure paths."""

    def execute(self):
        if self._mode == "update":
            return FakeResult(data=[])
        return super().execute()


class _EmptyInsertDB(FakeDB):
    def table(self, name):
        return _EmptyInsertBuilder(self, name)


class _EmptyUpdateDB(FakeDB):
    def table(self, name):
        return _EmptyUpdateBuilder(self, name)


def _failing_db(error=None):
    """A FakeDB whose every execute call raises (generic error branches)."""
    error = error or RuntimeError("db boom")
    db = FakeDB(rows={})
    original_table = db.table

    def table(name):
        builder = original_table(name)
        builder.execute = Mock(side_effect=error)
        return builder

    db.table = table
    return db


# =============================================================================
# verify_admin
# =============================================================================


def test_verify_admin_allows_explicit_admin_role():
    verify_admin({"id": "admin-1", "role": "admin"})


def test_verify_admin_allows_legacy_is_admin_flag():
    verify_admin({"id": "admin-1", "is_admin": True})


def test_verify_admin_allows_fitcheck_email():
    verify_admin({"id": "admin-1", "email": "editor@fitcheckaiapp.com"})


def test_verify_admin_denies_plain_user():
    with pytest.raises(PermissionDeniedError):
        verify_admin({"id": "user-1", "role": "user"})


# =============================================================================
# PUBLIC ENDPOINTS — error branches (success paths live in test_blog_api.py)
# =============================================================================


@pytest.mark.asyncio
async def test_list_posts_error_propagates_without_cache_header():
    db = _failing_db()
    response = Response()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.list_posts(
            params=BlogPostListParams(page=1, page_size=10),
            db=db,
            response=response,
        )

    assert "Cache-Control" not in response.headers


@pytest.mark.asyncio
async def test_list_posts_success_with_fake_db_filters():
    db = FakeDB(
        rows={
            "blog_posts": [
                _post_row("jeans-guide", title="Jeans Guide"),
                _post_row("other", title="Other Post"),
            ]
        }
    )
    response = Response()

    result = await blog_module.list_posts(
        params=BlogPostListParams(page=1, page_size=10, category="Style Guide", search="jeans"),
        db=db,
        response=response,
    )

    assert result["message"] == "OK"
    assert result["data"]["total"] == 1
    assert result["data"]["posts"][0]["slug"] == "jeans-guide"
    assert result["data"]["has_next"] is False
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_get_post_success_with_fake_db():
    db = FakeDB(rows={"blog_posts": [_post_row("some-post")]})
    response = Response()

    result = await blog_module.get_post(slug="some-post", db=db, response=response)

    assert result["data"]["slug"] == "some-post"
    assert result["data"]["content"] == "Full markdown content"
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_get_post_generic_error_propagates():
    db = _failing_db()
    response = Response()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.get_post(slug="some-post", db=db, response=response)

    assert "Cache-Control" not in response.headers


@pytest.mark.asyncio
async def test_get_categories_success_with_fake_db():
    db = FakeDB(
        rows={
            "blog_posts": [
                {"category": "Trends", "is_published": True},
                {"category": "Style Guide", "is_published": True},
                {"category": "Trends", "is_published": True},
            ]
        }
    )
    response = Response()

    result = await blog_module.get_categories(db=db, response=response)

    assert result["data"]["categories"] == ["Style Guide", "Trends"]
    assert response.headers["Cache-Control"] == CACHE_CONTROL


@pytest.mark.asyncio
async def test_get_categories_error_propagates():
    db = _failing_db()
    response = Response()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.get_categories(db=db, response=response)

    assert "Cache-Control" not in response.headers


# =============================================================================
# ADMIN: create_post
# =============================================================================


@pytest.mark.asyncio
async def test_create_post_success():
    db = FakeDB(rows={}, insert_defaults=_write_defaults())

    result = await blog_module.create_post(post_data=_create_data(), user=ADMIN, db=db)

    assert result["message"] == "Blog post created successfully"
    assert result["data"]["slug"] == "new-post"
    assert result["data"]["id"] == "22222222-2222-2222-2222-222222222222"
    db.assert_insert("blog_posts", slug="new-post", author="FitCheck AI")


@pytest.mark.asyncio
async def test_create_post_duplicate_slug_rejected():
    db = FakeDB(rows={"blog_posts": [_post_row("new-post")]})

    with pytest.raises(ValidationError):
        await blog_module.create_post(post_data=_create_data("new-post"), user=ADMIN, db=db)


@pytest.mark.asyncio
async def test_create_post_empty_insert_result_raises():
    db = _EmptyInsertDB(rows={})

    with pytest.raises(Exception, match="Failed to create blog post"):
        await blog_module.create_post(post_data=_create_data(), user=ADMIN, db=db)


@pytest.mark.asyncio
async def test_create_post_generic_error_propagates():
    db = _failing_db()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.create_post(post_data=_create_data(), user=ADMIN, db=db)


@pytest.mark.asyncio
async def test_create_post_denied_for_non_admin():
    db = FakeDB(rows={})

    with pytest.raises(PermissionDeniedError):
        await blog_module.create_post(post_data=_create_data(), user={"id": "u1", "role": "user"}, db=db)


# =============================================================================
# ADMIN: update_post
# =============================================================================


@pytest.mark.asyncio
async def test_update_post_success():
    db = FakeDB(rows={"blog_posts": [_post_row("first-post")]})

    result = await blog_module.update_post(
        slug="first-post", post_data=BlogPostUpdate(title="Updated Title"), user=ADMIN, db=db
    )

    assert result["message"] == "Blog post updated successfully"
    assert result["data"]["title"] == "Updated Title"
    assert result["data"]["slug"] == "first-post"
    db.assert_update("blog_posts", title="Updated Title")


@pytest.mark.asyncio
async def test_update_post_not_found():
    db = FakeDB(rows={})

    with pytest.raises(NotFoundError):
        await blog_module.update_post(
            slug="missing", post_data=BlogPostUpdate(title="X"), user=ADMIN, db=db
        )


@pytest.mark.asyncio
async def test_update_post_slug_change_duplicate_rejected():
    db = FakeDB(
        rows={
            "blog_posts": [
                _post_row("first-post"),
                _post_row("other-post", id="33333333-3333-3333-3333-333333333333"),
            ]
        }
    )

    with pytest.raises(ValidationError):
        await blog_module.update_post(
            slug="first-post", post_data=BlogPostUpdate(slug="other-post"), user=ADMIN, db=db
        )


@pytest.mark.asyncio
async def test_update_post_slug_change_to_unique_slug():
    db = FakeDB(
        rows={
            "blog_posts": [
                _post_row("first-post"),
                _post_row("other-post", id="33333333-3333-3333-3333-333333333333"),
            ]
        }
    )

    result = await blog_module.update_post(
        slug="first-post", post_data=BlogPostUpdate(slug="renamed-post"), user=ADMIN, db=db
    )

    assert result["message"] == "Blog post updated successfully"
    assert result["data"]["slug"] == "renamed-post"


@pytest.mark.asyncio
async def test_update_post_empty_update_rejected():
    db = FakeDB(rows={"blog_posts": [_post_row("first-post")]})

    with pytest.raises(ValidationError):
        await blog_module.update_post(
            slug="first-post", post_data=BlogPostUpdate(), user=ADMIN, db=db
        )


@pytest.mark.asyncio
async def test_update_post_empty_update_result_raises():
    db = _EmptyUpdateDB(rows={"blog_posts": [_post_row("first-post")]})

    with pytest.raises(Exception, match="Failed to update blog post"):
        await blog_module.update_post(
            slug="first-post", post_data=BlogPostUpdate(title="X"), user=ADMIN, db=db
        )


@pytest.mark.asyncio
async def test_update_post_generic_error_propagates():
    db = _failing_db()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.update_post(
            slug="first-post", post_data=BlogPostUpdate(title="X"), user=ADMIN, db=db
        )


# =============================================================================
# ADMIN: delete_post
# =============================================================================


@pytest.mark.asyncio
async def test_delete_post_success():
    db = FakeDB(rows={"blog_posts": [_post_row("first-post")]})

    result = await blog_module.delete_post(slug="first-post", user=ADMIN, db=db)

    assert result["message"] == "Blog post deleted successfully"
    assert result["data"] == {"slug": "first-post", "deleted": True}
    assert db.deletes == [("blog_posts", None)]


@pytest.mark.asyncio
async def test_delete_post_not_found():
    db = FakeDB(rows={})

    with pytest.raises(NotFoundError):
        await blog_module.delete_post(slug="missing", user=ADMIN, db=db)


@pytest.mark.asyncio
async def test_delete_post_generic_error_propagates():
    db = _failing_db()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.delete_post(slug="first-post", user=ADMIN, db=db)


# =============================================================================
# ADMIN: list_all_posts
# =============================================================================


@pytest.mark.asyncio
async def test_list_all_posts_success_with_filters():
    db = FakeDB(
        rows={
            "blog_posts": [
                _post_row("published-jeans", title="Jeans Guide"),
                _post_row("draft-post", is_published=False, updated_at="2026-08-03T00:00:00Z"),
                _post_row("other", category="Trends"),
            ]
        }
    )

    result = await blog_module.list_all_posts(
        page=1,
        page_size=20,
        include_unpublished=False,
        category="Style Guide",
        search="jeans",
        post_status=None,
        user=ADMIN,
        db=db,
    )

    assert result["message"] == "OK"
    assert result["data"]["total"] == 1
    assert result["data"]["posts"][0]["slug"] == "published-jeans"
    assert result["data"]["has_next"] is False
    assert result["data"]["has_prev"] is False


@pytest.mark.asyncio
async def test_list_all_posts_draft_status_and_pagination():
    db = FakeDB(
        rows={
            "blog_posts": [
                _post_row("draft-1", is_published=False),
                _post_row("draft-2", is_published=False),
                _post_row("live", is_published=True),
            ]
        }
    )

    result = await blog_module.list_all_posts(
        page=2,
        page_size=2,
        include_unpublished=True,
        category=None,
        search=None,
        post_status="draft",
        user=ADMIN,
        db=db,
    )

    assert result["data"]["total"] == 2
    assert result["data"]["total_pages"] == 1
    assert result["data"]["posts"] == []
    assert result["data"]["has_prev"] is True


@pytest.mark.asyncio
async def test_list_all_posts_published_status():
    db = FakeDB(rows={"blog_posts": [_post_row("live"), _post_row("draft", is_published=False)]})

    result = await blog_module.list_all_posts(
        page=1,
        page_size=20,
        include_unpublished=True,
        category=None,
        search=None,
        post_status="published",
        user=ADMIN,
        db=db,
    )

    assert result["data"]["total"] == 1
    assert result["data"]["posts"][0]["slug"] == "live"


@pytest.mark.asyncio
async def test_list_all_posts_generic_error_propagates():
    db = _failing_db()

    with pytest.raises(RuntimeError, match="db boom"):
        await blog_module.list_all_posts(
            page=1,
            page_size=20,
            include_unpublished=True,
            category=None,
            search=None,
            post_status=None,
            user=ADMIN,
            db=db,
        )


@pytest.mark.asyncio
async def test_list_all_posts_denied_for_non_admin():
    db = FakeDB(rows={})

    with pytest.raises(PermissionDeniedError):
        await blog_module.list_all_posts(
            page=1,
            page_size=20,
            include_unpublished=True,
            category=None,
            search=None,
            post_status=None,
            user={"id": "u1", "role": "user"},
            db=db,
        )
