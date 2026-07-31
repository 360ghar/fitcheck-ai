"""
Tests for StorageService.upload_source_image and download_to_base64.
"""

import io
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from PIL import Image

from app.core.config import settings
from app.services.storage_service import StorageService


def _image_bytes(format_name: str) -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), (240, 240, 240)).save(buffer, format=format_name)
    return buffer.getvalue()


async def _chunks(payload: bytes):
    yield payload


class _Stream:
    def __init__(self, response):
        self.response = response

    async def __aenter__(self):
        return self.response

    async def __aexit__(self, exc_type, exc, tb):
        return None


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
    payload = _image_bytes("JPEG")

    with patch.object(StorageService, "upload_file", fake_upload_file):
        result = await StorageService.upload_source_image(
            db=fake_db,
            user_id="user-42",
            file_data=payload,
            extension=".jpg",
        )

    assert result["image_url"].startswith("https://storage.test/user-42/sources/")
    assert result["image_url"].endswith(".jpg")
    assert result["storage_path"].startswith("user-42/sources/")
    assert captured["content_type"] == "image/jpeg"
    assert captured["file_data"] == payload


@pytest.mark.asyncio
async def test_upload_source_image_defaults_png_content_type_for_non_jpeg():
    captured: dict = {}

    async def fake_upload_file(*, db, file_data, file_path, content_type, **_):
        captured.update(content_type=content_type)
        return {"public_url": f"https://x/{file_path}", "storage_path": file_path}

    with patch.object(StorageService, "upload_file", fake_upload_file):
        await StorageService.upload_source_image(
            db=MagicMock(),
            user_id="u",
            file_data=_image_bytes("PNG"),
            extension=".png",
        )

    assert captured["content_type"] == "image/png"


@pytest.mark.asyncio
async def test_download_to_base64_returns_none_on_empty_url():
    assert await StorageService.download_to_base64("") is None
    assert await StorageService.download_to_base64(None) is None  # type: ignore[arg-type]


@pytest.mark.asyncio
async def test_download_to_base64_round_trips_bytes_through_httpx():
    """download_to_base64 should base64-encode the fetched body."""
    import base64

    payload = _image_bytes("PNG")

    fake_response = MagicMock()
    fake_response.raise_for_status = MagicMock()
    fake_response.status_code = 200
    fake_response.headers = {"content-type": "image/png"}
    fake_response.aiter_bytes = lambda: _chunks(payload)

    fake_client = MagicMock()
    fake_client.stream = MagicMock(return_value=_Stream(fake_response))
    fake_client.__aenter__ = AsyncMock(return_value=fake_client)
    fake_client.__aexit__ = AsyncMock(return_value=None)

    with patch("app.services.storage_service.httpx.AsyncClient", return_value=fake_client):
        result = await StorageService.download_to_base64(
            f"{settings.SUPABASE_URL.rstrip('/')}/storage/v1/object/public/items/img.png"
        )

    assert result == base64.b64encode(payload).decode("utf-8")


@pytest.mark.asyncio
async def test_download_to_base64_returns_none_on_http_error():
    """download_to_base64 must never raise — it returns None so callers can
    gracefully fall back to text-only generation."""

    fake_response = MagicMock()
    fake_response.status_code = 404
    fake_response.headers = {}
    fake_response.raise_for_status = MagicMock(side_effect=Exception("404"))

    fake_client = MagicMock()
    fake_client.stream = MagicMock(return_value=_Stream(fake_response))
    fake_client.__aenter__ = AsyncMock(return_value=fake_client)
    fake_client.__aexit__ = AsyncMock(return_value=None)

    with patch("app.services.storage_service.httpx.AsyncClient", return_value=fake_client):
        result = await StorageService.download_to_base64(
            f"{settings.SUPABASE_URL.rstrip('/')}/storage/v1/object/public/items/missing.png"
        )

    assert result is None
