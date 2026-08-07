"""Handler-branch coverage for app/api/v1/ai.py.

Exercises every AI endpoint (extraction, outfit/product/try-on generation,
models, embeddings, similarity search, provider test) with patched agents and
services — no provider or storage is ever contacted. Covers validation errors
(unowned storage paths, missing avatar), provider-failure branches (generic
exceptions wrapped as AIServiceError, FitCheckException re-raised), and the
rate-limit rejection path via a stubbed SubscriptionService.

Follows the house convention of calling route functions directly with
tests.utils.fake_db.FakeDB and Mock user ids.
"""
import base64
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock

import pytest
from fastapi import HTTPException

from app.api.v1 import ai as ai_module
from app.core.exceptions import AIServiceError, RateLimitError
from app.models.ai import (
    ExtractItemsRequest,
    ExtractSingleItemRequest,
    GenerateOutfitRequest,
    GenerateProductImageRequest,
    OutfitItemInput,
    TryOnRequest,
)
from app.services.ai_service import EmbeddingService
from app.services.storage_service import StorageService
from app.services.subscription_service import SubscriptionService
from tests.factories.row_factories import user_row
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"
OWNED = f"{USER_ID}/items/0123456789abcdef0123456789abcdef.jpg"
FOREIGN = "22222222-2222-2222-2222-222222222222/items/0123456789abcdef0123456789abcdef.jpg"
OWNED_AVATAR = f"{USER_ID}/avatars/0123456789abcdef0123456789abcdef.jpg"

_PNG_1PX = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
)
INLINE_IMAGE = base64.b64encode(_PNG_1PX).decode()


def _patch_rate_limit(monkeypatch, allowed: bool = True):
    """Stub SubscriptionService so rate_limited_operation yields / raises."""
    rate_check = SimpleNamespace(
        allowed=allowed,
        limit=10,
        current_count=1,
        remaining=9,
        plan_type=SimpleNamespace(value="free"),
    )
    monkeypatch.setattr(SubscriptionService, "check_limit", AsyncMock(return_value=rate_check))
    monkeypatch.setattr(SubscriptionService, "increment_usage", AsyncMock())
    monkeypatch.setattr(SubscriptionService, "plan_display_name", staticmethod(lambda pt: "Pro"))
    monkeypatch.setattr(SubscriptionService, "can_upgrade", staticmethod(lambda pt: False))
    return rate_check


def _patch_get_public_url(monkeypatch, url_factory=None):
    """Stub the async get_public_url with an awaitable fake."""

    async def _presign(path):
        return url_factory(path) if url_factory else f"https://cdn.example/{path}"

    monkeypatch.setattr(StorageService, "get_public_url", staticmethod(_presign))


def _extract_items_result() -> dict:
    return {
        "items": [],
        "people": [],
        "overall_confidence": 0.9,
        "image_description": "a tee",
        "item_count": 0,
        "requires_review": True,
        "has_profile_reference": False,
        "profile_match_found": False,
    }


def _outfit_result(image_base64: str = "img-b64"):
    return SimpleNamespace(image_base64=image_base64, prompt="p", model="m", provider="gemini")


def _fake_agent(monkeypatch, method: str, result=None, error=None):
    """Patch get_image_generation_agent / get_item_extraction_agent."""
    agent = Mock()
    target = AsyncMock(return_value=result) if error is None else AsyncMock(side_effect=error)
    setattr(agent, method, target)
    monkeypatch.setattr(ai_module, "get_image_generation_agent", AsyncMock(return_value=agent))
    return agent, target


# ===========================================================================
# _materialize_image_source
# ===========================================================================


@pytest.mark.asyncio
async def test_materialize_image_source_passes_inline_image_through():
    assert await ai_module._materialize_image_source(INLINE_IMAGE, None, USER_ID) == INLINE_IMAGE


@pytest.mark.asyncio
async def test_materialize_image_source_rejects_missing_source():
    with pytest.raises(HTTPException) as exc_info:
        await ai_module._materialize_image_source(None, None, USER_ID)
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_materialize_image_source_rejects_foreign_storage_path():
    with pytest.raises(HTTPException) as exc_info:
        await ai_module._materialize_image_source(None, FOREIGN, USER_ID)
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_materialize_image_source_returns_fresh_url_for_owned_path(monkeypatch):
    _patch_get_public_url(monkeypatch)

    url = await ai_module._materialize_image_source(None, OWNED, USER_ID)

    assert url == f"https://cdn.example/{OWNED}"


# ===========================================================================
# _provider_ready_avatar_url
# ===========================================================================


@pytest.mark.asyncio
async def test_provider_ready_avatar_url_uses_fresh_materialized_url(monkeypatch):
    async def _fresh(_avatar_url, *, presigned=False):
        return "https://fresh.example/avatar.jpg"

    monkeypatch.setattr(ai_module, "materialize_avatar_url", _fresh)

    assert await ai_module._provider_ready_avatar_url(OWNED_AVATAR) == "https://fresh.example/avatar.jpg"


@pytest.mark.asyncio
async def test_provider_ready_avatar_url_passes_https_external_url(monkeypatch):
    async def _none(_avatar_url, *, presigned=False):
        return None

    monkeypatch.setattr(ai_module, "materialize_avatar_url", _none)
    url = "https://lh3.googleusercontent.com/a/AA123456"

    assert await ai_module._provider_ready_avatar_url(url) == url


@pytest.mark.asyncio
async def test_provider_ready_avatar_url_rejects_non_https_external_url(monkeypatch):
    async def _none(_avatar_url, *, presigned=False):
        return None

    monkeypatch.setattr(ai_module, "materialize_avatar_url", _none)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module._provider_ready_avatar_url("http://169.254.169.254/latest/meta-data/")
    assert exc_info.value.status_code == 400


# ===========================================================================
# _fetch_user_avatar_base64
# ===========================================================================


@pytest.mark.asyncio
async def test_fetch_user_avatar_base64_downloads_stored_avatar(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR)]})
    monkeypatch.setattr(
        StorageService, "download_to_base64", staticmethod(AsyncMock(return_value="b64-avatar"))
    )

    avatar = await ai_module._fetch_user_avatar_base64(USER_ID, db)

    assert avatar == "b64-avatar"


@pytest.mark.asyncio
async def test_fetch_user_avatar_base64_missing_user_returns_none():
    db = FakeDB(rows={"users": []})

    assert await ai_module._fetch_user_avatar_base64(USER_ID, db) is None


@pytest.mark.asyncio
async def test_fetch_user_avatar_base64_missing_avatar_url_returns_none():
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=None)]})

    assert await ai_module._fetch_user_avatar_base64(USER_ID, db) is None


@pytest.mark.asyncio
async def test_fetch_user_avatar_base64_download_failure_returns_none(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR)]})
    monkeypatch.setattr(
        StorageService,
        "download_to_base64",
        staticmethod(AsyncMock(side_effect=RuntimeError("storage down"))),
    )

    assert await ai_module._fetch_user_avatar_base64(USER_ID, db) is None


# ===========================================================================
# POST /extract-items
# ===========================================================================


@pytest.mark.asyncio
async def test_extract_items_happy_path_with_storage_path(monkeypatch):
    request = ExtractItemsRequest(storage_path=OWNED)
    agent = Mock()
    agent.extract_multiple_items = AsyncMock(return_value=_extract_items_result())
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    monkeypatch.setattr(ai_module, "_fetch_user_avatar_base64", AsyncMock(return_value=None))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    result = await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Items extracted successfully"
    assert result["data"]["overall_confidence"] == 0.9
    kwargs = agent.extract_multiple_items.await_args.kwargs
    assert kwargs["image_base64"] == f"https://cdn.example/{OWNED}"
    assert kwargs["user_profile_image_base64"] is None


@pytest.mark.asyncio
async def test_extract_items_with_inline_image(monkeypatch):
    request = ExtractItemsRequest(image=INLINE_IMAGE)
    agent = Mock()
    agent.extract_multiple_items = AsyncMock(return_value=_extract_items_result())
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    monkeypatch.setattr(ai_module, "_fetch_user_avatar_base64", AsyncMock(return_value="b64"))
    _patch_rate_limit(monkeypatch)

    result = await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Items extracted successfully"
    kwargs = agent.extract_multiple_items.await_args.kwargs
    assert kwargs["image_base64"] == INLINE_IMAGE
    assert kwargs["user_profile_image_base64"] == "b64"


@pytest.mark.asyncio
async def test_extract_items_propagates_http_exception(monkeypatch):
    request = ExtractItemsRequest(storage_path=FOREIGN)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_extract_items_propagates_fitcheck_exception(monkeypatch):
    request = ExtractItemsRequest(storage_path=OWNED)
    agent = Mock()
    agent.extract_multiple_items = AsyncMock(side_effect=AIServiceError("provider refused"))
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    monkeypatch.setattr(ai_module, "_fetch_user_avatar_base64", AsyncMock(return_value=None))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_extract_items_wraps_generic_errors(monkeypatch):
    request = ExtractItemsRequest(storage_path=OWNED)
    agent = Mock()
    agent.extract_multiple_items = AsyncMock(side_effect=RuntimeError("boom"))
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    monkeypatch.setattr(ai_module, "_fetch_user_avatar_base64", AsyncMock(return_value=None))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())
    assert "Failed to extract items" in str(exc_info.value)


@pytest.mark.asyncio
async def test_extract_items_rate_limited(monkeypatch):
    request = ExtractItemsRequest(storage_path=OWNED)
    _patch_rate_limit(monkeypatch, allowed=False)

    with pytest.raises(RateLimitError):
        await ai_module.extract_items(request=request, user_id=USER_ID, db=FakeDB())


# ===========================================================================
# POST /extract-single-item
# ===========================================================================


@pytest.mark.asyncio
async def test_extract_single_item_happy_path(monkeypatch):
    request = ExtractSingleItemRequest(storage_path=OWNED, category_hint="tops")
    agent = Mock()
    agent.extract_single_item = AsyncMock(
        return_value={"category": "tops", "confidence": 0.8, "description": "d"}
    )
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    result = await ai_module.extract_single_item(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Item extracted successfully"
    assert result["data"]["category"] == "tops"
    kwargs = agent.extract_single_item.await_args.kwargs
    assert kwargs["category_hint"] == "tops"


@pytest.mark.asyncio
async def test_extract_single_item_wraps_generic_errors(monkeypatch):
    request = ExtractSingleItemRequest(storage_path=OWNED)
    agent = Mock()
    agent.extract_single_item = AsyncMock(side_effect=RuntimeError("boom"))
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.extract_single_item(request=request, user_id=USER_ID, db=FakeDB())
    assert "Failed to extract item" in str(exc_info.value)


@pytest.mark.asyncio
async def test_extract_single_item_propagates_http_exception(monkeypatch):
    request = ExtractSingleItemRequest(storage_path=FOREIGN)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.extract_single_item(request=request, user_id=USER_ID, db=FakeDB())
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_extract_single_item_propagates_fitcheck_exception(monkeypatch):
    request = ExtractSingleItemRequest(storage_path=OWNED)
    agent = Mock()
    agent.extract_single_item = AsyncMock(side_effect=AIServiceError("provider refused"))
    monkeypatch.setattr(ai_module, "get_item_extraction_agent", AsyncMock(return_value=agent))
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.extract_single_item(request=request, user_id=USER_ID, db=FakeDB())


# ===========================================================================
# POST /generate-outfit
# ===========================================================================


def _outfit_request(**overrides):
    defaults = {"items": [OutfitItemInput(name="Crew-neck tee")], "include_user_face": False}
    defaults.update(overrides)
    return GenerateOutfitRequest(**defaults)


@pytest.mark.asyncio
async def test_generate_outfit_happy_path(monkeypatch):
    request = _outfit_request()
    items = [item.model_dump() for item in request.items]
    agent, gen = _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Outfit generated successfully"
    assert result["data"]["image_base64"] == "img-b64"
    assert result["data"]["image_url"] is None
    gen.assert_awaited_once()
    assert gen.await_args.kwargs["items"] == items


@pytest.mark.asyncio
async def test_generate_outfit_with_avatar_and_body_profile(monkeypatch):
    request = _outfit_request(include_user_face=True, use_body_profile=True)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(
        rows={
            "users": [
                user_row(id=USER_ID, avatar_url=OWNED_AVATAR, body_profile_id="bp-1"),
            ],
            "body_profiles": [
                {
                    "id": "bp-1",
                    "height_cm": 170.0,
                    "weight_kg": 65.0,
                    "body_shape": "hourglass",
                    "skin_tone": "medium",
                },
            ],
        }
    )
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        StorageService, "download_to_base64", staticmethod(AsyncMock(return_value="raw-avatar"))
    )
    monkeypatch.setattr(ai_module, "downscale_base64_image", lambda b64: f"{b64}-downscaled")
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Outfit generated successfully"
    kwargs = ai_module.get_image_generation_agent.await_args.kwargs
    assert kwargs == {"user_id": USER_ID, "db": db}
    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["user_avatar_base64"] == "raw-avatar-downscaled"
    assert gen_kwargs["body_profile"]["height_cm"] == 170.0


@pytest.mark.asyncio
async def test_generate_outfit_no_avatar_but_uses_body_profile(monkeypatch):
    request = _outfit_request(include_user_face=True)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=None, body_profile_id="bp-1")]})
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Outfit generated successfully"
    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["user_avatar_base64"] is None


@pytest.mark.asyncio
async def test_generate_outfit_avatar_download_returns_none(monkeypatch):
    request = _outfit_request(include_user_face=True)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR)]})
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        StorageService, "download_to_base64", staticmethod(AsyncMock(return_value=None))
    )
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["user_avatar_base64"] is None


@pytest.mark.asyncio
async def test_generate_outfit_body_profile_disabled(monkeypatch):
    request = _outfit_request(include_user_face=True, use_body_profile=False)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(
        rows={
            "users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR, body_profile_id="bp-1")],
            "body_profiles": [],
        }
    )
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        StorageService, "download_to_base64", staticmethod(AsyncMock(return_value="raw-avatar"))
    )
    monkeypatch.setattr(ai_module, "downscale_base64_image", lambda b64: f"{b64}-downscaled")
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["user_avatar_base64"] == "raw-avatar-downscaled"
    assert gen_kwargs["body_profile"] is None


@pytest.mark.asyncio
async def test_generate_outfit_body_profile_row_missing(monkeypatch):
    request = _outfit_request(include_user_face=True)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(
        rows={
            "users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR, body_profile_id="bp-missing")],
            "body_profiles": [],
        }
    )
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        StorageService, "download_to_base64", staticmethod(AsyncMock(return_value="raw-avatar"))
    )
    monkeypatch.setattr(ai_module, "downscale_base64_image", lambda b64: f"{b64}-downscaled")
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["body_profile"] is None


@pytest.mark.asyncio
async def test_generate_outfit_avatar_download_failure_falls_back_to_generic_model(monkeypatch):
    request = _outfit_request(include_user_face=True)
    items = [item.model_dump() for item in request.items]
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=OWNED_AVATAR)]})
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        StorageService,
        "download_to_base64",
        staticmethod(AsyncMock(side_effect=RuntimeError("storage down"))),
    )
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Outfit generated successfully"
    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["user_avatar_base64"] is None


@pytest.mark.asyncio
async def test_generate_outfit_with_source_photo_reference(monkeypatch):
    request = _outfit_request(include_user_face=False, use_source_photo=True)
    items = [item.model_dump() for item in request.items]
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_source_reference",
        AsyncMock(return_value=("src-b64", {"source_photo": 1})),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Outfit generated successfully"
    gen_kwargs = ai_module.get_image_generation_agent.return_value.generate_outfit.await_args.kwargs
    assert gen_kwargs["source_photo_base64"] == "src-b64"


@pytest.mark.asyncio
async def test_generate_outfit_saves_to_storage(monkeypatch):
    request = _outfit_request(save_to_storage=True)
    items = [item.model_dump() for item in request.items]
    _fake_agent(monkeypatch, "generate_outfit", result=_outfit_result())
    monkeypatch.setattr(
        ai_module,
        "resolve_outfit_item_references",
        AsyncMock(return_value=(items, {"items": 1, "resolved": 0})),
    )
    monkeypatch.setattr(
        ai_module,
        "save_generated_image",
        AsyncMock(return_value={"image_url": "https://cdn.example/o.jpg", "storage_path": "p"}),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_outfit(request=request, user_id=USER_ID, db=FakeDB())

    assert result["data"]["image_base64"] == ""
    assert result["data"]["image_url"] == "https://cdn.example/o.jpg"
    assert result["data"]["storage_path"] == "p"
    saved = ai_module.save_generated_image.await_args.kwargs
    assert saved["image_type"] == "outfit"


@pytest.mark.asyncio
async def test_generate_outfit_wraps_generic_errors(monkeypatch):
    request = _outfit_request()
    _fake_agent(monkeypatch, "generate_outfit", error=RuntimeError("boom"))
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.generate_outfit(request=request, user_id=USER_ID, db=FakeDB())
    assert "Failed to generate outfit" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_outfit_rate_limited(monkeypatch):
    request = _outfit_request()
    _patch_rate_limit(monkeypatch, allowed=False)

    with pytest.raises(RateLimitError):
        await ai_module.generate_outfit(request=request, user_id=USER_ID, db=FakeDB())


# ===========================================================================
# POST /generate-product-image
# ===========================================================================


def _product_request(**overrides):
    defaults = {"item_description": "red dress", "category": "dresses"}
    defaults.update(overrides)
    return GenerateProductImageRequest(**defaults)


@pytest.mark.asyncio
async def test_generate_product_image_happy_path(monkeypatch):
    request = _product_request()
    _fake_agent(monkeypatch, "generate_product_image", result=_outfit_result())
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Product image generated successfully"
    assert result["data"]["image_base64"] == "img-b64"
    gen = ai_module.get_image_generation_agent.return_value.generate_product_image
    assert gen.await_args.kwargs["reference_image"] is None


@pytest.mark.asyncio
async def test_generate_product_image_with_inline_reference(monkeypatch):
    request = _product_request(reference_image=INLINE_IMAGE)
    _fake_agent(monkeypatch, "generate_product_image", result=_outfit_result())
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())

    assert result["message"] == "Product image generated successfully"
    gen = ai_module.get_image_generation_agent.return_value.generate_product_image
    assert gen.await_args.kwargs["reference_image"] == INLINE_IMAGE


@pytest.mark.asyncio
async def test_generate_product_image_with_owned_storage_reference(monkeypatch):
    request = _product_request(reference_storage_path=OWNED)
    _fake_agent(monkeypatch, "generate_product_image", result=_outfit_result())
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())

    gen = ai_module.get_image_generation_agent.return_value.generate_product_image
    assert gen.await_args.kwargs["reference_image"] == f"https://cdn.example/{OWNED}"


@pytest.mark.asyncio
async def test_generate_product_image_rejects_foreign_storage_reference(monkeypatch):
    request = _product_request(reference_storage_path=FOREIGN)
    _patch_rate_limit(monkeypatch)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_generate_product_image_saves_to_storage(monkeypatch):
    request = _product_request(save_to_storage=True)
    _fake_agent(monkeypatch, "generate_product_image", result=_outfit_result())
    monkeypatch.setattr(
        ai_module,
        "save_generated_image",
        AsyncMock(return_value={"image_url": "https://cdn.example/p.jpg", "storage_path": "p"}),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())

    assert result["data"]["image_base64"] == ""
    assert result["data"]["image_url"] == "https://cdn.example/p.jpg"
    assert ai_module.save_generated_image.await_args.kwargs["image_type"] == "product"


@pytest.mark.asyncio
async def test_generate_product_image_wraps_generic_errors(monkeypatch):
    request = _product_request()
    _fake_agent(monkeypatch, "generate_product_image", error=RuntimeError("boom"))
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())
    assert "Failed to generate product image" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_product_image_propagates_fitcheck_exception(monkeypatch):
    request = _product_request()
    _fake_agent(monkeypatch, "generate_product_image", error=AIServiceError("provider refused"))
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.generate_product_image(request=request, user_id=USER_ID, db=FakeDB())


# ===========================================================================
# POST /try-on
# ===========================================================================


def _try_on_request(**overrides):
    defaults = {"clothing_storage_path": OWNED}
    defaults.update(overrides)
    return TryOnRequest(**defaults)


@pytest.mark.asyncio
async def test_generate_try_on_user_not_found():
    request = _try_on_request()

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=FakeDB())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_generate_try_on_requires_avatar():
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=None)]})
    request = _try_on_request()

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)
    assert exc_info.value.status_code == 400


@pytest.mark.asyncio
async def test_generate_try_on_rejects_foreign_avatar_storage_path():
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="https://ext.example/a.jpg")]})
    request = _try_on_request(avatar_storage_path=FOREIGN)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)
    assert exc_info.value.status_code == 403


@pytest.mark.asyncio
async def test_generate_try_on_happy_path_with_stored_avatar(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="http://stored/avatar.jpg")]})
    request = _try_on_request()
    _fake_agent(monkeypatch, "generate_try_on", result=_outfit_result())
    monkeypatch.setattr(
        ai_module, "materialize_avatar_url", AsyncMock(return_value="https://fresh.example/a.jpg")
    )
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Try-on image generated successfully"
    gen = ai_module.get_image_generation_agent.return_value.generate_try_on
    assert gen.await_args.kwargs["user_avatar_base64"] == "https://fresh.example/a.jpg"
    assert gen.await_args.kwargs["clothing_image_base64"] == f"https://cdn.example/{OWNED}"


@pytest.mark.asyncio
async def test_generate_try_on_happy_path_with_avatar_storage_path(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=None)]})
    request = _try_on_request(avatar_storage_path=OWNED_AVATAR)
    _fake_agent(monkeypatch, "generate_try_on", result=_outfit_result())
    _patch_get_public_url(monkeypatch)
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Try-on image generated successfully"
    gen = ai_module.get_image_generation_agent.return_value.generate_try_on
    assert gen.await_args.kwargs["user_avatar_base64"] == f"https://cdn.example/{OWNED_AVATAR}"


@pytest.mark.asyncio
async def test_generate_try_on_bad_gateway_when_avatar_url_empty(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url=None)]})
    request = _try_on_request(avatar_storage_path=OWNED_AVATAR)
    _patch_get_public_url(monkeypatch, url_factory=lambda path: "")
    _patch_rate_limit(monkeypatch)

    with pytest.raises(HTTPException) as exc_info:
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)
    assert exc_info.value.status_code == 502


@pytest.mark.asyncio
async def test_generate_try_on_with_inline_clothing_image(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="http://stored/a.jpg")]})
    request = _try_on_request(clothing_image=INLINE_IMAGE)
    _fake_agent(monkeypatch, "generate_try_on", result=_outfit_result())
    monkeypatch.setattr(
        ai_module, "materialize_avatar_url", AsyncMock(return_value="https://fresh.example/a.jpg")
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)

    assert result["message"] == "Try-on image generated successfully"
    gen = ai_module.get_image_generation_agent.return_value.generate_try_on
    assert gen.await_args.kwargs["clothing_image_base64"] == INLINE_IMAGE


@pytest.mark.asyncio
async def test_generate_try_on_saves_to_storage(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="http://stored/a.jpg")]})
    request = _try_on_request(save_to_storage=True)
    _fake_agent(monkeypatch, "generate_try_on", result=_outfit_result())
    monkeypatch.setattr(
        ai_module, "materialize_avatar_url", AsyncMock(return_value="https://fresh.example/a.jpg")
    )
    monkeypatch.setattr(
        ai_module,
        "save_generated_image",
        AsyncMock(return_value={"image_url": "https://cdn.example/t.jpg", "storage_path": "p"}),
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)

    assert result["data"]["image_base64"] == ""
    assert result["data"]["image_url"] == "https://cdn.example/t.jpg"
    assert ai_module.save_generated_image.await_args.kwargs["image_type"] == "try-on"


@pytest.mark.asyncio
async def test_generate_try_on_wraps_generic_errors(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="http://stored/a.jpg")]})
    request = _try_on_request()
    _fake_agent(monkeypatch, "generate_try_on", error=RuntimeError("boom"))
    monkeypatch.setattr(
        ai_module, "materialize_avatar_url", AsyncMock(return_value="https://fresh.example/a.jpg")
    )
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)
    assert "Failed to generate try-on" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_try_on_propagates_fitcheck_exception(monkeypatch):
    db = FakeDB(rows={"users": [user_row(id=USER_ID, avatar_url="http://stored/a.jpg")]})
    request = _try_on_request()
    _fake_agent(monkeypatch, "generate_try_on", error=AIServiceError("provider refused"))
    monkeypatch.setattr(
        ai_module, "materialize_avatar_url", AsyncMock(return_value="https://fresh.example/a.jpg")
    )
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.generate_try_on(request=request, user_id=USER_ID, db=db)


# ===========================================================================
# GET /models
# ===========================================================================


@pytest.mark.asyncio
async def test_get_available_models_returns_provider_model_lists():
    result = await ai_module.get_available_models(user_id=USER_ID)

    assert result["message"] == "OK"
    assert "gpt-4o" in result["data"]["openai"]["chat"]
    assert "gemini-3.6-flash" in result["data"]["gemini"]["chat"]


# ===========================================================================
# POST /embeddings
# ===========================================================================


@pytest.mark.asyncio
async def test_generate_embedding_happy_path(monkeypatch):
    monkeypatch.setattr(EmbeddingService, "generate_embedding", AsyncMock(return_value=[0.1, 0.2, 0.3]))
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_embedding(
        ai_module.EmbeddingRequest(text="linen shirt"), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Embedding generated successfully"
    assert result["data"]["dimensions"] == 3
    assert result["data"]["provider"] == "gemini"


@pytest.mark.asyncio
async def test_generate_embedding_propagates_fitcheck_exception(monkeypatch):
    monkeypatch.setattr(
        EmbeddingService, "generate_embedding", AsyncMock(side_effect=AIServiceError("provider down"))
    )
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.generate_embedding(
            ai_module.EmbeddingRequest(text="linen shirt"), user_id=USER_ID, db=FakeDB()
        )


@pytest.mark.asyncio
async def test_generate_embedding_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(EmbeddingService, "generate_embedding", AsyncMock(side_effect=RuntimeError("boom")))
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.generate_embedding(
            ai_module.EmbeddingRequest(text="linen shirt"), user_id=USER_ID, db=FakeDB()
        )
    assert "Failed to generate embedding" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_batch_embeddings_happy_path(monkeypatch):
    monkeypatch.setattr(
        EmbeddingService, "batch_generate_embeddings", AsyncMock(return_value=[[0.1], [0.2]])
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.generate_batch_embeddings(
        ai_module.BatchEmbeddingRequest(texts=["linen", "cotton"]), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Batch embeddings generated successfully"
    assert result["data"]["count"] == 2
    assert result["data"]["dimensions"] == 1


@pytest.mark.asyncio
async def test_generate_batch_embeddings_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(
        EmbeddingService, "batch_generate_embeddings", AsyncMock(side_effect=RuntimeError("boom"))
    )
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.generate_batch_embeddings(
            ai_module.BatchEmbeddingRequest(texts=["linen"]), user_id=USER_ID, db=FakeDB()
        )
    assert "Failed to generate batch embeddings" in str(exc_info.value)


@pytest.mark.asyncio
async def test_generate_batch_embeddings_empty_texts_short_circuits(monkeypatch):
    """model_construct bypasses the min_length guard to reach the dead branch."""
    request = ai_module.BatchEmbeddingRequest.model_construct(texts=[])

    result = await ai_module.generate_batch_embeddings(
        request, user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "No texts provided"
    assert result["data"]["embeddings"] == []


@pytest.mark.asyncio
async def test_generate_batch_embeddings_propagates_fitcheck_exception(monkeypatch):
    monkeypatch.setattr(
        EmbeddingService,
        "batch_generate_embeddings",
        AsyncMock(side_effect=AIServiceError("provider down")),
    )
    _patch_rate_limit(monkeypatch)

    with pytest.raises(AIServiceError):
        await ai_module.generate_batch_embeddings(
            ai_module.BatchEmbeddingRequest(texts=["linen"]), user_id=USER_ID, db=FakeDB()
        )


# ===========================================================================
# POST /embeddings/search
# ===========================================================================


@pytest.mark.asyncio
async def test_search_similar_items_requires_text_or_embedding():
    with pytest.raises(HTTPException) as exc_info:
        await ai_module.search_similar_items(
            ai_module.SimilaritySearchRequest(), user_id=USER_ID, db=FakeDB()
        )
    assert exc_info.value.status_code == 400


@pytest.mark.asyncio
async def test_search_similar_items_with_embedding(monkeypatch):
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(
        return_value=[{"id": "i1", "score": 0.9, "metadata": {"name": "tee"}}]
    )
    monkeypatch.setattr(ai_module, "get_vector_service", lambda: vector_service)

    result = await ai_module.search_similar_items(
        ai_module.SimilaritySearchRequest(embedding=[0.1, 0.2]), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Found 1 similar items"
    assert result["data"]["items"][0]["item_id"] == "i1"
    assert result["data"]["query_embedding_dimensions"] == 2
    vector_service.find_similar.assert_awaited_once()


@pytest.mark.asyncio
async def test_search_similar_items_with_text_generates_embedding(monkeypatch):
    monkeypatch.setattr(EmbeddingService, "generate_embedding", AsyncMock(return_value=[0.5, 0.5]))
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(return_value=[])
    monkeypatch.setattr(ai_module, "get_vector_service", lambda: vector_service)
    _patch_rate_limit(monkeypatch)

    result = await ai_module.search_similar_items(
        ai_module.SimilaritySearchRequest(text="linen"), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Found 0 similar items"
    call_kwargs = vector_service.find_similar.await_args.kwargs
    assert call_kwargs["embedding"] == [0.5, 0.5]
    assert call_kwargs["user_id"] == USER_ID


@pytest.mark.asyncio
async def test_search_similar_items_wraps_generic_errors(monkeypatch):
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(side_effect=RuntimeError("boom"))
    monkeypatch.setattr(ai_module, "get_vector_service", lambda: vector_service)

    with pytest.raises(AIServiceError) as exc_info:
        await ai_module.search_similar_items(
            ai_module.SimilaritySearchRequest(embedding=[0.1]), user_id=USER_ID, db=FakeDB()
        )
    assert "Failed to search similar items" in str(exc_info.value)


@pytest.mark.asyncio
async def test_search_similar_items_propagates_fitcheck_exception(monkeypatch):
    vector_service = Mock()
    vector_service.find_similar = AsyncMock(side_effect=AIServiceError("vector store down"))
    monkeypatch.setattr(ai_module, "get_vector_service", lambda: vector_service)

    with pytest.raises(AIServiceError):
        await ai_module.search_similar_items(
            ai_module.SimilaritySearchRequest(embedding=[0.1]), user_id=USER_ID, db=FakeDB()
        )


# ===========================================================================
# POST /embeddings/test
# ===========================================================================


@pytest.mark.asyncio
async def test_embedding_model_happy_path(monkeypatch):
    monkeypatch.setattr(EmbeddingService, "generate_embedding", AsyncMock(return_value=[1.0]))
    _patch_rate_limit(monkeypatch)

    result = await ai_module.test_embedding_model(
        ai_module.TestEmbeddingRequest(provider="gemini", model="gemini-embed"), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Embedding model test successful"
    assert result["data"]["success"] is True


@pytest.mark.asyncio
async def test_embedding_model_reports_ai_service_failure(monkeypatch):
    monkeypatch.setattr(
        EmbeddingService, "generate_embedding", AsyncMock(side_effect=AIServiceError("key invalid"))
    )
    _patch_rate_limit(monkeypatch)

    result = await ai_module.test_embedding_model(
        ai_module.TestEmbeddingRequest(provider="gemini", model="m"), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "Embedding model test failed"
    assert result["data"]["success"] is False


@pytest.mark.asyncio
async def test_embedding_model_reports_generic_failure(monkeypatch):
    monkeypatch.setattr(EmbeddingService, "generate_embedding", AsyncMock(side_effect=RuntimeError("boom")))
    _patch_rate_limit(monkeypatch)

    result = await ai_module.test_embedding_model(
        ai_module.TestEmbeddingRequest(provider="gemini", model="m"), user_id=USER_ID, db=FakeDB()
    )

    assert result["data"]["success"] is False
    assert "boom" in result["data"]["message"]


@pytest.mark.asyncio
async def test_embedding_model_rate_limited(monkeypatch):
    _patch_rate_limit(monkeypatch, allowed=False)

    with pytest.raises(RateLimitError):
        await ai_module.test_embedding_model(
            ai_module.TestEmbeddingRequest(provider="gemini", model="m"), user_id=USER_ID, db=FakeDB()
        )
