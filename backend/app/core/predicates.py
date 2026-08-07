"""Canonical PostgREST ``column.op.value`` predicate grammar.

Admin filters are passed to supabase-py's ``.or_()`` as one string of
comma-separated ``col.op.value`` predicates. Two sides of that boundary must
agree on the grammar:

* ``app/services/admin_service.py`` CONSTRUCTS the strings (``build_predicate``)
* ``tests/admin_test_utils.py`` EMULATES PostgREST row matching
  (``parse_predicate`` + ``evaluate_predicate``)

Keeping the grammar in one place means a qualified column
(``users.email.ilike.%x%``), a value that itself contains dots
(``google_order_id.eq.GPA.123``), or a parenthesised ``in`` list
(``role.in.(admin,ops)``) is parsed exactly the way it was built.

The grammar (mirrors PostgREST logical operators):

    predicate := column "." op "." value
    column    := segment ("." segment)*     # dotted for embedded resources
    segment   := [A-Za-z0-9_]+
    op        := [a-z_]+
    value     := anything (may contain dots/commas/parens)

This module is pure (no I/O, no app imports) so both services and tests can
use it, and ``app/core`` is the one layer both may import (ARCHITECTURE.md).
"""

from __future__ import annotations

import re
from typing import Any, Dict, List, Tuple

# column: one or more [A-Za-z0-9_]+ segments joined by dots (embedded
# resources like ``users.email``); op: lowercase letters/underscores; value:
# everything after the last ``.op.`` boundary (``.+`` is greedy on purpose,
# and a value must be non-empty — ``email.ilike.`` is malformed).
PREDICATE_RE = re.compile(
    r"^(?P<col>[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)*)"
    r"\.(?P<op>[a-z_]+)"
    r"\.(?P<val>.+)$"
)

_COLUMN_SEGMENT_RE = re.compile(r"^[A-Za-z0-9_]+$")
_OP_RE = re.compile(r"^[a-z_]+$")

# Operators the emulation can evaluate against an in-memory row. Anything
# else parses fine but evaluates to False (a PostgREST feature we never use).
_EVALUATABLE_OPS = frozenset({"eq", "neq", "gte", "lte", "gt", "lt", "ilike", "like", "in"})


class PredicateError(ValueError):
    """Raised for a predicate that does not match the canonical grammar."""


def parse_predicate(predicate: str) -> Tuple[str, str, str]:
    """Split one ``col.op.value`` predicate into ``(column, op, value)``.

    Raises PredicateError when the predicate is not grammatically valid.
    """
    match = PREDICATE_RE.fullmatch(predicate.strip())
    if not match:
        raise PredicateError(f"malformed predicate: {predicate!r}")
    return match.group("col"), match.group("op"), match.group("val")


def build_predicate(column: str, op: str, value: Any) -> str:
    """Build a ``col.op.value`` predicate string from its parts.

    ``column`` and ``op`` are validated by round-tripping the built string
    through ``parse_predicate``: the grammar is the single source of truth,
    so a column that smuggles an operator (``email.ilike``) or a wildcard
    (``email%``) can never be emitted. ``value`` is free-form — dots are fine
    (``GPA.123``), but a value containing a top-level comma must not be
    embedded in an ``or_`` list (PostgREST would split it); use parentheses
    (``in`` lists) or a direct ``.eq()`` for those.
    """
    column = column.strip()
    op = op.strip()
    if not column or not all(_COLUMN_SEGMENT_RE.fullmatch(seg) for seg in column.split(".")):
        raise PredicateError(f"invalid column in predicate: {column!r}")
    if not _OP_RE.fullmatch(op):
        raise PredicateError(f"invalid operator in predicate: {op!r}")
    built = f"{column}.{op}.{value}"
    parsed_col, parsed_op, _ = parse_predicate(built)
    if parsed_col != column or parsed_op != op:
        raise PredicateError(f"ambiguous predicate parts: {column!r}.{op!r}.{value!r}")
    return built


def split_or(expression: str) -> List[str]:
    """Split an ``or_`` expression on top-level commas (parens are respected)."""
    parts: List[str] = []
    depth = 0
    current = ""
    for ch in expression:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == "," and depth == 0:
            parts.append(current)
            current = ""
            continue
        current += ch
    if current.strip():
        parts.append(current)
    return parts


def resolve_dotted(row: Dict[str, Any], column: str) -> Any:
    """Resolve a column path (embedded resources use dots: ``a.b.c``)."""
    value: Any = row
    for part in column.split("."):
        if isinstance(value, dict):
            value = value.get(part)
        else:
            return None
    return value


def _coerce_literal(raw: str) -> Any:
    """Parse PostgREST literal values used in filter expressions."""
    if raw == "true":
        return True
    if raw == "false":
        return False
    if raw in ("null", "NULL"):
        return None
    return raw


def evaluate_predicate(row: Dict[str, Any], predicate: str) -> bool:
    """Evaluate one ``col.op.value`` predicate against an in-memory row.

    This is the row-matching emulation of PostgREST used by the admin test
    fake; it shares ``parse_predicate`` with the service's construction side
    so the two cannot drift. Unknown operators evaluate to False; malformed
    predicates raise PredicateError (a loud failure in tests, never a silent
    mis-match).
    """
    column, op, raw = parse_predicate(predicate)
    if op not in _EVALUATABLE_OPS:
        return False
    value = resolve_dotted(row, column)

    if op == "eq":
        return value == _coerce_literal(raw)
    if op == "neq":
        return value != _coerce_literal(raw)
    if op == "gte":
        return str(value or "") >= raw
    if op == "lte":
        return str(value or "") <= raw
    if op == "gt":
        return str(value or "") > raw
    if op == "lt":
        return str(value or "") < raw
    if op == "ilike":
        pattern = raw.strip("%")
        if pattern == raw:  # no wildcards -> case-insensitive equality
            return str(value or "").lower() == raw.lower()
        return pattern.lower() in str(value or "").lower()
    if op == "like":
        pattern = raw.strip("%")
        if pattern == raw:
            return str(value or "") == raw
        return pattern in str(value or "")
    if op == "in":
        allowed = [item.strip() for item in raw.strip("()").split(",") if item.strip()]
        return str(value or "") in allowed or value in allowed
    # Unreachable: ops not in _EVALUATABLE_OPS return False above, and every
    # evaluatable op is handled by one of the ifs.
    return False  # pragma: no cover - all evaluatable ops handled above
