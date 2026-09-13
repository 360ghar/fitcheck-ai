"""Unit coverage for app.core.sentry_config.

The contract under test: a blank SENTRY_DSN must be a complete no-op (the
pre-Sentry behavior promise), a configured DSN must produce exactly the
options the docs promise (release from RAILWAY_GIT_COMMIT_SHA, environment
from is_production(), no PII), and health/readiness transactions must be
dropped before they consume quota.
"""

import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

from app.core import sentry_config
from app.core.sentry_config import _before_send_transaction, init_sentry


def test_init_sentry_no_dsn_is_noop(monkeypatch):
    """No DSN -> sentry_sdk.init is never called (fully disabled)."""
    calls = []
    monkeypatch.setattr(sentry_config.sentry_sdk, "init", lambda **kw: calls.append(kw))
    monkeypatch.setattr(sentry_config.settings, "SENTRY_DSN", "")

    init_sentry()

    assert calls == []


def test_init_sentry_configures_sdk(monkeypatch):
    """A DSN turns on exactly the documented options."""
    captured = {}
    monkeypatch.setattr(sentry_config.sentry_sdk, "init", lambda **kw: captured.update(kw))
    monkeypatch.setattr(sentry_config.settings, "SENTRY_DSN", "https://key@o0.ingest.sentry.io/0")
    monkeypatch.setattr(sentry_config.settings, "RAILWAY_GIT_COMMIT_SHA", "abc1234")
    monkeypatch.setattr(sentry_config.settings, "SENTRY_TRACES_SAMPLE_RATE", 0.25)
    # DEBUG=True (no RAILWAY_ENVIRONMENT in tests) -> is_production() False.
    monkeypatch.setattr(sentry_config.settings, "DEBUG", True)

    init_sentry()

    assert captured["dsn"] == "https://key@o0.ingest.sentry.io/0"
    assert captured["release"] == "abc1234"
    assert captured["environment"] == "development"
    assert captured["traces_sample_rate"] == 0.25
    assert captured["send_default_pii"] is False
    assert captured["attach_stacktrace"] is True
    assert captured["before_send_transaction"] is _before_send_transaction
    # The logging integration must be present exactly once and CRITICAL-
    # gated: the SDK default (ERROR) would turn the logger.error() call in
    # unhandled_exception_handler into a SECOND event per 500, and would
    # flood Sentry with routine boot-time config errors.
    logging_integrations = [
        i for i in captured["integrations"] if isinstance(i, LoggingIntegration)
    ]
    assert len(logging_integrations) == 1


def test_init_sentry_production_environment(monkeypatch):
    """DEBUG=False (the deployed default) reports the production environment."""
    captured = {}
    monkeypatch.setattr(sentry_config.sentry_sdk, "init", lambda **kw: captured.update(kw))
    monkeypatch.setattr(sentry_config.settings, "SENTRY_DSN", "https://key@o0.ingest.sentry.io/0")
    monkeypatch.setattr(sentry_config.settings, "DEBUG", False)

    init_sentry()

    assert captured["environment"] == "production"


def test_init_sentry_unknown_commit_omits_release(monkeypatch):
    """The local 'unknown' placeholder must not become a fake Sentry release."""
    captured = {}
    monkeypatch.setattr(sentry_config.sentry_sdk, "init", lambda **kw: captured.update(kw))
    monkeypatch.setattr(sentry_config.settings, "SENTRY_DSN", "https://key@o0.ingest.sentry.io/0")
    monkeypatch.setattr(sentry_config.settings, "RAILWAY_GIT_COMMIT_SHA", "unknown")

    init_sentry()

    assert captured["release"] is None


def test_transaction_filter_drops_health_probes():
    """/health, its /api/v1/health alias and /ready never consume quota."""
    assert _before_send_transaction({"transaction": "/health"}, {}) is None
    assert _before_send_transaction({"transaction": "/ready"}, {}) is None
    assert _before_send_transaction({"transaction": "/api/v1/health"}, {}) is None
    assert _before_send_transaction({"transaction": "GET /health"}, {}) is None


def test_transaction_filter_keeps_business_routes():
    event = {"transaction": "/api/v1/items"}
    assert _before_send_transaction(event, {}) is event


def test_transaction_filter_tolerates_missing_transaction():
    """A shapeless event passes through instead of raising in the filter."""
    event: dict = {}
    assert _before_send_transaction(event, {}) is event


def test_capture_in_scope_is_safe_when_sentry_disabled():
    """scope.capture_exception on an uninitialized SDK must not raise —
    this is the path unhandled_exception_handler relies on with no DSN."""
    with sentry_sdk.new_scope() as scope:
        scope.set_tag("correlation_id", "test-correlation-id")
        scope.capture_exception(ValueError("boom"))
