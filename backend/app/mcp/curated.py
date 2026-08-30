"""Curated toolset for the ChatGPT app mount (``/mcp/chatgpt``).

ChatGPT renders every tool it sees into the model's context; 160+ mirrored
tools degrade the experience badly. The ChatGPT app instead exposes a small,
friendlier set with rich titles, invocation strings, and (for the core views)
UI widgets served as ``ui://`` resources.

Each curated tool is a REBRAND of a tool from the generated mirror registry
(``generate.py``), located by method+path. Schemas are therefore always in
sync with the real API — a route signature change updates both mounts, and a
removed route drops the curated tool (with a startup warning) instead of
producing a broken tool.
"""

from __future__ import annotations

import logging
from dataclasses import dataclass
from typing import Any

from app.mcp.generate import MCPTool

logger = logging.getLogger(__name__)


@dataclass(frozen=True)
class CuratedSpec:
    """Curated tool definition: the mirror tool it wraps plus presentation."""

    method: str
    path: str
    name: str
    title: str
    description: str
    invoking: str
    invoked: str
    widget: str | None = None  # file under app/mcp/static/, e.g. wardrobe-grid.html


_CURATED: tuple[CuratedSpec, ...] = (
    CuratedSpec(
        method="GET",
        path="/api/v1/items",
        name="get_wardrobe",
        title="Show my wardrobe",
        description=(
            "List the signed-in user's wardrobe items (name, category, color, "
            "brand, wear count). Supports pagination via limit/offset."
        ),
        invoking="Looking in your wardrobe…",
        invoked="Wardrobe ready",
        widget="wardrobe-grid.html",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/items/{item_id}",
        name="get_item",
        title="Get one clothing item",
        description="Full details (colors, brand, category, favorite, wear history) for a single wardrobe item by ID.",
        invoking="Fetching that item…",
        invoked="Item details ready",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/items/stats",
        name="get_wardrobe_stats",
        title="Show wardrobe stats",
        description="Wardrobe summary: total items, categories, cost per wear, most-worn pieces.",
        invoking="Counting your closet…",
        invoked="Wardrobe stats ready",
        widget="wardrobe-grid.html",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/outfits",
        name="get_outfits",
        title="Show my outfits",
        description="List the user's saved outfits with images and metadata. Paginated via limit/offset.",
        invoking="Pulling up your outfits…",
        invoked="Outfits ready",
        widget="outfit-cards.html",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/outfits/{outfit_id}",
        name="get_outfit",
        title="Get one outfit",
        description="Full details (items, images, occasion) for a single saved outfit by ID.",
        invoking="Fetching that outfit…",
        invoked="Outfit ready",
        widget="outfit-cards.html",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/recommendations/weather",
        name="get_todays_outfit_ideas",
        title="Get today's outfit ideas",
        description=(
            "Weather conditions and clothing guidance for a given city and date. "
            "Does not read the user's wardrobe or calendar."
        ),
        invoking="Checking weather guidance…",
        invoked="Weather guidance ready",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/calendar/events",
        name="get_wear_plan",
        title="Show my wear plan",
        description="Upcoming calendar events and their planned outfits.",
        invoking="Checking your calendar…",
        invoked="Wear plan ready",
    ),
    CuratedSpec(
        method="GET",
        path="/api/v1/weather",
        name="get_weather",
        title="Get weather for outfit planning",
        description="Current weather conditions for a city (used for outfit planning).",
        invoking="Checking the sky…",
        invoked="Weather ready",
    ),
)


def build_curated_registry(base_registry: list[MCPTool]) -> list[MCPTool]:
    """Derive the curated ChatGPT registry from the full mirror registry."""
    by_route: dict[tuple[str, str], MCPTool] = {
        (tool.method or "", tool.path_template or ""): tool for tool in base_registry
    }
    curated: list[MCPTool] = []
    for spec in _CURATED:
        base = by_route.get((spec.method, spec.path))
        if base is None:
            logger.warning(
                "Curated ChatGPT tool %s skipped: route %s %s no longer exists",
                spec.name,
                spec.method,
                spec.path,
            )
            continue
        meta: dict[str, Any] = {
            "openai/toolInvocation/invoking": spec.invoking,
            "openai/toolInvocation/invoked": spec.invoked,
        }
        if spec.widget:
            meta["openai/outputTemplate"] = f"ui://fitcheck/{spec.widget}"
        curated.append(
            MCPTool(
                name=spec.name,
                title=spec.title,
                description=spec.description,
                input_schema=base.input_schema,
                meta=meta,
                method=base.method,
                path_template=base.path_template,
            )
        )
    logger.info("MCP curated registry: %d ChatGPT tools", len(curated))
    return curated
