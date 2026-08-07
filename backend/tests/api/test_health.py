"""Contract tests for the liveness/readiness/root endpoints through the real
app: shapes, aliases, and the /ready schema-cache paths."""

from __future__ import annotations

from unittest.mock import patch

import app.main as main_module
from app.core.config import settings


def test_health_liveness_shape(client):
    response = client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "healthy"
    assert body["service"] == settings.PROJECT_NAME
    assert body["version"] == settings.VERSION
    assert body["commit"] == settings.RAILWAY_GIT_COMMIT_SHA
    assert isinstance(body["rss_mb"], (int, float))


def test_health_api_v1_alias_serves_same_payload(client):
    """Probes pointed at the legacy /api/v1/health alias get the canonical
    liveness payload (RCA 2026-08-07)."""
    canonical = client.get("/health").json()
    alias = client.get("/api/v1/health")

    assert alias.status_code == 200
    assert alias.json() == canonical


def test_root_returns_project_metadata(client):
    response = client.get("/")

    assert response.status_code == 200
    body = response.json()
    assert body["message"] == f"Welcome to {settings.PROJECT_NAME}"
    assert body["version"] == settings.VERSION
    assert body["docs"] == "/api/v1/docs"


def test_robots_txt_disallows_crawling(client):
    """The API origin must not be indexed (RCA 2026-08-05: 404 noise)."""
    response = client.get("/robots.txt")

    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/plain")
    assert "Disallow: /" in response.text


def test_ready_healthy_when_schema_cache_says_ready(client):
    with patch.object(main_module, "_get_cached_schema_status", return_value=(True, [])):
        response = client.get("/ready")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ready"
    assert body["schema_ready"] is True


def test_ready_not_ready_when_schema_check_fails(client):
    with patch.object(main_module, "_get_cached_schema_status", return_value=(False, ["items", "outfits"])):
        response = client.get("/ready")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "not_ready"
    assert body["schema_ready"] is False
    # The missing list is only surfaced in debug mode (never a prod detail leak).
    if settings.DEBUG:
        assert body["missing_tables"] == ["items", "outfits"]
    else:
        assert "missing_tables" not in body


def test_ready_degrades_gracefully_when_probe_raises(client):
    """A probe crash must not 500 the readiness endpoint (fail closed)."""
    with patch.object(main_module, "_get_cached_schema_status", side_effect=RuntimeError("boom")):
        response = client.get("/ready")

    assert response.status_code == 200
    assert response.json()["status"] == "not_ready"
