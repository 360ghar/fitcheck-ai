"""
Authentication API routes.
Handles user registration, login, logout, token refresh, and password reset.
"""

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, EmailStr, Field, field_validator
from typing import Optional, Dict, Any
from datetime import datetime
import logging

from app.db.connection import get_db
from app.core.security import verify_password_strength, TokenData
from supabase import Client

logger = logging.getLogger(__name__)

router = APIRouter()

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
    token: str
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


@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
async def register(
    request: RegisterRequest,
    db: Client = Depends(get_db)
):
    """
    Register a new user.

    Creates a user in Supabase Auth and adds a profile to the public.users table.
    """
    try:
        # Create user via Supabase Auth
        auth_response = db.auth.sign_up({
            "email": request.email,
            "password": request.password,
            "options": {
                "data": {
                    "full_name": request.full_name
                }
            }
        })

        if auth_response.user is None:
            # Check for error in response
            if hasattr(auth_response, 'error') and auth_response.error:
                error_msg = auth_response.error.get('message', 'Registration failed')
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=error_msg
                )
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Registration failed"
            )

        user_id = auth_response.user.id
        session = auth_response.session

        # Create user profile in public.users table
        try:
            db.table("users").insert({
                "id": user_id,
                "email": request.email,
                "full_name": request.full_name,
                "email_verified": False,
                "is_active": True,
                "created_at": datetime.now().isoformat(),
                "updated_at": datetime.now().isoformat()
            }).execute()

            # Create default user preferences
            db.table("user_preferences").insert({
                "user_id": user_id,
                "favorite_colors": [],
                "preferred_styles": [],
                "liked_brands": [],
                "disliked_patterns": []
            }).execute()

            # Create default user settings
            db.table("user_settings").insert({
                "user_id": user_id,
                "language": "en",
                "measurement_units": "imperial",
                "notifications_enabled": True,
                "email_marketing": False,
                "dark_mode": False
            }).execute()

        except Exception as e:
            logger.error(f"Error creating user profile: {str(e)}")
            # Continue even if profile creation fails - auth user is created

        return AuthResponse(
            access_token=session.access_token if session else "",
            refresh_token=session.refresh_token if session else "",
            user={
                "id": user_id,
                "email": request.email,
                "full_name": request.full_name
            }
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Registration error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during registration"
        )


@router.post("/login", response_model=AuthResponse)
async def login(
    request: LoginRequest,
    db: Client = Depends(get_db)
):
    """
    Login with email and password.

    Returns JWT tokens and user data.
    """
    try:
        # Authenticate with Supabase Auth
        auth_response = db.auth.sign_in_with_password({
            "email": request.email,
            "password": request.password
        })

        if auth_response.user is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password"
            )

        user = auth_response.user
        session = auth_response.session

        # Update last_login_at in users table
        try:
            db.table("users").update({
                "last_login_at": datetime.now().isoformat()
            }).eq("id", user.id).execute()
        except Exception as e:
            logger.warning(f"Failed to update last_login_at: {str(e)}")

        # Get user profile data
        user_data = {
            "id": user.id,
            "email": user.email,
            "full_name": user.user_metadata.get("full_name") if user.user_metadata else None,
            "avatar_url": user.user_metadata.get("avatar_url") if user.user_metadata else None
        }

        return AuthResponse(
            access_token=session.access_token,
            refresh_token=session.refresh_token,
            user=user_data
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Login error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during login"
        )


@router.post("/logout", response_model=MessageResponse)
async def logout(db: Client = Depends(get_db)):
    """
    Logout user by invalidating the session.

    Note: In a stateless JWT setup, the client should simply discard the token.
    This endpoint primarily serves to revoke the refresh token on the server.
    """
    try:
        db.auth.sign_out()
        return MessageResponse(message="Logged out successfully")
    except Exception as e:
        logger.error(f"Logout error: {str(e)}")
        # Return success even if sign_out fails - client should discard token
        return MessageResponse(message="Logged out successfully")


@router.post("/refresh", response_model=AuthResponse)
async def refresh_token(
    request: RefreshTokenRequest,
    db: Client = Depends(get_db)
):
    """
    Refresh access token using a refresh token.

    Returns new access and refresh tokens.
    """
    try:
        refresh_token = request.refresh_token

        if not refresh_token:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="refresh_token is required"
            )

        # Refresh session using Supabase
        auth_response = db.auth.refresh_session(refresh_token)

        if auth_response.session is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )

        session = auth_response.session
        user = auth_response.user

        return AuthResponse(
            access_token=session.access_token,
            refresh_token=session.refresh_token,
            user={
                "id": user.id,
                "email": user.email
            }
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Token refresh error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Failed to refresh token"
        )


@router.post("/reset-password", response_model=MessageResponse)
async def reset_password(
    request: ResetPasswordRequest,
    db: Client = Depends(get_db)
):
    """
    Request a password reset email.

    Sends an email with a password reset link to the user's email address.
    """
    try:
        # In a real implementation, you would configure Supabase to send emails
        # This is a placeholder that shows the flow
        db.auth.reset_password_for_email(
            request.email,
            {
                "redirectUrl": f"http://localhost:5173/auth/reset-password"
            }
        )

        # Always return success to prevent email enumeration
        return MessageResponse(
            message="If an account exists with this email, a password reset link has been sent"
        )

    except Exception as e:
        logger.error(f"Password reset error: {str(e)}")
        # Return success even if there's an error (prevent email enumeration)
        return MessageResponse(
            message="If an account exists with this email, a password reset link has been sent"
        )


@router.post("/confirm-reset-password", response_model=MessageResponse)
async def confirm_reset_password(
    request: ConfirmResetRequest,
    db: Client = Depends(get_db)
):
    """
    Confirm password reset with the token from the email.

    Updates the user's password with the new password.
    """
    try:
        # Update password using Supabase Auth
        auth_response = db.auth.update_user({
            "password": request.new_password
        })

        if auth_response:
            return MessageResponse(message="Password has been reset successfully")
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token"
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Confirm password reset error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred while resetting password"
        )
