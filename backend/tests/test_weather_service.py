import httpx
import pytest

from app.services.weather_service import WeatherService


@pytest.mark.asyncio
async def test_get_weather_parses_lat_lon_string(monkeypatch):
    service = WeatherService()
    service.api_key = "test-key"

    calls: list[dict] = []

    async def mock_get(self, url, params=None, timeout=None):  # noqa: ANN001
        calls.append({"url": str(url), "params": params})
        return httpx.Response(
            200,
            json={
                "main": {"temp": 72, "feels_like": 70, "humidity": 60},
                "weather": [{"main": "Clear", "description": "clear sky"}],
                "wind": {"speed": 3.5},
                "name": "Testville",
            },
        )

    monkeypatch.setattr(httpx.AsyncClient, "get", mock_get, raising=True)

    weather = await service.get_weather("28.4455,77.0081", units="imperial")

    assert weather["temperature"] == 72
    assert len(calls) == 1
    assert calls[0]["url"].endswith("/weather")
    assert "q" not in calls[0]["params"]
    assert calls[0]["params"]["lat"] == 28.4455
    assert calls[0]["params"]["lon"] == 77.0081


@pytest.mark.asyncio
async def test_get_weather_uses_q_for_city(monkeypatch):
    service = WeatherService()
    service.api_key = "test-key"

    calls: list[dict] = []

    async def mock_get(self, url, params=None, timeout=None):  # noqa: ANN001
        calls.append({"url": str(url), "params": params})
        return httpx.Response(
            200,
            json={
                "main": {"temp": 65, "feels_like": 64, "humidity": 55},
                "weather": [{"main": "Clouds", "description": "scattered clouds"}],
                "wind": {"speed": 2.0},
                "name": "New York",
            },
        )

    monkeypatch.setattr(httpx.AsyncClient, "get", mock_get, raising=True)

    weather = await service.get_weather("New York", units="imperial")

    assert weather["location"] == "New York"
    assert len(calls) == 1
    assert calls[0]["url"].endswith("/weather")
    assert calls[0]["params"]["q"] == "New York"
    assert "zip" not in calls[0]["params"]


@pytest.mark.asyncio
async def test_get_weather_uses_zip_param(monkeypatch):
    service = WeatherService()
    service.api_key = "test-key"

    calls: list[dict] = []

    async def mock_get(self, url, params=None, timeout=None):  # noqa: ANN001
        calls.append({"url": str(url), "params": params})
        return httpx.Response(
            200,
            json={
                "main": {"temp": 55, "feels_like": 54, "humidity": 40},
                "weather": [{"main": "Clear", "description": "clear"}],
                "wind": {"speed": 1.0},
                "name": "Zipville",
            },
        )

    monkeypatch.setattr(httpx.AsyncClient, "get", mock_get, raising=True)

    await service.get_weather("94040,us", units="imperial")

    assert len(calls) == 1
    assert calls[0]["url"].endswith("/weather")
    assert calls[0]["params"]["zip"] == "94040,us"
    assert "q" not in calls[0]["params"]


@pytest.mark.asyncio
async def test_get_forecast_parses_lat_lon_string(monkeypatch):
    service = WeatherService()
    service.api_key = "test-key"

    calls: list[dict] = []

    async def mock_get(self, url, params=None, timeout=None):  # noqa: ANN001
        calls.append({"url": str(url), "params": params})
        return httpx.Response(200, json={"list": []})

    monkeypatch.setattr(httpx.AsyncClient, "get", mock_get, raising=True)

    forecast = await service.get_forecast("28.4455,77.0081", units="imperial", days=3)

    assert forecast == []
    assert len(calls) == 1
    assert calls[0]["url"].endswith("/forecast")
    assert "q" not in calls[0]["params"]
    assert calls[0]["params"]["lat"] == 28.4455
    assert calls[0]["params"]["lon"] == 77.0081
