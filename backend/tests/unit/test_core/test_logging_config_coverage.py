"""Residual branch coverage for app.core.logging_config.

The ContextLogger wrapper is used app-wide via get_context_logger, but the
formatter internals, session logging setup, and sanitizer are rarely
exercised directly. This file covers them, restoring the root logger's
handlers after each setup_session_logging call.
"""

import logging
import sys

import pytest

from app.core import logging_config
from app.core.logging_config import (
    ContextLogger,
    JsonFormatter,
    PrettyFormatter,
    get_logger,
    sanitize_for_logging,
    setup_session_logging,
)
from app.core.middleware import CorrelationIdLogFilter


@pytest.fixture(autouse=True)
def _restore_root_logger():
    root = logging.getLogger()
    saved_handlers = list(root.handlers)
    saved_level = root.level
    yield
    root.handlers[:] = saved_handlers
    root.setLevel(saved_level)


def _record(
    message: str,
    level: int = logging.INFO,
    **extra,
) -> logging.LogRecord:
    rec = logging.LogRecord(
        name="test.module",
        level=level,
        pathname=__file__,
        lineno=42,
        msg=message,
        args=(),
        exc_info=None,
    )
    for key, value in extra.items():
        setattr(rec, key, value)
    return rec


# ---------------------------------------------------------------------------
# ContextLogger
# ---------------------------------------------------------------------------


def test_context_logger_name_property():
    assert ContextLogger("my.logger").name == "my.logger"


def test_context_logger_all_levels_forward_with_extra(caplog):
    with caplog.at_level(logging.DEBUG):
        logger = ContextLogger("coverage.test")
        logger.debug("d", tag="x")
        logger.info("i", tag="x")
        logger.warning("w", tag="x")
        logger.error("e", tag="x")
        logger.exception("ex", tag="x")
        logger.critical("c", tag="x")
    assert len(caplog.records) == 6
    assert all(rec.__dict__.get("tag") == "x" for rec in caplog.records)
    levels = [rec.levelno for rec in caplog.records]
    assert levels == [
        logging.DEBUG,
        logging.INFO,
        logging.WARNING,
        logging.ERROR,
        logging.ERROR,
        logging.CRITICAL,
    ]
    # error/exception/critical default to exc_info capture.
    assert caplog.records[3].exc_info is not None
    assert caplog.records[4].exc_info is not None
    assert caplog.records[5].exc_info is not None


# ---------------------------------------------------------------------------
# JsonFormatter
# ---------------------------------------------------------------------------


def test_json_formatter_includes_user_id_and_exception():
    formatter = JsonFormatter()
    rec = _record("boom", logging.ERROR, user_id="u123", correlation_id="c456")
    rec.exc_info = (ValueError, ValueError("bad"), None)
    payload = formatter.format(rec)
    assert '"user_id": "u123"' in payload
    assert '"correlation_id": "c456"' in payload
    assert "bad" in payload  # exception text rendered
    assert '"level": "ERROR"' in payload


def test_json_formatter_omits_user_id_when_absent_and_includes_extra():
    formatter = JsonFormatter()
    rec = _record("plain", logging.INFO, some_field="v")
    payload = formatter.format(rec)
    assert '"user_id"' not in payload  # omitted when absent
    assert '"some_field": "v"' in payload
    # Info-level records do not carry a location block.
    assert '"location"' not in payload


# ---------------------------------------------------------------------------
# PrettyFormatter
# ---------------------------------------------------------------------------


def test_pretty_formatter_context_empty_and_non_empty():
    formatter = PrettyFormatter()
    assert formatter._format_context(_record("x"), 4) == ""

    context = formatter._format_context(_record("x", tag="a", error="e"), 4)
    assert "tag" in context and "error" in context
    assert "└─" in context  # tree connector present


def test_pretty_formatter_full_line_with_context():
    formatter = PrettyFormatter()
    rec = _record("hello world", logging.WARNING, correlation_id="abcdefgh", user_id="user1234")
    line = formatter.format(rec)
    assert "[abcdefgh]" in line
    assert "u:user1234" in line
    assert "hello world" in line
    assert "WARNING" in line
    assert "test.module" in line


def test_pretty_formatter_with_exception():
    formatter = PrettyFormatter()
    rec = _record("failed", logging.ERROR)
    try:
        raise RuntimeError("trace me")
    except RuntimeError:
        rec.exc_info = sys.exc_info()
    line = formatter.format(rec)
    assert "trace me" in line


# ---------------------------------------------------------------------------
# setup_session_logging
# ---------------------------------------------------------------------------


def test_setup_session_logging_dev_branch_creates_session_file(monkeypatch, tmp_path):
    monkeypatch.setattr(logging_config.settings, "LOG_DIR", str(tmp_path))
    monkeypatch.setattr(
        logging_config.settings.__class__,
        "is_production",
        property(lambda self: False),
    )
    root = logging.getLogger()
    root.handlers.clear()

    log_path = setup_session_logging()

    assert log_path.startswith(str(tmp_path))
    assert log_path.endswith(".log")
    assert any(isinstance(h, logging.FileHandler) for h in root.handlers)
    assert any(isinstance(h, logging.StreamHandler) for h in root.handlers)
    assert any(hasattr(h, "filters") and any(isinstance(f, CorrelationIdLogFilter) for f in h.filters) for h in root.handlers)


def test_setup_session_logging_production_skips_file(monkeypatch, tmp_path):
    monkeypatch.setattr(logging_config.settings, "LOG_DIR", str(tmp_path))
    monkeypatch.setattr(
        logging_config.settings.__class__,
        "is_production",
        property(lambda self: True),
    )
    root = logging.getLogger()
    root.handlers.clear()

    log_path = setup_session_logging()

    assert log_path == ""
    assert not any(isinstance(h, logging.FileHandler) for h in root.handlers)
    # Console handler uses the JSON formatter in production.
    json_handlers = [
        h for h in root.handlers if isinstance(h, logging.StreamHandler)
    ]
    assert json_handlers
    assert isinstance(json_handlers[0].formatter, JsonFormatter)


def test_setup_session_logging_respects_invalid_log_level(monkeypatch, tmp_path):
    monkeypatch.setattr(logging_config.settings, "LOG_LEVEL", "NONSENSE")
    monkeypatch.setattr(logging_config.settings, "LOG_DIR", str(tmp_path))
    monkeypatch.setattr(
        logging_config.settings.__class__,
        "is_production",
        property(lambda self: True),
    )
    root = logging.getLogger()
    root.handlers.clear()

    setup_session_logging()

    assert root.level == logging.INFO  # falls back to INFO


# ---------------------------------------------------------------------------
# get_logger / sanitize_for_logging
# ---------------------------------------------------------------------------


def test_get_logger_returns_standard_logger():
    assert get_logger("coverage.plain").name == "coverage.plain"


def test_sanitize_for_logging_truncates_long_strings_recursively():
    long_str = "x" * 500
    assert "truncated 500 chars" in sanitize_for_logging(long_str)
    assert sanitize_for_logging("short") == "short"
    assert sanitize_for_logging({"a": long_str, "b": "ok"})["b"] == "ok"
    assert "truncated" in sanitize_for_logging({"a": long_str})["a"]
    assert "truncated" in sanitize_for_logging([long_str, "fine"])[0]
    assert sanitize_for_logging([long_str, "fine"])[1] == "fine"
    assert sanitize_for_logging(42) == 42
    assert sanitize_for_logging(None) is None
