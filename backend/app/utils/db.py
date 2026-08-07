"""
Helpers for working with postgrest-py query results.
"""

import asyncio
import inspect
import logging
import re
import time
from typing import Any, Callable, Dict, Optional, Tuple

import httpx

logger = logging.getLogger(__name__)


def safe_search_term(term: str) -> str:
    """Strip characters that break postgrest's .or_() filter syntax.

    The term is interpolated into `name.ilike.<term>`; PostgREST reserves
    `,` `(` `)` `*` as logical operators and `.` `:` as value separators.
    Stripping them keeps `%`/`_` as the intended ilike wildcards while
    preventing a crafted query from injecting extra filter clauses or 500ing
    the route. Shared by the items/outfits/blog search routes.
    """
    return re.sub(r"[(),*.:]", "", term)


def persistence_db(db: Any) -> Any:
    """The hosted Supabase client, or None for sentinel DBs.

    Direct-call tests and non-HTTP callers pass a sentinel DB object; those
    paths must stay explicitly in-memory rather than fail while trying to
    persist through an invalid client.
    """
    return db if hasattr(db, "table") else None


# =============================================================================
# Pooled-connection resilience
#
# supabase-py keeps ONE httpx pool per singleton client (SupabaseDB). When the
# Supabase gateway or a proxy between it and the app restarts / idles the
# connection, every subsequent request on that pool fails with an HTTP/2
# transport error (observed 2026-08-01: `<ConnectionTerminated error_code:1,
# last_stream_id:...>` on /items, /auth/oauth/sync, /outfits and usage
# increments - a process restart was the only thing that healed it). The
# helpers below detect that class of error and retry once through a freshly
# built client, which also heals all later requests.
# =============================================================================

_DB_TRANSIENT_ERRORS = (
    httpx.RemoteProtocolError,
    httpx.LocalProtocolError,
    httpx.ConnectError,
    httpx.ConnectTimeout,
    httpx.ReadError,
    httpx.ReadTimeout,
    httpx.WriteError,
    httpx.PoolTimeout,
)

# String fallback: postgrest/httpx versions can wrap the h2 exception without
# a matching isinstance type (the repr embeds `<ConnectionTerminated ...>`).
_DB_CONNECTION_TEXT_MARKERS = (
    "connectionterminated",
    "remote protocol error",
    "pool timeout",
    "connection reset by peer",
    "connection closed by peer",
    "peer closed connection",
    "server disconnected",
    "goaway",
    # Python `RuntimeError` from httpcore's HTTP/2 connection pool when the
    # SAME shared Supabase client is used concurrently: a coroutine iterating
    # the pool's deque while another pops/extends it. Transient - a retry
    # through a freshly built client heals it (observed 2026-08-03:
    # "Error checking limit for user ... deque mutated during iteration" ->
    # generate-outfit 500).
    "deque mutated during iteration",
    "list changed size during iteration",
    # h2 ProtocolError state-machine text when a dead connection receives
    # frames: "Invalid input StreamInputs.SEND_HEADERS in state 5" and
    # "Invalid input ConnectionInputs.RECV_DATA in state ConnectionState.CLOSED"
    # (observed 2026-08-03 on /referral/* and /subscription after a gateway
    # restart). Also covers the 2026-08-03 "Server disconnected" bursts.
    "invalid input",
)


def is_db_connection_error(exc: Exception) -> bool:
    """True when `exc` means the pooled Supabase connection is dead and the
    operation is worth one retry through a fresh client."""
    if isinstance(exc, _DB_TRANSIENT_ERRORS):
        return True
    text = str(exc).lower().strip()
    if text.isdigit():
        # Some h2/httpcore versions collapse a ConnectionTerminated to the
        # bare error code with no message text (observed 2026-08-03:
        # "Error getting subscription for user ...: 11" / "41" / "45" / "79"
        # / "81" - all ConnectionTerminated error_codes). A numeric-only
        # error text has no other meaning at these call sites; retry once
        # through a freshly built client.
        return True
    return any(marker in text for marker in _DB_CONNECTION_TEXT_MARKERS)


async def execute_with_reconnect(
    builder: Callable[[Any], Any],
    db: Any,
    *,
    extra: Optional[Dict[str, Any]] = None,
    max_retries: int = 1,
    backoff_seconds: float = 0.4,
) -> Any:
    """Run ``builder(db)`` in a worker thread; on a pooled-connection error,
    rebuild the Supabase singleton client and retry with the fresh client.

    ``builder`` receives the client and returns the query result (a plain
    function is called directly; an ``async def``/coroutine-returning callable
    is awaited). Example::

        result = await execute_with_reconnect(
            lambda d: d.table("items").select("*").execute(),
            db,
            extra={"operation": "list_items", "user_id": user_id},
        )

    Up to ``max_retries`` rebuild+retry cycles run with a short
    ``backoff_seconds`` sleep between them (default: 1 retry, no change from
    the original behavior). The retry only fires for connection-class errors;
    anything else (missing rows, permissions, RPC errors) propagates unchanged.

    The default of one immediate retry heals a blip but not a sustained
    outage; hot read paths (``list_items``, ``get_subscription``, users
    ``/me``, dashboard) pass ``max_retries=2`` so a 1-2 s gateway blip
    resolves without surfacing a 500 (observed 2026-08-04: /items 500 bursts
    where the first rebuilt client hit the same dead gateway).

    Note on retry semantics: a connection error can mean the server never got
    the request OR that the response was lost after the server committed it.
    For non-idempotent writes (e.g. a fresh ``outfits`` insert) the retry can
    therefore duplicate the row in the rare lost-response case - the same
    hazard a user-triggered manual retry already had, now automatic. Prefer
    wrapping reads and idempotent upserts (``on_conflict``) for exact-once
    semantics; wrap plain inserts knowing the tradeoff.
    """
    from app.db.connection import SupabaseDB  # local import avoids a cycle

    async def _attempt(d: Any) -> Any:
        if inspect.iscoroutinefunction(builder):
            # Coroutine builders run on the event loop (they schedule their
            # own to_thread calls internally).
            return await builder(d)
        # Plain callables run in a worker thread so the sync supabase client
        # never blocks the loop; a callable that RETURNS a coroutine (e.g. a
        # lambda wrapping an async function) is awaited on the loop after the
        # thread hands the coroutine back.
        outcome = await asyncio.to_thread(builder, d)
        if inspect.iscoroutine(outcome):
            outcome = await outcome
        return outcome

    attempt_db = db
    for attempt_no in range(max_retries + 1):
        try:
            return await _attempt(attempt_db)
        except Exception as exc:
            if not is_db_connection_error(exc):
                raise
            if attempt_no == max_retries:
                logger.warning(
                    "Supabase pooled connection error, retries exhausted",
                    extra={"db_error": str(exc)[:300], "max_retries": max_retries, **(extra or {})},
                )
                raise
            logger.warning(
                "Supabase pooled connection error, rebuilding client and retrying once",
                extra={
                    "db_error": str(exc)[:300],
                    "attempt": attempt_no + 1,
                    "max_retries": max_retries,
                    **(extra or {}),
                },
            )
            # Rebuild under the singleton lock off-thread so concurrent failing
            # requests share ONE fresh client. Passing the client we just saw fail
            # is what enables that sharing (see SupabaseDB.rebuild_service_client).
            attempt_db = await asyncio.to_thread(SupabaseDB.rebuild_service_client, attempt_db)
            await asyncio.sleep(backoff_seconds)


def run_sync_with_reconnect(
    fn: Callable[[Any], Any],
    db: Any,
    *,
    extra: Optional[Dict[str, Any]] = None,
    max_retries: int = 1,
    backoff_seconds: float = 0.4,
) -> Any:
    """Synchronous twin of :func:`execute_with_reconnect` for the few call
    sites that talk to the client directly without ``asyncio.to_thread``
    (e.g. ``auth._require_schema``)."""
    from app.db.connection import SupabaseDB

    attempt_db = db
    for attempt_no in range(max_retries + 1):
        try:
            return fn(attempt_db)
        except Exception as exc:
            if not is_db_connection_error(exc):
                raise
            if attempt_no == max_retries:
                logger.warning(
                    "Supabase pooled connection error (sync call), retries exhausted",
                    extra={"db_error": str(exc)[:300], "max_retries": max_retries, **(extra or {})},
                )
                raise
            logger.warning(
                "Supabase pooled connection error (sync call), rebuilding client and retrying once",
                extra={
                    "db_error": str(exc)[:300],
                    "attempt": attempt_no + 1,
                    "max_retries": max_retries,
                    **(extra or {}),
                },
            )
            # Rebuild under the singleton lock so concurrent failing requests
            # share ONE fresh client. Passing the client we just saw fail is what
            # enables that sharing (see SupabaseDB.rebuild_service_client).
            attempt_db = SupabaseDB.rebuild_service_client(attempt_db)
            time.sleep(backoff_seconds)


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


# ============================================================================
# Durable-job persistence (migration gap) detection
#
# Batch and photoshoot job creation mirror a durable summary row to
# `extraction_jobs` / `photoshoot_jobs` (migrations 016 / 023). When those
# migrations (or their columns/constraints) are missing on the hosted DB,
# postgrest-py raises a raw APIError (PGRST205 unknown table, 42703 unknown
# column, PGRST204 unknown column in the schema cache - the exact code
# observed 2026-08-07 when photoshoot_jobs.image_failures, migration 035,
# was missing - and 23514 CHECK violation). Services must wrap those raw
# errors into a friendly retryable 503 and log this operator hint - never
# send the raw DB text to a client. Same policy as the quota-RPC helpers
# above.
# ============================================================================

_MISSING_SCHEMA_MARKERS = ("pgrst205", "42703", "pgrst204")
# CHECK-violation marker for the extraction_jobs.generation_batch_size bound
# (016 allows <=10; 023/029 raise it to <=50/<=100 to match the API cap).
_CHECK_VIOLATION_MARKERS = ("23514", "valid_batch_size")


def is_missing_table_or_column(error: Exception) -> bool:
    """True when a postgrest error means the table/column is absent (migration gap)."""
    text = str(error).lower()
    return any(marker in text for marker in _MISSING_SCHEMA_MARKERS)


def job_persistence_migration_hint(table: str, error: Exception) -> str:
    """Operator-facing log hint for durable-job persistence migration gaps.

    Covers the two ways a hosted-Supabase migration gap breaks job creation:
    the table/columns do not exist (016/023/035 missing - PGRST205/42703/
    PGRST204) or the ``generation_batch_size`` CHECK is still the pre-023
    bound (<=10) while the API sends up to 50. Returns "" when the error is
    not a migration gap.

    LOGS ONLY — never put this string in a client-facing error message.
    """
    text = str(error).lower()
    if is_missing_table_or_column(error):
        return (
            f"AI job persistence is unavailable: '{table}' or its columns are "
            "missing from the hosted schema (migrations "
            "016_extraction_jobs.sql / 023_durable_job_state.sql / "
            "035_add_photoshoot_jobs_image_failures.sql not applied). Apply "
            "them to restore batch/photoshoot job creation."
        )
    if all(marker in text for marker in _CHECK_VIOLATION_MARKERS):
        return (
            "AI job persistence rejected generation_batch_size: the "
            "extraction_jobs.valid_batch_size CHECK bound is below the API's "
            "cap (migrations 023/029 not applied; the boot probe logs the "
            "exact bound). Apply 023_durable_job_state.sql / "
            "029_pr9_hardening.sql on hosted Supabase."
        )
    return ""


# ============================================================================
# Boot-time quota-RPC presence probe (non-mutating)
#
# Deferred-debt item from the 2026-07-31 batch-quota outage: verify at boot
# that the hosted DB actually has the quota RPCs the deployed backend
# requires, so a missing migration is logged with the runbook hint the moment
# the deploy lands instead of surfacing as request-time 500s/503s.
#
# Every probe targets a UUID that matches no user row, so the RPCs return
# FALSE without touching data. A missing function raises PGRST202; anything
# else (permissions, transient errors) means the function EXISTS and is
# reported as present - it is not a migration gap.
# ============================================================================

# Postgres UUID 'nil' - matches no real user row.
_NIL_USER_UUID = "00000000-0000-0000-0000-000000000000"

QUOTA_RPC_PROBES = {
    "reserve_ai_usage": {
        "p_user_id": _NIL_USER_UUID,
        "p_operation": "extraction",
        "p_count": 1,
        "p_limit": 0,
    },
    "release_ai_usage": {
        "p_user_id": _NIL_USER_UUID,
        "p_operation": "extraction",
        "p_count": 1,
    },
    "reserve_usage": {
        "p_user_id": _NIL_USER_UUID,
        "p_period_start": "1970-01-01",
        "p_field": "monthly_extractions",
        "p_count": 1,
        "p_limit": 0,
    },
    "reserve_daily_photoshoot_usage": {
        "p_user_id": _NIL_USER_UUID,
        "p_period_start": "1970-01-01",
        "p_count": 1,
        "p_limit": 0,
    },
}


def missing_quota_rpcs(db) -> list:
    """Return the quota RPC names absent from the hosted schema (migration gap).

    Non-mutating: probes target a nil UUID that matches no user row. Missing
    functions raise PGRST202; a present function (even one that errors for
    other reasons) is counted as present.
    """
    missing = []
    for name, args in QUOTA_RPC_PROBES.items():
        try:
            db.rpc(name, args).execute()
        except Exception as error:
            if is_pgrst202_missing_rpc(error):
                missing.append(name)
    return missing


# ============================================================================
# Boot-time referral/billing RPC presence probe (non-mutating)
#
# RCA 2026-08-04: referral redemptions silently failed for every signup when
# migrations 022/026 were never applied to the hosted project (the same
# migration gap that broke quota RPCs on 2026-07-31) - a missing
# redeem_referral_atomic raises PGRST202, which register/oauth_sync swallow
# and the new user + referrer stay free with no visible error. This probe
# closes the blind spot so the gap is logged with the runbook hint at boot.
#
# Both probes are non-mutating:
#   - redeem_referral_atomic with a code that cannot exist (real codes are
#     "{slug}-{hex}") returns success=FALSE 'Referral code not found' before
#     touching any row (no code row is found and locked).
#   - apply_referral_credit_atomic with the nil user UUID fails the
#     users(id) FK (23503) on its subscription insert before writing
#     anything (a missing row is never mutated).
# A missing function raises PGRST202; anything else (permissions, the FK
# rejection above) means the function EXISTS and is reported as present - it
# is not a migration gap.
# ============================================================================

# A code that no generated referral code can equal (generation is
# lowercase-alphanumeric slug + '-' + hex, and lookup is LOWER(TRIM(code))).
_BOOT_PROBE_NONEXISTENT_CODE = "__boot_probe_nonexistent__"

REFERRAL_RPC_PROBES = {
    "redeem_referral_atomic": {
        "p_referred_user_id": _NIL_USER_UUID,
        "p_code": _BOOT_PROBE_NONEXISTENT_CODE,
        "p_credit_months": 1,
    },
    "apply_referral_credit_atomic": {
        "p_user_id": _NIL_USER_UUID,
        "p_months": 1,
    },
}


def missing_referral_rpcs(db) -> list:
    """Return the referral RPC names absent from the hosted schema (migration gap).

    Same policy as missing_quota_rpcs: a PGRST202 means the function (and its
    migration) is missing; any other error means the function exists.
    """
    missing = []
    for name, args in REFERRAL_RPC_PROBES.items():
        try:
            db.rpc(name, args).execute()
        except Exception as error:
            if is_pgrst202_missing_rpc(error):
                missing.append(name)
    return missing

# ============================================================================
# Boot-time valid_batch_size bound probe (non-mutating)
#
# The API persists generation_batch_size into extraction_jobs (single-extract
# writes AI_GENERATION_CONCURRENCY, clamped to <=100) and the DB enforces it
# with the valid_batch_size CHECK. Three migration eras exist:
#   016 -> <=10 | 023 -> <=50 | 029 -> <=100
# A stale bound turns every job creation into a 23514 CHECK violation and a
# friendly 503 at request time (the 2026-08-01 single-extract outage). The
# probe detects the bound at boot so the gap is logged with the runbook hint
# the moment the deploy lands - same policy as the quota-RPC probes above.
#
# Non-mutating by construction: the probe insert targets the nil UUID user,
# so the row always fails the users(id) foreign key (23503) and nothing is
# ever persisted. CHECK constraints fire before FK checks, so 23514 means the
# probe value exceeded the bound; 23503 (or a success, which the nil FK makes
# impossible) means the CHECK passed.
# ============================================================================

# Probe values: 11 passes only when bound >= 11 (post-016); 51 passes only
# when bound >= 51 (post-023).
_BATCH_SIZE_PROBE_VALUES = (11, 51)

# 23503 is the users(id) FK rejection the nil-UUID probe always triggers once
# the CHECK accepts the probe value.
_PROBE_FK_BLOCKED_MARKER = "23503"


def _probe_insert(db: Any, generation_batch_size: int) -> Optional[str]:
    """Non-mutating probe insert; None means the CHECK accepted the value.

    Returns one of: None (CHECK passed), "violated" (23514/valid_batch_size),
    "missing" (PGRST205/42703), "unknown" (connectivity/permissions/etc.).
    """
    try:
        db.table("extraction_jobs").insert(
            {
                "id": f"boot-probe-{generation_batch_size}",
                "user_id": _NIL_USER_UUID,
                "status": "pending",
                "job_type": "single",
                "generation_batch_size": generation_batch_size,
            }
        ).execute()
        # Unreachable in practice: nil user_id always fails the FK.
        return None
    except Exception as error:
        code = str(getattr(error, "code", "")).lower()
        text = str(error).lower()
        if (code and code in _CHECK_VIOLATION_MARKERS) or any(
            marker in text for marker in _CHECK_VIOLATION_MARKERS
        ):
            return "violated"
        if (code and code in _MISSING_SCHEMA_MARKERS) or any(
            marker in text for marker in _MISSING_SCHEMA_MARKERS
        ):
            return "missing"
        if code == _PROBE_FK_BLOCKED_MARKER:
            return None
        return "unknown"


def probe_valid_batch_size_bound(db: Any) -> Tuple[str, str]:
    """Probe the extraction_jobs.valid_batch_size CHECK bound at boot.

    Returns ``(level, message)`` with level in:
      - "ok": bound accepts >= 51 (029-era, <=100) or no CHECK at all
      - "warn": bound is 11-50 (023-era) - caps above 50 will 503
      - "critical": bound <= 10 (016-era) - every job creation 503s
      - "missing": extraction_jobs absent (016/023 not applied)
      - "unknown": DB unreachable / probe blocked - no bound reported

    LOGS ONLY - never part of a client-facing payload.
    """
    first = _probe_insert(db, _BATCH_SIZE_PROBE_VALUES[0])
    if first == "violated":
        return (
            "critical",
            "extraction_jobs.valid_batch_size CHECK bound is <= 10 (016-era; "
            "migrations 023/029 not applied). Every job creation (single/batch "
            "extract, photoshoot mirror) fails with a friendly 503 until 023 "
            "and 029 are applied on hosted Supabase.",
        )
    if first in ("missing", "unknown"):
        return first, _probe_inconclusive_message(first)
    second = _probe_insert(db, _BATCH_SIZE_PROBE_VALUES[1])
    if second == "violated":
        return (
            "warn",
            "extraction_jobs.valid_batch_size CHECK bound is 11-50 (023-era; "
            "029 not applied). Job creation with generation_batch_size > 50 "
            "(e.g. single-extract with AI_GENERATION_CONCURRENCY > 50) will "
            "503. Apply 029_pr9_hardening.sql to raise the bound to 100.",
        )
    if second in ("missing", "unknown"):
        return second, _probe_inconclusive_message(second)
    return (
        "ok",
        "extraction_jobs.valid_batch_size CHECK bound accepts >= 51 "
        "(029-era, <=100) - aligned with the API cap.",
    )


def _probe_inconclusive_message(level: str) -> str:
    if level == "missing":
        return (
            "extraction_jobs is absent from hosted Supabase (migrations "
            "016_extraction_jobs.sql / 023_durable_job_state.sql not applied) "
            "- cannot probe the valid_batch_size bound."
        )
    return (
        "valid_batch_size bound probe inconclusive (DB unreachable or the "
        "probe was blocked) - no bound reported; check DB connectivity."
    )

