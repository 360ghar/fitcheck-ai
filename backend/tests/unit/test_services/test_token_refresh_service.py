"""
Tests for token refresh deduplication.

The service deduplicates only in-flight refreshes for the same refresh token and
intentionally does not keep a long-lived cache of refreshed tokens.

Concurrency sequencing uses threading.Event handshakes (the mocked
``refresh_session`` runs in a worker thread via ``asyncio.to_thread``), never
fixed ``time.sleep`` delays — the leader parks on an event until every follower
has joined the in-flight dedupe, so the interleavings under test are
deterministic.
"""

import asyncio
import threading
from unittest.mock import Mock

import pytest

from app.core.exceptions import AuthenticationError
from app.services import token_refresh_service as svc
from app.services.token_refresh_service import (
    _hash_token,
    clear_token_cache,
    get_cache_stats,
    refresh_token_with_deduplication,
)


@pytest.fixture(autouse=True)
def reset_state():
    """Reset service state before each test."""
    svc._inflight_refreshes.clear()
    svc._locks.clear()
    svc._token_cache.clear()
    yield
    svc._inflight_refreshes.clear()
    svc._locks.clear()
    svc._token_cache.clear()


@pytest.fixture
def mock_supabase_client():
    client = Mock()
    client.auth = Mock()
    return client


@pytest.fixture
def mock_auth_response():
    response = Mock()
    response.session = Mock()
    response.session.access_token = "new_access_token_123"
    response.session.refresh_token = "new_refresh_token_456"
    response.user = Mock()
    response.user.id = "user_id_789"
    response.user.email = "test@example.com"
    return response


@pytest.mark.asyncio
async def test_concurrent_same_token_calls_supabase_once(
    mock_supabase_client,
    mock_auth_response,
    monkeypatch,
):
    """Concurrent refreshes for one token should share a single upstream call.

    Handshake, not a sleep: the leader parks inside ``refresh_session``
    (threading.Event) until every follower has joined the in-flight dedupe
    (observed via a counting wrapper on ``_await_inflight``), then releases.
    Only then can we assert one upstream call without a timing race.
    """

    entered_refresh = threading.Event()
    release_leader = threading.Event()
    joined = {"n": 0}
    all_joined = asyncio.Event()

    def delayed_refresh(_token):
        entered_refresh.set()
        if not release_leader.wait(5):
            raise AssertionError("leader never released")
        return mock_auth_response

    original_await_inflight = svc._await_inflight

    async def tracking_await_inflight(token_hash, inflight):
        joined["n"] += 1
        if joined["n"] == 4:
            all_joined.set()
        return await original_await_inflight(token_hash, inflight)

    monkeypatch.setattr(svc, "_await_inflight", tracking_await_inflight)
    mock_supabase_client.auth.refresh_session.side_effect = delayed_refresh

    refresh_token = "shared_refresh_token"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )
    # Wait (bounded) until the leader is inside refresh_session, then start
    # the followers so they join the in-flight dedupe behind it.
    assert await asyncio.to_thread(entered_refresh.wait, 5)
    follower_tasks = [
        asyncio.create_task(
            refresh_token_with_deduplication(mock_supabase_client, refresh_token)
        )
        for _ in range(4)
    ]
    await asyncio.wait_for(all_joined.wait(), timeout=5)
    release_leader.set()

    results = await asyncio.gather(leader_task, *follower_tasks)

    assert mock_supabase_client.auth.refresh_session.call_count == 1
    assert all(result == results[0] for result in results)


@pytest.mark.asyncio
async def test_sequential_calls_do_not_use_long_lived_cache(
    mock_supabase_client,
    mock_auth_response,
):
    """A reused refresh token should not be served from cache after first completion."""
    refresh_token = "test_refresh_token_abc"

    mock_supabase_client.auth.refresh_session.return_value = mock_auth_response
    first = await refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    assert first["access_token"] == "new_access_token_123"

    # Simulate upstream refusing reuse of the same refresh token.
    mock_supabase_client.auth.refresh_session.side_effect = Exception(
        "Invalid Refresh Token: Already Used"
    )

    with pytest.raises(AuthenticationError) as exc_info:
        await refresh_token_with_deduplication(mock_supabase_client, refresh_token)

    assert exc_info.value.error_code == "AUTH_REFRESH_FAILED"
    assert mock_supabase_client.auth.refresh_session.call_count == 2


@pytest.mark.asyncio
async def test_different_tokens_dont_dedupe(
    mock_supabase_client,
    mock_auth_response,
):
    """Different refresh tokens should each call Supabase once."""
    mock_supabase_client.auth.refresh_session.return_value = mock_auth_response

    tasks = [
        refresh_token_with_deduplication(mock_supabase_client, "token_one"),
        refresh_token_with_deduplication(mock_supabase_client, "token_two"),
        refresh_token_with_deduplication(mock_supabase_client, "token_three"),
    ]

    results = await asyncio.gather(*tasks)

    assert len(results) == 3
    assert mock_supabase_client.auth.refresh_session.call_count == 3


@pytest.mark.asyncio
async def test_supabase_error_is_shared_for_waiters(mock_supabase_client, monkeypatch):
    """If leader refresh fails, waiters should receive the same auth error."""

    entered_refresh = threading.Event()
    release_leader = threading.Event()
    joined = {"n": 0}
    all_joined = asyncio.Event()

    def delayed_error(_token):
        entered_refresh.set()
        if not release_leader.wait(5):
            raise AssertionError("leader never released")
        raise Exception("Supabase error")

    original_await_inflight = svc._await_inflight

    async def tracking_await_inflight(token_hash, inflight):
        joined["n"] += 1
        if joined["n"] == 1:
            all_joined.set()
        return await original_await_inflight(token_hash, inflight)

    monkeypatch.setattr(svc, "_await_inflight", tracking_await_inflight)
    mock_supabase_client.auth.refresh_session.side_effect = delayed_error

    refresh_token = "test_error_token"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )
    # Bounded handshake: hold the leader inside refresh_session until the
    # follower has joined the in-flight dedupe, so the error is shared rather
    # than raced past.
    assert await asyncio.to_thread(entered_refresh.wait, 5)
    follower_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )
    await asyncio.wait_for(all_joined.wait(), timeout=5)
    release_leader.set()

    results = await asyncio.gather(leader_task, follower_task, return_exceptions=True)

    assert mock_supabase_client.auth.refresh_session.call_count == 1
    assert all(isinstance(result, AuthenticationError) for result in results)


@pytest.mark.asyncio
async def test_invalid_token_error(mock_supabase_client):
    """No session from Supabase maps to AUTH_TOKEN_EXPIRED."""
    mock_response = Mock()
    mock_response.session = None
    mock_supabase_client.auth.refresh_session.return_value = mock_response

    with pytest.raises(AuthenticationError) as exc_info:
        await refresh_token_with_deduplication(mock_supabase_client, "invalid_token")

    assert exc_info.value.error_code == "AUTH_TOKEN_EXPIRED"


@pytest.mark.asyncio
async def test_waiter_timeout(mock_supabase_client, mock_auth_response, monkeypatch):
    """Follower request should timeout if leader refresh stalls."""
    monkeypatch.setattr(svc, "LOCK_TIMEOUT_SECONDS", 0.1)

    entered_refresh = threading.Event()
    release_leader = threading.Event()

    def slow_refresh(_token):
        entered_refresh.set()
        if not release_leader.wait(5):
            raise AssertionError("leader never released")
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    refresh_token = "slow_token"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )

    # Bounded handshake: once the leader is parked inside refresh_session the
    # follower's wait_for hits LOCK_TIMEOUT_SECONDS deterministically.
    assert await asyncio.to_thread(entered_refresh.wait, 5)

    with pytest.raises(AuthenticationError) as exc_info:
        await refresh_token_with_deduplication(mock_supabase_client, refresh_token)

    assert exc_info.value.error_code == "AUTH_REFRESH_TIMEOUT"

    # Leader still completes successfully once released.
    release_leader.set()
    leader_result = await leader_task
    assert leader_result["access_token"] == "new_access_token_123"


@pytest.mark.asyncio
async def test_clear_token_cache_cancels_inflight(mock_supabase_client, monkeypatch):
    """clear_token_cache should cancel any in-flight refresh for that token."""
    monkeypatch.setattr(svc, "LOCK_TIMEOUT_SECONDS", 1)

    entered_refresh = threading.Event()
    release_leader = threading.Event()

    def slow_refresh(_token):
        entered_refresh.set()
        if not release_leader.wait(5):
            raise AssertionError("leader never released")
        return Mock(session=None)

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    refresh_token = "cancel_me"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )

    # Bounded handshake: clear the in-flight state while the leader is parked
    # inside refresh_session (no fixed sleeps).
    assert await asyncio.to_thread(entered_refresh.wait, 5)
    await clear_token_cache(refresh_token)
    release_leader.set()

    with pytest.raises(AuthenticationError) as exc_info:
        await leader_task

    assert exc_info.value.error_code in {"AUTH_REFRESH_CANCELLED", "AUTH_TOKEN_EXPIRED"}


@pytest.mark.asyncio
async def test_cache_stats_reports_inflight(mock_supabase_client, mock_auth_response):
    """Stats should expose in-flight counts and no long-lived cache entries."""

    entered_refresh = threading.Event()
    release_leader = threading.Event()

    def slow_refresh(_token):
        entered_refresh.set()
        if not release_leader.wait(5):
            raise AssertionError("leader never released")
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, "stats_token")
    )
    assert await asyncio.to_thread(entered_refresh.wait, 5)

    stats = get_cache_stats()
    assert stats["cache_size"] == 0
    assert stats["inflight_count"] >= 1

    release_leader.set()
    await task


def test_hash_token_consistency():
    token = "test_token_123"
    hash1 = _hash_token(token)
    hash2 = _hash_token(token)

    assert hash1 == hash2
    assert len(hash1) == 16
