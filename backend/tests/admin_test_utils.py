"""
Shared test doubles for admin API tests.

A small in-memory fake of the supabase-py query builder: routes run through
``execute_with_reconnect`` (worker thread), so the fake only needs to be
thread-safe for plain attribute access. It supports the filter operators the
admin service uses (eq/neq/gte/lte/ilike/in/or_), ``maybe_single``/``single``
semantics, ``limit``/``range``, and records ``insert``/``update`` payloads
plus every ``select`` column list for assertions
(db.inserts / db.updates / db.selects).
"""

from __future__ import annotations

from typing import Any, Dict, List, Optional

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


class FakeBuilder:
    """Chainable fake query builder backed by FakeDB rows."""

    def __init__(self, db: "FakeDB", table: str):
        self._db = db
        self._table = table
        self._filters: List[tuple] = []
        self._mode: Optional[str] = None  # None | "insert" | "update"
        self._payload: Optional[Dict[str, Any]] = None
        self._single = False
        self._limit: Optional[int] = None
        self._range: Optional[tuple] = None

    # --- query modifiers (no-ops for the fake, recorded for assertions) ------
    def select(self, *args, **kwargs):
        self._db.selects.append((self._table, args))
        return self

    def eq(self, col: str, value: Any):
        self._filters.append(("eq", col, value))
        return self

    def neq(self, col: str, value: Any):
        self._filters.append(("neq", col, value))
        return self

    def gte(self, col: str, value: Any):
        self._filters.append(("gte", col, value))
        return self

    def lte(self, col: str, value: Any):
        self._filters.append(("lte", col, value))
        return self

    def gt(self, col: str, value: Any):
        self._filters.append(("gt", col, value))
        return self

    def lt(self, col: str, value: Any):
        self._filters.append(("lt", col, value))
        return self

    def ilike(self, col: str, value: Any):
        self._filters.append(("ilike", col, str(value)))
        return self

    def like(self, col: str, value: Any):
        self._filters.append(("like", col, str(value)))
        return self

    def in_(self, col: str, values: Any):
        self._filters.append(("in", col, list(values)))
        return self

    def or_(self, expression: str):
        self._filters.append(("or", "", expression))
        return self

    def order(self, *args, **kwargs):
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
        return self

    def not_(self):
        return self

    # --- mutations -----------------------------------------------------------
    def insert(self, row: Dict[str, Any]):
        self._mode = "insert"
        self._payload = row
        return self

    def update(self, row: Dict[str, Any]):
        self._mode = "update"
        self._payload = row
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
            db.inserts.append((self._table, self._payload))
            return FakeResult(data=[self._payload], count=1)
        if self._mode == "update":
            db.updates.append((self._table, self._payload))
            matched = self._matched_rows()
            merged = [{**row, **self._payload} for row in matched]
            return FakeResult(data=merged, count=len(merged))

        rows = self._matched_rows()
        count = len(rows)
        if self._range is not None:
            start, end = self._range
            rows = rows[start : end + 1]
        if self._limit is not None:
            rows = rows[: self._limit]
        if self._single:
            return FakeResult(data=rows[0] if rows else None, count=count)
        return FakeResult(data=rows, count=count)


class FakeDB:
    """In-memory stand-in for the supabase service client.

    ``rows`` maps table name -> list of row dicts. ``inserts`` and ``updates``
    record every write as ``(table, payload)`` for assertions.
    ``rpc_results`` maps RPC function name -> list of row dicts; ``rpc_calls``
    records every ``d.rpc(...)`` invocation as ``(name, params)``.
    """

    def __init__(
        self,
        rows: Optional[Dict[str, List[Dict[str, Any]]]] = None,
        rpc_results: Optional[Dict[str, List[Dict[str, Any]]]] = None,
    ):
        self.rows: Dict[str, List[Dict[str, Any]]] = rows or {}
        self.rpc_results: Dict[str, List[Dict[str, Any]]] = rpc_results or {}
        self.inserts: List[tuple] = []
        self.updates: List[tuple] = []
        self.rpc_calls: List[tuple] = []
        self.selects: List[tuple] = []

    def _rows_for(self, table: str) -> List[Dict[str, Any]]:
        return self.rows.get(table, [])

    def table(self, name: str) -> FakeBuilder:
        return FakeBuilder(self, name)

    def rpc(self, name: str, params: Optional[Dict[str, Any]] = None) -> FakeRpcBuilder:
        self.rpc_calls.append((name, params or {}))
        return FakeRpcBuilder(self, name)

    def assert_insert(self, table: str, **payload) -> None:
        for recorded_table, recorded in self.inserts:
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
