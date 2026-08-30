"""Request and response contracts for FitCheck Pro gift vouchers."""

from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Literal, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator, model_validator


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


class GiftPersonalization(BaseModel):
    from_name: str = Field(min_length=1, max_length=80)
    to_name: str = Field(min_length=1, max_length=80)
    message: Optional[str] = Field(default=None, max_length=240)

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

    @model_validator(mode="after")
    def require_change(self):
        if not self.model_fields_set:
            raise ValueError("At least one field is required")
        return self


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
