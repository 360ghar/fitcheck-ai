"""Short-TTL in-process cache for the auth hot path.

``get_current_user`` (app/api/v1/deps.py) runs a ``users`` PK select on
nearly every authenticated request (~140 routes). On cold containers the
logs show every one of those reads clustering at 400-1500 ms; the profile
row itself changes rarely, so a small per-process TTL cache removes the
roundtrip for the burst of parallel requests that follows app launch and
container restart.

Design constraints:

- **TTL, not forever.** 30 s bounds staleness for any writer that forgets
  to invalidate (external admin edits, SQL console fixes).
- **Explicit invalidation** on the known writers: self-profile update,
  avatar upload, admin user update, admin quota override, account
  deletion. Suspension must take effect immediately, so every writer of
  ``is_active`` invalidates; the cached value still carries ``is_active``
  and the suspension check runs on the cached dict exactly as before.
- **Single-flight.** A cold-cache burst (5 parallel requests after launch)
  must produce ONE DB read, not five: concurrent callers await the same
  in-flight lookup via an asyncio lock keyed by user id.
- **Copy-out semantics.** Callers mutate the returned dict (deps.py injects
  the token email); each ``get`` returns a fresh shallow copy so one
  request's mutation never leaks into another's response.
- **Bounded memory.** Max ~2048 entries with FIFO eviction; profiles are
  small dicts, so this stays well under a megabyte.
"""

from __future__ import annotations

import asyncio
import logging
import time
from collections import OrderedDict
from typing import Any, Dict, Optional

logger = logging.getLogger(__name__)

_TTL_SECONDS = 30.0
_MAX_ENTRIES = 2048

_cache: "OrderedDict[str, Dict[str, Any]]" = OrderedDict()
_expiry: Dict[str, float] = {}
_locks: Dict[str, asyncio.Lock] = {}


def _now() -> float:
    return time.monotonic()


def get(user_id: str) -> Optional[Dict[str, Any]]:
    """Return a copy of the cached profile, or None on miss/expiry."""
    expires_at = _expiry.get(user_id)
    if expires_at is None or _now() >= expires_at:
        return None
    entry = _cache.get(user_id)
    if not isinstance(entry, dict):
        return None
    _cache.move_to_end(user_id)
    return dict(entry)


def set_(user_id: str, profile: Dict[str, Any]) -> None:
    """Cache a copy of ``profile`` for the TTL window."""
    if not isinstance(profile, dict):
        return
    _cache[user_id] = dict(profile)
    _expiry[user_id] = _now() + _TTL_SECONDS
    _cache.move_to_end(user_id)
    while len(_cache) > _MAX_ENTRIES:
        evicted, _ = _cache.popitem(last=False)
        _expiry.pop(evicted, None)
        _locks.pop(evicted, None)


def invalidate(user_id: str) -> None:
    """Drop the cached profile (call after any write to that users row)."""
    _cache.pop(user_id, None)
    _expiry.pop(user_id, None)


def clear() -> None:
    """Drop all cached profiles (tests, admin bulk operations)."""
    _cache.clear()
    _expiry.clear()
    _locks.clear()


def lock_for(user_id: str) -> asyncio.Lock:
    """Per-user single-flight lock for cold-cache lookups."""
    lock = _locks.get(user_id)
    if lock is None:
        lock = asyncio.Lock()
        # Bound the lock map alongside the cache; leftover locks for evicted
        # users are harmless (an unlocked asyncio.Lock is just an object).
        if len(_locks) > _MAX_ENTRIES * 2:
            _locks.clear()
            lock = asyncio.Lock()
        _locks[user_id] = lock
    return lock


async def get_or_load(user_id: str, loader) -> Optional[Dict[str, Any]]:
    """Return the cached profile or load it once under the single-flight lock.

    ``loader`` is an async callable returning the profile dict (or None when
    the row does not exist). Concurrent callers for the same user share one
    load; the winner's result is cached for the TTL window.
    """
    cached = get(user_id)
    if cached is not None:
        return cached

    async with lock_for(user_id):
        cached = get(user_id)
        if cached is not None:
            return cached
        profile = await loader()
        if profile is not None:
            set_(user_id, profile)
        return profile
