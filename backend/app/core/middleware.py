"""
Middleware for FitCheck AI backend.

Provides request correlation IDs for distributed tracing and request/response logging.
Uses contextvars for proper async isolation between concurrent requests.
"""

import logging
import re
import time
import uuid
from contextvars import ContextVar
from typing import Any, Callable, Dict, Optional

from fastapi import Request, Response
from fastapi.security import HTTPAuthorizationCredentials
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.security import verify_token

logger = logging.getLogger(__name__)

# Context variables for async-safe request context
_correlation_id: ContextVar[Optional[str]] = ContextVar("correlation_id", default=None)
_log_context: ContextVar[Dict[str, Any]] = ContextVar("log_context", default={})


def get_correlation_id() -> str:
    """Get the correlation ID for the current request.

    Returns a placeholder if called outside of a request context.
    """
    return _correlation_id.get() or "no-request-context"


def set_correlation_id(correlation_id: str) -> None:
    """Set the correlation ID for the current request context."""
    _correlation_id.set(correlation_id)


def get_log_context() -> Dict[str, Any]:
    """Get the current logging context dictionary."""
    return _log_context.get().copy()


def set_log_context(**kwargs: Any) -> None:
    """Add key-value pairs to the logging context for the current request.

    Example:
        set_log_context(user_id="123", action="create_item")
    """
    current = _log_context.get().copy()
    current.update(kwargs)
    _log_context.set(current)


def clear_log_context() -> None:
    """Clear the logging context (called at end of request)."""
    _log_context.set({})


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    """Middleware to add correlation IDs to all requests.

    - Generates a UUID for each request
    - Adds it to the response headers as X-Correlation-ID
    - Makes it available to the logging context via contextvars
    - Extracts user_id from a VERIFIED JWT for logging context (best effort)
    """

    CORRELATION_ID_HEADER = "X-Correlation-ID"
    # Client-supplied correlation IDs are echoed for trace propagation but are
    # log input, so they are validated before use: bounded length and a safe
    # charset keep them from being a log-injection vector.
    _CORRELATION_ID_RE = re.compile(r"^[A-Za-z0-9._-]{1,64}$")

    @staticmethod
    def _validate_correlation_id(value: str) -> str:
        """Return ``value`` when it is a safe correlation id, else a UUID."""
        if value and CorrelationIdMiddleware._CORRELATION_ID_RE.match(value):
            return value
        return str(uuid.uuid4())

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Check if correlation ID was provided in request headers (from upstream)
        correlation_id = request.headers.get(self.CORRELATION_ID_HEADER)

        # Validate before echoing: an arbitrary client-supplied value is log
        # input (length/char-set capped to [A-Za-z0-9._-], <= 64 chars) and
        # falls back to a generated UUID otherwise.
        correlation_id = self._validate_correlation_id(correlation_id or "")

        # Store in context for logging (contextvars are automatically scoped per-request)
        set_correlation_id(correlation_id)

        # Add to request state for handler access
        request.state.correlation_id = correlation_id

        # Extract user_id from JWT if present (best effort, no failure on invalid token)
        await self._extract_user_context(request)

        try:
            response = await call_next(request)

            # Add correlation ID to response headers
            response.headers[self.CORRELATION_ID_HEADER] = correlation_id

            return response
        finally:
            # Clear log context at end of request
            clear_log_context()

    async def _extract_user_context(self, request: Request) -> None:
        """Extract user_id from a VERIFIED JWT and add to logging context.

        The user identity is only trusted when the token verifies
        (signature + exp/iss/aud) — see ``app.core.security.verify_token``.
        The old unverified decode let any client forge a ``sub`` claim and
        have it logged as their user_id. When verification fails the log
        context records a fixed ``anonymous`` value instead of an
        unverified (or absent) claim. Actual auth validation happens in the
        route dependencies.
        """
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return

        try:
            credentials = HTTPAuthorizationCredentials(
                scheme="Bearer",
                credentials=auth_header[7:],
            )
            token_data = await verify_token(credentials)
            if token_data and token_data.sub:
                set_log_context(user_id=token_data.sub)
                return
        except Exception:
            # Invalid/expired/malformed token: never trust any claim from it.
            pass

        set_log_context(user_id="anonymous")


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log all incoming requests and their responses.
    
    Logs:
    - Request method and path (deliberately NOT the query string: search
      terms, storage_path keys and other values land there and must not be
      captured into logs)
    - Response status code
    - Request duration
    - Correlation ID for tracing
    """
    
    # Paths to skip logging (health checks, etc.)
    SKIP_PATHS = {
        "/health",
        "/ready",
        "/",
        "/api/v1/health",
        "/api/v1/docs",
        "/api/v1/redoc",
        "/api/v1/openapi.json",
    }

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # CORS preflights are browser transport noise, not application calls.
        # They are answered identically by Starlette's CORSMiddleware (which
        # sits OUTSIDE this middleware in the stack) and logging them as
        # request/response entries made every web API call look duplicated in
        # logs. Correlation ID and CORS behavior are unchanged.
        if request.method == "OPTIONS":
            return await call_next(request)

        # Skip logging for certain paths
        if request.url.path in self.SKIP_PATHS:
            return await call_next(request)

        # Get correlation ID (set by CorrelationIdMiddleware)
        correlation_id = getattr(request.state, "correlation_id", "unknown")
        
        # Capture request info. The query string is intentionally NOT logged:
        # it can carry search terms, storage_path keys and (for misconfigured
        # clients) tokens, and has no place in request logs.
        method = request.method
        path = request.url.path
        client_ip = request.client.host if request.client else "unknown"
        
        # Log request start
        logger.info(
            f"[{correlation_id}] --> {method} {path} (client: {client_ip})"
        )
        
        # Time the request
        start_time = time.perf_counter()
        
        try:
            response = await call_next(request)
            
            # Calculate duration
            duration_ms = (time.perf_counter() - start_time) * 1000
            
            # Log response
            status_code = response.status_code
            log_level = logging.INFO if status_code < 400 else logging.WARNING if status_code < 500 else logging.ERROR
            
            logger.log(
                log_level,
                f"[{correlation_id}] <-- {method} {path} | {status_code} | {duration_ms:.2f}ms"
            )
            
            return response
            
        except Exception as e:
            # Log exception
            duration_ms = (time.perf_counter() - start_time) * 1000
            logger.error(
                f"[{correlation_id}] <-- {method} {path} | EXCEPTION | {duration_ms:.2f}ms | {type(e).__name__}: {str(e)}"
            )
            raise


class CorrelationIdLogFilter(logging.Filter):
    """Log filter that adds correlation ID and log context to all log records.

    This allows the correlation ID and other context (user_id, etc.)
    to be included in log format strings and JSON output.
    """

    def filter(self, record: logging.LogRecord) -> bool:
        record.correlation_id = get_correlation_id()

        # Add all log context items to the record
        context = get_log_context()
        for key, value in context.items():
            if not hasattr(record, key):
                setattr(record, key, value)

        return True
