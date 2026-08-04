"""Regression: every storage upload must carry a REAL content type.

storage3's `DEFAULT_FILE_OPTIONS` stamps `content-type: text/plain;charset=UTF-8`
on any `upload()` call that passes no `file_options` (storage3/constants.py,
merged in `_sync/file_api.py::_upload_or_update`). Every item, outfit and avatar
object in the bucket was written that way, so all five upload helpers now pass
explicit options - and the type is sniffed from the BYTES, because the batch web
client names its upload `${tempId}.png` whatever the generator returned.
"""

import io
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.services.storage_service import DEFAULT_CACHE_CONTROL, StorageService
from tests.storage_test_utils import FakeS3Backend

JPEG_MAGIC = b"\xff\xd8\xff\xe0" + b"0" * 64
PNG_MAGIC = b"\x89PNG\r\n\x1a\n" + b"0" * 64


def _webp_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGBA", (8, 8), (255, 0, 0, 128)).save(buf, format="WEBP")
    return buf.getvalue()


# =============================================================================
# _sniff_content_type
# =============================================================================


def test_bytes_beat_a_lying_filename():
    """The batch client's `${tempId}.png` must not override real WebP bytes."""
    assert StorageService._sniff_content_type(_webp_bytes(), "abc123.png") == "image/webp"
    assert StorageService._sniff_content_type(JPEG_MAGIC, "whatever.png") == "image/jpeg"


def test_extension_is_the_fallback_for_unreadable_bytes():
    assert StorageService._sniff_content_type(b"not an image", "x.png") == "image/png"
    # Callers pass a bare extension too (upload_source_image / temp uploads).
    assert StorageService._sniff_content_type(b"not an image", ".webp") == "image/webp"


def test_unknown_bytes_and_no_filename_fall_back_to_octet_stream():
    assert StorageService._sniff_content_type(b"???") == "application/octet-stream"


def test_sniff_never_raises_on_hostile_input():
    for payload in (b"", b"\x00" * 5, PNG_MAGIC[:3], b"RIFF____NOTWEBP"):
        assert isinstance(StorageService._sniff_content_type(payload, ""), str)


# =============================================================================
# _upload_options
# =============================================================================


def test_upload_options_carry_content_type_and_cache_control():
    options = StorageService._upload_options(PNG_MAGIC, "item.png")
    assert options == {
        "content-type": "image/png",
        "cache-control": DEFAULT_CACHE_CONTROL,
        # upsert makes the reconnect retry exact-once: a retry after a
        # committed-but-lost response overwrites the same path instead of
        # 409ing "Duplicate" (paths are unique uuid4 keys, so upsert never
        # clobbers a foreign object).
        "upsert": "true",
    }


def test_upload_options_builds_a_fresh_dict_each_call():
    """storage3 MUTATES the file_options dict it is handed (it pops
    cache-control and upsert), so a shared dict would be emptied after one use."""
    first = StorageService._upload_options(PNG_MAGIC, "a.png")
    first.pop("cache-control")
    second = StorageService._upload_options(PNG_MAGIC, "a.png")
    assert "cache-control" in second


# =============================================================================
# the five upload sites
# =============================================================================


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "helper,kwargs",
    [
        ("upload_item_image", {"filename": "shot.png"}),
        ("upload_outfit_image", {"filename": "shot.png"}),
        ("upload_avatar", {"filename": "shot.png"}),
        ("upload_feedback_attachment", {"filename": "shot.png"}),
    ],
)
async def test_upload_helpers_pass_sniffed_content_type(helper, kwargs):
    backend = FakeS3Backend()
    webp = _webp_bytes()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await getattr(StorageService, helper)(db=MagicMock(), user_id="u1", file_data=webp, **kwargs)

    call = backend.upload_calls[-1]
    # Sniffed from the bytes, NOT from the .png filename the caller supplied.
    assert call["content_type"] == "image/webp"
    assert call["cache_control"] == DEFAULT_CACHE_CONTROL
    assert call["key"].endswith(".webp")


@pytest.mark.asyncio
async def test_move_image_uses_server_side_copy_and_delete():
    """move_image is now an S3 server-side copy + delete (no byte round-trip).

    The old test asserted move_image re-downloaded and re-sniffed the bytes;
    with the S3 backend the content type is preserved by the copy, so the
    upload helper under test is the copy itself.
    """
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        moved = await StorageService.move_image(
            db=MagicMock(), old_path="u/tmp/a.png", new_path="u/items/a.png"
        )

    assert moved is True
    assert backend.copy_calls == [("u/tmp/a.png", "u/items/a.png")]
    assert backend.delete_calls == ["u/tmp/a.png"]


@pytest.mark.asyncio
async def test_upload_file_honours_a_custom_cache_control():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_file(
            db=MagicMock(),
            file_data=PNG_MAGIC,
            file_path="u/x.png",
            content_type="image/png",
            bucket="items",
            upsert=True,
            cache_control="60",
        )

    call = backend.upload_calls[-1]
    assert call["cache_control"] == "60"
    assert call["key"] == "u/x.png"
    assert call["content_type"] == "image/png"


@pytest.mark.asyncio
async def test_temp_generated_upload_sniffs_format_and_extension():
    """Generated images are no longer always PNG - a matted one is WebP."""
    db = MagicMock()
    captured: dict = {}

    async def fake_upload_file(*, db, file_data, file_path, content_type, **_):
        captured.update(file_path=file_path, content_type=content_type)
        return {"public_url": "https://x/" + file_path, "storage_path": file_path}

    with patch.object(StorageService, "upload_file", fake_upload_file):
        await StorageService.upload_temp_generated_image(
            db=db, user_id="u1", file_data=_webp_bytes()
        )

    assert captured["content_type"] == "image/webp"
    assert captured["file_path"].endswith(".webp")
