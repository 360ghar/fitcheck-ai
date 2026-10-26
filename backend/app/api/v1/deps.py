"""
FastAPI dependency functions for routes.
Provides commonly used dependencies like database client and current user.
"""

import asyncio
import logging
from typing import Any, Dict, Optional
from fastapi import Depends
from supabase import Client

from app.db.connection import get_db, SupabaseDB
from app.core.middleware import apply_user_language
from app.core.security import verify_token, TokenData
from app.core.exceptions import AuthenticationError, PermissionDeniedError
from app.core import user_profile_cache
from app.utils.datetime_util import utcnow_iso
from app.utils.db import execute_with_reconnect, maybe_single_data

logger = logging.getLogger(__name__)


def _stored_language(profile: Dict[str, Any]) -> tuple[Optional[str], bool]:
    """The user's saved language and whether they picked it.

    Both auth lookups embed `user_settings(language, language_explicit)` on the
    profile query, so this costs no extra roundtrip. PostgREST returns the
    one-to-one embed as a dict (a list is tolerated because a schema change
    could make it one-to-many), and a profile created before this embed existed
    simply has no key — the request then keeps the language `Accept-Language`
    resolved to.

    `language_explicit` comes from migration 065. Before that migration is
    applied the embed fails (PostgREST PGRST200/201/202) and `_select_user_row`
    retries a plain select, so this returns `(None, False)` and the request
    falls back to the header — degraded, never broken.
    """
    settings = profile.get("user_settings")
    if isinstance(settings, list):
        settings = settings[0] if settings else None
    if not isinstance(settings, dict):
        return None, False
    value = settings.get("language")
    explicit = settings.get("language_explicit")
    return (str(value) if value else None), explicit is True


def _is_missing_profile_error(error: Exception) -> bool:
    """Return whether PostgREST reported the expected no-row condition.

    Only the structured code field counts: a timeout/permission error whose
    message text merely contains "PGRST116" must not trigger OAuth
    auto-provisioning.
    """
    return getattr(error, "code", None) == "PGRST116"


# The embed token both auth selects carry. The stored language is read from it,
# never from a second query (see _stored_language).
_LANGUAGE_EMBED = ", user_settings(language, language_explicit)"

# PostgREST answers an embed it cannot resolve (stale schema cache, missing FK
# in a self-hosted build) with one of these. Retrying without the embed keeps a
# display preference from turning into a 401/500 on every authenticated route.
#
# `42703` is the case that matters for migration 065. When the embedded table
# lacks the COLUMN — not the relationship — PostgREST passes Postgres' error
# through verbatim, and the live project answers:
#
#   HTTP 400  {"code":"42703",
#              "message":"column user_settings_1.language_explicit does not exist"}
#
# That is checked against the real project, not inferred: the PGRST2xx codes
# above are for a relationship PostgREST cannot resolve, and a missing column
# produces `42703` instead. Without it, deploying this code ahead of the
# migration makes every authenticated request raise — the failure lands on the
# hot path of auth, not on a settings screen.
_EMBED_UNSUPPORTED_CODES = frozenset({"PGRST200", "PGRST201", "PGRST202", "42703"})

# `postgrest-py` does not guarantee a `code` attribute on every error shape, so
# the code alone is not a reliable test. The message is the fallback signal, but
# it has to name the column: every Postgres "something does not exist" error
# reads the same, so matching on `does not exist` alone would swallow a missing
# TABLE — a broken schema — and quietly drop the language preference instead of
# failing loudly.
_EMBED_COLUMN_NAME = "language_explicit"


def _embed_is_unsupported(error: Exception) -> bool:
    if getattr(error, "code", None) in _EMBED_UNSUPPORTED_CODES:
        return True
    text = str(error)
    return _EMBED_COLUMN_NAME in text and "does not exist" in text


async def _select_user_row(db: Client, *, columns: str, user_id: str, operation: str) -> Any:
    """Select one ``users`` row, degrading gracefully if the embed is rejected."""
    try:
        return await execute_with_reconnect(
            lambda d: d.table("users").select(columns).eq("id", user_id).maybe_single().execute(),
            db,
            extra={"operation": operation, "user_id": user_id},
        )
    except Exception as error:
        if not _embed_is_unsupported(error):
            raise
        logger.warning(
            "user_settings embed rejected by PostgREST; language falls back to Accept-Language",
            extra={
                "operation": operation,
                "user_id": user_id,
                "code": getattr(error, "code", None),
            },
        )
        # Drop only the column migration 065 adds, keeping `language`. The
        # stored preference still works; what is lost is the distinction
        # between "picked English" and "never picked", which is exactly the
        # bit the missing column was meant to carry. Stripping the whole embed
        # would throw away a working language preference to recover from a
        # missing column, which is a much worse trade.
        reduced = columns.replace(", language_explicit", "")
        try:
            return await execute_with_reconnect(
                lambda d: d.table("users").select(reduced).eq("id", user_id).maybe_single().execute(),
                db,
                extra={"operation": operation, "user_id": user_id, "embed": "reduced"},
            )
        except Exception as reduced_error:
            if not _embed_is_unsupported(reduced_error):
                raise
            logger.warning(
                "user_settings embed rejected even without the new column; "
                "dropping it entirely",
                extra={"operation": operation, "user_id": user_id},
            )
            plain_columns = columns.replace(_LANGUAGE_EMBED, "")
            return await execute_with_reconnect(
                lambda d: d.table("users").select(plain_columns).eq("id", user_id).maybe_single().execute(),
                db,
                extra={"operation": operation, "user_id": user_id, "embed": "none"},
            )


async def _provision_profile(token_data: TokenData, db: Client) -> Dict[str, Any]:
    """Create a first-login profile while the cache single-flight lock is held."""
    logger.info("Auto-creating profile for OAuth user %s", token_data.sub)

    def _create_profile() -> Dict[str, Any]:
        client = SupabaseDB.get_service_client()
        auth_user = client.auth.admin.get_user_by_id(token_data.sub)
        if not auth_user or not auth_user.user:
            raise AuthenticationError(
                "User account no longer exists",
                error_code="AUTH_PROFILE_NOT_FOUND",
            )

        user_metadata = auth_user.user.user_metadata or {}
        email = auth_user.user.email or token_data.email
        full_name = (
            user_metadata.get("full_name")
            or user_metadata.get("name")
            or ""
        )[:255]
        avatar_url = (
            user_metadata.get("avatar_url")
            or user_metadata.get("picture")
        )
        if avatar_url is not None:
            avatar_url = avatar_url[:500]

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
            pass
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
            pass
        return profile

    return await asyncio.to_thread(_create_profile)


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
        # `.maybe_single()` (not `.single()`, A2-17): a missing profile is a
        # bare None result, so the no-row case is a VALUE, not an exception —
        # the PGRST116 code attribute is not guaranteed by postgrest-py and
        # must not be the provisioning signal.
        #
        # The lookup itself is wrapped in a short-TTL single-flight cache
        # (app.core.user_profile_cache): launch bursts fire 5+ parallel
        # requests that each paid this roundtrip; now they share one load,
        # and warm-cache requests skip it entirely. Writers invalidate via
        # user_profile_cache.invalidate (users.py, admin_service.py); the
        # 30 s TTL bounds staleness for anything else. Suspension still
        # applies: the cached dict carries is_active and the check below
        # runs on every request regardless of cache state.
        async def _load_profile():
            # Unwrap .data here so the cache stores plain profile dicts
            # (or None), not postgrest response objects.
            result = await _select_user_row(
                db,
                columns="*" + _LANGUAGE_EMBED,
                user_id=token_data.sub,
                operation="get_current_user.lookup",
            )
            return maybe_single_data(result)

        async def _load_or_provision_profile():
            try:
                profile = await _load_profile()
            except Exception as error:
                if not _is_missing_profile_error(error):
                    raise
                profile = None
            if profile is not None:
                return profile
            try:
                return await _provision_profile(token_data, db)
            except AuthenticationError:
                raise
            except Exception as error:
                logger.warning(
                    "Failed to auto-create user profile for %s: %s",
                    token_data.sub,
                    error,
                )
                raise AuthenticationError(
                    message="User profile could not be loaded or created",
                    error_code="AUTH_PROFILE_ERROR",
                ) from error

        user = await user_profile_cache.get_or_load(
            token_data.sub,
            _load_or_provision_profile,
        )
    except AuthenticationError:
        raise
    except Exception as error:
        # With maybe_single, a raised error is NEVER a missing profile (the
        # id lookup is on the PK, so PGRST116/multi-row is impossible) —
        # timeouts, permissions and other database errors must not be
        # misclassified as a missing profile. `_is_missing_profile_error` is
        # kept for legacy error surfaces that still raise PGRST116.
        logger.warning("Failed to load user profile for %s: %s", token_data.sub, error)
        raise AuthenticationError(
            message="User profile lookup failed",
            error_code="AUTH_PROFILE_LOOKUP_ERROR",
        ) from error

    if user is None:
        # The loader provisions a missing profile while it holds the cache
        # single-flight lock, so this would only be possible for a malformed
        # loader result. Never revive the removed pre-lock provisioning path.
        raise AuthenticationError(
            message="User profile could not be loaded or created",
            error_code="AUTH_PROFILE_ERROR",
        )

    # Suspended accounts are rejected before anything else: the admin panel
    # must not keep serving a user whose account was disabled by an admin.
    # is_active defaults to True for rows created before the flag existed, so
    # only an explicit False counts as suspended.
    if user.get("is_active") is False:
        raise AuthenticationError(
            message="Account is suspended",
            error_code="ACCOUNT_SUSPENDED",
        )
    # Add email from token if not in database.
    if not user.get("email") and token_data.email:
        user["email"] = token_data.email
    # AI text is generated in the user's own language: an explicit settings
    # choice (including an explicit English) outranks `Accept-Language`.
    # Services read this from the contextvar.
    stored, explicit = _stored_language(user)
    apply_user_language(stored, explicit=explicit)
    return user


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
    result = await _select_user_row(
        db,
        columns="is_active" + _LANGUAGE_EMBED,
        user_id=token_data.sub,
        operation="get_active_user_id.lookup",
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
    # Same stored-language upgrade as get_current_user: this dependency backs
    # the upload/extraction/generation routes, which are exactly the ones that
    # write user-visible text.
    stored, explicit = _stored_language(row)
    apply_user_language(stored, explicit=explicit)
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
