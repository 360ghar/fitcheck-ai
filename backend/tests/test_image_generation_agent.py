"""
Tests for ImageGenerationAgent.generate_product_image, focused on the
reference-image path where the item is IDENTIFIED by its dense description
and REPLICATED from the source photo as a single isolated product shot
(no bounding box).
"""

from unittest.mock import AsyncMock

import pytest

from app.agents.image_generation_agent import ImageGenerationAgent


def _make_agent() -> ImageGenerationAgent:
    # The agent only needs an ai_service whose generate_image returns a fixed
    # response. We never hit a real provider in these tests.
    fake_ai_service = AsyncMock()
    fake_ai_service.generate_image = AsyncMock(
        return_value=_FakeImageResponse("ZmFrZQ==")
    )
    return ImageGenerationAgent(ai_service=fake_ai_service)


class _FakeImageResponse:
    def __init__(self, image_b64: str):
        self.images = [image_b64]
        self.model = "fake-model"
        self.provider = "fake-provider"


@pytest.mark.asyncio
async def test_product_prompt_identifies_item_by_description_and_isolates_single_item():
    """With a reference photo, the item is IDENTIFIED by its dense description
    and isolated to a single product shot. No bounding box is used."""
    agent = _make_agent()

    await agent.generate_product_image(
        item_description=(
            "crew-neck t-shirt; off-white base; ribbed crew collar; "
            "short set-in sleeves; plain-weave cotton midweight; matte"
        ),
        category="tops",
        sub_category="t-shirt",
        colors=["white"],
        material="cotton",
        reference_image="ZmFrZQ==",
    )

    # The captured prompt is the first positional arg to generate_image.
    captured_prompt = agent.ai_service.generate_image.call_args.args[0]
    # No bounding box anywhere — identification is by description, not region.
    assert "bounding box" not in captured_prompt.lower()
    # The dense description identifies the item and is embedded verbatim.
    assert "ribbed crew collar" in captured_prompt
    # The reference photo is the appearance source of truth.
    assert "REFERENCE IMAGE" in captured_prompt
    assert "appearance source of truth" in captured_prompt
    # PRODUCT_LOCK enumerates the visual categories and forces single-item.
    assert "graphic content" in captured_prompt
    assert "hardware color" in captured_prompt
    assert "logo/branding" in captured_prompt
    assert "Single isolated product shot only" in captured_prompt
    # Explicit isolation: ignore every other item in the photo.
    assert "Ignore EVERY other garment" in captured_prompt
    # The reference image is forwarded to the provider.
    assert (
        agent.ai_service.generate_image.call_args.kwargs.get("reference_image")
        == "ZmFrZQ=="
    )


@pytest.mark.asyncio
async def test_product_prompt_reference_embeds_description_and_tokens():
    """The reference-image branch embeds the description and the item tokens."""
    agent = _make_agent()

    await agent.generate_product_image(
        item_description="blue jeans; mid-blue indigo wash; 5-pocket",
        category="bottoms",
        sub_category="jeans",
        colors=["blue"],
        material="denim",
        reference_image="ZmFrZQ==",
    )

    captured_prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "REFERENCE IMAGE" in captured_prompt
    assert "mid-blue indigo wash" in captured_prompt
    assert "bounding box" not in captured_prompt.lower()
    # Item tokens line carries category, colors, material.
    assert "jeans" in captured_prompt
    assert "colors: blue" in captured_prompt
    assert "material: denim" in captured_prompt


@pytest.mark.asyncio
async def test_product_prompt_text_only_when_no_reference_supplied():
    """No reference image -> standard text-only catalog prompt."""
    agent = _make_agent()

    await agent.generate_product_image(
        item_description="black cotton t-shirt",
        category="tops",
        sub_category="t-shirt",
        colors=["black"],
    )

    captured_prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "REFERENCE IMAGE" not in captured_prompt
    assert "bounding box" not in captured_prompt.lower()
    # Text-only path forwards reference_image=None to _generate_image so the
    # underlying provider call doesn't try to attach one.
    assert agent.ai_service.generate_image.call_args.kwargs.get("reference_image") is None


def test_generate_default_description_no_longer_short_stub():
    """If the VLM returns no detailedDescription, the fallback should produce
    at least silhouette + color + material wording, not a 4-word stub."""
    from app.agents.item_extraction_agent import ItemExtractionAgent

    fallback_ai_service = AsyncMock()
    extraction_agent = ItemExtractionAgent(ai_service=fallback_ai_service)

    description = extraction_agent._generate_default_description({
        "sub_category": "t-shirt",
        "category": "tops",
        "colors": ["white"],
        "material": "cotton",
        "pattern": "solid",
    })

    # 4-word stubs ("A t-shirt in white") are gone.
    assert len(description.split()) >= 6
    assert "t-shirt" in description
    assert "white" in description
