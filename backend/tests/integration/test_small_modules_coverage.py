"""Residual coverage for the small thin modules.

Targets the remaining missed lines in app/api/v1/referral.py (routes),
app/services/feedback_service.py, app/services/outfit_service.py,
app/utils/crypto.py, app/services/rate_limit.py, and
app/api/v1/admin/ops.py (full-suite coverage report).
"""

from unittest.mock import AsyncMock, Mock

import pytest

from app.api.v1.admin import ops as ops_module
from app.api.v1.referral import (
    get_referral_code,
    get_referral_stats,
    redeem_referral_code,
    validate_referral_code,
)
from app.core.exceptions import OutfitNotFoundError, RateLimitError
from app.models.feedback import (
    CreateFeedbackRequest,
    DeviceInfo,
    TicketCategory,
    TicketStatus,
)
from app.services import outfit_service
from app.services.feedback_service import FeedbackService
from app.services.referral_service import ReferralService
from app.utils import crypto


def _db():
    return Mock()


# ---------------------------------------------------------------------------
# app/api/v1/referral.py — thin route wrappers
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_referral_routes_wrap_services(monkeypatch):
    class _CodeResult:
        def model_dump(self, mode):
            return {"code": "ABC123", "url": "https://x/r/ABC123"}

    class _StatsResult:
        def model_dump(self, mode):
            return {"code": "ABC123", "uses": 3, "referred": []}

    async def _code(user_id, full_name, db):
        return _CodeResult()

    async def _stats(user_id, db):
        return _StatsResult()

    async def _validate(code, db):
        return _CodeResult()

    async def _redeem(referred_user_id, code, db):
        return _CodeResult()

    monkeypatch.setattr(ReferralService, "get_or_create_referral_code", _code)
    monkeypatch.setattr(ReferralService, "get_referral_stats", _stats)
    monkeypatch.setattr(ReferralService, "validate_referral_code", _validate)
    monkeypatch.setattr(ReferralService, "redeem_referral", _redeem)

    user = {"id": "u1", "full_name": "Alice"}
    code = await get_referral_code(user=user, db=_db())
    assert code["data"]["code"] == "ABC123"

    stats = await get_referral_stats(user=user, db=_db())
    assert stats["data"]["uses"] == 3

    validated = await validate_referral_code(
        request=Mock(code="ABC123"), db=_db()
    )
    assert validated["data"]["url"].endswith("ABC123")

    redeemed = await redeem_referral_code(
        request=Mock(code="ABC123"), user=user, db=_db()
    )
    assert redeemed["data"]["code"] == "ABC123"


# ---------------------------------------------------------------------------
# app/services/feedback_service.py
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_create_ticket_service(monkeypatch):
    result = Mock()
    result.data = [
        {"id": "11111111-1111-1111-1111-111111111111", "category": "bug_report", "subject": "S", "status": "open",
         "created_at": "2026-01-01T00:00:00Z"}
    ]

    def _insert(payload):
        class _Chain:
            def execute(self):
                return result

        return _Chain()

    db = Mock()
    db.table.return_value.insert.side_effect = _insert

    ticket = await FeedbackService.create_ticket(
        request=CreateFeedbackRequest(
            category=TicketCategory.BUG_REPORT,
            subject="Broken",
            description="It broke completely",
            device_info=DeviceInfo(app_version="1.0", platform="ios"),
        ),
        user_id="u1",
        attachment_urls=["https://cdn/a.png"],
        db=db,
        attachment_storage_paths=["u1/feedback/a.png"],
    )
    assert str(ticket.id) == "11111111-1111-1111-1111-111111111111"
    assert ticket.status == TicketStatus.OPEN


@pytest.mark.asyncio
async def test_create_ticket_service_raises_when_no_row():
    db = Mock()
    db.table.return_value.insert.return_value.execute.return_value.data = []

    with pytest.raises(Exception, match="Failed to create support ticket"):
        await FeedbackService.create_ticket(
            request=CreateFeedbackRequest(
                category=TicketCategory.BUG_REPORT,
                subject="Broken",
                description="It broke completely",
            ),
            user_id=None,
            attachment_urls=[],
            db=db,
        )


@pytest.mark.asyncio
async def test_get_user_tickets_service():
    count_result = Mock()
    count_result.count = 4
    rows_result = Mock()
    rows_result.data = [
        {"id": "11111111-1111-1111-1111-111111111111", "category": TicketCategory.BUG_REPORT, "subject": "S",
         "status": TicketStatus.OPEN, "created_at": "2026-01-01T00:00:00Z"},
        {"id": "22222222-2222-2222-2222-222222222222", "category": TicketCategory.FEATURE_REQUEST, "subject": "F",
         "status": TicketStatus.CLOSED, "created_at": "2026-01-02T00:00:00Z"},
    ]

    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.execute.return_value = count_result
    # The paginated select chains off a fresh table() call.
    db.table.return_value.select.return_value.eq.return_value.order.return_value.range.return_value.execute.return_value = rows_result

    response = await FeedbackService.get_user_tickets("u1", db, limit=20, offset=0)
    assert response.total == 4
    assert len(response.tickets) == 2
    assert response.tickets[0].subject == "S"


# ---------------------------------------------------------------------------
# app/services/outfit_service.py
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_delete_outfit_not_found(monkeypatch):
    async def _load(*_a, **_k):
        return Mock(data=None)

    monkeypatch.setattr(outfit_service, "execute_with_reconnect", _load)
    with pytest.raises(OutfitNotFoundError):
        await outfit_service.delete_outfit(_db(), user_id="u1", outfit_id="o1")


@pytest.mark.asyncio
async def test_delete_outfit_resolve_failure_logs_and_continues(monkeypatch):
    async def _load(*_a, **_k):
        return Mock(data={"id": "o1"})

    monkeypatch.setattr(outfit_service, "execute_with_reconnect", _load)
    monkeypatch.setattr(
        outfit_service.StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(side_effect=RuntimeError("storage down")),
    )
    monkeypatch.setattr(
        outfit_service.StorageService,
        "delete_multiple_images",
        AsyncMock(),
    )

    # resolve failure is swallowed; the row delete must still complete.
    result = await outfit_service.delete_outfit(_db(), user_id="u1", outfit_id="o1")
    assert result is None  # delete_outfit returns None on success


@pytest.mark.asyncio
async def test_delete_outfit_image_delete_failure_logs(monkeypatch):
    async def _load(*_a, **_k):
        return Mock(data={"id": "o1"})

    monkeypatch.setattr(outfit_service, "execute_with_reconnect", _load)
    monkeypatch.setattr(
        outfit_service.StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(return_value={"storage_paths": ["u1/outfits/x.jpg"]}),
    )
    monkeypatch.setattr(
        outfit_service.StorageService,
        "delete_multiple_images",
        AsyncMock(side_effect=RuntimeError("delete failed")),
    )

    # Storage cleanup failure is logged, never raised.
    result = await outfit_service.delete_outfit(_db(), user_id="u1", outfit_id="o1")
    assert result is None


@pytest.mark.asyncio
async def test_delete_outfit_no_storage_paths_skips_cleanup(monkeypatch):
    async def _load(*_a, **_k):
        return Mock(data={"id": "o1"})

    monkeypatch.setattr(outfit_service, "execute_with_reconnect", _load)
    monkeypatch.setattr(
        outfit_service.StorageService,
        "resolve_owned_storage_paths",
        AsyncMock(return_value={"storage_paths": []}),
    )
    monkeypatch.setattr(
        outfit_service.StorageService,
        "delete_multiple_images",
        AsyncMock(),
    )

    await outfit_service.delete_outfit(_db(), user_id="u1", outfit_id="o1")
    outfit_service.StorageService.delete_multiple_images.assert_not_awaited()


# ---------------------------------------------------------------------------
# app/utils/crypto.py
# ---------------------------------------------------------------------------


def test_raw_key_bytes_hex_like_value_that_is_not_hex():
    # 64 chars, not hex -> ValueError caught -> treated as a passphrase.
    secret = "x" * 64
    assert crypto._raw_key_bytes(secret) == secret.encode("utf-8")


def test_legacy_derive_fernet_key_empty_secret_returns_none():
    assert crypto.legacy_derive_fernet_key("") is None


# ---------------------------------------------------------------------------
# app/services/rate_limit.py
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_rate_limited_operation_limit_message_variants(monkeypatch):
    from app.services import rate_limit as rate_limit_module
    from app.services.subscription_service import SubscriptionService

    class _Check:
        allowed = False
        plan_type = "free"
        limit = 10
        remaining = 2

    monkeypatch.setattr(
        SubscriptionService,
        "check_limit",
        AsyncMock(return_value=_Check()),
    )
    monkeypatch.setattr(SubscriptionService, "plan_display_name", lambda pt: "Free")
    monkeypatch.setattr(SubscriptionService, "can_upgrade", lambda pt: True)

    async def _use():
        async with rate_limit_module.rate_limited_operation(
            user_id="u1", operation_type="generation", db=_db(), count=2
        ):
            pass

    with pytest.raises(RateLimitError, match="Upgrade to Pro"):
        await _use()


# ---------------------------------------------------------------------------
# app/api/v1/admin/ops.py
# ---------------------------------------------------------------------------


def test_schema_readiness_handles_check_failure(monkeypatch):
    import app.main as main_module

    def _boom():
        raise RuntimeError("schema check crashed")

    monkeypatch.setattr(main_module, "_get_cached_schema_status", _boom)
    result = __import__("asyncio").run(ops_module._schema_readiness())
    assert result == {"schema_ready": False, "missing_tables": []}
