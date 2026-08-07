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
    # A tmp/ key, deliberately: `generated/` carries its own much longer window
    # (see test_generated_orphans_get_a_long_retention_window) and would be
    # protected here for an unrelated reason.
    key = "u1/tmp/photoshoot/edge.png"
    mtimes = {key: NOW - timedelta(hours=2)}
    deletable, protected = script.split_by_age(
        [key], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == [key]
    assert protected == []


def test_just_under_cutoff_is_protected(script):
    # 1 second short of the 2h boundary (1h59m59s ago) -> protected.
    key = "u1/tmp/photoshoot/edge.png"
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


# --------------------------------------------------------------------------- #
# parent_of_thumb (thumbnail siblings are never orphans)
# --------------------------------------------------------------------------- #
def test_parent_stem_of_thumb_derives_the_extensionless_parent(script):
    # Thumbs are always .webp regardless of the parent's format, so only the
    # STEM is recoverable — matching on a full key would miss `abc.jpg`.
    assert script.parent_stem_of_thumb("u/items/abc_thumb.webp") == "u/items/abc"
    assert script.parent_stem_of_thumb("u/outfits/abc_thumb.webp") == "u/outfits/abc"


def test_parent_stem_of_thumb_returns_none_for_non_thumbs(script):
    assert script.parent_stem_of_thumb("u/items/abc.jpg") is None
    # Syntactically a tmp key CAN map (the function is purely lexical); the
    # orphan filter then drops it because tmp parents are never DB-referenced,
    # so a tmp thumb would still be treated as an orphan and deleted.
    assert script.parent_stem_of_thumb("u/tmp/x/y_thumb.webp") == "u/tmp/x/y"
    assert script.parent_stem_of_thumb("") is None
    # A name with "_thumb" but no extension is not a thumb key.
    assert script.parent_stem_of_thumb("u/items/abc_thumb") is None


def test_key_stem_strips_the_extension(script):
    assert script.key_stem("u/items/abc.jpg") == "u/items/abc"
    assert script.key_stem("u/items/abc.webp") == "u/items/abc"
    # No extension at all: unchanged.
    assert script.key_stem("u/items/abc") == "u/items/abc"


def test_thumb_matches_its_parent_across_a_format_change(script):
    """The property the orphan filter depends on: a .webp thumb resolves to a
    .jpg / .png / .webp parent alike."""
    for parent in ("u/items/abc.jpg", "u/items/abc.png", "u/items/abc.webp"):
        assert script.parent_stem_of_thumb("u/items/abc_thumb.webp") == script.key_stem(
            parent
        )


# --------------------------------------------------------------------------- #
# per-category retention (generated/ is user-saved, not transient)
# --------------------------------------------------------------------------- #
# `{user}/generated/{image_type}/...` is a try-on or outfit render the user asked
# to KEEP (save_to_storage=true). It is not DB-referenced, so the orphan math
# flags every one — and under the uniform 2h window the cleanup script deleted
# saved renders two hours after they were made.
def test_generated_orphans_get_a_long_retention_window(script):
    key = "u1/generated/try-on/abc.png"
    # 5h old: past the 2h transient window, nowhere near the generated window.
    mtimes = {key: NOW - timedelta(hours=5)}
    deletable, protected = script.split_by_age(
        [key], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == []
    assert protected == [key]


def test_generated_orphans_are_deletable_past_their_own_window(script):
    key = "u1/generated/outfit/abc.png"
    window = script.CATEGORY_MIN_AGE_HOURS["generated"]
    mtimes = {key: NOW - timedelta(hours=window + 1)}
    deletable, protected = script.split_by_age(
        [key], mtimes, min_age_hours=2, now=NOW
    )
    assert deletable == [key]
    assert protected == []


def test_generated_window_far_exceeds_the_transient_window(script):
    """Contract: the generated window is a RETENTION decision, so it must be
    orders of magnitude longer than the in-flight-preview window."""
    assert script.CATEGORY_MIN_AGE_HOURS["generated"] >= 24 * 7


def test_per_category_window_does_not_leak_to_other_categories(script):
    """tmp/ and item orphans keep the caller's --min-age-hours."""
    keys = ["u1/tmp/social-import/a.webp", "u1/items/b.webp"]
    mtimes = {k: NOW - timedelta(hours=5) for k in keys}
    deletable, protected = script.split_by_age(keys, mtimes, min_age_hours=2, now=NOW)
    assert sorted(deletable) == sorted(keys)
    assert protected == []


# --------------------------------------------------------------------------- #
# classify_category understands both preview layouts
# --------------------------------------------------------------------------- #
def test_classify_category_top_level_preview_folders(script):
    # Top-level tmp/ and generated/ folders -> category is the FIRST segment.
    assert script.classify_category("tmp/u1/photoshoot/abc.png") == "tmp"
    assert script.classify_category("tmp/u1/batch/abc.webp") == "tmp"
    assert script.classify_category("generated/u1/try-on/abc.png") == "generated"


def test_classify_category_legacy_preview_and_canonical_unchanged(script):
    # Legacy per-user preview keys still classify via the second segment.
    assert script.classify_category("u1/tmp/photoshoot/abc.png") == "tmp"
    assert script.classify_category("u1/generated/try-on/abc.png") == "generated"
    # Canonical categories and the oldest filename-prefix layout are untouched.
    assert script.classify_category("u1/items/abc.png") == "items"
    assert script.classify_category("u1/outfits/abc.png") == "outfits"
    assert script.classify_category("u1/20260101/item_abc123.png") == "items"
    assert script.classify_category("u1/other/x.png") == "legacy-other"
