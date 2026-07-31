"""UTC datetime helpers.

Centralizes timezone-aware UTC timestamp creation so services stop mixing
naive ``datetime.utcnow()`` calls with aware variants, which can produce
subtly different ISO strings and drift across modules.
"""

from __future__ import annotations

from datetime import date, datetime, timezone
from typing import Any, Optional


def utcnow() -> datetime:
    """Return a timezone-aware UTC datetime."""
    return datetime.now(timezone.utc)


def utcnow_iso() -> str:
    """Return an ISO-8601 UTC timestamp string."""
    return utcnow().isoformat()


def utc_today() -> date:
    """Return today's UTC date."""
    return utcnow().date()


def parse_utc_datetime(value: Any) -> Optional[datetime]:
    """Parse an ISO-8601 timestamp into an aware UTC datetime, or None.

    PostgREST returns timestamps as ISO strings with a ``Z`` suffix (which
    ``datetime.fromisoformat`` rejects) or as naive strings when the column
    has no timezone. ``parse_utc_datetime`` normalizes both so callers stop
    hand-rolling the same ``str(value).replace("Z", "+00:00")`` dance.
    """
    if isinstance(value, datetime):
        # Always normalize to UTC, not just to "aware": an aware input in
        # another zone must be converted, or callers silently compare mixed
        # zones.
        return (
            value.replace(tzinfo=timezone.utc)
            if value.tzinfo is None
            else value.astimezone(timezone.utc)
        )
    if not value:
        return None
    try:
        parsed = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except (TypeError, ValueError):
        return None
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=timezone.utc)
    return parsed.astimezone(timezone.utc)
