"""Coverage-completing tests for BatchExtractionService.

The sibling pipeline/reference/photo-cache tests cover the overlapped
extract -> generate flow with patched phases. These tests drive the real
orchestration internals: single-image extraction (persist source, VLM call,
retry, caching, failure/quotas, capacity skip), the avatar fetch, the
generation consumer's cancellation and dispatch guards, per-item generation
persistence/upload/failure branches, pipeline cleanup/cancellation paths,
and the extraction cache write.
"""

import asyncio
import base64
import io
from datetime import datetime, timezone
from unittest.mock import AsyncMock, MagicMock, Mock, patch
from uuid import uuid4

import pytest
from PIL import Image

from app.core.exceptions import AIServiceError
from app.services import batch_extraction_service as bes
from app.services.batch_extraction_service import BatchExtractionService
from app.services.batch_job_service import (
    BatchImageData,
    BatchJob,
    BatchJobService,
    BatchJobStatus,
    DetectedItemData,
)
from tests.utils.fake_db import FakeDB


def _make_photo_b64(size=(640, 480)) -> str:
    img = Image.new("RGB", size, (10, 20, 30))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=90)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _make_job(image_ids, auto_generate: bool = True) -> BatchJob:
    images = {
        iid: BatchImageData(image_id=iid, image_base64=_make_photo_b64(), filename=f"{iid}.jpg")
        for iid in image_ids
    }
    return BatchJob(
        job_id=str(uuid4()),
        user_id="u1",
        status=BatchJobStatus.PENDING,
        created_at=datetime.now(timezone.utc),
        auto_generate=auto_generate,
        generation_batch_size=30,
        images=images,
    )


async def _register(job: BatchJob) -> None:
    async with BatchJobService._lock:
        BatchJobService._jobs[job.job_id] = job


@pytest.fixture(autouse=True)
def _clear_job_store():
    BatchJobService._jobs.clear()
    yield
    BatchJobService._jobs.clear()


class _FakeGeneratedImage:
    def __init__(self, image_base64: str = "Z2VuZXJhdGVk"):
        self.image_base64 = image_base64


async def _call_once(fn, **kwargs):
    """with_retry replacement: run the operation exactly once, no sleeps."""
    return await fn()


def _make_extraction_agent(items):
    agent = MagicMock()
    agent.extract_multiple_items = AsyncMock(return_value={"items": items})
    return agent


class _FakeAvatarClient:
    def __init__(self, response=None, exc=None):
        self.response = response
        self.exc = exc

    async def __aenter__(self):
        return self

    async def __aexit__(self, *args):
        return False

    async def get(self, url, **kwargs):
        if self.exc is not None:
            raise self.exc
        return self.response


# ---------------------------------------------------------------------------
# _extract_single_image
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_extract_single_image_success_full_path():
    job = _make_job(["img-1"])
    await _register(job)
    items = [{"temp_id": "t1", "category": "tops", "colors": ["black"]}]
    agent = _make_extraction_agent(items)
    service = BatchExtractionService(user_id="u1", db=None)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    async def fake_upload(**kwargs):
        return {"image_url": "https://cdn/source.jpg", "storage_path": "u/source.jpg"}

    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch(
            "app.services.batch_extraction_service.StorageService.upload_source_image",
            new=fake_upload,
        ),
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ) as set_cached,
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        result = await service._extract_single_image(job, "img-1", _make_photo_b64(), agent)

    assert result == items
    assert job.detected_items[0].temp_id == "t1"
    assert job.detected_items[0].source_image_url == "https://cdn/source.jpg"
    assert job.images["img-1"].source_image_url == "https://cdn/source.jpg"
    assert job.extraction_completed == {"img-1"}
    # The finally block released the source payload immediately.
    assert job.images["img-1"].image_base64 == ""
    assert "image_extraction_complete" in events
    set_cached.assert_awaited_once()
    call_kwargs = agent.extract_multiple_items.await_args.kwargs
    assert call_kwargs["user_profile_image_base64"] is None


@pytest.mark.asyncio
async def test_extract_single_image_hard_failure_path():
    job = _make_job(["img-1"])
    await _register(job)
    agent = MagicMock()
    agent.extract_multiple_items = AsyncMock(
        side_effect=AIServiceError("bad prompt", retryable=False, error_kind="hard")
    )
    service = BatchExtractionService(user_id="u1", db=None)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        result = await service._extract_single_image(job, "img-1", _make_photo_b64(), agent)

    assert result == []
    assert job.extraction_failed["img-1"] == "bad prompt"
    assert "image_extraction_failed" in events
    assert "extraction_capacity_exhausted" not in events
    assert service._extraction_capacity_exhausted is False
    assert job.images["img-1"].image_base64 == ""


@pytest.mark.asyncio
async def test_extract_single_image_upstream_quota_skips_remaining_images():
    """A first image failing with upstream_quota sets the capacity flag; the
    next image is skipped without another VLM call."""
    job = _make_job(["img-1", "img-2"])
    await _register(job)
    agent = MagicMock()
    agent.extract_multiple_items = AsyncMock(
        side_effect=AIServiceError(
            "quota", retryable=True, error_kind="upstream_quota", retry_after_seconds=30
        )
    )
    service = BatchExtractionService(user_id="u1", db=None)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        first = await service._extract_single_image(job, "img-1", _make_photo_b64(), agent)
        assert first == []
        assert service._extraction_capacity_exhausted is True
        assert "extraction_capacity_exhausted" in events
        agent.extract_multiple_items.reset_mock()
        second = await service._extract_single_image(job, "img-2", _make_photo_b64(), agent)

    assert second == []
    assert job.extraction_failed["img-2"].startswith("Skipped: AI service capacity exhausted")
    agent.extract_multiple_items.assert_not_awaited()


@pytest.mark.asyncio
async def test_extract_single_image_tolerates_upload_and_enqueue_errors():
    job = _make_job(["img-1"])
    await _register(job)
    agent = _make_extraction_agent([{"temp_id": "t1", "category": "tops"}])
    service = BatchExtractionService(user_id="u1", db=None)

    async def on_items_ready(items):
        raise RuntimeError("enqueue failed")

    async def raise_upload(image_id, image_base64):
        raise RuntimeError("upload failed")

    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(BatchExtractionService, "_persist_source_image", new=raise_upload),
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        result = await service._extract_single_image(
            job, "img-1", _make_photo_b64(), agent, on_items_ready=on_items_ready
        )

    assert result[0]["temp_id"] == "t1"
    assert job.detected_items[0].temp_id == "t1"


@pytest.mark.asyncio
async def test_extract_single_image_cancelled_job_returns_early():
    job = _make_job(["img-1"])
    await _register(job)
    job.cancelled = True
    agent = _make_extraction_agent([])
    service = BatchExtractionService(user_id="u1", db=None)

    result = await service._extract_single_image(job, "img-1", "b64", agent)

    assert result == []
    agent.extract_multiple_items.assert_not_awaited()


@pytest.mark.asyncio
async def test_extract_single_image_aborts_when_consumer_dead():
    job = _make_job(["img-1"])
    await _register(job)

    async def dead_consumer():
        raise RuntimeError("consumer crashed")

    consumer_task = asyncio.create_task(dead_consumer())
    await asyncio.sleep(0)
    service = BatchExtractionService(user_id="u1", db=None)

    with pytest.raises(RuntimeError, match="Generation consumer failed"):
        await service._extract_single_image(
            job, "img-1", "b64", MagicMock(), consumer_task=consumer_task
        )


@pytest.mark.asyncio
async def test_extract_single_image_cancelled_inside_semaphore(monkeypatch):
    """A cancellation that lands while the task waits on the extraction
    semaphore is honored by the in-semaphore check."""
    job = _make_job(["img-1"])
    await _register(job)
    monkeypatch.setattr(bes, "EXTRACTION_SEMAPHORE", asyncio.Semaphore(1))
    agent = _make_extraction_agent([])
    service = BatchExtractionService(user_id="u1", db=None)

    await bes.EXTRACTION_SEMAPHORE.acquire()
    task = asyncio.create_task(
        service._extract_single_image(job, "img-1", "b64", agent)
    )
    await asyncio.sleep(0)
    job.cancelled = True
    job.cancel_event.set()
    bes.EXTRACTION_SEMAPHORE.release()

    result = await task
    assert result == []
    agent.extract_multiple_items.assert_not_awaited()


@pytest.mark.asyncio
async def test_extract_single_image_capacity_recheck_skips_image():
    """The pre-call capacity re-check (inside the semaphore, after the entry
    check) marks the image skipped without a VLM call."""
    job = _make_job(["img-1"])
    await _register(job)
    agent = MagicMock()
    agent.extract_multiple_items = AsyncMock(return_value={"items": []})
    service = BatchExtractionService(user_id="u1", db=None)
    # First call (semaphore entry) passes; the re-check right before the VLM
    # call sees the flag and skips.
    with patch.object(
        service, "_skip_due_to_capacity", AsyncMock(side_effect=[False, True])
    ):
        result = await service._extract_single_image(job, "img-1", "b64", agent)
    assert result == []
    agent.extract_multiple_items.assert_not_awaited()


@pytest.mark.asyncio
async def test_extract_single_image_skips_source_persist_without_bytes():
    """No source bytes means no storage upload; extraction still proceeds."""
    job = _make_job(["img-1"])
    await _register(job)
    items = [{"temp_id": "t1", "category": "tops"}]
    agent = _make_extraction_agent(items)
    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(BatchExtractionService, "_persist_source_image", AsyncMock()) as persist,
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        result = await service._extract_single_image(job, "img-1", "", agent)
    assert result == items
    persist.assert_not_awaited()
    assert job.images["img-1"].source_image_url is None


@pytest.mark.asyncio
async def test_extract_single_image_multi_image_job_skips_cache():
    """The extraction cache is single-image only: a multi-image job skips it."""
    job = _make_job(["img-1", "img-2"])
    await _register(job)
    items = [{"temp_id": "t1", "category": "tops"}]
    agent = _make_extraction_agent(items)
    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(
            BatchExtractionService,
            "_persist_source_image",
            AsyncMock(return_value={"image_url": "https://cdn/s.jpg", "storage_path": "u/s.jpg"}),
        ),
        patch(
            "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
            new=AsyncMock(),
        ) as set_cached,
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        result = await service._extract_single_image(job, "img-1", _make_photo_b64(), agent)
    assert result == items
    set_cached.assert_not_awaited()


# ---------------------------------------------------------------------------
# run_pipeline
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_run_pipeline_completes_and_tolerates_queue_put_error():
    """The sentinel put in stop_consumer is best-effort: a closed queue must
    not fail the job (and the pipeline still completes normally)."""
    job = _make_job(["img-1"], auto_generate=True)
    await _register(job)

    class _RaisingQueue:
        def __init__(self):
            self.items = []

        async def put(self, item):
            if item is None:
                raise RuntimeError("queue closed")
            self.items.append(item)

        async def get(self):
            return None

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        # Empty item batches must never be enqueued for generation.
        await on_items_ready([])

    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch("app.services.batch_extraction_service.asyncio.Queue", _RaisingQueue),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.COMPLETED
    assert "job_complete" in events


@pytest.mark.asyncio
async def test_run_pipeline_failure_without_consumer_reports_phase_error():
    """With auto_generate off there is no consumer task: a phase failure still
    fails the job with the phase's own error message."""
    job = _make_job(["img-1"], auto_generate=False)
    await _register(job)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        raise RuntimeError("phase died")

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.FAILED
    assert job.error_message == "phase died"
    assert "job_failed" in events


@pytest.mark.asyncio
async def test_run_pipeline_without_generation_enqueue_is_noop():
    job = _make_job(["img-1"], auto_generate=False)
    await _register(job)

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        # gen_queue is None when auto_generate is off: the enqueue no-ops.
        await on_items_ready(
            [DetectedItemData(temp_id="t1", image_id="img-1", category="tops")]
        )

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.COMPLETED


@pytest.mark.asyncio
async def test_run_pipeline_cancelled_job_skips_terminal_flush():
    job = _make_job(["img-1"], auto_generate=True)
    await _register(job)

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        await BatchJobService.update_status(job_arg.job_id, BatchJobStatus.EXTRACTING)
        added = await BatchJobService.add_detected_items(
            job_arg.job_id, "img-1", [{"temp_id": "t1", "category": "tops"}]
        )
        job_arg.cancelled = True
        job_arg.cancel_event.set()
        await on_items_ready(added)

    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.EXTRACTING  # terminal flush skipped
    assert job.cancelled is True
    assert "job_complete" not in events


@pytest.mark.asyncio
async def test_run_pipeline_cancellation_propagates():
    """Task cancellation stops the consumer (cancelling its in-flight work)
    and frees generated payloads before re-raising."""
    job = _make_job(["img-1"], auto_generate=True)
    await _register(job)
    hold = asyncio.Event()

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        await hold.wait()

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        task = asyncio.create_task(service.run_pipeline(job))
        await asyncio.sleep(0)
        await asyncio.sleep(0)
        task.cancel()
        with pytest.raises(asyncio.CancelledError):
            await task
    assert job.status == BatchJobStatus.PENDING


@pytest.mark.asyncio
async def test_run_pipeline_merges_consumer_exception_into_error():
    """When the extraction phase itself fails and the generation consumer
    also crashed, both root causes surface in the job error."""
    job = _make_job(["img-1"], auto_generate=True)
    await _register(job)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    async def fake_phase(self, job_arg, consumer_task=None, on_items_ready=None):
        added = await BatchJobService.add_detected_items(
            job_arg.job_id, "img-1", [{"temp_id": "t1", "category": "tops"}]
        )
        await on_items_ready(added)
        # Let the consumer run so it dies on the agent factory before we fail.
        await asyncio.sleep(0)
        raise RuntimeError("phase died")

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_run_extraction_phase", fake_phase),
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(side_effect=AIServiceError("agent boom", retryable=False)),
        ),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.FAILED
    assert "job_failed" in events
    assert "phase died" in job.error_message
    assert "generation consumer also failed: agent boom" in job.error_message


@pytest.mark.asyncio
async def test_run_pipeline_surfaces_consumer_crash_after_extraction_phase():
    """A generation consumer that dies mid-pipeline is surfaced by the
    extraction phase's end-of-phase check and fails the job."""
    job = _make_job(["img-1"], auto_generate=True)
    await _register(job)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    async def fake_extract(self, job_arg, image_id, image_base64, agent, **kwargs):
        on_items_ready = kwargs.get("on_items_ready")
        added = await BatchJobService.add_detected_items(
            job_arg.job_id, image_id, [{"temp_id": "t1", "category": "tops"}]
        )
        if on_items_ready:
            await on_items_ready(added)
        # Give the consumer a chance to process the batch and die.
        await asyncio.sleep(0)
        return added

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_extract_single_image", fake_extract),
        patch.object(
            BatchExtractionService, "_fetch_user_avatar_base64", AsyncMock(return_value=None)
        ),
        patch(
            "app.services.batch_extraction_service.get_item_extraction_agent",
            AsyncMock(return_value=MagicMock()),
        ),
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(side_effect=AIServiceError("agent boom", retryable=False)),
        ),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        await service.run_pipeline(job)

    assert job.status == BatchJobStatus.FAILED
    assert "agent boom" in job.error_message
    assert "job_failed" in events
    assert "job_complete" not in events


# ---------------------------------------------------------------------------
# _generation_consumer
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_generation_consumer_exits_immediately_when_cancelled():
    job = _make_job(["img-1"])
    await _register(job)
    job.cancelled = True
    service = BatchExtractionService(user_id="u1", db=None)

    await service._generation_consumer(job, asyncio.Queue())


@pytest.mark.asyncio
async def test_generation_consumer_discards_batch_when_cancelled_midstream():
    """A cancellation landing between the queue-get and the batch dispatch
    discards the batch without generating."""
    job = _make_job(["img-1"])
    await _register(job)
    await BatchJobService.add_detected_items(
        job.job_id, "img-1", [{"temp_id": "a", "category": "tops"}]
    )

    class _CancelOnFirstGet:
        def __init__(self, target):
            self.target = target
            self.first = True

        async def get(self):
            if self.first:
                self.first = False
                self.target.cancelled = True
                self.target.cancel_event.set()
                return list(self.target.detected_items)
            return None

    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch.object(BatchExtractionService, "_generate_single_item", AsyncMock()) as generate,
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(return_value=object()),
        ),
    ):
        await service._generation_consumer(job, _CancelOnFirstGet(job))
    # The batch must be discarded without generating anything.
    generate.assert_not_awaited()


@pytest.mark.asyncio
async def test_generation_consumer_stops_dispatching_when_cancelled():
    """A cancellation landing mid-dispatch stops dispatching remaining items
    (the first item was already handed to a generation task)."""
    job = _make_job(["img-1"])
    await _register(job)
    await BatchJobService.add_detected_items(
        job.job_id,
        "img-1",
        [
            {"temp_id": "a", "category": "tops", "source_image_url": "https://cdn/a.jpg"},
            {"temp_id": "b", "category": "bottoms", "source_image_url": "https://cdn/b.jpg"},
        ],
    )
    dispatched = []

    async def fake_download(url, **kwargs):
        job.cancelled = True
        job.cancel_event.set()
        return f"ref:{url}"

    async def fake_generate(self, job_arg, item, agent, reference_image_base64):
        dispatched.append(item.temp_id)
        return None

    service = BatchExtractionService(user_id="u1", db=None)
    queue = asyncio.Queue()
    with (
        patch(
            "app.services.batch_extraction_service.StorageService.download_and_downscale_to_base64",
            fake_download,
        ),
        patch.object(BatchExtractionService, "_generate_single_item", fake_generate),
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(return_value=object()),
        ),
    ):
        consumer = asyncio.create_task(service._generation_consumer(job, queue))
        await queue.put(list(job.detected_items))
        await queue.put(None)
        await consumer

    assert dispatched == ["a"]


@pytest.mark.asyncio
async def test_generation_consumer_cancel_waits_for_in_flight():
    """Cancelling the consumer cancels its in-flight generation tasks and
    awaits them before unwinding."""
    job = _make_job(["img-1"])
    await _register(job)
    await BatchJobService.add_detected_items(
        job.job_id,
        "img-1",
        [{"temp_id": "a", "category": "tops"}, {"temp_id": "b", "category": "bottoms"}],
    )
    gate = asyncio.Event()
    started = asyncio.Event()

    async def fake_generate(self, job_arg, item, agent, reference_image_base64):
        started.set()
        await gate.wait()
        return None

    service = BatchExtractionService(user_id="u1", db=None)
    queue = asyncio.Queue()
    with (
        patch.object(BatchExtractionService, "_generate_single_item", fake_generate),
        patch(
            "app.services.batch_extraction_service.get_image_generation_agent",
            AsyncMock(return_value=object()),
        ),
    ):
        consumer = asyncio.create_task(service._generation_consumer(job, queue))
        await queue.put(list(job.detected_items))
        await started.wait()
        consumer.cancel()
        with pytest.raises(asyncio.CancelledError):
            await consumer

    assert not gate.is_set()


# ---------------------------------------------------------------------------
# _generate_single_item
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_generate_single_item_cancelled_guards():
    job = _make_job(["img-1"])
    await _register(job)
    item = DetectedItemData(temp_id="t1", image_id="img-1", category="tops")
    agent = MagicMock()
    service = BatchExtractionService(user_id="u1", db=None)

    job.cancelled = True
    assert await service._generate_single_item(job, item, agent, None) is None
    agent.generate_product_image.assert_not_called()

    job.cancelled = False
    job.cancel_event.clear()

    class _CancelOnEnter:
        def __init__(self, target):
            self.target = target

        async def __aenter__(self):
            self.target.cancelled = True
            self.target.cancel_event.set()
            return self

        async def __aexit__(self, *args):
            return False

    with patch.object(bes, "image_gen_slot", lambda: _CancelOnEnter(job)):
        assert await service._generate_single_item(job, item, agent, None) is None
    agent.generate_product_image.assert_not_called()


@pytest.mark.asyncio
async def test_generate_single_item_description_variants():
    job = _make_job(["img-1"])
    await _register(job)
    service = BatchExtractionService(user_id="u1", db=None)
    captured = []

    async def fake_generate(**kwargs):
        captured.append(kwargs)
        return _FakeGeneratedImage()

    agent = MagicMock()
    agent.generate_product_image = fake_generate

    cases = [
        (
            DetectedItemData(
                temp_id="a",
                image_id="img-1",
                category="tops",
                sub_category="tee",
                colors=["black"],
                source_image_url="https://cdn/x.jpg",
            ),
            "black tee",
        ),
        (DetectedItemData(temp_id="b", image_id="img-1", category="tops", colors=["black"]), "black tops"),
        (DetectedItemData(temp_id="c", image_id="img-1", category="tops"), "tops"),
        (DetectedItemData(temp_id="d", image_id="img-1", category=None), None),
        (
            DetectedItemData(
                temp_id="e",
                image_id="img-1",
                category="bottoms",
                detailed_description="red pants",
            ),
            "red pants",
        ),
    ]
    with (
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
        patch.object(BatchJobService, "update_item_generation", AsyncMock()),
    ):
        for item, _expected in cases:
            job.detected_items = [item]
            await service._generate_single_item(job, item, agent, None)

    assert [call["item_description"] for call in captured] == [
        "black tee",
        "black tops",
        "tops",
        None,
        "red pants",
    ]
    # A source URL with no available bytes still degrades to text-only.
    assert all(call["reference_image"] is None for call in captured)


@pytest.mark.asyncio
async def test_generate_single_item_passes_reference_through():
    """A single-item photo reference passes through resolve unchanged."""
    job = _make_job(["img-1"])
    await _register(job)
    item = DetectedItemData(temp_id="t1", image_id="img-1", category="tops")
    job.detected_items = [item]
    captured = {}

    async def fake_generate(**kwargs):
        captured.update(kwargs)
        return _FakeGeneratedImage()

    agent = MagicMock()
    agent.generate_product_image = fake_generate
    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
        patch.object(BatchJobService, "update_item_generation", AsyncMock()),
    ):
        await service._generate_single_item(job, item, agent, "photo-ref-b64")

    assert captured["reference_image"] == "photo-ref-b64"


@pytest.mark.asyncio
async def test_generate_single_item_persists_generated_image():
    job = _make_job(["img-1"])
    job.persistence_db = object()
    await _register(job)
    item = DetectedItemData(temp_id="t1", image_id="img-1", category="tops", colors=["black"])
    job.detected_items = [item]
    agent = MagicMock()
    agent.generate_product_image = AsyncMock(
        return_value=_FakeGeneratedImage("data:image/webp;base64,ZmFrZQ==")
    )
    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch(
            "app.services.batch_extraction_service.StorageService.upload_temp_generated_image",
            new=AsyncMock(return_value={"image_url": "https://cdn/gen.webp"}),
        ),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        result = await service._generate_single_item(job, item, agent, None)

    assert result == "data:image/webp;base64,ZmFrZQ=="
    assert item.generated_image_url == "https://cdn/gen.webp"
    assert item.status == "generated"


@pytest.mark.asyncio
async def test_generate_single_item_upload_failure_keeps_base64():
    job = _make_job(["img-1"])
    job.persistence_db = object()
    await _register(job)
    item = DetectedItemData(temp_id="t1", image_id="img-1", category="tops")
    job.detected_items = [item]
    agent = MagicMock()
    agent.generate_product_image = AsyncMock(return_value=_FakeGeneratedImage())
    service = BatchExtractionService(user_id="u1", db=None)
    with (
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch(
            "app.services.batch_extraction_service.StorageService.upload_temp_generated_image",
            new=AsyncMock(side_effect=RuntimeError("upload failed")),
        ),
        patch.object(BatchJobService, "broadcast_event", AsyncMock()),
    ):
        result = await service._generate_single_item(job, item, agent, None)

    assert result == "Z2VuZXJhdGVk"
    assert item.generated_image_url is None
    assert item.generated_image_base64 == "Z2VuZXJhdGVk"


@pytest.mark.asyncio
async def test_generate_single_item_generation_failure():
    job = _make_job(["img-1"])
    await _register(job)
    item = DetectedItemData(temp_id="t1", image_id="img-1", category="tops")
    job.detected_items = [item]
    agent = MagicMock()
    agent.generate_product_image = AsyncMock(side_effect=RuntimeError("gen failed"))
    service = BatchExtractionService(user_id="u1", db=None)
    events = []

    async def record(job_id, event_type, data):
        events.append(event_type)

    with (
        patch("app.services.batch_extraction_service.with_retry", new=_call_once),
        patch.object(BatchJobService, "broadcast_event", record),
    ):
        result = await service._generate_single_item(job, item, agent, None)

    assert result is None
    assert item.status == "failed"
    assert item.generation_error == "gen failed"
    assert job.generation_failed == {"t1": "gen failed"}
    assert "item_generation_failed" in events


# ---------------------------------------------------------------------------
# _cache_extraction_results
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cache_extraction_results_paths():
    service = BatchExtractionService(user_id="u1", db=None)
    job = _make_job(["img-1"])
    job.detected_items = [DetectedItemData(temp_id="t1", image_id="img-1", category="tops")]

    with patch(
        "app.services.extraction_cache_service.ExtractionCacheService.set_cached_result",
        new=AsyncMock(),
    ) as set_cached:
        await service._cache_extraction_results(job)
        set_cached.assert_awaited_once()

        empty = _make_job(["img-1"])
        empty.images = {}
        await service._cache_extraction_results(empty)

        no_b64 = _make_job(["img-1"])
        no_b64.images["img-1"].image_base64 = ""
        await service._cache_extraction_results(no_b64)

        set_cached.side_effect = RuntimeError("cache down")
        await service._cache_extraction_results(job)  # must not raise


# ---------------------------------------------------------------------------
# _fetch_user_avatar_base64 / _persist_source_image
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_fetch_user_avatar_base64_paths():
    service = BatchExtractionService(
        user_id="u1",
        db=FakeDB(rows={"users": [{"id": "u1", "avatar_url": "https://cdn.test/avatar.png"}]}),
    )
    response = Mock(content=b"raw-avatar", raise_for_status=Mock())
    with patch(
        "app.services.batch_extraction_service.httpx.AsyncClient",
        return_value=_FakeAvatarClient(response=response),
    ):
        result = await service._fetch_user_avatar_base64()
    assert result == base64.b64encode(b"raw-avatar").decode()

    # No user row.
    no_user = BatchExtractionService(user_id="u1", db=FakeDB())
    assert await no_user._fetch_user_avatar_base64() is None

    # Row without avatar_url.
    no_url = BatchExtractionService(
        user_id="u1", db=FakeDB(rows={"users": [{"id": "u1", "avatar_url": None}]})
    )
    assert await no_url._fetch_user_avatar_base64() is None

    # Timeout is swallowed.
    timed_out = BatchExtractionService(
        user_id="u1",
        db=FakeDB(rows={"users": [{"id": "u1", "avatar_url": "https://cdn.test/a.png"}]}),
    )
    with patch(
        "app.services.batch_extraction_service.httpx.AsyncClient",
        return_value=_FakeAvatarClient(exc=asyncio.TimeoutError()),
    ):
        assert await timed_out._fetch_user_avatar_base64() is None

    # Generic failures are swallowed too.
    class _BrokenDb:
        def table(self, name):
            raise RuntimeError("db down")

    broken = BatchExtractionService(user_id="u1", db=_BrokenDb())
    assert await broken._fetch_user_avatar_base64() is None


@pytest.mark.asyncio
async def test_persist_source_image_empty_and_data_url():
    service = BatchExtractionService(user_id="u1", db=None)
    assert await service._persist_source_image("img-1", "") is None

    captured = {}

    async def fake_upload(**kwargs):
        captured.update(kwargs)
        return {"image_url": "https://cdn/s.jpg", "storage_path": "u/s.jpg"}

    with patch(
        "app.services.batch_extraction_service.StorageService.upload_source_image",
        new=fake_upload,
    ):
        result = await service._persist_source_image("img-1", "data:image/jpeg;base64,ZmFrZQ==")

    assert result == {"image_url": "https://cdn/s.jpg", "storage_path": "u/s.jpg"}
    assert captured["file_data"] == b"fake"
