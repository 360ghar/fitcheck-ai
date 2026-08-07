"""
Admin ops tests: health passthrough (liveness + schema readiness) and the
storage temp inventory/cleanup (happy + failure paths). All storage and
schema-cache calls are mocked — no real network.
"""
from unittest.mock import AsyncMock, patch

import pytest
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user, get_db
from tests.utils.fake_db import FakeDB
from app.core.config import settings
from app.services.admin_service import TEMP_DELETE_MAX_OBJECTS

ADMIN = {
    "id": "user-admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}


@pytest.fixture
def client(monkeypatch):
    # Deterministic storage config so the not-configured branch is testable
    # and configured branches never touch the real bucket.
    monkeypatch.setattr(settings, "OBJECT_STORAGE_ENDPOINT", "https://s3.example.com")
    monkeypatch.setattr(settings, "OBJECT_STORAGE_BUCKET", "test-bucket")
    return TestClient(main_module.app)


def _call(client, method, url, user=ADMIN, db=None, **kwargs):
    app = client.app
    app.dependency_overrides[get_current_user] = lambda: user
    app.dependency_overrides[get_db] = lambda: db or FakeDB()
    try:
        return client.request(method, url, **kwargs)
    finally:
        app.dependency_overrides.clear()


# =============================================================================
# Health
# =============================================================================


def test_ops_health_mirrors_public_health_plus_schema(client):
    with patch.object(main_module, "_get_cached_schema_status", return_value=(True, [])):
        response = _call(client, "GET", "/api/v1/admin/ops/health")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "healthy"
    assert body["service"] == settings.PROJECT_NAME
    assert body["version"] == settings.VERSION
    assert body["commit"] == settings.RAILWAY_GIT_COMMIT_SHA
    assert "rss_mb" in body
    assert body["schema_ready"] is True


def test_ops_health_reports_schema_gap(client):
    with patch.object(main_module, "_get_cached_schema_status", return_value=(False, ["audit_events"])):
        response = _call(client, "GET", "/api/v1/admin/ops/health")
    assert response.status_code == 200
    assert response.json()["schema_ready"] is False


# =============================================================================
# Storage inventory
# =============================================================================


def _temp_item(key: str, size: int, when: str) -> dict:
    return {"key": key, "size": size, "last_modified": when}


def test_ops_storage_inventory_shape(client):
    items = [
        _temp_item("u1/tmp/photoshoot/a.png", 100, "2026-08-05T00:00:00+00:00"),
        _temp_item("u2/tmp/social-import/b.webp", 200, "2026-08-06T00:00:00+00:00"),
    ]
    inventory = {
        "scanned_keys": 250,
        "count": 2,
        "total_bytes": 300,
        "oldest": items[0],
        "newest": items[1],
        "items": items,
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ) as list_temp:
        response = _call(client, "GET", "/api/v1/admin/ops/storage")

    assert response.status_code == 200
    body = response.json()
    assert body["bucket"] == "test-bucket"
    assert body["count"] == 2
    assert body["total_bytes"] == 300
    assert body["oldest"]["key"] == "u1/tmp/photoshoot/a.png"
    assert body["newest"]["key"] == "u2/tmp/social-import/b.webp"
    assert len(body["items"]) == 2
    assert body["truncated"] is False
    list_temp.assert_awaited_once()


def test_ops_storage_inventory_truncates_display_items(client):
    items = [_temp_item(f"u{i}/tmp/photoshoot/x.png", 1, "2026-08-01T00:00:00+00:00") for i in range(150)]
    inventory = {
        "scanned_keys": 150,
        "count": 150,
        "total_bytes": 150,
        "oldest": items[0],
        "newest": items[-1],
        "items": items,
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ):
        response = _call(client, "GET", "/api/v1/admin/ops/storage")
    assert response.status_code == 200
    assert len(response.json()["items"]) == 100


def test_ops_storage_not_configured_503(client, monkeypatch):
    monkeypatch.setattr(settings, "OBJECT_STORAGE_ENDPOINT", "")
    response = _call(client, "GET", "/api/v1/admin/ops/storage")
    assert response.status_code == 503
    assert response.json()["code"] == "STORAGE_SERVICE_ERROR"


# =============================================================================
# Storage cleanup
# =============================================================================


def test_ops_storage_cleanup_happy_path_and_audit(client):
    items = [
        _temp_item("u1/tmp/photoshoot/a.png", 100, "2026-08-05T00:00:00+00:00"),
        _temp_item("u2/tmp/social-import/b.webp", 200, "2026-08-06T00:00:00+00:00"),
    ]
    inventory = {
        "scanned_keys": 250,
        "count": 2,
        "total_bytes": 300,
        "oldest": items[0],
        "newest": items[1],
        "items": items,
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ):
        with patch(
            "app.services.storage_service.StorageService.delete_temp_objects",
            new=AsyncMock(return_value=2),
        ) as delete_temp:
            db = FakeDB()
            response = _call(client, "DELETE", "/api/v1/admin/ops/storage/temp", db=db)

    assert response.status_code == 200
    body = response.json()
    assert body["deleted"] == 2
    assert body["bytes_freed"] == 300
    assert body["remaining"] == 0
    assert body["truncated"] is False
    delete_temp.assert_awaited_once()
    db.assert_insert("audit_events", action="storage.temp_cleaned", entity_type="storage")


def test_ops_storage_cleanup_respects_delete_cap(client):
    items = [
        _temp_item(f"u{i}/tmp/photoshoot/x.png", 1, "2026-08-01T00:00:00+00:00")
        for i in range(TEMP_DELETE_MAX_OBJECTS + 10)
    ]
    inventory = {
        "scanned_keys": len(items),
        "count": len(items),
        "total_bytes": len(items),
        "oldest": items[0],
        "newest": items[-1],
        "items": items,
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ):
        with patch(
            "app.services.storage_service.StorageService.delete_temp_objects",
            new=AsyncMock(return_value=TEMP_DELETE_MAX_OBJECTS),
        ) as delete_temp:
            response = _call(client, "DELETE", "/api/v1/admin/ops/storage/temp", db=FakeDB())

    assert response.status_code == 200
    body = response.json()
    assert body["deleted"] == TEMP_DELETE_MAX_OBJECTS
    assert body["remaining"] == 10
    assert body["truncated"] is True
    # Only the cap's worth of keys is ever sent to the backend.
    sent_keys = delete_temp.await_args.args[0]
    assert len(sent_keys) == TEMP_DELETE_MAX_OBJECTS


def test_ops_storage_cleanup_failure_path(client):
    items = [_temp_item("u1/tmp/photoshoot/a.png", 100, "2026-08-05T00:00:00+00:00")]
    inventory = {
        "scanned_keys": 1,
        "count": 1,
        "total_bytes": 100,
        "oldest": items[0],
        "newest": items[0],
        "items": items,
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ):
        with patch(
            "app.services.storage_service.StorageService.delete_temp_objects",
            new=AsyncMock(side_effect=RuntimeError("bucket down")),
        ):
            response = _call(client, "DELETE", "/api/v1/admin/ops/storage/temp", db=FakeDB())

    assert response.status_code == 503
    assert response.json()["code"] == "STORAGE_SERVICE_ERROR"


def test_ops_storage_cleanup_nothing_to_delete(client):
    inventory = {
        "scanned_keys": 0,
        "count": 0,
        "total_bytes": 0,
        "oldest": None,
        "newest": None,
        "items": [],
        "truncated": False,
    }
    with patch(
        "app.services.storage_service.StorageService.list_temp_objects",
        new=AsyncMock(return_value=inventory),
    ):
        response = _call(client, "DELETE", "/api/v1/admin/ops/storage/temp", db=FakeDB())

    assert response.status_code == 200
    body = response.json()
    assert body["deleted"] == 0
    assert body["bytes_freed"] == 0
    assert body["remaining"] == 0
