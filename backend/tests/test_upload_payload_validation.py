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
from app.utils.image_processing import decode_and_validate_base64_image, validate_image_bytes


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
