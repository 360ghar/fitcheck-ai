"""End-to-end Sentry capture behavior for the running FastAPI app.

Answers the two questions the init-option unit tests cannot:

1. Does an unhandled 500 produce EXACTLY ONE Sentry event — the explicit
   capture in ``unhandled_exception_handler`` — rather than a duplicate from
   the SDK's ASGI/Starlette integration or from the adjacent ``logger.error``
   call?
2. Do /health and /ready transactions get dropped by
   ``_before_send_transaction`` while real routes still produce them?

The tests go through the REAL ``init_sentry()`` path: ``sentry_sdk.init`` is
monkeypatched only to inject an in-memory recording transport, then
``app.main`` is reloaded so its module-level ``init_sentry()`` runs with the
production options (integrations, release, transaction filter). No network
traffic is possible: the recording transport never leaves the process.

httpx's ASGITransport is in-process only (no sockets), so the repo-wide
socket-blocking guard in tests/conftest.py stays satisfied.
"""

import importlib
import logging

import pytest

import sentry_sdk
from sentry_sdk.transport import Transport

from app.core import sentry_config

# asyncio_mode = strict in pytest.ini requires the explicit marker.
pytestmark = pytest.mark.asyncio

# Standard never-contacted test DSN (same shape Sentry's own docs use).
_TEST_DSN = "https://examplePublicKey@o0.ingest.sentry.io/0"


class _RecordingTransport(Transport):
    """In-memory stand-in for Sentry's HTTP transport.

    sentry-sdk 2.x sends EVERYTHING through envelopes (error events, log
    events, transactions), so the recorder parses ``capture_envelope`` items
    back into plain event dicts. ``capture_event`` is kept for completeness;
    2.x clients no longer call it directly.
    """

    def __init__(self) -> None:
        super().__init__()
        self.events: list[dict] = []

    def capture_event(self, event, hint=None) -> None:
        self.events.append(event)

    def capture_envelope(self, envelope) -> None:
        for item in envelope.items:
            try:
                if (item.headers or {}).get("type") in ("event", "transaction"):
                    payload = getattr(item.payload, "json", None)
                    if isinstance(payload, dict):
                        self.events.append(payload)
            except Exception:  # pragma: no cover - never fail on a test probe
                continue

    # Error events are what these tests assert on. Log-entry events carry
    # "logentry" (no "exception" key), so filtering on exceptions alone would
    # hide exactly the double-report this suite exists to catch.
    def reportable_events(self) -> list[dict]:
        return [e for e in self.events if e.get("exception") or e.get("logentry")]

    def transaction_names(self) -> list[str]:
        return [
            e.get("transaction") or ""
            for e in self.events
            if e.get("type") == "transaction"
        ]


@pytest.fixture()
def sentry_app(monkeypatch):
    """Reload app.main with production Sentry config, recording transport.

    The reload re-runs app.main's module-level init_sentry() so the app is
    constructed with Sentry's integration patches active - exactly the
    production ordering (init before app construction).
    """
    transport = _RecordingTransport()
    real_init = sentry_sdk.init

    def _init_with_recorder(**kwargs):
        kwargs["transport"] = transport
        real_init(**kwargs)

    monkeypatch.setattr(sentry_sdk, "init", _init_with_recorder)
    # is_production is a @property on Settings; DEBUG=True (no Railway env in
    # tests) keeps the environment "development" without touching os.environ.
    monkeypatch.setattr(sentry_config.settings, "DEBUG", True)
    monkeypatch.setattr(sentry_config.settings, "SENTRY_DSN", _TEST_DSN)
    # Trace sampling is random against the production default (0.1); force
    # 1.0 so the keep-the-business-transaction assertion is deterministic.
    monkeypatch.setattr(sentry_config.settings, "SENTRY_TRACES_SAMPLE_RATE", 1.0)

    main = importlib.reload(importlib.import_module("app.main"))
    transport.events.clear()
    return transport, main.app


async def test_unhandled_500_reports_exactly_one_sentry_event(sentry_app):
    transport, app = sentry_app

    from httpx import ASGITransport, AsyncClient
    from starlette.routing import Route

    async def _boom(request):
        raise ValueError("boom-500-test")

    # app.main mounts the MCP ASGI app LAST at path "" (a catch-all); routes
    # appended after it are unreachable (every miss 404s inside the mount),
    # so the probe route must be inserted BEFORE the mount.
    app.router.routes.insert(-1, Route("/__test_boom", _boom, methods=["GET"]))

    async with AsyncClient(
        transport=ASGITransport(app=app, raise_app_exceptions=False),
        base_url="http://testserver",
    ) as client:
        response = await client.get("/__test_boom")

    assert response.status_code == 500
    # Exactly one event: the explicit capture with the correlation-ID tag.
    # A second event here means the logging integration or the ASGI
    # integration is double-reporting.
    events = transport.reportable_events()
    assert len(events) == 1
    event = events[0]
    assert event["tags"].get("correlation_id")
    values = event["exception"]["values"]
    assert any(v.get("value") == "boom-500-test" for v in values)


async def test_error_level_logs_do_not_become_sentry_events(sentry_app):
    """logger.error must stay a breadcrumb; CRITICAL files an event."""
    transport, _app = sentry_app

    logging.getLogger("sentry_test_probe").error("operational-noise-probe")
    assert transport.reportable_events() == []

    logging.getLogger("sentry_test_probe").critical("critical-probe")
    events = transport.reportable_events()
    assert len(events) == 1
    assert events[0]["logentry"]["message"] == "critical-probe"


async def test_health_transactions_dropped_but_root_transaction_kept(sentry_app):
    transport, app = sentry_app

    from httpx import ASGITransport, AsyncClient

    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://testserver",
    ) as client:
        health = await client.get("/health")
        root = await client.get("/")

    assert health.status_code == 200
    assert root.status_code == 200
    names = transport.transaction_names()
    assert not any("/health" in name for name in names)
    assert not any("/ready" in name for name in names)
    assert "/" in names
