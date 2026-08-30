"""ASGI contract tests for the MCP streamable-HTTP endpoint at /mcp.

Drives the real app's low-level MCP server through a fresh streamable-HTTP
transport per test with raw JSON-RPC POSTs (stateless mode: every POST is
independent).

Note: the manager context lives INSIDE each test (not an async fixture) —
pytest-asyncio tears fixtures down in a different task than setup, and anyio
cancel scopes forbid that. Entering/exiting in the test task is required.
"""

from __future__ import annotations

import json
import re
from contextlib import asynccontextmanager

import httpx
import pytest

import app.main as main_module
from app.api.v1.deps import get_active_user_id
from app.mcp.generate import build_tool_registry
from app.mcp.http import ManagedMCPASGIApp
from tests.factories.row_factories import user_row

pytestmark = pytest.mark.api

AUTH = {"Authorization": "Bearer test-token"}
# The streamable HTTP transport rejects POSTs without both content types.
ACCEPT = {"Accept": "application/json, text/event-stream"}
HEADERS = {**AUTH, **ACCEPT}


def _rpc(method: str, params: dict | None = None, id: int | None = 1) -> dict:
    message: dict = {"jsonrpc": "2.0", "method": method}
    if params is not None:
        message["params"] = params
    if id is not None:
        message["id"] = id
    return message


@asynccontextmanager
async def mcp_client():
    """Fresh multi-mount transport + HTTPX client, mirrors main.py wiring."""
    from app.mcp.curated import build_curated_registry
    from app.mcp.server import build_mcp_server
    from app.mcp.widgets import WidgetProvider
    from app.core.config import settings

    mirror = build_tool_registry(main_module.app)
    asgi_app = ManagedMCPASGIApp(
        [
            (
                "/mcp",
                build_mcp_server(
                    "fitcheck",
                    "mirror",
                    mirror,
                    version=settings.VERSION,
                ),
            ),
            (
                "/mcp/chatgpt",
                build_mcp_server(
                    "fitcheck",
                    "chatgpt app",
                    build_curated_registry(mirror),
                    version=settings.VERSION,
                    widget_provider=WidgetProvider(),
                ),
            ),
        ]
    )
    transport = httpx.ASGITransport(app=asgi_app)
    async with asgi_app.run():
        async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as client:
            yield client


@pytest.mark.asyncio
async def test_missing_bearer_rejected_with_www_authenticate():
    async with mcp_client() as client:
        response = await client.post("/mcp", json=_rpc("initialize", {}), headers=ACCEPT)
    assert response.status_code == 401
    assert "bearer" in response.headers.get("www-authenticate", "").lower()
    assert response.json()["error"]["code"] == -32001


@pytest.mark.asyncio
async def test_initialize_returns_server_info():
    async with mcp_client() as client:
        response = await client.post(
            "/mcp",
            json=_rpc(
                "initialize",
                {
                    "protocolVersion": "2025-06-18",
                    "capabilities": {},
                    "clientInfo": {"name": "pytest", "version": "0"},
                },
            ),
            headers=HEADERS,
        )
    assert response.status_code == 200
    payload = response.json()
    assert payload["result"]["serverInfo"]["name"] == "fitcheck"


@pytest.mark.asyncio
async def test_tools_list_returns_mirror_without_denylisted_surfaces():
    async with mcp_client() as client:
        response = await client.post("/mcp", json=_rpc("tools/list", {}), headers=HEADERS)
    assert response.status_code == 200
    tools = response.json()["result"]["tools"]
    assert len(tools) > 50

    names = {tool["name"] for tool in tools}
    assert "items_list_items" in names
    assert "outfits_list_outfits" in names

    # Denylisted surfaces must not leak into the registry.
    assert not any(name.startswith("admin") for name in names)
    assert not any(name.startswith("auth") for name in names)
    assert all("inputSchema" in tool for tool in tools)
    assert all(tool["inputSchema"].get("type") == "object" for tool in tools)

    # Tool names are MCP-spec valid.
    for name in names:
        assert re.fullmatch(r"[a-zA-Z0-9_-]{1,64}", name), name


async def _resolve_tool_name(client: httpx.AsyncClient, method: str, path: str) -> str:
    """Find the mirror-tool name for an API path via tools/list descriptions."""
    response = await client.post("/mcp", json=_rpc("tools/list", {}), headers=HEADERS)
    tools = response.json()["result"]["tools"]
    for tool in tools:
        if f"[{method} {path}]" in tool["description"]:
            return tool["name"]
    raise AssertionError(f"No MCP tool mirrors {method} {path}")


@pytest.mark.asyncio
async def test_tool_call_maps_api_errors_without_raising():
    """No auth override: the loopback route 401s (fake token) and the tool
    surfaces it as a readable structured error."""
    async with mcp_client() as client:
        tool_name = await _resolve_tool_name(client, "GET", "/api/v1/users/me")
        response = await client.post(
            "/mcp",
            json=_rpc("tools/call", {"name": tool_name, "arguments": {}}),
            headers=HEADERS,
        )
    assert response.status_code == 200
    result = response.json()["result"]
    structured = result.get("structuredContent") or {}
    assert structured.get("error", {}).get("status") == 401


@pytest.mark.asyncio
async def test_tool_call_happy_path_returns_api_payload(db):  # noqa: F811
    """With the auth dependency overridden and a users row seeded, the tool
    returns the API payload as structuredContent."""
    from app.main import app

    user = user_row()
    db.rows["users"] = [user]
    app.dependency_overrides[get_active_user_id] = lambda: user["id"]
    try:
        async with mcp_client() as client:
            tool_name = await _resolve_tool_name(client, "GET", "/api/v1/users/me")
            response = await client.post(
                "/mcp",
                json=_rpc("tools/call", {"name": tool_name, "arguments": {}}),
                headers=HEADERS,
            )
    finally:
        app.dependency_overrides.pop(get_active_user_id, None)

    assert response.status_code == 200
    result = response.json()["result"]
    structured = result.get("structuredContent")
    assert isinstance(structured, dict)
    # GET /users/me wraps the profile: {"data": {...}, "message": "OK"}
    assert structured.get("data", {}).get("id") == user["id"]


@pytest.mark.asyncio
async def test_unknown_tool_returns_error():
    async with mcp_client() as client:
        response = await client.post(
            "/mcp",
            json=_rpc("tools/call", {"name": "does_not_exist", "arguments": {}}),
            headers=HEADERS,
        )
    assert response.status_code == 200
    assert "does_not_exist" in json.dumps(response.json())


@pytest.mark.asyncio
async def test_chatgpt_mount_serves_curated_tools_only():
    """The ChatGPT mount exposes the small curated set with widget metadata,
    and requests are routed to it — NOT to the full mirror."""
    async with mcp_client() as client:
        response = await client.post(
            "/mcp/chatgpt", json=_rpc("tools/list", {}), headers=HEADERS
        )
    assert response.status_code == 200
    tools = response.json()["result"]["tools"]
    names = {tool["name"] for tool in tools}
    assert 0 < len(names) <= 12
    assert "get_wardrobe" in names
    # Mirror-only tools must not leak into the curated mount.
    assert "items_list_items" not in names

    wardrobe = next(tool for tool in tools if tool["name"] == "get_wardrobe")
    meta = wardrobe["_meta"]
    assert meta["openai/outputTemplate"] == "ui://fitcheck/wardrobe-grid.html"
    assert wardrobe["title"] == "Show my wardrobe"


@pytest.mark.asyncio
async def test_chatgpt_mount_routing_is_isolated_from_mirror():
    """Same tool name must not resolve across mounts; unknown on chatgpt."""
    async with mcp_client() as client:
        response = await client.post(
            "/mcp/chatgpt",
            json=_rpc("tools/call", {"name": "items_list_items", "arguments": {}}),
            headers=HEADERS,
        )
    assert response.status_code == 200
    # Mirror tool name on the curated mount → error result, not mirror data.
    assert "Unknown tool" in json.dumps(response.json()["result"])


@pytest.mark.asyncio
async def test_non_mcp_paths_are_404ed_by_the_gate():
    """The root mount must not swallow unrelated paths."""
    from app.core.config import settings
    from app.mcp.server import build_mcp_server

    asgi_app = ManagedMCPASGIApp(
        [("/mcp", build_mcp_server("fitcheck", "mirror", [], version=settings.VERSION))]
    )
    transport = httpx.ASGITransport(app=asgi_app)
    async with asgi_app.run():
        async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as client:
            response = await client.get("/some/other/path", headers=HEADERS)
    assert response.status_code == 404
    body = response.json()
    # Same envelope as unknown API routes (error handlers in main.py).
    assert body["error"] == "Not Found"
    assert body["code"] == "HTTP_ERROR"
    assert isinstance(body["correlation_id"], str)


@pytest.mark.asyncio
async def test_transport_503s_when_lifespan_never_ran():
    """Bare ASGI use without run() must degrade to 503, not hang/raise."""
    from app.core.config import settings
    from app.mcp.server import build_mcp_server

    asgi_app = ManagedMCPASGIApp(
        [("/mcp", build_mcp_server("fitcheck", "mirror", [], version=settings.VERSION))]
    )
    transport = httpx.ASGITransport(app=asgi_app)
    async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as client:
        response = await client.post("/mcp", json=_rpc("initialize", {}), headers=HEADERS)
    assert response.status_code == 503
