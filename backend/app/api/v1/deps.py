"""
FastAPI dependency functions for routes.
Provides commonly used dependencies like database client and current user.
"""

import asyncio
import logging
from typing import Any, Dict
from fastapi import Depends
from supabase import Client

from app.db.connection import get_db, SupabaseDB
from app.core.security import verify_token, TokenData
from app.core.exceptions import AuthenticationError, PermissionDeniedError
from app.utils.datetime_util import utcnow_iso
from app.utils.db import execute_with_reconnect, maybe_single_data

logger = logging.getLogger(__name__)


def _is_missing_profile_error(error: Exception) -> bool:
    """Return whether PostgREST reported the expected no-row condition.

    Only the structured code field counts: a timeout/permission error whose
    message text merely contains "PGRST116" must not trigger OAuth
    auto-provisioning.
    """
    return getattr(error, "code", None) == "PGRST116"


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
        AuthenticationError: If user profile could not be loaded or created,
            or the account is suspended (is_active is False).
    """
    try:
        # supabase-py's Client is synchronous; this blocks the event loop for
        # the duration of the network call. get_current_user runs on nearly
        # every authenticated request (~140 routes), so it's the highest-
        # value place to stop blocking, without migrating the whole app off
        # the sync client (a much larger, separately-planned effort - see
        # app/db/connection.py for the full migration path this stops short
        # of). asyncio.to_thread offloads just this call to a worker thread.
        user = await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", token_data.sub).single().execute(),
            db,
            extra={"operation": "get_current_user.lookup", "user_id": token_data.sub},
        )
    except Exception as error:
        # Only a confirmed no-row response may enter OAuth profile
        # auto-provisioning. Timeouts, permissions, and other database errors
        # must not be misclassified as a missing profile.
        if not _is_missing_profile_error(error):
            logger.warning("Failed to load user profile for %s: %s", token_data.sub, error)
            raise AuthenticationError(
                message="User profile lookup failed",
                error_code="AUTH_PROFILE_LOOKUP_ERROR",
            ) from error
        user = None

    if user is not None and user.data:
        # Suspended accounts are rejected before anything else: the admin
        # panel (and every client) must not keep serving a user whose
        # account was disabled by an admin. is_active defaults to True for
        # rows created before the flag existed, so only an explicit False
        # counts as suspended. Raised OUTSIDE the lookup try/except so it is
        # not re-wrapped as AUTH_PROFILE_LOOKUP_ERROR.
        if user.data.get("is_active") is False:
            raise AuthenticationError(
                message="Account is suspended",
                error_code="ACCOUNT_SUSPENDED",
            )
        # Add email from token if not in database
        if not user.data.get("email") and token_data.email:
            user.data["email"] = token_data.email
        return user.data

    # Profile doesn't exist - attempt auto-creation for OAuth users.
    # All sync Supabase calls run in a worker thread so first-login does not
    # block the single event loop (same rationale as the select above).
    try:
        logger.info(f"Auto-creating profile for user {token_data.sub}")

        def _create_profile():
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

            now = utcnow_iso()
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

            return profile

        profile = await asyncio.to_thread(_create_profile)
        logger.info(f"Auto-created profile for OAuth user {token_data.sub}")
        return profile

    except Exception as e:
        logger.warning(f"Failed to auto-create user profile: {e}")
        raise AuthenticationError(
            message="User profile could not be loaded or created",
            error_code="AUTH_PROFILE_ERROR"
        )


# =============================================================================
# ACTIVE-USER DEPENDENCY
#
# Token-only routes (get_current_user_id) never checked the suspension flag:
# a suspended account could keep calling every route that resolved the token
# without loading the profile. get_active_user_id is the same cheap token
# dependency PLUS the is_active gate — one PK select on users.is_active, same
# error shape as get_current_user (AUTH_PROFILE_NOT_FOUND / ACCOUNT_SUSPENDED).
# Routers that only need the user id must depend on this, not the bare token.
# =============================================================================


async def get_active_user_id(
    db: Client = Depends(get_db),
    token_data: TokenData = Depends(verify_token),
) -> str:
    """Return the current user's id after verifying the profile exists and is active.

    Same suspension semantics as ``get_current_user`` for routes that only
    need the user id: a missing profile raises AUTH_PROFILE_NOT_FOUND and an
    explicitly suspended profile (is_active is False) raises ACCOUNT_SUSPENDED
    before the handler runs. Legacy rows without the flag pass (missing key
    != False).

    Args:
        db: Supabase client
        token_data: Verified JWT token data

    Returns:
        User id string

    Raises:
        AuthenticationError: If the profile is missing or the account is
            suspended.
    """
    result = await execute_with_reconnect(
        lambda d: d.table("users")
        .select("is_active")
        .eq("id", token_data.sub)
        .maybe_single()
        .execute(),
        db,
        extra={"operation": "get_active_user_id.lookup", "user_id": token_data.sub},
    )
    row = maybe_single_data(result)
    if row is None:
        raise AuthenticationError(
            message="User profile not found",
            error_code="AUTH_PROFILE_NOT_FOUND",
        )
    # Explicit False only: rows created before the flag existed default to
    # active, so a missing key must not be treated as suspension.
    if row.get("is_active") is False:
        raise AuthenticationError(
            message="Account is suspended",
            error_code="ACCOUNT_SUSPENDED",
        )
    return token_data.sub


# =============================================================================
# ADMIN AUTHORIZATION DEPENDENCIES
#
# Role/permission resolution lives in app.core.permissions (pure functions).
# These dependencies are the enforcement point: every /api/v1/admin/* route
# sits behind require_admin or require_permission(...). UI gating is cosmetic;
# this is the trust boundary (2026-08-06 admin panel spec, §4/§8).
# =============================================================================


async def require_admin(user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
    """Require an admin role (super_admin | admin | ops | support | content_editor).

    Replaces the legacy per-route ``verify_admin`` checks (blog.py) with one
    shared dependency; a plain ``user`` role gets 403.
    """
    from app.core.permissions import ADMIN_ROLES, get_user_role

    if get_user_role(user) not in ADMIN_ROLES:
        logger.warning(
            "Non-admin user attempted admin operation",
            extra={"user_id": user.get("id"), "role": get_user_role(user)},
        )
        raise PermissionDeniedError("Admin access required")
    return user


def require_permission(permission: str):
    """Dependency factory: require the current user's role to grant permission.

    Usage: ``user=Depends(require_permission("users.read"))``. The ``*``
    permission (super_admin/admin) grants everything.
    """

    async def _dependency(user: Dict[str, Any] = Depends(get_current_user)) -> Dict[str, Any]:
        from app.core.permissions import has_permission

        if not has_permission(user, permission):
            logger.warning(
                "User missing permission for admin operation",
                extra={"user_id": user.get("id"), "permission": permission},
            )
            raise PermissionDeniedError(f"Permission required: {permission}")
        return user

    return _dependency
