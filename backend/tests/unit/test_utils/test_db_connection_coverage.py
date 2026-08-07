"""Residual branch coverage for app.db.connection.

Sibling test_db_connection_retry.py exercises the reconnect wrappers; this
file covers the singleton client creation branches (including the missing-
credentials guards), reset, the already-rebuilt path of
rebuild_service_client, and the three async dependency helpers.
"""

from unittest.mock import Mock

import pytest

from app.db import connection
from app.db.connection import SupabaseDB


@pytest.fixture(autouse=True)
def _clean_singletons():
    SupabaseDB.reset()
    yield
    SupabaseDB.reset()


def _env(monkeypatch):
    monkeypatch.setattr(connection.settings, "SUPABASE_URL", "https://proj.supabase.co")
    monkeypatch.setattr(connection.settings, "SUPABASE_PUBLISHABLE_KEY", "anon-key")
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "service-key")


def test_get_client_creates_singleton(monkeypatch):
    _env(monkeypatch)
    client = Mock()
    monkeypatch.setattr(connection, "create_client", Mock(return_value=client))
    assert SupabaseDB.get_client() is client
    assert SupabaseDB.get_client() is client  # cached
    connection.create_client.assert_called_once_with(
        "https://proj.supabase.co", "anon-key"
    )


def test_get_client_missing_credentials_raises(monkeypatch):
    monkeypatch.setattr(connection.settings, "SUPABASE_URL", "")
    monkeypatch.setattr(connection.settings, "SUPABASE_PUBLISHABLE_KEY", "")
    with pytest.raises(ValueError, match="must be set"):
        SupabaseDB.get_client()


def test_get_service_client_creates_singleton(monkeypatch):
    _env(monkeypatch)
    client = Mock()
    monkeypatch.setattr(connection, "create_client", Mock(return_value=client))
    assert SupabaseDB.get_service_client() is client
    assert SupabaseDB.get_service_client() is client
    connection.create_client.assert_called_once_with(
        "https://proj.supabase.co", "service-key"
    )


def test_get_service_client_missing_credentials_raises(monkeypatch):
    _env(monkeypatch)
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "")
    with pytest.raises(ValueError, match="must be set"):
        SupabaseDB.get_service_client()


def test_rebuild_service_client_returns_existing_when_not_stale(monkeypatch):
    _env(monkeypatch)
    current = Mock()
    monkeypatch.setattr(SupabaseDB, "_service_instance", current)
    # A different (stale) client than the singleton -> already rebuilt by a
    # peer waiter -> reuse it without creating.
    monkeypatch.setattr(connection, "create_client", Mock(side_effect=AssertionError("no create")))
    rebuilt = SupabaseDB.rebuild_service_client(stale=Mock())
    assert rebuilt is current


def test_rebuild_service_client_recreates(monkeypatch):
    _env(monkeypatch)
    fresh = Mock()
    monkeypatch.setattr(connection, "create_client", Mock(return_value=fresh))
    rebuilt = SupabaseDB.rebuild_service_client(stale=None)
    assert rebuilt is fresh
    assert SupabaseDB._service_instance is fresh
    # Both singletons were dropped by the rebuild.
    assert SupabaseDB._instance is None


def test_rebuild_service_client_missing_credentials_raises(monkeypatch):
    _env(monkeypatch)
    monkeypatch.setattr(connection.settings, "SUPABASE_SECRET_KEY", "")
    with pytest.raises(ValueError, match="must be set"):
        SupabaseDB.rebuild_service_client()


@pytest.mark.asyncio
async def test_db_dependency_helpers(monkeypatch):
    _env(monkeypatch)
    service = Mock()
    anon = Mock()
    monkeypatch.setattr(connection, "create_client", Mock(side_effect=[service, anon]))

    assert await connection.get_db() is service
    assert await connection.get_anon_db() is anon
    assert await connection.get_service_db() is service
