"""Customer and public APIs for FitCheck Pro gift vouchers."""

from __future__ import annotations

from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, Query, Request, Response, status
from supabase import Client

from app.api.v1.deps import get_current_user, get_db
from app.core.ip_rate_limit import auth_rate_limited_operation
from app.models.gift import (
    ComplimentaryGiftCreate,
    GiftCheckoutFulfill,
    GiftClaimRequest,
    GiftUpdate,
    PaidGiftCheckoutCreate,
)
from app.services.gift_service import GiftService

router = APIRouter()


@router.get("/catalog")
async def catalog() -> dict[str, Any]:
    """Return fixed USD gift terms and paid-checkout availability."""
    return {
        "data": [item.model_dump(mode="json") for item in GiftService.catalog()],
        "message": "OK",
    }


@router.get("/public/{public_id}")
async def get_public_gift(
    public_id: UUID,
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    """Return presentation and lifecycle state without private account data."""
    voucher = await GiftService.get_public(str(public_id), db)
    return {"data": voucher.model_dump(mode="json", exclude_none=True), "message": "OK"}


@router.get("/public/{public_id}/artwork/og.png", response_class=Response)
async def get_public_gift_artwork(
    public_id: UUID,
    db: Client = Depends(get_db),
) -> Response:
    """Return the versioned 1200 x 630 social preview."""
    image = await GiftService.public_artwork(str(public_id), db)
    return Response(
        content=image,
        media_type="image/png",
        headers={
            "Cache-Control": "public, max-age=3600, stale-while-revalidate=86400",
            "X-Robots-Tag": "noindex, nofollow",
        },
    )


@router.get("/allowances")
async def get_allowances(
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    allowances = await GiftService.get_allowances(user, db)
    return {
        "data": [item.model_dump(mode="json") for item in allowances],
        "message": "OK",
    }


@router.get("/sent")
async def list_sent_gifts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    result = await GiftService.list_for_user(
        str(user["id"]), db, received=False, page=page, page_size=page_size
    )
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.get("/received")
async def list_received_gifts(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    result = await GiftService.list_for_user(
        str(user["id"]), db, received=True, page=page, page_size=page_size
    )
    return {"data": result.model_dump(mode="json"), "message": "OK"}


@router.post("/complimentary", status_code=status.HTTP_201_CREATED)
async def create_complimentary_gift(
    body: ComplimentaryGiftCreate,
    http_request: Request,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    async with auth_rate_limited_operation(http_request, "gift creation"):
        voucher = await GiftService.create_complimentary(user, body, db)
    return {"data": voucher.model_dump(mode="json"), "message": "Gift created"}


@router.post("/checkout", status_code=status.HTTP_201_CREATED)
async def create_paid_gift_checkout(
    body: PaidGiftCheckoutCreate,
    http_request: Request,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    async with auth_rate_limited_operation(http_request, "gift creation"):
        result = await GiftService.create_paid_checkout(user, body, db)
    return {"data": result, "message": "Checkout created"}


@router.post("/checkout/fulfill")
async def fulfill_paid_gift_checkout(
    body: GiftCheckoutFulfill,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    voucher = await GiftService.fulfill_checkout(
        body.session_id,
        db,
        expected_user_id=str(user["id"]),
    )
    return {"data": voucher.model_dump(mode="json"), "message": "Gift ready"}


@router.post("/claim")
async def claim_gift(
    body: GiftClaimRequest,
    http_request: Request,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    async with auth_rate_limited_operation(http_request, "gift claim"):
        result = await GiftService.claim(user, body.public_id, body.secret, db)
    return {"data": result.model_dump(mode="json"), "message": "Gift claimed"}


@router.get("/{voucher_id}")
async def get_owned_gift(
    voucher_id: UUID,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    voucher = await GiftService.get_owned(str(voucher_id), str(user["id"]), db)
    return {
        "data": GiftService.serialize(voucher, audience="owner").model_dump(mode="json"),
        "message": "OK",
    }


@router.patch("/{voucher_id}")
async def update_owned_gift(
    voucher_id: UUID,
    body: GiftUpdate,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    voucher = await GiftService.update_presentation(
        str(voucher_id), str(user["id"]), body, db
    )
    return {"data": voucher.model_dump(mode="json"), "message": "Gift updated"}


@router.post("/{voucher_id}/rotate")
async def rotate_owned_gift_link(
    voucher_id: UUID,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> dict[str, Any]:
    voucher = await GiftService.rotate_link(str(voucher_id), str(user["id"]), db)
    return {"data": voucher.model_dump(mode="json"), "message": "Gift link rotated"}


@router.get("/{voucher_id}/artwork/portrait.png", response_class=Response)
async def download_owned_gift_artwork(
    voucher_id: UUID,
    user: dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
) -> Response:
    image = await GiftService.portrait_artwork(str(voucher_id), str(user["id"]), db)
    return Response(
        content=image,
        media_type="image/png",
        headers={
            "Cache-Control": "private, max-age=3600",
            "Content-Disposition": f'attachment; filename="fitcheck-pro-gift-{voucher_id}.png"',
            "X-Robots-Tag": "noindex, nofollow",
        },
    )
