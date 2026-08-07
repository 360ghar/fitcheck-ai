"""
Admin dashboards: overview metrics, top-user lists, referral totals, revenue,
time-series trends.
"""

from typing import Any, Dict

from fastapi import APIRouter, Depends, Query
from supabase import Client

from app.api.v1.deps import get_db, require_permission
from app.models.admin import (
    AdminOverviewResponse,
    AdminReferralsResponse,
    AdminRevenueResponse,
    AdminTopUsersResponse,
    AdminTrendsResponse,
)
from app.services.admin_service import (
    dashboard_overview,
    dashboard_referrals,
    dashboard_revenue,
    dashboard_top_users,
    dashboard_trends,
)

router = APIRouter()


@router.get("/dashboards/overview", response_model=AdminOverviewResponse)
async def overview(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("dashboards.read")),
) -> AdminOverviewResponse:
    """Signups / active users / paid subscriptions / AI jobs aggregates."""
    result = await dashboard_overview(db)
    return AdminOverviewResponse(**result)


@router.get("/dashboards/top-users", response_model=AdminTopUsersResponse)
async def top_users(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("dashboards.read")),
) -> AdminTopUsersResponse:
    """Top-10 users by outfits, items and referrals."""
    result = await dashboard_top_users(db)
    return AdminTopUsersResponse(**result)


@router.get("/dashboards/referrals", response_model=AdminReferralsResponse)
async def referrals(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("dashboards.read")),
) -> AdminReferralsResponse:
    """Referral totals: codes issued, redemptions, credits granted/pending."""
    result = await dashboard_referrals(db)
    return AdminReferralsResponse(**result)


@router.get("/dashboards/revenue", response_model=AdminRevenueResponse)
async def revenue(
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("dashboards.read")),
) -> AdminRevenueResponse:
    """MRR estimate (Stripe vs IAP), paid/trial counts, churn events, refunds."""
    result = await dashboard_revenue(db)
    return AdminRevenueResponse(**result)


@router.get("/dashboards/trends", response_model=AdminTrendsResponse)
async def trends(
    days: int = Query(30, description="Window in days (7, 15, 30, or 90)"),
    db: Client = Depends(get_db),
    user: Dict[str, Any] = Depends(require_permission("dashboards.read")),
) -> AdminTrendsResponse:
    """Daily signups / AI jobs / paid / active series over the window."""
    result = await dashboard_trends(db, days=days)
    return AdminTrendsResponse(**result)
