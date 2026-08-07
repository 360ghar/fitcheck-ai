"""Coverage-completing tests for SocialScraperService.

Sibling to the integration-level social import tests: this file exercises the
statements the routes never reach — the pinned-address httpcore backends, the
Instagram web login flow (including every error branch and 2FA completion),
all response-parsing shapes, the Meta Graph API discovery paths, the offset
cursor pagination semantics of discover_profile_photos, and the SSRF-safe
image downloader in fetch_photo_as_base64. Everything runs against canned
httpx.Response objects with httpx.AsyncClient patched out — no sockets.
"""

import base64
import socket
from datetime import datetime, timezone
from unittest.mock import AsyncMock, Mock, patch

import httpx
import pytest

from app.core.exceptions import SocialImportError
from app.models.social_import import DiscoverPhotosResult, ScrapedPhotoRef, SocialPlatform
from app.services.social_scraper_service import (
    InstagramLoginResult,
    SocialScraperService,
    _PinnedAddressHTTPTransport,
    _PinnedAddressNetworkBackend,
)


# =============================================================================
# Test doubles
# =============================================================================


class _FakeStream:
    """Async context manager returned by the fake client's ``stream`` method."""

    def __init__(self, response):
        self._response = response

    async def __aenter__(self):
        return self._response

    async def __aexit__(self, *args):
        return False


def _fake_client(get=None, post=None, stream=None, get_exc=None, post_exc=None):
    """Fake httpx.AsyncClient: async context manager with canned responses."""
    client = AsyncMock()
    client.headers = {}
    if get_exc is not None:
        client.get = AsyncMock(side_effect=get_exc)
    else:
        client.get = AsyncMock(return_value=get)
    if post_exc is not None:
        client.post = AsyncMock(side_effect=post_exc)
    else:
        client.post = AsyncMock(return_value=post)
    # httpx's stream() returns an async context manager directly (not a coroutine).
    client.stream = Mock(return_value=_FakeStream(stream))
    client.__aenter__.return_value = client
    client.__aexit__.return_value = None
    return client


def _patch_client(client):
    return patch("app.services.social_scraper_service.httpx.AsyncClient", return_value=client)


def _response(
    status=200,
    json=None,
    text=None,
    content=None,
    headers=None,
    url="https://www.instagram.com/x",
):
    request = httpx.Request("GET", url)
    return httpx.Response(
        status,
        json=json,
        text=text,
        content=content,
        headers=headers,
        request=request,
    )


def _addrinfo(ip):
    """One getaddrinfo-style tuple whose sockaddr carries ``ip`` on port 443."""
    return (socket.AF_INET, socket.SOCK_STREAM, 6, "", (ip, 443))


def _patch_resolver(*ips):
    return patch("socket.getaddrinfo", return_value=[_addrinfo(ip) for ip in ips])


# =============================================================================
# _PinnedAddressNetworkBackend / _PinnedAddressHTTPTransport
# =============================================================================


@pytest.mark.asyncio
async def test_pinned_network_backend_connect_tcp_substitutes_pinned_address():
    backend = _PinnedAddressNetworkBackend("example.com", "93.184.216.34")
    backend._delegate = AsyncMock()

    await backend.connect_tcp(
        "example.com",
        443,
        timeout=5.0,
        local_address="127.0.0.1",
        socket_options=[(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)],
    )
    await backend.connect_tcp("other.example.com", 80)

    calls = backend._delegate.connect_tcp.await_args_list
    assert calls[0].args == ("93.184.216.34", 443)
    assert calls[0].kwargs == {
        "timeout": 5.0,
        "local_address": "127.0.0.1",
        "socket_options": [(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)],
    }
    # Hosts that do not match the pinned hostname pass through unchanged.
    assert calls[1].args == ("other.example.com", 80)
    assert calls[1].kwargs == {"timeout": None, "local_address": None, "socket_options": None}


@pytest.mark.asyncio
async def test_pinned_network_backend_delegates_unix_socket_and_sleep():
    backend = _PinnedAddressNetworkBackend("example.com", "93.184.216.34")
    backend._delegate = AsyncMock()

    await backend.connect_unix_socket("/tmp/test.sock", timeout=1.0, socket_options=None)
    backend._delegate.connect_unix_socket.assert_awaited_once_with(
        "/tmp/test.sock", timeout=1.0, socket_options=None
    )

    await backend.sleep(0.25)
    backend._delegate.sleep.assert_awaited_once_with(0.25)


def test_pinned_http_transport_rebuilds_pool_with_pinned_backend():
    transport = _PinnedAddressHTTPTransport("example.com", "93.184.216.34")
    backend = transport._pool._network_backend
    assert isinstance(backend, _PinnedAddressNetworkBackend)
    assert backend._hostname == "example.com"
    assert backend._address == "93.184.216.34"


# =============================================================================
# _resolve_remote_image_endpoint
# =============================================================================


@pytest.mark.asyncio
async def test_resolve_remote_image_endpoint_rejects_bad_scheme_and_missing_host():
    with pytest.raises(SocialImportError, match="must use HTTP or HTTPS"):
        await SocialScraperService._resolve_remote_image_endpoint("ftp://example.com/a.jpg")
    with pytest.raises(SocialImportError, match="must use HTTP or HTTPS"):
        await SocialScraperService._resolve_remote_image_endpoint("not-a-url")


@pytest.mark.asyncio
async def test_resolve_remote_image_endpoint_rejects_credentials():
    with pytest.raises(SocialImportError, match="cannot contain credentials"):
        await SocialScraperService._resolve_remote_image_endpoint(
            "https://user:pass@example.com/a.jpg"
        )


@pytest.mark.asyncio
async def test_resolve_remote_image_endpoint_resolution_failures():
    with patch("socket.getaddrinfo", side_effect=OSError("no dns")):
        with pytest.raises(SocialImportError, match="could not be resolved"):
            await SocialScraperService._resolve_remote_image_endpoint(
                "https://example.com/a.jpg"
            )
    with patch("socket.getaddrinfo", side_effect=ValueError("bad port")):
        with pytest.raises(SocialImportError, match="could not be resolved"):
            await SocialScraperService._resolve_remote_image_endpoint(
                "https://example.com/a.jpg"
            )
    with patch("socket.getaddrinfo", return_value=[]):
        with pytest.raises(SocialImportError, match="could not be resolved"):
            await SocialScraperService._resolve_remote_image_endpoint(
                "https://example.com/a.jpg"
            )


@pytest.mark.asyncio
async def test_resolve_remote_image_endpoint_rejects_private_ip():
    with _patch_resolver("10.0.0.5"):
        with pytest.raises(SocialImportError, match="private or blocked"):
            await SocialScraperService._resolve_remote_image_endpoint(
                "https://example.com/a.jpg"
            )


@pytest.mark.asyncio
async def test_resolve_remote_image_endpoint_returns_hostname_and_ip():
    with patch("socket.getaddrinfo", return_value=[_addrinfo("93.184.216.34")]) as gai:
        hostname, ip = await SocialScraperService._resolve_remote_image_endpoint(
            "https://example.com/a.jpg"
        )
    assert (hostname, ip) == ("example.com", "93.184.216.34")
    assert gai.call_args_list[0].args == ("example.com", 443)

    with patch("socket.getaddrinfo", return_value=[_addrinfo("93.184.216.35")]) as gai:
        hostname, ip = await SocialScraperService._resolve_remote_image_endpoint(
            "http://example.com:8080/a.jpg"
        )
    assert (hostname, ip) == ("example.com", "93.184.216.35")
    assert gai.call_args_list[0].args == ("example.com", 8080)


# =============================================================================
# _instagram_login
# =============================================================================


@pytest.mark.asyncio
async def test_instagram_login_missing_csrf_token():
    client = _fake_client(get=_response(200, text="<html>no token</html>"))
    with _patch_client(client):
        result = await SocialScraperService._instagram_login("user1", "pass1")

    assert result.success is False
    assert result.error_message == "Failed to get CSRF token from Instagram"


@pytest.mark.asyncio
async def test_instagram_login_success_with_session_cookies():
    login_page = _response(200, text="<html>login</html>")
    login_page.cookies.set("csrftoken", "csrf-token")
    login_resp = _response(200, json={"authenticated": True, "user": True})
    login_resp.cookies.set("sessionid", "sess1")
    login_resp.cookies.set("ds_user_id", "42")

    client = _fake_client(get=login_page, post=login_resp)
    with _patch_client(client):
        result = await SocialScraperService._instagram_login("user1", "pass1")

    assert result.success is True
    assert result.sessionid == "sess1"
    assert result.csrftoken == "csrf-token"
    assert result.ds_user_id == "42"
    assert client.headers["X-CSRFToken"] == "csrf-token"
    assert client.headers["X-IG-App-ID"] == SocialScraperService._INSTAGRAM_APP_ID
    assert client.headers["Referer"] == SocialScraperService._INSTAGRAM_LOGIN_URL


@pytest.mark.asyncio
async def test_instagram_login_completes_two_factor():
    login_page = _response(200, text="<html>login</html>")
    login_page.cookies.set("csrftoken", "csrf-token")
    tf_resp = _response(
        200,
        json={
            "two_factor_required": True,
            "two_factor_info": {"two_factor_identifier": "ident123"},
        },
    )

    client = _fake_client(get=login_page, post=tf_resp)
    with _patch_client(client):
        result = await SocialScraperService._instagram_login(
            "user1", "pass1", otp_code="123456", two_factor_identifier="ident123"
        )

    assert result.success is False
    assert result.requires_otp is True
    assert result.otp_identifier == "ident123"
    assert result.error_message == "Two-factor authentication required"
    # The 2FA completion posts to the two-factor endpoint.
    assert client.post.await_args.args[0].startswith(
        "https://www.instagram.com/api/v1/accounts/two_factor_authentication/"
    )


@pytest.mark.asyncio
async def test_instagram_login_network_error():
    client = _fake_client(get_exc=httpx.ConnectError("boom", request=httpx.Request("GET", "https://x")))
    with _patch_client(client):
        result = await SocialScraperService._instagram_login("user1", "pass1")

    assert result.success is False
    assert result.error_message == "Network error: boom"


@pytest.mark.asyncio
async def test_instagram_login_unexpected_error():
    client = _fake_client(get_exc=ValueError("boom"))
    with _patch_client(client):
        result = await SocialScraperService._instagram_login("user1", "pass1")

    assert result.success is False
    assert result.error_message == "Login failed: boom"


# =============================================================================
# _extract_csrftoken / _encrypt_password
# =============================================================================


def test_extract_csrftoken_from_cookie():
    resp = _response(200, json={})
    resp.cookies.set("csrftoken", "token-from-cookie")
    assert SocialScraperService._extract_csrftoken(resp) == "token-from-cookie"


def test_extract_csrftoken_from_set_cookie_header():
    resp = _response(200, json={}, headers={"set-cookie": "csrftoken=token-from-header; Path=/; HttpOnly"})
    # httpx auto-populates the cookie jar from the Set-Cookie header; clear it
    # so the header-regex branch is what is exercised.
    resp.cookies.clear()
    assert SocialScraperService._extract_csrftoken(resp) == "token-from-header"


def test_extract_csrftoken_missing_returns_none():
    resp = _response(200, json={}, headers={"x-whatever": "1"})
    assert SocialScraperService._extract_csrftoken(resp) is None


def test_encrypt_password_uses_legacy_format():
    with patch("app.services.social_scraper_service.time.time", return_value=1234567890):
        encoded = SocialScraperService._encrypt_password("password")
    assert encoded == "#PWD_INSTAGRAM_BROWSER:0:1234567890:cGFzc3dvcmQ="


# =============================================================================
# _parse_login_response
# =============================================================================


def test_parse_login_response_invalid_json():
    result = SocialScraperService._parse_login_response(
        _response(200, text="<html>not json</html>"), "csrf"
    )
    assert result.success is False
    assert result.error_message == "Invalid response from Instagram"


def test_parse_login_response_success():
    resp = _response(200, json={"authenticated": True})
    resp.cookies.set("sessionid", "sess1")
    resp.cookies.set("ds_user_id", "99")
    result = SocialScraperService._parse_login_response(resp, "csrf-token")
    assert result.success is True
    assert result.sessionid == "sess1"
    assert result.ds_user_id == "99"
    assert result.csrftoken == "csrf-token"


def test_parse_login_response_authenticated_without_sessionid_falls_through():
    result = SocialScraperService._parse_login_response(
        _response(200, json={"authenticated": True}), "csrf"
    )
    assert result.success is False
    assert result.error_message == "Login failed"


def test_parse_login_response_two_factor():
    resp = _response(
        200,
        json={
            "two_factor_required": True,
            "two_factor_info": {"two_factor_identifier": "tf-id-1"},
        },
    )
    result = SocialScraperService._parse_login_response(resp, "csrf")
    assert result.requires_otp is True
    assert result.otp_identifier == "tf-id-1"
    assert result.error_message == "Two-factor authentication required"


def test_parse_login_response_checkpoint():
    resp = _response(200, json={"checkpoint_url": "https://instagram.com/challenge/abc"})
    result = SocialScraperService._parse_login_response(resp, "csrf")
    assert result.success is False
    assert result.checkpoint_url == "https://instagram.com/challenge/abc"


def test_parse_login_response_incorrect_password():
    resp = _response(200, json={"user": True, "authenticated": False})
    result = SocialScraperService._parse_login_response(resp, "csrf")
    assert result.success is False
    assert result.error_message == "Incorrect password"


def test_parse_login_response_username_not_found():
    resp = _response(200, json={"user": False})
    result = SocialScraperService._parse_login_response(resp, "csrf")
    assert result.success is False
    assert result.error_message == "Username not found"


def test_parse_login_response_generic_message():
    resp = _response(200, json={"message": "rate limit hit"})
    result = SocialScraperService._parse_login_response(resp, "csrf")
    assert result.success is False
    assert result.error_message == "rate limit hit"


def test_parse_login_response_generic_default_message():
    result = SocialScraperService._parse_login_response(_response(200, json={}), "csrf")
    assert result.success is False
    assert result.error_message == "Login failed"


# =============================================================================
# _discover_with_instagram_scraper
# =============================================================================


def _scraper_session(**payload):
    return {"session_payload": payload}


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_invalid_session():
    missing_sessionid = await SocialScraperService._discover_with_instagram_scraper(
        normalized_url="https://www.instagram.com/user1/",
        auth_session=_scraper_session(csrftoken="c"),
        cursor=None,
        page_size=10,
    )
    missing_csrftoken = await SocialScraperService._discover_with_instagram_scraper(
        normalized_url="https://www.instagram.com/user1/",
        auth_session=_scraper_session(sessionid="s"),
        cursor=None,
        page_size=10,
    )
    for result in (missing_sessionid, missing_csrftoken):
        assert result.requires_auth is True
        assert result.exhausted is True
        assert result.metadata == {"reason": "invalid_session"}


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_invalid_url():
    result = await SocialScraperService._discover_with_instagram_scraper(
        normalized_url="https://example.com/not-instagram",
        auth_session=_scraper_session(sessionid="s", csrftoken="c"),
        cursor=None,
        page_size=10,
    )
    assert result.requires_auth is False
    assert result.exhausted is True
    assert result.metadata == {"reason": "invalid_url"}


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_fetches_user_id_from_profile():
    feed_result = DiscoverPhotosResult(
        requires_auth=False,
        photos=[ScrapedPhotoRef(source_photo_url="https://cdn.example.com/a.jpg")],
        next_cursor=None,
        exhausted=True,
    )
    with (
        patch.object(
            SocialScraperService,
            "_get_user_id_from_profile",
            new=AsyncMock(return_value="111"),
        ) as get_user_id,
        patch.object(
            SocialScraperService,
            "_fetch_instagram_feed",
            new=AsyncMock(return_value=feed_result),
        ) as fetch_feed,
    ):
        payload = {"sessionid": "s", "csrftoken": "c"}
        result = await SocialScraperService._discover_with_instagram_scraper(
            normalized_url="https://www.instagram.com/user1/",
            auth_session={"session_payload": payload},
            cursor="cur",
            page_size=10,
        )

    get_user_id.assert_awaited_once_with("user1", "s", "c")
    assert payload["ds_user_id"] == "111"
    fetch_feed.assert_awaited_once_with(
        ds_user_id="111", sessionid="s", csrftoken="c", cursor="cur", page_size=10
    )
    assert result is feed_result


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_user_id_not_found():
    with patch.object(
        SocialScraperService,
        "_get_user_id_from_profile",
        new=AsyncMock(return_value=None),
    ):
        result = await SocialScraperService._discover_with_instagram_scraper(
            normalized_url="https://www.instagram.com/user1/",
            auth_session=_scraper_session(sessionid="s", csrftoken="c"),
            cursor=None,
            page_size=10,
        )

    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"reason": "user_id_not_found"}


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_exception_after_username():
    with patch.object(
        SocialScraperService,
        "_fetch_instagram_feed",
        new=AsyncMock(side_effect=RuntimeError("boom")),
    ):
        result = await SocialScraperService._discover_with_instagram_scraper(
            normalized_url="https://www.instagram.com/user1/",
            auth_session=_scraper_session(sessionid="s", csrftoken="c", ds_user_id="1"),
            cursor=None,
            page_size=10,
        )

    assert result.requires_auth is False
    assert result.exhausted is False
    assert result.metadata == {"error_type": "discovery_failure", "message": "boom"}


@pytest.mark.asyncio
async def test_discover_with_instagram_scraper_exception_before_username():
    with patch.object(
        SocialScraperService,
        "_extract_username_from_url",
        new=Mock(side_effect=RuntimeError("boom")),
    ):
        result = await SocialScraperService._discover_with_instagram_scraper(
            normalized_url="https://www.instagram.com/user1/",
            auth_session=_scraper_session(sessionid="s", csrftoken="c"),
            cursor=None,
            page_size=10,
        )

    assert result.metadata == {"error_type": "discovery_failure", "message": "boom"}


# =============================================================================
# _extract_username_from_url
# =============================================================================


def test_extract_username_from_url_basic():
    assert SocialScraperService._extract_username_from_url(
        "https://www.instagram.com/some.user_1/"
    ) == "some.user_1"
    assert SocialScraperService._extract_username_from_url(
        "https://www.INSTAGRAM.com/User2"
    ) == "User2"


def test_extract_username_from_url_blacklist_and_no_match():
    assert SocialScraperService._extract_username_from_url(
        "https://www.instagram.com/accounts/login/"
    ) is None
    assert SocialScraperService._extract_username_from_url(
        "https://www.instagram.com/"
    ) is None
    assert SocialScraperService._extract_username_from_url(
        "https://example.com/user"
    ) is None


# =============================================================================
# _get_user_id_from_profile
# =============================================================================


@pytest.mark.asyncio
async def test_get_user_id_from_profile_all_patterns_and_none():
    responses = [
        _response(200, text='{"profile_id":"11111"}', url="https://www.instagram.com/u1/"),
        _response(200, text='"user_id":"22222"', url="https://www.instagram.com/u1/"),
        _response(
            200,
            text='{"id":"33333","username":"u1"}',
            url="https://www.instagram.com/u1/",
        ),
        _response(200, text="<html>no ids</html>", url="https://www.instagram.com/u1/"),
    ]
    client = _fake_client(get=None)
    client.get = AsyncMock(side_effect=responses)
    with _patch_client(client):
        results = [
            await SocialScraperService._get_user_id_from_profile("u1", "s", "c")
            for _ in responses
        ]
    assert results == ["11111", "22222", "33333", None]


@pytest.mark.asyncio
async def test_get_user_id_from_profile_exception_returns_none():
    client = _fake_client(get_exc=httpx.ConnectError("boom", request=httpx.Request("GET", "https://x")))
    with _patch_client(client):
        result = await SocialScraperService._get_user_id_from_profile("u1", "s", "c")
    assert result is None


# =============================================================================
# _fetch_instagram_feed
# =============================================================================


@pytest.mark.asyncio
async def test_fetch_instagram_feed_success_with_cursor():
    feed_json = {
        "items": [
            {
                "id": "p1",
                "image_versions2": {
                    "candidates": [
                        {"width": 640, "height": 640, "url": "https://cdn.example.com/a.jpg"}
                    ]
                },
                "taken_at": 1700000000,
                "code": "ABC",
                "media_type": 1,
            }
        ],
        "more_available": True,
        "next_max_id": "nxt",
    }
    client = _fake_client(get=_response(200, json=feed_json))
    with _patch_client(client):
        result = await SocialScraperService._fetch_instagram_feed(
            ds_user_id="99", sessionid="s", csrftoken="c", cursor="cur1", page_size=10
        )

    assert result.requires_auth is False
    assert result.next_cursor == "nxt"
    assert result.exhausted is False
    assert len(result.photos) == 1
    photo = result.photos[0]
    assert photo.source_photo_id == "p1"
    assert photo.source_photo_url == "https://cdn.example.com/a.jpg"
    assert photo.source_taken_at == datetime(2023, 11, 14, 22, 13, 20, tzinfo=timezone.utc)
    assert photo.metadata["code"] == "ABC"
    called_url = client.get.await_args.args[0]
    assert "count=10" in called_url
    assert "max_id=cur1" in called_url


@pytest.mark.asyncio
async def test_fetch_instagram_feed_401_session_expired():
    client = _fake_client(get=_response(401, json={}))
    with _patch_client(client):
        result = await SocialScraperService._fetch_instagram_feed(
            ds_user_id="99", sessionid="s", csrftoken="c", cursor=None, page_size=10
        )
    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"reason": "session_expired"}


@pytest.mark.asyncio
async def test_fetch_instagram_feed_403_auth_error():
    client = _fake_client(get=_response(403, json={}))
    with _patch_client(client):
        result = await SocialScraperService._fetch_instagram_feed(
            ds_user_id="99", sessionid="s", csrftoken="c", cursor=None, page_size=10
        )
    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"reason": "auth_error", "status": 403}


@pytest.mark.asyncio
async def test_fetch_instagram_feed_500_fetch_failure():
    client = _fake_client(get=_response(500, json={}))
    with _patch_client(client):
        result = await SocialScraperService._fetch_instagram_feed(
            ds_user_id="99", sessionid="s", csrftoken="c", cursor=None, page_size=10
        )
    assert result.requires_auth is False
    assert result.exhausted is False
    assert result.metadata["error_type"] == "fetch_failure"


@pytest.mark.asyncio
async def test_fetch_instagram_feed_unexpected_exception():
    client = _fake_client(get_exc=ValueError("boom"))
    with _patch_client(client):
        result = await SocialScraperService._fetch_instagram_feed(
            ds_user_id="99", sessionid="s", csrftoken="c", cursor=None, page_size=10
        )
    assert result.requires_auth is False
    assert result.exhausted is False
    assert result.metadata == {"error_type": "fetch_failure", "message": "boom"}


# =============================================================================
# _parse_instagram_feed / _extract_image_url_from_item / _timestamp_to_iso
# =============================================================================


def test_parse_instagram_feed_skips_non_dict_and_url_less_items():
    data = {
        "items": [
            "not-a-dict",
            {"id": "no-image"},
            {
                "id": "ok1",
                "image_versions2": {
                    "candidates": [
                        {"width": 640, "height": 640, "url": "https://cdn.example.com/ok.jpg"}
                    ]
                },
                "taken_at": 1700000000,
                "code": "CODE",
                "media_type": 1,
            },
        ],
        "more_available": False,
    }
    result = SocialScraperService._parse_instagram_feed(data, "99")
    assert len(result.photos) == 1
    assert result.photos[0].source_photo_id == "ok1"
    assert result.photos[0].source_taken_at == datetime(2023, 11, 14, 22, 13, 20, tzinfo=timezone.utc)
    assert result.photos[0].metadata["platform"] == "instagram"
    assert result.next_cursor is None
    assert result.exhausted is True


def test_parse_instagram_feed_more_available_sets_cursor():
    data = {
        "items": [
            {
                "id": "p1",
                "image_versions2": {
                    "candidates": [
                        {"width": 10, "height": 10, "url": "https://cdn.example.com/x.jpg"}
                    ]
                },
            }
        ],
        "more_available": True,
        "next_max_id": "nxt-1",
    }
    result = SocialScraperService._parse_instagram_feed(data, "99")
    assert result.next_cursor == "nxt-1"
    assert result.exhausted is False
    assert result.metadata == {"total_returned": 1, "has_more": True}


def test_extract_image_url_from_item_image_versions_picks_largest():
    item = {
        "image_versions2": {
            "candidates": [
                {"width": 100, "height": 100, "url": "https://cdn.example.com/small.jpg"},
                {"width": 640, "height": 640, "url": "https://cdn.example.com/large.jpg"},
            ]
        }
    }
    assert SocialScraperService._extract_image_url_from_item(item) == (
        "https://cdn.example.com/large.jpg"
    )


def test_extract_image_url_from_item_carousel_fallback():
    item = {
        "carousel_media": [
            {
                "image_versions2": {
                    "candidates": [
                        {"width": 320, "height": 320, "url": "https://cdn.example.com/car.jpg"}
                    ]
                }
            }
        ]
    }
    assert SocialScraperService._extract_image_url_from_item(item) == (
        "https://cdn.example.com/car.jpg"
    )


def test_extract_image_url_from_item_thumbnail_fallback():
    assert SocialScraperService._extract_image_url_from_item(
        {"thumbnail_url": "https://cdn.example.com/thumb.jpg"}
    ) == "https://cdn.example.com/thumb.jpg"
    # Empty candidates in a carousel also falls back to the thumbnail.
    assert SocialScraperService._extract_image_url_from_item(
        {"carousel_media": [{"image_versions2": {"candidates": []}}],
         "thumbnail_url": "https://cdn.example.com/thumb2.jpg"}
    ) == "https://cdn.example.com/thumb2.jpg"


def test_timestamp_to_iso_none_and_valid():
    assert SocialScraperService._timestamp_to_iso(None) is None
    assert SocialScraperService._timestamp_to_iso(0) is None
    assert SocialScraperService._timestamp_to_iso(1700000000) == "2023-11-14T22:13:20+00:00"


# =============================================================================
# _decode_url / _extract_image_urls / _is_private_or_blocked / _build_headers
# =============================================================================


def test_decode_url_unescapes_slashes_and_html():
    assert SocialScraperService._decode_url(r"https:\/\/example.com\/a.jpg") == (
        "https://example.com/a.jpg"
    )
    assert SocialScraperService._decode_url("https://example.com/a.jpg?x=1&amp;y=2") == (
        "https://example.com/a.jpg?x=1&y=2"
    )


def test_extract_image_urls_all_patterns_and_dedup():
    html = (
        '<script>{"display_url":"https:\\/\\/example.com\\/a.jpg"}</script>'
        '"image" : { "uri" : "https:\\/\\/example.com\\/b.jpg" }'
        '<script>"src" : "https:\\/\\/example.com\\/c.jpg?w=200"</script>'
        '<meta property="og:image" content="https://example.com/og.jpg">'
        '<meta property="og:image" content="ftp://example.com/skip.jpg">'
        '"src":"https:\\/\\/example.com\\/profile_pic.jpg"'
        '"display_url":"https:\\/\\/example.com\\/a.jpg"'
    )
    urls = SocialScraperService._extract_image_urls(html)
    assert urls == [
        "https://example.com/a.jpg",
        "https://example.com/b.jpg",
        "https://example.com/c.jpg?w=200",
        "https://example.com/og.jpg",
    ]


def test_is_private_or_blocked_detects_markers():
    assert SocialScraperService._is_private_or_blocked("This account is private") is True
    assert SocialScraperService._is_private_or_blocked("You must log in to view") is True
    assert SocialScraperService._is_private_or_blocked("a public profile") is False


def test_build_headers_with_session_payload():
    headers = SocialScraperService._build_headers(
        {
            "session_payload": {
                "cookie_header": "sessionid=s1; csrftoken=c1",
                "provider_access_token": "tok123",
            }
        }
    )
    assert headers["Cookie"] == "sessionid=s1; csrftoken=c1"
    assert headers["Authorization"] == "Bearer tok123"
    assert headers["User-Agent"].startswith("Mozilla/5.0")


def test_build_headers_without_auth():
    headers = SocialScraperService._build_headers(None)
    assert "Cookie" not in headers
    assert "Authorization" not in headers


# =============================================================================
# Facebook URL extraction
# =============================================================================


def test_extract_facebook_attachment_urls_recursive():
    node = {
        "media": {"image": {"src": "https://fb.com/img1.jpg"}},
        "subattachments": {
            "data": [
                {"media": {"image": {"src": "https://fb.com/img2.jpg"}}},
                {"media": {"image": {"src": "ftp://bad"}}},
                {"media": {"image": 42}},
                {"media": "not-a-dict"},
                "not-a-dict",
                {
                    "media": "not-a-dict",
                    "subattachments": {
                        "data": [{"media": {"image": {"src": "https://fb.com/img3.jpg"}}}]
                    },
                },
                {"subattachments": {"data": "not-a-list"}},
            ]
        },
    }
    urls = []
    SocialScraperService._extract_facebook_attachment_urls(node, urls)
    assert urls == [
        "https://fb.com/img1.jpg",
        "https://fb.com/img2.jpg",
        "https://fb.com/img3.jpg",
    ]
    # A node with no media/subattachments is a no-op.
    SocialScraperService._extract_facebook_attachment_urls({"other": 1}, urls)
    assert len(urls) == 3


def test_extract_facebook_post_urls_full_picture_attachments_and_dedup():
    post = {
        "full_picture": "https://fb.com/full.jpg",
        "attachments": {
            "data": [
                {"media": {"image": {"src": "https://fb.com/att.jpg"}}},
                "not-a-dict",
                {"media": {"image": {"src": "https://fb.com/full.jpg"}}},
            ]
        },
    }
    urls = SocialScraperService._extract_facebook_post_urls(post)
    assert urls == ["https://fb.com/full.jpg", "https://fb.com/att.jpg"]


def test_extract_facebook_post_urls_non_list_attachments():
    assert SocialScraperService._extract_facebook_post_urls(
        {"full_picture": "not-an-url", "attachments": {"data": "not-a-list"}}
    ) == []


def test_extract_facebook_post_urls_empty():
    assert SocialScraperService._extract_facebook_post_urls({"id": "p1"}) == []


# =============================================================================
# _discover_with_meta_api
# =============================================================================


@pytest.mark.asyncio
async def test_discover_with_meta_api_invalid_payload_and_token():
    assert await SocialScraperService._discover_with_meta_api(
        platform=SocialPlatform.INSTAGRAM,
        auth_session={"session_payload": "not-a-dict"},
        cursor=None,
        page_size=10,
    ) is None
    assert await SocialScraperService._discover_with_meta_api(
        platform=SocialPlatform.INSTAGRAM,
        auth_session={"session_payload": {"provider_user_id": "1"}},
        cursor=None,
        page_size=10,
    ) is None


@pytest.mark.asyncio
async def test_discover_with_meta_api_routes_by_platform():
    with (
        patch.object(
            SocialScraperService,
            "_discover_instagram_via_meta_api",
            new=AsyncMock(return_value=None),
        ) as ig,
        patch.object(
            SocialScraperService,
            "_discover_facebook_via_meta_api",
            new=AsyncMock(return_value=None),
        ) as fb,
    ):
        auth_session = {
            "session_payload": {"provider_access_token": "tok", "provider_user_id": "1"}
        }
        await SocialScraperService._discover_with_meta_api(
            platform=SocialPlatform.INSTAGRAM, auth_session=auth_session,
            cursor="c", page_size=10,
        )
        await SocialScraperService._discover_with_meta_api(
            platform=SocialPlatform.FACEBOOK, auth_session=auth_session,
            cursor=None, page_size=5,
        )
    ig.assert_awaited_once_with(payload=auth_session["session_payload"], cursor="c", page_size=10)
    fb.assert_awaited_once_with(payload=auth_session["session_payload"], cursor=None, page_size=5)


# =============================================================================
# _discover_instagram_via_meta_api
# =============================================================================


def _ig_payload(page_token="ptok", provider_token="tok", user_id="ig1"):
    return {"provider_user_id": user_id, "provider_page_access_token": page_token,
            "provider_access_token": provider_token}


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_missing_ids():
    missing_user = await SocialScraperService._discover_instagram_via_meta_api(
        payload={}, cursor=None, page_size=10
    )
    assert missing_user.requires_auth is True
    assert missing_user.metadata == {"reason": "missing_instagram_user_id"}

    missing_token = await SocialScraperService._discover_instagram_via_meta_api(
        payload={"provider_user_id": "ig1"}, cursor=None, page_size=10
    )
    assert missing_token.requires_auth is True
    assert missing_token.metadata == {"reason": "missing_access_token"}


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_http_status_error():
    req = httpx.Request("GET", "https://graph.facebook.com/v23.0/ig1/media")
    exc = httpx.HTTPStatusError("500", request=req, response=httpx.Response(500, request=req))
    client = _fake_client(get_exc=exc)
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_request_error():
    client = _fake_client(get_exc=httpx.ConnectError("boom", request=httpx.Request("GET", "https://x")))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_401_requires_auth():
    client = _fake_client(get=_response(401, json={}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"source": "meta_api", "http_status": 401}


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_non_success_returns_none():
    client = _fake_client(get=_response(500, json={}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_non_json_body():
    client = _fake_client(get=_response(200, text="<html>oops</html>", url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_success():
    body = {
        "data": [
            {
                "id": "row1",
                "media_type": "IMAGE",
                "media_url": "https://cdn.example.com/a.jpg",
                "thumbnail_url": "https://cdn.example.com/a_thumb.jpg",
                "timestamp": "2024-01-01T00:00:00Z",
                "permalink": "https://instagram.com/p/1",
            },
            {"media_type": "VIDEO", "thumbnail_url": "https://cdn.example.com/v.jpg"},
            {
                "id": "row3",
                "media_type": "CAROUSEL_ALBUM",
                "media_url": "https://cdn.example.com/c.jpg",
                "thumbnail_url": 123,
            },
            "not-a-dict",
            {"id": "row5", "media_type": "REELS", "media_url": "https://cdn.example.com/r.jpg"},
            {"id": "row6", "media_type": "IMAGE", "media_url": "ftp://bad"},
        ],
        "paging": {"cursors": {"after": "next-cursor-1"}},
    }
    client = _fake_client(get=_response(200, json=body, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(page_token=None), cursor="c1", page_size=10
        )

    assert result.requires_auth is False
    assert result.next_cursor == "next-cursor-1"
    assert result.exhausted is False
    assert result.metadata == {"source": "meta_api", "returned": 3}
    ids = [p.source_photo_id for p in result.photos]
    assert ids == ["row1", "instagram-1", "row3"]
    assert result.photos[0].source_thumb_url == "https://cdn.example.com/a_thumb.jpg"
    assert result.photos[1].source_photo_url == "https://cdn.example.com/v.jpg"
    assert result.photos[2].source_thumb_url == "https://cdn.example.com/c.jpg"
    assert result.photos[0].metadata["media_type"] == "IMAGE"
    assert result.photos[0].metadata["source"] == "meta_api"
    params = client.get.await_args.kwargs["params"]
    assert params["after"] == "c1"
    assert params["limit"] == 10
    # provider_page_access_token was absent, so the provider token was used.
    assert params["access_token"] == "tok"


@pytest.mark.asyncio
async def test_discover_instagram_via_meta_api_no_paging_cursor():
    client = _fake_client(get=_response(200, json={"data": []}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_instagram_via_meta_api(
            payload=_ig_payload(), cursor=None, page_size=10
        )
    assert result.next_cursor is None
    assert result.exhausted is True
    assert result.photos == []


# =============================================================================
# _discover_facebook_via_meta_api
# =============================================================================


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_missing_token():
    result = await SocialScraperService._discover_facebook_via_meta_api(
        payload={}, cursor=None, page_size=10
    )
    assert result.requires_auth is True
    assert result.metadata == {"reason": "missing_access_token"}


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_http_status_error():
    req = httpx.Request("GET", "https://graph.facebook.com/v23.0/me/posts")
    exc = httpx.HTTPStatusError("500", request=req, response=httpx.Response(500, request=req))
    client = _fake_client(get_exc=exc)
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_request_error():
    client = _fake_client(get_exc=httpx.ConnectError("boom", request=httpx.Request("GET", "https://x")))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_401_requires_auth():
    client = _fake_client(get=_response(401, json={}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result.requires_auth is True
    assert result.metadata == {"source": "meta_api", "http_status": 401}


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_non_success_returns_none():
    client = _fake_client(get=_response(500, json={}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_non_json_body():
    client = _fake_client(get=_response(200, text="oops", url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result is None


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_success():
    body = {
        "data": [
            {
                "id": "post1",
                "created_time": "2024-01-01T00:00:00Z",
                "full_picture": "https://fb.com/full.jpg",
                "attachments": {
                    "data": [
                        {
                            "media": {"image": {"src": "https://fb.com/att.jpg"}},
                            "subattachments": {
                                "data": [
                                    {"media": {"image": {"src": "https://fb.com/sub.jpg"}}}
                                ]
                            },
                        }
                    ]
                },
            },
            {"created_time": "2024-01-02T00:00:00Z"},
            "not-a-dict",
        ],
        "paging": {"cursors": {"after": "after2"}},
    }
    client = _fake_client(get=_response(200, json=body, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor="c1", page_size=10
        )

    assert result.requires_auth is False
    assert result.next_cursor == "after2"
    assert result.exhausted is False
    assert result.metadata == {"source": "meta_api", "returned": 3}
    ids = [p.source_photo_id for p in result.photos]
    assert ids == ["post1-0", "post1-1", "post1-2"]
    assert result.photos[0].source_photo_url == "https://fb.com/full.jpg"
    assert result.photos[1].source_photo_url == "https://fb.com/att.jpg"
    assert result.photos[2].source_photo_url == "https://fb.com/sub.jpg"
    assert result.photos[0].source_taken_at == datetime(2024, 1, 1, tzinfo=timezone.utc)
    assert result.photos[0].metadata["post_id"] == "post1"
    params = client.get.await_args.kwargs["params"]
    assert params["after"] == "c1"
    assert params["limit"] == 10


@pytest.mark.asyncio
async def test_discover_facebook_via_meta_api_no_paging_cursor():
    client = _fake_client(get=_response(200, json={"data": []}, url="https://graph.facebook.com/x"))
    with _patch_client(client):
        result = await SocialScraperService._discover_facebook_via_meta_api(
            payload={"provider_access_token": "tok"}, cursor=None, page_size=10
        )
    assert result.next_cursor is None
    assert result.exhausted is True
    assert result.photos == []


# =============================================================================
# discover_profile_photos — public scraping path
# =============================================================================


def _three_image_html():
    return (
        '"display_url":"https:\\/\\/example.com\\/1.jpg"'
        '"display_url":"https:\\/\\/example.com\\/2.jpg"'
        '"display_url":"https:\\/\\/example.com\\/3.jpg"'
    )


@pytest.mark.asyncio
async def test_discover_profile_photos_public_scrape_with_pagination():
    client = _fake_client(get=_response(200, text=_three_image_html()))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
            page_size=2,
        )

    assert result.requires_auth is False
    assert len(result.photos) == 2
    assert result.photos[0].source_photo_id == "instagram-0"
    assert result.photos[0].source_photo_url == "https://example.com/1.jpg"
    assert result.photos[1].source_photo_id == "instagram-1"
    assert result.next_cursor == "2"
    assert result.exhausted is False
    assert result.metadata == {"total_discovered": 3, "returned": 2, "offset": 0}
    client.get.assert_awaited_once()


@pytest.mark.asyncio
async def test_discover_profile_photos_public_scrape_with_cursor():
    client = _fake_client(get=_response(200, text=_three_image_html()))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
            cursor="1",
            page_size=2,
        )

    assert len(result.photos) == 2
    assert result.photos[0].source_photo_id == "instagram-1"
    assert result.next_cursor is None
    assert result.exhausted is True
    assert result.metadata == {"total_discovered": 3, "returned": 2, "offset": 1}


@pytest.mark.asyncio
async def test_discover_profile_photos_invalid_cursor_defaults_to_zero():
    client = _fake_client(get=_response(200, text=_three_image_html()))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
            cursor="not-a-number",
        )

    assert len(result.photos) == 3
    assert result.metadata["offset"] == 0
    assert result.exhausted is True


@pytest.mark.asyncio
async def test_discover_profile_photos_401_requires_auth():
    client = _fake_client(get=_response(401, json={}))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
        )
    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"http_status": 401}


@pytest.mark.asyncio
async def test_discover_profile_photos_500_fetch_failure():
    client = _fake_client(get=_response(500, json={}))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
        )
    assert result.requires_auth is False
    assert result.exhausted is False
    assert result.metadata["error_type"] == "fetch_failure"
    assert "HTTP 500" in result.metadata["message"]
    assert result.metadata["http_status"] == 500


@pytest.mark.asyncio
async def test_discover_profile_photos_private_profile_without_auth():
    client = _fake_client(get=_response(200, text="This account is private"))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
        )
    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata == {"reason": "private_profile"}


@pytest.mark.asyncio
async def test_discover_profile_photos_private_html_with_auth_proceeds():
    client = _fake_client(get=_response(200, text="You must log in to view. No images here."))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.facebook.com/user1/",
            platform=SocialPlatform.FACEBOOK,
            auth_session={"session_payload": {"provider_user_id": "1"}},
        )
    assert result.requires_auth is False
    assert result.photos == []
    assert result.metadata == {"total_discovered": 0, "returned": 0, "offset": 0}


@pytest.mark.asyncio
async def test_discover_profile_photos_request_error():
    client = _fake_client(get_exc=httpx.ConnectError("boom", request=httpx.Request("GET", "https://x")))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
        )
    assert result.requires_auth is False
    assert result.exhausted is False
    assert result.metadata == {"error_type": "fetch_failure", "message": "boom"}


# =============================================================================
# discover_profile_photos — Meta API path
# =============================================================================


@pytest.mark.asyncio
async def test_discover_profile_photos_meta_api_path():
    meta_result = DiscoverPhotosResult(
        requires_auth=False,
        photos=[
            ScrapedPhotoRef(source_photo_url="https://cdn.example.com/1.jpg"),
            ScrapedPhotoRef(source_photo_url="https://cdn.example.com/2.jpg"),
        ],
        next_cursor="n",
        exhausted=False,
        metadata={"source": "meta_api"},
    )
    with patch.object(
        SocialScraperService,
        "_discover_with_meta_api",
        new=AsyncMock(return_value=meta_result),
    ) as meta:
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": {"provider_access_token": "tok"}},
            cursor="c",
        )

    assert result is meta_result
    assert len(result.photos) == 2
    meta.assert_awaited_once()
    assert meta.await_args.kwargs["platform"] == SocialPlatform.INSTAGRAM
    assert meta.await_args.kwargs["cursor"] == "c"


@pytest.mark.asyncio
async def test_discover_profile_photos_meta_api_none_falls_through_to_public():
    client = _fake_client(get=_response(200, text=_three_image_html()))
    with (
        patch.object(
            SocialScraperService,
            "_discover_with_meta_api",
            new=AsyncMock(return_value=None),
        ),
        _patch_client(client),
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/user1/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": {"provider_access_token": "tok"}},
        )

    assert result.requires_auth is False
    assert len(result.photos) == 3
    client.get.assert_awaited_once()


# =============================================================================
# discover_profile_photos — Instagram scraper path
# =============================================================================


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_otp_required():
    login_result = InstagramLoginResult(
        success=False, requires_otp=True, otp_identifier="tf-id-1"
    )
    payload = {"username": "u", "password": "p"}
    with patch.object(
        SocialScraperService, "_instagram_login", new=AsyncMock(return_value=login_result)
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": payload},
        )

    assert result.requires_auth is True
    assert result.exhausted is True
    assert result.metadata["reason"] == "two_factor_required"
    assert result.metadata["two_factor_identifier"] == "tf-id-1"
    assert payload["two_factor_identifier"] == "tf-id-1"


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_checkpoint_required():
    login_result = InstagramLoginResult(
        success=False, checkpoint_url="https://instagram.com/challenge/abc"
    )
    with patch.object(
        SocialScraperService, "_instagram_login", new=AsyncMock(return_value=login_result)
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": {"username": "u", "password": "p"}},
        )

    assert result.requires_auth is True
    assert result.metadata["reason"] == "checkpoint_required"
    assert result.metadata["checkpoint_url"] == "https://instagram.com/challenge/abc"


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_login_failed_with_message():
    login_result = InstagramLoginResult(success=False, error_message="Bad credentials")
    with patch.object(
        SocialScraperService, "_instagram_login", new=AsyncMock(return_value=login_result)
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": {"username": "u", "password": "p"}},
        )

    assert result.requires_auth is True
    assert result.metadata["reason"] == "login_failed"
    assert result.metadata["message"] == "Bad credentials"


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_login_failed_default_message():
    login_result = InstagramLoginResult(success=False)
    with patch.object(
        SocialScraperService, "_instagram_login", new=AsyncMock(return_value=login_result)
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": {"username": "u", "password": "p"}},
        )

    assert result.metadata["message"] == "Login failed"


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_login_success_stores_session():
    login_result = InstagramLoginResult(
        success=True, sessionid="sess1", csrftoken="csrf1", ds_user_id="99"
    )
    scraper_result = DiscoverPhotosResult(
        requires_auth=False,
        photos=[ScrapedPhotoRef(source_photo_url="https://cdn.example.com/1.jpg")],
        next_cursor=None,
        exhausted=True,
    )
    payload = {"username": "u", "password": "p"}
    with (
        patch.object(
            SocialScraperService, "_instagram_login", new=AsyncMock(return_value=login_result)
        ),
        patch.object(
            SocialScraperService,
            "_discover_with_instagram_scraper",
            new=AsyncMock(return_value=scraper_result),
        ) as scraper,
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={"session_payload": payload},
            page_size=10,
        )

    assert result is scraper_result
    assert len(result.photos) == 1
    assert payload["sessionid"] == "sess1"
    assert payload["csrftoken"] == "csrf1"
    assert payload["ds_user_id"] == "99"
    assert payload["cookie_header"] == "sessionid=sess1; csrftoken=csrf1; ds_user_id=99"
    scraper.assert_awaited_once()
    assert scraper.await_args.kwargs["page_size"] == 10


@pytest.mark.asyncio
async def test_discover_profile_photos_scraper_existing_session_skips_login():
    scraper_result = DiscoverPhotosResult(
        requires_auth=False,
        photos=[ScrapedPhotoRef(source_photo_url="https://cdn.example.com/1.jpg")],
        next_cursor=None,
        exhausted=True,
    )
    with (
        patch.object(
            SocialScraperService,
            "_instagram_login",
            new=AsyncMock(return_value=InstagramLoginResult(success=True)),
        ) as login,
        patch.object(
            SocialScraperService,
            "_discover_with_instagram_scraper",
            new=AsyncMock(return_value=scraper_result),
        ),
    ):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.instagram.com/u/",
            platform=SocialPlatform.INSTAGRAM,
            auth_session={
                "session_payload": {
                    "username": "u",
                    "password": "p",
                    "sessionid": "existing",
                }
            },
        )

    login.assert_not_awaited()
    assert len(result.photos) == 1


@pytest.mark.asyncio
async def test_discover_profile_photos_non_scraper_platform_falls_to_public():
    client = _fake_client(get=_response(200, text=_three_image_html()))
    with _patch_client(client):
        result = await SocialScraperService.discover_profile_photos(
            normalized_url="https://www.facebook.com/u/",
            platform=SocialPlatform.FACEBOOK,
            auth_session={
                "session_payload": {
                    "username": "u",
                    "password": "p",
                    "cookie_header": "sessionid=s1",
                }
            },
        )

    assert result.requires_auth is False
    assert len(result.photos) == 3
    call_kwargs = client.get.await_args.kwargs
    assert call_kwargs["headers"]["Cookie"] == "sessionid=s1"


# =============================================================================
# fetch_photo_as_base64
# =============================================================================


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_success():
    resp = _response(
        200,
        headers={"content-type": "image/jpeg"},
        content=b"abc",
        url="https://example.com/a.jpg",
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        result = await SocialScraperService.fetch_photo_as_base64(
            "https://example.com/a.jpg"
        )

    assert result == base64.b64encode(b"abc").decode()
    assert client.stream.call_args.args == ("GET", "https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_quotes_url_with_spaces():
    resp = _response(
        200,
        headers={"content-type": "image/png"},
        content=b"png",
        url="https://example.com/a%20b.jpg",
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        await SocialScraperService.fetch_photo_as_base64("https://example.com/a b.jpg")

    assert client.stream.call_args.args[1] == "https://example.com/a%20b.jpg"


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_follows_redirect():
    first = _response(
        302,
        headers={"location": "https://example.com/next.jpg"},
        url="https://example.com/a.jpg",
    )
    second = _response(
        200,
        headers={"content-type": "image/jpeg"},
        content=b"xyz",
        url="https://example.com/next.jpg",
    )
    client = _fake_client(stream=None)
    client.stream = Mock(side_effect=[_FakeStream(first), _FakeStream(second)])
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        result = await SocialScraperService.fetch_photo_as_base64(
            "https://example.com/a.jpg"
        )

    assert result == base64.b64encode(b"xyz").decode()
    assert client.stream.call_args_list[1].args[1] == "https://example.com/next.jpg"


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_redirect_without_location():
    resp = _response(302, headers={}, url="https://example.com/a.jpg")
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="redirect chain is invalid or too long"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_redirect_chain_exhausted():
    client = _fake_client(stream=None)
    responses = []
    for i in range(SocialScraperService._MAX_IMAGE_REDIRECTS + 1):
        responses.append(
            _FakeStream(
                _response(
                    302,
                    headers={"location": f"https://example.com/hop{i}.jpg"},
                    url=f"https://example.com/hop{i}.jpg",
                )
            )
        )
    client.stream = Mock(side_effect=responses)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="redirect chain is invalid"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_http_error_propagates():
    resp = _response(404, headers={"content-type": "image/jpeg"}, url="https://example.com/a.jpg")
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(httpx.HTTPStatusError):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_non_image_content_type():
    resp = _response(
        200,
        headers={"content-type": "text/html; charset=utf-8"},
        content=b"<html></html>",
        url="https://example.com/a.jpg",
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="did not return an image"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_content_length_too_large():
    resp = _response(
        200,
        headers={
            "content-type": "image/jpeg",
            "content-length": str(SocialScraperService._MAX_IMPORTED_IMAGE_BYTES + 1),
        },
        content=b"x",
        url="https://example.com/a.jpg",
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="exceeds the maximum size"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_chunk_exceeds_max_size():
    # A streamed body has no content-length header, so the size guard must
    # trip while accumulating chunks.
    resp = httpx.Response(
        200,
        stream=httpx.ByteStream(b"x" * (SocialScraperService._MAX_IMPORTED_IMAGE_BYTES + 1)),
        headers={"content-type": "image/jpeg"},
        request=httpx.Request("GET", "https://example.com/a.jpg"),
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="exceeds the maximum size"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")


@pytest.mark.asyncio
async def test_fetch_photo_as_base64_empty_content():
    resp = _response(
        200,
        headers={"content-type": "image/jpeg"},
        content=b"",
        url="https://example.com/a.jpg",
    )
    client = _fake_client(stream=resp)
    with _patch_resolver("93.184.216.34"), _patch_client(client):
        with pytest.raises(SocialImportError, match="Imported image is empty"):
            await SocialScraperService.fetch_photo_as_base64("https://example.com/a.jpg")
