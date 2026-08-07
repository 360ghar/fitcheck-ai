"""DB row dict builders — seed :class:`tests.utils.fake_db.FakeDB` with rows
that mirror the real Supabase table shapes.

Every builder takes ``**overrides`` so a test can customize exactly the
columns it branches on while the rest stay realistic. Deterministic defaults
(UUIDs, timestamps) keep assertions stable.

Example::

    db = FakeDB(rows={"users": [user_row(email="ada@example.com")]})
"""

from __future__ import annotations

import uuid as _uuid
from typing import Any, Dict

NOW = "2026-01-01T00:00:00+00:00"


def uuid5(seed: str) -> str:
    """Deterministic UUID from a seed string (same seed → same uuid)."""
    return str(_uuid.uuid5(_uuid.NAMESPACE_URL, f"fitcheck-tests:{seed}"))


def user_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("user"),
        "email": "wardrobe@example.com",
        "full_name": "Ada Lovelace",
        "avatar_url": None,
        "gender": None,
        "birth_date": None,
        "birth_time": None,
        "birth_place": None,
        "is_active": True,
        "email_verified": True,
        "created_at": NOW,
        "updated_at": NOW,
        "last_login_at": None,
        "body_profile_id": None,
    }
    row.update(overrides)
    return row


def preferences_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "user_id": uuid5("user"),
        "favorite_colors": [],
        "preferred_styles": [],
        "liked_brands": [],
        "disliked_patterns": [],
        "preferred_occasions": [],
        "data_points_collected": 0,
        "last_updated": NOW,
    }
    row.update(overrides)
    return row


def settings_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "user_id": uuid5("user"),
        "language": "en",
        "measurement_units": "imperial",
        "notifications_enabled": True,
        "email_marketing": False,
        "dark_mode": False,
        "timezone": None,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def body_profile_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("body-profile"),
        "user_id": uuid5("user"),
        "name": "Everyday",
        "height_cm": 170.0,
        "weight_kg": 65.0,
        "body_shape": "hourglass",
        "skin_tone": "medium",
        "is_default": True,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def ai_settings_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "user_id": uuid5("user"),
        "preferred_ai_provider": "gemini",
        "fallback_provider": None,
        "auto_extract_on_upload": True,
        "encrypted_api_key": None,
        "encrypted_provider": None,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def item_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("item"),
        "user_id": uuid5("user"),
        "name": "Crew-neck tee",
        "category": "tops",
        "subcategory": None,
        "colors": [],
        "occasion_tags": [],
        "material": None,
        "brand": None,
        "image_url": None,
        "is_favorite": False,
        "wear_count": 0,
        "last_worn_at": None,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def outfit_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("outfit"),
        "user_id": uuid5("user"),
        "name": "Monday look",
        "description": None,
        "tags": [],
        "is_public": False,
        "is_favorite": False,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def subscription_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("subscription"),
        "user_id": uuid5("user"),
        "plan_type": "free",
        "status": "active",
        "current_period_start": NOW,
        "current_period_end": None,
        "cancel_at_period_end": False,
        "trial_end": None,
        "referral_credit_months": 0,
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row


def referral_code_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("referral-code"),
        "user_id": uuid5("user"),
        "code": "FIT-TEST01",
        "total_redemptions": 0,
        "created_at": NOW,
    }
    row.update(overrides)
    return row


def promo_code_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("promo-code"),
        "code": "SUMMER25",
        "description": None,
        "credit_months": 1,
        "max_redemptions": 100,
        "redemption_count": 0,
        "expires_at": None,
        "is_active": True,
        "created_at": NOW,
    }
    row.update(overrides)
    return row


def audit_event_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("audit-event"),
        "actor_user_id": uuid5("user"),
        "action": "user.updated",
        "entity_type": "user",
        "entity_id": uuid5("user"),
        "metadata": {},
        "created_at": NOW,
    }
    row.update(overrides)
    return row


def support_ticket_row(**overrides: Any) -> Dict[str, Any]:
    row = {
        "id": uuid5("ticket"),
        "user_id": uuid5("user"),
        "subject": "Help needed",
        "category": "billing",
        "status": "open",
        "message": "Please help",
        "created_at": NOW,
        "updated_at": NOW,
    }
    row.update(overrides)
    return row
