"""
Helpers for working with postgrest-py query results.
"""

from typing import Any, Dict, Optional


def persistence_db(db: Any) -> Any:
    """The hosted Supabase client, or None for sentinel DBs.

    Direct-call tests and non-HTTP callers pass a sentinel DB object; those
    paths must stay explicitly in-memory rather than fail while trying to
    persist through an invalid client.
    """
    return db if hasattr(db, "table") else None


def maybe_single_data(result: Any) -> Optional[Dict[str, Any]]:
    """
    Safely extract `.data` from a `.maybe_single().execute()` result.

    postgrest-py returns a bare `None` (not a response object) when the query
    matches zero rows, so `result.data` raises `AttributeError` unless `result`
    itself is checked first.
    """
    return result.data if result else None


def unwrap_rpc_result(result: Any, key: Optional[str] = None) -> Any:
    """Normalize a postgrest-py RPC result into a scalar.

    RPC responses arrive as a response object (``.data`` is a list of dicts),
    a bare list, a bare dict, or a scalar depending on the function's return
    type. This unwraps the first two shapes and, when ``key`` is given, returns
    ``row[key]`` (or None) for a dict payload. Services that previously
    hand-rolled the same list/dict unwrap (quota reservations, referral
    redemption) use this to stay consistent.
    """
    data = getattr(result, "data", result)
    if isinstance(data, list):
        data = data[0] if data else None
    if key is not None and isinstance(data, dict):
        data = data.get(key)
    return data


def unwrap_rpc_bool(result: Any, function_name: str) -> bool:
    """Extract a boolean from a scalar-returning RPC, robust to result shape.

    PostgREST keys a scalar-returning function's result by the function name
    (``[{"reserve_usage": true}]``), while TABLE-returning functions use the
    column name (``[{"reserved": true}]``). Accept either key, plus a bare
    scalar, so callers do not silently fail-closed when the function
    signature changes shape.
    """
    data = unwrap_rpc_result(result)
    if isinstance(data, dict):
        value = data.get(function_name)
        if value is None:
            value = data.get("reserved")
        return bool(value)
    return bool(data)
