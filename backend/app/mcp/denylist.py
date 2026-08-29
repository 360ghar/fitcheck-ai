"""Exclusion rules for MCP tool generation.

An OpenAPI operation is excluded from the tool registry when:
- its path matches any prefix/pattern here, or
- its request body is multipart (binary uploads), or
- its success/error responses are event streams or raw binary.

These surfaces are either not agent-appropriate (admin console, auth session
management, webhooks) or not JSON-tool compatible (SSE, image bytes).
"""

from __future__ import annotations

import re
from typing import Final

# Path prefixes that must never become MCP tools.
_EXCLUDED_PREFIXES: Final[tuple[str, ...]] = (
    # Admin console surface: server-enforced RBAC, internal only.
    "/api/v1/admin",
    # Auth session management (login/signup/password/OAuth link flows).
    # Agents authenticate via the Authorization header, never via these.
    "/api/v1/auth",
    # Public marketing surfaces (IP-rate-limited, no user scope).
    "/api/v1/demo",
    "/api/v1/waitlist",
    # Image serving returns redirects / raw bytes, not JSON data.
    "/api/v1/images",
    # Liveness/readiness probes.
    "/health",
    "/ready",
)

# Substring patterns for webhook receivers (Stripe / Apple / Google) and any
# future callback-style endpoint. Never agent-callable.
_EXCLUDED_PATTERNS: Final[tuple[re.Pattern[str], ...]] = (
    re.compile(r"webhook", re.IGNORECASE),
)

# SSE endpoints (long-lived streaming responses; a tool call would hang until
# the stream closes). These are exact-suffix matches, NOT substrings:
# `/events` must not exclude the calendar's JSON list endpoints
# (`GET/POST /api/v1/calendar/events`), so calendar paths are exempt.
_SSE_PATH_SUFFIXES: Final[tuple[str, ...]] = ("/events",)
_SSE_PATH_EXEMPT_PREFIXES: Final[tuple[str, ...]] = (
    "/api/v1/calendar",
)

# Batch extraction is a multipart-upload + SSE flow; no single-call tool can
# drive it. Individual item extraction stays exposed via the items/ai routes.
_EXCLUDED_PREFIXES_EXTRA: Final[tuple[str, ...]] = (
    "/api/v1/ai/batch-extract",
)

# Response content types that are not JSON-tool compatible.
_NON_JSON_CONTENT_TYPES: Final[tuple[str, ...]] = (
    "text/event-stream",
    "application/octet-stream",
    "image/",
    "text/html",
    "text/plain",
)

# Request body content types that are not JSON-tool compatible.
_NON_JSON_BODY_TYPES: Final[tuple[str, ...]] = (
    "multipart/form-data",
    "application/octet-stream",
    "image/",
)


def is_excluded_path(path: str) -> bool:
    """Return whether an OpenAPI path must not become an MCP tool."""
    prefixes = _EXCLUDED_PREFIXES + _EXCLUDED_PREFIXES_EXTRA
    if any(path.startswith(prefix) for prefix in prefixes):
        return True
    if any(pattern.search(path) for pattern in _EXCLUDED_PATTERNS):
        return True
    if path.endswith(_SSE_PATH_SUFFIXES):
        if not any(path.startswith(exempt) for exempt in _SSE_PATH_EXEMPT_PREFIXES):
            return True
    return False


def has_non_json_body(operation: dict) -> bool:
    """Return whether the operation's request body is multipart/binary."""
    body = operation.get("requestBody") or {}
    content = body.get("content") or {}
    return any(
        content_type.startswith(prefix) for content_type in content for prefix in _NON_JSON_BODY_TYPES
    )


def has_non_json_response(operation: dict) -> bool:
    """Return whether any documented response is a stream/binary/HTML body."""
    for response in (operation.get("responses") or {}).values():
        content = response.get("content") or {}
        if any(content_type.startswith(prefix) for content_type in content for prefix in _NON_JSON_CONTENT_TYPES):
            return True
    return False
