"""Residual branch coverage for app.models.item.

The sibling test_item_occasion_tags.py covers tag normalization through the
models; this file covers the remaining validators: tag-list input shapes
(None/str/scalar), the category/condition/price validation branches on
ItemCreate and ItemUpdate, the DECIMAL(10,2) price bounds, the response-side
leniency (no whitelist validators on ItemResponse), and the shared
colors/tags/seasonal_tags normalization.
"""

import pytest
from pydantic import ValidationError

from app.models.item import ItemCreate, ItemResponse, ItemUpdate, normalize_tag_list


def test_normalize_tag_list_none_returns_empty():
    assert normalize_tag_list(None) == []


def test_normalize_tag_list_string_becomes_single_tag():
    assert normalize_tag_list("Formal") == ["formal"]


def test_normalize_tag_list_scalar_non_string_is_wrapped():
    assert normalize_tag_list(42) == ["42"]


def test_item_create_accepts_valid_category_and_condition():
    item = ItemCreate(name="Shirt", category="TOPS", condition="clean", price=12.5)
    assert item.category == "tops"
    assert item.condition == "clean"


def test_item_create_rejects_invalid_category():
    with pytest.raises(ValidationError, match="Invalid category"):
        ItemCreate(name="Shirt", category="hovercraft")


def test_item_create_rejects_invalid_condition():
    with pytest.raises(ValidationError, match="Invalid condition"):
        ItemCreate(name="Shirt", category="tops", condition="sparkly")


def test_item_create_rejects_negative_price():
    with pytest.raises(ValidationError, match="greater than or equal to 0"):
        ItemCreate(name="Shirt", category="tops", price=-1.0)


def test_item_create_allows_none_price():
    item = ItemCreate(name="Shirt", category="tops", price=None)
    assert item.price is None


def test_item_update_lowercases_provided_category():
    update = ItemUpdate(category="BOTTOMS")
    assert update.category == "bottoms"


def test_item_update_rejects_invalid_category():
    with pytest.raises(ValidationError, match="Invalid category"):
        ItemUpdate(category="hovercraft")


def test_item_update_keeps_none_category():
    assert ItemUpdate().category is None


def test_item_update_rejects_invalid_condition():
    with pytest.raises(ValidationError, match="Invalid condition"):
        ItemUpdate(condition="sparkly")


def test_item_update_keeps_none_condition():
    assert ItemUpdate().condition is None


def test_item_update_occasion_tags_none_is_preserved():
    update = ItemUpdate(occasion_tags=None)
    assert update.occasion_tags is None


# ---------------------------------------------------------------------------
# DECIMAL(10,2) price bounds (B3-05)
# ---------------------------------------------------------------------------


def test_item_create_rejects_infinite_price():
    with pytest.raises(ValidationError, match="finite"):
        ItemCreate(name="Shirt", category="tops", price=float("inf"))


def test_item_create_rejects_price_beyond_decimal_bounds():
    with pytest.raises(ValidationError, match="less than or equal to 99999999.99"):
        ItemCreate(name="Shirt", category="tops", price=1e8)


def test_item_create_accepts_max_decimal_price():
    item = ItemCreate(name="Shirt", category="tops", price=99_999_999.99)
    assert item.price == 99_999_999.99


def test_item_update_rejects_infinite_price():
    with pytest.raises(ValidationError, match="finite"):
        ItemUpdate(price=float("inf"))


def test_item_update_rejects_price_beyond_decimal_bounds():
    with pytest.raises(ValidationError, match="less than or equal to 99999999.99"):
        ItemUpdate(price=1e308)


# ---------------------------------------------------------------------------
# Shared tag-list normalization for colors/tags/seasonal_tags (B3-20)
# ---------------------------------------------------------------------------


def test_item_create_normalizes_colors_tags_seasonal_tags():
    item = ItemCreate(
        name="Shirt",
        category="tops",
        colors=[" Navy ", "navy", "", "RED"],
        tags=["  work", "Work", "", " "],
        seasonal_tags=["Summer", "summer", "winter"],
    )
    assert item.colors == ["navy", "red"]
    assert item.tags == ["work"]
    assert item.seasonal_tags == ["summer", "winter"]


def test_item_update_normalizes_tag_lists_and_keeps_none():
    update = ItemUpdate(colors=[" Blue ", "blue"], seasonal_tags=["Spring"], tags=None)
    assert update.colors == ["blue"]
    assert update.seasonal_tags == ["spring"]
    assert update.tags is None


# ---------------------------------------------------------------------------
# ItemResponse leniency (B3-10)
# ---------------------------------------------------------------------------


def _response_kwargs(**overrides):
    kwargs = {
        "id": "11111111-1111-1111-1111-111111111111",
        "user_id": "22222222-2222-2222-2222-222222222222",
        "name": "Legacy shirt",
        "category": "tops",
        "condition": "clean",
        "created_at": "2026-01-01T00:00:00",
        "updated_at": "2026-01-01T00:00:00",
    }
    kwargs.update(overrides)
    return kwargs


def test_item_response_accepts_out_of_whitelist_category_and_condition():
    # The whitelist validators live on ItemCreate/ItemUpdate only: a legacy
    # row with a value outside the list must still serialize instead of 500.
    response = ItemResponse(**_response_kwargs(category="vintage", condition="stained"))
    assert response.category == "vintage"
    assert response.condition == "stained"


def test_item_response_normalizes_legacy_tag_arrays_without_raising():
    response = ItemResponse(
        **_response_kwargs(colors=[" Navy ", ""], tags=["Work", "work"], seasonal_tags=["Summer"])
    )
    assert response.colors == ["navy"]
    assert response.tags == ["work"]
    assert response.seasonal_tags == ["summer"]
