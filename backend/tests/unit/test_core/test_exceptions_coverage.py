"""Residual branch coverage for app.core.exceptions.

The sibling test_exception_import.py covers module importability; this file
exercises the error-class constructors and serialization branches that
routes/services don't always hit: default-message subclasses, detail
population, and the retryable AIServiceError.to_dict surface.
"""

from app.core.exceptions import (
    AIServiceError,
    CalendarEventNotFoundError,
    CollectionNotFoundError,
    DatabaseError,
    ImageNotFoundError,
    InvalidInputError,
    InvalidTokenError,
    ItemNotFoundError,
    NotFoundError,
    OutfitNotFoundError,
    PermissionDeniedError,
    SchemaNotInitializedError,
    SharedOutfitNotFoundError,
    TokenExpiredError,
    UserNotFoundError,
)


def test_default_message_subclasses():
    assert "expired" in TokenExpiredError().message.lower()
    assert "invalid" in InvalidTokenError().message.lower()
    assert "not found" in UserNotFoundError().message.lower()


def test_permission_denied_carries_resource_type_detail():
    err = PermissionDeniedError(resource_type="outfit")
    assert err.details["resource_type"] == "outfit"
    # Without a resource_type no details dict entry is added.
    assert PermissionDeniedError().details == {}


def test_invalid_input_error_carries_value_detail():
    err = InvalidInputError(field="price", message="bad", value=12)
    assert err.details == {"field": "price", "value": "12"}
    err2 = InvalidInputError(field="price", message="bad")
    assert err2.details == {"field": "price"}


def test_not_found_details_with_type_and_id():
    err = NotFoundError(resource_type="item", resource_id="abc")
    assert err.details == {"resource_type": "item", "resource_id": "abc"}
    assert NotFoundError().details == {}


def test_resource_not_found_subclasses_build_messages_and_details():
    for exc, resource_type in (
        (ItemNotFoundError("i1"), "item"),
        (OutfitNotFoundError("o1"), "outfit"),
        (ImageNotFoundError("im1"), "image"),
        (CollectionNotFoundError("c1"), "collection"),
        (CalendarEventNotFoundError("ev1"), "calendar_event"),
        (SharedOutfitNotFoundError("s1"), "shared_outfit"),
    ):
        assert exc.details["resource_id"] is not None
        assert exc.details["resource_type"] == resource_type
    assert ItemNotFoundError().message == "Item not found"


def test_ai_service_error_to_dict_surfaces_retry_metadata():
    err = AIServiceError(
        message="AI busy",
        retryable=True,
        error_kind="transient",
        retry_after_seconds=2.5,
        provider_status=429,
    )
    payload = err.to_dict()
    assert payload["retryable"] is True
    assert payload["error_kind"] == "transient"
    assert payload["retry_after_seconds"] == 2.5

    # Omitted fields stay out of the payload.
    plain = AIServiceError().to_dict()
    assert plain["retryable"] is False
    assert "error_kind" not in plain
    assert "retry_after_seconds" not in plain


def test_database_error_carries_operation_detail():
    err = DatabaseError(operation="insert")
    assert err.details["operation"] == "insert"
    assert DatabaseError().details == {}


def test_schema_not_initialized_error():
    err = SchemaNotInitializedError()
    assert err.error_code == "SCHEMA_NOT_INITIALIZED"
    assert "schema" in err.message.lower()
