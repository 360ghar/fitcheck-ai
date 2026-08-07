"""Admin service coverage tests (direct service-layer, no routes).

Covers the branches of ``app/services/admin_service.py`` that the route-level
suite leaves uncovered: the ``_extract_count`` defensive shapes, ``update_user``
role/suspension guards (incl. the last-admin check), the audit-entity dedupe in
``user_activity``, list-builder filters (subscriptions status, IAP status,
users/quota q, promo code q/active/plan, feedback category/status/q),
``refund_subscription`` (missing row, no Stripe customer, idempotent reuse,
refund creation, no-charge, StripeError mapping), ``dashboard_trends`` rows
without a ``day``, ``create_promo_code`` error branches, ``deployment_settings``
tolerating a broken ``ENABLE_*`` toggle, and the storage-cleanup guard.

Service functions are called directly with ``tests.utils.fake_db.FakeDB``
(rows + rpc_results); assertions run against ``db.filters``/``db.inserts``/
``db.updates`` and the returned payloads — same pattern as the sibling files
in this directory.
"""

import sys
from types import SimpleNamespace

import pytest

from tests.utils.fake_db import FakeDB
from app.core.config import Settings
from app.core.exceptions import (
    BillingNotConfiguredError,
    NotFoundError,
    StorageServiceError,
    ValidationError,
)
from app.services import admin_service
from app.services.admin_service import (
    _extract_count,
    create_promo_code,
    dashboard_trends,
    deployment_settings,
    list_feedback,
    list_iap_transactions,
    list_promo_codes,
    list_quota_usage,
    list_subscriptions,
    list_users,
    refund_subscription,
    storage_temp_cleanup,
    _trend_count_rows,
    update_user,
    user_activity,
)
from app.utils.datetime_util import utc_today

# =============================================================================
# _extract_count
# =============================================================================


def test_extract_count_list_first_element_not_a_dict_is_zero():
    assert _extract_count([42]) == 0
    assert _extract_count(["nope"]) == 0


def test_extract_count_dict_and_list_shapes():
    # dict value -> int(value.get("count") or 0)
    assert _extract_count({"count": 7}) == 7
    # count=None -> 0 (the `or 0` fallback)
    assert _extract_count({"count": None}) == 0
    # list whose first element IS a dict
    assert _extract_count([{"count": 3}]) == 3
    # empty list / non-dict fall through to 0
    assert _extract_count([]) == 0
    assert _extract_count(None) == 0


# =============================================================================
# update_user
# =============================================================================


def _user_row(**overrides) -> dict:
    row = {
        "id": "u1",
        "email": "u1@example.com",
        "full_name": "User One",
        "role": "user",
        "is_admin": False,
        "is_active": True,
    }
    row.update(overrides)
    return row


@pytest.mark.asyncio
async def test_update_user_sets_is_admin_flag():
    db = FakeDB(rows={"users": [_user_row()]})

    result = await update_user(
        db,
        actor={"id": "root-1", "role": "super_admin"},
        user_id="u1",
        is_admin=True,
    )

    assert result["user"]["is_admin"] is True
    assert result["changes"] == [
        {"action": "user.role_changed", "field": "is_admin", "before": False, "after": True}
    ]
    db.assert_update("users", is_admin=True)


@pytest.mark.asyncio
async def test_update_user_rejects_self_suspension():
    db = FakeDB(rows={"users": [_user_row()]})

    with pytest.raises(ValidationError, match="suspend your own account"):
        await update_user(
            db,
            actor={"id": "u1"},
            user_id="u1",
            is_active=False,
        )


@pytest.mark.asyncio
async def test_update_user_non_admin_actor_cannot_demote_an_admin():
    db = FakeDB(rows={"users": [_user_row(role="admin", is_admin=True)]})

    with pytest.raises(ValidationError, match="Only admins can change an admin's role"):
        await update_user(
            db,
            actor={"id": "support-1", "role": "support"},
            user_id="u1",
            role="user",
        )


@pytest.mark.asyncio
async def test_update_user_admin_actor_cannot_grant_super_admin():
    db = FakeDB(rows={"users": [_user_row()]})

    with pytest.raises(ValidationError, match="Only a super admin can grant the super_admin role"):
        await update_user(
            db,
            actor={"id": "admin-1", "role": "admin"},
            user_id="u1",
            role="super_admin",
        )


@pytest.mark.asyncio
async def test_update_user_super_admin_can_demote_an_admin_when_another_exists():
    db = FakeDB(
        rows={
            "users": [
                _user_row(role="admin", is_admin=True),
                {
                    "id": "a2",
                    "email": "admin2@example.com",
                    "full_name": "Admin Two",
                    "role": "admin",
                    "is_admin": True,
                    "is_active": True,
                },
            ]
        }
    )

    result = await update_user(
        db,
        actor={"id": "root-1", "role": "super_admin"},
        user_id="u1",
        role="user",
    )

    assert result["user"]["role"] == "user"
    assert result["user"]["is_admin"] is False
    assert [c["action"] for c in result["changes"]] == ["user.role_changed", "user.role_changed"]
    db.assert_update("users", role="user", is_admin=False)


@pytest.mark.asyncio
async def test_update_user_cannot_demote_the_last_admin():
    db = FakeDB(rows={"users": [_user_row(role="admin", is_admin=True)]})

    with pytest.raises(ValidationError, match="Cannot demote the last admin"):
        await update_user(
            db,
            actor={"id": "root-1", "role": "super_admin"},
            user_id="u1",
            role="user",
        )


@pytest.mark.asyncio
async def test_update_user_cannot_suspend_the_last_admin():
    db = FakeDB(rows={"users": [_user_row(role="admin", is_admin=True)]})

    with pytest.raises(ValidationError, match="Cannot suspend the last admin"):
        await update_user(
            db,
            actor={"id": "root-1", "role": "super_admin"},
            user_id="u1",
            is_active=False,
        )


# =============================================================================
# user_activity (audit dedupe)
# =============================================================================


@pytest.mark.asyncio
async def test_user_activity_dedupes_entity_audit_rows_with_same_id():
    db = FakeDB(
        rows={
            "users": [{"id": "u1"}],
            "audit_events": [
                {
                    "id": "e1",
                    "entity_type": "user",
                    "entity_id": "u1",
                    "created_at": "2026-08-07T09:00:00Z",
                },
                {
                    "id": "e1",  # duplicate id -> skipped by the seen-set
                    "entity_type": "user",
                    "entity_id": "u1",
                    "created_at": "2026-08-07T09:00:00Z",
                },
                {
                    "id": "e2",
                    "entity_type": "user",
                    "entity_id": "u1",
                    "created_at": "2026-08-07T08:00:00Z",
                },
            ],
        }
    )

    result = await user_activity(db, "u1")

    assert [row["id"] for row in result["audit_events"]] == ["e1", "e2"]
    assert result["recent_jobs"] == []


# =============================================================================
# Subscriptions list filters
# =============================================================================


@pytest.mark.asyncio
async def test_list_subscriptions_applies_status_filter():
    db = FakeDB(
        rows={
            "subscriptions": [
                {"id": "s1", "status": "active", "plan_type": "pro_monthly", "user_id": "u1"},
                {"id": "s2", "status": "trialing", "plan_type": "pro_monthly", "user_id": "u2"},
            ]
        }
    )

    result = await list_subscriptions(db, status="active")

    assert ("subscriptions", "eq", "status", "active") in db.filters
    assert [item["id"] for item in result["items"]] == ["s1"]


@pytest.mark.asyncio
async def test_list_iap_transactions_applies_status_filter():
    db = FakeDB(
        rows={
            "subscriptions": [
                {
                    "id": "s1",
                    "status": "active",
                    "billing_provider": "apple",
                    "apple_original_transaction_id": "txn-1",
                    "user_id": "u1",
                },
                {
                    "id": "s2",
                    "status": "refunded",
                    "billing_provider": "google",
                    "google_order_id": "GPA.1",
                    "user_id": "u2",
                },
            ]
        }
    )

    result = await list_iap_transactions(db, status="active")

    assert ("subscriptions", "eq", "status", "active") in db.filters
    assert ("subscriptions", "in", "billing_provider", ["apple", "google"]) in db.filters
    assert [item["id"] for item in result["items"]] == ["s1"]
    assert result["items"][0]["transaction_id"] == "txn-1"


# =============================================================================
# Search (or_) filters on the list builders
# =============================================================================


@pytest.mark.asyncio
async def test_list_users_applies_search_or_filter():
    db = FakeDB(rows={})

    await list_users(db, q="alice")

    or_filters = [
        expr for table, op, _col, expr in db.filters if table == "users" and op == "or"
    ]
    assert or_filters
    assert all(
        "email.ilike.%alice%" in expr and "full_name.ilike.%alice%" in expr
        for expr in or_filters
    )


@pytest.mark.asyncio
async def test_list_quota_usage_applies_search_or_filter():
    db = FakeDB(rows={})

    await list_quota_usage(db, q="bob")

    or_filters = [
        expr for table, op, _col, expr in db.filters if table == "user_ai_settings" and op == "or"
    ]
    assert or_filters
    assert all(
        "users.email.ilike.%bob%" in expr and "users.full_name.ilike.%bob%" in expr
        for expr in or_filters
    )


# =============================================================================
# refund_subscription
# =============================================================================


class _StripeError(Exception):
    """Stand-in for ``stripe.error.StripeError``."""


class _FakeStripe:
    """Minimal stripe stand-in: canned PaymentIntent/Charge/Refund lists.

    Records every ``Refund.create`` call so tests can assert the idempotent
    reuse path never creates a second refund.
    """

    def __init__(self, *, intents=None, charges=None, existing_refunds=None):
        self.intents = list(intents or [])
        self.charges = list(charges or [])
        self.existing_refunds = list(existing_refunds or [])
        self.created = []  # kwargs passed to Refund.create
        self.Refund = SimpleNamespace(list=self._refund_list, create=self._refund_create)
        self.PaymentIntent = SimpleNamespace(list=self._intent_list)
        self.Charge = SimpleNamespace(list=self._charge_list)
        self.error = SimpleNamespace(StripeError=_StripeError)

    def _intent_list(self, **kwargs):
        return SimpleNamespace(data=self.intents)

    def _charge_list(self, **kwargs):
        return SimpleNamespace(data=self.charges)

    def _refund_list(self, **kwargs):
        return SimpleNamespace(data=self.existing_refunds)

    def _refund_create(self, **kwargs):
        self.created.append(kwargs)
        return SimpleNamespace(
            id="re_created",
            status="succeeded",
            amount=1000,
            currency="usd",
            charge=kwargs.get("charge", "ch_created"),
        )


def _refund_db() -> FakeDB:
    return FakeDB(
        rows={"subscriptions": [{"user_id": "u1", "stripe_customer_id": "cus_1"}]}
    )


@pytest.mark.asyncio
async def test_refund_subscription_raises_when_billing_not_configured(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: False)

    with pytest.raises(BillingNotConfiguredError, match="billing is not configured"):
        await refund_subscription(FakeDB(), "u1")


@pytest.mark.asyncio
async def test_refund_subscription_missing_subscription_raises_not_found(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    db = FakeDB(rows={})

    with pytest.raises(NotFoundError):
        await refund_subscription(db, "u1")


@pytest.mark.asyncio
async def test_refund_subscription_without_stripe_customer_raises(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    db = FakeDB(rows={"subscriptions": [{"user_id": "u1", "billing_provider": "apple"}]})

    with pytest.raises(ValidationError, match="no Stripe customer"):
        await refund_subscription(db, "u1")


@pytest.mark.asyncio
async def test_refund_subscription_reuses_existing_succeeded_refund(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    existing = SimpleNamespace(
        id="re_existing",
        status="succeeded",
        amount=900,
        currency="usd",
        charge="ch_existing",
    )
    stripe_fake = _FakeStripe(
        intents=[SimpleNamespace(id="pi_1")],
        existing_refunds=[existing],
    )
    monkeypatch.setitem(sys.modules, "stripe", stripe_fake)

    result = await refund_subscription(_refund_db(), "u1")

    assert result == {
        "refund_id": "re_existing",
        "payment_intent": "pi_1",
        "charge_id": "ch_existing",
        "amount": 900,
        "currency": "usd",
        "status": "succeeded",
    }
    assert stripe_fake.created == []


@pytest.mark.asyncio
async def test_refund_subscription_creates_new_refund_when_existing_not_succeeded(monkeypatch):
    """An existing refund that is neither succeeded nor pending must not be
    reused - the code falls through to Refund.create."""
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    failed = SimpleNamespace(
        id="re_failed",
        status="failed",
        amount=900,
        currency="usd",
        charge="ch_failed",
    )
    stripe_fake = _FakeStripe(
        intents=[SimpleNamespace(id="pi_1")],
        existing_refunds=[failed],
    )
    monkeypatch.setitem(sys.modules, "stripe", stripe_fake)

    result = await refund_subscription(_refund_db(), "u1")

    assert result["refund_id"] == "re_created"
    assert result["payment_intent"] == "pi_1"
    assert stripe_fake.created == [{"payment_intent": "pi_1"}]


@pytest.mark.asyncio
async def test_refund_subscription_creates_refund_via_charge(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    stripe_fake = _FakeStripe(charges=[SimpleNamespace(id="ch_1")])
    monkeypatch.setitem(sys.modules, "stripe", stripe_fake)

    result = await refund_subscription(_refund_db(), "u1")

    assert result["refund_id"] == "re_created"
    assert result["charge_id"] == "ch_1"
    assert result["status"] == "succeeded"
    assert stripe_fake.created == [{"charge": "ch_1"}]


@pytest.mark.asyncio
async def test_refund_subscription_without_charges_raises_not_found(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)
    monkeypatch.setitem(sys.modules, "stripe", _FakeStripe())

    with pytest.raises(NotFoundError, match="No charge found"):
        await refund_subscription(_refund_db(), "u1")


@pytest.mark.asyncio
async def test_refund_subscription_maps_stripe_errors_to_validation(monkeypatch):
    monkeypatch.setattr(admin_service, "_billing_configured", lambda: True)

    class _RaisingStripe(_FakeStripe):
        def _intent_list(self, **kwargs):
            raise _StripeError("No such payment_intent: pi_xyz")

    monkeypatch.setitem(sys.modules, "stripe", _RaisingStripe())

    with pytest.raises(ValidationError, match="No such payment_intent"):
        await refund_subscription(_refund_db(), "u1")


# =============================================================================
# Dashboard trends (rows without a day)
# =============================================================================


@pytest.mark.asyncio
async def test_dashboard_trends_skips_rows_without_a_day():
    today = utc_today().isoformat()
    db = FakeDB(
        rows={},
        rpc_results={
            "admin_trend_signups": [],
            "admin_trend_jobs": [
                # No `day` -> skipped by the `if not day` guard.
                {"kind": "extraction", "total": 1, "succeeded": 1, "failed": 0},
                {"day": today, "kind": "photoshoot", "total": 2, "succeeded": 1, "failed": 1},
            ],
            "admin_trend_paid": [
                {"provider": "apple", "count": 1},  # no `day` -> skipped
                {"day": today, "provider": "stripe", "count": 3},
            ],
            "admin_trend_active": [],
        },
    )

    result = await dashboard_trends(db, days=7)

    assert sum(row["total"] for row in result["jobs"]) == 2
    assert result["jobs"][-1] == {"day": today, "total": 2, "succeeded": 1, "failed": 1}
    assert result["paid"][-2] == {"day": today, "provider": "stripe", "count": 3}
    assert result["paid"][-1] == {"day": today, "provider": "iap", "count": 0}
    assert sum(row["count"] for row in result["paid"]) == 3


# =============================================================================
# Promo codes
# =============================================================================


@pytest.mark.asyncio
async def test_list_promo_codes_applies_q_active_and_plan_filters():
    db = FakeDB(rows={})
    await list_promo_codes(db, q="sum")
    assert ("promo_codes", "ilike", "code", "%sum%") in db.filters

    db = FakeDB(rows={})
    await list_promo_codes(db, active=False)
    assert ("promo_codes", "eq", "active", False) in db.filters

    db = FakeDB(rows={})
    await list_promo_codes(db, active=True, plan_type="pro_monthly")
    assert ("promo_codes", "eq", "active", True) in db.filters
    assert ("promo_codes", "eq", "plan_type", "pro_monthly") in db.filters


@pytest.mark.asyncio
async def test_create_promo_code_rejects_invalid_format():
    db = FakeDB(rows={})

    with pytest.raises(ValidationError, match="3-50 characters"):
        await create_promo_code(db, {"code": "!!"})


@pytest.mark.asyncio
async def test_create_promo_code_rejects_existing_code():
    db = FakeDB(rows={"promo_codes": [{"id": "p1", "code": "SUMMER25"}]})

    with pytest.raises(ValidationError, match="already exists"):
        await create_promo_code(db, {"code": "SUMMER25"})


class _RaisingPromoDb:
    """Minimal db stand-in whose promo_codes insert raises on execute."""

    def __init__(self, insert_error: Exception):
        self._insert_error = insert_error

    def table(self, name: str) -> "_RaisingPromoBuilder":
        return _RaisingPromoBuilder(self, name)


class _RaisingPromoBuilder:
    def __init__(self, db: _RaisingPromoDb, name: str):
        self._db = db
        self._name = name
        self._inserting = False

    def select(self, *args, **kwargs):
        return self

    def ilike(self, *args, **kwargs):
        return self

    def maybe_single(self):
        return self

    def insert(self, row):
        self._inserting = True
        return self

    def execute(self):
        if self._name == "promo_codes" and self._inserting:
            raise self._db._insert_error
        return None


@pytest.mark.asyncio
async def test_create_promo_code_maps_unique_violation_to_already_exists():
    db = _RaisingPromoDb(
        insert_error=RuntimeError(
            'duplicate key value violates unique constraint "promo_codes_code_key" (SQLSTATE 23505)'
        )
    )

    with pytest.raises(ValidationError, match="already exists"):
        await create_promo_code(db, {"code": "WELCOME10"})


@pytest.mark.asyncio
async def test_create_promo_code_reraises_non_duplicate_insert_errors():
    db = _RaisingPromoDb(insert_error=RuntimeError("some other insert failure"))

    with pytest.raises(RuntimeError, match="some other insert failure"):
        await create_promo_code(db, {"code": "WELCOME10"})


@pytest.mark.asyncio
async def test_create_promo_code_inserts_stripped_code():
    db = FakeDB(rows={})

    created = await create_promo_code(db, {"code": " WELCOME10 ", "discount_percent": 20})

    assert created["code"] == "WELCOME10"
    db.assert_insert("promo_codes", code="WELCOME10", discount_percent=20)


# =============================================================================
# Feedback (support tickets)
# =============================================================================


@pytest.mark.asyncio
async def test_list_feedback_applies_category_status_and_q_filters():
    db = FakeDB(
        rows={
            "support_tickets": [
                {
                    "id": "t1",
                    "category": "billing",
                    "subject": "refund please",
                    "status": "open",
                    "description": "charged twice",
                },
                {
                    "id": "t2",
                    "category": "bug",
                    "subject": "crash",
                    "status": "open",
                    "description": "app closes",
                },
            ]
        }
    )

    result = await list_feedback(db, category="billing", status="open", q="refund")

    assert ("support_tickets", "eq", "category", "billing") in db.filters
    assert ("support_tickets", "eq", "status", "open") in db.filters
    or_filters = [
        expr for table, op, _col, expr in db.filters if table == "support_tickets" and op == "or"
    ]
    assert or_filters
    assert all(
        "subject.ilike.%refund%" in expr and "description.ilike.%refund%" in expr
        for expr in or_filters
    )
    assert [item["id"] for item in result["items"]] == ["t1"]


# =============================================================================
# Deployment settings (defensive toggle) + storage cleanup guard
# =============================================================================


class _BrokenToggle:
    """``bool()`` raises — simulates a misbehaving ``ENABLE_*`` settings toggle."""

    def __bool__(self):
        raise ValueError("toggle broken")


def test_deployment_settings_tolerates_broken_toggle(monkeypatch):
    # The Settings class has no ENABLE_FAKE_* field; add one whose bool()
    # raises so the defensive `except Exception` in deployment_settings is
    # exercised (a broken toggle must not 500 the settings endpoint).
    monkeypatch.setattr(Settings, "ENABLE_FAKE_BROKEN_TOGGLE", _BrokenToggle(), raising=False)

    info = deployment_settings()

    assert "ENABLE_FAKE_BROKEN_TOGGLE" not in info["feature_toggles"]
    assert "ENABLE_GAMIFICATION" in info["feature_toggles"]
    assert "ENABLE_SOCIAL_IMPORT" in info["feature_toggles"]


@pytest.mark.asyncio
async def test_storage_temp_cleanup_requires_object_storage(monkeypatch):
    monkeypatch.setattr(admin_service, "_object_storage_configured", lambda: False)

    with pytest.raises(StorageServiceError, match="Object storage is not configured"):
        await storage_temp_cleanup(FakeDB())


# =============================================================================
# update_user residual arcs
# =============================================================================


@pytest.mark.asyncio
async def test_update_user_self_update_without_suspension_allowed():
    """Own-account update where is_active is not False passes the self-
    suspension guard (arc 405 -> next checks)."""
    db = FakeDB(rows={"users": [_user_row(is_active=False)]})

    result = await update_user(
        db,
        actor={"id": "u1", "role": "user"},
        user_id="u1",
        is_active=True,
    )

    assert result["user"]["is_active"] is True


@pytest.mark.asyncio
async def test_update_user_admin_actor_promotes_plain_user():
    """An admin (not super_admin) promoting a plain user passes the
    admin-state guard without tripping the demote checks."""
    db = FakeDB(rows={"users": [_user_row()]})

    result = await update_user(
        db,
        actor={"id": "admin-1", "role": "admin"},
        user_id="u1",
        is_admin=True,
    )

    assert result["user"]["is_admin"] is True


# =============================================================================
# _trend_count_rows residual arc
# =============================================================================


def test_trend_count_rows_skips_rows_without_day():
    """A row without a usable day value is skipped (arc back to the loop)."""
    from datetime import timedelta

    today = utc_today()
    yesterday = (today - timedelta(days=1)).isoformat()
    rows = [
        {"day": None, "count": 5},
        {"count": 3},
        {"day": yesterday, "count": 2},
    ]
    series = _trend_count_rows(rows, 7)
    counts = {r["day"]: r["count"] for r in series}
    assert counts[yesterday] == 2
    assert len(series) == 7  # zero-filled over the whole window
