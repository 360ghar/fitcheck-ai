"""Coverage-completing tests for token_refresh_service.

Sibling to test_token_refresh_service.py: this file pins the two remaining
uncovered branches — a follower whose in-flight refresh finished with neither
a result nor an error (AUTH_REFRESH_FAILED), and clear_token_cache on state
that is absent or already completed (no cancellation error injected).
"""

from unittest.mock import Mock

import pytest

from app.core.exceptions import AuthenticationError
from app.services import token_refresh_service as svc


@pytest.fixture(autouse=True)
def reset_state():
    svc._inflight_refreshes.clear()
    svc._locks.clear()
    svc._token_cache.clear()
    yield
    svc._inflight_refreshes.clear()
    svc._locks.clear()
    svc._token_cache.clear()


@pytest.mark.asyncio
async def test_waiter_raises_auth_failed_when_inflight_completed_without_result():
    """An in-flight entry whose event fired but carries neither a result nor
    an error must not hang the follower or return a bare None."""
    client = Mock()
    token = "orphan-token"
    inflight = svc._InflightRefresh()
    inflight.event.set()  # completed, but no payload recorded
    svc._inflight_refreshes[svc._hash_token(token)] = inflight

    with pytest.raises(AuthenticationError) as exc_info:
        await svc.refresh_token_with_deduplication(client, token)

    assert exc_info.value.error_code == "AUTH_REFRESH_FAILED"
    client.auth.refresh_session.assert_not_called()


@pytest.mark.asyncio
async def test_clear_token_cache_unknown_token_is_noop():
    await svc.clear_token_cache("never-seen-token")

    assert svc.get_cache_stats()["inflight_count"] == 0


@pytest.mark.asyncio
async def test_clear_token_cache_keeps_completed_inflight_untouched():
    token = "done-token"
    inflight = svc._InflightRefresh()
    inflight.event.set()
    svc._inflight_refreshes[svc._hash_token(token)] = inflight

    await svc.clear_token_cache(token)

    assert inflight.error is None
    assert svc.get_cache_stats()["inflight_count"] == 0
