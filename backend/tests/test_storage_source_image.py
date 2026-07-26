"""
Tests for StorageService.upload_source_image and download_to_base64.
"""

from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from app.services.storage_service import StorageService


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

    with patch.object(StorageService, "upload_file", fake_upload_file):
        result = await StorageService.upload_source_image(
            db=fake_db,
            user_id="user-42",
            file_data=b"\xff\xd8\xff\xe0bytes",
            extension=".jpg",
        )

    assert result["image_url"].startswith("https://storage.test/user-42/sources/")
    assert result["image_url"].endswith(".jpg")
    assert result["storage_path"].startswith("user-42/sources/")
    assert captured["content_type"] == "image/jpeg"
    assert captured["file_data"] == b"\xff\xd8\xff\xe0bytes"


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
            file_data=b"pngbytes",
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

    payload = b"\x89PNG\r\n\x1a\n image body"

    fake_response = MagicMock()
    fake_response.raise_for_status = MagicMock()
    fake_response.content = payload

    fake_client = MagicMock()
    fake_client.get = AsyncMock(return_value=fake_response)
    fake_client.__aenter__ = AsyncMock(return_value=fake_client)
    fake_client.__aexit__ = AsyncMock(return_value=None)

    with patch("app.services.storage_service.httpx.AsyncClient", return_value=fake_client):
        result = await StorageService.download_to_base64("https://storage.test/img.png")

    assert result == base64.b64encode(payload).decode("utf-8")


@pytest.mark.asyncio
async def test_download_to_base64_returns_none_on_http_error():
    """download_to_base64 must never raise — it returns None so callers can
    gracefully fall back to text-only generation."""

    fake_response = MagicMock()
    fake_response.raise_for_status = MagicMock(side_effect=Exception("404"))

    fake_client = MagicMock()
    fake_client.get = AsyncMock(return_value=fake_response)
    fake_client.__aenter__ = AsyncMock(return_value=fake_client)
    fake_client.__aexit__ = AsyncMock(return_value=None)

    with patch("app.services.storage_service.httpx.AsyncClient", return_value=fake_client):
        result = await StorageService.download_to_base64("https://storage.test/missing.png")

    assert result is None
