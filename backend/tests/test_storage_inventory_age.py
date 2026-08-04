"""Tests for the age-based protection logic in scripts/storage_inventory.py.

Temp/generated images (``{user_id}/tmp/{source}/...``) are served only via
short-lived presigned URLs (1h TTL) and are NEVER referenced by any DB row, so
the orphan math flags every one of them as an orphan — including one a user is
actively previewing. The grace window (``split_by_age``) is what stops the
cleanup from deleting an in-flight preview, so the properties that matter are:

  * only orphans older than the grace window are ``deletable``;
  * an orphan whose mtime is unknown is ALWAYS protected (safe default for a
    one-time cleanup — never delete what we cannot age-verify);
  * the boundary is inclusive at exactly the cutoff;
  * ``age_hours`` round-trips and tolerates a missing mtime.

The script is imported by path (it lives in ``scripts/``, not a package) the
same way ``test_backfill_transparent`` loads its script. The helpers under test
are pure and touch neither the bucket nor the network.
"""

from __future__ import annotations

import importlib.util
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest

BACKEND_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "storage_inventory.py"


@pytest.fixture(scope="module")
def script():
    """Load storage_inventory.py by path and return the module object."""
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("storage_inventory", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


NOW = datetime(2026, 8, 4, 12, 0, 0, tzinfo=timezone.utc)


def test_old_orphan_is_deletable(script):
    # 5h old >> 2h window -> deletable
    mtimes = {"u1/tmp/photoshoot/abc.png": NOW - timedelta(hours=5)}
    deletable, protected = script.split_by_age(
        ["u1/tmp/photoshoot/abc.png"], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == ["u1/tmp/photoshoot/abc.png"]
    assert protected == []


def test_recent_preview_is_protected(script):
    # 30 min old, still inside the 1h presign window -> must be protected
    mtimes = {"u1/tmp/social-import/abc.webp": NOW - timedelta(minutes=30)}
    deletable, protected = script.split_by_age(
        ["u1/tmp/social-import/abc.webp"], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == []
    assert protected == ["u1/tmp/social-import/abc.webp"]


def test_unknown_mtime_is_protected(script):
    # An orphan with no captured LastModified is never deleted (safe default).
    deletable, protected = script.split_by_age(
        ["u1/tmp/whatever/abc.png"], mtimes={}, min_age_hours=2, now=NOW
    )
    assert deletable == []
    assert protected == ["u1/tmp/whatever/abc.png"]


def test_cutoff_is_inclusive(script):
    # Exactly at the 2h boundary -> deletable (age >= window).
    key = "u1/generated/edge.png"
    mtimes = {key: NOW - timedelta(hours=2)}
    deletable, protected = script.split_by_age(
        [key], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == [key]
    assert protected == []


def test_just_under_cutoff_is_protected(script):
    # 1 second short of the 2h boundary (1h59m59s ago) -> protected.
    key = "u1/generated/edge.png"
    mtimes = {key: NOW - timedelta(hours=1, minutes=59, seconds=59)}
    deletable, protected = script.split_by_age(
        [key], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == []
    assert protected == [key]


def test_mixed_set_splits_correctly(script):
    mtimes = {
        "old": NOW - timedelta(hours=10),
        "fresh": NOW - timedelta(minutes=5),
        "edge": NOW - timedelta(hours=2),
    }
    keys = ["old", "fresh", "edge", "unknown"]
    deletable, protected = script.split_by_age(
        keys, mtimes, min_age_hours=2, now=NOW
    )
    assert set(deletable) == {"old", "edge"}
    assert set(protected) == {"fresh", "unknown"}


def test_age_hours_round_trips(script):
    mtime = NOW - timedelta(hours=3, minutes=15)
    assert script.age_hours(mtime, NOW) == round(3.25, 2)


def test_age_hours_none_for_missing_mtime(script):
    assert script.age_hours(None, NOW) is None


def test_naive_datetimes_are_treated_as_utc(script):
    # A naive mtime / now should not raise (defensive normalization).
    naive_now = datetime(2026, 8, 4, 12, 0, 0)
    mtimes = {"k": datetime(2026, 8, 4, 9, 0, 0)}  # 3h before
    deletable, protected = script.split_by_age(
        ["k"], mtimes, min_age_hours=2, now=naive_now
    )
    assert deletable == ["k"]
    assert protected == []


def test_default_min_age_hours_exceeds_presign_ttl(script):
    # Contract: the grace window must exceed the 1h presign TTL so an in-flight
    # preview (up to 1h old) is never deletable by default.
    assert script.DEFAULT_MIN_AGE_HOURS > 1
