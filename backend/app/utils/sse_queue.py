"""One SSE fan-out policy, shared by every job store that broadcasts events.

Policy: a slow SSE client degrades itself, never the producer and never the
process.

* Subscriber queues are **bounded** (``SSE_QUEUE_MAXSIZE``). An unbounded queue
  fed by ``image_complete`` events carrying base64 payloads grows RSS without
  limit on a worker that already has OOM pressure.
* Broadcast is **non-blocking** (``put_nowait``). ``await queue.put`` on a full
  queue back-pressures the extraction/generation pipeline, not the client that
  stopped reading.
* On overflow the subscriber is **dropped**: its backlog is discarded, it is
  handed a single terminal ``stream_overflow`` event so its generator closes
  (and the client can reconnect and replay), and it is removed from the
  subscriber list. ``remove_subscriber`` alone is not enough — it only runs in
  the generator's ``finally``, which a client that never reads never reaches.
* Subscriber queues additionally carry a **byte budget**
  (``SSE_QUEUE_MAX_BUFFERED_BYTES``): each item is a ``(event, size)`` tuple
  and fanout tracks buffered bytes per queue, so a stalled client is dropped
  once its backlog crosses the budget — the event-count cap alone would let
  one client pin 100 x 5 MB = 500 MB. Consumers report consumption via
  ``note_consumed`` so a healthy stream never trips the budget.
* A subscriber that leaves NORMALLY (client disconnect, generator ``finally``)
  must be released via ``discard_subscriber`` (every store's
  ``remove_subscriber`` does this): the queue is drained and its byte-ledger
  entry dropped, otherwise the ledger's strong reference pins the queue and
  its buffered base64 events until process exit. The overflow drop path in
  ``fanout`` already does the same cleanup.

This module exists so the three stores cannot drift apart again; they did, in
opposite directions (batch blocked the pipeline, photoshoot/social grew
unbounded), because the decision lived in three places.
"""

import asyncio
from typing import Any, Dict, List

from app.core.config import settings

# Deep enough to absorb a normal burst (one batch of generations), shallow
# enough that 100 buffered base64 events per stalled client is survivable.
SSE_QUEUE_MAXSIZE = 100

# Byte budget per subscriber queue (see module docstring). Floored at 1 MB so
# a misconfigured env (0/negative) cannot drop every subscriber instantly.
SSE_QUEUE_MAX_BUFFERED_BYTES = max(1024 * 1024, settings.SSE_QUEUE_MAX_BUFFERED_BYTES)

# Terminal event handed to a subscriber we are dropping. Deliberately NOT
# ``job_failed``: the job is still running and its images are still billed, and
# clients treat ``job_failed`` as "generation died" (they clear results). All
# three SSE generators treat this type as terminal and close the stream, which
# clients see as a disconnect and recover from by reconnecting + replaying.
STREAM_OVERFLOW = "stream_overflow"

# Max events retained per job for late-join SSE replay. Combined with the
# base64 strip in ``strip_history_base64``, history stays small even for
# 50-item jobs whose live events are multi-MB.
EVENT_HISTORY_MAX = 200


def strip_history_base64(event: Dict[str, Any]) -> Dict[str, Any]:
    """History copy of an SSE event with generated base64 payloads removed.

    Live subscribers receive the full event (the client save flow needs the
    base64). History exists only for late-join replay, and every successfully
    generated image is also persisted to a durable storage URL at generation
    time, so the stripped copy still carries everything a late joiner needs.
    The one exception is a generated image whose durable upload FAILED: its
    base64 is the only copy, so it is retained in history (the cost is
    bounded — upload failures are rare and images are dropped at job TTL).
    Keeps finished jobs from pinning multi-MB strings for the whole finished
    TTL. Shared by the batch and photoshoot stores so they cannot drift.
    """
    data = event.get("data")
    if not isinstance(data, dict):
        return event

    def _strip(node: Any) -> Any:
        if isinstance(node, dict):
            stripped: Dict[str, Any] = {}
            for key, value in node.items():
                if key == "generated_image_base64":
                    # Batch-store events always carry a durable URL, so the
                    # base64 copy is redundant for late-join replay.
                    stripped[key] = None
                elif key == "image_base64":
                    # Photoshoot image events carry base64 AND a durable URL;
                    # the URL alone renders in clients, so replays drop the
                    # multi-hundred-KB payload (a single oversized event can
                    # also blow the client-side SSE buffer). URL-less images
                    # (upload failed) KEEP base64 — stripping it would leave
                    # a blank image with no way to render it.
                    stripped[key] = None if node.get("image_url") else _strip(value)
                else:
                    stripped[key] = _strip(value)
            return stripped
        if isinstance(node, list):
            return [_strip(value) for value in node]
        return node

    # Keep SSE metadata (especially the monotonic ``id``) alongside the
    # stripped payload so replay filtering and EventSourceResponse can emit it.
    history_event = {key: value for key, value in event.items() if key != "data"}
    history_event["type"] = event.get("type")
    history_event["data"] = _strip(data)
    return history_event


def event_size_bytes(event: Dict[str, Any]) -> int:
    """Cheap upper-bound estimate of an event's buffered footprint (bytes).

    The dominant cost of image events is their base64 string values; summing
    string lengths over-approximates by the JSON scaffolding, which is the
    conservative direction for a memory budget.
    """
    total = 0
    stack = [event]
    while stack:
        node = stack.pop()
        if isinstance(node, str):
            total += len(node)
        elif isinstance(node, dict):
            stack.extend(node.values())
        elif isinstance(node, (list, tuple)):
            stack.extend(node)
    return total


# Buffered-byte ledger per subscriber queue. Subscriber queues carry
# ``(event, size)`` tuples; ``fanout`` adds on put, consumers report back with
# ``note_consumed`` so a healthy stream never trips the budget. A dropped
# queue's ledger entry is removed with its backlog.
_buffered_bytes: "Dict[asyncio.Queue, int]" = {}


def note_put(queue: asyncio.Queue, size: int) -> None:
    _buffered_bytes[queue] = _buffered_bytes.get(queue, 0) + size


def note_consumed(queue: asyncio.Queue, size: int) -> None:
    remaining = _buffered_bytes.get(queue, 0) - size
    if remaining <= 0:
        _buffered_bytes.pop(queue, None)
    else:
        _buffered_bytes[queue] = remaining


def buffered_bytes(queue: asyncio.Queue) -> int:
    return _buffered_bytes.get(queue, 0)


def _drain_and_drop(queue: asyncio.Queue) -> None:
    """Drain a subscriber's queue and drop its byte-ledger entry.

    The queue may hold multi-MB base64 events; freeing the backlog is the
    memory win, and the ledger entry must go with it or the strong reference
    pins the queue until process exit. Non-blocking (``get_nowait`` only) and
    idempotent, so it is safe to call while holding a store lock or from a
    generator ``finally``.
    """
    try:
        while not queue.empty():
            queue.get_nowait()
    except Exception:  # pragma: no cover - defensive, matches prior behaviour
        pass
    _buffered_bytes.pop(queue, None)


def discard_subscriber(queue: asyncio.Queue) -> None:
    """Free a subscriber's queue and its byte-ledger entry on disconnect.

    Called by every store's ``remove_subscriber`` (and anywhere else a
    subscriber leaves): the queue is drained (its buffered events may hold
    multi-MB base64) and the ledger entry is dropped. Without this, the
    ``_buffered_bytes`` dict keeps a STRONG reference to every queue whose
    client disconnected with events still buffered — the events (and the
    queue) would never be freed, so churned SSE connections leak RSS
    without bound.
    """
    _drain_and_drop(queue)


def overflow_event() -> Dict[str, Any]:
    return {
        "type": STREAM_OVERFLOW,
        "data": {
            "error": "Event stream fell behind and was dropped.",
            "recoverable": True,
        },
    }


def fanout(event: Dict[str, Any], subscribers: List[asyncio.Queue]) -> List[asyncio.Queue]:
    """Broadcast ``event`` without ever blocking. Returns the queues to drop.

    Subscriber queues carry ``(event, size)`` tuples; the size is the event's
    buffered footprint, tracked so a stalled client is dropped once the byte
    budget is crossed - not only when the event-count cap is hit. Callers
    must remove the returned queues from their subscriber list.
    """
    size = event_size_bytes(event)
    dropped: List[asyncio.Queue] = []
    for queue in subscribers:
        # Byte-budget check BEFORE the put: a single multi-MB event arriving
        # on an already-buffered queue must not be admitted just because the
        # event count is still under the cap.
        if buffered_bytes(queue) + size > SSE_QUEUE_MAX_BUFFERED_BYTES:
            # Free the backlog immediately (that is the memory), then leave
            # exactly one terminal event behind. No awaits here, so the
            # consumer cannot interleave with the drain.
            _drain_and_drop(queue)
            try:
                queue.put_nowait((overflow_event(), 0))
            except Exception:  # pragma: no cover - defensive, matches prior behaviour
                pass
            dropped.append(queue)
            continue
        try:
            queue.put_nowait((event, size))
            note_put(queue, size)
        except asyncio.QueueFull:
            # Free the backlog immediately (that is the memory), then leave
            # exactly one terminal event behind. No awaits here, so the
            # consumer cannot interleave with the drain.
            _drain_and_drop(queue)
            queue.put_nowait((overflow_event(), 0))
            dropped.append(queue)
        except Exception:  # pragma: no cover - defensive, matches prior behaviour
            dropped.append(queue)
    return dropped
