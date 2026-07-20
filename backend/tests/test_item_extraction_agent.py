import json

import pytest

from app.agents.item_extraction_agent import (
    ItemExtractionAgent,
    _normalize_bounding_box,
)
from app.services.ai_provider_service import AIResponse


# =============================================================================
# Bounding box normalization
# =============================================================================


def test_normalize_bounding_box_xywh_percent():
    assert _normalize_bounding_box({"x": 10, "y": 20, "width": 30, "height": 40}) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_dict_values_below_1_are_not_scaled():
    """Dict boxes are percent verbatim per the prompt/schema contract.

    Values ≤ 1 used to be treated as 0–1 fractions and multiplied by 100,
    which blew up legitimate sub-1% percent boxes (tiny accessories) into
    near-full-frame crops. They are now left alone; the 1% floor rejects
    them. The 0–1 guess survives only for non-schema list input.
    """
    assert _normalize_bounding_box(
        {"x": 0.1, "y": 0.2, "width": 0.3, "height": 0.4}
    ) is None
    assert _normalize_bounding_box([0.1, 0.2, 0.4, 0.6]) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_percent_overflow_is_clamped_not_shrunk():
    """A percent box slightly over 100 is clamped into the frame, not
    misread as 0–1000 scale and shrunk to a corner sliver."""
    assert _normalize_bounding_box({"x": 5, "y": 10, "width": 90, "height": 102}) == {
        "x": 5.0,
        "y": 10.0,
        "width": 90.0,
        "height": 90.0,
    }


def test_normalize_bounding_box_xyxy():
    assert _normalize_bounding_box({"x1": 10, "y1": 20, "x2": 40, "y2": 60}) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_0_1000_scale():
    # Gemini-style 0–1000 coordinates
    assert _normalize_bounding_box({"x1": 100, "y1": 200, "x2": 400, "y2": 600}) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_list_xyxy():
    assert _normalize_bounding_box([10, 20, 40, 60]) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_clamps_overflow():
    box = _normalize_bounding_box({"x": 90, "y": 90, "width": 50, "height": 50})
    assert box is not None
    assert box["x"] == 90.0
    assert box["y"] == 90.0
    assert box["width"] == 10.0
    assert box["height"] == 10.0


def test_normalize_bounding_box_rejects_tiny_or_empty():
    assert _normalize_bounding_box({"x": 10, "y": 10, "width": 0.5, "height": 20}) is None
    assert _normalize_bounding_box(None) is None
    assert _normalize_bounding_box({}) is None


def test_normalize_bounding_box_small_percent_not_treated_as_fraction():
    """width/height slightly above 1 must stay percent, not ×100."""
    assert _normalize_bounding_box(
        {"x": 0.5, "y": 0.5, "width": 1.2, "height": 1.5}
    ) == {
        "x": 0.5,
        "y": 0.5,
        "width": 1.2,
        "height": 1.5,
    }


@pytest.mark.asyncio
async def test_extract_multiple_items_keeps_percent_boxes():
    payload = {
        "items": [
            {
                "category": "tops",
                "sub_category": "tee",
                "colors": ["red"],
                "material": "cotton",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.9,
                "boundingBox": {"x": 10, "y": 10, "width": 40, "height": 30},
                "detailedDescription": "Red tee",
                "person_id": "p1",
                "person_label": "A",
                "is_current_user_person": False,
            }
        ],
        "people": [
            {
                "person_id": "p1",
                "person_label": "A",
                "is_current_user_person": False,
                "confidence": 0.9,
            }
        ],
        "overall_confidence": 0.9,
        "image_description": "One person",
        "item_count": 1,
        "profile_match_found": False,
    }

    agent = ItemExtractionAgent(FakeAIService(json.dumps(payload)))
    result = await agent.extract_multiple_items(image_base64="img")

    assert result["items"][0]["bounding_box"] == {
        "x": 10.0,
        "y": 10.0,
        "width": 40.0,
        "height": 30.0,
    }


class FakeAIService:
    def __init__(self, text: str):
        self.text = text
        self.calls = []

    async def chat_with_vision(self, prompt, images, response_format=None, **kwargs):  # noqa: ANN001
        self.calls.append(
            {
                "prompt": prompt,
                "images": images,
                "response_format": response_format,
                "kwargs": kwargs,
            }
        )
        return AIResponse(text=self.text)


@pytest.mark.asyncio
async def test_extract_multiple_items_profile_match_sets_include_only_for_current_user():
    payload = {
        "items": [
            {
                "category": "tops",
                "sub_category": "t-shirt",
                "colors": ["navy"],
                "material": "cotton",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.93,
                "boundingBox": {"x": 10, "y": 10, "width": 40, "height": 30},
                "detailedDescription": "Navy tee",
                "person_id": "p1",
                "person_label": "Main",
                "is_current_user_person": True,
            },
            {
                "category": "outerwear",
                "sub_category": "jacket",
                "colors": ["black"],
                "material": "leather",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.9,
                "boundingBox": {"x": 50, "y": 8, "width": 35, "height": 45},
                "detailedDescription": "Black jacket",
                "person_id": "p2",
                "person_label": "Friend",
                "is_current_user_person": False,
            },
        ],
        "people": [
            {
                "person_id": "p1",
                "person_label": "Main",
                "is_current_user_person": True,
                "confidence": 0.95,
            },
            {
                "person_id": "p2",
                "person_label": "Friend",
                "is_current_user_person": False,
                "confidence": 0.91,
            },
        ],
        "overall_confidence": 0.92,
        "image_description": "Two people",
        "item_count": 2,
        "profile_match_found": True,
    }

    fake_service = FakeAIService(json.dumps(payload))
    agent = ItemExtractionAgent(fake_service)

    result = await agent.extract_multiple_items(
        image_base64="img-data",
        user_profile_image_base64="avatar-data",
    )

    assert result["has_profile_reference"] is True
    assert result["profile_match_found"] is True
    assert len(result["items"]) == 2

    included = [item for item in result["items"] if item["include_in_wardrobe"]]
    assert len(included) == 1
    assert included[0]["is_current_user_person"] is True

    people_by_label = {p["person_label"]: p for p in result["people"]}
    assert "You" in people_by_label
    assert people_by_label["You"]["is_current_user_person"] is True

    assert len(fake_service.calls) == 1
    assert len(fake_service.calls[0]["images"]) == 2
    assert fake_service.calls[0]["response_format"] is not None


@pytest.mark.asyncio
async def test_extract_multiple_items_without_avatar_includes_all_items():
    payload = {
        "items": [
            {
                "category": "tops",
                "sub_category": "shirt",
                "colors": ["white"],
                "material": "cotton",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.88,
                "boundingBox": {"x": 12, "y": 10, "width": 35, "height": 30},
                "detailedDescription": "White shirt",
                "person_id": "p1",
                "person_label": "Person A",
                "is_current_user_person": False,
            },
            {
                "category": "bottoms",
                "sub_category": "jeans",
                "colors": ["blue"],
                "material": "denim",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.86,
                "boundingBox": {"x": 12, "y": 42, "width": 35, "height": 45},
                "detailedDescription": "Blue jeans",
                "person_id": "p1",
                "person_label": "Person A",
                "is_current_user_person": False,
            },
        ],
        "people": [
            {
                "person_id": "p1",
                "person_label": "Person A",
                "is_current_user_person": False,
                "confidence": 0.9,
            }
        ],
        "overall_confidence": 0.87,
        "image_description": "Single person",
        "item_count": 2,
        "profile_match_found": False,
    }

    fake_service = FakeAIService(json.dumps(payload))
    agent = ItemExtractionAgent(fake_service)

    result = await agent.extract_multiple_items(image_base64="img-data")

    assert result["has_profile_reference"] is False
    assert result["profile_match_found"] is False
    assert len(result["items"]) == 2
    assert all(item["include_in_wardrobe"] for item in result["items"])
    assert all(item["is_current_user_person"] is False for item in result["items"])
    assert len(fake_service.calls[0]["images"]) == 1


@pytest.mark.asyncio
async def test_extract_multiple_items_falls_back_to_regex_json_parsing_when_needed():
    payload = {
        "items": [
            {
                "category": "shoes",
                "sub_category": "sneakers",
                "colors": ["white"],
                "material": "leather",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.89,
                "boundingBox": {"x": 20, "y": 70, "width": 22, "height": 18},
                "detailedDescription": "White sneakers",
                "person_id": "p1",
                "person_label": "Runner",
                "is_current_user_person": False,
            }
        ],
        "people": [
            {
                "person_id": "p1",
                "person_label": "Runner",
                "is_current_user_person": False,
                "confidence": 0.82,
            }
        ],
        "overall_confidence": 0.89,
        "image_description": "One person wearing sneakers",
        "item_count": 1,
        "profile_match_found": False,
    }

    text = f"Model output:\n```json\n{json.dumps(payload)}\n```"
    fake_service = FakeAIService(text)
    agent = ItemExtractionAgent(fake_service)

    result = await agent.extract_multiple_items(
        image_base64="img-data",
        user_profile_image_base64="avatar-data",
    )

    assert len(result["items"]) == 1
    assert result["profile_match_found"] is False
    assert result["items"][0]["include_in_wardrobe"] is True


@pytest.mark.asyncio
async def test_extract_multiple_items_avatar_no_match_includes_all_items():
    payload = {
        "items": [
            {
                "category": "accessories",
                "sub_category": "bag",
                "colors": ["brown"],
                "material": "leather",
                "pattern": "solid",
                "brand": None,
                "confidence": 0.84,
                "boundingBox": {"x": 62, "y": 40, "width": 20, "height": 25},
                "detailedDescription": "Brown bag",
                "person_id": "p2",
                "person_label": "Person B",
                "is_current_user_person": False,
            }
        ],
        "people": [
            {
                "person_id": "p2",
                "person_label": "Person B",
                "is_current_user_person": False,
                "confidence": 0.84,
            }
        ],
        "overall_confidence": 0.84,
        "image_description": "No profile match",
        "item_count": 1,
        "profile_match_found": False,
    }

    fake_service = FakeAIService(json.dumps(payload))
    agent = ItemExtractionAgent(fake_service)

    result = await agent.extract_multiple_items(
        image_base64="img-data",
        user_profile_image_base64="avatar-data",
    )

    assert result["has_profile_reference"] is True
    assert result["profile_match_found"] is False
    assert all(item["include_in_wardrobe"] for item in result["items"])
