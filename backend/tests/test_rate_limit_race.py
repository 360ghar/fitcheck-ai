"""
Regression test for the rate-limit check-then-act race.

Usage used to be incremented AFTER the protected operation completed, so N
concurrent requests could all read the same pre-increment count, pass the
check, and collectively exceed the limit. Usage must now be reserved before
the operation runs (matching auth_rate_limited_operation's already-correct
pattern), so the increment call happens before the caller's code inside the
`async with` block.
"""
from unittest.mock import patch

import pytest

from app.services.rate_limit import rate_limited_operation
from app.models.subscription import PlanType, UsageCheckResult


@pytest.mark.asyncio
async def test_usage_is_incremented_before_operation_runs():
    call_order = []

    async def fake_check_limit(**kwargs):
        return UsageCheckResult(
            allowed=True, current_count=0, limit=10, remaining=10, plan_type=PlanType.FREE
        )

    async def fake_increment_usage(**kwargs):
        call_order.append("increment")

    with patch(
        "app.services.rate_limit.SubscriptionService.check_limit", side_effect=fake_check_limit
    ), patch(
        "app.services.rate_limit.SubscriptionService.increment_usage", side_effect=fake_increment_usage
    ):
        async with rate_limited_operation(user_id="user-1", operation_type="generation", db=object()):
            # Simulates the protected operation (e.g. an AI provider call).
            call_order.append("operation")

    assert call_order == ["increment", "operation"]
