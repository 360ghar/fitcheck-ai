"""
Sentry error tracking setup.

Initialized once at the top of app.main, before the module body runs, so a
crash during app construction is captured too. Entirely disabled when
SENTRY_DSN is empty: init_sentry() becomes a no-op, no SDK transport is
created, and behavior is identical to pre-Sentry. This is the same
blank-DSN convention the web app (VITE_SENTRY_DSN) and mobile app
(SENTRY_DSN via dart-define) already use.

Capture routing:
- Unhandled 500s are captured EXPLICITLY by unhandled_exception_handler in
  app/main.py: a handler registered for Exception intercepts errors before
  Sentry's ServerErrorMiddleware integration ever sees them, so the
  integration alone would stay blind to exactly the errors that matter.
  Those events carry the request correlation ID as a tag so they can be
  joined with the structured logs in backend/logs/.
- FitCheckException (business 4xx) and RequestValidationError (422) are
  deliberately NOT captured: they are expected traffic, not defects.
- Performance transactions for /health and /ready are dropped before they
  consume quota: Railway probes /health continuously and /ready is
  monitoring, not users.
"""

import logging

import sentry_sdk
from sentry_sdk.integrations.logging import LoggingIntegration

from app.core.config import settings

logger = logging.getLogger(__name__)

# Substring match on the transaction name so it holds across SDK version
# differences in naming ("/health", "GET /health") and covers the
# /api/v1/health compatibility alias. Neither string appears in a business
# route.
_QUIET_TRANSACTION_SUBSTRINGS = ("/health", "/ready")


def _before_send_transaction(event: dict, hint: dict) -> dict | None:
    """Drop health/readiness transactions so probes never consume quota."""
    name = event.get("transaction") or ""
    if any(quiet in name for quiet in _QUIET_TRANSACTION_SUBSTRINGS):
        return None
    return event


def init_sentry() -> None:
    """Initialize Sentry when SENTRY_DSN is set; a no-op otherwise.

    Never raises: telemetry must not be able to block startup (the same
    contract as the GC tuning and config-health calls in app.main).
    """
    if not settings.SENTRY_DSN:
        return

    # "unknown" is the placeholder the local .env template ships; grouping
    # every event under a fake release would pollute Sentry's releases UI,
    # so release stays unset when no real commit SHA is available.
    release = settings.RAILWAY_GIT_COMMIT_SHA
    if release == "unknown":
        release = None
    # is_production is a @property on Settings (not a method) — do not call it.
    environment = "production" if settings.is_production else "development"

    try:
        sentry_sdk.init(
            dsn=settings.SENTRY_DSN,
            release=release,
            environment=environment,
            traces_sample_rate=settings.SENTRY_TRACES_SAMPLE_RATE,
            attach_stacktrace=True,
            send_default_pii=False,
            before_send_transaction=_before_send_transaction,
            # The SDK's default logging integration turns EVERY logger.error()
            # into a Sentry event. This backend logs .error() for routine
            # operational conditions (boot-time config health, missing RPC
            # probes) and right before capture_exception in
            # unhandled_exception_handler - so the default would flood Sentry
            # with boot noise AND double-report every 500. Events come from
            # explicit capture sites instead; INFO+ still lands as breadcrumbs.
            integrations=[
                LoggingIntegration(level=logging.INFO, event_level=logging.CRITICAL),
            ],
        )
        logger.info("Sentry initialized (environment=%s, release=%s)", environment, release or "unset")
    except Exception:  # pragma: no cover - defensive; a bad DSN must not block boot
        logger.exception("Sentry initialization failed; continuing without it")
