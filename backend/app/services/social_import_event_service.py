"""
Event bus + persistence for social import SSE streams.
"""

from __future__ import annotations

import asyncio
from typing import Any, Dict, List, Optional

from app.services.social_import_job_store import SocialImportJobStore
from app.utils.sse_queue import discard_subscriber, fanout


class SocialImportEventService:
    """Broadcast social import events to live subscribers and persist for replay."""

    _subscribers: Dict[str, List[asyncio.Queue]] = {}
    _lock: asyncio.Lock = asyncio.Lock()

    @classmethod
    async def add_subscriber(cls, job_id: str, queue: asyncio.Queue) -> None:
        async with cls._lock:
            cls._subscribers.setdefault(job_id, []).append(queue)

    @classmethod
    async def remove_subscriber(cls, job_id: str, queue: asyncio.Queue) -> None:
        async with cls._lock:
            queues = cls._subscribers.get(job_id)
            if not queues:
                return
            if queue in queues:
                queues.remove(queue)
            if not queues:
                cls._subscribers.pop(job_id, None)
            # Drain the queue and drop its byte-ledger entry (see
            # sse_queue.discard_subscriber): a disconnected client's
            # buffered events must not stay pinned by the ledger's strong
            # reference.
            discard_subscriber(queue)

    @classmethod
    async def publish(
        cls,
        db,
        *,
        job_id: str,
        user_id: str,
        event_type: str,
        payload: Dict[str, Any],
    ) -> Dict[str, Any]:
        persisted = await SocialImportJobStore.create_event(
            db,
            job_id=job_id,
            user_id=user_id,
            event_type=event_type,
            payload=payload,
        )

        event = {
            "id": persisted.get("id"),
            "type": event_type,
            "data": payload,
            "created_at": persisted.get("created_at"),
        }

        async with cls._lock:
            queues = list(cls._subscribers.get(job_id, []))

        # Same non-blocking fan-out policy as the in-memory stores. Replay here
        # stays Postgres-backed (Last-Event-ID), so a dropped subscriber loses
        # nothing: it reconnects and replays from its last id.
        dropped = fanout(event, queues)
        if dropped:
            async with cls._lock:
                live = cls._subscribers.get(job_id)
                if live is not None:
                    for queue in dropped:
                        if queue in live:
                            live.remove(queue)
                    if not live:
                        cls._subscribers.pop(job_id, None)

        return event

    @staticmethod
    async def replay(
        db,
        *,
        job_id: str,
        user_id: str,
        after_id: Optional[int] = None,
    ) -> List[Dict[str, Any]]:
        rows = await SocialImportJobStore.list_events(
            db,
            job_id=job_id,
            user_id=user_id,
            after_id=after_id,
        )
        events: List[Dict[str, Any]] = []
        for row in rows:
            events.append(
                {
                    "id": row.get("id"),
                    "type": row.get("event_type"),
                    "data": row.get("payload") or {},
                    "created_at": row.get("created_at"),
                }
            )
        return events
