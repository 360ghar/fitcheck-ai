#!/usr/bin/env python3
"""Generate docs/references/api-spec.md from the live FastAPI OpenAPI document.

Loads the FastAPI app in-process (TestClient, same approach as
backend/scripts/export_openapi.py — Supabase clients are lazy and the schema
endpoint is unauthenticated; no network is required; reads backend/.env for
settings) and renders a deterministic Markdown reference:

- fixed front-matter (generated banner, reconciliation points, base URL,
  authentication, response/error envelopes derived from app/main.py handlers,
  status codes)
- one section per endpoint group (auth, items, outfits, ai, admin, ...),
  with per-endpoint request-body tables, parameters tables, auth requirement
  and 2xx response summaries
- a Models appendix listing every ``components.schemas`` entry

Output is byte-stable for a given backend state: paths and schemas are sorted,
no timestamps are emitted, so CI can drift-check the committed file.

Usage (from the repo root or the backend dir):

    cd backend && source .venv/bin/activate && python ../scripts/generate_api_spec_doc.py
    python scripts/generate_api_spec_doc.py [OUTPUT_PATH]   # optional explicit output (CI)

Without an argument the script writes docs/references/api-spec.md.
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BACKEND_DIR = ROOT / "backend"
DEFAULT_OUTPUT = ROOT / "docs" / "references" / "api-spec.md"

# Make the backend package importable when run from either the repo root or
# the backend dir.
sys.path.insert(0, str(BACKEND_DIR))

from fastapi.testclient import TestClient  # noqa: E402

from app.main import app  # noqa: E402

# Method display order within a path.
METHOD_ORDER = {"get": 0, "post": 1, "put": 2, "patch": 3, "delete": 4, "head": 5, "options": 6}

# Endpoint grouping: (path prefix, section heading), first match wins.
# Order here is the document order of the sections; "/" is the catch-all and
# must stay last so it never shadows a more specific prefix.
GROUPS = [
    ("/health", "Health & readiness"),
    ("/ready", "Health & readiness"),
    ("/api/v1/health", "Health & readiness"),
    ("/api/v1/auth", "Authentication Endpoints"),
    ("/api/v1/waitlist", "Waitlist"),
    ("/api/v1/demo", "Demo"),
    ("/api/v1/users", "Users"),
    ("/api/v1/items", "Items"),
    ("/api/v1/outfits", "Outfits"),
    ("/api/v1/shared-outfits", "Shared Outfits"),
    ("/api/v1/recommendations", "Recommendations"),
    ("/api/v1/calendar", "Calendar"),
    ("/api/v1/weather", "Weather"),
    ("/api/v1/gamification", "Gamification"),
    ("/api/v1/ai/settings", "AI Settings"),
    ("/api/v1/ai/social-import", "Social Import"),
    ("/api/v1/ai/batch", "Batch Processing"),
    ("/api/v1/ai", "AI Operations"),
    ("/api/v1/photoshoot", "Photoshoot"),
    ("/api/v1/images", "Images"),
    ("/api/v1/subscription", "Subscription"),
    ("/api/v1/referral", "Referral"),
    ("/api/v1/promo", "Promo"),
    ("/api/v1/feedback", "Feedback"),
    ("/api/v1/blog", "Blog"),
    ("/api/v1/admin", "Admin"),
    ("/", "Root & robots"),
]

REASON = {
    200: "OK",
    201: "Created",
    202: "Accepted",
    204: "No Content",
    207: "Multi-Status",
    400: "Bad Request",
    401: "Unauthorized",
    403: "Forbidden",
    404: "Not Found",
    405: "Method Not Allowed",
    409: "Conflict",
    413: "Payload Too Large",
    415: "Unsupported Media Type",
    422: "Unprocessable Entity",
    429: "Too Many Requests",
    500: "Internal Server Error",
    502: "Bad Gateway",
    503: "Service Unavailable",
    504: "Gateway Timeout",
}

# Envelope notes for the status-codes table; derived from app/main.py error
# handlers and app/core/exceptions.py (kept in sync with those files).
STATUS_NOTES = {
    200: "Success — body uses the success envelope.",
    201: "Created — resource created.",
    202: "Accepted — async job/upload accepted (see reconciliation points).",
    204: "No Content — success with no body.",
    207: "Multi-Status — partial success (photoshoot sync mode).",
    400: "Bad Request — error envelope with a domain code.",
    401: "Unauthorized — `AUTH_UNAUTHORIZED` / `AUTH_TOKEN_EXPIRED` / `AUTH_TOKEN_INVALID`.",
    403: "Forbidden — `PERMISSION_DENIED` (admin routes re-check RBAC server-side).",
    404: "Not Found — `NOT_FOUND` family (`ITEM_NOT_FOUND`, `OUTFIT_NOT_FOUND`, ...).",
    409: "Conflict — e.g. `AUTH_EMAIL_EXISTS`, `SOCIAL_IMPORT_MFA_REQUIRED`.",
    415: "Unsupported Media Type — `UNSUPPORTED_MEDIA_TYPE`.",
    422: "Validation Error — `VALIDATION_ERROR` with `details.errors[]`.",
    429: "Too Many Requests — `RATE_LIMIT_EXCEEDED` (AI daily quota / IP rate limit).",
    500: "Internal Server Error — `INTERNAL_ERROR` / `DATABASE_ERROR`.",
    501: "Not Implemented — e.g. the Stripe webhook endpoint when webhooks are not configured (`HTTPException(501)`).",
    502: "Bad Gateway — e.g. `SOCIAL_IMPORT_OAUTH_EXCHANGE_ERROR`.",
    503: "Service Unavailable — `AI_SERVICE_ERROR` / `SERVICE_UNAVAILABLE` / `SCHEMA_NOT_INITIALIZED` / `BILLING_NOT_CONFIGURED`.",
}

# Common FitCheckException codes for the Response Format section (the full
# set lives in backend/app/core/exceptions.py).
COMMON_ERROR_CODES = [
    ("AUTH_UNAUTHORIZED", "401", "Missing/invalid credentials"),
    ("AUTH_TOKEN_EXPIRED", "401", "Access token has expired"),
    ("AUTH_TOKEN_INVALID", "401", "Access token is invalid or malformed"),
    ("AUTH_EMAIL_EXISTS", "409", "Email already registered"),
    ("PERMISSION_DENIED", "403", "User lacks permission (admin RBAC)"),
    ("VALIDATION_ERROR", "422", "Request body/query validation failed"),
    ("INVALID_INPUT", "422", "Invalid input value"),
    ("FILE_TOO_LARGE", "422", "Uploaded file exceeds the size limit"),
    ("UNSUPPORTED_MEDIA_TYPE", "415", "Unsupported file type"),
    ("ITEM_NOT_FOUND", "404", "Wardrobe item not found"),
    ("OUTFIT_NOT_FOUND", "404", "Outfit not found"),
    ("USER_NOT_FOUND", "404", "User not found"),
    ("RATE_LIMIT_EXCEEDED", "429", "Daily AI quota or IP rate limit hit"),
    ("AI_SERVICE_ERROR", "503", "AI provider unavailable/failed"),
    ("STORAGE_SERVICE_ERROR", "503", "Storage service unavailable"),
    ("DATABASE_ERROR", "500", "Database operation failed"),
    ("SCHEMA_NOT_INITIALIZED", "503", "Supabase schema/migrations incomplete"),
    ("SERVICE_UNAVAILABLE", "503", "External service temporarily unavailable"),
    ("BILLING_NOT_CONFIGURED", "503", "Stripe billing not configured for this deployment"),
    ("HTTP_ERROR", "varies", "Generic HTTP exception (e.g. 404 from FastAPI)"),
    ("INTERNAL_ERROR", "500", "Unhandled exception (catch-all handler)"),
]

MAX_TABLE_PROPERTIES = 12  # inline a response model table when at most this many fields


def load_openapi() -> dict:
    """Load the live OpenAPI document from the FastAPI app via TestClient."""
    client = TestClient(app)
    response = client.get("/api/v1/openapi.json")
    if response.status_code != 200:
        raise SystemExit(
            f"OpenAPI load failed: GET /api/v1/openapi.json -> {response.status_code}"
        )
    return response.json()


def clean_desc(text: str, limit: int = 220) -> str:
    """Flatten a description for a table cell (single line, escaped pipes)."""
    if not text:
        return ""
    return " ".join(str(text).split()).replace("|", "\\|")[:limit]


def deref(schema: dict, components: dict) -> dict:
    """Resolve $ref pointers; guard against cycles by capping depth."""
    seen = 0
    while isinstance(schema, dict) and "$ref" in schema:
        name = schema["$ref"].rsplit("/", 1)[-1]
        target = components.get(name)
        if target is None or seen > 20:
            return schema
        schema = target
        seen += 1
    return schema


def ref_name(schema: dict) -> str | None:
    """Return the referenced schema name for a $ref, or None."""
    if isinstance(schema, dict) and "$ref" in schema:
        return schema["$ref"].rsplit("/", 1)[-1]
    return None


def type_label(schema, components: dict, depth: int = 0) -> str:
    """Compact inline type label for a (possibly $ref'd) OpenAPI schema."""
    if depth > 10:
        return "object"
    if not isinstance(schema, dict):
        return "object"
    if "$ref" in schema:
        return f"`{schema['$ref'].rsplit('/', 1)[-1]}`"
    if "allOf" in schema:
        merged: dict = {}
        for part in schema["allOf"]:
            resolved = deref(part, components)
            if isinstance(resolved, dict):
                merged.update(resolved)
        return type_label(merged, components, depth + 1)
    for variant_key in ("anyOf", "oneOf"):
        if variant_key in schema:
            variants = schema[variant_key]
            non_null = [v for v in variants if not (isinstance(v, dict) and v.get("type") == "null")]
            null_present = len(non_null) != len(variants)
            if len(non_null) == 1:
                label = type_label(non_null[0], components, depth + 1)
                return f"{label} (nullable)" if null_present else label
            joined = " \\| ".join(type_label(v, components, depth + 1) for v in non_null)
            return f"one of: {joined}"
    if "type" not in schema:
        # {} or {properties/additionalProperties}-only: an arbitrary object
        return "object"
    t = schema["type"]
    if t == "array":
        return f"array<{type_label(schema.get('items', {}), components, depth + 1)}>"
    if t == "object":
        additional = schema.get("additionalProperties")
        if isinstance(additional, dict):
            return f"object<{type_label(additional, components, depth + 1)}>"
        return "object"
    if t == "string":
        if schema.get("format") == "binary" or "contentMediaType" in schema:
            return "file (binary)"
        if "enum" in schema:
            values = ", ".join(str(e) for e in schema["enum"])
            return f"enum: {values}"
        fmt = schema.get("format")
        if fmt in ("uuid", "date", "date-time", "email"):
            return f"string ({fmt})"
        return "string"
    if t == "integer":
        return "integer"
    if t == "number":
        return "number"
    if t == "boolean":
        return "boolean"
    return t


def schema_table(schema, components: dict) -> list[str]:
    """Markdown table (Field | Type | Required | Description) for a schema."""
    resolved = deref(schema, components)
    if isinstance(resolved, dict) and "allOf" in resolved:
        merged: dict = {}
        for part in resolved["allOf"]:
            part_resolved = deref(part, components)
            if isinstance(part_resolved, dict):
                merged.setdefault("properties", {}).update(part_resolved.get("properties", {}))
                merged["required"] = list(
                    dict.fromkeys(
                        merged.get("required", []) + list(part_resolved.get("required", []))
                    )
                )
                if part_resolved.get("description") and not merged.get("description"):
                    merged["description"] = part_resolved["description"]
        resolved = merged
    if not isinstance(resolved, dict) or not resolved.get("properties"):
        return []
    required = set(resolved.get("required", []))
    rows = ["| Field | Type | Required | Description |", "|---|---|---|---|"]
    for name in sorted(resolved["properties"]):
        prop = resolved["properties"][name]
        if not isinstance(prop, dict):
            prop = {}
        req = "yes" if name in required else "no"
        rows.append(
            f"| `{name}` | {type_label(prop, components)} | {req} | {clean_desc(prop.get('description', ''))} |"
        )
    return rows


def schema_description(schema, components: dict) -> str:
    """Return a flattened schema description (empty when none is declared)."""
    resolved = deref(schema, components)
    if isinstance(resolved, dict):
        return clean_desc(resolved.get("description", ""), limit=400)
    return ""


def group_for(path: str) -> str:
    """Map an API path to its section heading (first matching prefix rule)."""
    for prefix, heading in GROUPS:
        if path.startswith(prefix):
            return heading
    return "Other API"


def auth_line(op: dict) -> str:
    """One-line auth requirement note for an OpenAPI operation."""
    security = op.get("security")
    if not security:  # None or []
        return "**Auth:** none (public endpoint)"
    return "**Auth:** required — `Authorization: Bearer <jwt>`"


def is_generic_payload(schema: dict) -> bool:
    """Routes declared with response_model=Dict[str, Any] produce these."""
    if schema == {}:
        return True
    if schema.get("type") == "object" and schema.get("additionalProperties") is True:
        return True
    return False


def render_endpoint(method: str, path: str, op: dict, components: dict) -> list[str]:
    """Render the full markdown section (params, body, responses) for one operation."""
    lines: list[str] = []
    heading = f"### {method.upper()} {path}"
    lines.append(heading)
    lines.append("")

    summary = op.get("summary") or ""
    description = op.get("description") or ""
    if description:
        lines.append(description.strip())
    elif summary:
        lines.append(summary.strip())
    lines.append("")

    lines.append(auth_line(op))
    lines.append("")

    # Parameters (path + query)
    params = [p for p in op.get("parameters", []) if p.get("in") in ("path", "query")]
    if params:
        lines.append("**Parameters:**")
        lines.append("")
        lines.append("| Parameter | In | Type | Required | Description |")
        lines.append("|-----------|----|------|----------|-------------|")
        for p in sorted(params, key=lambda x: (x["in"], x["name"])):
            p_schema = p.get("schema", {}) if isinstance(p.get("schema"), dict) else {}
            req = "yes" if p.get("required") else "no"
            lines.append(
                f"| `{p['name']}` | {p['in']} | {type_label(p_schema, components)} | {req} | "
                f"{clean_desc(p.get('description', ''))} |"
            )
        lines.append("")

    # Request body
    rb = op.get("requestBody")
    if rb:
        content = rb.get("content", {})
        required = bool(rb.get("required", False))
        for content_type, body in content.items():
            body_schema = body.get("schema", {}) if isinstance(body.get("schema"), dict) else {}
            req_mark = "required" if required else "optional"
            lines.append(f"**Request body** (`{content_type}`, {req_mark}):")
            lines.append("")
            rows = schema_table(body_schema, components)
            if rows:
                lines.extend(rows)
            else:
                lines.append("_No structured fields declared._")
            lines.append("")

    # Responses
    responses = op.get("responses", {}) or {}
    success = [(c, r) for c, r in responses.items() if c.startswith("2")]
    errors = [(c, r) for c, r in responses.items() if not c.startswith("2")]
    if success or errors:
        lines.append("**Responses:**")
        lines.append("")
        for code, resp in sorted(success, key=lambda x: int(x[0])):
            headline, rows = render_success(method, path, code, resp, components)
            if rows:
                lines.append(f"**Response {code}:** {headline}")
                lines.append("")
                lines.extend(rows)
                lines.append("")
            else:
                lines.append(f"- **{code}** {headline}")
        if errors:
            parts = []
            for code, resp in sorted(errors, key=lambda x: int(x[0])):
                desc = resp.get("description") or ""
                if desc in ("", "Successful Response", "Validation Error"):
                    desc = REASON.get(int(code), "")
                parts.append(f"{code} {desc}".strip())
            lines.append(f"- **Errors:** {', '.join(parts)}")
        lines.append("")
    return lines


def render_success(method: str, path: str, code: str, resp: dict, components: dict) -> tuple[str, list[str]]:
    """Render a 2xx response; returns (headline, optional schema table rows)."""
    is_sse = path.endswith("/events") and method.lower() == "get"
    content = resp.get("content") or {}
    if is_sse:
        return (
            "SSE event stream (`text/event-stream`; OpenAPI declares no schema). "
            "Frames are `data: {…}` JSON; terminal events: batch and photoshoot emit "
            "`job_complete`, social import emits `job_completed` (TD-020).",
            [],
        )
    if not content:
        return (REASON.get(int(code), "").rstrip("."), [])
    for content_type, body in content.items():
        schema = body.get("schema", {}) if isinstance(body.get("schema"), dict) else {}
        if "event-stream" in content_type:
            return (
                "SSE event stream (`text/event-stream`; no schema declared). "
                "See reconciliation points (TD-020) for terminal event names.",
                [],
            )
        if is_generic_payload(schema):
            return (
                "Arbitrary JSON object — routes wrap payloads in the `{data, message}` "
                "envelope (see [Response Format](#response-format)).",
                [],
            )
        name = ref_name(schema)
        if name:
            resolved = deref(schema, components)
            props = resolved.get("properties", {}) if isinstance(resolved, dict) else {}
            if props and len(props) <= MAX_TABLE_PROPERTIES:
                desc = schema_description(schema, components)
                headline = f"Returns `{name}`" + (f" — {desc}" if desc else "")
                return (headline, schema_table(schema, components))
            return (f"Returns `{name}` — see [Models](#models).", [])
        return (f"Returns {type_label(schema, components)}.", [])
    return ("", [])


def render_public_endpoints(spec: dict) -> list[str]:
    """Render the Authentication section and the public (no-auth) endpoint list."""
    lines = ["## Authentication", ""]
    lines.append(
        "All endpoints except the public set below require a JWT bearer token in the "
        "`Authorization` header:"
    )
    lines.append("")
    lines.append("```text")
    lines.append("Authorization: Bearer <jwt_token>")
    lines.append("```")
    lines.append("")
    lines.append("The OpenAPI security scheme is `HTTPBearer`; tokens are verified "
                 "server-side (`app/core/security.py`), and admin routes additionally "
                 "enforce RBAC via `require_admin` / `require_permission`.")
    lines.append("")
    lines.append("Public endpoints (no auth required):")
    lines.append("")
    public: list[str] = []
    for path in sorted(spec["paths"]):
        for method, op in spec["paths"][path].items():
            if isinstance(op, dict) and not op.get("security"):
                public.append(f"- `{method.upper()} {path}`")
    if public:
        lines.extend(public)
    else:
        lines.append("_None._")
    lines.append("")
    return lines


def render_status_codes(spec: dict) -> list[str]:
    """Render the Status Codes table (declared responses + handler-emitted codes)."""
    codes: set[int] = set()
    for path in spec["paths"]:
        for op in spec["paths"][path].values():
            if not isinstance(op, dict):
                continue
            for code in op.get("responses", {}):
                if code.isdigit():
                    codes.add(int(code))
    # Union with the statuses the error handlers can emit (app/main.py +
    # app/core/exceptions.py), which routes rarely declare in OpenAPI.
    codes |= set(STATUS_NOTES)
    lines = ["## Status Codes", ""]
    lines.append("| Code | Description |")
    lines.append("|------|-------------|")
    for code in sorted(codes):
        note = STATUS_NOTES.get(code, REASON.get(code, ""))
        lines.append(f"| {code} | {note} |")
    lines.append("")
    lines.append(
        "Error responses always use the error envelope below (with `correlation_id`); "
        "the `code` field is the domain code, not the HTTP status."
    )
    lines.append("")
    return lines


def render_models(spec: dict) -> list[str]:
    """Render the Models section (every OpenAPI component schema, sorted by name)."""
    schemas = spec.get("components", {}).get("schemas", {})
    lines = ["## Models", ""]
    lines.append(
        "All request/response models from the OpenAPI `components.schemas`, sorted by "
        "name. Endpoint sections reference these by name; `Body_*` entries are the "
        "multipart/form-data request shapes (file fields are `file (binary)`)."
    )
    lines.append("")
    for name in sorted(schemas):
        schema = schemas[name]
        lines.append(f"### `{name}`")
        lines.append("")
        desc = schema_description({"$ref": f"#/components/schemas/{name}"}, schemas)
        if desc:
            lines.append(f"{desc}")
            lines.append("")
        rows = schema_table(schema, schemas)
        if rows:
            lines.extend(rows)
            lines.append("")
    return lines


def render_doc(spec: dict) -> list[str]:
    """Assemble the full generated markdown document from the OpenAPI spec."""
    components = spec.get("components", {}).get("schemas", {})
    paths = spec["paths"]

    operations: list[tuple[str, str, dict]] = []
    for path in paths:
        for method, op in paths[path].items():
            if isinstance(op, dict) and method in METHOD_ORDER:
                operations.append((path, method, op))
    operations.sort(key=lambda x: (x[0], METHOD_ORDER[x[1]]))

    grouped: dict[str, list[tuple[str, str, dict]]] = {}
    for path, method, op in operations:
        grouped.setdefault(group_for(path), []).append((path, method, op))

    # Emit sections in GROUPS order (document narrative), then any leftovers.
    # "Root & robots" is the "/" catch-all rule (last in the match list, so it
    # never shadows a specific prefix) but belongs first in the document.
    section_order: list[str] = ["Root & robots"] if "Root & robots" in grouped else []
    for _, heading in GROUPS:
        if heading in grouped and heading not in section_order:
            section_order.append(heading)
    for heading in grouped:
        if heading not in section_order:
            section_order.append(heading)

    lines: list[str] = []
    lines.append("# API Specification")
    lines.append("")
    lines.append(
        "> **Generated document.** This file is generated from the live FastAPI "
        "OpenAPI document (`GET /api/v1/openapi.json`, exposed at `/api/v1/docs`). "
        "Do not edit by hand — regenerate after backend API changes:"
    )
    lines.append(">")
    lines.append("> ```bash")
    lines.append("> cd backend && source .venv/bin/activate && python ../scripts/generate_api_spec_doc.py")
    lines.append("> ```")
    lines.append(">")
    lines.append(
        "> Or from the repo root: `python scripts/generate_api_spec_doc.py [OUTPUT_PATH]`. "
        "CI drift-checks this file (`.github/workflows/backend-ci.yml`), so API changes "
        "must land with a regenerated copy."
    )
    lines.append("")

    lines.append("## Overview")
    lines.append("")
    lines.append(
        f"This reference covers **{len(operations)}** operations across "
        f"**{len(paths)}** paths, grouped by router. Request bodies and response "
        "models are rendered from the OpenAPI `components.schemas`; where a route is "
        "declared with an arbitrary-JSON response model (no schema), the response is "
        "documented as the `{data, message}` envelope and the shape of `data` should "
        "be confirmed against the route source."
    )
    lines.append("")
    lines.append(
        "Job-based endpoints (photoshoot, batch extraction, social import) accept "
        "work asynchronously: they return a `job_id` in `data` immediately (202) and "
        "expose `/status` polling plus `/events` SSE streams (see TD-020 below)."
    )
    lines.append("")
    lines.append("## Known reconciliation points")
    lines.append("")
    lines.append(
        "These curated caveats carry forward from manual review of the API and remain "
        "true at generation time (see `docs/exec-plans/tech-debt-tracker.md`):"
    )
    lines.append("")
    lines.append("- **TD-023** — `POST /api/v1/items/upload` declares `202 Accepted` but runs "
                 "synchronously: it uploads all files and returns the final result in the "
                 "same response; there is no job to poll.")
    lines.append("- **TD-020** — SSE terminal event names differ between streams: batch and "
                 "photoshoot emit `job_complete`; social import emits `job_completed`.")
    lines.append("- **Feature flags alter route behavior** — `ENABLE_SOCIAL_IMPORT` mounts the "
                 "social-import router and `ENABLE_GAMIFICATION` is enforced inside handlers "
                 "(the router stays mounted); the OpenAPI above reflects the flags enabled "
                 "at generation time.")
    lines.append("- **Stripe price IDs are environment configuration** (`STRIPE_*_PRICE_ID`), "
                 "not API data.")
    lines.append("- **Outfit garment references** — generation sends the avatar plus up to "
                 "`AI_OUTFIT_ITEM_REFERENCE_MAX_IMAGES` (default 12) garment reference "
                 "images per generation (the request list is separately capped at "
                 "`AI_MAX_OUTFIT_ITEMS`, default 100); provider image-count behavior for "
                 "garment references remains unverified (TD-033).")
    lines.append("")
    lines.append("## Base URL")
    lines.append("")
    lines.append("```text")
    lines.append("Development: http://localhost:8000/api/v1")
    lines.append("Production:  https://api.fitcheckaiapp.com/api/v1")
    lines.append("```")
    lines.append("")
    lines.append(
        "The web app calls the API same-origin through a proxy (`/api` → backend in "
        "dev; Netlify redirect to `api.fitcheckaiapp.com` in prod); mobile apps use the "
        "absolute production origin."
    )
    lines.append("")

    lines.extend(render_public_endpoints(spec))
    lines.extend(render_response_format(spec))
    lines.extend(render_status_codes(spec))

    for heading in section_order:
        lines.append(f"## {heading}")
        lines.append("")
        for path, method, op in grouped[heading]:
            lines.extend(render_endpoint(method, path, op, components))

    lines.extend(render_models(spec))

    lines.append("---")
    lines.append("")
    lines.append(
        "_Regenerate after backend API changes; CI drift-checks this file "
        "(`.github/workflows/backend-ci.yml`)._"
    )
    lines.append("")
    return lines


def render_response_format(spec: dict) -> list[str]:
    """Render the Response Format section (envelope shapes + handler mapping)."""
    lines = ["## Response Format", ""]
    lines.append("### Success Response")
    lines.append("")
    lines.append(
        "Routes wrap payloads in a `{data, message}` envelope (verified across the "
        "route modules; a few endpoints return a bare `{message}` — e.g. password "
        "reset). The shape of `data` varies per endpoint:"
    )
    lines.append("")
    lines.append("```json")
    lines.append('{')
    lines.append('  "data": {},')
    lines.append('  "message": "OK"')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append(
        "Many routes declare `response_model=Dict[str, Any]`, so OpenAPI cannot "
        "enumerate `data`'s fields; endpoint sections show a model table only where a "
        "real response model is declared."
    )
    lines.append("")
    lines.append("### Error Response")
    lines.append("")
    lines.append(
        "All error responses (from `backend/app/main.py` exception handlers) share "
        "this envelope — the `code` field carries the domain error code:"
    )
    lines.append("")
    lines.append("```json")
    lines.append('{')
    lines.append('  "error": "Error message",')
    lines.append('  "code": "DOMAIN_ERROR_CODE",')
    lines.append('  "details": {},')
    lines.append('  "correlation_id": "..."')
    lines.append('}')
    lines.append("```")
    lines.append("")
    lines.append("Handler mapping (from `app/main.py`):")
    lines.append("")
    lines.append("| Source | HTTP status | `code` | `details` |")
    lines.append("|--------|-------------|--------|-----------|")
    lines.append("| `FitCheckException` | its `status_code` | class `error_code` | exception `details` |")
    lines.append("| `StarletteHTTPException` | its status | `HTTP_ERROR` | `{}` |")
    lines.append("| `RequestValidationError` | 422 | `VALIDATION_ERROR` | `{errors: [{field, message}]}` |")
    lines.append("| Unhandled exception | 500 | `INTERNAL_ERROR` | `{}` |")
    lines.append("")
    lines.append("`X-Correlation-ID` is also exposed on responses (CORS `expose_headers`).")
    lines.append("")
    lines.append("Common domain error codes (full set in `backend/app/core/exceptions.py`):")
    lines.append("")
    lines.append("| Code | Status | Meaning |")
    lines.append("|------|--------|---------|")
    for code, status, meaning in COMMON_ERROR_CODES:
        lines.append(f"| `{code}` | {status} | {meaning} |")
    lines.append("")
    return lines


def main() -> int:
    """Generate the API reference markdown; default output is docs/references/api-spec.md."""
    out_path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_OUTPUT
    spec = load_openapi()
    lines = render_doc(spec)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(
        f"Wrote {out_path.relative_to(ROOT) if out_path.is_relative_to(ROOT) else out_path} "
        f"({len(lines)} lines)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
