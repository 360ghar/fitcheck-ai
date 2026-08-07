"""
Admin subscriptions: list, per-user detail, Stripe refunds.
"""

from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import (
    AdminRefundResponse,
    AdminSubscriptionDetail,
    AdminSubscriptionListItem,
    PageResponse,
)
from app.services.admin_service import (
    get_user_subscription,
    list_subscriptions,
    refund_subscription,
)
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/subscriptions", response_model=PageResponse[AdminSubscriptionListItem])
async def list_admin_subscriptions(
    plan: Optional[str] = Query(None, min_length=1, max_length=20),
    status: Optional[str] = Query(None, min_length=1, max_length=20),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_by: Literal["created_at", "current_period_start", "plan_type", "status"] = Query("created_at"),
    sort_dir: Literal["asc", "desc"] = Query("desc"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("subscriptions.read")),
) -> PageResponse[AdminSubscriptionListItem]:
    """Paginated subscriptions with user email and display amount."""
    result = await list_subscriptions(
        db,
        plan=plan,
        status=status,
        page=page,
        page_size=page_size,
        sort_by=sort_by,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminSubscriptionListItem](
        items=[AdminSubscriptionListItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.get("/subscriptions/user/{user_id}", response_model=AdminSubscriptionDetail)
async def admin_subscription_detail(
    user_id: str,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("subscriptions.read")),
) -> AdminSubscriptionDetail:
    """Full subscription detail incl. provider identifiers + current usage."""
    result = await get_user_subscription(db, user_id)
    return AdminSubscriptionDetail(**result)


@router.post("/subscriptions/user/{user_id}/refund", response_model=AdminRefundResponse)
async def admin_subscription_refund(
    user_id: str,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("subscriptions.refund")),
) -> AdminRefundResponse:
    """Refund the user's latest Stripe charge (full refund).

    Only Stripe-billed subscriptions carry a Stripe customer; store-billed
    rows are rejected with a validation error. The refund is audit-logged.
    """
    result = await refund_subscription(db, user_id)
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="subscription.refunded",
        entity_type="subscription",
        entity_id=user_id,
        payload={
            "refund_id": result["refund_id"],
            "payment_intent": result.get("payment_intent"),
            "charge_id": result.get("charge_id"),
            "amount": result["amount"],
            "currency": result["currency"],
        },
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return AdminRefundResponse(**result)
