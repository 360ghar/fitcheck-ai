"""The catch-all 500 handler must echo CORS headers for allowed origins.

A handler registered for ``Exception`` runs on ServerErrorMiddleware, which
sits OUTSIDE CORSMiddleware: without the explicit echo, a genuine 500 reaches
the browser without CORS headers, the browser itself blocks it, and axios
reports a network failure ("Connection Error") instead of a server error
carrying the correlation ID (2026-08-31 check-duplicates RCA).

The probe route is inserted before app.main's trailing MCP mount (same
technique as test_sentry_unhandled_capture.py); httpx's ASGITransport is
in-process only, so the repo-wide socket-blocking guard stays satisfied.
"""

import pytest
from httpx import ASGITransport, AsyncClient
from starlette.routing import Route

from app.main import app

pytestmark = pytest.mark.asyncio

PROBE_PATH = "/__test_boom_cors"


@pytest.fixture()
def probe_route():
    async def _boom(request):
        raise ValueError("boom-500-cors")

    route = Route(PROBE_PATH, _boom, methods=["GET"])
    app.router.routes.insert(-1, route)
    yield PROBE_PATH
    app.router.routes.remove(route)


async def _get_500(path: str, origin=None):
    headers = {"Origin": origin} if origin else {}
    async with AsyncClient(
        transport=ASGITransport(app=app, raise_app_exceptions=False),
        base_url="http://testserver",
    ) as client:
        return await client.get(path, headers=headers)


async def test_first_party_origin_gets_cors_headers_on_500(probe_route):
    response = await _get_500(probe_route, origin="https://fitcheckaiapp.com")

    assert response.status_code == 500
    assert response.headers["access-control-allow-origin"] == "https://fitcheckaiapp.com"
    assert response.headers["access-control-allow-credentials"] == "true"


async def test_regex_matched_origin_gets_cors_headers_on_500(probe_route):
    response = await _get_500(probe_route, origin="https://preview.netlify.app")

    assert response.status_code == 500
    assert response.headers["access-control-allow-origin"] == "https://preview.netlify.app"


async def test_regex_near_miss_origin_gets_no_cors_headers_on_500(probe_route):
    # fullmatch parity with CORSMiddleware: a regex matched with re.match
    # would allow this host ("preview.netlify.app" is a PREFIX of it).
    response = await _get_500(probe_route, origin="https://preview.netlify.app.evil.io")

    assert response.status_code == 500
    assert "access-control-allow-origin" not in response.headers


async def test_foreign_origin_gets_no_cors_headers_on_500(probe_route):
    response = await _get_500(probe_route, origin="https://evil.example.com")

    assert response.status_code == 500
    assert "access-control-allow-origin" not in response.headers


async def test_request_without_origin_gets_no_cors_headers_on_500(probe_route):
    response = await _get_500(probe_route)

    assert response.status_code == 500
    assert "access-control-allow-origin" not in response.headers
