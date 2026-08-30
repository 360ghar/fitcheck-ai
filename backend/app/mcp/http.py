"""Streamable-HTTP transport for the MCP servers.

Each mount gets its own ``StreamableHTTPSessionManager`` running in
**stateless JSON mode**: no session affinity, no server-side session state, so
requests hit any worker (Railway scale-out safe) and every JSON-RPC message is
a self-contained POST with bearer credentials in the header.

Dispatch inside :class:`ManagedMCPASGIApp` (outermost first, all pure ASGI):

    FastAPI middleware (CORS, logging, correlation)
      → mount-path match         (404 envelope for anything outside every mount)
        → BearerPresenceMiddleware (401 without Authorization; captures header)
          → StreamableHTTPASGIApp  (MCP streamable HTTP transport)
            → lowlevel Server      (tools/list, tools/call, resources)

The underlying ``StreamableHTTPSessionManager`` is one-shot (its task group
cannot re-run). :class:`ManagedMCPASGIApp` therefore creates a FRESH manager
on every lifespan cycle: production boots once, but repeated
``with TestClient(app):`` lifespans in the test suite each get a working
transport without "run() can only be called once" errors.
"""

from __future__ import annotations

import logging
from contextlib import asynccontextmanager
from typing import Any, AsyncIterator

from mcp.server.fastmcp.server import StreamableHTTPASGIApp
from mcp.server.streamable_http_manager import StreamableHTTPSessionManager

from app.mcp.auth import BearerPresenceMiddleware, send_not_found

logger = logging.getLogger(__name__)


class ManagedMCPASGIApp:
    """Multi-mount MCP transport; session managers are (re)created per run.

    Mounts are given as ``(mount_path, server)`` pairs (longest prefix wins:
    ``/mcp/chatgpt`` is matched before ``/mcp``). Starlette ``Mount`` cannot
    be used here — ``Mount("/mcp")`` 307-redirects the exact ``/mcp`` URL MCP
    clients POST to, and a second root-level mount would never be reached.
    Requests for paths outside every mount get the app's standard 404
    envelope, so unmatched API routes still 404 normally.
    """

    def __init__(self, mounts: list[tuple[str, Any]]) -> None:
        self._mounts = sorted(mounts, key=lambda pair: -len(pair[0]))
        self._chains: dict[str, Any] = {}

    @asynccontextmanager
    async def run(self) -> AsyncIterator[None]:
        from contextlib import AsyncExitStack

        async with AsyncExitStack() as stack:
            for mount_path, server in self._mounts:
                manager = StreamableHTTPSessionManager(
                    app=server,
                    event_store=None,  # stateless: no SSE resumability
                    json_response=True,  # plain JSON responses; proxy-friendly
                    stateless=True,
                )
                await stack.enter_async_context(manager.run())
                self._chains[mount_path] = BearerPresenceMiddleware(
                    StreamableHTTPASGIApp(manager)
                )
            logger.info("MCP session managers started: %s", [path for path, _ in self._mounts])
            try:
                yield
            finally:
                self._chains.clear()
                logger.info("MCP session managers stopped")

    def _matching_mount(self, path: str) -> str | None:
        for mount_path, _ in self._mounts:
            if path == mount_path or path.startswith(mount_path + "/"):
                return mount_path
        return None

    async def _dispatch(self, scope: dict[str, Any], receive: Any, send: Any) -> None:
        mount_path = self._matching_mount(scope.get("path", ""))
        chain = self._chains.get(mount_path) if mount_path else None
        if mount_path is None:
            # Fell through every registered mount: normal 404 envelope.
            await send_not_found(send)
            return
        if chain is None:
            # /mcp* request but the lifespan never ran (bare ASGI use).
            body = b'{"error":"MCP transport not started"}'
            await send(
                {
                    "type": "http.response.start",
                    "status": 503,
                    "headers": [
                        (b"content-type", b"application/json"),
                        (b"content-length", str(len(body)).encode("latin-1")),
                    ],
                }
            )
            await send({"type": "http.response.body", "body": body})
            return
        await chain(scope, receive, send)

    async def __call__(self, scope: dict[str, Any], receive: Any, send: Any) -> None:
        await self._dispatch(scope, receive, send)
