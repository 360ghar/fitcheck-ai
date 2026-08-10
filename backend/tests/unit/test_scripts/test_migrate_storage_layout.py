"""Tests for scripts/migrate_storage_layout_users.py (users/ layout migration).

The script is imported by path (it lives in scripts/, not a package), the same
way test_migrate_temp_keys_layout.py loads its script. The pure promotion helper
``_promotion_target`` is tested directly; the async ``_run`` dry-run/apply
behavior is exercised against a fake backend + the shared in-memory FakeDB with
no network.

Covers the three code-review fixes:
  (1) preview-promotion fires for legacy generated keys,
  (2) duplicate destinations are deduped before the concurrent copy,
  (3) a target-already-existing pair still gets its DB refs rewritten (resume).
"""

from __future__ import annotations

import importlib.util
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import app

import pytest

BACKEND_ROOT = Path(app.__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "migrate_storage_layout_users.py"

USER_ID = "11111111-1111-1111-1111-111111111111"
NAME = "0123456789abcdef0123456789abcdef"
NOW = datetime(2026, 8, 10, 12, 0, 0, tzinfo=timezone.utc)


@pytest.fixture(scope="module")
def script():
    """Load migrate_storage_layout_users.py by path and return the module."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location(
        "migrate_storage_layout_users", SCRIPT_PATH
    )
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --------------------------------------------------------------------------- #
# _promotion_target (pure) — Finding 1
# --------------------------------------------------------------------------- #
def test_promotion_target_promotes_legacy_generated_key(script):
    # A DB-referenced legacy preview key (raw legacy bucket key, no users/
    # prefix) is promoted to a users/{user}/items/ key.
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    db_paths = {legacy}
    target = script._promotion_target(legacy, db_paths)
    assert target is not None
    assert target.startswith(f"users/{USER_ID}/items/")
    assert target.endswith(".png")


def test_promotion_target_promotes_top_level_tmp_key(script):
    # The other legacy preview spelling (top-level tmp/) also promotes.
    legacy = f"tmp/{USER_ID}/batch/{NAME}.png"
    db_paths = {legacy}
    target = script._promotion_target(legacy, db_paths)
    assert target is not None
    assert target.startswith(f"users/{USER_ID}/items/")


def test_promotion_target_returns_none_for_unreferenced_key(script):
    # A preview key the DB does NOT reference is never promoted (it re-keys
    # as staging instead).
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    assert script._promotion_target(legacy, set()) is None


def test_promotion_target_returns_none_for_canonical_key(script):
    # A durable canonical key is not a preview, so no promotion.
    canonical = f"{USER_ID}/items/{NAME}.png"
    assert script._promotion_target(canonical, {canonical}) is None


# --------------------------------------------------------------------------- #
# async _run against a fake backend + FakeDB (no network)
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
    """Mirrors the bits of S3StorageBackend the script touches.

    ``existing`` is the set of keys ``exists()`` reports as present so the
    resume path (Finding 3) can be exercised: a target already in ``existing``
    short-circuits the copy and is HEAD-verified against this same set.
    """

    def __init__(self, keys):
        self.keys = list(keys)
        self.existing = set(keys)
        self.copy_calls = []
        self.delete_calls = []
        self.exists_calls = []
        self.bucket = "test-bucket"
        self.endpoint_url = "https://s3.example.com"
        self._client = _FakeClient(self.keys)

    async def _get_client(self):
        return self._client

    async def copy(self, src_key, dst_key):
        self.copy_calls.append((src_key, dst_key))
        self.existing.add(dst_key)

    async def delete(self, key):
        self.delete_calls.append(key)

    async def exists(self, key):
        self.exists_calls.append(key)
        return key in self.existing


async def _noop_close():
    return None


def _patch(script, backend, db):
    """Wire the fakes into the script's module-level seams."""
    script.get_storage_backend = lambda: backend
    script.close_storage_backend = _noop_close
    script.SupabaseDB = type(
        "SupabaseDBStub", (), {"get_service_client": classmethod(lambda cls: db)}
    )


# --------------------------------------------------------------------------- #
# Finding 2: duplicate destinations are deduped before the gather
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_run_dedups_duplicate_destinations(script, fake_db, tmp_path):
    # Two distinct legacy spellings that reduce to the SAME users/ key.
    top_level = f"tmp/{USER_ID}/batch/{NAME}.png"
    per_user = f"{USER_ID}/tmp/batch/{NAME}.png"
    destination = f"users/{USER_ID}/tmp/batch/{NAME}.png"
    backend = _FakeBackend([top_level, per_user])
    # Neither is DB-referenced -> plain re-key, both target `destination`.
    _patch(script, backend, fake_db)

    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0

    # Only ONE copy lands on the destination (the first source wins); the
    # other is dropped as a duplicate, never copied concurrently.
    dest_copies = [c for c in backend.copy_calls if c[1] == destination]
    assert len(dest_copies) == 1
    assert dest_copies[0][0] == top_level  # first source kept

    # The losing source is NOT copied and NOT deleted (it stays for an
    # operator to inspect); only the winning source is deleted after rewrite.
    assert per_user not in [c[0] for c in backend.copy_calls]
    assert per_user not in backend.delete_calls

    # The duplicate is audit-logged as a skipped-collision.
    audit = [
        json.loads(line)
        for line in (tmp_path / "audit.jsonl").read_text().splitlines()
    ]
    skips = [r for r in audit if r["action"] == "skip"]
    assert any(
        r["old_key"] == per_user and r["new_key"] == destination for r in skips
    )


@pytest.mark.asyncio
async def test_run_dry_run_dedups_without_writes(script, fake_db, tmp_path):
    top_level = f"tmp/{USER_ID}/batch/{NAME}.png"
    per_user = f"{USER_ID}/tmp/batch/{NAME}.png"
    backend = _FakeBackend([top_level, per_user])
    _patch(script, backend, fake_db)

    rc = await script._run(apply=False, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0
    assert backend.copy_calls == []
    assert backend.delete_calls == []
    # Dry-run never writes an audit file.
    assert not (tmp_path / "audit.jsonl").exists()


# --------------------------------------------------------------------------- #
# Finding 3: a target-already-existing pair still gets its DB refs rewritten
# --------------------------------------------------------------------------- #
@pytest.mark.asyncio
async def test_run_resumes_when_target_already_exists(script, fake_db, tmp_path):
    # Simulate a prior interrupted run: the old key still exists, AND the
    # migrated target already exists (the copy succeeded, the rewrite did
    # not). The DB still references the OLD key.
    old_key = f"{USER_ID}/items/{NAME}.png"
    new_key = f"users/{USER_ID}/items/{NAME}.png"
    backend = _FakeBackend([old_key, new_key])  # both present

    fake_db.rows["item_images"] = [
        {"id": "row1", "storage_path": old_key}
    ]
    _patch(script, backend, fake_db)

    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0

    # The pair was NOT re-copied (target exists), but the DB ref was still
    # rewritten to the new key so the row is not stranded.
    assert backend.copy_calls == []
    fake_db.assert_update("item_images", storage_path=new_key)

    # The old key is deleted (the migration is completed, not skipped).
    assert old_key in backend.delete_calls

    # The resume is audit-logged distinctly from a plain copy.
    audit = [
        json.loads(line)
        for line in (tmp_path / "audit.jsonl").read_text().splitlines()
    ]
    assert any(r["action"] == "resume" and r["old_key"] == old_key for r in audit)


@pytest.mark.asyncio
async def test_run_apply_promotes_db_referenced_preview(script, fake_db, tmp_path):
    # End-to-end: a DB-referenced legacy generated key is promoted to items/,
    # the DB column is rewritten to the promoted key, and the old key deleted.
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    backend = _FakeBackend([legacy])
    fake_db.rows["item_images"] = [{"id": "row1", "storage_path": legacy}]
    _patch(script, backend, fake_db)

    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0

    # Exactly one copy, from the legacy key to a users/.../items/ promotion.
    assert len(backend.copy_calls) == 1
    src, dst = backend.copy_calls[0]
    assert src == legacy
    assert dst.startswith(f"users/{USER_ID}/items/")
    assert dst.endswith(".png")

    # DB rewritten to the promoted key, old key deleted.
    fake_db.assert_update("item_images", storage_path=dst)
    assert backend.delete_calls == [legacy]


@pytest.mark.asyncio
async def test_run_dry_run_writes_nothing(script, fake_db, tmp_path):
    legacy = f"{USER_ID}/items/{NAME}.png"
    backend = _FakeBackend([legacy])
    _patch(script, backend, fake_db)

    rc = await script._run(apply=False, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0
    assert backend.copy_calls == []
    assert backend.delete_calls == []
    assert not (tmp_path / "audit.jsonl").exists()
