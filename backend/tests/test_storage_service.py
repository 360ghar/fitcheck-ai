import io
import re
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.services.storage_service import DEFAULT_CACHE_CONTROL, StorageService
from tests.storage_test_utils import FakeS3Backend


def _valid_png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), (255, 255, 255)).save(buffer, format="PNG")
    return buffer.getvalue()


@pytest.mark.asyncio
async def test_upload_item_image_uses_s3_backend_and_returns_presigned_url():
    """upload_item_image now writes through the S3 backend (no db.storage.from_)
    and returns a presigned GET URL for the new {user_id}/items/ key layout."""
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.upload_item_image(
            db=MagicMock(),
            user_id="user-1",
            filename="shirt.jpg",
            file_data=_valid_png_bytes(),
        )

    assert len(backend.upload_calls) == 1
    call = backend.upload_calls[0]
    assert call["key"].startswith("user-1/items/")
    assert call["key"].endswith(".png")
    assert call["content_type"] == "image/png"
    assert call["cache_control"] == DEFAULT_CACHE_CONTROL

    assert result["image_url"].startswith("https://presigned.example/")
    assert result["thumbnail_url"] == result["image_url"]
    assert result["storage_path"] == call["key"]


def test_build_key_uses_user_category_and_uuid_without_timestamps():
    """The new key layout is {user_id}/{category}/{uuid4hex}.{ext} — no timestamps."""
    key = StorageService._build_key("user-1", "items", ".png")
    assert re.fullmatch(r"user-1/items/[0-9a-f]{32}\.png", key)

    # The extension is normalized to a leading dot.
    assert StorageService._build_key("u", "outfits", "webp").endswith(".webp")

    # uuid4 hex is random per call, so two builds differ.
    assert StorageService._build_key("user-1", "items", ".png") != key


@pytest.mark.asyncio
async def test_get_public_url_returns_presigned_url():
    """get_public_url is async and returns a short-lived presigned GET URL."""
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        url = await StorageService.get_public_url("user-1/items/abc.png")

    assert url == "https://presigned.example/user-1/items/abc.png"
    assert backend.presign_calls == ["user-1/items/abc.png"]


def test_key_from_path_handles_supabase_url_bare_key_and_s3_presigned_url(monkeypatch):
    monkeypatch.setattr("app.services.storage_service.settings.SUPABASE_STORAGE_BUCKET", "items")
    monkeypatch.setattr("app.services.storage_service.settings.OBJECT_STORAGE_BUCKET", "bucket")

    # Supabase public object URL -> key (bucket segment dropped).
    assert StorageService.key_from_path(
        "https://project.supabase.co/storage/v1/object/public/items/user-a/item.webp"
    ) == "user-a/item.webp"

    # S3 presigned URL (query string ignored) -> key.
    assert StorageService.key_from_path(
        "https://storage.railway.app/bucket/user-a/items/item.webp?X-Amz-Signature=abc"
    ) == "user-a/items/item.webp"

    # A bare bucket key passes through unchanged.
    assert StorageService.key_from_path("user-a/items/item.webp") == "user-a/items/item.webp"

    # Empty / None -> None.
    assert StorageService.key_from_path("") is None
    assert StorageService.key_from_path(None) is None
