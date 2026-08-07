"""
Authentication API routes.
Handles user registration, login, logout, token refresh, and password reset.
"""

import asyncio
import random
from typing import Optional, Dict, Any

import httpx
from fastapi import APIRouter, HTTPException, Depends, Request, status
from fastapi.security import HTTPAuthorizationCredentials
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.db.connection import get_db, get_anon_db, SupabaseDB
from app.core.security import security, verify_password_strength, TokenData, verify_token
from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    AuthenticationError,
    EmailAlreadyExistsError,
    FitCheckException,
    ValidationError,
    SchemaNotInitializedError,
    DatabaseError,
)
from app.core.ip_rate_limit import auth_rate_limited_operation
from app.utils.db import execute_with_reconnect, run_sync_with_reconnect
from app.utils.datetime_util import utcnow_iso
from app.services.referral_service import ReferralService
from app.models.subscription import RedeemReferralResponse
from supabase import Client
from supabase_auth.errors import AuthApiError
from postgrest.exceptions import APIError as PostgrestAPIError

logger = get_context_logger(__name__)

router = APIRouter()


_schema_confirmed_ready = False


def _require_schema(db: Client) -> None:
    """Fail fast when Supabase migrations haven't been applied.

    We intentionally check a few tables/columns introduced in `001_full_schema.sql`
    so we don't create orphaned Supabase Auth users when the public schema isn't ready.

    Whether migrations are applied doesn't change while the process is
    running, so once this succeeds once we stop re-running it on every
    register/login/oauth_sync call - it was previously 4 extra DB round trips
    on the hottest auth paths for an answer that's effectively static post-deploy.

    Runs through run_sync_with_reconnect: a dead pooled HTTP/2 connection is
    NOT a schema gap and must not be misread as one (observed 2026-08-01:
    oauth/sync 500 at boot on a stale connection).
    """
    global _schema_confirmed_ready
    if _schema_confirmed_ready:
        return

    run_sync_with_reconnect(
        _check_schema_tables,
        db,
        extra={"operation": "_require_schema"},
    )
    _schema_confirmed_ready = True


def _check_schema_tables(db: Client) -> None:
    """The four schema probes. Separate function so the reconnect wrapper can
    re-run them against a rebuilt client."""
    try:
        db.table("users").select("id").limit(1).execute()
        db.table("user_preferences").select("preferred_occasions").limit(1).execute()
        db.table("items").select("material").limit(1).execute()
        db.table("outfits").select("is_public").limit(1).execute()
    except PostgrestAPIError as e:
        code = getattr(e, "code", None)
        if code in {"PGRST205", "42703"}:
            raise SchemaNotInitializedError()
        raise


async def _upsert_user_profile(
    db: Client,
    payload: Dict[str, Any],
    max_attempts: int = 12,
    retry_delay_seconds: float = 0.5,
) -> bool:
    """Upsert the user profile with a short retry for auth propagation."""
    last_fk_error = False
    for attempt in range(max_attempts):
        try:
            # Query built outside the callable so the retry loop can't capture a
            # stale binding; to_thread keeps the sync client off the event loop.
            upsert = db.table("users").upsert(payload, on_conflict="id")
            await asyncio.to_thread(upsert.execute)
            return True
        except PostgrestAPIError as e:
            error_info = getattr(e, "json", lambda: {})() or {}
            code = error_info.get("code") or getattr(e, "code", None)
            message = str(error_info.get("message") or str(e))
            if code == "23503" or "users_id_fkey" in message:
                last_fk_error = True
                if attempt < max_attempts - 1:
                    # Exponential backoff with jitter to prevent thundering herd
                    delay = retry_delay_seconds * (attempt + 1) + random.uniform(0, 0.2)
                    await asyncio.sleep(delay)
                    continue
                break
            raise
    if last_fk_error:
        logger.warning(
            f"FK constraint error persisted after {max_attempts} attempts for user {payload.get('id')}"
        )
        try:
            existing = await asyncio.to_thread(
                db.table("users")
                .select("id")
                .eq("id", payload.get("id"))
                .limit(1)
                .execute
            )
            if existing.data:
                return True
        except Exception as e:
            logger.debug(f"Fallback user check failed: {e}")
    return False

# ============================================================================
# REQUEST/RESPONSE MODELS
# ============================================================================


class RegisterRequest(BaseModel):
    """User registration request."""
    email: EmailStr
    # Length-gated only, matching the shipped web form (strength checklist is
    # guidance, not a hard gate) and mobile signup (direct Supabase, no
    # strength rule). Before 2026-08-04 this required upper+lower+digit+special
    # while the clients did not, so every such signup 422'd. Full strength is
    # still enforced on password RESET (ConfirmResetRequest), where clients
    # gate on it client-side.
    password: str = Field(..., min_length=8, max_length=100)
    full_name: Optional[str] = Field(None, max_length=255)
    referral_code: Optional[str] = Field(None, max_length=50)


class LoginRequest(BaseModel):
    """User login request."""
    email: EmailStr
    password: str


class RefreshTokenRequest(BaseModel):
    """Token refresh request."""
    refresh_token: str


class LogoutRequest(BaseModel):
    """Optional logout body.

    ``refresh_token`` is accepted for API compatibility: the actual
    server-side revocation happens through Supabase /auth/v1/logout, which
    the backend calls with the request's Bearer access token and which
    revokes that session's refresh token. A stateless client has no stored
    Supabase session to sign out from, so the token alone cannot revoke
    anything.
    """
    refresh_token: Optional[str] = None


class ResetPasswordRequest(BaseModel):
    """Password reset request."""
    email: EmailStr


class ConfirmResetRequest(BaseModel):
    """Password reset confirmation."""
    # Supabase recovery links typically land on the frontend with a session in the URL hash:
    #   #access_token=...&refresh_token=...&type=recovery
    # We support that flow by accepting access+refresh tokens and setting a temporary session.
    access_token: Optional[str] = None
    refresh_token: Optional[str] = None
    # Optional OTP token variant (advanced / future use)
    token: Optional[str] = None
    new_password: str = Field(..., min_length=8)

    @field_validator('new_password')
    @classmethod
    def validate_password_strength(cls, v):
        """Ensure password meets strength requirements."""
        is_valid, error_msg = verify_password_strength(v)
        if not is_valid:
            raise ValueError(error_msg)
        return v


class AuthResponse(BaseModel):
    """Authentication response with tokens and user data."""
    access_token: str
    refresh_token: str
    user: Dict[str, Any]


class UserResponse(BaseModel):
    """User data response."""
    id: str
    email: str
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: Optional[str] = None
    last_login_at: Optional[str] = None
    is_active: bool = True
    email_verified: bool = False


class MessageResponse(BaseModel):
    """Generic message response."""
    message: str


class OAuthSyncRequest(BaseModel):
    """Optional metadata from OAuth provider for profile sync."""
    full_name: Optional[str] = Field(None, max_length=255)
    avatar_url: Optional[str] = None
    referral_code: Optional[str] = Field(None, max_length=50)


# ============================================================================
# AUTH ENDPOINTS
# ============================================================================


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(
    register_request: RegisterRequest,
    http_request: Request,
    anon_db: Client = Depends(get_anon_db),
    db: Client = Depends(get_db),
):
    """
    Register a new user.

    Creates a user in Supabase Auth and adds a profile to the public.users table.
    """
    async with auth_rate_limited_operation(http_request, "register"):
        try:
            _require_schema(db)

            # Create user via Supabase Auth
            # Normalize email to lowercase to prevent case-sensitivity login
            # mismatches regardless of Supabase project settings.
            normalized_email = register_request.email.lower()
            try:
                auth_response = anon_db.auth.sign_up({
                    "email": normalized_email,
                    "password": register_request.password,
                    "options": {
                        "data": {
                            "full_name": register_request.full_name
                        }
                    }
                })
            except AuthApiError as e:
                message = str(e) or "Registration failed"
                lower = message.lower()
                if "already registered" in lower:
                    raise EmailAlreadyExistsError()
                raise AuthenticationError(message, error_code="AUTH_REGISTRATION_FAILED")

            if auth_response.user is None:
                # Check for error in response
                if hasattr(auth_response, 'error') and auth_response.error:
                    error_msg = auth_response.error.get('message', 'Registration failed')
                    raise AuthenticationError(error_msg, error_code="AUTH_REGISTRATION_FAILED")
                raise AuthenticationError("Registration failed", error_code="AUTH_REGISTRATION_FAILED")

            user_id = auth_response.user.id
            session = auth_response.session
            requires_email_confirmation = not bool(getattr(session, "access_token", None))

            # Create/update user profile in public.users table
            # Note: The database trigger (002_user_profile_trigger.sql) may have already
            # created the profile. We use upsert to handle both cases gracefully.
            try:
                profile_payload = {
                    "id": user_id,
                    "email": normalized_email,
                    "full_name": register_request.full_name,
                    "email_verified": False,
                    "is_active": True,
                    "created_at": utcnow_iso(),
                    "updated_at": utcnow_iso(),
                }
                profile_created = await execute_with_reconnect(
                    lambda d: _upsert_user_profile(d, profile_payload),
                    db,
                    extra={"operation": "register.upsert_profile", "user_id": user_id},
                )
                if not profile_created:
                    logger.error(
                        "Auth user record not available for profile creation",
                        user_id=user_id,
                    )
                    raise DatabaseError(
                        "User profile could not be created because the auth user record was not available. Try again shortly or verify Supabase Auth/migrations.",
                        operation="create_profile"
                    )

                # Create default user preferences (upsert to handle trigger-created records)
                try:
                    await asyncio.to_thread(db.table("user_preferences").upsert({
                        "user_id": user_id,
                        "favorite_colors": [],
                        "preferred_styles": [],
                        "liked_brands": [],
                        "disliked_patterns": [],
                        "preferred_occasions": [],
                        "data_points_collected": 0,
                    }, on_conflict="user_id").execute)
                except Exception as e:
                    logger.debug(f"User preferences upsert skipped (may exist from trigger): {e}")

                # Create default user settings (upsert to handle trigger-created records)
                try:
                    await asyncio.to_thread(db.table("user_settings").upsert({
                        "user_id": user_id,
                        "language": "en",
                        "measurement_units": "imperial",
                        "notifications_enabled": True,
                        "email_marketing": False,
                        "dark_mode": False
                    }, on_conflict="user_id").execute)
                except Exception as e:
                    logger.debug(f"User settings upsert skipped (may exist from trigger): {e}")

                # Process referral code if provided
                referral_result = None
                if register_request.referral_code:
                    try:
                        referral_result = await ReferralService.redeem_referral(
                            referred_user_id=user_id,
                            code=register_request.referral_code,
                            db=db,
                        )
                        if referral_result.success:
                            logger.info(
                                "Referral code redeemed during registration",
                                user_id=user_id,
                                code=register_request.referral_code,
                            )
                        else:
                            # Definitive rejection (invalid/own code). The
                            # retry hook was already cleared by the service.
                            # `rejection_reason` (not `message`) because
                            # ContextLogger.warning's first positional param
                            # is named `message` - a keyword `message=` would
                            # collide and raise TypeError (observed 2026-08-04).
                            logger.warning(
                                "Referral code rejected during registration",
                                user_id=user_id,
                                code=register_request.referral_code,
                                rejection_reason=referral_result.message,
                            )
                    except Exception as e:
                        # Transient failure (missing RPC from an unapplied
                        # migration, dead pooled connection). The code was
                        # persisted on users.referred_by_code before the RPC,
                        # so process_pending_referral completes the grant on
                        # the user's next login. Surface it in the response
                        # so the client shows a "will retry" message instead
                        # of silence (RCA 2026-08-04).
                        logger.warning(f"Failed to redeem referral code during registration: {e}")
                        referral_result = RedeemReferralResponse(
                            success=False,
                            message=(
                                "We couldn't apply your referral right now. "
                                "It will be applied automatically on your next sign-in."
                            ),
                            credit_months=0,
                        )

            except PostgrestAPIError as e:
                error_info = getattr(e, 'json', lambda: {})() or {}
                code = error_info.get('code') or getattr(e, 'code', None)
                message = error_info.get('message', str(e))

                # Handle duplicate email error - user already exists in public.users
                if code == '23505' and 'users_email_key' in message:
                    logger.warning("Email already exists in public.users", email=normalized_email)
                    raise EmailAlreadyExistsError()

                logger.error("Error creating user profile", error_info=error_info or str(e))
                raise DatabaseError(
                    "User profile could not be created. Ensure Supabase migrations have been applied.",
                    operation="create_profile"
                )
            except (EmailAlreadyExistsError, DatabaseError):
                raise
            except Exception as e:
                logger.error(
                    "Error creating user profile",
                    error=str(e),
                    user_id=user_id,
                )
                raise DatabaseError(
                    "User profile could not be created. Ensure Supabase migrations have been applied.",
                    operation="create_profile",
                )

            logger.info("User registered successfully", user_id=user_id, email=normalized_email)

            response_data = {
                "user": {
                    "id": user_id,
                    "email": normalized_email,
                    "full_name": register_request.full_name,
                    "avatar_url": None,
                    "gender": None,
                    "is_active": True,
                    "email_verified": False,
                    "created_at": profile_payload.get("created_at"),
                },
                "access_token": session.access_token if session else "",
                "refresh_token": session.refresh_token if session else "",
                "requires_email_confirmation": requires_email_confirmation,
            }

            # Add referral info to response if applicable
            if register_request.referral_code and referral_result:
                response_data["referral"] = {
                    "success": referral_result.success,
                    "message": referral_result.message,
                    "credit_months": referral_result.credit_months,
                }

            return {
                "data": response_data,
                "message": "Registered",
            }

        except (HTTPException, FitCheckException):
            raise
        except AuthApiError as e:
            logger.error(
                "Registration error",
                error=str(e),
                error_code=e.code if hasattr(e, 'code') else None,
            )
            raise AuthenticationError(str(e) or "Registration failed", error_code="AUTH_REGISTRATION_FAILED")
        except Exception as e:
            logger.error("Registration error", error=str(e), error_type=type(e).__name__)
            raise DatabaseError("An error occurred during registration")


@router.post("/login", response_model=dict)
async def login(
    login_request: LoginRequest,
    http_request: Request,
    anon_db: Client = Depends(get_anon_db),
    db: Client = Depends(get_db),
):
    """
    Login with email and password.

    Returns JWT tokens and user data.
    """
    async with auth_rate_limited_operation(http_request, "login"):
        try:
            _require_schema(db)

            # Authenticate with Supabase Auth
            # Normalize email to lowercase so case never causes login failures.
            normalized_email = login_request.email.lower()
            try:
                auth_response = anon_db.auth.sign_in_with_password({
                    "email": normalized_email,
                    "password": login_request.password
                })
            except AuthApiError as e:
                message = str(e) or "Login failed"
                lower = message.lower()
                if "email not confirmed" in lower:
                    raise AuthenticationError("Email not confirmed", error_code="AUTH_EMAIL_NOT_CONFIRMED")
                if "invalid login credentials" in lower:
                    raise AuthenticationError("Invalid email or password", error_code="AUTH_INVALID_CREDENTIALS")
                raise AuthenticationError(message, error_code="AUTH_LOGIN_FAILED")

            if auth_response.user is None:
                raise AuthenticationError("Invalid email or password", error_code="AUTH_INVALID_CREDENTIALS")

            user = auth_response.user
            session = auth_response.session

            # Ensure user profile exists in public.users (handles missing trigger case)
            try:
                existing = await asyncio.to_thread(db.table("users").select("id").eq("id", user.id).execute)
                if not existing.data:
                    # Profile doesn't exist - create it
                    profile_payload = {
                        "id": user.id,
                        "email": user.email,
                        "full_name": user.user_metadata.get("full_name") if user.user_metadata else "",
                        "email_verified": user.email_confirmed_at is not None,
                        "is_active": True,
                        "created_at": utcnow_iso(),
                        "updated_at": utcnow_iso(),
                        "last_login_at": utcnow_iso(),
                    }
                    await _upsert_user_profile(db, profile_payload)

                    # Create default user_preferences
                    await asyncio.to_thread(db.table("user_preferences").upsert({
                        "user_id": user.id,
                        "favorite_colors": [],
                        "preferred_styles": [],
                        "liked_brands": [],
                        "disliked_patterns": [],
                        "preferred_occasions": [],
                        "data_points_collected": 0,
                    }, on_conflict="user_id").execute)

                    # Create default user_settings
                    await asyncio.to_thread(db.table("user_settings").upsert({
                        "user_id": user.id,
                        "language": "en",
                        "measurement_units": "imperial",
                        "notifications_enabled": True,
                        "email_marketing": False,
                        "dark_mode": False,
                    }, on_conflict="user_id").execute)

                    logger.info("Created missing user profile on login", user_id=user.id)
                else:
                    # Profile exists - just update last_login_at
                    await asyncio.to_thread(db.table("users").update({
                        "last_login_at": utcnow_iso()
                    }).eq("id", user.id).execute)
            except Exception as e:
                logger.warning("Failed to ensure user profile", user_id=user.id, error=str(e))

            # Get user profile data from database (not auth metadata) to ensure
            # avatar_url and other profile fields are returned correctly
            profile_result = await asyncio.to_thread(db.table("users").select("*").eq("id", user.id).execute)
            if profile_result.data and len(profile_result.data) > 0:
                profile = profile_result.data[0]
                user_data = {
                    "id": user.id,
                    "email": user.email,
                    "full_name": profile.get("full_name"),
                    "avatar_url": profile.get("avatar_url"),
                    "gender": profile.get("gender"),
                    "is_active": profile.get("is_active", True),
                    "email_verified": profile.get("email_verified", False),
                    "created_at": profile.get("created_at"),
                    "updated_at": profile.get("updated_at"),
                    "last_login_at": profile.get("last_login_at"),
                }
            else:
                # Fallback to auth metadata if no profile exists yet
                user_data = {
                    "id": user.id,
                    "email": user.email,
                    "full_name": user.user_metadata.get("full_name") if user.user_metadata else None,
                    "avatar_url": None,
                }

            # Process any pending referral code: a redemption that failed at
            # signup (missing RPC from an unapplied migration, dead pooled
            # connection) leaves users.referred_by_code set; complete the
            # grant here on the next sign-in. Idempotent - the atomic RPC
            # reports already-redeemed instead of double-granting (RCA
            # 2026-08-04).
            try:
                await ReferralService.process_pending_referral(user.id, db)
            except Exception as e:
                logger.warning(
                    "Failed to process pending referral on login",
                    user_id=user.id,
                    error=str(e),
                )

            logger.info("User logged in successfully", user_id=user.id)
            return {
                "data": {
                    "access_token": session.access_token,
                    "refresh_token": session.refresh_token,
                    "user": user_data,
                },
                "message": "OK",
            }

        except (HTTPException, FitCheckException):
            raise
        except AuthApiError as e:
            logger.error(
                "Login error",
                error=str(e),
                error_code=e.code if hasattr(e, 'code') else None,
            )
            raise AuthenticationError(str(e) or "Login failed", error_code="AUTH_LOGIN_FAILED")
        except Exception as e:
            logger.error("Login error", error=str(e), error_type=type(e).__name__)
            raise DatabaseError("An error occurred during login")


async def _revoke_supabase_session(access_token: str) -> None:
    """Revoke the Supabase Auth session server-side via ``/auth/v1/logout``.

    Supabase's logout endpoint invalidates the session (and therefore its
    refresh token) for the Bearer access token. This is the only way a
    stateless backend — whose anon client holds no stored session — can
    revoke the refresh token; ``anon_db.auth.sign_out()`` alone is a no-op
    on such a client.
    """
    async with httpx.AsyncClient(timeout=10) as client:
        await client.post(
            f"{settings.SUPABASE_URL}auth/v1/logout",
            headers={
                "apikey": settings.SUPABASE_PUBLISHABLE_KEY,
                "Authorization": f"Bearer {access_token}",
            },
        )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(
    request: Optional[LogoutRequest] = None,
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    anon_db: Client = Depends(get_anon_db),
):
    """
    Logout user by invalidating the session.

    With a Bearer access token, POSTs to Supabase /auth/v1/logout so the
    session's refresh token is revoked server-side. Without one, falls back
    to the legacy best-effort sign_out() on the anon client. Always
    best-effort: a failure is logged and 204 is still returned — the client
    discards its tokens regardless.
    """
    try:
        access_token = credentials.credentials if credentials else None
        if access_token:
            await _revoke_supabase_session(access_token)
        else:
            # Legacy best-effort path for callers that send no token.
            anon_db.auth.sign_out()
    except Exception as e:
        logger.warning("Logout error (best-effort)", error=str(e))
        # Best-effort: client should still discard tokens.
        pass

    return None


@router.post("/refresh", response_model=dict)
async def refresh_token(
    request: RefreshTokenRequest,
    anon_db: Client = Depends(get_anon_db)
):
    """
    Refresh access token using a refresh token.

    Returns new access and refresh tokens.

    Uses deduplication to prevent "Invalid Refresh Token: Already Used" errors
    when multiple concurrent requests arrive with the same refresh token.
    """
    try:
        refresh_token = request.refresh_token

        if not refresh_token:
            raise ValidationError("refresh_token is required", details={"field": "refresh_token"})

        # Refresh session with deduplication (prevents race conditions)
        from app.services.token_refresh_service import refresh_token_with_deduplication

        response_data = await refresh_token_with_deduplication(
            supabase_client=anon_db,
            refresh_token=refresh_token,
        )

        return {
            "data": response_data,
            "message": "OK",
        }

    except FitCheckException:
        raise
    except Exception as e:
        logger.error("Token refresh error", error=str(e))
        raise AuthenticationError("Failed to refresh token", error_code="AUTH_REFRESH_FAILED")


@router.post("/reset-password", response_model=dict)
async def reset_password(
    reset_request: ResetPasswordRequest,
    http_request: Request,
    anon_db: Client = Depends(get_anon_db)
):
    """
    Request a password reset email.

    Sends an email with a password reset link to the user's email address.
    """
    async with auth_rate_limited_operation(http_request, "password_reset"):
        try:
            # In a real implementation, you would configure Supabase to send emails
            # This is a placeholder that shows the flow
            anon_db.auth.reset_password_for_email(
                reset_request.email,
                {
                    "redirectUrl": f"{settings.FRONTEND_URL.rstrip('/')}/auth/reset-password"
                }
            )
            logger.info("Password reset email requested", email=reset_request.email)

            # Always return success to prevent email enumeration
            return {"message": "If an account exists with this email, a password reset link has been sent"}

        except Exception as e:
            logger.warning("Password reset error (returning success to prevent enumeration)", error=str(e))
            # Return success even if there's an error (prevent email enumeration)
            return {"message": "If an account exists with this email, a password reset link has been sent"}


@router.post("/confirm-reset-password", response_model=dict)
async def confirm_reset_password(
    request: ConfirmResetRequest,
    anon_db: Client = Depends(get_anon_db)
):
    """
    Confirm password reset with the token from the email.

    Updates the user's password with the new password.
    """
    try:
        if request.access_token and request.refresh_token:
            # Set a temporary session from the recovery link.
            anon_db.auth.set_session(request.access_token, request.refresh_token)
        elif request.token:
            # OTP-based verification (if using token-based recovery flows)
            anon_db.auth.verify_otp({"token": request.token, "type": "recovery"})
        else:
            raise ValidationError(
                "Missing recovery session. Provide access_token + refresh_token from the reset link.",
                details={"required_fields": ["access_token", "refresh_token"]}
            )

        anon_db.auth.update_user({"password": request.new_password})
        try:
            anon_db.auth.sign_out()
        except Exception:
            # sign_out is best-effort; don't fail the reset if it errors.
            pass

        logger.info("Password reset confirmed successfully")
        return {"message": "Password has been reset successfully"}

    except ValidationError:
        raise
    except Exception as e:
        logger.error(
            "Confirm password reset error",
            error=str(e)[:300],
            error_type=type(e).__name__,
        )
        raise DatabaseError("An error occurred while resetting password")


@router.post("/oauth/sync", response_model=dict)
async def oauth_sync(
    request: Optional[OAuthSyncRequest] = None,
    db: Client = Depends(get_db),
    token_data: TokenData = Depends(verify_token),
):
    """
    Sync user profile after OAuth authentication.

    Called by frontend after successful OAuth flow. Creates or updates
    the user profile in public.users table if it doesn't exist.

    This endpoint is idempotent - calling it multiple times is safe.
    """
    user_id = token_data.sub
    user_email = token_data.email

    try:
        _require_schema(db)

        # Check if user profile already exists
        existing = await execute_with_reconnect(
            lambda d: d.table("users").select("*").eq("id", user_id).execute(),
            db,
            extra={"operation": "oauth_sync.lookup", "user_id": user_id},
        )
        is_new_user = not existing.data

        if is_new_user:
            # Fetch additional metadata from Supabase Auth if available
            user_metadata = {}
            try:
                client = SupabaseDB.get_service_client()
                auth_user = client.auth.admin.get_user_by_id(user_id)
                if auth_user and auth_user.user:
                    user_metadata = auth_user.user.user_metadata or {}
                    # Use email from auth if not in token
                    if not user_email:
                        user_email = auth_user.user.email
            except Exception as e:
                logger.debug(f"Could not fetch auth user metadata: {e}")

            # Determine values (priority: request > auth metadata > defaults)
            full_name = (
                (request.full_name if request else None)
                or user_metadata.get("full_name")
                or user_metadata.get("name")  # Google OAuth uses "name"
                or ""
            )
            avatar_url = (
                (request.avatar_url if request else None)
                or user_metadata.get("avatar_url")
                or user_metadata.get("picture")  # Google OAuth uses "picture"
            )

            # Create user profile
            profile_payload = {
                "id": user_id,
                "email": user_email,
                "full_name": full_name,
                "avatar_url": avatar_url,
                "email_verified": True,  # OAuth emails are verified by provider
                "is_active": True,
                "created_at": utcnow_iso(),
                "updated_at": utcnow_iso(),
                "last_login_at": utcnow_iso(),
            }

            profile_created = await execute_with_reconnect(
                lambda d: _upsert_user_profile(d, profile_payload),
                db,
                extra={"operation": "oauth_sync.upsert_profile", "user_id": user_id},
            )
            if not profile_created:
                raise DatabaseError(
                    "User profile could not be created",
                    operation="oauth_sync"
                )

            # Create default user_preferences
            try:
                await execute_with_reconnect(
                    lambda d: d.table("user_preferences").upsert({
                        "user_id": user_id,
                        "favorite_colors": [],
                        "preferred_styles": [],
                        "liked_brands": [],
                        "disliked_patterns": [],
                        "preferred_occasions": [],
                        "data_points_collected": 0,
                    }, on_conflict="user_id").execute(),
                    db,
                    extra={"operation": "oauth_sync.upsert_preferences", "user_id": user_id},
                )
            except Exception as e:
                logger.debug(f"User preferences upsert skipped: {e}")

            # Create default user_settings
            try:
                await execute_with_reconnect(
                    lambda d: d.table("user_settings").upsert({
                        "user_id": user_id,
                        "language": "en",
                        "measurement_units": "imperial",
                        "notifications_enabled": True,
                        "email_marketing": False,
                        "dark_mode": False,
                    }, on_conflict="user_id").execute(),
                    db,
                    extra={"operation": "oauth_sync.upsert_settings", "user_id": user_id},
                )
            except Exception as e:
                logger.debug(f"User settings upsert skipped: {e}")

            # Process referral code if provided (for new OAuth users)
            referral_result = None
            if request and request.referral_code:
                try:
                    referral_result = await ReferralService.redeem_referral(
                        referred_user_id=user_id,
                        code=request.referral_code,
                        db=db,
                    )
                    if referral_result.success:
                        logger.info("Referral code redeemed during OAuth sync", user_id=user_id, code=request.referral_code)
                    else:
                        logger.warning(
                            "Referral code rejected during OAuth sync",
                            user_id=user_id,
                            code=request.referral_code,
                            rejection_reason=referral_result.message,
                        )
                except Exception as e:
                    # Transient failure - the code was persisted on
                    # users.referred_by_code before the RPC, so the next
                    # login/oauth_sync retries it (RCA 2026-08-04).
                    logger.warning(f"Failed to redeem referral code during OAuth sync: {e}")
                    referral_result = RedeemReferralResponse(
                        success=False,
                        message=(
                            "We couldn't apply your referral right now. "
                            "It will be applied automatically on your next sign-in."
                        ),
                        credit_months=0,
                    )

            logger.info("Created user profile via OAuth sync", user_id=user_id)

            # Fetch the created profile
            profile_result = await execute_with_reconnect(
                lambda d: d.table("users").select("*").eq("id", user_id).execute(),
                db,
                extra={"operation": "oauth_sync.fetch_profile", "user_id": user_id},
            )
            user_data = profile_result.data[0] if (profile_result.data and len(profile_result.data) > 0) else profile_payload
        else:
            # Profile exists - update last_login_at
            await execute_with_reconnect(
                lambda d: d.table("users").update({
                    "last_login_at": utcnow_iso()
                }).eq("id", user_id).execute(),
                db,
                extra={"operation": "oauth_sync.touch_login", "user_id": user_id},
            )

            user_data = existing.data[0] if (existing.data and len(existing.data) > 0) else {}
            logger.info("OAuth sync for existing user", user_id=user_id)
            referral_result = None  # No new-code redemption for existing users

            # Process any pending referral code from a failed signup-time
            # redemption (missing RPC migration, dead connection): the code
            # was persisted on users.referred_by_code, complete the grant now.
            # Idempotent via the atomic RPC (RCA 2026-08-04).
            try:
                await ReferralService.process_pending_referral(user_id, db)
            except Exception as e:
                logger.warning(
                    "Failed to process pending referral on OAuth sync",
                    user_id=user_id,
                    error=str(e),
                )

        response_data = {
            "user": {
                "id": user_id,
                "email": user_email,
                "full_name": user_data.get("full_name"),
                "avatar_url": user_data.get("avatar_url"),
                "gender": user_data.get("gender"),
                "is_active": user_data.get("is_active", True),
                "email_verified": user_data.get("email_verified", True),
                "created_at": user_data.get("created_at"),
                "updated_at": user_data.get("updated_at"),
                "last_login_at": user_data.get("last_login_at"),
            },
            "is_new_user": is_new_user,
        }

        # Add referral info to response if applicable
        if is_new_user and request and request.referral_code and referral_result:
            response_data["referral"] = {
                "success": referral_result.success,
                "message": referral_result.message,
                "credit_months": referral_result.credit_months,
            }

        return {
            "data": response_data,
            "message": "OK",
        }

    except (HTTPException, FitCheckException):
        raise
    except Exception as e:
        logger.error("OAuth sync error", error=str(e))
        raise DatabaseError("An error occurred during OAuth sync")
