"""Auth gate for MCP HTTP endpoints.

Presence-only check at the transport layer: every HTTP request to an MCP
mount must carry ``Authorization: Bearer <token>`` or it is rejected with 401
+ ``WWW-Authenticate`` before any JSON-RPC processing (this is what lets MCP
clients discover the OAuth metadata via the OAuth gateway). The token itself
is NOT verified here — verification happens inside the loopbacked API route
via the existing ``get_current_user`` dependency, keeping one verification
code path.

Pure ASGI, framework-free, so it composes with the streamable-HTTP transport.
"""

from __future__ import annotations

import json
from contextvars import ContextVar
from typing import Any

from app.core.config import settings

# Authorization header of the HTTP request currently being handled. Stateless
# transport = one task per POST, so a plain ContextVar is request-scoped in
# practice; set by BearerPresenceMiddleware before JSON-RPC processing and
# read by tool handlers to forward credentials into the loopback call.
current_authorization: ContextVar[str | None] = ContextVar("mcp_authorization", default=None)


def get_authorization() -> str | None:
    """The caller's Authorization header (or None), for the executor."""
    return current_authorization.get()


def www_authenticate_header() -> str:
    """Value of the ``WWW-Authenticate`` header on 401 responses.

    Includes the OAuth protected-resource metadata URL once configured so MCP
    clients can discover the authorization server (the discovery parameter
    lives on the challenge, per RFC 6750/9728).
    """
    challenge = "Bearer"
    issuer = (settings.MCP_OAUTH_ISSUER or "").rstrip("/")
    if issuer:
        challenge = (
            f'{challenge}, resource_metadata="{issuer}/.well-known/oauth-protected-resource"'
        )
    return challenge


async def send_unauthorized(send: Any) -> None:
    """401 JSON-RPC-shaped response with the OAuth discovery challenge."""
    body = (
        b'{"jsonrpc":"2.0","id":null,"error":{"code":-32001,'
        b'"message":"Unauthorized: missing bearer token"}}'
    )
    await send(
        {
            "type": "http.response.start",
            "status": 401,
            "headers": [
                (b"content-type", b"application/json"),
                (b"www-authenticate", www_authenticate_header().encode("latin-1")),
                (b"content-length", str(len(body)).encode("latin-1")),
            ],
        }
    )
    await send({"type": "http.response.body", "body": body})


async def send_not_found(send: Any) -> None:
    """404 with the app's standard HTTP_ERROR envelope (error handlers in
    main.py), including the request's correlation ID."""
    from app.core.middleware import get_correlation_id

    body = json.dumps(
        {
            "error": "Not Found",
            "code": "HTTP_ERROR",
            "details": {},
            "correlation_id": get_correlation_id() or "",
        }
    ).encode("utf-8")
    await send(
        {
            "type": "http.response.start",
            "status": 404,
            "headers": [
                (b"content-type", b"application/json"),
                (b"content-length", str(len(body)).encode("latin-1")),
            ],
        }
    )
    await send({"type": "http.response.body", "body": body})


class BearerPresenceMiddleware:
    """Reject unauthenticated HTTP requests before JSON-RPC handling."""

    def __init__(self, app: Any) -> None:
        self.app = app

    async def __call__(self, scope: dict[str, Any], receive: Any, send: Any) -> None:
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        headers = {
            key.decode("latin-1").lower(): value.decode("latin-1")
            for key, value in scope.get("headers") or []
        }
        authorization = headers.get("authorization", "")
        if not authorization.lower().startswith("bearer ") or not authorization[7:].strip():
            await send_unauthorized(send)
            return

        token = current_authorization.set(authorization)
        try:
            await self.app(scope, receive, send)
        finally:
            current_authorization.reset(token)
