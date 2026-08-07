"""
Admin authorization tests: every /api/v1/admin/* endpoint 403s for a plain
user and is reachable for an admin. The route list is derived from the live
OpenAPI schema so a newly added admin endpoint cannot silently miss the gate.
"""
from contextlib import contextmanager

import pytest
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_current_user, get_db
from tests.utils.fake_db import FakeDB

PLAIN_USER = {
    "id": "user-plain",
    "email": "plain@example.com",
    "full_name": "Plain User",
    "is_active": True,
    "is_admin": False,
    "role": "user",
}

ADMIN_USER = {
    "id": "user-admin",
    "email": "admin@example.com",
    "full_name": "Admin User",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}

# Path-param sample values used to build request URLs.
PARAM_SAMPLES = {
    "user_id": "user-1",
    "txn_id": "txn-1",
    "ticket_id": "ticket-1",
    "code_id": "code-1",
    "entity_type": "user",
    "entity_id": "user-1",
}

# Routes that touch object storage / the real schema cache — covered in
# test_admin_ops.py with mocks, excluded here to avoid real network calls.
NETWORK_ROUTES = {
    ("GET", "/api/v1/admin/ops/health"),
    ("GET", "/api/v1/admin/ops/storage"),
    ("DELETE", "/api/v1/admin/ops/storage/temp"),
}


def _admin_routes():
    schema = main_module.app.openapi()
    routes = []
    for path, operations in schema["paths"].items():
        if not path.startswith("/api/v1/admin"):
            continue
        for method in operations:
            if method in ("get", "post", "patch", "delete"):
                routes.append((method.upper(), path))
    return routes


def _fill_path(path: str) -> str:
    for name, sample in PARAM_SAMPLES.items():
        path = path.replace("{" + name + "}", sample)
    return path


def _body_for(method: str, path: str):
    if method == "POST" and path == "/api/v1/admin/promo-codes":
        return {"code": "TEST100", "plan_type": "pro_monthly", "months": 1}
    if method in ("POST", "PATCH", "DELETE"):
        return None if method == "DELETE" else {}
    return None


@pytest.fixture
def client():
    return TestClient(main_module.app)


@contextmanager
def _with_user(client, user, db=None):
    client.app.dependency_overrides[get_current_user] = lambda: user
    if db is not None:
        client.app.dependency_overrides[get_db] = lambda: db
    try:
        yield
    finally:
        client.app.dependency_overrides.clear()


@pytest.mark.parametrize("method,path", _admin_routes())
def test_non_admin_is_forbidden_on_every_admin_route(client, method, path):
    """A plain user (no is_admin, non-@fitcheckaiapp.com email) gets 403."""
    with _with_user(client, PLAIN_USER, FakeDB()):
        url = _fill_path(path)
        if path == "/api/v1/admin/search":
            url += "?q=test"
        response = client.request(method, url, json=_body_for(method, path))
        assert response.status_code == 403, f"{method} {path} -> {response.status_code}"


def test_admin_me_returns_role_and_permissions(client):
    with _with_user(client, ADMIN_USER, FakeDB()):
        response = client.get("/api/v1/admin/me")
    assert response.status_code == 200
    body = response.json()
    assert body["role"] == "admin"
    assert "*" in body["permissions"]
    assert body["user"]["id"] == "user-admin"


def test_super_admin_me_returns_star_permissions(client):
    super_admin = {**ADMIN_USER, "role": "super_admin"}
    with _with_user(client, super_admin, FakeDB()):
        response = client.get("/api/v1/admin/me")
    assert response.status_code == 200
    assert response.json()["role"] == "super_admin"
    assert "*" in response.json()["permissions"]


def test_legacy_email_admin_gets_admin_role(client):
    """@fitcheckaiapp.com email without is_admin/role still bootstraps admin."""
    legacy = {
        "id": "user-legacy",
        "email": "founder@fitcheckaiapp.com",
        "full_name": "Founder",
        "is_active": True,
        "is_admin": False,
        "role": "user",
    }
    with _with_user(client, legacy, FakeDB()):
        response = client.get("/api/v1/admin/me")
    assert response.status_code == 200
    assert response.json()["role"] == "admin"


@pytest.mark.parametrize("method,path", _admin_routes())
def test_admin_reaches_every_admin_route(client, method, path):
    """An admin is never blocked by the authz gate (empty fake DB -> expected
    200/404/etc. outcomes; no real services are touched)."""
    if (method, path) in NETWORK_ROUTES:
        pytest.skip("covered in test_admin_ops.py with mocks")
    with _with_user(client, ADMIN_USER, FakeDB()):
        url = _fill_path(path)
        if path == "/api/v1/admin/search":
            url += "?q=test"
        response = client.request(method, url, json=_body_for(method, path))
        if method == "POST" and path == "/api/v1/admin/subscriptions/user/{user_id}/refund":
            allowed = (200, 404, 503)
        elif method == "POST":
            allowed = (200, 201, 404)
        elif method == "PATCH":
            allowed = (200, 404, 422)
        else:
            # GETs: list endpoints 200; detail endpoints 404 on empty DB.
            allowed = (200, 404)
        assert response.status_code in allowed, (
            f"{method} {path} -> {response.status_code} {response.text[:200]}"
        )


def test_ops_network_routes_still_gated_for_non_admin(client):
    """The network-touching ops routes are part of the 403 sweep (authz fails
    before any storage/schema call)."""
    for method, path in sorted(NETWORK_ROUTES):
        with _with_user(client, PLAIN_USER, FakeDB()):
            response = client.request(method, _fill_path(path))
            assert response.status_code == 403, f"{method} {path}"


# =============================================================================
# Pure RBAC unit checks (app.core.permissions)
# =============================================================================


def test_get_user_role_priority_and_fallbacks():
    from app.core.permissions import get_user_role

    # Explicit admin role wins even with a non-admin email.
    assert get_user_role({"role": "ops", "email": "ops@example.com", "is_admin": False}) == "ops"
    # is_admin flag fallback.
    assert get_user_role({"role": "user", "email": "x@example.com", "is_admin": True}) == "admin"
    # Legacy email fallback.
    assert get_user_role({"role": "user", "email": "founder@fitcheckaiapp.com", "is_admin": False}) == "admin"
    # Plain user.
    assert get_user_role({"email": "plain@example.com"}) == "user"


def test_has_permission_star_and_role_maps():
    from app.core.permissions import has_permission

    assert has_permission({"role": "admin", "email": "a@example.com"}, "storage.cleanup") is True
    assert has_permission({"role": "super_admin", "email": "a@example.com"}, "anything.at.all") is True
    assert has_permission({"role": "ops", "email": "o@example.com"}, "subscriptions.refund") is True
    assert has_permission({"role": "ops", "email": "o@example.com"}, "feedback.write") is False
    assert has_permission({"role": "support", "email": "s@example.com"}, "feedback.write") is True
    assert has_permission({"role": "content_editor", "email": "c@example.com"}, "content.write") is True
    assert has_permission({"role": "content_editor", "email": "c@example.com"}, "users.read") is False
    assert has_permission({"role": "user", "email": "p@example.com"}, "search") is False


# =============================================================================
# Admin role/suspend edits (admin_service.update_user guards)
# =============================================================================

SUPPORT_USER = {
    "id": "user-support",
    "email": "support@example.com",
    "full_name": "Support User",
    "is_active": True,
    "is_admin": False,
    "role": "support",
}

TARGET_ADMIN_ROW = {
    "id": "user-1",
    "email": "target@example.com",
    "full_name": "Target Admin",
    "is_active": True,
    "is_admin": True,
    "role": "admin",
}


def test_self_role_change_rejected(client):
    """A users.write holder must not PATCH their OWN role to escalate
    (previously only self-demotion/self-suspension were blocked)."""
    db = FakeDB(rows={"users": [ADMIN_USER]})
    with _with_user(client, ADMIN_USER, db):
        response = client.patch(
            "/api/v1/admin/users/user-admin", json={"role": "super_admin"}
        )
    assert response.status_code == 422
    assert "own role" in response.json()["error"].lower()


def test_support_cannot_grant_admin_roles(client):
    """support/ops must not promote others into admin roles (only the
    last-admin check existed before, so promotions were unrestricted)."""
    db = FakeDB(rows={"users": [PLAIN_USER]})
    with _with_user(client, SUPPORT_USER, db):
        response = client.patch(
            "/api/v1/admin/users/user-plain", json={"role": "admin"}
        )
    assert response.status_code == 422
    assert "grant admin" in response.json()["error"].lower()


def test_admin_demote_by_support_rejected(client):
    """support/ops must not demote existing admins either."""
    db = FakeDB(rows={"users": [TARGET_ADMIN_ROW]})
    with _with_user(client, SUPPORT_USER, db):
        response = client.patch(
            "/api/v1/admin/users/user-1", json={"role": "user"}
        )
    assert response.status_code == 422
    assert "admin" in response.json()["error"].lower()


def test_last_admin_suspension_rejected(client):
    """Suspending the last admin must fail the same way demoting them does:
    the last-admin existence check now also runs for is_active=False."""
    db = FakeDB(rows={"users": [TARGET_ADMIN_ROW]})
    with _with_user(client, ADMIN_USER, db):
        response = client.patch(
            "/api/v1/admin/users/user-1", json={"is_active": False}
        )
    assert response.status_code == 422
    assert "suspend the last admin" in response.json()["error"].lower()
