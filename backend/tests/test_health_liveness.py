"""
/health is a pure liveness probe: no DB, no schema scan.

Railway (and any platform probe) polls this path; it must stay cheap so
event-loop stalls or Supabase blips cannot flip the process unhealthy.
"""
from unittest.mock import patch

from fastapi.testclient import TestClient

import app.main as main_module


def test_health_does_not_touch_schema_status():
    with patch.object(main_module, "_get_cached_schema_status") as mock_schema:
        client = TestClient(main_module.app)
        response = client.get("/health")

    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "healthy"
    assert "schema_ready" not in body
    assert "commit" in body
    mock_schema.assert_not_called()


def test_ready_uses_schema_cache():
    main_module._SCHEMA_STATUS_CACHE["missing"] = []
    main_module._SCHEMA_STATUS_CACHE["checked_at"] = main_module.datetime.utcnow()

    client = TestClient(main_module.app)
    response = client.get("/ready")

    assert response.status_code == 200
    body = response.json()
    assert body["schema_ready"] is True
    assert body["status"] == "ready"
