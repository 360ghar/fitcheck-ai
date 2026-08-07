"""
Admin user management tests: list/search/filter/pagination, PATCH role +
suspend with the self-demotion and last-admin guards, activity endpoint.
"""
import pytest
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user, get_db
from tests.utils.fake_db import FakeDB

ADMIN = {
    "id": "user-admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}

TARGET = {
    "id": "user-1",
    "email": "target@example.com",
    "full_name": "Target User",
    "is_active": True,
    "is_admin": False,
    "role": "user",
    "created_at": "2026-01-01T00:00:00",
    "last_login_at": "2026-08-01T00:00:00",
}

TARGET_ADMIN = {
    "id": "user-1",
    "email": "target@example.com",
    "full_name": "Target Admin",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
    "created_at": "2026-01-01T00:00:00",
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


# =============================================================================
# List / search / filter / pagination
# =============================================================================


def test_list_users_returns_envelope_with_embedded_counts(client):
    db = FakeDB(
        rows={
            "users": [
                {
                    **TARGET,
                    "subscriptions": {
                        "plan_type": "pro_monthly",
                        "status": "active",
                        "current_period_start": "2026-08-01T00:00:00",
                    },
                    "outfits": [{"count": 3}],
                    "items": [{"count": 7}],
                }
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/users", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["page"] == 1
    assert body["page_size"] == 20
    item = body["items"][0]
    assert item["id"] == "user-1"
    assert item["subscription"]["plan_type"] == "pro_monthly"
    assert item["outfits_count"] == 3
    assert item["items_count"] == 7


def test_list_users_accepts_all_filters(client):
    db = FakeDB(
        rows={
            "users": [
                {**TARGET, "subscriptions": {"plan_type": "free", "status": "active"}}
            ]
        }
    )
    response = _call(
        client,
        "GET",
        "/api/v1/admin/users?q=target&status=active&role=user&plan=free"
        "&sort_by=created_at&sort_dir=desc&page=1&page_size=50",
        db=db,
    )
    assert response.status_code == 200
    assert response.json()["items"][0]["id"] == "user-1"


def test_list_users_search_filters_by_email(client):
    db = FakeDB(
        rows={
            "users": [
                TARGET,
                {**TARGET, "id": "user-2", "email": "other@example.com", "full_name": "Other User"},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/users?q=target", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["email"] == "target@example.com"


def test_list_users_status_suspended_filter(client):
    db = FakeDB(
        rows={
            "users": [
                TARGET,
                {**TARGET, "id": "user-2", "is_active": False},
            ]
        }
    )
    response = _call(client, "GET", "/api/v1/admin/users?status=suspended", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["total"] == 1
    assert body["items"][0]["is_active"] is False


def test_list_users_page_size_capped(client):
    response = _call(client, "GET", "/api/v1/admin/users?page_size=101")
    assert response.status_code == 422


# =============================================================================
# Detail
# =============================================================================


def test_user_detail_returns_full_snapshot(client):
    db = FakeDB(
        rows={
            "users": [TARGET],
            "subscriptions": [
                {
                    "user_id": "user-1",
                    "plan_type": "pro_monthly",
                    "status": "active",
                    "billing_provider": "stripe",
                    "stripe_customer_id": "cus_123",
                    "current_period_start": "2026-08-01T00:00:00",
                }
            ],
            "user_ai_settings": [
                {
                    "user_id": "user-1",
                    "daily_extraction_count": 12,
                    "daily_generation_count": 3,
                    "daily_embedding_count": 0,
                    "last_reset_date": "2026-08-06",
                    "total_extractions": 40,
                }
            ],
            "subscription_usage": [
                {
                    "user_id": "user-1",
                    "period_start": "2026-08-01",
                    "monthly_extractions": 12,
                    "daily_photoshoot_images": 2,
                }
            ],
            "extraction_jobs": [
                {"id": "job-1", "user_id": "user-1", "status": "completed", "job_type": "batch", "created_at": "2026-08-06T00:00:00"}
            ],
            "photoshoot_jobs": [
                {"id": "job-2", "user_id": "user-1", "status": "complete", "use_case": "try-on", "created_at": "2026-08-06T01:00:00"}
            ],
        }
    )
    response = _call(client, "GET", "/api/v1/admin/users/user-1", db=db)
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["id"] == "user-1"
    assert body["subscription"]["stripe_customer_id"] == "cus_123"
    assert body["usage"]["ai"]["daily_extraction_count"] == 12
    assert body["counts"]["outfits"] == 0
    assert body["counts"]["items"] == 0
    assert {job["id"] for job in body["recent_jobs"]} == {"job-1", "job-2"}


def test_user_detail_missing_user_404(client):
    response = _call(client, "GET", "/api/v1/admin/users/user-ghost", db=FakeDB())
    assert response.status_code == 404


# =============================================================================
# PATCH
# =============================================================================


def test_patch_role_change_updates_and_audits(client):
    db = FakeDB(rows={"users": [TARGET]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        db=db,
        json={"role": "ops"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["user"]["role"] == "ops"
    assert body["changes"][0]["action"] == "user.role_changed"
    db.assert_update("users", role="ops")
    db.assert_insert("audit_events", action="user.role_changed", entity_id="user-1")


def test_patch_suspend_updates_and_audits(client):
    db = FakeDB(rows={"users": [TARGET]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        db=db,
        json={"is_active": False},
    )
    assert response.status_code == 200
    db.assert_update("users", is_active=False)
    db.assert_insert("audit_events", action="user.status_changed", entity_id="user-1")


def test_patch_invalid_role_rejected(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        db=FakeDB(rows={"users": [TARGET]}),
        json={"role": "god"},
    )
    assert response.status_code == 422


def test_patch_no_changes_rejected(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        db=FakeDB(rows={"users": [TARGET]}),
        json={},
    )
    assert response.status_code == 422


def test_patch_missing_user_404(client):
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-ghost",
        db=FakeDB(),
        json={"role": "ops"},
    )
    assert response.status_code == 404


def test_patch_self_demotion_rejected(client):
    db = FakeDB(rows={"users": [TARGET_ADMIN]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        user=TARGET_ADMIN,  # actor IS the target
        db=db,
        json={"role": "user"},
    )
    assert response.status_code == 422
    assert "demote" in response.json()["error"].lower()


def test_patch_self_suspend_rejected(client):
    db = FakeDB(rows={"users": [TARGET_ADMIN]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        user=TARGET_ADMIN,
        db=db,
        json={"is_active": False},
    )
    assert response.status_code == 422


def test_patch_last_admin_rejected(client):
    """Only admin in the DB: demoting them must fail."""
    db = FakeDB(rows={"users": [TARGET_ADMIN]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        user=ADMIN,
        db=db,
        json={"role": "user"},
    )
    assert response.status_code == 422
    assert "last admin" in response.json()["error"].lower()


def test_patch_demote_allowed_when_another_admin_exists(client):
    other_admin = {**TARGET_ADMIN, "id": "user-2", "email": "other-admin@example.com"}
    db = FakeDB(rows={"users": [TARGET_ADMIN, other_admin]})
    response = _call(
        client,
        "PATCH",
        "/api/v1/admin/users/user-1",
        user=ADMIN,
        db=db,
        json={"role": "user"},
    )
    assert response.status_code == 200
    db.assert_update("users", role="user")
    db.assert_insert("audit_events", action="user.role_changed", entity_id="user-1")


# =============================================================================
# Activity
# =============================================================================


def test_user_activity_returns_audit_and_jobs(client):
    db = FakeDB(
        rows={
            "users": [TARGET],
            "audit_events": [
                {
                    "id": "a1",
                    "actor_id": "user-admin",
                    "action": "user.role_changed",
                    "entity_type": "user",
                    "entity_id": "user-1",
                    "payload": {"field": "role"},
                    "created_at": "2026-08-06T00:00:00",
                },
                {
                    "id": "a2",
                    "actor_id": "user-1",
                    "action": "feedback.updated",
                    "entity_type": "support_ticket",
                    "entity_id": "t-1",
                    "payload": {},
                    "created_at": "2026-08-05T00:00:00",
                },
            ],
            "extraction_jobs": [
                {"id": "job-1", "user_id": "user-1", "status": "completed", "created_at": "2026-08-06T00:00:00"}
            ],
        }
    )
    response = _call(client, "GET", "/api/v1/admin/users/user-1/activity", db=db)
    assert response.status_code == 200
    body = response.json()
    assert {item["id"] for item in body["audit_events"]} == {"a1", "a2"}
    assert body["recent_jobs"][0]["id"] == "job-1"


def test_user_activity_missing_user_404(client):
    response = _call(client, "GET", "/api/v1/admin/users/user-ghost/activity", db=FakeDB())
    assert response.status_code == 404
