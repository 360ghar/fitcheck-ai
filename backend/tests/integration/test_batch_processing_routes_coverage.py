"""Route-level coverage for app/api/v1/batch_processing.py.

Follows the house convention of calling route functions directly with fakes
(no TestClient, no network): the shared FakeDB stands in for Supabase, service
methods are patched with AsyncMock, and SSE generators are driven by stubbing
``EventSourceResponse`` (same pattern as tests/integration/test_sse_error_paths.py).

Deliberately does NOT re-cover what tests/unit/test_services/test_batch_*.py,
tests/unit/test_services/test_pipeline_task_refs.py and
tests/integration/test_sse_error_paths.py already own; this file targets the
route-level branches they miss: quota-admission failure compensation, multipart
validation/release paths, SSE stream/heartbeat/cancel branches, cancel/status
endpoints, and the single-extract cache + pipeline paths.
"""

import asyncio
import base64
import io
import json
from datetime import datetime, timezone

from unittest.mock import AsyncMock, Mock

import pytest
from fastapi import HTTPException
from PIL import Image

from app.api.v1 import batch_processing as bp
from app.core.exceptions import (
    InvalidInputError,
    RateLimitError,
    UnsupportedMediaTypeError,
)
from app.models.subscription import OperationType
from app.services.ai_settings_service import AISettingsService
from app.services.batch_extraction_service import BatchExtractionService
from app.services.batch_job_service import BatchJob, BatchJobService, BatchJobStatus
from app.services.extraction_cache_service import ExtractionCacheService
from app.utils import maybe_single_data

USER_ID = "11111111-1111-1111-1111-111111111111"
JOB_ID = "22222222-2222-2222-2222-222222222222"


def _png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), "white").save(buffer, format="PNG")
    return buffer.getvalue()


def _png_b64() -> str:
    return base64.b64encode(_png_bytes()).decode("ascii")


def _make_job(status: BatchJobStatus = BatchJobStatus.PENDING) -> BatchJob:
    job = BatchJob(
        job_id=JOB_ID,
        user_id=USER_ID,
        status=status,
        created_at=datetime.now(timezone.utc),
    )
    return job


class _FakeUpload:
    """Stand-in for fastapi UploadFile (capped reads in 1MB chunks)."""

    def __init__(self, data: bytes, filename: str = "a.png", content_type: str = "image/png"):
        self._data = data
        self.filename = filename
        self.content_type = content_type

    async def read(self, size: int = -1) -> bytes:
        if size is None or size < 0:
            out, self._data = self._data, b""
            return out
        out, self._data = self._data[:size], self._data[size:]
        return out

    async def seek(self, offset: int) -> None:
        assert offset == 0


class _CapturingESR:
    """Stand-in for EventSourceResponse that captures the generator."""

    def __init__(self, content, *args, **kwargs):
        self.content = content


async def _drain(generator, cap: int = 25):
    """Collect yielded events, capping iterations so a broken error path
    (infinite heartbeat loop) cannot hang the test suite."""
    events = []
    try:
        async for event in generator:
            events.append(event)
            if len(events) >= cap:
                break
    finally:
        await generator.aclose()
    return events


def _event_types(events):
    return [e.get("event") for e in events]


def _discard_pipeline(coro, tasks):
    """spawn_background_task stand-in: never run the real pipeline."""
    coro.close()


def _patch_pipeline(monkeypatch):
    monkeypatch.setattr(bp, "spawn_background_task", _discard_pipeline)
    monkeypatch.setattr(BatchExtractionService, "run_pipeline", AsyncMock())


# ---------------------------------------------------------------------------
# POST /batch-extract (JSON)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_start_batch_extraction_json_success(monkeypatch):
    """Happy path: reserves quota through the real admission helper, creates a
    job, spawns the pipeline and returns the 202 envelope."""
    from app.api.v1.batch_processing import BatchExtractionRequest, BatchImageInput

    request = BatchExtractionRequest(images=[BatchImageInput(image_id="img-1", image_base64=_png_b64())])
    job = _make_job()
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    _patch_pipeline(monkeypatch)

    result = await bp.start_batch_extraction(request, user_id=USER_ID, db=Mock())

    assert result.job_id == JOB_ID
    assert result.status == "pending"
    assert result.total_images == 1
    assert result.sse_url == f"/api/v1/ai/batch-extract/{JOB_ID}/events"
    assert result.message == "Batch extraction started for 1 images"
    assert AISettingsService.reserve_usage.await_count == 2  # extraction + generation


@pytest.mark.asyncio
async def test_start_batch_extraction_propagates_http_exception(monkeypatch):
    request = Mock(images=[Mock(model_dump=Mock(return_value={"image_id": "i", "image_base64": "x"}))])
    monkeypatch.setattr(bp, "_start_batch_job", AsyncMock(side_effect=HTTPException(status_code=404, detail="nope")))

    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction(request, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 404


@pytest.mark.asyncio
async def test_start_batch_extraction_propagates_fitcheck_exception(monkeypatch):
    request = Mock(images=[Mock(model_dump=Mock(return_value={"image_id": "i", "image_base64": "x"}))])
    monkeypatch.setattr(bp, "_start_batch_job", AsyncMock(side_effect=RateLimitError("nope")))

    with pytest.raises(RateLimitError):
        await bp.start_batch_extraction(request, user_id=USER_ID, db=Mock())


@pytest.mark.asyncio
async def test_start_batch_extraction_generic_error_returns_500(monkeypatch):
    request = Mock(images=[Mock(model_dump=Mock(return_value={"image_id": "i", "image_base64": "x"}))])
    monkeypatch.setattr(bp, "_start_batch_job", AsyncMock(side_effect=RuntimeError("boom")))

    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction(request, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 500
    assert exc.value.detail == "Failed to start batch extraction"


# ---------------------------------------------------------------------------
# _start_batch_job guards + compensation
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_start_batch_job_rejects_empty_and_oversized_batches():
    with pytest.raises(HTTPException) as empty:
        await bp._start_batch_job(
            user_id=USER_ID, db=Mock(), images_data=[], auto_generate=False, generation_batch_size=1
        )
    assert empty.value.status_code == 400
    assert empty.value.detail == "At least one image is required"

    many = [{"image_id": f"img-{i}", "image_base64": "x"} for i in range(51)]
    with pytest.raises(HTTPException) as too_many:
        await bp._start_batch_job(
            user_id=USER_ID, db=Mock(), images_data=many, auto_generate=False, generation_batch_size=1
        )
    assert too_many.value.status_code == 400
    assert "Maximum 50 images per batch" in too_many.value.detail


@pytest.mark.asyncio
async def test_start_batch_job_releases_reservations_when_job_creation_fails(monkeypatch):
    """Admission succeeded but create_job failed: the reserved capacity must be
    returned before the failure surfaces (both explicit and inferred quota)."""
    released = []

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(side_effect=RuntimeError("db down")))

    with pytest.raises(RuntimeError, match="db down"):
        await bp._start_batch_job(
            user_id=USER_ID,
            db=Mock(),
            images_data=[{"image_id": "img-1", "image_base64": "x"}],
            auto_generate=True,
            generation_batch_size=1,
            reservations={"extraction": 1, "generation": 3},
        )
    assert sorted(released) == sorted([(OperationType.EXTRACTION, 1), (OperationType.GENERATION, 3)])


@pytest.mark.asyncio
async def test_start_batch_job_releases_inferred_reservations_on_failure(monkeypatch):
    """reservations=None -> the admission helper runs inside; a later failure
    still compensates what was reserved."""
    released = []

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(side_effect=RuntimeError("db down")))

    with pytest.raises(RuntimeError, match="db down"):
        await bp._start_batch_job(
            user_id=USER_ID,
            db=Mock(),
            images_data=[{"image_id": "img-1", "image_base64": "x"}],
            auto_generate=True,
            generation_batch_size=1,
        )
    assert sorted(released) == sorted([(OperationType.EXTRACTION, 1), (OperationType.GENERATION, 3)])


# ---------------------------------------------------------------------------
# _check_batch_rate_limits admission matrix
# ---------------------------------------------------------------------------


def _reserve_side_effect(*, operation_type, **_kwargs):
    return True


@pytest.mark.asyncio
async def test_check_batch_rate_limits_extraction_only_admitted(monkeypatch):
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))

    result = await bp._check_batch_rate_limits(
        user_id=USER_ID, db=Mock(), total_images=2, auto_generate=False
    )

    assert result == {"extraction": 2}


@pytest.mark.asyncio
async def test_check_batch_rate_limits_extraction_only_rejected(monkeypatch):
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=False))

    with pytest.raises(RateLimitError, match="Daily extraction limit"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=2, auto_generate=False
        )


@pytest.mark.asyncio
async def test_check_batch_rate_limits_releases_generation_when_extraction_fails(monkeypatch):
    """Extraction reservation raised -> generation (the winner of the race) is
    compensated and the original exception is re-raised, never masked."""
    released = []

    async def reserve_usage(*, operation_type, **_kwargs):
        if operation_type == OperationType.EXTRACTION:
            raise RuntimeError("quota rpc down")
        return True

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve_usage)
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)

    with pytest.raises(RuntimeError, match="quota rpc down"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=2, auto_generate=True
        )
    assert released == [(OperationType.GENERATION, 6)]


@pytest.mark.asyncio
async def test_check_batch_rate_limits_releases_extraction_when_generation_fails(monkeypatch):
    released = []

    async def reserve_usage(*, operation_type, **_kwargs):
        if operation_type == OperationType.GENERATION:
            raise RuntimeError("quota rpc down")
        return True

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve_usage)
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)

    with pytest.raises(RuntimeError, match="quota rpc down"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=2, auto_generate=True
        )
    assert released == [(OperationType.EXTRACTION, 2)]


@pytest.mark.asyncio
async def test_check_batch_rate_limits_both_rejected_raises_extraction_error(monkeypatch):
    """Both reservations failed: nothing to release, plain RateLimitError."""
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=False))
    release = AsyncMock()
    monkeypatch.setattr(AISettingsService, "release_usage", release)

    with pytest.raises(RateLimitError, match="Daily extraction limit"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=2, auto_generate=True
        )
    release.assert_not_awaited()


@pytest.mark.asyncio
async def test_check_batch_rate_limits_generation_rejected_has_user_facing_message(monkeypatch):
    """Extraction ok + generation rejected -> the user-facing message, not the
    developer hint (observed 2026-08-03 leak fix)."""
    released = []

    async def reserve_usage(*, operation_type, **_kwargs):
        return operation_type == OperationType.EXTRACTION

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve_usage)
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)

    with pytest.raises(RateLimitError, match="more AI generations than you have left"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=3, auto_generate=True
        )
    assert released == [(OperationType.EXTRACTION, 3)]


@pytest.mark.asyncio
async def test_check_batch_rate_limits_both_admitted_includes_generation(monkeypatch):
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))

    result = await bp._check_batch_rate_limits(
        user_id=USER_ID, db=Mock(), total_images=3, auto_generate=True
    )

    assert result == {"extraction": 3, "generation": 9}


@pytest.mark.asyncio
async def test_check_batch_rate_limits_release_failure_is_best_effort(monkeypatch):
    """A failing release RPC must not mask the original admission error."""
    async def reserve_usage(*, operation_type, **_kwargs):
        return operation_type == OperationType.EXTRACTION

    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve_usage)
    monkeypatch.setattr(AISettingsService, "release_usage", AsyncMock(side_effect=RuntimeError("release down")))

    with pytest.raises(RateLimitError, match="more AI generations"):
        await bp._check_batch_rate_limits(
            user_id=USER_ID, db=Mock(), total_images=2, auto_generate=True
        )


# ---------------------------------------------------------------------------
# POST /batch-extract-multipart
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_multipart_requires_at_least_one_file():
    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction_multipart(files=[], user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 400
    assert "At least one file" in exc.value.detail


@pytest.mark.asyncio
async def test_multipart_rejects_more_than_max_files():
    files = [_FakeUpload(_png_bytes()) for _ in range(51)]
    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction_multipart(files=files, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 400
    assert "Maximum 50 images per batch" in exc.value.detail


@pytest.mark.asyncio
async def test_multipart_image_ids_parse_failure_falls_back_to_csv(monkeypatch):
    """Non-JSON image_ids degrade to the comma-separated fallback, and the ids
    are passed through to the job."""
    job = _make_job()
    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value={"extraction": 2}))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    _patch_pipeline(monkeypatch)

    files = [_FakeUpload(_png_bytes()), _FakeUpload(_png_bytes())]
    result = await bp.start_batch_extraction_multipart(
        files=files, image_ids="a, b", auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
    )

    assert result.job_id == JOB_ID
    images = BatchJobService.create_job.await_args.kwargs["images"]
    assert [img["image_id"] for img in images] == ["a", "b"]


@pytest.mark.asyncio
async def test_multipart_image_ids_must_be_a_json_array(monkeypatch):
    files = [_FakeUpload(_png_bytes())]
    with pytest.raises(InvalidInputError, match="JSON array"):
        await bp.start_batch_extraction_multipart(
            files=files, image_ids='{"a": 1}', auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_multipart_image_ids_length_must_match_files(monkeypatch):
    files = [_FakeUpload(_png_bytes())]
    with pytest.raises(InvalidInputError, match="length"):
        await bp.start_batch_extraction_multipart(
            files=files, image_ids='["x", "y"]', auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_multipart_image_ids_must_be_unique(monkeypatch):
    files = [_FakeUpload(_png_bytes()), _FakeUpload(_png_bytes())]
    with pytest.raises(InvalidInputError, match="unique"):
        await bp.start_batch_extraction_multipart(
            files=files, image_ids='["x", "x"]', auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_multipart_rejects_non_image_content_type_and_releases_quota(monkeypatch):
    """A pre-buffer reservation must be compensated when buffering fails."""
    released = []

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value={"extraction": 1}))
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)

    upload = _FakeUpload(b"junk", filename="notes.txt", content_type="text/plain")
    with pytest.raises(UnsupportedMediaTypeError, match="Unsupported content type at index 0"):
        await bp.start_batch_extraction_multipart(
            files=[upload], image_ids=None, auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )
    assert released == [(OperationType.EXTRACTION, 1)]


@pytest.mark.asyncio
async def test_multipart_rejects_empty_file(monkeypatch):
    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value={"extraction": 1}))
    monkeypatch.setattr(AISettingsService, "release_usage", AsyncMock())

    upload = _FakeUpload(b"", filename="empty.png", content_type="image/png")
    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction_multipart(
            files=[upload], image_ids=None, auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )
    assert exc.value.status_code == 400
    assert "Empty file at index 0" in exc.value.detail


@pytest.mark.asyncio
async def test_multipart_rejects_invalid_image_bytes(monkeypatch):
    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value={"extraction": 1}))
    monkeypatch.setattr(AISettingsService, "release_usage", AsyncMock())

    upload = _FakeUpload(b"not-an-image", filename="a.png", content_type="image/png")
    with pytest.raises(UnsupportedMediaTypeError, match="Invalid image at index 0"):
        await bp.start_batch_extraction_multipart(
            files=[upload], image_ids=None, auto_generate=False, generation_batch_size=1, user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_multipart_success_generates_ids_and_passes_reservations(monkeypatch):
    """Happy path: buffered images keep their generated ids, the pre-buffer
    reservation is handed to _start_batch_job (no second admission call)."""
    job = _make_job()
    reservations = {"extraction": 1, "generation": 3}
    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value=reservations))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    _patch_pipeline(monkeypatch)

    upload = _FakeUpload(_png_bytes(), filename="a.png", content_type="image/png")
    result = await bp.start_batch_extraction_multipart(
        files=[upload], image_ids=None, auto_generate=True, generation_batch_size=2, user_id=USER_ID, db=Mock()
    )

    assert result.job_id == JOB_ID
    assert result.message == "Batch extraction started for 1 images"
    images = BatchJobService.create_job.await_args.kwargs["images"]
    assert images[0]["image_id"].startswith("img-")
    assert images[0]["filename"] == "a.png"
    assert base64.b64decode(images[0]["image_base64"]) == _png_bytes()


@pytest.mark.asyncio
async def test_multipart_buffering_error_returns_500_and_releases_quota(monkeypatch):
    """A failure mid-buffering (after admission) surfaces as 500 and the
    reservation is compensated."""
    released = []

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(return_value={"extraction": 1, "generation": 3}))
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)
    monkeypatch.setattr(bp, "read_upload_capped", AsyncMock(side_effect=RuntimeError("read failed")))

    upload = _FakeUpload(_png_bytes())
    with pytest.raises(HTTPException) as exc:
        await bp.start_batch_extraction_multipart(
            files=[upload], image_ids=None, auto_generate=True, generation_batch_size=2, user_id=USER_ID, db=Mock()
        )
    assert exc.value.status_code == 500
    assert exc.value.detail == "Failed to start batch extraction"
    assert sorted(released) == sorted([(OperationType.EXTRACTION, 1), (OperationType.GENERATION, 3)])


# ---------------------------------------------------------------------------
# GET /batch-extract/{job_id}/events (SSE)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_batch_events_404_when_job_missing(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=None))

    with pytest.raises(HTTPException) as exc:
        await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 404


@pytest.mark.asyncio
async def test_batch_events_accepts_invalid_last_event_id(monkeypatch):
    """A non-integer Last-Event-ID must fall back to replaying from the start."""
    seen = {}

    async def fake_add_subscriber(job_id, queue, replay_after):
        seen["replay_after"] = replay_after
        return False

    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job()))
    monkeypatch.setattr(BatchJobService, "add_subscriber", fake_add_subscriber)
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(
        job_id=JOB_ID, user_id=USER_ID, db=Mock(), last_event_id="not-an-int"
    )
    events = await _drain(response.content)

    assert seen["replay_after"] == 0
    assert _event_types(events) == ["error"]
    # A rejected subscription returns before the try/finally, so the generator
    # never registers a subscriber to remove.
    BatchJobService.remove_subscriber.assert_not_awaited()


@pytest.mark.asyncio
async def test_batch_events_terminal_job_without_status_data(monkeypatch):
    """A terminal job whose status snapshot vanished still closes the stream
    cleanly after the connected event."""
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job(BatchJobStatus.COMPLETED)))
    monkeypatch.setattr(BatchJobService, "add_subscriber", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "get_job_status", AsyncMock(return_value=None))
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    events = await _drain(response.content)

    assert _event_types(events) == ["connected"]
    BatchJobService.remove_subscriber.assert_awaited_once()


@pytest.mark.asyncio
async def test_batch_events_recovered_job_emits_job_failed(monkeypatch):
    """Recovered jobs are never resumed: the client receives a terminal
    job_failed event with the restart message instead of polling forever."""
    job = _make_job()
    job.recovered_from_persistence = True
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=job))
    monkeypatch.setattr(BatchJobService, "add_subscriber", AsyncMock(return_value=True))
    monkeypatch.setattr(
        BatchJobService, "get_job_status", AsyncMock(return_value={"status": "pending", "error": None})
    )
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    events = await _drain(response.content)

    types = _event_types(events)
    assert types == ["connected", "job_failed"]
    data = json.loads(events[1]["data"])
    assert "cannot resume" in data["error"]


@pytest.mark.asyncio
async def test_batch_events_streams_events_until_terminal(monkeypatch):
    """Live events flow through the queue and the stream stops at a terminal
    event, preserving the monotonic id for Last-Event-ID replay."""
    captured = {}

    async def fake_add_subscriber(job_id, queue, replay_after):
        captured["queue"] = queue
        queue.put_nowait(({"type": "image_extraction_complete", "data": {"image_id": "i1"}, "id": 5}, 10))
        queue.put_nowait(({"type": "job_complete", "data": {"status": "completed"}}, 5))
        return True

    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job()))
    monkeypatch.setattr(BatchJobService, "add_subscriber", fake_add_subscriber)
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    events = await _drain(response.content)

    types = _event_types(events)
    assert types == ["connected", "image_extraction_complete", "job_complete"]
    assert events[1]["id"] == "5"
    BatchJobService.remove_subscriber.assert_awaited_once()


class _HeartbeatQueue:
    """Fake queue: first get times out (heartbeat), second returns a terminal
    event so the stream cannot loop forever."""

    def __init__(self, *args, **kwargs):
        self._calls = 0

    async def get(self):
        self._calls += 1
        if self._calls == 1:
            raise asyncio.TimeoutError
        return ({"type": "job_cancelled", "data": {"status": "cancelled"}}, 0)


@pytest.mark.asyncio
async def test_batch_events_heartbeat_then_terminal(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job()))
    monkeypatch.setattr(BatchJobService, "add_subscriber", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp.asyncio, "Queue", _HeartbeatQueue)
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    events = await _drain(response.content)

    types = _event_types(events)
    assert types == ["connected", "heartbeat", "job_cancelled"]
    BatchJobService.remove_subscriber.assert_awaited_once()


class _CancelQueue:
    """Fake queue whose get raises CancelledError (client disconnect)."""

    def __init__(self, *args, **kwargs):
        pass

    async def get(self):
        raise asyncio.CancelledError


@pytest.mark.asyncio
async def test_batch_events_client_disconnect_closes_stream(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job()))
    monkeypatch.setattr(BatchJobService, "add_subscriber", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "remove_subscriber", AsyncMock())
    monkeypatch.setattr(bp.asyncio, "Queue", _CancelQueue)
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    events = await _drain(response.content)

    assert _event_types(events) == ["connected"]
    BatchJobService.remove_subscriber.assert_awaited_once()


# ---------------------------------------------------------------------------
# POST /batch-extract/{job_id}/cancel
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cancel_batch_job_success(monkeypatch):
    monkeypatch.setattr(BatchJobService, "cancel_job", AsyncMock(return_value=True))

    result = await bp.cancel_batch_job(job_id=JOB_ID, user_id=USER_ID, db=Mock())

    assert result == {"message": "Job cancelled"}
    BatchJobService.cancel_job.assert_awaited_once()
    assert BatchJobService.cancel_job.await_args.args == (JOB_ID, USER_ID)


@pytest.mark.asyncio
async def test_cancel_batch_job_not_found(monkeypatch):
    monkeypatch.setattr(BatchJobService, "cancel_job", AsyncMock(return_value=False))

    with pytest.raises(HTTPException) as exc:
        await bp.cancel_batch_job(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 404
    assert exc.value.detail == "Job not found or already complete"


# ---------------------------------------------------------------------------
# GET /batch-extract/{job_id}/status
# ---------------------------------------------------------------------------


_STATUS_DATA = {
    "job_id": JOB_ID,
    "status": "completed",
    "total_images": 1,
    "extractions_completed": 1,
    "extractions_failed": 0,
    "total_items": 2,
    "generations_completed": 2,
    "generations_failed": 0,
    "items": [{"temp_id": "t1"}],
}


@pytest.mark.asyncio
async def test_get_batch_job_status_success(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job(BatchJobStatus.COMPLETED)))
    monkeypatch.setattr(BatchJobService, "get_job_status", AsyncMock(return_value=dict(_STATUS_DATA)))

    result = await bp.get_batch_job_status(job_id=JOB_ID, user_id=USER_ID, db=Mock())

    assert result.job_id == JOB_ID
    assert result.status == "completed"
    assert result.total_items == 2
    assert result.items == [{"temp_id": "t1"}]


@pytest.mark.asyncio
async def test_get_batch_job_status_404_when_job_missing(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=None))

    with pytest.raises(HTTPException) as exc:
        await bp.get_batch_job_status(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 404


@pytest.mark.asyncio
async def test_get_batch_job_status_404_when_snapshot_missing(monkeypatch):
    monkeypatch.setattr(BatchJobService, "get_job", AsyncMock(return_value=_make_job()))
    monkeypatch.setattr(BatchJobService, "get_job_status", AsyncMock(return_value=None))

    with pytest.raises(HTTPException) as exc:
        await bp.get_batch_job_status(job_id=JOB_ID, user_id=USER_ID, db=Mock())
    assert exc.value.status_code == 404


# ---------------------------------------------------------------------------
# POST /single-extract
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_single_extraction_cache_hit_returns_completed_job(monkeypatch):
    """A cache hit skips quota entirely and serves the cached items as a
    completed job (the cache-hit path must not consume daily quota)."""
    from app.api.v1.batch_processing import SingleExtractionRequest

    job = _make_job()
    monkeypatch.setattr(
        ExtractionCacheService,
        "get_cached_result",
        AsyncMock(return_value={"items": [{"temp_id": "t1", "name": "Shirt"}]}),
    )
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    monkeypatch.setattr(BatchJobService, "restore_cached_items", AsyncMock())
    monkeypatch.setattr(BatchJobService, "update_status", AsyncMock())
    reserve = AsyncMock()
    monkeypatch.setattr(AISettingsService, "reserve_usage", reserve)

    result = await bp.start_single_extraction(
        SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
    )

    assert result.status == "completed"
    assert result.message == "Items detected (cached)"
    assert result.total_images == 1
    BatchJobService.restore_cached_items.assert_awaited_once()
    BatchJobService.update_status.assert_awaited_once_with(job.job_id, BatchJobStatus.COMPLETED)
    # The cache-hit path must not consume quota.
    reserve.assert_not_awaited()


@pytest.mark.asyncio
async def test_single_extraction_cache_hit_with_non_list_items(monkeypatch):
    """A malformed cache payload (items not a list) degrades to an empty
    restore rather than crashing the route."""
    from app.api.v1.batch_processing import SingleExtractionRequest

    job = _make_job()
    monkeypatch.setattr(
        ExtractionCacheService, "get_cached_result", AsyncMock(return_value={"items": {"t1": "x"}})
    )
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    monkeypatch.setattr(BatchJobService, "restore_cached_items", AsyncMock())
    monkeypatch.setattr(BatchJobService, "update_status", AsyncMock())

    result = await bp.start_single_extraction(
        SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
    )

    assert result.status == "completed"
    BatchJobService.restore_cached_items.assert_not_awaited()


@pytest.mark.asyncio
async def test_single_extraction_skip_cache_starts_pipeline(monkeypatch):
    from app.api.v1.batch_processing import SingleExtractionRequest

    job = _make_job()
    get_cached = AsyncMock()
    monkeypatch.setattr(ExtractionCacheService, "get_cached_result", get_cached)
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    _patch_pipeline(monkeypatch)

    result = await bp.start_single_extraction(
        SingleExtractionRequest(image=_png_b64(), skip_cache=True), user_id=USER_ID, db=Mock()
    )

    get_cached.assert_not_awaited(), "skip_cache must bypass the cache lookup"
    assert result.status == "pending"
    assert result.message == "Single-item extraction started"


@pytest.mark.asyncio
async def test_single_extraction_cache_miss_starts_pipeline(monkeypatch):
    from app.api.v1.batch_processing import SingleExtractionRequest

    job = _make_job()
    monkeypatch.setattr(ExtractionCacheService, "get_cached_result", AsyncMock(return_value=None))
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(return_value=job))
    _patch_pipeline(monkeypatch)

    result = await bp.start_single_extraction(
        SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
    )

    assert result.job_id == JOB_ID
    assert result.status == "pending"
    assert result.message == "Single-item extraction started"
    images = BatchJobService.create_job.await_args.kwargs["images"]
    assert images[0]["image_id"].startswith("single_")
    assert images[0]["filename"] == "uploaded_image.jpg"


@pytest.mark.asyncio
async def test_single_extraction_create_job_failure_releases_quota(monkeypatch):
    """A job-creation failure after a successful admission is surfaced as a
    500 by the route, and the reservation is compensated before that."""
    from app.api.v1.batch_processing import SingleExtractionRequest

    released = []

    async def release_usage(*, operation_type, count, **_kwargs):
        released.append((operation_type, count))

    monkeypatch.setattr(ExtractionCacheService, "get_cached_result", AsyncMock(return_value=None))
    monkeypatch.setattr(AISettingsService, "reserve_usage", AsyncMock(return_value=True))
    monkeypatch.setattr(AISettingsService, "release_usage", release_usage)
    monkeypatch.setattr(BatchJobService, "create_job", AsyncMock(side_effect=RuntimeError("db down")))

    with pytest.raises(HTTPException) as exc:
        await bp.start_single_extraction(
            SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
        )
    assert exc.value.status_code == 500
    assert exc.value.detail == "Failed to start extraction"
    assert sorted(released) == sorted([(OperationType.EXTRACTION, 1), (OperationType.GENERATION, 3)])


@pytest.mark.asyncio
async def test_single_extraction_rate_limit_propagates(monkeypatch):
    from app.api.v1.batch_processing import SingleExtractionRequest

    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(side_effect=RateLimitError("nope")))

    with pytest.raises(RateLimitError):
        await bp.start_single_extraction(
            SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_single_extraction_fitcheck_exception_propagates(monkeypatch):
    from app.api.v1.batch_processing import SingleExtractionRequest

    monkeypatch.setattr(
        bp, "_check_batch_rate_limits", AsyncMock(side_effect=UnsupportedMediaTypeError(message="nope"))
    )

    with pytest.raises(UnsupportedMediaTypeError):
        await bp.start_single_extraction(
            SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
        )


@pytest.mark.asyncio
async def test_single_extraction_generic_error_returns_500(monkeypatch):
    from app.api.v1.batch_processing import SingleExtractionRequest

    monkeypatch.setattr(bp, "_check_batch_rate_limits", AsyncMock(side_effect=RuntimeError("boom")))

    with pytest.raises(HTTPException) as exc:
        await bp.start_single_extraction(
            SingleExtractionRequest(image=_png_b64()), user_id=USER_ID, db=Mock()
        )
    assert exc.value.status_code == 500
    assert exc.value.detail == "Failed to start extraction"


# ---------------------------------------------------------------------------
# Misc helpers used by the SSE/cache paths
# ---------------------------------------------------------------------------


def test_maybe_single_data_survives_bare_none():
    """maybe_single_data must tolerate the postgrest bare-None no-row result
    (the delete-account avatar read relies on it)."""
    assert maybe_single_data(None) is None


def test_batch_request_model_rejects_zero_images():
    from pydantic import ValidationError

    from app.api.v1.batch_processing import BatchExtractionRequest

    with pytest.raises(ValidationError):
        BatchExtractionRequest(images=[])


def test_batch_request_model_rejects_oversized_batch_size():
    from pydantic import ValidationError

    from app.api.v1.batch_processing import BatchExtractionRequest, BatchImageInput

    with pytest.raises(ValidationError):
        BatchExtractionRequest(
            images=[BatchImageInput(image_id="img-1", image_base64=_png_b64())],
            generation_batch_size=999999,
        )


def test_batch_pipeline_task_set_starts_empty():
    """The strong-reference set must not leak tasks between tests."""
    assert bp._pipeline_tasks == set()


def test_terminal_sse_events_are_known():
    from app.utils.sse_queue import STREAM_OVERFLOW

    assert "job_complete" in bp._TERMINAL_SSE_EVENTS
    assert "job_failed" in bp._TERMINAL_SSE_EVENTS
    assert "job_cancelled" in bp._TERMINAL_SSE_EVENTS
    assert STREAM_OVERFLOW in bp._TERMINAL_SSE_EVENTS
