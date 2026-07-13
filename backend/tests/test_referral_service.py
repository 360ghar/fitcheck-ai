"""
Regression test for ReferralService.validate_referral_code with a zero-row lookup.

postgrest-py's `.maybe_single().execute()` returns bare `None` (not an object
with `.data = None`) when the query matches no rows - this used to crash with
`AttributeError: 'NoneType' object has no attribute 'data'` for any invalid code.
"""
from unittest.mock import Mock

import pytest

from app.services.referral_service import ReferralService


@pytest.mark.asyncio
async def test_validate_referral_code_handles_zero_row_result():
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = None

    response = await ReferralService.validate_referral_code("doesnotexist", db)

    assert response.valid is False
    assert response.message == "Invalid referral code"
