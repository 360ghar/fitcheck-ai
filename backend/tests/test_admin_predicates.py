"""
Unit tests for the canonical PostgREST predicate grammar
(``app/core/predicates.py``), shared by the admin service's query construction
and the test emulation. Covers the failure modes that a naive ``split(".")``
parser gets wrong: qualified columns (``users.email``), dotted values
(``GPA.123``), parenthesised ``in`` lists, and mixed ``or_`` expressions.
"""
import pytest

from app.core.predicates import (
    PredicateError,
    build_predicate,
    evaluate_predicate,
    parse_predicate,
    resolve_dotted,
    split_or,
)


# --------------------------------------------------------------------------- #
# parse_predicate: col.op.value grammar
# --------------------------------------------------------------------------- #
def test_parse_unqualified_predicate():
    assert parse_predicate("email.ilike.%x%") == ("email", "ilike", "%x%")


def test_parse_qualified_predicate_column():
    # The column may be dotted (embedded resource); the op boundary is the
    # LAST ".op." boundary, so the whole "users.email" is the column.
    assert parse_predicate("users.email.ilike.%x%") == ("users.email", "ilike", "%x%")


def test_parse_dotted_value():
    # Store transaction ids contain dots; the value keeps them whole.
    assert parse_predicate("google_order_id.eq.GPA.123") == (
        "google_order_id",
        "eq",
        "GPA.123",
    )
    assert parse_predicate("apple_original_transaction_id.eq.100000.1234567890") == (
        "apple_original_transaction_id",
        "eq",
        "100000.1234567890",
    )


def test_parse_dotted_search_term():
    assert parse_predicate("full_name.ilike.%saksham.mittal%") == (
        "full_name",
        "ilike",
        "%saksham.mittal%",
    )


def test_parse_in_list_value():
    assert parse_predicate("role.in.(super_admin,admin,ops)") == (
        "role",
        "in",
        "(super_admin,admin,ops)",
    )


def test_parse_qualified_column_with_dotted_value():
    assert parse_predicate("subscriptions.apple_original_transaction_id.eq.GPA.9") == (
        "subscriptions.apple_original_transaction_id",
        "eq",
        "GPA.9",
    )


def test_parse_malformed_predicates_raise():
    for bad in ("", "email", "email.ilike", "email..%x%", ".eq.x", "email.ilike."):
        with pytest.raises(PredicateError):
            parse_predicate(bad)


# --------------------------------------------------------------------------- #
# split_or: top-level comma splitting (parens respected)
# --------------------------------------------------------------------------- #
def test_split_or_mixed_expression():
    expr = (
        "email.ilike.%x%,"
        "users.full_name.ilike.%x%,"
        "role.in.(super_admin,admin,ops),"
        "google_order_id.eq.GPA.123"
    )
    assert split_or(expr) == [
        "email.ilike.%x%",
        "users.full_name.ilike.%x%",
        "role.in.(super_admin,admin,ops)",
        "google_order_id.eq.GPA.123",
    ]


def test_split_or_commas_inside_parens_are_kept():
    assert split_or("role.in.(a,b),status.eq.open") == [
        "role.in.(a,b)",
        "status.eq.open",
    ]


# --------------------------------------------------------------------------- #
# build_predicate: construction side of the same grammar
# --------------------------------------------------------------------------- #
def test_build_round_trips_through_parse():
    cases = [
        ("email", "ilike", "%x%"),
        ("users.email", "ilike", "%x%"),
        ("google_order_id", "eq", "GPA.123"),
        ("role", "in", "(super_admin,admin,ops)"),
        ("full_name", "ilike", "%saksham.mittal%"),
        ("subscriptions.apple_original_transaction_id", "eq", "GPA.9"),
    ]
    for column, op, value in cases:
        built = build_predicate(column, op, value)
        assert parse_predicate(built) == (column, op, value)


def test_build_rejects_invalid_columns_and_ops():
    # Column segments may not carry characters outside the grammar.
    with pytest.raises(PredicateError):
        build_predicate("email-address", "eq", "v")
    with pytest.raises(PredicateError):
        build_predicate("email%", "ilike", "v")
    with pytest.raises(PredicateError):
        build_predicate("email", "EQ", "v")
    with pytest.raises(PredicateError):
        build_predicate("email", "not.eq", "v")
    # Dotted columns are legal and round-trip unchanged (like users.email).
    assert build_predicate("email.ilike.x", "eq", "v") == "email.ilike.x.eq.v"


# --------------------------------------------------------------------------- #
# evaluate_predicate: the row-matching emulation
# --------------------------------------------------------------------------- #
def test_evaluate_qualified_and_dotted_values():
    row = {
        "users": {"email": "Target@Example.com"},
        "google_order_id": "GPA.123",
        "role": "ops",
        "full_name": "Saksham.Mittal",
    }
    assert evaluate_predicate(row, "users.email.ilike.%target%")
    assert evaluate_predicate(row, "users.email.ilike.%Target%")
    assert evaluate_predicate(row, "google_order_id.eq.GPA.123")
    assert not evaluate_predicate(row, "google_order_id.eq.GPA.999")
    assert evaluate_predicate(row, "role.in.(super_admin,admin,ops)")
    assert not evaluate_predicate(row, "role.in.(super_admin,admin)")
    assert evaluate_predicate(row, "full_name.ilike.%saksham.mittal%")


def test_evaluate_or_expression_any_matches():
    row = {"email": "a@b.com", "full_name": "Nobody"}
    assert evaluate_predicate(row, "email.ilike.%b.com%") or evaluate_predicate(
        row, "full_name.ilike.%x%"
    )
    assert evaluate_predicate(row, "email.ilike.%zzz%") or evaluate_predicate(
        row, "full_name.ilike.%obody%"
    )
    assert not (
        evaluate_predicate(row, "email.ilike.%zzz%")
        or evaluate_predicate(row, "full_name.ilike.%qqq%")
    )


def test_evaluate_unknown_op_is_false_and_malformed_raises():
    row = {"email": "a@b.com"}
    assert not evaluate_predicate(row, "email.not.x")
    with pytest.raises(PredicateError):
        evaluate_predicate(row, "email")


def test_resolve_dotted_nested():
    row = {"users": {"email": "x@y.z"}, "plan": None}
    assert resolve_dotted(row, "users.email") == "x@y.z"
    assert resolve_dotted(row, "users.plan") is None
    assert resolve_dotted(row, "users.missing.deep") is None
    assert resolve_dotted(row, "plan") is None
