"""
Route-level coverage for app/api/v1/photoshoot.py.

Complements tests/integration/test_sse_error_paths.py and
tests/integration/test_sse_slow_consumer.py (which own the bounded-queue and
terminal-on-error regressions) by covering the remaining branches: demo
create/status flows, sync and async generate paths, cancel/status routes,
and the SSE generator's terminal/replay/live-queue/heartbeat arms.
"""
import asyncio
import base64
import io
import json
from contextlib import asynccontextmanager
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import pytest
from fastapi import HTTPException
from PIL import Image

from app.api.v1 import photoshoot as ps
from app.core.exceptions import AIServiceError, RateLimitError, ServiceError, ValidationError
from app.models.photoshoot import (
    DemoPhotoshootRequest,
    PhotoshootJobStatus,
    StartPhotoshootRequest,
    PhotoshootUseCase,
)
from app.services.photoshoot_job_service import PhotoshootJobService
from app.services.photoshoot_service import PhotoshootService, PhotoshootStreamingService

DEMO_IP = "203.0.113.7"
USER_ID = "11111111-1111-1111-1111-111111111111"


def _png_b64() -> str:
    """A small, valid PNG as base64 (the request models verify real bytes)."""
    buf = io.BytesIO()
    Image.new("RGB", (4, 4), color=(180, 90, 40)).save(buf, format="PNG")
    return base64.b64encode(buf.getvalue()).decode()


def _demo_request() -> Mock:
    request = Mock()
    request.client = Mock()
    request.client.host = DEMO_IP
    return request


class _CapturingESR:
    """Stand-in for EventSourceResponse that captures the generator."""

    def __init__(self, content, *args, **kwargs):
        self.content = content


async def _drain(generator, cap: int = 30):
    events = []
    async for event in generator:
        events.append(event)
        if len(events) >= cap:
            break
    return events


async def _collect_in_task(generator):
    return await _drain(generator)


async def _wait_for_subscriber(job_id: str) -> None:
    for _ in range(200):
        job = PhotoshootJobService._jobs.get(job_id)
        if job and job.subscribers:
            return
        await asyncio.sleep(0.01)
    raise AssertionError(f"SSE generator never subscribed to {job_id}")


def _event_types(events):
    return [e.get("event") for e in events]


@pytest.fixture(autouse=True)
def _clear_job_store():
    PhotoshootJobService._jobs.clear()
    ps._pipeline_tasks.clear()
    yield
    PhotoshootJobService._jobs.clear()
    ps._pipeline_tasks.clear()


async def _seed_job(user_id=USER_ID, **kwargs):
    return await PhotoshootJobService.create_job(
        user_id=user_id,
        photos=[_png_b64()],
        use_case="aesthetic",
        num_images=2,
        batch_size=2,
        aspect_ratio="1:1",
        db=None,
        **kwargs,
    )


# ---------------------------------------------------------------------------
# Use cases + demo flow
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_use_cases_returns_every_template():
    result = await ps.get_use_cases()

    assert result["message"] == "OK"
    ids = [uc["id"] for uc in result["data"]["use_cases"]]
    assert set(ids) == {
        "linkedin",
        "dating_app",
        "model_portfolio",
        "instagram",
        "aesthetic",
        "custom",
    }


@pytest.mark.asyncio
async def test_demo_photoshoot_starts_a_job_and_coerces_custom(monkeypatch):
    @asynccontextmanager
    async def _ok_rate_limit(request, operation):  # noqa: ANN001
        yield {"remaining": 2}

    monkeypatch.setattr(ps, "ip_rate_limited_operation", _ok_rate_limit)
    monkeypatch.setattr(PhotoshootStreamingService, "run_pipeline", AsyncMock())

    result = await ps.demo_photoshoot(
        request=_demo_request(),
        body=DemoPhotoshootRequest(photo=_png_b64(), use_case=PhotoshootUseCase.CUSTOM),
    )

    assert result.status_code == 202
    payload = json.loads(result.body)
    assert payload["message"] == "OK"
    data = payload["data"]
    assert data["message"] == "Demo photoshoot generation started"
    assert data["remaining_today"] == 1
    assert data["status"] == "pending"

    job = PhotoshootJobService._jobs[data["job_id"]]
    # CUSTOM is not allowed in demo mode: coerced to AESTHETIC.
    assert job.use_case == "aesthetic"
    assert job.user_id == ps._demo_user_id(_demo_request())
    assert job.num_images == 2


@pytest.mark.asyncio
async def test_demo_photoshoot_rate_limit_exceeded(monkeypatch):
    class _Denied:
        async def __aenter__(self):
            raise RateLimitError(
                "Demo photoshoot limit (1 per day) exceeded.", retry_after=86400
            )

        async def __aexit__(self, *exc):
            return False

    monkeypatch.setattr(ps, "ip_rate_limited_operation", lambda request, op: _Denied())
    monkeypatch.setattr(PhotoshootStreamingService, "run_pipeline", AsyncMock())

    with pytest.raises(RateLimitError, match="per day"):
        await ps.demo_photoshoot(
            request=_demo_request(),
            body=DemoPhotoshootRequest(photo=_png_b64()),
        )


@pytest.mark.asyncio
async def test_demo_photoshoot_wraps_unexpected_failures(monkeypatch):
    @asynccontextmanager
    async def _ok_rate_limit(request, operation):  # noqa: ANN001
        yield {"remaining": 1}

    monkeypatch.setattr(ps, "ip_rate_limited_operation", _ok_rate_limit)
    monkeypatch.setattr(
        PhotoshootJobService, "create_job", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(AIServiceError, match="Failed to start demo photoshoot"):
        await ps.demo_photoshoot(
            request=_demo_request(),
            body=DemoPhotoshootRequest(photo=_png_b64()),
        )


@pytest.mark.asyncio
async def test_demo_photoshoot_status_returns_the_job_without_usage():
    job = await _seed_job(user_id=ps._demo_user_id(_demo_request()))
    request = _demo_request()

    result = await ps.demo_photoshoot_status(job_id=job.job_id, request=request)

    assert result["message"] == "OK"
    assert result["data"]["job_id"] == job.job_id
    assert "usage" not in result["data"]


@pytest.mark.asyncio
async def test_demo_photoshoot_status_404_when_job_is_missing():
    with pytest.raises(HTTPException) as exc_info:
        await ps.demo_photoshoot_status(job_id="missing-job", request=_demo_request())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_demo_photoshoot_status_404_when_status_is_missing():
    with patch.object(
        PhotoshootJobService, "get_job", new=AsyncMock(return_value=Mock())
    ), patch.object(
        PhotoshootJobService, "get_job_status", new=AsyncMock(return_value=None)
    ):
        with pytest.raises(HTTPException) as exc_info:
            await ps.demo_photoshoot_status(job_id="job-1", request=_demo_request())
    assert exc_info.value.status_code == 404


# ---------------------------------------------------------------------------
# Generate: sync and async modes
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_generate_requires_a_custom_prompt_for_custom_use_case():
    body = StartPhotoshootRequest(photos=[_png_b64()], use_case=PhotoshootUseCase.CUSTOM)

    with pytest.raises(ValidationError, match="Custom prompt is required"):
        await ps.generate_photoshoot(body, user={"id": USER_ID}, db=Mock())


@pytest.mark.asyncio
async def test_generate_sync_mode_returns_200_on_full_success():
    body = StartPhotoshootRequest(photos=[_png_b64()], use_case=PhotoshootUseCase.AESTHETIC)
    with patch.object(
        PhotoshootService,
        "generate_photoshoot",
        new=AsyncMock(
            return_value=Mock(
                partial_success=False,
                model_dump=lambda mode="json": {"session_id": "s1", "generated_count": 2},
            )
        ),
    ):
        result = await ps.generate_photoshoot(body, sync=True, user={"id": USER_ID}, db=Mock())

    assert result.status_code == 200
    assert json.loads(result.body)["data"]["session_id"] == "s1"


@pytest.mark.asyncio
async def test_generate_sync_mode_returns_207_on_partial_success():
    body = StartPhotoshootRequest(photos=[_png_b64()], use_case=PhotoshootUseCase.AESTHETIC)
    with patch.object(
        PhotoshootService,
        "generate_photoshoot",
        new=AsyncMock(
            return_value=Mock(
                partial_success=True,
                model_dump=lambda mode="json": {"session_id": "s1", "generated_count": 1},
            )
        ),
    ):
        result = await ps.generate_photoshoot(body, sync=True, user={"id": USER_ID}, db=Mock())

    assert result.status_code == 207


@pytest.mark.asyncio
async def test_generate_sync_mode_timeout_raises_service_error():
    body = StartPhotoshootRequest(photos=[_png_b64()], use_case=PhotoshootUseCase.AESTHETIC)
    with patch.object(
        PhotoshootService, "generate_photoshoot", new=AsyncMock(side_effect=asyncio.TimeoutError())
    ):
        with pytest.raises(ServiceError, match="taking longer than expected"):
            await ps.generate_photoshoot(body, sync=True, user={"id": USER_ID}, db=Mock())


@pytest.mark.asyncio
async def test_generate_async_mode_returns_the_job_id(monkeypatch):
    body = StartPhotoshootRequest(
        photos=[_png_b64()], use_case=PhotoshootUseCase.AESTHETIC, num_images=4
    )
    run_pipeline = AsyncMock()
    monkeypatch.setattr(PhotoshootStreamingService, "run_pipeline", run_pipeline)
    with patch.object(
        PhotoshootService, "check_daily_limit", new=AsyncMock(return_value=(True, Mock()))
    ), patch.object(
        PhotoshootJobService,
        "create_job",
        new=AsyncMock(
            return_value=Mock(job_id="job-1", status=SimpleNamespace(value="processing"))
        ),
    ):
        result = await ps.generate_photoshoot(
            body, sync=False, user={"id": USER_ID}, db=Mock()
        )

    assert result["message"] == "OK"
    assert result["data"]["job_id"] == "job-1"
    assert result["data"]["status"] == "processing"
    assert "4 images" in result["data"]["message"]
    await asyncio.sleep(0.05)
    assert run_pipeline.await_count == 1


@pytest.mark.asyncio
async def test_generate_async_mode_rate_limited():
    body = StartPhotoshootRequest(photos=[_png_b64()], use_case=PhotoshootUseCase.AESTHETIC)
    with patch.object(
        PhotoshootService,
        "check_daily_limit",
        new=AsyncMock(return_value=(False, Mock(remaining=2))),
    ):
        with pytest.raises(RateLimitError, match="2 images remaining"):
            await ps.generate_photoshoot(body, sync=False, user={"id": USER_ID}, db=Mock())


@pytest.mark.asyncio
async def test_get_usage_returns_the_envelope():
    with patch.object(
        PhotoshootService,
        "get_usage",
        new=AsyncMock(
            return_value=Mock(
                model_dump=lambda mode="json": {"used_today": 3, "limit_today": 10}
            )
        ),
    ):
        result = await ps.get_usage(user={"id": USER_ID}, db=Mock())

    assert result["message"] == "OK"
    assert result["data"]["used_today"] == 3


# ---------------------------------------------------------------------------
# Cancel + status routes
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cancel_job_returns_confirmation():
    with patch.object(
        PhotoshootJobService, "cancel_job", new=AsyncMock(return_value=True)
    ):
        result = await ps.cancel_photoshoot_job(job_id="job-1", user={"id": USER_ID}, db=Mock())

    assert result == {"message": "Job cancelled"}


@pytest.mark.asyncio
async def test_cancel_job_404_when_job_cannot_be_cancelled():
    with patch.object(
        PhotoshootJobService, "cancel_job", new=AsyncMock(return_value=False)
    ):
        with pytest.raises(HTTPException) as exc_info:
            await ps.cancel_photoshoot_job(job_id="job-1", user={"id": USER_ID}, db=Mock())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_get_job_status_returns_the_status_payload():
    with patch.object(
        PhotoshootJobService, "get_job", new=AsyncMock(return_value=Mock())
    ), patch.object(
        PhotoshootJobService,
        "get_job_status",
        new=AsyncMock(return_value={"status": "complete", "generated_count": 2}),
    ):
        result = await ps.get_photoshoot_job_status(job_id="job-1", user={"id": USER_ID}, db=Mock())

    assert result["message"] == "OK"
    assert result["data"]["status"] == "complete"


@pytest.mark.asyncio
async def test_get_job_status_404_when_job_is_missing():
    with patch.object(
        PhotoshootJobService, "get_job", new=AsyncMock(return_value=None)
    ):
        with pytest.raises(HTTPException) as exc_info:
            await ps.get_photoshoot_job_status(job_id="job-1", user={"id": USER_ID}, db=Mock())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_get_job_status_404_when_status_is_missing():
    with patch.object(
        PhotoshootJobService, "get_job", new=AsyncMock(return_value=Mock())
    ), patch.object(
        PhotoshootJobService, "get_job_status", new=AsyncMock(return_value=None)
    ):
        with pytest.raises(HTTPException) as exc_info:
            await ps.get_photoshoot_job_status(job_id="job-1", user={"id": USER_ID}, db=Mock())
    assert exc_info.value.status_code == 404


# ---------------------------------------------------------------------------
# SSE events generator
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_events_route_404_when_job_is_unknown():
    with pytest.raises(HTTPException) as exc_info:
        await ps.photoshoot_job_events(job_id="missing", user={"id": USER_ID}, db=None)
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_events_generator_emits_error_when_subscription_is_rejected(monkeypatch):
    job = await _seed_job()
    monkeypatch.setattr(
        PhotoshootJobService, "add_subscriber", AsyncMock(return_value=(False, 0))
    )
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    assert _event_types(events) == ["error"]
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("status", "expected_event"),
    [
        (PhotoshootJobStatus.COMPLETE, "job_complete"),
        (PhotoshootJobStatus.FAILED, "job_failed"),
        (PhotoshootJobStatus.CANCELLED, "job_cancelled"),
    ],
)
async def test_events_generator_replays_terminal_jobs(monkeypatch, status, expected_event):
    job = await _seed_job()
    job.status = status
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    types = _event_types(events)
    assert types[0] == "connected"
    assert expected_event in types
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


@pytest.mark.asyncio
async def test_events_generator_terminal_job_without_status_data(monkeypatch):
    """A terminal job whose status payload is gone (e.g. evicted from the
    in-memory store) closes the stream after 'connected' without crashing."""
    job = await _seed_job()
    job.status = PhotoshootJobStatus.COMPLETE
    monkeypatch.setattr(PhotoshootJobService, "get_job_status", AsyncMock(return_value=None))
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    assert _event_types(events) == ["connected"]


@pytest.mark.asyncio
async def test_events_generator_recovered_job_without_status_data(monkeypatch):
    """A recovered job whose status payload is gone also closes the stream
    after 'connected' instead of emitting a stale recovered event."""
    job = await _seed_job()
    job.recovered_from_persistence = True
    monkeypatch.setattr(PhotoshootJobService, "get_job_status", AsyncMock(return_value=None))
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    assert _event_types(events) == ["connected"]


@pytest.mark.asyncio
async def test_events_generator_emits_recovered_event_for_hydrated_jobs(monkeypatch):
    job = await _seed_job()
    job.recovered_from_persistence = True
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    types = _event_types(events)
    assert types[0] == "connected"
    assert "job_recovered" in types


@pytest.mark.asyncio
async def test_events_generator_replays_buffered_history_including_ids(monkeypatch):
    job = await _seed_job()
    job.event_history = [
        {"type": "generation_started", "data": {"total_batches": 1}, "id": 1},
        {"type": "job_complete", "data": {"done": True}, "id": 2},
    ]
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    events = await _drain(response.content)

    types = _event_types(events)
    assert types == ["connected", "generation_started", "job_complete"]
    assert events[1]["id"] == "1"
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


@pytest.mark.asyncio
async def test_events_generator_streams_live_events_until_terminal(monkeypatch):
    job = await _seed_job()
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    task = asyncio.create_task(_collect_in_task(response.content))
    await _wait_for_subscriber(job.job_id)

    await PhotoshootJobService.broadcast_event(
        job.job_id, "image_complete", {"index": 0, "image_base64": "abc"}
    )
    await PhotoshootJobService.broadcast_event(
        job.job_id, "job_complete", {"generated_count": 1}
    )

    events = await asyncio.wait_for(task, timeout=5)
    types = _event_types(events)
    assert types[0] == "connected"
    assert "image_complete" in types
    assert "job_complete" in types
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


@pytest.mark.asyncio
async def test_events_generator_heartbeats_on_idle_queue_then_streams(monkeypatch):
    job = await _seed_job()
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)
    real_wait_for = asyncio.wait_for
    state = {"n": 0}

    async def _fake_wait_for(coro, timeout):
        state["n"] += 1
        if timeout == 30 and state["n"] == 1:
            coro.close()
            raise asyncio.TimeoutError()
        return await real_wait_for(coro, timeout)

    monkeypatch.setattr(ps.asyncio, "wait_for", _fake_wait_for)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    task = asyncio.create_task(_collect_in_task(response.content))
    await _wait_for_subscriber(job.job_id)
    await asyncio.sleep(0.2)

    await PhotoshootJobService.broadcast_event(
        job.job_id, "job_complete", {"generated_count": 2}
    )
    events = await asyncio.wait_for(task, timeout=5)

    types = _event_types(events)
    assert "heartbeat" in types
    assert "job_complete" in types


@pytest.mark.asyncio
async def test_events_generator_handles_client_disconnect_cleanly(monkeypatch):
    """Cancelling the consuming task (client disconnect) must unwind the
    generator through the CancelledError arm and drop the subscriber."""
    job = await _seed_job()
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    task = asyncio.create_task(_collect_in_task(response.content))
    await _wait_for_subscriber(job.job_id)
    await asyncio.sleep(0.05)

    # Cancelling the consumer injects CancelledError into the generator at the
    # queue read; the generator unwinds through its CancelledError arm and
    # drops the subscriber, so the consumer task ends normally.
    task.cancel()
    await asyncio.wait_for(task, timeout=5)

    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


@pytest.mark.asyncio
async def test_events_generator_emits_terminal_failure_on_internal_error(monkeypatch):
    """An unexpected error mid-stream must still close with a terminal event
    (regression covered here for the consumption-reporting step)."""
    job = await _seed_job()

    def _boom(queue, event_size):  # noqa: ANN001
        raise RuntimeError("ledger exploded")

    monkeypatch.setattr(ps, "note_consumed", _boom)
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": USER_ID}, db=None)
    task = asyncio.create_task(_collect_in_task(response.content))
    await _wait_for_subscriber(job.job_id)

    await PhotoshootJobService.broadcast_event(
        job.job_id, "image_complete", {"index": 0, "image_base64": "abc"}
    )
    events = await asyncio.wait_for(task, timeout=5)

    assert "job_failed" in _event_types(events)
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []
