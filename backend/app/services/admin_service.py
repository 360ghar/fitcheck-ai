"""
Admin domain queries (``/api/v1/admin/*`` backend logic).

Routes stay thin; non-trivial queries live here. All DB access goes through
``execute_with_reconnect`` (pooled-connection retry + worker-thread offload),
matching the rest of the codebase. Every query targets tables verified
against the migrations in ``backend/db/supabase/migrations``.

Table/column map used throughout (verified 2026-08-06):

- ``users`` (001/002/008/037): id, email, full_name, avatar_url, is_active,
  email_verified, created_at, updated_at, last_login_at, is_admin (037),
  role (037), custom_daily_quota (037)
- ``subscriptions`` (007/030): user_id, plan_type, status, current_period_start,
  current_period_end, cancel_at_period_end, stripe_customer_id,
  stripe_subscription_id, trial_end, referral_credit_months,
  billing_provider, apple_original_transaction_id, google_purchase_token,
  google_order_id, billing_product_id
- ``user_ai_settings`` (003/006): daily_extraction_count,
  daily_generation_count, daily_embedding_count, last_reset_date,
  total_extractions, total_generations
- ``subscription_usage`` (007/010/022/029): period_start,
  monthly_extractions, monthly_generations, monthly_embeddings,
  daily_photoshoot_images, last_photoshoot_reset
- ``extraction_jobs`` (016/023): id, user_id, status, job_type, created_at,
  completed_at, error_message  (status: pending|extracting|generating|
  completed|failed|cancelled)
- ``photoshoot_jobs`` (023/035): id, user_id, status, use_case, created_at,
  completed_at, error_message  (status: pending|processing|complete|failed|
  cancelled)
- ``referral_codes`` / ``referral_redemptions`` (007): referrer_user_id,
  referred_user_id, referrer_credit_applied, referred_credit_applied
- ``promo_codes`` / ``promo_redemptions`` (031)
- ``support_tickets`` (009/034/037): id, user_id, category, subject,
  description, status, contact_email, app_platform, app_version,
  internal_notes (037), created_at, updated_at
- ``blog_posts`` (017)
- ``audit_events`` (038)
"""

from __future__ import annotations

import asyncio
import re
from datetime import timedelta
from typing import Any, Dict, Iterable, List, Optional

from app.core.config import settings
from app.core.exceptions import (
    BillingNotConfiguredError,
    NotFoundError,
    StorageServiceError,
    UserNotFoundError,
    ValidationError,
)
from app.core.permissions import ADMIN_ROLES, USER_ROLE, get_user_role
from app.core.predicates import build_predicate
from app.utils.db import execute_with_reconnect, maybe_single_data, safe_search_term
from app.utils.datetime_util import utc_today, utcnow

# =============================================================================
# Small shared helpers
# =============================================================================

# Display prices for the subscriptions/IAP lists, sourced from settings so the
# admin UI never hardcodes prices. Free/unknown plans yield None.
PLAN_AMOUNTS: Dict[str, float] = {
    "plus_monthly": settings.PLAN_PLUS_MONTHLY_PRICE,
    "plus_yearly": settings.PLAN_PLUS_YEARLY_PRICE,
    "pro_monthly": settings.PLAN_PRO_MONTHLY_PRICE,
    "pro_yearly": settings.PLAN_PRO_YEARLY_PRICE,
}


def plan_display_amount(plan_type: Optional[str]) -> Optional[float]:
    """USD display price for a plan_type, or None for free/unknown plans."""
    if not plan_type:
        return None
    return PLAN_AMOUNTS.get(plan_type)


def _or_ilike(columns: Iterable[str], term: str) -> str:
    """Comma-joined ``col.ilike.<term>`` predicates for an ``or_`` expression.

    Built through ``app.core.predicates.build_predicate`` so the construction
    side and the test emulation share one grammar (qualified columns like
    ``users.email`` and dotted search terms cannot drift apart).
    """
    return ",".join(build_predicate(col, "ilike", term) for col in columns)


def _or_eq(columns: Iterable[str], value: str) -> str:
    """Comma-joined ``col.eq.<value>`` predicates for an ``or_`` expression."""
    return ",".join(build_predicate(col, "eq", value) for col in columns)


def _page_range(page: int, page_size: int) -> tuple[int, int]:
    """PostgREST .range() is inclusive on both ends."""
    offset = (page - 1) * page_size
    return offset, offset + page_size - 1


def _extract_count(value: Any) -> int:
    """Pull the count out of an embedded aggregate (``outfits(count)``)."""
    if isinstance(value, list) and value:
        first = value[0]
        if isinstance(first, dict):
            return int(first.get("count") or 0)
        return 0
    if isinstance(value, dict):
        return int(value.get("count") or 0)
    return 0


def _first_row(result: Any) -> Optional[Dict[str, Any]]:
    data = getattr(result, "data", None) or []
    return data[0] if data else None


def _billing_configured() -> bool:
    """Web (Stripe) billing is fully configured when the secret key is set."""
    return bool(settings.STRIPE_SECRET_KEY)


# =============================================================================
# Users
# =============================================================================

_USER_SORT_COLUMNS = {"created_at", "last_login_at", "email", "full_name"}
_ADMIN_ROLE_LIST = ",".join(sorted(ADMIN_ROLES))


def _users_list_builder(
    d: Any,
    *,
    q: Optional[str],
    status: Optional[str],
    role: Optional[str],
    plan: Optional[str],
    sort_col: str,
    sort_dir: str,
) -> Any:
    query = d.table("users").select(
        "*",
        "subscriptions(plan_type,status,current_period_start,current_period_end,billing_provider)",
        "outfits(count)",
        "items(count)",
        count="exact",
    )
    if q:
        term = f"%{safe_search_term(q)}%"
        query = query.or_(_or_ilike(("email", "full_name"), term))
    if status == "active":
        query = query.eq("is_active", True)
    elif status == "suspended":
        query = query.eq("is_active", False)
    if role:
        query = query.eq("role", role)
    if plan:
        # Every user has a subscription row (007/008 backfill + new-user
        # trigger), so the embedded-resource filter is complete for all plans.
        query = query.eq("subscriptions.plan_type", plan)
    return query.order(sort_col, desc=(sort_dir == "desc"))


async def list_users(
    db: Any,
    *,
    q: Optional[str] = None,
    status: Optional[str] = None,
    role: Optional[str] = None,
    plan: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_by: str = "created_at",
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    """Paginated user list with subscription + outfits/items counts."""
    sort_col = sort_by if sort_by in _USER_SORT_COLUMNS else "created_at"
    kwargs = dict(
        q=q,
        status=status,
        role=role,
        plan=plan,
        sort_col=sort_col,
        sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc",
    )
    count_result = await execute_with_reconnect(
        lambda d: _users_list_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_users", "page": page},
    )
    total = getattr(count_result, "count", 0) or 0

    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _users_list_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_users.page", "page": page},
    )

    items: List[Dict[str, Any]] = []
    for row in page_result.data or []:
        row = dict(row)
        sub = row.pop("subscriptions", None) or {}
        items.append(
            {
                **row,
                "subscription": sub if isinstance(sub, dict) else {},
                "outfits_count": _extract_count(row.pop("outfits", None)),
                "items_count": _extract_count(row.pop("items", None)),
            }
        )
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def get_user_detail(db: Any, user_id: str) -> Dict[str, Any]:
    """Full user profile: row + subscription + usage snapshot + counts + jobs."""
    user_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.get_user", "user_id": user_id},
        )
    )
    if not user_row:
        raise UserNotFoundError(user_id)

    sub_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscriptions").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.get_user.subscription", "user_id": user_id},
        )
    )
    ai_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("user_ai_settings")
            .select(
                "daily_extraction_count,daily_generation_count,daily_embedding_count,"
                "last_reset_date,total_extractions,total_generations"
            )
            .eq("user_id", user_id)
            .maybe_single()
            .execute(),
            db,
            extra={"operation": "admin.get_user.ai_usage", "user_id": user_id},
        )
    )
    usage_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscription_usage")
            .select(
                "period_start,monthly_extractions,monthly_generations,monthly_embeddings,"
                "daily_photoshoot_images,last_photoshoot_reset"
            )
            .eq("user_id", user_id)
            .eq("period_start", utc_today().isoformat())
            .maybe_single()
            .execute(),
            db,
            extra={"operation": "admin.get_user.subscription_usage", "user_id": user_id},
        )
    )

    counts: Dict[str, int] = {}
    for table in ("outfits", "items"):
        res = await execute_with_reconnect(
            lambda d: d.table(table).select("id", count="exact").eq("user_id", user_id).execute(),
            db,
            extra={"operation": f"admin.get_user.count.{table}", "user_id": user_id},
        )
        counts[table] = getattr(res, "count", 0) or 0
    ref_res = await execute_with_reconnect(
        lambda d: d.table("referral_redemptions")
        .select("id", count="exact")
        .eq("referrer_user_id", user_id)
        .execute(),
        db,
        extra={"operation": "admin.get_user.count.referrals", "user_id": user_id},
    )
    counts["referrals"] = getattr(ref_res, "count", 0) or 0

    jobs: List[Dict[str, Any]] = []
    job_queries = (
        ("extraction_jobs", "id,status,job_type,created_at,completed_at,error_message"),
        ("photoshoot_jobs", "id,status,use_case,created_at,completed_at,error_message"),
    )
    for table, columns in job_queries:
        res = await execute_with_reconnect(
            lambda d: d.table(table)
            .select(columns)
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(5)
            .execute(),
            db,
            extra={"operation": f"admin.get_user.jobs.{table}", "user_id": user_id},
        )
        for row in res.data or []:
            jobs.append({**dict(row), "job_table": table})
    jobs.sort(key=lambda r: str(r.get("created_at") or ""), reverse=True)

    return {
        "user": user_row,
        "subscription": sub_row,
        "usage": {"ai": ai_row or {}, "subscription_usage": usage_row or {}},
        "counts": counts,
        "recent_jobs": jobs[:10],
    }


async def update_user(
    db: Any,
    *,
    actor: Dict[str, Any],
    user_id: str,
    is_admin: Optional[bool] = None,
    role: Optional[str] = None,
    is_active: Optional[bool] = None,
) -> Dict[str, Any]:
    """Apply admin edits to a user with the spec's safety rules.

    Rules enforced here:
    - ``role`` must be in ADMIN_ROLES or ``user``.
    - An admin cannot demote, suspend, or otherwise change their own role.
    - Only admin/super_admin actors may grant or change admin roles;
      super_admin grants require a super_admin actor.
    - Demoting OR suspending the LAST admin (is_admin flag or admin role)
      is rejected.
    """
    target = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.update_user.load", "user_id": user_id},
        )
    )
    if not target:
        raise UserNotFoundError(user_id)

    if role is not None and role not in ADMIN_ROLES and role != USER_ROLE:
        raise ValidationError(
            message=f"Invalid role '{role}'",
            details={"field": "role", "allowed": sorted([USER_ROLE, *ADMIN_ROLES])},
        )

    updates: Dict[str, Any] = {}
    if role is not None and role != target.get("role"):
        updates["role"] = role
    if is_admin is not None and bool(is_admin) != bool(target.get("is_admin")):
        updates["is_admin"] = bool(is_admin)
    if is_active is not None and bool(is_active) != bool(target.get("is_active")):
        updates["is_active"] = bool(is_active)

    # Demoting to the plain 'user' role must also clear the legacy is_admin
    # flag: the RBAC fallback treats is_admin=True as admin, so leaving it set
    # would silently keep the demoted user an admin.
    if (
        updates.get("role") == USER_ROLE
        and bool(target.get("is_admin"))
        and "is_admin" not in updates
    ):
        updates["is_admin"] = False

    if not updates:
        raise ValidationError(message="No changes provided", details={"fields": "Provide at least one field"})

    was_admin = (target.get("role") in ADMIN_ROLES) or bool(target.get("is_admin"))
    new_role = updates.get("role", target.get("role"))
    new_is_admin = updates.get("is_admin", bool(target.get("is_admin")))
    will_be_admin = (new_role in ADMIN_ROLES) or bool(new_is_admin)

    is_self = str(actor.get("id")) == str(user_id)
    if is_self:
        if was_admin and not will_be_admin:
            raise ValidationError(message="You cannot demote your own account", details={"field": "role"})
        # Any self role/is_admin change is rejected, not just demotions: a
        # users.write holder (support/ops) could otherwise PATCH their OWN
        # role to admin/super_admin and fully escalate (the old guards only
        # blocked self-demotion and self-suspension).
        if "role" in updates or "is_admin" in updates:
            raise ValidationError(message="You cannot change your own role", details={"field": "role"})
        if updates.get("is_active") is False:
            raise ValidationError(message="You cannot suspend your own account", details={"field": "is_active"})

    # Only admins may change who is an admin: a support/ops holder can
    # neither promote a user into an admin role nor demote an existing admin
    # (previously only the last-admin check existed, so both were possible).
    # Granting super_admin additionally requires a super_admin actor.
    role_changes_admin_state = "role" in updates or "is_admin" in updates
    if role_changes_admin_state:
        actor_role = get_user_role(actor)
        if actor_role not in ("admin", "super_admin"):
            if will_be_admin:
                raise ValidationError(
                    message="Only admins can grant admin roles",
                    details={"field": "role"},
                )
            if was_admin:
                raise ValidationError(
                    message="Only admins can change an admin's role",
                    details={"field": "role"},
                )
        elif updates.get("role") == "super_admin" and actor_role != "super_admin":
            raise ValidationError(
                message="Only a super admin can grant the super_admin role",
                details={"field": "role"},
            )

    # The last-admin guard also fires when the update would DEACTIVATE the
    # last admin (is_active=False), not only on demotion — otherwise a
    # support/ops holder could suspend the last admin and lock the panel.
    if was_admin and (not will_be_admin or updates.get("is_active") is False):
        others = await execute_with_reconnect(
            lambda d: d.table("users")
            .select("id", count="exact")
            .or_(
                f"{build_predicate('is_admin', 'eq', 'true')},"
                f"{build_predicate('role', 'in', f'({_ADMIN_ROLE_LIST})')}"
            )
            .neq("id", user_id)
            .execute(),
            db,
            extra={"operation": "admin.update_user.last_admin_check", "user_id": user_id},
        )
        other_count = getattr(others, "count", 0) or 0
        if other_count == 0:
            if updates.get("is_active") is False and will_be_admin:
                raise ValidationError(
                    message="Cannot suspend the last admin",
                    details={"field": "is_active"},
                )
            raise ValidationError(
                message="Cannot demote the last admin; promote another user first",
                details={"field": "role"},
            )

    result = await execute_with_reconnect(
        lambda d: d.table("users").update(updates).eq("id", user_id).execute(),
        db,
        extra={"operation": "admin.update_user.apply", "user_id": user_id},
    )
    updated = _first_row(result) or {**target, **updates}

    # Change list for the route's audit rows (before/after per field).
    changes: List[Dict[str, Any]] = []
    if "role" in updates:
        changes.append(
            {
                "action": "user.role_changed",
                "field": "role",
                "before": target.get("role"),
                "after": updates["role"],
            }
        )
    if "is_admin" in updates:
        changes.append(
            {
                "action": "user.role_changed",
                "field": "is_admin",
                "before": bool(target.get("is_admin")),
                "after": updates["is_admin"],
            }
        )
    if "is_active" in updates:
        changes.append(
            {
                "action": "user.status_changed",
                "field": "is_active",
                "before": bool(target.get("is_active")),
                "after": updates["is_active"],
            }
        )

    return {"user": updated, "changes": changes}


async def user_activity(db: Any, user_id: str) -> Dict[str, Any]:
    """Recent audit events + recent jobs for one user (limit 25 each)."""
    user_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("id").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.user_activity.load", "user_id": user_id},
        )
    )
    if not user_row:
        raise UserNotFoundError(user_id)

    audit_rows: List[Dict[str, Any]] = []
    audit_res = await execute_with_reconnect(
        lambda d: d.table("audit_events")
        .select("*")
        .eq("actor_id", user_id)
        .order("created_at", desc=True)
        .limit(25)
        .execute(),
        db,
        extra={"operation": "admin.user_activity.audit_actor", "user_id": user_id},
    )
    audit_rows.extend(audit_res.data or [])
    entity_res = await execute_with_reconnect(
        lambda d: d.table("audit_events")
        .select("*")
        .eq("entity_type", "user")
        .eq("entity_id", user_id)
        .order("created_at", desc=True)
        .limit(25)
        .execute(),
        db,
        extra={"operation": "admin.user_activity.audit_entity", "user_id": user_id},
    )
    seen: set = set()
    for row in entity_res.data or []:
        if row.get("id") in seen:
            continue
        seen.add(row.get("id"))
        audit_rows.append(row)
    audit_rows.sort(key=lambda r: str(r.get("created_at") or ""), reverse=True)

    jobs: List[Dict[str, Any]] = []
    for table in ("extraction_jobs", "photoshoot_jobs"):
        res = await execute_with_reconnect(
            lambda d: d.table(table)
            .select("id,status,created_at,completed_at,error_message")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(25)
            .execute(),
            db,
            extra={"operation": f"admin.user_activity.jobs.{table}", "user_id": user_id},
        )
        for row in res.data or []:
            jobs.append({**dict(row), "job_table": table})
    jobs.sort(key=lambda r: str(r.get("created_at") or ""), reverse=True)

    return {
        "user_id": user_id,
        "audit_events": audit_rows[:25],
        "recent_jobs": jobs[:25],
    }


# =============================================================================
# Subscriptions
# =============================================================================

_SUBSCRIPTION_SORT_COLUMNS = {"created_at", "current_period_start", "plan_type", "status"}


def _subscriptions_list_builder(
    d: Any, *, plan: Optional[str], status: Optional[str], sort_col: str, sort_dir: str
) -> Any:
    query = d.table("subscriptions").select("*", "users(email,full_name)", count="exact")
    if plan:
        query = query.eq("plan_type", plan)
    if status:
        query = query.eq("status", status)
    return query.order(sort_col, desc=(sort_dir == "desc"))


async def list_subscriptions(
    db: Any,
    *,
    plan: Optional[str] = None,
    status: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_by: str = "created_at",
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    sort_col = sort_by if sort_by in _SUBSCRIPTION_SORT_COLUMNS else "created_at"
    kwargs = dict(
        plan=plan,
        status=status,
        sort_col=sort_col,
        sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc",
    )
    count_result = await execute_with_reconnect(
        lambda d: _subscriptions_list_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_subscriptions"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _subscriptions_list_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_subscriptions.page"},
    )
    items = []
    for row in page_result.data or []:
        row = dict(row)
        user = row.pop("users", None) or {}
        items.append(
            {
                **row,
                "user": user if isinstance(user, dict) else {},
                "amount": plan_display_amount(row.get("plan_type")),
            }
        )
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def get_user_subscription(db: Any, user_id: str) -> Dict[str, Any]:
    """Full subscription detail incl. provider identifiers + current usage."""
    sub_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscriptions").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.get_user_subscription", "user_id": user_id},
        )
    )
    if not sub_row:
        raise NotFoundError(
            message=f"No subscription found for user {user_id}",
            resource_type="subscription",
            resource_id=user_id,
        )
    user_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("id,email,full_name,created_at").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.get_user_subscription.user", "user_id": user_id},
        )
    )
    usage_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscription_usage")
            .select(
                "period_start,monthly_extractions,monthly_generations,monthly_embeddings,"
                "daily_photoshoot_images"
            )
            .eq("user_id", user_id)
            .eq("period_start", utc_today().isoformat())
            .maybe_single()
            .execute(),
            db,
            extra={"operation": "admin.get_user_subscription.usage", "user_id": user_id},
        )
    )
    return {"subscription": sub_row, "user": user_row or {}, "usage": usage_row or {}}


async def refund_subscription(db: Any, user_id: str) -> Dict[str, Any]:
    """Refund the user's latest Stripe charge/payment intent (full refund).

    Raises ``BillingNotConfiguredError`` when Stripe is not configured and
    ``ValidationError`` when the subscription has no Stripe customer (e.g.
    store-billed rows cannot be refunded through Stripe).
    """
    if not _billing_configured():
        raise BillingNotConfiguredError(
            message="Stripe billing is not configured for this deployment",
            service_name="stripe",
        )
    sub_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscriptions").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.refund_subscription.load", "user_id": user_id},
        )
    )
    if not sub_row:
        raise NotFoundError(
            message=f"No subscription found for user {user_id}",
            resource_type="subscription",
            resource_id=user_id,
        )
    customer_id = sub_row.get("stripe_customer_id")
    if not customer_id:
        raise ValidationError(
            message="Subscription has no Stripe customer; only Stripe-billed rows are refundable here",
            details={"user_id": user_id, "billing_provider": sub_row.get("billing_provider")},
        )

    def _refund() -> Dict[str, Any]:
        import stripe  # local import: stripe is only needed on this path

        stripe.api_key = settings.STRIPE_SECRET_KEY

        def _create_refund(*, payment_intent: Optional[str] = None, charge: Optional[str] = None) -> Dict[str, Any]:
            """Create a refund, idempotently.

            Reuses an existing succeeded/pending refund for the same intent or
            charge instead of calling Refund.create again — Stripe rejects the
            duplicate with InvalidRequestError, which used to surface as a 500.
            """
            list_kwargs: Dict[str, Any] = {"limit": 1}
            if payment_intent:
                list_kwargs["payment_intent"] = payment_intent
            if charge:
                list_kwargs["charge"] = charge
            existing = stripe.Refund.list(**list_kwargs)
            if existing and existing.data:
                refund = existing.data[0]
                if refund.status in ("succeeded", "pending"):
                    return {
                        "refund_id": refund.id,
                        "payment_intent": payment_intent,
                        "charge_id": charge or getattr(refund, "charge", None),
                        "amount": refund.amount,
                        "currency": refund.currency,
                        "status": refund.status,
                    }
            refund = stripe.Refund.create(**{k: v for k, v in (("payment_intent", payment_intent), ("charge", charge)) if v})
            return {
                "refund_id": refund.id,
                "payment_intent": payment_intent,
                "charge_id": charge or getattr(refund, "charge", None),
                "amount": refund.amount,
                "currency": refund.currency,
                "status": refund.status,
            }

        try:
            payment_intents = stripe.PaymentIntent.list(customer=customer_id, limit=1)
            if payment_intents and payment_intents.data:
                payment_intent = payment_intents.data[0]
                return _create_refund(payment_intent=payment_intent.id)
            charges = stripe.Charge.list(customer=customer_id, limit=1)
            if charges and charges.data:
                charge = charges.data[0]
                return _create_refund(charge=charge.id)
        except stripe.error.StripeError as exc:
            # StripeError is not a FitCheckException; without this mapping the
            # catch-all handler turns e.g. an already-refunded InvalidRequestError
            # into a 500. A refund that cannot be executed is a 4xx client
            # problem, not a server fault.
            raise ValidationError(
                message=str(exc),
                details={"service": "stripe"},
            ) from exc
        raise NotFoundError(
            message="No charge found for this Stripe customer to refund",
            resource_type="stripe_customer",
            resource_id=customer_id,
        )

    return await asyncio.to_thread(_refund)


# =============================================================================
# IAP transactions (store-billed subscriptions, migration 030)
# =============================================================================


def _iap_list_builder(d: Any, *, platform: Optional[str], status: Optional[str], sort_dir: str) -> Any:
    query = d.table("subscriptions").select("*", "users(email,full_name)", count="exact").in_(
        "billing_provider", ["apple", "google"]
    )
    if platform:
        query = query.eq("billing_provider", platform)
    if status:
        query = query.eq("status", status)
    return query.order("created_at", desc=(sort_dir == "desc"))


def _iap_item(row: Dict[str, Any]) -> Dict[str, Any]:
    row = dict(row)
    user = row.pop("users", None) or {}
    transaction_id = (
        row.get("apple_original_transaction_id")
        or row.get("google_order_id")
        or row.get("google_purchase_token")
    )
    return {
        **row,
        "subscription_id": row.get("id"),
        "transaction_id": transaction_id,
        "user_id": row.get("user_id"),
        "user_email": user.get("email") if isinstance(user, dict) else None,
        "platform": row.get("billing_provider"),
        "amount": plan_display_amount(row.get("plan_type")),
    }


async def list_iap_transactions(
    db: Any,
    *,
    platform: Optional[str] = None,
    status: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    kwargs = dict(platform=platform, status=status, sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc")
    count_result = await execute_with_reconnect(
        lambda d: _iap_list_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_iap_transactions"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _iap_list_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_iap_transactions.page"},
    )
    return {
        "items": [_iap_item(row) for row in page_result.data or []],
        "total": total,
        "page": page,
        "page_size": page_size,
    }


async def get_iap_transaction(db: Any, txn_id: str) -> Dict[str, Any]:
    """Look up a store transaction by any of its provider identifiers."""
    # NOT safe_search_term(): it also strips "." and ":", which are LEGAL in
    # PostgREST eq values (predicates.py round-trips google_order_id.eq.GPA.123).
    # Google order ids are "GPA.1234-5678-9012-34567", so stripping the dots
    # made the lookup never match and admin detail/mark-refunded 404'd. Only
    # commas and parens break the or_ list syntax (they delimit predicates);
    # strip just those.
    safe = re.sub(r"[(),]", "", txn_id)
    result = await execute_with_reconnect(
        lambda d: d.table("subscriptions")
        .select("*", "users(email,full_name)")
        .or_(
            _or_eq(
                (
                    "apple_original_transaction_id",
                    "google_order_id",
                    "google_purchase_token",
                ),
                safe,
            )
        )
        .neq("billing_provider", "stripe")
        .limit(1)
        .execute(),
        db,
        extra={"operation": "admin.get_iap_transaction", "txn_id": txn_id},
    )
    row = _first_row(result)
    if not row:
        raise NotFoundError(
            message=f"IAP transaction '{txn_id}' not found",
            resource_type="iap_transaction",
            resource_id=txn_id,
        )
    return _iap_item(row)


async def mark_iap_refunded(db: Any, txn_id: str) -> Dict[str, Any]:
    """Mark a store transaction as refunded (status-only update).

    Store-side refunds arrive via webhooks; this endpoint only flips the
    stored state so the admin UI reflects reality.
    """
    row = await get_iap_transaction(db, txn_id)
    before_status = row.get("status")
    result = await execute_with_reconnect(
        lambda d: d.table("subscriptions")
        .update({"status": "refunded"})
        .eq("id", row.get("subscription_id"))
        .execute(),
        db,
        extra={"operation": "admin.mark_iap_refunded", "txn_id": txn_id},
    )
    updated = _first_row(result) or {}
    return {"transaction": updated, "before_status": before_status, "after_status": "refunded"}


# =============================================================================
# Quotas
# =============================================================================

_QUOTA_SORT_COLUMNS = {
    "extraction": "daily_extraction_count",
    "generation": "daily_generation_count",
    "embedding": "daily_embedding_count",
    "user": "user_id",
}


def _quota_usage_builder(
    d: Any, *, q: Optional[str], plan: Optional[str], sort_col: str, sort_dir: str
) -> Any:
    query = d.table("user_ai_settings").select(
        "user_id,daily_extraction_count,daily_generation_count,daily_embedding_count,"
        "last_reset_date,total_extractions,total_generations",
        "users(email,full_name,custom_daily_quota)",
        "subscriptions(plan_type,status)",
        count="exact",
    )
    if q:
        term = f"%{safe_search_term(q)}%"
        query = query.or_(_or_ilike(("users.email", "users.full_name"), term))
    if plan:
        query = query.eq("subscriptions.plan_type", plan)
    return query.order(sort_col, desc=(sort_dir == "desc"))


async def list_quota_usage(
    db: Any,
    *,
    q: Optional[str] = None,
    plan: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_by: str = "extraction",
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    sort_col = _QUOTA_SORT_COLUMNS.get(sort_by or "", "daily_extraction_count")
    kwargs = dict(
        q=q,
        plan=plan,
        sort_col=sort_col,
        sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc",
    )
    count_result = await execute_with_reconnect(
        lambda d: _quota_usage_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_quota_usage"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _quota_usage_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_quota_usage.page"},
    )
    items = []
    for row in page_result.data or []:
        row = dict(row)
        user = row.pop("users", None) or {}
        sub = row.pop("subscriptions", None) or {}
        items.append(
            {
                **row,
                "email": user.get("email") if isinstance(user, dict) else None,
                "full_name": user.get("full_name") if isinstance(user, dict) else None,
                "custom_daily_quota": user.get("custom_daily_quota") if isinstance(user, dict) else None,
                "plan_type": sub.get("plan_type") if isinstance(sub, dict) else None,
            }
        )
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def set_quota_override(db: Any, user_id: str, daily_limit: Optional[int]) -> Dict[str, Any]:
    """Set (or clear with null) a per-user daily AI quota override."""
    user_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("id").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.quota_override.load", "user_id": user_id},
        )
    )
    if not user_row:
        raise UserNotFoundError(user_id)
    await execute_with_reconnect(
        lambda d: d.table("users").update({"custom_daily_quota": daily_limit}).eq("id", user_id).execute(),
        db,
        extra={"operation": "admin.quota_override.apply", "user_id": user_id},
    )
    return {"user_id": user_id, "custom_daily_quota": daily_limit}


# =============================================================================
# Dashboards
# =============================================================================


async def dashboard_overview(db: Any) -> Dict[str, Any]:
    """Signups/active/paid/job aggregates for the overview cards."""
    now = utcnow()
    d7 = (now - timedelta(days=7)).isoformat()
    d30 = (now - timedelta(days=30)).isoformat()

    async def _count(builder: Any) -> int:
        # builder(d) returns a query chain; the .execute() happens inside the
        # offloader lambda so the structural no-blocking-execute guard (see
        # tests/test_small_routes_async.py) sees it as off the event loop.
        res = await execute_with_reconnect(
            lambda d: builder(d).execute(),
            db,
            extra={"operation": "admin.dashboard_overview.count"},
        )
        return getattr(res, "count", 0) or 0

    signups_7d = await _count(lambda d: d.table("users").select("id", count="exact").gte("created_at", d7))
    signups_30d = await _count(lambda d: d.table("users").select("id", count="exact").gte("created_at", d30))
    active_7d = await _count(
        lambda d: d.table("users").select("id", count="exact").eq("is_active", True).gte("last_login_at", d7)
    )
    active_30d = await _count(
        lambda d: d.table("users").select("id", count="exact").eq("is_active", True).gte("last_login_at", d30)
    )
    paid = await _count(
        lambda d: d.table("subscriptions")
        .select("id", count="exact")
        .neq("plan_type", "free")
        .in_("status", ["active", "trial"])
    )

    # AI jobs last 7d: extraction_jobs (016/023) + photoshoot_jobs (023/035).
    # Success buckets differ per table ('completed' vs 'complete').
    extraction_total = await _count(
        lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7)
    )
    extraction_ok = await _count(
        lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7).in_("status", ["completed"])
    )
    extraction_failed = await _count(
        lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7).eq("status", "failed")
    )
    photoshoot_total = await _count(
        lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7)
    )
    photoshoot_ok = await _count(
        lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7).in_("status", ["complete"])
    )
    photoshoot_failed = await _count(
        lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7).eq("status", "failed")
    )

    return {
        "signups": {"7d": signups_7d, "30d": signups_30d},
        "active_users": {"7d": active_7d, "30d": active_30d},
        "paid_subscriptions": paid,
        "ai_jobs_7d": {
            "total": extraction_total + photoshoot_total,
            "succeeded": extraction_ok + photoshoot_ok,
            "failed": extraction_failed + photoshoot_failed,
        },
    }


async def _top_users_from_rpc(db: Any, rpc_name: str) -> List[Dict[str, Any]]:
    """Top-10 users by row count from a service-role aggregate RPC.

    PostgREST select-side aggregates are disabled on this project
    (db-aggregates-enabled = false) and the legacy bare-`count` shorthand
    emits SQL without GROUP BY (Postgres 42803), so grouped counts come from
    the hardened functions in migration 040_admin_dashboard_top_users.sql.
    """
    result = await execute_with_reconnect(
        lambda d: d.rpc(rpc_name).execute(),
        db,
        extra={"operation": f"admin.top_users.{rpc_name}"},
    )
    rows = sorted(
        result.data or [],
        key=lambda r: (-(r.get("count") or 0), r.get("user_id") or ""),
    )[:10]
    ids = [r.get("user_id") for r in rows if r.get("user_id")]
    users: Dict[str, Dict[str, Any]] = {}
    if ids:
        user_result = await execute_with_reconnect(
            lambda d: d.table("users").select("id,email,full_name").in_("id", ids).execute(),
            db,
            extra={"operation": f"admin.top_users.{rpc_name}.users"},
        )
        users = {u["id"]: u for u in user_result.data or []}
    out = []
    for row in rows:
        uid = row.get("user_id")
        out.append({**users.get(uid, {}), "user_id": uid, "count": row.get("count", 0)})
    return out


async def dashboard_top_users(db: Any) -> Dict[str, Any]:
    """Top-10 lists by outfits, items and referrals (service-role RPCs)."""
    top_outfits = await _top_users_from_rpc(db, "admin_top_users_outfits")
    top_items = await _top_users_from_rpc(db, "admin_top_users_items")
    top_referrers = await _top_users_from_rpc(db, "admin_top_users_referrals")
    return {"top_outfits": top_outfits, "top_items": top_items, "top_referrers": top_referrers}


async def dashboard_referrals(db: Any) -> Dict[str, Any]:
    """Referral totals: codes issued, redemptions, credits granted/pending."""
    async def _count(builder: Any) -> int:
        res = await execute_with_reconnect(
            lambda d: builder(d).execute(),
            db,
            extra={"operation": "admin.dashboard_referrals"},
        )
        return getattr(res, "count", 0) or 0

    codes_issued = await _count(lambda d: d.table("referral_codes").select("id", count="exact"))
    redemptions = await _count(lambda d: d.table("referral_redemptions").select("id", count="exact"))
    referrer_credits = await _count(
        lambda d: d.table("referral_redemptions").select("id", count="exact").eq("referrer_credit_applied", True)
    )
    referred_credits = await _count(
        lambda d: d.table("referral_redemptions").select("id", count="exact").eq("referred_credit_applied", True)
    )
    credits_granted = referrer_credits + referred_credits
    return {
        "codes_issued": codes_issued,
        "redemptions": redemptions,
        "credits_granted": credits_granted,
        "credits_pending": max(0, redemptions * 2 - credits_granted),
    }


# =============================================================================
# Revenue + trends (time-series dashboards)
# =============================================================================

TREND_DAYS_CHOICES = (7, 15, 30, 90)

# Churn/expiry lifecycle event types per billing source (webhook dedupe
# tables 022/030). Deliberately conservative: only unambiguous terminal
# events — Stripe cancellation, Apple EXPIRED/REVOKE, Google
# SUBSCRIPTION_EXPIRED/CANCELED/REVOKED.
STRIPE_CHURN_EVENT_TYPES = ("customer.subscription.deleted",)
APPLE_CHURN_EVENT_TYPES = ("EXPIRED", "REVOKE")
GOOGLE_CHURN_EVENT_TYPES = ("SUBSCRIPTION_EXPIRED", "SUBSCRIPTION_CANCELED", "SUBSCRIPTION_REVOKED")


def _monthly_mrr_amount(plan_type: str) -> float:
    """Monthly USD MRR contribution for a plan_type (yearly plans amortized)."""
    amount = PLAN_AMOUNTS.get(plan_type)
    if amount is None:
        return 0.0
    if plan_type.endswith("_yearly"):
        return round(amount / 12, 2)
    return amount


async def dashboard_revenue(db: Any) -> Dict[str, Any]:
    """Revenue snapshot: MRR estimate, paid/trial counts, churn events, refunds.

    MRR is an estimate derived from the configured plan prices
    (``PLAN_AMOUNTS``) — store rows do not carry amounts. "Churn" is a count
    of lifecycle churn events in the last 30 days (Stripe subscription
    deletions + Apple EXPIRED/REVOKE + Google expiry/cancel/revoke
    notifications), not a subscriber-level history (none exists).
    """
    now = utcnow()
    d30 = (now - timedelta(days=30)).isoformat()

    async def _count(builder: Any) -> int:
        res = await execute_with_reconnect(
            lambda d: builder(d).execute(),
            db,
            extra={"operation": "admin.dashboard_revenue.count"},
        )
        return getattr(res, "count", 0) or 0

    # All active paid rows — small enough to aggregate in Python, and it
    # avoids select-side aggregates (disabled on this project, see 040/041).
    subs_result = await execute_with_reconnect(
        lambda d: d.table("subscriptions")
        .select("plan_type,billing_provider")
        .neq("plan_type", "free")
        .eq("status", "active")
        .execute(),
        db,
        extra={"operation": "admin.dashboard_revenue.subscriptions"},
    )
    mrr_total = 0.0
    mrr_stripe = 0.0
    mrr_iap = 0.0
    paid = 0
    for row in subs_result.data or []:
        plan = row.get("plan_type")
        amount = _monthly_mrr_amount(str(plan)) if plan else 0.0
        provider = row.get("billing_provider")
        mrr_total += amount
        if provider == "stripe":
            mrr_stripe += amount
        elif provider in ("apple", "google"):
            mrr_iap += amount
        paid += 1

    trials = await _count(
        lambda d: d.table("subscriptions").select("id", count="exact").neq("plan_type", "free").eq("status", "trial")
    )
    churn_stripe = await _count(
        lambda d: d.table("stripe_webhook_events")
        .select("id", count="exact")
        .in_("event_type", STRIPE_CHURN_EVENT_TYPES)
        .gte("received_at", d30)
    )
    churn_apple = await _count(
        lambda d: d.table("apple_iap_events")
        .select("id", count="exact")
        .in_("event_type", APPLE_CHURN_EVENT_TYPES)
        .gte("received_at", d30)
    )
    churn_google = await _count(
        lambda d: d.table("google_rtdn_events")
        .select("id", count="exact")
        .in_("event_type", GOOGLE_CHURN_EVENT_TYPES)
        .gte("received_at", d30)
    )
    refunds = await _count(
        lambda d: d.table("audit_events")
        .select("id", count="exact")
        .in_("action", ["subscription.refunded", "iap.refund_marked"])
        .gte("created_at", d30)
    )
    churn_total = churn_stripe + churn_apple + churn_google

    return {
        "as_of": now.isoformat(),
        "mrr": {
            "total": round(mrr_total, 2),
            "stripe": round(mrr_stripe, 2),
            "iap": round(mrr_iap, 2),
        },
        "paid_subscriptions": paid,
        "trial_subscriptions": trials,
        "churn_events_30d": {
            "total": churn_total,
            "stripe": churn_stripe,
            "apple": churn_apple,
            "google": churn_google,
        },
        "refunds_30d": refunds,
    }


def _trend_days_axis(days: int) -> List[str]:
    """ISO dates ('YYYY-MM-DD') for the window, oldest first."""
    start = utc_today() - timedelta(days=days - 1)
    return [(start + timedelta(days=offset)).isoformat() for offset in range(days)]


def _trend_count_rows(rows: List[Dict[str, Any]], days: int) -> List[Dict[str, Any]]:
    """Zero-filled [{day, count}] over the window, ordered oldest first."""
    counts: Dict[str, int] = {}
    for row in rows:
        day = str(row.get("day") or "")[:10]
        if day:
            counts[day] = int(row.get("count") or 0)
    return [{"day": day, "count": counts.get(day, 0)} for day in _trend_days_axis(days)]


async def dashboard_trends(db: Any, days: int = 30) -> Dict[str, Any]:
    """Daily series over a 7/15/30/90-day window via the migration-041 RPCs."""
    if days not in TREND_DAYS_CHOICES:
        raise ValidationError(
            message=f"days must be one of {sorted(TREND_DAYS_CHOICES)}",
            details={"field": "days"},
        )
    rpc_names = ("admin_trend_signups", "admin_trend_jobs", "admin_trend_paid", "admin_trend_active")
    data: Dict[str, List[Dict[str, Any]]] = {}
    for name in rpc_names:
        # PostgREST matches RPC args by parameter name — the migration-041
        # functions declare `p_days` (codebase convention: p_-prefixed SQL
        # params, cf. promo/referral/quota RPC call sites).
        result = await execute_with_reconnect(
            lambda d: d.rpc(name, {"p_days": days}).execute(),
            db,
            extra={"operation": f"admin.dashboard_trends.{name}", "days": days},
        )
        data[name] = result.data or []

    # Jobs: aggregate per-kind rows (day, kind, total, succeeded, failed)
    # into one zero-filled per-day series.
    jobs_by_day: Dict[str, Dict[str, int]] = {}
    for row in data["admin_trend_jobs"]:
        day = str(row.get("day") or "")[:10]
        if not day:
            continue
        bucket = jobs_by_day.setdefault(day, {"total": 0, "succeeded": 0, "failed": 0})
        bucket["total"] += int(row.get("total") or 0)
        bucket["succeeded"] += int(row.get("succeeded") or 0)
        bucket["failed"] += int(row.get("failed") or 0)
    jobs: List[Dict[str, Any]] = []
    for day in _trend_days_axis(days):
        bucket = jobs_by_day.get(day, {"total": 0, "succeeded": 0, "failed": 0})
        jobs.append({"day": day, **bucket})

    # Paid: normalize providers (apple/google -> iap) and zero-fill each day
    # for both providers so the stacked chart is a clean rectangle.
    paid_counts: Dict[str, Dict[str, int]] = {}
    for row in data["admin_trend_paid"]:
        day = str(row.get("day") or "")[:10]
        if not day:
            continue
        provider = "stripe" if row.get("provider") == "stripe" else "iap"
        bucket = paid_counts.setdefault(day, {"stripe": 0, "iap": 0})
        bucket[provider] += int(row.get("count") or 0)
    paid: List[Dict[str, Any]] = []
    for day in _trend_days_axis(days):
        bucket = paid_counts.get(day, {"stripe": 0, "iap": 0})
        paid.append({"day": day, "provider": "stripe", "count": bucket["stripe"]})
        paid.append({"day": day, "provider": "iap", "count": bucket["iap"]})

    return {
        "days": days,
        "signups": _trend_count_rows(data["admin_trend_signups"], days),
        "jobs": jobs,
        "paid": paid,
        "active": _trend_count_rows(data["admin_trend_active"], days),
    }


# =============================================================================
# Promo codes
# =============================================================================

# Mirrors migration 031's promo_codes_code_format CHECK.
PROMO_CODE_RE = re.compile(r"^[a-zA-Z0-9][a-zA-Z0-9_-]{2,49}$")


def _promo_codes_builder(
    d: Any,
    *,
    q: Optional[str],
    active: Optional[bool],
    plan_type: Optional[str],
    sort_dir: str,
) -> Any:
    query = d.table("promo_codes").select("*", "promo_redemptions(count)", count="exact")
    if q:
        query = query.ilike("code", f"%{safe_search_term(q)}%")
    if active is not None:
        query = query.eq("active", active)
    if plan_type:
        query = query.eq("plan_type", plan_type)
    return query.order("created_at", desc=(sort_dir == "desc"))


async def list_promo_codes(
    db: Any,
    *,
    q: Optional[str] = None,
    active: Optional[bool] = None,
    plan_type: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    kwargs = dict(q=q, active=active, plan_type=plan_type, sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc")
    count_result = await execute_with_reconnect(
        lambda d: _promo_codes_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_promo_codes"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _promo_codes_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_promo_codes.page"},
    )
    items = []
    for row in page_result.data or []:
        row = dict(row)
        items.append(
            {
                **row,
                "redemptions_count": _extract_count(row.pop("promo_redemptions", None)),
            }
        )
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def create_promo_code(db: Any, data: Dict[str, Any]) -> Dict[str, Any]:
    """Create a promo code (validates format + duplicates; audit by the route)."""
    code = str(data.get("code") or "").strip()
    if not PROMO_CODE_RE.match(code):
        raise ValidationError(
            message="Code must be 3-50 characters (letters, digits, '-' or '_'), starting alphanumeric",
            details={"field": "code"},
        )
    duplicate = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("promo_codes").select("id").ilike("code", code).maybe_single().execute(),
            db,
            extra={"operation": "admin.create_promo_code.duplicate_check", "code": code},
        )
    )
    if duplicate:
        raise ValidationError(message=f"Promo code '{code}' already exists", details={"field": "code"})

    row = {**data, "code": code}
    try:
        result = await execute_with_reconnect(
            lambda d: d.table("promo_codes").insert(row).execute(),
            db,
            extra={"operation": "admin.create_promo_code.insert", "code": code},
        )
    except Exception as exc:  # noqa: BLE001 - map DB constraint errors to validation
        if "23505" in str(exc).lower() or "duplicate" in str(exc).lower():
            raise ValidationError(message=f"Promo code '{code}' already exists", details={"field": "code"}) from exc
        raise
    created = _first_row(result) or row
    return created


async def update_promo_code(db: Any, code_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Update a promo code's edit-safe subset; returns before/after for audit."""
    if not data:
        raise ValidationError(message="No fields provided", details={"fields": "Provide at least one field"})
    existing = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("promo_codes").select("*").eq("id", code_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.update_promo_code.load", "code_id": code_id},
        )
    )
    if not existing:
        raise NotFoundError(
            message=f"Promo code '{code_id}' not found",
            resource_type="promo_code",
            resource_id=code_id,
        )
    before = {key: existing.get(key) for key in data}
    result = await execute_with_reconnect(
        lambda d: d.table("promo_codes").update(data).eq("id", code_id).execute(),
        db,
        extra={"operation": "admin.update_promo_code.apply", "code_id": code_id},
    )
    updated = _first_row(result) or {**existing, **data}
    return {"before": before, "after": updated}


# =============================================================================
# Feedback (support tickets)
# =============================================================================


def _feedback_builder(
    d: Any,
    *,
    status: Optional[str],
    category: Optional[str],
    q: Optional[str],
    sort_dir: str,
) -> Any:
    query = d.table("support_tickets").select("*", "users(email,full_name)", count="exact")
    if status:
        query = query.eq("status", status)
    if category:
        query = query.eq("category", category)
    if q:
        term = f"%{safe_search_term(q)}%"
        query = query.or_(_or_ilike(("subject", "description"), term))
    return query.order("created_at", desc=(sort_dir == "desc"))


async def list_feedback(
    db: Any,
    *,
    status: Optional[str] = None,
    category: Optional[str] = None,
    q: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    kwargs = dict(status=status, category=category, q=q, sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc")
    count_result = await execute_with_reconnect(
        lambda d: _feedback_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_feedback"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _feedback_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_feedback.page"},
    )
    items = []
    for row in page_result.data or []:
        row = dict(row)
        user = row.pop("users", None) or {}
        items.append({**row, "user": user if isinstance(user, dict) else {}})
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def update_feedback(db: Any, ticket_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """Update a ticket's status / internal notes; returns before/after."""
    if not data:
        raise ValidationError(message="No fields provided", details={"fields": "Provide at least one field"})
    existing = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("support_tickets").select("*").eq("id", ticket_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.update_feedback.load", "ticket_id": ticket_id},
        )
    )
    if not existing:
        raise NotFoundError(
            message=f"Support ticket '{ticket_id}' not found",
            resource_type="support_ticket",
            resource_id=ticket_id,
        )
    before = {key: existing.get(key) for key in data}
    result = await execute_with_reconnect(
        lambda d: d.table("support_tickets").update(data).eq("id", ticket_id).execute(),
        db,
        extra={"operation": "admin.update_feedback.apply", "ticket_id": ticket_id},
    )
    updated = _first_row(result) or {**existing, **data}
    return {"before": before, "after": updated}


# =============================================================================
# Audit trail
# =============================================================================


def _audit_builder(
    d: Any,
    *,
    actor_id: Optional[str],
    action: Optional[str],
    entity_type: Optional[str],
    entity_id: Optional[str],
    created_from: Optional[str],
    created_to: Optional[str],
    sort_dir: str,
) -> Any:
    query = d.table("audit_events").select("*", "users(email,full_name)", count="exact")
    if actor_id:
        query = query.eq("actor_id", actor_id)
    if action:
        query = query.ilike("action", f"%{safe_search_term(action)}%")
    if entity_type:
        query = query.eq("entity_type", entity_type)
    if entity_id:
        query = query.eq("entity_id", entity_id)
    if created_from:
        query = query.gte("created_at", created_from)
    if created_to:
        query = query.lte("created_at", created_to)
    return query.order("created_at", desc=(sort_dir == "desc"))


async def list_audit_events(
    db: Any,
    *,
    actor_id: Optional[str] = None,
    action: Optional[str] = None,
    entity_type: Optional[str] = None,
    entity_id: Optional[str] = None,
    created_from: Optional[str] = None,
    created_to: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    kwargs = dict(
        actor_id=actor_id,
        action=action,
        entity_type=entity_type,
        entity_id=entity_id,
        created_from=created_from,
        created_to=created_to,
        sort_dir=sort_dir if sort_dir in ("asc", "desc") else "desc",
    )
    count_result = await execute_with_reconnect(
        lambda d: _audit_builder(d, **kwargs).execute(),
        db,
        extra={"operation": "admin.list_audit_events"},
    )
    total = getattr(count_result, "count", 0) or 0
    offset, end = _page_range(page, page_size)
    page_result = await execute_with_reconnect(
        lambda d: _audit_builder(d, **kwargs).range(offset, end).execute(),
        db,
        extra={"operation": "admin.list_audit_events.page"},
    )
    items = []
    for row in page_result.data or []:
        row = dict(row)
        actor = row.pop("users", None) or {}
        items.append({**row, "actor": actor if isinstance(actor, dict) else {}})
    return {"items": items, "total": total, "page": page, "page_size": page_size}


async def entity_audit_events(db: Any, entity_type: str, entity_id: str, limit: int = 100) -> List[Dict[str, Any]]:
    """Full history for one entity (e.g. a user or subscription)."""
    result = await execute_with_reconnect(
        lambda d: d.table("audit_events")
        .select("*", "users(email,full_name)")
        .eq("entity_type", entity_type)
        .eq("entity_id", entity_id)
        .order("created_at", desc=True)
        .limit(limit)
        .execute(),
        db,
        extra={"operation": "admin.entity_audit", "entity_type": entity_type, "entity_id": entity_id},
    )
    items = []
    for row in result.data or []:
        row = dict(row)
        actor = row.pop("users", None) or {}
        items.append({**row, "actor": actor if isinstance(actor, dict) else {}})
    return items


# =============================================================================
# Search
# =============================================================================

_SEARCH_LIMIT = 5


async def search_all(db: Any, q: str) -> Dict[str, Any]:
    """Top-5 hits per entity kind (users, blog posts, tickets, promo codes)."""
    term = f"%{safe_search_term(q)}%"

    users_result = await execute_with_reconnect(
        lambda d: d.table("users")
        .select("id,email,full_name,avatar_url,is_active,role,created_at")
        .or_(_or_ilike(("email", "full_name"), term))
        .limit(_SEARCH_LIMIT)
        .execute(),
        db,
        extra={"operation": "admin.search.users", "q": q},
    )
    posts_result = await execute_with_reconnect(
        lambda d: d.table("blog_posts")
        .select("id,slug,title,category,is_published,created_at")
        .or_(_or_ilike(("title", "excerpt"), term))
        .limit(_SEARCH_LIMIT)
        .execute(),
        db,
        extra={"operation": "admin.search.posts", "q": q},
    )
    tickets_result = await execute_with_reconnect(
        lambda d: d.table("support_tickets")
        .select("id,subject,category,status,created_at")
        .or_(_or_ilike(("subject", "description"), term))
        .limit(_SEARCH_LIMIT)
        .execute(),
        db,
        extra={"operation": "admin.search.tickets", "q": q},
    )
    codes_result = await execute_with_reconnect(
        lambda d: d.table("promo_codes")
        .select("id,code,plan_type,active,used_count,expires_at,created_at")
        .ilike("code", term)
        .limit(_SEARCH_LIMIT)
        .execute(),
        db,
        extra={"operation": "admin.search.promo_codes", "q": q},
    )

    return {
        "users": users_result.data or [],
        "posts": posts_result.data or [],
        "tickets": tickets_result.data or [],
        "promo_codes": codes_result.data or [],
    }


# =============================================================================
# Settings (safe deployment info — whitelist only, never secrets)
# =============================================================================


def deployment_settings() -> Dict[str, Any]:
    """Read-only deployment info. Explicit whitelist: no keys/tokens ever."""
    feature_toggles: Dict[str, bool] = {}
    for name in dir(settings):
        if name.startswith("ENABLE_"):
            try:
                feature_toggles[name] = bool(getattr(settings, name))
            except Exception:  # noqa: BLE001 - a broken toggle must not 500 settings
                continue
    return {
        "app_name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "commit": settings.RAILWAY_GIT_COMMIT_SHA,
        "environment": "production" if not settings.DEBUG else "development",
        "feature_toggles": feature_toggles,
        "billing": {
            # Booleans only — presence, never values.
            "stripe": bool(settings.STRIPE_SECRET_KEY),
            "apple": bool(settings.APPLE_PRIVATE_KEY and settings.APPLE_ISSUER_ID and settings.APPLE_KEY_ID),
            "google": bool(settings.GOOGLE_SERVICE_ACCOUNT_JSON),
        },
        "storage": {
            "bucket": settings.OBJECT_STORAGE_BUCKET,
            "serving_mode": settings.IMAGE_SERVING_MODE,
            "presign_ttl_seconds": settings.OBJECT_STORAGE_PRESIGN_TTL,
            "configured": bool(settings.OBJECT_STORAGE_ENDPOINT),
        },
        "limits": {
            "free_monthly": {
                "extractions": settings.PLAN_FREE_MONTHLY_EXTRACTIONS,
                "generations": settings.PLAN_FREE_MONTHLY_GENERATIONS,
                "embeddings": settings.PLAN_FREE_MONTHLY_EMBEDDINGS,
            },
            "plus_monthly": {
                "extractions": settings.PLAN_PLUS_MONTHLY_EXTRACTIONS,
                "generations": settings.PLAN_PLUS_MONTHLY_GENERATIONS,
                "embeddings": settings.PLAN_PLUS_MONTHLY_EMBEDDINGS,
            },
            "pro_monthly": {
                "extractions": settings.PLAN_PRO_MONTHLY_EXTRACTIONS,
                "generations": settings.PLAN_PRO_MONTHLY_GENERATIONS,
                "embeddings": settings.PLAN_PRO_MONTHLY_EMBEDDINGS,
            },
        },
    }


# =============================================================================
# Ops (storage temp inventory / cleanup)
# =============================================================================

# Bounded scan: at most this many S3 list pages (each ~1000 keys) per call.
TEMP_SCAN_MAX_PAGES = 50
# Safety cap on objects deleted per cleanup call (spec: 5,000).
TEMP_DELETE_MAX_OBJECTS = 5000


def _object_storage_configured() -> bool:
    return bool(settings.OBJECT_STORAGE_ENDPOINT)


async def storage_temp_inventory(db: Any) -> Dict[str, Any]:
    """Bounded inventory of temp preview objects (``{user_id}/tmp/...``).

    Returns all temp objects found in the scanned range under ``items``; the
    route truncates the payload for display. ``db`` is accepted for signature
    symmetry but the scan talks to object storage, not Postgres.
    """
    from app.services.storage_service import StorageService

    if not _object_storage_configured():
        raise StorageServiceError(
            message="Object storage is not configured for this deployment",
        )
    return await StorageService.list_temp_objects(max_pages=TEMP_SCAN_MAX_PAGES)


async def storage_temp_cleanup(db: Any) -> Dict[str, Any]:
    """Delete temp objects up to TEMP_DELETE_MAX_OBJECTS; returns stats."""
    from app.services.storage_service import StorageService

    if not _object_storage_configured():
        raise StorageServiceError(
            message="Object storage is not configured for this deployment",
        )
    inventory = await StorageService.list_temp_objects(max_pages=TEMP_SCAN_MAX_PAGES)
    keys = [item["key"] for item in inventory["items"]][:TEMP_DELETE_MAX_OBJECTS]
    if not keys:
        return {
            "deleted": 0,
            "bytes_freed": 0,
            "remaining": inventory["count"],
            "truncated": False,
        }
    deleted = await StorageService.delete_temp_objects(keys)
    size_by_key = {item["key"]: int(item.get("size") or 0) for item in inventory["items"]}
    bytes_freed = sum(size_by_key.get(key, 0) for key in keys)
    remaining = max(0, inventory["count"] - len(keys))
    return {
        "deleted": deleted,
        "bytes_freed": bytes_freed,
        "remaining": remaining,
        "truncated": remaining > 0 or inventory["truncated"],
    }
