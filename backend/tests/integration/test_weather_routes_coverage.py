"""
Route-level coverage for app/api/v1/weather.py.

Complements tests/unit/test_services/test_weather_service.py (service-level):
these drive the two endpoints directly with a stubbed weather service, plus
the module helpers (_parse_location / _resolve_location) that the endpoints
branch on. No real HTTP ever happens: the OpenWeather client is never
constructed because get_weather_service() is stubbed per test.
"""
from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1 import weather as weather_api
from app.core.exceptions import WeatherServiceError
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"


class _FakeWeatherService:
    """Stand-in for WeatherService with per-test AsyncMock methods."""

    def __init__(self):
        self.get_weather = AsyncMock()
        self.get_weather_by_coordinates = AsyncMock()
        self.get_forecast = AsyncMock()


def _patch_service(monkeypatch, service):
    monkeypatch.setattr(weather_api, "get_weather_service", lambda: service)
    return service


# ---------------------------------------------------------------------------
# _parse_location
# ---------------------------------------------------------------------------


@pytest.mark.parametrize(
    ("location", "expected"),
    [
        ("12.3,45.6", (12.3, 45.6, None)),
        (" 10 , 20 ", (10.0, 20.0, None)),
        ("-33.86,151.2", (-33.86, 151.2, None)),
        ("abc,def", (None, None, "abc,def")),
        ("Pune", (None, None, "Pune")),
        ("1,2,3", (None, None, "1,2,3")),
        ("", (None, None, "")),
    ],
)
def test_parse_location_handles_all_supported_formats(location, expected):
    assert weather_api._parse_location(location) == expected


# ---------------------------------------------------------------------------
# _resolve_location
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_resolve_location_prefers_the_query_param():
    assert (
        await weather_api._resolve_location(FakeDB(), USER_ID, location="Berlin") == "Berlin"
    )


@pytest.mark.asyncio
async def test_resolve_location_reads_the_user_settings_default():
    db = FakeDB(
        {
            "user_settings": [
                {"user_id": USER_ID, "default_location": "Pune", "updated_at": "2026-01-01"}
            ]
        }
    )
    assert await weather_api._resolve_location(db, USER_ID, None) == "Pune"


@pytest.mark.asyncio
async def test_resolve_location_falls_back_to_new_york_when_no_settings_row():
    assert await weather_api._resolve_location(FakeDB({"user_settings": []}), USER_ID, None) == "New York"


@pytest.mark.asyncio
async def test_resolve_location_falls_back_when_settings_read_fails():
    db = Mock()
    db.table.side_effect = RuntimeError("boom")
    assert await weather_api._resolve_location(db, USER_ID, None) == "New York"


# ---------------------------------------------------------------------------
# GET /weather (current conditions, Celsius)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_current_weather_by_city_name_converts_to_celsius(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather.return_value = {
        "temperature": 95.0,
        "condition": "Clear",
        "humidity": 40,
        "wind_speed": 10.0,
        "feels_like": 90.0,
        "location": "Pune",
    }

    result = await weather_api.get_current_weather(
        location="Pune", user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "OK"
    assert result["data"]["temperature"] == 35.0  # (95 - 32) * 5 / 9
    assert result["data"]["feels_like"] == 32.2  # (90 - 32) * 5 / 9, rounded
    assert result["data"]["location"] == "Pune"
    service.get_weather.assert_awaited_once_with(location="Pune", units="imperial")


@pytest.mark.asyncio
async def test_get_current_weather_by_coordinates(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather_by_coordinates.return_value = {
        "temperature": 50.0,
        "condition": "Clouds",
        "humidity": 60,
        "wind_speed": 5.0,
        "feels_like": 48.0,
        "location": "12.3,45.6",
    }

    result = await weather_api.get_current_weather(
        location="12.3,45.6", user_id=USER_ID, db=FakeDB()
    )

    assert result["data"]["temperature"] == 10.0
    service.get_weather_by_coordinates.assert_awaited_once_with(
        lat=12.3, lon=45.6, units="imperial"
    )
    service.get_weather.assert_not_called()


@pytest.mark.asyncio
async def test_get_current_weather_uses_defaults_for_missing_fields(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather.return_value = {"temperature": 80.0}

    result = await weather_api.get_current_weather(
        location="Pune", user_id=USER_ID, db=FakeDB()
    )

    # feels_like falls back to temperature; missing fields become defaults.
    assert result["data"]["feels_like"] == 26.7
    assert result["data"]["condition"] == ""
    assert result["data"]["humidity"] == 0
    assert result["data"]["location"] == "Pune"


@pytest.mark.asyncio
async def test_get_current_weather_empty_payload_is_a_service_error(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather.return_value = None

    with pytest.raises(WeatherServiceError, match="temporarily unavailable"):
        await weather_api.get_current_weather(location="Pune", user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_get_current_weather_propagates_service_error(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather.side_effect = WeatherServiceError("upstream said no")

    with pytest.raises(WeatherServiceError, match="upstream said no"):
        await weather_api.get_current_weather(location="Pune", user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_get_current_weather_wraps_unexpected_failures(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_weather.side_effect = ValueError("bad payload")

    with pytest.raises(WeatherServiceError, match="temporarily unavailable"):
        await weather_api.get_current_weather(location="Pune", user_id=USER_ID, db=FakeDB())


# ---------------------------------------------------------------------------
# GET /weather/forecast
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_weather_forecast_converts_temperatures(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_forecast.return_value = [
        {
            "date": "2026-01-01",
            "temperature": {"high": 90.0, "low": 70.0},
            "condition": "Clear",
            "precipitation_chance": 10,
        },
        {
            "date": "2026-01-02",
            "temperature": {},
            "condition": "Rain",
            "precipitation_chance": 50,
        },
    ]

    result = await weather_api.get_weather_forecast(
        location="Pune", days=3, user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "OK"
    days = result["data"]["forecast"]
    assert days[0]["temperature"] == {"high": 32.2, "low": 21.1}
    # A day without high/low keys passes through untouched.
    assert days[1]["temperature"] == {}
    service.get_forecast.assert_awaited_once_with(
        location="Pune", lat=None, lon=None, units="imperial", days=3
    )


@pytest.mark.asyncio
async def test_get_weather_forecast_parses_coordinates(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_forecast.return_value = []

    result = await weather_api.get_weather_forecast(
        location="12.3,45.6", days=5, user_id=USER_ID, db=FakeDB()
    )

    assert result["data"]["forecast"] == []
    service.get_forecast.assert_awaited_once_with(
        location="12.3,45.6", lat=12.3, lon=45.6, units="imperial", days=5
    )


@pytest.mark.asyncio
async def test_get_weather_forecast_propagates_service_error(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_forecast.side_effect = WeatherServiceError("forecast unavailable")

    with pytest.raises(WeatherServiceError, match="forecast unavailable"):
        await weather_api.get_weather_forecast(
            location="Pune", days=3, user_id=USER_ID, db=FakeDB()
        )


@pytest.mark.asyncio
async def test_get_weather_forecast_wraps_unexpected_failures(monkeypatch):
    service = _patch_service(monkeypatch, _FakeWeatherService())
    service.get_forecast.side_effect = KeyError("temps")

    with pytest.raises(WeatherServiceError, match="temporarily unavailable"):
        await weather_api.get_weather_forecast(
            location="Pune", days=3, user_id=USER_ID, db=FakeDB()
        )
