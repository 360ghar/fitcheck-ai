"""Tests for AI request model validation (image source migration)."""

import pytest
from pydantic import ValidationError

from app.models.ai import (
    ExtractItemsRequest,
    ExtractSingleItemRequest,
    GenerateOutfitRequest,
    GenerateProductImageRequest,
    OutfitItemInput,
    TryOnRequest,
)

_VALID_STORAGE_PATH = "user-1/items/0123456789abcdef0123456789abcdef.jpg"


def test_try_on_accepts_storage_path_only():
    request = TryOnRequest.model_validate({"clothing_storage_path": _VALID_STORAGE_PATH})
    assert request.clothing_image is None
    assert request.clothing_storage_path == _VALID_STORAGE_PATH


def test_try_on_accepts_explicit_null_legacy_image_with_storage_path():
    """Regression: explicit null for the optional legacy field must not trip
    the strict base64 validator (mirrors ExtractItemsRequest behavior)."""
    request = TryOnRequest.model_validate(
        {"clothing_image": None, "clothing_storage_path": _VALID_STORAGE_PATH}
    )
    assert request.clothing_image is None


def test_try_on_accepts_legacy_inline_image():
    import base64

    # Minimal valid PNG bytes (1x1) - the validator decodes and sniffs.
    png = base64.b64decode(
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="
    )
    request = TryOnRequest.model_validate(
        {"clothing_image": base64.b64encode(png).decode()}
    )
    assert request.clothing_image


def test_try_on_rejects_neither_source():
    with pytest.raises(ValueError, match="clothing_image or clothing_storage_path is required"):
        TryOnRequest.model_validate({})


def test_extract_items_requires_one_source():
    with pytest.raises(ValueError, match="image or storage_path is required"):
        ExtractItemsRequest.model_validate({})
    with pytest.raises(ValueError, match="image or storage_path is required"):
        ExtractItemsRequest.model_validate({"image": ""})
    request = ExtractItemsRequest.model_validate(
        {"image": None, "storage_path": _VALID_STORAGE_PATH}
    )
    assert request.storage_path == _VALID_STORAGE_PATH


def test_extract_single_item_accepts_null_image_with_storage_path():
    request = ExtractSingleItemRequest.model_validate(
        {"image": None, "storage_path": _VALID_STORAGE_PATH}
    )
    assert request.image is None


def test_product_image_accepts_null_reference_with_storage_path():
    request = GenerateProductImageRequest.model_validate(
        {"item_description": "red dress", "category": "dresses", "reference_image": None,
         "reference_storage_path": _VALID_STORAGE_PATH}
    )
    assert request.reference_image is None


# ---------------------------------------------------------------------------
# Prompt/description caps (B3-17) — unbounded strings amplified provider
# prompts; 2000 chars for prompts, 500 for descriptions/labels.
# ---------------------------------------------------------------------------


def _outfit_request_with(**overrides):
    payload = {"items": [{"name": "Shirt"}]}
    payload.update(overrides)
    return payload


def test_outfit_item_input_name_capped_at_500():
    with pytest.raises(ValidationError, match="at most 500 characters"):
        OutfitItemInput(name="n" * 501)


def test_generate_outfit_request_custom_prompt_capped_at_2000():
    with pytest.raises(ValidationError, match="at most 2000 characters"):
        GenerateOutfitRequest.model_validate(
            _outfit_request_with(custom_prompt="p" * 2001)
        )


def test_generate_outfit_request_style_and_background_capped_at_500():
    with pytest.raises(ValidationError, match="at most 500 characters"):
        GenerateOutfitRequest.model_validate(_outfit_request_with(style="s" * 501))
    with pytest.raises(ValidationError, match="at most 500 characters"):
        GenerateOutfitRequest.model_validate(_outfit_request_with(background="b" * 501))
    # Defaults still construct.
    assert GenerateOutfitRequest.model_validate(_outfit_request_with()).style == "casual"


def test_generate_product_image_request_item_description_capped_at_500():
    with pytest.raises(ValidationError, match="at most 500 characters"):
        GenerateProductImageRequest(
            item_description="d" * 501,
            category="tops",
        )


def test_try_on_request_description_and_style_capped():
    with pytest.raises(ValidationError, match="at most 500 characters"):
        TryOnRequest.model_validate(
            {
                "clothing_storage_path": _VALID_STORAGE_PATH,
                "clothing_description": "c" * 501,
            }
        )
    with pytest.raises(ValidationError, match="at most 500 characters"):
        TryOnRequest.model_validate(
            {
                "clothing_storage_path": _VALID_STORAGE_PATH,
                "style": "s" * 501,
            }
        )
