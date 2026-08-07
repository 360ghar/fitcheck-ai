"""Auth helpers for the test suite: signed tokens, credential wrappers, and
role-scoped user dicts for dependency overrides.

The real ``verify_token`` path is exercised in ``tests/api/test_auth_flow.py``
with tokens from :func:`make_hs256_token` (signed with the configured
``SUPABASE_JWT_SECRET``). Resource tests override the dependency instead (see
``tests/api/conftest.py``), so they never depend on token mechanics.
"""

from __future__ import annotations

import time
from typing import Any, Dict

from fastapi.security import HTTPAuthorizationCredentials
from jose import jwt

from app.core.config import settings


def make_hs256_token(
    sub: str = "user-1",
    aud: str = "authenticated",
    exp_delta_seconds: int = 3600,
    **extra_claims: Any,
) -> str:
    """A valid-looking HS256 access token signed with the configured secret."""
    payload = {
        "sub": sub,
        "aud": aud,
        "iss": f"{settings.SUPABASE_URL.rstrip('/')}/auth/v1",
        "exp": int(time.time()) + exp_delta_seconds,
        **extra_claims,
    }
    return jwt.encode(payload, settings.SUPABASE_JWT_SECRET, algorithm="HS256")


def bearer_credentials(token: str) -> HTTPAuthorizationCredentials:
    """Wrap a token in the credentials object ``verify_token`` receives."""
    return HTTPAuthorizationCredentials(scheme="Bearer", credentials=token)


def auth_header(token: str) -> Dict[str, str]:
    """Headers dict for httpx/TestClient requests carrying a bearer token."""
    return {"Authorization": f"Bearer {token}"}


# ---------------------------------------------------------------------------
# User dicts for dependency overrides (get_current_user / require_admin)
# ---------------------------------------------------------------------------


def make_user(**overrides: Any) -> Dict[str, Any]:
    """A realistic users-row dict for a plain authenticated user."""
    user = {
        "id": "11111111-1111-1111-1111-111111111111",
        "email": "wardrobe@example.com",
        "full_name": "Ada Lovelace",
        "avatar_url": None,
        "is_active": True,
        "email_verified": True,
        "role": "user",
        "created_at": "2026-01-01T00:00:00+00:00",
        "updated_at": "2026-01-01T00:00:00+00:00",
    }
    user.update(overrides)
    return user


def make_admin_user(**overrides: Any) -> Dict[str, Any]:
    """A users-row dict with an admin role (passes ``require_admin``)."""
    user = make_user(id="22222222-2222-2222-2222-222222222222", role="admin")
    user.update(overrides)
    return user
