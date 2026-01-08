"""
Weather service for integrating with weather APIs.
Used to provide weather-based outfit recommendations.
"""

from typing import Optional, Dict, Any, List
from datetime import datetime, timezone, timedelta
from collections import Counter, defaultdict

import httpx

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import WeatherServiceError

logger = get_context_logger(__name__)


# ============================================================================
# WEATHER DATA MODELS
# ============================================================================


class WeatherCondition:
    """Standardized weather conditions."""

    # Conditions that map to recommendation logic
    HOT = "hot"           # >80°F
    WARM = "warm"         # 65-80°F
    MILD = "mild"         # 50-65°F
    COOL = "cool"         # 40-50°F
    COLD = "cold"         # 32-40°F
    FREEZING = "freezing" # <32°F

    # Weather states
    SUNNY = "sunny"
    CLOUDY = "cloudy"
    RAINY = "rainy"
    SNOWY = "snowy"
    WINDY = "windy"
    STORMY = "stormy"


# ============================================================================
# WEATHER SERVICE
# ============================================================================


class WeatherService:
    """Service for fetching weather data and making outfit recommendations."""

    def __init__(self):
        """Initialize weather service."""
        self.api_key = getattr(settings, 'WEATHER_API_KEY', None)
        self.base_url = "https://api.openweathermap.org/data/2.5"

    async def get_weather(
        self,
        location: str,
        units: str = "imperial"
    ) -> Dict[str, Any]:
        """Get current weather for a location.

        Args:
            location: City name, zip code, or lat,lon
            units: 'imperial' (Fahrenheit) or 'metric' (Celsius)

        Returns:
            Weather data dict

        Raises:
            WeatherServiceError: If API key not configured or API call fails
        """
        if not self.api_key:
            logger.error(
                "Weather API key not configured",
                location=location,
            )
            raise WeatherServiceError("Weather API key not configured. Set WEATHER_API_KEY in environment.")

        try:
            async with httpx.AsyncClient() as client:
                params = {
                    "q": location,
                    "appid": self.api_key,
                    "units": units
                }

                response = await client.get(
                    f"{self.base_url}/weather",
                    params=params,
                    timeout=10.0
                )

                if response.status_code == 200:
                    logger.info(
                        "Fetched weather data",
                        location=location,
                        units=units,
                    )
                    return self._parse_weather_response(response.json())
                else:
                    logger.error(
                        "Weather API returned error",
                        location=location,
                        status_code=response.status_code,
                        response_text=response.text[:200],
                    )
                    raise WeatherServiceError(f"Weather API error: {response.status_code}")

        except WeatherServiceError:
            raise
        except Exception as e:
            logger.error(
                "Failed to fetch weather",
                location=location,
                error=str(e),
            )
            raise WeatherServiceError(f"Failed to fetch weather: {str(e)}")

    async def get_weather_by_coordinates(
        self,
        lat: float,
        lon: float,
        units: str = "imperial"
    ) -> Dict[str, Any]:
        """Get weather by latitude and longitude.

        Args:
            lat: Latitude
            lon: Longitude
            units: 'imperial' or 'metric'

        Returns:
            Weather data dict

        Raises:
            WeatherServiceError: If API key not configured or API call fails
        """
        if not self.api_key:
            logger.error(
                "Weather API key not configured",
                lat=lat,
                lon=lon,
            )
            raise WeatherServiceError("Weather API key not configured. Set WEATHER_API_KEY in environment.")

        try:
            async with httpx.AsyncClient() as client:
                params = {
                    "lat": lat,
                    "lon": lon,
                    "appid": self.api_key,
                    "units": units
                }

                response = await client.get(
                    f"{self.base_url}/weather",
                    params=params,
                    timeout=10.0
                )

                if response.status_code == 200:
                    logger.info(
                        "Fetched weather data by coordinates",
                        lat=lat,
                        lon=lon,
                        units=units,
                    )
                    return self._parse_weather_response(response.json())
                else:
                    logger.error(
                        "Weather API returned error",
                        lat=lat,
                        lon=lon,
                        status_code=response.status_code,
                        response_text=response.text[:200],
                    )
                    raise WeatherServiceError(f"Weather API error: {response.status_code}")

        except WeatherServiceError:
            raise
        except Exception as e:
            logger.error(
                "Failed to fetch weather by coordinates",
                lat=lat,
                lon=lon,
                error=str(e),
            )
            raise WeatherServiceError(f"Failed to fetch weather: {str(e)}")

    async def get_forecast(
        self,
        location: str,
        lat: Optional[float] = None,
        lon: Optional[float] = None,
        units: str = "imperial",
        days: int = 7,
    ) -> List[Dict[str, Any]]:
        """Get a simple daily forecast.

        Notes:
        - Uses OpenWeatherMap 5-day /forecast (3-hour intervals) when available.
        - For days > 5, results are capped to available range.

        Args:
            location: City name or identifier
            lat: Optional latitude
            lon: Optional longitude
            units: 'imperial' or 'metric'
            days: Number of days to forecast (max 5 for free tier)

        Returns:
            List of daily forecast objects:
              {date, temperature:{high,low}, condition, precipitation_chance}

        Raises:
            WeatherServiceError: If API key not configured or API call fails
        """
        if not self.api_key:
            logger.error(
                "Weather API key not configured for forecast",
                location=location,
            )
            raise WeatherServiceError("Weather API key not configured. Set WEATHER_API_KEY in environment.")

        # OpenWeather free /forecast typically provides ~5 days of 3h intervals
        days = max(1, min(days, 5))

        try:
            async with httpx.AsyncClient() as client:
                params: Dict[str, Any] = {"appid": self.api_key, "units": units}

                if lat is not None and lon is not None:
                    params.update({"lat": lat, "lon": lon})
                else:
                    params["q"] = location

                response = await client.get(
                    f"{self.base_url}/forecast",
                    params=params,
                    timeout=10.0,
                )

                if response.status_code != 200:
                    logger.error(
                        "Forecast API returned error",
                        location=location,
                        lat=lat,
                        lon=lon,
                        status_code=response.status_code,
                        response_text=response.text[:200],
                    )
                    raise WeatherServiceError(f"Forecast API error: {response.status_code}")

                logger.info(
                    "Fetched forecast data",
                    location=location,
                    lat=lat,
                    lon=lon,
                    days=days,
                )
                return self._parse_forecast_response(response.json(), days)

        except WeatherServiceError:
            raise
        except Exception as e:
            logger.error(
                "Failed to fetch forecast",
                location=location,
                lat=lat,
                lon=lon,
                error=str(e),
            )
            raise WeatherServiceError(f"Failed to fetch forecast: {str(e)}")

    def _parse_weather_response(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Parse OpenWeatherMap API response.

        Args:
            data: Raw API response

        Returns:
            Standardized weather data
        """
        main = data.get("main", {})
        weather = data.get("weather", [{}])[0]
        wind = data.get("wind", {})

        temp = main.get("temp", 70)
        feels_like = main.get("feels_like", temp)
        humidity = main.get("humidity", 50)
        condition = weather.get("main", "").lower()
        description = weather.get("description", "")
        wind_speed = wind.get("speed", 0)

        # Determine temperature category
        temp_category = self._get_temp_category(temp)

        # Determine weather state
        weather_state = self._get_weather_state(condition, temp)

        return {
            "temperature": temp,
            "feels_like": feels_like,
            "humidity": humidity,
            "condition": condition,
            "description": description,
            "wind_speed": wind_speed,
            "temp_category": temp_category,
            "weather_state": weather_state,
            "location": data.get("name", "Unknown"),
            "fetched_at": datetime.now().isoformat()
        }

    def _get_temp_category(self, temp_f: float) -> str:
        """Categorize temperature.

        Args:
            temp_f: Temperature in Fahrenheit

        Returns:
            Temperature category string
        """
        if temp_f >= 85:
            return WeatherCondition.HOT
        elif temp_f >= 70:
            return WeatherCondition.WARM
        elif temp_f >= 55:
            return WeatherCondition.MILD
        elif temp_f >= 40:
            return WeatherCondition.COOL
        elif temp_f >= 32:
            return WeatherCondition.COLD
        else:
            return WeatherCondition.FREEZING

    def _get_weather_state(self, condition: str, temp: float) -> str:
        """Determine weather state from condition and temp.

        Args:
            condition: Weather condition string
            temp: Temperature

        Returns:
            Weather state
        """
        condition_lower = condition.lower()

        if "rain" in condition_lower or "drizzle" in condition_lower:
            return WeatherCondition.RAINY
        elif "snow" in condition_lower or "sleet" in condition_lower:
            return WeatherCondition.SNOWY
        elif "clear" in condition_lower:
            return WeatherCondition.SUNNY
        elif "cloud" in condition_lower:
            return WeatherCondition.CLOUDY
        elif "storm" in condition_lower or "thunder" in condition_lower:
            return WeatherCondition.STORMY
        elif temp < 40:  # Windy when cold
            return WeatherCondition.WINDY
        else:
            return WeatherCondition.CLOUDY

    def _parse_forecast_response(self, data: Dict[str, Any], days: int) -> List[Dict[str, Any]]:
        """Parse OpenWeatherMap 5-day /forecast response into daily summaries."""
        by_day: Dict[str, List[Dict[str, Any]]] = defaultdict(list)

        for entry in data.get("list", []):
            dt = entry.get("dt")
            if not dt:
                continue
            day = datetime.fromtimestamp(dt, tz=timezone.utc).date().isoformat()
            by_day[day].append(entry)

        results: List[Dict[str, Any]] = []
        for day in sorted(by_day.keys())[:days]:
            entries = by_day[day]
            temps = [e.get("main", {}).get("temp") for e in entries]
            temps = [t for t in temps if isinstance(t, (int, float))]

            if temps:
                high = max(temps)
                low = min(temps)
            else:
                high = low = 0.0

            # Pick the most common condition name
            conditions = []
            pops = []
            for e in entries:
                weather = (e.get("weather") or [{}])[0] or {}
                cond = weather.get("main") or weather.get("description") or ""
                if cond:
                    conditions.append(str(cond).lower())
                pop = e.get("pop")
                if isinstance(pop, (int, float)):
                    pops.append(float(pop))

            condition = Counter(conditions).most_common(1)[0][0] if conditions else "unknown"
            precipitation_chance = int(round(max(pops) * 100)) if pops else 0
            precipitation_chance = max(0, min(100, precipitation_chance))

            results.append(
                {
                    "date": day,
                    "temperature": {"high": high, "low": low},
                    "condition": condition,
                    "precipitation_chance": precipitation_chance,
                }
            )

        return results


# ============================================================================
# OUTFIT RECOMMENDATIONS BASED ON WEATHER
# ============================================================================


class WeatherOutfitRecommender:
    """Generate outfit recommendations based on weather."""

    # Recommendations by temperature category
    TEMP_RECOMMENDATIONS = {
        WeatherCondition.HOT: {
            "preferred_categories": ["tops", "bottoms", "shoes", "accessories"],
            "avoid_categories": ["outerwear"],
            "materials": ["cotton", "linen", "mesh", "lightweight"],
            "layers": 1,
            "notes": "Light, breathable fabrics. Short sleeves and shorts recommended."
        },
        WeatherCondition.WARM: {
            "preferred_categories": ["tops", "bottoms", "shoes", "accessories"],
            "avoid_categories": ["outerwear"],
            "materials": ["cotton", "lightweight", "breathable"],
            "layers": 1,
            "notes": "Light layers. Short sleeves or light long sleeves."
        },
        WeatherCondition.MILD: {
            "preferred_categories": ["tops", "bottoms", "shoes", "outerwear", "accessories"],
            "avoid_categories": [],
            "materials": ["cotton", "wool", "lightweight"],
            "layers": 2,
            "notes": "Perfect weather for light layers. Bring a jacket for evening."
        },
        WeatherCondition.COOL: {
            "preferred_categories": ["tops", "bottoms", "shoes", "outerwear", "accessories"],
            "avoid_categories": [],
            "materials": ["wool", "cotton", "denim"],
            "layers": 2,
            "notes": "Long sleeves and a light jacket or cardigan."
        },
        WeatherCondition.COLD: {
            "preferred_categories": ["tops", "bottoms", "shoes", "outerwear", "accessories"],
            "avoid_categories": [],
            "materials": ["wool", "cashmere", "fleece", "heavy"],
            "layers": 3,
            "notes": "Warm layers needed. Coat, scarf, and gloves recommended."
        },
        WeatherCondition.FREEZING: {
            "preferred_categories": ["tops", "bottoms", "shoes", "outerwear", "accessories"],
            "avoid_categories": [],
            "materials": ["wool", "thermal", "insulated", "waterproof"],
            "layers": 4,
            "notes": "Maximum warmth. Heavy coat, hat, gloves, scarf, and boots."
        }
    }

    # Recommendations by weather state
    WEATHER_RECOMMENDATIONS = {
        WeatherCondition.RAINY: {
            "add_items": ["raincoat", "umbrella", "waterproof shoes", "boots"],
            "avoid_items": ["suede", "canvas shoes", "light colors"],
            "notes": "Waterproof outer layer and footwear recommended."
        },
        WeatherCondition.SNOWY: {
            "add_items": ["waterproof boots", "heavy coat", "gloves", "hat", "scarf"],
            "avoid_items": ["sneakers", "light jacket"],
            "notes": "Insulated, waterproof footwear and heavy outerwear needed."
        },
        WeatherCondition.WINDY: {
            "add_items": ["windbreaker", "close-fitting clothes"],
            "avoid_items": ["loose clothing", "flowing fabrics"],
            "notes": "Wind-resistant outer layer recommended."
        },
        WeatherCondition.STORMY: {
            "add_items": ["raincoat", "umbrella", "waterproof boots"],
            "avoid_items": ["anything you don't want getting wet"],
            "notes": "Stay indoors if possible! Waterproof everything."
        }
    }

    @staticmethod
    def get_recommendations(weather: Dict[str, Any]) -> Dict[str, Any]:
        """Get outfit recommendations based on weather.

        Args:
            weather: Weather data from WeatherService

        Returns:
            Recommendation dict
        """
        temp_category = weather.get("temp_category", WeatherCondition.MILD)
        weather_state = weather.get("weather_state", WeatherCondition.SUNNY)

        temp_rec = WeatherOutfitRecommender.TEMP_RECOMMENDATIONS.get(
            temp_category,
            WeatherOutfitRecommender.TEMP_RECOMMENDATIONS[WeatherCondition.MILD]
        )

        weather_rec = WeatherOutfitRecommender.WEATHER_RECOMMENDATIONS.get(
            weather_state,
            {}
        )

        # Build final recommendations
        recommendations = {
            "temperature": weather.get("temperature"),
            "temp_category": temp_category,
            "weather_state": weather_state,
            "preferred_categories": temp_rec.get("preferred_categories", []),
            "avoid_categories": temp_rec.get("avoid_categories", []),
            "preferred_materials": temp_rec.get("materials", []),
            "suggested_layers": temp_rec.get("layers", 2),
            "additional_items": weather_rec.get("add_items", []),
            "items_to_avoid": weather_rec.get("avoid_items", []),
            "notes": [
                temp_rec.get("notes", ""),
                weather_rec.get("notes", "")
            ],
            "color_suggestions": WeatherOutfitRecommender._get_color_suggestions(weather_state)
        }

        return recommendations

    @staticmethod
    def _get_color_suggestions(weather_state: str) -> List[str]:
        """Get color suggestions based on weather.

        Args:
            weather_state: Current weather state

        Returns:
            List of color suggestions
        """
        if weather_state == WeatherCondition.RAINY:
            return ["Dark colors to hide rain spots", "Bright colors for visibility"]
        elif weather_state == WeatherCondition.SNOWY:
            return ["Bright colors to stand out against snow", "Red for visibility"]
        elif weather_state == WeatherCondition.SUNNY:
            return ["Any colors work well", "Light colors reflect heat"]
        else:
            return ["Earth tones for cloudy days"]


# Singleton instance
_weather_service: Optional[WeatherService] = None


def get_weather_service() -> WeatherService:
    """Get the singleton WeatherService instance."""
    global _weather_service
    if _weather_service is None:
        _weather_service = WeatherService()
    return _weather_service
