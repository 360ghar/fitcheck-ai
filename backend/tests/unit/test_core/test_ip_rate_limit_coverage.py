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
    """Minimal FastAPI Request stand-in exposing .client."""
    class _Client:
        host = ip

    class _FakeRequest:
        client = _Client()

    return _FakeRequest()
