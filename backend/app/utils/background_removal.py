"""Cut a flat white studio backdrop out of a generated image, producing alpha.

CONTRACT, and it is deliberately the INVERSE of
`app/utils/image_processing.py`: this module CREATES transparency, on bytes
that go straight to a user's screen (an item tile, a flat-lay look). Nothing
here ever feeds an AI model, and nothing here may be used to prepare a
reference image. The two modules are kept in separate files precisely because
co-locating "flatten alpha onto white, encode JPEG" with "cut alpha out of
white, encode WebP" invites someone to matte a reference image or flatten a
matte. If you are here to make a reference image smaller, you want
`downscale_base64_image` instead.

WHY A PILLOW THRESHOLD MATTE AND NOT A SEGMENTER
No provider we use can return alpha, so the backdrop has to be removed after
generation. `rembg`/`onnxruntime` and hosted cutout APIs were rejected (weight,
cost, a new failure mode). A threshold matte is only viable because we CONTROL
the backdrop: the generation prompts ask for a pure flat #FFFFFF field with no
gradient, vignette, floor plane or cast shadow (`_MATTE_READY_BACKGROUND` in
`app/agents/image_generation_agent.py`). It is therefore only wired to the
flat-lay and product-shot paths, never to a person shot - a hard threshold
cannot cut hair, and the guards below would NOT catch that failure (a full-body
figure lands around 0.70-0.80 transparent, comfortably under
MAX_TRANSPARENT_FRACTION), so bad hair would ship.

THE FAILURE MODE IS "SOME WHITE ITEMS KEEP THEIR WHITE BACKGROUND", NEVER
"SOME WHITE ITEMS ARE DESTROYED". Three guards enforce that, and on any guard
failure the ORIGINAL bytes are returned untouched.

PERFORMANCE
A full-resolution `ImageDraw.floodfill` is a Python loop holding the GIL and
measures ~562ms on a 1024x1024 image; at AI_GENERATION_CONCURRENCY=30 that is
~17s of serialized CPU stalling the batch SSE loop. So the near-white test runs
at full resolution in C (`ImageChops` + `.point()` LUTs) and the flood fill -
needed only for CONNECTIVITY - runs on a 256px copy whose result is upscaled
and re-intersected with the full-res mask.

Measured on a 1024x1024 generated product shot (Apple M-series, Pillow 11,
mean of 10): decode 0.9ms + near-white 3.8ms + coarse flood 35ms + guards 1.9ms
+ edge/feather 40ms + WebP encode 36ms = ~110ms total. Everything here is
GIL-held C work, so callers MUST run it off the event loop
(`asyncio.to_thread`); the two MaxFilter passes and the WebP encode are the
knobs if this ever needs to be cheaper.
"""

import base64
import io
from typing import NamedTuple, Optional

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageOps

# Imported for format detection ONLY. Do not reach for anything else in that
# module from here - see this file's header.
from app.utils.image_processing import EXTENSION_BY_MIME, sniff_image_mime

# =============================================================================
# CONSTANTS
# =============================================================================

# A pixel is a near-white CANDIDATE when its darkest channel is at least this
# bright. 240 tolerates the +-8 of JPEG ringing a generated "pure white"
# actually carries, while measured garment fold shadows land at 205-225 -
# safely below. min(R,G,B) is used rather than luma ON PURPOSE: a pale-yellow
# or pale-pink garment has high luma but a low min channel, so it is excluded.
WHITE_MIN_CHANNEL = 240

# ...and the pixel must also be neutral. max(R,G,B) - min(R,G,B) <= 12 rejects
# tinted and gradient backdrops, plus the pale tinted garments a pure
# brightness test would eat.
MAX_CHROMA = 12

# The flood fill runs on a copy this many pixels on its longest edge: 34ms
# versus 562ms at full resolution, and connectivity is a topological property
# that survives the downsample.
COARSE_EDGE = 256

# After a BILINEAR downsample of a binary mask, a value >= 250 means very
# nearly every contributing full-resolution pixel was near-white. Requiring
# that ERODES the flood domain, which is the conservative direction: the flood
# then cannot leak through a thin bright seam (a shoulder highlight, a white
# shoelace) into the garment's interior.
COARSE_SOLID_THRESHOLD = 250

# Alpha ramp across the object boundary, driven by the same min-channel image:
# >= 252 goes fully transparent, <= 232 stays fully opaque, ~20 levels between.
ALPHA_RAMP_LOW = 232
ALPHA_RAMP_HIGH = 252

# MaxFilter kernel used to dilate by 1px (3 => 1px). The ramp is applied ONLY
# inside this halo band, so interior white highlights on a white garment stay
# fully opaque instead of being punched through.
EDGE_BAND_PX = 3

# Sub-pixel blur to kill the staircase on the alpha edge. Large enough to
# soften, too small to read as a glow.
FEATHER_RADIUS = 0.6

# G1: below this there was no white backdrop to remove - a scene shot or a user
# camera photo. Rewriting it would be vandalism, so the original is kept.
MIN_TRANSPARENT_FRACTION = 0.02

# G2: above this the matte ate the subject. Real product shots measure
# 0.73-0.85 transparent.
MAX_TRANSPARENT_FRACTION = 0.93

# G3: a product shot always has the item in the middle. Sampling the central
# 10% box and requiring 70% of it to survive tolerates a genuine hole (a ring,
# an open jacket) while catching a hollowed-out garment - which means the flood
# walked through the garment itself.
CENTER_BOX_RATIO = 0.10
MIN_CENTER_OPACITY = 0.70

# Generation returns 1024x1024 today; this is a ceiling, not a target.
MATTE_MAX_EDGE = 1536

# Output format. Measured on a 1024x1024 generated product shot: WebP q85 with
# alpha 120KB, today's opaque JPEG 144KB, PNG with alpha 850KB. Kept as a
# module constant so the format is switchable in one place.
MATTE_FORMAT = "webp"
MATTE_WEBP_QUALITY = 85

STATUS_MATTED = "matted"
STATUS_SKIPPED_NO_BACKGROUND = "skipped_no_background"
STATUS_REJECTED_ATE_SUBJECT = "rejected_ate_subject"
STATUS_REJECTED_CENTER_TRANSPARENT = "rejected_center_transparent"
STATUS_ERROR = "error"


class MatteResult(NamedTuple):
    """Outcome of one matte attempt.

    On any status other than `matted`, `image_bytes` is the UNMODIFIED input and
    `content_type` is the sniffed type of those original bytes.
    """

    image_bytes: bytes
    content_type: str
    status: str
    transparent_fraction: float
    center_opacity: float
    width: Optional[int]
    height: Optional[int]


def matte_content_type() -> str:
    """MIME type of successfully matted output."""
    return f"image/{MATTE_FORMAT}"


def matte_extension() -> str:
    """File extension matching `matte_content_type()` (e.g. '.webp')."""
    return EXTENSION_BY_MIME.get(matte_content_type(), f".{MATTE_FORMAT}")


# =============================================================================
# INTERNALS
# =============================================================================


def _binarize(mask: Image.Image, threshold: int) -> Image.Image:
    """Threshold an L-mode image to 0/255 via a 256-entry LUT (C speed)."""
    return mask.point(lambda v: 255 if v >= threshold else 0, mode="L")


def _near_white_candidate(rgb: Image.Image) -> tuple[Image.Image, Image.Image]:
    """(candidate mask, min-channel image) for a full-resolution RGB image.

    All C-speed: three channel splits, two darker/lighter passes, one
    difference, three LUT thresholds. No Python per-pixel work.
    """
    r, g, b = rgb.split()
    min_ch = ImageChops.darker(ImageChops.darker(r, g), b)
    max_ch = ImageChops.lighter(ImageChops.lighter(r, g), b)

    bright = _binarize(min_ch, WHITE_MIN_CHANNEL)
    # max_ch >= min_ch everywhere, so difference() is exactly the chroma span.
    chroma = ImageChops.difference(max_ch, min_ch)
    neutral = chroma.point(lambda v: 255 if v <= MAX_CHROMA else 0, mode="L")

    # multiply of two 0/255 masks is a binary AND.
    return ImageChops.multiply(bright, neutral), min_ch


def _border_connected(candidate: Image.Image) -> Image.Image:
    """Full-res mask of candidate pixels reachable from the frame border.

    This is what stops a white garment from being eaten: the interior white of
    a garment is enclosed by its own fold shadows and silhouette edge (measured
    205-225, below WHITE_MIN_CHANNEL), so it is never border-connected.
    """
    width, height = candidate.size
    scale = min(1.0, COARSE_EDGE / float(max(width, height)))
    coarse_w = max(1, int(round(width * scale)))
    coarse_h = max(1, int(round(height * scale)))

    small = candidate.resize((coarse_w, coarse_h), Image.BILINEAR)
    small = _binarize(small, COARSE_SOLID_THRESHOLD)

    # Pad a 1px white border FIRST. Without it a garment touching the frame
    # edge blocks seeding along that whole side.
    padded = Image.new("L", (coarse_w + 2, coarse_h + 2), 255)
    padded.paste(small, (1, 1))
    # thresh=0 on a binary mask is exact - all the tolerance lives in
    # _near_white_candidate, where it is auditable.
    ImageDraw.floodfill(padded, (0, 0), 128, thresh=0)

    reached = padded.crop((1, 1, coarse_w + 1, coarse_h + 1))
    reached = reached.point(lambda v: 255 if v == 128 else 0, mode="L")

    # BILINEAR upsample has no negative lobes, so thresholding at >= 1 simply
    # grows the reachable region by ~half a coarse pixel. Growth is safe: the
    # AND against the full-resolution candidate below is what actually decides.
    upscaled = reached.resize((width, height), Image.BILINEAR)
    return _binarize(upscaled, 1)


def _mask_fraction(mask: Image.Image) -> float:
    """Fraction of an 0/255 mask that is set."""
    total = mask.size[0] * mask.size[1]
    if total <= 0:
        return 0.0
    return mask.histogram()[255] / float(total)


def _center_opacity(background: Image.Image) -> float:
    """Fraction of the central CENTER_BOX_RATIO box that survived the matte."""
    width, height = background.size
    box_w = max(1, int(round(width * CENTER_BOX_RATIO)))
    box_h = max(1, int(round(height * CENTER_BOX_RATIO)))
    left = (width - box_w) // 2
    top = (height - box_h) // 2
    center = background.crop((left, top, left + box_w, top + box_h))
    return 1.0 - _mask_fraction(center)


def _build_alpha(background: Image.Image, min_ch: Image.Image) -> Image.Image:
    """Anti-aliased alpha from a binary background mask.

    Ramp only inside a 1px halo of the background (so interior white highlights
    stay opaque), then a sub-pixel feather, then re-clamp against a dilated
    keep mask so the blur cannot resurrect background more than 1px outside the
    object.
    """
    keep = ImageChops.invert(background)

    # The 1px ring of KEPT pixels that touch background.
    halo = background.filter(ImageFilter.MaxFilter(EDGE_BAND_PX))
    band = ImageChops.multiply(halo, keep)

    span = float(ALPHA_RAMP_HIGH - ALPHA_RAMP_LOW)

    def _ramp(value: int) -> int:
        if value <= ALPHA_RAMP_LOW:
            return 255
        if value >= ALPHA_RAMP_HIGH:
            return 0
        return int(round(255.0 * (ALPHA_RAMP_HIGH - value) / span))

    ramp = min_ch.point(_ramp, mode="L")

    # ramp inside the band, hard keep/drop everywhere else.
    alpha = Image.composite(ramp, keep, band)
    alpha = alpha.filter(ImageFilter.GaussianBlur(FEATHER_RADIUS))
    return ImageChops.darker(alpha, keep.filter(ImageFilter.MaxFilter(EDGE_BAND_PX)))


def _existing_alpha_fraction(img: Image.Image) -> float:
    """Fraction of pixels already carrying alpha < 255, or 0.0 when opaque."""
    if img.mode not in ("RGBA", "LA", "PA") and "transparency" not in img.info:
        return 0.0
    try:
        alpha = img.convert("RGBA").getchannel("A")
    except Exception:
        return 0.0
    histogram = alpha.histogram()
    total = float(sum(histogram)) or 1.0
    return (total - histogram[255]) / total


# =============================================================================
# PUBLIC API
# =============================================================================


def remove_white_background(
    image_bytes: bytes, filename: Optional[str] = None
) -> MatteResult:
    """Cut a flat white backdrop out of `image_bytes`, returning a MatteResult.

    NEVER raises - mirrors `downscale_base64_image`'s best-effort convention.
    Any failure, and any guard rejection, returns the input bytes unmodified
    with a status explaining why, so a caller can always pass an image through
    this function safely.

    Already-transparent input is reported as `skipped_no_background` and echoed
    back unchanged, which makes the operation idempotent - important because a
    backfill may re-visit rows. (Detecting that explicitly is required: a matted
    WebP keeps its white RGB values under the transparent alpha, so a naive
    re-run would happily "re-matte" it.)
    """
    original_content_type = sniff_image_mime(image_bytes, filename)

    def _unchanged(
        status: str, transparent: float = 0.0, center: float = 1.0,
        size: tuple[Optional[int], Optional[int]] = (None, None),
    ) -> MatteResult:
        return MatteResult(
            image_bytes=image_bytes,
            content_type=original_content_type,
            status=status,
            transparent_fraction=transparent,
            center_opacity=center,
            width=size[0],
            height=size[1],
        )

    try:
        with Image.open(io.BytesIO(image_bytes)) as opened:
            already_transparent = _existing_alpha_fraction(opened)
            oriented = ImageOps.exif_transpose(opened)
            rgb = oriented.convert("RGB")
            original_size = rgb.size
            if max(rgb.size) > MATTE_MAX_EDGE:
                rgb.thumbnail((MATTE_MAX_EDGE, MATTE_MAX_EDGE))
            processing_size = rgb.size

            if already_transparent >= MIN_TRANSPARENT_FRACTION:
                return _unchanged(
                    STATUS_SKIPPED_NO_BACKGROUND,
                    transparent=already_transparent,
                    size=original_size,
                )

            candidate, min_ch = _near_white_candidate(rgb)
            background = ImageChops.multiply(candidate, _border_connected(candidate))

            transparent_fraction = _mask_fraction(background)
            center_opacity = _center_opacity(background)

            # G1 - nothing white and border-connected to remove.
            if transparent_fraction < MIN_TRANSPARENT_FRACTION:
                return _unchanged(
                    STATUS_SKIPPED_NO_BACKGROUND,
                    transparent_fraction,
                    center_opacity,
                    original_size,
                )
            # G2 - the matte ate the subject.
            if transparent_fraction > MAX_TRANSPARENT_FRACTION:
                return _unchanged(
                    STATUS_REJECTED_ATE_SUBJECT,
                    transparent_fraction,
                    center_opacity,
                    original_size,
                )
            # G3 - the flood walked through the garment.
            if center_opacity < MIN_CENTER_OPACITY:
                return _unchanged(
                    STATUS_REJECTED_CENTER_TRANSPARENT,
                    transparent_fraction,
                    center_opacity,
                    original_size,
                )

            rgb.putalpha(_build_alpha(background, min_ch))
            buffer = io.BytesIO()
            rgb.save(
                buffer,
                format=MATTE_FORMAT.upper(),
                quality=MATTE_WEBP_QUALITY,
            )

            return MatteResult(
                image_bytes=buffer.getvalue(),
                content_type=matte_content_type(),
                status=STATUS_MATTED,
                transparent_fraction=transparent_fraction,
                center_opacity=center_opacity,
                width=processing_size[0],
                height=processing_size[1],
            )
    except Exception:
        # Best-effort: the caller keeps the image it already had.
        return _unchanged(STATUS_ERROR)


def remove_white_background_base64(image_base64: str) -> tuple[str, str]:
    """base64 -> (base64, status) wrapper around `remove_white_background`.

    Echoes the input verbatim on every non-`matted` status (including a decode
    failure), so callers can treat this as a transparent best-effort filter.
    """
    try:
        raw = base64.b64decode(image_base64)
    except Exception:
        return image_base64, STATUS_ERROR

    result = remove_white_background(raw)
    if result.status != STATUS_MATTED:
        return image_base64, result.status
    return base64.b64encode(result.image_bytes).decode("utf-8"), result.status
