"""Tests for AI request model validation (image source migration)."""

import pytest

from app.models.ai import (
    ExtractItemsRequest,
    ExtractSingleItemRequest,
    GenerateProductImageRequest,
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
