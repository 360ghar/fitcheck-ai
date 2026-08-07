"""Tests for scripts/migrate_temp_keys_layout.py (preview-key layout migration).

The script is imported by path (it lives in scripts/, not a package), the same
way test_storage_inventory_age.py loads its script. The pure key-mapping helper
is tested directly; the async _run dry-run/apply behavior is exercised against
a fake backend with no network.
"""

from __future__ import annotations

import importlib.util
import sys
from datetime import datetime, timezone
from pathlib import Path

import app

import pytest

BACKEND_ROOT = Path(app.__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "migrate_temp_keys_layout.py"

NAME = "0123456789abcdef0123456789abcdef"
NOW = datetime(2026, 8, 7, 12, 0, 0, tzinfo=timezone.utc)


@pytest.fixture(scope="module")
def script():
    """Load migrate_temp_keys_layout.py by path and return the module object."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("migrate_temp_keys_layout", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --------------------------------------------------------------------------- #
# legacy_to_new_key (pure)
# --------------------------------------------------------------------------- #
def test_legacy_to_new_key_maps_both_folders(script):
    assert (
        script.legacy_to_new_key(f"u1/tmp/photoshoot/{NAME}.png")
        == f"tmp/u1/photoshoot/{NAME}.png"
    )
    assert (
        script.legacy_to_new_key(f"u1/tmp/social-import/{NAME}.webp")
        == f"tmp/u1/social-import/{NAME}.webp"
    )
    assert (
        script.legacy_to_new_key(f"u1/generated/try-on/{NAME}.png")
        == f"generated/u1/try-on/{NAME}.png"
    )


def test_legacy_to_new_key_rejects_non_legacy_keys(script):
    # Canonical keys never move.
    assert script.legacy_to_new_key(f"u1/items/{NAME}.jpg") is None
    assert script.legacy_to_new_key(f"u1/outfits/{NAME}.png") is None
    # New-layout keys are already migrated (idempotent re-runs).
    assert script.legacy_to_new_key(f"tmp/u1/photoshoot/{NAME}.png") is None
    assert script.legacy_to_new_key(f"generated/u1/try-on/{NAME}.png") is None
    # Thumb siblings, exports, and wrong shapes never move.
    assert script.legacy_to_new_key(f"u1/items/{NAME}_thumb.webp") is None
    assert script.legacy_to_new_key("u1/export/data.json") is None
    assert script.legacy_to_new_key("u1/tmp/photoshoot/short.png") is None
    assert script.legacy_to_new_key(f"u1/tmp/{NAME}.png") is None
    assert script.legacy_to_new_key(f"u1/tmp/photoshoot/{NAME}.txt") is None


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
        self.copy_calls = []
        self.delete_calls = []
        self.bucket = "test-bucket"
        self.endpoint_url = "https://s3.example.com"
        self._client = _FakeClient(self.keys)

    async def _get_client(self):
        return self._client

    async def copy(self, src_key, dst_key):
        self.copy_calls.append((src_key, dst_key))

    async def delete(self, key):
        self.delete_calls.append(key)


async def _noop_close():
    return None


def _patch_backend(script, backend):
    script.get_storage_backend = lambda: backend
    script.close_storage_backend = _noop_close


@pytest.mark.asyncio
async def test_run_dry_run_performs_no_writes(script, tmp_path):
    backend = _FakeBackend([f"u1/tmp/photoshoot/{NAME}.png", f"u1/items/{NAME}.jpg"])
    _patch_backend(script, backend)
    rc = await script._run(apply=False, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0
    assert backend.copy_calls == []
    assert backend.delete_calls == []
    assert not (tmp_path / "audit.jsonl").exists()


@pytest.mark.asyncio
async def test_run_apply_moves_only_legacy_preview_keys(script, tmp_path):
    backend = _FakeBackend(
        [
            f"u1/tmp/photoshoot/{NAME}.png",
            f"u1/generated/try-on/{NAME}.png",
            f"u1/items/{NAME}.jpg",  # canonical -> never moved
            f"tmp/u2/batch/{NAME}.png",  # already new layout -> never moved
        ]
    )
    _patch_backend(script, backend)
    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0
    assert sorted(backend.copy_calls) == [
        (f"u1/generated/try-on/{NAME}.png", f"generated/u1/try-on/{NAME}.png"),
        (f"u1/tmp/photoshoot/{NAME}.png", f"tmp/u1/photoshoot/{NAME}.png"),
    ]
    assert sorted(backend.delete_calls) == [
        f"u1/generated/try-on/{NAME}.png",
        f"u1/tmp/photoshoot/{NAME}.png",
    ]
    audit = (tmp_path / "audit.jsonl").read_text()
    assert '"action":"move"' in audit
    assert "u1/items" not in audit
    assert "tmp/u2/batch" not in audit


@pytest.mark.asyncio
async def test_run_apply_skips_colliding_targets(script, tmp_path):
    # A partial prior run left the target in place: the pair must be skipped,
    # never clobbered by copy_object.
    backend = _FakeBackend(
        [f"u1/tmp/photoshoot/{NAME}.png", f"tmp/u1/photoshoot/{NAME}.png"]
    )
    _patch_backend(script, backend)
    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0
    assert backend.copy_calls == []
    assert backend.delete_calls == []
    audit = (tmp_path / "audit.jsonl").read_text()
    assert '"action":"skip"' in audit
