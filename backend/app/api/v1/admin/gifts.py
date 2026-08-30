"""Admin gift voucher reporting and audited explicit actions."""

from __future__ import annotations

from datetime import date, datetime, time, timezone
from typing import Any, Dict, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request, Response, status
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import PageResponse
from app.models.gift import (
    AdminGiftAction,
    AdminGiftAllowanceAdjust,
    AdminGiftAssign,
    AdminGiftCreate,
    GiftUpdate,
)
from app.services.admin_gift_service import AdminGiftService
from app.services.audit_service import record_audit

router = APIRouter(prefix="/gifts")


def _request_audit(request: Request) -> dict[str, Optional[str]]:
    return {
        "ip": request.client.host if request.client else None,
        "user_agent": request.headers.get("user-agent"),
    }


def _date_bounds(
    created_from: Optional[date], created_to: Optional[date]
) -> tuple[Optional[datetime], Optional[datetime]]:
    start = (
        datetime.combine(created_from, time.min, tzinfo=timezone.utc)
        if created_from
        else None
    )
    end = (
        datetime.combine(created_to, time.max, tzinfo=timezone.utc)
        if created_to
        else None
    )
    return start, end


@router.get("/summary")
async def gift_summary(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.read")),
) -> dict[str, Any]:
    del user
    return await AdminGiftService.summary(db)


@router.get("/export.csv", response_class=Response)
async def export_gifts(
    q: Optional[str] = Query(None, min_length=1, max_length=100),
    source: Optional[str] = Query(None, pattern="^(paid|complimentary|admin)$"),
    duration_months: Optional[int] = Query(None),
    gift_status: Optional[str] = Query(None, alias="status", max_length=24),
    created_from: Optional[date] = Query(None),
    created_to: Optional[date] = Query(None),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.read")),
) -> Response:
    del user
    created_from_at, created_to_at = _date_bounds(created_from, created_to)
    content = await AdminGiftService.export_csv(
        db,
        q=q,
        source=source,
        duration_months=duration_months,
        status=gift_status,
        created_from=created_from_at,
        created_to=created_to_at,
    )
    return Response(
        content=content,
        media_type="text/csv",
        headers={"Content-Disposition": 'attachment; filename="gift-vouchers.csv"'},
    )


@router.get("", response_model=PageResponse[Dict[str, Any]])
async def list_gifts(
    q: Optional[str] = Query(None, min_length=1, max_length=100),
    source: Optional[str] = Query(None, pattern="^(paid|complimentary|admin)$"),
    duration_months: Optional[int] = Query(None),
    gift_status: Optional[str] = Query(None, alias="status", max_length=24),
    created_from: Optional[date] = Query(None),
    created_to: Optional[date] = Query(None),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.read")),
) -> PageResponse[Dict[str, Any]]:
    del user
    created_from_at, created_to_at = _date_bounds(created_from, created_to)
    result = await AdminGiftService.list(
        db,
        q=q,
        source=source,
        duration_months=duration_months,
        status=gift_status,
        created_from=created_from_at,
        created_to=created_to_at,
        page=page,
        page_size=page_size,
    )
    return PageResponse[Dict[str, Any]](**result)


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_gift(
    body: AdminGiftCreate,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.create(str(user["id"]), body, db)
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action="gift.created",
        entity_type="gift_voucher",
        entity_id=result["id"],
        payload={"source": "admin", "duration_months": body.duration_months, "note": body.note},
        **_request_audit(http_request),
    )
    return result


@router.post("/allowances/{user_id}")
async def adjust_gift_allowance(
    user_id: UUID,
    body: AdminGiftAllowanceAdjust,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.adjust_allowance(
        str(user_id), body.duration_months, body.add_count, db
    )
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action="gift.allowance_adjusted",
        entity_type="user",
        entity_id=str(user_id),
        payload=body.model_dump(mode="json"),
        **_request_audit(http_request),
    )
    return result


@router.get("/{voucher_id}")
async def get_gift(
    voucher_id: UUID,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.read")),
) -> dict[str, Any]:
    del user
    return await AdminGiftService.get(str(voucher_id), db)


@router.patch("/{voucher_id}")
async def update_gift(
    voucher_id: UUID,
    body: GiftUpdate,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.update(str(voucher_id), body, db)
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action="gift.presentation_updated",
        entity_type="gift_voucher",
        entity_id=str(voucher_id),
        payload=body.model_dump(exclude_unset=True),
        **_request_audit(http_request),
    )
    return result


@router.post("/{voucher_id}/rotate")
async def rotate_gift(
    voucher_id: UUID,
    body: AdminGiftAction,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.rotate(str(voucher_id), db)
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action="gift.link_rotated",
        entity_type="gift_voucher",
        entity_id=str(voucher_id),
        payload={"reason": body.reason},
        **_request_audit(http_request),
    )
    return result


@router.post("/{voucher_id}/assign")
async def assign_gift(
    voucher_id: UUID,
    body: AdminGiftAssign,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.assign(str(voucher_id), str(body.user_id), db)
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action="gift.assigned",
        entity_type="gift_voucher",
        entity_id=str(voucher_id),
        payload={"recipient_user_id": str(body.user_id), "reason": body.reason},
        **_request_audit(http_request),
    )
    return result


@router.post("/{voucher_id}/void-or-revoke")
async def void_or_revoke_gift(
    voucher_id: UUID,
    body: AdminGiftAction,
    http_request: Request,
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("gifts.write")),
) -> dict[str, Any]:
    result = await AdminGiftService.void_or_revoke(str(voucher_id), body.reason, db)
    await record_audit(
        db,
        actor_id=str(user["id"]),
        action=f"gift.{result['status']}",
        entity_type="gift_voucher",
        entity_id=str(voucher_id),
        payload={"reason": body.reason},
        **_request_audit(http_request),
    )
    return result
