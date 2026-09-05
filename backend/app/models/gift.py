"""Request and response contracts for FitCheck Pro gift vouchers."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any, Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator, model_validator

from app.core.exceptions import ValidationError


GiftDuration = Literal[1, 3, 12]


class GiftSource(str, Enum):
    PAID = "paid"
    COMPLIMENTARY = "complimentary"
    ADMIN = "admin"


class GiftStatus(str, Enum):
    PENDING = "pending"
    ISSUED = "issued"
    CLAIMED = "claimed"
    EXPIRED = "expired"
    VOIDED = "voided"
    REVOKED = "revoked"
    PAYMENT_FAILED = "payment_failed"
    PAYMENT_REVIEW = "payment_review"


class GiftOccasion(str, Enum):
    BIRTHDAY = "birthday"
    ANNIVERSARY = "anniversary"
    OTHER = "other"


# Authoritative wording for fixed greetings (rendered into voucher artwork).
# Keep in sync with giftOccasionGreeting in frontend/src/api/gifts.ts and
# flutter/lib/features/gifts/models/gift_models.dart.
_FIXED_OCCASION_GREETINGS: dict[GiftOccasion, str] = {
    GiftOccasion.BIRTHDAY: "Happy Birthday",
    GiftOccasion.ANNIVERSARY: "Happy Anniversary",
}


def resolve_occasion_greeting(
    occasion: GiftOccasion | str | None,
    custom_greeting: str | None,
) -> str | None:
    """Return the public card heading without inventing one for no occasion."""
    if occasion is None:
        return None
    try:
        normalized = GiftOccasion(occasion)
    except ValueError:
        return None
    if normalized == GiftOccasion.OTHER:
        return custom_greeting
    return _FIXED_OCCASION_GREETINGS[normalized]


def validate_occasion(
    occasion: GiftOccasion | str | None,
    greeting: str | None,
) -> None:
    """Keep custom wording exclusive to the explicit Other occasion."""
    if occasion is None:
        if greeting is not None:
            raise ValueError("An occasion greeting requires an occasion")
        return
    normalized = GiftOccasion(occasion)
    if normalized == GiftOccasion.OTHER:
        if greeting is None:
            raise ValueError("A greeting is required for the Other occasion")
        return
    if greeting is not None:
        raise ValueError("A custom greeting is only allowed for the Other occasion")


def _trim_optional_string(value: Any) -> Any:
    """Trim before Pydantic applies a field length constraint."""
    if value is None:
        return None
    if isinstance(value, str):
        return value.strip() or None
    return value


class GiftPersonalization(BaseModel):
    from_name: str = Field(min_length=1, max_length=80)
    to_name: str = Field(min_length=1, max_length=80)
    recipient_email: EmailStr
    message: Optional[str] = Field(default=None, max_length=240)
    occasion: Optional[GiftOccasion] = None
    occasion_greeting: Optional[str] = Field(default=None, max_length=80)

    @field_validator("from_name", "to_name")
    @classmethod
    def strip_required_name(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("Name cannot be blank")
        return value

    @field_validator("message")
    @classmethod
    def strip_message(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        value = value.strip()
        return value or None

    @field_validator("occasion_greeting", mode="before")
    @classmethod
    def strip_occasion_greeting(cls, value: Any) -> Any:
        return _trim_optional_string(value)

    @field_validator("recipient_email")
    @classmethod
    def normalize_recipient_email(cls, value: EmailStr) -> str:
        """Store one canonical address for private incoming-gift matching."""
        return str(value).strip().lower()

    @model_validator(mode="after")
    def validate_personalization_occasion(self):
        validate_occasion(self.occasion, self.occasion_greeting)
        return self


class ComplimentaryGiftCreate(GiftPersonalization):
    duration_months: GiftDuration
    client_request_id: str = Field(min_length=8, max_length=100)


class PaidGiftCheckoutCreate(GiftPersonalization):
    duration_months: GiftDuration
    client_request_id: str = Field(min_length=8, max_length=100)
    success_url: str = Field(default="/gifts?checkout=success&session_id={CHECKOUT_SESSION_ID}", max_length=500)
    cancel_url: str = Field(default="/gifts?checkout=cancelled", max_length=500)


class GiftCheckoutFulfill(BaseModel):
    session_id: str = Field(min_length=8, max_length=255)


class GiftUpdate(BaseModel):
    from_name: Optional[str] = Field(default=None, min_length=1, max_length=80)
    to_name: Optional[str] = Field(default=None, min_length=1, max_length=80)
    message: Optional[str] = Field(default=None, max_length=240)
    occasion: Optional[GiftOccasion] = None
    occasion_greeting: Optional[str] = Field(default=None, max_length=80)

    @field_validator("from_name", "to_name")
    @classmethod
    def strip_optional_name(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        value = value.strip()
        if not value:
            raise ValueError("Name cannot be blank")
        return value

    @field_validator("message")
    @classmethod
    def strip_optional_message(cls, value: Optional[str]) -> Optional[str]:
        if value is None:
            return None
        return value.strip() or None

    @field_validator("occasion_greeting", mode="before")
    @classmethod
    def strip_optional_occasion_greeting(cls, value: Any) -> Any:
        return _trim_optional_string(value)

    @model_validator(mode="after")
    def require_change(self):
        if not self.model_fields_set:
            raise ValueError("At least one field is required")
        if "occasion" in self.model_fields_set and "occasion_greeting" in self.model_fields_set:
            # The service resolves omitted companion fields from the stored
            # voucher before saving; only fully supplied pairs validate here.
            validate_occasion(self.occasion, self.occasion_greeting)
        return self


def presentation_payload(voucher: dict[str, Any], request: GiftUpdate) -> dict[str, Any]:
    """Resolve nullable occasion changes against the unclaimed voucher."""
    payload = request.model_dump(exclude_unset=True)
    if "occasion" not in payload and "occasion_greeting" not in payload:
        return payload

    requested_occasion = payload.get("occasion", voucher.get("occasion"))
    occasion = requested_occasion.value if isinstance(requested_occasion, GiftOccasion) else requested_occasion
    provided_greeting = payload.get("occasion_greeting") if "occasion_greeting" in payload else voucher.get("occasion_greeting")

    try:
        if occasion is None:
            if "occasion_greeting" in payload:
                validate_occasion(None, provided_greeting)
            greeting = None
        elif occasion in {GiftOccasion.BIRTHDAY.value, GiftOccasion.ANNIVERSARY.value}:
            if "occasion_greeting" in payload:
                validate_occasion(occasion, provided_greeting)
            greeting = None
        else:
            greeting = str(provided_greeting).strip() if provided_greeting is not None else None
            validate_occasion(occasion, greeting)
    except ValueError as exc:
        raise ValidationError(str(exc)) from exc

    payload["occasion"] = occasion
    payload["occasion_greeting"] = greeting
    return payload


class GiftClaimRequest(BaseModel):
    public_id: UUID
    secret: str = Field(min_length=16, max_length=160)


class GiftCatalogOption(BaseModel):
    duration_months: GiftDuration
    retail_value_cents: int
    currency: str = "USD"
    paid_available: bool


class GiftAllowance(BaseModel):
    duration_months: GiftDuration
    granted_count: int
    used_count: int
    remaining_count: int


class GiftVoucherResponse(BaseModel):
    id: UUID
    public_id: UUID
    source: Optional[GiftSource] = None
    duration_months: GiftDuration
    retail_value_cents: int
    currency: str
    from_name: str
    to_name: str
    message: Optional[str] = None
    occasion: Optional[GiftOccasion] = None
    occasion_greeting: Optional[str] = None
    status: GiftStatus
    payment_status: Optional[str] = None
    issued_at: Optional[datetime] = None
    expires_at: Optional[datetime] = None
    claimed_at: Optional[datetime] = None
    created_at: datetime
    artwork_version: int
    share_url: Optional[str] = None
    claim_code: Optional[str] = None
    portrait_url: Optional[str] = None
    og_image_url: str
    entitlement_status: Optional[str] = None
    entitlement_starts_at: Optional[datetime] = None
    entitlement_ends_at: Optional[datetime] = None

    model_config = ConfigDict(extra="allow")


class GiftListResponse(BaseModel):
    items: list[GiftVoucherResponse]
    total: int
    page: int
    page_size: int


class GiftDashboardSummary(BaseModel):
    """Private dashboard data for invitation sending and incoming claims."""

    allowances: list[GiftAllowance]
    incoming: list[GiftVoucherResponse]


class GiftClaimResponse(BaseModel):
    voucher: GiftVoucherResponse
    entitlement_status: Literal["active", "queued"]
    active_ends_at: Optional[datetime] = None
    queued_count: int = 0
    queued_months: int = 0


class AdminGiftCreate(GiftPersonalization):
    duration_months: GiftDuration
    expires_at: Optional[datetime] = None
    note: str = Field(min_length=3, max_length=500)

    @field_validator("expires_at")
    @classmethod
    def require_future_expiry(cls, value: Optional[datetime]) -> Optional[datetime]:
        if value is None:
            return None
        normalized = value if value.tzinfo else value.replace(tzinfo=timezone.utc)
        if normalized <= datetime.now(timezone.utc):
            raise ValueError("Gift expiry must be in the future")
        return normalized


class AdminGiftAssign(BaseModel):
    user_id: UUID
    reason: str = Field(min_length=3, max_length=500)


class AdminGiftAllowanceAdjust(BaseModel):
    duration_months: GiftDuration
    add_count: int = Field(ge=1, le=100)
    reason: str = Field(min_length=3, max_length=500)


class AdminGiftAction(BaseModel):
    reason: str = Field(min_length=3, max_length=500)
