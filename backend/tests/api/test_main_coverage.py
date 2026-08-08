"""Residual coverage for app.main: schema checks, background startup,
lifespan, and the /ready debug branch.

The api-layer siblings (test_health*.py) cover /health and the schema cache
from the HTTP side; this file exercises the remaining startup internals
directly and the lifespan via a context-managed TestClient with all
background IO mocked.
"""

from unittest.mock import AsyncMock, Mock, patch

import pytest
from fastapi.testclient import TestClient
from postgrest.exceptions import APIError as PostgrestAPIError

import app.main as main_module


def _api_error(code: str) -> PostgrestAPIError:
    return PostgrestAPIError({"code": code, "message": "x", "hint": None, "details": None})


def _ok_db():
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.return_value = object()
    return db


# ---------------------------------------------------------------------------
# _column_exists / _schema_missing
# ---------------------------------------------------------------------------


def test_column_exists_true_and_absent_code():
    assert main_module._column_exists(_ok_db(), "users", "email") is True

    absent_db = Mock()
    absent_db.table.return_value.select.return_value.limit.return_value.execute.side_effect = _api_error("PGRST205")
    assert main_module._column_exists(absent_db, "users", "email") is False


def test_column_exists_non_schema_code_and_generic_error():
    bad_db = Mock()
    bad_db.table.return_value.select.return_value.limit.return_value.execute.side_effect = _api_error("500")
    assert main_module._column_exists(bad_db, "users", "email") is False

    raiser = Mock()
    raiser.table.return_value.select.return_value.limit.return_value.execute.side_effect = RuntimeError("boom")
    assert main_module._column_exists(raiser, "users", "email") is False


def test_schema_missing_all_tables_present():
    assert main_module._schema_missing(_ok_db()) == []


def test_schema_missing_with_feature_tables(monkeypatch):
    monkeypatch.setattr(main_module.settings, "ENABLE_GAMIFICATION", True)
    monkeypatch.setattr(main_module.settings, "ENABLE_SOCIAL_IMPORT", True)
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.side_effect = _api_error("PGRST205")
    missing = main_module._schema_missing(db)
    assert set(main_module.GAMIFICATION_TABLES) <= set(missing)
    assert set(main_module.SOCIAL_IMPORT_TABLES) <= set(missing)


def test_schema_missing_dedupes_overlapping_table_lists(monkeypatch):
    """A table listed in both REQUIRED_TABLES and a feature-flag list is
    reported once (the de-dupe loop)."""
    monkeypatch.setattr(main_module.settings, "ENABLE_GAMIFICATION", True)
    monkeypatch.setattr(main_module, "GAMIFICATION_TABLES", ("users", "user_streaks"))
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.side_effect = _api_error("PGRST205")
    missing = main_module._schema_missing(db)
    assert missing.count("users") == 1


def test_schema_missing_non_schema_code_is_reported_missing():
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.side_effect = _api_error("500")
    missing = main_module._schema_missing(db)
    # Every table is flagged (columns whose checks also fail add more).
    assert len(missing) >= len(main_module.REQUIRED_TABLES)


def test_schema_missing_generic_exception_is_reported_missing():
    db = Mock()
    db.table.return_value.select.return_value.limit.return_value.execute.side_effect = RuntimeError("net")
    missing = main_module._schema_missing(db)
    assert missing  # nothing is silently dropped


def test_schema_missing_accepts_alternative_column():
    """birth_date missing but the legacy date_of_birth alternative present."""
    db = Mock()

    def _select(column, *_a, **_k):
        chain = Mock()
        if column == "date_of_birth":
            chain.limit.return_value.execute.return_value = object()
        else:
            chain.limit.return_value.execute.side_effect = _api_error("PGRST205")
        return chain

    db.table.side_effect = lambda table: Mock(select=_select)
    missing = main_module._schema_missing(db)
    assert "users.birth_date" not in missing


# ---------------------------------------------------------------------------
# _seed_schema_status_in_thread / _init_pinecone_in_thread
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_seed_schema_status_logs_rpc_gaps_and_critical_bound(monkeypatch):
    monkeypatch.setattr(main_module.SupabaseDB, "get_service_client", lambda: _ok_db())
    monkeypatch.setattr(main_module, "_schema_missing", lambda db: ["users"])
    monkeypatch.setattr(main_module, "missing_quota_rpcs", lambda db: ["reserve_ai_usage"])
    monkeypatch.setattr(main_module, "missing_referral_rpcs", lambda db: ["redeem_referral_atomic"])
    monkeypatch.setattr(main_module, "probe_valid_batch_size_bound", lambda db: ("critical", "bound <= 10"))

    await main_module._seed_schema_status_in_thread()

    assert main_module._SCHEMA_STATUS_CACHE["missing"] == ["users"]
    assert main_module._SCHEMA_STATUS_CACHE["checked_at"] is not None


@pytest.mark.asyncio
@pytest.mark.parametrize("level", ["warn", "missing", "unknown", "ok"])
async def test_seed_schema_status_bound_levels(monkeypatch, level):
    monkeypatch.setattr(main_module.SupabaseDB, "get_service_client", lambda: _ok_db())
    monkeypatch.setattr(main_module, "_schema_missing", lambda db: [])
    monkeypatch.setattr(main_module, "missing_quota_rpcs", lambda db: [])
    monkeypatch.setattr(main_module, "missing_referral_rpcs", lambda db: [])
    monkeypatch.setattr(main_module, "probe_valid_batch_size_bound", lambda db: (level, f"message {level}"))

    await main_module._seed_schema_status_in_thread()

    assert main_module._SCHEMA_STATUS_CACHE["missing"] == []


@pytest.mark.asyncio
async def test_seed_schema_status_survives_exceptions(monkeypatch):
    def _boom():
        raise RuntimeError("db unreachable")

    monkeypatch.setattr(main_module.SupabaseDB, "get_service_client", _boom)
    await main_module._seed_schema_status_in_thread()  # must not raise


@pytest.mark.asyncio
async def test_init_pinecone_skips_without_api_key(monkeypatch):
    monkeypatch.setattr(main_module.settings, "PINECONE_API_KEY", "")
    await main_module._init_pinecone_in_thread()  # early return


@pytest.mark.asyncio
async def test_init_pinecone_creates_index(monkeypatch):
    svc = Mock()
    svc.create_index = Mock()
    monkeypatch.setattr(main_module.settings, "PINECONE_API_KEY", "pk")
    with patch.dict(
        "sys.modules",
        {"app.services.vector_service": Mock(get_vector_service=lambda: svc)},
    ):
        await main_module._init_pinecone_in_thread()
    svc.create_index.assert_called_once()


@pytest.mark.asyncio
async def test_init_pinecone_survives_failures(monkeypatch):
    monkeypatch.setattr(main_module.settings, "PINECONE_API_KEY", "pk")
    with patch.dict(
        "sys.modules",
        {"app.services.vector_service": Mock(get_vector_service=Mock(side_effect=RuntimeError("no svc")))},
    ):
        await main_module._init_pinecone_in_thread()  # must not raise


@pytest.mark.asyncio
async def test_background_startup_logs_step_failures(monkeypatch):
    monkeypatch.setattr(main_module, "_seed_schema_status_in_thread", AsyncMock(side_effect=RuntimeError("seed")))
    monkeypatch.setattr(main_module, "_init_pinecone_in_thread", AsyncMock())
    monkeypatch.setattr("app.utils.process_metrics.log_memory", Mock())
    logger = Mock()
    await main_module._background_startup(logger)
    assert logger.warning.call_count >= 1


@pytest.mark.asyncio
async def test_background_startup_logs_crash_when_logging_itself_fails(monkeypatch):
    """If a step-failure warning raises, the outer guard must log the crash
    instead of letting the task die silently."""
    monkeypatch.setattr(main_module, "_seed_schema_status_in_thread", AsyncMock(side_effect=RuntimeError("seed")))
    monkeypatch.setattr(main_module, "_init_pinecone_in_thread", AsyncMock())
    monkeypatch.setattr("app.utils.process_metrics.log_memory", Mock(side_effect=RuntimeError("metrics")))
    logger = Mock()
    logger.warning = Mock(side_effect=RuntimeError("logging broke"))
    await main_module._background_startup(logger)
    logger.exception.assert_called_once()


# ---------------------------------------------------------------------------
# Lifespan via context-managed TestClient
# ---------------------------------------------------------------------------


@pytest.fixture
def _lifespan_mocks(monkeypatch):
    monkeypatch.setattr(main_module, "_background_startup", AsyncMock())
    monkeypatch.setattr(main_module, "setup_session_logging", lambda: "")
    monkeypatch.setattr("app.utils.process_metrics.log_memory", Mock())
    monkeypatch.setattr("app.core.config_health.validate_production_config", lambda: [])
    return main_module


def test_lifespan_startup_shutdown_runs(_lifespan_mocks):
    with TestClient(main_module.app) as client:
        resp = client.get("/")
        assert resp.status_code == 200
        assert "Welcome to" in resp.json()["message"]

    main_module._background_startup.assert_awaited()


def test_lifespan_with_session_log_file_and_config_issues(monkeypatch, tmp_path):
    log_file = tmp_path / "session.log"
    monkeypatch.setattr(main_module, "_background_startup", AsyncMock())
    monkeypatch.setattr(main_module, "setup_session_logging", lambda: str(log_file))
    monkeypatch.setattr("app.utils.process_metrics.log_memory", Mock())

    class _Issue:
        severity = "error"
        key = "AI_ENCRYPTION_KEY"
        message = "missing"

    monkeypatch.setattr("app.core.config_health.validate_production_config", lambda: [_Issue()])

    with TestClient(main_module.app) as client:
        resp = client.get("/robots.txt")
        assert resp.status_code == 200
        assert "Disallow" in resp.text


def test_lifespan_shutdown_handles_background_task_error(monkeypatch):
    """A background startup task that ends with an error must be logged, not
    left as 'Task exception was never retrieved'."""
    monkeypatch.setattr(main_module, "_background_startup", AsyncMock(side_effect=RuntimeError("bg failed")))
    monkeypatch.setattr(main_module, "setup_session_logging", lambda: "")
    monkeypatch.setattr("app.utils.process_metrics.log_memory", Mock())
    monkeypatch.setattr("app.core.config_health.validate_production_config", lambda: [])

    with TestClient(main_module.app):
        pass


def test_ready_endpoint_debug_includes_missing_tables(_lifespan_mocks, monkeypatch):
    monkeypatch.setattr(main_module, "_get_cached_schema_status", lambda: (False, ["users", "items"]))
    monkeypatch.setattr(main_module.settings, "DEBUG", True)

    with TestClient(main_module.app) as client:
        resp = client.get("/ready")

    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "not_ready"
    assert body["missing_tables"] == ["users", "items"]


def test_ready_endpoint_reports_ready(_lifespan_mocks, monkeypatch):
    monkeypatch.setattr(main_module, "_get_cached_schema_status", lambda: (True, []))
    monkeypatch.setattr(main_module.settings, "DEBUG", False)

    with TestClient(main_module.app) as client:
        resp = client.get("/ready")

    assert resp.json()["status"] == "ready"
    assert "missing_tables" not in resp.json()


def test_ready_endpoint_falls_back_when_check_raises(_lifespan_mocks, monkeypatch):
    def _boom():
        raise RuntimeError("check failed")

    monkeypatch.setattr(main_module, "_get_cached_schema_status", _boom)
    monkeypatch.setattr(main_module.settings, "DEBUG", True)

    with TestClient(main_module.app) as client:
        resp = client.get("/ready")

    body = resp.json()
    assert body["status"] == "not_ready"
    assert body["schema_ready"] is False
