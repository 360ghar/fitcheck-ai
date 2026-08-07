"""
Coverage companion for app/services/storage_service.py.

Covers the branches the sibling storage tests miss: upload/delete/inventory
error arms, path-handling edge cases (whitespace keys, legacy preview URLs,
thumb-less keys), thumbnail best-effort failures, and the download/promote/
cleanup helpers. Never touches real network or S3: the backend is always a
fake (FakeS3Backend or a small raising stand-in) injected via
``app.services.storage_service.get_storage_backend``.
"""

import io
import uuid

import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from PIL import Image

from app.core.exceptions import (
    FileTooLargeError,
    StorageServiceError,
    UnsupportedMediaTypeError,
)
from app.services.storage_service import (
    MAX_FILE_SIZE,
    StorageService,
    _with_thumb_siblings,
    close_download_client,
)
from app.services import storage_service as storage_module
from tests.utils.fake_db import FakeDB
from tests.utils.fake_storage import FakeS3Backend


def _valid_png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (200, 200), (255, 255, 255)).save(buffer, format="PNG")
    return buffer.getvalue()


# --------------------------------------------------------------------------- #
# _with_thumb_siblings / close_download_client
# --------------------------------------------------------------------------- #


def test_with_thumb_siblings_drops_falsy_and_duplicate_paths():
    paths = ["u1/items/a.png", "", "u1/items/a.png", "u1/items/b.png", None]
    expanded = _with_thumb_siblings(paths)
    # Falsy paths and the duplicate are dropped; each canonical path gets one
    # _thumb sibling.
    assert expanded == [
        "u1/items/a.png",
        "u1/items/a_thumb.webp",
        "u1/items/b.png",
        "u1/items/b_thumb.webp",
    ]


def test_with_thumb_siblings_never_derives_thumb_from_thumb():
    # A _thumb key itself has no sibling; it is passed through once.
    expanded = _with_thumb_siblings(["u1/items/a.png", "u1/items/a_thumb.webp"])
    assert expanded == ["u1/items/a.png", "u1/items/a_thumb.webp"]


def test_with_thumb_siblings_passes_thumbless_tmp_paths_through():
    # tmp/ previews have no thumb sibling (thumb_key_for returns None).
    assert _with_thumb_siblings(["tmp/u1/social-import/x.png"]) == [
        "tmp/u1/social-import/x.png"
    ]


@pytest.mark.asyncio
async def test_close_download_client_closes_backend():
    with patch.object(storage_module, "close_storage_backend", new=AsyncMock()) as close:
        await close_download_client()
    close.assert_awaited_once_with()


# --------------------------------------------------------------------------- #
# thumb_key_for edge cases
# --------------------------------------------------------------------------- #


def test_thumb_key_for_empty_path_returns_none():
    assert StorageService.thumb_key_for("") is None
    assert StorageService.thumb_key_for(None) is None


def test_thumb_key_for_thumb_key_itself_returns_none():
    assert StorageService.thumb_key_for("u1/items/abc_thumb.webp") is None


def test_thumb_key_for_extensionless_name_returns_none():
    assert StorageService.thumb_key_for("u1/items/abc") is None


# --------------------------------------------------------------------------- #
# _upload_thumbnail error arm (best-effort by contract)
# --------------------------------------------------------------------------- #


class _RaisingUploadBackend:
    """S3-backend stand-in whose upload always raises."""

    def __init__(self, error):
        self.error = error

    async def upload(self, key, data, content_type, cache_control):
        raise self.error

    async def presign_get(self, key, expires=900):
        return f"https://presigned.example/{key}"


@pytest.mark.asyncio
async def test_upload_thumbnail_swallows_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("s3 down"))
    with patch.object(
        storage_module, "run_image_op", new=AsyncMock(return_value=b"thumb-bytes")
    ):
        written = await StorageService._upload_thumbnail(
            backend, "u1/items/abc.png", b"data"
        )
    assert written is False


@pytest.mark.asyncio
async def test_upload_thumbnail_returns_false_when_encode_fails():
    backend = FakeS3Backend()
    with patch.object(storage_module, "run_image_op", new=AsyncMock(return_value=None)):
        written = await StorageService._upload_thumbnail(
            backend, "u1/items/abc.png", b"data"
        )
    assert written is False
    # No object was written under the thumb key.
    assert backend.upload_calls == []


# --------------------------------------------------------------------------- #
# _validate_image error branches
# --------------------------------------------------------------------------- #


def test_validate_image_rejects_oversized_file():
    with pytest.raises(FileTooLargeError):
        StorageService._validate_image(b"x" * (MAX_FILE_SIZE + 1), "big.png")


def test_validate_image_rejects_disallowed_extension():
    with pytest.raises(UnsupportedMediaTypeError, match="Invalid file type"):
        StorageService._validate_image(_valid_png_bytes(), "photo.pdf")


def test_validate_image_rejects_invalid_bytes():
    with pytest.raises(UnsupportedMediaTypeError, match="not a valid supported image"):
        StorageService._validate_image(b"this is not an image at all", "photo.png")


# --------------------------------------------------------------------------- #
# _normalize_upload_bytes transcode branches
# --------------------------------------------------------------------------- #


def test_normalize_upload_bytes_keeps_original_when_transcode_fails():
    payload = b"heic-bytes"
    with (
        patch.object(
            storage_module, "sniff_image_mime_from_magic", return_value="image/heic"
        ),
        patch.object(storage_module, "transcode_to_webp", return_value=None),
    ):
        assert StorageService._normalize_upload_bytes(payload) == payload


def test_normalize_upload_bytes_uses_transcoded_webp():
    with (
        patch.object(
            storage_module, "sniff_image_mime_from_magic", return_value="image/tiff"
        ),
        patch.object(storage_module, "transcode_to_webp", return_value=b"WEBPDATA"),
        patch.object(storage_module, "downscale_image_bytes_to_webp", return_value=None),
    ):
        assert StorageService._normalize_upload_bytes(b"raw") == b"WEBPDATA"


# --------------------------------------------------------------------------- #
# key_from_path edge cases
# --------------------------------------------------------------------------- #


def test_key_from_path_whitespace_only_returns_none():
    assert StorageService.key_from_path("   ") is None


def test_key_from_path_resolves_legacy_preview_url(monkeypatch):
    monkeypatch.setattr("app.services.storage_service.settings.SUPABASE_STORAGE_BUCKET", "items")
    monkeypatch.setattr("app.services.storage_service.settings.OBJECT_STORAGE_BUCKET", "bucket")
    user = str(uuid.uuid4())
    # A path-style URL from a bucket that is no longer the configured one,
    # embedding the user in the SECOND segment under tmp/.
    assert StorageService.key_from_path(
        f"https://old-storage.example/railway-bucket/tmp/{user}/social-import/x.png"
    ) == f"tmp/{user}/social-import/x.png"
    assert StorageService.key_from_path(
        f"https://old-storage.example/some-bucket/generated/{user}/y.webp"
    ) == f"generated/{user}/y.webp"


def test_build_object_url(monkeypatch):
    monkeypatch.setattr("app.services.storage_service.settings.OBJECT_STORAGE_ENDPOINT", "https://r2.example/")
    monkeypatch.setattr("app.services.storage_service.settings.OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.build_object_url("/u1/items/a.png") == (
        "https://r2.example/fitcheck-images/u1/items/a.png"
    )


# --------------------------------------------------------------------------- #
# upload error arms
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_upload_item_image_raises_storage_error_on_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("put failed"))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to upload image"):
            await StorageService.upload_item_image(
                db=MagicMock(),
                user_id="u1",
                filename="shirt.png",
                file_data=_valid_png_bytes(),
            )


@pytest.mark.asyncio
async def test_upload_outfit_image_raises_storage_error_on_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("put failed"))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to upload outfit image"):
            await StorageService.upload_outfit_image(
                db=MagicMock(),
                user_id="u1",
                filename="outfit.png",
                file_data=_valid_png_bytes(),
            )


@pytest.mark.asyncio
async def test_upload_avatar_raises_storage_error_on_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("put failed"))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to upload avatar"):
            await StorageService.upload_avatar(
                db=MagicMock(),
                user_id="u1",
                filename="avatar.png",
                file_data=_valid_png_bytes(),
            )


@pytest.mark.asyncio
async def test_upload_feedback_attachment_raises_storage_error_on_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("put failed"))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to upload attachment"):
            await StorageService.upload_feedback_attachment(
                db=MagicMock(),
                user_id="anonymous",
                filename="feedback.png",
                file_data=_valid_png_bytes(),
            )


@pytest.mark.asyncio
async def test_upload_file_raises_storage_error_on_backend_failure():
    backend = _RaisingUploadBackend(RuntimeError("put failed"))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to upload file"):
            await StorageService.upload_file(
                db=MagicMock(),
                file_data=b"raw",
                file_path="tmp/u1/social-import/x.png",
            )


# --------------------------------------------------------------------------- #
# delete paths
# --------------------------------------------------------------------------- #


class _ThumbDeleteFailsBackend:
    """Backend whose primary delete works but the _thumb delete raises."""

    def __init__(self):
        self.deleted = []

    async def delete(self, key):
        self.deleted.append(key)
        if key.endswith("_thumb.webp"):
            raise RuntimeError("thumb delete boom")


@pytest.mark.asyncio
async def test_delete_image_tolerates_thumb_delete_failure():
    backend = _ThumbDeleteFailsBackend()
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        deleted = await StorageService.delete_image(
            db=MagicMock(), storage_path="u1/items/abc.png"
        )
    assert deleted is True
    assert backend.deleted == ["u1/items/abc.png", "u1/items/abc_thumb.webp"]


class _AlwaysFailingDeleteBackend:
    async def delete(self, key):
        raise RuntimeError("delete boom")


@pytest.mark.asyncio
async def test_delete_image_raises_storage_error_on_primary_delete_failure():
    backend = _AlwaysFailingDeleteBackend()
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        with pytest.raises(StorageServiceError, match="Failed to delete image"):
            await StorageService.delete_image(
                db=MagicMock(), storage_path="u1/items/abc.png"
            )


@pytest.mark.asyncio
async def test_delete_image_skips_thumb_for_non_canonical_key():
    backend = FakeS3Backend()
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        deleted = await StorageService.delete_image(
            db=MagicMock(), storage_path="tmp/u1/social-import/x.png"
        )
    assert deleted is True
    # Only the object itself: tmp previews have no _thumb sibling.
    assert backend.delete_calls == ["tmp/u1/social-import/x.png"]


@pytest.mark.asyncio
async def test_delete_multiple_images_empty_returns_zero():
    assert await StorageService.delete_multiple_images(db=MagicMock(), storage_paths=[]) == 0


@pytest.mark.asyncio
async def test_delete_multiple_images_raises_on_backend_failure():
    class _Failing:
        async def delete_many(self, keys):
            raise RuntimeError("batch delete boom")

    with patch.object(storage_module, "get_storage_backend", return_value=_Failing()):
        with pytest.raises(StorageServiceError, match="Failed to delete images"):
            await StorageService.delete_multiple_images(
                db=MagicMock(), storage_paths=["u1/items/a.png"]
            )


# --------------------------------------------------------------------------- #
# resolve_owned_storage_paths scoped variant
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_resolve_owned_storage_paths_scopes_to_requested_ids():
    db = FakeDB(
        rows={
            "items": [
                {"id": "item-1", "user_id": "u1", "source_image_storage_path": "u1/sources/s1.png"},
                {"id": "item-2", "user_id": "u1", "source_image_storage_path": "u1/sources/s2.png"},
                {"id": "item-3", "user_id": "u1", "source_image_storage_path": "u1/sources/s3.png"},
            ],
            "outfits": [{"id": "outfit-1", "user_id": "u1"}],
            "item_images": [
                {"item_id": "item-1", "storage_path": "u1/items/a.png"},
                {"item_id": "item-2", "storage_path": "u1/items/b.png"},
                {"item_id": "item-3", "storage_path": "u1/items/c.png"},
            ],
            "outfit_images": [
                {"outfit_id": "outfit-1", "storage_path": "u1/outfits/o.png"}
            ],
        }
    )
    result = await StorageService.resolve_owned_storage_paths(
        db,
        user_id="u1",
        item_ids=["item-1", "item-2"],
        outfit_ids=["outfit-1"],
    )
    assert result["item_ids"] == ["item-1", "item-2"]
    assert result["outfit_ids"] == ["outfit-1"]
    # Sources from the parent rows + child image rows + derived thumbs.
    assert "u1/sources/s1.png" in result["storage_paths"]
    assert "u1/sources/s2.png" in result["storage_paths"]
    assert "u1/sources/s3.png" not in result["storage_paths"]
    assert "u1/items/a.png" in result["storage_paths"]
    assert "u1/items/c.png" not in result["storage_paths"]
    assert "u1/items/a_thumb.webp" in result["storage_paths"]


@pytest.mark.asyncio
async def test_resolve_owned_storage_paths_empty_scopes_return_empty():
    db = FakeDB(
        rows={
            "items": [{"id": "item-1", "source_image_storage_path": "u1/sources/s1.png"}],
        }
    )
    result = await StorageService.resolve_owned_storage_paths(
        db, user_id="u1", item_ids=[], outfit_ids=[]
    )
    assert result == {"item_ids": [], "outfit_ids": [], "storage_paths": []}


@pytest.mark.asyncio
async def test_resolve_owned_storage_paths_unscoped_collects_everything():
    db = FakeDB(
        rows={
            "items": [
                {"id": "item-1", "user_id": "u1", "source_image_storage_path": "u1/sources/s1.png"},
                # A row with no id is skipped from owned_ids (the continue arm).
                {"user_id": "u1", "source_image_storage_path": "u1/sources/s2.png"},
            ],
            "outfits": [{"id": "outfit-1", "user_id": "u1"}],
            "item_images": [{"item_id": "item-1", "storage_path": "u1/items/a.png"}],
            "outfit_images": [{"outfit_id": "outfit-1", "storage_path": "u1/outfits/o.png"}],
        }
    )
    result = await StorageService.resolve_owned_storage_paths(db, user_id="u1")
    assert result["item_ids"] == ["item-1"]
    assert result["outfit_ids"] == ["outfit-1"]
    assert "u1/sources/s1.png" in result["storage_paths"]
    assert "u1/items/a.png" in result["storage_paths"]
    assert "u1/outfits/o.png" in result["storage_paths"]
    assert "u1/items/a_thumb.webp" in result["storage_paths"]


@pytest.mark.asyncio
async def test_resolve_owned_storage_paths_skips_child_queries_when_no_owned_ids():
    """A parent scope whose rows all lack an id contributes no ids and no
    child-image queries (the continue arm)."""
    db = FakeDB(
        rows={
            "outfits": [{"user_id": "u1"}],
            "outfit_images": [{"outfit_id": "missing", "storage_path": "u1/outfits/x.png"}],
        }
    )
    result = await StorageService.resolve_owned_storage_paths(db, user_id="u1")
    assert result["outfit_ids"] == []
    assert "u1/outfits/x.png" not in result["storage_paths"]


@pytest.mark.asyncio
async def test_list_temp_objects_summarizes_scan():
    objects = [
        {"key": "tmp/u1/social-import/a.png", "size": 100, "last_modified": "2026-01-01T00:00:00Z"},
        {"key": "u2/tmp/legacy/b.png", "size": 200, "last_modified": "2026-01-02T00:00:00Z"},
        {"key": "u1/items/c.png", "size": 300, "last_modified": "2026-01-03T00:00:00Z"},
        {"key": "tmp/u3/undated.png", "size": 50, "last_modified": None},
    ]
    backend = FakeS3Backend(objects=objects)
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        result = await StorageService.list_temp_objects(max_pages=5)

    assert result["scanned_keys"] == 4
    assert result["count"] == 3  # two tmp/ keys + one legacy /tmp/ key
    assert result["total_bytes"] == 350
    assert result["oldest"]["key"] == "tmp/u1/social-import/a.png"
    assert result["newest"]["key"] == "u2/tmp/legacy/b.png"
    assert result["truncated"] is False
    assert len(result["items"]) == 3
    assert backend.scan_calls == [("", 5)]


@pytest.mark.asyncio
async def test_list_temp_objects_flags_truncation():
    objects = [{"key": "tmp/u1/x.png", "size": 1, "last_modified": None}]
    backend = FakeS3Backend(objects=objects)
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        result = await StorageService.list_temp_objects(max_pages=0)
    # With a zero page cap every scan looks truncated.
    assert result["truncated"] is True


# --------------------------------------------------------------------------- #
# move / download / promote / cleanup helpers
# --------------------------------------------------------------------------- #


@pytest.mark.asyncio
async def test_move_image_raises_storage_error_on_backend_failure():
    class _Failing:
        async def copy(self, src, dst):
            raise RuntimeError("copy boom")

    with patch.object(storage_module, "get_storage_backend", return_value=_Failing()):
        with pytest.raises(StorageServiceError, match="Failed to move image"):
            await StorageService.move_image(
                db=MagicMock(), old_path="u1/items/a.png", new_path="u1/items/b.png"
            )


@pytest.mark.asyncio
async def test_download_bytes_returns_none_for_whitespace_url():
    assert await StorageService._download_bytes("   ") is None


@pytest.mark.asyncio
async def test_download_bytes_returns_none_for_empty_content():
    backend = FakeS3Backend(download_bytes=b"")
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        assert await StorageService._download_bytes("u1/items/a.png") is None


@pytest.mark.asyncio
async def test_download_bytes_returns_none_for_oversized_content():
    backend = FakeS3Backend(download_bytes=b"x" * (MAX_FILE_SIZE + 1))
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        assert await StorageService._download_bytes("u1/items/a.png") is None


@pytest.mark.asyncio
async def test_download_bytes_returns_none_on_backend_failure():
    backend = FakeS3Backend()  # download raises NoSuchKey by default
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        assert await StorageService._download_bytes("u1/items/a.png") is None


@pytest.mark.asyncio
async def test_download_and_downscale_to_base64_none_when_download_fails():
    backend = FakeS3Backend()
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        result = await StorageService.download_and_downscale_to_base64("u1/items/a.png")
    assert result is None


@pytest.mark.asyncio
async def test_download_and_downscale_to_base64_returns_downscaled():
    backend = FakeS3Backend(download_bytes=_valid_png_bytes())
    with (
        patch.object(storage_module, "get_storage_backend", return_value=backend),
        patch.object(
            storage_module,
            "downscale_image_bytes_to_base64",
            return_value="downscaled-b64",
        ),
    ):
        result = await StorageService.download_and_downscale_to_base64(
            "u1/items/a.png", max_edge=1024, quality=80
        )
    assert result == "downscaled-b64"


@pytest.mark.asyncio
async def test_promote_temp_image_skips_thumb_when_download_empty():
    backend = FakeS3Backend(download_bytes=b"")
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        result = await StorageService.promote_temp_image_to_item(
            db=MagicMock(), user_id="u1", temp_storage_path="tmp/u1/photoshoot/x.png"
        )
    assert result["storage_path"].startswith("u1/items/")
    assert not any("_thumb" in c["key"] for c in backend.upload_calls)


@pytest.mark.asyncio
async def test_promote_temp_image_tolerates_download_failure():
    backend = FakeS3Backend()  # download raises NoSuchKey
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        result = await StorageService.promote_temp_image_to_item(
            db=MagicMock(), user_id="u1", temp_storage_path="tmp/u1/photoshoot/x.png"
        )
    assert result["image_url"].startswith("https://presigned.example/")


@pytest.mark.asyncio
async def test_cleanup_temp_images_empty_returns_zero():
    assert await StorageService.cleanup_temp_images(db=MagicMock(), storage_paths=[]) == 0


@pytest.mark.asyncio
async def test_cleanup_temp_images_returns_zero_on_failure():
    with patch.object(
        StorageService,
        "delete_multiple_images",
        new=AsyncMock(side_effect=RuntimeError("boom")),
    ):
        assert await StorageService.cleanup_temp_images(
            db=MagicMock(), storage_paths=["tmp/u1/x.png"]
        ) == 0


@pytest.mark.asyncio
async def test_delete_temp_objects_empty_returns_zero():
    assert await StorageService.delete_temp_objects([]) == 0


@pytest.mark.asyncio
async def test_delete_temp_objects_deletes_through_backend():
    backend = FakeS3Backend()
    with patch.object(storage_module, "get_storage_backend", return_value=backend):
        deleted = await StorageService.delete_temp_objects(["tmp/u1/x.png", "tmp/u1/y.png"])
    assert deleted == 2
    assert backend.delete_calls == ["tmp/u1/x.png", "tmp/u1/y.png"]
