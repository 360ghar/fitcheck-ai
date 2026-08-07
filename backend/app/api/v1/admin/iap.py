"""
Admin IAP: store-billed (Apple / Google) transactions.

Store transactions live on the ``subscriptions`` rows with
``billing_provider IN ('apple','google')`` (migration 030); the provider
identifiers (apple_original_transaction_id / google_order_id /
google_purchase_token) are the transaction ids surfaced here.
"""

from typing import Any, Dict, Literal, Optional

from fastapi import APIRouter, Depends, Query, Request
from supabase import Client

from app.api.v1.deps import get_db, require_admin, require_permission
from app.models.admin import (
    AdminIapTransactionListItem,
    PageResponse,
)
from app.services.admin_service import (
    get_iap_transaction,
    list_iap_transactions,
    mark_iap_refunded,
)
from app.services.audit_service import record_audit

router = APIRouter()


@router.get("/iap/transactions", response_model=PageResponse[AdminIapTransactionListItem])
async def list_admin_iap_transactions(
    platform: Optional[Literal["apple", "google"]] = Query(None),
    status: Optional[str] = Query(None, min_length=1, max_length=20),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    sort_dir: Literal["asc", "desc"] = Query("desc"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("iap.read")),
) -> PageResponse[AdminIapTransactionListItem]:
    """Paginated store transactions (Apple App Store / Google Play)."""
    result = await list_iap_transactions(
        db,
        platform=platform,
        status=status,
        page=page,
        page_size=page_size,
        sort_dir=sort_dir,
    )
    return PageResponse[AdminIapTransactionListItem](
        items=[AdminIapTransactionListItem(**item) for item in result["items"]],
        total=result["total"],
        page=result["page"],
        page_size=result["page_size"],
    )


@router.get("/iap/transactions/{txn_id}", response_model=Dict[str, Any])
async def admin_iap_transaction_detail(
    txn_id: str,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("iap.read")),
) -> Dict[str, Any]:
    """IAP transaction detail (looked up by any provider identifier)."""
    return await get_iap_transaction(db, txn_id)


@router.post("/iap/transactions/{txn_id}/mark-refunded", response_model=Dict[str, Any])
async def admin_iap_mark_refunded(
    txn_id: str,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_admin),
) -> Dict[str, Any]:
    """Mark a store transaction refunded (status-only update + audit).

    Store-side refunds arrive via webhooks; this endpoint only records the
    refunded state for the admin UI.
    """
    result = await mark_iap_refunded(db, txn_id)
    await record_audit(
        db,
        actor_id=user.get("id"),
        action="iap.refund_marked",
        entity_type="iap_transaction",
        entity_id=txn_id,
        payload={
            "before_status": result["before_status"],
            "after_status": result["after_status"],
            "subscription_id": result["transaction"].get("id"),
        },
        ip=http_request.client.host if http_request.client else None,
        user_agent=http_request.headers.get("user-agent"),
    )
    return result
