"""Security, artwork, entitlement, and value-protection tests for gifts."""

from __future__ import annotations

import io
from datetime import timedelta
from pathlib import Path
from unittest.mock import AsyncMock, Mock, patch

import pytest
from PIL import Image

from app.core.config import settings
from app.core.exceptions import PermissionDeniedError, ServiceError, ValidationError
from app.models.gift import AdminGiftCreate, ComplimentaryGiftCreate, PaidGiftCheckoutCreate
from app.models.subscription import PlanType, SubscriptionResponse, SubscriptionStatus
from app.services.admin_gift_service import AdminGiftService
from app.services.gift_artwork_service import GiftArtworkService
from app.services.gift_service import GiftService
from app.utils.datetime_util import utcnow
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-4111-8111-111111111111"
OTHER_USER_ID = "22222222-2222-4222-8222-222222222222"
VOUCHER_ID = "33333333-3333-4333-8333-333333333333"
PUBLIC_ID = "44444444-4444-4444-8444-444444444444"


def voucher(**overrides):
    row = {
        "id": VOUCHER_ID,
        "public_id": PUBLIC_ID,
        "purchaser_user_id": USER_ID,
        "source": "complimentary",
        "duration_months": 3,
        "retail_value_cents": 6000,
        "currency": "USD",
        "from_name": "Alex Morgan",
        "to_name": "Taylor Reed",
        "message": "For every outfit still waiting to happen.",
        "status": "issued",
        "payment_status": "not_applicable",
        "token_version": 1,
        "artwork_version": 1,
        "issued_at": utcnow().isoformat(),
        "expires_at": (utcnow() + timedelta(days=180)).isoformat(),
        "claimed_at": None,
        "created_at": utcnow().isoformat(),
    }
    row.update(overrides)
    return row


def test_admin_gift_expiry_must_be_in_the_future():
    with pytest.raises(ValueError, match="expiry must be in the future"):
        AdminGiftCreate(
            duration_months=1,
            from_name="FitCheck",
            to_name="Taylor Reed",
            note="Support goodwill gift",
            expires_at=utcnow() - timedelta(seconds=1),
        )


def test_artwork_message_truncation_is_visible():
    lines = GiftArtworkService._message_lines("exclusive invitation " * 30)

    assert len(lines) == 4
    assert lines[-1].endswith("…")


@pytest.fixture(autouse=True)
def gift_secret(monkeypatch):
    monkeypatch.setattr(settings, "GIFT_TOKEN_SECRET", "test-gift-secret-with-enough-entropy")


def test_claim_credentials_are_stable_and_rotate_with_token_version():
    first = voucher()
    rotated = voucher(token_version=2)

    assert GiftService.claim_secret(first) == GiftService.claim_secret(first)
    assert GiftService.claim_code(first) == GiftService.claim_code(first)
    assert GiftService.claim_secret(first) != GiftService.claim_secret(rotated)
    assert GiftService.claim_code(first) != GiftService.claim_code(rotated)
    assert GiftService.credential_matches(first, GiftService.claim_secret(first))
    assert GiftService.credential_matches(first, GiftService.claim_code(first).lower())
    assert GiftService.credential_matches(first, GiftService.claim_code(first).replace("-", ""))
    assert not GiftService.credential_matches(first, GiftService.claim_secret(rotated))


def test_checkout_return_url_requires_the_configured_origin(monkeypatch):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://fitcheckaiapp.com")

    assert GiftService._absolute_frontend_url("/gifts?checkout=cancelled") == (
        "https://fitcheckaiapp.com/gifts?checkout=cancelled"
    )
    with pytest.raises(ValidationError, match="FitCheck web app"):
        GiftService._absolute_frontend_url("http://fitcheckaiapp.com/gifts")


def test_public_serializer_hides_source_payment_and_claim_credential():
    public = GiftService.serialize(voucher(), audience="public")

    assert public.source is None
    assert public.payment_status is None
    assert public.share_url is None
    assert public.claim_code is None
    assert public.portrait_url is None
    assert public.og_image_url.endswith("/artwork/og.png?v=1")


def test_recipient_serializer_hides_sender_only_fields_but_keeps_entitlement():
    recipient = GiftService.serialize(
        voucher(status="claimed", claimed_at=utcnow().isoformat()),
        audience="recipient",
        entitlement={
            "status": "active",
            "started_at": utcnow().isoformat(),
            "ends_at": (utcnow() + timedelta(days=30)).isoformat(),
        },
    )

    assert recipient.source is None
    assert recipient.payment_status is None
    assert recipient.share_url is None
    assert recipient.claim_code is None
    assert recipient.portrait_url is None
    assert recipient.claimed_at is not None
    assert recipient.entitlement_status == "active"


def test_admin_serializer_never_exposes_claim_credentials():
    admin = GiftService.serialize(voucher(), audience="admin")

    assert admin.source is not None
    assert admin.payment_status == "not_applicable"
    assert admin.share_url is None
    assert admin.claim_code is None
    assert admin.portrait_url is None


def test_gift_tables_are_not_directly_readable_by_browser_roles():
    migration = (
        Path(__file__).resolve().parents[3]
        / "db"
        / "supabase"
        / "migrations"
        / "056_gift_vouchers.sql"
    ).read_text(encoding="utf-8")

    for table in (
        "gift_vouchers",
        "gift_voucher_allowances",
        "gift_entitlement_grants",
    ):
        assert (
            f"REVOKE ALL ON TABLE public.{table} FROM PUBLIC, anon, authenticated;"
            in migration
        )
    assert "CREATE POLICY gift_vouchers_read_own" not in migration


@pytest.mark.parametrize(
    ("variant", "expected_size"),
    [("portrait", (1080, 1350)), ("og", (1200, 630))],
)
def test_artwork_is_deterministic_and_has_exact_dimensions(variant, expected_size):
    row = voucher()
    kwargs = (
        {
            "claim_url": GiftService._share_url(row, GiftService.claim_secret(row)),
            "claim_code": GiftService.claim_code(row),
        }
        if variant == "portrait"
        else {}
    )

    first = GiftArtworkService.render(row, variant=variant, **kwargs)
    second = GiftArtworkService.render(row, variant=variant, **kwargs)

    assert first == second
    with Image.open(io.BytesIO(first)) as image:
        assert image.size == expected_size
        assert image.format == "PNG"


def _base_subscription(plan_type: PlanType = PlanType.FREE) -> SubscriptionResponse:
    now = utcnow()
    return SubscriptionResponse(
        id="55555555-5555-4555-8555-555555555555",
        user_id=OTHER_USER_ID,
        plan_type=plan_type,
        status=SubscriptionStatus.ACTIVE,
        current_period_start=now,
        current_period_end=now + timedelta(days=30) if plan_type != PlanType.FREE else None,
        is_pro=plan_type != PlanType.FREE,
    )


@pytest.mark.asyncio
async def test_active_gift_overlays_free_account_as_backward_compatible_pro():
    active_end = utcnow() + timedelta(days=31)
    with patch.object(
        GiftService,
        "resolve_entitlements",
        new=AsyncMock(
            return_value={
                "active_grant_id": VOUCHER_ID,
                "active_ends_at": active_end.isoformat(),
                "queued_count": 2,
                "queued_months": 13,
            }
        ),
    ):
        result = await GiftService.overlay_subscription(OTHER_USER_ID, _base_subscription(), Mock())

    assert result.plan_type == PlanType.PRO_MONTHLY
    assert result.entitlement_source == "gift"
    assert result.active_gift_ends_at == active_end
    assert result.queued_gift_count == 2
    assert result.queued_gift_months == 13
    assert result.is_pro is True


@pytest.mark.asyncio
async def test_pro_account_keeps_billing_entitlement_when_gift_is_queued():
    base = _base_subscription(PlanType.PRO_YEARLY)
    with patch.object(
        GiftService,
        "resolve_entitlements",
        new=AsyncMock(
            return_value={
                "active_grant_id": None,
                "active_ends_at": None,
                "queued_count": 1,
                "queued_months": 3,
            }
        ),
    ):
        result = await GiftService.overlay_subscription(OTHER_USER_ID, base, Mock())

    assert result.plan_type == PlanType.PRO_YEARLY
    assert result.entitlement_source == "subscription"
    assert result.queued_gift_count == 1


@pytest.mark.asyncio
async def test_self_claim_is_rejected_before_database_mutation():
    row = voucher()
    db = Mock()
    result = Mock(data=row)
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = result

    with pytest.raises(ValidationError, match="cannot claim"):
        await GiftService.claim(
            {"id": USER_ID, "email_verified": True},
            __import__("uuid").UUID(PUBLIC_ID),
            GiftService.claim_secret(row),
            db,
        )

    db.rpc.assert_not_called()


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "existing",
    [
        voucher(source="paid", duration_months=1),
        voucher(duration_months=3),
        voucher(duration_months=1, to_name="Another recipient"),
    ],
)
async def test_complimentary_idempotency_key_rejects_a_different_request(
    existing,
    monkeypatch,
):
    monkeypatch.setattr(settings, "ENABLE_GIFT_VOUCHER_CREATION", True)
    db = Mock()
    db.rpc.return_value.execute.return_value = Mock(data=[existing])
    request = ComplimentaryGiftCreate(
        duration_months=1,
        from_name="Alex Morgan",
        to_name="Taylor Reed",
        message=None,
        client_request_id="request-123",
    )

    with pytest.raises(ValidationError, match="request key was already used"):
        await GiftService.create_complimentary(
            {"id": USER_ID, "email_verified": True},
            request,
            db,
        )


@pytest.mark.asyncio
async def test_concurrent_paid_idempotency_collision_revalidates_the_winning_request(
    monkeypatch,
):
    monkeypatch.setattr(settings, "ENABLE_GIFT_VOUCHER_CREATION", True)
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_gifts")
    monkeypatch.setattr(settings, "STRIPE_GIFT_PRO_1M_PRICE_ID", "price_gift_1m")
    request = PaidGiftCheckoutCreate(
        duration_months=1,
        from_name="Alex Morgan",
        to_name="Taylor Reed",
        message=None,
        client_request_id="request-paid-123",
    )
    db = Mock()
    db.table.return_value.insert.return_value.execute.side_effect = RuntimeError(
        "duplicate key"
    )
    winning_row = voucher(
        source="paid",
        duration_months=3,
        status="pending",
        payment_status="pending",
        stripe_checkout_session_id=None,
    )

    with (
        patch.object(
            GiftService,
            "_find_owner_request",
            new=AsyncMock(side_effect=[None, winning_row]),
        ),
        patch(
            "app.services.gift_service.stripe.checkout.Session.create",
            return_value={"id": "cs_should_not_exist", "url": "https://stripe.test"},
        ) as create_session,
    ):
        with pytest.raises(ValidationError, match="request key was already used"):
            await GiftService.create_paid_checkout(
                {"id": USER_ID, "email": "alex@example.test", "email_verified": True},
                request,
                db,
            )

    create_session.assert_not_called()


@pytest.mark.asyncio
async def test_verified_paid_checkout_recovers_after_an_earlier_failure(monkeypatch):
    monkeypatch.setattr(settings, "STRIPE_SECRET_KEY", "sk_test_gifts")
    monkeypatch.setattr(settings, "STRIPE_GIFT_PRO_1M_PRICE_ID", "price_gift_1m")
    row = voucher(
        source="paid",
        duration_months=1,
        retail_value_cents=2_000,
        expires_at=None,
        status="payment_failed",
        payment_status="failed",
        stripe_checkout_session_id="cs_gift_1",
        stripe_payment_intent_id=None,
    )
    db = FakeDB(rows={"gift_vouchers": [row]})
    session = {
        "id": "cs_gift_1",
        "mode": "payment",
        "payment_status": "paid",
        "metadata": {
            "purchase_kind": "gift_voucher",
            "voucher_id": VOUCHER_ID,
            "purchaser_user_id": USER_ID,
            "duration_months": "1",
        },
        "line_items": {
            "data": [{"price": {"id": "price_gift_1m"}, "quantity": 1}]
        },
        "amount_total": 2_000,
        "currency": "usd",
        "client_reference_id": VOUCHER_ID,
        "payment_intent": "pi_gift_1",
        "customer": "cus_gift_1",
    }

    with patch(
        "app.services.gift_service.stripe.checkout.Session.retrieve",
        return_value=session,
    ):
        result = await GiftService.fulfill_checkout("cs_gift_1", db)

    assert result.status.value == "issued"
    assert result.payment_status == "paid"
    assert db.rows["gift_vouchers"][0]["stripe_payment_intent_id"] == "pi_gift_1"


@pytest.mark.asyncio
async def test_partial_refund_does_not_revoke_paid_gift_value():
    row = voucher(
        source="paid",
        status="claimed",
        payment_status="paid",
        amount_paid_cents=6_000,
        amount_refunded_cents=0,
        stripe_payment_intent_id="pi_gift_partial",
    )
    grant = {"voucher_id": VOUCHER_ID, "status": "active"}
    db = FakeDB(
        rows={
            "gift_vouchers": [row],
            "gift_entitlement_grants": [grant],
        }
    )

    await GiftService.process_payment_event(
        "charge.refunded",
        {
            "payment_intent": "pi_gift_partial",
            "amount": 6_000,
            "amount_refunded": 1_000,
            "refunded": False,
        },
        db,
    )

    assert db.rows["gift_vouchers"][0]["status"] == "claimed"
    assert db.rows["gift_vouchers"][0]["payment_status"] == "partially_refunded"
    assert db.rows["gift_vouchers"][0]["amount_refunded_cents"] == 1_000
    assert db.rows["gift_entitlement_grants"][0]["status"] == "active"


@pytest.mark.asyncio
@pytest.mark.parametrize(
    "event_type",
    ["charge.refunded", "charge.dispute.created", "charge.dispute.closed"],
)
async def test_gift_payment_event_before_checkout_fulfillment_is_retryable(event_type):
    row = voucher(
        source="paid",
        status="pending",
        payment_status="pending",
        stripe_checkout_session_id="cs_gift_pending",
        stripe_payment_intent_id=None,
    )
    db = FakeDB(rows={"gift_vouchers": [row]})

    event = {
        "payment_intent": "pi_gift_pending",
        "metadata": {
            "purchase_kind": "gift_voucher",
            "voucher_id": VOUCHER_ID,
        },
    }
    if event_type.startswith("charge.dispute"):
        event.pop("metadata")
        event["charge"] = "ch_gift_pending"

    with patch(
        "app.services.gift_service.stripe.Charge.retrieve",
        return_value={
            "payment_intent": "pi_gift_pending",
            "metadata": {
                "purchase_kind": "gift_voucher",
                "voucher_id": VOUCHER_ID,
            },
        },
    ) as retrieve_charge:
        with pytest.raises(ServiceError, match="before checkout fulfillment"):
            await GiftService.process_payment_event(event_type, event, db)

    if event_type.startswith("charge.dispute"):
        retrieve_charge.assert_called_once_with("ch_gift_pending")
    else:
        retrieve_charge.assert_not_called()
    assert db.rows["gift_vouchers"][0]["status"] == "pending"
    assert db.rows["gift_vouchers"][0]["stripe_payment_intent_id"] is None


@pytest.mark.asyncio
async def test_full_refund_revokes_claimed_paid_gift_value():
    row = voucher(
        source="paid",
        status="claimed",
        payment_status="partially_refunded",
        amount_paid_cents=6_000,
        amount_refunded_cents=1_000,
        stripe_payment_intent_id="pi_gift_full",
    )
    grant = {"voucher_id": VOUCHER_ID, "status": "queued"}
    db = FakeDB(
        rows={
            "gift_vouchers": [row],
            "gift_entitlement_grants": [grant],
        }
    )

    await GiftService.process_payment_event(
        "charge.refunded",
        {
            "payment_intent": "pi_gift_full",
            "amount": 6_000,
            "amount_refunded": 6_000,
            "refunded": True,
        },
        db,
    )

    assert db.rows["gift_vouchers"][0]["status"] == "revoked"
    assert db.rows["gift_vouchers"][0]["payment_status"] == "refunded"
    assert db.rows["gift_entitlement_grants"][0]["status"] == "revoked"


@pytest.mark.asyncio
async def test_closed_inquiry_restores_partial_refund_payment_state():
    row = voucher(
        source="paid",
        status="issued",
        payment_status="review",
        amount_paid_cents=6_000,
        amount_refunded_cents=1_000,
        stripe_payment_intent_id="pi_gift_inquiry",
    )
    db = FakeDB(rows={"gift_vouchers": [row]})

    await GiftService.process_payment_event(
        "charge.dispute.closed",
        {
            "payment_intent": "pi_gift_inquiry",
            "status": "warning_closed",
        },
        db,
    )

    assert db.rows["gift_vouchers"][0]["payment_status"] == "partially_refunded"


@pytest.mark.asyncio
async def test_admin_summary_reports_net_paid_revenue_after_partial_refund():
    db = FakeDB(
        rows={
            "gift_vouchers": [
                voucher(
                    source="paid",
                    status="claimed",
                    payment_status="partially_refunded",
                    amount_paid_cents=6_000,
                    amount_refunded_cents=1_000,
                )
            ],
            "gift_entitlement_grants": [],
        }
    )

    result = await AdminGiftService.summary(db)

    assert result["paid_revenue_cents"] == 5_000


@pytest.mark.asyncio
async def test_admin_csv_neutralizes_spreadsheet_formulas():
    db = FakeDB(
        rows={
            "gift_vouchers": [
                voucher(
                    source="admin",
                    status="claimed",
                    from_name='=HYPERLINK("https://attacker.test")',
                )
            ]
        }
    )

    content = await AdminGiftService.export_csv(
        db,
        q=None,
        source=None,
        duration_months=None,
        status=None,
        created_from=None,
        created_to=None,
    )

    assert "'=HYPERLINK" in content.decode("utf-8")


@pytest.mark.asyncio
async def test_admin_csv_exports_rows_beyond_the_storage_page_limit():
    rows = [
        voucher(
            id=f"gift-{index:04d}",
            public_id=f"public-{index:04d}",
            created_at=(utcnow() - timedelta(seconds=index)).isoformat(),
        )
        for index in range(1_001)
    ]
    db = FakeDB(rows={"gift_vouchers": rows})

    content = await AdminGiftService.export_csv(
        db,
        q=None,
        source=None,
        duration_months=None,
        status=None,
        created_from=None,
        created_to=None,
    )

    exported_lines = content.decode("utf-8").splitlines()
    assert len(exported_lines) == 1_002
    assert "gift-0000" in exported_lines[1]
    assert "gift-1000" in exported_lines[-1]
    assert len([query for query in db.selects if query[0] == "gift_vouchers"]) == 2


@pytest.mark.asyncio
async def test_received_history_loads_entitlements_in_one_batch():
    received = [
        voucher(
            id=f"33333333-3333-4333-8333-33333333333{index}",
            public_id=f"44444444-4444-4444-8444-44444444444{index}",
            status="claimed",
            claimed_by_user_id=OTHER_USER_ID,
            claimed_at=utcnow().isoformat(),
        )
        for index in range(3)
    ]
    grants = [
        {
            "voucher_id": item["id"],
            "status": "queued",
            "started_at": None,
            "ends_at": None,
        }
        for item in received
    ]
    db = FakeDB(
        rows={
            "gift_vouchers": received,
            "gift_entitlement_grants": grants,
        }
    )

    result = await GiftService.list_for_user(
        OTHER_USER_ID,
        db,
        received=True,
        page=1,
        page_size=20,
    )

    entitlement_selects = [
        call for call in db.selects if call[0] == "gift_entitlement_grants"
    ]
    assert len(result.items) == 3
    assert len(entitlement_selects) == 1


@pytest.mark.asyncio
async def test_admin_cannot_manually_void_paid_value():
    with patch.object(
        AdminGiftService,
        "get",
        new=AsyncMock(
            return_value=GiftService.serialize(
                voucher(source="paid"), audience="admin"
            ).model_dump()
        ),
    ):
        with pytest.raises(PermissionDeniedError, match="Stripe refund"):
            await AdminGiftService.void_or_revoke(VOUCHER_ID, "manual attempt", Mock())
