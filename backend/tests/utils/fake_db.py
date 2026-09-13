"""
Shared in-memory fake of the supabase-py query builder — the suite's
"fresh database".

The backend talks to hosted Supabase through the *synchronous* supabase-py
client (no ORM, no local DB — see ``app/db/connection.py``). Routes run
through ``execute_with_reconnect`` (worker thread), so the fake only needs to
be thread-safe for plain attribute access. It supports the filter operators
the services use (eq/neq/gte/lte/gt/lt/ilike/like/in_/or_/not_.in_), the
``maybe_single``/``single`` semantics, ``limit``/``range``, and records every
``select``/``insert``/``update``/``delete``/``rpc`` call for assertions
(``db.selects`` / ``db.inserts`` / ``db.updates`` / ``db.deletes`` /
``db.rpc_calls`` / ``db.filters``).

Every test receives a brand-new instance via the ``fake_db`` fixture in
``tests/conftest.py`` — no database state is ever shared between tests.
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any, Dict, List, Optional, Tuple

try:
    from postgrest.exceptions import APIError as PostgrestAPIError
except ImportError:  # pragma: no cover - postgrest is a backend dependency
    PostgrestAPIError = RuntimeError  # type: ignore[assignment,misc]

from app.core.predicates import evaluate_predicate, resolve_dotted, split_or
from app.utils.datetime_util import utcnow


# Unique keys per table, mirroring the migrations' constraints (the fake can
# only enforce uniqueness it knows about). The real client raises
# APIError 409/SQLSTATE 23505 on a duplicate plain insert; only an
# ``upsert(..., on_conflict=...)`` is idempotent. Enforcing both here is what
# lets tests pin upsert-vs-insert regressions.
UNIQUE_KEYS: Dict[str, Tuple[str, ...]] = {
    # 007_subscriptions_and_referrals.sql: subscriptions UNIQUE(user_id)
    "subscriptions": ("user_id",),
    # 007_subscriptions_and_referrals.sql: one row per user/month
    "subscription_usage": ("user_id", "period_start"),
    # 031_promo_codes.sql: promo_redemptions UNIQUE (user_id)
    "promo_redemptions": ("user_id",),
    # 011_shared_outfits_unique_constraint.sql: UNIQUE (outfit_id, user_id)
    "shared_outfits": ("outfit_id", "user_id"),
    # 001_full_schema.sql: user_preferences.user_id PRIMARY KEY
    "user_preferences": ("user_id",),
    # 001_full_schema.sql: user_settings.user_id PRIMARY KEY
    "user_settings": ("user_id",),
    # 003_remove_puter_add_ai_settings.sql: user_ai_settings.user_id PRIMARY KEY
    "user_ai_settings": ("user_id",),
    # 007_subscriptions_and_referrals.sql: referral_redemptions UNIQUE(referred_user_id)
    "referral_redemptions": ("referred_user_id",),
    # 005_waitlist.sql: waitlist_email_unique UNIQUE (email)
    "waitlist": ("email",),
}


def _key_values(row: Dict[str, Any], keys: Tuple[str, ...]) -> Tuple[Any, ...]:
    return tuple(row.get(key) for key in keys)


def _timestamp_expired(value: Any) -> bool:
    """Match the OAuth RPC's expiry branch for ISO timestamps."""
    if not value:
        return False
    try:
        parsed = value if isinstance(value, datetime) else datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except ValueError:
        return True
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=timezone.utc)
    return parsed < (utcnow() - timedelta(seconds=1))


class FakeResult:
    """Stand-in for a postgrest-py response object."""

    def __init__(self, data: Any = None, count: int = 0):
        self.data = data if data is not None else []
        self.count = count


class PGRSTDuplicateError(PostgrestAPIError):
    """Mirror of postgrest-py's unique-violation (SQLSTATE 23505) failure.

    A plain ``.insert()`` that collides with an existing unique key raises on
    the real client (409/PGRST23505); idempotent writes must use
    ``.upsert(..., on_conflict=...)`` instead. Subclassing the real
    ``APIError`` keeps service error handling (``except PostgrestAPIError``
    / ``e.code == '23505'``) behaving identically to production.
    """

    def __init__(self, table: str, keys: Tuple[str, ...]):
        super().__init__(
            {
                "code": "23505",
                "message": (
                    f'duplicate key value violates unique constraint '
                    f'"{table}_pkey" ({", ".join(keys)})'
                ),
                "hint": None,
                "details": None,
            }
        )


class PGRST116Error(RuntimeError):
    """Mirror of postgrest-py's zero-row ``.single()`` failure.

    The real client RAISES ``APIError`` (406/PGRST116) when ``.single()``
    matches zero rows; it never returns a falsy result. Returning
    ``FakeResult(data=None)`` instead is exactly the divergence that made the
    dead ``if not result.data`` guards (2026-08-09 GET /items/{id} 500 burst)
    pass the suite while production 500'd. Only ``maybe_single()`` may return
    ``None`` for a zero-row select.
    """

    def __init__(self):
        super().__init__("JSON object requested, multiple (or no) rows returned")
        self.code = "PGRST116"
        self.http_status = 406


def _split_predicates(expr: str) -> List[str]:
    """Split an or_ expression on top-level commas (ignores parens).

    Delegates to the canonical grammar module so the emulation cannot drift
    from the service's construction side.
    """
    return split_or(expr)


class FakeRpcBuilder:
    """Stand-in for a postgrest-py RPC builder; returns canned rows.

    ``FakeDB.rpc_results`` maps function name -> list of row dicts, so
    services that call ``d.rpc("name")`` (e.g. the admin dashboard
    top-users RPCs from migration 040) can be tested without a live DB.
    """

    def __init__(self, db: "FakeDB", name: str, params: Dict[str, Any]):
        self._db = db
        self._name = name
        self._params = params

    def execute(self) -> FakeResult:
        return self._db._execute_rpc(self._name, self._params)


class FakeNotBuilder:
    """Negation wrapper returned by ``FakeBuilder.not_()``.

    Mirrors postgrest-py's ``not_`` which must be followed by another filter
    call (``.not_.in_("status", [...])``). The negation is recorded as a
    distinct operator (``not_in`` / ``not_eq`` / ``not_ilike`` / ``not_like``)
    so it is both applied during ``execute()`` and visible in
    ``FakeDB.filters`` for assertions.
    """

    def __init__(self, builder: "FakeBuilder"):
        self._builder = builder

    def in_(self, col: str, values: Any) -> "FakeBuilder":
        self._builder._add_filter("not_in", col, list(values))
        return self._builder

    def eq(self, col: str, value: Any) -> "FakeBuilder":
        self._builder._add_filter("not_eq", col, value)
        return self._builder

    def neq(self, col: str, value: Any) -> "FakeBuilder":
        self._builder._add_filter("not_neq", col, value)
        return self._builder

    def ilike(self, col: str, value: Any) -> "FakeBuilder":
        self._builder._add_filter("not_ilike", col, str(value))
        return self._builder

    def like(self, col: str, value: Any) -> "FakeBuilder":
        self._builder._add_filter("not_like", col, str(value))
        return self._builder

    def is_(self, col: str, value: Any) -> "FakeBuilder":
        self._builder._add_filter("not_is", col, value)
        return self._builder


class FakeBuilder:
    """Chainable fake query builder backed by FakeDB rows."""

    def __init__(self, db: "FakeDB", table: str):
        self._db = db
        self._table = table
        self._filters: List[tuple] = []
        self._mode: Optional[str] = None  # None | "insert" | "update" | "delete"
        self._payload: Optional[Dict[str, Any]] = None
        self._on_conflict: Optional[str] = None
        self._single = False
        self._bare_none = False
        self._limit: Optional[int] = None
        self._range: Optional[tuple] = None
        self._order: Optional[tuple] = None  # (column, desc, nullsfirst)
        self._not: FakeNotBuilder = FakeNotBuilder(self)

    # --- query modifiers (recorded; filters also applied on execute) ---------
    def select(self, *args, **kwargs):
        self._db.selects.append((self._table, args))
        return self

    def _add_filter(self, op: str, col: str, value: Any) -> None:
        self._filters.append((op, col, value))
        self._db.filters.append((self._table, op, col, value))

    def eq(self, col: str, value: Any):
        self._add_filter("eq", col, value)
        return self

    def neq(self, col: str, value: Any):
        self._add_filter("neq", col, value)
        return self

    def gte(self, col: str, value: Any):
        self._add_filter("gte", col, value)
        return self

    def lte(self, col: str, value: Any):
        self._add_filter("lte", col, value)
        return self

    def gt(self, col: str, value: Any):
        self._add_filter("gt", col, value)
        return self

    def lt(self, col: str, value: Any):
        self._add_filter("lt", col, value)
        return self

    def ilike(self, col: str, value: Any):
        self._add_filter("ilike", col, str(value))
        return self

    def like(self, col: str, value: Any):
        self._add_filter("like", col, str(value))
        return self

    def in_(self, col: str, values: Any):
        self._add_filter("in", col, list(values))
        return self

    def is_(self, col: str, value: Any):
        self._add_filter("is", col, value)
        return self

    def or_(self, expression: str):
        self._add_filter("or", "", expression)
        return self

    @property
    def not_(self) -> FakeNotBuilder:
        # postgrest-py exposes `not_` as a PROPERTY (it flips a
        # `negate_next` flag), so callers write `.not_.in_(...)` without
        # parentheses. A method here diverges from the real client and makes
        # `.not_.in_` fail with AttributeError ('function' object has no
        # attribute 'in_') — a fake that is stricter than the real thing
        # hides exactly the bug class this suite exists to catch.
        return self._not

    def order(self, column: str, desc: bool = False, nullsfirst: bool = False, **kwargs):
        # Mirror postgrest-py's QueryRequestBuilder.order: nullsfirst=False is
        # the default and means NULLS LAST (independent of direction).
        self._order = (column, bool(desc), bool(nullsfirst))
        self._db.orders.append((self._table, column, bool(desc), bool(nullsfirst)))
        return self

    def limit(self, n: int):
        self._limit = n
        return self

    def range(self, start: int, end: int):
        self._range = (start, end)
        return self

    def single(self):
        self._single = True
        return self

    def maybe_single(self):
        self._single = True
        self._bare_none = True
        return self

    # --- mutations -----------------------------------------------------------
    def insert(self, row: Dict[str, Any]):
        self._mode = "insert"
        self._payload = row
        return self

    def upsert(self, row: Dict[str, Any], on_conflict: Optional[str] = None):
        """Idempotent write: replace an existing row on the conflicting key.

        Real PostgREST upserts on the unique constraint; the fake mirrors it:
        a row already holding the ``on_conflict`` key(s) is REPLACED in place
        (postgrest echoes the written row back either way), and a row with no
        match is appended. When ``on_conflict`` is omitted the table's
        registry key (``UNIQUE_KEYS``) is used.
        """
        self._mode = "insert"
        self._payload = row
        if on_conflict is None:
            on_conflict = ",".join(UNIQUE_KEYS.get(self._table, ()))
        self._on_conflict = on_conflict
        return self

    def update(self, row: Dict[str, Any]):
        self._mode = "update"
        self._payload = row
        return self

    def delete(self):
        self._mode = "delete"
        return self

    # --- execution -----------------------------------------------------------
    def _matched_rows(self) -> List[Dict[str, Any]]:
        rows = self._db._rows_for(self._table)
        result = []
        for row in rows:
            keep = True
            for op, col, value in self._filters:
                row_value = resolve_dotted(row, col)
                if op == "eq" and row_value != value:
                    keep = False
                elif op == "neq" and row_value == value:
                    keep = False
                elif op == "gte" and str(row_value or "") < str(value):
                    keep = False
                elif op == "lte" and str(row_value or "") > str(value):
                    keep = False
                elif op == "gt" and str(row_value or "") <= str(value):
                    keep = False
                elif op == "lt" and str(row_value or "") >= str(value):
                    keep = False
                elif op == "ilike":
                    pattern = str(value).strip("%")
                    if pattern == str(value):
                        if str(row_value or "").lower() != str(value).lower():
                            keep = False
                    elif pattern.lower() not in str(row_value or "").lower():
                        keep = False
                elif op == "like":
                    pattern = str(value).strip("%")
                    if pattern == str(value):
                        if str(row_value or "") != str(value):
                            keep = False
                    elif pattern not in str(row_value or ""):
                        keep = False
                elif op == "in" and str(row_value or "") not in [str(v) for v in value]:
                    keep = False
                elif op == "is":
                    want_null = value is None or str(value).lower() == "null"
                    if want_null and row_value is not None:
                        keep = False
                    elif not want_null and row_value is None:
                        keep = False
                elif op == "not_is":
                    want_null = value is None or str(value).lower() == "null"
                    if want_null and row_value is None:
                        keep = False
                    elif not want_null and row_value is not None:
                        keep = False
                elif op == "not_in" and str(row_value or "") in [str(v) for v in value]:
                    keep = False
                elif op == "not_eq" and row_value == value:
                    keep = False
                elif op == "not_neq" and row_value != value:
                    keep = False
                elif op == "not_ilike":
                    pattern = str(value).strip("%")
                    if pattern == str(value):
                        if str(row_value or "").lower() == str(value).lower():
                            keep = False
                    elif pattern.lower() in str(row_value or "").lower():
                        keep = False
                elif op == "not_like":
                    pattern = str(value).strip("%")
                    if pattern == str(value):
                        if str(row_value or "") == str(value):
                            keep = False
                    elif pattern in str(row_value or ""):
                        keep = False
                elif op == "or":
                    if not any(evaluate_predicate(row, p) for p in _split_predicates(value)):
                        keep = False
                if not keep:
                    break
            if keep:
                result.append(row)
        return result

    def execute(self) -> FakeResult:
        db = self._db
        if self._mode == "insert":
            db.inserts.append((self._table, self._payload, self._on_conflict))
            payloads = self._payload if isinstance(self._payload, list) else [self._payload]
            rows = db._rows_for(self._table)
            unique_keys = UNIQUE_KEYS.get(self._table)
            written = []
            for p in payloads:
                row = dict(p)
                for column, default in db.insert_defaults.items():
                    if row.get(column) is None:
                        row[column] = default
                if self._on_conflict:
                    # Upsert: replace the row holding the conflicting key(s);
                    # append when nothing conflicts (PostgREST semantics).
                    conflict_keys = tuple(
                        c.strip() for c in self._on_conflict.split(",") if c.strip()
                    )
                    replaced = False
                    for idx, existing in enumerate(rows):
                        if all(existing.get(k) == row.get(k) for k in conflict_keys):
                            rows[idx] = row
                            replaced = True
                            break
                    if not replaced:
                        rows.append(row)
                else:
                    # Plain insert: a duplicate unique key raises 23505 on the
                    # real client — only upsert is idempotent.
                    if unique_keys is not None and any(
                        _key_values(existing, unique_keys) == _key_values(row, unique_keys)
                        for existing in rows
                    ):
                        raise PGRSTDuplicateError(self._table, unique_keys)
                    rows.append(row)
                written.append(row)
            return FakeResult(data=written, count=len(written))

        if self._mode == "update":
            db.updates.append((self._table, self._payload))
            matched = self._matched_rows()
            merged = [{**row, **self._payload} for row in matched]
            # Persist the merged rows so read-after-update sees them (keeps
            # the fake consistent with insert/delete, which also mutate).
            rows = db._rows_for(self._table)
            for idx, row in enumerate(rows):
                if row in matched:
                    rows[idx] = merged[matched.index(row)]
            return FakeResult(data=merged, count=len(merged))

        if self._mode == "delete":
            db.deletes.append((self._table, None))
            matched = self._matched_rows()
            remaining = [row for row in db._rows_for(self._table) if row not in matched]
            db._rows_for(self._table)[:] = remaining
            return FakeResult(data=matched, count=len(matched))

        rows = self._matched_rows()
        count = len(rows)
        if self._order is not None:
            column, desc, nullsfirst = self._order
            # Partition NULLs out of the value sort (None is not comparable
            # with numbers/strings) and place them per Postgres semantics:
            # NULLS LAST by default, matching postgrest-py's
            # order(..., nullsfirst=False); NULLS FIRST when requested.
            nulls = [r for r in rows if r.get(column) is None]
            values = [r for r in rows if r.get(column) is not None]
            values = sorted(values, key=lambda r: r.get(column), reverse=desc)
            rows = values + nulls if not nullsfirst else nulls + values
        if self._range is not None:
            start, end = self._range
            rows = rows[start : end + 1]
        if self._limit is not None:
            rows = rows[: self._limit]
        if self._single:
            if self._bare_none and not rows:
                # postgrest-py returns a bare None (not a response object) for
                # zero-row `.maybe_single().execute()`; app code handles that
                # via `maybe_single_data(result)`.
                return None
            if not rows:
                # Fidelity with the real client: `.single()` raises (PGRST116)
                # on zero rows instead of returning a falsy result — the
                # divergence that used to mask dead not-found branches.
                raise PGRST116Error()
            return FakeResult(data=rows[0], count=count)
        return FakeResult(data=rows, count=count)


class FakeDB:
    """In-memory stand-in for the supabase service client.

    ``rows`` maps table name -> list of row dicts. ``inserts`` and ``updates``
    record every write as ``(table, payload)`` (inserts carry the
    ``on_conflict`` argument as the third element), ``deletes`` record every
    delete as ``(table, None)``, and ``filters`` records every filter applied
    as ``(table, op, column, value)`` so ownership/scope boundaries can be
    asserted directly. ``rpc_results`` maps RPC function name -> list of row
    dicts; ``rpc_calls`` records every ``d.rpc(...)`` invocation as
    ``(name, params)``.

    ``insert_defaults`` maps column name -> default value; any ``None`` value
    in an inserted payload is filled with the default, mirroring the NOT NULL
    defaults a real Postgres table fills in for you.

    Uniqueness: tables listed in ``UNIQUE_KEYS`` reject a plain ``insert``
    that collides with an existing row (``PGRSTDuplicateError``, SQLSTATE
    23505 — like the real client), while ``upsert(..., on_conflict=...)``
    replaces the conflicting row in place. This is what lets the suite pin
    upsert-vs-insert regressions instead of silently appending both.
    """

    def __init__(
        self,
        rows: Optional[Dict[str, List[Dict[str, Any]]]] = None,
        rpc_results: Optional[Dict[str, List[Dict[str, Any]]]] = None,
        insert_defaults: Optional[Dict[str, Any]] = None,
    ):
        self.rows: Dict[str, List[Dict[str, Any]]] = rows or {}
        self.rpc_results: Dict[str, List[Dict[str, Any]]] = rpc_results or {}
        self.insert_defaults: Dict[str, Any] = insert_defaults or {}
        self.inserts: List[tuple] = []
        self.updates: List[tuple] = []
        self.deletes: List[tuple] = []
        self.rpc_calls: List[tuple] = []
        self.selects: List[tuple] = []
        self.filters: List[tuple] = []
        self.orders: List[tuple] = []  # (table, column, desc, nullsfirst)

    def _rows_for(self, table: str) -> List[Dict[str, Any]]:
        return self.rows.setdefault(table, [])

    def table(self, name: str) -> FakeBuilder:
        return FakeBuilder(self, name)

    def rpc(self, name: str, params: Optional[Dict[str, Any]] = None) -> FakeRpcBuilder:
        rpc_params = params or {}
        self.rpc_calls.append((name, rpc_params))
        return FakeRpcBuilder(self, name, rpc_params)

    def _execute_rpc(self, name: str, params: Dict[str, Any]) -> FakeResult:
        """Execute an RPC with either a canned result or its stateful fake.

        The OAuth RPCs mutate their backing rows, so canned data cannot model
        a full authorization-code and refresh-token flow. Keep that behavior
        here with the table fake rather than special-casing production code.
        """
        if name in self.rpc_results:
            return FakeResult(data=list(self.rpc_results[name]))
        if name == "consume_mcp_oauth_authorization_code":
            return self._consume_mcp_oauth_authorization_code(params)
        if name == "rotate_mcp_oauth_refresh_token":
            return self._rotate_mcp_oauth_refresh_token(params)
        if name == "admin_extend_user_trial":
            return self._admin_extend_user_trial(params)
        if name == "admin_clear_user_daily_ai_counters":
            return self._admin_clear_user_daily_ai_counters(params)
        return FakeResult(data=[])

    def _admin_extend_user_trial(self, params: Dict[str, Any]) -> FakeResult:
        """Mirror migration 060's row-locked trial extension outcome."""
        user_id = params.get("p_user_id")
        days = int(params.get("p_days") or 0)
        # Match the RPC's day-range guard (1..90), like the service layer.
        if not 1 <= days <= 90:
            return FakeResult(data=[])
        record = next(
            (row for row in self._rows_for("subscriptions") if row.get("user_id") == user_id),
            None,
        )
        if not record:
            return FakeResult(data=[])
        before = record.get("trial_end")
        before_dt: Optional[datetime] = None
        if before:
            try:
                before_dt = datetime.fromisoformat(str(before).replace("Z", "+00:00"))
                if before_dt.tzinfo is None:
                    before_dt = before_dt.replace(tzinfo=timezone.utc)
            except ValueError:
                before_dt = None
        now = utcnow()
        base = max(before_dt, now) if before_dt else now
        after = base + timedelta(days=days)
        record["trial_end"] = after.isoformat()
        # Mirror the RPC's updated_at touch so callers can assert on it.
        record["updated_at"] = now.isoformat()
        return FakeResult(
            data=[
                {
                    "subscription": dict(record),
                    "before_trial_end": before,
                    "after_trial_end": after.isoformat(),
                }
            ]
        )

    def _admin_clear_user_daily_ai_counters(self, params: Dict[str, Any]) -> FakeResult:
        """Mirror migration 060's all-or-nothing daily-counter reset."""
        user_id = params.get("p_user_id")
        if not any(row.get("id") == user_id for row in self._rows_for("users")):
            return FakeResult(data=[])
        today = utcnow().date()
        today_iso = today.isoformat()
        period_start = today.replace(day=1).isoformat()

        now_iso = utcnow().isoformat()
        settings = next(
            (row for row in self._rows_for("user_ai_settings") if row.get("user_id") == user_id),
            None,
        )
        if settings is None:
            settings = {"user_id": user_id}
            self._rows_for("user_ai_settings").append(settings)
        settings.update(
            {
                "daily_extraction_count": 0,
                "daily_generation_count": 0,
                "daily_embedding_count": 0,
                "last_reset_date": today_iso,
                "updated_at": now_iso,
            }
        )

        usage = next(
            (
                row
                for row in self._rows_for("subscription_usage")
                if row.get("user_id") == user_id and str(row.get("period_start")) == period_start
            ),
            None,
        )
        if usage is None:
            usage = {
                "user_id": user_id,
                "period_start": period_start,
                "monthly_extractions": 0,
                "monthly_generations": 0,
                "monthly_embeddings": 0,
            }
            self._rows_for("subscription_usage").append(usage)
        usage.update({"daily_photoshoot_images": 0, "last_photoshoot_reset": today_iso, "updated_at": now_iso})
        return FakeResult(data=[{"today": today_iso, "period_start": period_start}])

    def _consume_mcp_oauth_authorization_code(self, params: Dict[str, Any]) -> FakeResult:
        record = next(
            (
                row
                for row in self._rows_for("mcp_oauth_auth_codes")
                if row.get("code_hash") == params.get("p_code_hash")
            ),
            None,
        )
        if not record or record.get("used_at"):
            return FakeResult(data=[{"outcome": "invalid"}])
        if _timestamp_expired(record.get("expires_at")):
            return FakeResult(data=[{"outcome": "expired"}])
        if (
            record.get("client_id") != params.get("p_client_id")
            or record.get("redirect_uri") != params.get("p_redirect_uri")
        ):
            return FakeResult(data=[{"outcome": "client_mismatch"}])
        if record.get("code_challenge") != params.get("p_code_challenge"):
            return FakeResult(data=[{"outcome": "pkce_failed"}])
        if not record.get("user_id"):
            return FakeResult(data=[{"outcome": "unbound"}])

        record["used_at"] = utcnow().isoformat()
        return FakeResult(
            data=[
                {
                    "outcome": "consumed",
                    "user_id": record["user_id"],
                    "scope": record.get("scope") or "mcp",
                }
            ]
        )

    def _rotate_mcp_oauth_refresh_token(self, params: Dict[str, Any]) -> FakeResult:
        tokens = self._rows_for("mcp_oauth_refresh_tokens")
        record = next(
            (row for row in tokens if row.get("token_hash") == params.get("p_token_hash")),
            None,
        )
        if not record:
            return FakeResult(data=[{"outcome": "invalid"}])
        if record.get("revoked_at"):
            now = utcnow().isoformat()
            for token in tokens:
                if token.get("family") == record.get("family"):
                    token["revoked_at"] = token.get("revoked_at") or now
            return FakeResult(data=[{"outcome": "reused", "family": record.get("family")}])
        if _timestamp_expired(record.get("expires_at")):
            return FakeResult(data=[{"outcome": "expired", "family": record.get("family")}])

        record["revoked_at"] = utcnow().isoformat()
        record["replaced_by"] = params.get("p_replacement_id")
        tokens.append(
            {
                "id": params.get("p_replacement_id"),
                "token_hash": params.get("p_replacement_token_hash"),
                "user_id": record["user_id"],
                "client_id": record["client_id"],
                "scope": record.get("scope") or "mcp",
                "family": record["family"],
                "expires_at": params.get("p_replacement_expires_at"),
                "revoked_at": None,
                "replaced_by": None,
            }
        )
        return FakeResult(
            data=[
                {
                    "outcome": "rotated",
                    "user_id": record["user_id"],
                    "client_id": record["client_id"],
                    "scope": record.get("scope") or "mcp",
                    "family": record["family"],
                }
            ]
        )

    def ops_on(self, table: str) -> List[Tuple[str, Optional[Dict[str, Any]]]]:
        """(op, payload) for every mutation recorded against ``table``."""
        ops: List[Tuple[str, Optional[Dict[str, Any]]]] = []
        for t, payload, _on_conflict in self.inserts:
            if t == table:
                ops.append(("insert", payload))
        for t, payload in self.updates:
            if t == table:
                ops.append(("update", payload))
        for t, _payload in self.deletes:
            if t == table:
                ops.append(("delete", None))
        return ops

    def assert_insert(self, table: str, **payload) -> None:
        for recorded_table, recorded, _on_conflict in self.inserts:
            if recorded_table == table and all(
                recorded.get(key) == value for key, value in payload.items()
            ):
                return
        raise AssertionError(
            f"no insert into {table} matching {payload}; recorded: {self.inserts}"
        )

    def assert_update(self, table: str, **payload) -> None:
        for recorded_table, recorded in self.updates:
            if recorded_table == table and all(
                recorded.get(key) == value for key, value in payload.items()
            ):
                return
        raise AssertionError(
            f"no update to {table} matching {payload}; recorded: {self.updates}"
        )
