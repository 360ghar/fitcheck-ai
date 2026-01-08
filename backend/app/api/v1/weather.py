"""
Weather API routes.

Implements the endpoints described in docs/2-technical/api-spec.md:
- GET /api/v1/weather
- GET /api/v1/weather/forecast

Weather data is fetched from OpenWeatherMap when configured; otherwise a safe
mock is returned for local development.
"""

from datetime import datetime, timezone
from typing import Any, Dict, List, Optional, Tuple

from fastapi import APIRouter, Depends, Query, status
from pydantic import BaseModel, Field
from supabase import Client

from app.core.exceptions import WeatherServiceError
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.services.weather_service import get_weather_service

logger = get_context_logger(__name__)

router = APIRouter()


# ============================================================================
# RESPONSE MODELS
# ============================================================================


class CurrentWeatherData(BaseModel):
    temperature: float
    condition: str
    humidity: int
    wind_speed: float
    feels_like: float
    location: str


class ForecastTemperature(BaseModel):
    high: float
    low: float


class ForecastDay(BaseModel):
    date: str
    temperature: ForecastTemperature
    condition: str
    precipitation_chance: int = Field(ge=0, le=100)


class ForecastData(BaseModel):
    forecast: List[ForecastDay]


# ============================================================================
# HELPERS
# ============================================================================


def _parse_location(location: str) -> Tuple[Optional[float], Optional[float], Optional[str]]:
    """Parse a location string.

    Supported formats:
    - "lat,lon" (both floats)
    - "City name"
    """
    if "," in location:
        parts = [p.strip() for p in location.split(",")]
        if len(parts) == 2:
            try:
                return float(parts[0]), float(parts[1]), None
            except ValueError:
                return None, None, location
    return None, None, location


def _f_to_c(temp_f: float) -> float:
    return (temp_f - 32.0) * 5.0 / 9.0


async def _resolve_location(
    db: Client,
    user_id: str,
    location: Optional[str],
) -> str:
    """Resolve a location string from query param or user settings."""
    if location:
        return location

    try:
        settings_row = (
            db.table("user_settings")
            .select("default_location")
            .eq("user_id", user_id)
            .single()
            .execute()
        )
        if settings_row.data and settings_row.data.get("default_location"):
            return str(settings_row.data["default_location"])
    except Exception:
        pass

    return "New York"


# ============================================================================
# ENDPOINTS
# ============================================================================


@router.get("", response_model=Dict[str, Any])
async def get_current_weather(
    location: Optional[str] = Query(None, description="City name or 'lat,lon'"),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Get current weather (Celsius)."""
    try:
        resolved = await _resolve_location(db=db, user_id=user_id, location=location)
        lat, lon, city = _parse_location(resolved)

        service = get_weather_service()
        if lat is not None and lon is not None:
            weather = await service.get_weather_by_coordinates(lat=lat, lon=lon, units="imperial")
        else:
            weather = await service.get_weather(location=city or resolved, units="imperial")

        if not weather:
            raise WeatherServiceError(
                message="Weather service temporarily unavailable"
            )

        data = CurrentWeatherData(
            temperature=round(_f_to_c(float(weather.get("temperature", 0))), 1),
            condition=str(weather.get("condition", "")),
            humidity=int(weather.get("humidity", 0)),
            wind_speed=float(weather.get("wind_speed", 0)),
            feels_like=round(
                _f_to_c(float(weather.get("feels_like", weather.get("temperature", 0)))), 1
            ),
            location=str(weather.get("location", resolved)),
        )

        logger.debug(
            "Weather retrieved",
            user_id=user_id,
            location=resolved,
            temperature=data.temperature
        )
        return {"data": data.model_dump(), "message": "OK"}

    except WeatherServiceError:
        raise
    except Exception as e:
        logger.error(
            "Error getting weather",
            user_id=user_id,
            location=location,
            error=str(e)
        )
        raise WeatherServiceError(
            message="Weather service temporarily unavailable"
        )


@router.get("/forecast", response_model=Dict[str, Any])
async def get_weather_forecast(
    location: Optional[str] = Query(None, description="City name or 'lat,lon'"),
    days: int = Query(7, ge=1, le=14),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Get a simple daily forecast (Celsius)."""
    try:
        resolved = await _resolve_location(db=db, user_id=user_id, location=location)
        lat, lon, city = _parse_location(resolved)

        service = get_weather_service()
        forecast = await service.get_forecast(
            location=city or resolved,
            lat=lat,
            lon=lon,
            units="imperial",
            days=days,
        )
        # Convert temps to Celsius for the API contract
        for day in forecast:
            temps = day.get("temperature") or {}
            if "high" in temps:
                temps["high"] = round(_f_to_c(float(temps["high"])), 1)
            if "low" in temps:
                temps["low"] = round(_f_to_c(float(temps["low"])), 1)
            day["temperature"] = temps

        logger.debug(
            "Weather forecast retrieved",
            user_id=user_id,
            location=resolved,
            days=days,
            forecast_count=len(forecast)
        )
        return {"data": {"forecast": forecast}, "message": "OK"}

    except WeatherServiceError:
        raise
    except Exception as e:
        logger.error(
            "Error getting forecast",
            user_id=user_id,
            location=location,
            error=str(e)
        )
        raise WeatherServiceError(
            message="Weather service temporarily unavailable"
        )
