"""Unit tests for recommendation item image normalization helpers.

Imports production helpers so tests fail if implementation drifts.
"""
from app.api.v1.recommendations import _prepare_item_for_response


def test_prepare_item_maps_item_images_to_images_and_image_url():
    raw = {
        "id": "item-1",
        "name": "Blue Tee",
        "category": "tops",
        "item_images": [
            {
                "id": "img-1",
                "image_url": "https://cdn.example/full.jpg",
                "thumbnail_url": "https://cdn.example/thumb.jpg",
                "is_primary": True,
            }
        ],
    }
    out = _prepare_item_for_response(raw)
    assert "images" in out
    assert len(out["images"]) == 1
    assert out["images"][0]["image_url"] == "https://cdn.example/full.jpg"
    assert out["image_url"] == "https://cdn.example/thumb.jpg"
    assert "item_images" not in out


def test_prepare_item_handles_missing_images():
    out = _prepare_item_for_response({"id": "item-2", "name": "No Photo", "category": "bottoms"})
    assert out["images"] == []
    assert "image_url" not in out


def test_prepare_item_prefers_existing_images_over_empty_item_images():
    raw = {
        "id": "item-3",
        "name": "Jacket",
        "category": "outerwear",
        "images": [
            {
                "id": "img-2",
                "image_url": "https://cdn.example/jacket.jpg",
                "is_primary": True,
            }
        ],
        "item_images": [],
    }
    # pop empty item_images leaves images list from existing field
    out = _prepare_item_for_response(raw)
    assert len(out["images"]) == 1
    assert out["image_url"] == "https://cdn.example/jacket.jpg"
