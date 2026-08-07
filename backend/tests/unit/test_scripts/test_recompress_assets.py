"""Tests for scripts/recompress_assets.py (storage-budget backfill).

The script is imported by path (it lives in scripts/, not a package), the
same way test_temp_cleanup_script.py loads its script. Pure helpers
(decide_reencode, category_of, _KEY_RE, audit resume) are tested directly; the
async _run dry-run/apply behavior is exercised against a fake backend with no
network.
"""

from __future__ import annotations

import importlib.util
import io
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import app

import pytest
from PIL import Image

BACKEND_ROOT = Path(app.__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "recompress_assets.py"

NAME = "0123456789abcdef0123456789abcdef"
NOW = datetime(2026, 8, 7, 12, 0, 0, tzinfo=timezone.utc)


@pytest.fixture(scope="module")
def script():
    """Load recompress_assets.py by path and return the module object."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("recompress_assets", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def _photo_jpeg(width: int = 1200, height: int = 1600, quality: int = 95) -> bytes:
    """A smooth photo-like gradient: compresses dramatically better as WebP."""
    buf = io.BytesIO()
    grad = Image.linear_gradient("L").resize((width, height))
    Image.merge("RGB", [grad, grad, grad]).save(buf, format="JPEG", quality=quality)
    return buf.getvalue()


def _tiny_jpeg() -> bytes:
    buf = io.BytesIO()
    Image.new("RGB", (16, 16), (1, 2, 3)).save(buf, format="JPEG")
    return buf.getvalue()


def _optimized_webp() -> bytes:
    buf = io.BytesIO()
    Image.new("RGBA", (64, 64), (1, 2, 3, 128)).save(buf, format="WEBP", quality=75)
    return buf.getvalue()


def _animated_gif() -> bytes:
    frames = [Image.new("P", (32, 32), color) for color in (1, 2)]
    buf = io.BytesIO()
    frames[0].save(
        buf, format="GIF", save_all=True, append_images=frames[1:], duration=100, loop=0
    )
    return buf.getvalue()


# --------------------------------------------------------------------------- #
# key matching (pure)
# --------------------------------------------------------------------------- #
def test_key_re_matches_canonical_and_generated_layouts(script):
    assert script._KEY_RE.fullmatch(f"u1/items/{NAME}.jpg")
    assert script._KEY_RE.fullmatch(f"u1/outfits/{NAME}.png")
    assert script._KEY_RE.fullmatch(f"u1/avatars/{NAME}.webp")
    assert script._KEY_RE.fullmatch(f"u1/sources/{NAME}.jpeg")
    assert script._KEY_RE.fullmatch(f"u1/feedback/{NAME}.avif")
    # Both generated layouts (top-level folder + legacy per-user).
    assert script._KEY_RE.fullmatch(f"generated/u1/try-on/{NAME}.png")
    assert script._KEY_RE.fullmatch(f"u1/generated/product/{NAME}.webp")


def test_key_re_rejects_thumbs_tmp_and_exports(script):
    # Thumb siblings are derived objects; the parent pass regenerates them.
    assert not script._KEY_RE.fullmatch(f"u1/items/{NAME}_thumb.webp")
    # Transient previews are the weekly cleanup's job, not this backfill's.
    assert not script._KEY_RE.fullmatch(f"tmp/u1/photoshoot/{NAME}.png")
    assert not script._KEY_RE.fullmatch(f"u1/tmp/batch/{NAME}.png")
    # Exports and data blobs are never images.
    assert not script._KEY_RE.fullmatch("u1/export/data.json")
    # Wrong shapes: short names, non-image extensions.
    assert not script._KEY_RE.fullmatch("u1/items/short.jpg")
    assert not script._KEY_RE.fullmatch(f"u1/items/{NAME}.txt")


def test_category_of(script):
    assert script.category_of(f"u1/items/{NAME}.jpg") == "items"
    assert script.category_of(f"generated/u1/try-on/{NAME}.png") == "generated"
    assert script.category_of(f"u1/generated/product/{NAME}.png") == "generated"


# --------------------------------------------------------------------------- #
# decide_reencode (pure)
# --------------------------------------------------------------------------- #
def test_decide_reencode_large_jpeg_returns_smaller_webp(script):
    jpg = _photo_jpeg()
    webp = script.decide_reencode(jpg)
    assert webp is not None
    assert len(webp) < len(jpg)
    with Image.open(io.BytesIO(webp)) as img:
        assert img.format == "WEBP"
        assert max(img.size) <= 2048


def test_decide_reencode_keep_smaller_passes_optimized_webp(script):
    # An already-optimized WebP within the max edge is returned unchanged by
    # the encoder, so the size comparison never fires -> None means "leave
    # byte-identical" (deterministic: no re-encode happens at all).
    buf = io.BytesIO()
    Image.new("RGBA", (64, 64), (1, 2, 3, 128)).save(buf, format="WEBP", quality=75)
    assert script.decide_reencode(buf.getvalue()) is None


def test_decide_reencode_preserves_alpha(script):
    buf = io.BytesIO()
    Image.new("RGBA", (900, 900), (255, 0, 0, 128)).save(buf, format="PNG")
    png = buf.getvalue()
    webp = script.decide_reencode(png)
    assert webp is not None
    assert len(webp) < len(png)
    with Image.open(io.BytesIO(webp)) as img:
        assert img.mode == "RGBA"


def test_decide_reencode_skips_animated_gifs(script):
    assert script.decide_reencode(_animated_gif()) is None


# --------------------------------------------------------------------------- #
# audit resume (pure)
# --------------------------------------------------------------------------- #
def test_audit_resume_skips_terminal_actions_only(script, tmp_path):
    audit = tmp_path / "audit.jsonl"
    for action, key in (
        ("reencoded", f"u1/items/{NAME}.jpg"),
        ("error", f"u1/items/{'b' * 32}.jpg"),
        ("unchanged", f"u1/items/{'c' * 32}.jpg"),
    ):
        script.append_audit(audit, script.make_record(key=key, action=action))

    done = script.load_audit(audit)
    # Terminal actions are skipped; a transient error stays retryable.
    assert f"u1/items/{NAME}.jpg" in done
    assert f"u1/items/{'c' * 32}.jpg" in done
    assert f"u1/items/{'b' * 32}.jpg" not in done


# --------------------------------------------------------------------------- #
# async _run against a fake backend (no network)
# --------------------------------------------------------------------------- #
class _FakePageIter:
    def __init__(self, pages):
        self._pages = list(pages)

    def __aiter__(self):
        return self

    async def __anext__(self):
        if not self._pages:
            raise StopAsyncIteration
        return self._pages.pop(0)


class _FakePaginator:
    def __init__(self, pages):
        self._pages = list(pages)

    def paginate(self, **_kwargs):
        return _FakePageIter(self._pages)


class _FakeClient:
    def __init__(self, keys):
        self._pages = [{"Contents": [{"Key": k, "LastModified": NOW} for k in keys]}]

    def get_paginator(self, name):
        assert name == "list_objects_v2"
        return _FakePaginator(self._pages)


class _FakeBackend:
    """In-memory bucket: download returns per-key bytes, upload records."""

    def __init__(self, objects: dict):
        self.objects = dict(objects)  # key -> bytes
        self.uploads: list[dict] = []
        self.bucket = "test-bucket"
        self.endpoint_url = "https://s3.example.com"
        self._client = _FakeClient(list(self.objects))

    async def _get_client(self):
        return self._client

    async def download(self, key):
        return self.objects[key]

    async def upload(self, key, data, content_type, cache_control):
        self.uploads.append(
            dict(key=key, data=data, content_type=content_type, cache_control=cache_control)
        )


async def _noop_close():
    return None


def _patch_backend(script, backend):
    script.get_storage_backend = lambda: backend
    script.close_storage_backend = _noop_close


def _listing(keys):
    return {k: NOW for k in keys}


@pytest.mark.asyncio
async def test_run_dry_run_never_writes(script, tmp_path):
    big = f"u1/items/{NAME}.jpg"
    backend = _FakeBackend({big: _photo_jpeg(), f"u1/items/{'c' * 32}.jpg": _tiny_jpeg()})
    _patch_backend(script, backend)
    rc = await script._run(
        apply=False,
        audit_path=tmp_path / "audit.jsonl",
        concurrency=1,
        limit=0,
        only_category=None,
        listing=_listing(backend.objects),
    )
    assert rc == 0
    assert backend.uploads == []
    assert not (tmp_path / "audit.jsonl").exists()


@pytest.mark.asyncio
async def test_run_apply_reencodes_and_backfills_thumbs(script, tmp_path):
    reencode_key = f"u1/items/{NAME}.jpg"  # big JPEG -> smaller WebP + thumb
    unchanged_key = f"u1/items/{'c' * 32}.webp"  # optimized -> untouched, thumb created
    thumbed_key = f"u1/items/{'d' * 32}.jpg"  # has an existing thumb sibling
    thumb_sibling = f"u1/items/{'d' * 32}_thumb.webp"
    generated_key = f"generated/u1/try-on/{'e' * 32}.png"  # no thumb by design
    tmp_key = f"tmp/u1/photoshoot/{'f' * 32}.png"  # excluded

    backend = _FakeBackend(
        {
            reencode_key: _photo_jpeg(),
            unchanged_key: _optimized_webp(),
            thumbed_key: _photo_jpeg(),
            thumb_sibling: b"existing-thumb-bytes",
            generated_key: _photo_jpeg(),
            tmp_key: _photo_jpeg(),
        }
    )
    _patch_backend(script, backend)
    rc = await script._run(
        apply=True,
        audit_path=tmp_path / "audit.jsonl",
        concurrency=1,
        limit=0,
        only_category=None,
        listing=_listing(backend.objects),
    )
    assert rc == 0

    upload_keys = [u["key"] for u in backend.uploads]
    # The big JPEG was overwritten as WebP; its thumb regenerated from the
    # new bytes. The unchanged key got a thumb backfill only. The already
    # thumbed key was re-encoded AND its thumb regenerated. Generated gets no
    # thumb (thumb_key_for returns None). tmp/ is never touched.
    assert reencode_key in upload_keys
    assert f"u1/items/{NAME}_thumb.webp" in upload_keys
    assert unchanged_key not in upload_keys
    assert f"u1/items/{'c' * 32}_thumb.webp" in upload_keys
    assert thumbed_key in upload_keys
    assert thumb_sibling in upload_keys
    assert generated_key in upload_keys
    assert not any(k.startswith("tmp/") for k in upload_keys)

    # The re-encoded parent carries the real content type and a short TTL so
    # CDN/browser caches refresh quickly.
    parent = next(u for u in backend.uploads if u["key"] == reencode_key)
    assert parent["content_type"] == "image/webp"
    assert parent["cache_control"] == "60"
    assert len(parent["data"]) < len(_photo_jpeg())

    # Audit: every processed key recorded; terminal actions resume-skip.
    audit = (tmp_path / "audit.jsonl").read_text()
    assert reencode_key in audit
    assert tmp_key not in audit

    rc2 = await script._run(
        apply=True,
        audit_path=tmp_path / "audit.jsonl",
        concurrency=1,
        limit=0,
        only_category=None,
        listing=_listing(backend.objects),
    )
    assert rc2 == 0
    # No second-round writes: everything is terminal in the audit.
    assert len(backend.uploads) == len(upload_keys)


@pytest.mark.asyncio
async def test_run_apply_thumb_failure_records_error_not_terminal(
    script, tmp_path, monkeypatch
):
    # A re-encoded parent whose thumb write fails must record an ERROR
    # (retryable on resume), not a terminal action that skips the key forever
    # with no thumb. The parent itself is still overwritten: a thumb failure
    # never fails the parent.
    key = f"u1/items/{NAME}.jpg"
    backend = _FakeBackend({key: _photo_jpeg()})
    _patch_backend(script, backend)

    async def _failing_thumb(backend, storage_path, file_data):
        return False

    monkeypatch.setattr(script.StorageService, "_upload_thumbnail", _failing_thumb)
    rc = await script._run(
        apply=True,
        audit_path=tmp_path / "audit.jsonl",
        concurrency=1,
        limit=0,
        only_category=None,
        listing=_listing(backend.objects),
    )
    assert rc == 0
    assert key in [u["key"] for u in backend.uploads]
    # Error actions are not terminal, so resume will retry this key.
    assert script.load_audit(tmp_path / "audit.jsonl") == set()
    records = [
        json.loads(line)
        for line in (tmp_path / "audit.jsonl").read_text().splitlines()
    ]
    assert records[0]["action"] == "error"
    assert records[0]["error"] == "thumb_failed"


@pytest.mark.asyncio
async def test_run_only_category_scopes_targets(script, tmp_path):
    backend = _FakeBackend(
        {
            f"u1/items/{NAME}.jpg": _photo_jpeg(),
            f"u1/outfits/{'c' * 32}.png": _photo_jpeg(),
        }
    )
    _patch_backend(script, backend)
    rc = await script._run(
        apply=True,
        audit_path=tmp_path / "audit.jsonl",
        concurrency=1,
        limit=0,
        only_category="outfits",
        listing=_listing(backend.objects),
    )
    assert rc == 0
    upload_keys = [u["key"] for u in backend.uploads]
    assert all("items" not in k for k in upload_keys)
    assert any("outfits" in k for k in upload_keys)
