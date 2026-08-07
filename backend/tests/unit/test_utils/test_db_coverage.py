"""Residual branch coverage for app.utils.db helpers.

The sibling test_db_connection_retry.py covers the reconnect wrappers'
main paths; this file covers the remaining branches: jsonb_contains with a
string value, the retry-exhausted sync path, empty-list/dict unwrap shapes,
and the scalar/dict RPC-bool unwraps.
"""

import httpx
import pytest

from app.utils.db import (
    execute_with_reconnect,
    jsonb_contains,
    run_sync_with_reconnect,
    unwrap_rpc_bool,
    unwrap_rpc_result,
)


def test_jsonb_contains_wraps_string_value_in_list():
    calls = []

    class _Builder:
        def contains(self, column, value):
            calls.append((column, value))
            return self

    assert jsonb_contains(_Builder(), "tags", "solo") is not None
    assert calls == [("tags", '["solo"]')]


def test_jsonb_contains_serializes_list_to_json_array_literal():
    calls = []

    class _Builder:
        def contains(self, column, value):
            calls.append((column, value))
            return self

    assert jsonb_contains(_Builder(), "tags", ["solo", "trip"]) is not None
    assert calls == [("tags", '["solo", "trip"]')]


def test_unwrap_rpc_result_empty_list_returns_none():
    assert unwrap_rpc_result([]) is None


def test_unwrap_rpc_result_plain_list_takes_first_row():
    assert unwrap_rpc_result([{"a": 1}, {"a": 2}]) == {"a": 1}


def test_unwrap_rpc_result_key_from_dict_payload():
    assert unwrap_rpc_result({"count": 7}, key="count") == 7


def test_unwrap_rpc_result_response_object_shape():
    class _Resp:
        data = [{"count": 3}]

    assert unwrap_rpc_result(_Resp(), key="count") == 3


def test_unwrap_rpc_bool_falls_back_to_reserved_key():
    assert unwrap_rpc_bool({"reserved": True}, "reserve_usage") is True


def test_unwrap_rpc_bool_uses_function_name_key():
    assert unwrap_rpc_bool({"reserve_usage": False}, "reserve_usage") is False


def test_unwrap_rpc_bool_scalar_passthrough():
    assert unwrap_rpc_bool("yes", "anything") is True
    assert unwrap_rpc_bool("", "anything") is False


@pytest.mark.asyncio
async def test_execute_with_reconnect_exhausted_logs_and_raises(monkeypatch):
    """The sync twin's retries-exhausted branch logs the operator hint and
    re-raises; the async loop-exit (max_retries=-1) returns None without
    attempting anything."""
    from app.db.connection import SupabaseDB

    monkeypatch.setattr(
        SupabaseDB, "rebuild_service_client", staticmethod(lambda _stale=None: object())
    )

    def builder(d):
        raise httpx.RemoteProtocolError("goaway")

    with pytest.raises(httpx.RemoteProtocolError):
        await execute_with_reconnect(builder, object(), backoff_seconds=0)

    # max_retries=-1 -> range(0): the loop never runs.
    assert await execute_with_reconnect(lambda d: "never", object(), max_retries=-1) is None


def test_run_sync_with_reconnect_exhausted_logs_and_raises(monkeypatch):
    from app.db.connection import SupabaseDB

    monkeypatch.setattr(
        SupabaseDB, "rebuild_service_client", staticmethod(lambda _stale=None: object())
    )

    def fn(d):
        raise httpx.RemoteProtocolError("goaway")

    with pytest.raises(httpx.RemoteProtocolError):
        run_sync_with_reconnect(fn, object(), backoff_seconds=0)

    # max_retries=-1 -> range(0): the loop never runs.
    assert run_sync_with_reconnect(lambda d: "never", object(), max_retries=-1) is None
