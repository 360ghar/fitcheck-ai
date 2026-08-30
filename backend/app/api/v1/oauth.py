"""OAuth 2.1 gateway routes for the MCP / ChatGPT surface.

ChatGPT (Apps SDK) discovers these endpoints through the
``WWW-Authenticate: Bearer resource_metadata="..."`` challenge on the MCP
mount's 401s, so every URL below is derived from ``MCP_OAUTH_ISSUER``
(e.g. ``https://api.fitcheckaiapp.com/api/v1/oauth``):

- ``{issuer}/.well-known/oauth-protected-resource``   (RFC 9728 §3.1 subset)
- ``{issuer}/.well-known/oauth-authorization-server`` (RFC 8414 §3.1 subset)
- ``POST {issuer}/register``            dynamic client registration (RFC 7591)
- ``GET  {issuer}/authorize``           authorization request → Supabase login
- ``POST {issuer}/authorize/complete``  frontend bridge binds Supabase session
- ``POST {issuer}/token``               code exchange + refresh (RFC 6749 §3.2)
- ``POST {issuer}/revoke``              refresh-token revocation (RFC 7009)

All storage/validation logic lives in ``app.services.mcp_oauth_service``.
"""

from __future__ import annotations

import logging
import secrets
from typing import Any, Dict, Optional

from fastapi import APIRouter, Depends, Form, HTTPException, status
from fastapi.responses import JSONResponse, RedirectResponse
from supabase import Client

from app.core.config import settings
from app.core.exceptions import AuthenticationError, FitCheckException, ValidationError
from app.core.security import decode_supabase_token
from app.db.connection import get_db
from app.services import mcp_oauth_service as oauth_service

logger = logging.getLogger(__name__)

router = APIRouter()

SERVICE_DOCUMENTATION = "https://fitcheckaiapp.com/llms.txt"


def _require_enabled() -> None:
    if not oauth_service.is_oauth_enabled():
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="OAuth gateway disabled: MCP_OAUTH_ISSUER is not configured",
        )


def _issuer_url(path: str) -> str:
    return f"{oauth_service.issuer()}{path}"


# ---------------------------------------------------------------------------
# Discovery metadata
# ---------------------------------------------------------------------------


@router.get("/.well-known/oauth-protected-resource")
async def protected_resource_metadata() -> Dict[str, Any]:
    """RFC 9728 protected-resource metadata for the /mcp resource."""
    _require_enabled()
    base = (settings.PUBLIC_API_BASE_URL or "").rstrip("/")
    return {
        "resource": f"{base}/mcp",
        "authorization_servers": [oauth_service.issuer()],
        "scopes_supported": [oauth_service.MCP_SCOPE],
        "bearer_methods_supported": ["header"],
        "resource_documentation": SERVICE_DOCUMENTATION,
    }


@router.get("/.well-known/oauth-authorization-server")
async def authorization_server_metadata() -> Dict[str, Any]:
    """RFC 8414 authorization-server metadata (public clients, PKCE S256)."""
    _require_enabled()
    return {
        "issuer": oauth_service.issuer(),
        "authorization_endpoint": _issuer_url("/authorize"),
        "token_endpoint": _issuer_url("/token"),
        "revocation_endpoint": _issuer_url("/revoke"),
        "registration_endpoint": _issuer_url("/register"),
        "response_types_supported": ["code"],
        "grant_types_supported": ["authorization_code", "refresh_token"],
        "code_challenge_methods_supported": ["S256"],
        "token_endpoint_auth_methods_supported": ["none"],
        "scopes_supported": [oauth_service.MCP_SCOPE],
        "service_documentation": SERVICE_DOCUMENTATION,
    }


# ---------------------------------------------------------------------------
# Dynamic client registration
# ---------------------------------------------------------------------------


@router.post("/register")
async def register_client(
    body: Dict[str, Any],
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """RFC 7591 dynamic registration. Public clients only (PKCE, no secret);
    redirect URIs must match MCP_REDIRECT_URI_ALLOWLIST."""
    _require_enabled()
    redirect_uris = body.get("redirect_uris") or []
    if not isinstance(redirect_uris, list):
        raise ValidationError(message="redirect_uris must be a list", error_code="OAUTH_INVALID_REGISTRATION")
    try:
        return oauth_service.register_client(
            db,
            redirect_uris=[str(uri) for uri in redirect_uris],
            client_name=str(body.get("client_name") or "unknown"),
        )
    except FitCheckException as error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "invalid_client_metadata", "error_description": error.message},
        ) from error


# ---------------------------------------------------------------------------
# Authorization endpoint
# ---------------------------------------------------------------------------


@router.get("/authorize")
async def authorize(
    response_type: str,
    client_id: str,
    redirect_uri: str,
    code_challenge: str,
    code_challenge_method: str = "S256",
    scope: str = oauth_service.MCP_SCOPE,
    state: str = "",
    db: Client = Depends(get_db),
):
    """Validate the client's authorization request and bounce the user to the
    frontend bridge (Supabase hosted login runs there)."""
    _require_enabled()
    if response_type != "code":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "unsupported_response_type"},
        )
    try:
        oauth_service.validate_scope(scope)
    except ValidationError as error:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={
                "error": "invalid_scope",
                "error_description": error.message,
            },
        )
    txn_state = state or secrets.token_urlsafe(16)
    try:
        oauth_service.create_pending_authorization(
            db,
            client_id=client_id,
            redirect_uri=redirect_uri,
            state=txn_state,
            code_challenge=code_challenge,
            code_challenge_method=code_challenge_method,
        )
    except FitCheckException as error:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail={"error": "invalid_request", "error_description": error.message},
        ) from error

    frontend = (settings.FRONTEND_URL or "").rstrip("/")
    return RedirectResponse(f"{frontend}/oauth/bridge?state={txn_state}", status_code=302)


@router.post("/authorize/complete")
async def authorize_complete(
    body: Dict[str, Any],
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """Frontend bridge callback: bind the Supabase session to the pending
    authorization. Returns the redirect URL the browser must follow."""
    _require_enabled()
    state = str(body.get("state") or "")
    access_token = str(body.get("access_token") or "")
    if not state or not access_token:
        raise ValidationError(message="state and access_token are required", error_code="OAUTH_STATE_INVALID")
    try:
        redirect_url = oauth_service.complete_authorization(
            db,
            state=state,
            supabase_access_token=access_token,
            decode_supabase_token=decode_supabase_token,
        )
    except AuthenticationError as error:
        # The bridge shows the message; don't leak which step failed.
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail={"error": "access_denied", "error_description": error.message},
        ) from error
    return {"redirect": redirect_url}


# ---------------------------------------------------------------------------
# Token + revocation
# ---------------------------------------------------------------------------

_OAUTH_GRANT_ERROR = status.HTTP_400_BAD_REQUEST


@router.post("/token")
async def issue_token(
    grant_type: str = Form(...),
    client_id: str = Form(...),
    code: Optional[str] = Form(None),
    redirect_uri: Optional[str] = Form(None),
    code_verifier: Optional[str] = Form(None),
    refresh_token: Optional[str] = Form(None),
    db: Client = Depends(get_db),
) -> Any:
    """RFC 6749 token endpoint: authorization_code (PKCE) or refresh_token."""
    _require_enabled()
    try:
        if grant_type == "authorization_code":
            if not code or not redirect_uri or not code_verifier:
                raise ValidationError(
                    message="code, redirect_uri and code_verifier are required",
                    error_code="OAUTH_CODE_INVALID",
                )
            return oauth_service.exchange_code_for_tokens(
                db,
                code=code,
                client_id=client_id,
                redirect_uri=redirect_uri,
                code_verifier=code_verifier,
            )
        if grant_type == "refresh_token":
            if not refresh_token:
                raise ValidationError(message="refresh_token is required", error_code="OAUTH_REFRESH_INVALID")
            return oauth_service.rotate_refresh_token(db, refresh_token)
        raise ValidationError(message=f"unsupported grant_type: {grant_type}", error_code="OAUTH_GRANT_UNSUPPORTED")
    except AuthenticationError as error:
        # RFC 6749 §5.2: grant failures are 400 invalid_grant.
        return JSONResponse(
            status_code=_OAUTH_GRANT_ERROR,
            content={"error": "invalid_grant", "error_description": error.message},
        )


@router.post("/revoke")
async def revoke_token(
    token: str = Form(...),
    db: Client = Depends(get_db),
) -> Dict[str, Any]:
    """RFC 7009 revocation (idempotent; always 200 for valid requests)."""
    _require_enabled()
    oauth_service.revoke_refresh_token(db, token)
    return {}
