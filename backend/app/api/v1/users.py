"""
User API routes.
Handles user profile, preferences, and settings management.
"""

import uuid
import logging
from typing import Optional, List
from datetime import datetime

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr
from supabase import Client

from app.db.connection import get_db
from app.core.security import get_current_user_id, TokenData, verify_token
from app.models.user import (
    UserUpdate, UserResponse, UserPreferencesUpdate, UserPreferences,
    UserSettingsUpdate, UserSettings, UserStats, UserDashboard,
    BodyProfileCreate, BodyProfileUpdate, BodyProfile
)
from app.services.storage_service import StorageService

logger = logging.getLogger(__name__)

router = APIRouter()


# ============================================================================
# REQUEST MODELS
# ============================================================================


class AvatarUpload(BaseModel):
    """Avatar upload request."""
    avatar_url: str


# ============================================================================
# USER PROFILE ENDPOINTS
# ============================================================================


@router.get("/me", response_model=UserResponse)
async def get_current_user(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Get the current user's profile."""
    try:
        result = db.table("users").select("*").eq("id", user_id).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )


@router.put("/me", response_model=UserResponse)
async def update_current_user(
    update_data: UserUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Update the current user's profile."""
    try:
        # Verify user exists
        existing = db.table("users").select("id").eq("id", user_id).single().execute()

        if not existing.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        # Prepare update data
        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = datetime.now().isoformat()

        # Update user
        result = db.table("users").update(update_dict).eq("id", user_id).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update user"
            )

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating user: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the user"
        )


@router.post("/me/avatar", response_model=UserResponse)
async def upload_avatar(
    avatar_url: str,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Update user avatar URL."""
    try:
        result = db.table("users").update({
            "avatar_url": avatar_url,
            "updated_at": datetime.now().isoformat()
        }).eq("id", user_id).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update avatar"
            )

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating avatar: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the avatar"
        )


@router.get("/me/dashboard", response_model=UserDashboard)
async def get_user_dashboard(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Get dashboard data for the current user."""
    try:
        # Get user profile
        user_result = db.table("users").select("*").eq("id", user_id).single().execute()

        if not user_result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User not found"
            )

        user = user_result.data

        # Get stats
        stats = await _get_user_stats(user_id, db)

        # Get recent items
        recent_items_result = db.table("items").select("*").eq("user_id", user_id).order("created_at", desc=True).limit(5).execute()
        recent_items = recent_items_result.data

        # Get recent outfits
        recent_outfits_result = db.table("outfits").select("*").eq("user_id", user_id).order("created_at", desc=True).limit(5).execute()
        recent_outfits = recent_outfits_result.data

        # Get basic recommendations (favorites, least worn)
        recommendations_result = db.table("items").select("*").eq("user_id", user_id).eq("is_favorite", True).limit(3).execute()
        recommendations = recommendations_result.data

        return UserDashboard(
            user=user,
            stats=stats,
            recent_items=recent_items,
            recent_outfits=recent_outfits,
            recommendations=recommendations
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting dashboard: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching dashboard data"
        )


# ============================================================================
# USER PREFERENCES ENDPOINTS
# ============================================================================


@router.get("/me/preferences", response_model=UserPreferences)
async def get_user_preferences(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Get the current user's preferences."""
    try:
        result = db.table("user_preferences").select("*").eq("user_id", user_id).single().execute()

        if not result.data:
            # Create default preferences
            default_prefs = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "favorite_colors": [],
                "preferred_styles": [],
                "liked_brands": [],
                "disliked_patterns": [],
                "style_notes": None,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }

            insert_result = db.table("user_preferences").insert(default_prefs).execute()

            if insert_result.data:
                return insert_result.data[0]

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting preferences: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching preferences"
        )


@router.put("/me/preferences", response_model=UserPreferences)
async def update_user_preferences(
    update_data: UserPreferencesUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Update the current user's preferences."""
    try:
        # Check if preferences exist
        existing = db.table("user_preferences").select("id").eq("user_id", user_id).single().execute()

        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = datetime.now().isoformat()

        if existing.data:
            result = db.table("user_preferences").update(update_dict).eq("user_id", user_id).execute()
        else:
            # Create new preferences
            new_prefs = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                **update_dict,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            result = db.table("user_preferences").insert(new_prefs).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update preferences"
            )

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating preferences: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating preferences"
        )


# ============================================================================
# USER SETTINGS ENDPOINTS
# ============================================================================


@router.get("/me/settings", response_model=UserSettings)
async def get_user_settings(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Get the current user's settings."""
    try:
        result = db.table("user_settings").select("*").eq("user_id", user_id).single().execute()

        if not result.data:
            # Create default settings
            default_settings = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                "language": "en",
                "measurement_units": "imperial",
                "notifications_enabled": True,
                "email_marketing": False,
                "dark_mode": False,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }

            insert_result = db.table("user_settings").insert(default_settings).execute()

            if insert_result.data:
                return insert_result.data[0]

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting settings: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while fetching settings"
        )


@router.put("/me/settings", response_model=UserSettings)
async def update_user_settings(
    update_data: UserSettingsUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Update the current user's settings."""
    try:
        # Check if settings exist
        existing = db.table("user_settings").select("id").eq("user_id", user_id).single().execute()

        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = datetime.now().isoformat()

        if existing.data:
            result = db.table("user_settings").update(update_dict).eq("user_id", user_id).execute()
        else:
            # Create new settings
            new_settings = {
                "id": str(uuid.uuid4()),
                "user_id": user_id,
                **update_dict,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            result = db.table("user_settings").insert(new_settings).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update settings"
            )

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating settings: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating settings"
        )


# ============================================================================
# BODY PROFILE ENDPOINTS
# ============================================================================


@router.get("/me/body-profile", response_model=BodyProfile)
async def get_body_profile(
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Get the current user's body profile."""
    try:
        result = db.table("body_profiles").select("*").eq("user_id", user_id).order("created_at", desc=True).limit(1).single().execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Body profile not found"
            )

        return result.data

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting body profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Body profile not found"
        )


@router.post("/me/body-profile", response_model=BodyProfile, status_code=status.HTTP_201_CREATED)
async def create_body_profile(
    profile_data: BodyProfileCreate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Create a new body profile for the user."""
    try:
        profile_id = str(uuid.uuid4())

        new_profile = {
            "id": profile_id,
            "user_id": user_id,
            "height": profile_data.height,
            "weight": profile_data.weight,
            "body_type": profile_data.body_type,
            "skin_tone": profile_data.skin_tone,
            "hair_color": profile_data.hair_color,
            "eye_color": profile_data.eye_color,
            "notes": profile_data.notes,
            "created_at": datetime.now().isoformat(),
            "updated_at": datetime.now().isoformat()
        }

        result = db.table("body_profiles").insert(new_profile).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to create body profile"
            )

        # Link to user
        db.table("users").update({"body_profile_id": profile_id}).eq("id", user_id).execute()

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating body profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while creating the body profile"
        )


@router.put("/me/body-profile", response_model=BodyProfile)
async def update_body_profile(
    update_data: BodyProfileUpdate,
    user_id: str = Depends(get_current_user_id),
    db: Client = Depends(get_db)
):
    """Update the current user's body profile."""
    try:
        # Get existing profile
        existing = db.table("body_profiles").select("id").eq("user_id", user_id).order("created_at", desc=True).limit(1).single().execute()

        if not existing.data:
            # Create if doesn't exist
            return await create_body_profile(
                BodyProfileCreate(**update_data.model_dump()),
                user_id,
                db
            )

        profile_id = existing.data["id"]

        update_dict = update_data.model_dump(exclude_unset=True)
        update_dict["updated_at"] = datetime.now().isoformat()

        result = db.table("body_profiles").update(update_dict).eq("id", profile_id).execute()

        if not result.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to update body profile"
            )

        return result.data[0]

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating body profile: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while updating the body profile"
        )


# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================


async def _get_user_stats(user_id: str, db: Client) -> UserStats:
    """Get statistics about user's wardrobe and usage."""
    # Total items
    items_result = db.table("items").select("id", count="exact").eq("user_id", user_id).execute()
    total_items = items_result.count if hasattr(items_result, 'count') else len(items_result.data)

    # Total outfits
    outfits_result = db.table("outfits").select("id", count="exact").eq("user_id", user_id).execute()
    total_outfits = outfits_result.count if hasattr(outfits_result, 'count') else len(outfits_result.data)

    # Items by category
    category_items = db.table("items").select("category").eq("user_id", user_id).execute()
    items_by_category = {}
    for item in category_items.data:
        cat = item.get("category", "other")
        items_by_category[cat] = items_by_category.get(cat, 0) + 1

    # Items by condition
    condition_items = db.table("items").select("condition").eq("user_id", user_id).execute()
    items_by_condition = {}
    for item in condition_items.data:
        cond = item.get("condition", "clean")
        items_by_condition[cond] = items_by_condition.get(cond, 0) + 1

    # Most worn items
    most_worn_result = db.table("items").select("*").eq("user_id", user_id).order("usage_times_worn", desc=True).limit(5).execute()
    most_worn_items = most_worn_result.data

    # Least worn items
    least_worn_result = db.table("items").select("*").eq("user_id", user_id).order("usage_times_worn", asc=True).limit(5).execute()
    least_worn_items = least_worn_result.data

    # Calculate cost
    price_result = db.table("items").select("price").eq("user_id", user_id).not_.is_("price").execute()
    total_cost = sum(item.get("price", 0) for item in price_result.data)

    # Calculate cost per wear
    usage_result = db.table("items").select("price, usage_times_worn").eq("user_id", user_id).not_.is_("price").execute()

    total_wear_cost = 0
    total_wears = 0

    for item in usage_result.data:
        price = item.get("price", 0)
        wears = item.get("usage_times_worn", 0)
        total_wear_cost += price
        total_wears += wears

    avg_cost_per_wear = total_wear_cost / total_wears if total_wears > 0 else 0

    return UserStats(
        total_items=total_items,
        total_outfits=total_outfits,
        items_by_category=items_by_category,
        items_by_condition=items_by_condition,
        most_worn_items=most_worn_items,
        least_worn_items=least_worn_items,
        total_cost=total_cost,
        avg_cost_per_wear=avg_cost_per_wear,
        storage_used_bytes=None
    )
