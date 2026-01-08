"""
Security module for JWT token verification and user authentication.
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import datetime
from typing import Optional
import logging

from app.core.config import settings
from app.db.connection import SupabaseDB

logger = logging.getLogger(__name__)

# HTTP Bearer security scheme
security = HTTPBearer(auto_error=False)


class TokenData:
    """Data extracted from a verified JWT token."""

    def __init__(self, sub: str, exp: Optional[int] = None, aud: Optional[str] = None):
        self.sub = sub  # User ID
        self.exp = exp  # Expiration timestamp
        self.aud = aud  # Audience
        self.email: Optional[str] = None


async def verify_token(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> TokenData:
    """Verify JWT token and extract user claims.

    Args:
        credentials: HTTP Bearer credentials from Authorization header

    Returns:
        TokenData with user ID and other claims

    Raises:
        HTTPException: If token is invalid or expired
    """
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials

    try:
        # Use Supabase client to verify the token
        # The service client can validate any user's JWT
        client = SupabaseDB.get_service_client()
        user_response = client.auth.get_user(token)

        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user = user_response.user
        token_data = TokenData(
            sub=user.id,
            exp=None,  # Supabase handles expiration
            aud="authenticated"
        )
        token_data.email = user.email

        return token_data

    except HTTPException:
        raise
    except Exception as e:
        logger.warning(f"Token verification failed: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_current_user_id(
    token_data: TokenData = Depends(verify_token)
) -> str:
    """Extract user ID from verified token.

    This is a convenience dependency for routes that only need the user ID.

    Args:
        token_data: Verified token data from verify_token

    Returns:
        User ID string
    """
    return token_data.sub


async def get_current_user_email(
    token_data: TokenData = Depends(verify_token)
) -> Optional[str]:
    """Extract user email from verified token.

    Args:
        token_data: Verified token data from verify_token

    Returns:
        User email string or None
    """
    return token_data.email


async def get_optional_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> Optional[str]:
    """Best-effort user ID extraction without requiring auth."""
    if not credentials:
        return None
    try:
        token_data = await verify_token(credentials)
        return token_data.sub
    except HTTPException:
        return None


def verify_password_strength(password: str) -> tuple[bool, Optional[str]]:
    """Verify that a password meets minimum strength requirements.

    Requirements:
    - At least 8 characters
    - At least one uppercase letter
    - At least one lowercase letter
    - At least one digit
    - At least one special character

    Args:
        password: Password to verify

    Returns:
        Tuple of (is_valid, error_message)
    """
    if len(password) < 8:
        return False, "Password must be at least 8 characters"

    has_upper = any(c.isupper() for c in password)
    has_lower = any(c.islower() for c in password)
    has_digit = any(c.isdigit() for c in password)
    has_special = any(c in "!@#$%^&*(),.?\":{}|<>" for c in password)

    if not has_upper:
        return False, "Password must contain at least one uppercase letter"
    if not has_lower:
        return False, "Password must contain at least one lowercase letter"
    if not has_digit:
        return False, "Password must contain at least one digit"
    if not has_special:
        return False, "Password must contain at least one special character"

    return True, None
