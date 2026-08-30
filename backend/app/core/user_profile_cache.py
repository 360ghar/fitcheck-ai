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

_MISSING = object()
_cache: "OrderedDict[str, Dict[str, Any] | object]" = OrderedDict()
_expiry: Dict[str, float] = {}
_locks: Dict[str, asyncio.Lock] = {}
_generation = 0


def _now() -> float:
    return time.monotonic()


def _get_entry(user_id: str) -> tuple[bool, Optional[Dict[str, Any]]]:
    """Return whether the cached entry exists and its copied profile."""
    expires_at = _expiry.get(user_id)
    if expires_at is None or _now() >= expires_at:
        _cache.pop(user_id, None)
        _expiry.pop(user_id, None)
        return False, None
    entry = _cache.get(user_id)
    if entry is _MISSING:
        _cache.move_to_end(user_id)
        return True, None
    if not isinstance(entry, dict):
        _cache.pop(user_id, None)
        _expiry.pop(user_id, None)
        return False, None
    _cache.move_to_end(user_id)
    return True, dict(entry)


def get(user_id: str) -> Optional[Dict[str, Any]]:
    """Return a copy of the cached profile, or None on miss/negative hit."""
    _, profile = _get_entry(user_id)
    return profile


def _set_entry(user_id: str, profile: Optional[Dict[str, Any]]) -> None:
    """Store a positive or negative lookup result for the TTL window."""
    _cache[user_id] = dict(profile) if isinstance(profile, dict) else _MISSING
    _expiry[user_id] = _now() + _TTL_SECONDS
    _cache.move_to_end(user_id)
    while len(_cache) > _MAX_ENTRIES:
        evicted, _ = _cache.popitem(last=False)
        _expiry.pop(evicted, None)


def set_(user_id: str, profile: Dict[str, Any]) -> None:
    """Cache a copy of the profile for the TTL window."""
    if isinstance(profile, dict):
        _set_entry(user_id, profile)


def invalidate(user_id: str) -> None:
    """Drop the cached profile (call after any write to that users row)."""
    global _generation
    _generation += 1
    _cache.pop(user_id, None)
    _expiry.pop(user_id, None)


def clear() -> None:
    """Drop all cached profiles (tests, admin bulk operations)."""
    global _generation
    _generation += 1
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
    hit, cached = _get_entry(user_id)
    if hit:
        return cached

    while True:
        async with lock_for(user_id):
            hit, cached = _get_entry(user_id)
            if hit:
                return cached
            generation = _generation
            profile = await loader()
            if generation != _generation:
                continue
            _set_entry(user_id, profile)
            return dict(profile) if isinstance(profile, dict) else None
