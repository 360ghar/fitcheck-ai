from datetime import datetime, timedelta, timezone, time as dt_time

import pytest
from pydantic import ValidationError

from app.models.user import (
    UserPreferencesUpdate,
    UserResponse,
    UserSettingsUpdate,
    UserUpdate,
)


def test_user_update_allows_birth_time_without_birth_date() -> None:
    payload = UserUpdate(birth_time=dt_time(9, 15))

    assert payload.birth_time == dt_time(9, 15)
    assert payload.birth_date is None


def test_user_update_rejects_future_birth_date() -> None:
    future_date = datetime.now(timezone.utc).date() + timedelta(days=1)

    with pytest.raises(ValidationError):
        UserUpdate(birth_date=future_date)


# ---------------------------------------------------------------------------
# Column-width bounds (B3-06): VARCHAR(10/50/20/50)
# ---------------------------------------------------------------------------


def test_user_settings_language_and_timezone_max_length() -> None:
    with pytest.raises(ValidationError, match="at most 10 characters"):
        UserSettingsUpdate(language="e" * 11)
    with pytest.raises(ValidationError, match="at most 50 characters"):
        UserSettingsUpdate(timezone="x" * 51)


def test_user_preferences_color_temperature_and_style_personality_max_length() -> None:
    with pytest.raises(ValidationError, match="at most 20 characters"):
        UserPreferencesUpdate(color_temperature="w" * 21)
    with pytest.raises(ValidationError, match="at most 50 characters"):
        UserPreferencesUpdate(style_personality="s" * 51)


# ---------------------------------------------------------------------------
# Read-side leniency (B3-09): UserResponse must not run input validators
# ---------------------------------------------------------------------------


def test_user_response_tolerates_legacy_rows() -> None:
    """A legacy row with a non-email address or a future birth_date must
    still serialize — EmailStr and the future-check live on the input
    models only (same documented pattern as OutfitBase/OutfitResponse)."""
    future_date = datetime.now(timezone.utc).date() + timedelta(days=365)

    user = UserResponse(
        id="11111111-1111-1111-1111-111111111111",
        email="not-an-email",
        birth_date=future_date,
        created_at="2026-01-01T00:00:00",
    )

    assert user.email == "not-an-email"
    assert user.birth_date == future_date


def test_user_base_stays_strict_on_input_side() -> None:
    """The input base keeps EmailStr + the future birth_date check."""
    from app.models.user import UserBase

    with pytest.raises(ValidationError):
        UserBase(email="not-an-email")
    with pytest.raises(ValidationError, match="cannot be in the future"):
        UserBase(
            email="a@b.com",
            birth_date=datetime.now(timezone.utc).date() + timedelta(days=1),
        )
