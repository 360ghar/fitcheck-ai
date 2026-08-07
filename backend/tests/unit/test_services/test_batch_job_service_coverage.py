"""Coverage-completing tests for BatchJobService.

The sibling lifecycle/durable/cleanup tests cover the core create/update/
hydrate flows. These tests fill the remaining branches: persisted payload
building with items, legacy per-image status parsing, hydrate edge shapes,
the post-build concurrency cap re-check, persistence failure compensation,
release helpers on missing jobs, cancel-job guards and CAS-loss paths,
durable-cancel adoption, status guards, ghost-image item adds, extraction
failure markers, cached-item restore, generation error updates, set_error
CAS loss, dropped-subscriber cleanup, subscriber replay overflow, cleanup
loop error handling, and finished-job eviction.
"""

import asyncio
from datetime import datetime, timedelta, timezone
from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.core.exceptions import AIServiceError, RateLimitError
from app.services import batch_job_service as bjs
from app.services.batch_job_service import (
    BatchJob,
    BatchJobService,
    BatchJobStatus,
    _parse_image_extraction_status,
)


@pytest.fixture(autouse=True)
def _clear_job_store():
    BatchJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()


def _db_with_rows(row, *, update_data=None):
    db = Mock()
    result = Mock(data=row)
    chain = (
        db.table.return_value.select.return_value.eq.return_value.eq.return_value
        .maybe_single.return_value
    )
    chain.execute.return_value = result
    db.table.return_value.upsert.return_value.execute.return_value = Mock(data=[row])
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.eq.return_value.execute.return_value = Mock(
        data=[row] if update_data is None else update_data
    )
    return db


async def _make_job(user_id: str = "u1", image_id: str = "img-1") -> BatchJob:
    return await BatchJobService.create_job(
        user_id, [{"image_id": image_id, "image_base64": "c291cmNl"}]
    )


# ---------------------------------------------------------------------------
# Persisted payload / parsing / counters
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_persisted_payload_builds_item_rows_without_base64():
    db = _db_with_rows(None)
    job = await BatchJobService.create_job(
        "u1", [{"image_id": "img-1", "image_base64": "x"}], db=db
    )
    await BatchJobService.add_detected_items(
        job.job_id,
        "img-1",
        [{"temp_id": "t1", "category": "tops"}],
    )
    await BatchJobService.update_item_generation(
        job.job_id, "t1", generated_image_url="https://cdn/x.png"
    )
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    payload = db.table.return_value.update.call_args.args[0]
    assert payload["status"] == "completed"
    assert payload["items"] == [
        {
            "temp_id": "t1",
            "image_id": "img-1",
            "category": "tops",
            "sub_category": None,
            "colors": [],
            "material": None,
            "pattern": None,
            "brand": None,
            "confidence": 0.5,
            "bounding_box": None,
            "detailed_description": None,
            "person_id": None,
            "person_label": None,
            "is_current_user_person": False,
            "include_in_wardrobe": True,
            "status": "generated",
            "source_image_url": None,
            "source_image_storage_path": None,
            "generated_image_url": "https://cdn/x.png",
            "generation_error": None,
        }
    ]
    assert "generated_image_base64" not in payload["items"][0]


def test_parse_image_extraction_status_defaults_legacy_values():
    assert _parse_image_extraction_status(None) == BatchJobStatus.PENDING
    assert _parse_image_extraction_status("completed") == BatchJobStatus.COMPLETED
    assert _parse_image_extraction_status("bogus-legacy-value") == BatchJobStatus.PENDING


def test_count_active_jobs():
    assert BatchJobService.count_active_jobs() == 0
    job = BatchJob(
        job_id="j1",
        user_id="u1",
        status=BatchJobStatus.PENDING,
        created_at=datetime.now(timezone.utc),
    )
    finished = BatchJob(
        job_id="j2",
        user_id="u2",
        status=BatchJobStatus.COMPLETED,
        created_at=datetime.now(timezone.utc),
    )
    BatchJobService._jobs[job.job_id] = job
    BatchJobService._jobs[finished.job_id] = finished
    assert BatchJobService.count_active_jobs() == 1


# ---------------------------------------------------------------------------
# Hydration edge shapes
# ---------------------------------------------------------------------------


def test_hydrate_accepts_dict_images_and_skips_non_dict_items():
    row = {
        "id": "j1",
        "user_id": "u1",
        "status": "pending",
        "created_at": "2026-01-01T00:00:00+00:00",
        "images": {
            "img-1": {
                "image_id": "img-1",
                "filename": "a.jpg",
                "extraction_status": "completed",
            }
        },
        "items": ["junk", {"temp_id": "t1", "category": "tops", "status": "generated"}],
    }
    job = BatchJobService._hydrate(row, Mock())

    assert job is not None
    assert job.images["img-1"].extraction_status == BatchJobStatus.COMPLETED
    assert job.extraction_completed == {"img-1"}
    assert job.detected_items[0].temp_id == "t1"
    assert job.generation_completed == {"t1"}


def test_hydrate_defaults_legacy_extraction_status():
    row = {
        "id": "j2",
        "user_id": "u1",
        "status": "pending",
        "created_at": "2026-01-01T00:00:00+00:00",
        "images": [{"image_id": "img-1", "extraction_status": "legacy-unknown"}],
        "items": [],
    }
    job = BatchJobService._hydrate(row, Mock())
    assert job is not None
    assert job.images["img-1"].extraction_status == BatchJobStatus.PENDING
    assert "img-1" not in job.extraction_completed
    assert "img-1" not in job.extraction_failed


def test_hydrate_returns_none_on_malformed_row():
    assert BatchJobService._hydrate({"user_id": "u1"}, Mock()) is None


def test_hydrate_detected_item_without_image_tracks_no_generation():
    """A 'detected' item with no generated image nor error belongs to neither
    the completed nor the failed generation set after hydration."""
    row = {
        "id": "j3",
        "user_id": "u1",
        "status": "pending",
        "created_at": "2026-01-01T00:00:00+00:00",
        "images": {"img-1": {"image_id": "img-1"}},
        "items": [
            {
                "temp_id": "t1",
                "image_id": "img-1",
                "category": "tops",
                "status": "detected",
                "generated_image_base64": None,
                "generated_image_url": None,
                "generation_error": None,
            }
        ],
    }
    job = BatchJobService._hydrate(row, Mock())
    assert job is not None
    assert job.generation_completed == set()
    assert job.generation_failed == {}


# ---------------------------------------------------------------------------
# create_job
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_job_post_build_cap_check_raises_server_busy(monkeypatch):
    """The re-check under the lock catches a slot lost between the pre-check
    and admission (two checks, same SERVER_BUSY contract as the pre-check)."""
    active = BatchJob(
        job_id="j1",
        user_id="u1",
        status=BatchJobStatus.PENDING,
        created_at=datetime.now(timezone.utc),
    )

    class _FlakyStore(dict):
        def __init__(self, *args, **kwargs):
            super().__init__(*args, **kwargs)
            self._reads = 0

        def values(self):
            self._reads += 1
            if self._reads == 2:
                return [active, active]
            return super().values()

    monkeypatch.setattr(BatchJobService, "_jobs", _FlakyStore())

    with pytest.raises(RateLimitError) as exc_info:
        await BatchJobService.create_job(
            "u2", [{"image_id": "img-1", "image_base64": "x"}]
        )
    assert exc_info.value.error_code == "SERVER_BUSY"


@pytest.mark.asyncio
async def test_create_job_persistence_create_false_raises_friendly_503():
    with patch.object(bjs._store, "create", AsyncMock(return_value=False)):
        with pytest.raises(AIServiceError) as exc_info:
            await BatchJobService.create_job(
                "u1", [{"image_id": "img-1", "image_base64": "x"}], db=Mock()
            )
    assert exc_info.value.retryable is True
    # The admitted-but-unpersisted job must not occupy a concurrency slot.
    assert BatchJobService._jobs == {}


@pytest.mark.asyncio
async def test_create_job_persistence_migration_gap_logs_hint():
    """A postgrest migration-gap error (missing table/columns) logs the
    operator hint and surfaces as the friendly retryable 503."""
    db = Mock()
    db.table.return_value.upsert.return_value.execute.side_effect = RuntimeError(
        "PGRST204 Could not find the table 'extraction_jobs' in schema 'public'"
    )
    with pytest.raises(AIServiceError) as exc_info:
        await BatchJobService.create_job(
            "u1", [{"image_id": "img-1", "image_base64": "x"}], db=db
        )
    assert exc_info.value.retryable is True
    assert BatchJobService._jobs == {}


@pytest.mark.asyncio
async def test_create_job_persistence_aiservice_error_propagates():
    with patch.object(
        bjs._store, "create", AsyncMock(side_effect=AIServiceError("nope", retryable=False))
    ):
        with pytest.raises(AIServiceError, match="nope"):
            await BatchJobService.create_job(
                "u1", [{"image_id": "img-1", "image_base64": "x"}], db=Mock()
            )
    assert BatchJobService._jobs == {}


# ---------------------------------------------------------------------------
# Payload release helpers
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_release_helpers_missing_jobs_are_noops():
    await BatchJobService.release_image_payloads("ghost")
    await BatchJobService.release_single_image_payload("ghost", "img-1")
    await BatchJobService.release_generated_payloads("ghost")
    await BatchJobService.clear_event_history("ghost")


@pytest.mark.asyncio
async def test_release_single_image_payload_unknown_image():
    job = await _make_job()
    await BatchJobService.release_single_image_payload(job.job_id, "ghost")
    assert job.images["img-1"].image_base64 == "c291cmNl"


# ---------------------------------------------------------------------------
# get_job / cancel_job / check_durable_cancel
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_job_in_memory_attaches_persistence_db():
    job = await _make_job()
    db = object()
    fetched = await BatchJobService.get_job(job.job_id, "u1", db=db)
    assert fetched is job
    assert fetched.persistence_db is db


@pytest.mark.asyncio
async def test_get_job_missing_without_db_returns_none():
    assert await BatchJobService.get_job("ghost", "u1") is None


@pytest.mark.asyncio
async def test_get_job_hydrates_malformed_row_to_none():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data={"user_id": "u1"}  # no id/status/created_at -> hydrate returns None
    )
    assert await BatchJobService.get_job("ghost", "u1", db=db) is None


@pytest.mark.asyncio
async def test_get_job_reacquires_job_admitted_during_durable_read(monkeypatch):
    """A job admitted by another worker while the durable read is in flight is
    found again under the second lock and gets the caller's persistence db."""
    job = await _make_job()
    async with BatchJobService._lock:
        BatchJobService._jobs.pop(job.job_id, None)
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data={"id": job.job_id, "user_id": "u1", "status": "pending",
              "created_at": "2026-01-01T00:00:00+00:00"}
    )
    real_to_thread = asyncio.to_thread

    async def race_to_thread(fn, *args, **kwargs):
        # The job lands in memory between the durable read's start and finish.
        async with BatchJobService._lock:
            BatchJobService._jobs[job.job_id] = job
        return await real_to_thread(fn, *args, **kwargs)

    monkeypatch.setattr(bjs.asyncio, "to_thread", race_to_thread)
    fetched = await BatchJobService.get_job(job.job_id, "u1", db=db)
    assert fetched is job
    assert fetched.persistence_db is db


@pytest.mark.asyncio
async def test_cancel_job_missing_and_foreign_user():
    job = await _make_job()
    assert await BatchJobService.cancel_job(job.job_id, "other-user") is False
    assert await BatchJobService.cancel_job("ghost", "u1") is False
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None
    assert await BatchJobService.cancel_job("ghost", "u1", db=db) is False


@pytest.mark.asyncio
async def test_cancel_job_terminal_returns_false():
    job = await _make_job()
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
    assert await BatchJobService.cancel_job(job.job_id, "u1") is False


@pytest.mark.asyncio
async def test_cancel_job_happy_path():
    job = await _make_job()
    assert await BatchJobService.cancel_job(job.job_id, "u1") is True
    assert job.cancelled is True
    assert job.cancel_event.is_set()
    assert job.status == BatchJobStatus.CANCELLED


@pytest.mark.asyncio
async def test_cancel_job_transition_lost_returns_false():
    job = await _make_job()
    job.persistence_db = Mock()
    with patch.object(bjs._store, "transition", AsyncMock(return_value=False)):
        assert await BatchJobService.cancel_job(job.job_id, "u1") is False
    assert job.status == BatchJobStatus.PENDING


@pytest.mark.asyncio
async def test_cancel_job_transition_lost_but_adopted_succeeds():
    """The CAS lost to a writer that already persisted CANCELLED; adoption
    makes the local terminal state visible, so the cancel reports success."""
    job = await _make_job()
    job.persistence_db = Mock()

    async def lost_but_adopted(target, **kwargs):
        # A concurrent worker already persisted CANCELLED.
        target.status = BatchJobStatus.CANCELLED
        return False

    with patch.object(bjs._store, "transition", lost_but_adopted):
        assert await BatchJobService.cancel_job(job.job_id, "u1") is True
    assert job.status == BatchJobStatus.CANCELLED
    assert job.cancelled is True
    assert job.cancel_event.is_set()


@pytest.mark.asyncio
async def test_cancel_job_persisted_cas_success():
    """The durable CAS write succeeds: the terminal cancel is persisted."""
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.eq.return_value.execute.return_value = Mock(
        data=None  # _payload_ok treats a None data as a matched CAS
    )
    job = await _make_job()
    job.persistence_db = db
    assert await BatchJobService.cancel_job(job.job_id, "u1") is True
    assert job.status == BatchJobStatus.CANCELLED
    assert job.cancelled is True


@pytest.mark.asyncio
async def test_cancel_job_adopts_externally_persisted_cancel():
    db = Mock()
    db.table.return_value.update.return_value.eq.return_value.eq.return_value.eq.return_value.execute.return_value = Mock(
        data=[]
    )
    db.table.return_value.select.return_value.eq.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data={"status": "cancelled"}
    )
    job = await _make_job()
    job.persistence_db = db

    assert await BatchJobService.cancel_job(job.job_id, "u1") is True
    assert job.status == BatchJobStatus.CANCELLED
    assert job.cancelled is True


@pytest.mark.asyncio
async def test_check_durable_cancel_adopts_persisted_cancel():
    job = await _make_job()
    job.persistence_db = Mock()
    with patch.object(bjs._store, "_read_status", AsyncMock(return_value="cancelled")):
        await BatchJobService.check_durable_cancel(job)
    assert job.cancelled is True
    assert job.cancel_event.is_set()
    assert job.status == BatchJobStatus.CANCELLED
    assert job.persistence_dirty is False


@pytest.mark.asyncio
async def test_check_durable_cancel_noop_paths():
    job = await _make_job()  # persistence_db None: early return
    await BatchJobService.check_durable_cancel(job)

    job.persistence_db = Mock()
    job.cancelled = True
    await BatchJobService.check_durable_cancel(job)  # already cancelled: early return

    job2 = await _make_job("u2")
    job2.persistence_db = Mock()
    with patch.object(bjs._store, "_read_status", AsyncMock(return_value=None)):
        await BatchJobService.check_durable_cancel(job2)  # no durable row
    assert job2.status == BatchJobStatus.PENDING

    with patch.object(bjs._store, "_read_status", AsyncMock(return_value="pending")):
        await BatchJobService.check_durable_cancel(job2)  # row not cancelled
    assert job2.status == BatchJobStatus.PENDING


# ---------------------------------------------------------------------------
# update_status / add_detected_items / mark_extraction_failed
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_update_status_guards():
    await BatchJobService.update_status("ghost", BatchJobStatus.EXTRACTING)
    job = await _make_job()
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
    await BatchJobService.update_status(job.job_id, BatchJobStatus.EXTRACTING)
    assert job.status == BatchJobStatus.COMPLETED


@pytest.mark.asyncio
async def test_update_status_terminal_transition_lost():
    job = await _make_job()
    job.persistence_db = Mock()
    with patch.object(bjs._store, "transition", AsyncMock(return_value=False)):
        await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)
    assert job.status == BatchJobStatus.PENDING


@pytest.mark.asyncio
async def test_add_detected_items_unknown_image_and_terminal_guard():
    job = await _make_job()
    added = await BatchJobService.add_detected_items(
        job.job_id, "ghost", [{"temp_id": "t1", "category": "tops"}]
    )
    assert len(added) == 1
    assert added[0].source_image_url is None
    assert "ghost" in job.extraction_completed

    finished = await _make_job("u2")
    await BatchJobService.update_status(finished.job_id, BatchJobStatus.COMPLETED)
    assert (
        await BatchJobService.add_detected_items(
            finished.job_id, "img-1", [{"temp_id": "t2", "category": "tops"}]
        )
        == []
    )
    assert finished.detected_items == []


@pytest.mark.asyncio
async def test_mark_extraction_failed_branches():
    await BatchJobService.mark_extraction_failed("ghost", "img-1", "x")
    job = await _make_job()
    await BatchJobService.mark_extraction_failed(job.job_id, "img-1", "boom")
    assert job.extraction_failed["img-1"] == "boom"
    assert job.images["img-1"].extraction_status == BatchJobStatus.FAILED
    assert job.images["img-1"].extraction_error == "boom"

    await BatchJobService.mark_extraction_failed(job.job_id, "ghost", "nope")
    assert job.extraction_failed["ghost"] == "nope"

    finished = await _make_job("u2")
    await BatchJobService.update_status(finished.job_id, BatchJobStatus.COMPLETED)
    await BatchJobService.mark_extraction_failed(finished.job_id, "img-1", "late")
    assert "img-1" not in finished.extraction_failed


# ---------------------------------------------------------------------------
# restore_cached_items / update_item_generation / set_error
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_restore_cached_items_populates_job():
    job = await _make_job()
    await BatchJobService.restore_cached_items(
        job.job_id,
        [
            {
                "temp_id": "c1",
                "image_id": "img-1",
                "category": "tops",
                "colors": ["black", "white"],
                "confidence": 0.9,
                "include_in_wardrobe": True,
                "status": "generated",
                "generated_image_url": "https://cdn/1.png",
            },
            {
                "temp_id": "c2",
                "category": "bottoms",
                "colors": "not-a-list",
                "confidence": "oops",
                "include_in_wardrobe": "yes",
                "status": "failed",
                "generation_error": "gen boom",
            },
            "junk",
        ],
    )

    assert [i.temp_id for i in job.detected_items] == ["c1", "c2"]
    assert job.detected_items[1].colors == []
    assert job.detected_items[1].confidence == 0.0
    assert job.detected_items[1].include_in_wardrobe is True
    assert job.detected_items[1].image_id == "img-1"  # default_image_id
    assert job.generation_completed == {"c1"}
    assert job.generation_failed == {"c2": "gen boom"}
    assert job.extraction_completed == {"img-1"}
    assert job.images["img-1"].extraction_status == BatchJobStatus.COMPLETED


@pytest.mark.asyncio
async def test_restore_cached_items_missing_job_is_noop():
    await BatchJobService.restore_cached_items("ghost", [{"category": "tops"}])


@pytest.mark.asyncio
async def test_restore_cached_items_detected_item_tracks_no_generation():
    """A restored item that is neither generated nor failed belongs to no
    generation tracking set."""
    job = await _make_job()
    await BatchJobService.restore_cached_items(
        job.job_id,
        [{"temp_id": "t1", "image_id": "img-1", "category": "tops", "status": "detected"}],
    )
    assert job.generation_completed == set()
    assert job.generation_failed == {}


@pytest.mark.asyncio
async def test_update_item_generation_error_and_missing_item():
    await BatchJobService.update_item_generation("ghost", "t1", generated_image_base64="b64")
    job = await _make_job()
    await BatchJobService.add_detected_items(
        job.job_id, "img-1", [{"temp_id": "t1", "category": "tops"}]
    )
    await BatchJobService.update_item_generation(job.job_id, "t1", error="gen boom")
    assert job.detected_items[0].status == "failed"
    assert job.generation_failed == {"t1": "gen boom"}

    # Unknown temp_id: loop exits without a match.
    await BatchJobService.update_item_generation(job.job_id, "nope", generated_image_base64="b64")
    assert job.detected_items[0].generated_image_base64 is None


@pytest.mark.asyncio
async def test_set_error_branches():
    await BatchJobService.set_error("ghost", "x")
    job = await _make_job()
    await BatchJobService.set_error(job.job_id, "real error")
    assert job.status == BatchJobStatus.FAILED
    assert job.error_message == "real error"

    lost = await _make_job("u2")
    lost.persistence_db = Mock()
    with patch.object(bjs._store, "transition", AsyncMock(return_value=False)):
        await BatchJobService.set_error(lost.job_id, "lost cas")
    assert lost.status == BatchJobStatus.PENDING


# ---------------------------------------------------------------------------
# broadcast_event / subscribers
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_broadcast_drops_slow_subscriber_and_removes_it():
    job = await _make_job()
    queue = asyncio.Queue(maxsize=1)
    queue.put_nowait(("prefill", 1))
    job.subscribers.append(queue)

    await BatchJobService.broadcast_event(
        job.job_id, "image_extraction_complete", {"image_id": "img-1"}
    )

    assert queue not in job.subscribers
    event, _size = queue.get_nowait()
    assert event["type"] == "stream_overflow"


@pytest.mark.asyncio
async def test_broadcast_handles_dropped_queue_already_unsubscribed():
    job = await _make_job()
    foreign = asyncio.Queue()
    with patch("app.services.batch_job_service.fanout", return_value=[foreign]):
        await BatchJobService.broadcast_event(job.job_id, "x", {})
    assert foreign not in job.subscribers


@pytest.mark.asyncio
async def test_broadcast_dropped_slow_subscriber_after_job_eviction():
    """A slow subscriber dropped while the job is evicted mid-fanout still
    logs the drop instead of crashing."""
    job = await _make_job()
    queue = asyncio.Queue()
    job.subscribers.append(queue)

    def evict_and_drop(event, subscribers):
        BatchJobService._jobs.pop(job.job_id, None)
        return [queue]

    with patch("app.services.batch_job_service.fanout", evict_and_drop):
        await BatchJobService.broadcast_event(job.job_id, "x", {})


@pytest.mark.asyncio
async def test_add_subscriber_missing_job_returns_false():
    assert await BatchJobService.add_subscriber("ghost", asyncio.Queue()) is False


@pytest.mark.asyncio
async def test_add_subscriber_replay_respects_last_event_id_and_queue_full():
    job = await _make_job()
    for i in range(6):
        await BatchJobService.broadcast_event(job.job_id, "e", {"i": i})
    queue = asyncio.Queue(maxsize=2)
    queue.put_nowait(("a", 1))
    queue.put_nowait(("b", 1))

    assert await BatchJobService.add_subscriber(job.job_id, queue, last_event_id=3) is True

    assert queue in job.subscribers
    # The replay tail could not be admitted: the queue was already full.
    assert queue.qsize() == 2


@pytest.mark.asyncio
async def test_add_subscriber_replay_generic_error_is_caught():
    class _BrokenQueue(asyncio.Queue):
        def put_nowait(self, item):
            raise RuntimeError("boom")

    job = await _make_job()
    await BatchJobService.broadcast_event(job.job_id, "e", {"x": 1})
    await BatchJobService.broadcast_event(job.job_id, "e", {"x": 2})

    assert await BatchJobService.add_subscriber(job.job_id, _BrokenQueue()) is True


@pytest.mark.asyncio
async def test_remove_subscriber_branches():
    job = await _make_job()
    queue = asyncio.Queue()
    job.subscribers.append(queue)
    await BatchJobService.remove_subscriber(job.job_id, queue)
    assert queue not in job.subscribers
    # Unknown queue / missing job: still drains via discard_subscriber.
    await BatchJobService.remove_subscriber(job.job_id, queue)
    await BatchJobService.remove_subscriber("ghost", queue)


@pytest.mark.asyncio
async def test_get_job_status_present_and_missing():
    job = await _make_job()
    status = await BatchJobService.get_job_status(job.job_id)
    assert status["job_id"] == job.job_id
    assert status["total_images"] == 1
    assert await BatchJobService.get_job_status("ghost") is None


# ---------------------------------------------------------------------------
# Cleanup loop / expiry
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cleanup_loop_runs_and_survives_errors(monkeypatch):
    BatchJobService._cleanup_task = None
    monkeypatch.setattr(bjs, "_CLEANUP_INTERVAL_S", 0.001)
    calls = []

    async def fake_cleanup():
        calls.append(1)
        if len(calls) == 1:
            raise RuntimeError("boom")

    monkeypatch.setattr(BatchJobService, "_cleanup_expired_jobs", fake_cleanup)
    task = asyncio.create_task(BatchJobService._cleanup_loop())
    await asyncio.sleep(0.05)
    task.cancel()
    # The loop swallows CancelledError and breaks cleanly.
    await task
    assert len(calls) >= 2  # the error did not kill the loop
    BatchJobService._cleanup_task = None


@pytest.mark.asyncio
async def test_cleanup_expired_jobs_evicts_and_frees_payloads():
    old_finished = await _make_job("u1")
    await BatchJobService.add_detected_items(
        old_finished.job_id, "img-1", [{"temp_id": "t1", "category": "tops"}]
    )
    await BatchJobService.update_item_generation(
        old_finished.job_id, "t1", generated_image_base64="Z2VuZXJhdGVk"
    )
    await BatchJobService.broadcast_event(old_finished.job_id, "e", {"x": 1})
    old_finished.status = BatchJobStatus.COMPLETED
    old_finished.created_at = datetime.now(timezone.utc) - timedelta(minutes=20)

    young_finished = await _make_job("u2")
    await BatchJobService.add_detected_items(
        young_finished.job_id, "img-1", [{"temp_id": "t2", "category": "tops"}]
    )
    await BatchJobService.update_item_generation(
        young_finished.job_id, "t2", generated_image_base64="c2Vjb25k"
    )
    await BatchJobService.broadcast_event(young_finished.job_id, "e", {"x": 1})
    young_finished.status = BatchJobStatus.COMPLETED

    old_active = await _make_job("u3")
    old_active.status = BatchJobStatus.EXTRACTING
    old_active.created_at = datetime.now(timezone.utc) - timedelta(minutes=40)
    young_active = await _make_job("u4")
    young_active.status = BatchJobStatus.EXTRACTING

    await BatchJobService._cleanup_expired_jobs()

    assert old_finished.job_id not in BatchJobService._jobs
    assert old_active.job_id not in BatchJobService._jobs
    assert young_finished.job_id in BatchJobService._jobs
    assert young_active.job_id in BatchJobService._jobs
    # Finished jobs free source base64 and history immediately.
    assert young_finished.images["img-1"].image_base64 == ""
    assert young_finished.event_history == []
    # The young finished job keeps its generated base64 (status polls still use it).
    assert young_finished.detected_items[0].generated_image_base64 == "c2Vjb25k"
    # The old finished job's generated payload was freed before eviction.
    assert old_finished.detected_items[0].generated_image_base64 is None
