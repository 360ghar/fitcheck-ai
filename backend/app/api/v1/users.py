"""
User API routes.

Implements:
- GET/PUT /api/v1/users/me
- GET/PUT /api/v1/users/preferences
- GET/PUT /api/v1/users/settings
- GET/PUT /api/v1/users/body-profile
- POST /api/v1/users/me/avatar (upload)
- GET /api/v1/users/dashboard (MVP aggregate)
"""

import uuid
from datetime import datetime
from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Depends, File, UploadFile, status
from supabase import Client

from app.core.exceptions import (
    BodyProfileNotFoundError,
    DatabaseError,
    StorageServiceError,
    UnsupportedMediaTypeError,
    UserNotFoundError,
    ValidationError,
)
from app.core.logging_config import get_context_logger
from app.core.security import get_current_user_id
from app.db.connection import get_db
from app.models.user import (
    BodyProfile,
    BodyProfileCreate,
    BodyProfileUpdate,
    UserPreferences,
    UserPreferencesUpdate,
    UserResponse,
    UserSettings,
    UserSettingsUpdate,
    UserUpdate,
)
from app.services.storage_service import StorageService
from app.services.weather_service import get_weather_service

logger = get_context_logger(__name__)

router = APIRouter()


def _now() -> str:
    return datetime.utcnow().isoformat()


# ============================================================================
# PROFILE
# ============================================================================


@router.get("/me", response_model=Dict[str, Any])
async def get_current_user(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = db.table("users").select("*").eq("id", user_id).execute()
        if not result.data:
            raise UserNotFoundError(user_id=user_id)
        # Let Pydantic validate/normalize
        user = UserResponse.model_validate(result.data[0])
        return {"data": user.model_dump(mode="json"), "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to fetch user", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch user")


@router.put("/me", response_model=Dict[str, Any])
async def update_current_user(
    update_data: UserUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        update_dict = update_data.model_dump(exclude_unset=True)
        if not update_dict:
            # No-op
            return await get_current_user(user_id=user_id, db=db)
        update_dict["updated_at"] = _now()
        result = db.table("users").update(update_dict).eq("id", user_id).execute()
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update user")
        user = UserResponse.model_validate(row)
        return {"data": user.model_dump(mode="json"), "message": "Updated"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to update user", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update user")


@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_current_user(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Delete the current user's account and data (best-effort)."""
    try:
        # Best-effort: delete auth user (requires service role)
        try:
            admin = getattr(db.auth, "admin", None)
            if admin and hasattr(admin, "delete_user"):
                admin.delete_user(user_id)
        except Exception as e:
            logger.warning("Auth user deletion failed", user_id=user_id, error=str(e))

        # Ensure public data is deleted even if auth deletion isn't available
        try:
            db.table("users").delete().eq("id", user_id).execute()
        except Exception:
            pass

        return None
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to delete account", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to delete account")


@router.post("/me/avatar", response_model=Dict[str, Any])
async def upload_avatar(
    file: UploadFile = File(...),
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        if not file.content_type or not file.content_type.startswith("image/"):
            raise UnsupportedMediaTypeError(message="Avatar must be an image file")

        file_bytes = await file.read()
        avatar_url = await StorageService.upload_avatar(
            db=db, user_id=user_id, filename=file.filename or "avatar.png", file_data=file_bytes
        )

        db.table("users").update({"avatar_url": avatar_url, "updated_at": _now()}).eq("id", user_id).execute()
        return {"data": {"avatar_url": avatar_url}, "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError, UnsupportedMediaTypeError, StorageServiceError):
        raise
    except Exception as e:
        logger.error("Failed to upload avatar", user_id=user_id, file_name=file.filename, error=str(e))
        raise StorageServiceError("Failed to upload avatar")


# ============================================================================
# PREFERENCES
# ============================================================================


@router.get("/preferences", response_model=Dict[str, Any])
@router.get("/me/preferences", response_model=Dict[str, Any])  # backwards compatibility
async def get_user_preferences(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = db.table("user_preferences").select("*").eq("user_id", user_id).execute()
        if not result.data:
            # Create defaults
            defaults = {
                "user_id": user_id,
                "favorite_colors": [],
                "preferred_styles": [],
                "liked_brands": [],
                "disliked_patterns": [],
                "preferred_occasions": [],
                "color_temperature": None,
                "style_personality": None,
                "data_points_collected": 0,
                "last_updated": _now(),
            }
            insert = db.table("user_preferences").insert(defaults).execute()
            row = (insert.data or [None])[0]
            if not row:
                raise DatabaseError("Failed to create preferences")
            prefs = UserPreferences.model_validate(row)
            return {"data": prefs.model_dump(mode="json"), "message": "OK"}

        prefs = UserPreferences.model_validate(result.data[0])
        return {"data": prefs.model_dump(mode="json"), "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to fetch preferences", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch preferences")


@router.put("/preferences", response_model=Dict[str, Any])
@router.put("/me/preferences", response_model=Dict[str, Any])  # backwards compatibility
async def update_user_preferences(
    update_data: UserPreferencesUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["last_updated"] = _now()

        existing = db.table("user_preferences").select("user_id").eq("user_id", user_id).execute()
        if existing.data:
            result = db.table("user_preferences").update(update_dict).eq("user_id", user_id).execute()
        else:
            result = db.table("user_preferences").insert({"user_id": user_id, **update_dict}).execute()

        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update preferences")
        prefs = UserPreferences.model_validate(row)
        return {"data": prefs.model_dump(mode="json"), "message": "Updated"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to update preferences", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update preferences")


# ============================================================================
# SETTINGS
# ============================================================================


@router.get("/settings", response_model=Dict[str, Any])
@router.get("/me/settings", response_model=Dict[str, Any])  # backwards compatibility
async def get_user_settings(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = db.table("user_settings").select("*").eq("user_id", user_id).execute()
        if not result.data:
            defaults = {
                "user_id": user_id,
                "default_location": None,
                "timezone": None,
                "language": "en",
                "measurement_units": "imperial",
                "notifications_enabled": True,
                "email_marketing": False,
                "dark_mode": False,
                "created_at": _now(),
                "updated_at": _now(),
            }
            insert = db.table("user_settings").insert(defaults).execute()
            row = (insert.data or [None])[0]
            if not row:
                raise DatabaseError("Failed to create settings")
            settings = UserSettings.model_validate(row)
            return {"data": settings.model_dump(mode="json"), "message": "OK"}

        settings = UserSettings.model_validate(result.data[0])
        return {"data": settings.model_dump(mode="json"), "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to fetch settings", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch settings")


@router.put("/settings", response_model=Dict[str, Any])
@router.put("/me/settings", response_model=Dict[str, Any])  # backwards compatibility
async def update_user_settings(
    update_data: UserSettingsUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = _now()

        existing = db.table("user_settings").select("user_id").eq("user_id", user_id).execute()
        if existing.data:
            result = db.table("user_settings").update(update_dict).eq("user_id", user_id).execute()
        else:
            insert = {
                "user_id": user_id,
                "created_at": _now(),
                "updated_at": _now(),
                **update_dict,
            }
            result = db.table("user_settings").insert(insert).execute()

        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update settings")
        settings = UserSettings.model_validate(row)
        return {"data": settings.model_dump(mode="json"), "message": "Updated"}
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to update settings", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to update settings")


# ============================================================================
# BODY PROFILE
# ============================================================================


@router.get("/body-profiles", response_model=Dict[str, Any])
async def list_body_profiles(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """List all body profiles for the user."""
    try:
        res = (
            db.table("body_profiles")
            .select("*")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .execute()
        )
        profiles = [BodyProfile.model_validate(r).model_dump(mode="json") for r in (res.data or [])]
        return {"data": {"body_profiles": profiles}, "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to fetch body profiles", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch body profiles")


@router.post("/body-profiles", response_model=Dict[str, Any], status_code=status.HTTP_201_CREATED)
async def create_body_profile(
    request: BodyProfileCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Create a new body profile."""
    try:
        now = _now()
        existing_count = db.table("body_profiles").select("id", count="exact").eq("user_id", user_id).execute()
        count = getattr(existing_count, "count", len(existing_count.data or []))

        payload = request.model_dump()
        if count == 0:
            payload["is_default"] = True

        if payload.get("is_default"):
            db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute()

        profile_id = str(uuid.uuid4())
        insert = {"id": profile_id, "user_id": user_id, **payload, "created_at": now, "updated_at": now}
        res = db.table("body_profiles").insert(insert).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to create body profile")

        if payload.get("is_default"):
            db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute()

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Created"}
    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to create body profile", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to create body profile")


@router.put("/body-profiles/{profile_id}", response_model=Dict[str, Any])
async def update_body_profile(
    profile_id: UUID,
    update_data: BodyProfileUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Update an existing body profile."""
    try:
        profile_id_str = str(profile_id)
        existing = db.table("body_profiles").select("*").eq("id", profile_id_str).eq("user_id", user_id).execute()
        if not existing.data:
            raise BodyProfileNotFoundError(profile_id=profile_id_str)

        update = update_data.model_dump(exclude_unset=True)
        update["updated_at"] = _now()

        if update.get("is_default") is True:
            db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute()

        res = db.table("body_profiles").update(update).eq("id", profile_id_str).eq("user_id", user_id).execute()
        row = (res.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update body profile")

        if update.get("is_default") is True:
            db.table("users").update({"body_profile_id": profile_id_str}).eq("id", user_id).execute()

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Updated"}
    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to update body profile", user_id=user_id, profile_id=str(profile_id), error=str(e))
        raise DatabaseError("Failed to update body profile")


@router.delete("/body-profiles/{profile_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_body_profile(
    profile_id: UUID,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Delete a body profile."""
    try:
        profile_id_str = str(profile_id)
        existing = db.table("body_profiles").select("id,is_default").eq("id", profile_id_str).eq("user_id", user_id).execute()
        if not existing.data:
            raise BodyProfileNotFoundError(profile_id=profile_id_str)

        db.table("body_profiles").delete().eq("id", profile_id_str).eq("user_id", user_id).execute()

        # If deleting the default profile, promote the newest remaining profile (if any)
        if existing.data.get("is_default"):
            remaining = (
                db.table("body_profiles")
                .select("id")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(1)
                .execute()
            )
            if remaining.data and len(remaining.data) > 0:
                new_default_id = remaining.data[0]["id"]
                db.table("body_profiles").update({"is_default": True, "updated_at": _now()}).eq("id", new_default_id).execute()
                db.table("users").update({"body_profile_id": new_default_id}).eq("id", user_id).execute()
            else:
                db.table("users").update({"body_profile_id": None}).eq("id", user_id).execute()

        return None
    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to delete body profile", user_id=user_id, profile_id=str(profile_id), error=str(e))
        raise DatabaseError("Failed to delete body profile")


@router.get("/body-profile", response_model=Dict[str, Any])
@router.get("/me/body-profile", response_model=Dict[str, Any])  # backwards compatibility
async def get_body_profile(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        result = (
            db.table("body_profiles")
            .select("*")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .limit(1)
            .single()
            .execute()
        )
        if not result.data:
            raise BodyProfileNotFoundError()

        profile = BodyProfile.model_validate(result.data)
        return {"data": profile.model_dump(mode="json"), "message": "OK"}
    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to fetch body profile", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch body profile")


@router.put("/body-profile", response_model=Dict[str, Any])
@router.put("/me/body-profile", response_model=Dict[str, Any])  # backwards compatibility
async def upsert_body_profile(
    update_data: BodyProfileUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        existing = (
            db.table("body_profiles")
            .select("id, is_default")
            .eq("user_id", user_id)
            .order("is_default", desc=True)
            .order("created_at", desc=True)
            .limit(1)
            .single()
            .execute()
        )

        now = _now()
        if not existing.data:
            # Creating requires full payload; validate via BodyProfileCreate
            create = BodyProfileCreate(**update_data.model_dump(exclude_unset=True))
            insert = {
                "user_id": user_id,
                **create.model_dump(),
                "is_default": True,
                "created_at": now,
                "updated_at": now,
            }
            result = db.table("body_profiles").insert(insert).execute()
            row = (result.data or [None])[0]
            if not row:
                raise DatabaseError("Failed to create body profile")
            profile_id = row["id"]
            # Link default profile
            db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute()
            profile = BodyProfile.model_validate(row)
            return {"data": profile.model_dump(mode="json"), "message": "Created"}

        profile_id = existing.data["id"]
        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = now

        if update_dict.get("is_default") is True:
            db.table("body_profiles").update({"is_default": False}).eq("user_id", user_id).execute()

        result = db.table("body_profiles").update(update_dict).eq("id", profile_id).execute()
        row = (result.data or [None])[0]
        if not row:
            raise DatabaseError("Failed to update body profile")

        # If user toggles is_default, keep users.body_profile_id updated
        if update_dict.get("is_default") is True:
            db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute()

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        logger.error("Failed to save body profile", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to save body profile")


# ============================================================================
# DASHBOARD (MVP)
# ============================================================================


@router.get("/dashboard", response_model=Dict[str, Any])
async def get_dashboard(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    """Aggregate endpoint for the dashboard UI."""
    try:
        user_row = db.table("users").select("*").eq("id", user_id).execute()
        if not user_row.data:
            raise UserNotFoundError(user_id=user_id)

        now_dt = datetime.utcnow()
        month_start = now_dt.replace(day=1, hour=0, minute=0, second=0, microsecond=0).isoformat()

        items_count = db.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_deleted", False).execute()
        outfits_count = db.table("outfits").select("id", count="exact").eq("user_id", user_id).execute()

        items_added_month = (
            db.table("items")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .gte("created_at", month_start)
            .execute()
        )
        outfits_created_month = (
            db.table("outfits")
            .select("id", count="exact")
            .eq("user_id", user_id)
            .gte("created_at", month_start)
            .execute()
        )

        most_worn_item = (
            db.table("items")
            .select("name,usage_times_worn")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("usage_times_worn", desc=True)
            .limit(1)
            .execute()
        ).data or []

        fav_items = db.table("items").select("id", count="exact").eq("user_id", user_id).eq("is_favorite", True).eq("is_deleted", False).execute()
        fav_outfits = db.table("outfits").select("id", count="exact").eq("user_id", user_id).eq("is_favorite", True).execute()

        # Recent activity (best-effort)
        recent_activity: List[Dict[str, Any]] = []

        recent_items = (
            db.table("items")
            .select("id,name,created_at")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("created_at", desc=True)
            .limit(5)
            .execute()
        ).data or []
        for it in recent_items:
            recent_activity.append(
                {
                    "type": "item_created",
                    "description": f"Added {it.get('name')}",
                    "timestamp": it.get("created_at"),
                }
            )

        recent_outfits = (
            db.table("outfits")
            .select("id,name,created_at")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(5)
            .execute()
        ).data or []
        for o in recent_outfits:
            recent_activity.append(
                {
                    "type": "outfit_created",
                    "description": f"Created {o.get('name')}",
                    "timestamp": o.get("created_at"),
                }
            )

        # Sort recent activity by timestamp desc and keep top 10
        recent_activity = sorted(recent_activity, key=lambda a: a.get("timestamp") or "", reverse=True)[:10]

        # Weather-based suggestion (optional)
        weather_based = None
        try:
            settings_row = db.table("user_settings").select("default_location").eq("user_id", user_id).execute()
            location = settings_row.data[0].get("default_location") if (settings_row.data and len(settings_row.data) > 0) else None
            if location:
                service = get_weather_service()
                weather = await service.get_weather(location=str(location), units="imperial")
                if weather:
                    temp_f = float(weather.get("temperature", 0))
                    temp_c = round((temp_f - 32.0) * 5.0 / 9.0, 1)
                    recommendation = "Consider light layers."
                    if temp_c < 5:
                        recommendation = "Wear a warm coat and layered outfit."
                    elif temp_c > 27:
                        recommendation = "Choose breathable fabrics and lighter colors."
                    weather_based = {"temperature": temp_c, "recommendation": recommendation}
        except Exception:
            weather_based = None

        # Outfit of the day (most recently updated)
        outfit_of_the_day = None
        try:
            outfit = (
                db.table("outfits")
                .select("id,name,outfit_images(image_url,thumbnail_url,is_primary)")
                .eq("user_id", user_id)
                .order("updated_at", desc=True)
                .limit(1)
                .execute()
            ).data or []
            if outfit:
                o = outfit[0]
                images = o.get("outfit_images") or []
                primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
                outfit_of_the_day = {
                    "id": o.get("id"),
                    "name": o.get("name"),
                    "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
                }
        except Exception:
            outfit_of_the_day = None

        return {
            "data": {
                "user": user_row.data,
                "statistics": {
                    "total_items": getattr(items_count, "count", len(items_count.data or [])),
                    "total_outfits": getattr(outfits_count, "count", len(outfits_count.data or [])),
                    "items_added_this_month": getattr(items_added_month, "count", len(items_added_month.data or [])),
                    "outfits_created_this_month": getattr(outfits_created_month, "count", len(outfits_created_month.data or [])),
                    "most_worn_item": (
                        {"name": most_worn_item[0].get("name"), "times_worn": int(most_worn_item[0].get("usage_times_worn") or 0)}
                        if most_worn_item
                        else None
                    ),
                    "favorite_items_count": getattr(fav_items, "count", len(fav_items.data or [])),
                    "favorite_outfits_count": getattr(fav_outfits, "count", len(fav_outfits.data or [])),
                },
                "recent_activity": recent_activity,
                "suggestions": {
                    "weather_based": weather_based,
                    "outfit_of_the_day": outfit_of_the_day,
                },
            },
            "message": "OK",
        }
    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        logger.error("Failed to fetch dashboard", user_id=user_id, error=str(e))
        raise DatabaseError("Failed to fetch dashboard")
