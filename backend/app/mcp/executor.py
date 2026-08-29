"""Loopback executor: runs MCP tool calls against the real FastAPI routes.

Tools execute as in-process ASGI requests (``httpx`` + ``ASGITransport``), not
network calls. The caller's ``Authorization`` header is forwarded, so the
route's own auth dependency is the single source of truth — the MCP layer
never re-implements token verification, and every request keeps normal
validation, rate limits, correlation IDs and error formatting.

The FastAPI app is injected via :func:`set_asgi_app` from ``main.py`` (lazy,
to avoid a circular import).
"""

from __future__ import annotations

import logging
import uuid
from typing import Any

import httpx

logger = logging.getLogger(__name__)

_asgi_app: Any = None

# AI endpoints (outfit generation, photoshoot) can legitimately take a
# while; this bounds a hung call instead of tying up the MCP session.
_LOOPBACK_TIMEOUT_SECONDS = 180.0


def set_asgi_app(app: Any) -> None:
    """Inject the FastAPI app (called once from main.py)."""
    global _asgi_app
    _asgi_app = app


def _get_asgi_app() -> Any:
    if _asgi_app is None:
        raise RuntimeError("MCP executor not initialized: set_asgi_app() was never called")
    return _asgi_app


def build_request(
    method: str,
    path_template: str,
    arguments: dict[str, Any],
) -> tuple[str, dict[str, Any], dict[str, Any] | None]:
    """Split tool arguments into path substitution, query params and body.

    Returns ``(path, params, json_body)``. Path parameters are required by the
    tool schema; leftover arguments become query parameters; ``body`` (the
    nested request-payload key used by the generator) becomes the JSON body.
    """
    args = dict(arguments or {})
    path = path_template
    for placeholder in [segment[1:-1] for segment in path_template.split("/") if segment.startswith("{") and segment.endswith("}")]:
        value = args.pop(placeholder, None)
        if value is None:
            raise ValueError(f"Missing required path parameter: {placeholder}")
        path = path.replace("{" + placeholder + "}", str(value))

    body = args.pop("body", None)
    # Drop empty optional values so agents can omit query params freely.
    params = {key: value for key, value in args.items() if value is not None}
    json_body = body if method.upper() in {"POST", "PUT", "PATCH", "DELETE"} and body is not None else None
    return path, params, json_body


async def call_endpoint(
    method: str,
    path_template: str,
    arguments: dict[str, Any],
    authorization: str | None,
) -> dict[str, Any]:
    """Execute one API call and return a JSON-safe result for the tool.

    2xx → the parsed response body is returned directly (the tool result IS
    the API data). Non-2xx → ``{"error": {"status": ..., **body}}`` without
    raising, so agents can read validation messages and self-correct.
    """
    path, params, json_body = build_request(method, path_template, arguments)

    headers: dict[str, str] = {
        # Fresh correlation ID: the inbound JSON-RPC request has its own; the
        # loopback API call gets a distinct one, tied together in logs by the
        # MCP tool name logged below.
        "X-Correlation-ID": f"mcp-{uuid.uuid4()}",
        "accept": "application/json",
    }
    if authorization:
        headers["Authorization"] = authorization

    transport = httpx.ASGITransport(app=_get_asgi_app())
    async with httpx.AsyncClient(transport=transport, base_url="http://fitcheck-mcp.loopback", timeout=_LOOPBACK_TIMEOUT_SECONDS) as client:
        response = await client.request(method.upper(), path, params=params, json=json_body, headers=headers)

    try:
        parsed = response.json()
    except ValueError:
        parsed = {"raw": response.text[:2000]}

    if response.is_success:
        return parsed if isinstance(parsed, dict) else {"result": parsed}

    logger.info(
        "MCP loopback %s %s -> %d",
        method.upper(),
        path_template,
        response.status_code,
    )
    error_body = parsed if isinstance(parsed, dict) else {"detail": parsed}
    return {"error": {"status": response.status_code, **error_body}}
