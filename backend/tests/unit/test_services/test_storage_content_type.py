"""Regression: every storage upload must carry a REAL content type.

ORIGIN (Supabase Storage era): storage3's `DEFAULT_FILE_OPTIONS` stamped
`content-type: text/plain;charset=UTF-8` on any `upload()` that passed no
`file_options`, so every item, outfit and avatar object in the bucket was written
with a lying content type. storage3 is no longer in the call graph — uploads go
through `S3StorageBackend.upload` with an explicit `content_type` — but the
requirement it created outlived it and is what these tests hold:

  * every upload helper passes a content type, and
  * the type is sniffed from the BYTES, never inferred from the filename, because
    the batch web client names its upload `${tempId}.png` whatever the generator
    actually returned (frequently WebP since `background_removal.py` landed).
"""

import io
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.services.storage_service import (
    DEFAULT_CACHE_CONTROL,
    STORAGE_MAX_EDGE,
    StorageService,
)
from tests.utils.fake_storage import FakeS3Backend

JPEG_MAGIC = b"\xff\xd8\xff\xe0" + b"0" * 64
PNG_MAGIC = b"\x89PNG\r\n\x1a\n" + b"0" * 64


def _webp_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGBA", (8, 8), (255, 0, 0, 128)).save(buf, format="WEBP")
    return buf.getvalue()


def _heic_bytes() -> bytes:
    # pillow-heif is registered at import of app.utils.image_processing.
    buf = io.BytesIO()
    Image.new("RGBA", (16, 16), (10, 120, 200, 180)).save(buf, format="HEIF")
    return buf.getvalue()


def _bmp_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (16, 16), (10, 120, 200)).save(buf, format="BMP")
    return buf.getvalue()


def _tiff_bytes() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (16, 16), (10, 120, 200)).save(buf, format="TIFF")
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


# The two tests that used to live here covered `StorageService._upload_options`
# and asserted that "storage3 MUTATES the file_options dict it is handed" — a
# property of a library that is no longer in the call graph at all. The S3 path
# passes scalar content_type / cache_control to `S3StorageBackend.upload`, so the
# helper had no production caller and the tests only guarded dead code. Both, and
# the helper, are gone; what actually matters (the sniffed type reaching every
# upload) is covered by the per-site tests below.


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

    # First call = the original object; second = the `_thumb` sibling.
    original, thumb = backend.upload_calls[0], backend.upload_calls[-1]
    # Sniffed from the bytes, NOT from the .png filename the caller supplied.
    assert original["content_type"] == "image/webp"
    assert original["cache_control"] == DEFAULT_CACHE_CONTROL
    assert original["key"].endswith(".webp")
    # The thumb sibling derives from the original key; its type is the
    # sniffed original when the flattened-JPEG re-encode is bigger (a small
    # WebP cutout is routinely smaller than its white-flattened JPEG), else
    # image/jpeg for the downscaled variant.
    assert thumb["key"] == StorageService.thumb_key_for(original["key"])
    assert thumb["content_type"] in {"image/webp", "image/jpeg"}


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


# =============================================================================
# non-web-native formats are transcoded to WebP on the way in
# =============================================================================


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "data,filename",
    [
        (_heic_bytes, "photo.heic"),
        (_bmp_bytes, "scan.bmp"),
        (_tiff_bytes, "scan.tiff"),
    ],
)
async def test_non_web_native_uploads_are_stored_as_webp(data, filename):
    """HEIC/BMP/TIFF are accepted at the boundary but never persisted as-is:
    the canonical object is a browser-safe .webp (browsers cannot render
    HEIC/TIFF). Guards the _normalize_upload_bytes chokepoint."""
    backend = FakeS3Backend()
    raw = data()  # parametrize over the factory, not the bytes, for clarity

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename=filename, file_data=raw
        )

    original = backend.upload_calls[0]
    assert original["key"].endswith(".webp"), original["key"]
    assert original["content_type"] == "image/webp"
    # The original (non-web-native) bytes are never the persisted object.
    assert original["data"] != raw


@pytest.mark.asyncio
async def test_web_native_upload_is_reencoded_to_smaller_webp():
    """JPEG (a web-native format) is re-encoded to the storage compression
    profile (WebP q82 @ 2048px) when that shrinks it: a full-res phone photo
    is the storage cost driver (measured: items at median 0.75MB, max 10.4MB),
    and nothing downstream consumes more than 2048px."""
    backend = FakeS3Backend()
    buf = io.BytesIO()
    # Smooth photo-like gradient: compresses dramatically better as WebP.
    grad = Image.linear_gradient("L").resize((1200, 1600))
    Image.merge("RGB", [grad, grad, grad]).save(buf, format="JPEG", quality=95)
    jpg = buf.getvalue()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename="photo.jpg", file_data=jpg
        )

    original = backend.upload_calls[0]
    assert original["key"].endswith(".webp")
    assert original["content_type"] == "image/webp"
    assert len(original["data"]) < len(jpg)
    with Image.open(io.BytesIO(original["data"])) as img:
        assert max(img.size) <= STORAGE_MAX_EDGE


@pytest.mark.asyncio
async def test_upload_is_downscaled_to_storage_max_edge():
    """An oversized upload never exceeds the storage max edge (2048px)."""
    backend = FakeS3Backend()
    buf = io.BytesIO()
    grad = Image.linear_gradient("L").resize((3200, 2400))
    Image.merge("RGB", [grad, grad, grad]).save(buf, format="JPEG", quality=95)
    jpg = buf.getvalue()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename="huge.jpg", file_data=jpg
        )

    original = backend.upload_calls[0]
    with Image.open(io.BytesIO(original["data"])) as img:
        assert img.size == (2048, 1536)  # aspect preserved, longest edge capped


@pytest.mark.asyncio
async def test_keep_smaller_passes_optimized_webp_through():
    """An already-optimized image (WebP within the max edge) is stored
    byte-identical: the normalization must never inflate bytes, and an
    already-compressed input is exactly the 'would grow' case."""
    backend = FakeS3Backend()
    buf = io.BytesIO()
    Image.new("RGBA", (64, 64), (1, 2, 3, 128)).save(buf, format="WEBP", quality=75)
    webp = buf.getvalue()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename="cutout.webp", file_data=webp
        )

    original = backend.upload_calls[0]
    assert original["key"].endswith(".webp")
    assert original["content_type"] == "image/webp"
    assert original["data"] == webp  # byte-identical, no re-encode


@pytest.mark.asyncio
async def test_png_alpha_survives_storage_normalization():
    """Background-removed cutouts are transparent PNGs; the stored WebP must
    keep the alpha channel (a flattened thumbnail/object renders every
    garment on a white block)."""
    backend = FakeS3Backend()
    buf = io.BytesIO()
    Image.new("RGBA", (900, 900), (255, 0, 0, 128)).save(buf, format="PNG")
    png = buf.getvalue()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename="cutout.png", file_data=png
        )

    original = backend.upload_calls[0]
    assert original["content_type"] == "image/webp"
    with Image.open(io.BytesIO(original["data"])) as img:
        assert img.mode == "RGBA"


@pytest.mark.asyncio
async def test_animated_gif_passes_through_unchanged():
    """Animated GIFs are never re-encoded (Pillow would flatten them to a
    single frame)."""
    backend = FakeS3Backend()
    frames = [Image.new("P", (32, 32), color) for color in (1, 2)]
    buf = io.BytesIO()
    frames[0].save(
        buf, format="GIF", save_all=True, append_images=frames[1:], duration=100, loop=0
    )
    gif = buf.getvalue()

    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(), user_id="u1", filename="anim.gif", file_data=gif
        )

    original = backend.upload_calls[0]
    assert original["key"].endswith(".gif")
    assert original["content_type"] == "image/gif"
    assert original["data"] == gif  # byte-identical
