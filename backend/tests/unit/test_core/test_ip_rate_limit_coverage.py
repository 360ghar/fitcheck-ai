"""Residual branch coverage for app.core.ip_rate_limit.

The sibling test_ip_rate_limit_client_ip.py covers client-IP resolution and
auth-rate-limit checks; this file covers the demo-operation context manager's
limit-exceeded raise and the usage-stats reader.
"""

from datetime import timedelta

import pytest

from app.core import ip_rate_limit
from app.core.exceptions import RateLimitError
from app.core.ip_rate_limit import (
    RATE_LIMIT_WINDOW,
    get_ip_usage_stats,
    increment_ip_usage,
    ip_rate_limited_operation,
)
from app.utils.datetime_util import utcnow


@pytest.fixture(autouse=True)
def _reset_ip_usage():
    ip_rate_limit._ip_usage.clear()
    yield
    ip_rate_limit._ip_usage.clear()


@pytest.mark.asyncio
async def test_ip_rate_limited_operation_raises_when_limit_exceeded():
    ip = "203.0.113.7"
    # 3 is the daily extraction limit; seed 3 fresh usages.
    for _ in range(3):
        await increment_ip_usage(ip, "extraction")

    with pytest.raises(RateLimitError, match="limit"):
        async with ip_rate_limited_operation(_request(ip), "extraction"):
            pass  # pragma: no cover - never reached


@pytest.mark.asyncio
async def test_ip_rate_limited_operation_yields_on_allowed():
    ip = "203.0.113.8"

    async with ip_rate_limited_operation(_request(ip), "extraction") as check:
        assert check["allowed"] is True
        assert check["remaining"] == 3

    # The usage was incremented once the block ran.
    assert (await get_ip_usage_stats(ip))["extraction"]["used"] == 1


@pytest.mark.asyncio
async def test_get_ip_usage_stats_prunes_stale_entries():
    ip = "203.0.113.9"
    # One fresh usage and one older than the 24h window.
    await increment_ip_usage(ip, "extraction")
    ip_rate_limit._ip_usage[ip]["try_on"].append(utcnow() - RATE_LIMIT_WINDOW - timedelta(minutes=1))

    stats = await get_ip_usage_stats(ip)

    assert stats["extraction"] == {"used": 1, "limit": 3, "remaining": 2}
    # The stale try_on entry was pruned.
    assert stats["try_on"] == {"used": 0, "limit": 2, "remaining": 2}
    assert stats["photoshoot"] == {"used": 0, "limit": 1, "remaining": 1}


def _request(ip: str):
    """Minimal FastAPI Request stand-in exposing .client and .headers."""
    class _Client:
        host = ip

    class _FakeRequest:
        client = _Client()
        headers = {}

    return _FakeRequest()


def _seed_ip(ip: str, age_hours: float):
    """Seed a usage entry with a controlled age."""
    ip_rate_limit._ip_usage[ip]["auth_login"].append(
        utcnow() - timedelta(hours=age_hours)
    )


@pytest.mark.asyncio
async def test_prune_sweeps_keys_without_fresh_entries(monkeypatch):
    """A1-10: once the map passes the sweep threshold, keys with no fresh
    entries are dropped so per-IP state cannot grow forever."""
    monkeypatch.setattr(ip_rate_limit, "_IP_SWEEP_THRESHOLD", 1)
    for i in range(5):
        _seed_ip(f"10.0.0.{i}", age_hours=25.0)
    # The active IP has a fresh entry and must survive the sweep.
    await increment_ip_usage("10.0.0.99", "extraction")
    await ip_rate_limit.check_ip_rate_limit("10.0.0.99", "extraction")
    assert set(ip_rate_limit._ip_usage.keys()) == {"10.0.0.99"}


@pytest.mark.asyncio
async def test_prune_keeps_keys_with_fresh_entries(monkeypatch):
    """A1-10: a key with a fresh entry survives the sweep."""
    monkeypatch.setattr(ip_rate_limit, "_IP_SWEEP_THRESHOLD", 1)
    _seed_ip("10.0.0.1", age_hours=0.1)  # fresh
    _seed_ip("10.0.0.2", age_hours=25.0)  # stale
    await ip_rate_limit.check_ip_rate_limit("10.0.0.99", "extraction")
    assert "10.0.0.1" in ip_rate_limit._ip_usage
    assert "10.0.0.2" not in ip_rate_limit._ip_usage


@pytest.mark.asyncio
async def test_prune_hard_cap_evicts_least_recently_active(monkeypatch):
    """A1-10: even when every key is fresh, the hard cap evicts the
    least-recently-active keys so memory stays bounded."""
    monkeypatch.setattr(ip_rate_limit, "_IP_SWEEP_THRESHOLD", 0)
    monkeypatch.setattr(ip_rate_limit, "_MAX_TRACKED_IPS", 3)
    # Key 10.0.0.1 is least recently active; 10.0.0.4 the most. All entries
    # are kept within the auth (1h) window so the per-operation prune does not
    # drop them first — the cap must do the eviction.
    _seed_ip("10.0.0.1", age_hours=0.9)
    _seed_ip("10.0.0.2", age_hours=0.5)
    _seed_ip("10.0.0.3", age_hours=0.2)
    _seed_ip("10.0.0.4", age_hours=0.05)
    cutoff = utcnow() - ip_rate_limit.RATE_LIMIT_WINDOW
    async with ip_rate_limit._lock:
        ip_rate_limit._prune_ip_usage_locked(cutoff)
    assert len(ip_rate_limit._ip_usage) == 3
    assert "10.0.0.1" not in ip_rate_limit._ip_usage
    assert "10.0.0.4" in ip_rate_limit._ip_usage


@pytest.mark.asyncio
async def test_auth_prune_preserves_still_valid_demo_reservations(monkeypatch):
    """A5-10: an auth-rate-limit check prunes with the 1h auth window, but it
    must NOT evict an IP whose only entries are still-valid 24h demo
    reservations — otherwise a caller could reset their daily demo quota just
    by making an auth request."""
    monkeypatch.setattr(ip_rate_limit, "_IP_SWEEP_THRESHOLD", 1)
    # A demo extraction reservation made 2h ago is outside the 1h auth window
    # but INSIDE the 24h demo window — it is still valid quota.
    await increment_ip_usage("198.51.100.7", "extraction")
    ip_rate_limit._ip_usage["198.51.100.7"]["extraction"] = [
        utcnow() - timedelta(hours=2)
    ]
    # An unrelated IP with only a stale 25h-old auth entry must be swept.
    ip_rate_limit._ip_usage["198.51.100.8"]["auth_login"].append(
        utcnow() - timedelta(hours=25)
    )

    await ip_rate_limit.check_auth_rate_limit("198.51.100.9", "login")

    # The demo-only IP survived the auth-triggered sweep (its demo slot is
    # still valid); the genuinely stale auth IP was dropped.
    assert "198.51.100.7" in ip_rate_limit._ip_usage
    assert "198.51.100.8" not in ip_rate_limit._ip_usage
