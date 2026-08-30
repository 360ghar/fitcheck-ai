"""OAuth 2.1 authorization-server service for the MCP/ChatGPT surface.

ChatGPT (Apps SDK) connects to MCP servers only through OAuth 2.1 with
dynamic client registration; Supabase cannot play that role directly. This
module implements the minimal OAuth gateway:

- dynamic client registration (redirect URIs restricted to an allowlist),
- authorization-code flow with mandatory PKCE (S256),
- single-use 60-second codes,
- refresh-token rotation with family revocation on reuse,
- access tokens are backend-minted HS256 JWTs (``aud=fitcheck-mcp``) whose
  ``sub`` is the FitCheck user id — accepted by ``get_current_user`` via the
  MCP branch in ``app.core.security`` so loopbacked tool calls authenticate
  exactly like first-party clients.

The user's identity is established by the Supabase session obtained in the
frontend bridge (Supabase hosted login → ``/oauth/bridge`` → this service
verifies that JWT and binds it to the pending authorization).

Storage lives in three service-role-only tables (migration 057).
"""

from __future__ import annotations

import base64
import hashlib
import logging
import secrets
import uuid
from typing import Any, Dict, List, Optional
from urllib.parse import urlencode, urlsplit

import jwt
from supabase import Client

from app.core.config import settings
from app.core.exceptions import AuthenticationError, ValidationError
from app.utils.datetime_util import utcnow

logger = logging.getLogger(__name__)

MCP_TOKEN_AUDIENCE = "fitcheck-mcp"
MCP_TOKEN_TYPE = "mcp"
MCP_SCOPE = "mcp"

ACCESS_TOKEN_TTL_SECONDS = 3600  # 1 hour
REFRESH_TOKEN_TTL_DAYS = 30
AUTH_CODE_TTL_SECONDS = 60

_CODE_BYTES = 32
_REFRESH_BYTES = 48


class OAuthDisabledError(Exception):
    """OAuth gateway is not configured on this deployment."""


# ---------------------------------------------------------------------------
# Configuration helpers
# ---------------------------------------------------------------------------


def is_oauth_enabled() -> bool:
    """OAuth only runs when the issuer is configured (opt-in per deployment)."""
    return bool((settings.MCP_OAUTH_ISSUER or "").strip())


def _require_enabled() -> None:
    if not is_oauth_enabled():
        raise OAuthDisabledError("MCP_OAUTH_ISSUER is not configured")


def redirect_uri_allowlist() -> List[str]:
    """Allowed redirect-URI roots for dynamic registration (comma-separated)."""
    raw = (settings.MCP_REDIRECT_URI_ALLOWLIST or "").strip()
    if not raw:
        return []
    return [item.strip().rstrip("/") for item in raw.split(",") if item.strip()]


def _redirect_uri_allowed(redirect_uri: str) -> bool:
    candidate = urlsplit((redirect_uri or "").strip())
    if not candidate.scheme or not candidate.netloc or candidate.fragment:
        return False
    candidate_path = candidate.path.rstrip("/")

    for configured in redirect_uri_allowlist():
        allowed = urlsplit(configured)
        if not allowed.scheme or not allowed.netloc:
            continue
        if candidate.scheme != allowed.scheme or candidate.netloc != allowed.netloc:
            continue
        allowed_path = allowed.path.rstrip("/")
        if not allowed_path:
            return True
        if candidate_path == allowed_path or candidate_path.startswith(f"{allowed_path}/"):
            return True
    return False


def validate_scope(scope: str) -> str:
    """Validate the only OAuth scope exposed by the MCP resource."""
    if (scope or "").strip() != MCP_SCOPE:
        raise ValidationError(message="unsupported scope")
    return MCP_SCOPE


def signing_key() -> str:
    """HS256 key for MCP-issued tokens (dedicated secret or Supabase secret)."""
    return settings.MCP_JWT_SECRET or settings.SUPABASE_JWT_SECRET


def issuer() -> str:
    return (settings.MCP_OAUTH_ISSUER or "").rstrip("/")


def _hash(value: str) -> str:
    return hashlib.sha256(value.encode("utf-8")).hexdigest()


def _b64url_no_pad(digest: bytes) -> str:
    return base64.urlsafe_b64encode(digest).rstrip(b"=").decode("ascii")


def pkce_challenge(verifier: str) -> str:
    """S256 code challenge for a verifier (RFC 7636)."""
    return _b64url_no_pad(hashlib.sha256(verifier.encode("ascii")).digest())


# ---------------------------------------------------------------------------
# Access tokens (backend-minted JWTs)
# ---------------------------------------------------------------------------


def mint_access_token(user_id: str, client_id: str, scope: str = MCP_SCOPE) -> Dict[str, Any]:
    """Issue a signed MCP access token. Returns ``{token, expires_in}``."""
    _require_enabled()
    now = utcnow()
    issued_at = int(now.timestamp())
    payload = {
        "iss": issuer(),
        "sub": user_id,
        "aud": MCP_TOKEN_AUDIENCE,
        "typ": MCP_TOKEN_TYPE,
        "client_id": client_id,
        "scope": scope,
        "iat": issued_at,
        "exp": issued_at + ACCESS_TOKEN_TTL_SECONDS,
        "jti": secrets.token_hex(12),
    }
    token = jwt.encode(payload, signing_key(), algorithm="HS256")
    return {"token": token, "expires_in": ACCESS_TOKEN_TTL_SECONDS}


def verify_access_token(token: str) -> Dict[str, Any]:
    """Strict verification of an MCP-issued access token."""
    _require_enabled()
    return jwt.decode(
        token,
        signing_key(),
        algorithms=["HS256"],
        audience=MCP_TOKEN_AUDIENCE,
        issuer=issuer(),
        options={"require": ["exp"]},
    )


# ---------------------------------------------------------------------------
# Dynamic client registration
# ---------------------------------------------------------------------------


def register_client(db: Client, redirect_uris: List[str], client_name: str) -> Dict[str, Any]:
    """Register a public client (PKCE only, no secret). Returns the RFC 7591
    registration payload subset ChatGPT needs."""
    if not redirect_uris:
        raise ValidationError(message="redirect_uris is required")
    for uri in redirect_uris:
        if not _redirect_uri_allowed(uri):
            raise ValidationError(
                message=f"redirect_uri not allowed: {uri}",
            )

    client_id = "mcp_" + secrets.token_hex(12)
    now = utcnow().isoformat()
    db.table("mcp_oauth_clients").insert(
        {
            "client_id": client_id,
            "client_name": (client_name or "unknown")[:200],
            "redirect_uris": redirect_uris,
            "scope": MCP_SCOPE,
            "created_at": now,
        }
    ).execute()
    return {
        "client_id": client_id,
        "client_name": client_name,
        "redirect_uris": redirect_uris,
        "token_endpoint_auth_method": "none",  # public client + PKCE
        "grant_types": ["authorization_code", "refresh_token"],
        "response_types": ["code"],
        "scope": MCP_SCOPE,
    }


def get_client(db: Client, client_id: str) -> Optional[Dict[str, Any]]:
    result = db.table("mcp_oauth_clients").select("*").eq("client_id", client_id).maybe_single().execute()
    return getattr(result, "data", None)


# ---------------------------------------------------------------------------
# Authorization codes (pending → completed → consumed)
# ---------------------------------------------------------------------------


def create_pending_authorization(
    db: Client,
    *,
    client_id: str,
    redirect_uri: str,
    state: str,
    code_challenge: str,
    code_challenge_method: str,
) -> Dict[str, Any]:
    """Record the client's authorize request; user binds at /authorize/complete."""
    client = get_client(db, client_id)
    if not client:
        raise ValidationError(message="unknown client_id")
    if redirect_uri not in (client.get("redirect_uris") or []):
        raise ValidationError(message="redirect_uri mismatch")
    if code_challenge_method != "S256":
        raise ValidationError(message="code_challenge_method must be S256")

    row = {
        "id": str(uuid.uuid4()),
        "txn_state": state,
        "code_hash": None,
        "user_id": None,
        "client_id": client_id,
        "redirect_uri": redirect_uri,
        "scope": MCP_SCOPE,
        "code_challenge": code_challenge,
        "challenge_method": code_challenge_method,
        "expires_at": _seconds_from_now(600),
        "used_at": None,
    }
    # A client that reuses a `state` value (or retries the authorize request)
    # must not leave two pending rows — complete_authorization resolves the
    # pending row via maybe_single, which errors on multiples. Delete the
    # stale duplicate first; the DB ALSO enforces this with a unique partial
    # index (migration 057) as defense in depth.
    db.table("mcp_oauth_auth_codes").delete().eq("txn_state", state).execute()
    db.table("mcp_oauth_auth_codes").insert(row).execute()
    return row


def complete_authorization(
    db: Client,
    *,
    state: str,
    supabase_access_token: str,
    decode_supabase_token,
) -> str:
    """Bind the pending authorization to a Supabase-verified user and mint the
    one-time code. ``decode_supabase_token`` is injected (app.core.security)
    to keep this service free of auth-layer imports. Returns the redirect URL
    the frontend bridge must navigate to."""

    result = (
        db.table("mcp_oauth_auth_codes")
        .select("*")
        .eq("txn_state", state)
        .is_("used_at", "null")
        .is_("code_hash", "null")
        .gt("expires_at", utcnow().isoformat())
        .maybe_single()
        .execute()
    )
    pending = getattr(result, "data", None)
    if not pending:
        raise AuthenticationError(message="unknown or expired authorization state")

    try:
        claims = decode_supabase_token(supabase_access_token)
    except Exception as error:
        raise AuthenticationError(message="Supabase session invalid") from error
    user_id = claims.get("sub")
    if not user_id:
        raise AuthenticationError(message="Supabase session invalid")

    code = secrets.token_urlsafe(_CODE_BYTES)
    claimed = db.table("mcp_oauth_auth_codes").update(
        {
            "code_hash": _hash(code),
            "txn_state": None,  # single binding: state cannot be replayed
            "user_id": user_id,
            "expires_at": _seconds_from_now(AUTH_CODE_TTL_SECONDS),
        }
    ).eq("id", pending["id"]).eq("txn_state", state).is_(
        "used_at", "null"
    ).is_("code_hash", "null").gt(
        "expires_at", utcnow().isoformat()
    ).execute()
    claimed_rows = getattr(claimed, "data", None)
    if not claimed_rows:
        raise AuthenticationError(message="unknown or expired authorization state")

    query = urlencode({"code": code, "state": state, "scope": pending["scope"]})
    separator = "&" if "?" in pending["redirect_uri"] else "?"
    return f"{pending['redirect_uri']}{separator}{query}"


# ---------------------------------------------------------------------------
# Token issuance / rotation / revocation
# ---------------------------------------------------------------------------


def _issue_token_pair(db: Client, user_id: str, client_id: str, scope: str, family: Optional[str] = None) -> Dict[str, Any]:
    access = mint_access_token(user_id, client_id, scope)
    refresh = secrets.token_urlsafe(_REFRESH_BYTES)
    family_id = family or str(uuid.uuid4())
    db.table("mcp_oauth_refresh_tokens").insert(
        {
            # Explicit id: the prod column default (gen_random_uuid) is fine,
            # but an explicit value keeps FakeDB-based tests working too.
            "id": str(uuid.uuid4()),
            "token_hash": _hash(refresh),
            "user_id": user_id,
            "client_id": client_id,
            "scope": scope,
            "family": family_id,
            "expires_at": _seconds_from_now(REFRESH_TOKEN_TTL_DAYS * 86400),
            "revoked_at": None,
            "replaced_by": None,
        }
    ).execute()
    return {
        "access_token": access["token"],
        "token_type": "bearer",
        "expires_in": access["expires_in"],
        "refresh_token": refresh,
        "scope": scope,
    }


def _rpc_row(result: Any) -> Optional[Dict[str, Any]]:
    """Return the single row returned by a Supabase RPC call."""
    data = getattr(result, "data", None)
    if isinstance(data, list):
        return data[0] if data else None
    return data if isinstance(data, dict) else None


def exchange_code_for_tokens(db: Client, *, code: str, client_id: str, redirect_uri: str, code_verifier: str) -> Dict[str, Any]:
    result = db.rpc(
        "consume_mcp_oauth_authorization_code",
        {
            "p_code_hash": _hash(code),
            "p_client_id": client_id,
            "p_redirect_uri": redirect_uri,
            "p_code_challenge": pkce_challenge(code_verifier),
        },
    ).execute()
    record = _rpc_row(result)
    outcome = record.get("outcome") if record else "invalid"
    if outcome == "client_mismatch":
        raise AuthenticationError(message="code was issued to a different client")
    if outcome == "expired":
        raise AuthenticationError(message="authorization code expired")
    if outcome == "pkce_failed":
        raise AuthenticationError(message="PKCE verification failed")
    if outcome == "unbound":
        raise AuthenticationError(message="authorization code not bound to a user")
    if outcome != "consumed" or not record or not record.get("user_id"):
        raise AuthenticationError(message="invalid authorization code")
    return _issue_token_pair(db, record["user_id"], client_id, record["scope"] or MCP_SCOPE)


def rotate_refresh_token(db: Client, refresh_token: str) -> Dict[str, Any]:
    """Rotate a refresh token. Reuse of a revoked token kills its whole family
    (RFC 6819 refresh-token replay mitigation)."""
    replacement = secrets.token_urlsafe(_REFRESH_BYTES)
    result = db.rpc(
        "rotate_mcp_oauth_refresh_token",
        {
            "p_token_hash": _hash(refresh_token),
            "p_replacement_id": str(uuid.uuid4()),
            "p_replacement_token_hash": _hash(replacement),
            "p_replacement_expires_at": _seconds_from_now(REFRESH_TOKEN_TTL_DAYS * 86400),
        },
    ).execute()
    record = _rpc_row(result)
    outcome = record.get("outcome") if record else "invalid"
    if outcome == "reused":
        logger.warning("OAuth refresh-token replay detected; family %s revoked", record.get("family"))
        raise AuthenticationError(message="refresh token reuse detected")
    if outcome == "expired":
        raise AuthenticationError(message="refresh token expired")
    if outcome != "rotated" or not record:
        raise AuthenticationError(message="invalid refresh token")

    scope = record.get("scope") or MCP_SCOPE
    access = mint_access_token(record["user_id"], record["client_id"], scope)
    return {
        "access_token": access["token"],
        "token_type": "bearer",
        "expires_in": access["expires_in"],
        "refresh_token": replacement,
        "scope": scope,
    }


def revoke_refresh_token(db: Client, refresh_token: str) -> None:
    """Revoke one refresh token (idempotent per RFC 7009)."""
    db.table("mcp_oauth_refresh_tokens").update({"revoked_at": utcnow().isoformat()}).eq(
        "token_hash", _hash(refresh_token)
    ).execute()


def revoke_all_for_user(db: Client, user_id: str) -> None:
    """Kill every refresh family for a user (logout-everywhere / incident path)."""
    db.table("mcp_oauth_refresh_tokens").update({"revoked_at": utcnow().isoformat()}).eq(
        "user_id", user_id
    ).is_("revoked_at", "null").execute()


# ---------------------------------------------------------------------------
# Small time helpers
# ---------------------------------------------------------------------------


def _seconds_from_now(seconds: int) -> str:
    from datetime import timedelta

    return (utcnow() + timedelta(seconds=seconds)).isoformat()


def _is_expired(iso_timestamp: str) -> bool:
    from datetime import datetime, timedelta

    try:
        parsed = datetime.fromisoformat(iso_timestamp.replace("Z", "+00:00"))
    except ValueError:
        return True
    return parsed < (utcnow() - timedelta(seconds=1))
