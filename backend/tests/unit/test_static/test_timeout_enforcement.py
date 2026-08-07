"""
Regression: external HTTP calls must configure explicit timeouts.

A missing timeout lets a hung upstream keep a request (and an event-loop
worker) blocked indefinitely. These tests assert that the httpx clients our
services build always carry a timeout, both behaviorally (spy clients) and
structurally (no bare ``httpx.AsyncClient()`` anywhere in app code).
"""

import importlib
import inspect
import pkgutil

import pytest

from app.services import weather_service


class _FakeWeatherResponse:
    status_code = 200
    text = "{}"

    def json(self):
        return {
            "main": {"temp": 70, "feels_like": 70, "humidity": 50},
            "weather": [{"main": "Clear", "description": "clear sky"}],
            "wind": {"speed": 3},
            "name": "London",
        }


def _assert_has_timeout(client) -> None:
    """A client is compliant if it was built with a timeout OR every request
    it issued carried one."""
    client_timeout = getattr(client, "client_timeout", None)
    request_timeouts = getattr(client, "request_timeouts", [])
    assert client_timeout is not None or (
        request_timeouts and all(t is not None for t in request_timeouts)
    ), "httpx client made a call without any timeout configured"


@pytest.mark.asyncio
async def test_weather_get_weather_carries_timeout(monkeypatch):
    created = []

    class _SpyClient:
        def __init__(self, *args, **kwargs):
            self.client_timeout = kwargs.get("timeout")
            self.request_timeouts = []
            created.append(self)

        async def __aenter__(self):
            return self

        async def __aexit__(self, *exc):
            return False

        async def get(self, url, **kwargs):
            self.request_timeouts.append(kwargs.get("timeout"))
            return _FakeWeatherResponse()

    monkeypatch.setattr(weather_service.httpx, "AsyncClient", _SpyClient)

    service = weather_service.WeatherService()
    service.api_key = "test-key"

    result = await service.get_weather("London")

    assert created, "expected an httpx client to be created"
    assert result["location"] == "London"
    for client in created:
        _assert_has_timeout(client)


@pytest.mark.asyncio
async def test_weather_get_forecast_carries_timeout(monkeypatch):
    created = []

    class _SpyClient:
        def __init__(self, *args, **kwargs):
            self.client_timeout = kwargs.get("timeout")
            self.request_timeouts = []
            created.append(self)

        async def __aenter__(self):
            return self

        async def __aexit__(self, *exc):
            return False

        async def get(self, url, **kwargs):
            self.request_timeouts.append(kwargs.get("timeout"))
            return _FakeWeatherResponse()

    monkeypatch.setattr(weather_service.httpx, "AsyncClient", _SpyClient)

    service = weather_service.WeatherService()
    service.api_key = "test-key"

    await service.get_forecast("London", days=3)

    assert created, "expected an httpx client to be created"
    for client in created:
        _assert_has_timeout(client)


@pytest.mark.asyncio
async def test_social_oauth_token_exchange_carries_timeout(monkeypatch):
    from app.services import social_oauth_service as sos

    monkeypatch.setattr(sos.settings, "META_OAUTH_CLIENT_ID", "client-id")
    monkeypatch.setattr(sos.settings, "META_OAUTH_CLIENT_SECRET", "client-secret")

    created = []

    class _OAuthResponse:
        status_code = 200
        is_success = True
        text = "{}"

        def json(self):
            return {"access_token": "tok", "expires_in": 3600}

    class _SpyClient:
        def __init__(self, *args, **kwargs):
            self.client_timeout = kwargs.get("timeout")
            self.request_timeouts = []
            created.append(self)

        async def __aenter__(self):
            return self

        async def __aexit__(self, *exc):
            return False

        async def get(self, url, **kwargs):
            self.request_timeouts.append(kwargs.get("timeout"))
            return _OAuthResponse()

    monkeypatch.setattr(sos.httpx, "AsyncClient", _SpyClient)

    result = await sos.SocialOAuthService.exchange_code_for_token(
        code="auth-code",
        redirect_uri="https://example.com/callback",
    )

    assert result["provider_access_token"] == "tok"
    assert created, "expected an httpx client to be created"
    for client in created:
        _assert_has_timeout(client)


def test_no_bare_timeoutless_httpx_clients_in_app_code():
    """Structural guard: no ``httpx.AsyncClient()`` with zero arguments.

    Every AsyncClient construction in services and routes must pass a timeout
    (or a Timeout object) so a hung upstream cannot block forever.
    """
    import app.api.v1 as routes_pkg
    from app import services as services_pkg

    offenders = []
    for pkg in (services_pkg, routes_pkg):
        for mod_info in pkgutil.iter_modules(pkg.__path__):
            module = importlib.import_module(f"{pkg.__name__}.{mod_info.name}")
            try:
                source = inspect.getsource(module)
            except (OSError, TypeError):
                continue
            if "httpx.AsyncClient()" in source:
                offenders.append(module.__name__)

    assert not offenders, (
        "Bare httpx.AsyncClient() (no timeout) found in: " + ", ".join(offenders)
    )
