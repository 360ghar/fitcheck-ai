"""
Tests for token refresh deduplication.

The service deduplicates only in-flight refreshes for the same refresh token and
intentionally does not keep a long-lived cache of refreshed tokens.
"""

import asyncio
import time
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
):
    """Concurrent refreshes for one token should share a single upstream call."""

    def delayed_refresh(_token):
        time.sleep(0.05)
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = delayed_refresh

    refresh_token = "shared_refresh_token"
    tasks = [
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
        for _ in range(5)
    ]

    results = await asyncio.gather(*tasks)

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

    def delayed_refresh(_token):
        time.sleep(0.05)
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = delayed_refresh

    tasks = [
        refresh_token_with_deduplication(mock_supabase_client, "token_one"),
        refresh_token_with_deduplication(mock_supabase_client, "token_two"),
        refresh_token_with_deduplication(mock_supabase_client, "token_three"),
    ]

    results = await asyncio.gather(*tasks)

    assert len(results) == 3
    assert mock_supabase_client.auth.refresh_session.call_count == 3


@pytest.mark.asyncio
async def test_supabase_error_is_shared_for_waiters(mock_supabase_client):
    """If leader refresh fails, waiters should receive the same auth error."""

    def delayed_error(_token):
        time.sleep(0.05)
        raise Exception("Supabase error")

    mock_supabase_client.auth.refresh_session.side_effect = delayed_error

    refresh_token = "test_error_token"
    tasks = [
        refresh_token_with_deduplication(mock_supabase_client, refresh_token),
        refresh_token_with_deduplication(mock_supabase_client, refresh_token),
    ]

    results = await asyncio.gather(*tasks, return_exceptions=True)

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

    def slow_refresh(_token):
        time.sleep(0.5)
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    refresh_token = "slow_token"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )

    await asyncio.sleep(0.02)

    with pytest.raises(AuthenticationError) as exc_info:
        await refresh_token_with_deduplication(mock_supabase_client, refresh_token)

    assert exc_info.value.error_code == "AUTH_REFRESH_TIMEOUT"

    # Leader still completes successfully.
    leader_result = await leader_task
    assert leader_result["access_token"] == "new_access_token_123"


@pytest.mark.asyncio
async def test_clear_token_cache_cancels_inflight(mock_supabase_client, monkeypatch):
    """clear_token_cache should cancel any in-flight refresh for that token."""
    monkeypatch.setattr(svc, "LOCK_TIMEOUT_SECONDS", 1)

    def slow_refresh(_token):
        time.sleep(0.3)
        return Mock(session=None)

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    refresh_token = "cancel_me"
    leader_task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, refresh_token)
    )

    await asyncio.sleep(0.05)
    await clear_token_cache(refresh_token)

    with pytest.raises(AuthenticationError) as exc_info:
        await leader_task

    assert exc_info.value.error_code in {"AUTH_REFRESH_CANCELLED", "AUTH_TOKEN_EXPIRED"}


@pytest.mark.asyncio
async def test_cache_stats_reports_inflight(mock_supabase_client, mock_auth_response):
    """Stats should expose in-flight counts and no long-lived cache entries."""

    def slow_refresh(_token):
        time.sleep(0.2)
        return mock_auth_response

    mock_supabase_client.auth.refresh_session.side_effect = slow_refresh

    task = asyncio.create_task(
        refresh_token_with_deduplication(mock_supabase_client, "stats_token")
    )
    await asyncio.sleep(0.02)

    stats = get_cache_stats()
    assert stats["cache_size"] == 0
    assert stats["inflight_count"] >= 1

    await task


def test_hash_token_consistency():
    token = "test_token_123"
    hash1 = _hash_token(token)
    hash2 = _hash_token(token)

    assert hash1 == hash2
    assert len(hash1) == 16
