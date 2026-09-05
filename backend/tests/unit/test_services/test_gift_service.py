"""Security, artwork, entitlement, and value-protection tests for gifts."""

from __future__ import annotations

import io
from datetime import timedelta
from pathlib import Path
from unittest.mock import AsyncMock, Mock, patch

import pytest
from PIL import Image
from pydantic import ValidationError as PydanticValidationError

from app.core.config import settings
from app.core.exceptions import PermissionDeniedError, ServiceError, ValidationError
from app.models.gift import (
    AdminGiftCreate,
    ComplimentaryGiftCreate,
    GiftOccasion,
    GiftUpdate,
    PaidGiftCheckoutCreate,
    presentation_payload,
    resolve_occasion_greeting,
)
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
            recipient_email="taylor@example.com",
            note="Support goodwill gift",
            expires_at=utcnow() - timedelta(seconds=1),
        )


def test_artwork_message_truncation_is_visible():
    lines = GiftArtworkService._message_lines("exclusive invitation " * 30)

    assert len(lines) == 4
    assert lines[-1].endswith("…")


def test_artwork_uses_a_new_optional_occasion_layout_namespace():
    assert GiftArtworkService.storage_key(voucher(), "portrait").endswith("/v1/layout3/portrait.png")


def test_gifts_default_to_no_occasion_or_greeting():
    request = ComplimentaryGiftCreate(
        duration_months=1,
        from_name="Alex Morgan",
        to_name="Taylor Reed",
        recipient_email="taylor@example.com",
        client_request_id="request-no-occasion",
    )

    assert request.occasion is None
    assert request.occasion_greeting is None
    assert resolve_occasion_greeting(request.occasion, request.occasion_greeting) is None


@pytest.mark.parametrize(
    ("occasion", "greeting", "match"),
    [
        (None, "Hello", "requires an occasion"),
        (GiftOccasion.BIRTHDAY, "Happy birthday Taylor", "only allowed for the Other"),
        (GiftOccasion.OTHER, None, "required for the Other"),
    ],
)
def test_gift_occasion_validation_rejects_invalid_combinations(occasion, greeting, match):
    with pytest.raises(PydanticValidationError, match=match):
        ComplimentaryGiftCreate(
            duration_months=1,
            from_name="Alex Morgan",
            to_name="Taylor Reed",
            recipient_email="taylor@example.com",
            client_request_id="request-invalid-occasion",
            occasion=occasion,
            occasion_greeting=greeting,
        )


def test_fixed_and_other_occasion_greetings_are_resolved_truthfully():
    assert resolve_occasion_greeting(GiftOccasion.BIRTHDAY, None) == "Happy Birthday"
    assert resolve_occasion_greeting(GiftOccasion.ANNIVERSARY, None) == "Happy Anniversary"
    assert resolve_occasion_greeting(GiftOccasion.OTHER, "Happy Diwali!") == "Happy Diwali!"


def test_other_occasion_greeting_is_trimmed_before_length_validation():
    padded_greeting = f"{'x' * 80} "
    create = ComplimentaryGiftCreate(
        duration_months=1,
        from_name="Alex Morgan",
        to_name="Taylor Reed",
        recipient_email="taylor@example.com",
        client_request_id="request-trimmed-occasion",
        occasion=GiftOccasion.OTHER,
        occasion_greeting=padded_greeting,
    )
    update = GiftUpdate(
        occasion=GiftOccasion.OTHER,
        occasion_greeting=padded_greeting,
    )

    assert create.occasion_greeting == "x" * 80
    assert update.occasion_greeting == "x" * 80


def test_unclaimed_presentation_updates_can_set_and_clear_an_occasion():
    birthday = presentation_payload(
        voucher(occasion="other", occasion_greeting="Congratulations!"),
        GiftUpdate(occasion=GiftOccasion.BIRTHDAY),
    )
    cleared = presentation_payload(
        voucher(occasion="other", occasion_greeting="Congratulations!"),
        GiftUpdate(occasion=None, occasion_greeting=None),
    )

    assert birthday["occasion"] == "birthday"
    assert birthday["occasion_greeting"] is None
    assert cleared["occasion"] is None
    assert cleared["occasion_greeting"] is None


def test_presentation_update_rejects_an_orphaned_other_greeting():
    with pytest.raises(ValidationError, match="requires an occasion"):
        presentation_payload(voucher(), GiftUpdate(occasion_greeting="Congratulations!"))


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


def test_claim_credentials_reject_non_ascii_input_without_an_error():
    assert not GiftService.credential_matches(voucher(), "not-a-valid-credential-é")


def test_checkout_return_url_requires_the_configured_origin(monkeypatch):
    monkeypatch.setattr(settings, "FRONTEND_URL", "https://fitcheckaiapp.com")

    assert GiftService._absolute_frontend_url("/gifts?checkout=cancelled") == (
        "https://fitcheckaiapp.com/gifts?checkout=cancelled"
    )
    with pytest.raises(ValidationError, match="FitCheck web app"):
        GiftService._absolute_frontend_url("http://fitcheckaiapp.com/gifts")


def test_public_serializer_hides_source_payment_and_claim_credential():
    public = GiftService.serialize(
        voucher(recipient_email="taylor@example.com"),
        audience="public",
    )

    assert public.source is None
    assert public.payment_status is None
    assert public.share_url is None
    assert public.claim_code is None
    assert public.portrait_url is None
    assert public.og_image_url.endswith("/artwork/og.png?v=1&layout=3")
    assert "recipient_email" not in public.model_dump(exclude_none=True)


def test_public_serializer_exposes_an_optional_occasion_without_private_matching_data():
    public = GiftService.serialize(
        voucher(occasion="other", occasion_greeting="Happy Diwali!", recipient_email="taylor@example.com"),
        audience="public",
    )

    assert public.occasion == GiftOccasion.OTHER
    assert public.occasion_greeting == "Happy Diwali!"
    assert "recipient_email" not in public.model_dump(exclude_none=True)


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


def test_new_gift_recipient_email_is_normalized():
    request = ComplimentaryGiftCreate(
        duration_months=1,
        from_name="Alex Morgan",
        to_name="Taylor Reed",
        recipient_email="Taylor@Example.com",
        client_request_id="request-email-123",
    )

    assert request.recipient_email == "taylor@example.com"


def test_named_recipient_matching_supports_unicode_email_addresses():
    GiftService._require_recipient_match(
        {"email": "tést@example.com"},
        voucher(recipient_email="tést@example.com"),
    )


def test_gift_tables_are_not_directly_readable_by_browser_roles():
    migration = (
        Path(__file__).resolve().parents[3] / "db" / "supabase" / "migrations" / "056_gift_vouchers.sql"
    ).read_text(encoding="utf-8")

    for table in (
        "gift_vouchers",
        "gift_voucher_allowances",
        "gift_entitlement_grants",
    ):
        assert f"REVOKE ALL ON TABLE public.{table} FROM PUBLIC, anon, authenticated;" in migration
    assert "CREATE POLICY gift_vouchers_read_own" not in migration


def test_atomic_admin_gift_revoke_migration_keeps_voucher_and_grant_guards():
    """Static SQL contract for the hosted-Supabase-only revoke transaction."""
    migration = (
        Path(__file__).resolve().parents[3] / "db" / "supabase" / "migrations" / "059_atomic_admin_gift_revoke.sql"
    ).read_text(encoding="utf-8")

    assert "BEGIN;" in migration and "COMMIT;" in migration
    assert "IF p_expected_status NOT IN ('issued', 'claimed') THEN" in migration

    voucher_update = migration.split("UPDATE public.gift_vouchers", 1)[1].split("RETURNING * INTO v_voucher", 1)[0]
    assert "source <> 'paid'" in voucher_update
    assert "status = p_expected_status" in voucher_update

    grant_update_index = migration.index("UPDATE public.gift_entitlement_grants")
    assert migration.index("IF NOT FOUND THEN") < grant_update_index
    grant_update = migration[grant_update_index:]
    assert "IF p_expected_status = 'claimed' THEN" in migration[:grant_update_index]
    assert "WHERE voucher_id = p_voucher_id" in grant_update
    assert "status IN ('queued', 'active')" in grant_update


def test_recipient_matching_migration_keeps_legacy_links_and_secures_new_claims():
    migration = (
        Path(__file__).resolve().parents[3]
        / "db"
        / "supabase"
        / "migrations"
        / "061_gift_voucher_recipient_matching.sql"
    ).read_text(encoding="utf-8")

    assert "recipient_email IS NULL" in migration
    assert "gift_vouchers_incoming_recipient_idx" in migration
    assert "DROP CONSTRAINT IF EXISTS gift_vouchers_recipient_email_normalized" in migration
    assert "lower(btrim(email)) = v_voucher.recipient_email" in migration
    assert "issue_complimentary_gift_for_recipient" in migration
    assert "CREATE TRIGGER gift_vouchers_require_recipient_email" in migration
    assert "FOR UPDATE" in migration
    assert "v_voucher.status <> 'issued'" in migration
    assert "INSERT INTO public.gift_entitlement_grants" in migration


def test_optional_occasion_migration_keeps_legacy_gifts_blank_and_replaces_the_rpc():
    migration = (
        Path(__file__).resolve().parents[3]
        / "db"
        / "supabase"
        / "migrations"
        / "062_gift_voucher_occasions.sql"
    ).read_text(encoding="utf-8")

    assert "ADD COLUMN IF NOT EXISTS occasion VARCHAR(20)" in migration
    assert "ADD COLUMN IF NOT EXISTS occasion_greeting VARCHAR(80)" in migration
    assert "occasion IS NULL AND occasion_greeting IS NULL" in migration
    assert "DROP FUNCTION IF EXISTS public.issue_complimentary_gift_for_recipient" in migration
    assert "p_occasion_greeting VARCHAR" in migration
    assert "GRANT EXECUTE ON FUNCTION public.issue_complimentary_gift_for_recipient" in migration


@pytest.mark.asyncio
async def test_dashboard_summary_selects_only_email_matched_claimable_gifts():
    now = utcnow()
    incoming = voucher(
        id="33333333-3333-4333-8333-333333333334",
        public_id="44444444-4444-4444-8444-444444444445",
        purchaser_user_id=USER_ID,
        recipient_email="taylor@example.com",
        created_at=now.isoformat(),
    )
    own_gift = voucher(
        id="33333333-3333-4333-8333-333333333335",
        public_id="44444444-4444-4444-8444-444444444446",
        purchaser_user_id=OTHER_USER_ID,
        recipient_email="taylor@example.com",
    )
    other_recipient = voucher(
        id="33333333-3333-4333-8333-333333333336",
        public_id="44444444-4444-4444-8444-444444444447",
        purchaser_user_id=USER_ID,
        recipient_email="another@example.com",
    )
    expired = voucher(
        id="33333333-3333-4333-8333-333333333337",
        public_id="44444444-4444-4444-8444-444444444448",
        purchaser_user_id=USER_ID,
        recipient_email="taylor@example.com",
        expires_at=(now - timedelta(seconds=1)).isoformat(),
    )
    db = FakeDB(
        rows={
            "gift_vouchers": [incoming, own_gift, other_recipient, expired],
        },
        rpc_results={
            "initialize_gift_allowances": [
                {
                    "duration_months": 1,
                    "granted_count": 2,
                    "used_count": 1,
                }
            ],
        },
    )

    summary = await GiftService.get_dashboard_summary(
        {
            "id": OTHER_USER_ID,
            "email": "Taylor@Example.com",
            "email_verified": True,
        },
        db,
    )

    assert summary.allowances[0].remaining_count == 1
    assert [str(item.id) for item in summary.incoming] == [incoming["id"]]
    assert "recipient_email" not in summary.incoming[0].model_dump()
    assert (
        "gift_vouchers",
        "eq",
        "recipient_email",
        "taylor@example.com",
    ) in db.filters


@pytest.mark.asyncio
async def test_dashboard_summary_filters_expired_gifts_before_the_result_limit():
    now = utcnow()
    expired = [
        voucher(
            id=f"33333333-3333-4333-8333-{index:012d}",
            public_id=f"44444444-4444-4444-8444-{index:012d}",
            purchaser_user_id=USER_ID,
            recipient_email="taylor@example.com",
            expires_at=(now - timedelta(days=1)).isoformat(),
            created_at=(now + timedelta(seconds=index)).isoformat(),
        )
        for index in range(1, 51)
    ]
    claimable = voucher(
        id="33333333-3333-4333-8333-999999999999",
        public_id="44444444-4444-4444-8444-999999999999",
        purchaser_user_id=USER_ID,
        recipient_email="taylor@example.com",
        expires_at=None,
        created_at=now.isoformat(),
    )
    db = FakeDB(
        rows={"gift_vouchers": [*expired, claimable]},
        rpc_results={
            "initialize_gift_allowances": [{"duration_months": 1, "granted_count": 3, "used_count": 3}],
        },
    )

    summary = await GiftService.get_dashboard_summary(
        {"id": OTHER_USER_ID, "email": "taylor@example.com", "email_verified": True},
        db,
    )

    assert [str(item.id) for item in summary.incoming] == [claimable["id"]]


@pytest.mark.asyncio
async def test_dashboard_summary_does_not_truncate_claimable_incoming_gifts():
    now = utcnow()
    incoming = [
        voucher(
            id=f"33333333-3333-4333-8333-{index:012d}",
            public_id=f"44444444-4444-4444-8444-{index:012d}",
            purchaser_user_id=USER_ID,
            recipient_email="taylor@example.com",
            expires_at=(now + timedelta(days=30)).isoformat(),
            created_at=(now + timedelta(seconds=index)).isoformat(),
        )
        for index in range(1, 52)
    ]
    db = FakeDB(
        rows={"gift_vouchers": incoming},
        rpc_results={
            "initialize_gift_allowances": [{"duration_months": 1, "granted_count": 3, "used_count": 3}],
        },
    )

    summary = await GiftService.get_dashboard_summary(
        {"id": OTHER_USER_ID, "email": "taylor@example.com", "email_verified": True},
        db,
    )

    assert len(summary.incoming) == 51


@pytest.mark.asyncio
async def test_dashboard_summary_includes_a_claimable_gift_after_the_sender_is_deleted():
    row = voucher(recipient_email="taylor@example.com", purchaser_user_id=None)
    db = FakeDB(
        rows={"gift_vouchers": [row]},
        rpc_results={
            "initialize_gift_allowances": [{"duration_months": 1, "granted_count": 3, "used_count": 3}],
        },
    )

    summary = await GiftService.get_dashboard_summary(
        {"id": OTHER_USER_ID, "email": "taylor@example.com", "email_verified": True},
        db,
    )

    assert [str(item.id) for item in summary.incoming] == [row["id"]]


@pytest.mark.asyncio
async def test_assigned_claim_rejects_a_different_verified_email_before_database_mutation():
    row = voucher(recipient_email="taylor@example.com")
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data=row
    )

    with pytest.raises(ValidationError, match="reserved for another"):
        await GiftService.claim_assigned(
            {"id": OTHER_USER_ID, "email": "other@example.com", "email_verified": True},
            __import__("uuid").UUID(VOUCHER_ID),
            db,
        )

    db.rpc.assert_not_called()


@pytest.mark.asyncio
async def test_admin_issue_persists_the_normalized_recipient_email(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_GIFT_VOUCHER_CREATION", True)
    db = FakeDB(rows={"gift_vouchers": []})

    result = await AdminGiftService.create(
        USER_ID,
        AdminGiftCreate(
            duration_months=1,
            from_name="FitCheck",
            to_name="Taylor Reed",
            recipient_email="Taylor@Example.com",
            note="Support goodwill gift",
        ),
        db,
    )

    assert db.rows["gift_vouchers"][0]["recipient_email"] == "taylor@example.com"
    assert result["recipient_email"] == "taylor@example.com"


@pytest.mark.parametrize(
    ("variant", "expected_size"),
    [("portrait", (1080, 1350)), ("og", (1200, 630))],
)
def test_artwork_is_deterministic_and_has_exact_dimensions(variant, expected_size):
    row = voucher()
    first = GiftArtworkService.render(row, variant=variant)
    second = GiftArtworkService.render(row, variant=variant)

    assert first == second
    with Image.open(io.BytesIO(first)) as image:
        assert image.size == expected_size
        assert image.format == "PNG"


def test_artwork_omits_the_old_generic_fallback_and_changes_for_an_occasion():
    blank = GiftArtworkService.render(voucher(message=None), variant="portrait")
    old_fallback = GiftArtworkService.render(
        voucher(message="A private invitation to make getting dressed feel effortless."),
        variant="portrait",
    )
    birthday = GiftArtworkService.render(
        voucher(message=None, occasion="birthday"),
        variant="portrait",
    )

    assert blank != old_fallback
    assert blank != birthday


@pytest.mark.asyncio
async def test_portrait_artwork_never_receives_claim_credentials():
    row = voucher()
    db = FakeDB(rows={"gift_vouchers": [row]})

    with patch.object(
        GiftArtworkService,
        "get_or_render",
        new_callable=AsyncMock,
        return_value=b"credential-free-artwork",
    ) as render:
        image = await GiftService.portrait_artwork(VOUCHER_ID, USER_ID, db)

    assert image == b"credential-free-artwork"
    render.assert_awaited_once_with(row, variant="portrait")


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
async def test_named_claim_rejects_a_different_verified_email_before_database_mutation():
    row = voucher(recipient_email="taylor@example.com")
    db = Mock()
    db.table.return_value.select.return_value.eq.return_value.maybe_single.return_value.execute.return_value = Mock(
        data=row
    )

    with pytest.raises(ValidationError, match="reserved for another"):
        await GiftService.claim(
            {"id": OTHER_USER_ID, "email": "other@example.com", "email_verified": True},
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
        recipient_email="taylor@example.com",
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
        recipient_email="taylor@example.com",
        message=None,
        client_request_id="request-paid-123",
    )
    db = Mock()
    db.table.return_value.insert.return_value.execute.side_effect = RuntimeError("duplicate key")
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
                {"id": USER_ID, "email": "alex@example.com", "email_verified": True},
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
        "line_items": {"data": [{"price": {"id": "price_gift_1m"}, "quantity": 1}]},
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

    entitlement_selects = [call for call in db.selects if call[0] == "gift_entitlement_grants"]
    assert len(result.items) == 3
    assert len(entitlement_selects) == 1


@pytest.mark.asyncio
async def test_admin_cannot_manually_void_paid_value():
    with patch.object(
        AdminGiftService,
        "get",
        new=AsyncMock(return_value=GiftService.serialize(voucher(source="paid"), audience="admin").model_dump()),
    ):
        with pytest.raises(PermissionDeniedError, match="Stripe refund"):
            await AdminGiftService.void_or_revoke(VOUCHER_ID, "manual attempt", Mock())


@pytest.mark.asyncio
async def test_admin_revoke_uses_one_atomic_voucher_and_grant_rpc():
    claimed = voucher(
        status="claimed",
        claimed_by_user_id=OTHER_USER_ID,
        claimed_at=utcnow().isoformat(),
    )
    revoked = {**claimed, "status": "revoked", "admin_note": "fraud review"}
    db = FakeDB(
        rows={"gift_vouchers": [claimed]},
        rpc_results={"void_or_revoke_gift_voucher": [revoked]},
    )

    result = await AdminGiftService.void_or_revoke(
        VOUCHER_ID,
        "fraud review",
        db,
    )

    assert result["status"] == "revoked"
    rpc_name, params = db.rpc_calls[0]
    assert rpc_name == "void_or_revoke_gift_voucher"
    assert params["p_voucher_id"] == VOUCHER_ID
    assert params["p_expected_status"] == "claimed"
    assert params["p_reason"] == "fraud review"
    assert params["p_now"]
    assert not [update for update in db.updates if update[0] == "gift_entitlement_grants"]


@pytest.mark.asyncio
async def test_admin_void_rejects_a_voucher_claimed_after_the_initial_read():
    issued = voucher(status="issued")
    db = FakeDB(
        rows={"gift_vouchers": [issued]},
        rpc_results={"void_or_revoke_gift_voucher": []},
    )

    with pytest.raises(ValidationError, match="gift changed"):
        await AdminGiftService.void_or_revoke(VOUCHER_ID, "manual void", db)

    assert db.rpc_calls[0][1]["p_expected_status"] == "issued"
