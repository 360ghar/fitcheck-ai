"""Regression coverage for byte-level validation at image upload boundaries."""

import base64
import io

import pytest
from PIL import Image
from pydantic import ValidationError

from app.api.v1.batch_processing import BatchImageInput, SingleExtractionRequest
from app.models.ai import ExtractItemsRequest, ExtractSingleItemRequest, GenerateProductImageRequest, TryOnRequest
from app.models.demo import DemoExtractItemsRequest, DemoTryOnRequest
from app.models.photoshoot import DemoPhotoshootRequest, PhotoshootUseCase, StartPhotoshootRequest
from app.utils.image_processing import (
    SUPPORTED_UPLOAD_MIME_TYPES,
    decode_and_validate_base64_image,
    ensure_provider_safe_base64,
    sniff_image_mime_from_magic,
    to_data_url,
    validate_image_bytes,
)


def _png_bytes() -> bytes:
    buffer = io.BytesIO()
    Image.new("RGB", (2, 2), "white").save(buffer, format="PNG")
    return buffer.getvalue()


def test_base64_image_validation_uses_decoded_bytes_not_extension_or_header():
    encoded = base64.b64encode(_png_bytes()).decode("ascii")

    assert decode_and_validate_base64_image(encoded, max_bytes=1024 * 1024)
    with pytest.raises(ValueError, match="valid decodable image"):
        decode_and_validate_base64_image(base64.b64encode(b"not-an-image").decode("ascii"), max_bytes=1024)


@pytest.mark.parametrize(
    "model_factory",
    [
        lambda value: BatchImageInput(image_id="img-1", image_base64=value),
        lambda value: SingleExtractionRequest(image=value),
        lambda value: ExtractItemsRequest(image=value),
        lambda value: ExtractSingleItemRequest(image=value),
        lambda value: GenerateProductImageRequest(
            item_description="shirt", category="tops", reference_image=value
        ),
        lambda value: TryOnRequest(clothing_image=value),
        lambda value: DemoExtractItemsRequest(image=value),
        lambda value: DemoTryOnRequest(person_image=value, clothing_image=value),
        lambda value: StartPhotoshootRequest(
            photos=[value], use_case=PhotoshootUseCase.AESTHETIC, num_images=1
        ),
        lambda value: DemoPhotoshootRequest(photo=value),
    ],
)
def test_request_models_reject_invalid_base64_image_bytes(model_factory):
    invalid = base64.b64encode(b"not-an-image").decode("ascii")

    with pytest.raises(ValidationError, match="invalid|valid decodable"):
        model_factory(invalid)


def test_multipart_byte_validator_rejects_spoofed_image_type():
    with pytest.raises(ValueError, match="valid decodable image"):
        validate_image_bytes(b"not-an-image", max_bytes=1024 * 1024)


# ---------------------------------------------------------------------------
# AVIF uploads (2026-08-04): iOS Safari 16+/modern cameras upload AVIF; it
# decodes fine but was rejected with a 415 "Unsupported decoded image
# format: image/avif" on /ai/batch-extract-multipart. The upload allow-list
# now accepts it, and provider-bound bytes are re-encoded to JPEG first
# because neither Gemini nor the OpenAI-compatible image APIs can read AVIF.
# ---------------------------------------------------------------------------


def test_avif_is_in_upload_allowlist_and_sniffed():
    assert "image/avif" in SUPPORTED_UPLOAD_MIME_TYPES
    # ftypavif ISO-BMFF brand -> image/avif
    assert sniff_image_mime_from_magic(b"\x00\x00\x00\x18ftypavifmif1") == "image/avif"


@pytest.mark.skipif(
    "AVIF" not in Image.registered_extensions(),
    reason="Pillow build lacks an AVIF decoder (pillow-avif-plugin)",
)
def test_validate_image_bytes_accepts_real_avif():
    """A genuine AVIF file passes upload validation once the decoder exists
    (production Pillow 11.3.0 decodes AVIF - it previously failed only on the
    allow-list). Skipped in environments without an AVIF decoder, where the
    upload fails earlier as 'not a valid decodable image'."""
    import glob
    import os

    # Tiny 1x1 AVIF: build from the plugin's own test corpus if present,
    # else synthesize via Pillow's AVIF encoder (present with the plugin).
    samples = glob.glob(os.path.join(os.path.dirname(__file__), "fixtures", "*.avif"))
    if samples:
        with open(samples[0], "rb") as fh:
            avif_bytes = fh.read()
    else:
        buffer = io.BytesIO()
        Image.new("RGB", (2, 2), "red").save(buffer, format="AVIF")
        avif_bytes = buffer.getvalue()
    assert validate_image_bytes(avif_bytes, max_bytes=1024 * 1024) == "image/avif"


def test_ensure_provider_safe_base64_passes_safe_formats_through():
    png = _png_bytes()
    png_b64 = base64.b64encode(png).decode("ascii")
    # Identity: same object back, no decode/copy for JPEG/PNG/WebP.
    assert ensure_provider_safe_base64(png_b64) is png_b64
    assert ensure_provider_safe_base64(f"data:image/png;base64,{png_b64}") == f"data:image/png;base64,{png_b64}"


def test_ensure_provider_safe_base64_normalizes_avif_data_url_to_jpeg():
    """An AVIF-typed data URL is re-encoded to JPEG regardless of size (avif
    is usually SMALLER than its JPEG re-encode, so the downscale helper's
    size-comparison ponytail cannot be reused here). The header drives the
    branch, so this runs even where Pillow cannot decode AVIF itself."""
    png = _png_bytes()
    avif_data_url = f"data:image/avif;base64,{base64.b64encode(png).decode('ascii')}"

    out = ensure_provider_safe_base64(avif_data_url)

    assert out.startswith("data:image/jpeg;base64,")
    payload = base64.b64decode(out.partition(",")[2])
    with Image.open(io.BytesIO(payload)) as img:
        assert img.format == "JPEG"


def test_to_data_url_normalizes_avif_for_provider_bound_images():
    """The OpenAI-compatible wire boundary (to_data_url) never emits an AVIF
    data URL: the payload it builds for Agnes/image APIs must be JPEG."""
    png = _png_bytes()
    avif_data_url = f"data:image/avif;base64,{base64.b64encode(png).decode('ascii')}"

    out = to_data_url(avif_data_url)

    assert out.startswith("data:image/jpeg;base64,")
    assert "image/avif" not in out
