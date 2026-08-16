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
import hashlib
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


def test_promotion_target_is_deterministic_across_runs(script):
    # The promotion target must be recomputed identically on a rerun, or an
    # interrupted run (copy done, DB rewrite not) strands the first copy as an
    # orphan when the second run computes a fresh UUID. The fixture uses a
    # 32-hex source name, so it exercises the canonical-shaped REUSE branch
    # (name carried over as-is). The hashed-name branch of _promotion_target
    # is unreachable through parse_key today — every preview regex requires a
    # 32-hex name — so only the reuse branch is pinned here.
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    db_paths = {legacy}
    first = script._promotion_target(legacy, db_paths)
    second = script._promotion_target(legacy, db_paths)
    assert first is not None
    assert first == second
    # The canonical-shaped source name is reused, so the target is STABLE
    # (and its 32-hex name parses as a canonical items key).
    assert first == f"users/{USER_ID}/items/{NAME}.png"
    assert script.parse_key(first) is not None


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

    ``metadata`` (``{key: {"size": int, "etag": str}}``) backs the new
    ``head()`` provenance check: a key the test does not pin gets a stable
    hash-derived identity, so two DIFFERENT keys never accidentally match.
    ``copy()`` clones the source's metadata onto the destination, so a test
    simulating a completed prior copy just seeds the target in ``keys`` with
    the source's metadata.
    """

    def __init__(self, keys, metadata=None):
        self.keys = list(keys)
        self.existing = set(keys)
        self.metadata = {}
        for key in keys:
            info = _default_head(key)
            if metadata and key in metadata:
                info.update(metadata[key])
            self.metadata[key] = info
        self.copy_calls = []
        self.delete_calls = []
        self.exists_calls = []
        self.head_calls = []
        self.bucket = "test-bucket"
        self.endpoint_url = "https://s3.example.com"
        self._client = _FakeClient(self.keys)

    async def _get_client(self):
        return self._client

    async def copy(self, src_key, dst_key):
        self.copy_calls.append((src_key, dst_key))
        self.existing.add(dst_key)
        self.metadata[dst_key] = dict(self.metadata[src_key])

    async def delete(self, key):
        self.delete_calls.append(key)

    async def exists(self, key):
        self.exists_calls.append(key)
        return key in self.existing

    async def head(self, key):
        self.head_calls.append(key)
        if key not in self.existing:
            return None
        return dict(self.metadata[key])


def _default_head(key: str) -> dict:
    """Stable per-key identity so unrelated keys never accidentally match."""
    digest = hashlib.sha256(key.encode()).hexdigest()
    return {"size": int(digest[:8], 16), "etag": digest[:16]}


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
    # not). The DB still references the OLD key. The target carries the
    # SOURCE's metadata so the provenance check (size+etag match) accepts it
    # as a prior copy of this source rather than a collision.
    old_key = f"{USER_ID}/items/{NAME}.png"
    new_key = f"users/{USER_ID}/items/{NAME}.png"
    metadata = {new_key: _default_head(old_key)}  # prior copy => same identity
    backend = _FakeBackend([old_key, new_key], metadata=metadata)  # both present

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
async def test_run_unrelated_target_object_is_not_touched(script, fake_db, tmp_path):
    # Finding 1 regression: an unrelated pre-existing users/ object at the
    # target key must NOT be treated as a prior copy. Source and target have
    # different size+etag, so the pair is left untouched: no DB retarget to
    # the unrelated bytes, no delete of the source.
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    target = f"users/{USER_ID}/items/{NAME}.png"
    # The target exists with its OWN identity (different from the source) —
    # an unrelated object that happens to share the promotion key.
    backend = _FakeBackend([legacy, target])
    fake_db.rows["item_images"] = [{"id": "row1", "storage_path": legacy}]
    _patch(script, backend, fake_db)

    rc = await script._run(apply=True, audit_path=tmp_path / "audit.jsonl")
    assert rc == 0

    # Nothing was copied, deleted, or DB-retargeted: the collision is left
    # alone and the source preserved.
    assert backend.copy_calls == []
    assert backend.delete_calls == []
    assert fake_db.updates == []

    # Audit-logged as a collision, source preserved.
    audit = [
        json.loads(line)
        for line in (tmp_path / "audit.jsonl").read_text().splitlines()
    ]
    assert any(
        r["action"] == "skip"
        and r["old_key"] == legacy
        and "collision" in (r["error"] or "")
        for r in audit
    )


@pytest.mark.asyncio
async def test_run_promotion_target_is_stable_across_reruns(script, fake_db, tmp_path):
    # Finding 2 regression: a rerun of a promoted preview must target the SAME
    # key, or a run interrupted between copy and DB rewrite strands the first
    # copy as an unreferenced orphan when the rerun computes a fresh UUID.
    legacy = f"{USER_ID}/generated/product/{NAME}.png"
    fake_db.rows["item_images"] = [{"id": "row1", "storage_path": legacy}]

    backend1 = _FakeBackend([legacy])
    _patch(script, backend1, fake_db)
    rc = await script._run(apply=True, audit_path=tmp_path / "audit1.jsonl")
    assert rc == 0
    assert len(backend1.copy_calls) == 1
    first_target = backend1.copy_calls[0][1]
    assert first_target == f"users/{USER_ID}/items/{NAME}.png"

    # Simulate the state a rerun sees: the copy materialized (target carries
    # the source's identity), but the DB rewrite never happened, so the row
    # still references the legacy key.
    backend2 = _FakeBackend(
        [legacy, first_target], metadata={first_target: _default_head(legacy)}
    )
    fake_db.rows["item_images"] = [{"id": "row1", "storage_path": legacy}]
    _patch(script, backend2, fake_db)
    rc = await script._run(apply=True, audit_path=tmp_path / "audit2.jsonl")
    assert rc == 0

    # The rerun recomputes the SAME target key (no fresh UUID, no orphan) and
    # finishes the rewrite instead of copying to a new name.
    assert backend2.copy_calls == []
    fake_db.assert_update("item_images", storage_path=first_target)
    assert legacy in backend2.delete_calls


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
