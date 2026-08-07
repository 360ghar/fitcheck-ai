"""
Coverage-completion tests for app/agents/item_extraction_agent.py.

Complements tests/unit/test_agents/test_item_extraction_agent.py (bounding-box
normalization and parser regressions) by exercising the remaining branches:
empty and unparseable model responses, AIServiceError passthrough and
generic-failure fallbacks, person merging/backfill, non-dict people/items,
single-item extraction, color detection, the default-description fallback, and
the factory function.

Pure unit tests: the AI service is an AsyncMock and no network is touched.
"""

import json
from unittest.mock import AsyncMock

import pytest

from app.agents import item_extraction_agent as _item_agent_module
from app.agents.item_extraction_agent import (
    ItemExtractionAgent,
    _build_multi_item_extraction_prompt,
    _clamp_confidence,
    _clean_text,
    _normalize_bounding_box,
    _normalize_category,
    _to_bool,
    _to_float,
    get_item_extraction_agent,
)
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIResponse
from app.services.ai_settings_service import AISettingsService


def _agent(text=None, *, error=None) -> ItemExtractionAgent:
    """Agent whose chat_with_vision returns canned text or raises."""
    ai_service = AsyncMock()
    if error is not None:
        ai_service.chat_with_vision = AsyncMock(side_effect=error)
    else:
        ai_service.chat_with_vision = AsyncMock(return_value=AIResponse(text=text))
    return ItemExtractionAgent(ai_service)


def _item(
    category="tops",
    *,
    person_id="p1",
    person_label="A",
    is_current=False,
    confidence=0.9,
    detailed="A detailed description",
):
    return {
        "category": category,
        "sub_category": "tee",
        "colors": ["blue"],
        "material": "cotton",
        "pattern": "solid",
        "brand": None,
        "confidence": confidence,
        "boundingBox": {"x": 10, "y": 10, "width": 40, "height": 30},
        "detailedDescription": detailed,
        "person_id": person_id,
        "person_label": person_label,
        "is_current_user_person": is_current,
    }


def _payload(items, people=None, **overrides):
    payload = {
        "items": items,
        "people": people or [],
        "overall_confidence": 0.9,
        "image_description": "desc",
        "item_count": len(items),
        "profile_match_found": False,
    }
    payload.update(overrides)
    return payload


@pytest.fixture
def format_safe_single_prompt(monkeypatch):
    """App bug workaround: SINGLE_ITEM_EXTRACTION_PROMPT contains unescaped
    JSON braces, so ``.format(category_hint=...)`` raises KeyError on every
    call before the try block (reported, not fixed here). Patching the module
    constant with a format-safe template lets the function body be tested.
    """
    monkeypatch.setattr(
        _item_agent_module,
        "SINGLE_ITEM_EXTRACTION_PROMPT",
        "Analyze this clothing image and describe the single item shown."
        "{category_hint}\n\nReturn JSON only.",
    )


# =============================================================================
# Small helpers
# =============================================================================


def test_to_bool_string_and_foreign_values():
    assert _to_bool(True) is True
    assert _to_bool(False) is False
    assert _to_bool("TRUE") is True
    assert _to_bool("1") is True
    assert _to_bool("yes") is True
    assert _to_bool("False") is False
    assert _to_bool("0") is False
    assert _to_bool("no") is False
    # Unknown strings, numbers and None fall back to the default.
    assert _to_bool("maybe") is False
    assert _to_bool(123) is False
    assert _to_bool(None) is False
    assert _to_bool(None, default=True) is True


def test_to_float_and_clamp_confidence_edge_values():
    assert _to_float("3.5") == 3.5
    assert _to_float(2) == 2.0
    assert _to_float("abc", default=1.5) == 1.5
    assert _to_float(None, default=1.5) == 1.5
    assert _clamp_confidence(1.5) == 1.0
    assert _clamp_confidence(-1) == 0.0
    assert _clamp_confidence(0.7) == 0.7
    assert _clamp_confidence("abc", default=0.3) == 0.3


def test_normalize_category_and_clean_text_edge_values():
    assert _normalize_category("TOPS") == "tops"
    assert _normalize_category("dress") == "other"
    assert _normalize_category(None) == "other"
    assert _clean_text(None) is None
    assert _clean_text("  hi  ") == "hi"
    assert _clean_text("   ") is None


def test_normalize_bounding_box_left_top_right_bottom():
    assert _normalize_bounding_box({"left": 10, "top": 20, "right": 40, "bottom": 60}) == {
        "x": 10.0,
        "y": 20.0,
        "width": 30.0,
        "height": 40.0,
    }


def test_normalize_bounding_box_rejects_invalid_shapes():
    assert _normalize_bounding_box("nonsense") is None
    assert _normalize_bounding_box([1, 2, 3]) is None
    assert _normalize_bounding_box(42) is None
    assert _normalize_bounding_box(("a", "b")) is None


def test_normalize_bounding_box_rejects_zero_size():
    assert _normalize_bounding_box({"x1": 10, "y1": 10, "x2": 10, "y2": 30}) is None
    assert _normalize_bounding_box([20, 10, 10, 10]) is None


def test_multi_item_prompt_profile_variants():
    with_profile = _build_multi_item_extraction_prompt(True)
    assert "You are given TWO images" in with_profile
    assert "profile_match_found=false" in with_profile
    without = _build_multi_item_extraction_prompt(False)
    assert "You are given one outfit photo only" in without


# =============================================================================
# extract_multiple_items: response failure modes
# =============================================================================


@pytest.mark.asyncio
async def test_extract_multiple_items_empty_response_returns_empty_result():
    agent = _agent(text=None)
    result = await agent.extract_multiple_items(image_base64="img")

    assert result == {
        "items": [],
        "people": [],
        "overall_confidence": 0,
        "image_description": "Unable to analyze image automatically",
        "item_count": 0,
        "requires_review": True,
        "has_profile_reference": False,
        "profile_match_found": False,
    }

    agent_with_profile = _agent(text=None)
    result_with_profile = await agent_with_profile.extract_multiple_items(
        image_base64="img", user_profile_image_base64="avatar"
    )
    assert result_with_profile["has_profile_reference"] is True
    assert result_with_profile["image_description"] == "Unable to analyze image automatically"


@pytest.mark.asyncio
async def test_extract_multiple_items_unparseable_text_returns_empty_result():
    agent = _agent(text="I cannot process this image.")
    result = await agent.extract_multiple_items(image_base64="img")

    assert result["items"] == []
    assert result["requires_review"] is True
    assert result["image_description"] == "I cannot process this image."


@pytest.mark.asyncio
async def test_extract_multiple_items_propagates_ai_service_error():
    agent = _agent(error=AIServiceError("provider down"))
    with pytest.raises(AIServiceError, match="provider down"):
        await agent.extract_multiple_items(image_base64="img")


@pytest.mark.asyncio
async def test_extract_multiple_items_generic_error_falls_back():
    agent = _agent(error=RuntimeError("boom"))
    result = await agent.extract_multiple_items(
        image_base64="img", user_profile_image_base64="avatar"
    )

    assert result["items"] == []
    assert result["requires_review"] is True
    assert result["has_profile_reference"] is True
    assert result["image_description"] == "Unable to analyze image automatically"


# =============================================================================
# _parse_json_object
# =============================================================================


def test_parse_json_object_empty_and_bare_text():
    agent = ItemExtractionAgent(AsyncMock())
    assert agent._parse_json_object("") is None
    assert agent._parse_json_object("   ") is None
    assert agent._parse_json_object('{"a": 1}') == {"a": 1}
    assert agent._parse_json_object("not json") is None


# =============================================================================
# extract_multiple_items: person handling
# =============================================================================


@pytest.mark.asyncio
async def test_extract_multiple_items_person_without_id_gets_generated_label():
    payload = _payload(
        items=[
            _item(person_id=None, person_label=None),
            _item(person_id="px", person_label="you"),
        ]
    )
    agent = _agent(json.dumps(payload))
    result = await agent.extract_multiple_items(image_base64="img")

    # No raw id -> no canonical mapping; default labels, forbidden labels
    # replaced with Person N.
    labels = [p["person_label"] for p in result["people"]]
    assert labels == ["Person 1", "Person 2"]
    assert result["items"][0]["person_id"] == "person_1"
    assert result["items"][1]["person_id"] == "person_2"


@pytest.mark.asyncio
async def test_extract_multiple_items_merges_person_and_backfills_label():
    people = [
        {
            "person_id": "p1",
            "person_label": None,
            "is_current_user_person": True,
            "confidence": 0.9,
        }
    ]
    payload = _payload(
        items=[
            _item(person_id="p1", person_label="Alice", is_current=False),
            _item(person_id="p1", person_label="Bob", is_current=False),
        ],
        people=people,
        profile_match_found=True,
    )
    agent = _agent(json.dumps(payload))
    result = await agent.extract_multiple_items(
        image_base64="img", user_profile_image_base64="avatar"
    )

    # The people entry seeds the person; the first item backfills the label,
    # the second is a no-op merge; is_current_user_person ORs in from people.
    assert result["profile_match_found"] is True
    assert result["people"][0]["person_label"] == "You"
    assert result["people"][0]["is_current_user_person"] is True
    assert all(item["person_label"] == "You" for item in result["items"])
    assert all(item["include_in_wardrobe"] is False for item in result["items"])


@pytest.mark.asyncio
async def test_extract_multiple_items_skips_non_dict_people_and_items():
    payload = _payload(
        items=["junk", _item()],
        people=[
            "junk",
            {"person_id": "p1", "person_label": "A", "is_current_user_person": False, "confidence": 0.9},
        ],
    )
    agent = _agent(json.dumps(payload))
    result = await agent.extract_multiple_items(image_base64="img")

    assert len(result["items"]) == 1
    assert len(result["people"]) == 1
    assert result["people"][0]["person_label"] == "A"


@pytest.mark.asyncio
async def test_extract_multiple_items_people_without_items_are_dropped():
    payload = _payload(
        items=[],
        people=[
            {"person_id": "p1", "person_label": "A", "is_current_user_person": False, "confidence": 0.9}
        ],
    )
    agent = _agent(json.dumps(payload))
    result = await agent.extract_multiple_items(image_base64="img")

    assert result["items"] == []
    assert result["people"] == []
    assert result["requires_review"] is True


# =============================================================================
# _generate_default_description
# =============================================================================


def test_generate_default_description_full_fields():
    agent = ItemExtractionAgent(AsyncMock())
    description = agent._generate_default_description(
        {
            "sub_category": "wide-leg trousers",
            "category": "bottoms",
            "colors": ["Black", "white"],
            "material": "wool",
            "pattern": "Houndstooth",
            "brand": "Acme",
        }
    )

    assert "wide-leg trousers" in description
    assert "in black, white" in description
    assert "made of wool" in description
    assert "with Houndstooth pattern" in description
    assert "by Acme" in description
    assert len(description.split()) >= 10
    assert "further visual details" not in description


def test_generate_default_description_minimal_item_is_padded():
    agent = ItemExtractionAgent(AsyncMock())
    assert agent._generate_default_description({"category": "shoes"}) == (
        "shoes; further visual details not specified"
    )
    # category defaults to "other" through _normalize_category; the
    # "clothing item" fallback is unreachable.
    assert agent._generate_default_description({}) == (
        "other; further visual details not specified"
    )


def test_generate_default_description_solid_pattern_and_brand():
    agent = ItemExtractionAgent(AsyncMock())
    description = agent._generate_default_description(
        {"category": "tops", "pattern": "plain", "brand": "Nike"}
    )
    assert "solid colorway" in description
    assert "by Nike" in description


# =============================================================================
# extract_single_item
# =============================================================================


@pytest.mark.asyncio
async def test_extract_single_item_happy_path_with_category_hint(format_safe_single_prompt):
    text = json.dumps(
        {
            "category": "tops",
            "sub_category": "t-shirt",
            "colors": ["Blue", "WHITE"],
            "material": "cotton",
            "pattern": "striped",
            "brand": "Nike",
            "confidence": 0.9,
            "description": "A blue cotton tee",
        }
    )
    agent = _agent(text)
    result = await agent.extract_single_item(image_base64="img", category_hint="t-shirt")

    prompt = agent.ai_service.chat_with_vision.await_args.kwargs["prompt"]
    assert "The item is likely a t-shirt." in prompt
    assert result["category"] == "tops"
    assert result["sub_category"] == "t-shirt"
    assert result["colors"] == ["blue", "white"]
    assert result["material"] == "cotton"
    assert result["pattern"] == "striped"
    assert result["brand"] == "Nike"
    assert result["confidence"] == 0.9
    assert result["description"] == "A blue cotton tee"


@pytest.mark.asyncio
async def test_extract_single_item_empty_response_returns_empty(format_safe_single_prompt):
    result = await _agent(text=None).extract_single_item(image_base64="img")
    assert result == {"category": "other", "colors": [], "confidence": 0}


@pytest.mark.asyncio
async def test_extract_single_item_unparseable_response_returns_raw_text(format_safe_single_prompt):
    result = await _agent(text="no json").extract_single_item(image_base64="img")
    assert result == {
        "category": "other",
        "colors": [],
        "confidence": 0,
        "description": "no json",
    }


@pytest.mark.asyncio
async def test_extract_single_item_non_list_colors_are_ignored(format_safe_single_prompt):
    text = json.dumps({"category": "bottoms", "colors": "blue", "confidence": 0.5})
    result = await _agent(text).extract_single_item(image_base64="img")
    assert result["colors"] == []
    assert result["category"] == "bottoms"
    assert result["confidence"] == 0.5


@pytest.mark.asyncio
async def test_extract_single_item_invalid_category_normalized_to_other(format_safe_single_prompt):
    text = json.dumps({"category": "handbag", "confidence": 0.4})
    result = await _agent(text).extract_single_item(image_base64="img")
    assert result["category"] == "other"
    assert result["confidence"] == 0.4


@pytest.mark.asyncio
async def test_extract_single_item_propagates_ai_service_error(format_safe_single_prompt):
    agent = _agent(error=AIServiceError("provider down"))
    with pytest.raises(AIServiceError, match="provider down"):
        await agent.extract_single_item(image_base64="img")


@pytest.mark.asyncio
async def test_extract_single_item_generic_error_returns_empty(format_safe_single_prompt):
    result = await _agent(error=RuntimeError("boom")).extract_single_item(
        image_base64="img", category_hint="jeans"
    )
    assert result == {"category": "other", "colors": [], "confidence": 0}


# =============================================================================
# detect_colors
# =============================================================================


@pytest.mark.asyncio
async def test_detect_colors_happy_path_lowercases():
    agent = _agent(text='["Red", "BLUE", "navy"]')
    result = await agent.detect_colors(image_base64="img")
    assert result == ["red", "blue", "navy"]


@pytest.mark.asyncio
async def test_detect_colors_empty_response_returns_empty():
    assert await _agent(text=None).detect_colors(image_base64="img") == []


@pytest.mark.asyncio
async def test_detect_colors_unparseable_response_returns_empty():
    assert await _agent(text="not a list").detect_colors(image_base64="img") == []


@pytest.mark.asyncio
async def test_detect_colors_generic_error_returns_empty():
    assert await _agent(error=RuntimeError("boom")).detect_colors(image_base64="img") == []


# =============================================================================
# Factory
# =============================================================================


@pytest.mark.asyncio
async def test_get_item_extraction_agent_factory(monkeypatch, fake_db):
    service = AsyncMock()
    factory = AsyncMock(return_value=service)
    monkeypatch.setattr(AISettingsService, "get_ai_service_for_user", factory)

    agent = await get_item_extraction_agent(user_id="u1", db=fake_db)

    assert isinstance(agent, ItemExtractionAgent)
    assert agent.ai_service is service
    factory.assert_awaited_once_with("u1", fake_db)
