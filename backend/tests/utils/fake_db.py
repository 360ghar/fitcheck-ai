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

from typing import Any, Dict, List, Optional, Tuple

from app.core.predicates import evaluate_predicate, resolve_dotted, split_or


class FakeResult:
    """Stand-in for a postgrest-py response object."""

    def __init__(self, data: Any = None, count: int = 0):
        self.data = data if data is not None else []
        self.count = count


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

    def __init__(self, db: "FakeDB", name: str):
        self._db = db
        self._name = name

    def execute(self) -> FakeResult:
        return FakeResult(data=list(self._db.rpc_results.get(self._name, [])))


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

    def or_(self, expression: str):
        self._add_filter("or", "", expression)
        return self

    def not_(self) -> FakeNotBuilder:
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
        """Idempotent write: insert semantics, recorded like an insert.

        Real PostgREST upserts on the unique constraint; the fake appends the
        row (postgrest echoes it back either way), which is what handlers
        branch on.
        """
        self._mode = "insert"
        self._payload = row
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
            written = []
            for p in payloads:
                row = dict(p)
                for column, default in db.insert_defaults.items():
                    if row.get(column) is None:
                        row[column] = default
                written.append(row)
            db._rows_for(self._table).extend(written)
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
            return FakeResult(data=rows[0] if rows else None, count=count)
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
        self.rpc_calls.append((name, params or {}))
        return FakeRpcBuilder(self, name)

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
