"""Generate MCP tool definitions from the FastAPI OpenAPI schema.

One tool per non-excluded operation. Tool names are sanitized ``operationId``s
(fastapi generates unique ones per route function), input schemas merge path
params, query params and the JSON request body, and ``$ref`` pointers are
rewritten to a local ``$defs`` block so each inputSchema is self-contained.

Descriptions come from the route ``summary`` / ``description`` plus tags so
agent-side model can pick the right tool without reading the API docs.
"""

from __future__ import annotations

import logging
import re
from dataclasses import dataclass, field
from typing import Any, Awaitable, Callable

from fastapi import FastAPI

from app.mcp import denylist

logger = logging.getLogger(__name__)

# MCP tool names must match ^[a-zA-Z0-9_-]{1,64}$ (spec) — sanitize to that.
_INVALID_NAME_CHARS = re.compile(r"[^a-zA-Z0-9_-]+")

_MAX_NAME_LENGTH = 64
_MAX_DESCRIPTION_LENGTH = 900

_JSON_MEDIA_TYPE = "application/json"


@dataclass
class MCPTool:
    """A single MCP tool: its wire metadata plus how to execute it."""

    name: str
    description: str
    input_schema: dict[str, Any]
    title: str | None = None
    meta: dict[str, Any] | None = None
    # API-mirror tools: executed via the loopback executor.
    method: str | None = None
    path_template: str | None = None
    # Curated tools (ChatGPT app): a direct handler instead of a mirrored
    # route. Receives (arguments, authorization_header).
    handler: Callable[[dict[str, Any], str | None], Awaitable[Any]] | None = None
    tags: list[str] = field(default_factory=list)


def sanitize_tool_name(raw: str) -> str:
    """Reduce an operationId to a valid MCP tool name."""
    name = _INVALID_NAME_CHARS.sub("_", raw).strip("_")
    if not name:
        name = "tool"
    return name[:_MAX_NAME_LENGTH].rstrip("_")


def _friendly_tool_name(operation_id: str, tags: list[str]) -> str:
    """Turn FastAPI's auto operationId into an agent-friendly tool name.

    FastAPI generates ``{func_name}_{path_slug}_{method}`` (e.g.
    ``create_item_api_v1_items_post``). The path slug is redundant for an
    agent, so split it off and prefix the router tag instead:
    ``items_create_item``. Operation IDs without the marker (custom
    ``operation_id=``) are used as-is.
    """
    base = operation_id
    marker = "_api_v1_"
    if marker in operation_id:
        base = operation_id.split(marker, 1)[0]
        tag_slug = _INVALID_NAME_CHARS.sub("_", (tags[0] if tags else "")).strip("_").lower()
        base = f"{tag_slug}_{base}" if tag_slug else base
    return sanitize_tool_name(base)


def _collect_schema_refs(schema: Any, into: set[str]) -> None:
    """Recursively gather component schema names referenced by a schema."""
    if isinstance(schema, dict):
        ref = schema.get("$ref")
        if isinstance(ref, str) and ref.startswith("#/components/schemas/"):
            name = ref.split("/")[-1]
            if name not in into:
                into.add(name)
        for value in schema.values():
            _collect_schema_refs(value, into)
    elif isinstance(schema, list):
        for item in schema:
            _collect_schema_refs(item, into)


def _localize_refs(node: Any) -> Any:
    """Rewrite ``#/components/schemas/X`` pointers to ``#/$defs/X``."""
    if isinstance(node, dict):
        localized: dict[str, Any] = {}
        for key, value in node.items():
            if key == "$ref" and isinstance(value, str) and value.startswith("#/components/schemas/"):
                localized[key] = "#/$defs/" + value.split("/")[-1]
            else:
                localized[key] = _localize_refs(value)
        return localized
    if isinstance(node, list):
        return [_localize_refs(item) for item in node]
    return node


def _build_input_schema(
    operation: dict[str, Any],
    components: dict[str, Any],
) -> dict[str, Any]:
    """Merge path/query parameters and the JSON body into one JSON schema."""
    properties: dict[str, Any] = {}
    required: list[str] = []

    for parameter in operation.get("parameters") or []:
        name = parameter.get("name")
        param_schema = parameter.get("schema") or {"type": "string"}
        if not name:
            continue
        entry = dict(param_schema)
        entry["description"] = parameter.get("description") or entry.get("description", "")
        properties[name] = entry
        if parameter.get("required"):
            required.append(name)

    body = operation.get("requestBody") or {}
    body_schema = (body.get("content") or {}).get(_JSON_MEDIA_TYPE, {}).get("schema")
    if isinstance(body_schema, dict):
        # Nested under an explicit "body" key: collision-free with path/query
        # params regardless of the endpoint's schema, and unambiguous for the
        # calling agent (arguments.body = request payload).
        properties["body"] = body_schema
        if body.get("required"):
            required.append("body")

    input_schema: dict[str, Any] = {
        "type": "object",
        "properties": properties,
    }
    if required:
        input_schema["required"] = required

    # Self-contained $defs: copy every referenced component schema and rewrite
    # pointers so clients (and validators) resolve refs inside the tool schema.
    refs: set[str] = set()
    _collect_schema_refs(input_schema, refs)
    if refs:
        defs: dict[str, Any] = {}
        queue = list(refs)
        seen: set[str] = set()
        while queue:
            ref_name = queue.pop()
            if ref_name in seen:
                continue
            seen.add(ref_name)
            component = ((components.get("schemas") or {}).get(ref_name)) or {}
            defs[ref_name] = component
            nested: set[str] = set()
            _collect_schema_refs(component, nested)
            queue.extend(nested - seen)
        input_schema["$defs"] = {name: _localize_refs(schema) for name, schema in defs.items()}
        input_schema = _localize_refs(input_schema)

    input_schema["additionalProperties"] = False
    return input_schema


def _build_description(operation: dict[str, Any], method: str, path: str) -> str:
    parts: list[str] = []
    summary = (operation.get("summary") or "").strip()
    description = (operation.get("description") or "").strip()
    if summary:
        parts.append(summary)
    elif description:
        parts.append(description.split("\n\n")[0])
    tags = operation.get("tags") or []
    if tags:
        parts.append(f"({', '.join(tags)})")
    parts.append(f"[{method.upper()} {path}]")
    text = ". ".join(parts)
    if len(text) > _MAX_DESCRIPTION_LENGTH:
        text = text[: _MAX_DESCRIPTION_LENGTH - 1] + "…"
    return text


def build_tool_registry(app: FastAPI) -> list[MCPTool]:
    """Generate the full API-mirror tool registry from the app's OpenAPI."""
    schema = app.openapi()
    components = schema.get("components") or {}
    registry: list[MCPTool] = []
    used_names: set[str] = set()
    excluded = 0

    for path, path_item in (schema.get("paths") or {}).items():
        if denylist.is_excluded_path(path):
            excluded += len(path_item)
            continue
        for method, operation in path_item.items():
            if method not in {"get", "post", "put", "patch", "delete"}:
                continue
            if not isinstance(operation, dict):
                continue
            if denylist.is_excluded_path(path) or denylist.has_non_json_body(operation) or denylist.has_non_json_response(operation):
                excluded += 1
                continue
            operation_id = operation.get("operationId")
            if not operation_id:
                excluded += 1
                continue
            tags = list(operation.get("tags") or [])

            name = _friendly_tool_name(operation_id, tags)
            while name in used_names:
                name = f"{name[:_MAX_NAME_LENGTH - 2]}_x"
            used_names.add(name)

            registry.append(
                MCPTool(
                    name=name,
                    description=_build_description(operation, method, path),
                    input_schema=_build_input_schema(operation, components),
                    title=(operation.get("summary") or name)[:120],
                    method=method.upper(),
                    path_template=path,
                    tags=tags,
                )
            )

    logger.info(
        "MCP registry: %d tools generated, %d operations excluded by denylist/rules",
        len(registry),
        excluded,
    )
    return registry
