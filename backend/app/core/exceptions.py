"""
Custom exception classes for FitCheck AI.

Provides standardized error handling with error codes, HTTP status codes,
and user-friendly messages for consistent API error responses.
"""

from typing import Any, Dict, Optional
from fastapi import status


class FitCheckException(Exception):
    """Base exception for all FitCheck errors.
    
    All custom exceptions should inherit from this class.
    """
    
    status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR
    error_code: str = "INTERNAL_ERROR"
    
    def __init__(
        self,
        message: str = "An unexpected error occurred",
        details: Optional[Dict[str, Any]] = None,
        error_code: Optional[str] = None,
    ):
        self.message = message
        self.details = details or {}
        if error_code:
            self.error_code = error_code
        super().__init__(self.message)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert exception to API response format."""
        response = {
            "error": self.message,
            "code": self.error_code,
            "details": self.details,
        }
        return response


# ============================================================================
# AUTHENTICATION ERRORS
# ============================================================================


class AuthenticationError(FitCheckException):
    """Raised when authentication fails."""
    
    status_code = status.HTTP_401_UNAUTHORIZED
    error_code = "AUTH_UNAUTHORIZED"
    
    def __init__(
        self,
        message: str = "Authentication required",
        details: Optional[Dict[str, Any]] = None,
        error_code: Optional[str] = None,
    ):
        super().__init__(message, details, error_code)


class TokenExpiredError(AuthenticationError):
    """Raised when an access token has expired."""
    
    error_code = "AUTH_TOKEN_EXPIRED"
    
    def __init__(self, message: str = "Access token has expired"):
        super().__init__(message)


class InvalidTokenError(AuthenticationError):
    """Raised when a token is invalid or malformed."""
    
    error_code = "AUTH_TOKEN_INVALID"
    
    def __init__(self, message: str = "Invalid or malformed token"):
        super().__init__(message)


class EmailAlreadyExistsError(FitCheckException):
    """Raised when trying to register with an existing email."""

    status_code = status.HTTP_409_CONFLICT
    error_code = "AUTH_EMAIL_EXISTS"

    def __init__(self, message: str = "Email already registered"):
        super().__init__(message)


class PermissionDeniedError(FitCheckException):
    """Raised when user lacks permission for an action."""

    status_code = status.HTTP_403_FORBIDDEN
    error_code = "PERMISSION_DENIED"

    def __init__(
        self,
        message: str = "You don't have permission to perform this action",
        resource_type: Optional[str] = None,
    ):
        details = {}
        if resource_type:
            details["resource_type"] = resource_type
        super().__init__(message, details)


# ============================================================================
# VALIDATION ERRORS
# ============================================================================


class ValidationError(FitCheckException):
    """Raised when request validation fails."""

    status_code = status.HTTP_422_UNPROCESSABLE_ENTITY
    error_code = "VALIDATION_ERROR"

    def __init__(
        self,
        message: str = "Invalid request data",
        details: Optional[Dict[str, Any]] = None,
    ):
        super().__init__(message, details)


class FileTooLargeError(ValidationError):
    """Raised when uploaded file exceeds size limit."""

    error_code = "FILE_TOO_LARGE"

    def __init__(self, max_size_mb: int = 10):
        super().__init__(
            f"File size exceeds {max_size_mb}MB limit",
            details={"max_size_mb": max_size_mb}
        )


class UnsupportedMediaTypeError(FitCheckException):
    """Raised when file type is not supported."""

    status_code = status.HTTP_415_UNSUPPORTED_MEDIA_TYPE
    error_code = "UNSUPPORTED_MEDIA_TYPE"

    def __init__(
        self,
        allowed_types: Optional[list] = None,
        message: str = "Unsupported file type"
    ):
        super().__init__(
            message,
            details={"allowed_types": allowed_types or ["image/jpeg", "image/png", "image/webp"]}
        )


class InvalidInputError(ValidationError):
    """Raised for invalid input that doesn't match expected format."""

    error_code = "INVALID_INPUT"

    def __init__(self, field: str, message: str, value: Any = None):
        details: Dict[str, Any] = {"field": field}
        if value is not None:
            details["value"] = str(value)
        super().__init__(message, details=details)


class SocialImportInvalidUrlError(ValidationError):
    """Raised when the provided social profile URL is invalid or unsupported."""

    error_code = "SOCIAL_IMPORT_INVALID_URL"

    def __init__(self, message: str = "Invalid or unsupported social profile URL"):
        super().__init__(message)


# ============================================================================
# NOT FOUND ERRORS
# ============================================================================


class NotFoundError(FitCheckException):
    """Base class for resource not found errors."""
    
    status_code = status.HTTP_404_NOT_FOUND
    error_code = "NOT_FOUND"
    
    def __init__(
        self,
        message: str = "Resource not found",
        resource_type: Optional[str] = None,
        resource_id: Optional[str] = None,
    ):
        details = {}
        if resource_type:
            details["resource_type"] = resource_type
        if resource_id:
            details["resource_id"] = resource_id
        super().__init__(message, details)


class ItemNotFoundError(NotFoundError):
    """Raised when a wardrobe item is not found."""
    
    error_code = "ITEM_NOT_FOUND"
    
    def __init__(self, item_id: Optional[str] = None):
        message = "Item not found"
        super().__init__(message, "item", item_id)


class OutfitNotFoundError(NotFoundError):
    """Raised when an outfit is not found."""
    
    error_code = "OUTFIT_NOT_FOUND"
    
    def __init__(self, outfit_id: Optional[str] = None):
        message = "Outfit not found"
        super().__init__(message, "outfit", outfit_id)


class UserNotFoundError(NotFoundError):
    """Raised when a user is not found."""
    
    error_code = "USER_NOT_FOUND"
    
    def __init__(self, user_id: Optional[str] = None):
        message = "User not found"
        super().__init__(message, "user", user_id)


class ImageNotFoundError(NotFoundError):
    """Raised when an image is not found."""
    
    error_code = "IMAGE_NOT_FOUND"
    
    def __init__(self, image_id: Optional[str] = None):
        message = "Image not found"
        super().__init__(message, "image", image_id)


class CollectionNotFoundError(NotFoundError):
    """Raised when a collection is not found."""

    error_code = "COLLECTION_NOT_FOUND"

    def __init__(self, collection_id: Optional[str] = None):
        message = "Collection not found"
        super().__init__(message, "collection", collection_id)


class CalendarEventNotFoundError(NotFoundError):
    """Raised when a calendar event is not found."""

    error_code = "CALENDAR_EVENT_NOT_FOUND"

    def __init__(self, event_id: Optional[str] = None):
        message = "Calendar event not found"
        super().__init__(message, "calendar_event", event_id)


class SharedOutfitNotFoundError(NotFoundError):
    """Raised when a shared outfit is not found."""

    error_code = "SHARED_OUTFIT_NOT_FOUND"

    def __init__(self, share_id: Optional[str] = None):
        message = "Shared outfit not found"
        super().__init__(message, "shared_outfit", share_id)


class BodyProfileNotFoundError(NotFoundError):
    """Raised when a body profile is not found."""

    error_code = "BODY_PROFILE_NOT_FOUND"

    def __init__(self, profile_id: Optional[str] = None):
        message = "Body profile not found"
        super().__init__(message, "body_profile", profile_id)


class SocialImportJobNotFoundError(NotFoundError):
    """Raised when a social import job is not found."""

    error_code = "SOCIAL_IMPORT_JOB_NOT_FOUND"

    def __init__(self, job_id: Optional[str] = None):
        super().__init__("Social import job not found", "social_import_job", job_id)


# ============================================================================
# SERVICE ERRORS
# ============================================================================


class ServiceError(FitCheckException):
    """Raised when an external service fails."""
    
    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    error_code = "SERVICE_UNAVAILABLE"
    
    def __init__(
        self,
        message: str = "Service temporarily unavailable",
        service_name: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
    ):
        _details = details or {}
        if service_name:
            _details["service"] = service_name
        super().__init__(message, _details)


class AIServiceError(ServiceError):
    """Raised when AI service (Gemini) fails."""
    
    error_code = "AI_SERVICE_ERROR"
    
    def __init__(self, message: str = "AI service unavailable"):
        super().__init__(message, "ai")


class WeatherServiceError(ServiceError):
    """Raised when weather service fails."""
    
    error_code = "WEATHER_SERVICE_ERROR"
    
    def __init__(self, message: str = "Weather service unavailable"):
        super().__init__(message, "weather")


class StorageServiceError(ServiceError):
    """Raised when storage service fails."""
    
    error_code = "STORAGE_SERVICE_ERROR"
    
    def __init__(self, message: str = "Storage service unavailable"):
        super().__init__(message, "storage")


class SocialImportError(FitCheckException):
    """Base exception for social import errors."""

    status_code = status.HTTP_400_BAD_REQUEST
    error_code = "SOCIAL_IMPORT_ERROR"

    def __init__(
        self,
        message: str = "Social import failed",
        details: Optional[Dict[str, Any]] = None,
        error_code: Optional[str] = None,
    ):
        super().__init__(message=message, details=details, error_code=error_code)


class SocialImportAuthRequiredError(SocialImportError):
    """Raised when authentication is required to access a private profile."""

    status_code = status.HTTP_401_UNAUTHORIZED
    error_code = "SOCIAL_IMPORT_AUTH_REQUIRED"

    def __init__(self, message: str = "Profile requires login to continue import"):
        super().__init__(message=message)


class SocialImportLoginFailedError(SocialImportError):
    """Raised when social login credentials are rejected."""

    status_code = status.HTTP_401_UNAUTHORIZED
    error_code = "SOCIAL_IMPORT_LOGIN_FAILED"

    def __init__(self, message: str = "Failed to authenticate social profile access"):
        super().__init__(message=message)


class SocialImportMFARequiredError(SocialImportError):
    """Raised when scraper login requires MFA verification."""

    status_code = status.HTTP_409_CONFLICT
    error_code = "SOCIAL_IMPORT_MFA_REQUIRED"

    def __init__(self, message: str = "Additional verification is required"):
        super().__init__(message=message)


class SocialImportEncryptionConfigError(SocialImportError):
    """Raised when secure auth session encryption is not configured."""

    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    error_code = "SOCIAL_IMPORT_ENCRYPTION_CONFIG_ERROR"

    def __init__(self, message: str = "Secure social import auth is not configured"):
        super().__init__(message=message)


# ============================================================================
# DATABASE ERRORS
# ============================================================================


class DatabaseError(FitCheckException):
    """Raised when a database operation fails."""
    
    status_code = status.HTTP_500_INTERNAL_SERVER_ERROR
    error_code = "DATABASE_ERROR"
    
    def __init__(
        self,
        message: str = "Database operation failed",
        operation: Optional[str] = None,
    ):
        details = {}
        if operation:
            details["operation"] = operation
        super().__init__(message, details)


class SchemaNotInitializedError(DatabaseError):
    """Raised when database schema is not initialized."""
    
    status_code = status.HTTP_503_SERVICE_UNAVAILABLE
    error_code = "SCHEMA_NOT_INITIALIZED"
    
    def __init__(self):
        super().__init__(
            "Database schema not initialized. Run migrations in Supabase SQL Editor.",
            "schema_check",
        )


# ============================================================================
# RATE LIMIT ERRORS
# ============================================================================


class RateLimitError(FitCheckException):
    """Raised when rate limit is exceeded."""
    
    status_code = status.HTTP_429_TOO_MANY_REQUESTS
    error_code = "RATE_LIMIT_EXCEEDED"
    
    def __init__(
        self,
        message: str = "Too many requests. Please try again later.",
        retry_after: Optional[int] = None,
    ):
        details = {}
        if retry_after:
            details["retry_after_seconds"] = retry_after
        super().__init__(message, details)
