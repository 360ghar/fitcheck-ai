"""
Meta OAuth helpers for social import.
"""

from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
import threading
from dataclasses import dataclass
from datetime import timedelta
from app.utils.datetime_util import utcnow
from typing import Any, Dict, Optional
from urllib.parse import urlencode, urlparse, urlunparse

import httpx

from app.core.config import settings
from app.core.logging_config import get_context_logger
from app.core.exceptions import (
    SocialImportOAuthConfigError,
    SocialImportOAuthExchangeError,
    SocialImportOAuthStateError,
)
from app.models.social_import import SocialPlatform
from app.utils.crypto import derive_key


logger = get_context_logger(__name__)


# backend #16: account-selection tokens are stateless HMAC tokens, so without
# an explicit consume step a single picker link is replayable for its full TTL.
# Concurrent submissions of one picker token could otherwise bind a different
# candidate page after the job already resumed. This module-level, lock-guarded
# dict records each consumed nonce -> its token expiry timestamp. Entries are
# pruned opportunistically on each consume so the set cannot grow unbounded
# (every entry self-expires). This is replay protection only - it is NOT a
# durable store, and a process restart loses the set (worst case: a token that
# was already used once becomes reusable until its natural expiry, same as the
# pre-fix behavior, but a second use within one process lifetime is blocked).
_CONSUMED_SELECTION_NONCES: Dict[str, float] = {}
_CONSUMED_SELECTION_NONCES_LOCK = threading.Lock()


@dataclass
class SocialOAuthState:
    user_id: str
    job_id: str
    platform: SocialPlatform
    opener_origin: Optional[str]
    mobile_redirect_uri: Optional[str]
    exp: int
    nonce: str


class SocialOAuthService:
    """Create OAuth URLs, validate callback state, and exchange Meta auth codes."""

    _GRAPH_VERSION = "v23.0"
    _DIALOG_URL = f"https://www.facebook.com/{_GRAPH_VERSION}/dialog/oauth"
    _GRAPH_BASE_URL = f"https://graph.facebook.com/{_GRAPH_VERSION}"
    _STATE_TTL_SECONDS = 10 * 60

    _SCOPES: Dict[SocialPlatform, list[str]] = {
        SocialPlatform.INSTAGRAM: [
            "public_profile",
            "pages_show_list",
            "instagram_basic",
            "business_management",
        ],
        SocialPlatform.FACEBOOK: [
            "public_profile",
            "user_photos",
            "user_posts",
        ],
    }

    @staticmethod
    def _sanitize_mobile_redirect_uri(value: Optional[str]) -> Optional[str]:
        if not value:
            return None

        parsed = urlparse(value.strip())
        # Restrict redirect target to our app custom scheme to avoid open redirects.
        if parsed.scheme != "fitcheck.ai" or not parsed.netloc:
            return None

        sanitized = parsed._replace(fragment="")
        return urlunparse(sanitized)

    _STATE_KEY_PURPOSE = b"fitcheck-social-oauth-state-v1"

    @classmethod
    def _state_secret(cls) -> bytes:
        # No fallback to SUPABASE_JWT_SECRET - reusing a JWT-signing secret to
        # sign unrelated OAuth CSRF state would be key reuse across security
        # domains. Fail closed if AI_ENCRYPTION_KEY is unset. HKDF-derived
        # with a purpose label distinct from the other AI_ENCRYPTION_KEY
        # consumers (ai_settings_service, social_auth_service) so the three
        # domains don't share a derived key. State tokens are short-lived
        # (_STATE_TTL_SECONDS) and never persisted, so there's no
        # already-encrypted-data migration concern for this one.
        secret = settings.AI_ENCRYPTION_KEY
        if not secret:
            raise SocialImportOAuthConfigError(
                "Set AI_ENCRYPTION_KEY to enable OAuth state signing"
            )
        return derive_key(secret, cls._STATE_KEY_PURPOSE)

    @staticmethod
    def _b64_url_encode(raw: bytes) -> str:
        return base64.urlsafe_b64encode(raw).decode("utf-8").rstrip("=")

    @staticmethod
    def _b64_url_decode(value: str) -> bytes:
        padding = "=" * (-len(value) % 4)
        return base64.urlsafe_b64decode(value + padding)

    @classmethod
    def _sign_state(cls, encoded_payload: str) -> str:
        digest = hmac.new(
            cls._state_secret(),
            encoded_payload.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        return digest

    @classmethod
    def create_state(
        cls,
        *,
        user_id: str,
        job_id: str,
        platform: SocialPlatform,
        opener_origin: Optional[str] = None,
        mobile_redirect_uri: Optional[str] = None,
    ) -> str:
        exp = int((utcnow() + timedelta(seconds=cls._STATE_TTL_SECONDS)).timestamp())
        payload = {
            "uid": user_id,
            "jid": job_id,
            "plt": platform.value,
            "exp": exp,
            "nonce": secrets.token_urlsafe(12),
        }
        if opener_origin:
            payload["org"] = opener_origin
        mobile_redirect = cls._sanitize_mobile_redirect_uri(mobile_redirect_uri)
        if mobile_redirect:
            payload["mru"] = mobile_redirect
        encoded_payload = cls._b64_url_encode(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
        signature = cls._sign_state(encoded_payload)
        return f"{encoded_payload}.{signature}"

    @classmethod
    def parse_state(cls, state: str) -> SocialOAuthState:
        try:
            encoded_payload, signature = state.split(".", 1)
        except ValueError as exc:
            raise SocialImportOAuthStateError("Malformed OAuth state") from exc

        expected = cls._sign_state(encoded_payload)
        if not hmac.compare_digest(signature, expected):
            raise SocialImportOAuthStateError("Invalid OAuth state signature")

        try:
            payload = json.loads(cls._b64_url_decode(encoded_payload).decode("utf-8"))
            user_id = str(payload["uid"])
            job_id = str(payload["jid"])
            platform = SocialPlatform(str(payload["plt"]))
            exp = int(payload["exp"])
            nonce = str(payload["nonce"])
            opener_origin = payload.get("org")
            if opener_origin is not None:
                opener_origin = str(opener_origin)
                if not opener_origin.startswith(("http://", "https://")):
                    opener_origin = None
            mobile_redirect_uri = cls._sanitize_mobile_redirect_uri(payload.get("mru"))
        except Exception as exc:
            raise SocialImportOAuthStateError("Invalid OAuth state payload") from exc

        now_ts = int(utcnow().timestamp())
        if exp < now_ts:
            raise SocialImportOAuthStateError("OAuth state expired, please retry")

        return SocialOAuthState(
            user_id=user_id,
            job_id=job_id,
            platform=platform,
            opener_origin=opener_origin,
            mobile_redirect_uri=mobile_redirect_uri,
            exp=exp,
            nonce=nonce,
        )

    # ---- account-selection tokens (A4-28) ----------------------------------
    #
    # The multi-account picker is a plain HTML form POSTed from the callback's
    # browser context, which cannot carry the app's Authorization header. The
    # selection is authorized by a short-lived HMAC token (same construction
    # as the OAuth state) that pins the job + user; the select-page endpoint
    # validates it and resolves the user from the token, not from a header.
    _SELECTION_KEY_PURPOSE = b"fitcheck-social-oauth-selection-v1"
    _SELECTION_TTL_SECONDS = 10 * 60

    @classmethod
    def _selection_secret(cls) -> bytes:
        # Same fail-closed policy as _state_secret: purpose-scoped HKDF key
        # derived from AI_ENCRYPTION_KEY, distinct from every other consumer.
        secret = settings.AI_ENCRYPTION_KEY
        if not secret:
            raise SocialImportOAuthConfigError(
                "Set AI_ENCRYPTION_KEY to enable account selection signing"
            )
        return derive_key(secret, cls._SELECTION_KEY_PURPOSE)

    @classmethod
    def create_selection_token(cls, *, user_id: str, job_id: str) -> str:
        """Sign a short-lived selection token for the account picker."""
        exp = int((utcnow() + timedelta(seconds=cls._SELECTION_TTL_SECONDS)).timestamp())
        payload = {
            "uid": user_id,
            "jid": job_id,
            "exp": exp,
            "nonce": secrets.token_urlsafe(12),
        }
        encoded = cls._b64_url_encode(
            json.dumps(payload, separators=(",", ":")).encode("utf-8")
        )
        signature = hmac.new(
            cls._selection_secret(),
            encoded.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        return f"{encoded}.{signature}"

    @classmethod
    def parse_selection_token(cls, token: str) -> Dict[str, str]:
        """Validate a selection token; returns {user_id, job_id, nonce, exp}.

        Raises SocialImportOAuthStateError on malformed/expired/invalid
        tokens (same error class the OAuth state uses).

        This validates signature + expiry only - it does NOT consume the
        nonce. Use ``consume_selection_token`` at the point of use to get
        single-use / replay protection (backend #16).
        """
        try:
            encoded, signature = token.split(".", 1)
        except ValueError as exc:
            raise SocialImportOAuthStateError("Malformed account selection token") from exc

        expected = hmac.new(
            cls._selection_secret(),
            encoded.encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()
        if not hmac.compare_digest(signature, expected):
            raise SocialImportOAuthStateError("Invalid account selection token")

        try:
            payload = json.loads(cls._b64_url_decode(encoded).decode("utf-8"))
            user_id = str(payload["uid"])
            job_id = str(payload["jid"])
            exp = int(payload["exp"])
            nonce = str(payload["nonce"])
        except Exception as exc:
            raise SocialImportOAuthStateError("Invalid account selection token payload") from exc

        if exp < int(utcnow().timestamp()):
            raise SocialImportOAuthStateError("Account selection expired, please retry")

        return {"user_id": user_id, "job_id": job_id, "nonce": nonce, "exp": exp}

    @classmethod
    def consume_selection_token(cls, token: str) -> Dict[str, str]:
        """Validate AND single-use a selection token (backend #16).

        Same validation as ``parse_selection_token`` (signature + expiry),
        then atomically records the token's signed nonce in the
        process-local consumed set. A second call with the same token raises
        ``SocialImportOAuthStateError`` so a replayed picker link cannot bind
        a different candidate page after the job already resumed.

        The nonce is part of the signed token body (see
        ``create_selection_token``), so it cannot be swapped without
        invalidating the signature.
        """
        parsed = cls.parse_selection_token(token)
        nonce = parsed["nonce"]
        exp = parsed["exp"]

        with _CONSUMED_SELECTION_NONCES_LOCK:
            now_ts = utcnow().timestamp()
            # Opportunistic GC: drop entries whose token already expired so
            # the set is bounded by the live (un-expired) token population.
            if _CONSUMED_SELECTION_NONCES:
                expired = [k for k, v in _CONSUMED_SELECTION_NONCES.items() if v < now_ts]
                for k in expired:
                    _CONSUMED_SELECTION_NONCES.pop(k, None)
            if nonce in _CONSUMED_SELECTION_NONCES:
                raise SocialImportOAuthStateError(
                    "This account selection has already been used. Please reconnect."
                )
            _CONSUMED_SELECTION_NONCES[nonce] = float(exp)

        return {"user_id": parsed["user_id"], "job_id": parsed["job_id"]}

    @classmethod
    def build_authorize_url(
        cls,
        *,
        user_id: str,
        job_id: str,
        platform: SocialPlatform,
        redirect_uri: str,
        opener_origin: Optional[str] = None,
        mobile_redirect_uri: Optional[str] = None,
    ) -> Dict[str, Any]:
        client_id = settings.META_OAUTH_CLIENT_ID
        if not client_id:
            raise SocialImportOAuthConfigError(
                "META_OAUTH_CLIENT_ID must be configured to start social OAuth"
            )

        state = cls.create_state(
            user_id=user_id,
            job_id=job_id,
            platform=platform,
            opener_origin=opener_origin,
            mobile_redirect_uri=mobile_redirect_uri,
        )
        scope = ",".join(cls._SCOPES.get(platform, ["public_profile"]))
        query = urlencode(
            {
                "client_id": client_id,
                "redirect_uri": redirect_uri,
                "response_type": "code",
                "scope": scope,
                "state": state,
            }
        )
        return {
            "auth_url": f"{cls._DIALOG_URL}?{query}",
            "state": state,
            "expires_in_seconds": cls._STATE_TTL_SECONDS,
            "provider": "meta",
        }

    @classmethod
    async def exchange_code_for_token(
        cls,
        *,
        code: str,
        redirect_uri: str,
    ) -> Dict[str, Any]:
        client_id = settings.META_OAUTH_CLIENT_ID
        client_secret = settings.META_OAUTH_CLIENT_SECRET
        if not client_id or not client_secret:
            raise SocialImportOAuthConfigError(
                "META_OAUTH_CLIENT_ID and META_OAUTH_CLIENT_SECRET must be configured"
            )

        params = {
            "client_id": client_id,
            "client_secret": client_secret,
            "redirect_uri": redirect_uri,
            "code": code,
        }
        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            response = await client.get(f"{cls._GRAPH_BASE_URL}/oauth/access_token", params=params)
            data = cls._parse_graph_response(response, "OAuth code exchange failed")

            access_token = data.get("access_token")
            if not access_token:
                raise SocialImportOAuthExchangeError("Meta OAuth response did not include access token")

            expires_in = int(data.get("expires_in") or 0)

            # Try to upgrade to a long-lived token. Keep short-lived token if unavailable.
            try:
                exchange_params = {
                    "grant_type": "fb_exchange_token",
                    "client_id": client_id,
                    "client_secret": client_secret,
                    "fb_exchange_token": access_token,
                }
                ll_response = await client.get(
                    f"{cls._GRAPH_BASE_URL}/oauth/access_token",
                    params=exchange_params,
                )
                if ll_response.is_success:
                    ll_data = ll_response.json()
                    if ll_data.get("access_token"):
                        access_token = ll_data["access_token"]
                        expires_in = int(ll_data.get("expires_in") or expires_in)
            except (httpx.RequestError, httpx.HTTPStatusError, KeyError, ValueError, TypeError):
                # Non-fatal: continue with the short-lived token.
                logger.debug("Long-lived token exchange failed, using short-lived token")

        expires_at = None
        if expires_in > 0:
            expires_at = utcnow() + timedelta(seconds=expires_in)

        return {
            "provider_access_token": access_token,
            "expires_at": expires_at,
        }

    @classmethod
    async def resolve_platform_identity(
        cls,
        *,
        platform: SocialPlatform,
        access_token: str,
        preferred_page_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        async with httpx.AsyncClient(timeout=20.0, follow_redirects=True) as client:
            if platform == SocialPlatform.INSTAGRAM:
                return await cls._resolve_instagram_identity(
                    client,
                    access_token=access_token,
                    preferred_page_id=preferred_page_id,
                )
            return await cls._resolve_facebook_identity(client, access_token=access_token)

    @classmethod
    async def _resolve_facebook_identity(
        cls,
        client: httpx.AsyncClient,
        *,
        access_token: str,
    ) -> Dict[str, Any]:
        response = await client.get(
            f"{cls._GRAPH_BASE_URL}/me",
            params={
                "fields": "id,name",
                "access_token": access_token,
            },
        )
        data = cls._parse_graph_response(response, "Failed to load Facebook profile identity")
        return {
            "provider_user_id": data.get("id"),
            "provider_username": data.get("name"),
        }

    @classmethod
    async def _resolve_instagram_identity(
        cls,
        client: httpx.AsyncClient,
        *,
        access_token: str,
        preferred_page_id: Optional[str] = None,
    ) -> Dict[str, Any]:
        response = await client.get(
            f"{cls._GRAPH_BASE_URL}/me/accounts",
            params={
                "fields": "id,name,access_token,instagram_business_account{id,username}",
                "limit": 25,
                "access_token": access_token,
            },
        )
        data = cls._parse_graph_response(
            response,
            "Failed to load Instagram account identity from connected pages",
        )

        accounts = data.get("data") or []
        candidates = []
        for account in accounts:
            ig_account = account.get("instagram_business_account") or {}
            ig_user_id = ig_account.get("id")
            if ig_user_id:
                candidates.append(
                    {
                        "provider_user_id": ig_user_id,
                        "provider_username": ig_account.get("username"),
                        "provider_page_access_token": account.get("access_token"),
                        "provider_page_id": account.get("id"),
                        # For the account-selection error details.
                        "page_name": account.get("name"),
                    }
                )

        if not candidates:
            raise SocialImportOAuthExchangeError(
                "No connected Instagram business account found in your Meta Pages"
            )

        if len(candidates) == 1:
            # Single business account: unambiguous, no selection needed.
            return {k: v for k, v in candidates[0].items() if k != "page_name"}

        # A4-28: multiple Instagram business accounts. Never silently pick the
        # first one - the import would use the wrong page's feed. Prefer the
        # page the connection was already bound to (provider_page_id stored on
        # the auth session); otherwise fail with a clear message listing the
        # candidates so the client can ask the user to select an account.
        if preferred_page_id:
            for candidate in candidates:
                if candidate.get("provider_page_id") == preferred_page_id:
                    return {k: v for k, v in candidate.items() if k != "page_name"}

        raise SocialImportOAuthExchangeError(
            "Multiple Instagram business accounts are connected to this Meta "
            "account. Select which account to import and reconnect.",
            details={
                "accounts": [
                    {
                        "provider_page_id": c["provider_page_id"],
                        "page_name": c.get("page_name"),
                        "username": c.get("provider_username"),
                    }
                    for c in candidates
                ],
                "requires_page_selection": True,
            },
        )

    @staticmethod
    def _parse_graph_response(response: httpx.Response, default_error_message: str) -> Dict[str, Any]:
        try:
            payload = response.json()
        except (ValueError, TypeError):
            payload = {}

        if response.is_success:
            return payload

        graph_error = payload.get("error") if isinstance(payload, dict) else None
        graph_message = graph_error.get("message") if isinstance(graph_error, dict) else None
        if response.status_code in {400, 401, 403}:
            message = graph_message or default_error_message
            raise SocialImportOAuthExchangeError(message)

        raise SocialImportOAuthExchangeError(default_error_message)
