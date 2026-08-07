from datetime import datetime, timedelta, timezone, time as dt_time

import pytest
from pydantic import ValidationError

from app.models.user import UserUpdate


def test_user_update_allows_birth_time_without_birth_date() -> None:
    payload = UserUpdate(birth_time=dt_time(9, 15))

    assert payload.birth_time == dt_time(9, 15)
    assert payload.birth_date is None


def test_user_update_rejects_future_birth_date() -> None:
    future_date = datetime.now(timezone.utc).date() + timedelta(days=1)

    with pytest.raises(ValidationError):
        UserUpdate(birth_date=future_date)
