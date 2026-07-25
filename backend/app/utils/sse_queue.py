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

This module exists so the three stores cannot drift apart again; they did, in
opposite directions (batch blocked the pipeline, photoshoot/social grew
unbounded), because the decision lived in three places.
"""

import asyncio
from typing import Any, Dict, List

# Deep enough to absorb a normal burst (one batch of generations), shallow
# enough that 100 buffered base64 events per stalled client is survivable.
SSE_QUEUE_MAXSIZE = 100

# Terminal event handed to a subscriber we are dropping. Deliberately NOT
# ``job_failed``: the job is still running and its images are still billed, and
# clients treat ``job_failed`` as "generation died" (they clear results). All
# three SSE generators treat this type as terminal and close the stream, which
# clients see as a disconnect and recover from by reconnecting + replaying.
STREAM_OVERFLOW = "stream_overflow"


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

    Callers must remove the returned queues from their subscriber list.
    """
    dropped: List[asyncio.Queue] = []
    for queue in subscribers:
        try:
            queue.put_nowait(event)
        except asyncio.QueueFull:
            # Free the backlog immediately (that is the memory), then leave
            # exactly one terminal event behind. No awaits here, so the
            # consumer cannot interleave with the drain.
            while not queue.empty():
                queue.get_nowait()
            queue.put_nowait(overflow_event())
            dropped.append(queue)
        except Exception:  # pragma: no cover - defensive, matches prior behaviour
            dropped.append(queue)
    return dropped
