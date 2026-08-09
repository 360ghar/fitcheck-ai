"""Item-write migration-gap handling for app/api/v1/items.py.

Observed 2026-08-08: `POST /api/v1/items` 500s ("Create item error") with the
real cause only in a structured `error` field that Railway's plain-text log
drain drops. The two deterministic causes are hosted-Supabase schema gaps:
`items.source_image_url` / `items.source_image_storage_path` absent (migration
019 not applied -> PGRST204/42703 on every insert, because the API always
sends those columns) and `item_images.image_url` still VARCHAR(500) (migration
036 not applied -> 22001 "value too long" for long presigned/R2 URLs).

These tests pin the fix, mirroring the durable-job persistence policy
(test_wave_b_hardening.py): a schema gap must surface as a friendly 503
(SchemaNotInitializedError, never raw DB text), the operator hint must be
logged with the exception type in the *message* text (plain-text-drain safe),
and non-migration errors keep the existing 500 while still naming the
exception type in the log message.

Follows the house convention of calling route functions directly with a fake
Supabase client / patched services (see test_items_routes_coverage.py).
"""
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import items as items_module
from app.core.exceptions import DatabaseError, SchemaNotInitializedError
from app.models.item import ItemCreate
from app.utils.db import items_schema_migration_hint

USER_ID = "11111111-1111-1111-1111-111111111111"


# ============================================================================
# items_schema_migration_hint (unit)
# ============================================================================


class _PGRST204(Exception):
    """Simulates postgrest-py's schema-cache error for a missing column."""

    def __init__(self, table: str, column: str):
        super().__init__(
            f'PGRST204: Could not find the "{column}" column of "{table}" '
            "in the schema cache"
        )


class _PGRST205(Exception):
    """Simulates postgrest-py's error when a table is absent from the schema."""

    def __init__(self, table: str):
        super().__init__(
            f'PGRST205: Could not find the "{table}" relation in the schema cache'
        )


class _UnknownColumn(Exception):
    """Simulates a Postgres 42703 unknown-column error surfaced by PostgREST."""

    def __init__(self, table: str, column: str):
        super().__init__(
            f'ERROR: 42703: column "{column}" of relation "{table}" does not exist'
        )


class _ValueTooLong(Exception):
    """Simulates a Postgres 22001 width violation (VARCHAR(500) image_url)."""

    def __init__(self):
        super().__init__(
            'ERROR: 22001: value too long for type character varying(500)'
        )


def test_hint_missing_items_columns_names_migration_019():
    for error in (
        _PGRST204("items", "source_image_url"),
        _PGRST205("items"),
        _UnknownColumn("items", "source_image_storage_path"),
    ):
        hint = items_schema_migration_hint(error)
        assert "019_add_item_source_image.sql" in hint, error
        assert "source_image_url" in hint or "source_image_storage_path" in hint


def test_hint_value_too_long_names_migration_036():
    for error in (_ValueTooLong(), Exception("value too long for type character varying")):
        hint = items_schema_migration_hint(error)
        assert "036_widen_image_url_columns.sql" in hint, error


def test_hint_empty_for_unrelated_errors():
    assert items_schema_migration_hint(RuntimeError("boom")) == ""
    assert items_schema_migration_hint(Exception("connection reset")) == ""


# ============================================================================
# create_item migration-gap handling (route level)
# ============================================================================


@pytest.mark.asyncio
async def test_create_item_missing_column_returns_503_and_logs_hint(monkeypatch, caplog):
    """A missing items.source_image_url column (migration 019 not applied)
    must surface as a friendly 503 SCHEMA_NOT_INITIALIZED - never an opaque
    500 or raw DB text - with the operator hint (exception type included)
    in the log message text."""
    error = _PGRST204("items", "source_image_url")
    monkeypatch_insert_error(monkeypatch, error)

    with pytest.raises(SchemaNotInitializedError) as exc_info:
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )

    assert exc_info.value.status_code == 503
    # Friendly client message only - no raw DB text, no table/column names.
    assert "PGRST204" not in exc_info.value.message
    assert "source_image_url" not in exc_info.value.message
    assert "items" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "019_add_item_source_image.sql" in logged
    # Exception type must survive Railway's plain-text drain.
    assert "PGRST204" in logged


@pytest.mark.asyncio
async def test_create_item_missing_table_returns_503_and_logs_hint(monkeypatch, caplog):
    error = _PGRST205("items")
    monkeypatch_insert_error(monkeypatch, error)

    with pytest.raises(SchemaNotInitializedError) as exc_info:
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )

    assert exc_info.value.status_code == 503
    assert "PGRST205" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "019_add_item_source_image.sql" in logged
    assert "PGRST205" in logged


@pytest.mark.asyncio
async def test_create_item_value_too_long_returns_503_and_logs_036_hint(monkeypatch, caplog):
    """A VARCHAR(500) image_url rejection (migration 036 not applied) must
    surface as a friendly 503 with the 036 hint in the log text."""
    error = _ValueTooLong()
    monkeypatch_insert_error(monkeypatch, error)

    with pytest.raises(SchemaNotInitializedError) as exc_info:
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )

    assert exc_info.value.status_code == 503
    assert "22001" not in exc_info.value.message

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "036_widen_image_url_columns.sql" in logged
    assert "22001" in logged


@pytest.mark.asyncio
async def test_create_item_non_migration_error_keeps_500_and_logs_type(monkeypatch, caplog):
    """A non-migration failure (e.g. a transient timeout) keeps the existing
    500 DatabaseError, but the exception type now appears in the log message
    text so the cause survives Railway's plain-text drain."""
    monkeypatch_insert_error(monkeypatch, TimeoutError("connection timed out"))

    with pytest.raises(DatabaseError) as exc_info:
        await items_module.create_item(
            item=ItemCreate(name="Tee", category="tops"), user_id=USER_ID, db=Mock()
        )

    assert exc_info.value.status_code == 500

    logged = " ".join(r.getMessage() for r in caplog.records)
    assert "TimeoutError" in logged
    # No migration hint should fire for a non-migration error.
    assert "019_add_item_source_image.sql" not in logged
    assert "036_widen_image_url_columns.sql" not in logged


def monkeypatch_insert_error(monkeypatch, error: Exception) -> None:
    """Make the first DB touch inside create_item (the items insert, which
    runs through execute_with_reconnect) raise `error`."""
    monkeypatch.setattr(
        items_module,
        "execute_with_reconnect",
        AsyncMock(side_effect=error),
    )
