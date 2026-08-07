"""Residual branch coverage for app.core.predicates.

The sibling test_admin_predicates.py covers the grammar parsing, build
round-trips, and the main row-evaluation operators; this file covers the
remaining evaluation operators (neq/gte/lte/gt/lt, literal coercion,
like/ilike wildcard forms, in-list matching) and the ambiguous-build guard.
"""

import pytest

from app.core.predicates import (
    PredicateError,
    build_predicate,
    evaluate_predicate,
    split_or,
)


def test_build_predicate_rejects_ambiguous_value():
    """A value containing '.eq.' re-parses with a different column/op."""
    with pytest.raises(PredicateError, match="ambiguous"):
        build_predicate("email", "eq", "x.eq.y")


def test_split_or_handles_trailing_comma():
    assert split_or("a.eq.1,b.eq.2,") == ["a.eq.1", "b.eq.2"]
    assert split_or("single.eq.x") == ["single.eq.x"]


def test_evaluate_boolean_and_null_literals():
    row = {"is_active": True, "deleted_at": None, "flag": False}
    assert evaluate_predicate(row, "is_active.eq.true")
    assert not evaluate_predicate(row, "flag.eq.true")
    assert evaluate_predicate(row, "flag.eq.false")
    assert evaluate_predicate(row, "deleted_at.eq.null")
    assert not evaluate_predicate(row, "is_active.eq.null")


def test_evaluate_neq():
    row = {"role": "admin"}
    assert evaluate_predicate(row, "role.neq.user")
    assert not evaluate_predicate(row, "role.neq.admin")


def test_evaluate_comparison_operators():
    row = {"usage_count": "7", "score": "12.5"}
    assert evaluate_predicate(row, "usage_count.gte.5")
    assert not evaluate_predicate(row, "usage_count.gte.9")
    assert evaluate_predicate(row, "usage_count.lte.7")
    assert not evaluate_predicate(row, "usage_count.lte.6")
    assert evaluate_predicate(row, "usage_count.gt.6")
    assert not evaluate_predicate(row, "usage_count.gt.7")
    assert evaluate_predicate(row, "usage_count.lt.8")
    assert not evaluate_predicate(row, "usage_count.lt.7")
    # Missing values compare as empty strings (never crash, no match for gt).
    assert not evaluate_predicate({}, "usage_count.gt.0")


def test_evaluate_ilike_exact_and_wildcard():
    row = {"email": "Target@Example.com"}
    # No wildcards -> case-insensitive equality.
    assert evaluate_predicate(row, "email.ilike.target@example.com")
    assert not evaluate_predicate(row, "email.ilike.target@example.org")
    # Wildcards -> substring match.
    assert evaluate_predicate(row, "email.ilike.%target%")
    assert evaluate_predicate(row, "email.ilike.target%")
    assert evaluate_predicate(row, "email.ilike.%example%")
    assert not evaluate_predicate(row, "email.ilike.%zzz%")


def test_evaluate_like_case_sensitive():
    row = {"slug": "My-Post"}
    assert evaluate_predicate(row, "slug.like.my-post") is False
    assert evaluate_predicate(row, "slug.like.My-Post")
    assert evaluate_predicate(row, "slug.like.%Post")
    assert not evaluate_predicate(row, "slug.like.%post")


def test_evaluate_in_matches_string_values():
    row = {"role": "ops"}
    assert evaluate_predicate(row, "role.in.(super_admin,admin,ops)")
    assert not evaluate_predicate(row, "role.in.(super_admin,admin)")
    assert evaluate_predicate(row, "role.in.( ops )")
