"""
Tests for app.utils.image_processing: crop_base64_image_to_box and
resolve_product_reference_image, the fix for single-item product images
bleeding in other garments or passing the source photo through unchanged.
"""

import base64
import io

from PIL import Image

from app.utils.image_processing import (
    MAX_BBOX_AREA_RATIO,
    MIN_BBOX_CONFIDENCE,
    crop_base64_image_to_box,
    resolve_product_reference_image,
)


def _make_image_b64(size=(1000, 800), color=(255, 0, 0), fmt="JPEG") -> str:
    img = Image.new("RGB", size, color)
    buf = io.BytesIO()
    img.save(buf, format=fmt, quality=90)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


# =============================================================================
# crop_base64_image_to_box
# =============================================================================


def test_crop_reduces_image_to_padded_box_region():
    original = _make_image_b64(size=(1000, 800))
    # Box roughly in the middle third of the frame.
    box = {"x": 30.0, "y": 30.0, "width": 20.0, "height": 20.0}

    cropped_b64 = crop_base64_image_to_box(original, box)

    with Image.open(io.BytesIO(base64.b64decode(cropped_b64))) as cropped:
        cropped_w, cropped_h = cropped.size

    # Cropped result is meaningfully smaller than the source (box + padding
    # is well under the full 1000x800 frame) but not degenerate.
    assert 0 < cropped_w < 1000
    assert 0 < cropped_h < 800


def test_crop_padding_is_generous_enough_to_absorb_bbox_drift():
    original = _make_image_b64(size=(1000, 1000))
    tight_box = {"x": 40.0, "y": 40.0, "width": 20.0, "height": 20.0}

    cropped_b64 = crop_base64_image_to_box(original, tight_box, padding_ratio=0.20)
    with Image.open(io.BytesIO(base64.b64decode(cropped_b64))) as cropped:
        cropped_w, _ = cropped.size

    # 20% width + a percentage-point floor on each side should grow the crop
    # noticeably past the raw 20%-of-frame box (200px on a 1000px image).
    assert cropped_w > 200


def test_crop_clamps_to_image_bounds_near_edges():
    original = _make_image_b64(size=(500, 500))
    # Box touching the top-left corner - padding must not go negative/out of range.
    edge_box = {"x": 0.0, "y": 0.0, "width": 10.0, "height": 10.0}

    cropped_b64 = crop_base64_image_to_box(original, edge_box)

    with Image.open(io.BytesIO(base64.b64decode(cropped_b64))) as cropped:
        assert cropped.size[0] > 0
        assert cropped.size[1] > 0


def test_crop_falls_back_to_original_on_degenerate_box():
    original = _make_image_b64()
    bad_box = {"x": 0.0, "y": 0.0, "width": 0.0, "height": 0.0}

    assert crop_base64_image_to_box(original, bad_box) == original


def test_crop_falls_back_to_original_on_invalid_image_bytes():
    not_an_image = base64.b64encode(b"definitely not image bytes").decode("utf-8")
    box = {"x": 10.0, "y": 10.0, "width": 20.0, "height": 20.0}

    assert crop_base64_image_to_box(not_an_image, box) == not_an_image


def test_crop_handles_exif_rotated_image():
    # A rotated image with EXIF orientation metadata should still crop without
    # raising - exif_transpose is applied before the crop math.
    img = Image.new("RGB", (600, 400), (0, 255, 0))
    buf = io.BytesIO()
    exif = img.getexif()
    exif[0x0112] = 6  # Orientation: rotate 270 (common phone-photo tag)
    img.save(buf, format="JPEG", exif=exif)
    rotated_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    box = {"x": 10.0, "y": 10.0, "width": 30.0, "height": 30.0}
    result = crop_base64_image_to_box(rotated_b64, box)

    with Image.open(io.BytesIO(base64.b64decode(result))) as cropped:
        assert cropped.size[0] > 0
        assert cropped.size[1] > 0


# =============================================================================
# resolve_product_reference_image
# =============================================================================


def test_no_source_photo_returns_none_strategy_none():
    result, strategy = resolve_product_reference_image(
        reference_image_base64=None,
        bounding_box={"x": 1, "y": 1, "width": 10, "height": 10},
        confidence=0.9,
        sibling_count=3,
    )
    assert result is None
    assert strategy == "none"


def test_single_item_photo_keeps_full_reference_regardless_of_bbox():
    photo = _make_image_b64()
    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=None,
        confidence=0.0,
        sibling_count=1,
    )
    assert result == photo
    assert strategy == "full"


def test_multi_item_photo_with_trustworthy_bbox_crops():
    photo = _make_image_b64(size=(1000, 1000))
    box = {"x": 10.0, "y": 10.0, "width": 20.0, "height": 20.0}

    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=box,
        confidence=MIN_BBOX_CONFIDENCE,
        sibling_count=2,
    )

    assert strategy == "crop"
    assert result != photo  # actually cropped, not the raw photo passed through
    with Image.open(io.BytesIO(base64.b64decode(result))) as cropped:
        assert cropped.size[0] < 1000


def test_multi_item_photo_with_low_confidence_bbox_goes_text_only():
    photo = _make_image_b64()
    box = {"x": 10.0, "y": 10.0, "width": 20.0, "height": 20.0}

    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=box,
        confidence=MIN_BBOX_CONFIDENCE - 0.01,
        sibling_count=2,
    )

    assert result is None
    assert strategy == "text_only"


def test_multi_item_photo_with_missing_bbox_goes_text_only():
    photo = _make_image_b64()

    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=None,
        confidence=0.9,
        sibling_count=4,
    )

    assert result is None
    assert strategy == "text_only"


def test_multi_item_photo_with_near_full_frame_bbox_goes_text_only():
    photo = _make_image_b64()
    # ~95% of the frame area - above MAX_BBOX_AREA_RATIO, treated as the model
    # having given up rather than a legitimately large garment.
    huge_box = {"x": 1.0, "y": 1.0, "width": 98.0, "height": 98.0}
    assert (98.0 * 98.0) / 10000.0 > MAX_BBOX_AREA_RATIO

    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=huge_box,
        confidence=0.99,
        sibling_count=2,
    )

    assert result is None
    assert strategy == "text_only"


def test_multi_item_photo_with_legitimately_large_item_still_crops():
    photo = _make_image_b64()
    # A dress/jumpsuit filling most of the frame, but under the 90% cutoff -
    # should still be trusted and cropped, not punished for being large.
    large_but_valid_box = {"x": 5.0, "y": 5.0, "width": 85.0, "height": 85.0}
    assert (85.0 * 85.0) / 10000.0 <= MAX_BBOX_AREA_RATIO

    result, strategy = resolve_product_reference_image(
        reference_image_base64=photo,
        bounding_box=large_but_valid_box,
        confidence=0.9,
        sibling_count=2,
    )

    assert strategy == "crop"
    assert result is not None
