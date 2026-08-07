"""Residual branch coverage for app.utils.image_processing.

The sibling test_image_processing.py covers the crop/downscale/transcode
happy paths; this file covers the remaining guards and failure branches:
magic sniffing edge cases, payload validation raises, data-URL handling,
AVIF/HEIF provider re-encode fallbacks, mode conversions, and degenerate
crop boxes.
"""

import base64
import io

import pytest
from PIL import Image

from app.utils.image_processing import (
    decode_and_validate_base64_image,
    downscale_base64_image,
    downscale_image_bytes_to_base64,
    downscale_image_bytes_to_webp,
    ensure_provider_safe_base64,
    make_base64_image_validator,
    sniff_image_mime,
    sniff_image_mime_from_magic,
    to_data_url,
    validate_image_bytes,
    crop_base64_image_to_box,
)


def _b64(img: Image.Image, fmt: str) -> str:
    buf = io.BytesIO()
    img.save(buf, format=fmt)
    return base64.b64encode(buf.getvalue()).decode("utf-8")


def _raw(img: Image.Image, fmt: str) -> bytes:
    buf = io.BytesIO()
    img.save(buf, format=fmt)
    return buf.getvalue()


# ---------------------------------------------------------------------------
# sniff_image_mime
# ---------------------------------------------------------------------------


def test_sniff_image_mime_from_magic_empty_and_gif():
    assert sniff_image_mime_from_magic(b"") is None
    gif = _raw(Image.new("RGB", (10, 10)), "GIF")
    assert sniff_image_mime_from_magic(gif) == "image/gif"


def test_sniff_image_mime_falls_back_to_pillow_format():
    ico = _raw(Image.new("RGB", (16, 16)), "ICO")
    assert sniff_image_mime(ico) == "image/ico"


def test_sniff_image_mime_falls_back_to_filename_extension():
    garbage = b"definitely not an image"
    assert sniff_image_mime(garbage, filename="photo.jpg") == "image/jpeg"
    assert sniff_image_mime(garbage, filename=".png") == "image/png"
    assert sniff_image_mime(garbage, filename="unknown.xyz") == "application/octet-stream"


# ---------------------------------------------------------------------------
# validate_image_bytes / decode_and_validate_base64_image
# ---------------------------------------------------------------------------


def test_validate_image_bytes_rejects_empty_and_oversized():
    with pytest.raises(ValueError, match="empty"):
        validate_image_bytes(b"", max_bytes=1000)
    with pytest.raises(ValueError, match="exceeds"):
        validate_image_bytes(_raw(Image.new("RGB", (4, 4)), "PNG"), max_bytes=1)


def test_validate_image_bytes_rejects_unsupported_decoded_format():
    ico = _raw(Image.new("RGB", (16, 16)), "ICO")
    with pytest.raises(ValueError, match="Unsupported decoded image format"):
        validate_image_bytes(ico, max_bytes=100_000)


def test_decode_and_validate_base64_image_empty_and_bad_data_url():
    with pytest.raises(ValueError, match="required"):
        decode_and_validate_base64_image("   ", max_bytes=1000)
    with pytest.raises(ValueError, match="base64"):
        decode_and_validate_base64_image("data:image/png,notbase64", max_bytes=1000)
    with pytest.raises(ValueError, match="base64"):
        decode_and_validate_base64_image("data:image/png", max_bytes=1000)


def test_decode_and_validate_base64_image_rejects_invalid_base64():
    with pytest.raises(ValueError, match="not valid base64"):
        decode_and_validate_base64_image("!!!not-base64!!!", max_bytes=1000)


def test_make_base64_image_validator_wraps_decode_errors():
    validate = make_base64_image_validator(max_bytes=1_000_000)
    real = _b64(Image.new("RGB", (4, 4)), "PNG")
    assert validate(real) == real
    with pytest.raises(ValueError, match="Image is invalid"):
        validate("!!!bad-base64!!!")


# ---------------------------------------------------------------------------
# to_data_url / ensure_provider_safe_base64
# ---------------------------------------------------------------------------


def test_to_data_url_passthrough_for_data_urls():
    data_url = "data:image/png;base64,AAAA"
    assert to_data_url(data_url) == data_url


def test_to_data_url_sniffs_real_mime():
    png = _b64(Image.new("RGB", (8, 8)), "PNG")
    out = to_data_url(png)
    assert out.startswith("data:image/png;base64,")
    assert out.endswith(png)


def test_to_data_url_handles_bad_padding_prefix():
    # 95 chars: invalid base64 length -> sniffing fails -> JPEG fallback.
    out = to_data_url("a" * 95)
    assert out.startswith("data:image/jpeg;base64,")


def test_ensure_provider_safe_base64_passes_through_safe_formats():
    png = _b64(Image.new("RGB", (8, 8)), "PNG")
    assert ensure_provider_safe_base64(png) == png


def test_ensure_provider_safe_base64_data_url_avif_reencodes():
    avif_bytes = b"fake-avif-payload"
    data_url = f"data:image/avif;base64,{base64.b64encode(avif_bytes).decode()}"
    out = ensure_provider_safe_base64(data_url)
    # Undecodable payload -> best-effort passthrough unchanged.
    assert out == data_url


def test_ensure_provider_safe_base64_bare_avif_with_bad_tail_passthrough():
    head = base64.b64encode(b"\x00\x00\x00\x18ftypavif" + b"\x00" * 80).decode()
    bad = head + "!!!"  # magic says avif, full decode fails
    assert ensure_provider_safe_base64(bad) == bad


def test_ensure_provider_safe_base64_bare_avif_undecodable_passthrough():
    avif = base64.b64encode(b"\x00\x00\x00\x18ftypavif" + b"\x00" * 200).decode()
    assert ensure_provider_safe_base64(avif) == avif


def test_ensure_provider_safe_base64_bare_avif_reencodes_to_jpeg():
    avif = _b64(Image.new("RGB", (64, 64)), "AVIF")
    out = ensure_provider_safe_base64(avif)
    assert out != avif
    assert out.startswith("/9j/")  # JPEG re-encode


def test_ensure_provider_safe_base64_bare_garbage_passthrough():
    garbage = "a" * 95  # bad padding -> sniff failure -> passthrough
    assert ensure_provider_safe_base64(garbage) == garbage


# ---------------------------------------------------------------------------
# downscale bytes / mode conversions
# ---------------------------------------------------------------------------


def test_downscale_image_bytes_to_base64_returns_raw_on_failure():
    raw = b"garbage bytes"
    assert base64.b64decode(downscale_image_bytes_to_base64(raw)) == raw


def test_downscale_image_bytes_to_base64_alpha_source_reencodes():
    rgba = _raw(Image.new("RGBA", (300, 200), (255, 0, 0, 128)), "PNG")
    out = downscale_image_bytes_to_base64(rgba)
    assert out.startswith("/9j/")  # always re-encoded when alpha was flattened


def test_downscale_image_bytes_to_webp_success_and_failure():
    jpeg = _raw(Image.new("RGB", (300, 200)), "JPEG")
    out = downscale_image_bytes_to_webp(jpeg, max_edge=100)
    assert out is not None
    with Image.open(io.BytesIO(out)) as img:
        assert img.format == "WEBP"
        assert max(img.size) <= 100
    assert downscale_image_bytes_to_webp(b"garbage", max_edge=100) is None
    # A within-bound WebP passes through unchanged.
    webp = _raw(Image.new("RGB", (30, 20)), "WEBP")
    assert downscale_image_bytes_to_webp(webp, max_edge=100) == webp


def test_downscale_base64_image_returns_input_on_invalid_base64():
    bad = "a" * 95
    assert downscale_base64_image(bad) == bad


def test_decode_and_fit_flattens_palette_without_alpha_to_rgb():
    palette = Image.new("P", (50, 50))
    out = downscale_image_bytes_to_base64(_raw(palette, "PNG"))
    assert out  # non-empty JPEG base64


def test_decode_and_fit_converts_transparent_palette_to_rgba():
    palette = Image.new("P", (50, 50))
    palette.info["transparency"] = 0
    out = downscale_image_bytes_to_webp(_raw(palette, "PNG"), max_edge=40)
    assert out is not None


def test_decode_and_fit_converts_cmyk_without_alpha_to_rgb():
    cmyk = Image.new("CMYK", (40, 30))
    out = downscale_image_bytes_to_base64(_raw(cmyk, "JPEG"))
    assert out


def test_decode_and_fit_converts_cmyk_without_alpha_for_webp():
    cmyk = Image.new("CMYK", (40, 30))
    out = downscale_image_bytes_to_webp(_raw(cmyk, "JPEG"), max_edge=40)
    assert out is not None
    with Image.open(io.BytesIO(out)) as img:
        assert img.format == "WEBP"


# ---------------------------------------------------------------------------
# crop_base64_image_to_box edge branches
# ---------------------------------------------------------------------------


def test_crop_with_png_source_skips_draft_and_converts_mode():
    png = _b64(Image.new("RGB", (200, 150)), "PNG")
    out = crop_base64_image_to_box(png, {"x": 10, "y": 10, "width": 50, "height": 50})
    assert out.startswith("/9j/")  # JPEG base64 result


def test_crop_with_palette_source_converts_mode():
    palette = _b64(Image.new("P", (120, 90)), "PNG")
    out = crop_base64_image_to_box(palette, {"x": 0, "y": 0, "width": 40, "height": 40})
    assert out.startswith("/9j/")


def test_crop_with_negative_padding_ratio_returns_input():
    # Both padding_ratio and padding_floor negative make the padded box
    # degenerate (x1 <= x0), which must fall back to the input unchanged.
    png = _b64(Image.new("RGB", (100, 100)), "PNG")
    out = crop_base64_image_to_box(
        png,
        {"x": 50, "y": 50, "width": 10, "height": 10},
        padding_ratio=-50.0,
        padding_floor=-50.0,
    )
    assert out == png
