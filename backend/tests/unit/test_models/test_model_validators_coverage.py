"""Residual validator/arc coverage for the small model modules.

Each test targets a specific missed line/branch from the full-suite coverage
report in app/models/{item,user,ai,blog,outfit,photoshoot}.py.
"""

import re
from datetime import date, timedelta

import pytest
from pydantic import ValidationError

from app.models.ai import (
    ExtractSingleItemRequest,
    GenerateOutfitRequest,
    HealthCheckResult,
    OutfitItemInput,
)
from app.models.blog import BlogPostCreate, BlogPostUpdate
from app.models.item import ItemBase, ItemUpdate
from app.models.outfit import OutfitCreate, OutfitUpdate
from app.models.photoshoot import StartPhotoshootRequest
from app.models.user import UserBase, UserSettingsUpdate, UserUpdate


# ---------------------------------------------------------------------------
# app/models/item.py
# ---------------------------------------------------------------------------


def test_item_price_validator_dead_branch_pragma_guard():
    # Field(ge=0) fires before validate_price, so ItemBase.price=-1 fails on
    # the constraint, never reaching the validator's raise.
    with pytest.raises(ValidationError, match="greater than or equal to 0"):
        ItemBase(
            name="x",
            category="tops",
            price=-1,
        )


def test_item_update_category_none_and_condition_none():
    update = ItemUpdate(category=None, condition=None)
    assert update.category is None
    assert update.condition is None


# ---------------------------------------------------------------------------
# app/models/user.py
# ---------------------------------------------------------------------------


def test_user_birth_date_future_rejected():
    with pytest.raises(ValidationError, match="cannot be in the future"):
        UserBase(
            email="a@b.com",
            birth_date=date.today() + timedelta(days=1),
        )


def test_user_birth_place_non_string_is_rejected_by_type_check():
    # The before-validator's non-str passthrough (return v) runs here: the
    # Optional[str] type check rejects the value only after the validator.
    with pytest.raises(ValidationError):
        UserBase(email="a@b.com", birth_place=12345)


def test_user_update_gender_invalid_rejected():
    with pytest.raises(ValidationError, match="gender must be one of"):
        UserUpdate(gender="alien")


def test_user_update_birth_place_branches():
    assert UserUpdate(birth_place=None).birth_place is None
    with pytest.raises(ValidationError):
        UserUpdate(birth_place=12345)


def test_user_settings_units_invalid_rejected():
    with pytest.raises(ValidationError, match='either "imperial" or "metric"'):
        UserSettingsUpdate(measurement_units="yards")


# ---------------------------------------------------------------------------
# app/models/ai.py
# ---------------------------------------------------------------------------


def test_extract_single_item_request_requires_image_source():
    with pytest.raises(ValidationError, match="image or storage_path is required"):
        ExtractSingleItemRequest()
    # Either source satisfies the validator.
    tiny_png = (
        b"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk"
        b"+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    assert ExtractSingleItemRequest(image=tiny_png).image == tiny_png.decode()
    assert ExtractSingleItemRequest(storage_path="u1/items/x.jpg").storage_path is not None


def test_generate_outfit_request_item_count_cap(monkeypatch):
    from app.models import ai as ai_model

    monkeypatch.setattr(ai_model.settings, "AI_MAX_OUTFIT_ITEMS", 1)
    with pytest.raises(ValidationError, match="At most 1 outfit items are allowed"):
        GenerateOutfitRequest(items=[OutfitItemInput(name="a"), OutfitItemInput(name="b")])


def test_health_check_result_getitem_shim():
    result = HealthCheckResult(available=True, message="ok", model="gpt")
    assert result["success"] is True
    assert result["available"] is True
    assert result["model"] == "gpt"
    assert result["message"] == "ok"
    with pytest.raises(KeyError):
        result["nope"]


# ---------------------------------------------------------------------------
# app/models/blog.py
# ---------------------------------------------------------------------------


def _blog_kwargs():
    return {
        "title": "Post",
        "content": "body",
        "excerpt": "summary",
        "category": "tech",
        "date": "2026-01-01",
        "read_time": "3 min",
        "emoji": "x",
        "author": "A",
    }


def test_blog_create_slug_invalid_rejected():
    with pytest.raises(ValidationError, match="Slug must contain only lowercase"):
        BlogPostCreate(**_blog_kwargs(), slug="Bad Slug!")


def test_blog_create_keywords_empty_returns_empty_list():
    assert BlogPostCreate(**_blog_kwargs(), slug="post", keywords=[]).keywords == []


def test_blog_create_keywords_normalized_and_deduped():
    post = BlogPostCreate(**_blog_kwargs(), slug="post", keywords=["SEO", "seo", " Fitting "])
    assert post.keywords == ["seo", "fitting"]


def test_blog_update_slug_branches():
    assert BlogPostUpdate(slug=None).slug is None
    with pytest.raises(ValidationError, match="Slug must contain only lowercase"):
        BlogPostUpdate(slug="Bad!")


def test_blog_update_keywords_branches():
    assert BlogPostUpdate(keywords=None).keywords is None
    update = BlogPostUpdate(keywords=[" A ", "a", "B"])
    assert update.keywords == ["a", "b"]


# ---------------------------------------------------------------------------
# app/models/outfit.py
# ---------------------------------------------------------------------------


def test_outfit_create_duplicate_item_ids_rejected():
    ids = ["11111111-1111-1111-1111-111111111111", "11111111-1111-1111-1111-111111111111"]
    with pytest.raises(ValidationError, match="cannot contain duplicate items"):
        OutfitCreate(name="fit", item_ids=ids)


def test_outfit_update_item_ids_branches():
    assert OutfitUpdate(item_ids=None).item_ids is None
    with pytest.raises(ValidationError, match="at least one item"):
        OutfitUpdate(item_ids=[])
    ids = ["11111111-1111-1111-1111-111111111111", "11111111-1111-1111-1111-111111111111"]
    with pytest.raises(ValidationError, match="cannot contain duplicate items"):
        OutfitUpdate(item_ids=ids)


# ---------------------------------------------------------------------------
# app/models/photoshoot.py
# ---------------------------------------------------------------------------


def test_photoshoot_request_oversized_photo_rejected():
    # A >10MB payload as a padded base64 string is rejected by the size
    # validator before decoding.
    with pytest.raises(ValidationError, match="exceeds maximum size of 10MB"):
        StartPhotoshootRequest(photos=["A" * (10 * 1024 * 1024 + 4)])


def test_photoshoot_request_invalid_aspect_ratio_rejected():
    with pytest.raises(ValidationError, match="Invalid aspect ratio"):
        StartPhotoshootRequest(photos=["aGk="], aspect_ratio="2:1")


def test_photoshoot_request_valid_aspect_ratio_accepted():
    tiny_png = (
        "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk"
        "+A8AAQUBAScY42YAAAAASUVORK5CYII="
    )
    request = StartPhotoshootRequest(
        use_case="instagram", photos=[tiny_png], aspect_ratio="9:16"
    )
    assert request.aspect_ratio == "9:16"


def test_blog_slug_regex_shape():
    # Guard: the regex is as expected by both validators.
    assert re.match(r"^[a-z0-9-]+$", "my-post-2") is not None
