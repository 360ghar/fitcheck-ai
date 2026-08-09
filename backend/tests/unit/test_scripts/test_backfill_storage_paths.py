"""Tests for scripts/backfill_storage_paths.py (legacy NULL storage_path repair).

The script is imported by path (it lives in scripts/, not a package), the same
way test_temp_cleanup_script.py loads its script. The pure key-derivation
helper is tested directly; ``run_backfill`` is exercised against the shared
in-memory FakeDB with no network, asserting both dry-run (no writes) and
apply (correct payloads + audit log) behavior.
"""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import app

import pytest

BACKEND_ROOT = Path(app.__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "backfill_storage_paths.py"

USER_ID = "11111111-1111-1111-1111-111111111111"
NAME = "0123456789abcdef0123456789abcdef"
ITEM_KEY = f"{USER_ID}/items/{NAME}.webp"
OUTFIT_KEY = f"{USER_ID}/outfits/{NAME}.png"
SOURCE_KEY = f"{USER_ID}/sources/{NAME}.jpg"


@pytest.fixture(scope="module")
def script():
    """Load backfill_storage_paths.py by path and return the module object."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("backfill_storage_paths", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


# --------------------------------------------------------------------------- #
# derive_storage_path (pure)
# --------------------------------------------------------------------------- #
def test_derive_accepts_bare_key(script):
    assert script.derive_storage_path(ITEM_KEY) == ITEM_KEY


def test_derive_accepts_supabase_public_url(script):
    url = f"https://xyz.supabase.co/storage/v1/object/public/fitcheck-images/{ITEM_KEY}"
    assert script.derive_storage_path(url) == ITEM_KEY


def test_derive_accepts_presigned_r2_url(script):
    # Path-style presigned URL with an arbitrary bucket-name first segment.
    url = f"https://acct.r2.cloudflarestorage.com/whatever-bucket/{ITEM_KEY}?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=deadbeef"
    assert script.derive_storage_path(url) == ITEM_KEY


def test_derive_accepts_legacy_url_with_old_bucket_prefix(script):
    # A URL from a provider cutover whose bucket name is not the configured one
    # still reduces to the key (key_from_path's non-UUID-first-segment rule).
    url = f"https://old.storageapi.dev/old-bucket/{ITEM_KEY}"
    assert script.derive_storage_path(url) == ITEM_KEY


def test_derive_rejects_external_junk(script):
    # The pre-existing junk avatar (https://example.com/a.jpg) has no key; it
    # must report unrepairable, never be rewritten into one of our keys.
    assert script.derive_storage_path("https://example.com/a.jpg") is None
    assert script.derive_storage_path("https://lh3.googleusercontent.com/picture?x=1") is None
    assert script.derive_storage_path("") is None
    assert script.derive_storage_path(None) is None


def test_derive_rejects_preview_keys(script):
    # tmp/generated previews are never DB-referenced; a URL reducing to one of
    # those layouts is not a canonical image row and must not be written.
    assert (
        script.derive_storage_path(f"tmp/{USER_ID}/social-import/{NAME}.png") is None
    )
    assert (
        script.derive_storage_path(f"generated/{USER_ID}/try-on/{NAME}.png") is None
    )


# --------------------------------------------------------------------------- #
# collect_candidates
# --------------------------------------------------------------------------- #
def test_collect_candidates_skips_keyed_rows_and_empty_keys(script, fake_db):
    fake_db.rows["item_images"] = [
        {"id": "r1", "storage_path": ITEM_KEY, "image_url": "https://fresh/x"},
        # NULL storage_path -> candidate, prefers image_url over thumbnail_url.
        {
            "id": "r2",
            "storage_path": None,
            "image_url": f"https://cdn/storage/v1/object/public/b/{ITEM_KEY}",
            "thumbnail_url": "https://cdn/stale/thumb",
        },
        # Empty-string key -> treated as missing.
        {"id": "r3", "storage_path": "", "image_url": f"https://cdn/b/{ITEM_KEY}"},
        # NULL storage_path, no usable URL -> candidate with url None.
        {"id": "r4", "storage_path": None, "image_url": None, "thumbnail_url": ""},
    ]
    candidates = script.collect_candidates(
        fake_db, "item_images", "storage_path", ("image_url", "thumbnail_url")
    )
    assert [c["id"] for c in candidates] == ["r2", "r3", "r4"]
    assert candidates[0]["url"] == f"https://cdn/storage/v1/object/public/b/{ITEM_KEY}"
    assert candidates[2]["url"] is None


def test_collect_candidates_paginates_past_postgrest_row_cap(script, fake_db, monkeypatch):
    """PostgREST caps a single SELECT at 1000 rows; a bare select would stop
    scanning past the cap and silently miss candidates. The scanner pages in
    id order, so every row is examined. Page size is monkeypatched small so
    the test crosses several pages."""
    monkeypatch.setattr(script, "_PAGE_SIZE", 7)
    fake_db.rows["item_images"] = [
        (
            {"id": f"r{i:02d}", "storage_path": None, "image_url": f"https://cdn/b/{ITEM_KEY}"}
            if i % 5 == 0
            else {"id": f"r{i:02d}", "storage_path": ITEM_KEY, "image_url": "https://fresh/x"}
        )
        for i in range(23)
    ]
    candidates = script.collect_candidates(
        fake_db, "item_images", "storage_path", ("image_url", "thumbnail_url")
    )
    assert [c["id"] for c in candidates] == ["r00", "r05", "r10", "r15", "r20"]


# --------------------------------------------------------------------------- #
# run_backfill
# --------------------------------------------------------------------------- #
def _db_with_mixed_rows(fake_db):
    fake_db.rows["item_images"] = [
        {
            "id": "i1",
            "storage_path": None,
            "image_url": f"https://xyz.supabase.co/storage/v1/object/public/fitcheck-images/{ITEM_KEY}",
            "thumbnail_url": None,
        },
        {
            "id": "i2",
            "storage_path": None,
            "image_url": "https://example.com/a.jpg",
            "thumbnail_url": None,
        },
        {"id": "i3", "storage_path": ITEM_KEY, "image_url": "https://fresh/x"},
    ]
    fake_db.rows["outfit_images"] = [
        {
            "id": "o1",
            "storage_path": None,
            "image_url": f"https://acct.r2.cloudflarestorage.com/bucket/{OUTFIT_KEY}?X-Amz-Signature=abc",
            "thumbnail_url": None,
        }
    ]
    fake_db.rows["items"] = [
        {
            "id": "s1",
            "source_image_storage_path": None,
            "source_image_url": SOURCE_KEY,
        }
    ]
    return fake_db


def test_run_backfill_dry_run_writes_nothing(script, fake_db):
    db = _db_with_mixed_rows(fake_db)
    report = script.run_backfill(db, apply=False)

    assert db.updates == []
    assert report["repaired_total"] == 3  # i1, o1, s1
    assert report["unrepairable_total"] == 1  # i2 (example.com junk)
    assert report["tables"]["item_images"]["candidates"] == 2
    assert report["tables"]["outfit_images"]["candidates"] == 1
    assert report["tables"]["items"]["candidates"] == 1


def test_run_backfill_apply_writes_keys_and_audit(script, fake_db, tmp_path):
    db = _db_with_mixed_rows(fake_db)
    audit = tmp_path / "audit.jsonl"
    report = script.run_backfill(db, apply=True, audit_path=audit)

    assert report["repaired_total"] == 3
    updates = {t: p for t, p in db.updates}
    assert updates == {
        "item_images": {"storage_path": ITEM_KEY},
        "outfit_images": {"storage_path": OUTFIT_KEY},
        "items": {"source_image_storage_path": SOURCE_KEY},
    }
    # The junk row was never updated.
    assert db.rows["item_images"][1]["storage_path"] is None

    lines = [json.loads(line) for line in audit.read_text().splitlines()]
    assert len(lines) == 3
    assert {line["table"] for line in lines} == {"item_images", "outfit_images", "items"}
    assert all(line["action"] == "backfill_storage_path" for line in lines)
    assert lines[0]["storage_path"] == ITEM_KEY


def test_run_backfill_apply_without_audit_path_still_writes(script, fake_db):
    db = _db_with_mixed_rows(fake_db)
    report = script.run_backfill(db, apply=True, audit_path=None)
    assert report["repaired_total"] == 3
    assert len(db.updates) == 3
