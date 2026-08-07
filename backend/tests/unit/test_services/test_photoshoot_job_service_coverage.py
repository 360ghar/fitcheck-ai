"""Coverage-completing tests for PhotoshootJobService.

Sibling to test_photoshoot_service.py / test_durable_job_state.py /
test_job_cleanup.py: this file pins the remaining untested branches — the
concurrency cap re-check during admission, persistence failure compensation
(create returns no row / raises AIServiceError), durable-row hydration
fallbacks (legacy failed_indices, non-dict generated images, malformed rows),
the get_job durable-read race, cancel/set_error CAS-loss paths, SSE subscriber
drop handling, and the cleanup loop's error branch.
"""

import asyncio
import uuid
from datetime import timedelta
from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.core.exceptions import AIServiceError, RateLimitError
from app.models.photoshoot import PhotoshootJobStatus
from app.services import photoshoot_job_service
from app.services.photoshoot_job_service import (
    _FINISHED_JOB_TTL,
    PhotoshootJob,
    PhotoshootJobService,
)
from app.utils.datetime_util import utcnow
from app.utils.db import QUOTA_UNAVAILABLE_CLIENT_MESSAGE

USER_ID = "u1"


@pytest.fixture(autouse=True)
def _clear_job_store():
    PhotoshootJobService._jobs.clear()
    yield
    PhotoshootJobService._jobs.clear()


def _persisted_row(**overrides):
    row = {
        "id": "ps-1",
        "user_id": USER_ID,
        "status": "pending",
        "created_at": utcnow().isoformat(),
        "use_case": "aesthetic",
        "custom_prompt": None,
        "num_images": 2,
        "batch_size": 2,
        "aspect_ratio": "1:1",
        "session_id": "ps_abc",
        "total_batches": 1,
        "current_batch": 0,
        "generated_images": [],
        "failed_indices": [],
        "error_message": None,
        "usage": None,
    }
    row.update(overrides)
    return row


async def _make_job(user_id=USER_ID, num_images=2):
    return await PhotoshootJobService.create_job(
        user_id=user_id,
        photos=["c291cmNl"],
        use_case="aesthetic",
        num_images=num_images,
    )


def _db_select_result(row):
    """Mock db whose photoshoot_jobs select chain returns `row` (data attr)."""
    db = Mock()
    result = Mock(data=row)
    maybe_single = (
        db.table.return_value.select.return_value.eq.return_value.eq.return_value
        .maybe_single.return_value
    )
    maybe_single.execute.return_value = result
    return db


# =============================================================================
# Admission / persistence
# =============================================================================


@pytest.mark.asyncio
async def test_count_active_jobs_counts_only_active_statuses():
    job = await _make_job()
    assert PhotoshootJobService.count_active_jobs() == 1

    await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)
    assert PhotoshootJobService.count_active_jobs() == 0


@pytest.mark.asyncio
async def test_create_job_second_cap_check_raises_when_slot_taken_during_admission():
    """The cap is re-checked under the lock after job construction; another
    request that lands between the checks must still trip the limit."""

    def _inject_busy_jobs():
        now = utcnow()
        PhotoshootJobService._jobs["busy-a"] = PhotoshootJob(
            job_id="busy-a",
            user_id="other",
            status=PhotoshootJobStatus.PROCESSING,
            created_at=now,
            photos=[],
            use_case="aesthetic",
        )
        PhotoshootJobService._jobs["busy-b"] = PhotoshootJob(
            job_id="busy-b",
            user_id="other",
            status=PhotoshootJobStatus.PROCESSING,
            created_at=now,
            photos=[],
            use_case="aesthetic",
        )
        return uuid.uuid4()

    with patch("app.services.photoshoot_job_service.uuid4", side_effect=_inject_busy_jobs):
        with pytest.raises(RateLimitError) as exc_info:
            await PhotoshootJobService.create_job(USER_ID, ["c291cmNl"], "aesthetic", 2)

    assert exc_info.value.status_code == 429
    assert "busy" in exc_info.value.message.lower()
    assert "busy-a" in PhotoshootJobService._jobs and "busy-b" in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_create_job_pops_job_and_503s_when_persistence_returns_no_row():
    db = Mock()
    with patch.object(
        photoshoot_job_service._store, "create", new=AsyncMock(return_value=False)
    ):
        with pytest.raises(AIServiceError) as exc_info:
            await PhotoshootJobService.create_job(
                USER_ID, ["c291cmNl"], "aesthetic", 2, db=db
            )

    assert exc_info.value.message == QUOTA_UNAVAILABLE_CLIENT_MESSAGE
    assert exc_info.value.retryable is True
    assert PhotoshootJobService._jobs == {}


@pytest.mark.asyncio
async def test_create_job_re_raises_ai_service_error_and_pops_job():
    db = Mock()
    with patch.object(
        photoshoot_job_service._store,
        "create",
        new=AsyncMock(side_effect=AIServiceError("persist boom")),
    ):
        with pytest.raises(AIServiceError):
            await PhotoshootJobService.create_job(
                USER_ID, ["c291cmNl"], "aesthetic", 2, db=db
            )

    assert PhotoshootJobService._jobs == {}


# =============================================================================
# In-memory release helpers (missing-job no-ops)
# =============================================================================


@pytest.mark.asyncio
async def test_release_reference_photos_missing_job_is_noop():
    await PhotoshootJobService.release_reference_photos("nope")
    assert "nope" not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_clear_event_history_missing_job_is_noop():
    await PhotoshootJobService.clear_event_history("nope")


@pytest.mark.asyncio
async def test_release_generated_payloads_missing_job_is_noop():
    await PhotoshootJobService.release_generated_payloads("nope")


# =============================================================================
# get_job
# =============================================================================


@pytest.mark.asyncio
async def test_get_job_in_memory_hit_reattaches_persistence_db():
    job = await _make_job()
    db = Mock()
    returned = await PhotoshootJobService.get_job(job.job_id, USER_ID, db=db)

    assert returned is job
    assert returned.persistence_db is db


@pytest.mark.asyncio
async def test_get_job_durable_miss_returns_none():
    job = await _make_job()
    PhotoshootJobService._jobs.clear()
    db = _db_select_result(None)

    assert await PhotoshootJobService.get_job(job.job_id, USER_ID, db=db) is None


@pytest.mark.asyncio
async def test_get_job_durable_read_race_reattaches_db_to_in_memory_job():
    """A job that lands in memory while the durable read is in flight must get
    its persistence db re-attached instead of being re-hydrated."""
    job = await _make_job()
    PhotoshootJobService._jobs.clear()
    db = Mock()
    result = Mock(data=_persisted_row(id=job.job_id))

    def _execute():
        PhotoshootJobService._jobs[job.job_id] = job
        return result

    maybe_single = (
        db.table.return_value.select.return_value.eq.return_value.eq.return_value
        .maybe_single.return_value
    )
    maybe_single.execute = _execute

    returned = await PhotoshootJobService.get_job(job.job_id, USER_ID, db=db)

    assert returned is job
    assert returned.persistence_db is db


@pytest.mark.asyncio
async def test_get_job_returns_none_when_hydration_fails():
    PhotoshootJobService._jobs.clear()
    db = _db_select_result({"user_id": USER_ID})  # missing "id" -> KeyError

    assert await PhotoshootJobService.get_job("ps-missing", USER_ID, db=db) is None


# =============================================================================
# cancel_job
# =============================================================================


@pytest.mark.asyncio
async def test_cancel_job_loads_from_db_then_reports_not_found():
    db = _db_select_result(None)

    result = await PhotoshootJobService.cancel_job("ps-gone", USER_ID, db=db)

    assert result is False
    assert "ps-gone" not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_cancel_job_returns_false_when_persisted_cas_loses():
    job = await _make_job()
    job.persistence_db = Mock()
    job.status = PhotoshootJobStatus.PROCESSING

    with patch.object(
        photoshoot_job_service._store, "transition", new=AsyncMock(return_value=False)
    ):
        result = await PhotoshootJobService.cancel_job(job.job_id, USER_ID)

    assert result is False
    assert job.cancelled is False
    assert job.status == PhotoshootJobStatus.PROCESSING


@pytest.mark.asyncio
async def test_cancel_job_adopts_external_cancelled_when_cas_loses():
    """A CAS that loses to a writer that already persisted CANCELLED must
    adopt the terminal state and report success instead of a 404."""
    job = await _make_job()
    job.persistence_db = Mock()
    job.status = PhotoshootJobStatus.PROCESSING

    async def _transition_adopting(job, *, status, error_message=None):
        job.status = PhotoshootJobStatus.CANCELLED
        job._persisted_status = PhotoshootJobStatus.CANCELLED
        return False

    with patch.object(
        photoshoot_job_service._store, "transition", new=_transition_adopting
    ):
        result = await PhotoshootJobService.cancel_job(job.job_id, USER_ID)

    assert result is True
    assert job.cancelled is True
    assert job.status == PhotoshootJobStatus.CANCELLED


# =============================================================================
# Status / progress mutations
# =============================================================================


@pytest.mark.asyncio
async def test_update_status_missing_job_is_noop():
    await PhotoshootJobService.update_status("nope", PhotoshootJobStatus.FAILED)


@pytest.mark.asyncio
async def test_update_current_batch_missing_job_is_noop():
    await PhotoshootJobService.update_current_batch("nope", 2)


@pytest.mark.asyncio
async def test_set_usage_missing_job_is_noop():
    await PhotoshootJobService.set_usage("nope", {"used_today": 1})


@pytest.mark.asyncio
async def test_set_error_returns_early_when_persisted_cas_loses():
    job = await _make_job()
    job.persistence_db = Mock()
    job.status = PhotoshootJobStatus.PROCESSING

    with patch.object(
        photoshoot_job_service._store, "transition", new=AsyncMock(return_value=False)
    ):
        await PhotoshootJobService.set_error(job.job_id, "boom")

    assert job.status == PhotoshootJobStatus.PROCESSING
    assert job.error_message is None


# =============================================================================
# SSE broadcasting / subscribers
# =============================================================================


@pytest.mark.asyncio
async def test_broadcast_event_missing_job_is_noop():
    await PhotoshootJobService.broadcast_event("nope", "job_progress", {"x": 1})


@pytest.mark.asyncio
async def test_broadcast_event_removes_dropped_slow_subscriber():
    job = await _make_job()
    queue = asyncio.Queue()
    ok, replay_from = await PhotoshootJobService.add_subscriber(job.job_id, queue)
    assert ok is True and replay_from == 0

    with patch("app.services.photoshoot_job_service.fanout", return_value=[queue]):
        await PhotoshootJobService.broadcast_event(job.job_id, "job_progress", {"x": 1})

    assert queue not in job.subscribers


@pytest.mark.asyncio
async def test_broadcast_event_dropped_queue_not_subscribed_skips_removal():
    job = await _make_job()
    subscribed = asyncio.Queue()
    stray = asyncio.Queue()
    await PhotoshootJobService.add_subscriber(job.job_id, subscribed)

    with patch("app.services.photoshoot_job_service.fanout", return_value=[stray]):
        await PhotoshootJobService.broadcast_event(job.job_id, "job_progress", {"x": 1})

    assert subscribed in job.subscribers
    assert stray not in job.subscribers


@pytest.mark.asyncio
async def test_broadcast_event_job_evicted_after_fanout_skips_removal():
    job = await _make_job()
    queue = asyncio.Queue()
    await PhotoshootJobService.add_subscriber(job.job_id, queue)

    def _fanout_evicting(_event, _subscribers):
        PhotoshootJobService._jobs.pop(job.job_id)
        return [queue]

    with patch("app.services.photoshoot_job_service.fanout", side_effect=_fanout_evicting):
        await PhotoshootJobService.broadcast_event(job.job_id, "job_progress", {"x": 1})

    assert job.job_id not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_add_subscriber_missing_job_returns_failure():
    ok, replay_from = await PhotoshootJobService.add_subscriber("nope", asyncio.Queue())
    assert ok is False and replay_from == 0


@pytest.mark.asyncio
async def test_remove_subscriber_missing_job_still_discards_queue():
    queue = asyncio.Queue()
    await PhotoshootJobService.remove_subscriber("nope", queue)


@pytest.mark.asyncio
async def test_get_event_history_missing_job_returns_empty():
    assert await PhotoshootJobService.get_event_history("nope") == []


@pytest.mark.asyncio
async def test_get_job_status_missing_job_returns_none():
    assert await PhotoshootJobService.get_job_status("nope") is None


# =============================================================================
# Payload / hydration helpers
# =============================================================================


def test_build_persisted_payload_strips_base64_from_image_dicts():
    job = PhotoshootJob(
        job_id="ps-1",
        user_id=USER_ID,
        status=PhotoshootJobStatus.PROCESSING,
        created_at=utcnow(),
        photos=["c291cmNl"],
        use_case="aesthetic",
    )
    job.generated_images = [
        {"id": "img-1", "index": 0, "image_base64": "QUJD", "image_url": "https://cdn/1.png"},
        "not-a-dict",
    ]

    payload = photoshoot_job_service._build_persisted_payload(job)

    assert payload["generated_images"] == [
        {"id": "img-1", "index": 0, "image_url": "https://cdn/1.png"}
    ]


def test_hydrate_falls_back_to_legacy_failed_indices():
    row = _persisted_row(failed_indices=[1, 3])  # no image_failures column

    job = PhotoshootJobService._hydrate(row, Mock())

    assert job is not None
    assert job.image_failures == {1: "", 3: ""}
    assert job.failed_indices == {1, 3}


def test_hydrate_prefers_image_failures_over_failed_indices():
    row = _persisted_row(
        image_failures=[{"index": 2, "error": "provider timeout"}],
        failed_indices=[1, 3],
    )

    job = PhotoshootJobService._hydrate(row, Mock())

    assert job is not None
    assert job.image_failures == {2: "provider timeout"}
    assert job.failed_indices == {2}


def test_hydrate_skips_non_dict_generated_images():
    row = _persisted_row(generated_images=[{"id": "a", "image_base64": "x"}, "junk"])

    job = PhotoshootJobService._hydrate(row, Mock())

    assert job is not None
    assert job.generated_images == [{"id": "a"}]


def test_hydrate_returns_none_on_malformed_row():
    row = {"user_id": USER_ID, "status": "pending"}  # missing "id"

    assert PhotoshootJobService._hydrate(row, Mock()) is None


# =============================================================================
# Cleanup
# =============================================================================


@pytest.mark.asyncio
async def test_cleanup_evicts_old_finished_job_and_pops_generated_base64():
    job = await _make_job()
    await PhotoshootJobService.add_generated_image(
        job.job_id,
        "img-1",
        0,
        image_base64="QUJD",
        image_url="https://cdn/1.png",
    )
    job.generated_images.append("not-a-dict")  # non-dict entries are skipped
    await PhotoshootJobService.update_status(job.job_id, PhotoshootJobStatus.COMPLETE)
    job.created_at = utcnow() - (_FINISHED_JOB_TTL + timedelta(minutes=1))

    await PhotoshootJobService._cleanup_expired_jobs()

    assert job.job_id not in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_cleanup_keeps_young_active_job():
    job = await _make_job()

    await PhotoshootJobService._cleanup_expired_jobs()

    assert job.job_id in PhotoshootJobService._jobs


@pytest.mark.asyncio
async def test_cleanup_loop_logs_and_continues_on_error(monkeypatch):
    monkeypatch.setattr(photoshoot_job_service, "_CLEANUP_INTERVAL_S", 0)
    with patch.object(
        PhotoshootJobService,
        "_cleanup_expired_jobs",
        new=AsyncMock(side_effect=RuntimeError("boom")),
    ) as sweep:
        task = asyncio.create_task(PhotoshootJobService._cleanup_loop())
        await asyncio.sleep(0)
        await asyncio.sleep(0)
        task.cancel()
        await task

    assert task.done()
    assert sweep.call_count >= 1
