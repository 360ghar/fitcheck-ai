"""Custom assertion helpers for response contracts.

The API wraps every response in an envelope (see ``app/core/exceptions.py``
and the exception handlers in ``app/main.py``):

- success:  ``{"data": ..., "message": ...}``
- error:    ``{"error": ..., "code": ..., "details": ..., "correlation_id": ...}``
- 422:      ``{"error": "Invalid request data", "code": "VALIDATION_ERROR",
              "details": {"errors": [{"field", "message"}, ...]}}``
"""

from __future__ import annotations

from typing import Any, Dict, Iterable, List, Optional

from httpx import Response


def assert_error_envelope(
    response: Response,
    *,
    status_code: int,
    code: str,
) -> Dict[str, Any]:
    """Assert the standard error envelope and return its body."""
    assert response.status_code == status_code, (
        f"expected {status_code}, got {response.status_code}: {response.text[:500]}"
    )
    body = response.json()
    assert body["error"], "error message must be present"
    assert body["code"] == code, f"expected code {code!r}, got {body.get('code')!r}"
    assert isinstance(body.get("details"), dict), "details must be an object"
    assert "correlation_id" in body, "correlation_id must be present"
    return body


def assert_validation_error(
    response: Response,
    fields: Optional[Iterable[str]] = None,
) -> Dict[str, Any]:
    """Assert a 422 VALIDATION_ERROR envelope; optionally check which fields
    failed validation."""
    body = assert_error_envelope(response, status_code=422, code="VALIDATION_ERROR")
    errors: List[Dict[str, Any]] = body["details"].get("errors", [])
    assert errors, "validation details must list at least one error"
    if fields is not None:
        failed = {e.get("field") for e in errors}
        expected = set(fields)
        missing = expected - failed
        assert not missing, f"expected validation failures on {sorted(missing)}, got {sorted(failed)}"
    return body


def assert_success_envelope(response: Response, status_code: int = 200) -> Dict[str, Any]:
    """Assert a 2xx success envelope and return the body."""
    assert response.status_code == status_code, (
        f"expected {status_code}, got {response.status_code}: {response.text[:500]}"
    )
    body = response.json()
    assert "data" in body, "success envelope must carry a data key"
    return body
