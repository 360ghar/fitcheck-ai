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

HOW IT COPES WITH REAL (IMPERFECT) GENERATOR OUTPUT
Real output drifts off a perfect #FFFFFF field (JPEG ringing, contact shadows,
off-white fields), so `_estimate_backdrop` derives per-image thresholds from
the border ring, falling back to the strict 240/12 constants when the border
varies. Edge treatment (leak-proofed flood, speckle open, shadow-ring pass,
white despill) is documented at each helper below.

THE FAILURE MODE IS "SOME WHITE ITEMS KEEP THEIR WHITE BACKGROUND", NEVER
"SOME WHITE ITEMS ARE DESTROYED". Three guards enforce that, and on any guard
failure the ORIGINAL bytes are returned untouched.

PERFORMANCE
A full-resolution flood fill is a Python loop holding the GIL and measures
~562ms on a 1024x1024 image; at AI_GENERATION_CONCURRENCY=30 that is ~17s of
serialized CPU stalling the batch SSE loop. So the near-white test runs at
full resolution in C (`ImageChops` + `.point()` LUTs) and the flood fill -
needed only for CONNECTIVITY - runs on a 256px copy (`_flood_from_border`, a
bytearray walk) whose result is upscaled and re-intersected with the full-res
mask. Binary dilations use a box blur (`_dilate`), not a rank filter, and
everything after the guards runs on the kept bbox plus CROP_WORK_MARGIN_PX,
not the whole frame.

Measured on the 1024x1024 test product shot (Apple M-series, Pillow 11, best
of 10): 217ms before those three changes, 86ms now at full frame, 69ms with
`crop=True` (smaller encode). Everything here is GIL-held C work, so callers
MUST run it off the event loop via the bounded `run_image_op` executor; the
despill MinFilter and the WebP encode are the remaining big costs. Peak
transient memory is bounded: at most ~3 full-res RGB buffers during the
despill composite plus a handful of 1-byte-per-pixel L masks (~40MB worst case at MATTE_MAX_EDGE=1536, freed by
refcount the moment each stage finishes). No numpy, no temp files.
"""

import base64
import io
from typing import NamedTuple, Optional

from PIL import Image, ImageChops, ImageFilter, ImageOps

# Imported for format detection ONLY. Do not reach for anything else in that
# module from here - see this file's header.
from app.utils.image_processing import EXTENSION_BY_MIME, sniff_image_mime

# =============================================================================
# CONSTANTS
# =============================================================================

# Strict-fallback candidate: a pixel is a near-white CANDIDATE when its darkest
# channel is at least this bright. 240 tolerates the +-8 of JPEG ringing a
# generated "pure white" actually carries, while measured garment fold shadows
# land at 205-225 - safely below. min(R,G,B) is used rather than luma ON
# PURPOSE: a pale-yellow or pale-pink garment has high luma but a low min
# channel, so it is excluded.
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

# Alpha ramp across the object boundary (strict-fallback values; the adaptive
# path derives its own HIGH/LOW from the estimated backdrop, same shape).
ALPHA_RAMP_LOW = 232
ALPHA_RAMP_HIGH = 252

# MaxFilter kernel used to dilate by 2px (5 => 2px). The ramp is applied ONLY
# inside this halo band, so interior white highlights on a white garment stay
# fully opaque instead of being punched through. 2px (not 1px) because the
# coarse-upsampled connectivity mask lands ~half a coarse pixel off the true
# edge, which used to leave a 1px opaque white rim the feather could not kill.
EDGE_BAND_PX = 5

# Sub-pixel blur to kill the staircase on the alpha edge. Large enough to
# soften, too small to read as a glow.
FEATHER_RADIUS = 0.6

# --- Backdrop-adaptive thresholds (all in 0-255 channel units) ---

# Width of the border ring sampled to estimate the backdrop. Small strips, so
# the histograms cost microseconds, not megabytes.
BORDER_SAMPLE_PX = 8

# The adaptive path engages only when the border median is at least this
# bright: true studio fields (white through light-gray falloff) adapt, while
# deliberate gray/gradient backdrops and scene photos keep the strict fallback
# and fail G1 honestly.
ADAPTIVE_MIN_BG_MEDIAN = 235

# ...and the border min-channel p90-p10 spread is at most this: a uniform field
# adapts, a gradient (which varies across the frame) does not.
ADAPTIVE_MAX_SPREAD = 16

# ...and the border chroma p90 is at most this (tinted fields stay strict).
ADAPTIVE_MAX_CHROMA_P90 = 24

# Adaptive candidate floor: bg_median - BG_TOL, never below this. The floor
# keeps measured fold-seam shading (222) out of the candidate set.
BG_TOL = 16
BG_TOL_FLOOR = 225

# Edge ramp shape on the adaptive path: HIGH sits just under the backdrop
# median (so the backdrop itself goes fully transparent even on off-white
# fields) and LOW sits RAMP_SPAN below it (so contact shadows get partial
# alpha instead of an opaque gray outline).
RAMP_SPAN = 40
RAMP_HIGH_OFFSET = 4

# Shadow-ring pass: neutral pixels in [SHADOW_MIN_CHANNEL, cand_thresh) sitting
# just outside the silhouette fade from opaque (dark end) to SHADOW_TIP_ALPHA
# (bright end) instead of shipping as a gray outline. Below SHADOW_MIN the
# pixel is dark enough to be garment - hands off.
SHADOW_MIN_CHANNEL = 180
# Shadow search zone: the coarse flood mask (256px) dilated by this kernel,
# then upsampled. 7 on coarse walks ~3 coarse px ~ +/-12 full px - wide enough
# to cover a real contact shadow, computed on 65k pixels instead of 1M. Only
# neutral mid-tones in [SHADOW_MIN_CHANNEL, cand_thresh) are ever eligible, so
# garment darks and interior whites are excluded by construction; the zone
# terms below add a second layer of protection (see _build_alpha).
SHADOW_ZONE_COARSE_PX = 7
# Alpha of the brightest shadow pixel: clearly translucent, not a hole.
SHADOW_TIP_ALPHA = 90

# G0 (gradient gate): the matte may refuse even a large uniform-looking mask
# when the frame corners disagree. A true studio field is near-identical in
# all four corners; a gradient or scene photo is not. Measured as the
# min-channel range across four corner squares OUTSIDE the garment zone: above
# this the image is a gradient/scene and the original is kept, however big the
# border-connected mask grew.
BG_CORNER_PX = 48
BG_CORNER_VARIANCE_LIMIT = 30

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

# --- Crop to content (item cutouts only; see remove_white_background) ---

# Transparent pad kept around the content box, as a fraction of the box's long
# edge, never less than CROP_MIN_PAD_PX. Keeps the feathered edge and a faint
# contact shadow inside the frame, and gives the item a little air in a tile.
CROP_PAD_RATIO = 0.03
CROP_MIN_PAD_PX = 8
# Alpha below this is feather noise, not content, for the bbox.
CROP_ALPHA_FLOOR = 8
# An already-transparent image is re-cropped only when that removes at least
# this share of its area. A cropped image re-fed lands under it, so a re-run is
# a no-op instead of a re-encode.
CROP_MIN_GAIN = 0.05
# The alpha/despill/encode stages run on the kept bbox grown by this margin
# instead of the whole frame. It must exceed the shadow zone (~12px) and every
# filter reach (despill ~6px, band 2px, feather ~2px), so the result inside
# the box is the same as a full-frame run.
CROP_WORK_MARGIN_PX = 24

STATUS_MATTED = "matted"
STATUS_CROPPED = "cropped"
STATUS_SKIPPED_NO_BACKGROUND = "skipped_no_background"
STATUS_REJECTED_ATE_SUBJECT = "rejected_ate_subject"
STATUS_REJECTED_CENTER_TRANSPARENT = "rejected_center_transparent"
STATUS_ERROR = "error"


class MatteResult(NamedTuple):
    """Outcome of one matte attempt.

    `matted` and `cropped` return transformed `image_bytes` and their output
    `content_type`. Every other status returns the UNMODIFIED input bytes and
    the sniffed content type of that input.
    """

    image_bytes: bytes
    content_type: str
    status: str
    transparent_fraction: float
    center_opacity: float
    width: Optional[int]
    height: Optional[int]


class _Backdrop(NamedTuple):
    """Per-image thresholds derived from the border-ring estimate."""

    bg_median: int
    cand_thresh: int
    chroma_limit: int
    ramp_high: int
    ramp_low: int


def matte_content_type() -> str:
    """MIME type of successfully matted output."""
    return f"image/{MATTE_FORMAT}"


def matte_extension() -> str:
    """File extension matching `matte_content_type()` (e.g. '.webp')."""
    # Fallback only fires if the webp MIME entry is ever removed from the map.
    return EXTENSION_BY_MIME.get(matte_content_type(), f".{MATTE_FORMAT}")  # pragma: no cover - MIME map always has webp


# =============================================================================
# INTERNALS
# =============================================================================


def _binarize(mask: Image.Image, threshold: int) -> Image.Image:
    """Threshold an L-mode image to 0/255 via a 256-entry LUT (C speed)."""
    return mask.point(lambda v: 255 if v >= threshold else 0, mode="L")


def _dilate(mask: Image.Image, size: int) -> Image.Image:
    """Binary dilation of a 0/255 mask by a size x size square.

    Same pixels as `mask.filter(MaxFilter(size))`, but a box blur is O(1) per
    pixel where a rank filter is O(size^2): 2ms versus 34ms at 1024px for
    size=5. Any set pixel in the window leaves a non-zero mean, so
    thresholding at 1 is exact. Only valid on binary masks.
    """
    return _binarize(mask.filter(ImageFilter.BoxBlur(size // 2)), 1)


def _crop_pad(box: tuple[int, int, int, int]) -> int:
    """Transparent pad for a content box (see CROP_PAD_RATIO)."""
    long_edge = max(box[2] - box[0], box[3] - box[1])
    return max(CROP_MIN_PAD_PX, int(round(CROP_PAD_RATIO * long_edge)))


def _grow_box(
    box: tuple[int, int, int, int], margin: int, size: tuple[int, int]
) -> tuple[int, int, int, int]:
    """`box` grown by `margin` on every side, clamped to an image of `size`."""
    left, top, right, bottom = box
    return (
        max(0, left - margin),
        max(0, top - margin),
        min(size[0], right + margin),
        min(size[1], bottom + margin),
    )


def _content_box(alpha: Image.Image) -> Optional[tuple[int, int, int, int]]:
    """Bbox of alpha >= CROP_ALPHA_FLOOR plus its pad, or None when empty.

    Every opaque pixel counts, so a garment is never cut.
    """
    # ponytail: one stray opaque speck far from the item widens the box (a
    # safe miss: less crop, never a cut). If backfill audits show many items
    # barely shrinking, drop tiny components before the bbox.
    box = _binarize(alpha, CROP_ALPHA_FLOOR).getbbox()
    if box is None:
        return None
    return _grow_box(box, _crop_pad(box), alpha.size)


def _crop_existing_alpha(rgba: Image.Image) -> Optional[Image.Image]:
    """Crop an already-transparent image to its content, or None to keep it.

    None when there is no content at all, or when the crop would remove less
    than CROP_MIN_GAIN of the area - which is what makes a re-run on cropped
    output a no-op.
    """
    box = _content_box(rgba.getchannel("A"))
    if box is None:
        return None
    width, height = rgba.size
    area = (box[2] - box[0]) * (box[3] - box[1])
    if area > (1.0 - CROP_MIN_GAIN) * width * height:
        return None
    return rgba.crop(box)


def _percentile(hist: list[int], total: int, quantile: float) -> int:
    """Value at `quantile` (0-1) of a 256-bin L histogram."""
    if total <= 0:
        return 0
    target = total * quantile
    running = 0
    for value, count in enumerate(hist):
        running += count
        if running >= target:
            return value
    return 255


def _estimate_backdrop(rgb: Image.Image) -> _Backdrop:
    """Estimate the studio backdrop from the outer border ring.

    Samples top/bottom/left/right strips (tiny - a few tens of KB), histograms
    the min-channel and chroma there, and returns per-image thresholds. A
    uniform near-white border adapts; anything else falls back to the strict
    WHITE_MIN_CHANNEL / MAX_CHROMA constants so gradients and scene photos
    still fail G1 honestly.
    """
    width, height = rgb.size
    sample = max(2, min(BORDER_SAMPLE_PX, min(width, height) // 8))
    strips = [
        rgb.crop((0, 0, width, sample)),
        rgb.crop((0, height - sample, width, height)),
        rgb.crop((0, sample, sample, height - sample)),
        rgb.crop((width - sample, sample, width, height - sample)),
    ]

    min_hist = [0] * 256
    chroma_hist = [0] * 256
    for strip in strips:
        r, g, b = strip.split()
        min_ch = ImageChops.darker(ImageChops.darker(r, g), b)
        max_ch = ImageChops.lighter(ImageChops.lighter(r, g), b)
        chroma = ImageChops.difference(max_ch, min_ch)
        for i, count in enumerate(min_ch.histogram()):
            min_hist[i] += count
        for i, count in enumerate(chroma.histogram()):
            chroma_hist[i] += count
        del r, g, b, min_ch, max_ch, chroma

    total = sum(min_hist)
    median = _percentile(min_hist, total, 0.50)
    spread = _percentile(min_hist, total, 0.90) - _percentile(min_hist, total, 0.10)
    chroma_p90 = _percentile(chroma_hist, total, 0.90)

    if (
        median >= ADAPTIVE_MIN_BG_MEDIAN
        and spread <= ADAPTIVE_MAX_SPREAD
        and chroma_p90 <= ADAPTIVE_MAX_CHROMA_P90
    ):
        cand_thresh = max(BG_TOL_FLOOR, median - BG_TOL)
        chroma_limit = max(MAX_CHROMA, chroma_p90 + 6)
        ramp_high = min(ALPHA_RAMP_HIGH, max(ALPHA_RAMP_HIGH - 12, median - RAMP_HIGH_OFFSET))
        ramp_low = max(190, ramp_high - RAMP_SPAN)
        return _Backdrop(median, cand_thresh, chroma_limit, ramp_high, ramp_low)

    return _Backdrop(
        WHITE_MIN_CHANNEL, WHITE_MIN_CHANNEL, MAX_CHROMA, ALPHA_RAMP_HIGH, ALPHA_RAMP_LOW
    )


def _near_white_candidate(
    rgb: Image.Image, cand_thresh: int, chroma_limit: int
) -> tuple[Image.Image, Image.Image, Image.Image]:
    """(candidate mask, min-channel image, neutral mask) for an RGB image.

    All C-speed: three channel splits, two darker/lighter passes, one
    difference, LUT thresholds. No Python per-pixel work. The caller owns all
    three outputs and must release the candidate/neutral once the background
    mask and shadow pass no longer need them.
    """
    r, g, b = rgb.split()
    min_ch = ImageChops.darker(ImageChops.darker(r, g), b)
    max_ch = ImageChops.lighter(ImageChops.lighter(r, g), b)
    del r, g, b

    bright = _binarize(min_ch, cand_thresh)
    # max_ch >= min_ch everywhere, so difference() is exactly the chroma span.
    chroma = ImageChops.difference(max_ch, min_ch)
    del max_ch
    neutral = chroma.point(lambda v: 255 if v <= chroma_limit else 0, mode="L")
    del chroma

    # multiply of two 0/255 masks is a binary AND.
    return ImageChops.multiply(bright, neutral), min_ch, neutral


def _flood_from_border(mask: Image.Image) -> Image.Image:
    """255 where a set pixel of a binary mask is 4-connected to the frame edge.

    Every set pixel on the edge seeds the flood, so a garment touching one side
    of the frame does not block seeding along it. Exact, no tolerance - all
    the tolerance lives in _near_white_candidate, where it is auditable. Same
    output as `ImageDraw.floodfill` on a 1px-padded copy, ~3x faster (8ms vs
    28ms at 256px): that one calls a Python colour-diff per neighbour, this is
    a flat stack walk over a bytearray.
    """
    width, height = mask.size
    total = width * height
    src = mask.tobytes()
    out = bytearray(total)
    last_col = width - 1
    edge = (
        list(range(width))
        + list(range(total - width, total))
        + list(range(0, total, width))
        + list(range(last_col, total, width))
    )
    stack = []
    for i in edge:
        if src[i] and not out[i]:
            out[i] = 255
            stack.append(i)
    pop, push = stack.pop, stack.append
    while stack:
        i = pop()
        x = i % width
        if x and src[i - 1] and not out[i - 1]:
            out[i - 1] = 255
            push(i - 1)
        if x != last_col and src[i + 1] and not out[i + 1]:
            out[i + 1] = 255
            push(i + 1)
        j = i - width
        if j >= 0 and src[j] and not out[j]:
            out[j] = 255
            push(j)
        j = i + width
        if j < total and src[j] and not out[j]:
            out[j] = 255
            push(j)
    return Image.frombytes("L", (width, height), bytes(out))


def _border_connected(candidate: Image.Image) -> tuple[Image.Image, Image.Image, Image.Image]:
    """(full-res border-connected mask, coarse search zone, coarse bg halo).

    The full-res mask is what stops a white garment from being eaten: the
    interior white of a garment is enclosed by its own fold shadows and
    silhouette edge (measured 205-225, below any candidate threshold), so it
    is never border-connected. A 1px coarse erode ahead of the flood is the
    conservative direction: it severs thin bright bridges (highlight streaks,
    laces) that would otherwise wick the flood through the silhouette into the
    garment.
    The two coarse products are upsampled to full res for their consumers: the
    shadow ZONE (dilated flood: "background plus its surround", drives the
    shadow pass) and the background HALO (dilated flood minus nothing: the
    background side of the despill zone). Dilating at 256px costs microseconds
    where the full-res equivalents cost hundreds of ms, and the softness is
    irrelevant - both are intersected with sharp full-res masks below.
    """
    width, height = candidate.size
    scale = min(1.0, COARSE_EDGE / float(max(width, height)))
    coarse_w = max(1, int(round(width * scale)))
    coarse_h = max(1, int(round(height * scale)))

    small = candidate.resize((coarse_w, coarse_h), Image.BILINEAR)
    small = _binarize(small, COARSE_SOLID_THRESHOLD)
    small = small.filter(ImageFilter.MinFilter(3))

    reached = _flood_from_border(small)
    del small

    zone = _dilate(reached, SHADOW_ZONE_COARSE_PX)
    zone = zone.resize((width, height), Image.BILINEAR)
    zone = _binarize(zone, 1)

    # Background-side despill halo: a SMALLER dilate of the same flood (~2
    # coarse px ~ 8 full px). Upsampled coarse edges are soft, which is fine -
    # the halo is intersected with the sharp full-res keep dilate below.
    bg_halo = _dilate(reached, 5)
    bg_halo = bg_halo.resize((width, height), Image.BILINEAR)
    bg_halo = _binarize(bg_halo, 1)

    # BILINEAR upsample has no negative lobes, so thresholding at >= 1 simply
    # grows the reachable region by ~half a coarse pixel. Growth is safe: the
    # AND against the full-resolution candidate below is what actually decides.
    upscaled = reached.resize((width, height), Image.BILINEAR)
    return _binarize(upscaled, 1), zone, bg_halo


def _corner_variance(min_ch: Image.Image) -> int:
    """Min-channel range across the four frame corners (gradient detector).

    Corner squares sit outside the garment zone of a centered product shot, so
    they sample backdrop only. A uniform studio field reads near-zero here; a
    gradient or scene reads wide. One getextrema per corner, all C-speed.
    """
    width, height = min_ch.size
    probe = max(8, min(BG_CORNER_PX, min(width, height) // 8))
    boxes = [
        (0, 0, probe, probe),
        (width - probe, 0, width, probe),
        (0, height - probe, probe, height),
        (width - probe, height - probe, width, height),
    ]
    lo, hi = 255, 0
    for box in boxes:
        corner_lo, corner_hi = min_ch.crop(box).getextrema()
        lo = min(lo, corner_lo)
        hi = max(hi, corner_hi)
    return hi - lo


def _mask_fraction(mask: Image.Image) -> float:
    """Fraction of an 0/255 mask that is set."""
    total = mask.size[0] * mask.size[1]
    if total <= 0:  # pragma: no cover - Pillow rejects zero-size images
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


def _build_alpha(
    background: Image.Image,
    min_ch: Image.Image,
    neutral: Image.Image,
    zone: Image.Image,
    bg_halo: Image.Image,
    backdrop: _Backdrop,
) -> tuple[Image.Image, Image.Image]:
    """(anti-aliased alpha, despill mask) from a binary background mask.

    Ramp only inside a 2px halo of the background (so interior white highlights
    stay opaque), then the shadow ring in the surround zone fades to
    SHADOW_TIP_ALPHA instead of shipping as a gray outline, then a sub-pixel
    feather, then re-clamp against a dilated keep mask so the blur cannot
    resurrect background more than 2px outside the object. The despill mask
    (background dilated ~2px, keep dilated ~2px, intersected) straddles the
    silhouette so edge RGB on BOTH sides is pulled toward the garment.
    """
    keep = ImageChops.invert(background)

    # The 2px ring of KEPT pixels that touch background.
    halo = _dilate(background, EDGE_BAND_PX)
    band = ImageChops.multiply(halo, keep)
    del halo

    span = float(backdrop.ramp_high - backdrop.ramp_low) or 1.0

    def _ramp(value: int) -> int:
        if value <= backdrop.ramp_low:
            return 255
        if value >= backdrop.ramp_high:
            return 0
        return int(round(255.0 * (backdrop.ramp_high - value) / span))

    ramp = min_ch.point(_ramp, mode="L")

    # ramp inside the band, hard keep/drop everywhere else.
    alpha = Image.composite(ramp, keep, band)
    del ramp

    # Shadow ring: neutral pixels in the background's surround zone that were
    # too dark to be backdrop candidates (contact shadow, gray falloff) but
    # are not inside the garment either. They fade instead of staying opaque.
    # zone already excludes the razor mask edge, so subtract the dilated halo
    # rather than the mask: the outermost shadow pixels sit just past the band.
    # Protection against eating garment comes from the eligibility terms, not
    # from geometry: shadow pixels must be NEUTRAL mid-tones in
    # [SHADOW_MIN_CHANNEL, cand_thresh) - garment darks, saturated colors and
    # interior whites are excluded by construction. (A halo-adjacent clip was
    # tried here and walled off all but ~4px of real shadows, so it was
    # dropped; the white-fold test pins the interior-white safety.)
    ring_extra = ImageChops.subtract(zone, band)
    shadow_range = min_ch.point(
        lambda v: 255 if SHADOW_MIN_CHANNEL <= v < backdrop.cand_thresh else 0,
        mode="L",
    )
    shadow_mask = ImageChops.multiply(
        ImageChops.multiply(ring_extra, neutral), shadow_range
    )
    del ring_extra, shadow_range

    denom = float(backdrop.cand_thresh - SHADOW_MIN_CHANNEL) or 1.0
    tip = SHADOW_TIP_ALPHA

    def _shadow(value: int) -> int:
        if value < SHADOW_MIN_CHANNEL:
            return 255
        if value >= backdrop.cand_thresh:
            return tip
        return int(
            round(255.0 - (value - SHADOW_MIN_CHANNEL) / denom * (255.0 - tip))
        )

    shadow_alpha = min_ch.point(_shadow, mode="L")
    feathered_in = Image.composite(shadow_alpha, alpha, shadow_mask)
    del alpha, shadow_alpha, shadow_mask, band, zone
    alpha = feathered_in

    # One 2px keep dilate serves both the re-clamp and the despill zone
    # (EDGE_BAND_PX is 5, the same kernel the despill zone needs).
    dil_keep = _dilate(keep, EDGE_BAND_PX)
    del keep
    alpha = alpha.filter(ImageFilter.GaussianBlur(FEATHER_RADIUS))
    alpha = ImageChops.darker(alpha, dil_keep)

    # Despill zone: wide on the BACKGROUND side, narrow on KEEP. The fringe
    # lives on background-side semi pixels, which the razor mask + halo do NOT
    # cover (they stop at the mask edge). bg_halo is the coarse-dilated flood
    # (~8 full px reach, microseconds at 256px); intersect with the sharp
    # full-res keep dilate so deep-interior garment stays untouched.
    despill_mask = ImageChops.multiply(bg_halo, dil_keep)
    del bg_halo, dil_keep
    return alpha, despill_mask


def _despill_rgb(rgb: Image.Image, mask: Image.Image) -> Image.Image:
    """Pull edge RGB toward the darkest neighbor inside `mask`.

    Anti-aliased silhouette pixels are optical blends of garment + white
    backdrop; encoding the blend's near-white RGB under partial alpha is what
    reads as white fringe when the tile composites over a dark UI. The blend
    ramp is ~8px wide, so a MinFilter(3) never reaches past it into true
    garment color. Instead the minima run at HALF resolution - MinFilter(7)
    there sees ~14 full px for ~45ms (a full-res MinFilter(13) costs ~450ms) -
    and upsample NEAREST so the replacement colors stay pure garment instead
    of re-blended. Only sampled inside `mask`, which straddles the silhouette,
    so flat areas are untouched. All C-speed, no numpy.
    """
    width, height = rgb.size
    half = (max(1, width // 2), max(1, height // 2))
    small = rgb.resize(half, Image.BILINEAR)
    dark_small = small.filter(ImageFilter.MinFilter(7))
    del small
    dark = dark_small.resize((width, height), Image.NEAREST)
    return Image.composite(dark, rgb, mask)


def _existing_alpha_fraction(img: Image.Image) -> float:
    """Fraction of pixels already carrying alpha < 255, or 0.0 when opaque."""
    if img.mode not in ("RGBA", "LA", "PA") and "transparency" not in img.info:
        return 0.0
    try:
        alpha = img.convert("RGBA").getchannel("A")
    except Exception:  # pragma: no cover - defensive; convert always succeeds
        return 0.0
    histogram = alpha.histogram()
    total = float(sum(histogram)) or 1.0
    return (total - histogram[255]) / total


def _encode(rgba: Image.Image) -> bytes:
    """Encode matte output in MATTE_FORMAT."""
    buffer = io.BytesIO()
    rgba.save(buffer, format=MATTE_FORMAT.upper(), quality=MATTE_WEBP_QUALITY)
    return buffer.getvalue()


# =============================================================================
# PUBLIC API
# =============================================================================


def remove_white_background(
    image_bytes: bytes, filename: Optional[str] = None, *, crop: bool = False
) -> MatteResult:
    """Cut a flat white backdrop out of `image_bytes`, returning a MatteResult.

    `crop=True` also trims the output to its content plus a small transparent
    pad (CROP_PAD_RATIO), so a grid tile shows the item instead of a 1024px
    field of nothing. Item cutouts only: an outfit look stays full-frame
    because outfit tiles use `object-cover` for their (opaque) model shots, and
    a tight flat-lay under `cover` would lose its top and bottom. With
    `crop=True`, already-transparent input is cropped the same way and
    reported as `cropped` (or `skipped_no_background` when it is already
    tight), which is what lets the backfill trim the previously matted corpus.

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

            if already_transparent >= MIN_TRANSPARENT_FRACTION:
                if crop:
                    cropped = _crop_existing_alpha(oriented.convert("RGBA"))
                    if cropped is not None:
                        return MatteResult(
                            image_bytes=_encode(cropped),
                            content_type=matte_content_type(),
                            status=STATUS_CROPPED,
                            transparent_fraction=already_transparent,
                            center_opacity=1.0,
                            width=cropped.size[0],
                            height=cropped.size[1],
                        )
                return _unchanged(
                    STATUS_SKIPPED_NO_BACKGROUND,
                    transparent=already_transparent,
                    size=oriented.size,
                )

            rgb = oriented.convert("RGB")
            original_size = rgb.size
            if max(rgb.size) > MATTE_MAX_EDGE:
                rgb.thumbnail((MATTE_MAX_EDGE, MATTE_MAX_EDGE))
            frame_size = rgb.size

            backdrop = _estimate_backdrop(rgb)
            candidate, min_ch, neutral = _near_white_candidate(
                rgb, backdrop.cand_thresh, backdrop.chroma_limit
            )
            connected, zone, bg_halo = _border_connected(candidate)
            # Connectivity ANDed against the full-resolution candidate: the
            # upsampled flood may have grown ~half a coarse pixel, and only
            # the full-res near-white test decides.
            background = ImageChops.multiply(candidate, connected)
            del candidate, connected

            transparent_fraction = _mask_fraction(background)
            center_opacity = _center_opacity(background)

            # G0 - the frame corners disagree: gradient or scene, not a studio
            # field. Refused however large the mask grew.
            if _corner_variance(min_ch) > BG_CORNER_VARIANCE_LIMIT:
                return _unchanged(
                    STATUS_SKIPPED_NO_BACKGROUND,
                    transparent_fraction,
                    center_opacity,
                    original_size,
                )
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

            # The guards needed the whole frame; nothing after them does. Run
            # alpha, despill and encode on the kept bbox plus a margin wider
            # than every filter's reach: ~75% of a product shot is backdrop,
            # and outside this box the alpha is 0 anyway.
            keep_box = ImageChops.invert(background).getbbox() or (0, 0, *frame_size)
            margin = max(CROP_WORK_MARGIN_PX, _crop_pad(keep_box))
            work_box = _grow_box(keep_box, margin, frame_size)
            background, min_ch, neutral, zone, bg_halo, rgb = (
                image.crop(work_box)
                for image in (background, min_ch, neutral, zone, bg_halo, rgb)
            )

            alpha, despill_mask = _build_alpha(background, min_ch, neutral, zone, bg_halo, backdrop)
            del background, min_ch, neutral, zone, bg_halo
            rgb = _despill_rgb(rgb, despill_mask)
            del despill_mask
            rgb.putalpha(alpha)

            if crop:
                content_box = _content_box(alpha)
                if content_box is not None:
                    rgb = rgb.crop(content_box)
            else:
                # Full frame back. RGB under alpha 0 stays white, as before.
                canvas = Image.new("RGBA", frame_size, (255, 255, 255, 0))
                canvas.paste(rgb, work_box[:2])
                rgb = canvas
            del alpha

            return MatteResult(
                image_bytes=_encode(rgb),
                content_type=matte_content_type(),
                status=STATUS_MATTED,
                transparent_fraction=transparent_fraction,
                center_opacity=center_opacity,
                width=rgb.size[0],
                height=rgb.size[1],
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
