"""Tests for SocialOAuthService.

State signing/parsing roundtrips use a fixed AI_ENCRYPTION_KEY; all HTTP
paths go through httpx.MockTransport so nothing touches graph.facebook.com.
Time is frozen (via monkeypatched utcnow) wherever an assertion depends on
expiry arithmetic.
"""

import json
from datetime import datetime, timedelta, timezone

import httpx
import pytest

from app.core.config import settings
from app.core.exceptions import (
    SocialImportOAuthConfigError,
    SocialImportOAuthExchangeError,
    SocialImportOAuthStateError,
)
from app.models.social_import import SocialPlatform
from app.services.social_oauth_service import SocialOAuthService

FIXED_NOW = datetime(2026, 8, 7, 12, 0, 0, tzinfo=timezone.utc)
FIXED_NOW_TS = int(FIXED_NOW.timestamp())


def _patch_async_client(monkeypatch, handler):
    """Replace httpx.AsyncClient with one wired to a MockTransport handler."""
    original = httpx.AsyncClient

    def factory(*args, **kwargs):
        return original(transport=httpx.MockTransport(handler), **kwargs)

    monkeypatch.setattr(httpx, "AsyncClient", factory)


def _build_signed_state(payload: dict) -> str:
    """Craft a properly signed state from a raw payload dict."""
    encoded = SocialOAuthService._b64_url_encode(
        json.dumps(payload, separators=(",", ":")).encode("utf-8")
    )
    return f"{encoded}.{SocialOAuthService._sign_state(encoded)}"


def _valid_state_payload(**overrides) -> dict:
    payload = {
        "uid": "user-123",
        "jid": "job-456",
        "plt": SocialPlatform.INSTAGRAM.value,
        "exp": FIXED_NOW_TS + 600,
        "nonce": "nonce-1",
    }
    payload.update(overrides)
    return payload


@pytest.fixture(autouse=True)
def _state_secret(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)


# ---------------------------------------------------------------------------
# existing tests (kept from the original file)
# ---------------------------------------------------------------------------


def test_oauth_state_roundtrip(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.INSTAGRAM,
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.user_id == "user-123"
    assert parsed.job_id == "job-456"
    assert parsed.platform == SocialPlatform.INSTAGRAM


def test_oauth_state_roundtrip_with_mobile_redirect(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.INSTAGRAM,
        mobile_redirect_uri="fitcheck.ai://social-import-callback",
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.mobile_redirect_uri == "fitcheck.ai://social-import-callback"


def test_oauth_state_ignores_invalid_mobile_redirect(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
        mobile_redirect_uri="https://malicious.example/callback",
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.mobile_redirect_uri is None


def test_oauth_state_rejects_tampering(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)
    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
    )
    encoded_payload, signature = state.split(".", 1)
    tampered = f"{encoded_payload}.{signature[:-1]}x"

    with pytest.raises(SocialImportOAuthStateError):
        SocialOAuthService.parse_state(tampered)


def test_oauth_state_rejects_expired(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)
    monkeypatch.setattr(SocialOAuthService, "_STATE_TTL_SECONDS", -1, raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
    )

    with pytest.raises(SocialImportOAuthStateError):
        SocialOAuthService.parse_state(state)


# ---------------------------------------------------------------------------
# state secret / base64 helpers
# ---------------------------------------------------------------------------


class TestStateSecret:
    def test_missing_key_fails_closed(self, monkeypatch):
        monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None, raising=False)

        with pytest.raises(SocialImportOAuthConfigError, match="AI_ENCRYPTION_KEY"):
            SocialOAuthService.create_state(
                user_id="u", job_id="j", platform=SocialPlatform.INSTAGRAM,
            )

    def test_state_secret_is_purpose_derived_bytes(self):
        secret = SocialOAuthService._state_secret()

        assert isinstance(secret, bytes)
        assert len(secret) == 32


class TestBase64Helpers:
    def test_roundtrip_payload_with_padding(self):
        raw = b"a"  # 1 byte -> urlsafe encoding needs padding that must be stripped
        encoded = SocialOAuthService._b64_url_encode(raw)

        assert "=" not in encoded
        assert SocialOAuthService._b64_url_decode(encoded) == raw

    def test_roundtrip_utf8_payload(self):
        raw = json.dumps({"name": "Jalape\u00f1o"}).encode("utf-8")

        assert SocialOAuthService._b64_url_decode(SocialOAuthService._b64_url_encode(raw)) == raw


class TestSanitizeMobileRedirectUri:
    def test_rejects_empty_and_missing(self):
        assert SocialOAuthService._sanitize_mobile_redirect_uri(None) is None
        assert SocialOAuthService._sanitize_mobile_redirect_uri("") is None

    def test_rejects_non_fitcheck_schemes(self):
        assert SocialOAuthService._sanitize_mobile_redirect_uri("https://evil.example/cb") is None
        assert SocialOAuthService._sanitize_mobile_redirect_uri("javascript:alert(1)") is None

    def test_strips_fragment_and_surrounding_whitespace(self):
        sanitized = SocialOAuthService._sanitize_mobile_redirect_uri(" fitcheck.ai://cb?job=1#frag ")

        assert sanitized == "fitcheck.ai://cb?job=1"


# ---------------------------------------------------------------------------
# create_state / parse_state
# ---------------------------------------------------------------------------


class TestCreateState:
    def test_includes_opener_origin_and_mobile_redirect_in_payload(self):
        state = SocialOAuthService.create_state(
            user_id="user-123",
            job_id="job-456",
            platform=SocialPlatform.FACEBOOK,
            opener_origin="https://app.example.com",
            mobile_redirect_uri="fitcheck.ai://cb",
        )

        parsed = SocialOAuthService.parse_state(state)
        assert parsed.opener_origin == "https://app.example.com"
        assert parsed.mobile_redirect_uri == "fitcheck.ai://cb"
        assert parsed.platform == SocialPlatform.FACEBOOK


class TestParseStateErrors:
    def test_malformed_state_missing_delimiter(self):
        with pytest.raises(SocialImportOAuthStateError, match="Malformed"):
            SocialOAuthService.parse_state("no-delimiter-here")

    def test_non_json_payload_rejected(self):
        encoded = SocialOAuthService._b64_url_encode(b"not json")
        state = f"{encoded}.{SocialOAuthService._sign_state(encoded)}"

        with pytest.raises(SocialImportOAuthStateError, match="payload"):
            SocialOAuthService.parse_state(state)

    def test_missing_required_field_rejected(self):
        state = _build_signed_state({"jid": "job-456", "plt": "facebook", "exp": FIXED_NOW_TS + 600, "nonce": "n"})

        with pytest.raises(SocialImportOAuthStateError, match="payload"):
            SocialOAuthService.parse_state(state)

    def test_unknown_platform_value_rejected(self):
        state = _build_signed_state(_valid_state_payload(plt="tiktok"))

        with pytest.raises(SocialImportOAuthStateError, match="payload"):
            SocialOAuthService.parse_state(state)

    def test_expired_state_rejected(self, monkeypatch):
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)
        state = _build_signed_state(_valid_state_payload(exp=FIXED_NOW_TS - 1))

        with pytest.raises(SocialImportOAuthStateError, match="expired"):
            SocialOAuthService.parse_state(state)

    def test_non_http_opener_origin_is_cleared(self, monkeypatch):
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)
        state = _build_signed_state(_valid_state_payload(org="not-a-url"))

        parsed = SocialOAuthService.parse_state(state)

        assert parsed.opener_origin is None
        assert parsed.user_id == "user-123"


# ---------------------------------------------------------------------------
# build_authorize_url
# ---------------------------------------------------------------------------


class TestBuildAuthorizeUrl:
    def test_missing_client_id_raises(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", None, raising=False)

        with pytest.raises(SocialImportOAuthConfigError, match="META_OAUTH_CLIENT_ID"):
            SocialOAuthService.build_authorize_url(
                user_id="user-123", job_id="job-456",
                platform=SocialPlatform.INSTAGRAM, redirect_uri="https://app.example.com/cb",
            )

    def test_instagram_url_includes_scopes_and_state(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)

        result = SocialOAuthService.build_authorize_url(
            user_id="user-123", job_id="job-456",
            platform=SocialPlatform.INSTAGRAM, redirect_uri="https://app.example.com/cb",
        )

        assert result["provider"] == "meta"
        assert result["expires_in_seconds"] == SocialOAuthService._STATE_TTL_SECONDS
        assert result["auth_url"].startswith(f"{SocialOAuthService._DIALOG_URL}?")
        assert "client_id=client-1" in result["auth_url"]
        assert "redirect_uri=https%3A%2F%2Fapp.example.com%2Fcb" in result["auth_url"]
        assert "instagram_basic" in result["auth_url"]
        assert result["state"]
        parsed = SocialOAuthService.parse_state(result["state"])
        assert parsed.user_id == "user-123"
        assert parsed.job_id == "job-456"

    def test_facebook_url_uses_facebook_scopes(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)

        result = SocialOAuthService.build_authorize_url(
            user_id="user-123", job_id="job-456",
            platform=SocialPlatform.FACEBOOK, redirect_uri="https://app.example.com/cb",
        )

        assert "user_photos" in result["auth_url"]
        assert "instagram_basic" not in result["auth_url"]


# ---------------------------------------------------------------------------
# exchange_code_for_token
# ---------------------------------------------------------------------------


class TestExchangeCodeForToken:
    @pytest.mark.asyncio
    async def test_missing_client_id_or_secret_raises(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", None, raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", None, raising=False)

        with pytest.raises(SocialImportOAuthConfigError, match="META_OAUTH_CLIENT_ID"):
            await SocialOAuthService.exchange_code_for_token(code="c", redirect_uri="https://app.example.com/cb")

    @pytest.mark.asyncio
    async def test_missing_secret_alone_raises(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", None, raising=False)

        with pytest.raises(SocialImportOAuthConfigError, match="META_OAUTH_CLIENT_ID"):
            await SocialOAuthService.exchange_code_for_token(code="c", redirect_uri="https://app.example.com/cb")

    @pytest.mark.asyncio
    async def test_upgrades_to_long_lived_token(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)
        requests: list[httpx.Request] = []

        def handler(request):
            requests.append(request)
            if request.url.params.get("grant_type") == "fb_exchange_token":
                return httpx.Response(200, json={"access_token": "long-token", "expires_in": 5184000}, request=request)
            return httpx.Response(200, json={"access_token": "short-token", "expires_in": 3600}, request=request)

        _patch_async_client(monkeypatch, handler)

        result = await SocialOAuthService.exchange_code_for_token(
            code="auth-code", redirect_uri="https://app.example.com/cb",
        )

        assert result["provider_access_token"] == "long-token"
        assert result["expires_at"] == FIXED_NOW + timedelta(seconds=5184000)
        assert len(requests) == 2
        assert requests[0].url.params["code"] == "auth-code"
        assert requests[0].url.params["client_id"] == "client-1"
        assert requests[1].url.params["grant_type"] == "fb_exchange_token"

    @pytest.mark.asyncio
    async def test_keeps_short_lived_token_when_upgrade_rejected(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)

        def handler(request):
            if request.url.params.get("grant_type") == "fb_exchange_token":
                return httpx.Response(400, json={"error": {"message": "invalid token"}}, request=request)
            return httpx.Response(200, json={"access_token": "short-token", "expires_in": 3600}, request=request)

        _patch_async_client(monkeypatch, handler)

        result = await SocialOAuthService.exchange_code_for_token(
            code="auth-code", redirect_uri="https://app.example.com/cb",
        )

        assert result["provider_access_token"] == "short-token"
        assert result["expires_at"] == FIXED_NOW + timedelta(seconds=3600)

    @pytest.mark.asyncio
    async def test_keeps_short_lived_token_when_upgrade_raises(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)

        async def handler(request):
            if request.url.params.get("grant_type") == "fb_exchange_token":
                raise httpx.ConnectError("graph down", request=request)
            return httpx.Response(200, json={"access_token": "short-token", "expires_in": 3600}, request=request)

        _patch_async_client(monkeypatch, handler)

        result = await SocialOAuthService.exchange_code_for_token(
            code="auth-code", redirect_uri="https://app.example.com/cb",
        )

        assert result["provider_access_token"] == "short-token"
        assert result["expires_at"] == FIXED_NOW + timedelta(seconds=3600)

    @pytest.mark.asyncio
    async def test_upgrade_response_without_token_keeps_short_lived(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)
        monkeypatch.setattr("app.services.social_oauth_service.utcnow", lambda: FIXED_NOW)

        def handler(request):
            if request.url.params.get("grant_type") == "fb_exchange_token":
                return httpx.Response(200, json={"expires_in": 999}, request=request)
            return httpx.Response(200, json={"access_token": "short-token", "expires_in": 3600}, request=request)

        _patch_async_client(monkeypatch, handler)

        result = await SocialOAuthService.exchange_code_for_token(
            code="auth-code", redirect_uri="https://app.example.com/cb",
        )

        assert result["provider_access_token"] == "short-token"
        assert result["expires_at"] == FIXED_NOW + timedelta(seconds=3600)

    @pytest.mark.asyncio
    async def test_response_without_expires_in_has_no_expiry(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)

        def handler(request):
            return httpx.Response(200, json={"access_token": "tok"}, request=request)

        _patch_async_client(monkeypatch, handler)

        result = await SocialOAuthService.exchange_code_for_token(
            code="auth-code", redirect_uri="https://app.example.com/cb",
        )

        assert result["provider_access_token"] == "tok"
        assert result["expires_at"] is None

    @pytest.mark.asyncio
    async def test_response_without_access_token_raises(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)

        def handler(request):
            return httpx.Response(200, json={"foo": "bar"}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(SocialImportOAuthExchangeError, match="did not include access token"):
            await SocialOAuthService.exchange_code_for_token(code="c", redirect_uri="https://app.example.com/cb")

    @pytest.mark.asyncio
    async def test_graph_error_message_surfaces(self, monkeypatch):
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_ID", "client-1", raising=False)
        monkeypatch.setattr(settings, "META_OAUTH_CLIENT_SECRET", "secret-1", raising=False)

        def handler(request):
            return httpx.Response(400, json={"error": {"message": "Invalid verification code format."}}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(SocialImportOAuthExchangeError, match="Invalid verification code"):
            await SocialOAuthService.exchange_code_for_token(code="bad", redirect_uri="https://app.example.com/cb")


# ---------------------------------------------------------------------------
# identity resolution
# ---------------------------------------------------------------------------


class TestResolvePlatformIdentity:
    @pytest.mark.asyncio
    async def test_facebook_identity(self, monkeypatch):
        def handler(request):
            assert request.url.path.endswith("/me")
            return httpx.Response(200, json={"id": "fb-user-1", "name": "Jane Doe"}, request=request)

        _patch_async_client(monkeypatch, handler)

        identity = await SocialOAuthService.resolve_platform_identity(
            platform=SocialPlatform.FACEBOOK, access_token="tok",
        )

        assert identity == {"provider_user_id": "fb-user-1", "provider_username": "Jane Doe"}

    @pytest.mark.asyncio
    async def test_instagram_identity_from_connected_page(self, monkeypatch):
        def handler(request):
            assert request.url.path.endswith("/me/accounts")
            return httpx.Response(200, json={"data": [{
                "id": "page-1",
                "name": "My Page",
                "access_token": "page-tok",
                "instagram_business_account": {"id": "ig-1", "username": "my.handle"},
            }]}, request=request)

        _patch_async_client(monkeypatch, handler)

        identity = await SocialOAuthService.resolve_platform_identity(
            platform=SocialPlatform.INSTAGRAM, access_token="tok",
        )

        assert identity == {
            "provider_user_id": "ig-1",
            "provider_username": "my.handle",
            "provider_page_access_token": "page-tok",
            "provider_page_id": "page-1",
        }

    @pytest.mark.asyncio
    async def test_instagram_page_without_business_account_skipped(self, monkeypatch):
        def handler(request):
            return httpx.Response(200, json={"data": [
                {"id": "page-1", "name": "No IG"},
                {"id": "page-2", "instagram_business_account": {"id": "ig-2", "username": "found"}},
            ]}, request=request)

        _patch_async_client(monkeypatch, handler)

        identity = await SocialOAuthService.resolve_platform_identity(
            platform=SocialPlatform.INSTAGRAM, access_token="tok",
        )

        assert identity["provider_user_id"] == "ig-2"

    @pytest.mark.asyncio
    async def test_instagram_without_business_account_raises(self, monkeypatch):
        def handler(request):
            return httpx.Response(200, json={"data": [{"id": "page-1", "name": "My Page"}]}, request=request)

        _patch_async_client(monkeypatch, handler)

        with pytest.raises(SocialImportOAuthExchangeError, match="No connected Instagram"):
            await SocialOAuthService.resolve_platform_identity(
                platform=SocialPlatform.INSTAGRAM, access_token="tok",
            )


class TestParseGraphResponse:
    def test_success_returns_payload(self):
        response = httpx.Response(200, json={"id": "1"})

        assert SocialOAuthService._parse_graph_response(response, "default") == {"id": "1"}

    def test_success_with_invalid_json_returns_empty_dict(self):
        response = httpx.Response(200, text="not json")

        assert SocialOAuthService._parse_graph_response(response, "default") == {}

    def test_4xx_with_graph_message_uses_it(self):
        response = httpx.Response(401, json={"error": {"message": "bad token"}})

        with pytest.raises(SocialImportOAuthExchangeError, match="bad token"):
            SocialOAuthService._parse_graph_response(response, "default message")

    def test_4xx_without_graph_message_uses_default(self):
        response = httpx.Response(403, json={})

        with pytest.raises(SocialImportOAuthExchangeError, match="default message"):
            SocialOAuthService._parse_graph_response(response, "default message")

    def test_other_status_uses_default_even_with_graph_error(self):
        response = httpx.Response(500, json={"error": {"message": "boom"}})

        with pytest.raises(SocialImportOAuthExchangeError, match="default message"):
            SocialOAuthService._parse_graph_response(response, "default message")

    def test_error_status_with_non_dict_payload_uses_default(self):
        response = httpx.Response(400, json=["not", "a", "dict"])

        with pytest.raises(SocialImportOAuthExchangeError, match="default message"):
            SocialOAuthService._parse_graph_response(response, "default message")
