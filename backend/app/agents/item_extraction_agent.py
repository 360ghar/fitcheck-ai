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
import uuid
from typing import Any, Dict, List, Optional

from app.core.logging_config import get_context_logger
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import AISettingsService
from app.utils.json_utils import safe_extract_json_array, safe_extract_json_object

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
8. boundingBox — see BOUNDING BOX RULES below
9. detailedDescription — see DETAILED DESCRIPTION RULES below (critical for image generation fidelity)
10. person_id
11. person_label
12. is_current_user_person

DETAILED DESCRIPTION RULES (critical — this paragraph drives the image generator):
Write ONE dense paragraph (>= 35 words) covering these visual categories IN THIS
EXACT ORDER, separated by ";":
  cut/silhouette; colorway; print or graphic content; pattern geometry if any;
  collar/neckline; sleeve style + length; hem length + shape; pockets/buttons/zips;
  fabric weave + weight; surface texture + sheen + distress; hardware color + finish;
  logo/branding placement + scale; fit note; other distinctive marks.
- Use only OBSERVABLE visual facts. No vague praise (nice, stylish, modern, trendy,
  fashionable, beautiful). No guesses about price or fabric composition if not visible.
- If a category does not apply (e.g. a t-shirt has no hardware), write "none" for it.
- Examples:
  "crew-neck cropped t-shirt; off-white base with charcoal sleeves; small front-left
   embroidered tiger graphic; solid no pattern; ribbed crew collar; short set-in
   sleeves; straight cropped hem at waist; no pockets; plain-weave cotton midweight;
   matte soft hand no distress; none; no visible logo; relaxed cropped fit; faint
   yellowing at collar"
  "high-rise wide-leg jeans; mid-blue indigo wash; no print; faded vertical
   honeycomb whiskering at hips; classic 5-pocket waist with belt loops; full
   length raw hem; front slash + back patch pockets; 12oz twill denim; matte
   broken-in mild knee bagging; antiqued brass rivets; leather patch back-right
   waist; slim-straight through thigh wide from knee; contrast orange bartack
   stitching"


BOUNDING BOX RULES (critical — boxes are used for crops and overlays):
- Format: object with x, y, width, height.
- Units: percentages of the FULL image (0 to 100). Not pixels. Not 0–1 fractions.
- Origin: top-left of the image. x increases right, y increases down.
- x,y = top-left corner of a TIGHT box around THAT garment only.
- width/height = box size as percent of image width/height.
- Keep the box tight: include the full garment with ~2–5% padding; do not include
  other people, unrelated clothing, or large empty background.
- Category guidance (approximate location):
  - tops/outerwear → torso / upper body
  - bottoms → waist to ankles
  - shoes → near the feet
  - accessories → only the accessory itself
- One box per item. If you cannot locate the item, set boundingBox to null.
- Never use a near full-image box (e.g. width/height ~100) unless the item truly fills the frame.
- Example: a shirt on the left half might be {{"x": 18, "y": 12, "width": 42, "height": 48}}.

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


def _normalize_bounding_box(raw: Any) -> Optional[Dict[str, float]]:
    """Normalize model bounding boxes to {x, y, width, height} percentages 0–100.

    Accepts common VLM variants:
    - xywh dict: {x, y, width, height}
    - xyxy dict: {x1, y1, x2, y2} or {left, top, right, bottom}
    - list/tuple of 4 numbers treated as xyxy (x1, y1, x2, y2)

    The prompt and response schema mandate percent 0–100, so dict boxes are
    taken verbatim; only unambiguous foreign scales are rescaled.
    """
    if raw is None:
        return None

    x1: Optional[float] = None
    y1: Optional[float] = None
    x2: Optional[float] = None
    y2: Optional[float] = None
    is_xywh = False
    is_dict = isinstance(raw, dict)

    if is_dict:
        if all(k in raw for k in ("x", "y", "width", "height")):
            x1 = _to_float(raw.get("x"), 0.0)
            y1 = _to_float(raw.get("y"), 0.0)
            x2 = _to_float(raw.get("width"), 0.0)
            y2 = _to_float(raw.get("height"), 0.0)
            is_xywh = True
        elif all(k in raw for k in ("x1", "y1", "x2", "y2")):
            x1 = _to_float(raw.get("x1"), 0.0)
            y1 = _to_float(raw.get("y1"), 0.0)
            x2 = _to_float(raw.get("x2"), 0.0)
            y2 = _to_float(raw.get("y2"), 0.0)
        elif all(k in raw for k in ("left", "top", "right", "bottom")):
            x1 = _to_float(raw.get("left"), 0.0)
            y1 = _to_float(raw.get("top"), 0.0)
            x2 = _to_float(raw.get("right"), 0.0)
            y2 = _to_float(raw.get("bottom"), 0.0)
        else:
            return None
    elif isinstance(raw, (list, tuple)) and len(raw) == 4:
        x1, y1, x2, y2 = (_to_float(v, 0.0) for v in raw)
    else:
        return None

    # Scale normalization:
    # - max_v > 150 → unambiguously not percent: 0–1000 style (legacy/Gemini
    #   rows) → ×0.1. The 150 threshold (not 100) so a percent box that
    #   slightly overflows the frame (e.g. height=102, which the clamp below
    #   exists to fix) is clamped in-frame instead of being shrunk 10×.
    # - max_v <= 1 → 0–1 fractions, guessed ONLY for non-schema list input.
    #   Never for dict boxes: the contract says percent, and ×100 blew up
    #   legitimate sub-1% percent boxes (tiny accessories) into
    #   near-full-frame crops. Sub-1% dict boxes instead fall afoul of the
    #   1% floor below and yield no box — better than a wrong giant crop.
    vals = [x1, y1, x2, y2]
    max_v = max(abs(v) for v in vals)
    if max_v > 150.0:
        x1, y1, x2, y2 = x1 * 0.1, y1 * 0.1, x2 * 0.1, y2 * 0.1
    elif max_v <= 1.0 and not is_dict:
        x1, y1, x2, y2 = x1 * 100.0, y1 * 100.0, x2 * 100.0, y2 * 100.0

    if is_xywh:
        x, y, w, h = x1, y1, x2, y2
    else:
        # xyxy → xywh
        x = min(x1, x2)
        y = min(y1, y2)
        w = abs(x2 - x1)
        h = abs(y2 - y1)

    if w <= 0 or h <= 0:
        return None

    x = max(0.0, min(100.0, x))
    y = max(0.0, min(100.0, y))
    w = max(0.0, min(100.0 - x, w))
    h = max(0.0, min(100.0 - y, h))

    if w < 1.0 or h < 1.0:
        return None

    return {
        "x": round(x, 2),
        "y": round(y, 2),
        "width": round(w, 2),
        "height": round(h, 2),
    }


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
            if not parsed:
                # Some providers skip the envelope and return the item array
                # at the top level; normalize it so a valid detection is not
                # reported as "No items found".
                bare_items = safe_extract_json_array(response.text or "")
                if isinstance(bare_items, list):
                    parsed = {"items": bare_items}
            if not parsed or not isinstance(parsed, dict):
                raw_text = response.text or ""
                stripped_text = raw_text.strip()
                logger.warning(
                    "Failed to parse item extraction response",
                    response_length=len(raw_text),
                    first_char=stripped_text[:1],
                    last_char=stripped_text[-1:],
                    response_preview=raw_text[:120].replace("\n", "\\n"),
                )
                return self._empty_result(
                    raw_text or "Unable to analyze image",
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
            logger.error(
                "Item extraction failed",
                error=str(e),
                error_type=type(e).__name__,
                has_profile_reference=has_profile_reference,
            )
            return self._empty_result(
                "Unable to analyze image automatically",
                has_profile_reference=has_profile_reference,
            )

    def _parse_json_object(self, text: str) -> Optional[Dict[str, Any]]:
        """Parse a JSON object from the model response, or None.

        JSON-first, then a quote/escape-aware block extraction as fallback
        (survives braces/escaped quotes inside string values, which used to
        truncate the block and fail extraction on valid photos). Returns
        only objects; callers that tolerate a bare array handle it
        themselves.
        """
        stripped = (text or "").strip()
        if not stripped:
            return None

        try:
            parsed = json.loads(stripped)
            if isinstance(parsed, dict):
                return parsed
        except json.JSONDecodeError:
            pass

        return safe_extract_json_object(stripped)

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

            bounding_box = _normalize_bounding_box(
                item.get("boundingBox") or item.get("bounding_box")
            )

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
            logger.error(
                "Single item extraction failed",
                error=str(e),
                error_type=type(e).__name__,
                category_hint=category_hint,
            )
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

            parsed = safe_extract_json_array(response.text)

            if isinstance(parsed, list):
                return [str(c).lower() for c in parsed]

            return []

        except Exception as e:
            logger.error(
                "Color detection failed",
                error=str(e),
                error_type=type(e).__name__,
            )
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
        """Generate a fallback description from item attributes.

        Only used when the VLM returned an empty detailedDescription — the
        prompt asks for a 35+ word paragraph, so this fallback is a last
        resort. Build the densest description we can from whatever structured
        fields are present, covering silhouette, color, material, pattern, and
        branding when available.
        """
        parts: List[str] = []

        # Silhouette / cut
        sub = _clean_text(item.get("sub_category"))
        cat = _normalize_category(item.get("category", ""))
        silhouette = sub or cat or "clothing item"
        parts.append(silhouette)

        # Colorway
        colors = item.get("colors") or []
        colors = [str(c).strip().lower() for c in colors if str(c).strip()]
        if colors:
            parts.append(f"in {', '.join(colors)}")

        # Material / fabric weight
        material = _clean_text(item.get("material"))
        if material:
            parts.append(f"made of {material}")

        # Pattern / print geometry
        pattern = _clean_text(item.get("pattern"))
        if pattern and pattern.lower() not in {"solid", "none", "plain"}:
            parts.append(f"with {pattern} pattern")
        elif pattern:
            parts.append("solid colorway")

        # Brand / logo placement
        brand = _clean_text(item.get("brand"))
        if brand:
            parts.append(f"by {brand}")

        # If we still have very little, pad with category so the image-gen
        # prompt has at least silhouette + color to anchor on.
        description = "; ".join(p for p in parts if p)
        if len(description.split()) < 10:
            description = f"{description}; further visual details not specified"
        return description


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
