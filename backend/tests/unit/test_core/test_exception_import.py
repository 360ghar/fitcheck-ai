from starlette import status

from app.core.exceptions import ValidationError


def test_validation_error_uses_supported_unprocessable_status():
    assert ValidationError.status_code == status.HTTP_422_UNPROCESSABLE_CONTENT
