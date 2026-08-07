"""
Admin audit tests: audit listing + filters, per-entity history, and the
never-raise contract of record_audit.
"""
from unittest.mock import Mock

import pytest
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user, get_db
from tests.utils.fake_db import FakeDB
from app.services.audit_service import record_audit

ADMIN = {
    "id": "user-admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}

EVENT_1 = {
    "id": "a1",
    "actor_id": "user-admin",
    "action": "user.role_changed",
    "entity_type": "user",
    "entity_id": "user-1",
    "payload": {"field": "role", "before": "user", "after": "ops"},
    "ip": "1.2.3.4",
    "user_agent": "pytest",
    "created_at": "2026-08-06T00:00:00",
    "users": {"email": "admin@example.com", "full_name": "Admin User"},
}

EVENT_2 = {
    "id": "a2",
    "actor_id": "user-admin",
    "action": "promo.created",
    "entity_type": "promo_code",
    "entity_id": "p1",
    "payload": {"code": "SUMMER25"},
    "ip": "1.2.3.4",
    "user_agent": "pytest",
    "created_at": "2026-08-05T00:00:00",
    "users": {"email": "admin@example.com", "full_name": "Admin User"},
}


@pytest.fixture
def client():
    return TestClient(main_module.app)


def _call(client, method, url, user=ADMIN, db=None, **kwargs):
    app = client.app
    app.dependency_overrides[get_current_user] = lambda: user
    app.dependency_overrides[get_db] = lambda: db or FakeDB()
    try:
        return client.request(method, url, **kwargs)
    finally:
        app.dependency_overrides.clear()


def test_audit_list_returns_envelope_with_actor_email(client):
    db = FakeDB(rows={"audit_events": [EVENT_1, EVENT_2]})
    response = _call(client, "GET", "/api/v1/admin/audit", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 2
    first = body["items"][0]
    assert first["actor"]["email"] == "admin@example.com"
    assert first["payload"]["before"] == "user"
    assert first["entity_type"] == "user"


def test_audit_list_action_filter(client):
    db = FakeDB(rows={"audit_events": [EVENT_1, EVENT_2]})
    response = _call(client, "GET", "/api/v1/admin/audit?action=role", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["action"] == "user.role_changed"


def test_audit_list_entity_filter(client):
    db = FakeDB(rows={"audit_events": [EVENT_1, EVENT_2]})
    response = _call(client, "GET", "/api/v1/admin/audit?entity_type=promo_code&entity_id=p1", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["id"] == "a2"


def test_audit_list_actor_filter(client):
    db = FakeDB(
        rows={
            "audit_events": [
                EVENT_1,
                {**EVENT_1, "id": "a9", "actor_id": "someone-else"},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/audit?actor_id=user-admin", db=db)
    assert response.status_code == 200
    assert response.json()["total"] == 1


def test_audit_list_date_range_filter(client):
    db = FakeDB(rows={"audit_events": [EVENT_1, EVENT_2]})
    response = _call(
        client,
        "GET",
        "/api/v1/admin/audit?from=2026-08-05T12:00:00&to=2026-08-06T12:00:00",
        db=db,
    )
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["id"] == "a1"


def test_entity_audit_history(client):
    db = FakeDB(rows={"audit_events": [EVENT_1, EVENT_2]})
    response = _call(client, "GET", "/api/v1/admin/audit/entity/user/user-1", db=db)
    assert response.status_code == 200
    body = response.json()
    assert isinstance(body, list)
    assert len(body) == 1
    assert body[0]["id"] == "a1"


@pytest.mark.asyncio
async def test_record_audit_never_raises_on_db_failure():
    db = Mock()
    db.table.side_effect = RuntimeError("boom")
    # Must not raise, by contract.
    await record_audit(db, actor_id="user-admin", action="test.action", entity_type="user", entity_id="user-1")


@pytest.mark.asyncio
async def test_record_audit_writes_row():
    db = FakeDB()
    await record_audit(
        db,
        actor_id="user-admin",
        action="user.role_changed",
        entity_type="user",
        entity_id="user-1",
        payload={"field": "role", "before": "user", "after": "admin"},
        ip="1.2.3.4",
        user_agent="pytest",
    )
    db.assert_insert(
        "audit_events",
        actor_id="user-admin",
        action="user.role_changed",
        entity_type="user",
        entity_id="user-1",
        ip="1.2.3.4",
        user_agent="pytest",
    )
