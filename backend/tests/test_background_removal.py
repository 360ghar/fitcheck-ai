"""Tests for app.utils.background_removal - the white-backdrop matte.

The four fixtures below ARE the justification for the algorithm's design, so
they are written as explicit optical cases rather than smoke tests:

  1. dark garment on white          -> matted (the easy case)
  2. flat-white garment, no shading -> REJECTED, original kept (the pathological
                                       case: nothing distinguishes garment from
                                       backdrop, so both guards must fire)
  3. white garment with real folds  -> matted CORRECTLY (the case that makes
                                       this shippable: a real generated white
                                       shirt is never flat 255)
  4. scene photo, no white backdrop -> SKIPPED, original kept

The invariant they protect: the failure mode is "some white items keep their
white background", NEVER "some white items are destroyed".
"""

import base64
import io
import time

import pytest
from PIL import Image, ImageDraw

from app.utils.background_removal import (
    MATTE_WEBP_QUALITY,
    MAX_TRANSPARENT_FRACTION,
    MIN_CENTER_OPACITY,
    MIN_TRANSPARENT_FRACTION,
    STATUS_ERROR,
    STATUS_MATTED,
    STATUS_REJECTED_ATE_SUBJECT,
    STATUS_SKIPPED_NO_BACKGROUND,
    matte_content_type,
    remove_white_background,
    remove_white_background_base64,
)
from app.utils.image_processing import downscale_base64_image

SIZE = (1024, 1024)
# A centred garment-ish silhouette covering ~26% of a 1024 frame, matching the
# 0.73-0.85 transparent fraction real product shots measure.
GARMENT_BOX = (300, 180, 724, 844)


def _encode(img: Image.Image, fmt="JPEG", **kwargs) -> bytes:
    buf = io.BytesIO()
    img.save(buf, format=fmt, quality=kwargs.pop("quality", 92), **kwargs)
    return buf.getvalue()


def _b64(data: bytes) -> str:
    return base64.b64encode(data).decode("utf-8")


def _draw_garment(draw: ImageDraw.ImageDraw, fill, outline=None) -> None:
    """A shirt-ish silhouette: body plus two sleeves."""
    left, top, right, bottom = GARMENT_BOX
    draw.rounded_rectangle(
        (left, top, right, bottom), radius=40, fill=fill, outline=outline, width=6
    )
    draw.polygon(
        [(left, top + 30), (left - 120, top + 180), (left - 60, top + 250), (left, top + 140)],
        fill=fill,
        outline=outline,
    )
    draw.polygon(
        [(right, top + 30), (right + 120, top + 180), (right + 60, top + 250), (right, top + 140)],
        fill=fill,
        outline=outline,
    )


def _dark_garment_on_white() -> bytes:
    img = Image.new("RGB", SIZE, (255, 255, 255))
    _draw_garment(ImageDraw.Draw(img), fill=(38, 44, 61))
    return _encode(img)


def _flat_white_garment() -> bytes:
    """(253,253,253) on (255,255,255): zero shading anywhere. Pathological."""
    img = Image.new("RGB", SIZE, (255, 255, 255))
    _draw_garment(ImageDraw.Draw(img), fill=(253, 253, 253))
    return _encode(img)


def _white_garment_with_folds() -> bytes:
    """A realistic white shirt: body 246, shaded seams 222, silhouette 205."""
    img = Image.new("RGB", SIZE, (255, 255, 255))
    draw = ImageDraw.Draw(img)
    _draw_garment(draw, fill=(246, 246, 246), outline=(205, 205, 205))

    left, top, right, bottom = GARMENT_BOX
    # Fold shadows running down the body, plus a shaded hem and a placket.
    for x in range(left + 60, right - 40, 90):
        draw.line([(x, top + 60), (x + 18, bottom - 40)], fill=(222, 222, 222), width=9)
    draw.line([(left + 8, bottom - 26), (right - 8, bottom - 26)], fill=(222, 222, 222), width=10)
    draw.line(
        [((left + right) // 2, top + 20), ((left + right) // 2, bottom - 20)],
        fill=(222, 222, 222),
        width=12,
    )
    return _encode(img)


def _scene_photo() -> bytes:
    """No white backdrop at all - a mid-tone room with a gradient wall."""
    img = Image.new("RGB", SIZE)
    pixels = img.load()
    for y in range(SIZE[1]):
        for x in range(0, SIZE[0], 4):
            value = 90 + (x * 60) // SIZE[0] + (y * 40) // SIZE[1]
            for dx in range(4):
                pixels[x + dx, y] = (value, value - 12, value - 30)
    _draw_garment(ImageDraw.Draw(img), fill=(58, 70, 92))
    return _encode(img)


def _report(label: str, result, elapsed_ms: float, source_len: int) -> None:
    print(
        f"\n[matte] {label:<34} status={result.status:<28} "
        f"transparent={result.transparent_fraction:.3f} "
        f"center_opacity={result.center_opacity:.3f} "
        f"{elapsed_ms:.1f}ms  in={source_len / 1024:.1f}KB "
        f"out={len(result.image_bytes) / 1024:.1f}KB"
    )


def _run(label: str, data: bytes):
    start = time.perf_counter()
    result = remove_white_background(data)
    elapsed_ms = (time.perf_counter() - start) * 1000.0
    _report(label, result, elapsed_ms, len(data))
    return result, elapsed_ms


# =============================================================================
# The four algorithm cases
# =============================================================================


def test_dark_garment_on_white_is_matted():
    result, _ = _run("dark garment on white", _dark_garment_on_white())

    assert result.status == STATUS_MATTED
    assert MIN_TRANSPARENT_FRACTION < result.transparent_fraction < MAX_TRANSPARENT_FRACTION
    assert result.center_opacity >= MIN_CENTER_OPACITY
    assert result.content_type == matte_content_type()
    assert result.width == SIZE[0] and result.height == SIZE[1]

    with Image.open(io.BytesIO(result.image_bytes)) as out:
        assert out.format == "WEBP"
        assert out.mode == "RGBA"
        alpha = out.getchannel("A")
        # Corners transparent, centre opaque.
        assert alpha.getpixel((2, 2)) == 0
        assert alpha.getpixel((SIZE[0] // 2, SIZE[1] // 2)) == 255


def test_flat_white_garment_is_rejected_and_original_kept():
    """No shading anywhere means garment and backdrop are indistinguishable.

    Both G2 (ate the subject) and G3 (centre went transparent) must condemn it;
    G2 is checked first so it is the reported status. The bytes must come back
    untouched - a white-backed tile is an acceptable outcome, a destroyed
    garment is not.
    """
    source = _flat_white_garment()
    result, _ = _run("flat white garment (253)", source)

    assert result.status == STATUS_REJECTED_ATE_SUBJECT
    assert result.transparent_fraction > MAX_TRANSPARENT_FRACTION
    assert result.center_opacity < MIN_CENTER_OPACITY  # G3 would also have fired
    assert result.image_bytes == source
    assert result.content_type == "image/jpeg"


def test_white_garment_with_folds_is_matted_correctly():
    """The mitigation for the white-garment problem, and why this ships."""
    result, _ = _run("white garment + folds", _white_garment_with_folds())

    assert result.status == STATUS_MATTED
    assert MIN_TRANSPARENT_FRACTION < result.transparent_fraction < MAX_TRANSPARENT_FRACTION
    assert result.center_opacity >= MIN_CENTER_OPACITY

    with Image.open(io.BytesIO(result.image_bytes)) as out:
        alpha = out.getchannel("A")
        assert alpha.getpixel((2, 2)) == 0
        # The garment's own 246-white interior must survive fully opaque.
        assert alpha.getpixel((SIZE[0] // 2, SIZE[1] // 2)) == 255
        assert alpha.getpixel((GARMENT_BOX[0] + 30, GARMENT_BOX[1] + 30)) == 255


def test_scene_photo_is_skipped_and_original_kept():
    source = _scene_photo()
    result, _ = _run("scene photo, no backdrop", source)

    assert result.status == STATUS_SKIPPED_NO_BACKGROUND
    assert result.transparent_fraction < MIN_TRANSPARENT_FRACTION
    assert result.image_bytes == source


def test_oversized_success_reports_processed_dimensions():
    """Successful mattes report the bounded processing canvas, not stale input
    dimensions that no longer match the bytes uploaded to storage."""
    size = (2048, 1024)
    img = Image.new("RGB", size, (255, 255, 255))
    ImageDraw.Draw(img).rounded_rectangle((600, 160, 1448, 864), radius=60, fill=(38, 44, 61))
    result = remove_white_background(_encode(img))

    assert result.status == STATUS_MATTED
    assert (result.width, result.height) == (1536, 768)


def test_oversized_rejection_reports_original_dimensions_and_bytes():
    """Rejected input keeps the original bytes, so its audit dimensions must
    remain the original decoded canvas rather than the temporary thumbnail."""
    size = (2048, 1024)
    img = Image.new("RGB", size, (255, 255, 255))
    ImageDraw.Draw(img).rounded_rectangle((600, 160, 1448, 864), radius=60, fill=(253, 253, 253))
    source = _encode(img)
    result = remove_white_background(source)

    assert result.status == STATUS_REJECTED_ATE_SUBJECT
    assert (result.width, result.height) == size
    assert result.image_bytes == source


# =============================================================================
# Robustness / idempotence / performance
# =============================================================================


def test_malformed_bytes_return_error_status_and_do_not_raise():
    result = remove_white_background(b"definitely not image bytes")
    assert result.status == STATUS_ERROR
    assert result.image_bytes == b"definitely not image bytes"
    assert result.width is None and result.height is None


def test_base64_wrapper_echoes_input_on_error():
    junk = base64.b64encode(b"not an image").decode("utf-8")
    out, status = remove_white_background_base64(junk)
    assert status == STATUS_ERROR
    assert out == junk


def test_base64_wrapper_returns_new_bytes_on_success():
    source = _b64(_dark_garment_on_white())
    out, status = remove_white_background_base64(source)
    assert status == STATUS_MATTED
    assert out != source
    with Image.open(io.BytesIO(base64.b64decode(out))) as img:
        assert img.mode == "RGBA"


@pytest.mark.parametrize("fmt", ["WEBP", "PNG"])
def test_rerunning_on_already_transparent_output_is_idempotent(fmt):
    """A matted image re-fed must be skipped, not chewed a second time.

    A matte keeps the backdrop's white RGB values under the transparent alpha,
    so without an explicit already-transparent check this would happily
    "re-matte" and re-encode forever.
    """
    matted = remove_white_background(_dark_garment_on_white())
    assert matted.status == STATUS_MATTED

    with Image.open(io.BytesIO(matted.image_bytes)) as img:
        buf = io.BytesIO()
        img.save(buf, format=fmt)
        transparent_source = buf.getvalue()

    second = remove_white_background(transparent_source)
    assert second.status == STATUS_SKIPPED_NO_BACKGROUND
    assert second.image_bytes == transparent_source
    assert second.content_type == f"image/{fmt.lower()}"


def test_matte_is_fast_enough_for_the_generation_concurrency_budget():
    """~70-85ms/image is the claim; assert a loose ceiling and print the truth.

    AI_GENERATION_CONCURRENCY is 30, so a full-resolution floodfill (562ms,
    GIL-held) would serialize into ~17s and stall the batch SSE loop. The
    ceiling here is deliberately generous for slow CI, and the printed number
    is what should be read.
    """
    source = _dark_garment_on_white()
    remove_white_background(source)  # warm Pillow's codecs
    timings = []
    for _ in range(5):
        _, elapsed_ms = _run("timing sample", source)
        timings.append(elapsed_ms)
    best = min(timings)
    print(f"\n[matte] best of 5: {best:.1f}ms  (mean {sum(timings) / len(timings):.1f}ms)")
    assert best < 400.0, f"matte took {best:.1f}ms, far above the ~80ms budget"


def test_webp_output_is_smaller_than_the_opaque_jpeg_baseline():
    """The batch job holds this base64 in memory AND pushes it over SSE, so the
    encoded size is a memory-cap concern (tests/test_job_memory_caps.py)."""
    source = _dark_garment_on_white()
    result = remove_white_background(source)
    assert result.status == STATUS_MATTED

    with Image.open(io.BytesIO(source)) as img:
        jpeg_baseline = _encode(img.convert("RGB"), quality=MATTE_WEBP_QUALITY)

    print(
        f"\n[matte] webp+alpha {len(result.image_bytes) / 1024:.1f}KB vs "
        f"jpeg q{MATTE_WEBP_QUALITY} baseline {len(jpeg_baseline) / 1024:.1f}KB"
    )
    assert len(result.image_bytes) <= len(jpeg_baseline)


# =============================================================================
# The guardrail against "unifying" the two modules
# =============================================================================


def test_downscale_still_flattens_alpha_to_an_opaque_jpeg():
    """image_processing is the INVERSE of background_removal and must stay so.

    Its output feeds the AI model, which cannot consume alpha; a matted item
    image arriving as a garment reference must be flattened onto white.
    """
    rgba = Image.new("RGBA", (300, 300), (0, 0, 0, 0))
    ImageDraw.Draw(rgba).ellipse((60, 60, 240, 240), fill=(20, 90, 200, 255))
    buf = io.BytesIO()
    rgba.save(buf, format="PNG")

    out = downscale_base64_image(_b64(buf.getvalue()))

    with Image.open(io.BytesIO(base64.b64decode(out))) as img:
        assert img.format == "JPEG"
        assert img.mode == "RGB"
        assert "A" not in img.getbands()
        # The transparent region became white, not black.
        assert img.getpixel((3, 3)) == (255, 255, 255)


def test_downscale_flattens_a_real_matted_webp_even_though_it_grows_it():
    """The realistic version of the case above, and a live regression.

    A lossy WebP cutout is SMALLER than its flattened JPEG, so
    `downscale_base64_image`'s "keep the original if the re-encode grew it"
    guard used to hand the transparent WebP straight back to the model.
    """
    matted = remove_white_background(_dark_garment_on_white())
    assert matted.status == STATUS_MATTED
    source = _b64(matted.image_bytes)

    out = downscale_base64_image(source)

    assert len(out) > len(source)  # the JPEG really is bigger
    with Image.open(io.BytesIO(base64.b64decode(out))) as img:
        assert img.format == "JPEG"
        assert img.mode == "RGB"
        assert img.getpixel((3, 3)) == (255, 255, 255)
