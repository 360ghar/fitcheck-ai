"""Contract tests for the error envelope: every failure response must carry
``error`` / ``code`` / ``details`` / ``correlation_id`` and the right status.

Covers the four handlers in ``app/main.py``: FitCheckException, Starlette
HTTPException, RequestValidationError, and the unhandled-exception catch-all.
"""

from __future__ import annotations

from fastapi.testclient import TestClient

from app.api.v1.deps import get_active_user_id
from app.core.exceptions import AuthenticationError
from tests.utils.assertions import assert_error_envelope, assert_validation_error


# ---------------------------------------------------------------------------
# FitCheckException handler
# ---------------------------------------------------------------------------


def test_fitcheck_exception_envelope_from_dependency(client, db):
    """A FitCheckException raised inside a dependency still goes through the
    app's handler (this is how every 401/403/404 in the API is produced)."""

    def _suspended():
        raise AuthenticationError(message="Account is suspended", error_code="ACCOUNT_SUSPENDED")

    client.app.dependency_overrides[get_active_user_id] = _suspended
    try:
        response = client.get("/api/v1/users/me")
    finally:
        client.app.dependency_overrides.clear()

    body = assert_error_envelope(response, status_code=401, code="ACCOUNT_SUSPENDED")
    assert body["error"] == "Account is suspended"
    assert isinstance(body["correlation_id"], str) and body["correlation_id"]


def test_unknown_route_uses_http_exception_envelope(client):
    """Starlette 404s (unknown route) use the HTTP_ERROR envelope."""
    response = client.get("/api/v1/definitely-not-a-route")

    assert_error_envelope(response, status_code=404, code="HTTP_ERROR")
    assert response.json()["error"] == "Not Found"


def test_validation_error_envelope_lists_fields(client, db, anon_db):
    """A 422 from FastAPI's validator must name every failing field."""
    response = client.post(
        "/api/v1/auth/register",
        json={
            "email": "not-an-email",
            "password": "short",
            "full_name": "x" * 300,  # exceeds max_length=255
        },
    )

    assert_validation_error(
        response,
        fields={"body.email", "body.password", "body.full_name"},
    )


def test_unhandled_exception_returns_generic_500_without_leak(client, db):
    """A RuntimeError must produce INTERNAL_ERROR with no internal details.

    Uses ``raise_server_exceptions=False``: Starlette's ServerErrorMiddleware
    deliberately re-raises the exception after sending the 500 so servers/test
    clients can log it — a handled exception is the whole point here.
    """
    quiet_client = TestClient(client.app, raise_server_exceptions=False)

    def _explode():
        raise RuntimeError("secret internal detail: db-password=xyz")

    quiet_client.app.dependency_overrides[get_active_user_id] = _explode
    try:
        response = quiet_client.get("/api/v1/users/me")
    finally:
        quiet_client.app.dependency_overrides.clear()

    body = assert_error_envelope(response, status_code=500, code="INTERNAL_ERROR")
    assert body["error"] == "An unexpected error occurred"
    assert "secret internal detail" not in response.text
    assert "db-password" not in response.text


# ---------------------------------------------------------------------------
# Correlation ID travels with every error response
# ---------------------------------------------------------------------------


def test_fitcheck_error_echoes_request_correlation_id(client, db):
    """The correlation_id in the body must echo the request's header when one
    was supplied (distributed tracing round-trip)."""
    response = client.get(
        "/api/v1/users/me",
        headers={"X-Correlation-ID": "trace-123"},
    )

    # No user row seeded -> the real get_active_user_id dependency 401s.
    assert response.status_code == 401
    assert response.json()["correlation_id"] == "trace-123"
    assert response.headers.get("X-Correlation-ID") == "trace-123"


def test_http_error_echoes_request_correlation_id(client):
    response = client.get(
        "/api/v1/definitely-not-a-route",
        headers={"X-Correlation-ID": "trace-456"},
    )

    assert response.status_code == 404
    assert response.json()["correlation_id"] == "trace-456"
    assert response.headers.get("X-Correlation-ID") == "trace-456"
