"""
Item Extraction Agent - Backend AI agent for clothing item detection.

This agent replaces the frontend itemExtractionAgent that used Puter.js.

Features:
- Extract single item from image
- Extract multiple items with bounding boxes
- Detect colors from image
- Generate detailed descriptions for image generation
"""

import json
import re
import uuid
from typing import Any, Dict, List, Optional, Tuple

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import AISettingsService

logger = get_context_logger(__name__)


# =============================================================================
# CONSTANTS
# =============================================================================


VALID_CATEGORIES = [
    "tops",
    "bottoms",
    "shoes",
    "accessories",
    "outerwear",
    "swimwear",
    "activewear",
    "other",
]


MULTI_ITEM_RESPONSE_FORMAT: Dict[str, Any] = {
    "type": "json_schema",
    "json_schema": {
        "name": "fitcheck_multi_item_extraction",
        "strict": True,
        "schema": {
            "type": "object",
            "additionalProperties": False,
            "properties": {
                "items": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "category": {"type": "string"},
                            "sub_category": {"type": ["string", "null"]},
                            "colors": {
                                "type": "array",
                                "items": {"type": "string"},
                            },
                            "material": {"type": ["string", "null"]},
                            "pattern": {"type": ["string", "null"]},
                            "brand": {"type": ["string", "null"]},
                            "confidence": {"type": "number"},
                            "boundingBox": {
                                "type": ["object", "null"],
                                "additionalProperties": False,
                                "properties": {
                                    "x": {"type": "number"},
                                    "y": {"type": "number"},
                                    "width": {"type": "number"},
                                    "height": {"type": "number"},
                                },
                                "required": ["x", "y", "width", "height"],
                            },
                            "detailedDescription": {"type": ["string", "null"]},
                            "person_id": {"type": ["string", "null"]},
                            "person_label": {"type": ["string", "null"]},
                            "is_current_user_person": {"type": ["boolean", "null"]},
                        },
                        "required": [
                            "category",
                            "sub_category",
                            "colors",
                            "material",
                            "pattern",
                            "brand",
                            "confidence",
                            "boundingBox",
                            "detailedDescription",
                            "person_id",
                            "person_label",
                            "is_current_user_person",
                        ],
                    },
                },
                "people": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "additionalProperties": False,
                        "properties": {
                            "person_id": {"type": "string"},
                            "person_label": {"type": "string"},
                            "is_current_user_person": {"type": "boolean"},
                            "confidence": {"type": "number"},
                        },
                        "required": [
                            "person_id",
                            "person_label",
                            "is_current_user_person",
                            "confidence",
                        ],
                    },
                },
                "overall_confidence": {"type": "number"},
                "image_description": {"type": "string"},
                "item_count": {"type": "integer"},
                "profile_match_found": {"type": "boolean"},
            },
            "required": [
                "items",
                "people",
                "overall_confidence",
                "image_description",
                "item_count",
                "profile_match_found",
            ],
        },
    },
}


# =============================================================================
# PROMPTS
# =============================================================================


def _build_multi_item_extraction_prompt(has_profile_reference: bool) -> str:
    if has_profile_reference:
        reference_text = """
You are given TWO images:
- Image 1: outfit photo to extract clothing from.
- Image 2: the current user's profile picture.

Match the current user in Image 1 against Image 2 and set is_current_user_person=true only for that matched person.
If no confident match exists, set is_current_user_person=false for everyone and profile_match_found=false.
"""
    else:
        reference_text = """
You are given one outfit photo only. There is no profile reference image.
Set is_current_user_person=false for all people and profile_match_found=false.
"""

    return f"""Analyze the outfit photo and detect ALL visible clothing items worn by foreground people.
Ignore background crowd members and non-wearable objects.

{reference_text}

For each detected item:
1. category (one of: tops, bottoms, shoes, accessories, outerwear, swimwear, activewear, other)
2. sub_category
3. colors (lowercase array)
4. material
5. pattern
6. brand (null if unknown)
7. confidence (0.0 to 1.0)
8. boundingBox (x,y,width,height percentages from 0 to 100)
9. detailedDescription (detailed product-quality description)
10. person_id
11. person_label
12. is_current_user_person

Also return people[] summary with:
- person_id
- person_label
- is_current_user_person
- confidence

Return JSON only according to the schema.
"""


SINGLE_ITEM_EXTRACTION_PROMPT = """Analyze this clothing image and describe the single item shown.{category_hint}

IMPORTANT: Focus ONLY on the main subject in the foreground.
Ignore background elements and people.

Provide:
1. category (tops, bottoms, shoes, accessories, outerwear, swimwear, activewear, other)
2. sub_category
3. colors (array, lowercase where possible)
4. material
5. pattern
6. brand (if visible, otherwise null)
7. confidence (0-1)

Return ONLY valid JSON in this exact format:
{
  "category": "tops",
  "sub_category": "t-shirt",
  "colors": ["blue"],
  "material": "cotton",
  "pattern": "solid",
  "brand": null,
  "confidence": 0.9,
  "description": "A blue cotton t-shirt"
}"""


COLOR_DETECTION_PROMPT = """Identify the dominant colors in this clothing image.

Return only a JSON array of lowercase color names (e.g. ["black", "white", "navy"])."""


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================


def _normalize_category(value: str) -> str:
    """Normalize category to valid value."""
    v = str(value or "").strip().lower()
    return v if v in VALID_CATEGORIES else "other"


def _safe_json_extract(text: str) -> Optional[Dict[str, Any]]:
    """Extract JSON object from text response."""
    match = re.search(r"\{[\s\S]*\}", text)
    if not match:
        return None
    try:
        return json.loads(match.group(0))
    except json.JSONDecodeError:
        return None


def _safe_json_array_extract(text: str) -> Optional[List[Any]]:
    """Extract JSON array from text response."""
    match = re.search(r"\[[\s\S]*\]", text)
    if not match:
        return None
    try:
        return json.loads(match.group(0))
    except json.JSONDecodeError:
        return None


def _generate_temp_id() -> str:
    """Generate a temporary ID for detected items."""
    return f"item-{uuid.uuid4().hex[:8]}"


def _to_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _clamp_confidence(value: Any, default: float = 0.5) -> float:
    confidence = _to_float(value, default)
    return max(0.0, min(1.0, confidence))


def _to_bool(value: Any, default: bool = False) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        v = value.strip().lower()
        if v in {"true", "1", "yes"}:
            return True
        if v in {"false", "0", "no"}:
            return False
    return default


def _clean_text(value: Any) -> Optional[str]:
    if value is None:
        return None
    s = str(value).strip()
    return s or None


# =============================================================================
# ITEM EXTRACTION AGENT
# =============================================================================


class ItemExtractionAgent:
    """Agent for extracting clothing items from images."""

    def __init__(self, ai_service: AIProviderService):
        """Initialize with an AI service instance."""
        self.ai_service = ai_service

    async def extract_multiple_items(
        self,
        image_base64: str,
        user_profile_image_base64: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Extract ALL items from an image with bounding boxes and detailed descriptions.

        Args:
            image_base64: Base64-encoded image
            user_profile_image_base64: Optional profile picture for person matching

        Returns:
            MultiItemDetectionResult dict with items, confidence, etc.
        """
        has_profile_reference = bool(user_profile_image_base64)
        logger.debug(
            "Extracting multiple items from image",
            has_profile_reference=has_profile_reference,
        )

        try:
            prompt = _build_multi_item_extraction_prompt(has_profile_reference)
            images = [image_base64]
            if user_profile_image_base64:
                images.append(user_profile_image_base64)

            response = await self.ai_service.chat_with_vision(
                prompt=prompt,
                images=images,
                response_format=MULTI_ITEM_RESPONSE_FORMAT,
            )

            if not response.text:
                logger.warning("Empty response from AI for item extraction")
                return self._empty_result(
                    "Unable to analyze image automatically",
                    has_profile_reference=has_profile_reference,
                )

            parsed = self._parse_json_object(response.text)
            if not parsed or not isinstance(parsed, dict):
                logger.warning(
                    "Failed to parse item extraction response",
                    response=response.text[:200],
                )
                return self._empty_result(
                    response.text or "Unable to analyze image",
                    has_profile_reference=has_profile_reference,
                )

            processed = self._process_multi_item_result(
                parsed=parsed,
                has_profile_reference=has_profile_reference,
            )
            return processed

        except AIServiceError:
            raise
        except Exception as e:
            logger.error("Item extraction failed", error=str(e))
            return self._empty_result(
                "Unable to analyze image automatically",
                has_profile_reference=has_profile_reference,
            )

    def _parse_json_object(self, text: str) -> Optional[Dict[str, Any]]:
        """Parse structured response with JSON-first strategy and regex fallback."""
        stripped = (text or "").strip()
        if not stripped:
            return None

        try:
            parsed = json.loads(stripped)
            if isinstance(parsed, dict):
                return parsed
        except json.JSONDecodeError:
            pass

        return _safe_json_extract(stripped)

    def _process_multi_item_result(
        self,
        parsed: Dict[str, Any],
        has_profile_reference: bool,
    ) -> Dict[str, Any]:
        items: List[Dict[str, Any]] = []
        raw_items = parsed.get("items", [])
        raw_people = parsed.get("people", [])

        person_order: List[str] = []
        person_lookup: Dict[str, Dict[str, Any]] = {}
        raw_to_canonical: Dict[str, str] = {}

        def ensure_person(
            raw_person_id: Any,
            raw_person_label: Any,
            is_current_user_person: bool,
            confidence: float,
        ) -> str:
            raw_id = _clean_text(raw_person_id)
            canonical = raw_to_canonical.get(raw_id or "") if raw_id else None
            if not canonical:
                canonical = f"person_{len(person_order) + 1}"
                person_order.append(canonical)
                if raw_id:
                    raw_to_canonical[raw_id] = canonical
                person_lookup[canonical] = {
                    "person_id": canonical,
                    "person_label": _clean_text(raw_person_label),
                    "is_current_user_person": bool(is_current_user_person),
                    "confidence": _clamp_confidence(confidence, 0.0),
                }
            else:
                meta = person_lookup[canonical]
                meta["is_current_user_person"] = bool(
                    meta.get("is_current_user_person") or is_current_user_person
                )
                meta["confidence"] = max(
                    _clamp_confidence(meta.get("confidence"), 0.0),
                    _clamp_confidence(confidence, 0.0),
                )
                if not meta.get("person_label"):
                    meta["person_label"] = _clean_text(raw_person_label)

            return canonical

        for person in raw_people:
            if not isinstance(person, dict):
                continue
            ensure_person(
                raw_person_id=person.get("person_id") or person.get("id"),
                raw_person_label=person.get("person_label") or person.get("label"),
                is_current_user_person=_to_bool(person.get("is_current_user_person"), False),
                confidence=_clamp_confidence(person.get("confidence"), 0.0),
            )

        for item in raw_items:
            if not isinstance(item, dict):
                continue

            bounding_box = None
            raw_bb = item.get("boundingBox") or item.get("bounding_box")
            if isinstance(raw_bb, dict):
                bounding_box = {
                    "x": _to_float(raw_bb.get("x"), 0.0),
                    "y": _to_float(raw_bb.get("y"), 0.0),
                    "width": _to_float(raw_bb.get("width"), 100.0),
                    "height": _to_float(raw_bb.get("height"), 100.0),
                }

            colors_raw = item.get("colors", [])
            colors = (
                [str(c).strip().lower() for c in colors_raw if str(c).strip()]
                if isinstance(colors_raw, list)
                else []
            )

            item_confidence = _clamp_confidence(item.get("confidence"), 0.5)
            item_is_current_user = _to_bool(item.get("is_current_user_person"), False)

            person_id = ensure_person(
                raw_person_id=item.get("person_id") or item.get("personId"),
                raw_person_label=item.get("person_label") or item.get("personLabel"),
                is_current_user_person=item_is_current_user,
                confidence=item_confidence,
            )

            processed_item = {
                "temp_id": _generate_temp_id(),
                "category": _normalize_category(item.get("category", "")),
                "sub_category": _clean_text(item.get("sub_category") or item.get("subCategory")),
                "colors": colors,
                "material": _clean_text(item.get("material")),
                "pattern": _clean_text(item.get("pattern")),
                "brand": _clean_text(item.get("brand")),
                "confidence": item_confidence,
                "bounding_box": bounding_box,
                "detailed_description": _clean_text(item.get("detailedDescription"))
                or self._generate_default_description(item),
                "status": "detected",
                "person_id": person_id,
                "person_label": None,
                "is_current_user_person": item_is_current_user,
                "include_in_wardrobe": True,
            }
            items.append(processed_item)

        current_user_count = sum(1 for item in items if item.get("is_current_user_person"))
        profile_match_found = has_profile_reference and (
            _to_bool(parsed.get("profile_match_found"), False) or current_user_count > 0
        )

        if not has_profile_reference:
            for item in items:
                item["is_current_user_person"] = False

        if has_profile_reference and profile_match_found:
            for item in items:
                item["include_in_wardrobe"] = bool(item.get("is_current_user_person"))
        else:
            for item in items:
                item["include_in_wardrobe"] = True

        used_person_ids = {item["person_id"] for item in items}
        if not used_person_ids and items:
            used_person_ids = {"person_1"}

        non_current_counter = 1
        people: List[Dict[str, Any]] = []
        for person_id in person_order:
            if person_id not in used_person_ids:
                continue

            meta = person_lookup.get(person_id, {})
            is_current = bool(meta.get("is_current_user_person", False))
            label = _clean_text(meta.get("person_label"))

            if has_profile_reference and profile_match_found and is_current:
                label = "You"
            else:
                if not label or label.lower() in {"you", "current user", "current_user"}:
                    label = f"Person {non_current_counter}"
                non_current_counter += 1

            meta["person_label"] = label
            person_lookup[person_id] = meta

            people.append(
                {
                    "person_id": person_id,
                    "person_label": label,
                    "is_current_user_person": bool(is_current and profile_match_found),
                    "confidence": _clamp_confidence(meta.get("confidence"), 0.0),
                }
            )

        for item in items:
            meta = person_lookup.get(item["person_id"], {})
            item["person_label"] = meta.get("person_label") or "Person"
            if not profile_match_found:
                item["is_current_user_person"] = False

        overall_confidence = _clamp_confidence(parsed.get("overall_confidence"), 0.5)
        low_confidence_count = sum(1 for item in items if item["confidence"] < 0.7)

        return {
            "items": items,
            "people": people,
            "overall_confidence": overall_confidence,
            "image_description": str(parsed.get("image_description", "")),
            "item_count": len(items),
            "requires_review": low_confidence_count > 0 or len(items) == 0,
            "has_profile_reference": has_profile_reference,
            "profile_match_found": profile_match_found,
        }

    async def extract_single_item(
        self,
        image_base64: str,
        category_hint: Optional[str] = None,
    ) -> Dict[str, Any]:
        """
        Extract a single item from an image.

        Args:
            image_base64: Base64-encoded image
            category_hint: Optional hint about the item category

        Returns:
            Extracted item dict
        """
        logger.debug("Extracting single item from image", category_hint=category_hint)

        hint_text = f" The item is likely a {category_hint}." if category_hint else ""
        prompt = SINGLE_ITEM_EXTRACTION_PROMPT.format(category_hint=hint_text)

        try:
            response = await self.ai_service.chat_with_vision(
                prompt=prompt,
                images=[image_base64],
            )

            if not response.text:
                return self._empty_single_item()

            parsed = self._parse_json_object(response.text)

            if not parsed or not isinstance(parsed, dict):
                return {
                    "category": "other",
                    "colors": [],
                    "confidence": 0,
                    "description": response.text,
                }

            colors = parsed.get("colors", [])
            if isinstance(colors, list):
                colors = [str(c).lower() for c in colors]
            else:
                colors = []

            return {
                "category": _normalize_category(parsed.get("category", "")),
                "sub_category": parsed.get("sub_category"),
                "colors": colors,
                "material": parsed.get("material"),
                "pattern": parsed.get("pattern"),
                "brand": parsed.get("brand"),
                "confidence": _clamp_confidence(parsed.get("confidence"), 0.5),
                "description": parsed.get("description"),
            }

        except AIServiceError:
            raise
        except Exception as e:
            logger.error("Single item extraction failed", error=str(e))
            return self._empty_single_item()

    async def detect_colors(
        self,
        image_base64: str,
    ) -> List[str]:
        """
        Detect dominant colors in an image.

        Args:
            image_base64: Base64-encoded image

        Returns:
            List of color names
        """
        logger.debug("Detecting colors from image")

        try:
            response = await self.ai_service.chat_with_vision(
                prompt=COLOR_DETECTION_PROMPT,
                images=[image_base64],
            )

            if not response.text:
                return []

            parsed = _safe_json_array_extract(response.text)

            if isinstance(parsed, list):
                return [str(c).lower() for c in parsed]

            return []

        except Exception as e:
            logger.error("Color detection failed", error=str(e))
            return []

    def _empty_result(self, description: str = "", has_profile_reference: bool = False) -> Dict[str, Any]:
        """Return an empty extraction result."""
        return {
            "items": [],
            "people": [],
            "overall_confidence": 0,
            "image_description": description,
            "item_count": 0,
            "requires_review": True,
            "has_profile_reference": has_profile_reference,
            "profile_match_found": False,
        }

    def _empty_single_item(self) -> Dict[str, Any]:
        """Return an empty single item result."""
        return {
            "category": "other",
            "colors": [],
            "confidence": 0,
        }

    def _generate_default_description(self, item: Dict[str, Any]) -> str:
        """Generate a default description from item attributes."""
        parts = []

        if item.get("sub_category"):
            parts.append(f"A {item['sub_category']}")
        elif item.get("category"):
            parts.append(f"A {item['category']}")
        else:
            parts.append("A clothing item")

        colors = item.get("colors", [])
        if colors:
            parts.append(f"in {' and '.join(colors)}")

        if item.get("material"):
            parts.append(f"made of {item['material']}")

        return " ".join(parts)


# =============================================================================
# FACTORY FUNCTION
# =============================================================================


async def get_item_extraction_agent(
    user_id: str,
    db,
) -> ItemExtractionAgent:
    """
    Get an item extraction agent configured for a user.

    Args:
        user_id: The user's ID
        db: Supabase client

    Returns:
        Configured ItemExtractionAgent
    """
    ai_service = await AISettingsService.get_ai_service_for_user(user_id, db)
    return ItemExtractionAgent(ai_service)
