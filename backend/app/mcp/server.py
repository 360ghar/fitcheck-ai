"""Build low-level MCP servers over a tool registry.

Uses ``mcp.server.lowlevel.Server`` (not FastMCP) because tools are generated
dynamically from the OpenAPI schema — there is no Python function per tool to
decorate. The same builder produces both mounts:

- ``/mcp``        — full API mirror registry (generate.py).
- ``/mcp/chatgpt`` — curated ChatGPT-app registry (curated.py, Phase C) with
  ``ui://`` widget resources.
"""

from __future__ import annotations

import json
import logging
from typing import Any

from mcp.server.lowlevel import Server
from mcp import types

from app.mcp.auth import get_authorization
from app.mcp.executor import call_endpoint
from app.mcp.generate import MCPTool

logger = logging.getLogger(__name__)

_JSONRPC_INVALID_PARAMS = -32602
_JSONRPC_INTERNAL_ERROR = -32603


def _tool_to_types(tool: MCPTool) -> types.Tool:
    kwargs: dict[str, Any] = {
        "name": tool.name,
        "description": tool.description,
        "inputSchema": tool.input_schema,
    }
    if tool.title:
        kwargs["title"] = tool.title
    if tool.meta:
        # Wire field is `_meta` (alias); construct via the alias key.
        kwargs["_meta"] = tool.meta
    return types.Tool(**kwargs)


def build_mcp_server(
    server_name: str,
    instructions: str,
    registry: list[MCPTool],
    version: str = "1.0.0",
    widget_provider: Any | None = None,
) -> Server:
    """Create an MCP server exposing exactly the tools in ``registry``.

    ``widget_provider`` (``app.mcp.widgets.WidgetProvider``) additionally
    exposes built ChatGPT widget bundles as ``ui://`` resources.
    """
    server = Server(server_name, version=version, instructions=instructions)
    tools_by_name: dict[str, MCPTool] = {tool.name: tool for tool in registry}

    @server.list_tools()
    async def _list_tools() -> list[types.Tool]:
        return [_tool_to_types(tool) for tool in registry]

    @server.call_tool(validate_input=False)
    async def _call_tool(name: str, arguments: dict[str, Any]) -> dict[str, Any]:
        tool = tools_by_name.get(name)
        if tool is None:
            # JSON-RPC invalid-params style error: the model read a stale
            # tools/list or hallucinated a name.
            raise ValueError(f"Unknown tool: {name}")

        try:
            authorization = get_authorization()
            if tool.handler is not None:
                result = await tool.handler(arguments or {}, authorization)
            else:
                result = await call_endpoint(
                    tool.method or "GET",
                    tool.path_template or "",
                    arguments or {},
                    authorization,
                )
        except ValueError as error:
            # Missing path parameter / bad argument shape — surface as an
            # isError result payload the agent can read and retry.
            logger.info("MCP tool %s rejected arguments: %s", name, error)
            return {"error": {"status": 400, "message": str(error)}}

        # dict → structuredContent (+ JSON text fallback for clients that
        # don't read structuredContent). Ensure JSON-serializable.
        try:
            json.dumps(result)
        except (TypeError, ValueError):
            logger.warning("MCP tool %s returned non-serializable result; stringified", name)
            result = {"result": str(result)}
        return result

    if widget_provider is not None:
        from mcp.server.lowlevel.helper_types import ReadResourceContents

        @server.list_resources()
        async def _list_resources() -> list[types.Resource]:
            entries = widget_provider.list()
            return [
                types.Resource(
                    uri=entry["uri"],
                    name=entry["name"],
                    description=entry["description"],
                    mimeType=entry["mimeType"],
                )
                for entry in entries
            ]

        @server.read_resource()
        async def _read_resource(uri: Any) -> list[ReadResourceContents]:
            resolved = widget_provider.read(str(uri))
            if resolved is None:
                raise ValueError(f"Unknown resource: {uri}")
            html, meta = resolved
            return [
                ReadResourceContents(
                    content=html,
                    mime_type=WIDGET_MIME_TYPE,
                    meta=meta,
                )
            ]

    return server


# Widget resource MIME type.
WIDGET_MIME_TYPE = "text/html"
