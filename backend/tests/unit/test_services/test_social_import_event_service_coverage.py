"""Coverage-completing tests for SocialImportEventService.

Sibling to the SSE route tests (test_social_import_routes_coverage.py,
test_sse_error_paths.py, test_sse_slow_consumer.py): this file pins the
subscriber-bookkeeping branches those flows leave untaken — removing a queue
that was never registered, removing one of several subscribers, publishing
with nothing dropped, dropping a queue that is no longer in the live list,
and replaying persisted rows.
"""

import asyncio
from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.services.social_import_event_service import SocialImportEventService


@pytest.fixture(autouse=True)
def _clear_subscribers():
    SocialImportEventService._subscribers.clear()
    yield
    SocialImportEventService._subscribers.clear()


def _queue() -> asyncio.Queue:
    return asyncio.Queue()


# =============================================================================
# remove_subscriber
# =============================================================================


@pytest.mark.asyncio
async def test_remove_subscriber_returns_early_when_job_has_no_queues():
    await SocialImportEventService.remove_subscriber("job-gone", _queue())
    assert "job-gone" not in SocialImportEventService._subscribers


@pytest.mark.asyncio
async def test_remove_subscriber_skips_unregistered_queue_and_keeps_others():
    q1 = _queue()
    stray = _queue()
    stray.put_nowait(("stale", 1))
    await SocialImportEventService.add_subscriber("job-1", q1)

    await SocialImportEventService.remove_subscriber("job-1", stray)

    # The stray queue was never subscribed: it is not removed from the live
    # list, but discard_subscriber still drains its buffered events.
    assert SocialImportEventService._subscribers["job-1"] == [q1]
    assert stray.empty()


@pytest.mark.asyncio
async def test_remove_subscriber_removes_one_of_many_and_keeps_the_rest():
    q1 = _queue()
    q2 = _queue()
    await SocialImportEventService.add_subscriber("job-1", q1)
    await SocialImportEventService.add_subscriber("job-1", q2)

    await SocialImportEventService.remove_subscriber("job-1", q1)

    # The job stays subscribed because q2 remains.
    assert SocialImportEventService._subscribers["job-1"] == [q2]
    assert q1.empty() and q2.empty()


# =============================================================================
# publish
# =============================================================================


@pytest.mark.asyncio
async def test_publish_with_no_subscribers_skips_drop_cleanup():
    with patch(
        "app.services.social_import_event_service.SocialImportJobStore.create_event",
        new=AsyncMock(return_value={"id": 1, "created_at": "2026-01-01T00:00:00"}),
    ), patch("app.services.social_import_event_service.fanout", return_value=[]):
        event = await SocialImportEventService.publish(
            Mock(), job_id="job-1", user_id="u1", event_type="progress", payload={"x": 1}
        )

    assert event == {
        "id": 1,
        "type": "progress",
        "data": {"x": 1},
        "created_at": "2026-01-01T00:00:00",
    }


@pytest.mark.asyncio
async def test_publish_dropped_queue_not_in_live_list_is_skipped():
    """A queue reported dropped by fanout but no longer in the live list (e.g.
    removed between the fanout snapshot and the re-check) is not double-
    removed, and the remaining subscriber keeps the job registered."""
    q1 = _queue()
    stray = _queue()
    await SocialImportEventService.add_subscriber("job-1", q1)

    with patch(
        "app.services.social_import_event_service.SocialImportJobStore.create_event",
        new=AsyncMock(return_value={"id": 2, "created_at": "2026-01-01T00:00:00"}),
    ), patch("app.services.social_import_event_service.fanout", return_value=[stray]):
        await SocialImportEventService.publish(
            Mock(), job_id="job-1", user_id="u1", event_type="progress", payload={"x": 1}
        )

    assert SocialImportEventService._subscribers["job-1"] == [q1]


@pytest.mark.asyncio
async def test_publish_job_evicted_after_fanout_skips_live_cleanup():
    """If the job's subscriber entry is gone by the time the drop cleanup
    re-checks, publish must not re-create it."""

    def _fanout_evicting(_event, _subscribers):
        SocialImportEventService._subscribers.pop("job-1", None)
        return [_queue()]

    with patch(
        "app.services.social_import_event_service.SocialImportJobStore.create_event",
        new=AsyncMock(return_value={"id": 3, "created_at": "2026-01-01T00:00:00"}),
    ), patch(
        "app.services.social_import_event_service.fanout", side_effect=_fanout_evicting
    ):
        await SocialImportEventService.publish(
            Mock(), job_id="job-1", user_id="u1", event_type="progress", payload={"x": 1}
        )

    assert "job-1" not in SocialImportEventService._subscribers


# =============================================================================
# replay
# =============================================================================


@pytest.mark.asyncio
async def test_replay_builds_events_from_persisted_rows():
    rows = [
        {
            "id": 1,
            "event_type": "progress",
            "payload": {"pct": 10},
            "created_at": "2026-01-01T00:00:00",
        },
        {
            "id": 2,
            "event_type": "complete",
            "payload": None,
            "created_at": "2026-01-01T00:01:00",
        },
    ]
    with patch(
        "app.services.social_import_event_service.SocialImportJobStore.list_events",
        new=AsyncMock(return_value=rows),
    ):
        events = await SocialImportEventService.replay(
            Mock(), job_id="job-1", user_id="u1", after_id=1
        )

    assert len(events) == 2
    assert events[0] == {
        "id": 1,
        "type": "progress",
        "data": {"pct": 10},
        "created_at": "2026-01-01T00:00:00",
    }
    # A row without a payload replays as an empty data object.
    assert events[1]["data"] == {}
    assert events[1]["type"] == "complete"


@pytest.mark.asyncio
async def test_replay_without_rows_returns_empty():
    with patch(
        "app.services.social_import_event_service.SocialImportJobStore.list_events",
        new=AsyncMock(return_value=[]),
    ):
        events = await SocialImportEventService.replay(
            Mock(), job_id="job-1", user_id="u1", after_id=None
        )

    assert events == []
