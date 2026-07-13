"""
Authentication helpers for social import.

Supports two auth session types:
- oauth: Meta OAuth token payload
- scraper: ephemeral credentials/session marker for scraper fallback
"""

from __future__ import annotations

import json
import logging
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from cryptography.fernet import Fernet, InvalidToken

from app.core.config import settings
from app.core.exceptions import (
    SocialImportEncryptionConfigError,
    SocialImportLoginFailedError,
    SocialImportMFARequiredError,
)
from app.models.social_import import SocialAuthType
from app.utils.crypto import derive_fernet_key, legacy_derive_fernet_key

_KEY_PURPOSE = b"fitcheck-social-auth-session-v1"


class SocialAuthService:
    """Manage ephemeral encrypted auth sessions for social import jobs."""

    _logger = logging.getLogger(__name__)

    @staticmethod
    def _fernet() -> Optional[Fernet]:
        # ponytail: no fallback to SUPABASE_JWT_SECRET - reusing a JWT-signing
        # secret to encrypt stored scraper credentials would be key reuse
        # across security domains. Fail closed if AI_ENCRYPTION_KEY is unset.
        key = settings.AI_ENCRYPTION_KEY
        if not key:
            return None
        return Fernet(derive_fernet_key(key, _KEY_PURPOSE))

    @staticmethod
    def _legacy_fernet() -> Optional[Fernet]:
        """Pre-domain-separation key, tried only as a decrypt fallback so
        sessions encrypted before this change stay readable during the
        migration window (these are short-TTL/ephemeral, so this fallback
        is only relevant for a brief period after deploy)."""
        key = settings.AI_ENCRYPTION_KEY
        if not key:
            return None
        legacy_key = legacy_derive_fernet_key(key)
        return Fernet(legacy_key) if legacy_key else None

    @classmethod
    def encrypt_session_payload(cls, payload: Dict[str, Any]) -> str:
        serialized = json.dumps(payload)
        fernet = cls._fernet()
        if not fernet:
            raise SocialImportEncryptionConfigError(
                "AI_ENCRYPTION_KEY must be configured to securely store social auth sessions"
            )

        return fernet.encrypt(serialized.encode("utf-8")).decode("utf-8")

    @classmethod
    def decrypt_session_payload(cls, encrypted_payload: str) -> Optional[Dict[str, Any]]:
        if not encrypted_payload:
            return None

        for fernet in (cls._fernet(), cls._legacy_fernet()):
            if not fernet:
                continue
            try:
                decrypted = fernet.decrypt(encrypted_payload.encode("utf-8")).decode("utf-8")
                return json.loads(decrypted)
            except (InvalidToken, ValueError, TypeError):
                continue

        return None

    @staticmethod
    def _expiry() -> datetime:
        ttl_minutes = max(5, settings.SOCIAL_IMPORT_AUTH_SESSION_TTL_MINUTES)
        return datetime.now(timezone.utc) + timedelta(minutes=ttl_minutes)

    @classmethod
    async def store_oauth_session(
        cls,
        db,
        *,
        job_id: str,
        user_id: str,
        provider_access_token: str,
        provider_refresh_token: Optional[str],
        provider_user_id: Optional[str],
        provider_page_access_token: Optional[str] = None,
        provider_page_id: Optional[str] = None,
        provider_username: Optional[str] = None,
        expires_at: Optional[datetime],
    ) -> Dict[str, Any]:
        payload = {
            "provider_access_token": provider_access_token,
            "provider_refresh_token": provider_refresh_token,
            "provider_user_id": provider_user_id,
            "provider_page_access_token": provider_page_access_token,
            "provider_page_id": provider_page_id,
            "provider_username": provider_username,
            "provider_expires_at": expires_at.isoformat() if expires_at else None,
            "saved_at": datetime.now(timezone.utc).isoformat(),
        }

        data = {
            "job_id": job_id,
            "user_id": user_id,
            "auth_type": SocialAuthType.OAUTH.value,
            "encrypted_session_blob": cls.encrypt_session_payload(payload),
            "expires_at": cls._expiry().isoformat(),
        }
        db.table("social_import_auth_sessions").upsert(
            data,
            on_conflict="job_id,auth_type",
        ).execute()
        return data

    @classmethod
    async def store_scraper_session(
        cls,
        db,
        *,
        job_id: str,
        user_id: str,
        username: str,
        password: str,
        otp_code: Optional[str],
        two_factor_identifier: Optional[str] = None,
        sessionid: Optional[str] = None,
        csrftoken: Optional[str] = None,
        ds_user_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        # Basic placeholder validation hooks for scraper fallback.
        if not username or not password:
            raise SocialImportLoginFailedError("Username and password are required")

        lowered = username.lower()
        if "mfa" in lowered and not otp_code:
            raise SocialImportMFARequiredError("MFA code required for this account")

        payload = {
            "username": username,
            "password": password,
            "otp_code": otp_code,
            "two_factor_identifier": two_factor_identifier,
            "sessionid": sessionid,
            "csrftoken": csrftoken,
            "ds_user_id": ds_user_id,
            "saved_at": datetime.now(timezone.utc).isoformat(),
            "session_kind": "ephemeral_credentials",
        }

        data = {
            "job_id": job_id,
            "user_id": user_id,
            "auth_type": SocialAuthType.SCRAPER.value,
            "encrypted_session_blob": cls.encrypt_session_payload(payload),
            "expires_at": cls._expiry().isoformat(),
        }
        db.table("social_import_auth_sessions").upsert(
            data,
            on_conflict="job_id,auth_type",
        ).execute()
        return data

    @classmethod
    async def get_active_session(
        cls,
        db,
        *,
        job_id: str,
        user_id: str,
    ) -> Optional[Dict[str, Any]]:
        now_iso = datetime.now(timezone.utc).isoformat()
        result = (
            db.table("social_import_auth_sessions")
            .select("*")
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .gte("expires_at", now_iso)
            .order("created_at", desc=True)
            .limit(1)
            .execute()
        )

        rows = result.data or []
        if not rows:
            return None

        row = rows[0]
        payload = cls.decrypt_session_payload(row.get("encrypted_session_blob") or "")
        if payload is None:
            return None

        row["session_payload"] = payload
        return row

    @staticmethod
    async def delete_sessions(db, *, job_id: str, user_id: str) -> None:
        (
            db.table("social_import_auth_sessions")
            .delete()
            .eq("job_id", job_id)
            .eq("user_id", user_id)
            .execute()
        )

    @staticmethod
    async def cleanup_expired_sessions(db) -> int:
        now_iso = datetime.now(timezone.utc).isoformat()
        result = (
            db.table("social_import_auth_sessions")
            .delete()
            .lt("expires_at", now_iso)
            .execute()
        )
        return len(result.data or [])
