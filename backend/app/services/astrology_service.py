"""
Astrology service for daily lucky-color recommendations.

The implementation is intentionally deterministic and uses:
- Vedic-lite mode (weekday + sidereal date windows)
- Vedic-full mode (optional birth time/place + sidereal moon/ascendant)
"""

from __future__ import annotations

from datetime import date, datetime, time as dt_time, timezone
from typing import Any, Dict, List, Optional, Tuple
from zoneinfo import ZoneInfo

import httpx

from app.core.logging_config import get_context_logger

logger = get_context_logger(__name__)


_WEEKDAY_PLANETS = {
    0: "Moon",      # Monday
    1: "Mars",      # Tuesday
    2: "Mercury",   # Wednesday
    3: "Jupiter",   # Thursday
    4: "Venus",     # Friday
    5: "Saturn",    # Saturday
    6: "Sun",       # Sunday
}

_COLOR_LIBRARY: Dict[str, Dict[str, Any]] = {
    "white": {
        "hex": "#FFFFFF",
        "planets": {"Moon": 0.35, "Venus": 0.28},
        "keywords": {"white", "ivory", "off white"},
    },
    "cream": {
        "hex": "#FFF3CD",
        "planets": {"Moon": 0.26, "Jupiter": 0.22},
        "keywords": {"cream", "beige", "sand", "ecru"},
    },
    "emerald green": {
        "hex": "#2E7D32",
        "planets": {"Mercury": 0.40, "Venus": 0.18},
        "keywords": {"emerald", "green", "olive", "mint"},
    },
    "royal blue": {
        "hex": "#1E40AF",
        "planets": {"Saturn": 0.28, "Jupiter": 0.16},
        "keywords": {"blue", "royal blue", "cobalt"},
    },
    "navy blue": {
        "hex": "#1F2A44",
        "planets": {"Saturn": 0.36, "Mercury": 0.12},
        "keywords": {"navy", "midnight blue", "ink blue"},
    },
    "charcoal": {
        "hex": "#36454F",
        "planets": {"Saturn": 0.33},
        "keywords": {"charcoal", "graphite", "slate"},
    },
    "golden yellow": {
        "hex": "#D4AF37",
        "planets": {"Jupiter": 0.42, "Sun": 0.16},
        "keywords": {"yellow", "gold", "mustard", "ochre"},
    },
    "saffron orange": {
        "hex": "#FF8C00",
        "planets": {"Sun": 0.45, "Mars": 0.12},
        "keywords": {"orange", "saffron", "amber", "tangerine"},
    },
    "ruby red": {
        "hex": "#A91B0D",
        "planets": {"Mars": 0.41, "Sun": 0.16},
        "keywords": {"red", "maroon", "crimson", "burgundy"},
    },
    "pastel pink": {
        "hex": "#F8BBD0",
        "planets": {"Venus": 0.34, "Moon": 0.16},
        "keywords": {"pink", "rose", "blush"},
    },
    "lavender": {
        "hex": "#C4B5FD",
        "planets": {"Venus": 0.20, "Mercury": 0.10},
        "keywords": {"lavender", "lilac", "violet"},
    },
    "black": {
        "hex": "#111111",
        "planets": {"Saturn": 0.22},
        "keywords": {"black", "jet", "onyx"},
    },
}

_COLOR_SYNONYMS = {
    "grey": "charcoal",
    "gray": "charcoal",
    "dark blue": "navy blue",
    "light blue": "royal blue",
    "maroon": "ruby red",
}

_SIGN_COLOR_BIAS: Dict[str, List[Tuple[str, float]]] = {
    "Aries": [("ruby red", 0.22), ("saffron orange", 0.15)],
    "Taurus": [("emerald green", 0.22), ("cream", 0.14)],
    "Gemini": [("emerald green", 0.18), ("lavender", 0.10)],
    "Cancer": [("white", 0.20), ("cream", 0.12)],
    "Leo": [("saffron orange", 0.22), ("golden yellow", 0.16)],
    "Virgo": [("emerald green", 0.21), ("charcoal", 0.10)],
    "Libra": [("pastel pink", 0.21), ("royal blue", 0.10)],
    "Scorpio": [("ruby red", 0.20), ("charcoal", 0.12)],
    "Sagittarius": [("golden yellow", 0.23), ("saffron orange", 0.10)],
    "Capricorn": [("navy blue", 0.21), ("charcoal", 0.16)],
    "Aquarius": [("royal blue", 0.18), ("lavender", 0.12)],
    "Pisces": [("white", 0.17), ("royal blue", 0.11)],
}

_MEETING_BOOST = {
    "navy blue": 0.22,
    "charcoal": 0.20,
    "white": 0.16,
    "emerald green": 0.12,
    "royal blue": 0.12,
    "cream": 0.10,
}

_CATEGORY_ORDER = [
    "tops",
    "bottoms",
    "shoes",
    "outerwear",
    "accessories",
    "activewear",
    "swimwear",
    "other",
]
_UNUSABLE_CONDITIONS = {"laundry", "repair", "donate"}


class AstrologyService:
    """Deterministic astrology recommendation service."""

    geocode_url = "https://geocoding-api.open-meteo.com/v1/search"

    async def resolve_birth_timezone(self, birth_place: Optional[str]) -> Optional[str]:
        """Best-effort timezone lookup for birth place."""
        if not birth_place:
            return None
        try:
            resolved = await self._resolve_birth_place(birth_place)
            return resolved.get("timezone")
        except Exception:
            return None

    async def generate_recommendation(
        self,
        *,
        birth_date: date,
        birth_time: Optional[dt_time],
        birth_place: Optional[str],
        target_date: date,
        mode: str,
        items: List[Dict[str, Any]],
        user_timezone: Optional[str],
        limit_per_category: int,
    ) -> Dict[str, Any]:
        """Generate astrology recommendation payload."""
        mode = mode if mode in {"daily", "important_meeting"} else "daily"
        context = self._base_context(target_date)
        astrology_mode = "vedic_lite"

        if birth_time is not None and birth_place:
            try:
                full_context = await self._build_full_context(
                    birth_date=birth_date,
                    birth_time=birth_time,
                    birth_place=birth_place,
                    fallback_timezone=user_timezone,
                )
                context.update(full_context)
                astrology_mode = "vedic_full"
            except Exception as e:
                logger.warning("Vedic full mode failed, using lite mode", error=str(e))

        if astrology_mode == "vedic_lite":
            context.update(self._build_lite_context(target_date))

        lucky_colors, avoid_colors, notes = self._score_colors(
            context=context,
            mode=mode,
        )

        scored_items = self._score_items(
            items=items,
            lucky_colors=lucky_colors,
            avoid_colors=avoid_colors,
            mode=mode,
        )
        wardrobe_picks = self._build_wardrobe_picks(scored_items, limit_per_category=limit_per_category)
        suggested_outfits = self._build_suggested_outfits(wardrobe_picks=wardrobe_picks, mode=mode)

        if mode == "important_meeting":
            notes.append("Meeting mode favors composed and communication-forward color pairings.")

        return {
            "astrology_mode": astrology_mode,
            "context": context,
            "lucky_colors": lucky_colors,
            "avoid_colors": avoid_colors,
            "wardrobe_picks": wardrobe_picks,
            "suggested_outfits": suggested_outfits,
            "notes": notes,
        }

    def user_local_today(self, timezone_name: Optional[str]) -> date:
        """Resolve today's date using user timezone, defaulting to UTC."""
        tz = self._safe_timezone(timezone_name)
        return datetime.now(tz).date()

    def _base_context(self, target_date: date) -> Dict[str, Any]:
        weekday_name = target_date.strftime("%A")
        ruling_planet = _WEEKDAY_PLANETS[target_date.weekday()]
        return {
            "weekday": weekday_name,
            "ruling_planet": ruling_planet,
            "moon_sign": None,
            "ascendant": None,
            "sidereal_sun_sign": None,
        }

    def _build_lite_context(self, target_date: date) -> Dict[str, Any]:
        sidereal_sign = self._sidereal_sun_sign(target_date)
        return {
            "sidereal_sun_sign": sidereal_sign,
            # Lite mode approximates mood from sidereal solar sign.
            "moon_sign": sidereal_sign,
            "ascendant": None,
        }

    async def _build_full_context(
        self,
        *,
        birth_date: date,
        birth_time: dt_time,
        birth_place: str,
        fallback_timezone: Optional[str],
    ) -> Dict[str, Any]:
        resolved = await self._resolve_birth_place(birth_place)
        timezone_name = resolved.get("timezone") or fallback_timezone or "UTC"
        birth_tz = self._safe_timezone(timezone_name)

        birth_dt_local = datetime.combine(birth_date, birth_time, tzinfo=birth_tz)
        birth_dt_utc = birth_dt_local.astimezone(timezone.utc)

        sidereal = self._compute_sidereal_context(
            birth_dt_utc=birth_dt_utc,
            latitude=resolved["latitude"],
            longitude=resolved["longitude"],
        )
        return {
            "moon_sign": sidereal.get("moon_sign"),
            "ascendant": sidereal.get("ascendant"),
            "sidereal_sun_sign": self._sidereal_sun_sign(birth_date),
            "birth_place_resolved": resolved.get("display_name"),
        }

    async def _resolve_birth_place(self, birth_place: str) -> Dict[str, Any]:
        async with httpx.AsyncClient(timeout=8.0) as client:
            response = await client.get(
                self.geocode_url,
                params={
                    "name": birth_place,
                    "count": 1,
                    "language": "en",
                    "format": "json",
                },
            )
        response.raise_for_status()
        payload = response.json() or {}
        results = payload.get("results") or []
        if not results:
            raise ValueError(f"Could not resolve birth place: {birth_place}")

        row = results[0]
        timezone_name = row.get("timezone")
        if not timezone_name:
            raise ValueError("Timezone missing for resolved birth place")

        display_name = ", ".join(
            [part for part in [row.get("name"), row.get("admin1"), row.get("country")] if part]
        )
        return {
            "latitude": float(row["latitude"]),
            "longitude": float(row["longitude"]),
            "timezone": timezone_name,
            "display_name": display_name or birth_place,
        }

    def _compute_sidereal_context(
        self,
        *,
        birth_dt_utc: datetime,
        latitude: float,
        longitude: float,
    ) -> Dict[str, str]:
        try:
            import swisseph as swe
        except Exception as e:
            raise RuntimeError("pyswisseph is unavailable") from e

        swe.set_sid_mode(swe.SIDM_LAHIRI, 0, 0)
        hour_decimal = (
            birth_dt_utc.hour
            + (birth_dt_utc.minute / 60.0)
            + (birth_dt_utc.second / 3600.0)
        )
        jd_ut = swe.julday(
            birth_dt_utc.year,
            birth_dt_utc.month,
            birth_dt_utc.day,
            hour_decimal,
        )
        flags = swe.FLG_SWIEPH | swe.FLG_SIDEREAL
        moon_longitude = float(swe.calc_ut(jd_ut, swe.MOON, flags)[0][0])

        try:
            _, ascmc = swe.houses_ex(jd_ut, latitude, longitude, b"P", flags)
        except Exception:
            _, ascmc = swe.houses(jd_ut, latitude, longitude, b"P")
        ascendant_longitude = float(ascmc[0])

        zodiac = [
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
        ]
        moon_sign = zodiac[int((moon_longitude % 360) // 30)]
        ascendant = zodiac[int((ascendant_longitude % 360) // 30)]
        return {"moon_sign": moon_sign, "ascendant": ascendant}

    def _score_colors(
        self,
        *,
        context: Dict[str, Any],
        mode: str,
    ) -> Tuple[List[Dict[str, Any]], List[Dict[str, Any]], List[str]]:
        scores: Dict[str, float] = {name: 0.15 for name in _COLOR_LIBRARY}
        ruling_planet = context.get("ruling_planet")

        if ruling_planet:
            for color_name, meta in _COLOR_LIBRARY.items():
                scores[color_name] += float(meta.get("planets", {}).get(ruling_planet, 0.0))

        for sign_key in ("sidereal_sun_sign", "moon_sign", "ascendant"):
            sign_value = context.get(sign_key)
            if sign_value in _SIGN_COLOR_BIAS:
                for color_name, boost in _SIGN_COLOR_BIAS[sign_value]:
                    scores[color_name] += boost

        if mode == "important_meeting":
            for color_name, boost in _MEETING_BOOST.items():
                scores[color_name] += boost

        ranked = sorted(scores.items(), key=lambda kv: kv[1], reverse=True)
        lucky_raw = ranked[:3]
        avoid_raw = sorted(scores.items(), key=lambda kv: kv[1])[:2]

        lucky_colors = [
            {
                "name": name,
                "hex": _COLOR_LIBRARY[name]["hex"],
                "reason": self._build_color_reason(name=name, context=context, mode=mode),
                "confidence": round(min(0.99, max(0.1, score)), 2),
            }
            for name, score in lucky_raw
        ]
        avoid_colors = [
            {
                "name": name,
                "hex": _COLOR_LIBRARY[name]["hex"],
                "reason": "Lower day-wise harmony from Vedic weighting",
                "confidence": round(min(0.99, max(0.1, 1.0 - score)), 2),
            }
            for name, score in avoid_raw
            if name not in {c["name"] for c in lucky_colors}
        ]

        notes = [
            f"Ruling planet today: {ruling_planet}.",
            "Use one lucky color as the focal outfit color and keep others neutral.",
        ]
        return lucky_colors, avoid_colors, notes

    def _build_color_reason(self, *, name: str, context: Dict[str, Any], mode: str) -> str:
        ruling_planet = context.get("ruling_planet")
        planets = _COLOR_LIBRARY[name].get("planets", {})
        if ruling_planet in planets:
            return f"{ruling_planet} support for the day"
        if mode == "important_meeting" and name in _MEETING_BOOST:
            return "Boosts confident and professional presence"
        return "Balanced by day-wise Vedic color weighting"

    def _score_items(
        self,
        *,
        items: List[Dict[str, Any]],
        lucky_colors: List[Dict[str, Any]],
        avoid_colors: List[Dict[str, Any]],
        mode: str,
    ) -> List[Dict[str, Any]]:
        lucky_set = {
            self._normalize_color_name(color["name"])
            for color in lucky_colors
            if color.get("name")
        }
        avoid_set = {
            self._normalize_color_name(color["name"])
            for color in avoid_colors
            if color.get("name")
        }
        lucky_set.discard(None)
        avoid_set.discard(None)

        scored: List[Dict[str, Any]] = []
        for item in items:
            condition = str(item.get("condition") or "").lower()
            if condition in _UNUSABLE_CONDITIONS:
                continue

            raw_colors = item.get("colors") or []
            normalized_colors = {
                self._normalize_color_name(str(color))
                for color in raw_colors
                if color is not None
            }
            normalized_colors.discard(None)

            lucky_hits = lucky_set & normalized_colors
            avoid_hits = avoid_set & normalized_colors

            score = 0.25
            score += len(lucky_hits) * 2.5
            score -= len(avoid_hits) * 1.8
            if not normalized_colors:
                score += 0.2

            category = str(item.get("category") or "other").lower()
            if mode == "important_meeting" and category in {"tops", "bottoms", "shoes", "outerwear"}:
                score += 0.7

            if normalized_colors & {"white", "cream", "charcoal", "black", "navy blue"}:
                score += 0.35

            scored_item = {**item, "_astrology_score": round(score, 3)}
            scored.append(scored_item)

        scored.sort(key=lambda row: row.get("_astrology_score", 0.0), reverse=True)
        return scored

    def _build_wardrobe_picks(
        self,
        scored_items: List[Dict[str, Any]],
        *,
        limit_per_category: int,
    ) -> List[Dict[str, Any]]:
        picks: List[Dict[str, Any]] = []
        for category in _CATEGORY_ORDER:
            category_items = [row for row in scored_items if str(row.get("category") or "").lower() == category]
            category_items = category_items[:limit_per_category]
            if not category_items:
                continue
            picks.append(
                {
                    "category": category,
                    "items": [self._sanitize_item_payload(row) for row in category_items],
                }
            )
        return picks

    def _build_suggested_outfits(
        self,
        *,
        wardrobe_picks: List[Dict[str, Any]],
        mode: str,
    ) -> List[Dict[str, Any]]:
        by_category = {row["category"]: row["items"] for row in wardrobe_picks}
        ordered_slots = ["tops", "bottoms", "shoes", "outerwear", "accessories"]

        suggestions: List[Dict[str, Any]] = []
        for idx in range(3):
            selected_item_ids: List[str] = []
            for category in ordered_slots:
                items = by_category.get(category) or []
                if len(items) > idx:
                    item_id = items[idx].get("id")
                    if item_id:
                        selected_item_ids.append(str(item_id))
            if len(selected_item_ids) < 2:
                continue

            base_score = 84 if mode == "important_meeting" else 78
            suggestions.append(
                {
                    "description": (
                        "Meeting-ready contrast look"
                        if mode == "important_meeting"
                        else "Day-wise balanced look"
                    ),
                    "item_ids": selected_item_ids,
                    "match_score": max(65, base_score - (idx * 4)),
                }
            )
        return suggestions

    def _sanitize_item_payload(self, item: Dict[str, Any]) -> Dict[str, Any]:
        clean_item = dict(item)
        clean_item.pop("_astrology_score", None)
        return clean_item

    def _normalize_color_name(self, color_value: str) -> Optional[str]:
        raw = (color_value or "").strip().lower()
        if not raw:
            return None
        if raw in _COLOR_SYNONYMS:
            return _COLOR_SYNONYMS[raw]

        for canonical, meta in _COLOR_LIBRARY.items():
            keywords = meta.get("keywords", set())
            if raw == canonical:
                return canonical
            if raw in keywords:
                return canonical
            if any(keyword in raw for keyword in keywords):
                return canonical
        return raw

    def _safe_timezone(self, timezone_name: Optional[str]) -> timezone | ZoneInfo:
        if not timezone_name:
            return timezone.utc
        try:
            return ZoneInfo(timezone_name)
        except Exception:
            return timezone.utc

    def _sidereal_sun_sign(self, target_date: date) -> str:
        """Approximate sidereal sun sign windows."""
        md = (target_date.month, target_date.day)
        if (4, 14) <= md <= (5, 14):
            return "Aries"
        if (5, 15) <= md <= (6, 14):
            return "Taurus"
        if (6, 15) <= md <= (7, 15):
            return "Gemini"
        if (7, 16) <= md <= (8, 16):
            return "Cancer"
        if (8, 17) <= md <= (9, 16):
            return "Leo"
        if (9, 17) <= md <= (10, 17):
            return "Virgo"
        if (10, 18) <= md <= (11, 16):
            return "Libra"
        if (11, 17) <= md <= (12, 15):
            return "Scorpio"
        if md >= (12, 16) or md <= (1, 13):
            return "Sagittarius"
        if (1, 14) <= md <= (2, 12):
            return "Capricorn"
        if (2, 13) <= md <= (3, 14):
            return "Aquarius"
        return "Pisces"


astrology_service = AstrologyService()


def get_astrology_service() -> AstrologyService:
    """Dependency-safe astrology service getter."""
    return astrology_service

