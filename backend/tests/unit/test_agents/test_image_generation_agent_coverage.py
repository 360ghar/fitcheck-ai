"""
Coverage-completion tests for app/agents/image_generation_agent.py.

Complements tests/unit/test_agents/test_image_generation_agent.py (reference
numbering, matte wiring, background tokens, provider input cap) by exercising
the remaining branches: custom background passthrough, matte executor
failures, empty outfit inventory, full-field item descriptions, body profiles,
product-image shadow conflicts and reference token assembly, flat lay and
variations delegation, generic error wrapping in every generation path,
save_generated_image, and the factory function.

Pure unit tests: the AI service is an AsyncMock and no network is touched.
"""

from unittest.mock import AsyncMock, patch

import pytest

from app.agents.image_generation_agent import (
    GeneratedImage,
    ImageGenerationAgent,
    _resolve_background,
    get_image_generation_agent,
    save_generated_image,
)
from app.core.exceptions import AIServiceError
from app.services.ai_settings_service import AISettingsService
from app.utils.background_removal import STATUS_MATTED, MatteResult
from app.utils.parallel import ParallelResult


class _FakeImageResponse:
    def __init__(self, image_b64="ZmFrZQ=="):
        self.images = [image_b64] if image_b64 else []
        self.model = "fake-model"
        self.provider = "fake-provider"


def _make_agent(image_b64="ZmFrZQ==") -> ImageGenerationAgent:
    fake_ai_service = AsyncMock()
    fake_ai_service.generate_image = AsyncMock(return_value=_FakeImageResponse(image_b64))
    fake_ai_service.chat = AsyncMock(return_value=_FakeImageResponse(image_b64))
    fake_ai_service.get_image_gen_model = lambda: "fake-image-model"
    return ImageGenerationAgent(ai_service=fake_ai_service)


def _item(name, category="tops", reference=None):
    item = {"name": name, "category": category, "colors": []}
    if reference:
        item[ImageGenerationAgent.REFERENCE_KEY] = reference
    return item


def _chat_prompt(agent) -> str:
    messages = agent.ai_service.chat.call_args.kwargs["messages"]
    assert len(messages) == 1
    content = messages[0].content
    assert content[-1]["type"] == "text"
    return content[-1]["text"]


# =============================================================================
# _resolve_background and GeneratedImage
# =============================================================================


def test_resolve_background_custom_passthrough_and_none():
    assert _resolve_background("sunset beach", matte_ready=False) == "sunset beach"
    assert _resolve_background(None, matte_ready=False).startswith("pure flat #FFFFFF")
    assert _resolve_background("gradient", matte_ready=False) == (
        "subtle gray-to-white gradient background"
    )


def test_generated_image_to_dict():
    image = GeneratedImage("b64", "prompt", "model", "provider", "url", "path")
    assert image.to_dict() == {
        "image_base64": "b64",
        "image_url": "url",
        "storage_path": "path",
        "prompt": "prompt",
        "model": "model",
        "provider": "provider",
    }
    bare = GeneratedImage("b64", "p", "m", "prov")
    assert bare.to_dict()["image_url"] is None
    assert bare.to_dict()["storage_path"] is None


# =============================================================================
# _matte failure modes
# =============================================================================


@pytest.mark.asyncio
async def test_matte_executor_failure_returns_original():
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    with patch(
        "app.agents.image_generation_agent.run_image_op",
        new=AsyncMock(side_effect=RuntimeError("executor down")),
    ):
        result = await ImageGenerationAgent._matte(generated, context="product image")
    assert result is generated


@pytest.mark.asyncio
async def test_matte_success_returns_new_image():
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    matte_result = MatteResult(
        image_bytes=b"new-bytes",
        content_type="image/webp",
        status=STATUS_MATTED,
        transparent_fraction=0.95,
        center_opacity=1.0,
        width=10,
        height=10,
    )
    with patch(
        "app.agents.image_generation_agent.run_image_op",
        new=AsyncMock(return_value=("bmV3LWJ5dGVz", matte_result)),
    ):
        result = await ImageGenerationAgent._matte(generated, context="product image")
    assert result.image_base64 == "bmV3LWJ5dGVz"
    assert result.prompt == "p"
    assert result.model == "m"
    assert result.provider == "prov"


@pytest.mark.asyncio
async def test_matte_non_matted_status_returns_original():
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    matte_result = MatteResult(
        image_bytes=b"same",
        content_type="image/jpeg",
        status="skipped_no_background",
        transparent_fraction=0.1,
        center_opacity=0.9,
        width=1,
        height=1,
    )
    with patch(
        "app.agents.image_generation_agent.run_image_op",
        new=AsyncMock(return_value=("ZmFrZQ==", matte_result)),
    ):
        result = await ImageGenerationAgent._matte(generated, context="product image")
    assert result is generated


# =============================================================================
# generate_outfit: inventory, item descriptions, body profile
# =============================================================================


@pytest.mark.asyncio
async def test_outfit_empty_inventory_message():
    agent = _make_agent()
    await agent.generate_outfit(items=[], include_model=False)
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Outfit inventory: none provided." in prompt


@pytest.mark.asyncio
async def test_outfit_item_description_uses_all_fields():
    agent = _make_agent()
    item = {
        "name": "Leather biker jacket",
        "brand": "Acme",
        "category": "outerwear",
        "colors": ["black"],
        "material": "leather",
        "pattern": "solid",
    }
    await agent.generate_outfit(items=[item])
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Leather biker jacket by Acme (outerwear)" in prompt
    assert "colors: black" in prompt
    assert "material: leather" in prompt
    assert "pattern: solid" in prompt


@pytest.mark.asyncio
async def test_outfit_item_without_category_skips_parens():
    agent = _make_agent()
    await agent.generate_outfit(items=[{"name": "Silk scarf"}])
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Silk scarf" in prompt
    assert "()" not in prompt


@pytest.mark.asyncio
async def test_outfit_body_profile_embedded_in_avatar_prompt():
    agent = _make_agent()
    await agent.generate_outfit(
        items=[_item("Cream sweater", "tops")],
        user_avatar_base64="YXZhdGFy",
        body_profile={"skin_tone": "medium", "body_shape": "athletic", "height_cm": 178},
    )
    prompt = _chat_prompt(agent)
    assert (
        "Model physical characteristics: skin tone: medium, "
        "body shape: athletic, height: approximately 178cm"
    ) in prompt


@pytest.mark.asyncio
async def test_outfit_empty_body_profile_adds_nothing():
    agent = _make_agent()
    await agent.generate_outfit(
        items=[_item("Cream sweater", "tops")],
        user_avatar_base64="YXZhdGFy",
        body_profile={},
    )
    assert "Model physical characteristics" not in _chat_prompt(agent)


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("profile", "expected"),
    [
        ({"body_shape": "athletic"}, "body shape: athletic"),
        ({"skin_tone": "medium"}, "skin tone: medium"),
        ({"height_cm": 170}, "height: approximately 170cm"),
        ({"unknown_key": "x"}, None),
    ],
)
async def test_outfit_body_profile_partial_variants(profile, expected):
    """Each body-profile field is optional; a truthy dict with no known
    fields produces no characteristics block at all."""
    agent = _make_agent()
    await agent.generate_outfit(
        items=[_item("Cream sweater", "tops")],
        user_avatar_base64="YXZhdGFy",
        body_profile=profile,
    )
    prompt = _chat_prompt(agent)
    if expected is None:
        assert "Model physical characteristics" not in prompt
    else:
        assert f"Model physical characteristics: {expected}" in prompt


@pytest.mark.asyncio
async def test_outfit_pose_flat_lay_word_triggers_flat_lay():
    agent = _make_agent()
    await agent.generate_outfit(items=[_item("tee", "tops")], pose="flat lay", include_model=True)
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Professional flat lay fashion photo" in prompt


@pytest.mark.asyncio
async def test_outfit_custom_prompt_is_appended():
    agent = _make_agent()
    await agent.generate_outfit(items=[_item("tee", "tops")], custom_prompt="Make it moody")
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Additional instructions: Make it moody" in prompt


@pytest.mark.asyncio
async def test_outfit_source_photo_without_avatar_is_image_one():
    agent = _make_agent()
    await agent.generate_outfit(
        items=[_item("Cream sweater", "tops", reference="c3dlYXRlcg==")],
        source_photo_base64="c3Jj",
    )
    content = agent.ai_service.chat.call_args.kwargs["messages"][0].content
    assert [part["type"] for part in content] == ["image_url", "image_url", "text"]
    prompt = content[-1]["text"]
    assert "IMAGE 1 = the original photo of this outfit as worn" in prompt
    assert 'IMAGE 2 = Item 1 "Cream sweater" (tops)' in prompt


# =============================================================================
# generate_product_image: shadows and reference tokens
# =============================================================================


@pytest.mark.asyncio
async def test_product_image_matte_conflict_disables_shadows():
    agent = _make_agent()
    await agent.generate_product_image(
        item_description="tee", category="tops", background="white", include_shadows=True
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "No shadows; fully isolated" in prompt


@pytest.mark.asyncio
async def test_product_image_custom_background_keeps_shadows():
    agent = _make_agent()
    await agent.generate_product_image(
        item_description="tee", category="tops", background="gray", include_shadows=True
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Subtle natural drop shadow" in prompt


@pytest.mark.asyncio
async def test_product_image_reference_tokens_colors_and_material():
    agent = _make_agent()
    await agent.generate_product_image(
        item_description="dress",
        category="bottoms",
        sub_category="jeans",
        colors=["blue"],
        material="denim",
        reference_image="ZmFrZQ==",
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Item: jeans; colors: blue; material: denim." in prompt


@pytest.mark.asyncio
async def test_product_image_reference_tokens_omit_missing_fields():
    agent = _make_agent()
    await agent.generate_product_image(
        item_description="dress",
        category="bottoms",
        colors=["red"],
        reference_image="ZmFrZQ==",
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Item: bottoms; colors: red." in prompt
    assert "material:" not in prompt


@pytest.mark.asyncio
async def test_product_image_reference_without_colors_or_material():
    agent = _make_agent()
    await agent.generate_product_image(
        item_description="dress", category="bottoms", reference_image="ZmFrZQ=="
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "Item: bottoms." in prompt
    assert "colors:" not in prompt


@pytest.mark.asyncio
@pytest.mark.parametrize(
    ("view_angle", "expected"),
    [
        ("front", "front view, straight-on angle"),
        ("side", "three-quarter view angle"),
        ("flat-lay", "flat lay top-down view"),
        ("unknown", "front view, straight-on angle"),
    ],
)
async def test_product_image_view_angles(view_angle, expected):
    agent = _make_agent()
    await agent.generate_product_image(item_description="tee", category="tops", view_angle=view_angle)
    assert expected in agent.ai_service.generate_image.call_args.args[0]


# =============================================================================
# generate_flat_lay and generate_variations
# =============================================================================


@pytest.mark.asyncio
async def test_generate_flat_lay_delegates_to_outfit():
    agent = _make_agent()
    result = await agent.generate_flat_lay(
        items=[_item("tee", "tops")], style="boho", background="white", lighting="warm"
    )
    prompt = agent.ai_service.generate_image.call_args.args[0]
    assert "flat lay (top-down)" in prompt
    assert "boho" in prompt
    assert "warm" in prompt
    assert result.image_base64 == "ZmFrZQ=="


@pytest.mark.asyncio
async def test_generate_variations_default_styles_runs_all():
    agent = _make_agent()

    async def _fake_parallel(items, fn, **kwargs):
        return [
            ParallelResult(success=True, data=await fn(item, index))
            for index, item in enumerate(items)
        ]

    with patch(
        "app.agents.image_generation_agent.parallel_with_retry",
        new=AsyncMock(side_effect=_fake_parallel),
    ):
        results = await agent.generate_variations(items=[_item("tee", "tops")])

    assert len(results) == 3
    assert all(result.image_base64 == "ZmFrZQ==" for result in results)


@pytest.mark.asyncio
async def test_generate_variations_returns_only_successes():
    agent = _make_agent()
    good = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    results = [
        ParallelResult(success=True, data=good, index=0),
        ParallelResult(success=False, error=RuntimeError("kaput"), index=1),
        ParallelResult(success=True, data=good, index=2),
    ]
    with patch(
        "app.agents.image_generation_agent.parallel_with_retry",
        new=AsyncMock(return_value=results),
    ):
        returned = await agent.generate_variations(
            items=[_item("tee", "tops")], styles=["a", "b", "c"]
        )

    assert returned == [good, good]


# =============================================================================
# Error wrapping in every generation path
# =============================================================================


@pytest.mark.asyncio
async def test_generate_with_references_wraps_generic_error():
    agent = _make_agent()
    agent.ai_service.chat = AsyncMock(side_effect=RuntimeError("kaput"))
    with pytest.raises(AIServiceError, match="outfit generation failed: kaput"):
        await agent._generate_with_references("prompt", ["img"], context="outfit")


@pytest.mark.asyncio
async def test_generate_image_no_images_is_retryable():
    agent = _make_agent()
    agent.ai_service.generate_image = AsyncMock(return_value=_FakeImageResponse(""))
    with pytest.raises(AIServiceError) as excinfo:
        await agent.generate_product_image(item_description="tee", category="tops")
    assert excinfo.value.retryable is True


@pytest.mark.asyncio
async def test_generate_image_wraps_generic_error():
    agent = _make_agent()
    agent.ai_service.generate_image = AsyncMock(side_effect=RuntimeError("kaput"))
    with pytest.raises(AIServiceError, match="Image generation failed: kaput"):
        await agent.generate_product_image(item_description="tee", category="tops")


@pytest.mark.asyncio
async def test_try_on_no_images_is_retryable():
    agent = _make_agent()
    agent.ai_service.chat = AsyncMock(return_value=_FakeImageResponse(""))
    with pytest.raises(AIServiceError) as excinfo:
        await agent.generate_try_on(user_avatar_base64="YQ==", clothing_image_base64="Yg==")
    assert excinfo.value.retryable is True


@pytest.mark.asyncio
async def test_try_on_wraps_generic_error():
    agent = _make_agent()
    agent.ai_service.chat = AsyncMock(side_effect=RuntimeError("kaput"))
    with pytest.raises(AIServiceError, match="Try-on generation failed: kaput"):
        await agent.generate_try_on(
            user_avatar_base64="YQ==",
            clothing_image_base64="Yg==",
            clothing_description="A red crew-neck sweater",
        )


@pytest.mark.asyncio
async def test_try_on_propagates_ai_service_error():
    agent = _make_agent()
    agent.ai_service.chat = AsyncMock(side_effect=AIServiceError("refused"))
    with pytest.raises(AIServiceError, match="refused"):
        await agent.generate_try_on(user_avatar_base64="YQ==", clothing_image_base64="Yg==")


@pytest.mark.asyncio
async def test_try_on_embeds_clothing_description():
    agent = _make_agent()
    await agent.generate_try_on(
        user_avatar_base64="YQ==",
        clothing_image_base64="Yg==",
        clothing_description="A red crew-neck sweater",
    )
    content = agent.ai_service.chat.call_args.kwargs["messages"][0].content
    assert [part["type"] for part in content] == ["image_url", "image_url", "text"]
    assert content[0]["image_url"]["url"] == "YQ=="
    assert content[1]["image_url"]["url"] == "Yg=="
    assert "Garment notes: A red crew-neck sweater" in content[2]["text"]


# =============================================================================
# save_generated_image
# =============================================================================


@pytest.mark.asyncio
async def test_save_generated_image_without_db_returns_empty():
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    assert await save_generated_image(generated, user_id="u1") == {
        "image_url": "",
        "storage_path": "",
    }


@pytest.mark.asyncio
async def test_save_generated_image_success(fake_db):
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    upload = AsyncMock(return_value={"public_url": "https://cdn.example/x.png"})
    with (
        patch("app.agents.image_generation_agent.run_image_op", new=AsyncMock(return_value=b"norm")),
        patch("app.agents.image_generation_agent.sniff_image_mime", return_value="image/png"),
        patch("app.services.storage_service.StorageService.upload_file", new=upload),
    ):
        result = await save_generated_image(
            generated, user_id="u1", image_type="outfit", db=fake_db
        )

    assert result["image_url"] == "https://cdn.example/x.png"
    assert result["storage_path"].startswith("generated/u1/outfit/")
    assert result["storage_path"].endswith(".png")
    upload.assert_awaited_once()
    call_kwargs = upload.await_args.kwargs
    assert call_kwargs["file_data"] == b"norm"
    assert call_kwargs["content_type"] == "image/png"
    assert call_kwargs["db"] is fake_db


@pytest.mark.asyncio
async def test_save_generated_image_error_returns_empty(fake_db):
    generated = GeneratedImage("ZmFrZQ==", "p", "m", "prov")
    with patch(
        "app.agents.image_generation_agent.run_image_op",
        new=AsyncMock(side_effect=RuntimeError("disk full")),
    ):
        result = await save_generated_image(
            generated, user_id="u1", image_type="product", db=fake_db
        )
    assert result == {"image_url": "", "storage_path": ""}


# =============================================================================
# Factory
# =============================================================================


@pytest.mark.asyncio
async def test_get_image_generation_agent_factory(monkeypatch, fake_db):
    service = AsyncMock()
    factory = AsyncMock(return_value=service)
    monkeypatch.setattr(AISettingsService, "get_ai_service_for_user", factory)

    agent = await get_image_generation_agent(user_id="u1", db=fake_db)

    assert isinstance(agent, ImageGenerationAgent)
    assert agent.ai_service is service
    factory.assert_awaited_once_with("u1", fake_db)
