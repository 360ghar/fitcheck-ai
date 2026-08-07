"""Residual branch coverage for app.models.item.

The sibling test_item_occasion_tags.py covers tag normalization through the
models; this file covers the remaining validators: tag-list input shapes
(None/str/scalar), and the category/condition/price validation branches on
ItemCreate and ItemUpdate.
"""

import pytest
from pydantic import ValidationError

from app.models.item import ItemCreate, ItemUpdate, normalize_tag_list


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
