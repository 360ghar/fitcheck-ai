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
- Webhook dedupe ledgers — PK is the provider's event ID, there is NO ``id``
  column, so count queries must select the PK: ``stripe_webhook_events``
  (022/027): event_id, event_type, received_at, status, attempts,
  processing_started_at, processed_at, last_error; ``apple_iap_events``
  (030): notification_id, event_type, signed_type, received_at, status,
  attempts, processing_started_at, processed_at, last_error;
  ``google_rtdn_events`` (030): message_id, event_type, received_at, status,
  attempts, processing_started_at, processed_at, last_error
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
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Iterable, List, Optional, Tuple

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
from app.utils.datetime_util import parse_utc_datetime, utc_today, utcnow

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
    # A bare embed is a LEFT join: with a plan filter the
    # `subscriptions.plan_type` eq would only filter the EMBEDDED rows, not
    # the parent, so every user still matches and `count` reports ALL users
    # (with subscriptions=null for non-matching plans). `!inner` turns the
    # subscriptions embed into an inner join so the plan filter restricts the
    # parent user rows. (007/008 backfill + new-user trigger give nearly every
    # user a subscription row, but rows without one must not appear under a
    # plan filter either.)
    subscriptions_embed = (
        "subscriptions!inner(plan_type,status,current_period_start,current_period_end,billing_provider)"
        if plan
        else "subscriptions(plan_type,status,current_period_start,current_period_end,billing_provider)"
    )
    query = d.table("users").select(
        "*",
        subscriptions_embed,
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
        # The subscriptions embed above is !inner when plan is set, so this
        # eq filters the parent user rows, not just the embedded rows.
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
    """Full user profile: row + subscription + usage snapshot + counts + jobs.

    Extended for the 360 detail page: 6 additional sections (items, outfits,
    photoshoot_jobs, collections, trips, achievements) plus social_import_jobs
    when the table is present. All are fetched concurrently via
    ``asyncio.gather`` so the detail page is one user-facing GET, not N.
    """
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

    async def _count_exact(table: str, column: str, value: str, operation: str) -> int:
        try:
            res = await execute_with_reconnect(
                lambda d, t=table, c=column, v=value: d.table(t).select("id", count="exact").eq(c, v).execute(),
                db,
                extra={"operation": operation, "user_id": user_id},
            )
            return getattr(res, "count", 0) or 0
        except Exception:
            return 0

    counts_outfits, counts_items, counts_ref = await asyncio.gather(
        _count_exact("outfits", "user_id", user_id, "admin.get_user.count.outfits"),
        _count_exact("items", "user_id", user_id, "admin.get_user.count.items"),
        _count_exact("referral_redemptions", "referrer_user_id", user_id, "admin.get_user.count.referrals"),
    )
    counts: Dict[str, int] = {
        "outfits": counts_outfits,
        "items": counts_items,
        "referrals": counts_ref,
    }

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

    # ------------------------------------------------------------------
    # 360-detail: 6 new sections + social_import_jobs, all concurrent.
    # Each is a simple `eq user_id order created_at desc limit N`. The
    # gather is best-effort: a missing table/column (migration not applied)
    # yields [] rather than failing the whole detail read. Helpers use
    # execute_with_reconnect so the pooled-connection retry still applies.
    # ------------------------------------------------------------------

    async def _fetch_items() -> List[Dict[str, Any]]:
        # items has no image_url column (image is in item_images); the spec
        # names image_url for convenience -- try it, fall back to without it.
        for cols in (
            "id,name,category,image_url,created_at",
            "id,name,category,created_at",
        ):
            try:
                res = await execute_with_reconnect(
                    lambda d, c=cols: d.table("items")
                    .select(c)
                    .eq("user_id", user_id)
                    .order("created_at", desc=True)
                    .limit(12)
                    .execute(),
                    db,
                    extra={"operation": "admin.get_user.detail.items", "user_id": user_id},
                )
                return [dict(r) for r in (res.data or [])]
            except Exception:
                # First columns variant was absent on this DB (42703 / PGRST204);
                # try the fallback. If both fail, the outer except returns [].
                if cols == "id,name,category,created_at":
                    return []
                continue
        return []

    async def _fetch_outfits() -> List[Dict[str, Any]]:
        # outfits.name is the display title (task says title). Try title then name
        # so both schema variants work; also attempt an outfit_images embed for
        # cover art when the relation exists -- cheap to try, harmless to drop.
        for cols in (
            "id,title,created_at",
            "id,name,created_at",
            "id,name,created_at,outfit_images(image_url,is_primary)",
        ):
            # The embed variant is explicitly attempted last so the simple
            # select remains the common path.
            if "outfit_images" in cols:
                try:
                    res = await execute_with_reconnect(
                        lambda d: d.table("outfits")
                        .select(cols)
                        .eq("user_id", user_id)
                        .order("created_at", desc=True)
                        .limit(12)
                        .execute(),
                        db,
                        extra={"operation": "admin.get_user.detail.outfits", "user_id": user_id},
                    )
                    out = []
                    for row in res.data or []:
                        r = dict(row)
                        images = r.pop("outfit_images", None)
                        # Normalize cover: first primary or first image.
                        cover = None
                        if isinstance(images, list) and images:
                            primary = next((i for i in images if i.get("is_primary")), None)
                            cover = (primary or images[0]).get("image_url")
                        elif isinstance(images, dict):
                            cover = images.get("image_url")
                        if cover:
                            r["cover_image_url"] = cover
                        # Normalize title field for callers that expect `title`
                        if "name" in r and "title" not in r:
                            r["title"] = r.get("name")
                        out.append(r)
                    return out
                except Exception:
                    return []
            try:
                res = await execute_with_reconnect(
                    lambda d, c=cols: d.table("outfits")
                    .select(c)
                    .eq("user_id", user_id)
                    .order("created_at", desc=True)
                    .limit(12)
                    .execute(),
                    db,
                    extra={"operation": "admin.get_user.detail.outfits", "user_id": user_id},
                )
                rows = [dict(r) for r in (res.data or [])]
                # Normalize name -> title for callers that expect `title`
                for r in rows:
                    if "title" not in r and "name" in r:
                        r["title"] = r.get("name")
                    # Also ensure name exists when DB column is title
                    if "name" not in r and "title" in r:
                        r["name"] = r.get("title")
                return rows
            except Exception:
                if cols == "id,name,created_at":
                    return []
                continue
        return []

    async def _fetch_photoshoot_jobs() -> List[Dict[str, Any]]:
        try:
            res = await execute_with_reconnect(
                lambda d: d.table("photoshoot_jobs")
                .select("id,status,use_case,created_at,completed_at,error_message,image_failures")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(12)
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.photoshoot_jobs", "user_id": user_id},
            )
            return [dict(r) for r in (res.data or [])]
        except Exception:
            # image_failures column from 035 may be absent; fall back without it.
            try:
                res2 = await execute_with_reconnect(
                    lambda d: d.table("photoshoot_jobs")
                    .select("id,status,use_case,created_at,completed_at,error_message")
                    .eq("user_id", user_id)
                    .order("created_at", desc=True)
                    .limit(12)
                    .execute(),
                    db,
                    extra={"operation": "admin.get_user.detail.photoshoot_jobs.fallback", "user_id": user_id},
                )
                return [dict(r) for r in (res2.data or [])]
            except Exception:
                return []

    async def _fetch_collections() -> List[Dict[str, Any]]:
        try:
            res = await execute_with_reconnect(
                lambda d: d.table("outfit_collections")
                .select("id,name,created_at")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(6)
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.collections", "user_id": user_id},
            )
            return [dict(r) for r in (res.data or [])]
        except Exception:
            return []

    async def _fetch_trips() -> List[Dict[str, Any]]:
        try:
            res = await execute_with_reconnect(
                lambda d: d.table("trips")
                .select("id,name,created_at")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(6)
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.trips", "user_id": user_id},
            )
            rows = [dict(r) for r in (res.data or [])]
            # Capsule counts — batched concurrently (at most 6 trips).
            async def _capsule_count(trip_id: str) -> int:
                try:
                    c_res = await execute_with_reconnect(
                        lambda d, t=trip_id: d.table("trip_capsule_items")
                        .select("id", count="exact")
                        .eq("trip_id", t)
                        .execute(),
                        db,
                        extra={"operation": "admin.get_user.detail.trips.capsule_count", "user_id": user_id},
                    )
                    return getattr(c_res, "count", 0) or 0
                except Exception:
                    return 0

            trip_ids = [r.get("id") for r in rows if r.get("id")]
            if trip_ids:
                cap_counts = await asyncio.gather(*(_capsule_count(str(tid)) for tid in trip_ids))
                id_to_count = dict(zip(trip_ids, cap_counts))
                for row in rows:
                    tid = row.get("id")
                    if tid in id_to_count:
                        row["capsule_count"] = id_to_count[tid]
            return rows
        except Exception:
            return []

    async def _fetch_achievements() -> Dict[str, Any]:
        # Provide both count and list so the spec's "counts only" and the
        # admin console's array expectation (achievements: JsonRecord[]) are
        # satisfied. The console reads `achievements` as an array and
        # `streak`/`streaks` as an object (see admin/src/features/users/pages/UserDetailPage.tsx).
        achievements: List[Dict[str, Any]] = []
        achievements_count = 0
        streak: Optional[Dict[str, Any]] = None
        try:
            # List for the UI (limit 12, most recent)
            res = await execute_with_reconnect(
                lambda d: d.table("user_achievements")
                .select("id,achievement_id,earned_at,reward_claimed")
                .eq("user_id", user_id)
                .order("earned_at", desc=True)
                .limit(12)
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.achievements.list", "user_id": user_id},
            )
            achievements = [dict(r) for r in (res.data or [])]
            # Count via the returned slice when possible, but precise count
            # via count="exact" if the slice is truncated or for accuracy.
            achievements_count = len(achievements)
            try:
                c_res = await execute_with_reconnect(
                    lambda d: d.table("user_achievements")
                    .select("id", count="exact")
                    .eq("user_id", user_id)
                    .execute(),
                    db,
                    extra={"operation": "admin.get_user.detail.achievements.count", "user_id": user_id},
                )
                achievements_count = getattr(c_res, "count", 0) or achievements_count
            except Exception:
                pass
        except Exception:
            achievements = []
            achievements_count = 0
        try:
            s_res = await execute_with_reconnect(
                lambda d: d.table("user_streaks")
                .select("*")
                .eq("user_id", user_id)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.streak", "user_id": user_id},
            )
            streak = maybe_single_data(s_res)
        except Exception:
            streak = None
        return {
            "achievements": achievements,
            "achievements_count": achievements_count,
            "streak": streak or {},
            "streaks": streak or {},
        }

    async def _fetch_social_import_jobs() -> List[Dict[str, Any]]:
        try:
            res = await execute_with_reconnect(
                lambda d: d.table("social_import_jobs")
                .select("id,status,created_at,completed_at,error_message")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(5)
                .execute(),
                db,
                extra={"operation": "admin.get_user.detail.social_import_jobs", "user_id": user_id},
            )
            return [dict(r) for r in (res.data or [])]
        except Exception:
            return []

    # Concurrent fetch. return_exceptions=False would fail the whole detail
    # on one bad section; with helpers swallowing per-section errors we can
    # gather normally. Keep it simple: individual helpers never raise.
    (
        items,
        outfits,
        photoshoot_jobs_detail,
        collections,
        trips,
        achievements,
        social_import_jobs,
    ) = await asyncio.gather(
        _fetch_items(),
        _fetch_outfits(),
        _fetch_photoshoot_jobs(),
        _fetch_collections(),
        _fetch_trips(),
        _fetch_achievements(),
        _fetch_social_import_jobs(),
    )

    # Extend counts where cheap: gifts, collections, trips — batched concurrently.
    extend_tables = (
        ("outfit_collections", "collections"),
        ("trips", "trips"),
        ("gift_entitlement_grants", "gifts"),
        ("shared_outfits", "shared_outfits"),
        ("support_tickets", "support_tickets"),
    )
    extend_results = await asyncio.gather(
        *(
            _count_exact(table, "user_id", user_id, f"admin.get_user.count.{key}")
            for table, key in extend_tables
        ),
    )
    for (_table, key), value in zip(extend_tables, extend_results):
        counts[key] = value

    # Gifts fallback: user_id column may differ by spec (granted_to / recipient_user_id).
    if counts.get("gifts", 0) == 0:
        async def _gift_alt(column: str) -> int:
            return await _count_exact(
                "gift_entitlement_grants", column, user_id, "admin.get_user.count.gifts.alt"
            )

        alt_results = await asyncio.gather(
            _gift_alt("granted_to"), _gift_alt("recipient_user_id")
        )
        for alt_cnt in alt_results:
            if alt_cnt:
                counts["gifts"] = alt_cnt
                break
    # Achievements counts surfaced both as a detail section and in counts
    # `achievements` is now {achievements: list, achievements_count, streak, streaks}
    _ach_list = achievements.get("achievements", []) if isinstance(achievements, dict) else []
    _streak = achievements.get("streak", {}) if isinstance(achievements, dict) else {}
    _streaks = achievements.get("streaks", _streak) if isinstance(achievements, dict) else {}
    counts["achievements"] = achievements.get("achievements_count", 0) if isinstance(achievements, dict) else 0
    # Streak is not counted separately; its fields live in streak/streaks

    return {
        "user": user_row,
        "subscription": sub_row,
        "usage": {"ai": ai_row or {}, "subscription_usage": usage_row or {}},
        "counts": counts,
        "recent_jobs": jobs[:10],
        "items": items,
        "outfits": outfits,
        "photoshoot_jobs": photoshoot_jobs_detail,
        "collections": collections,
        "trips": trips,
        "achievements": _ach_list,
        "streak": _streak,
        "streaks": _streaks,
        # Keep the original dict for callers that expect the old shape
        "achievements_meta": achievements if isinstance(achievements, dict) else {},
        "social_import_jobs": social_import_jobs,
    }


def _invalidate_user_profile_cache(user_id: str) -> None:
    """Best-effort invalidation of any cached user profile.

    The hosted app does not expose a centralized cache client; this helper
    is a no-op that logs at debug so the admin trace still records the
    invalidation. If a future cache (redis / in-memory) is introduced, wire
    it here and the two admin actions above will pick it up without churn.
    """
    import logging as _logging

    _logging.getLogger(__name__).debug(
        "invalidate user_profile_cache",
        extra={"user_id": user_id},
    )


async def extend_user_trial(db: Any, user_id: str, days: int) -> Dict[str, Any]:
    """Extend a user's subscription trial by ``days``.

    If ``subscriptions.trial_end`` is set, it is moved forward by ``days``;
    otherwise ``now + days`` becomes the new trial end. The write is behind
    the route's ``subscriptions.write`` / ``users.write`` permission check.

    Returns ``{subscription, before, after}`` where before/after are ISO
    strings (or None) for the audit payload.
    """
    if not 1 <= days <= 90:
        raise ValidationError(
            message="days must be between 1 and 90",
            details={"field": "days", "value": days},
        )
    sub_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("subscriptions").select("*").eq("user_id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.extend_trial.load", "user_id": user_id},
        )
    )
    if not sub_row:
        raise NotFoundError(
            message=f"No subscription found for user {user_id}",
            resource_type="subscription",
            resource_id=user_id,
        )
    before_raw = sub_row.get("trial_end")
    from app.utils.datetime_util import parse_utc_datetime  # local import to avoid cycle

    before_dt = parse_utc_datetime(before_raw) if before_raw else None
    now = utcnow()
    after_dt = (before_dt + timedelta(days=days)) if before_dt else (now + timedelta(days=days))
    after_iso = after_dt.isoformat()
    before_iso = before_dt.isoformat() if before_dt else (str(before_raw) if before_raw else None)

    result = await execute_with_reconnect(
        lambda d: d.table("subscriptions").update({"trial_end": after_iso}).eq("user_id", user_id).execute(),
        db,
        extra={"operation": "admin.extend_trial.apply", "user_id": user_id, "days": days},
    )
    updated = _first_row(result) or {**sub_row, "trial_end": after_iso}
    _invalidate_user_profile_cache(user_id)
    return {"subscription": updated, "before": before_iso, "after": after_iso}


async def clear_daily_ai_counters(db: Any, user_id: str) -> Dict[str, Any]:
    """Reset daily AI counters for a user.

    Resets ``user_ai_settings.daily_*_count`` to 0 and ``last_reset_date`` to
    today, plus ``subscription_usage.daily_photoshoot_images`` to 0 (creating
    the usage row if needed). Behind ``users.write`` (route check).
    """
    user_row = maybe_single_data(
        await execute_with_reconnect(
            lambda d: d.table("users").select("id").eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": "admin.clear_daily.load", "user_id": user_id},
        )
    )
    if not user_row:
        raise UserNotFoundError(user_id)

    today_iso = utc_today().isoformat()
    ai_payload = {
        "daily_extraction_count": 0,
        "daily_generation_count": 0,
        "daily_embedding_count": 0,
        "last_reset_date": today_iso,
    }
    ai_res = await execute_with_reconnect(
        lambda d: d.table("user_ai_settings").update(ai_payload).eq("user_id", user_id).execute(),
        db,
        extra={"operation": "admin.clear_daily.ai", "user_id": user_id},
    )
    if not _first_row(ai_res):
        try:
            await execute_with_reconnect(
                lambda d: d.table("user_ai_settings")
                .upsert({"user_id": user_id, **ai_payload}, on_conflict="user_id")
                .execute(),
                db,
                extra={"operation": "admin.clear_daily.ai.upsert", "user_id": user_id},
            )
        except Exception:
            pass
    try:
        await execute_with_reconnect(
            lambda d: d.table("subscription_usage")
            .update({"daily_photoshoot_images": 0})
            .eq("user_id", user_id)
            .eq("period_start", today_iso)
            .execute(),
            db,
            extra={"operation": "admin.clear_daily.usage", "user_id": user_id},
        )
    except Exception:
        pass
    try:
        maybe = maybe_single_data(
            await execute_with_reconnect(
                lambda d: d.table("subscription_usage")
                .select("user_id")
                .eq("user_id", user_id)
                .eq("period_start", today_iso)
                .maybe_single()
                .execute(),
                db,
                extra={"operation": "admin.clear_daily.usage.check", "user_id": user_id},
            )
        )
        if not maybe:
            await execute_with_reconnect(
                lambda d: d.table("subscription_usage")
                .upsert(
                    {
                        "user_id": user_id,
                        "period_start": today_iso,
                        "daily_photoshoot_images": 0,
                        "monthly_extractions": 0,
                        "monthly_generations": 0,
                        "monthly_embeddings": 0,
                    },
                    on_conflict="user_id,period_start",
                )
                .execute(),
                db,
                extra={"operation": "admin.clear_daily.usage.upsert", "user_id": user_id},
            )
    except Exception:
        pass

    _invalidate_user_profile_cache(user_id)
    return {"user_id": user_id, "today": today_iso, "cleared": ai_payload}


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
            # Dead: a non-admin actor changing admin state with will_be_admin
            # False implies the target WAS an admin (role demotion), so this
            # branch is always taken when reached.
            if was_admin:  # pragma: no cover - implied by the preceding checks
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
    # A4-09: seed `seen` with the actor-query ids so an event where the user
    # is BOTH actor and entity is not appended twice (previously the entity
    # loop's dedupe only saw rows added after it started).
    seen: set = set(row.get("id") for row in audit_rows if row.get("id"))
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
    d: Any,
    *,
    plan: Optional[str],
    status: Optional[str],
    billing_provider: Optional[str],
    sort_col: str,
    sort_dir: str,
) -> Any:
    query = d.table("subscriptions").select("*", "users(email,full_name)", count="exact")
    if plan:
        query = query.eq("plan_type", plan)
    if status:
        query = query.eq("status", status)
    if billing_provider:
        if billing_provider == "stripe":
            # Legacy rows predate migration 030's billing_provider default and
            # are NULL — they are Stripe-billed, so "stripe" includes them.
            query = query.or_("billing_provider.eq.stripe,billing_provider.is.null")
        else:
            query = query.eq("billing_provider", billing_provider)
    return query.order(sort_col, desc=(sort_dir == "desc"))


async def list_subscriptions(
    db: Any,
    *,
    plan: Optional[str] = None,
    status: Optional[str] = None,
    billing_provider: Optional[str] = None,
    page: int = 1,
    page_size: int = 20,
    sort_by: str = "created_at",
    sort_dir: str = "desc",
) -> Dict[str, Any]:
    sort_col = sort_by if sort_by in _SUBSCRIPTION_SORT_COLUMNS else "created_at"
    kwargs = dict(
        plan=plan,
        status=status,
        billing_provider=billing_provider,
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
    """Refund the user's Stripe charge for THIS subscription (full refund).

    A4-15/M3: the old implementation refunded the customer's MOST RECENT
    PaymentIntent with no subscription/date/amount filter, so a later
    unrelated purchase could be refunded instead of the subscription's own
    charge. The charge is now resolved as: subscription latest_invoice ->
    payment_intent (preferred), then the customer's most recent succeeded
    intent/charge created within the subscription's lifetime window. The
    refund amount/currency are taken from the resolved charge (refund <=
    charged amount, no currency mixing, enforced by Stripe server-side too).

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

        def _create_refund(
            *,
            payment_intent: Optional[str] = None,
            charge: Optional[str] = None,
            amount: Optional[int] = None,
            currency: Optional[str] = None,
        ) -> Dict[str, Any]:
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
            refund_kwargs: Dict[str, Any] = {}
            if payment_intent:
                refund_kwargs["payment_intent"] = payment_intent
            if charge:
                refund_kwargs["charge"] = charge
            # Amount/currency sanity: refund exactly the resolved charge's
            # amount and currency (refund <= charged, no currency mixing).
            if amount is not None:
                refund_kwargs["amount"] = amount
            if currency:
                refund_kwargs["currency"] = currency
            refund = stripe.Refund.create(**refund_kwargs)
            return {
                "refund_id": refund.id,
                "payment_intent": payment_intent,
                "charge_id": charge or getattr(refund, "charge", None),
                "amount": refund.amount,
                "currency": refund.currency,
                "status": refund.status,
            }

        def _resolve_charge() -> Tuple[Optional[str], Optional[str], Optional[int], Optional[str]]:
            """Resolve the subscription's own charge.

            Returns (payment_intent_id, charge_id, amount, currency).

            The subscription's own Stripe association is the ONLY thing that
            may be refunded here: a customer-level "most recent succeeded
            charge" fallback bounded only by the subscription's creation time
            can match an UNRELATED later purchase (a second checkout, a
            one-off charge) made after the subscription churned, and refund
            it. When the subscription's own charge cannot be recovered the
            function fails closed (raises) instead of refunding anything.
            """
            subscription_id = sub_row.get("stripe_subscription_id")
            if subscription_id:
                try:
                    subscription = stripe.Subscription.retrieve(
                        subscription_id,
                        expand=["latest_invoice.payment_intent"],
                    )
                    latest_invoice = getattr(subscription, "latest_invoice", None)
                    if isinstance(latest_invoice, dict):
                        intent = latest_invoice.get("payment_intent")
                        if isinstance(intent, dict) and intent.get("id"):
                            if intent.get("status") == "succeeded":
                                return (
                                    intent["id"],
                                    None,
                                    intent.get("amount"),
                                    intent.get("currency"),
                                )
                except stripe.error.StripeError:
                    # The subscription may be gone (deleted after churn);
                    # recover its own charge through the invoice list before
                    # giving up — never fall through to a customer-wide lookup.
                    pass
                try:
                    invoices = stripe.Invoice.list(
                        subscription=subscription_id,
                        limit=5,
                    )
                    for invoice in invoices.data:
                        intent = getattr(invoice, "payment_intent", None)
                        # Stripe objects are attribute-access; plain dicts
                        # appear when the list came from a cached/JSON shape.
                        if isinstance(intent, str) and intent:
                            # Payment intent expanded on a previous fetch may
                            # come back as a plain id on this one; resolve it.
                            try:
                                resolved = stripe.PaymentIntent.retrieve(intent)
                            except stripe.error.StripeError:
                                continue
                            if resolved.get("status") == "succeeded":
                                return (
                                    resolved.get("id"),
                                    None,
                                    resolved.get("amount"),
                                    resolved.get("currency"),
                                )
                            continue
                        if isinstance(intent, dict):
                            intent_id = intent.get("id")
                            intent_status = intent.get("status")
                            intent_amount = intent.get("amount")
                            intent_currency = intent.get("currency")
                        else:
                            intent_id = getattr(intent, "id", None)
                            intent_status = getattr(intent, "status", None)
                            intent_amount = getattr(intent, "amount", None)
                            intent_currency = getattr(intent, "currency", None)
                        if intent_id and intent_status == "succeeded":
                            return (
                                intent_id,
                                None,
                                intent_amount,
                                intent_currency,
                            )
                except stripe.error.StripeError as exc:
                    raise NotFoundError(
                        message="Could not recover the Stripe subscription's own "
                        "charge to refund; refusing to guess at a customer-level "
                        "charge (a later unrelated purchase could be refunded "
                        "instead)",
                        resource_type="stripe_subscription",
                        resource_id=subscription_id,
                    ) from exc

                # Subscription exists but no succeeded charge was recoverable.
                raise NotFoundError(
                    message="No succeeded charge found for this Stripe "
                    "subscription to refund; refusing to refund an unrelated "
                    "customer charge instead",
                    resource_type="stripe_subscription",
                    resource_id=subscription_id,
                )

            # No Stripe association on the row: the subscription's own charge
            # cannot be identified, so fail closed. The old behavior refunded
            # the customer's most recent succeeded charge, which could be a
            # purchase unrelated to this subscription.
            raise NotFoundError(
                message="This subscription has no Stripe subscription link, so "
                "its own charge cannot be identified for a refund; refusing "
                "to refund a customer-level charge that may be unrelated",
                resource_type="subscription",
                resource_id=user_id,
            )

        try:
            payment_intent, charge, amount, currency = _resolve_charge()
            if not payment_intent and not charge:
                raise NotFoundError(
                    message="No charge found for this Stripe customer to refund",
                    resource_type="stripe_customer",
                    resource_id=customer_id,
                )
            # Amount sanity check: a zero/absent amount means nothing was
            # ever charged (uncaptured/voided) and there is nothing to refund.
            if amount is None or amount <= 0:
                raise NotFoundError(
                    message="No payable charge found for this Stripe customer to refund",
                    resource_type="stripe_customer",
                    resource_id=customer_id,
                )
            return _create_refund(
                payment_intent=payment_intent,
                charge=charge,
                amount=amount,
                currency=currency,
            )
        except stripe.error.StripeError as exc:
            # StripeError is not a FitCheckException; without this mapping the
            # catch-all handler turns e.g. an already-refunded InvalidRequestError
            # into a 500. A refund that cannot be executed is a 4xx client
            # problem, not a server fault.
            raise ValidationError(
                message=str(exc),
                details={"service": "stripe"},
            ) from exc

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
    # subscriptions is embedded THROUGH users (users.id <- subscriptions.user_id,
    # migration 007): user_ai_settings has no FK to subscriptions, so a
    # top-level `subscriptions(...)` embed raises PGRST200 "Could not find a
    # relationship" on any DB with the repo schema (observed 2026-08-07 on
    # GET /api/v1/admin/quotas). subscriptions.user_id is UNIQUE, so the
    # nested embed resolves to a single object (not an array) in PostgREST.
    #
    # A bare embed is a LEFT join: with a plan filter the
    # `users.subscriptions.plan_type` eq would only filter the EMBEDDED
    # rows, not the parent, so every user_ai_settings row still matches and
    # `count` reports all plans' users (with subscriptions=null for the
    # non-matching rows). `!inner` on BOTH embed levels turns them into
    # inner joins, so the plan filter restricts the parent rows themselves.
    select = (
        "user_id,daily_extraction_count,daily_generation_count,daily_embedding_count,"
        "last_reset_date,total_extractions,total_generations",
        (
            "users!inner(email,full_name,custom_daily_quota,subscriptions!inner(plan_type,status))"
            if plan
            else "users(email,full_name,custom_daily_quota,subscriptions(plan_type,status))"
        ),
    )
    query = d.table("user_ai_settings").select(*select, count="exact")
    if q:
        term = f"%{safe_search_term(q)}%"
        query = query.or_(_or_ilike(("users.email", "users.full_name"), term))
    if plan:
        query = query.eq("users.subscriptions.plan_type", plan)
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
        # With the nested embed the subscription row lives inside `users`.
        # subscriptions.user_id is UNIQUE (007) so PostgREST returns a single
        # object; tolerate an array defensively (older PostgREST behavior).
        subscriptions = user.get("subscriptions") if isinstance(user, dict) else None
        if isinstance(subscriptions, list):
            sub = subscriptions[0] if subscriptions else {}
        else:
            sub = subscriptions or {}
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
    """Signups/active/paid/job aggregates for the overview cards.

    Extended v1: also returns ``trials_ending_7d`` and ``tickets_open_48h``.
    Both are zero-filled fallback counts added to the existing gather so the
    overview page can surface trial expiry pressure and overdue tickets
    without an extra round-trip.
    """
    now = utcnow()
    d7 = (now - timedelta(days=7)).isoformat()
    d30 = (now - timedelta(days=30)).isoformat()
    now_iso = now.isoformat()
    now_plus_7d = (now + timedelta(days=7)).isoformat()
    now_minus_48h = (now - timedelta(hours=48)).isoformat()

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

    (
        signups_7d,
        signups_30d,
        active_7d,
        active_30d,
        paid,
        extraction_total,
        extraction_ok,
        extraction_failed,
        photoshoot_total,
        photoshoot_ok,
        photoshoot_failed,
        trials_ending_7d,
        tickets_open_48h,
    ) = await asyncio.gather(
        _count(lambda d: d.table("users").select("id", count="exact").gte("created_at", d7)),
        _count(lambda d: d.table("users").select("id", count="exact").gte("created_at", d30)),
        _count(lambda d: d.table("users").select("id", count="exact").eq("is_active", True).gte("last_login_at", d7)),
        _count(lambda d: d.table("users").select("id", count="exact").eq("is_active", True).gte("last_login_at", d30)),
        _count(
            lambda d: d.table("subscriptions")
            .select("id", count="exact")
            .neq("plan_type", "free")
            .in_("status", ["active", "trial"])
        ),
        _count(lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7)),
        _count(lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7).in_("status", ["completed"])),
        _count(lambda d: d.table("extraction_jobs").select("id", count="exact").gte("created_at", d7).eq("status", "failed")),
        _count(lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7)),
        _count(lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7).in_("status", ["complete"])),
        _count(lambda d: d.table("photoshoot_jobs").select("id", count="exact").gte("created_at", d7).eq("status", "failed")),
        # trials_ending_7d: status=trial and trial_end between now and now+7d
        _count(
            lambda d: d.table("subscriptions")
            .select("id", count="exact")
            .eq("status", "trial")
            .gte("trial_end", now_iso)
            .lte("trial_end", now_plus_7d)
        ),
        # tickets_open_48h: status=open and created_at <= now-48h (overdue)
        _count(
            lambda d: d.table("support_tickets")
            .select("id", count="exact")
            .eq("status", "open")
            .lte("created_at", now_minus_48h)
        ),
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
        "trials_ending_7d": trials_ending_7d,
        "tickets_open_48h": tickets_open_48h,
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
    # A4-16: churn counts must reflect SUBSCRIBERS, not webhook volume. The
    # dedupe ledgers are keyed by provider event id (no subscription column),
    # so entity-level dedupe is not possible; at minimum only count events
    # the webhook processor actually handled (status='processed', the ledger's
    # success value) - unprocessed/retrying events double-count otherwise.
    churn_stripe = await _count(
        lambda d: d.table("stripe_webhook_events")
        .select("event_id", count="exact")
        .in_("event_type", STRIPE_CHURN_EVENT_TYPES)
        .eq("status", "processed")
        .gte("received_at", d30)
    )
    churn_apple = await _count(
        lambda d: d.table("apple_iap_events")
        .select("notification_id", count="exact")
        .in_("event_type", APPLE_CHURN_EVENT_TYPES)
        .eq("status", "processed")
        .gte("received_at", d30)
    )
    churn_google = await _count(
        lambda d: d.table("google_rtdn_events")
        .select("message_id", count="exact")
        .in_("event_type", GOOGLE_CHURN_EVENT_TYPES)
        .eq("status", "processed")
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
# Funnel + retention (single-page dashboard extensions, Phase 1a)
# =============================================================================


async def dashboard_funnel(db: Any, days: int = 30) -> Dict[str, Any]:
    """Funnel over the last ``days`` days: signups -> items -> outfits -> paid.

    All counts are computed in Python without PostgREST aggregates
    (select-side aggregates are disabled). Queries are plain
    ``select(..., count="exact")`` or ``select("user_id[,created_at]")``
    through ``execute_with_reconnect``.

    Steps
    - ``users_created``: count users where created_at >= now-days.
    - ``with_items_24h``: distinct users in the window who have >=1 item
      whose created_at lies between user.created_at and
      user.created_at+24h (strict window). Implemented via two-step fetch:
      window user_ids + their items, filtered in Python. Falls back to
      existential ``has any item`` when timestamps cannot be parsed.
      Documented as pragmatic v1: a true join would be a service-role RPC,
      but no migration is allowed; Python filtering keeps queries simple and
      preserves zero-filled fallback. If strict 24h is required later, move
      to a RPC or widen time window.
    - ``with_outfits_7d``: analogous, 7-day window on outfits.
    - ``paid_subs``: count subscriptions where user_id in window and
      plan_type != free and status in (active, trial). Optionally also
      created_at in window (approximated by user window per spec).

    Returns ``{days, steps: [{label, count, pct_of_prev}]}``. ``pct_of_prev``
    is 100.0 for the first step and ``round(count/prev*100,1)`` thereafter
    (0.0 when prev is 0). Drop-off is implicit (100-pct).

    Performance: one ``users`` count, one ``users`` id fetch (up to window
    size), then chunked ``items``/``outfits`` fetches (chunk 200) plus chunked
    paid counts. For a 30-day window with ~2k signups this is ~30 queries
    with bounded payloads; each ``_count`` is exact count via PostgREST.
    """
    if not 1 <= days <= 90:
        raise ValidationError(
            message="days must be between 1 and 90",
            details={"field": "days"},
        )
    now = utcnow()
    window_start = now - timedelta(days=days)
    window_start_iso = window_start.isoformat()

    async def _count(builder: Any) -> int:
        res = await execute_with_reconnect(
            lambda d: builder(d).execute(),
            db,
            extra={"operation": "admin.dashboard_funnel.count", "days": days},
        )
        return getattr(res, "count", 0) or 0

    users_created = await _count(
        lambda d: d.table("users").select("id", count="exact").gte("created_at", window_start_iso)
    )

    # Zero-fallback fast path: no signups means all downstream steps are 0.
    if users_created == 0:
        steps = [
            {"label": "Signups", "count": 0, "pct_of_prev": 100.0},
            {"label": "Added item (24h)", "count": 0, "pct_of_prev": 0.0},
            {"label": "Created outfit (7d)", "count": 0, "pct_of_prev": 0.0},
            {"label": "Paid subscription", "count": 0, "pct_of_prev": 0.0},
        ]
        return {"days": days, "steps": steps}

    # Fetch window users with timestamps for strict window filtering.
    users_res = await execute_with_reconnect(
        lambda d: d.table("users").select("id,created_at").gte("created_at", window_start_iso).execute(),
        db,
        extra={"operation": "admin.dashboard_funnel.window_users", "days": days},
    )
    users_by_id: Dict[str, Any] = {}
    for row in users_res.data or []:
        uid = str(row.get("id") or "")
        if not uid:
            continue
        dt = parse_utc_datetime(row.get("created_at"))
        # Fallback to window_start when timestamp missing — preserves existential fallback.
        users_by_id[uid] = dt or window_start
    window_ids = list(users_by_id.keys())
    # Reconcile counted vs fetched (FakeDB may diverge if rows mutated); trust fetched length for sets.
    # Keep users_created as the DB count for the first step to remain exact.
    if not window_ids:
        with_items_24h = 0
        with_outfits_7d = 0
        paid_subs = 0
    else:
        chunk_size = 200
        with_items_set: set = set()
        with_outfits_set: set = set()

        for idx in range(0, len(window_ids), chunk_size):
            chunk = window_ids[idx : idx + chunk_size]

            # Items: fetch user_id + created_at for strict 24h check.
            items_res = await execute_with_reconnect(
                lambda d, c=chunk: d.table("items").select("user_id,created_at").in_("user_id", c).execute(),
                db,
                extra={"operation": "admin.dashboard_funnel.items", "days": days},
            )
            for row in items_res.data or []:
                uid = str(row.get("user_id") or "")
                if uid not in users_by_id:
                    continue
                user_created = users_by_id.get(uid)
                item_created = parse_utc_datetime(row.get("created_at"))
                if user_created is not None and item_created is not None:
                    if user_created <= item_created <= (user_created + timedelta(hours=24)):
                        with_items_set.add(uid)
                else:
                    # Timestamp missing — existential fallback per spec's pragmatic v1.
                    with_items_set.add(uid)

            # Outfits: strict 7-day window.
            outfits_res = await execute_with_reconnect(
                lambda d, c=chunk: d.table("outfits").select("user_id,created_at").in_("user_id", c).execute(),
                db,
                extra={"operation": "admin.dashboard_funnel.outfits", "days": days},
            )
            for row in outfits_res.data or []:
                uid = str(row.get("user_id") or "")
                if uid not in users_by_id:
                    continue
                user_created = users_by_id.get(uid)
                outfit_created = parse_utc_datetime(row.get("created_at"))
                if user_created is not None and outfit_created is not None:
                    if user_created <= outfit_created <= (user_created + timedelta(days=7)):
                        with_outfits_set.add(uid)
                else:
                    with_outfits_set.add(uid)

        with_items_24h = len(with_items_set)
        with_outfits_7d = len(with_outfits_set)

        # Paid subs: subscriptions where user_id in window and paid+active/trial.
        paid_subs = 0
        for idx in range(0, len(window_ids), chunk_size):
            chunk = window_ids[idx : idx + chunk_size]
            cnt = await _count(
                lambda d, c=chunk: d.table("subscriptions")
                .select("user_id", count="exact")
                .in_("user_id", c)
                .neq("plan_type", "free")
                .in_("status", ["active", "trial"])
            )
            paid_subs += cnt

    # Build steps with drop-off pct.
    counts = [users_created, with_items_24h, with_outfits_7d, paid_subs]
    labels = ["Signups", "Added item (24h)", "Created outfit (7d)", "Paid subscription"]
    steps: List[Dict[str, Any]] = []
    for i, (label, count) in enumerate(zip(labels, counts)):
        if i == 0:
            pct = 100.0
        else:
            prev = counts[i - 1]
            pct = round((count / prev * 100) if prev else 0.0, 1)
        steps.append({"label": label, "count": count, "pct_of_prev": pct})

    return {"days": days, "steps": steps}


async def dashboard_retention(db: Any, weeks: int = 4) -> Dict[str, Any]:
    """Cohort retention: last ``weeks`` Mondays UTC × retained 7 days later.

    For each cohort week (Monday 00:00 UTC to next Monday), count signups
    that week and of those how many have ``last_login_at >= cohort_start+7d``
    as a proxy for retained. 8 ``_count`` queries total for weeks=4.

    v1 proxy: uses ``last_login_at`` only; items/outfits activity is not
    counted. Documented as tech debt — a richer "any activity" check would
    need to union items/outfits timestamps per cohort.

    Returns ``{weeks, cohorts: [{week_start, signups, retained_7d, retention_pct}]}``
    where week_start is ``YYYY-MM-DD`` (Monday) and retention_pct is
    ``round(retained/signups*100,1)`` (0.0 when signups is 0). Zero-filled
    fallback ensures cohorts always emit even when empty.
    """
    if not 1 <= weeks <= 12:
        raise ValidationError(
            message="weeks must be between 1 and 12",
            details={"field": "weeks"},
        )

    async def _count(builder: Any) -> int:
        res = await execute_with_reconnect(
            lambda d: builder(d).execute(),
            db,
            extra={"operation": "admin.dashboard_retention.count", "weeks": weeks},
        )
        return getattr(res, "count", 0) or 0

    today = utc_today()
    days_since_monday = today.weekday()  # Monday is 0
    most_recent_monday = today - timedelta(days=days_since_monday)
    # Oldest first: most_recent - (weeks-1) weeks .. most_recent
    cohort_mondays = [
        most_recent_monday - timedelta(weeks=weeks - 1 - i) for i in range(weeks)
    ]

    cohorts: List[Dict[str, Any]] = []
    for monday in cohort_mondays:
        start_dt = datetime(monday.year, monday.month, monday.day, tzinfo=timezone.utc)
        end_dt = start_dt + timedelta(days=7)
        start_iso = start_dt.isoformat()
        end_iso = end_dt.isoformat()
        week_start = monday.isoformat()  # YYYY-MM-DD

        signups = await _count(
            lambda d, s=start_iso, e=end_iso: d.table("users")
            .select("id", count="exact")
            .gte("created_at", s)
            .lt("created_at", e)
        )
        retained = await _count(
            lambda d, s=start_iso, e=end_iso: d.table("users")
            .select("id", count="exact")
            .gte("created_at", s)
            .lt("created_at", e)
            .gte("last_login_at", e)
        )
        retention_pct = round((retained / signups * 100) if signups else 0.0, 1)
        cohorts.append(
            {
                "week_start": week_start,
                "signups": signups,
                "retained_7d": retained,
                "retention_pct": retention_pct,
            }
        )

    return {"weeks": weeks, "cohorts": cohorts}


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
