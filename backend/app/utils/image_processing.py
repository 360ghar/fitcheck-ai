"""Best-effort image downscaling and cropping for the vision/generation pipeline.

Full-resolution phone photos blow up the payload sent inline to the vision
model (token cost + latency). Shrinking the longest edge to ~1568px and
re-encoding as JPEG keeps far more detail than the model tiles on while
cutting bytes ~10x.

CONTRACT, and it is deliberately the INVERSE of
`app/utils/background_removal.py`: everything in this module produces opaque
JPEG bytes destined for an AI MODEL, never for a user's screen. Alpha is
flattened onto white on the way in (see `downscale_base64_image`). Do not
"unify" the two modules and do not teach these functions to preserve
transparency - see the long note on `downscale_base64_image` for why.

Also home to the shared image format/MIME sniffers (`sniff_image_mime`,
`to_data_url`), which are pure format detection and belong to neither
direction of the pipeline.
"""

import base64
import io
import os
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


# =============================================================================
# FORMAT / MIME DETECTION
# =============================================================================
# Two independent bugs made this shared: (1) every storage3 `upload()` call
# without explicit `file_options` inherits DEFAULT_FILE_OPTIONS'
# `content-type: text/plain;charset=UTF-8`, so images were served as text;
# (2) every data URL in the codebase hardcoded `data:image/jpeg;base64,` even
# for PNG/WebP bytes, and GeminiProvider._decode_image_part parses that header
# straight into `Part.from_bytes(mime_type=...)`, so the lie reached the model.
# Filenames are NOT trusted: the batch client names its upload
# `${tempId}.png` regardless of what the bytes actually are.

FALLBACK_MIME = "application/octet-stream"

# Magic-byte prefixes, so a MIME can be resolved from ~32 bytes with no
# decode and no Pillow call. Order matters only in that ISO-BMFF (`ftyp`)
# checks look at bytes 4-12 rather than 0.
MIME_BY_PIL_FORMAT = {
    "JPEG": "image/jpeg",
    "PNG": "image/png",
    "WEBP": "image/webp",
    "GIF": "image/gif",
    "BMP": "image/bmp",
    "TIFF": "image/tiff",
    "AVIF": "image/avif",
    "HEIF": "image/heif",
}

MIME_BY_EXTENSION = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".webp": "image/webp",
    ".gif": "image/gif",
    ".bmp": "image/bmp",
    ".tif": "image/tiff",
    ".tiff": "image/tiff",
    ".avif": "image/avif",
    ".heic": "image/heif",
    ".heif": "image/heif",
}

EXTENSION_BY_MIME = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
    "image/gif": ".gif",
    "image/bmp": ".bmp",
    "image/tiff": ".tiff",
    "image/avif": ".avif",
    "image/heif": ".heic",
}


def sniff_image_mime_from_magic(head: bytes) -> Optional[str]:
    """MIME from a file's leading bytes, or None if unrecognised.

    Needs only the first ~32 bytes, does no decoding, and never raises.
    """
    if not head:
        return None
    if head.startswith(b"\xff\xd8\xff"):
        return "image/jpeg"
    if head.startswith(b"\x89PNG\r\n\x1a\n"):
        return "image/png"
    if head[:4] == b"RIFF" and head[8:12] == b"WEBP":
        return "image/webp"
    if head[:6] in (b"GIF87a", b"GIF89a"):
        return "image/gif"
    if head[:2] == b"BM":
        return "image/bmp"
    if head[:4] in (b"II*\x00", b"MM\x00*"):
        return "image/tiff"
    brand = head[4:12]
    if brand == b"ftypavif":
        return "image/avif"
    if brand in (b"ftypheic", b"ftypheix", b"ftypmif1", b"ftypmsf1"):
        return "image/heif"
    return None


def sniff_image_mime(file_data: bytes, filename: Optional[str] = None) -> str:
    """Best-effort content type for raw image bytes. Never raises.

    Resolution order: magic bytes -> Pillow's decoded format -> the filename's
    extension -> `application/octet-stream`. The filename is the LAST resort on
    purpose; callers routinely supply a made-up name (`${tempId}.png`).
    """
    magic = sniff_image_mime_from_magic(file_data[:32])
    if magic:
        return magic

    try:
        with Image.open(io.BytesIO(file_data)) as img:
            fmt = (img.format or "").upper()
        if fmt:
            return MIME_BY_PIL_FORMAT.get(fmt) or f"image/{fmt.lower()}"
    except Exception:
        pass

    if filename:
        # `os.path.splitext(".png")` yields ('.png', '') - a bare extension is a
        # hidden filename to posixpath - so fall back to the whole string, since
        # callers legitimately pass just ".png".
        ext = os.path.splitext(filename)[1].lower() or filename.strip().lower()
        mime = MIME_BY_EXTENSION.get(ext)
        if mime:
            return mime

    return FALLBACK_MIME


def to_data_url(image_base64: str) -> str:
    """Wrap bare base64 image bytes in a data URL carrying the REAL mime type.

    Pass-through when the input is already a data URL. Only the first 96 base64
    characters are decoded (72 bytes - plenty for any magic signature), so this
    is cheap enough to call per reference image. Falls back to `image/jpeg`
    when the bytes are unrecognisable: that is the historical value every
    caller hardcoded, so an unknown blob behaves exactly as it did before
    rather than newly breaking a provider that dislikes octet-stream.
    """
    if image_base64.startswith("data:"):
        return image_base64
    mime = None
    try:
        head = base64.b64decode(image_base64[:96], validate=False)
        mime = sniff_image_mime_from_magic(head)
    except Exception:
        mime = None
    return f"data:{mime or 'image/jpeg'};base64,{image_base64}"


def downscale_base64_image(
    image_base64: str,
    max_edge: int = DEFAULT_MAX_EDGE,
    quality: int = DEFAULT_QUALITY,
) -> str:
    """Return a downsized, OPAQUE JPEG (base64) for a base64 image.

    Best-effort: on ANY failure (not an image, unsupported format, decode
    error) the input is returned unchanged so the vision call still works.
    Never upscales - images already <= max_edge pass through re-encoded only
    if that actually shrinks them.

    THE ALPHA FLATTEN BELOW IS LOAD-BEARING - DO NOT "FIX" IT.
    This function's output goes to an AI model, never to a user's screen:
      - JPEG cannot carry an alpha channel at all, and the providers we use
        cannot consume one meaningfully (`_generate_image_via_images_api` sends
        a fixed payload with no output_format; GeminiProvider discards it).
      - Since `app/utils/background_removal.py` landed, item images in storage
        are transparent WebP cutouts. `item_reference_service` downloads those
        as garment references and they arrive here - flattening them onto white
        produces exactly the "clean isolated garment on white" that
        GARMENT_REFERENCE_LOCK and PRODUCT_REFERENCE_LOCK ask for. That is a
        feature, not a leak.
    `background_removal.py` is the inverse operation and the only place alpha
    is ever created. Keep the two apart.
    """
    try:
        raw = base64.b64decode(image_base64)
        with Image.open(io.BytesIO(raw)) as img:
            src_format = img.format
            src_size = img.size
            img = ImageOps.exif_transpose(img)  # honour phone orientation

            # Flatten transparency onto white so JPEG has no alpha channel.
            had_alpha = img.mode in ("RGBA", "LA", "PA") or "transparency" in img.info
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

        # ponytail: if re-encoding somehow made it bigger, keep the original -
        # UNLESS the source carried alpha. A lossy WebP cutout from
        # background_removal.py is routinely SMALLER than its flattened JPEG
        # (measured 10KB vs 27KB), so without this exemption the size check
        # would hand the model back the transparent original and quietly undo
        # the flatten this function exists to guarantee.
        if had_alpha:
            return result
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
