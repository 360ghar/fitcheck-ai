"""
Regression: SSE generators must always emit a terminal event.

When an unexpected error occurs mid-stream, the generator must yield a
terminal ``job_failed`` event before closing. Otherwise clients hang forever
waiting on a silently-closed stream. These tests drive each route's real
``event_generator`` (captured by stubbing ``EventSourceResponse``) and force an
underlying service call to raise, asserting a terminal event is still produced.
"""

import pytest

from app.services.batch_job_service import (
    BatchJobService,
    BatchJobStatus,
)
from app.services.photoshoot_job_service import PhotoshootJobService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    SocialImportEventService._subscribers.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    SocialImportEventService._subscribers.clear()


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


# ---------------------------------------------------------------------------
# Batch processing SSE
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_batch_sse_happy_path_emits_terminal_event(monkeypatch):
    """Control: an already-completed job yields a terminal event normally."""
    from app.api.v1 import batch_processing as bp

    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)
    response = await bp.batch_job_events(job_id=job.job_id, user_id="u1")

    events = await _drain(response.content)
    assert "job_complete" in _event_types(events)


@pytest.mark.asyncio
async def test_batch_sse_emits_terminal_event_on_unexpected_error(monkeypatch):
    from app.api.v1 import batch_processing as bp

    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    await BatchJobService.update_status(job.job_id, BatchJobStatus.COMPLETED)

    async def _boom(job_id):
        raise RuntimeError("status store exploded")

    monkeypatch.setattr(BatchJobService, "get_job_status", staticmethod(_boom))
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)

    response = await bp.batch_job_events(job_id=job.job_id, user_id="u1")

    # If the error handler were missing, _drain would re-raise RuntimeError.
    events = await _drain(response.content)
    types = _event_types(events)
    assert "job_failed" in types, f"expected a terminal job_failed event, got {types}"
    # The failed generator's finally block must remove its subscriber.
    assert BatchJobService._jobs[job.job_id].subscribers == []


# ---------------------------------------------------------------------------
# Photoshoot SSE
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_photoshoot_sse_emits_terminal_event_on_unexpected_error(monkeypatch):
    from app.api.v1 import photoshoot as ps

    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )

    async def _boom(job_id, up_to_index=None):
        raise RuntimeError("event history exploded")

    monkeypatch.setattr(PhotoshootJobService, "get_event_history", staticmethod(_boom))
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)

    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": "u1"})

    events = await _drain(response.content)
    types = _event_types(events)
    assert "job_failed" in types, f"expected a terminal job_failed event, got {types}"
    # The failed generator must not leave a dangling subscriber behind.
    assert PhotoshootJobService._jobs[job.job_id].subscribers == []


# ---------------------------------------------------------------------------
# Social import SSE
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_social_import_sse_emits_terminal_event_on_unexpected_error(monkeypatch):
    from app.api.v1 import social_import as si
    from app.core.config import settings

    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", True)

    async def _fake_get_job(db, *, job_id, user_id):
        return {"id": job_id, "platform": "instagram"}

    async def _fake_get_status(self, job_id):
        return {"status": "processing"}

    async def _boom_replay(db, *, job_id, user_id, after_id=None):
        raise RuntimeError("replay exploded")

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(_fake_get_job))
    monkeypatch.setattr(SocialImportPipelineService, "get_status", _fake_get_status)
    monkeypatch.setattr(SocialImportEventService, "replay", staticmethod(_boom_replay))
    monkeypatch.setattr(si, "EventSourceResponse", _CapturingESR)

    response = await si.social_import_events(
        job_id="job-1",
        last_event_id=None,
        user_id="u1",
        db=object(),
    )

    events = await _drain(response.content)
    types = _event_types(events)
    assert "job_failed" in types, f"expected a terminal job_failed event, got {types}"
