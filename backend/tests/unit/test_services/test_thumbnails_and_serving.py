"""Tests for thumbnail variants and image-serving modes (egress RCA Phase 2).

Covers:
- ``StorageService.thumb_key_for`` derivation (canonical categories only).
- Upload paths create the ``_thumb`` sibling (best-effort).
- Delete paths remove the thumb sibling (no orphaning).
- ``resolve_owned_storage_paths`` expands with thumb keys (account deletion).
- ``materialize_image_urls`` under the three serving states:
  presigned mode (legacy behavior), thumbnail serving on, and worker mode
  (stable CDN URLs).

See docs/exec-plans/active/2026-08-05-railway-egress-rca.md.
"""
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

import pytest
from PIL import Image

from app.api.v1 import images as images_module
from app.services.storage_service import StorageService
from tests.utils.fake_storage import FakeS3Backend


def _png_bytes() -> bytes:
    import io

    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), (255, 255, 255)).save(buffer, format="PNG")
    return buffer.getvalue()


# --------------------------------------------------------------------------- #
# thumb_key_for (pure)
# --------------------------------------------------------------------------- #
def test_thumb_key_for_canonical_categories():
    # ALWAYS .webp, whatever the parent's extension: thumbs are written as WebP
    # so transparency survives, and the key must not claim a format the object
    # does not have (it previously inherited the parent's extension while the
    # body was JPEG).
    assert (
        StorageService.thumb_key_for("user-1/items/abc123.jpg")
        == "user-1/items/abc123_thumb.webp"
    )
    assert (
        StorageService.thumb_key_for("user-1/outfits/abc123.png")
        == "user-1/outfits/abc123_thumb.webp"
    )
    assert (
        StorageService.thumb_key_for("user-1/avatars/abc123.webp")
        == "user-1/avatars/abc123_thumb.webp"
    )
    assert (
        StorageService.thumb_key_for("user-1/sources/abc123.jpg")
        == "user-1/sources/abc123_thumb.webp"
    )
    assert (
        StorageService.thumb_key_for("user-1/feedback/abc123.jpg")
        == "user-1/feedback/abc123_thumb.webp"
    )


def test_thumb_key_extension_matches_what_is_actually_stored():
    """Contract: the key's extension and the uploaded content type agree."""
    from app.services import storage_service as svc

    key = StorageService.thumb_key_for("user-1/items/abc123.png")
    assert key.endswith(svc.THUMB_EXTENSION)
    assert svc.THUMB_CONTENT_TYPE == "image/webp"
    assert svc.THUMB_EXTENSION == ".webp"


def test_thumb_key_for_non_canonical_returns_none():
    # tmp previews stay full-size (short-lived review flows), in both the
    # current top-level layout and the legacy per-user one.
    assert StorageService.thumb_key_for("tmp/user-1/social-import/abc.jpg") is None
    assert StorageService.thumb_key_for("user-1/tmp/social-import/abc.jpg") is None
    # generated/export/legacy layouts are not thumbnail targets.
    assert StorageService.thumb_key_for("generated/user-1/outfit/abc.png") is None
    assert StorageService.thumb_key_for("user-1/generated/outfit/abc.png") is None
    assert StorageService.thumb_key_for("user-1/export/data.json") is None
    # _thumb keys never re-derive.
    assert StorageService.thumb_key_for("user-1/items/abc_thumb.webp") is None
    # No extension -> no thumb key.
    assert StorageService.thumb_key_for("user-1/items/abc123") is None
    assert StorageService.thumb_key_for("") is None
    assert StorageService.thumb_key_for(None) is None


# --------------------------------------------------------------------------- #
# upload paths create the thumb sibling
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_upload_item_image_creates_thumb_sibling():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.upload_item_image(
            db=MagicMock(),
            user_id="user-1",
            filename="shirt.jpg",
            file_data=_png_bytes(),
        )

    assert len(backend.upload_calls) == 2
    keys = [call["key"] for call in backend.upload_calls]
    original = keys[0]
    thumb = keys[1]
    assert original == result["storage_path"]
    assert thumb == StorageService.thumb_key_for(original)
    assert StorageService.thumb_key_for(original) is not None


@pytest.mark.asyncio
async def test_upload_temp_image_does_not_create_thumb():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.upload_temp_generated_image(
            db=MagicMock(),
            user_id="user-1",
            file_data=_png_bytes(),
            source="social-import",
        )

    # tmp keys are not canonical -> no thumb upload.
    assert len(backend.upload_calls) == 1
    assert result["storage_path"].startswith("tmp/user-1/")


@pytest.mark.asyncio
async def test_promote_temp_image_to_item_creates_thumb():
    backend = FakeS3Backend(download_bytes=_png_bytes())
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        result = await StorageService.promote_temp_image_to_item(
            db=MagicMock(),
            user_id="user-1",
            temp_storage_path="tmp/user-1/social-import/abc123.png",
        )

    # Server-side copy (move) + thumb upload for the promoted items key.
    assert backend.copy_calls == [
        ("tmp/user-1/social-import/abc123.png", result["storage_path"])
    ]
    thumb_uploads = [c["key"] for c in backend.upload_calls if "thumb" in c["key"]]
    assert thumb_uploads == [StorageService.thumb_key_for(result["storage_path"])]


# --------------------------------------------------------------------------- #
# delete paths remove the thumb sibling
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_delete_image_also_deletes_thumb():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.delete_image(
            db=MagicMock(), storage_path="user-1/items/abc123.jpg"
        )

    assert sorted(backend.delete_calls) == [
        "user-1/items/abc123.jpg",
        "user-1/items/abc123_thumb.webp",
    ]


@pytest.mark.asyncio
async def test_delete_multiple_images_expands_thumbs():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.delete_multiple_images(
            db=MagicMock(),
            storage_paths=[
                "user-1/items/abc123.jpg",
                "user-1/tmp/social-import/x.png",  # tmp has no thumb
            ],
        )

    assert sorted(backend.delete_calls) == [
        "tmp/user-1/social-import/x.png",  # tmp has no thumb; sorts first
        "user-1/items/abc123.jpg",
        "user-1/items/abc123_thumb.webp",
    ]


@pytest.mark.asyncio
async def test_delete_normalizes_legacy_preview_keys():
    """A legacy per-user preview key held in a DB row resolves to the top-level
    layout on delete (storage_keys.normalize_preview_key) so a delete issued
    after the migration script has moved the bytes still finds the object.
    Canonical keys pass through unchanged."""
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.delete_multiple_images(
            db=MagicMock(),
            storage_paths=[
                "user-1/tmp/social-import/x.png",  # legacy per-user layout
                "user-1/items/abc123.jpg",  # canonical, untouched
            ],
        )

    assert sorted(backend.delete_calls) == [
        "tmp/user-1/social-import/x.png",  # normalized to the top-level folder
        "user-1/items/abc123.jpg",
        "user-1/items/abc123_thumb.webp",
    ]


# --------------------------------------------------------------------------- #
# resolve_owned_storage_paths includes thumbs (account deletion)
# --------------------------------------------------------------------------- #
class _Query:
    def __init__(self, db, table_name):
        self._db = db
        self._table = table_name
        self._filters = []

    def select(self, _columns="*", count=None):
        return self

    def eq(self, column, value):
        self._filters.append(("eq", column, value))
        return self

    def in_(self, column, values):
        self._filters.append(("in", column, values))
        return self

    def execute(self):
        rows = list(self._db.tables.get(self._table, []))
        for kind, column, value in self._filters:
            if kind == "eq":
                rows = [row for row in rows if row.get(column) == value]
            else:
                rows = [row for row in rows if row.get(column) in value]
        return SimpleNamespace(data=rows)


class _DB:
    def __init__(self, tables):
        self.tables = tables

    def table(self, table_name):
        return _Query(self, table_name)


@pytest.mark.asyncio
async def test_resolve_owned_storage_paths_includes_thumbs():
    db = _DB(
        {
            "items": [
                {
                    "id": "item-1",
                    "user_id": "user-1",
                    "source_image_storage_path": "user-1/sources/shot.jpg",
                },
                {"id": "item-2", "user_id": "user-2"},
            ],
            "item_images": [
                {"id": "img-1", "item_id": "item-1", "storage_path": "user-1/items/a.jpg"},
                {"id": "img-2", "item_id": "item-2", "storage_path": "user-2/items/b.jpg"},
            ],
            "outfits": [],
            "outfit_images": [],
        }
    )

    result = await StorageService.resolve_owned_storage_paths(db, "user-1")

    assert result["item_ids"] == ["item-1"]
    assert sorted(result["storage_paths"]) == [
        "user-1/items/a.jpg",
        "user-1/items/a_thumb.webp",
        "user-1/sources/shot.jpg",
        "user-1/sources/shot_thumb.webp",
    ]


# --------------------------------------------------------------------------- #
# materialize_image_urls serving modes
# --------------------------------------------------------------------------- #
def _presign(monkeypatch):
    async def _fake(key):
        return f"https://presigned.example/{key}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_fake))


def _img(storage_path="user-1/items/a.jpg"):
    return {
        "image_url": "https://stale/a.jpg",
        "thumbnail_url": "https://stale/a.jpg",
        "storage_path": storage_path,
    }


@pytest.mark.asyncio
async def test_materialize_presigned_mode_thumb_mirrors_image(monkeypatch):
    """Default mode: thumbnail_url mirrors image_url (legacy full-size)."""
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "presigned")
    monkeypatch.setattr(images_module.settings, "THUMBNAIL_SERVING", False)

    images = await images_module.materialize_image_urls([_img()])

    assert images[0]["image_url"] == "https://presigned.example/user-1/items/a.jpg"
    assert images[0]["thumbnail_url"] == images[0]["image_url"]


@pytest.mark.asyncio
async def test_materialize_thumbnail_serving_points_at_thumb_key(monkeypatch):
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "presigned")
    monkeypatch.setattr(images_module.settings, "THUMBNAIL_SERVING", True)
    monkeypatch.setattr(images_module.settings, "THUMBNAILS_BACKFILLED", True)

    images = await images_module.materialize_image_urls([_img()])

    assert images[0]["image_url"] == "https://presigned.example/user-1/items/a.jpg"
    assert (
        images[0]["thumbnail_url"]
        == "https://presigned.example/user-1/items/a_thumb.webp"
    )


@pytest.mark.asyncio
async def test_materialize_thumbnail_serving_backfill_not_done_mirrors_image(monkeypatch):
    """THUMBNAIL_SERVING on but THUMBNAILS_BACKFILLED off (the default until
    ops runs scripts/generate_thumbnails.py): the read path must NOT emit a
    thumb URL — pre-backfill objects have no ``_thumb`` sibling and a
    presigned URL for a missing object 404s the tile (the 404-tiles bug)."""
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "presigned")
    monkeypatch.setattr(images_module.settings, "THUMBNAIL_SERVING", True)
    monkeypatch.setattr(images_module.settings, "THUMBNAILS_BACKFILLED", False)

    images = await images_module.materialize_image_urls([_img()])

    assert images[0]["image_url"] == "https://presigned.example/user-1/items/a.jpg"
    assert images[0]["thumbnail_url"] == images[0]["image_url"]


@pytest.mark.asyncio
async def test_materialize_thumbnail_serving_tmp_has_no_thumb(monkeypatch):
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "presigned")
    monkeypatch.setattr(images_module.settings, "THUMBNAIL_SERVING", True)
    monkeypatch.setattr(images_module.settings, "THUMBNAILS_BACKFILLED", True)

    images = await images_module.materialize_image_urls(
        [_img("tmp/user-1/social-import/x.png")]
    )

    # tmp previews have no thumb variant; thumbnail_url mirrors image_url.
    assert images[0]["image_url"] == "https://presigned.example/tmp/user-1/social-import/x.png"
    assert images[0]["thumbnail_url"] == images[0]["image_url"]


@pytest.mark.asyncio
async def test_materialize_worker_mode_emits_stable_cdn_urls(monkeypatch):
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "worker")
    monkeypatch.setattr(
        images_module.settings, "IMAGE_CDN_BASE_URL", "https://images.fitcheckaiapp.com"
    )
    monkeypatch.setattr(images_module.settings, "THUMBNAIL_SERVING", True)
    monkeypatch.setattr(images_module.settings, "THUMBNAILS_BACKFILLED", True)

    images = await images_module.materialize_image_urls([_img()])

    # Stable, path-only URLs: no query string, so caches key cleanly.
    assert images[0]["image_url"] == "https://images.fitcheckaiapp.com/user-1/items/a.jpg"
    assert (
        images[0]["thumbnail_url"]
        == "https://images.fitcheckaiapp.com/user-1/items/a_thumb.webp"
    )


@pytest.mark.asyncio
async def test_materialize_worker_mode_without_base_falls_back_to_presigned(monkeypatch):
    _presign(monkeypatch)
    monkeypatch.setattr(images_module.settings, "IMAGE_SERVING_MODE", "worker")
    monkeypatch.setattr(images_module.settings, "IMAGE_CDN_BASE_URL", "")

    images = await images_module.materialize_image_urls([_img()])

    # No CDN base configured -> presigned fallback so reads never break.
    assert images[0]["image_url"] == "https://presigned.example/user-1/items/a.jpg"


# --------------------------------------------------------------------------- #
# _is_owned_by_user covers `generated/` previews
# --------------------------------------------------------------------------- #
# `generated/{user}/{image_type}/{name}` holds try-on / outfit renders the user
# asked to keep. It was absent from the key allowlist, so GET /images/presigned
# 404'd on it and the presigned URL returned once at generation time could never
# be refreshed — the image simply vanished after OBJECT_STORAGE_PRESIGN_TTL.
def test_is_owned_by_user_accepts_generated_preview_keys():
    name = "0123456789abcdef0123456789abcdef"
    for image_type in ("try-on", "outfit"):
        key = f"generated/user-a/{image_type}/{name}.png"
        assert images_module._is_owned_by_user(key, "user-a") is True
        # The legacy per-user layout stays servable during the migration window
        # (scripts/migrate_temp_keys_layout.py), then the regex is removed.
        legacy = f"user-a/generated/{image_type}/{name}.png"
        assert images_module._is_owned_by_user(legacy, "user-a") is True


def test_is_owned_by_user_still_accepts_tmp_and_canonical_keys():
    name = "0123456789abcdef0123456789abcdef"
    assert images_module._is_owned_by_user(f"user-a/items/{name}.webp", "user-a")
    assert images_module._is_owned_by_user(
        f"tmp/user-a/social-import/{name}.webp", "user-a"
    )
    assert images_module._is_owned_by_user(
        f"user-a/tmp/social-import/{name}.webp", "user-a"
    )


def test_is_owned_by_user_rejects_cross_user_and_malformed_generated_keys():
    name = "0123456789abcdef0123456789abcdef"
    # Another user's generated key (both layouts).
    assert not images_module._is_owned_by_user(f"generated/user-b/outfit/{name}.png", "user-a")
    assert not images_module._is_owned_by_user(f"user-b/generated/outfit/{name}.png", "user-a")
    # Traversal / separator tricks and a wrong-shaped name must still fail.
    assert not images_module._is_owned_by_user("generated/user-a/../items/x.png", "user-a")
    assert not images_module._is_owned_by_user("generated/user-a/outfit/short.png", "user-a")
    assert not images_module._is_owned_by_user(f"generated/{name}.png", "user-a")
    assert not images_module._is_owned_by_user(f"generated/user-a/{name}.png", "user-a")
    # An unknown two-segment category is not in the allowlist.
    assert not images_module._is_owned_by_user(f"user-a/export/{name}.png", "user-a")


# --------------------------------------------------------------------------- #
# thumbnails preserve transparency
# --------------------------------------------------------------------------- #
# Item images are routinely background-removed cutouts (background_removal.py
# emits transparent WebP/PNG). The first implementation routed thumbs through the
# AI-bound downscaler, which flattens alpha onto WHITE because providers need
# opaque JPEG — so every garment tile would have shown a white block behind it
# while the full-size image the card opens stayed transparent. Worse, it was
# inconsistent: the "keep whichever is smaller" branch preserved the original for
# small transparent WebPs, so some tiles were transparent and others were not.
def _transparent_png_bytes(size=(900, 900)) -> bytes:
    import io

    buffer = io.BytesIO()
    img = Image.new("RGBA", size, (0, 0, 0, 0))
    # An opaque blob in the middle, transparent margins.
    for x in range(size[0] // 4, size[0] // 2):
        for y in range(size[1] // 4, size[1] // 2):
            img.putpixel((x, y), (200, 30, 40, 255))
    img.save(buffer, format="PNG")
    return buffer.getvalue()


def test_thumbnail_encoder_preserves_alpha():
    import io

    from app.utils.image_processing import downscale_image_bytes_to_webp

    thumb = downscale_image_bytes_to_webp(_transparent_png_bytes(), 512, 75)
    assert thumb is not None
    with Image.open(io.BytesIO(thumb)) as img:
        assert img.format == "WEBP"
        assert img.mode in ("RGBA", "LA", "PA"), "thumbnail lost its alpha channel"
        # The corner was fully transparent in the source and must stay so.
        assert img.convert("RGBA").getpixel((0, 0))[3] == 0


def test_thumbnail_encoder_downscales_and_shrinks():
    import io

    from app.utils.image_processing import downscale_image_bytes_to_webp

    source = _transparent_png_bytes((900, 900))
    thumb = downscale_image_bytes_to_webp(source, 512, 75)
    assert thumb is not None
    with Image.open(io.BytesIO(thumb)) as img:
        assert max(img.size) == 512
    assert len(thumb) < len(source)


def test_thumbnail_encoder_passes_a_small_webp_through_unchanged():
    """An already-small WebP is its own best thumbnail; re-encoding only loses
    quality. It returns the ORIGINAL BYTES, not None — None is reserved for
    "no thumbnail could be made"."""
    import io

    from app.utils.image_processing import downscale_image_bytes_to_webp

    buffer = io.BytesIO()
    Image.new("RGBA", (64, 64), (10, 20, 30, 128)).save(buffer, format="WEBP")
    source = buffer.getvalue()
    assert downscale_image_bytes_to_webp(source, 512, 75) == source


def test_thumbnail_encoder_returns_none_only_when_it_cannot_produce_webp():
    from app.utils.image_processing import downscale_image_bytes_to_webp

    assert downscale_image_bytes_to_webp(b"not an image at all", 512, 75) is None
    assert downscale_image_bytes_to_webp(b"", 512, 75) is None


@pytest.mark.asyncio
async def test_no_thumb_object_is_written_when_encoding_fails():
    """A failed encode must write NOTHING, not fall back to the full-size bytes.

    Storing the original under the thumb key would serve full-size images to every
    grid tile — the exact egress cost thumbnails exist to remove — and would put
    non-WebP bytes under a `.webp` key.
    """
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        with patch(
            "app.services.storage_service.downscale_image_bytes_to_webp",
            return_value=None,
        ):
            written = await StorageService._upload_thumbnail(
                backend, "user-1/items/abc123.png", _png_bytes()
            )

    assert written is False
    assert [c for c in backend.upload_calls if "_thumb" in c["key"]] == []


@pytest.mark.asyncio
async def test_uploaded_thumb_is_webp_with_a_matching_content_type():
    backend = FakeS3Backend()
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        await StorageService.upload_item_image(
            db=MagicMock(),
            user_id="user-1",
            filename="cutout.png",
            file_data=_transparent_png_bytes(),
        )

    thumb_calls = [c for c in backend.upload_calls if "_thumb" in c["key"]]
    assert len(thumb_calls) == 1
    call = thumb_calls[0]
    assert call["key"].endswith(".webp")
    assert call["content_type"] == "image/webp"
    # And the stored bytes really are WebP with alpha intact.
    import io

    with Image.open(io.BytesIO(call["data"])) as img:
        assert img.format == "WEBP"
        assert img.convert("RGBA").getpixel((0, 0))[3] == 0


def test_is_owned_by_user_accepts_thumb_siblings_matching_the_worker():
    """The endpoint and infra/images-worker must agree on the servable key set."""
    name = "0123456789abcdef0123456789abcdef"
    assert images_module._is_owned_by_user(f"user-a/items/{name}_thumb.webp", "user-a")
    # Thumbs are always .webp, so any other extension is not one of ours.
    assert not images_module._is_owned_by_user(
        f"user-a/items/{name}_thumb.jpg", "user-a"
    )
    # Cross-user thumb stays a 404.
    assert not images_module._is_owned_by_user(
        f"user-b/items/{name}_thumb.webp", "user-a"
    )
    # A thumb key is exactly what thumb_key_for produces.
    derived = StorageService.thumb_key_for(f"user-a/items/{name}.png")
    assert images_module._is_owned_by_user(derived, "user-a")


# --------------------------------------------------------------------------- #
# admin temp inventory scan (list_temp_objects)
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_list_temp_objects_matches_both_tmp_layouts():
    """The admin inventory filter must see the top-level tmp/ folder AND the
    legacy per-user one, and never canonical or generated/ objects."""
    backend = FakeS3Backend(
        objects=[
            {"key": "tmp/u1/photoshoot/a.png", "size": 100, "last_modified": "2026-08-07T00:00:00+00:00"},
            {"key": "tmp/u2/batch/b.webp", "size": 200, "last_modified": "2026-08-07T00:00:00+00:00"},
            {"key": "u3/tmp/social-import/c.png", "size": 300, "last_modified": "2026-08-07T00:00:00+00:00"},
            {"key": "u1/items/d.jpg", "size": 400, "last_modified": "2026-08-07T00:00:00+00:00"},
            {"key": "generated/u1/try-on/e.png", "size": 500, "last_modified": "2026-08-07T00:00:00+00:00"},
        ]
    )
    with patch("app.services.storage_service.get_storage_backend", return_value=backend):
        inventory = await StorageService.list_temp_objects(max_pages=50)

    assert inventory["count"] == 3
    assert sorted(item["key"] for item in inventory["items"]) == [
        "tmp/u1/photoshoot/a.png",
        "tmp/u2/batch/b.webp",
        "u3/tmp/social-import/c.png",
    ]
    assert inventory["total_bytes"] == 600
    assert inventory["scanned_keys"] == 5
    assert inventory["truncated"] is False
