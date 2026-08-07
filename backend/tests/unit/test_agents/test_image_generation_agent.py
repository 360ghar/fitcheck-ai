"""
Tests for ImageGenerationAgent.

Covers two reference-image paths:
- generate_product_image, where the item is IDENTIFIED by its dense
  description and REPLICATED from the source photo as a single isolated
  product shot (no bounding box).
- generate_outfit, where each item's own stored image is sent as a numbered
  garment reference alongside the avatar identity reference, so the output
  reproduces the real garments instead of inventing lookalikes.
"""

from unittest.mock import AsyncMock

import pytest

from app.agents.image_generation_agent import ImageGenerationAgent
from app.core.exceptions import AIServiceError


def _make_agent() -> ImageGenerationAgent:
    # The agent only needs an ai_service whose generate_image/chat return a
    # fixed response. We never hit a real provider in these tests.
    fake_ai_service = AsyncMock()
    fake_ai_service.generate_image = AsyncMock(
        return_value=_FakeImageResponse("ZmFrZQ==")
    )
    fake_ai_service.chat = AsyncMock(return_value=_FakeImageResponse("ZmFrZQ=="))
    fake_ai_service.get_image_gen_model = lambda: "fake-image-model"
    return ImageGenerationAgent(ai_service=fake_ai_service)


class _FakeImageResponse:
    def __init__(self, image_b64: str):
        self.images = [image_b64] if image_b64 else []
        self.model = "fake-model"
        self.provider = "fake-provider"


def _item(name, category, reference=None):
    item = {"name": name, "category": category, "colors": []}
    if reference:
        item[ImageGenerationAgent.REFERENCE_KEY] = reference
    return item


def _captured_chat_content(agent):
    """The single user message's content parts from the mocked chat() call."""
    messages = agent.ai_service.chat.call_args.kwargs["messages"]
    assert len(messages) == 1
    return messages[0].content


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


@pytest.mark.asyncio
async def test_outfit_sends_avatar_plus_numbered_garment_references():
    """Avatar is IMAGE 1, each item's own photo follows in item order, and the
    prompt binds IMAGE n -> Item n without weakening the identity lock."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[
            _item("Cream ribbed knit sweater", "tops", reference="c3dlYXRlcg=="),
            _item("Black leather ankle boots", "shoes", reference="Ym9vdHM="),
        ],
        user_avatar_base64="YXZhdGFy",
    )

    content = _captured_chat_content(agent)
    # [avatar, garment 1, garment 2, prompt] - images first, in order.
    assert [part["type"] for part in content] == [
        "image_url",
        "image_url",
        "image_url",
        "text",
    ]
    # Images travel BARE in message content (the provider wraps at its own
    # wire boundary — see ai_provider_interface.build_user_multimodal_messages).
    assert content[0]["image_url"]["url"] == "YXZhdGFy"
    assert content[1]["image_url"]["url"] == "c3dlYXRlcg=="
    assert content[2]["image_url"]["url"] == "Ym9vdHM="

    prompt = content[3]["text"]
    assert "IMAGE 1 = the person" in prompt
    assert 'IMAGE 2 = Item 1 "Cream ribbed knit sweater" (tops)' in prompt
    assert 'IMAGE 3 = Item 2 "Black leather ankle boots" (shoes)' in prompt
    assert "GARMENT REFERENCE LOCK" in prompt
    assert "appearance reference: IMAGE 2" in prompt
    assert "appearance reference: IMAGE 3" in prompt
    # The person lock must still be intact and ahead of the garment block.
    assert "IDENTITY LOCK" in prompt
    assert "KEEP UNCHANGED" in prompt
    assert prompt.index("IDENTITY LOCK") < prompt.index("GARMENT REFERENCE LOCK")
    # Never hits the single-reference provider helper.
    agent.ai_service.generate_image.assert_not_called()


@pytest.mark.asyncio
async def test_outfit_with_avatar_and_no_item_references_is_unchanged():
    """Legacy clients that send no item_ids get exactly the previous prompt and
    a single avatar image - no garment scaffolding leaks in."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[_item("Cream ribbed knit sweater", "tops")],
        user_avatar_base64="YXZhdGFy",
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == ["image_url", "text"]

    prompt = content[1]["text"]
    # Byte-for-byte the pre-existing prompt, blank lines included: the header
    # sits directly above TASK with no blank line, exactly as before garment
    # references existed. Anything else is an unintended prompt regression on
    # the one path that already works in production.
    assert prompt.startswith(
        "REFERENCE IMAGE = person identity (source of truth for face/body/hair/skin).\n"
        "TASK: Photoreal fashion photo of that same person wearing the outfit below.\n\n"
        "IDENTITY LOCK (highest priority):"
    )
    assert "GARMENT REFERENCE LOCK" not in prompt
    assert "IMAGE 2" not in prompt
    assert "appearance reference" not in prompt
    assert "\n\n\n" not in prompt


@pytest.mark.asyncio
async def test_outfit_item_without_reference_falls_back_to_its_description():
    """A mix of items with and without images: the ones without are called out
    explicitly rather than silently numbered."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[
            _item("Cream ribbed knit sweater", "tops", reference="c3dlYXRlcg=="),
            _item("Vintage silver ring", "accessories"),
        ],
        user_avatar_base64="YXZhdGFy",
    )

    prompt = _captured_chat_content(agent)[-1]["text"]
    assert 'IMAGE 2 = Item 1 "Cream ribbed knit sweater" (tops)' in prompt
    assert "Item 2 has no reference image" in prompt
    assert "appearance reference: none — render from this description" in prompt


@pytest.mark.asyncio
async def test_flat_lay_numbers_garments_from_image_one_and_forbids_collage():
    """Flat lay has no person reference, so garments start at IMAGE 1. It must
    go through chat(), which is the only path that carries multiple images."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[_item("Cream ribbed knit sweater", "tops", reference="c3dlYXRlcg==")],
        include_model=False,
        user_avatar_base64="YXZhdGFy",  # ignored for flat lay
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == ["image_url", "text"]
    # Bare base64 in content; the provider wraps at the wire.
    assert content[0]["image_url"]["url"] == "c3dlYXRlcg=="

    prompt = content[1]["text"]
    assert 'IMAGE 1 = Item 1 "Cream ribbed knit sweater" (tops)' in prompt
    assert "IMAGE 1 = the person" not in prompt
    assert "not a collage, grid, or copy of the reference images" in prompt
    agent.ai_service.generate_image.assert_not_called()


@pytest.mark.asyncio
async def test_generic_model_numbers_garments_from_image_one():
    """No avatar: garments still get sent, numbered from IMAGE 1."""
    agent = _make_agent()

    await agent.generate_outfit(
        items=[_item("Striped linen trousers", "bottoms", reference="dHJvdXNlcnM=")],
    )

    content = _captured_chat_content(agent)
    assert [part["type"] for part in content] == ["image_url", "text"]
    prompt = content[1]["text"]
    assert 'IMAGE 1 = Item 1 "Striped linen trousers" (bottoms)' in prompt
    assert "GARMENT REFERENCE LOCK" in prompt


@pytest.mark.asyncio
async def test_outfit_with_no_images_at_all_stays_on_text_only_provider_call():
    """No avatar and no references -> the pre-existing text-to-image path."""
    agent = _make_agent()

    await agent.generate_outfit(items=[_item("Striped linen trousers", "bottoms")])

    agent.ai_service.chat.assert_not_called()
    assert (
        agent.ai_service.generate_image.call_args.kwargs.get("reference_image") is None
    )


@pytest.mark.asyncio
async def test_outfit_no_images_returned_is_retryable():
    """A 200 with no images is a transient silent refusal, not a hard failure."""
    agent = _make_agent()
    agent.ai_service.chat = AsyncMock(return_value=_FakeImageResponse(""))

    with pytest.raises(AIServiceError) as excinfo:
        await agent.generate_outfit(
            items=[_item("Cream sweater", "tops", reference="c3dlYXRlcg==")],
            user_avatar_base64="YXZhdGFy",
        )

    assert excinfo.value.retryable is True


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


# =============================================================================
# Background matte wiring (app/utils/background_removal.py)
# =============================================================================
# The matte is wired at EXACTLY TWO sites: the generate_product_image return and
# generate_outfit's flat-lay branch. The avatar branch, the generic-model branch
# and generate_try_on must stay OPAQUE - a Pillow threshold matte cannot cut
# hair, and the guards would not catch it (a full-body figure lands ~0.70-0.80
# transparent, under MAX_TRANSPARENT_FRACTION), so bad hair would ship.


def _product_shot_b64() -> str:
    """A dark item on a flat white field - the matte's happy path."""
    import base64
    import io

    from PIL import Image, ImageDraw

    img = Image.new("RGB", (256, 256), (255, 255, 255))
    ImageDraw.Draw(img).rounded_rectangle((70, 50, 186, 206), radius=12, fill=(34, 40, 58))
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=92)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _agent_returning(image_b64: str) -> ImageGenerationAgent:
    agent = _make_agent()
    agent.ai_service.generate_image = AsyncMock(return_value=_FakeImageResponse(image_b64))
    agent.ai_service.chat = AsyncMock(return_value=_FakeImageResponse(image_b64))
    return agent


def _is_transparent_webp(image_b64: str) -> bool:
    import base64
    import io

    from PIL import Image

    with Image.open(io.BytesIO(base64.b64decode(image_b64))) as img:
        return img.format == "WEBP" and img.mode == "RGBA"


@pytest.mark.asyncio
async def test_product_image_is_matted():
    source = _product_shot_b64()
    agent = _agent_returning(source)

    result = await agent.generate_product_image(
        item_description="black crew-neck t-shirt", category="tops"
    )

    assert result.image_base64 != source
    assert _is_transparent_webp(result.image_base64)


@pytest.mark.asyncio
async def test_flat_lay_outfit_is_matted():
    source = _product_shot_b64()
    agent = _agent_returning(source)

    result = await agent.generate_outfit(
        items=[_item("tee", "tops")], include_model=False
    )

    assert result.image_base64 != source
    assert _is_transparent_webp(result.image_base64)


@pytest.mark.asyncio
async def test_avatar_outfit_is_not_matted():
    source = _product_shot_b64()
    agent = _agent_returning(source)

    result = await agent.generate_outfit(
        items=[_item("tee", "tops")], user_avatar_base64="ZmFrZQ=="
    )

    assert result.image_base64 == source


@pytest.mark.asyncio
async def test_generic_model_outfit_is_not_matted():
    source = _product_shot_b64()
    agent = _agent_returning(source)

    result = await agent.generate_outfit(items=[_item("tee", "tops")])

    assert result.image_base64 == source


@pytest.mark.asyncio
async def test_try_on_is_not_matted():
    source = _product_shot_b64()
    agent = _agent_returning(source)

    result = await agent.generate_try_on(
        user_avatar_base64="ZmFrZQ==", clothing_image_base64="ZmFrZQ=="
    )

    assert result.image_base64 == source


@pytest.mark.asyncio
async def test_matte_failure_returns_the_original_image_untouched():
    """The matte is best-effort: undecodable bytes must pass straight through."""
    agent = _agent_returning("ZmFrZQ==")

    result = await agent.generate_product_image(
        item_description="black crew-neck t-shirt", category="tops"
    )

    assert result.image_base64 == "ZmFrZQ=="


# =============================================================================
# Background prompt strings
# =============================================================================


@pytest.mark.asyncio
async def test_outfit_default_background_is_flat_white_not_a_gradient_invite():
    """"seamless clean light background" invited the soft gradient sweep that a
    threshold matte cannot cut. Every white token must resolve to flat #FFFFFF."""
    agent = _agent_returning(_product_shot_b64())

    await agent.generate_outfit(items=[_item("tee", "tops")], include_model=False)
    prompt = agent.ai_service.generate_image.call_args.args[0]

    assert "seamless clean light background" not in prompt
    assert "pure flat #FFFFFF white background" in prompt
    assert "no gradient" in prompt and "no cast shadow" in prompt
    # Flat lay has no person in frame, so it may demand an isolated silhouette.
    assert "crisp clean silhouette edge" in prompt


@pytest.mark.asyncio
@pytest.mark.parametrize("token", ["white", "transparent", "studio white", ""])
async def test_every_white_token_resolves_to_the_same_flat_white(token):
    agent = _agent_returning(_product_shot_b64())

    await agent.generate_product_image(
        item_description="tee", category="tops", background=token
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]

    assert "pure flat #FFFFFF white background" in prompt


@pytest.mark.asyncio
async def test_gray_background_stays_honest():
    """A caller that explicitly asks for gray gets gray; the matte's G1 guard
    then finds no white backdrop and keeps the opaque original."""
    agent = _agent_returning(_product_shot_b64())

    await agent.generate_product_image(
        item_description="tee", category="tops", background="gray"
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]

    assert "light gray seamless studio background" in prompt
    assert "pure flat #FFFFFF" not in prompt


@pytest.mark.asyncio
async def test_model_outfit_prompt_drops_the_shadow_request():
    """Shadows orphan into detached grey blobs and make the corpus un-mattable
    if a real segmenter is ever added."""
    agent = _agent_returning(_product_shot_b64())

    await agent.generate_outfit(items=[_item("tee", "tops")], user_avatar_base64="ZmFrZQ==")
    content = _captured_chat_content(agent)
    prompt = content[-1]["text"]

    assert "realistic draping" in prompt
    assert "draping and shadows" not in prompt
    # The model branch gets flat white WITHOUT the garment-isolation clause.
    assert "pure flat #FFFFFF white background" in prompt
    assert "crisp clean silhouette edge" not in prompt


# =============================================================================
# Provider inline-image cap (observed 2026-08-01: agnes-image-2.1-flash
# rejects "too many input images: 7 provided, at most 6 allowed")
# =============================================================================


@pytest.mark.asyncio
async def test_outfit_truncates_garment_references_to_provider_input_cap(monkeypatch):
    """Avatar takes one slot; with the default cap of 6 the garment budget is
    5. Items beyond the budget still render - from their descriptions, with
    no IMAGE number - instead of 400-ing the whole request."""
    from app.core.config import settings

    monkeypatch.setattr(settings, "AI_IMAGE_GEN_MAX_INPUT_IMAGES", 6)
    agent = _make_agent()
    items = [
        _item(f"Garment {i}", "tops", reference="cmVmZXJlbmNlLXtJbn0=".replace("{I}", str(i)))
        for i in range(1, 9)
    ]

    await agent.generate_outfit(items=items, user_avatar_base64="YXZhdGFy")

    content = _captured_chat_content(agent)
    # avatar + 5 garments + prompt = 7 parts, NOT 10
    assert [part["type"] for part in content] == ["image_url"] * 6 + ["text"]
    prompt = content[-1]["text"]
    assert 'IMAGE 2 = Item 1 "Garment 1" (tops)' in prompt
    assert 'IMAGE 6 = Item 5 "Garment 5" (tops)' in prompt
    # Truncated items fall back to their description, exactly like items that
    # never had an image.
    assert "Items 6, 7, 8 have no reference image" in prompt
    assert 'IMAGE 7 = Item 6' not in prompt


@pytest.mark.asyncio
async def test_outfit_avatar_plus_source_photo_leaves_four_garment_slots(monkeypatch):
    """Avatar + source photo each consume a slot: budget = 6 - 2 = 4."""
    from app.core.config import settings

    monkeypatch.setattr(settings, "AI_IMAGE_GEN_MAX_INPUT_IMAGES", 6)
    agent = _make_agent()
    items = [
        _item(f"Garment {i}", "tops", reference="cmVmZXJlbmNlLXtJbn0=".replace("{I}", str(i)))
        for i in range(1, 7)
    ]

    await agent.generate_outfit(
        items=items,
        user_avatar_base64="YXZhdGFy",
        source_photo_base64="c291cmNlLXBob3Rv",
    )

    content = _captured_chat_content(agent)
    # avatar + source photo + 4 garments + prompt = 7 parts
    assert [part["type"] for part in content] == ["image_url"] * 6 + ["text"]
    prompt = content[-1]["text"]
    assert "IMAGE 2 = the original photo of this outfit as worn" in prompt
    assert 'IMAGE 3 = Item 1 "Garment 1" (tops)' in prompt
    assert 'IMAGE 6 = Item 4 "Garment 4" (tops)' in prompt
    assert "Items 5, 6 have no reference image" in prompt


@pytest.mark.asyncio
async def test_generate_with_references_raises_non_retryable_over_cap(monkeypatch):
    """A >cap payload (e.g. a future caller that skips the budget) fails fast
    with an actionable config error instead of a wasted provider 400."""
    from app.core.config import settings

    monkeypatch.setattr(settings, "AI_IMAGE_GEN_MAX_INPUT_IMAGES", 6)
    agent = _make_agent()

    with pytest.raises(AIServiceError) as excinfo:
        await agent._generate_with_references(
            "prompt", images=["a"] * 7, context="outfit"
        )

    assert excinfo.value.retryable is False
    assert excinfo.value.error_kind == "config"
    assert "at most 6" in str(excinfo.value)
