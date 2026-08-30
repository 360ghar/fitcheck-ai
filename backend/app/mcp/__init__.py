"""MCP (Model Context Protocol) server package.

Exposes the FitCheck API as MCP tools so AI agents (Claude, Cursor, Droid,
ChatGPT apps) can act on behalf of a user. Design:

- Tools are auto-generated from the FastAPI OpenAPI schema (``generate.py``),
  one tool per non-excluded operation.
- Tool calls are executed as in-process ASGI loopback requests against the
  real routes (``executor.py``), so auth, validation, rate limits and error
  formatting behave exactly like the public API.
- The denylist (``denylist.py``) keeps admin, auth session, webhook, SSE and
  binary-upload surfaces out of the tool registry.
- ``server.py`` builds low-level MCP ``Server`` instances; ``http.py`` wraps
  them in streamable-HTTP ASGI apps (stateless) that main.py mounts.

Docs: ``docs/references/mcp.md`` (system of record).
"""
