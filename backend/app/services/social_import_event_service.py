"""
Event bus + persistence for social import SSE streams.
"""

from __future__ import annotations

import asyncio
from typing import Any, Dict, List, Optional

from app.services.social_import_job_store import SocialImportJobStore


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

        for queue in queues:
            try:
                await queue.put(event)
            except Exception:
                continue

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
