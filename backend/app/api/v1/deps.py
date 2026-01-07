"""
FastAPI dependency functions for routes.
Provides commonly used dependencies like database client and current user.
"""

from fastapi import Depends
from supabase import Client

from app.db.connection import get_db
from app.core.security import verify_token, TokenData


async def get_current_user(
    db: Client = Depends(get_db),
    token_data: TokenData = Depends(verify_token)
):
    """Get the current authenticated user from the database.

    Args:
        db: Supabase client
        token_data: Verified JWT token data

    Returns:
        User data dict or None if not found
    """
    try:
        user = db.table("users").select("*").eq("id", token_data.sub).single().execute()
        if user.data:
            # Add email from token if not in database
            if not user.data.get("email") and token_data.email:
                user.data["email"] = token_data.email
            return user.data
    except Exception as e:
        # User might not exist in public.users table yet
        pass

    return None
