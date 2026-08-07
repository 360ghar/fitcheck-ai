"""Tests for WeatherService and WeatherOutfitRecommender.

Every HTTP interaction goes through httpx.MockTransport (patched onto
httpx.AsyncClient) - the suite's autouse fixture blocks all real network
access, so no test here ever touches api.openweathermap.org.
"""

from datetime import datetime, timezone

import httpx
import pytest

from app.core.exceptions import WeatherServiceError
from app.services.weather_service import (
    WeatherCondition,
    WeatherOutfitRecommender,
    WeatherService,
    get_weather_service,
)


def _patch_async_client(monkeypatch, handler):
    """Replace httpx.AsyncClient with one wired to a MockTransport handler."""
    original = httpx.AsyncClient

    def factory(*args, **kwargs):
        return original(transport=httpx.MockTransport(handler), **kwargs)

    monkeypatch.setattr(httpx, "AsyncClient", factory)


def _service_with_key(api_key: str = "test-key") -> WeatherService:
    service = WeatherService()
    service.api_key = api_key
    return service


def _weather_json(*, temp=72.0, feels_like=70.0, humidity=60, condition="Clear",
                  description="clear sky", wind_speed=3.5, name="Testville"):
    return {
        "main": {"temp": temp, "feels_like": feels_like, "humidity": humidity},
        "weather": [{"main": condition, "description": description}],
        "wind": {"speed": wind_speed},
        "name": name,
    }


# ---------------------------------------------------------------------------
# Existing tests (kept from the original file)
# ---------------------------------------------------------------------------


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


# ---------------------------------------------------------------------------
# _parse_coordinates / _looks_like_zip
# ---------------------------------------------------------------------------


class TestParseCoordinates:
    @pytest.mark.parametrize("location", [
        None,
        "",
        "New York",        # no comma
        "1,2,3",           # wrong part count
        "abc,def",         # not numbers
        "91,0",            # lat out of range
        "0,181",           # lon out of range
        "-90.1,0",         # lat just out of range
    ])
    def test_rejects_invalid_locations(self, location):
        assert WeatherService._parse_coordinates(location) is None

    def test_parses_valid_coordinates(self):
        assert WeatherService._parse_coordinates("28.4455, 77.0081") == (28.4455, 77.0081)
        assert WeatherService._parse_coordinates("90,180") == (90.0, 180.0)
        assert WeatherService._parse_coordinates("-90,-180") == (-90.0, -180.0)


class TestLooksLikeZip:
    @pytest.mark.parametrize("location,expected", [
        (None, False),
        ("", False),
        ("94040", True),
        ("94040,us", True),
        ("94040, US", True),
        ("1234567890,de", True),
        ("New York", False),
        ("12ab", False),
        ("123", False),  # too short
        ("94040,usa", False),  # country code too long
    ])
    def test_zip_detection(self, location, expected):
        assert WeatherService._looks_like_zip(location) is expected


# ---------------------------------------------------------------------------
# get_weather / get_weather_by_coordinates / get_forecast error paths
# ---------------------------------------------------------------------------


class TestMissingApiKey:
    @pytest.mark.asyncio
    async def test_all_public_methods_fail_closed_without_key(self):
        service = _service_with_key(api_key=None)

        with pytest.raises(WeatherServiceError, match="API key not configured"):
            await service.get_weather("London")
        with pytest.raises(WeatherServiceError, match="API key not configured"):
            await service.get_weather_by_coordinates(51.5, -0.12)
        with pytest.raises(WeatherServiceError, match="API key not configured"):
            await service.get_forecast("London")


class TestGetWeatherErrors:
    @pytest.mark.asyncio
    async def test_http_error_includes_api_detail_message(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(404, json={"message": "city not found"}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="city not found"):
            await service.get_weather("Nowhere")

    @pytest.mark.asyncio
    async def test_http_error_with_non_json_body_uses_status_code_only(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(503, text="temporarily unavailable", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Weather API error: 503"):
            await service.get_weather("Nowhere")

    @pytest.mark.asyncio
    async def test_transport_error_is_wrapped(self, monkeypatch):
        service = _service_with_key()

        async def handler(request):
            raise httpx.ConnectError("offline", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Failed to fetch weather"):
            await service.get_weather("London")


class TestGetWeatherByCoordinatesErrors:
    @pytest.mark.asyncio
    async def test_http_error_includes_api_detail_message(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(400, json={"message": "bad lat"}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="bad lat"):
            await service.get_weather_by_coordinates(999.0, 0.0)

    @pytest.mark.asyncio
    async def test_http_error_without_detail_uses_status_code(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(500, text="boom", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Weather API error: 500"):
            await service.get_weather_by_coordinates(51.5, -0.12)

    @pytest.mark.asyncio
    async def test_transport_error_is_wrapped(self, monkeypatch):
        service = _service_with_key()

        async def handler(request):
            raise httpx.ConnectTimeout("slow", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Failed to fetch weather"):
            await service.get_weather_by_coordinates(51.5, -0.12)


class TestGetForecastErrors:
    @pytest.mark.asyncio
    async def test_http_error_includes_api_detail_message(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(401, json={"message": "invalid key"}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="invalid key"):
            await service.get_forecast("London")

    @pytest.mark.asyncio
    async def test_http_error_without_detail_uses_status_code(self, monkeypatch):
        service = _service_with_key()

        def handler(request):
            return httpx.Response(429, text="rate limited", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Forecast API error: 429"):
            await service.get_forecast("London")

    @pytest.mark.asyncio
    async def test_transport_error_is_wrapped(self, monkeypatch):
        service = _service_with_key()

        async def handler(request):
            raise httpx.ConnectError("offline", request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(WeatherServiceError, match="Failed to fetch forecast"):
            await service.get_forecast("London")


# ---------------------------------------------------------------------------
# get_forecast request shaping / day clamping
# ---------------------------------------------------------------------------


class TestGetForecastRequests:
    @pytest.mark.asyncio
    async def test_city_name_uses_q_param(self, monkeypatch):
        calls: list[httpx.Request] = []

        def handler(request):
            calls.append(request)
            return httpx.Response(200, json={"list": []}, request=request)

        _patch_async_client(monkeypatch, handler)

        forecast = await _service_with_key().get_forecast("New York", units="metric")

        assert forecast == []
        assert len(calls) == 1
        assert calls[0].url.params["q"] == "New York"
        assert "lat" not in calls[0].url.params
        assert calls[0].url.params["units"] == "metric"

    @pytest.mark.asyncio
    async def test_explicit_lat_lon_used_over_location(self, monkeypatch):
        calls: list[httpx.Request] = []

        def handler(request):
            calls.append(request)
            return httpx.Response(200, json={"list": []}, request=request)

        _patch_async_client(monkeypatch, handler)

        await _service_with_key().get_forecast("Somewhere", lat=10.5, lon=20.5)

        assert calls[0].url.params["lat"] == "10.5"
        assert calls[0].url.params["lon"] == "20.5"
        assert "q" not in calls[0].url.params

    @pytest.mark.asyncio
    async def test_days_are_capped_between_one_and_five(self, monkeypatch):
        entries = []
        for day_offset in range(6):
            dt = int(datetime(2026, 1, 1 + day_offset, 12, tzinfo=timezone.utc).timestamp())
            entries.append({"dt": dt, "main": {"temp": 60}, "weather": [{"main": "Clear"}], "pop": 0.0})

        def handler(request):
            return httpx.Response(200, json={"list": entries}, request=request)

        _patch_async_client(monkeypatch, handler)

        service = _service_with_key()
        assert len(await service.get_forecast("X", days=10)) == 5
        assert len(await service.get_forecast("X", days=0)) == 1


# ---------------------------------------------------------------------------
# response parsing
# ---------------------------------------------------------------------------


class TestParseWeatherResponse:
    def test_standardizes_fields(self):
        parsed = _service_with_key()._parse_weather_response(
            _weather_json(temp=72.0, feels_like=70.5, humidity=61, condition="Rain",
                          description="light rain", wind_speed=4.2, name="Mumbai")
        )

        assert parsed["temperature"] == 72.0
        assert parsed["feels_like"] == 70.5
        assert parsed["humidity"] == 61
        assert parsed["condition"] == "rain"
        assert parsed["description"] == "light rain"
        assert parsed["wind_speed"] == 4.2
        assert parsed["location"] == "Mumbai"
        assert parsed["temp_category"] == WeatherCondition.WARM
        assert parsed["weather_state"] == WeatherCondition.RAINY
        assert parsed["fetched_at"]

    def test_defaults_when_fields_missing(self):
        parsed = _service_with_key()._parse_weather_response({})

        assert parsed["temperature"] == 70
        assert parsed["feels_like"] == 70
        assert parsed["humidity"] == 50
        assert parsed["condition"] == ""
        assert parsed["description"] == ""
        assert parsed["wind_speed"] == 0
        assert parsed["location"] == "Unknown"
        assert parsed["temp_category"] == WeatherCondition.WARM
        assert parsed["weather_state"] == WeatherCondition.CLOUDY


class TestTempCategory:
    @pytest.mark.parametrize("temp,expected", [
        (90, WeatherCondition.HOT),
        (85, WeatherCondition.HOT),
        (80, WeatherCondition.WARM),
        (70, WeatherCondition.WARM),
        (60, WeatherCondition.MILD),
        (55, WeatherCondition.MILD),
        (45, WeatherCondition.COOL),
        (40, WeatherCondition.COOL),
        (35, WeatherCondition.COLD),
        (32, WeatherCondition.COLD),
        (31, WeatherCondition.FREEZING),
        (-5, WeatherCondition.FREEZING),
    ])
    def test_categories(self, temp, expected):
        assert WeatherService()._get_temp_category(temp) == expected


class TestWeatherState:
    @pytest.mark.parametrize("condition,temp,expected", [
        ("Rain", 70, WeatherCondition.RAINY),
        ("drizzle", 60, WeatherCondition.RAINY),
        ("Snow", 30, WeatherCondition.SNOWY),
        ("sleet", 30, WeatherCondition.SNOWY),
        ("Clear", 80, WeatherCondition.SUNNY),
        ("Clouds", 70, WeatherCondition.CLOUDY),
        ("Storm", 70, WeatherCondition.STORMY),
        ("Thunderstorm", 70, WeatherCondition.STORMY),
        ("Windy", 30, WeatherCondition.WINDY),
        ("Windy", 70, WeatherCondition.CLOUDY),  # warm wind falls back to cloudy
        ("Haze", 60, WeatherCondition.CLOUDY),
    ])
    def test_states(self, condition, temp, expected):
        assert WeatherService()._get_weather_state(condition, temp) == expected


class TestParseForecastResponse:
    def test_groups_entries_by_day_and_computes_summary(self):
        day1 = int(datetime(2026, 1, 1, 12, tzinfo=timezone.utc).timestamp())
        day2 = int(datetime(2026, 1, 2, 12, tzinfo=timezone.utc).timestamp())
        data = {
            "list": [
                {"dt": day1, "main": {"temp": 60}, "weather": [{"main": "Clouds", "description": "cloudy"}], "pop": 0.2},
                {"dt": day1, "main": {"temp": 70}, "weather": [{"main": "Rain", "description": "rain"}], "pop": 0.8},
                # Non-numeric temp/pop and empty weather must be skipped, not crash.
                {"dt": day1, "main": {"temp": "n/a"}, "weather": [], "pop": "high"},
                # Description-only condition (no "main" key) must be used.
                {"dt": day2, "main": {"temp": 50}, "weather": [{"description": "clear sky"}], "pop": 0.1},
                {"no_dt": True},  # entry without dt is skipped
            ]
        }

        results = WeatherService()._parse_forecast_response(data, days=5)

        assert [r["date"] for r in results] == ["2026-01-01", "2026-01-02"]
        first = results[0]
        assert first["temperature"] == {"high": 70, "low": 60}
        assert first["condition"] == "clouds"
        assert first["precipitation_chance"] == 80
        second = results[1]
        assert second["temperature"] == {"high": 50, "low": 50}
        assert second["condition"] == "clear sky"
        assert second["precipitation_chance"] == 10

    def test_days_limit_truncates_sorted_days(self):
        day1 = int(datetime(2026, 1, 2, 12, tzinfo=timezone.utc).timestamp())
        day2 = int(datetime(2026, 1, 1, 12, tzinfo=timezone.utc).timestamp())
        data = {"list": [
            {"dt": day1, "main": {"temp": 60}, "weather": [{"main": "Clear"}], "pop": 0.0},
            {"dt": day2, "main": {"temp": 50}, "weather": [{"main": "Clear"}], "pop": 0.0},
        ]}

        results = WeatherService()._parse_forecast_response(data, days=1)

        assert [r["date"] for r in results] == ["2026-01-01"]

    def test_missing_numeric_values_fall_back_to_zeros(self):
        day = int(datetime(2026, 1, 1, 12, tzinfo=timezone.utc).timestamp())
        data = {"list": [{"dt": day, "main": {}, "weather": [], "pop": "none"}]}

        results = WeatherService()._parse_forecast_response(data, days=1)

        assert results[0]["temperature"] == {"high": 0.0, "low": 0.0}
        assert results[0]["condition"] == "unknown"
        assert results[0]["precipitation_chance"] == 0

    def test_precipitation_chance_is_clamped_to_100(self):
        day = int(datetime(2026, 1, 1, 12, tzinfo=timezone.utc).timestamp())
        data = {"list": [{"dt": day, "main": {"temp": 60}, "weather": [{"main": "Rain"}], "pop": 2.0}]}

        results = WeatherService()._parse_forecast_response(data, days=1)

        assert results[0]["precipitation_chance"] == 100

    def test_empty_list_returns_empty(self):
        assert WeatherService()._parse_forecast_response({"list": []}, days=3) == []


# ---------------------------------------------------------------------------
# WeatherOutfitRecommender
# ---------------------------------------------------------------------------


class TestGetRecommendations:
    @pytest.mark.parametrize("category,layers", [
        (WeatherCondition.HOT, 1),
        (WeatherCondition.WARM, 1),
        (WeatherCondition.MILD, 2),
        (WeatherCondition.COOL, 2),
        (WeatherCondition.COLD, 3),
        (WeatherCondition.FREEZING, 4),
    ])
    def test_temp_category_recommendations(self, category, layers):
        rec = WeatherOutfitRecommender.get_recommendations({
            "temperature": 60,
            "temp_category": category,
            "weather_state": WeatherCondition.SUNNY,
        })

        assert rec["temp_category"] == category
        assert rec["suggested_layers"] == layers
        assert rec["preferred_categories"]
        assert rec["notes"][0]
        assert rec["color_suggestions"] == ["Any colors work well", "Light colors reflect heat"]

    @pytest.mark.parametrize("state,expected_items", [
        (WeatherCondition.RAINY, ["raincoat", "umbrella", "waterproof shoes", "boots"]),
        (WeatherCondition.SNOWY, ["waterproof boots", "heavy coat", "gloves", "hat", "scarf"]),
        (WeatherCondition.WINDY, ["windbreaker", "close-fitting clothes"]),
        (WeatherCondition.STORMY, ["raincoat", "umbrella", "waterproof boots"]),
    ])
    def test_weather_state_recommendations(self, state, expected_items):
        rec = WeatherOutfitRecommender.get_recommendations({
            "temperature": 60,
            "temp_category": WeatherCondition.MILD,
            "weather_state": state,
        })

        assert rec["additional_items"] == expected_items
        assert rec["items_to_avoid"]
        assert rec["notes"][1]

    def test_unknown_category_and_state_fall_back_to_defaults(self):
        rec = WeatherOutfitRecommender.get_recommendations({
            "temperature": 60,
            "temp_category": "tropical",
            "weather_state": "monsoon",
        })

        assert rec["temp_category"] == "tropical"
        assert rec["weather_state"] == "monsoon"
        assert rec["suggested_layers"] == 2  # MILD fallback
        assert rec["additional_items"] == []  # no weather rec for unknown state
        assert rec["items_to_avoid"] == []
        assert rec["color_suggestions"] == ["Earth tones for cloudy days"]

    def test_missing_fields_use_defaults(self):
        rec = WeatherOutfitRecommender.get_recommendations({})

        assert rec["temp_category"] == WeatherCondition.MILD
        assert rec["weather_state"] == WeatherCondition.SUNNY
        assert rec["temperature"] is None
        assert rec["suggested_layers"] == 2


class TestColorSuggestions:
    @pytest.mark.parametrize("state,expected", [
        (WeatherCondition.RAINY, ["Dark colors to hide rain spots", "Bright colors for visibility"]),
        (WeatherCondition.SNOWY, ["Bright colors to stand out against snow", "Red for visibility"]),
        (WeatherCondition.SUNNY, ["Any colors work well", "Light colors reflect heat"]),
        (WeatherCondition.CLOUDY, ["Earth tones for cloudy days"]),
        ("mystery", ["Earth tones for cloudy days"]),
    ])
    def test_color_suggestions(self, state, expected):
        assert WeatherOutfitRecommender._get_color_suggestions(state) == expected


# ---------------------------------------------------------------------------
# singleton factory
# ---------------------------------------------------------------------------


def test_get_weather_service_returns_singleton(monkeypatch):
    import app.services.weather_service as module

    monkeypatch.setattr(module, "_weather_service", None)

    service = get_weather_service()

    assert isinstance(service, WeatherService)
    assert get_weather_service() is service
