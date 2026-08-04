"""
CORS preflights are browser transport noise, not application API calls.

The web client talks to the API through same-origin proxies (Vite / Netlify)
so in practice no preflights reach the backend; but mobile and standalone
clients still send OPTIONS. Logging every preflight made each web API call
look duplicated in backend logs. The RequestLoggingMiddleware must:
  - still ANSWER preflights successfully (CORS behavior unchanged);
  - NOT emit request/response log lines for OPTIONS.
"""
import logging

from fastapi.testclient import TestClient

from app.core.middleware import RequestLoggingMiddleware

import app.main as main_module


def test_options_preflight_is_answered_but_not_logged(caplog):
    client = TestClient(main_module.app)

    with caplog.at_level(logging.INFO):
        # Origin is a configured CORS origin so the preflight is answered
        # with allow-origin (localhost:3000 is in BACKEND_CORS_ORIGINS).
        response = client.options(
            "/api/v1/items",
            headers={
                "Origin": "http://localhost:3000",
                "Access-Control-Request-Method": "GET",
                "Access-Control-Request-Headers": "authorization",
            },
        )

    # The preflight is answered (CORS middleware still runs).
    assert response.status_code == 200
    assert response.headers.get("access-control-allow-origin") is not None

    # No request/response log lines for the OPTIONS method from the app's
    # RequestLoggingMiddleware (httpx's own client log is unrelated).
    log_lines = [r.getMessage() for r in caplog.records]
    assert not any(
        "OPTIONS" in line and r.name.startswith("app.") for r, line in zip(caplog.records, log_lines)
    )


def test_get_request_is_still_logged(caplog):
    client = TestClient(main_module.app)

    with caplog.at_level(logging.INFO):
        # An unauthenticated GET 401s but still passes through logging.
        response = client.get("/api/v1/items")

    assert response.status_code == 401
    log_lines = [r.getMessage() for r in caplog.records]
    assert any("GET /api/v1/items" in line for line in log_lines)


def test_skip_paths_still_skip():
    """Sanity: the middleware's skip set still contains the health paths."""
    assert "/health" in RequestLoggingMiddleware.SKIP_PATHS
    assert "/ready" in RequestLoggingMiddleware.SKIP_PATHS
