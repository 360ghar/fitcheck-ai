"""UTC datetime helpers.

Centralizes timezone-aware UTC timestamp creation so services stop mixing
naive ``datetime.utcnow()`` calls with aware variants, which can produce
subtly different ISO strings and drift across modules.
"""

from __future__ import annotations

from datetime import date, datetime, timezone


def utcnow() -> datetime:
    """Return a timezone-aware UTC datetime."""
    return datetime.now(timezone.utc)


def utcnow_iso() -> str:
    """Return an ISO-8601 UTC timestamp string."""
    return utcnow().isoformat()


def utc_today() -> date:
    """Return today's UTC date."""
    return utcnow().date()
