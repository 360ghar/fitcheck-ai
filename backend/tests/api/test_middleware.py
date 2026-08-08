"""Contract tests for the middleware stack: correlation IDs, request
logging, and CORS — the app-level behavior that direct-call tests bypass."""

from __future__ import annotations

import logging

import pytest

from tests.utils.auth_helpers import make_hs256_token


# ---------------------------------------------------------------------------
# Correlation ID
# ---------------------------------------------------------------------------


def test_response_carries_generated_correlation_id(client, db):
    response = client.get("/api/v1/users/me")

    assert response.status_code == 401  # no user row; dependency 401s
    header = response.headers.get("X-Correlation-ID")
    assert header, "response must carry an X-Correlation-ID header"
    # The error envelope echoes the same id.
    assert response.json()["correlation_id"] == header


def test_request_supplied_correlation_id_is_echoed(client):
    response = client.get("/health", headers={"X-Correlation-ID": "edge-proxy-id-1"})

    assert response.status_code == 200
    assert response.headers.get("X-Correlation-ID") == "edge-proxy-id-1"


def test_correlation_id_isolated_between_requests(client):
    """Each request gets its own id — no cross-request leakage (contextvars)."""
    first = client.get("/health")
    second = client.get("/health")

    assert first.headers["X-Correlation-ID"] != second.headers["X-Correlation-ID"]


def test_correlation_id_extracted_from_bearer_for_log_context(client, db, caplog):
    """The middleware decodes the token (unverified) to enrich log context."""
    from app.core.middleware import CorrelationIdLogFilter

    token = make_hs256_token(sub="user-log-context")
    # Production attaches CorrelationIdLogFilter to the root handlers in
    # setup_session_logging(); tests never run the lifespan, so attach it to
    # the caplog capture handler for the duration of this test.
    caplog.handler.addFilter(CorrelationIdLogFilter())
    with caplog.at_level(logging.INFO, logger="app.core.middleware"):
        client.get("/api/v1/definitely-not-a-route", headers={"Authorization": f"Bearer {token}"})

    # RequestLoggingMiddleware logs through the same logger module.
    records_with_user = [
        r for r in caplog.records if getattr(r, "user_id", None) == "user-log-context"
    ]
    assert records_with_user, "middleware log context must include the token's sub"


def test_bearer_token_without_sub_is_ignored(client, caplog):
    """A token that decodes (unverified) but carries no sub must not set a
    user_id in the log context."""
    from jose import jwt

    from app.core.middleware import CorrelationIdLogFilter

    token = jwt.encode({"no_sub": True}, "unused-key", algorithm="HS256")
    # /health is in the middleware SKIP_PATHS (no request-log record at all);
    # use a non-skipped path so the negative assertion actually observes logs.
    caplog.handler.addFilter(CorrelationIdLogFilter())
    with caplog.at_level(logging.INFO, logger="app.core.middleware"):
        response = client.get("/api/v1/definitely-not-a-route", headers={"Authorization": f"Bearer {token}"})

    assert response.status_code == 404
    records_with_user = [
        r for r in caplog.records if getattr(r, "user_id", None) is not None
    ]
    assert not records_with_user, "no log record may carry a user_id without a token sub"


# ---------------------------------------------------------------------------
# Request logging
# ---------------------------------------------------------------------------


def test_request_logging_logs_method_path_and_status(client, db, caplog):
    with caplog.at_level(logging.INFO, logger="app.core.middleware"):
        client.get("/api/v1/users/me")

    request_lines = [
        r.getMessage() for r in caplog.records if "-->" in r.getMessage() and "/api/v1/users/me" in r.getMessage()
    ]
    response_lines = [
        r.getMessage() for r in caplog.records if "<--" in r.getMessage() and "/api/v1/users/me" in r.getMessage()
    ]
    assert request_lines, "request start must be logged"
    assert response_lines, "response must be logged"
    assert any("401" in line for line in response_lines)


def test_request_logging_skips_health_paths(client, caplog):
    with caplog.at_level(logging.INFO, logger="app.core.middleware"):
        client.get("/health")

    assert not any("/health" in r.getMessage() for r in caplog.records if r.name == "app.core.middleware")


def test_request_logging_skips_cors_preflights(client, caplog):
    with caplog.at_level(logging.INFO, logger="app.core.middleware"):
        client.options(
            "/api/v1/auth/login",
            headers={
                "Origin": "https://www.fitcheckaiapp.com",
                "Access-Control-Request-Method": "POST",
            },
        )

    assert not any(
        "OPTIONS" in r.getMessage() and "auth/login" in r.getMessage()
        for r in caplog.records
        if r.name == "app.core.middleware"
    )


# ---------------------------------------------------------------------------
# CORS
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    "origin",
    [
        "https://www.fitcheckaiapp.com",
        "https://fitcheckaiapp.com",
        "https://admin.fitcheckaiapp.com",
    ],
)
def test_cors_allows_first_party_origins(client, origin):
    """Always-allowed first-party origins get CORS headers (RCA 2026-08-07)."""
    response = client.get(
        "/api/v1/auth/login",
        headers={"Origin": origin},
    )

    assert response.headers.get("access-control-allow-origin") == origin


def test_cors_preflight_allows_registered_origin(client):
    response = client.options(
        "/api/v1/auth/login",
        headers={
            "Origin": "https://www.fitcheckaiapp.com",
            "Access-Control-Request-Method": "POST",
            "Access-Control-Request-Headers": "authorization,content-type",
        },
    )

    assert response.status_code == 200
    assert response.headers.get("access-control-allow-origin") == "https://www.fitcheckaiapp.com"
    assert "authorization" in response.headers.get("access-control-allow-headers", "").lower()
    # Starlette expands allow_methods=["*"] into the explicit method list.
    allow_methods = response.headers.get("access-control-allow-methods", "")
    assert "POST" in allow_methods
    assert "OPTIONS" in allow_methods


def test_cors_rejects_disallowed_origin(client):
    response = client.get(
        "/api/v1/auth/login",
        headers={"Origin": "https://evil.example.com"},
    )

    assert response.headers.get("access-control-allow-origin") is None


def test_cors_exposes_correlation_id_header(client):
    """The frontend must be able to read X-Correlation-ID (CORS expose list)."""
    response = client.get(
        "/health",
        headers={"Origin": "https://www.fitcheckaiapp.com"},
    )

    assert "x-correlation-id" in response.headers.get("access-control-expose-headers", "").lower()
