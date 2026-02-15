"""
FastAPI dependency functions for routes.
Provides commonly used dependencies like database client and current user.
"""

import logging
from datetime import datetime
from fastapi import Depends
from supabase import Client

from app.db.connection import get_db, SupabaseDB
from app.core.security import verify_token, TokenData
from app.core.exceptions import AuthenticationError

logger = logging.getLogger(__name__)


async def get_current_user(
    db: Client = Depends(get_db),
    token_data: TokenData = Depends(verify_token)
):
    """Get the current authenticated user from the database.

    If the user profile doesn't exist (e.g., OAuth user on first API call),
    attempt to create it from Supabase Auth metadata.

    Args:
        db: Supabase client
        token_data: Verified JWT token data

    Returns:
        User data dict

    Raises:
        AuthenticationError: If user profile could not be loaded or created
    """
    try:
        user = db.table("users").select("*").eq("id", token_data.sub).single().execute()
        if user.data:
            # Add email from token if not in database
            if not user.data.get("email") and token_data.email:
                user.data["email"] = token_data.email
            return user.data
    except Exception:
        # User might not exist in public.users table yet
        pass

    # Profile doesn't exist - attempt auto-creation for OAuth users
    try:
        logger.info(f"Auto-creating profile for user {token_data.sub}")

        # Fetch metadata from Supabase Auth
        client = SupabaseDB.get_service_client()
        auth_user = client.auth.admin.get_user_by_id(token_data.sub)
        user_metadata = {}
        email = token_data.email

        if auth_user and auth_user.user:
            user_metadata = auth_user.user.user_metadata or {}
            email = auth_user.user.email or email

        full_name = (
            user_metadata.get("full_name")
            or user_metadata.get("name")  # Google OAuth
            or ""
        )
        avatar_url = (
            user_metadata.get("avatar_url")
            or user_metadata.get("picture")  # Google OAuth
        )

        now = datetime.now().isoformat()
        profile = {
            "id": token_data.sub,
            "email": email,
            "full_name": full_name,
            "avatar_url": avatar_url,
            "email_verified": True,
            "is_active": True,
            "created_at": now,
            "updated_at": now,
            "last_login_at": now,
        }

        db.table("users").upsert(profile, on_conflict="id").execute()

        # Create default preferences and settings
        try:
            db.table("user_preferences").upsert({
                "user_id": token_data.sub,
                "favorite_colors": [],
                "preferred_styles": [],
                "liked_brands": [],
                "disliked_patterns": [],
                "preferred_occasions": [],
                "data_points_collected": 0,
            }, on_conflict="user_id").execute()
        except Exception:
            pass  # May already exist from trigger

        try:
            db.table("user_settings").upsert({
                "user_id": token_data.sub,
                "language": "en",
                "measurement_units": "imperial",
                "notifications_enabled": True,
                "email_marketing": False,
                "dark_mode": False,
            }, on_conflict="user_id").execute()
        except Exception:
            pass  # May already exist from trigger

        logger.info(f"Auto-created profile for OAuth user {token_data.sub}")
        return profile

    except Exception as e:
        logger.warning(f"Failed to auto-create user profile: {e}")
        raise AuthenticationError(
            message="User profile could not be loaded or created",
            error_code="AUTH_PROFILE_ERROR"
        )
