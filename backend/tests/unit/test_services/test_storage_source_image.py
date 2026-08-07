"""
Tests for StorageService.upload_source_image and download_to_base64.
"""

import io
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.core.config import settings
from app.services.storage_service import StorageService
from tests.utils.fake_storage import FakeS3Backend


def _image_bytes(format_name: str) -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), (240, 240, 240)).save(buffer, format=format_name)
    return buffer.getvalue()


def _webp_bytes() -> bytes:
    buffer = io.BytesIO()
    # Already WebP within the storage max edge: the compression chokepoint
    # returns it unchanged (keep-smaller), so the extension/content-type are
    # deterministic in tests.
    Image.new("RGBA", (64, 64), (1, 2, 3, 128)).save(buffer, format="WEBP", quality=75)
    return buffer.getvalue()


@pytest.mark.asyncio
async def test_upload_source_image_uses_user_namespace_and_returns_url():
    """upload_source_image should drop the file under {user_id}/sources/ and
    return both the public URL and storage path."""
    captured: dict = {}

    async def fake_upload_file(*, db, file_data, file_path, content_type, **_):
        captured.update(file_path=file_path, content_type=content_type, file_data=file_data)
        return {
            "public_url": f"https://storage.test/{file_path}",
            "storage_path": file_path,
            "bucket": "items",
        }

    fake_db = MagicMock()
    payload = _webp_bytes()

    with patch.object(StorageService, "upload_file", fake_upload_file):
        result = await StorageService.upload_source_image(
            db=fake_db,
            user_id="user-42",
            file_data=payload,
            extension=".jpg",
        )

    assert result["image_url"].startswith("https://storage.test/user-42/sources/")
    assert result["image_url"].endswith(".webp")
    assert result["storage_path"].startswith("user-42/sources/")
    # Sniffed from the bytes, not from the .jpg hint the caller supplied.
    assert captured["content_type"] == "image/webp"
    assert captured["file_data"] == payload


@pytest.mark.asyncio
async def test_upload_source_image_compresses_png_to_webp():
    """A PNG source is stored as the WebP q82 compression profile (smaller
    than the source), with the key/content-type minted from the stored bytes."""
    captured: dict = {}

    async def fake_upload_file(*, db, file_data, file_path, content_type, **_):
        captured.update(content_type=content_type, file_path=file_path, file_data=file_data)
        return {"public_url": f"https://x/{file_path}", "storage_path": file_path}

    buffer = io.BytesIO()
    Image.new("RGB", (200, 200), (240, 240, 240)).save(buffer, format="PNG")
    png = buffer.getvalue()

    with patch.object(StorageService, "upload_file", fake_upload_file):
        await StorageService.upload_source_image(
            db=MagicMock(),
            user_id="u",
            file_data=png,
            extension=".png",
        )

    assert captured["content_type"] == "image/webp"
    assert captured["file_path"].endswith(".webp")
    assert captured["file_data"] != png  # re-encoded, not stored as-is


@pytest.mark.asyncio
async def test_download_to_base64_returns_none_on_empty_url():
    assert await StorageService.download_to_base64("") is None
    assert await StorageService.download_to_base64(None) is None  # type: ignore[arg-type]


@pytest.mark.asyncio
async def test_download_to_base64_round_trips_bytes_through_s3_backend():
    """download_to_base64 fetches via the S3 backend (no httpx public client)."""
    import base64

    payload = _image_bytes("PNG")
    backend = FakeS3Backend(download_bytes=payload)

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.download_to_base64(
            f"{settings.SUPABASE_URL.rstrip('/')}/storage/v1/object/public/items/img.png"
        )

    assert result == base64.b64encode(payload).decode("utf-8")
    # The URL was reduced to a bucket key and fetched from the backend, never
    # the public URL.
    assert backend.download_keys == ["img.png"]


@pytest.mark.asyncio
async def test_download_to_base64_returns_none_when_backend_fails():
    """download_to_base64 must never raise — it returns None so callers can
    gracefully fall back to text-only generation."""

    backend = FakeS3Backend()  # download raises NoSuchKey

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.download_to_base64(
            f"{settings.SUPABASE_URL.rstrip('/')}/storage/v1/object/public/items/missing.png"
        )

    assert result is None
    assert backend.download_keys == ["missing.png"]


@pytest.mark.asyncio
async def test_download_bytes_only_fetches_known_bucket_keys_not_arbitrary_urls():
    """SSRF guard: an arbitrary URL is reduced to a bucket key and fetched from
    the bucket, never from the URL's host."""
    payload = _image_bytes("PNG")
    backend = FakeS3Backend(download_bytes=payload)

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        content = await StorageService._download_bytes("https://attacker.example/private/secret.bin")

    assert content == payload
    # The attacker host was never contacted — only a bucket key was fetched.
    assert backend.download_keys == ["private/secret.bin"]
