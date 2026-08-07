"""Polyfactory factories for the app's Pydantic request models.

Use ``SomeFactory.build()`` to get a *valid* instance with randomized fields,
then override the field under test::

    payload = ItemCreateFactory.build().model_dump()
    payload["category"] = "not-a-category"  # the field the test targets

Factories that need constrained values (valid categories, strong passwords)
pin those fields so ``build()`` always produces an instance the app accepts.
"""

from __future__ import annotations

from polyfactory.factories.pydantic_factory import ModelFactory

from app.api.v1.auth import (
    ConfirmResetRequest,
    LoginRequest,
    RefreshTokenRequest,
    RegisterRequest,
    ResetPasswordRequest,
)
from app.models.admin import (
    AdminFeedbackUpdate,
    AdminPromoCodeCreate,
    AdminQuotaOverride,
    AdminUserPatch,
)
from app.models.blog import BlogPostCreate, BlogPostUpdate
from app.models.feedback import CreateFeedbackRequest
from app.models.item import ItemCreate, ItemUpdate
from app.models.outfit import OutfitCreate
from app.models.subscription import (
    CreateCheckoutRequest,
    RedeemPromoRequest,
    RedeemReferralRequest,
    RegisterIapTransactionRequest,
    ValidatePromoRequest,
    ValidateReferralRequest,
)
from app.models.user import (
    BodyProfileCreate,
    BodyProfileUpdate,
    UserPreferencesUpdate,
    UserSettingsUpdate,
    UserUpdate,
)


# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------


class LoginRequestFactory(ModelFactory[LoginRequest]):
    __model__ = LoginRequest


class RegisterRequestFactory(ModelFactory[RegisterRequest]):
    __model__ = RegisterRequest


class RefreshTokenRequestFactory(ModelFactory[RefreshTokenRequest]):
    __model__ = RefreshTokenRequest


class ResetPasswordRequestFactory(ModelFactory[ResetPasswordRequest]):
    __model__ = ResetPasswordRequest


class ConfirmResetRequestFactory(ModelFactory[ConfirmResetRequest]):
    __model__ = ConfirmResetRequest
    # The reset contract enforces full password strength; give the factory a
    # value that passes so build() is usable as a "valid request".
    new_password = "Str0ng!Pass1"


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------


class UserUpdateFactory(ModelFactory[UserUpdate]):
    __model__ = UserUpdate


class UserPreferencesUpdateFactory(ModelFactory[UserPreferencesUpdate]):
    __model__ = UserPreferencesUpdate


class UserSettingsUpdateFactory(ModelFactory[UserSettingsUpdate]):
    __model__ = UserSettingsUpdate


class BodyProfileCreateFactory(ModelFactory[BodyProfileCreate]):
    __model__ = BodyProfileCreate


class BodyProfileUpdateFactory(ModelFactory[BodyProfileUpdate]):
    __model__ = BodyProfileUpdate


# ---------------------------------------------------------------------------
# Wardrobe
# ---------------------------------------------------------------------------


class ItemCreateFactory(ModelFactory[ItemCreate]):
    __model__ = ItemCreate
    # ``validate_category`` only accepts VALID_CATEGORIES; pin one.
    category = "tops"
    condition = "clean"


class ItemUpdateFactory(ModelFactory[ItemUpdate]):
    __model__ = ItemUpdate


class OutfitCreateFactory(ModelFactory[OutfitCreate]):
    __model__ = OutfitCreate


# ---------------------------------------------------------------------------
# Subscription / IAP / referral / promo
# ---------------------------------------------------------------------------


class CreateCheckoutRequestFactory(ModelFactory[CreateCheckoutRequest]):
    __model__ = CreateCheckoutRequest


class RegisterIapTransactionRequestFactory(ModelFactory[RegisterIapTransactionRequest]):
    __model__ = RegisterIapTransactionRequest


class ValidateReferralRequestFactory(ModelFactory[ValidateReferralRequest]):
    __model__ = ValidateReferralRequest


class RedeemReferralRequestFactory(ModelFactory[RedeemReferralRequest]):
    __model__ = RedeemReferralRequest


class ValidatePromoRequestFactory(ModelFactory[ValidatePromoRequest]):
    __model__ = ValidatePromoRequest


class RedeemPromoRequestFactory(ModelFactory[RedeemPromoRequest]):
    __model__ = RedeemPromoRequest


# ---------------------------------------------------------------------------
# Feedback / blog / admin
# ---------------------------------------------------------------------------


class CreateFeedbackRequestFactory(ModelFactory[CreateFeedbackRequest]):
    __model__ = CreateFeedbackRequest


class BlogPostCreateFactory(ModelFactory[BlogPostCreate]):
    __model__ = BlogPostCreate


class BlogPostUpdateFactory(ModelFactory[BlogPostUpdate]):
    __model__ = BlogPostUpdate


class AdminUserPatchFactory(ModelFactory[AdminUserPatch]):
    __model__ = AdminUserPatch


class AdminPromoCodeCreateFactory(ModelFactory[AdminPromoCodeCreate]):
    __model__ = AdminPromoCodeCreate


class AdminFeedbackUpdateFactory(ModelFactory[AdminFeedbackUpdate]):
    __model__ = AdminFeedbackUpdate


class AdminQuotaOverrideFactory(ModelFactory[AdminQuotaOverride]):
    __model__ = AdminQuotaOverride
