"""
Middleware for FitCheck AI backend.

Provides request correlation IDs for distributed tracing and request/response logging.
Uses contextvars for proper async isolation between concurrent requests.
"""

import logging
import time
import uuid
from contextvars import ContextVar
from typing import Any, Callable, Dict, Optional

from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

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
    - Extracts user_id from JWT for logging context (best effort)
    """

    CORRELATION_ID_HEADER = "X-Correlation-ID"

    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Check if correlation ID was provided in request headers (from upstream)
        correlation_id = request.headers.get(self.CORRELATION_ID_HEADER)

        if not correlation_id:
            # Generate a new correlation ID
            correlation_id = str(uuid.uuid4())

        # Store in context for logging (contextvars are automatically scoped per-request)
        set_correlation_id(correlation_id)

        # Add to request state for handler access
        request.state.correlation_id = correlation_id

        # Extract user_id from JWT if present (best effort, no failure on invalid token)
        self._extract_user_context(request)

        try:
            response = await call_next(request)

            # Add correlation ID to response headers
            response.headers[self.CORRELATION_ID_HEADER] = correlation_id

            return response
        finally:
            # Clear log context at end of request
            clear_log_context()

    def _extract_user_context(self, request: Request) -> None:
        """Extract user_id from JWT and add to logging context.

        This is best-effort - invalid tokens are silently ignored.
        Actual auth validation happens in the route dependencies.
        """
        auth_header = request.headers.get("Authorization", "")
        if not auth_header.startswith("Bearer "):
            return

        try:
            from jose import jwt
            from app.core.config import settings

            token = auth_header[7:]
            # Decode without verification - just to extract user_id for logging
            # Actual verification happens in the security dependency
            payload = jwt.decode(
                token,
                options={"verify_signature": False, "verify_exp": False}
            )
            user_id = payload.get("sub")
            if user_id:
                set_log_context(user_id=user_id)
        except Exception:
            # Silently ignore any token parsing errors
            pass


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    """Middleware to log all incoming requests and their responses.
    
    Logs:
    - Request method, path, and query parameters
    - Response status code
    - Request duration
    - Correlation ID for tracing
    """
    
    # Paths to skip logging (health checks, etc.)
    SKIP_PATHS = {"/health", "/", "/api/v1/docs", "/api/v1/redoc", "/api/v1/openapi.json"}
    
    async def dispatch(self, request: Request, call_next: Callable) -> Response:
        # Skip logging for certain paths
        if request.url.path in self.SKIP_PATHS:
            return await call_next(request)
        
        # Get correlation ID (set by CorrelationIdMiddleware)
        correlation_id = getattr(request.state, "correlation_id", "unknown")
        
        # Capture request info
        method = request.method
        path = request.url.path
        query = str(request.query_params) if request.query_params else ""
        client_ip = request.client.host if request.client else "unknown"
        
        # Log request start
        logger.info(
            f"[{correlation_id}] --> {method} {path}"
            + (f"?{query}" if query else "")
            + f" (client: {client_ip})"
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
