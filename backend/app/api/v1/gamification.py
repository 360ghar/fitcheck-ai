"""
Gamification API routes.

The documentation includes gamification as a Phase/P2 feature. This module
provides a minimal MVP backed by Supabase tables when available.

When the Supabase schema for gamification is finalized, these handlers can be
backed by tables like user_streaks, user_achievements, challenges, etc.

Feature flag: ``settings.ENABLE_GAMIFICATION`` (default False). The flag is
enforced HERE, per handler, and never by unmounting the router in main.py --
see the long comment at main.py's ``include_router(gamification.router, ...)``
call for the Flutter dashboard reason. With the flag off every handler returns
200 with the same neutral payload its own ``except`` branch already returns,
and performs zero database work (which also kills the write-on-GET at
``get_streak``).
"""

import asyncio
from app.utils.datetime_util import utcnow_iso
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends
from supabase import Client

from app.core.config import settings
from app.core.exceptions import DatabaseError
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db

logger = get_context_logger(__name__)

router = APIRouter()

MILESTONES = [
    (3, "3-day Streak", "starter"),
    (7, "One Week Streak", "week"),
    (14, "Two Week Streak", "two_weeks"),
    (30, "Monthly Master", "month"),
    (60, "Two-Month Champion", "two_months"),
    (90, "Quarterly Queen/King", "quarter"),
    (100, "Century Streak", "century"),
    (365, "Yearly Legend", "year"),
]


def _now() -> str:
    return utcnow_iso()


def _safe_int(value: Any, default: int = 0) -> int:
    try:
        return int(value)
    except Exception:
        return default


def _compute_next_milestone(current: int) -> Optional[Dict[str, Any]]:
    for days, name, badge in MILESTONES:
        if current < days:
            return {"days": days, "name": name, "badge": badge}
    return None


def _compute_points(current_streak: int) -> int:
    # MVP: points are derived from streak only.
    return max(0, current_streak) * 10


def _compute_level(total_points: int) -> int:
    # MVP: simple leveling curve
    return max(1, (max(0, total_points) // 100) + 1)


def _display_name(profile: Dict[str, Any]) -> str:
    full_name = (profile.get("full_name") or "").strip()
    if full_name:
        return full_name
    user_id = str(profile.get("id") or "")
    if user_id:
        return f"User {user_id[:6]}"
    return "User"


def _achievement_catalog() -> List[Dict[str, Any]]:
    """The static achievement catalog.

    Module-level so the disabled payload and the live handler cannot drift.
    Returns a fresh list each call because callers mutate the enriched copies.
    """
    return [
        {"id": "first_upload", "name": "First Upload", "description": "Add your first wardrobe item", "xp_reward": 50},
        {"id": "first_outfit", "name": "First Outfit", "description": "Create your first outfit", "xp_reward": 50},
        {"id": "streak_7", "name": "7-day Streak", "description": "Plan outfits 7 days in a row", "xp_reward": 100},
    ]


# ---------------------------------------------------------------------------
# Neutral ("nothing to show") payloads.
#
# ONE definition each, used by BOTH the ENABLE_GAMIFICATION=False guard and the
# handlers' own ``except`` fallbacks. Two copies of "neutral" would drift, and a
# drifted shape is what breaks a mobile client that cannot be redeployed.
# These are 200 responses on purpose -- never 404. See main.py.
# ---------------------------------------------------------------------------


def _disabled_streak_payload() -> Dict[str, Any]:
    return {
        "data": {
            "current_streak": 0,
            "longest_streak": 0,
            "last_planned": None,
            "streak_freezes_remaining": 3,
            "streak_skips_remaining": 1,
            "next_milestone": _compute_next_milestone(0),
        },
        "message": "OK",
    }


def _disabled_achievements_payload() -> Dict[str, Any]:
    return {"data": {"earned": [], "available": _achievement_catalog()}, "message": "OK"}


def _disabled_leaderboard_payload() -> Dict[str, Any]:
    # ``user_rank`` is present-and-null, not omitted: the success path below
    # always includes the key and frontend/src/api/gamification.ts reads
    # ``data.user_rank``, so dropping it made the two shapes disagree.
    return {"data": {"entries": [], "user_rank": None}, "message": "OK"}


@router.get("/streak", response_model=Dict[str, Any])
async def get_streak(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    # Flag off -> 200 with zeros, NOT 404. A 404 here rejects the Flutter
    # dashboard's unguarded Future.wait (dashboard_controller.dart:60-67) and
    # leaves the home screen permanently broken. See main.py.
    if not settings.ENABLE_GAMIFICATION:
        return _disabled_streak_payload()

    try:
        result = await asyncio.to_thread(db.table("user_streaks").select("*").eq("user_id", user_id).maybe_single().execute)
        row = result.data if result else None
        if not row:
            now = _now()
            insert = {
                "user_id": user_id,
                "current_streak": 0,
                "longest_streak": 0,
                "last_planned_date": None,
                "streak_freezes_remaining": 3,
                "streak_skips_remaining": 1,
                "updated_at": now,
            }
            insert_result = await asyncio.to_thread(db.table("user_streaks").insert(insert).execute)
            if insert_result is None or not insert_result.data:
                raise DatabaseError("Failed to insert streak record")
            row = insert_result.data[0]
            logger.info(
                "User streak record initialized",
                user_id=user_id
            )

        current = _safe_int(row.get("current_streak"), 0)
        next_milestone = _compute_next_milestone(current)

        logger.debug(
            "Streak retrieved",
            user_id=user_id,
            current_streak=current
        )
        return {
            "data": {
                "current_streak": current,
                "longest_streak": _safe_int(row.get("longest_streak"), 0),
                "last_planned": row.get("last_planned_date"),
                "streak_freezes_remaining": _safe_int(row.get("streak_freezes_remaining"), 0),
                "streak_skips_remaining": _safe_int(row.get("streak_skips_remaining"), 0),
                "next_milestone": next_milestone,
            },
            "message": "OK",
        }
    except Exception as e:
        # Safe fallback - log the error but return default values
        logger.warning(
            "Streak retrieval failed, returning defaults",
            user_id=user_id,
            error=str(e),
            exc_info=False
        )
        return _disabled_streak_payload()


@router.get("/achievements", response_model=Dict[str, Any])
async def get_achievements(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    # Flag off -> 200 with an empty earned list, NOT 404. See main.py and the
    # Flutter Future.wait note on get_streak above.
    if not settings.ENABLE_GAMIFICATION:
        return _disabled_achievements_payload()

    catalog = _achievement_catalog()
    catalog_by_id = {row["id"]: row for row in catalog}

    def enrich_earned(rows: list) -> list:
        """Attach name/description from catalog when achievement_id matches slug ids."""
        enriched = []
        for row in rows or []:
            item = dict(row) if isinstance(row, dict) else {"raw": row}
            aid = str(item.get("achievement_id") or item.get("id") or "")
            meta = catalog_by_id.get(aid)
            if meta:
                item["name"] = meta["name"]
                item["description"] = meta["description"]
                item["xp_reward"] = meta.get("xp_reward")
            else:
                item.setdefault("name", "Achievement unlocked")
                item.setdefault("description", None)
            enriched.append(item)
        return enriched

    try:
        result = await asyncio.to_thread(db.table("user_achievements").select("*").eq("user_id", user_id).order("earned_at", desc=True).execute)
        earned_rows = enrich_earned(result.data if result else [])
        logger.debug(
            "Achievements retrieved",
            user_id=user_id,
            earned_count=len(earned_rows)
        )
        return {"data": {"earned": earned_rows, "available": catalog}, "message": "OK"}
    except Exception as e:
        logger.warning(
            "Achievements retrieval failed, returning defaults",
            user_id=user_id,
            error=str(e),
            exc_info=False
        )
        return _disabled_achievements_payload()


@router.get("/leaderboard", response_model=Dict[str, Any])
async def get_leaderboard(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    # Flag off -> 200 with no entries, NOT 404. See main.py and the Flutter
    # Future.wait note on get_streak above.
    if not settings.ENABLE_GAMIFICATION:
        return _disabled_leaderboard_payload()

    try:
        # Minimal leaderboard by current streak
        streaks_result = await asyncio.to_thread(
            db.table("user_streaks")
            .select("user_id,current_streak")
            .order("current_streak", desc=True)
            .limit(25)
            .execute
        )
        rows: List[Dict[str, Any]] = streaks_result.data if streaks_result else []

        user_ids = [r.get("user_id") for r in rows if r.get("user_id")]
        profiles: Dict[str, Dict[str, Any]] = {}
        if user_ids:
            prof_result = await asyncio.to_thread(
                db.table("users")
                .select("id,full_name,avatar_url")
                .in_("id", user_ids)
                .execute
            )
            prof_rows = prof_result.data if prof_result else []
            profiles = {str(p.get("id")): p for p in prof_rows if p.get("id")}

        entries: List[Dict[str, Any]] = []
        for idx, r in enumerate(rows):
            uid = str(r.get("user_id") or "")
            current_streak = _safe_int(r.get("current_streak"), 0)
            total_points = _compute_points(current_streak)
            profile = profiles.get(uid, {"id": uid})
            entries.append(
                {
                    "rank": idx + 1,
                    "user_id": uid,
                    "username": _display_name(profile),
                    "avatar_url": profile.get("avatar_url"),
                    "level": _compute_level(total_points),
                    "total_points": total_points,
                    "current_streak": current_streak,
                }
            )

        # User rank summary (best-effort)
        user_rank: Optional[Dict[str, Any]] = None
        try:
            me_result = await asyncio.to_thread(db.table("user_streaks").select("current_streak").eq("user_id", user_id).maybe_single().execute)
            me_row = me_result.data if me_result else None
            me_streak = _safe_int((me_row or {}).get("current_streak"), 0)
            higher = await asyncio.to_thread(db.table("user_streaks").select("user_id", count="exact").gt("current_streak", me_streak).execute)
            higher_count = getattr(higher, "count", len(getattr(higher, "data", []) or [])) or 0
            total = await asyncio.to_thread(db.table("user_streaks").select("user_id", count="exact").execute)
            total_users = getattr(total, "count", len(getattr(total, "data", []) or [])) or 0
            rank = int(higher_count) + 1
            points = _compute_points(me_streak)
            level = _compute_level(points)
            top_percentile = 100
            if total_users > 0:
                top_percentile = max(1, int((rank / total_users) * 100))
            user_rank = {
                "rank": rank,
                "total_points": points,
                "level": level,
                "total_users": total_users,
                "top_percentile": top_percentile,
            }
        except Exception as e:
            logger.warning(
                "User rank calculation failed",
                user_id=user_id,
                error=str(e),
                exc_info=False
            )
            user_rank = None

        logger.debug(
            "Leaderboard retrieved",
            user_id=user_id,
            entry_count=len(entries)
        )
        return {"data": {"entries": entries, "user_rank": user_rank}, "message": "OK"}
    except Exception as e:
        logger.warning(
            "Leaderboard retrieval failed, returning empty",
            user_id=user_id,
            error=str(e),
            exc_info=False
        )
        return _disabled_leaderboard_payload()
