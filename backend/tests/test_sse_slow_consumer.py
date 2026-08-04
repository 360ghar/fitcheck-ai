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
from app.utils.sse_queue import SSE_QUEUE_MAXSIZE, STREAM_OVERFLOW, strip_history_base64

# Comfortably more events than the queue can hold.
_FLOOD = SSE_QUEUE_MAXSIZE * 3
# A producer that is not blocked finishes this in milliseconds.
_NO_BLOCK_TIMEOUT = 2.0


def test_history_strip_preserves_sse_id_and_removes_base64():
    event = {
        "type": "image_complete",
        "id": 7,
        "data": {"generated_image_base64": "payload", "nested": [{"keep": True}]},
    }
    stripped = strip_history_base64(event)
    assert stripped["id"] == 7
    assert stripped["type"] == "image_complete"
    assert stripped["data"]["generated_image_base64"] is None
    assert stripped["data"]["nested"] == [{"keep": True}]


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
    # Subscriber queues carry (event, size) tuples (see app/utils/sse_queue).
    tail = None
    while not queue.empty():
        item = queue.get_nowait()
        tail = item[0] if isinstance(item, tuple) else item
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


@pytest.mark.asyncio
async def test_batch_slow_consumer_dropped_on_byte_budget_before_event_cap(monkeypatch):
    """The byte budget (SSE_QUEUE_MAX_BUFFERED_BYTES) must drop a stalled
    subscriber whose BACKLOG is multi-MB — long before the 100-event cap — so
    one client cannot pin 100 x 5 MB = 500 MB (the 2026-08-03 OOM class)."""
    from app.utils import sse_queue

    monkeypatch.setattr(sse_queue, "SSE_QUEUE_MAX_BUFFERED_BYTES", 1024 * 1024)
    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    assert await BatchJobService.add_subscriber(job.job_id, queue)

    big = "x" * 300_000  # ~300 KB per event; budget trips at ~1 MB
    for i in range(20):
        await BatchJobService.broadcast_event(
            job.job_id,
            "item_generation_complete",
            {"i": i, "generated_image_base64": big},
        )

    subscribers = BatchJobService._jobs[job.job_id].subscribers
    assert queue not in subscribers, "byte budget did not drop the subscriber"
    # Backlog was freed immediately; only the terminal overflow event remains.
    assert queue.qsize() <= 2
    tail = None
    while not queue.empty():
        item = queue.get_nowait()
        tail = item[0] if isinstance(item, tuple) else item
    assert tail is not None and tail["type"] == STREAM_OVERFLOW


@pytest.mark.asyncio
async def test_normal_remove_subscriber_releases_queue_and_byte_ledger():
    """A client that disconnects normally with events still buffered must not
    leak: remove_subscriber drains the queue and drops the byte-ledger entry,
    whose strong reference would otherwise pin the queue + its multi-MB
    events until process exit."""
    from app.utils import sse_queue
    from app.utils.sse_queue import buffered_bytes, note_put

    job = await BatchJobService.create_job(
        user_id="u1",
        images=[{"image_id": "img1", "image_base64": "abc"}],
    )
    queue: asyncio.Queue = asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE)
    assert await BatchJobService.add_subscriber(job.job_id, queue)

    # Simulate buffered, unconsumed events (client stopped reading).
    big = "y" * 200_000
    for i in range(5):
        event = {"type": "item_generation_complete", "data": {"i": i, "generated_image_base64": big}}
        note_put(queue, sse_queue.event_size_bytes(event))
        queue.put_nowait((event, sse_queue.event_size_bytes(event)))
    assert buffered_bytes(queue) > 0
    assert queue.qsize() == 5

    await BatchJobService.remove_subscriber(job.job_id, queue)

    assert queue not in BatchJobService._jobs[job.job_id].subscribers
    assert queue.qsize() == 0, "buffered events must be drained on disconnect"
    assert buffered_bytes(queue) == 0, "byte-ledger entry must be dropped"
    assert queue not in sse_queue._buffered_bytes


@pytest.mark.asyncio
async def test_photoshoot_remove_subscriber_releases_queue_and_byte_ledger():
    from app.utils import sse_queue
    from app.utils.sse_queue import buffered_bytes, note_put

    job = await PhotoshootJobService.create_job(
        user_id="u1",
        photos=["abc"],
        use_case="aesthetic",
        num_images=1,
    )
    ok, _ = await PhotoshootJobService.add_subscriber(job.job_id, queue := asyncio.Queue(maxsize=SSE_QUEUE_MAXSIZE))
    assert ok

    event = {"type": "image_complete", "data": {"image_base64": "z" * 100_000}}
    note_put(queue, sse_queue.event_size_bytes(event))
    queue.put_nowait((event, sse_queue.event_size_bytes(event)))
    assert buffered_bytes(queue) > 0

    await PhotoshootJobService.remove_subscriber(job.job_id, queue)

    assert queue not in PhotoshootJobService._jobs[job.job_id].subscribers
    assert queue.qsize() == 0
    assert buffered_bytes(queue) == 0
    assert queue not in sse_queue._buffered_bytes


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
