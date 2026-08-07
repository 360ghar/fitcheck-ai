"""Coverage-completing tests for AstrologyService.

Sibling to test_astrology_service.py: this file covers the remaining
branches — birth-timezone resolution (missing place, success, swallowed
errors), user_local_today, the geocoding TTL cache (hit, expiry, miss, set),
the real HTTP geocoding path (success, empty results, missing timezone,
non-dict JSON), the sidereal computation (real swisseph, houses_ex fallback,
missing-library), color scoring without a ruling planet, no-color and
non-core-category item scoring, suggested-outfit id-less items, color-name
normalization edges, timezone fallbacks, and the sidereal window fallback.
"""
import sys
import time
from datetime import datetime, timezone
from types import SimpleNamespace
from zoneinfo import ZoneInfo

import httpx
import pytest

from app.services import astrology_service as astrology_module
from app.services.astrology_service import AstrologyService

_ZODIAC = {
    "Aries",
    "Taurus",
    "Gemini",
    "Cancer",
    "Leo",
    "Virgo",
    "Libra",
    "Scorpio",
    "Sagittarius",
    "Capricorn",
    "Aquarius",
    "Pisces",
}


class _FakeHttpResponse:
    """Minimal httpx.Response stand-in: canned json, optional raise."""

    def __init__(self, json_value, error=None):
        self._json_value = json_value
        self._error = error

    def raise_for_status(self):
        if self._error is not None:
            raise self._error

    def json(self):
        return self._json_value


class _FakeAsyncClient:
    """httpx.AsyncClient stand-in whose async context manager yields itself."""

    def __init__(self, response):
        self.response = response

    async def __aenter__(self):
        return self

    async def __aexit__(self, *exc_info):
        return False

    async def get(self, *args, **kwargs):
        return self.response


def _patch_geocoding(monkeypatch, response):
    monkeypatch.setattr(astrology_module, "_GEOCODING_CACHE", {})
    monkeypatch.setattr(
        httpx, "AsyncClient", lambda *args, **kwargs: _FakeAsyncClient(response)
    )


# =============================================================================
# Birth timezone resolution
# =============================================================================


@pytest.mark.asyncio
async def test_resolve_birth_timezone_returns_none_without_place():
    service = AstrologyService()
    assert await service.resolve_birth_timezone(None) is None
    assert await service.resolve_birth_timezone("") is None


@pytest.mark.asyncio
async def test_resolve_birth_timezone_returns_resolved_zone(monkeypatch):
    service = AstrologyService()

    async def _resolve(_place):
        return {"timezone": "Asia/Kolkata"}

    monkeypatch.setattr(service, "_resolve_birth_place", _resolve)

    assert await service.resolve_birth_timezone("New Delhi") == "Asia/Kolkata"


@pytest.mark.asyncio
async def test_resolve_birth_timezone_swallows_resolution_errors(monkeypatch):
    service = AstrologyService()

    async def _resolve(_place):
        raise ValueError("geocoding failed")

    monkeypatch.setattr(service, "_resolve_birth_place", _resolve)

    assert await service.resolve_birth_timezone("Nowhere") is None


# =============================================================================
# Local date and geocoding cache
# =============================================================================


def test_user_local_today_resolves_timezone_and_defaults_to_utc():
    service = AstrologyService()
    assert service.user_local_today(None) == datetime.now(timezone.utc).date()
    assert service.user_local_today("UTC") == datetime.now(timezone.utc).date()
    ny = ZoneInfo("America/New_York")
    assert service.user_local_today("America/New_York") == datetime.now(ny).date()


def test_get_cached_geocode_miss_hit_and_expiry(monkeypatch):
    monkeypatch.setattr(astrology_module, "_GEOCODING_CACHE", {})
    service = AstrologyService()

    assert service._get_cached_geocode("Delhi") is None

    data = {"timezone": "Asia/Kolkata"}
    astrology_module._GEOCODING_CACHE["delhi"] = (data, time.time())
    assert service._get_cached_geocode("Delhi") is data

    astrology_module._GEOCODING_CACHE["delhi"] = (data, time.time() - 7200)
    assert service._get_cached_geocode("Delhi") is None
    assert "delhi" not in astrology_module._GEOCODING_CACHE


def test_set_cached_geocode_stores_lowercased_key(monkeypatch):
    monkeypatch.setattr(astrology_module, "_GEOCODING_CACHE", {})
    service = AstrologyService()

    service._set_cached_geocode("New Delhi", {"timezone": "Asia/Kolkata"})

    key, (stored, ts) = next(iter(astrology_module._GEOCODING_CACHE.items()))
    assert key == "new delhi"
    assert stored == {"timezone": "Asia/Kolkata"}
    assert time.time() - ts < 3600


# =============================================================================
# Birth place resolution (real HTTP path)
# =============================================================================


@pytest.mark.asyncio
async def test_resolve_birth_place_success_via_http(monkeypatch):
    response = _FakeHttpResponse(
        {
            "results": [
                {
                    "name": "New Delhi",
                    "admin1": "Delhi",
                    "country": "India",
                    "latitude": 28.6139,
                    "longitude": 77.2090,
                    "timezone": "Asia/Kolkata",
                }
            ]
        }
    )
    _patch_geocoding(monkeypatch, response)

    result = await AstrologyService()._resolve_birth_place("New Delhi")

    assert result == {
        "latitude": 28.6139,
        "longitude": 77.2090,
        "timezone": "Asia/Kolkata",
        "display_name": "New Delhi, Delhi, India",
    }
    assert astrology_module._GEOCODING_CACHE["new delhi"][0] == result


@pytest.mark.asyncio
async def test_resolve_birth_place_display_name_falls_back_to_place_name(monkeypatch):
    response = _FakeHttpResponse(
        {
            "results": [
                {
                    "name": "Tundra",
                    "timezone": "Asia/Anadyr",
                    "latitude": 1.0,
                    "longitude": 2.0,
                }
            ]
        }
    )
    _patch_geocoding(monkeypatch, response)

    result = await AstrologyService()._resolve_birth_place("Tundra")

    assert result["display_name"] == "Tundra"


@pytest.mark.asyncio
async def test_resolve_birth_place_empty_results_raise(monkeypatch):
    _patch_geocoding(monkeypatch, _FakeHttpResponse({"results": []}))

    with pytest.raises(ValueError, match="Could not resolve birth place"):
        await AstrologyService()._resolve_birth_place("Nowhere")


@pytest.mark.asyncio
async def test_resolve_birth_place_missing_timezone_raises(monkeypatch):
    response = _FakeHttpResponse(
        {"results": [{"name": "X", "latitude": 1.0, "longitude": 2.0}]}
    )
    _patch_geocoding(monkeypatch, response)

    with pytest.raises(ValueError, match="Timezone missing"):
        await AstrologyService()._resolve_birth_place("X")


@pytest.mark.asyncio
async def test_resolve_birth_place_tolerates_non_dict_json(monkeypatch):
    _patch_geocoding(monkeypatch, _FakeHttpResponse(None))

    with pytest.raises(ValueError, match="Could not resolve birth place"):
        await AstrologyService()._resolve_birth_place("Nowhere")


@pytest.mark.asyncio
async def test_resolve_birth_place_uses_cached_result(monkeypatch):
    cached = {
        "timezone": "Asia/Kolkata",
        "latitude": 28.6,
        "longitude": 77.2,
        "display_name": "New Delhi",
    }
    monkeypatch.setattr(
        astrology_module, "_GEOCODING_CACHE", {"new delhi": (cached, time.time())}
    )

    result = await AstrologyService()._resolve_birth_place("New Delhi")

    assert result is cached


# =============================================================================
# Sidereal context
# =============================================================================


def test_compute_sidereal_context_returns_signs():
    service = AstrologyService()
    result = service._compute_sidereal_context(
        birth_dt_utc=datetime(1994, 7, 21, 3, 15, 0, tzinfo=timezone.utc),
        latitude=28.6139,
        longitude=77.2090,
    )
    assert result["moon_sign"] in _ZODIAC
    assert result["ascendant"] in _ZODIAC


def test_compute_sidereal_context_falls_back_when_houses_ex_fails(monkeypatch):
    import swisseph as swe

    def _boom(*args, **kwargs):
        raise RuntimeError("houses_ex exploded")

    monkeypatch.setattr(swe, "houses_ex", _boom)

    service = AstrologyService()
    result = service._compute_sidereal_context(
        birth_dt_utc=datetime(1994, 7, 21, 3, 15, 0, tzinfo=timezone.utc),
        latitude=28.6139,
        longitude=77.2090,
    )
    assert result["moon_sign"] in _ZODIAC
    assert result["ascendant"] in _ZODIAC


def test_compute_sidereal_context_raises_without_swisseph(monkeypatch):
    monkeypatch.setitem(sys.modules, "swisseph", None)

    with pytest.raises(RuntimeError, match="pyswisseph is unavailable"):
        AstrologyService()._compute_sidereal_context(
            birth_dt_utc=datetime(1994, 7, 21, 3, 15, 0, tzinfo=timezone.utc),
            latitude=28.6139,
            longitude=77.2090,
        )


# =============================================================================
# Scoring
# =============================================================================


def test_score_colors_handles_context_without_ruling_planet():
    service = AstrologyService()
    # Leo bias makes saffron orange / golden yellow the clear winners, so the
    # avoid list is populated even though the ruling-planet loop is skipped.
    lucky, avoid, notes = service._score_colors(
        context={
            "sidereal_sun_sign": "Leo",
            "moon_sign": None,
            "ascendant": None,
        },
        mode="daily",
    )
    assert len(lucky) == 3
    assert len(avoid) == 1
    assert lucky[0]["name"] == "saffron orange"
    assert lucky[0]["confidence"] > 0
    assert notes[0] == "Ruling planet today: None."


def test_score_items_gives_bonus_to_items_without_colors():
    service = AstrologyService()
    scored = service._score_items(
        items=[{"id": "plain", "category": "tops", "condition": "clean"}],
        lucky_colors=[],
        avoid_colors=[],
        mode="daily",
    )
    # 0.25 base + 0.2 no-color bonus.
    assert scored[0]["_astrology_score"] == 0.45


def test_score_items_meeting_boost_only_for_core_categories():
    service = AstrologyService()
    scored = service._score_items(
        items=[
            {"id": "t1", "category": "tops", "condition": "clean", "colors": ["white"]},
            {
                "id": "a1",
                "category": "accessories",
                "condition": "clean",
                "colors": ["white"],
            },
        ],
        lucky_colors=[],
        avoid_colors=[],
        mode="important_meeting",
    )
    by_id = {row["id"]: row["_astrology_score"] for row in scored}
    # 0.25 + 0.35 neutral bonus + 0.7 meeting boost.
    assert by_id["t1"] == 1.3
    # 0.25 + 0.35 neutral bonus, no meeting boost for non-core categories.
    assert by_id["a1"] == 0.6


def test_build_suggested_outfits_skips_items_without_ids():
    service = AstrologyService()
    picks = [
        {"category": "tops", "items": [{"id": None}, {"id": "t2"}, {"id": "t3"}]},
        {"category": "bottoms", "items": [{"id": "b1"}, {"id": "b2"}]},
    ]

    suggestions = service._build_suggested_outfits(wardrobe_picks=picks, mode="daily")

    assert len(suggestions) == 1
    assert suggestions[0]["item_ids"] == ["t2", "b2"]
    assert suggestions[0]["description"] == "Day-wise balanced look"


# =============================================================================
# Name normalization, timezones, sidereal windows
# =============================================================================


def test_normalize_color_name_edge_cases():
    service = AstrologyService()
    assert service._normalize_color_name("") is None
    assert service._normalize_color_name("  ") is None
    assert service._normalize_color_name("grey") == "charcoal"
    assert service._normalize_color_name("maroon") == "ruby red"
    assert service._normalize_color_name("brown") == "brown"
    assert service._normalize_color_name("EMERALD") == "emerald green"


def test_safe_timezone_falls_back_to_utc():
    service = AstrologyService()
    assert service._safe_timezone(None) is timezone.utc
    assert service._safe_timezone("") is timezone.utc
    assert service._safe_timezone("Not/AZone") is timezone.utc
    assert service._safe_timezone("UTC") == ZoneInfo("UTC")


def test_sidereal_sun_sign_falls_back_when_no_window_matches():
    service = AstrologyService()
    # Duck-typed date whose month is out of range for every window: the
    # defensive fallback covers dates the windows table cannot match.
    weird_date = SimpleNamespace(month=13, day=1)
    assert service._sidereal_sun_sign(weird_date) == "Pisces"
