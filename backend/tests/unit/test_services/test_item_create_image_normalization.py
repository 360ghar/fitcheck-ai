"""Tests for items._normalize_create_image_row.

Pins the create-image normalization contract:
- an explicit unowned ``storage_path`` -> 400 (ValidationError);
- an unowned key DERIVED from ``image_url`` -> 400 (with key_from_path
  returning None for true external URLs, a derived value reliably means the
  URL embeds one of our key shapes, so it must be owned like an explicit one);
- an owned preview key (derived from the URL) -> promoted to a canonical item
  object via promote_temp_image_to_item;
- a true external URL (e.g. an OAuth picture) -> legacy passthrough unchanged
  (no key to promote or re-mint from).
"""

from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.api.v1 import items as items_module
from app.core.exceptions import ValidationError
from app.models.item import ItemImageBase
from app.services.storage_service import StorageService

USER_ID = "11111111-1111-1111-1111-111111111111"
FOREIGN = "22222222-2222-2222-2222-222222222222"
HEX = "0123456789abcdef0123456789abcdef"
OWNED_CANONICAL = f"users/{USER_ID}/items/{HEX}.png"
FOREIGN_CANONICAL = f"users/{FOREIGN}/items/{HEX}.png"
OWNED_PREVIEW = f"users/{USER_ID}/tmp/batch/{HEX}.webp"
OAUTH_URL = "https://lh3.googleusercontent.com/a/ACo8DcX/photo"


@pytest.mark.asyncio
async def test_explicit_unowned_storage_path_raises():
    img = ItemImageBase(image_url="", storage_path=FOREIGN_CANONICAL)

    with pytest.raises(ValidationError, match="caller's own objects"):
        await items_module._normalize_create_image_row(img, Mock(), USER_ID)


@pytest.mark.asyncio
async def test_derived_unowned_url_raises():
    """An unowned key derived from image_url must be rejected exactly like an
    explicit unowned storage_path (a cross-user presigned URL must never be
    persisted as a durable reference)."""
    img = ItemImageBase(
        image_url=f"https://cdn.example/{FOREIGN_CANONICAL}",
    )

    with pytest.raises(ValidationError, match="caller's own objects"):
        await items_module._normalize_create_image_row(img, Mock(), USER_ID)


@pytest.mark.asyncio
async def test_owned_preview_url_is_derived_and_promoted():
    img = ItemImageBase(
        image_url=f"https://cdn.fitcheck.ai/{OWNED_PREVIEW}",
    )
    promoted = {
        "image_url": "https://cdn.example/promoted.png",
        "thumbnail_url": "https://cdn.example/promoted_thumb.png",
        "storage_path": f"{USER_ID}/items/{HEX}.webp",
    }
    with patch.object(
        StorageService,
        "promote_temp_image_to_item",
        new=AsyncMock(return_value=promoted),
    ) as promote:
        row = await items_module._normalize_create_image_row(img, Mock(), USER_ID)

    promote.assert_awaited_once()
    kwargs = promote.await_args.kwargs
    assert kwargs["user_id"] == USER_ID
    assert kwargs["temp_storage_path"] == OWNED_PREVIEW
    assert kwargs["filename_hint"] == "generated.png"
    assert row == promoted


@pytest.mark.asyncio
async def test_external_url_passes_through_unchanged():
    img = ItemImageBase(image_url=OAUTH_URL, thumbnail_url=OAUTH_URL)

    row = await items_module._normalize_create_image_row(img, Mock(), USER_ID)

    assert row == {
        "image_url": OAUTH_URL,
        "thumbnail_url": OAUTH_URL,
        "storage_path": None,
    }
