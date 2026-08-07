"""
Regression test for get_current_user's DB lookup running via asyncio.to_thread
instead of blocking the event loop directly - the highest-traffic path in the
app (runs on nearly every authenticated request), stopping short of the full
sync-to-async Supabase client migration (a separately-planned, larger effort).
"""
from unittest.mock import Mock

import pytest

from app.api.v1.deps import get_current_user
from app.core.security import TokenData


@pytest.mark.asyncio
async def test_get_current_user_returns_existing_profile():
    db = Mock()
    result = Mock()
    result.data = {"id": "user-1", "email": "user@example.com", "full_name": "Test"}
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    token_data.email = "user@example.com"

    user = await get_current_user(db=db, token_data=token_data)

    assert user["id"] == "user-1"
    assert user["email"] == "user@example.com"


@pytest.mark.asyncio
async def test_get_current_user_fills_in_email_from_token_if_missing():
    db = Mock()
    result = Mock()
    result.data = {"id": "user-1", "email": None, "full_name": "Test"}
    db.table.return_value.select.return_value.eq.return_value.single.return_value.execute.return_value = result

    token_data = TokenData(sub="user-1")
    token_data.email = "from-token@example.com"

    user = await get_current_user(db=db, token_data=token_data)

    assert user["email"] == "from-token@example.com"
