"""Tests for scripts/backfill_transparent_backgrounds.py.

The backfill overwrites live objects in place, so the properties that matter
are the ones that stop it doing damage or doing pointless work:

  * a rejected or skipped matte writes NOTHING (no upload, no DB patch) -- it
    would otherwise burn a storage write and a CDN invalidation to replace an
    object with byte-identical content;
  * a resumed run does zero re-work, and only genuinely terminal outcomes are
    treated as done, so an `error` row stays retryable;
  * an object key is always recoverable, including for the pre-retrofit rows
    where `storage_path` is NULL and only `image_url` exists.

The script is deliberately importable: everything below is a pure function, so
none of this touches Supabase or the network.
"""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

import pytest

BACKEND_ROOT = Path(__file__).resolve().parents[1]
SCRIPT_PATH = BACKEND_ROOT / "scripts" / "backfill_transparent_backgrounds.py"


def _load_script():
    """Import the script by path.

    It lives in `scripts/`, which is not a package, and it is intended to be run
    as `python scripts/...`. Loading it by spec keeps the test honest about what
    is actually shipped rather than testing a copy.
    """
    if str(BACKEND_ROOT) not in sys.path:
        sys.path.insert(0, str(BACKEND_ROOT))
    spec = importlib.util.spec_from_file_location("backfill_transparent", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


bf = _load_script()

BUCKET = "fitcheck-images"


# --------------------------------------------------------------------------- #
# object key recovery
# --------------------------------------------------------------------------- #
class TestStorageKeyRecovery:
    def test_plain_public_url(self):
        url = f"https://proj.supabase.co/storage/v1/object/public/{BUCKET}/user-1/20260101/item_abc123.jpg"
        assert bf.storage_key_from_public_url(url, BUCKET) == "user-1/20260101/item_abc123.jpg"

    def test_strips_query_string(self):
        """A previous BUST_CACHE=1 run stamps `?v=<epoch>`; the key is unchanged."""
        url = f"https://proj.supabase.co/storage/v1/object/public/{BUCKET}/user-1/x.webp?v=1785000000"
        assert bf.storage_key_from_public_url(url, BUCKET) == "user-1/x.webp"

    def test_strips_fragment(self):
        url = f"https://proj.supabase.co/storage/v1/object/public/{BUCKET}/user-1/x.webp#frag"
        assert bf.storage_key_from_public_url(url, BUCKET) == "user-1/x.webp"

    @pytest.mark.parametrize("url", [None, "", "https://example.com/not-supabase/x.jpg"])
    def test_unrecoverable_urls_return_none(self, url):
        assert bf.storage_key_from_public_url(url, BUCKET) is None

    def test_wrong_bucket_is_not_matched(self):
        url = "https://proj.supabase.co/storage/v1/object/public/other-bucket/user-1/x.jpg"
        assert bf.storage_key_from_public_url(url, BUCKET) is None

    def test_storage_path_wins_when_present(self):
        row = {
            "storage_path": "user-1/20260101/item_abc.jpg",
            "image_url": f"https://p.supabase.co/storage/v1/object/public/{BUCKET}/DIFFERENT/key.jpg",
        }
        assert bf.resolve_storage_key(row, BUCKET) == "user-1/20260101/item_abc.jpg"

    def test_null_storage_path_falls_back_to_url(self):
        """`storage_path` was retrofitted with ADD COLUMN IF NOT EXISTS, so rows
        written before that migration are NULL and must still be processable."""
        row = {
            "storage_path": None,
            "image_url": f"https://p.supabase.co/storage/v1/object/public/{BUCKET}/user-9/old.jpg",
        }
        assert bf.resolve_storage_key(row, BUCKET) == "user-9/old.jpg"

    def test_blank_storage_path_falls_back_to_url(self):
        row = {
            "storage_path": "   ",
            "image_url": f"https://p.supabase.co/storage/v1/object/public/{BUCKET}/user-9/old.jpg",
        }
        assert bf.resolve_storage_key(row, BUCKET) == "user-9/old.jpg"

    def test_neither_available_is_unresolvable(self):
        assert bf.resolve_storage_key({"storage_path": None, "image_url": None}, BUCKET) is None


class TestVersionStamp:
    def test_appends_when_no_query(self):
        assert bf.with_version("https://x/y.webp", 42) == "https://x/y.webp?v=42"

    def test_replaces_existing_stamp_rather_than_stacking(self):
        assert bf.with_version("https://x/y.webp?v=1", 2) == "https://x/y.webp?v=2"

    def test_preserves_other_params(self):
        out = bf.with_version("https://x/y.webp?a=1&v=1&b=2", 9)
        assert out.startswith("https://x/y.webp?")
        assert "a=1" in out and "b=2" in out and out.endswith("v=9")

    def test_none_passes_through(self):
        assert bf.with_version(None, 1) is None


# --------------------------------------------------------------------------- #
# the write decision -- the most important assertion in this file
# --------------------------------------------------------------------------- #
class TestWriteDecision:
    def test_only_a_successful_matte_uploads(self):
        assert bf.should_upload(bf.ACTION_MATTED) is True

    @pytest.mark.parametrize(
        "action",
        [bf.ACTION_SKIPPED, bf.ACTION_REJECTED, bf.ACTION_ERROR, bf.ACTION_UNRESOLVABLE],
    )
    def test_every_other_outcome_writes_nothing(self, action):
        """Re-uploading identical bytes costs a storage write and a CDN purge for
        zero visible change, which is also why G1 is a fast path, not a failure."""
        assert bf.should_upload(action) is False

    @pytest.mark.parametrize(
        "status,expected",
        [
            ("matted", bf.ACTION_MATTED),
            ("skipped_no_background", bf.ACTION_SKIPPED),
            ("rejected_ate_subject", bf.ACTION_REJECTED),
            ("rejected_center_transparent", bf.ACTION_REJECTED),
            ("error", bf.ACTION_ERROR),
            ("something_new", bf.ACTION_ERROR),
        ],
    )
    def test_status_maps_to_action(self, status, expected):
        assert bf.action_for_status(status) == expected


class TestRowUpdate:
    def _result(self, status="matted", w=1024, h=1536):
        from app.utils.background_removal import MatteResult

        return MatteResult(
            image_bytes=b"x",
            content_type="image/webp",
            status=status,
            transparent_fraction=0.7,
            center_opacity=1.0,
            width=w,
            height=h,
        )

    def test_dimensions_written_even_when_matte_was_rejected(self):
        """We decoded the image either way, so the dimensions are correct
        regardless -- and they are NULL for every row ever written, which is a
        live CLS bug on both card grids."""
        row = {"width": None, "height": None}
        update = bf.build_row_update(
            row, self._result(status="rejected_ate_subject"),
            update_dimensions=True, bust_cache=False, version=1,
        )
        assert update == {"width": 1024, "height": 1536}

    def test_no_patch_when_dimensions_already_correct(self):
        row = {"width": 1024, "height": 1536}
        update = bf.build_row_update(
            row, self._result(), update_dimensions=True, bust_cache=False, version=1
        )
        assert update == {}

    def test_dimensions_skipped_when_disabled(self):
        row = {"width": None, "height": None}
        update = bf.build_row_update(
            row, self._result(), update_dimensions=False, bust_cache=False, version=1
        )
        assert update == {}

    def test_bust_cache_only_stamps_a_successful_matte(self):
        row = {"image_url": "https://x/a.webp", "thumbnail_url": "https://x/a.webp"}
        skipped = bf.build_row_update(
            row, self._result(status="skipped_no_background"),
            update_dimensions=False, bust_cache=True, version=7,
        )
        assert skipped == {}

        matted = bf.build_row_update(
            row, self._result(), update_dimensions=False, bust_cache=True, version=7
        )
        assert matted["image_url"] == "https://x/a.webp?v=7"
        assert matted["thumbnail_url"] == "https://x/a.webp?v=7"

    def test_bust_cache_off_by_default_leaves_urls_untouched(self):
        """The approved decision is overwrite-in-place with NO URL churn."""
        row = {"image_url": "https://x/a.webp", "thumbnail_url": "https://x/a.webp"}
        update = bf.build_row_update(
            row, self._result(), update_dimensions=False, bust_cache=False, version=7
        )
        assert "image_url" not in update and "thumbnail_url" not in update


class TestUploadArgs:
    def test_returns_content_type_and_cache_control(self):
        """The S3 overwrite takes (content_type, cache_control); S3 put_object
        overwrites an existing key by default (no `upsert` flag needed)."""
        content_type, cache_control = bf.upload_args("image/webp", 60)
        assert content_type == "image/webp"
        assert cache_control == "60"


class _FakeStorage:
    """Async stand-in for S3StorageBackend (process_row uses asyncio.run)."""

    def __init__(self, original=b"source", download_error=None, upload_error=None):
        self.original = original
        self.download_error = download_error
        self.upload_error = upload_error
        self.uploads = []

    async def download(self, key):
        if self.download_error:
            raise self.download_error
        return self.original

    async def upload(self, *, key, data, content_type, cache_control):
        if self.upload_error:
            raise self.upload_error
        self.uploads.append(
            {"key": key, "data": data, "content_type": content_type, "cache_control": cache_control}
        )


class _FakeDb:
    def __init__(self):
        self.updated = []
        self.update_error = None

    def table(self, table):
        return self

    def update(self, payload):
        self.updated.append(payload)
        if self.update_error:
            raise self.update_error
        return self

    def eq(self, *args):
        return self

    def execute(self):
        return None


def _cfg():
    return bf.Config(
        bucket=BUCKET,
        dry_run=False,
        cache_control=60,
        bust_cache=False,
        update_dimensions=True,
        throttle_ms=0,
        version=1,
    )


def _matte_result(status, width=100, height=80):
    from app.utils.background_removal import MatteResult

    return MatteResult(
        image_bytes=b"matted",
        content_type="image/webp",
        status=status,
        transparent_fraction=0.7,
        center_opacity=1.0,
        width=width,
        height=height,
    )


class TestProcessRowFailures:
    def _row(self):
        return {"id": "row-1", "storage_path": "user-1/item.jpg", "width": None, "height": None}

    def test_download_failure_is_retryable_and_not_decoded(self, monkeypatch):
        storage = _FakeStorage(download_error=RuntimeError("offline"))
        db = _FakeDb()
        monkeypatch.setattr(bf, "get_storage_backend", lambda: storage)

        record = bf.process_row(db, bf.TABLE_SPECS["item_images"], self._row(), _cfg())

        assert record["action"] == bf.ACTION_ERROR
        assert record["decoded"] is False
        assert not storage.uploads
        assert not db.updated

    def test_rejection_skips_upload_but_updates_original_dimensions(self, monkeypatch):
        storage = _FakeStorage()
        db = _FakeDb()
        monkeypatch.setattr(bf, "get_storage_backend", lambda: storage)
        monkeypatch.setattr(bf, "remove_white_background", lambda *_: _matte_result(
            bf.STATUS_REJECTED_ATE_SUBJECT, width=100, height=80
        ))

        record = bf.process_row(db, bf.TABLE_SPECS["item_images"], self._row(), _cfg())

        assert record["action"] == bf.ACTION_REJECTED
        assert record["decoded"] is True
        assert not storage.uploads
        assert db.updated == [{"width": 100, "height": 80}]

    def test_upload_failure_is_retryable(self, monkeypatch):
        storage = _FakeStorage(upload_error=RuntimeError("storage down"))
        db = _FakeDb()
        monkeypatch.setattr(bf, "get_storage_backend", lambda: storage)
        monkeypatch.setattr(bf, "remove_white_background", lambda *_: _matte_result(bf.STATUS_MATTED))

        record = bf.process_row(db, bf.TABLE_SPECS["item_images"], self._row(), _cfg())

        assert record["action"] == bf.ACTION_ERROR
        assert record["decoded"] is True
        assert not db.updated

    def test_decode_failure_is_not_counted_as_decoded(self, monkeypatch):
        storage = _FakeStorage()
        db = _FakeDb()
        monkeypatch.setattr(bf, "get_storage_backend", lambda: storage)
        monkeypatch.setattr(bf, "remove_white_background", lambda *_: _matte_result(bf.STATUS_ERROR))

        record = bf.process_row(db, bf.TABLE_SPECS["item_images"], self._row(), _cfg())

        assert record["action"] == bf.ACTION_ERROR
        assert record["decoded"] is False

    def test_database_update_failure_is_retryable_after_upload(self, monkeypatch):
        storage = _FakeStorage()
        db = _FakeDb()
        db.update_error = RuntimeError("database down")
        monkeypatch.setattr(bf, "get_storage_backend", lambda: storage)
        monkeypatch.setattr(bf, "remove_white_background", lambda *_: _matte_result(bf.STATUS_MATTED))

        record = bf.process_row(db, bf.TABLE_SPECS["item_images"], self._row(), _cfg())

        assert record["action"] == bf.ACTION_ERROR
        assert record["decoded"] is True
        assert len(storage.uploads) == 1


# --------------------------------------------------------------------------- #
# audit / resume
# --------------------------------------------------------------------------- #
class TestAudit:
    def _write(self, path: Path, rows):
        for row in rows:
            bf.append_audit(path, row)

    def test_round_trip(self, tmp_path):
        path = tmp_path / "audit.jsonl"
        rec = bf.make_record(
            table="item_images", row_id="r1", storage_path="u/1.jpg",
            action=bf.ACTION_MATTED, status="matted", bytes_before=100, bytes_after=50,
        )
        bf.append_audit(path, rec)
        lines = [json.loads(line) for line in path.read_text().splitlines() if line.strip()]
        assert len(lines) == 1
        assert lines[0]["row_id"] == "r1"
        assert lines[0]["action"] == "matted"

    def test_terminal_actions_are_skipped_on_resume(self, tmp_path):
        path = tmp_path / "audit.jsonl"
        self._write(path, [
            {"row_id": "matted-1", "action": bf.ACTION_MATTED},
            {"row_id": "skipped-1", "action": bf.ACTION_SKIPPED},
            {"row_id": "rejected-1", "action": bf.ACTION_REJECTED},
            {"row_id": "unresolvable-1", "action": bf.ACTION_UNRESOLVABLE},
        ])
        assert bf.load_audit(path) == {"matted-1", "skipped-1", "rejected-1", "unresolvable-1"}

    def test_error_rows_stay_retryable(self, tmp_path):
        path = tmp_path / "audit.jsonl"
        self._write(path, [{"row_id": "boom", "action": bf.ACTION_ERROR}])
        assert bf.load_audit(path) == set()

    def test_last_action_wins(self, tmp_path):
        """A row that errored and was later matted must not stay retryable, and a
        row matted earlier must not be resurrected by a later unrelated error."""
        path = tmp_path / "audit.jsonl"
        self._write(path, [
            {"row_id": "a", "action": bf.ACTION_ERROR},
            {"row_id": "a", "action": bf.ACTION_MATTED},
            {"row_id": "b", "action": bf.ACTION_MATTED},
            {"row_id": "b", "action": bf.ACTION_ERROR},
        ])
        done = bf.load_audit(path)
        assert "a" in done
        assert "b" not in done

    def test_missing_file_is_an_empty_set(self, tmp_path):
        assert bf.load_audit(tmp_path / "nope.jsonl") == set()

    def test_corrupt_line_does_not_abort_the_resume(self, tmp_path):
        path = tmp_path / "audit.jsonl"
        path.write_text('{"row_id":"ok","action":"matted"}\nNOT JSON\n\n')
        assert bf.load_audit(path) == {"ok"}


# --------------------------------------------------------------------------- #
# summary + operator warning
# --------------------------------------------------------------------------- #
class TestSummary:
    def _rec(self, action, status="", before=0, after=0):
        return {"action": action, "status": status, "bytes_before": before, "bytes_after": after}

    def test_counts_and_byte_delta(self):
        summary = bf.summarize([
            self._rec(bf.ACTION_MATTED, "matted", 100, 50),
            self._rec(bf.ACTION_MATTED, "matted", 200, 80),
            self._rec(bf.ACTION_SKIPPED, "skipped_no_background"),
        ])
        assert summary["total"] == 3
        assert summary["actions"][bf.ACTION_MATTED] == 2
        assert summary["bytes_before"] == 300
        assert summary["bytes_after"] == 130
        # WebP with alpha is smaller than the JPEG it replaces, so the bucket
        # should SHRINK. A positive delta here would mean the format regressed.
        assert summary["bytes_delta"] == -170

    def test_reject_ratio_excludes_unresolvable_rows(self):
        """We never got bytes for an unresolvable row, so counting it would
        dilute the very signal the 10% threshold exists to catch."""
        summary = bf.summarize([
            self._rec(bf.ACTION_REJECTED, "rejected_ate_subject"),
            self._rec(bf.ACTION_MATTED, "matted"),
            self._rec(bf.ACTION_UNRESOLVABLE, ""),
        ])
        assert summary["decoded"] == 2
        assert summary["reject_ratio"] == pytest.approx(0.5)

    def test_empty_run_does_not_divide_by_zero(self):
        assert bf.summarize([])["reject_ratio"] == 0.0

    def test_high_reject_ratio_warns_the_operator(self):
        summary = bf.summarize(
            [self._rec(bf.ACTION_REJECTED, "rejected_ate_subject")] * 3
            + [self._rec(bf.ACTION_MATTED, "matted")] * 7
        )
        assert summary["reject_ratio"] > bf.REJECT_WARN_RATIO
        rendered = bf.render_summary(summary)
        assert "WHITE_MIN_CHANNEL" in rendered, "the warning must name the knob to retune"

    def test_low_reject_ratio_is_quiet(self):
        summary = bf.summarize(
            [self._rec(bf.ACTION_REJECTED, "rejected_ate_subject")]
            + [self._rec(bf.ACTION_MATTED, "matted")] * 99
        )
        assert summary["reject_ratio"] < bf.REJECT_WARN_RATIO
        assert "WHITE_MIN_CHANNEL" not in bf.render_summary(summary)


class TestTableScope:
    def test_only_the_two_intended_tables_are_targetable(self):
        """`social_import_items` are temp review-queue objects, `source_image_*`
        are original photos with real backgrounds, and `outfit_generations`
        holds denormalised copies. None of them should be reachable."""
        assert set(bf.TABLE_SPECS) == {"item_images", "outfit_images"}

    def test_outfit_images_is_restricted_to_ai_generations(self):
        spec = bf.TABLE_SPECS["outfit_images"]
        assert spec.row_filter == {"generation_type": "ai"}, (
            "outfit_images must not sweep user-uploaded looks"
        )

    def test_item_images_is_unfiltered(self):
        assert bf.TABLE_SPECS["item_images"].row_filter == {}

    def test_source_photos_are_never_a_target(self):
        """The original photo has a real background; matting it is destructive."""
        joined = " ".join(bf.TABLE_SPECS)
        assert "source_image" not in joined
        assert "social_import" not in joined
