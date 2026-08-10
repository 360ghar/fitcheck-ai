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
from tests.utils.fake_storage import FakeS3Backend


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
    assert call["key"].startswith("users/user-1/items/")
    assert call["key"].endswith(".webp")
    assert call["content_type"] == "image/webp"
    assert call["cache_control"] == DEFAULT_CACHE_CONTROL

    thumb_call = backend.upload_calls[1]
    assert thumb_call["key"] == StorageService.thumb_key_for(call["key"])

    assert result["image_url"].startswith("https://presigned.example/")
    assert result["thumbnail_url"] == result["image_url"]
    assert result["storage_path"] == call["key"]


def test_build_key_uses_user_category_and_uuid_without_timestamps():
    """The key layout is users/{user_id}/{category}/{uuid4hex}.{ext} — no timestamps."""
    key = StorageService._build_key("user-1", "items", ".png")
    assert re.fullmatch(r"users/user-1/items/[0-9a-f]{32}\.png", key)

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
    monkeypatch.setattr("app.services.storage_service.settings.OBJECT_STORAGE_BUCKET", "bucket")

    # Supabase public object URL -> key (bucket segment dropped; the legacy
    # per-user key maps to its users/ home when the category is canonical).
    assert StorageService.key_from_path(
        "https://project.supabase.co/storage/v1/object/public/items/user-a/item.webp"
    ) == "user-a/item.webp"

    # S3 presigned URL (query string ignored) -> key, mapped to users/.
    assert StorageService.key_from_path(
        "https://storage.railway.app/bucket/user-a/items/item.webp?X-Amz-Signature=abc"
    ) == "users/user-a/items/item.webp"

    # A bare legacy key maps to its users/ home.
    assert StorageService.key_from_path("user-a/items/item.webp") == "users/user-a/items/item.webp"

    # A bare users/ key passes through unchanged.
    assert StorageService.key_from_path("users/user-a/items/item.webp") == "users/user-a/items/item.webp"

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
_KFP_KEY_USERS = f"users/{_KFP_KEY}"


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
        # Bare legacy key.
        _KFP_KEY,
    ],
)
def test_key_from_path_resolves_every_url_shape_to_the_same_key(url, monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    # Every shape reduces to the same legacy key, which is then mapped to its
    # users/ home (post-migration self-heal).
    assert StorageService.key_from_path(url) == _KFP_KEY_USERS


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
# key_from_path worker-CDN URLs and the None fallback
# --------------------------------------------------------------------------- #
# With IMAGE_SERVING_MODE=worker the CDN serves keys directly at the path
# root: a leading ``tmp|generated`` preview folder (whose second segment is
# the user UUID) or a user UUID IS the key and is returned as-is — the preview
# folder must never be dropped by the bucket-name rule. URLs that reduce to no
# known key shape return None (never reshaped into a garbage key).


def test_key_from_path_worker_cdn_preview_url_keeps_preview_folder(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(
        f"https://cdn.fitcheck.ai/tmp/{_KFP_USER}/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"
    ) == f"users/{_KFP_USER}/tmp/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"


def test_key_from_path_worker_cdn_canonical_url_returns_path_as_key(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(
        f"https://cdn.fitcheck.ai/{_KFP_USER}/items/deadbeefdeadbeefdeadbeefdeadbeef.png"
    ) == f"users/{_KFP_USER}/items/deadbeefdeadbeefdeadbeefdeadbeef.png"


def test_key_from_path_unconfigured_bucket_preview_url_keeps_preview_folder(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(
        f"https://r2.example.com/somebucket/tmp/{_KFP_USER}/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"
    ) == f"users/{_KFP_USER}/tmp/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"


def test_key_from_path_bare_preview_key_maps_to_users_home(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(
        f"tmp/{_KFP_USER}/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"
    ) == f"users/{_KFP_USER}/tmp/batch/deadbeefdeadbeefdeadbeefdeadbeef.webp"


def test_key_from_path_external_url_returns_none(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert (
        StorageService.key_from_path(
            "https://lh3.googleusercontent.com/a/ACo8DcX/photo"
        )
        is None
    )


def test_key_from_path_configured_bucket_presigned_url_still_resolves(monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "fitcheck-images")
    assert StorageService.key_from_path(
        f"https://acct.r2.cloudflarestorage.com/fitcheck-images/{_KFP_USER}/items/deadbeefdeadbeefdeadbeefdeadbeef.png?X-Amz-Signature=x"
    ) == f"users/{_KFP_USER}/items/deadbeefdeadbeefdeadbeefdeadbeef.png"


# --------------------------------------------------------------------------- #
# promote_temp_image_to_item normalizes legacy preview keys
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_promote_temp_image_to_item_maps_legacy_preview_key():
    """A legacy preview key ({user}/tmp/{sub}/...) held in a DB row is mapped
    to its users/ home before the server-side copy, mirroring the delete paths
    (storage_keys.migrate_key_to_users_layout): after the layout migration
    moved the bytes, the legacy key no longer exists and passing it straight to
    move_image would raise NoSuchKey. Current users/ keys pass through
    unchanged."""
    backend = FakeS3Backend(download_bytes=_valid_png_bytes())
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.promote_temp_image_to_item(
            db=MagicMock(),
            user_id="user-1",
            temp_storage_path="user-1/tmp/social-import/abc123.png",
        )

    # The move ran from the MAPPED key, not the legacy one, and the legacy key
    # was deleted (copy + delete semantics preserved).
    assert backend.copy_calls == [
        ("users/user-1/tmp/social-import/abc123.png", result["storage_path"])
    ]
    assert backend.delete_calls == ["users/user-1/tmp/social-import/abc123.png"]
    assert "user-1/tmp/social-import/abc123.png" not in backend.copy_calls[0]
    # The promoted object still gets its best-effort thumb sibling.
    assert any("_thumb" in c["key"] for c in backend.upload_calls)
