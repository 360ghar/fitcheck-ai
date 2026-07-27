"""Best-effort image downscaling and cropping for the vision/generation pipeline.

Full-resolution phone photos blow up the payload sent inline to the vision
model (token cost + latency). Shrinking the longest edge to ~1568px and
re-encoding as JPEG keeps far more detail than the model tiles on while
cutting bytes ~10x.
"""

import base64
import io
from typing import Any, Dict, Optional, Tuple

from PIL import Image, ImageOps

# Matches the mobile client's existing 1920/q85 upload; above vision tiling
# thresholds. One knob if extraction accuracy ever regresses.
DEFAULT_MAX_EDGE = 1568
DEFAULT_QUALITY = 85

# Padding added around a bounding box before cropping, as a fraction of the
# box's own width/height. Bounding boxes from the vision model are known to
# drift a few percentage points off the true garment edges - generous padding
# absorbs that without clipping the item.
DEFAULT_CROP_PADDING_RATIO = 0.20
# Floor padding in percentage points of the full image, applied even to tiny
# boxes (a pure ratio of a 2%-wide accessory box would pad almost nothing).
DEFAULT_CROP_PADDING_FLOOR = 4.0


def downscale_base64_image(
    image_base64: str,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> str:
    """Return a downsized JPEG (base64) for a base64 image.

    Best-effort: on ANY failure (not an image, unsupported format, decode
    error) the input is returned unchanged so the vision call still works.
    Never upscales - images already <= max_edge pass through re-encoded only
    if that actually shrinks them.
    """
    try:
        raw = base64.b64decode(image_base64)
        with Image.open(io.BytesIO(raw)) as img:
            src_format = img.format
            src_size = img.size
            img = ImageOps.exif_transpose(img)  # honour phone orientation

            # Flatten transparency onto white so JPEG has no alpha channel.
            if img.mode in ("RGBA", "LA", "P"):
                background = Image.new("RGB", img.size, (255, 255, 255))
                rgba = img.convert("RGBA")
                background.paste(rgba, mask=rgba.getchannel("A"))
                img = background
            elif img.mode != "RGB":
                img = img.convert("RGB")

            # thumbnail() is a no-op when already smaller (never upscales).
            img.thumbnail((max_edge, max_edge))

            # Already within bounds and already a JPEG - nothing to gain, and
            # skipping the re-encode keeps CPU off images that are fine as-is.
            if img.size == src_size and src_format == "JPEG":
                return image_base64

            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=quality, optimize=True)
            result = base64.b64encode(buf.getvalue()).decode("utf-8")

        # ponytail: if re-encoding somehow made it bigger, keep the original.
        return result if len(result) < len(image_base64) else image_base64
    except Exception:
        # ponytail: best-effort - vision call works with the raw bytes.
        return image_base64


def crop_base64_image_to_box(
    image_base64: str,
    box: Dict[str, Any],
    padding_ratio: float = DEFAULT_CROP_PADDING_RATIO,
    padding_floor: float = DEFAULT_CROP_PADDING_FLOOR,
) -> str:
    """Crop a base64 image to a percentage bounding box, with padding.

    `box` is `{x, y, width, height}` as 0-100 percentages of the full image,
    top-left origin (the shape produced by `_normalize_bounding_box` in
    item_extraction_agent.py). Padding is added around the box (a fraction of
    the box's own size, floored at `padding_floor` percentage points) to
    absorb ordinary bbox imprecision without clipping the garment.

    Whether cropping is even a good idea (confidence, area-ratio gating) is
    the caller's decision - this function only does the pixel math. It is
    best-effort like `downscale_base64_image`: on ANY failure (bad image,
    degenerate box, decode error) the input is returned unchanged rather than
    raising, so a caller can always safely pass its reference image through
    this function.

    Applies `ImageOps.exif_transpose` before computing crop coordinates,
    since the vision model's bounding-box percentages were computed against
    an EXIF-corrected image (see `downscale_base64_image` above) while a
    freshly re-downloaded source photo may still carry raw rotation
    metadata - skipping this would misalign the crop on rotated phone photos.
    """
    try:
        x = float(box["x"])
        y = float(box["y"])
        w = float(box["width"])
        h = float(box["height"])
        if w <= 0 or h <= 0:
            return image_base64

        raw = base64.b64decode(image_base64)
        with Image.open(io.BytesIO(raw)) as img:
            img = ImageOps.exif_transpose(img)
            if img.mode != "RGB":
                img = img.convert("RGB")
            width_px, height_px = img.size

            pad_x = max(w * padding_ratio, padding_floor)
            pad_y = max(h * padding_ratio, padding_floor)

            x0 = max(0.0, x - pad_x)
            y0 = max(0.0, y - pad_y)
            x1 = min(100.0, x + w + pad_x)
            y1 = min(100.0, y + h + pad_y)

            left = int(x0 / 100.0 * width_px)
            top = int(y0 / 100.0 * height_px)
            right = int(x1 / 100.0 * width_px)
            bottom = int(y1 / 100.0 * height_px)

            if right <= left or bottom <= top:
                return image_base64

            cropped = img.crop((left, top, right, bottom))
            buf = io.BytesIO()
            cropped.save(buf, format="JPEG", quality=90)
            return base64.b64encode(buf.getvalue()).decode("utf-8")
    except Exception:
        # ponytail: best-effort - caller's generation call works with the
        # uncropped reference image.
        return image_base64


# Trust thresholds for using a bounding box to crop the reference image for
# single-item product generation. Conservative on purpose: a wrong-region
# crop is worse than no crop at all (the model then has zero chance of
# finding the right item), so bboxes are only trusted when reasonably
# confident.
MIN_BBOX_CONFIDENCE = 0.6
# Set high on purpose: a source photo can legitimately BE a single large
# garment shot close-up (a dress/jumpsuit filling most of the frame even with
# other small items detected elsewhere, e.g. shoes in a corner). Only
# near-total-frame boxes, which really do indicate the model gave up and
# boxed the whole photo instead of localizing the item, are distrusted.
MAX_BBOX_AREA_RATIO = 0.90


def resolve_product_reference_image(
    reference_image_base64: Optional[str],
    bounding_box: Optional[Dict[str, Any]],
    confidence: float,
    sibling_count: int,
) -> Tuple[Optional[str], str]:
    """Decide what reference image (if any) to send for single-item generation.

    Never sends the full, uncropped, multi-item source photo when other
    items share the same photo - that's what causes the generator to bleed
    in other garments or pass the photo through unchanged (it asks the model
    to visually search a busy photo and self-select the right region from
    prose alone). Instead:
    - A photo with only one detected item has nothing else in frame to
      confuse the model, so the full photo is safe as-is.
    - A photo with multiple items and a trustworthy bbox gets cropped (via
      `crop_base64_image_to_box`, with generous padding to absorb bbox
      imprecision) so the model only sees the target garment.
    - A photo with multiple items and an untrustworthy/missing bbox drops
      the reference image entirely, falling back to pure text-to-image from
      the dense item description - the same mode the web app's "Regenerate"
      button already uses and reliably isolates a single item with.

    Returns (reference_image_to_use, strategy) where strategy is one of
    "none" (no source photo was ever available), "full", "crop", or
    "text_only" - callers should log this for tuning the thresholds above.
    """
    if reference_image_base64 is None:
        return None, "none"

    if sibling_count <= 1:
        return reference_image_base64, "full"

    if bounding_box:
        area_ratio = (
            float(bounding_box.get("width", 0.0)) * float(bounding_box.get("height", 0.0))
        ) / 10000.0
        if confidence >= MIN_BBOX_CONFIDENCE and area_ratio <= MAX_BBOX_AREA_RATIO:
            return crop_base64_image_to_box(reference_image_base64, bounding_box), "crop"

    return None, "text_only"
