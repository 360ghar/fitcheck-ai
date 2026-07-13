"""
Security module for JWT token verification and user authentication.

Supports:
- Supabase JWT Signing Keys (asymmetric ES256/RS256 via JWKS)
- Legacy HS256 shared secret (SUPABASE_JWT_SECRET) for older projects and tests
"""

from __future__ import annotations

import logging
from typing import Any, Dict, Optional, Set

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient

from app.core.config import settings

logger = logging.getLogger(__name__)

# HTTP Bearer security scheme
security = HTTPBearer(auto_error=False)

# Algorithms used by Supabase JWT Signing Keys (asymmetric)
_ASYMMETRIC_ALGS: Set[str] = {"ES256", "RS256"}

# In-process JWKS client (caches keys; recreated on demand)
_jwks_client: Optional[PyJWKClient] = None
_JWKS_CACHE_LIFESPAN_SECONDS = 3600


class TokenData:
    """Data extracted from a verified JWT token."""

    def __init__(self, sub: str, exp: Optional[int] = None, aud: Optional[str] = None):
        self.sub = sub  # User ID
        self.exp = exp  # Expiration timestamp
        self.aud = aud  # Audience
        self.email: Optional[str] = None


def _jwks_url() -> str:
    """Build Supabase Auth JWKS URL from configured project URL."""
    base = (settings.SUPABASE_URL or "").rstrip("/")
    return f"{base}/auth/v1/.well-known/jwks.json"


def _get_jwks_client() -> PyJWKClient:
    """Return a process-wide PyJWKClient with key caching."""
    global _jwks_client
    if _jwks_client is None:
        _jwks_client = PyJWKClient(
            _jwks_url(),
            cache_keys=True,
            lifespan=_JWKS_CACHE_LIFESPAN_SECONDS,
        )
    return _jwks_client


def reset_jwks_client() -> None:
    """Clear cached JWKS client (for tests / key rotation recovery)."""
    global _jwks_client
    _jwks_client = None


def _unauthorized(detail: str = "Invalid token") -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )


def _decode_payload(token: str) -> Dict[str, Any]:
    """Decode and verify a Supabase access token.

    Prefer asymmetric verification via JWKS when the token header says ES256/RS256
    (current Supabase JWT Signing Keys). Fall back to HS256 + SUPABASE_JWT_SECRET
    for legacy projects and unit tests.
    """
    try:
        header = jwt.get_unverified_header(token)
    except jwt.exceptions.DecodeError as e:
        raise _unauthorized() from e

    alg = header.get("alg")
    kid = header.get("kid")

    if alg in _ASYMMETRIC_ALGS:
        return _decode_asymmetric(token, alg=alg, kid=kid)

    # Legacy / test path: HS256 with project JWT secret
    return jwt.decode(
        token,
        settings.SUPABASE_JWT_SECRET,
        algorithms=["HS256"],
        audience="authenticated",
    )


def _decode_asymmetric(token: str, *, alg: str, kid: Optional[str]) -> Dict[str, Any]:
    """Verify ES256/RS256 tokens using Supabase JWKS public keys."""
    client = _get_jwks_client()
    try:
        signing_key = client.get_signing_key_from_jwt(token)
        return jwt.decode(
            token,
            signing_key.key,
            algorithms=list(_ASYMMETRIC_ALGS),
            audience="authenticated",
        )
    except Exception as first_error:
        # Unknown kid or stale cache: force one JWKS re-fetch, then retry once.
        logger.warning(
            "Asymmetric JWT verify failed (will refresh JWKS once): alg=%s kid=%s error=%s",
            alg,
            kid,
            first_error,
        )
        reset_jwks_client()
        client = _get_jwks_client()
        signing_key = client.get_signing_key_from_jwt(token)
        return jwt.decode(
            token,
            signing_key.key,
            algorithms=list(_ASYMMETRIC_ALGS),
            audience="authenticated",
        )


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
        raise _unauthorized("Not authenticated")

    token = credentials.credentials
    token_alg: Optional[str] = None
    token_kid: Optional[str] = None

    try:
        try:
            header = jwt.get_unverified_header(token)
            token_alg = header.get("alg")
            token_kid = header.get("kid")
        except Exception:
            pass

        # Local verification only — no network call to Supabase Auth per request
        # when JWKS is cached. Login still uses Supabase Auth for password checks.
        payload = _decode_payload(token)

        user_id = payload.get("sub")
        if not user_id:
            raise _unauthorized()

        token_data = TokenData(
            sub=user_id,
            exp=payload.get("exp"),
            aud=payload.get("aud"),
        )
        token_data.email = payload.get("email")

        return token_data

    except HTTPException:
        raise
    except jwt.PyJWTError as e:
        logger.warning(
            "Token verification failed: %s (alg=%s kid=%s)",
            e,
            token_alg,
            token_kid,
        )
        raise _unauthorized() from e
    except Exception as e:
        # JWKS fetch / unexpected crypto errors
        logger.warning(
            "Token verification failed: %s (alg=%s kid=%s)",
            e,
            token_alg,
            token_kid,
        )
        raise _unauthorized() from e


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
