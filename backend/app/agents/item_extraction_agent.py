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
from typing import Any, Dict, List, Optional

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService, ChatMessage
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


# =============================================================================
# PROMPTS
# =============================================================================


MULTI_ITEM_EXTRACTION_PROMPT = """Analyze this clothing image and identify ALL visible clothing items.

IMPORTANT: Focus ONLY on the main subject(s) in the foreground of the image.
Ignore any people in the background and their clothing.
Only extract clothing items that are clearly worn by the primary person(s) in the image.

For EACH item, provide:
1. category (must be one of: tops, bottoms, shoes, accessories, outerwear, swimwear, activewear, other)
2. sub_category (e.g., "t-shirt", "jeans", "sneakers", "handbag")
3. colors (array of colors in lowercase)
4. material (e.g., cotton, denim, leather, silk, wool)
5. pattern (e.g., solid, striped, plaid, floral, checkered)
6. brand (if visible logo, otherwise null)
7. confidence (0.0 to 1.0)
8. boundingBox (approximate location as percentages 0-100: x, y, width, height where x,y is top-left corner)
9. detailedDescription (a VERY detailed description of this specific item for image generation, including:
   - Exact style and cut (e.g., "slim fit", "oversized", "high-waisted")
   - Precise color shades (e.g., "deep navy blue", "heather gray")
   - Material texture and finish (e.g., "soft cotton jersey", "distressed denim")
   - Design details like buttons, zippers, seams, pockets, collars, cuffs
   - Any logos, prints, graphics, or embellishments
   - Overall aesthetic and condition)

Return ONLY valid JSON in this exact format:
{
  "items": [
    {
      "category": "tops",
      "sub_category": "t-shirt",
      "colors": ["navy blue"],
      "material": "cotton",
      "pattern": "solid",
      "brand": null,
      "confidence": 0.95,
      "boundingBox": { "x": 20, "y": 10, "width": 40, "height": 50 },
      "detailedDescription": "A classic crew-neck short-sleeve t-shirt in deep navy blue cotton jersey. The fabric has a soft, slightly textured finish. Features a ribbed crew neckline with reinforced stitching, set-in sleeves with double-needle hemming, and a straight hem. The fit appears relaxed and casual. Clean, minimal design with no visible logos or prints."
    }
  ],
  "overall_confidence": 0.92,
  "image_description": "Person wearing casual outfit with multiple clothing items",
  "item_count": 3
}"""


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
    # Try to find JSON object
    match = re.search(r'\{[\s\S]*\}', text)
    if not match:
        return None
    try:
        return json.loads(match.group(0))
    except json.JSONDecodeError:
        return None


def _safe_json_array_extract(text: str) -> Optional[List[Any]]:
    """Extract JSON array from text response."""
    match = re.search(r'\[[\s\S]*\]', text)
    if not match:
        return None
    try:
        return json.loads(match.group(0))
    except json.JSONDecodeError:
        return None


def _generate_temp_id() -> str:
    """Generate a temporary ID for detected items."""
    return f"item-{uuid.uuid4().hex[:8]}"


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
    ) -> Dict[str, Any]:
        """
        Extract ALL items from an image with bounding boxes and detailed descriptions.

        Args:
            image_base64: Base64-encoded image

        Returns:
            MultiItemDetectionResult dict with items, confidence, etc.
        """
        logger.debug("Extracting multiple items from image")

        try:
            response = await self.ai_service.chat_with_vision(
                prompt=MULTI_ITEM_EXTRACTION_PROMPT,
                images=[image_base64],
            )

            if not response.text:
                logger.warning("Empty response from AI for item extraction")
                return self._empty_result("Unable to analyze image automatically")

            parsed = _safe_json_extract(response.text)

            if not parsed or not isinstance(parsed, dict):
                logger.warning("Failed to parse item extraction response", response=response.text[:200])
                return self._empty_result(response.text or "Unable to analyze image")

            # Process items
            items = []
            raw_items = parsed.get("items", [])

            for i, item in enumerate(raw_items):
                if not isinstance(item, dict):
                    continue

                bounding_box = None
                if item.get("boundingBox"):
                    bb = item["boundingBox"]
                    bounding_box = {
                        "x": float(bb.get("x", 0)),
                        "y": float(bb.get("y", 0)),
                        "width": float(bb.get("width", 100)),
                        "height": float(bb.get("height", 100)),
                    }

                colors = item.get("colors", [])
                if isinstance(colors, list):
                    colors = [str(c).lower() for c in colors]
                else:
                    colors = []

                processed_item = {
                    "temp_id": _generate_temp_id(),
                    "category": _normalize_category(item.get("category", "")),
                    "sub_category": item.get("sub_category"),
                    "colors": colors,
                    "material": item.get("material"),
                    "pattern": item.get("pattern"),
                    "brand": item.get("brand"),
                    "confidence": float(item.get("confidence", 0.5)),
                    "bounding_box": bounding_box,
                    "detailed_description": item.get("detailedDescription") or self._generate_default_description(item),
                    "status": "detected",
                }
                items.append(processed_item)

            overall_confidence = float(parsed.get("overall_confidence", 0.5))
            low_confidence_count = sum(1 for item in items if item["confidence"] < 0.7)

            return {
                "items": items,
                "overall_confidence": overall_confidence,
                "image_description": str(parsed.get("image_description", "")),
                "item_count": len(items),
                "requires_review": low_confidence_count > 0 or len(items) == 0,
            }

        except AIServiceError:
            raise
        except Exception as e:
            logger.error("Item extraction failed", error=str(e))
            return self._empty_result("Unable to analyze image automatically")

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

            parsed = _safe_json_extract(response.text)

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
                "confidence": float(parsed.get("confidence", 0.5)),
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

    def _empty_result(self, description: str = "") -> Dict[str, Any]:
        """Return an empty extraction result."""
        return {
            "items": [],
            "overall_confidence": 0,
            "image_description": description,
            "item_count": 0,
            "requires_review": True,
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
