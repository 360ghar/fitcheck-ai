"""Regression: a slow SSE client must degrade itself, never the pipeline.

The absence of this test is why the three event stores drifted apart in
opposite wrong directions:

* batch    - bounded queue + ``await queue.put`` -> a stalled client blocked
             the extraction/generation pipeline.
* photoshoot / social import
           - unbounded queue -> a stalled client grew RSS without limit on a
             worker with documented OOM pressure (base64 image payloads).

Each store is asserted on BOTH properties, because the pre-fix failure mode
differs per store (hang vs unbounded growth) and checking only one would
rubber-stamp the other:

  a) the producer completes promptly (never blocked), and
  b) queue depth stays bounded and the stalled subscriber is dropped.
"""

import asyncio

import pytest

from app.services.batch_job_service import BatchJobService
from app.services.photoshoot_job_service import PhotoshootJobService
from app.services.social_import_event_service import SocialImportEventService
from app.utils.sse_queue import SSE_QUEUE_MAXSIZE, STREAM_OVERFLOW

# Comfortably more events than the queue can hold.
_FLOOD = SSE_QUEUE_MAXSIZE * 3
# A producer that is not blocked finishes this in milliseconds.
_NO_BLOCK_TIMEOUT = 2.0


@pytest.fixture(autouse=True)
def _clear_job_stores():
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    SocialImportEventService._subscribers.clear()
    yield
    BatchJobService._jobs.clear()
    PhotoshootJobService._jobs.clear()
    SocialImportEventService._subscribers.clear()


def _assert_dropped_cleanly(queue: asyncio.Queue, subscribers) -> None:
    """A dropped subscriber holds a bounded backlog + one terminal event."""
    assert queue.qsize() <= SSE_QUEUE_MAXSIZE, (
        f"queue grew past its bound: {queue.qsize()}"
    )
    assert queue not in subscribers, "stalled subscriber was not dropped"
    # Drain: the last thing it can read must terminate its generator, so the
    # client sees a close and reconnects instead of hanging forever.
    tail = None
    while not queue.empty():
        tail = queue.get_nowait()
    assert tail is not None and tail["type"] == STREAM_OVERFLOW, (
        f"expected a terminal {STREAM_OVERFLOW} event, got {tail}"
    )


# ---------------------------------------------------------------------------
# Batch job store
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_batch_slow_consumer_does_not_block_or_grow():
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    assert await BatchJobService.add_subscriber(job.job_id, queue)

    async def flood():
        for i in range(_FLOOD):
            await BatchJobService.broadcast_event(
                job.job_id, "item_generation_complete", {"i": i}
            )

    # (a) producer is never back-pressured by the client that stopped reading
    await asyncio.wait_for(flood(), timeout=_NO_BLOCK_TIMEOUT)

    # (b) bounded, and the subscriber degraded itself
    _assert_dropped_cleanly(queue, BatchJobService._jobs[job.job_id].subscribers)


@pytest.mark.asyncio
async def test_batch_late_subscriber_survives_next_broadcast():
    """Replay must leave queue headroom, or a fresh client is dropped at once."""
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    # Build a history far longer than one queue.
    for i in range(_FLOOD):
        await BatchJobService.broadcast_event(job.job_id, "image_extraction_complete", {"i": i})

    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    assert await BatchJobService.add_subscriber(job.job_id, queue)
    await BatchJobService.broadcast_event(job.job_id, "all_extractions_complete", {})

    subscribers = BatchJobService._jobs[job.job_id].subscribers
    assert queue in subscribers, "late joiner dropped before reading anything"


# ---------------------------------------------------------------------------
# Photoshoot job store
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_photoshoot_slow_consumer_does_not_block_or_grow():
    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    ok, _ = await PhotoshootJobService.add_subscriber(job.job_id, queue)
    assert ok

    async def flood():
        for i in range(_FLOOD):
            await PhotoshootJobService.broadcast_event(
                job.job_id, "image_complete", {"i": i, "image_base64": "x" * 1024}
            )

    await asyncio.wait_for(flood(), timeout=_NO_BLOCK_TIMEOUT)

    _assert_dropped_cleanly(queue, PhotoshootJobService._jobs[job.job_id].subscribers)


# ---------------------------------------------------------------------------
# Social import event service (Postgres-backed replay, same fan-out policy)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_social_import_slow_consumer_does_not_block_or_grow(monkeypatch):
    counter = {"n": 0}

    async def _fake_create_event(db, *, job_id, user_id, event_type, payload):
        counter["n"] += 1
        return {"id": counter["n"], "created_at": "2026-01-01T00:00:00Z"}

    from app.services.social_import_job_store import SocialImportJobStore

    monkeypatch.setattr(
        SocialImportJobStore, "create_event", staticmethod(_fake_create_event)
    )

    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    await SocialImportEventService.add_subscriber("job-1", queue)

    async def flood():
        for i in range(_FLOOD):
            await SocialImportEventService.publish(
                object(),
                job_id="job-1",
                user_id="u1",
                event_type="photo_processed",
                payload={"i": i},
            )

    await asyncio.wait_for(flood(), timeout=_NO_BLOCK_TIMEOUT)

    _assert_dropped_cleanly(queue, SocialImportEventService._subscribers.get("job-1", []))


# ---------------------------------------------------------------------------
# Routes must actually request a bounded queue
# ---------------------------------------------------------------------------


class _CapturingESR:
    def __init__(self, content, *args, **kwargs):
        self.content = content
        self.kwargs = kwargs


@pytest.mark.asyncio
async def test_batch_route_subscribes_with_bounded_queue(monkeypatch):
    from app.api.v1 import batch_processing as bp

    job = await BatchJobService.create_job(
        user_id="u1", images=[{"image_id": "img1", "image_base64": "abc"}]
    )
    monkeypatch.setattr(bp, "EventSourceResponse", _CapturingESR)
    response = await bp.batch_job_events(job_id=job.job_id, user_id="u1")

    gen = response.content
    await gen.__anext__()  # "connected"; subscriber is registered by now
    try:
        subscribers = BatchJobService._jobs[job.job_id].subscribers
        assert subscribers and subscribers[0].maxsize == SSE_QUEUE_MAXSIZE
    finally:
        await gen.aclose()

    assert response.kwargs.get("ping") == 15
    assert response.kwargs["headers"]["X-Accel-Buffering"] == "no"


@pytest.mark.asyncio
async def test_photoshoot_route_subscribes_with_bounded_queue(monkeypatch):
    from app.api.v1 import photoshoot as ps

    job = await PhotoshootJobService.create_job(
        user_id="u1", photos=["abc"], use_case="aesthetic", num_images=1
    )
    monkeypatch.setattr(ps, "EventSourceResponse", _CapturingESR)
    response = await ps.photoshoot_job_events(job_id=job.job_id, user={"id": "u1"})

    gen = response.content
    await gen.__anext__()
    try:
        subscribers = PhotoshootJobService._jobs[job.job_id].subscribers
        assert subscribers and subscribers[0].maxsize == SSE_QUEUE_MAXSIZE
    finally:
        await gen.aclose()

    assert response.kwargs.get("ping") == 15
    assert response.kwargs["headers"]["X-Accel-Buffering"] == "no"


@pytest.mark.asyncio
async def test_social_import_route_subscribes_with_bounded_queue(monkeypatch):
    from app.api.v1 import social_import as si
    from app.core.config import settings
    from app.services.social_import_job_store import SocialImportJobStore
    from app.services.social_import_pipeline_service import SocialImportPipelineService

    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", True)

    async def _fake_get_job(db, *, job_id, user_id):
        return {"id": job_id, "platform": "instagram"}

    async def _fake_get_status(self, job_id):
        return {"status": "processing"}

    async def _fake_replay(db, *, job_id, user_id, after_id=None):
        return []

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(_fake_get_job))
    monkeypatch.setattr(SocialImportPipelineService, "get_status", _fake_get_status)
    monkeypatch.setattr(SocialImportEventService, "replay", staticmethod(_fake_replay))
    monkeypatch.setattr(si, "EventSourceResponse", _CapturingESR)

    response = await si.social_import_events(
        job_id="job-1", last_event_id=None, user_id="u1", db=object()
    )

    gen = response.content
    await gen.__anext__()
    try:
        subscribers = SocialImportEventService._subscribers["job-1"]
        assert subscribers and subscribers[0].maxsize == SSE_QUEUE_MAXSIZE
    finally:
        await gen.aclose()

    assert response.kwargs.get("ping") == 15
    assert response.kwargs["headers"]["X-Accel-Buffering"] == "no"
