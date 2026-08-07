import io
import re
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.core.config import settings
from app.core.storage_keys import USER_ID_SEGMENT_RE
from app.services.storage_service import (
    DEFAULT_CACHE_CONTROL,
    StorageService,
)
from tests.storage_test_utils import FakeS3Backend


def _valid_png_bytes() -> bytes:
    buffer = io.BytesIO()
    # Large enough that the WebP q82 re-encode is reliably smaller (the
    # storage compression profile converts on the way in).
    Image.new("RGB", (200, 200), (255, 255, 255)).save(buffer, format="PNG")
    return buffer.getvalue()


@pytest.mark.asyncio
async def test_upload_item_image_uses_s3_backend_and_returns_presigned_url():
    """upload_item_image now writes through the S3 backend (no db.storage.from_)
    and returns a presigned GET URL for the new {user_id}/items/ key layout.

    Two objects are written: the original (re-encoded to the WebP q82 @ 2048px
    storage compression profile, since that is smaller than the source PNG)
    and its `_thumb` sibling (best-effort thumbnail serving, see
    thumb_key_for/_upload_thumbnail).
    """
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.upload_item_image(
            db=MagicMock(),
            user_id="user-1",
            filename="shirt.png",
            file_data=_valid_png_bytes(),
        )

    assert len(backend.upload_calls) == 2
    call = backend.upload_calls[0]
    assert call["key"].startswith("user-1/items/")
    assert call["key"].endswith(".webp")
    assert call["content_type"] == "image/webp"
    assert call["cache_control"] == DEFAULT_CACHE_CONTROL

    thumb_call = backend.upload_calls[1]
    assert thumb_call["key"] == StorageService.thumb_key_for(call["key"])

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


# --------------------------------------------------------------------------- #
# key_from_path is independent of the CURRENT bucket name
# --------------------------------------------------------------------------- #
# Latent data-loss bug that a provider cutover activates: DB columns persist
# presigned URLs containing whatever bucket was live at upload time (items.py /
# outfits.py / users.py all write the live URL). Matching only
# settings.OBJECT_STORAGE_BUCKET meant that after repointing at R2, an old Railway
# URL resolved to `railway-bucket/{user}/avatars/x.png` — so the real object was
# absent from storage_inventory's DB key set, looked like an orphan, and
# `--delete` would have deleted users' avatars.
_KFP_USER = "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"
_KFP_KEY = f"{_KFP_USER}/avatars/deadbeefdeadbeefdeadbeefdeadbeef.png"


@pytest.mark.parametrize(
    "url",
    [
        # Pre-cutover Railway URL, path-style, bucket no longer configured.
        f"https://t3.storageapi.dev/collapsible-saddlebag-s0pyqr/{_KFP_KEY}?X-Amz-Signature=x",
        # Current R2 URL, path-style.
        f"https://acct.r2.cloudflarestorage.com/fitcheck-images/{_KFP_KEY}?X-Amz-Signature=x",
        # R2 virtual-hosted style (no bucket in the path).
        f"https://fitcheck-images.acct.r2.cloudflarestorage.com/{_KFP_KEY}",
        # Worker CDN URL (IMAGE_SERVING_MODE=worker).
        f"https://images.fitcheckaiapp.com/{_KFP_KEY}",
        # Legacy Supabase public URL.
        f"https://p.supabase.co/storage/v1/object/public/fitcheck-images/{_KFP_KEY}",
        # Bare key.
        _KFP_KEY,
    ],
)
def test_key_from_path_resolves_every_url_shape_to_the_same_key(url, monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(url) == _KFP_KEY


def test_key_from_path_does_not_reshape_an_external_url_into_our_key_space(monkeypatch):
    """An OAuth avatar or social-import URL must not gain a plausible key shape.

    Callers additionally gate on a UUID first segment
    (``images.materialize_avatar_url``), so a mangled external URL is never
    presigned — this asserts the first segment stays non-UUID so that guard holds.
    """
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    for external in (
        "https://lh3.googleusercontent.com/a/ACw8oPics=w96-h96",
        "https://scontent.cdninstagram.com/v/t51/abc.jpg",
    ):
        resolved = StorageService.key_from_path(external)
        first_segment = (resolved or "").split("/", 1)[0]
        assert not USER_ID_SEGMENT_RE.fullmatch(first_segment)


# --------------------------------------------------------------------------- #
# promote_temp_image_to_item normalizes legacy preview keys
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_promote_temp_image_to_item_normalizes_legacy_preview_key():
    """A legacy per-user preview key ({user}/tmp/{sub}/...) held in a DB row is
    normalized to the top-level layout before the server-side copy, mirroring
    the delete paths (storage_keys.normalize_preview_key): after the temp-key
    migration script moved the bytes, the legacy key no longer exists and
    passing it straight to move_image would raise NoSuchKey. Canonical
    tmp/{user}/{sub}/... keys pass through unchanged."""
    backend = FakeS3Backend(download_bytes=_valid_png_bytes())
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.promote_temp_image_to_item(
            db=MagicMock(),
            user_id="user-1",
            temp_storage_path="user-1/tmp/social-import/abc123.png",
        )

    # The move ran from the NORMALIZED key, not the legacy one, and the
    # legacy key was deleted (copy + delete semantics preserved).
    assert backend.copy_calls == [
        ("tmp/user-1/social-import/abc123.png", result["storage_path"])
    ]
    assert backend.delete_calls == ["tmp/user-1/social-import/abc123.png"]
    assert "user-1/tmp/social-import/abc123.png" not in backend.copy_calls[0]
    # The promoted object still gets its best-effort thumb sibling.
    assert any("_thumb" in c["key"] for c in backend.upload_calls)
