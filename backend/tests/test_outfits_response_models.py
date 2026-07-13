"""
Regression tests for wiring real Pydantic response_model= into get_outfit
and list_outfits (previously response_model=Dict[str, Any], no validation).

These simulate what FastAPI's response-model layer does (Model.model_validate
against the route's actual return value) since the existing test convention
calls route functions directly rather than through a TestClient. Covers the
specific risks found while wiring this in:
- OutfitResponse must NOT inherit OutfitCreate's "item_ids must be non-empty"
  validator, or any persisted outfit with zero items would 500 on fetch.
- OutfitDetailResponse's field was named `items_details`, not `items` - the
  actual field Flutter's outfit_model.dart parses - which would have
  silently dropped every outfit's item list had it been wired in unfixed.
"""
from unittest.mock import Mock

import pytest

from app.api.v1.outfits import get_outfit, list_outfits
from app.models.common import DataResponse
from app.models.outfit import OutfitCreate, OutfitListResponse, OutfitResponse

USER_ID = "11111111-1111-1111-1111-111111111111"
OUTFIT_ID = "22222222-2222-2222-2222-222222222222"


def _outfit_row(item_ids=None, images=None):
    return {
        "id": OUTFIT_ID,
        "user_id": USER_ID,
        "name": "Weekend Casual",
        "description": None,
        "item_ids": item_ids if item_ids is not None else [],
        "style": "casual",
        "season": None,
        "occasion": None,
        "tags": [],
        "is_favorite": False,
        "is_draft": False,
        "is_public": False,
        "worn_count": 0,
        "last_worn_at": None,
        "created_at": "2026-01-01T00:00:00",
        "updated_at": "2026-01-01T00:00:00",
        "outfit_images": images if images is not None else [],
    }


def _outfit_image_row():
    return {
        "id": "33333333-3333-3333-3333-333333333333",
        "outfit_id": OUTFIT_ID,
        "image_url": "https://cdn.example.com/img.jpg",
        "thumbnail_url": None,
        "storage_path": None,
        "pose": "front",
        "lighting": None,
        "body_profile_id": None,
        "generation_type": "ai",
        "is_primary": True,
        "width": None,
        "height": None,
        "generation_metadata": None,
        "created_at": "2026-01-01T00:00:00",
    }


def _make_db_for_get_outfit(outfit_row, item_rows=None):
    db = Mock()

    def table_side_effect(name):
        m = Mock()
        if name == "outfits":
            m.select.return_value.eq.return_value.eq.return_value.single.return_value.execute.return_value.data = outfit_row
        elif name == "items":
            m.select.return_value.in_.return_value.execute.return_value.data = item_rows or []
        return m

    db.table.side_effect = table_side_effect
    return db


@pytest.mark.asyncio
async def test_get_outfit_with_zero_items_validates_against_response_model():
    """The old OutfitBase validator would have raised on this - a
    legitimately empty-item outfit must still be returned, not 500."""
    db = _make_db_for_get_outfit(_outfit_row(item_ids=[]))

    result = await get_outfit(outfit_id=OUTFIT_ID, user_id=USER_ID, db=db)

    validated = DataResponse[OutfitResponse].model_validate(result)
    assert validated.data.item_ids == []
    assert validated.data.items == []


@pytest.mark.asyncio
async def test_get_outfit_with_items_and_images_validates_and_preserves_items():
    item_id = "44444444-4444-4444-4444-444444444444"
    db = _make_db_for_get_outfit(
        _outfit_row(item_ids=[item_id], images=[_outfit_image_row()]),
        item_rows=[{"id": item_id, "name": "Blue Shirt", "item_images": []}],
    )

    result = await get_outfit(outfit_id=OUTFIT_ID, user_id=USER_ID, db=db)

    validated = DataResponse[OutfitResponse].model_validate(result)
    assert len(validated.data.images) == 1
    assert validated.data.images[0].pose == "front"
    # This is the exact bug that would have shipped with the mismatched
    # `items_details` field name: the items list must survive validation
    # under the `items` key that Flutter actually reads.
    assert validated.data.items is not None
    assert len(validated.data.items) == 1
    assert validated.data.items[0]["name"] == "Blue Shirt"


@pytest.mark.asyncio
async def test_list_outfits_validates_against_response_model():
    db = Mock()

    def table_side_effect(name):
        m = Mock()
        if name == "outfits":
            outfits_result = Mock()
            outfits_result.data = [_outfit_row(item_ids=[])]
            m.select.return_value.eq.return_value.order.return_value.range.return_value.execute.return_value = outfits_result

            count_result = Mock()
            count_result.count = 1
            count_result.data = []  # getattr's default arg is evaluated eagerly
            m.select.return_value.eq.return_value.execute.return_value = count_result
        return m

    db.table.side_effect = table_side_effect

    result = await list_outfits(
        page=1,
        page_size=20,
        is_favorite=None,
        style=None,
        season=None,
        search=None,
        tags=None,
        user_id=USER_ID,
        db=db,
    )

    validated = DataResponse[OutfitListResponse].model_validate(result)
    assert validated.data.total == 1
    assert len(validated.data.outfits) == 1
    assert validated.data.outfits[0].items == []


def test_outfit_create_still_rejects_empty_item_ids():
    """Confirms moving the validator from OutfitBase to OutfitCreate didn't
    lose the input-side business rule."""
    with pytest.raises(ValueError, match="at least one item"):
        OutfitCreate(name="Test", item_ids=[])


def test_outfit_response_allows_empty_item_ids():
    """The same field, on the response model, must NOT raise."""
    response = OutfitResponse(
        id=OUTFIT_ID,
        user_id=USER_ID,
        name="Test",
        item_ids=[],
        created_at="2026-01-01T00:00:00",
        updated_at="2026-01-01T00:00:00",
    )
    assert response.item_ids == []
