"""
Weather service for integrating with weather APIs.
Used to provide weather-based outfit recommendations.
"""

import logging
from typing import Optional, Dict, Any
from datetime import datetime

import httpx

from app.core.config import settings

logger = logging.getLogger(__name__)


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
    ) -> Optional[Dict[str, Any]]:
        """Get current weather for a location.

        Args:
            location: City name, zip code, or lat,lon
            units: 'imperial' (Fahrenheit) or 'metric' (Celsius)

        Returns:
            Weather data dict or None if error
        """
        if not self.api_key:
            logger.warning("Weather API key not configured, returning mock data")
            return self._mock_weather(location)

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
                    return self._parse_weather_response(response.json())
                else:
                    logger.warning(f"Weather API error: {response.status_code}")
                    return self._mock_weather(location)

        except Exception as e:
            logger.error(f"Error fetching weather: {str(e)}")
            return self._mock_weather(location)

    async def get_weather_by_coordinates(
        self,
        lat: float,
        lon: float,
        units: str = "imperial"
    ) -> Optional[Dict[str, Any]]:
        """Get weather by latitude and longitude.

        Args:
            lat: Latitude
            lon: Longitude
            units: 'imperial' or 'metric'

        Returns:
            Weather data dict or None
        """
        if not self.api_key:
            return self._mock_weather("current_location")

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
                    return self._parse_weather_response(response.json())
                else:
                    return self._mock_weather("current_location")

        except Exception as e:
            logger.error(f"Error fetching weather by coords: {str(e)}")
            return self._mock_weather("current_location")

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

    def _mock_weather(self, location: str) -> Dict[str, Any]:
        """Return mock weather data for testing/fallback.

        Args:
            location: Location name

        Returns:
            Mock weather data
        """
        return {
            "temperature": 72,
            "feels_like": 70,
            "humidity": 50,
            "condition": "Clear",
            "description": "clear sky",
            "wind_speed": 5,
            "temp_category": WeatherCondition.WARM,
            "weather_state": WeatherCondition.SUNNY,
            "location": location,
            "fetched_at": datetime.now().isoformat(),
            "is_mock": True
        }


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
