"""
Authentication API routes.
Handles user registration, login, logout, token refresh, and password reset.
"""

import asyncio
import random
from datetime import datetime
from typing import Optional, Dict, Any

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.db.connection import get_db, get_anon_db
from app.core.security import verify_password_strength, TokenData
from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    AuthenticationError,
    EmailAlreadyExistsError,
    ValidationError,
    SchemaNotInitializedError,
    DatabaseError,
)
from supabase import Client
from supabase_auth.errors import AuthApiError
from postgrest.exceptions import APIError as PostgrestAPIError

logger = get_context_logger(__name__)

router = APIRouter()


def _require_schema(db: Client) -> None:
    """Fail fast when Supabase migrations haven't been applied.

    We intentionally check a few tables/columns introduced in `001_full_schema.sql`
    so we don't create orphaned Supabase Auth users when the public schema isn't ready.
    """
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
            db.table("users").upsert(payload, on_conflict="id").execute()
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
            existing = (
                db.table("users")
                .select("id")
                .eq("id", payload.get("id"))
                .limit(1)
                .execute()
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
    password: str = Field(..., min_length=8, max_length=100)
    full_name: Optional[str] = Field(None, max_length=255)

    @field_validator('password')
    @classmethod
    def validate_password_strength(cls, v):
        """Ensure password meets strength requirements."""
        is_valid, error_msg = verify_password_strength(v)
        if not is_valid:
            raise ValueError(error_msg)
        return v


class LoginRequest(BaseModel):
    """User login request."""
    email: EmailStr
    password: str


class RefreshTokenRequest(BaseModel):
    """Token refresh request."""
    refresh_token: str


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


# ============================================================================
# AUTH ENDPOINTS
# ============================================================================


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(
    request: RegisterRequest,
    anon_db: Client = Depends(get_anon_db),
    db: Client = Depends(get_db),
):
    """
    Register a new user.

    Creates a user in Supabase Auth and adds a profile to the public.users table.
    """
    try:
        _require_schema(db)

        # Create user via Supabase Auth
        try:
            auth_response = anon_db.auth.sign_up({
                "email": request.email,
                "password": request.password,
                "options": {
                    "data": {
                        "full_name": request.full_name
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
                "email": request.email,
                "full_name": request.full_name,
                "email_verified": False,
                "is_active": True,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat(),
            }
            profile_created = await _upsert_user_profile(db, profile_payload)
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
                db.table("user_preferences").upsert({
                    "user_id": user_id,
                    "favorite_colors": [],
                    "preferred_styles": [],
                    "liked_brands": [],
                    "disliked_patterns": [],
                    "preferred_occasions": [],
                    "data_points_collected": 0,
                }, on_conflict="user_id").execute()
            except Exception as e:
                logger.debug(f"User preferences upsert skipped (may exist from trigger): {e}")

            # Create default user settings (upsert to handle trigger-created records)
            try:
                db.table("user_settings").upsert({
                    "user_id": user_id,
                    "language": "en",
                    "measurement_units": "imperial",
                    "notifications_enabled": True,
                    "email_marketing": False,
                    "dark_mode": False
                }, on_conflict="user_id").execute()
            except Exception as e:
                logger.debug(f"User settings upsert skipped (may exist from trigger): {e}")

        except PostgrestAPIError as e:
            error_info = getattr(e, 'json', lambda: {})() or {}
            code = error_info.get('code') or getattr(e, 'code', None)
            message = error_info.get('message', str(e))

            # Handle duplicate email error - user already exists in public.users
            if code == '23505' and 'users_email_key' in message:
                logger.warning("Email already exists in public.users", email=request.email)
                raise EmailAlreadyExistsError()

            logger.error("Error creating user profile", error_info=error_info or str(e))
            raise DatabaseError(
                "User profile could not be created. Ensure Supabase migrations have been applied.",
                operation="create_profile"
            )
        except (EmailAlreadyExistsError, DatabaseError):
            raise
        except Exception as e:
            logger.error("Error creating user profile")
            raise DatabaseError(
                "User profile could not be created. Ensure Supabase migrations have been applied.",
                operation="create_profile"
            )

        logger.info("User registered successfully", user_id=user_id, email=request.email)
        return {
            "data": {
                "user": {"id": user_id, "email": request.email, "full_name": request.full_name},
                "access_token": session.access_token if session else "",
                "refresh_token": session.refresh_token if session else "",
                "requires_email_confirmation": requires_email_confirmation,
            },
            "message": "Registered",
        }

    except (HTTPException, EmailAlreadyExistsError, AuthenticationError, DatabaseError, SchemaNotInitializedError):
        raise
    except AuthApiError as e:
        logger.error("Registration error", error=str(e))
        raise AuthenticationError(str(e) or "Registration failed", error_code="AUTH_REGISTRATION_FAILED")
    except Exception as e:
        logger.error("Registration error")
        raise DatabaseError("An error occurred during registration")


@router.post("/login", response_model=dict)
async def login(
    request: LoginRequest,
    anon_db: Client = Depends(get_anon_db),
    db: Client = Depends(get_db),
):
    """
    Login with email and password.

    Returns JWT tokens and user data.
    """
    try:
        _require_schema(db)

        # Authenticate with Supabase Auth
        try:
            auth_response = anon_db.auth.sign_in_with_password({
                "email": request.email,
                "password": request.password
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
            existing = db.table("users").select("id").eq("id", user.id).execute()
            if not existing.data:
                # Profile doesn't exist - create it
                profile_payload = {
                    "id": user.id,
                    "email": user.email,
                    "full_name": user.user_metadata.get("full_name") if user.user_metadata else "",
                    "email_verified": user.email_confirmed_at is not None,
                    "is_active": True,
                    "created_at": datetime.now().isoformat(),
                    "updated_at": datetime.now().isoformat(),
                    "last_login_at": datetime.now().isoformat(),
                }
                await _upsert_user_profile(db, profile_payload)

                # Create default user_preferences
                db.table("user_preferences").upsert({
                    "user_id": user.id,
                    "favorite_colors": [],
                    "preferred_styles": [],
                    "liked_brands": [],
                    "disliked_patterns": [],
                    "preferred_occasions": [],
                    "data_points_collected": 0,
                }, on_conflict="user_id").execute()

                # Create default user_settings
                db.table("user_settings").upsert({
                    "user_id": user.id,
                    "language": "en",
                    "measurement_units": "imperial",
                    "notifications_enabled": True,
                    "email_marketing": False,
                    "dark_mode": False,
                }, on_conflict="user_id").execute()

                logger.info("Created missing user profile on login", user_id=user.id)
            else:
                # Profile exists - just update last_login_at
                db.table("users").update({
                    "last_login_at": datetime.now().isoformat()
                }).eq("id", user.id).execute()
        except Exception as e:
            logger.warning("Failed to ensure user profile", user_id=user.id, error=str(e))

        # Get user profile data
        user_data = {
            "id": user.id,
            "email": user.email,
            "full_name": user.user_metadata.get("full_name") if user.user_metadata else None,
            "avatar_url": user.user_metadata.get("avatar_url") if user.user_metadata else None
        }

        logger.info("User logged in successfully", user_id=user.id)
        return {
            "data": {
                "access_token": session.access_token,
                "refresh_token": session.refresh_token,
                "user": user_data,
            },
            "message": "OK",
        }

    except (HTTPException, AuthenticationError, SchemaNotInitializedError):
        raise
    except AuthApiError as e:
        logger.error("Login error", error=str(e))
        raise AuthenticationError(str(e) or "Login failed", error_code="AUTH_LOGIN_FAILED")
    except Exception as e:
        logger.error("Login error")
        raise DatabaseError("An error occurred during login")


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(anon_db: Client = Depends(get_anon_db)):
    """
    Logout user by invalidating the session.

    Note: In a stateless JWT setup, the client should simply discard the token.
    This endpoint primarily serves to revoke the refresh token on the server.
    """
    try:
        # Supabase Auth sign-out is session-based; in a backend JWT flow the
        # client should discard tokens. We still call sign_out() as a best-effort.
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
    """
    try:
        refresh_token = request.refresh_token

        if not refresh_token:
            raise ValidationError("refresh_token is required", details={"field": "refresh_token"})

        # Refresh session using Supabase
        auth_response = anon_db.auth.refresh_session(refresh_token)

        if auth_response.session is None:
            raise AuthenticationError("Invalid or expired refresh token", error_code="AUTH_TOKEN_EXPIRED")

        session = auth_response.session
        user = auth_response.user

        logger.info("Token refreshed successfully", user_id=user.id)
        return {
            "data": {
                "access_token": session.access_token,
                "refresh_token": session.refresh_token,
                "user": {"id": user.id, "email": user.email},
            },
            "message": "OK",
        }

    except (ValidationError, AuthenticationError):
        raise
    except Exception as e:
        logger.error("Token refresh error", error=str(e))
        raise AuthenticationError("Failed to refresh token", error_code="AUTH_REFRESH_FAILED")


@router.post("/reset-password", response_model=dict)
async def reset_password(
    request: ResetPasswordRequest,
    anon_db: Client = Depends(get_anon_db)
):
    """
    Request a password reset email.

    Sends an email with a password reset link to the user's email address.
    """
    try:
        # In a real implementation, you would configure Supabase to send emails
        # This is a placeholder that shows the flow
        anon_db.auth.reset_password_for_email(
            request.email,
            {
                "redirectUrl": f"{settings.FRONTEND_URL.rstrip('/')}/auth/reset-password"
            }
        )
        logger.info("Password reset email requested", email=request.email)

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
            pass

        logger.info("Password reset confirmed successfully")
        return {"message": "Password has been reset successfully"}

    except ValidationError:
        raise
    except Exception as e:
        logger.error("Confirm password reset error")
        raise DatabaseError("An error occurred while resetting password")
