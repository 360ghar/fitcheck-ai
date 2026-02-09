"""
Gamification API routes.

The documentation includes gamification as a Phase/P2 feature. This module
provides a minimal MVP backed by Supabase tables when available.

When the Supabase schema for gamification is finalized, these handlers can be
backed by tables like user_streaks, user_achievements, challenges, etc.
"""

from datetime import datetime
from typing import Any, Dict, List, Optional

from fastapi import APIRouter, Depends
from supabase import Client

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
    return datetime.utcnow().isoformat()


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


@router.get("/streak", response_model=Dict[str, Any])
async def get_streak(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = db.table("user_streaks").select("*").eq("user_id", user_id).maybe_single().execute()
        if result is None:
            raise DatabaseError("Database query returned None")
        row = result.data
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
            insert_result = db.table("user_streaks").insert(insert).execute()
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


@router.get("/achievements", response_model=Dict[str, Any])
async def get_achievements(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    available = [
        {"id": "first_upload", "name": "First Upload", "description": "Add your first wardrobe item", "xp_reward": 50},
        {"id": "first_outfit", "name": "First Outfit", "description": "Create your first outfit", "xp_reward": 50},
        {"id": "streak_7", "name": "7-day Streak", "description": "Plan outfits 7 days in a row", "xp_reward": 100},
    ]

    try:
        result = db.table("user_achievements").select("*").eq("user_id", user_id).order("earned_at", desc=True).execute()
        earned_rows = result.data if result else []
        logger.debug(
            "Achievements retrieved",
            user_id=user_id,
            earned_count=len(earned_rows)
        )
        return {"data": {"earned": earned_rows, "available": available}, "message": "OK"}
    except Exception as e:
        logger.warning(
            "Achievements retrieval failed, returning defaults",
            user_id=user_id,
            error=str(e),
            exc_info=False
        )
        return {"data": {"earned": [], "available": available}, "message": "OK"}


@router.get("/leaderboard", response_model=Dict[str, Any])
async def get_leaderboard(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        # Minimal leaderboard by current streak
        streaks_result = (
            db.table("user_streaks")
            .select("user_id,current_streak")
            .order("current_streak", desc=True)
            .limit(25)
            .execute()
        )
        rows: List[Dict[str, Any]] = streaks_result.data if streaks_result else []

        user_ids = [r.get("user_id") for r in rows if r.get("user_id")]
        profiles: Dict[str, Dict[str, Any]] = {}
        if user_ids:
            prof_result = (
                db.table("users")
                .select("id,full_name,avatar_url")
                .in_("id", user_ids)
                .execute()
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
            me_result = db.table("user_streaks").select("current_streak").eq("user_id", user_id).maybe_single().execute()
            me_row = me_result.data if me_result else None
            me_streak = _safe_int((me_row or {}).get("current_streak"), 0)
            higher = db.table("user_streaks").select("user_id", count="exact").gt("current_streak", me_streak).execute()
            higher_count = getattr(higher, "count", len(getattr(higher, "data", []) or [])) or 0
            total = db.table("user_streaks").select("user_id", count="exact").execute()
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
        return {"data": {"entries": []}, "message": "OK"}
