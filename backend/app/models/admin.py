"""
Pydantic schemas for the admin API (``/api/v1/admin/*``).

Response convention for list endpoints::

    {"items": [...], "total": int, "page": int, "page_size": int}

Item models use ``extra="allow"`` so extra DB columns survive serialization
and the OpenAPI contract stays stable even when a row carries columns this
schema does not name.
"""

from __future__ import annotations

from datetime import datetime
from typing import Any, Dict, Generic, List, Literal, Optional, TypeVar

from pydantic import BaseModel, ConfigDict, Field

T = TypeVar("T")

# =============================================================================
# Common envelope
# =============================================================================


class PageResponse(BaseModel, Generic[T]):
    """Standard paginated list envelope for admin endpoints."""

    items: List[T]
    total: int
    page: int = Field(ge=1)
    page_size: int = Field(ge=1, le=100)


class AdminMeResponse(BaseModel):
    """GET /admin/me — session bootstrap payload."""

    user: Dict[str, Any]
    role: str
    permissions: List[str]

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Users
# =============================================================================


class AdminUserListItem(BaseModel):
    """One row of GET /admin/users."""

    id: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    is_active: Optional[bool] = None
    is_admin: Optional[bool] = None
    role: Optional[str] = None
    custom_daily_quota: Optional[int] = None
    created_at: Optional[Any] = None
    updated_at: Optional[Any] = None
    last_login_at: Optional[Any] = None
    email_verified: Optional[bool] = None
    # Embedded: subscription(plan_type, status, ...), outfits(count),
    # items(count) — merged by the service.
    subscription: Optional[Dict[str, Any]] = None
    outfits_count: Optional[int] = None
    items_count: Optional[int] = None

    model_config = ConfigDict(extra="allow")


class AdminUserDetail(BaseModel):
    """GET /admin/users/{user_id} — full profile detail."""

    user: Dict[str, Any]
    subscription: Optional[Dict[str, Any]] = None
    usage: Dict[str, Any] = Field(default_factory=dict)
    counts: Dict[str, Any] = Field(default_factory=dict)
    recent_jobs: List[Dict[str, Any]] = Field(default_factory=list)

    model_config = ConfigDict(extra="allow")


class AdminUserPatch(BaseModel):
    """PATCH /admin/users/{user_id} body.

    ``role`` must be one of the admin roles or ``user``; ``is_admin`` and
    ``is_active`` are the legacy flag / suspension toggle. All fields optional;
    at least one must be present.
    """

    is_admin: Optional[bool] = None
    role: Optional[str] = Field(None, min_length=1, max_length=50)
    is_active: Optional[bool] = None


class AdminUserActivity(BaseModel):
    """GET /admin/users/{user_id}/activity."""

    user_id: str
    audit_events: List[Dict[str, Any]] = Field(default_factory=list)
    recent_jobs: List[Dict[str, Any]] = Field(default_factory=list)

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Subscriptions
# =============================================================================


class AdminSubscriptionListItem(BaseModel):
    """One row of GET /admin/subscriptions."""

    id: str
    user_id: str
    plan_type: Optional[str] = None
    status: Optional[str] = None
    billing_provider: Optional[str] = None
    current_period_start: Optional[Any] = None
    current_period_end: Optional[Any] = None
    cancel_at_period_end: Optional[bool] = None
    trial_end: Optional[Any] = None
    referral_credit_months: Optional[int] = None
    created_at: Optional[Any] = None
    updated_at: Optional[Any] = None
    user: Optional[Dict[str, Any]] = None
    # Display amount (USD) derived from configured plan pricing; None for
    # free/unknown plans.
    amount: Optional[float] = None

    model_config = ConfigDict(extra="allow")


class AdminSubscriptionDetail(BaseModel):
    """GET /admin/subscriptions/user/{user_id}."""

    subscription: Dict[str, Any]
    user: Dict[str, Any] = Field(default_factory=dict)
    usage: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="allow")


class AdminRefundResponse(BaseModel):
    """POST /admin/subscriptions/user/{user_id}/refund."""

    refund_id: str
    payment_intent: Optional[str] = None
    charge_id: Optional[str] = None
    amount: int
    currency: str
    status: str

    model_config = ConfigDict(extra="allow")


# =============================================================================
# IAP transactions
# =============================================================================


class AdminIapTransactionListItem(BaseModel):
    """One row of GET /admin/iap/transactions (store-billed subscriptions)."""

    subscription_id: str
    transaction_id: Optional[str] = None
    user_id: str
    user_email: Optional[str] = None
    platform: Optional[str] = None
    billing_product_id: Optional[str] = None
    plan_type: Optional[str] = None
    status: Optional[str] = None
    created_at: Optional[Any] = None
    amount: Optional[float] = None

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Quotas
# =============================================================================


class AdminQuotaUsageItem(BaseModel):
    """One row of GET /admin/quotas (today's per-user AI usage)."""

    user_id: str
    email: Optional[str] = None
    full_name: Optional[str] = None
    plan_type: Optional[str] = None
    daily_extraction_count: Optional[int] = None
    daily_generation_count: Optional[int] = None
    daily_embedding_count: Optional[int] = None
    daily_photoshoot_images: Optional[int] = None
    last_reset_date: Optional[Any] = None
    custom_daily_quota: Optional[int] = None

    model_config = ConfigDict(extra="allow")


class AdminQuotaOverride(BaseModel):
    """PATCH /admin/users/{user_id}/quota-override body.

    ``daily_limit`` = new per-user daily AI limit; pass null to clear the
    override and fall back to the plan default.
    """

    daily_limit: Optional[int] = Field(None, ge=1)


# =============================================================================
# Promo codes
# =============================================================================


class AdminPromoCodeCreate(BaseModel):
    """POST /admin/promo-codes body (mirrors migration 031 constraints)."""

    code: str = Field(..., min_length=3, max_length=50)
    plan_type: Literal["plus_monthly", "plus_yearly", "pro_monthly", "pro_yearly"]
    months: int = Field(1, ge=1)
    max_uses: Optional[int] = Field(None, gt=0)
    expires_at: Optional[datetime] = None
    active: bool = True


class AdminPromoCodeUpdate(BaseModel):
    """PATCH /admin/promo-codes/{code_id} body — edit-safe subset."""

    active: Optional[bool] = None
    max_uses: Optional[int] = Field(None, gt=0)
    expires_at: Optional[datetime] = None
    months: Optional[int] = Field(None, ge=1)
    plan_type: Optional[Literal["plus_monthly", "plus_yearly", "pro_monthly", "pro_yearly"]] = None


# =============================================================================
# Feedback
# =============================================================================


class AdminFeedbackListItem(BaseModel):
    """One row of GET /admin/feedback (support tickets)."""

    id: str
    user_id: Optional[str] = None
    category: Optional[str] = None
    subject: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    app_platform: Optional[str] = None
    app_version: Optional[str] = None
    contact_email: Optional[str] = None
    internal_notes: Optional[str] = None
    created_at: Optional[Any] = None
    updated_at: Optional[Any] = None
    user: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(extra="allow")


class AdminFeedbackUpdate(BaseModel):
    """PATCH /admin/feedback/{ticket_id} body."""

    status: Optional[Literal["open", "in_progress", "resolved", "closed"]] = None
    internal_notes: Optional[str] = Field(None, max_length=10000)


# =============================================================================
# Audit
# =============================================================================


class AdminAuditEventItem(BaseModel):
    """One row of GET /admin/audit."""

    id: str
    actor_id: Optional[str] = None
    action: str
    entity_type: str
    entity_id: Optional[str] = None
    payload: Dict[str, Any] = Field(default_factory=dict)
    ip: Optional[str] = None
    user_agent: Optional[str] = None
    created_at: Optional[Any] = None
    actor: Optional[Dict[str, Any]] = None

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Search
# =============================================================================


class AdminSearchResponse(BaseModel):
    """GET /admin/search — top-5 hits per entity kind."""

    users: List[Dict[str, Any]] = Field(default_factory=list)
    posts: List[Dict[str, Any]] = Field(default_factory=list)
    tickets: List[Dict[str, Any]] = Field(default_factory=list)
    promo_codes: List[Dict[str, Any]] = Field(default_factory=list)

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Dashboards
# =============================================================================


class AdminOverviewResponse(BaseModel):
    """GET /admin/dashboards/overview."""

    signups: Dict[str, int] = Field(default_factory=dict)
    active_users: Dict[str, int] = Field(default_factory=dict)
    paid_subscriptions: int = 0
    ai_jobs_7d: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="allow")


class AdminTopUsersResponse(BaseModel):
    """GET /admin/dashboards/top-users."""

    top_outfits: List[Dict[str, Any]] = Field(default_factory=list)
    top_items: List[Dict[str, Any]] = Field(default_factory=list)
    top_referrers: List[Dict[str, Any]] = Field(default_factory=list)

    model_config = ConfigDict(extra="allow")


class AdminReferralsResponse(BaseModel):
    """GET /admin/dashboards/referrals."""

    codes_issued: int = 0
    redemptions: int = 0
    credits_granted: int = 0
    credits_pending: int = 0

    model_config = ConfigDict(extra="allow")


class AdminRevenueResponse(BaseModel):
    """GET /admin/dashboards/revenue — MRR estimate + paid/trial + churn.

    ``mrr`` is ``{total, stripe, iap}`` in USD, an estimate derived from the
    configured plan prices (store rows do not carry amounts). ``churn_events_30d``
    is ``{total, stripe, apple, google}`` lifecycle event counts (Stripe
    ``customer.subscription.deleted`` + store expiry/revoke notifications).
    """

    as_of: Optional[Any] = None
    mrr: Dict[str, float] = Field(default_factory=dict)
    paid_subscriptions: int = 0
    trial_subscriptions: int = 0
    churn_events_30d: Dict[str, int] = Field(default_factory=dict)
    refunds_30d: int = 0

    model_config = ConfigDict(extra="allow")


class AdminTrendsResponse(BaseModel):
    """GET /admin/dashboards/trends — daily series over a 30/90-day window.

    ``signups``/``active`` are ``[{day, count}]`` (zero-filled),
    ``jobs`` is ``[{day, total, succeeded, failed}]`` (zero-filled), and
    ``paid`` is ``[{day, provider, count}]`` with provider ``stripe`` or
    ``iap`` (zero-filled per day per provider).
    """

    days: int = 30
    signups: List[Dict[str, Any]] = Field(default_factory=list)
    jobs: List[Dict[str, Any]] = Field(default_factory=list)
    paid: List[Dict[str, Any]] = Field(default_factory=list)
    active: List[Dict[str, Any]] = Field(default_factory=list)

    model_config = ConfigDict(extra="allow")


# =============================================================================
# Ops + settings
# =============================================================================


class AdminOpsHealthResponse(BaseModel):
    """GET /admin/ops/health — liveness (mirrors /health) + schema readiness."""

    status: str
    service: str
    version: str
    commit: str
    rss_mb: Optional[float] = None
    schema_ready: Optional[bool] = None

    model_config = ConfigDict(extra="allow")


class AdminStorageTempItem(BaseModel):
    """One temp object summary."""

    key: str
    size: int = 0
    last_modified: Optional[Any] = None

    model_config = ConfigDict(extra="allow")


class AdminStorageResponse(BaseModel):
    """GET /admin/ops/storage — temp object inventory (bounded scan)."""

    bucket: str
    scanned_keys: int
    count: int
    total_bytes: int
    oldest: Optional[Dict[str, Any]] = None
    newest: Optional[Dict[str, Any]] = None
    items: List[AdminStorageTempItem] = Field(default_factory=list)
    truncated: bool = False

    model_config = ConfigDict(extra="allow")


class AdminStorageCleanupResponse(BaseModel):
    """DELETE /admin/ops/storage/temp."""

    deleted: int
    bytes_freed: int
    remaining: int
    truncated: bool = False

    model_config = ConfigDict(extra="allow")


class AdminSettingsResponse(BaseModel):
    """GET /admin/settings — safe deployment info (no secrets)."""

    app_name: str
    version: str
    commit: str
    environment: str
    feature_toggles: Dict[str, bool] = Field(default_factory=dict)
    billing: Dict[str, bool] = Field(default_factory=dict)
    storage: Dict[str, Any] = Field(default_factory=dict)
    limits: Dict[str, Any] = Field(default_factory=dict)

    model_config = ConfigDict(extra="allow")
