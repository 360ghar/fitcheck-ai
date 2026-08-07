"""Residual branch coverage for app.utils.sse_queue.

Sibling integration tests (test_sse_slow_consumer.py) exercise the stores'
SSE generators end-to-end; this file covers the shared queue-policy helpers
directly: history base64 stripping (keep vs drop), the byte-budget ledger,
overflow/queue-full drop paths in fanout, and discard semantics.
"""

import asyncio

from app.utils import sse_queue
from app.utils.sse_queue import (
    STREAM_OVERFLOW,
    buffered_bytes,
    discard_subscriber,
    event_size_bytes,
    fanout,
    note_consumed,
    note_put,
    overflow_event,
    strip_history_base64,
)


def test_strip_history_base64_drops_guarded_base64_with_durable_url():
    event = {
        "id": "e1",
        "type": "image_complete",
        "data": {
            "image_base64": "aGVsbG8=",
            "image_url": "https://cdn.example.com/1.png",
            "name": "shirt",
        },
    }
    stripped = strip_history_base64(event)
    assert stripped["data"]["image_base64"] is None
    assert stripped["data"]["image_url"] == "https://cdn.example.com/1.png"
    assert stripped["data"]["name"] == "shirt"
    assert stripped["id"] == "e1"
    assert stripped["type"] == "image_complete"


def test_strip_history_base64_keeps_base64_when_no_durable_copy():
    """URL-less images keep their base64: it is the only renderable copy."""
    event = {
        "id": "e2",
        "type": "image_complete",
        "data": {"image_base64": "aGVsbG8=", "name": "shirt"},
    }
    stripped = strip_history_base64(event)
    assert stripped["data"]["image_base64"] == "aGVsbG8="


def test_strip_history_base64_drops_unconditional_guard():
    event = {
        "id": "e3",
        "type": "generated",
        "data": {"generated_image_base64": "aGVsbG8=", "image_url": "https://x/2.png"},
    }
    stripped = strip_history_base64(event)
    assert stripped["data"]["generated_image_base64"] is None


def test_strip_history_base64_walks_nested_lists_and_non_dict_data():
    event = {"id": "e4", "type": "t", "data": {"items": [{"image_base64": "abc", "image_url": "https://x/3.png"}]}}
    stripped = strip_history_base64(event)
    assert stripped["data"]["items"][0]["image_base64"] is None

    # Non-dict data passes through untouched.
    event2 = {"id": "e5", "type": "t", "data": "just a string"}
    assert strip_history_base64(event2) == event2


def test_event_size_bytes_sums_strings_recursively():
    event = {"data": {"a": "hello", "b": ["world", {"c": "!"}], "n": 5}}
    assert event_size_bytes(event) == len("hello") + len("world") + len("!")


def test_overflow_event_shape():
    ev = overflow_event()
    assert ev["type"] == STREAM_OVERFLOW
    assert ev["data"]["recoverable"] is True


def test_note_and_consume_ledger():
    queue = asyncio.Queue()
    note_put(queue, 100)
    assert buffered_bytes(queue) == 100
    note_consumed(queue, 60)
    assert buffered_bytes(queue) == 40
    note_consumed(queue, 40)
    # Ledger entry removed once fully consumed.
    assert buffered_bytes(queue) == 0


def test_discard_subscriber_drains_queue_and_ledger():
    queue = asyncio.Queue()
    queue.put_nowait(("payload", 10))
    note_put(queue, 10)
    discard_subscriber(queue)
    assert queue.empty()
    assert buffered_bytes(queue) == 0


def test_fanout_puts_event_and_tracks_bytes():
    queue = asyncio.Queue()
    event = {"data": {"image_base64": "abc"}}
    dropped = fanout(event, [queue])
    assert dropped == []
    assert queue.qsize() == 1
    assert queue.get_nowait()[0] == event
    # Bytes are tracked in the ledger until the consumer reports them.
    assert buffered_bytes(queue) == 3
    note_consumed(queue, 3)
    assert buffered_bytes(queue) == 0


def test_fanout_drops_subscriber_over_byte_budget():
    queue = asyncio.Queue()
    # Push the queue past the byte budget before fanout.
    note_put(queue, sse_queue.SSE_QUEUE_MAX_BUFFERED_BYTES)
    dropped = fanout({"data": {"x": "y"}}, [queue])
    assert dropped == [queue]
    # Terminal overflow event is the only thing left behind.
    assert queue.qsize() == 1
    ev = queue.get_nowait()[0]
    assert ev["type"] == STREAM_OVERFLOW
    assert buffered_bytes(queue) == 0


def test_fanout_drops_subscriber_on_queue_full():
    queue = asyncio.Queue(maxsize=1)
    queue.put_nowait(("stuck", 10))
    dropped = fanout({"data": {"x": "y"}}, [queue])
    assert dropped == [queue]
    assert queue.qsize() == 1
    assert queue.get_nowait()[0]["type"] == STREAM_OVERFLOW
