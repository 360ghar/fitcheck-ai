"""
Account-suspension hardening: ``get_current_user`` rejects profiles with
``is_active = False`` (ACCOUNT_SUSPENDED) before any handler runs, and the
token-only ``get_active_user_id`` dependency applies the same gate to routes
that never load the full profile (items, ai, images, users/me, ...).
"""
from unittest.mock import Mock

import pytest
from fastapi.testclient import TestClient

import app.main as main_module
from app.api.v1.deps import get_active_user_id, get_current_user, get_db
from app.core.exceptions import AuthenticationError
from app.core.security import TokenData, verify_token
from admin_test_utils import FakeDB


@pytest.mark.asyncio
async def test_get_current_user_rejects_suspended_profile():
    db = Mock()
    result = Mock()
    result.data = {"id": "user-1", "email": "u@example.com", "is_active": False}
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    token_data.email = "u@example.com"

    with pytest.raises(AuthenticationError) as exc_info:
        await get_current_user(db=db, token_data=token_data)

    assert exc_info.value.error_code == "ACCOUNT_SUSPENDED"
    assert "suspended" in exc_info.value.message.lower()


@pytest.mark.asyncio
async def test_get_current_user_allows_active_profile_without_is_active_key():
    """Legacy rows without the column still pass (missing key != False)."""
    db = Mock()
    result = Mock()
    result.data = {"id": "user-1", "email": "u@example.com"}
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    token_data.email = "u@example.com"

    user = await get_current_user(db=db, token_data=token_data)
    assert user["id"] == "user-1"


def test_suspended_user_rejected_via_api():
    """End-to-end: a suspended user hits a real authed endpoint and gets 401
    ACCOUNT_SUSPENDED (the admin dep chain runs get_current_user first)."""
    db = FakeDB(
        rows={
            "users": [
                {
                    "id": "user-susp",
                    "email": "suspended@example.com",
                    "full_name": "Suspended",
                    "is_active": False,
                    "is_admin": False,
                    "role": "user",
                }
            ]
        }
    )
    app = main_module.app
    app.dependency_overrides[get_db] = lambda: db
    app.dependency_overrides[verify_token] = lambda: TokenData(sub="user-susp")
    try:
        client = TestClient(app)
        response = client.get("/api/v1/admin/me")
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 401
    body = response.json()
    assert body["code"] == "ACCOUNT_SUSPENDED"
    assert body["error"] == "Account is suspended"


# =============================================================================
# get_active_user_id (token-only dependency) — same gate for routes that
# never load the full profile
# =============================================================================


@pytest.mark.asyncio
async def test_get_active_user_id_rejects_suspended_profile():
    db = Mock()
    result = Mock()
    result.data = {"is_active": False}
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    with pytest.raises(AuthenticationError) as exc_info:
        await get_active_user_id(db=db, token_data=token_data)

    assert exc_info.value.error_code == "ACCOUNT_SUSPENDED"
    assert "suspended" in exc_info.value.message.lower()


@pytest.mark.asyncio
async def test_get_active_user_id_rejects_missing_profile():
    """A token whose profile row is gone must not be treated as active."""
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None

    token_data = TokenData(sub="ghost-user")
    with pytest.raises(AuthenticationError) as exc_info:
        await get_active_user_id(db=db, token_data=token_data)

    assert exc_info.value.error_code == "AUTH_PROFILE_NOT_FOUND"


@pytest.mark.asyncio
async def test_get_active_user_id_allows_active_profile_and_returns_sub():
    db = Mock()
    result = Mock()
    result.data = {"is_active": True}
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    assert await get_active_user_id(db=db, token_data=token_data) == "user-1"


@pytest.mark.asyncio
async def test_get_active_user_id_allows_legacy_row_without_flag():
    """Legacy rows without the is_active key still pass (missing key != False)."""
    db = Mock()
    result = Mock()
    result.data = {}
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    assert await get_active_user_id(db=db, token_data=token_data) == "user-1"


@pytest.mark.parametrize(
    "method,path",
    [
        ("GET", "/api/v1/items"),
        ("GET", "/api/v1/ai/models"),
        ("GET", "/api/v1/images/presigned?storage_path=user-susp/items/shot.jpg"),
    ],
)
def test_suspended_user_rejected_on_token_only_routes(method, path):
    """Token-only routers (items/ai/images) must reject suspended accounts
    through get_active_user_id — previously only get_current_user checked
    is_active, so these routes stayed live for suspended users."""
    db = FakeDB(
        rows={
            "users": [
                {
                    "id": "user-susp",
                    "email": "suspended@example.com",
                    "is_active": False,
                    "is_admin": False,
                    "role": "user",
                }
            ]
        }
    )
    app = main_module.app
    app.dependency_overrides[get_db] = lambda: db
    app.dependency_overrides[verify_token] = lambda: TokenData(sub="user-susp")
    try:
        client = TestClient(app)
        response = client.request(method, path)
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 401, f"{method} {path} -> {response.status_code}"
    body = response.json()
    assert body["code"] == "ACCOUNT_SUSPENDED"
    assert body["error"] == "Account is suspended"


def test_suspended_user_rejected_on_put_users_me():
    """A suspended user cannot self-unsuspend: PUT /users/me now runs behind
    get_active_user_id, so the ACCOUNT_SUSPENDED gate fires before the
    handler could write is_active back to True."""
    db = FakeDB(
        rows={
            "users": [
                {
                    "id": "user-susp",
                    "email": "suspended@example.com",
                    "is_active": False,
                    "is_admin": False,
                    "role": "user",
                }
            ]
        }
    )
    app = main_module.app
    app.dependency_overrides[get_db] = lambda: db
    app.dependency_overrides[verify_token] = lambda: TokenData(sub="user-susp")
    try:
        client = TestClient(app)
        response = client.put("/api/v1/users/me", json={"is_active": True})
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 401
    body = response.json()
    assert body["code"] == "ACCOUNT_SUSPENDED"
    # The self-unsuspend write must never have been attempted.
    assert db.updates == []
