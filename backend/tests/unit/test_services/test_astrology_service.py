from datetime import date, time as dt_time

import pytest

from app.services.astrology_service import AstrologyService


@pytest.mark.asyncio
async def test_generate_lite_mode_with_dob_only():
    service = AstrologyService()

    result = await service.generate_recommendation(
        birth_date=date(1996, 5, 12),
        birth_time=None,
        birth_place=None,
        target_date=date(2026, 2, 6),
        mode="daily",
        items=[],
        user_timezone="UTC",
        limit_per_category=4,
    )

    assert result["astrology_mode"] == "vedic_lite"
    assert result["context"]["weekday"] == "Friday"
    assert result["context"]["ruling_planet"] == "Venus"
    assert len(result["lucky_colors"]) == 3


@pytest.mark.asyncio
async def test_generate_full_mode_when_birth_time_and_place_available(monkeypatch):
    service = AstrologyService()

    async def fake_resolve_birth_place(_: str):
        return {
            "latitude": 28.6139,
            "longitude": 77.2090,
            "timezone": "Asia/Kolkata",
            "display_name": "New Delhi, India",
        }

    def fake_sidereal_context(*, birth_dt_utc, latitude, longitude):  # noqa: ANN001
        assert birth_dt_utc is not None
        assert latitude == 28.6139
        assert longitude == 77.2090
        return {"moon_sign": "Taurus", "ascendant": "Virgo"}

    monkeypatch.setattr(service, "_resolve_birth_place", fake_resolve_birth_place)
    monkeypatch.setattr(service, "_compute_sidereal_context", fake_sidereal_context)

    result = await service.generate_recommendation(
        birth_date=date(1994, 7, 21),
        birth_time=dt_time(8, 45, 0),
        birth_place="New Delhi",
        target_date=date(2026, 2, 6),
        mode="daily",
        items=[],
        user_timezone=None,
        limit_per_category=4,
    )

    assert result["astrology_mode"] == "vedic_full"
    assert result["context"]["moon_sign"] == "Taurus"
    assert result["context"]["ascendant"] == "Virgo"
    assert result["context"]["birth_place_resolved"] == "New Delhi, India"


@pytest.mark.asyncio
async def test_generate_falls_back_to_lite_when_full_mode_fails(monkeypatch):
    service = AstrologyService()

    async def failing_resolve_birth_place(_: str):
        raise ValueError("failed geocoding")

    monkeypatch.setattr(service, "_resolve_birth_place", failing_resolve_birth_place)

    result = await service.generate_recommendation(
        birth_date=date(1994, 7, 21),
        birth_time=dt_time(8, 45, 0),
        birth_place="Unknown",
        target_date=date(2026, 2, 6),
        mode="daily",
        items=[],
        user_timezone=None,
        limit_per_category=4,
    )

    assert result["astrology_mode"] == "vedic_lite"
    assert result["context"]["moon_sign"] is not None
    assert result["context"]["ascendant"] is None


@pytest.mark.asyncio
async def test_wardrobe_picks_exclude_unusable_conditions():
    service = AstrologyService()

    items = [
        {
            "id": "clean-top",
            "category": "tops",
            "condition": "clean",
            "colors": ["emerald"],
        },
        {
            "id": "laundry-top",
            "category": "tops",
            "condition": "laundry",
            "colors": ["emerald"],
        },
        {
            "id": "clean-bottom",
            "category": "bottoms",
            "condition": "clean",
            "colors": ["charcoal"],
        },
    ]

    result = await service.generate_recommendation(
        birth_date=date(1990, 1, 20),
        birth_time=None,
        birth_place=None,
        target_date=date(2026, 2, 6),
        mode="important_meeting",
        items=items,
        user_timezone="UTC",
        limit_per_category=4,
    )

    picked_ids = {
        item["id"]
        for category in result["wardrobe_picks"]
        for item in category["items"]
    }
    assert "clean-top" in picked_ids
    assert "clean-bottom" in picked_ids
    assert "laundry-top" not in picked_ids
