"""
Regression test for schema-status caching used by GET /ready.

Previously _schema_missing() (~30-40 sequential blocking DB queries) ran on
every single /health hit. /health is now pure liveness; the cache still
matters for /ready and startup seeding.
"""
from unittest.mock import Mock, patch

import app.main as main_module


def test_cached_schema_status_reuses_result_within_ttl():
    main_module._SCHEMA_STATUS_CACHE["missing"] = None
    main_module._SCHEMA_STATUS_CACHE["checked_at"] = None

    fake_db = Mock()
    with patch.object(main_module.SupabaseDB, "get_service_client", return_value=fake_db), \
         patch.object(main_module, "_schema_missing", return_value=[]) as mock_missing:
        ready1, missing1 = main_module._get_cached_schema_status()
        ready2, missing2 = main_module._get_cached_schema_status()

    assert ready1 is True and ready2 is True
    assert missing1 == [] and missing2 == []
    # Second call within the TTL window must not re-run the expensive check.
    mock_missing.assert_called_once()


def test_first_ever_check_failing_reports_not_ready():
    """Regression test: with no prior successful check to fall back on, a
    failure must report schema_ready=False (fail closed), not silently
    report healthy - this was a real bug introduced while adding the cache
    (the fallback `cached["missing"] or []` treated "never checked" the
    same as "checked and found nothing missing")."""
    main_module._SCHEMA_STATUS_CACHE["missing"] = None
    main_module._SCHEMA_STATUS_CACHE["checked_at"] = None

    with patch.object(main_module.SupabaseDB, "get_service_client", side_effect=RuntimeError("db down")):
        ready, missing = main_module._get_cached_schema_status()

    assert ready is False
    assert missing == ["schema_check_failed"]


def test_transient_failure_after_a_good_check_keeps_serving_last_known_result():
    """A DB hiccup on a later check (after at least one success) should keep
    serving the last known-good result, not flip to not-ready."""
    main_module._SCHEMA_STATUS_CACHE["missing"] = []
    main_module._SCHEMA_STATUS_CACHE["checked_at"] = None  # force a re-check

    with patch.object(main_module.SupabaseDB, "get_service_client", side_effect=RuntimeError("transient")):
        ready, missing = main_module._get_cached_schema_status()

    assert ready is True
    assert missing == []
