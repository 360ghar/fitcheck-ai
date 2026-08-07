"""Tests for scripts/cleanup_temp_assets.py (weekly temp-preview cleanup).

The script is imported by path (it lives in scripts/, not a package), the same
way test_storage_inventory_age.py loads its script. The pure helpers (_TMP_KEY_RE
matching, temp_source, split_by_age, age_hours) are tested directly; the async
_run dry-run/delete behavior is exercised against a fake backend with no
network.
"""

from __future__ import annotations

import importlib.util
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest

BACKEND_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "cleanup_temp_assets.py"

NAME = "0123456789abcdef0123456789abcdef"
NOW = datetime(2026, 8, 7, 12, 0, 0, tzinfo=timezone.utc)


@pytest.fixture(scope="module")
def script():
    """Load cleanup_temp_assets.py by path and return the module object."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("cleanup_temp_assets", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --------------------------------------------------------------------------- #
# key matching (pure)
# --------------------------------------------------------------------------- #
def test_tmp_key_re_matches_both_layouts(script):
    assert script._TMP_KEY_RE.fullmatch(f"tmp/u1/photoshoot/{NAME}.png")
    assert script._TMP_KEY_RE.fullmatch(f"tmp/u1/batch/{NAME}.webp")
    assert script._TMP_KEY_RE.fullmatch(f"tmp/u1/social-import/{NAME}.jpg")
    assert script._TMP_KEY_RE.fullmatch(f"u1/tmp/social-import/{NAME}.webp")


def test_tmp_key_re_rejects_canonical_and_generated_keys(script):
    # Canonical images are never temp and must never be matched.
    assert not script._TMP_KEY_RE.fullmatch(f"u1/items/{NAME}.jpg")
    assert not script._TMP_KEY_RE.fullmatch(f"u1/outfits/{NAME}.png")
    assert not script._TMP_KEY_RE.fullmatch(f"u1/sources/{NAME}.webp")
    # User-saved renders are NOT temp (30-day retention policy).
    assert not script._TMP_KEY_RE.fullmatch(f"generated/u1/try-on/{NAME}.png")
    assert not script._TMP_KEY_RE.fullmatch(f"u1/generated/try-on/{NAME}.png")
    # Wrong shapes: short names, non-image extensions, missing source segment.
    assert not script._TMP_KEY_RE.fullmatch("tmp/u1/photoshoot/short.png")
    assert not script._TMP_KEY_RE.fullmatch(f"tmp/u1/photoshoot/{NAME}.txt")
    assert not script._TMP_KEY_RE.fullmatch(f"u1/tmp/{NAME}.png")


def test_temp_source_extraction(script):
    # The source segment is index 2 in BOTH layouts.
    assert script.temp_source(f"tmp/u1/photoshoot/{NAME}.png") == "photoshoot"
    assert script.temp_source(f"u1/tmp/social-import/{NAME}.png") == "social-import"


# --------------------------------------------------------------------------- #
# age gating (pure)
# --------------------------------------------------------------------------- #
def test_split_by_age_default_zero_deletes_everything(script):
    # Default (no age gate): every temp key is deletable, even a fresh one —
    # weekly cleanup may delete live-TTL previews, which is harmless by policy.
    key = f"tmp/u1/photoshoot/{NAME}.png"
    deletable, protected = script.split_by_age([key], {key: NOW}, min_age_hours=0, now=NOW)
    assert deletable == [key]
    assert protected == []


def test_split_by_age_window_protects_recent_and_unknown(script):
    key = f"tmp/u1/photoshoot/{NAME}.png"
    # 30 min old, inside a 2h window -> protected.
    deletable, protected = script.split_by_age(
        [key], {key: NOW - timedelta(minutes=30)}, min_age_hours=2, now=NOW
    )
    assert deletable == []
    assert protected == [key]
    # Unknown mtime -> protected under a positive window (never delete what we
    # cannot age-verify).
    deletable, protected = script.split_by_age([key], {}, min_age_hours=2, now=NOW)
    assert deletable == []
    assert protected == [key]


def test_split_by_age_window_cutoff_is_inclusive(script):
    key = f"tmp/u1/batch/{NAME}.webp"
    deletable, protected = script.split_by_age(
        [key], {key: NOW - timedelta(hours=2)}, min_age_hours=2, now=NOW
    )
    assert deletable == [key]
    assert protected == []


def test_age_hours_round_trips(script):
    assert script.age_hours(NOW - timedelta(hours=3, minutes=15), NOW) == 3.25
    assert script.age_hours(None, NOW) is None


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
    def __init__(self, keys):
        self.keys = list(keys)
        self.deleted = []
        self.bucket = "test-bucket"
        self.endpoint_url = "https://s3.example.com"
        self._client = _FakeClient(self.keys)

    async def _get_client(self):
        return self._client

    async def delete_many(self, keys):
        self.deleted.extend(keys)
        return len(keys)


async def _noop_close():
    return None


def _patch_backend(script, backend):
    script.get_storage_backend = lambda: backend
    script.close_storage_backend = _noop_close


@pytest.mark.asyncio
async def test_run_dry_run_never_deletes(script, tmp_path):
    backend = _FakeBackend(
        [
            f"tmp/u1/photoshoot/{NAME}.png",
            f"u1/items/{NAME}.jpg",
            f"generated/u1/try-on/{NAME}.png",
        ]
    )
    _patch_backend(script, backend)
    rc = await script._run(
        delete=False, audit_path=tmp_path / "audit.jsonl", min_age_hours=0, source=None
    )
    assert rc == 0
    assert backend.deleted == []
    assert not (tmp_path / "audit.jsonl").exists()


@pytest.mark.asyncio
async def test_run_delete_removes_only_tmp_objects(script, tmp_path):
    backend = _FakeBackend(
        [
            f"tmp/u1/photoshoot/{NAME}.png",
            f"tmp/u2/social-import/{NAME}.webp",
            f"u1/items/{NAME}.jpg",  # canonical -> never deleted
            f"generated/u1/try-on/{NAME}.png",  # user-saved -> never deleted
        ]
    )
    _patch_backend(script, backend)
    rc = await script._run(
        delete=True, audit_path=tmp_path / "audit.jsonl", min_age_hours=0, source=None
    )
    assert rc == 0
    assert sorted(backend.deleted) == [
        f"tmp/u1/photoshoot/{NAME}.png",
        f"tmp/u2/social-import/{NAME}.webp",
    ]
    audit = (tmp_path / "audit.jsonl").read_text()
    assert f"tmp/u1/photoshoot/{NAME}.png" in audit
    assert "u1/items" not in audit
    assert "generated/u1" not in audit


@pytest.mark.asyncio
async def test_run_source_filter_scopes_the_delete(script, tmp_path):
    backend = _FakeBackend(
        [f"tmp/u1/photoshoot/{NAME}.png", f"tmp/u1/batch/{NAME}.png"]
    )
    _patch_backend(script, backend)
    await script._run(
        delete=True,
        audit_path=tmp_path / "audit.jsonl",
        min_age_hours=0,
        source="photoshoot",
    )
    assert backend.deleted == [f"tmp/u1/photoshoot/{NAME}.png"]
