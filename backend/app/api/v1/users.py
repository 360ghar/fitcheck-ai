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
import re
from datetime import datetime
from typing import Any, Dict, List, Optional, Tuple
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


def _extract_missing_users_column(err: Exception) -> Optional[str]:
    """Return missing users.<column> name when Postgres reports undefined column."""
    code = getattr(err, "code", None)
    text = str(err).lower()
    has_missing_column_signal = (
        code in {"42703", "PGRST204"}
        or "42703" in text
        or "could not find the" in text
        or "column users." in text
    )
    if not has_missing_column_signal:
        return None

    match = re.search(r"column\s+users\.([a-z0-9_]+)\s+does\s+not\s+exist", text)
    if match:
        return match.group(1)
    match = re.search(r"could\s+not\s+find\s+the\s+'([a-z0-9_]+)'\s+column\s+of\s+'users'", text)
    if match:
        return match.group(1)
    return None


def _extract_birth_patch(payload: Dict[str, Any]) -> Dict[str, Any]:
    return {field: payload[field] for field in ("birth_date", "birth_time", "birth_place") if field in payload}


def _normalize_user_birth_fields(row: Dict[str, Any]) -> Dict[str, Any]:
    """Normalize user row for response. birth_date is the canonical field."""
    return dict(row or {})


def _get_auth_user_metadata(db: Client, user_id: str) -> Dict[str, Any]:
    try:
        admin = getattr(db.auth, "admin", None)
        if not admin or not hasattr(admin, "get_user_by_id"):
            return {}
        auth_user = admin.get_user_by_id(user_id)
        if auth_user and getattr(auth_user, "user", None):
            return dict(getattr(auth_user.user, "user_metadata", {}) or {})
    except Exception:
        return {}
    return {}


def _update_auth_user_metadata(db: Client, user_id: str, patch: Dict[str, Any]) -> None:
    if not patch:
        return
    admin = getattr(db.auth, "admin", None)
    if not admin or not hasattr(admin, "update_user_by_id"):
        return
    merged = _get_auth_user_metadata(db, user_id)
    merged.update(patch)
    admin.update_user_by_id(user_id, {"user_metadata": merged})


def _handle_db_error(
    operation: str,
    user_id: str,
    error: Exception,
    extra_context: Optional[Dict[str, Any]] = None,
) -> None:
    """Log error and raise standardized DatabaseError."""
    context = {"user_id": user_id, "error": str(error)}
    if extra_context:
        context.update(extra_context)
    logger.error(f"Failed to {operation}", **context)
    raise DatabaseError(f"Failed to {operation}")


def _first_row(result_data: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """Extract first row from query result."""
    return (result_data or [None])[0] if result_data else None


T = Dict[str, Any]


def _get_or_create_record(
    db: Client,
    table: str,
    user_id: str,
    defaults: Dict[str, Any],
    model_class: Any,
) -> Tuple[Dict[str, Any], bool]:
    """
    Get existing record or create with defaults.
    Returns (record_data, was_created).
    """
    result = db.table(table).select("*").eq("user_id", user_id).execute()
    if result.data:
        return model_class.model_validate(result.data[0]).model_dump(mode="json"), False

    insert_defaults = {**defaults, "user_id": user_id}
    insert = db.table(table).insert(insert_defaults).execute()
    row = _first_row(insert.data or [])
    if not row:
        raise DatabaseError(f"Failed to create {table}")
    return model_class.model_validate(row).model_dump(mode="json"), True


def _upsert_record(
    db: Client,
    table: str,
    user_id: str,
    update_data: Any,
    model_class: Any,
    defaults: Optional[Dict[str, Any]] = None,
) -> Dict[str, Any]:
    """
    Upsert a record for user: update if exists, insert if not.
    Returns validated record data.
    """
    update_dict = update_data.model_dump(exclude_unset=True)
    update_dict["updated_at"] = _now()

    existing = db.table(table).select("user_id").eq("user_id", user_id).execute()

    if existing.data:
        result = db.table(table).update(update_dict).eq("user_id", user_id).execute()
    else:
        insert = {
            "user_id": user_id,
            "created_at": _now(),
            "updated_at": _now(),
            **(defaults or {}),
            **update_dict,
        }
        result = db.table(table).insert(insert).execute()

    row = _first_row(result.data or [])
    if not row:
        raise DatabaseError(f"Failed to update {table}")
    return model_class.model_validate(row).model_dump(mode="json")


def _sync_birth_fields_to_auth(
    db: Client,
    user_id: str,
    birth_patch: Dict[str, Any],
) -> None:
    """Sync birth fields to auth metadata with error logging."""
    if not birth_patch:
        return
    try:
        _update_auth_user_metadata(db, user_id, birth_patch)
    except Exception as metadata_error:
        logger.warning(
            "Failed to sync birth fields to auth metadata",
            user_id=user_id,
            error=str(metadata_error),
        )


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

        user = UserResponse.model_validate(_normalize_user_birth_fields(result.data[0]))
        user_data = user.model_dump(mode="json")

        # Fallback for projects that haven't applied astrology profile migration yet.
        if not all(user_data.get(field) for field in ("birth_date", "birth_time", "birth_place")):
            meta = _get_auth_user_metadata(db, user_id)
            for field in ("birth_date", "birth_time", "birth_place"):
                if not user_data.get(field):
                    user_data[field] = meta.get(field)

        return {"data": user_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch user", user_id, e)


@router.put("/me", response_model=Dict[str, Any])
async def update_current_user(
    update_data: UserUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        update_dict = update_data.model_dump(mode="json", exclude_unset=True)
        if not update_dict:
            return await get_current_user(user_id=user_id, db=db)

        birth_patch = _extract_birth_patch(update_dict)
        update_payload = dict(update_dict)
        skipped_fields: List[str] = []

        while True:
            update_payload["updated_at"] = _now()
            try:
                result = db.table("users").update(update_payload).eq("id", user_id).execute()
                break
            except Exception as e:
                missing_col = _extract_missing_users_column(e)
                if not missing_col or missing_col not in update_payload:
                    raise
                if missing_col == "birth_date":
                    # Support legacy schema that still uses users.date_of_birth.
                    update_payload["date_of_birth"] = update_payload.get("birth_date")
                    update_payload.pop("birth_date", None)
                    logger.warning(
                        "users.birth_date missing, retrying update using users.date_of_birth",
                        user_id=user_id,
                    )
                    continue
                skipped_fields.append(missing_col)
                update_payload.pop(missing_col, None)
                logger.warning(
                    "Skipping update for missing users column",
                    user_id=user_id,
                    skipped_column=missing_col,
                )
                # Avoid empty update (only updated_at left).
                if set(update_payload.keys()) <= {"updated_at"}:
                    _sync_birth_fields_to_auth(db, user_id, birth_patch)
                    return {
                        "data": (await get_current_user(user_id=user_id, db=db))["data"],
                        "message": "No schema-compatible profile fields to update",
                        "meta": {"skipped_fields": skipped_fields},
                    }

        row = _first_row(result.data or [])
        if not row:
            raise DatabaseError("Failed to update user")

        _sync_birth_fields_to_auth(db, user_id, birth_patch)

        user = UserResponse.model_validate(_normalize_user_birth_fields(row))
        response: Dict[str, Any] = {"data": user.model_dump(mode="json"), "message": "Updated"}
        if skipped_fields:
            response["meta"] = {"skipped_fields": skipped_fields}
        return response

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update user", user_id, e)


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
        _handle_db_error("delete account", user_id, e)


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
        _handle_db_error("upload avatar", user_id, e, {"file_name": file.filename})


# ============================================================================
# PREFERENCES
# ============================================================================


_PREFERENCES_DEFAULTS = {
    "favorite_colors": [],
    "preferred_styles": [],
    "liked_brands": [],
    "disliked_patterns": [],
    "preferred_occasions": [],
    "color_temperature": None,
    "style_personality": None,
    "data_points_collected": 0,
    "last_updated": None,  # Set by _get_or_create_record
}


@router.get("/preferences", response_model=Dict[str, Any])
@router.get("/me/preferences", response_model=Dict[str, Any])  # backwards compatibility
async def get_user_preferences(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        prefs_data, _ = _get_or_create_record(
            db, "user_preferences", user_id, _PREFERENCES_DEFAULTS, UserPreferences
        )
        prefs_data["last_updated"] = _now()
        return {"data": prefs_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch preferences", user_id, e)


@router.put("/preferences", response_model=Dict[str, Any])
@router.put("/me/preferences", response_model=Dict[str, Any])  # backwards compatibility
async def update_user_preferences(
    update_data: UserPreferencesUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        prefs_data = _upsert_record(
            db, "user_preferences", user_id, update_data, UserPreferences, _PREFERENCES_DEFAULTS
        )
        return {"data": prefs_data, "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update preferences", user_id, e)


# ============================================================================
# SETTINGS
# ============================================================================


_SETTINGS_DEFAULTS = {
    "default_location": None,
    "timezone": None,
    "language": "en",
    "measurement_units": "imperial",
    "notifications_enabled": True,
    "email_marketing": False,
    "dark_mode": False,
}


@router.get("/settings", response_model=Dict[str, Any])
@router.get("/me/settings", response_model=Dict[str, Any])  # backwards compatibility
async def get_user_settings(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        settings_data, _ = _get_or_create_record(
            db, "user_settings", user_id, _SETTINGS_DEFAULTS, UserSettings
        )
        return {"data": settings_data, "message": "OK"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("fetch settings", user_id, e)


@router.put("/settings", response_model=Dict[str, Any])
@router.put("/me/settings", response_model=Dict[str, Any])  # backwards compatibility
async def update_user_settings(
    update_data: UserSettingsUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db),
):
    try:
        settings_data = _upsert_record(
            db, "user_settings", user_id, update_data, UserSettings, _SETTINGS_DEFAULTS
        )
        return {"data": settings_data, "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError):
        raise
    except Exception as e:
        _handle_db_error("update settings", user_id, e)


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
        _handle_db_error("fetch body profiles", user_id, e)


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
        row = _first_row(res.data or [])
        if not row:
            raise DatabaseError("Failed to create body profile")

        if payload.get("is_default"):
            db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute()

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Created"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("create body profile", user_id, e)


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
        row = _first_row(res.data or [])
        if not row:
            raise DatabaseError("Failed to update body profile")

        if update.get("is_default") is True:
            db.table("users").update({"body_profile_id": profile_id_str}).eq("id", user_id).execute()

        profile = BodyProfile.model_validate(row)
        return {"data": profile.model_dump(mode="json"), "message": "Updated"}

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("update body profile", user_id, e, {"profile_id": profile_id_str})


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

        was_default = existing.data[0].get("is_default") if existing.data else False

        db.table("body_profiles").delete().eq("id", profile_id_str).eq("user_id", user_id).execute()

        # If deleting the default profile, promote the newest remaining profile (if any)
        if was_default:
            remaining = (
                db.table("body_profiles")
                .select("id")
                .eq("user_id", user_id)
                .order("created_at", desc=True)
                .limit(1)
                .execute()
            )
            if remaining.data:
                new_default_id = remaining.data[0]["id"]
                db.table("body_profiles").update({"is_default": True, "updated_at": _now()}).eq("id", new_default_id).execute()
                db.table("users").update({"body_profile_id": new_default_id}).eq("id", user_id).execute()
            else:
                db.table("users").update({"body_profile_id": None}).eq("id", user_id).execute()

        return None

    except (UserNotFoundError, ValidationError, DatabaseError, BodyProfileNotFoundError):
        raise
    except Exception as e:
        _handle_db_error("delete body profile", user_id, e, {"profile_id": profile_id_str})


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
        _handle_db_error("fetch body profile", user_id, e)


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
            row = _first_row(result.data or [])
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
        row = _first_row(result.data or [])
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
        _handle_db_error("save body profile", user_id, e)


# ============================================================================
# DASHBOARD (MVP)
# ============================================================================


def _get_count_from_result(result: Any) -> int:
    """Extract count from Supabase result, handling different response formats."""
    return getattr(result, "count", len(result.data or []))


def _build_recent_activity(items: List[Dict], outfits: List[Dict]) -> List[Dict[str, Any]]:
    """Build combined recent activity list from items and outfits."""
    activity: List[Dict[str, Any]] = []

    for it in items:
        activity.append({
            "type": "item_created",
            "description": f"Added {it.get('name')}",
            "timestamp": it.get("created_at"),
        })

    for o in outfits:
        activity.append({
            "type": "outfit_created",
            "description": f"Created {o.get('name')}",
            "timestamp": o.get("created_at"),
        })

    return sorted(activity, key=lambda a: a.get("timestamp") or "", reverse=True)[:10]


async def _get_weather_suggestion(user_id: str, db: Client) -> Optional[Dict[str, Any]]:
    """Get weather-based suggestion for user."""
    try:
        settings_row = db.table("user_settings").select("default_location").eq("user_id", user_id).execute()
        location = settings_row.data[0].get("default_location") if (settings_row.data and len(settings_row.data) > 0) else None
        if not location:
            return None

        service = get_weather_service()
        weather = await service.get_weather(location=str(location), units="imperial")
        if not weather:
            return None

        temp_f = float(weather.get("temperature", 0))
        temp_c = round((temp_f - 32.0) * 5.0 / 9.0, 1)

        if temp_c < 5:
            recommendation = "Wear a warm coat and layered outfit."
        elif temp_c > 27:
            recommendation = "Choose breathable fabrics and lighter colors."
        else:
            recommendation = "Consider light layers."

        return {"temperature": temp_c, "recommendation": recommendation}
    except Exception:
        return None


async def _get_outfit_of_the_day(user_id: str, db: Client) -> Optional[Dict[str, Any]]:
    """Get the most recently updated outfit for the user."""
    try:
        outfit = (
            db.table("outfits")
            .select("id,name,outfit_images(image_url,thumbnail_url,is_primary)")
            .eq("user_id", user_id)
            .order("updated_at", desc=True)
            .limit(1)
            .execute()
        ).data or []

        if not outfit:
            return None

        o = outfit[0]
        images = o.get("outfit_images") or []
        primary = next((i for i in images if i.get("is_primary")), images[0] if images else None)
        return {
            "id": o.get("id"),
            "name": o.get("name"),
            "image_url": (primary or {}).get("thumbnail_url") or (primary or {}).get("image_url"),
        }
    except Exception:
        return None


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

        # Parallel queries for counts
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

        # Recent activity
        recent_items = (
            db.table("items")
            .select("id,name,created_at")
            .eq("user_id", user_id)
            .eq("is_deleted", False)
            .order("created_at", desc=True)
            .limit(5)
            .execute()
        ).data or []

        recent_outfits = (
            db.table("outfits")
            .select("id,name,created_at")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .limit(5)
            .execute()
        ).data or []

        recent_activity = _build_recent_activity(recent_items, recent_outfits)

        # Weather-based suggestion and outfit of the day
        weather_based = await _get_weather_suggestion(user_id, db)
        outfit_of_the_day = await _get_outfit_of_the_day(user_id, db)

        return {
            "data": {
                "user": user_row.data,
                "statistics": {
                    "total_items": _get_count_from_result(items_count),
                    "total_outfits": _get_count_from_result(outfits_count),
                    "items_added_this_month": _get_count_from_result(items_added_month),
                    "outfits_created_this_month": _get_count_from_result(outfits_created_month),
                    "most_worn_item": (
                        {"name": most_worn_item[0].get("name"), "times_worn": int(most_worn_item[0].get("usage_times_worn") or 0)}
                        if most_worn_item
                        else None
                    ),
                    "favorite_items_count": _get_count_from_result(fav_items),
                    "favorite_outfits_count": _get_count_from_result(fav_outfits),
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
        _handle_db_error("fetch dashboard", user_id, e)
