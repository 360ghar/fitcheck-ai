"""Unit tests for MCP tool generation, denylist, and the loopback executor."""

from __future__ import annotations

from typing import Any

import pytest
from fastapi import FastAPI, Request
from pydantic import BaseModel

from app.mcp import denylist
from app.mcp.executor import build_request, call_endpoint, set_asgi_app
from app.mcp.generate import build_tool_registry, sanitize_tool_name


# ---------------------------------------------------------------------------
# sanitize_tool_name / friendly names
# ---------------------------------------------------------------------------


def test_sanitize_strips_invalid_characters():
    assert sanitize_tool_name("get item!! details") == "get_item_details"


def test_sanitize_truncates_to_mcp_limit():
    assert len(sanitize_tool_name("x" * 200)) <= 64


@pytest.mark.unit
def test_friendly_name_splits_fastapi_operation_ids():
    from app.mcp.generate import _friendly_tool_name

    assert _friendly_tool_name("create_item_api_v1_items_post", ["Items"]) == "items_create_item"
    # Multi-word tags are slugified.
    assert _friendly_tool_name(
        "import_job_api_v1_ai_social_import_post", ["Social Import"]
    ).startswith("social_import_")
    # Custom operation IDs (no marker) pass through sanitized.
    assert _friendly_tool_name("myCustomThing", []) == "myCustomThing"


# ---------------------------------------------------------------------------
# Denylist
# ---------------------------------------------------------------------------


@pytest.mark.unit
@pytest.mark.parametrize(
    "path,excluded",
    [
        ("/api/v1/admin/users", True),
        ("/api/v1/auth/login", True),
        ("/api/v1/demo/extract", True),
        ("/api/v1/waitlist", True),
        ("/api/v1/images/item-1", True),
        ("/api/v1/stripe/webhook", True),
        ("/api/v1/subscription/stripe-webhook", True),
        # SSE endpoints...
        ("/api/v1/photoshoot/{job_id}/events", True),
        ("/api/v1/ai/batch-extract/{job_id}/events", True),
        ("/api/v1/ai/social-import/jobs/{job_id}/events", True),
        # ...but the calendar's JSON events CRUD is NOT an SSE stream.
        ("/api/v1/calendar/events", False),
        ("/api/v1/items", False),
        ("/api/v1/outfits/{outfit_id}", False),
        ("/health", True),
        ("/api/v1/health", False),
    ],
)
def test_is_excluded_path(path: str, excluded: bool):
    assert denylist.is_excluded_path(path) is excluded


@pytest.mark.unit
def test_multipart_and_streaming_operations_excluded():
    assert denylist.has_non_json_body({"requestBody": {"content": {"multipart/form-data": {}}}})
    assert not denylist.has_non_json_body({"requestBody": {"content": {"application/json": {}}}})
    assert denylist.has_non_json_response(
        {"responses": {"200": {"content": {"text/event-stream": {}}}}}
    )
    assert not denylist.has_non_json_response(
        {"responses": {"200": {"content": {"application/json": {}}}}}
    )


# ---------------------------------------------------------------------------
# build_tool_registry on a mini app
# ---------------------------------------------------------------------------


class ThingCreate(BaseModel):
    name: str
    color: str


def make_mini_app() -> FastAPI:
    app = FastAPI()

    @app.get("/api/v1/things", tags=["Things"], summary="List things")
    async def list_things(limit: int = 10):  # pragma: no cover - schema only
        return []

    @app.post("/api/v1/things", tags=["Things"], summary="Create thing")
    async def create_thing(body: ThingCreate):  # pragma: no cover - schema only
        return body

    @app.get("/api/v1/things/{thing_id}", tags=["Things"], summary="Get thing")
    async def get_thing(thing_id: str):  # pragma: no cover - schema only
        return {"id": thing_id}

    @app.get("/api/v1/things/stream/events", tags=["Things"])  # SSE suffix
    async def stream_events():  # pragma: no cover - schema only
        return []

    return app


@pytest.mark.unit
def test_build_tool_registry_merges_params_and_body():
    registry = build_tool_registry(make_mini_app())
    by_name = {tool.name: tool for tool in registry}

    # SSE-suffixed route excluded, other three present.
    assert len(registry) == 3
    assert set(by_name) == {"things_list_things", "things_create_thing", "things_get_thing"}

    list_tool = by_name["things_list_things"]
    assert list_tool.method == "GET"
    assert list_tool.input_schema["properties"]["limit"]["type"] == "integer"
    assert list_tool.input_schema["additionalProperties"] is False

    create_tool = by_name["things_create_thing"]
    # Request body nested under the explicit "body" key, refs localized.
    body_prop = create_tool.input_schema["properties"]["body"]
    assert body_prop["$ref"] == "#/$defs/ThingCreate"
    assert "ThingCreate" in create_tool.input_schema["$defs"]

    get_tool = by_name["things_get_thing"]
    assert "thing_id" in get_tool.input_schema["required"]


# ---------------------------------------------------------------------------
# Executor: request splitting + loopback call
# ---------------------------------------------------------------------------


@pytest.mark.unit
def test_build_request_splits_path_query_body():
    path, params, body = build_request(
        "POST",
        "/api/v1/outfits/{outfit_id}/wear",
        {"outfit_id": "o-1", "note": "hi", "body": {"count": 2}},
    )
    assert path == "/api/v1/outfits/o-1/wear"
    assert params == {"note": "hi"}
    assert body == {"count": 2}


@pytest.mark.unit
def test_build_request_requires_path_params():
    with pytest.raises(ValueError, match="item_id"):
        build_request("GET", "/api/v1/items/{item_id}", {})


@pytest.mark.unit
@pytest.mark.asyncio
async def test_call_endpoint_loopback_forwards_auth_and_parses_json():
    seen: dict[str, Any] = {}

    stub = FastAPI()

    @stub.get("/api/v1/ping")
    async def ping(request: Request, detail: str = ""):
        seen["authorization"] = request.headers.get("authorization")
        return {"pong": True, "detail": detail}

    set_asgi_app(stub)
    try:
        result = await call_endpoint(
            "GET", "/api/v1/ping", {"detail": "x"}, "Bearer test-token"
        )
    finally:
        from app.main import app as real_app

        set_asgi_app(real_app)

    assert result == {"pong": True, "detail": "x"}
    assert seen["authorization"] == "Bearer test-token"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_call_endpoint_maps_http_errors_without_raising():
    from fastapi import HTTPException, status

    stub = FastAPI()

    @stub.get("/api/v1/restricted")
    async def restricted():
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="forbidden")

    set_asgi_app(stub)
    try:
        result = await call_endpoint("GET", "/api/v1/restricted", {}, "Bearer t")
    finally:
        from app.main import app as real_app

        set_asgi_app(real_app)

    assert result["error"]["status"] == 403
    assert result["error"]["detail"] == "forbidden"
