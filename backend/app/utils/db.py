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


# ============================================================================
# Missing-RPC (migration gap) detection — shared by quota admission paths
#
# PostgREST answers a missing rpc() with PGRST202 ("Could not find the
# function ... in the schema cache") when the hosted-Supabase migration that
# creates the function was never applied. Detection + log-hint text live here
# so ai_settings_service and subscription_service agree on the case handling
# and the wording. The detail is for OPERATORS ONLY: it names internal
# functions and migration files and must never be sent to a client.
# ============================================================================

_MISSING_RPC_MARKERS = ("pgrst202", "could not find the function")

# Client-facing copy for quota-admission failures. The raw RPC error / which
# function is missing stays in server logs; users only ever see this friendly
# 503 message (observed 2026-07-31: every batch-extract returned 500 because
# migrations 022/024/026 had not been applied to the hosted DB).
QUOTA_UNAVAILABLE_CLIENT_MESSAGE = (
    "AI services are temporarily unavailable. Please try again in a few moments."
)


def is_pgrst202_missing_rpc(error: Exception) -> bool:
    """True when a postgrest error means the RPC is absent (migration not applied).

    Both markers are compared against the lowercased error text so the match is
    case-insensitive on both sides (real PGRST202 bodies capitalise the phrase).
    """
    text = str(error).lower()
    return any(marker in text for marker in _MISSING_RPC_MARKERS)


def missing_rpc_log_hint(function_name: str) -> str:
    """Operator-facing log hint naming the missing RPC and the migrations.

    LOGS ONLY — never put this string in a client-facing error message.
    """
    return (
        f"AI quota reservation is unavailable: the '{function_name}' database "
        "function is missing (hosted Supabase migrations 022/024/026 not "
        "applied). Apply backend/db/supabase/migrations/022_wave_b_hardening.sql, "
        "024_atomic_daily_quota_reservations.sql and "
        "026_harden_rpc_privileges.sql to restore AI admission."
    )
