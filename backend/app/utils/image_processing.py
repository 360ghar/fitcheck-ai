"""Best-effort image downscaling for the vision pipeline.

Full-resolution phone photos blow up the payload sent inline to the vision
model (token cost + latency). Shrinking the longest edge to ~1568px and
re-encoding as JPEG keeps far more detail than the model tiles on while
cutting bytes ~10x.
"""

import base64
import io

from PIL import Image, ImageOps

# Matches the mobile client's existing 1920/q85 upload; above vision tiling
# thresholds. One knob if extraction accuracy ever regresses.
DEFAULT_MAX_EDGE = 1568
DEFAULT_QUALITY = 85


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


if __name__ == "__main__":
    # Self-check: a big PNG shrinks; a tiny JPEG is left alone.
    big = Image.new("RGBA", (3000, 2000), (255, 0, 0, 128))
    buf = io.BytesIO()
    big.save(buf, format="PNG")
    big_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    out = downscale_base64_image(big_b64)
    with Image.open(io.BytesIO(base64.b64decode(out))) as check:
        assert check.format == "JPEG", check.format
        assert max(check.size) <= DEFAULT_MAX_EDGE, check.size
    assert len(out) < len(big_b64), "expected a smaller payload"

    small = Image.new("RGB", (10, 10), (0, 0, 255))
    buf = io.BytesIO()
    small.save(buf, format="JPEG", quality=85)
    small_b64 = base64.b64encode(buf.getvalue()).decode("utf-8")
    assert downscale_base64_image(small_b64) == small_b64, "tiny image unchanged"

    print("image_processing self-check OK")
