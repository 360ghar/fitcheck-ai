"""Residual branch coverage for app.api.v1.images.

The sibling test_read_path_url_materialization.py covers the main
materialization paths; this file covers the remaining guards: ownership
validation input shapes, avatar materialization branches, gather-failure
skip semantics, the url-field sync, and the presigned endpoint.
"""

from unittest.mock import AsyncMock

import pytest

from app.api.v1.images import (
    _is_owned_by_user,
    get_presigned_url,
    materialize_avatar_url,
    materialize_image_urls,
    materialize_parent_images,
    serve_url,
)
from app.core.exceptions import NotFoundError
from app.services.storage_service import StorageService


USER = "11111111-1111-1111-1111-111111111111"
OWNED_KEY = f"{USER}/items/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg"


def test_is_owned_by_user_rejects_non_string_inputs():
    assert _is_owned_by_user(None, USER) is False
    assert _is_owned_by_user(OWNED_KEY, None) is False


def test_is_owned_by_user_rejects_backslashes_and_dotdot():
    assert _is_owned_by_user(f"{USER}\\items\\x.jpg", USER) is False
    assert _is_owned_by_user(f"../{USER}/items/x.jpg", USER) is False
    assert _is_owned_by_user(f" {OWNED_KEY}", USER) is False


def test_is_owned_by_user_accepts_all_key_shapes():
    thumb = f"{USER}/items/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa_thumb.webp"
    nested = f"generated/{USER}/tryon/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.png"
    legacy = f"{USER}/generated/tryon/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.png"
    assert _is_owned_by_user(OWNED_KEY, USER) is True
    assert _is_owned_by_user(thumb, USER) is True
    assert _is_owned_by_user(nested, USER) is True
    assert _is_owned_by_user(legacy, USER) is True
    # Same shape, different owner -> not owned.
    other = "22222222-2222-2222-2222-222222222222/items/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.jpg"
    assert _is_owned_by_user(other, USER) is False


def test_materialize_avatar_url_none_and_foreign_urls(monkeypatch):
    assert __import__("asyncio").run(materialize_avatar_url(None)) is None
    assert __import__("asyncio").run(materialize_avatar_url(12345)) is None

    async def _run():
        # Legacy public URL / OAuth picture -> not ours -> None.
        assert await materialize_avatar_url("https://example.com/pic.jpg") is None
        # Bare key without a UUID first segment -> None.
        assert await materialize_avatar_url("items/abc.jpg") is None
        # Our own object -> materialized.
        monkeypatch.setattr(
            StorageService, "get_public_url", AsyncMock(side_effect=lambda key: f"https://cdn/{key}")
        )
        url = await materialize_avatar_url(OWNED_KEY)
        assert url == f"https://cdn/{OWNED_KEY}"
        # presigned=True forces a signed URL.
        signed = await materialize_avatar_url(OWNED_KEY, presigned=True)
        assert signed == f"https://cdn/{OWNED_KEY}"

    __import__("asyncio").run(_run())


def test_serve_url_worker_mode(monkeypatch):
    monkeypatch.setattr(
        "app.api.v1.images.settings.IMAGE_SERVING_MODE", "worker"
    )
    monkeypatch.setattr(
        "app.api.v1.images.settings.IMAGE_CDN_BASE_URL", "https://img.example.com/"
    )
    assert __import__("asyncio").run(serve_url("u1/items/x.jpg")) == (
        "https://img.example.com/u1/items/x.jpg"
    )


def test_materialize_image_urls_empty_and_url_sync(monkeypatch):
    import asyncio

    assert asyncio.run(materialize_image_urls([])) == []

    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAIL_SERVING", True)
    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAILS_BACKFILLED", True)
    monkeypatch.setattr(
        "app.api.v1.images.StorageService.thumb_key_for",
        lambda key: key.replace(".jpg", "_thumb.webp"),
    )
    monkeypatch.setattr(
        "app.api.v1.images.serve_url",
        AsyncMock(side_effect=lambda key: f"https://cdn/{key}"),
    )

    images = [{"storage_path": OWNED_KEY, "url": "stale"}]
    asyncio.run(materialize_image_urls(images))
    assert images[0]["image_url"] == f"https://cdn/{OWNED_KEY}"
    assert images[0]["thumbnail_url"] == f"https://cdn/{OWNED_KEY.replace('.jpg', '_thumb.webp')}"
    # The Flutter-compat url field follows the fresh URLs.
    assert images[0]["url"] == images[0]["image_url"]


def test_materialize_image_urls_skips_failed_key(monkeypatch):
    import asyncio

    async def _failing(key):
        raise RuntimeError("presign failed")

    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAIL_SERVING", False)
    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAILS_BACKFILLED", False)
    monkeypatch.setattr("app.api.v1.images.serve_url", AsyncMock(side_effect=_failing))

    images = [{"storage_path": OWNED_KEY, "image_url": "old"}]
    asyncio.run(materialize_image_urls(images))
    # Failed key leaves the row untouched (old url preserved).
    assert images[0]["image_url"] == "old"


def test_materialize_image_urls_leaves_rows_without_storage_path(monkeypatch):
    import asyncio

    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAIL_SERVING", True)
    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAILS_BACKFILLED", True)

    images = [{"image_url": "https://legacy/x.jpg"}, "not-a-dict"]
    asyncio.run(materialize_image_urls(images))
    assert images[0]["image_url"] == "https://legacy/x.jpg"


def test_materialize_parent_images_nested(monkeypatch):
    import asyncio

    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAIL_SERVING", False)
    monkeypatch.setattr("app.api.v1.images.settings.THUMBNAILS_BACKFILLED", False)
    monkeypatch.setattr("app.api.v1.images.serve_url", AsyncMock(side_effect=lambda key: f"https://cdn/{key}"))

    parents = [
        {"images": [{"storage_path": OWNED_KEY}]},
        "not-a-dict",
        {"images": [], "items": [{"images": [{"storage_path": OWNED_KEY}]}, "skip"]},
    ]
    asyncio.run(materialize_parent_images(parents))
    assert parents[0]["images"][0]["image_url"].startswith("https://cdn/")
    assert parents[2]["items"][0]["images"][0]["image_url"].startswith("https://cdn/")
    # Non-dict entries were left alone.
    assert parents[1] == "not-a-dict"


def test_get_presigned_url_ownership_and_success(monkeypatch):
    import asyncio

    monkeypatch.setattr("app.api.v1.images.serve_url", AsyncMock(side_effect=lambda key: f"https://cdn/{key}"))

    async def _run():
        with pytest.raises(NotFoundError):
            await get_presigned_url(
                storage_path="22222222-2222-2222-2222-222222222222/items/x.jpg",
                user_id=USER,
            )
        result = await get_presigned_url(storage_path=OWNED_KEY, user_id=USER)
        assert result["data"]["url"] == f"https://cdn/{OWNED_KEY}"
        assert result["data"]["storage_path"] == OWNED_KEY

    asyncio.run(_run())
