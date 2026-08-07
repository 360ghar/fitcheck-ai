"""
Coverage for social_import route branches the sibling tests miss.

Siblings already cover create-job 429 (concurrency message) and approve-photo;
this file covers the remaining handlers: create-job success + duplicate-key
429 + generic error, status polling, the SSE event stream (replay terminal,
live queue terminal, heartbeat timeout, generator error, client disconnect),
OAuth connect/callback (web popup + mobile redirect + every early-error
branch), scraper/oauth auth submission, item patch (found + 404), reject and
cancel.

Route functions are called DIRECTLY with a FakeDB and patched services — no
HTTP and no real DB (tests/conftest.py blocks the network).
"""
import asyncio
import json
from types import SimpleNamespace
from unittest.mock import AsyncMock, Mock, patch

import pytest
from fastapi import HTTPException

import app.api.v1.social_import as social_import_api
from app.api.v1.social_import import (
    _frontend_origin,
    _validate_target_origin,
    cancel_social_import_job,
    create_oauth_connect_url,
    create_social_import_job,
    get_social_import_status,
    patch_social_item,
    reject_social_photo,
    social_import_events,
    social_oauth_callback,
    submit_oauth_auth,
    submit_scraper_login,
)
from app.core.config import settings
from app.core.exceptions import SocialImportJobNotFoundError
from app.models.social_import import (
    SocialImportItemPatchRequest,
    SocialImportOAuthAuthRequest,
    SocialImportScraperAuthRequest,
    SocialImportStartRequest,
    SocialPlatform,
)
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_oauth_service import SocialOAuthService

SOURCE_URL = "https://www.instagram.com/example/"
NORMALIZED_URL = "https://www.instagram.com/example/"
CALLBACK_URL = "http://testserver/api/v1/social-import/auth/oauth/callback"


def _job_row(job_id="job-1", user_id="user-1", platform="instagram", status="created"):
    return {
        "id": job_id,
        "user_id": user_id,
        "status": status,
        "platform": platform,
        "source_url": SOURCE_URL,
        "normalized_url": NORMALIZED_URL,
        "total_photos": 0,
        "discovered_photos": 0,
        "auth_required": False,
        "discovery_completed": False,
        "metadata": {},
    }


def _status_payload(**overrides):
    payload = {
        "id": "job-1",
        "status": "created",
        "platform": "instagram",
        "source_url": SOURCE_URL,
        "normalized_url": NORMALIZED_URL,
        "total_photos": 0,
        "discovered_photos": 0,
        "processed_photos": 0,
        "approved_photos": 0,
        "rejected_photos": 0,
        "failed_photos": 0,
        "auth_required": False,
        "discovery_completed": False,
        "error_message": None,
        "auth_reason": None,
        "two_factor_identifier": None,
        "checkpoint_url": None,
        "awaiting_review_photo": None,
        "buffered_photo": None,
        "processing_photo": None,
        "queued_count": 0,
    }
    payload.update(overrides)
    return payload


def _state_payload(**overrides):
    base = dict(
        user_id="user-1",
        job_id="job-1",
        platform=SocialPlatform.INSTAGRAM,
        opener_origin=None,
        mobile_redirect_uri=None,
        exp=9999999999,
        nonce="nonce",
    )
    base.update(overrides)
    return SimpleNamespace(**base)


def _patch_service(monkeypatch, service):
    monkeypatch.setattr(social_import_api, "_service", lambda user_id, db: service)


def _enable_social_import(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", True)


# =============================================================================
# create_social_import_job
# =============================================================================


@pytest.mark.asyncio
async def test_create_job_disabled_returns_404(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", False)
    with pytest.raises(HTTPException) as exc_info:
        await create_social_import_job(
            SocialImportStartRequest(source_url=SOURCE_URL),
            user_id="user-1",
            db=Mock(),
        )
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_create_job_success_through_real_service_and_rpc(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rpc_results["create_social_import_job"] = [_job_row()]
    monkeypatch.setattr(settings, "SOCIAL_IMPORT_MAX_CONCURRENT_JOBS", 2)
    schedule = AsyncMock()
    monkeypatch.setattr(SocialImportPipelineService, "schedule_job", schedule)

    result = await create_social_import_job(
        SocialImportStartRequest(source_url=SOURCE_URL),
        user_id="user-1",
        db=fake_db,
    )

    assert result["message"] == "Started"
    assert result["data"]["job_id"] == "job-1"
    assert result["data"]["platform"] == "instagram"
    assert result["data"]["normalized_url"] == NORMALIZED_URL
    assert fake_db.rpc_calls == [
        (
            "create_social_import_job",
            {
                "p_user_id": "user-1",
                "p_platform": "instagram",
                "p_source_url": SOURCE_URL,
                "p_normalized_url": NORMALIZED_URL,
                "p_max_concurrent_jobs": 2,
            },
        )
    ]
    schedule.assert_awaited_once()
    assert schedule.await_args.args[1] == "job-1"


@pytest.mark.asyncio
async def test_create_job_unrelated_error_is_re_raised(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    # No rpc_results: create_job raises "Failed to create social import job".
    with pytest.raises(RuntimeError, match="Failed to create social import job"):
        await create_social_import_job(
            SocialImportStartRequest(source_url=SOURCE_URL),
            user_id="user-1",
            db=fake_db,
        )


@pytest.mark.asyncio
async def test_create_job_duplicate_key_surfaces_429(monkeypatch):
    _enable_social_import(monkeypatch)

    async def fake_create_job(db, **kwargs):  # noqa: ANN001
        raise RuntimeError("duplicate key value violates unique constraint")

    monkeypatch.setattr(
        SocialImportJobStore, "create_job", staticmethod(fake_create_job)
    )

    with pytest.raises(HTTPException) as exc_info:
        await create_social_import_job(
            SocialImportStartRequest(source_url=SOURCE_URL),
            user_id="user-1",
            db=Mock(),
        )
    assert exc_info.value.status_code == 429


# =============================================================================
# get_social_import_status
# =============================================================================


@pytest.mark.asyncio
async def test_get_status_disabled_returns_404(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", False)
    with pytest.raises(HTTPException) as exc_info:
        await get_social_import_status(job_id="job-1", user_id="user-1", db=Mock())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_get_status_success_through_real_service(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]

    result = await get_social_import_status(job_id="job-1", user_id="user-1", db=fake_db)

    assert result["message"] == "OK"
    assert result["data"]["id"] == "job-1"
    assert result["data"]["status"] == "created"
    assert result["data"]["platform"] == "instagram"


# =============================================================================
# social_import_events (SSE stream)
# =============================================================================


@pytest.mark.asyncio
async def test_events_disabled_returns_404(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", False)
    with pytest.raises(HTTPException) as exc_info:
        await social_import_events(job_id="job-1", user_id="user-1", db=Mock())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_events_job_not_found_raises(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    with pytest.raises(SocialImportJobNotFoundError):
        await social_import_events(job_id="job-1", user_id="user-1", db=fake_db)


@pytest.mark.asyncio
async def test_events_replay_terminal_event_closes_stream(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()
    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock())
    monkeypatch.setattr(
        SocialImportEventService,
        "replay",
        AsyncMock(return_value=[{"id": 7, "type": "job_completed", "data": {"job_id": "job-1"}}]),
    )
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["connected", "job_completed"]
    assert json.loads(chunks[0]["data"])["status"] == "created"
    assert chunks[1]["id"] == "7"
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_live_queue_events_until_terminal(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()
    queued = [
        ({"id": 9, "type": "job_updated", "data": {"status": "processing"}}, 12),
        ({"id": 10, "type": "job_failed", "data": {"error": "boom"}}, 8),
    ]

    async def _add_subscriber(job_id, queue):
        for event, size in queued:
            queue.put_nowait((event, size))

    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock(side_effect=_add_subscriber))
    monkeypatch.setattr(SocialImportEventService, "replay", AsyncMock(return_value=[]))
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["connected", "job_updated", "job_failed"]
    assert chunks[1]["id"] == "9"
    assert json.loads(chunks[2]["data"])["error"] == "boom"
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_replay_mixed_history_then_terminal(monkeypatch, fake_db):
    """A non-terminal replayed event must fall through to the next history row."""
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()
    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock())
    monkeypatch.setattr(
        SocialImportEventService,
        "replay",
        AsyncMock(
            return_value=[
                {"id": 6, "type": "job_updated", "data": {"status": "processing"}},
                {"id": 7, "type": "job_completed", "data": {}},
            ]
        ),
    )
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["connected", "job_updated", "job_completed"]
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_live_event_without_id_skips_id_field(monkeypatch, fake_db):
    """Locally-generated events (stream_overflow) carry no DB id and must not
    emit an 'id' field that would poison the client's Last-Event-ID."""
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()

    async def _add_subscriber(job_id, queue):
        queue.put_nowait(({"type": "stream_overflow", "data": {"recoverable": True}}, 5))

    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock(side_effect=_add_subscriber))
    monkeypatch.setattr(SocialImportEventService, "replay", AsyncMock(return_value=[]))
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["connected", "stream_overflow"]
    assert "id" not in chunks[1]
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_heartbeat_on_queue_timeout(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()
    real_wait_for = asyncio.wait_for
    state = {"heartbeats": 0}

    async def _add_subscriber(job_id, queue):
        queue.put_nowait(({"id": 12, "type": "job_cancelled", "data": {}}, 4))

    async def _fake_wait_for(awaitable, timeout, *args, **kwargs):
        if state["heartbeats"] == 0:
            state["heartbeats"] += 1
            awaitable.close()
            raise asyncio.TimeoutError
        return await real_wait_for(awaitable, timeout, *args, **kwargs)

    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock(side_effect=_add_subscriber))
    monkeypatch.setattr(SocialImportEventService, "replay", AsyncMock(return_value=[]))
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    with patch.object(asyncio, "wait_for", new=_fake_wait_for):
        chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["connected", "heartbeat", "job_cancelled"]
    heartbeat = json.loads(chunks[1]["data"])
    assert heartbeat["status"] == "created"
    assert heartbeat["last_event_id"] is None
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_generator_error_yields_job_failed(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(
        monkeypatch,
        SimpleNamespace(get_status=AsyncMock(side_effect=RuntimeError("boom"))),
    )
    remove = AsyncMock()
    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock())
    monkeypatch.setattr(SocialImportEventService, "replay", AsyncMock(return_value=[]))
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = [chunk async for chunk in response.body_iterator]

    assert [chunk["event"] for chunk in chunks] == ["job_failed"]
    assert "Internal error" in json.loads(chunks[0]["data"])["error"]
    remove.assert_awaited_once()


@pytest.mark.asyncio
async def test_events_client_disconnect_cancels_generator(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row()]
    _patch_service(monkeypatch, SimpleNamespace(get_status=AsyncMock(return_value=_status_payload())))
    remove = AsyncMock()
    monkeypatch.setattr(SocialImportEventService, "add_subscriber", AsyncMock())
    monkeypatch.setattr(SocialImportEventService, "replay", AsyncMock(return_value=[]))
    monkeypatch.setattr(SocialImportEventService, "remove_subscriber", remove)

    response = await social_import_events(
        job_id="job-1", last_event_id=None, user_id="user-1", db=fake_db
    )
    chunks = []

    async def _consume():
        async for chunk in response.body_iterator:
            chunks.append(chunk)

    task = asyncio.create_task(_consume())
    for _ in range(1000):
        if chunks:
            break
        await asyncio.sleep(0.001)
    task.cancel()
    await asyncio.gather(task, return_exceptions=True)

    assert chunks[0]["event"] == "connected"
    remove.assert_awaited_once()


# =============================================================================
# create_oauth_connect_url
# =============================================================================


@pytest.mark.asyncio
async def test_oauth_connect_disabled_returns_404(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", False)
    with pytest.raises(HTTPException) as exc_info:
        await create_oauth_connect_url(job_id="job-1", request=Mock(), user_id="user-1", db=Mock())
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_oauth_connect_job_not_found(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    with pytest.raises(SocialImportJobNotFoundError):
        await create_oauth_connect_url(job_id="job-1", request=Mock(), user_id="user-1", db=fake_db)


@pytest.mark.asyncio
async def test_oauth_connect_success(monkeypatch, fake_db):
    _enable_social_import(monkeypatch)
    fake_db.rows["social_import_jobs"] = [_job_row(platform="facebook")]
    request = Mock()
    request.url_for.return_value = CALLBACK_URL
    request.headers.get.return_value = "https://fitcheckaiapp.com"
    oauth_data = {
        "auth_url": "https://www.facebook.com/v23.0/dialog/oauth?client_id=x",
        "expires_in_seconds": 600,
        "provider": "meta",
    }
    build = Mock(return_value=oauth_data)
    monkeypatch.setattr(SocialOAuthService, "build_authorize_url", staticmethod(build))

    result = await create_oauth_connect_url(
        job_id="job-1",
        request=request,
        mobile_redirect_uri=None,
        user_id="user-1",
        db=fake_db,
    )

    assert result["message"] == "OK"
    assert result["data"]["auth_url"] == oauth_data["auth_url"]
    assert result["data"]["provider"] == "meta"
    assert build.call_args.kwargs["platform"] == SocialPlatform.FACEBOOK
    assert build.call_args.kwargs["redirect_uri"] == CALLBACK_URL
    assert build.call_args.kwargs["opener_origin"] == "https://fitcheckaiapp.com"


# =============================================================================
# social_oauth_callback
# =============================================================================


def _callback_request():
    request = Mock()
    request.url_for.return_value = CALLBACK_URL
    return request


@pytest.mark.asyncio
async def test_oauth_callback_disabled(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", False)
    response = await social_oauth_callback(
        request=_callback_request(), state=None, code=None, error=None,
        error_description=None, db=Mock(),
    )
    assert "Social import is disabled" in response.body.decode()


@pytest.mark.asyncio
async def test_oauth_callback_missing_state(monkeypatch):
    _enable_social_import(monkeypatch)
    response = await social_oauth_callback(
        request=_callback_request(), state=None, code=None, error=None,
        error_description=None, db=Mock(),
    )
    assert "Missing OAuth state" in response.body.decode()


@pytest.mark.asyncio
async def test_oauth_callback_invalid_state(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService, "parse_state", Mock(side_effect=ValueError("bad state token"))
    )
    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code=None, error=None,
        error_description=None, db=Mock(),
    )
    assert "bad state token" in response.body.decode()


@pytest.mark.asyncio
async def test_oauth_callback_provider_error(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService, "parse_state", Mock(return_value=_state_payload())
    )
    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code=None,
        error="access_denied", error_description="User denied access", db=Mock(),
    )
    body = response.body.decode()
    assert "User denied access" in body
    assert '"status": "error"' in body


@pytest.mark.asyncio
async def test_oauth_callback_missing_code(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService, "parse_state", Mock(return_value=_state_payload())
    )
    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code=None, error=None,
        error_description=None, db=Mock(),
    )
    assert "Missing OAuth code" in response.body.decode()


@pytest.mark.asyncio
async def test_oauth_callback_exchange_failure(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService, "parse_state", Mock(return_value=_state_payload())
    )
    monkeypatch.setattr(
        SocialOAuthService,
        "exchange_code_for_token",
        AsyncMock(side_effect=RuntimeError("exchange failed")),
    )
    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code="code-1", error=None,
        error_description=None, db=Mock(),
    )
    assert "exchange failed" in response.body.decode()


@pytest.mark.asyncio
async def test_oauth_callback_success_mobile_redirect(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService,
        "parse_state",
        Mock(return_value=_state_payload(mobile_redirect_uri="fitcheck.ai://oauth")),
    )
    monkeypatch.setattr(
        SocialOAuthService,
        "exchange_code_for_token",
        AsyncMock(return_value={"provider_access_token": "token-1", "expires_at": None}),
    )
    monkeypatch.setattr(
        SocialOAuthService,
        "resolve_platform_identity",
        AsyncMock(return_value={"provider_user_id": "uid-1", "provider_username": "handle"}),
    )
    service = SimpleNamespace(accept_auth=AsyncMock())
    _patch_service(monkeypatch, service)

    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code="code-1", error=None,
        error_description=None, db=Mock(),
    )

    assert response.status_code == 302
    location = response.headers["location"]
    assert "fitcheck.ai://oauth" in location
    assert "status=success" in location
    assert "job_id=job-1" in location
    service.accept_auth.assert_awaited_once()
    assert service.accept_auth.await_args.args[:2] == ("job-1", "oauth")


@pytest.mark.asyncio
async def test_oauth_callback_success_web_popup(monkeypatch):
    _enable_social_import(monkeypatch)
    monkeypatch.setattr(
        SocialOAuthService,
        "parse_state",
        Mock(return_value=_state_payload(opener_origin="https://fitcheckaiapp.com")),
    )
    monkeypatch.setattr(
        SocialOAuthService,
        "exchange_code_for_token",
        AsyncMock(return_value={"provider_access_token": "token-1", "expires_at": None}),
    )
    monkeypatch.setattr(
        SocialOAuthService,
        "resolve_platform_identity",
        AsyncMock(return_value={"provider_user_id": "uid-1"}),
    )
    service = SimpleNamespace(accept_auth=AsyncMock())
    _patch_service(monkeypatch, service)

    response = await social_oauth_callback(
        request=_callback_request(), state="state-1", code="code-1", error=None,
        error_description=None, db=Mock(),
    )

    body = response.body.decode()
    assert '"status": "success"' in body
    assert "Social account connected. Import resumed." in body
    assert "https://fitcheckaiapp.com" in body
    service.accept_auth.assert_awaited_once()


# =============================================================================
# submit_oauth_auth / submit_scraper_login
# =============================================================================


@pytest.mark.asyncio
async def test_submit_oauth_auth_accepts(monkeypatch):
    service = SimpleNamespace(accept_auth=AsyncMock())
    _patch_service(monkeypatch, service)

    result = await submit_oauth_auth(
        job_id="job-1",
        body=SocialImportOAuthAuthRequest(provider_access_token="token-123456"),
        user_id="user-1",
        db=Mock(),
    )

    assert result["message"] == "OK"
    assert result["data"]["success"] is True
    assert result["data"]["status"] == "processing"
    service.accept_auth.assert_awaited_once()
    accept_args = service.accept_auth.await_args
    assert accept_args.args[:2] == ("job-1", "oauth")
    assert accept_args.args[2]["provider_access_token"] == "token-123456"


@pytest.mark.asyncio
async def test_submit_scraper_login_accepts(monkeypatch):
    service = SimpleNamespace(accept_auth=AsyncMock())
    _patch_service(monkeypatch, service)

    result = await submit_scraper_login(
        job_id="job-1",
        body=SocialImportScraperAuthRequest(username="user", password="pass"),
        user_id="user-1",
        db=Mock(),
    )

    assert result["message"] == "OK"
    assert result["data"]["status"] == "processing"
    accept_args = service.accept_auth.await_args
    assert accept_args.args[:2] == ("job-1", "scraper")
    assert accept_args.args[2]["username"] == "user"
    assert accept_args.args[2]["password"] == "pass"


# =============================================================================
# patch_social_item / reject / cancel
# =============================================================================


@pytest.mark.asyncio
async def test_patch_social_item_success(monkeypatch):
    service = SimpleNamespace(patch_item=AsyncMock(return_value={"id": "item-1", "name": "Shirt"}))
    _patch_service(monkeypatch, service)

    result = await patch_social_item(
        job_id="job-1",
        photo_id="photo-1",
        item_id="item-1",
        body=SocialImportItemPatchRequest(name="Shirt", colors=["red"]),
        user_id="user-1",
        db=Mock(),
    )

    assert result["message"] == "Updated"
    assert result["data"]["name"] == "Shirt"
    service.patch_item.assert_awaited_once()
    updates = service.patch_item.await_args.kwargs["updates"]
    assert updates == {"name": "Shirt", "colors": ["red"]}


@pytest.mark.asyncio
async def test_patch_social_item_not_found_returns_404(monkeypatch):
    service = SimpleNamespace(patch_item=AsyncMock(return_value=None))
    _patch_service(monkeypatch, service)

    with pytest.raises(HTTPException) as exc_info:
        await patch_social_item(
            job_id="job-1",
            photo_id="photo-1",
            item_id="missing",
            body=SocialImportItemPatchRequest(name="Shirt"),
            user_id="user-1",
            db=Mock(),
        )
    assert exc_info.value.status_code == 404


@pytest.mark.asyncio
async def test_reject_social_photo(monkeypatch):
    service = SimpleNamespace(reject_photo=AsyncMock())
    _patch_service(monkeypatch, service)

    result = await reject_social_photo(job_id="job-1", photo_id="photo-1", user_id="user-1", db=Mock())

    assert result["message"] == "Rejected"
    assert result["data"]["status"] == "rejected"
    assert result["data"]["photo_id"] == "photo-1"
    service.reject_photo.assert_awaited_once_with("job-1", "photo-1")


@pytest.mark.asyncio
async def test_cancel_social_import_job(monkeypatch):
    service = SimpleNamespace(cancel_job=AsyncMock())
    _patch_service(monkeypatch, service)

    result = await cancel_social_import_job(job_id="job-1", user_id="user-1", db=Mock())

    assert result["message"] == "Cancelled"
    assert result["data"]["status"] == "cancelled"
    service.cancel_job.assert_awaited_once_with("job-1")


# =============================================================================
# Origin validation helpers
# =============================================================================


def _set_origins(monkeypatch, frontend_url, cors_origins=None):
    monkeypatch.setattr(settings, "FRONTEND_URL", frontend_url)
    monkeypatch.setattr(settings, "BACKEND_CORS_ORIGINS", cors_origins or [])


def test_frontend_origin_parses_scheme_and_netloc(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert _frontend_origin() == "https://fitcheckaiapp.com"


def test_frontend_origin_falls_back_to_raw_value(monkeypatch):
    _set_origins(monkeypatch, "localhost:3000")
    assert _frontend_origin() == "localhost:3000"


def test_validate_target_origin_none_uses_frontend(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert _validate_target_origin(None) == "https://fitcheckaiapp.com"


def test_validate_target_origin_empty_frontend_falls_back_to_star(monkeypatch):
    _set_origins(monkeypatch, "")
    assert _validate_target_origin("https://other.example.com") == "*"


def test_validate_target_origin_rejects_non_http_scheme(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert _validate_target_origin("javascript:alert(1)") == "https://fitcheckaiapp.com"


def test_validate_target_origin_rejects_missing_netloc(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert _validate_target_origin("localhost") == "https://fitcheckaiapp.com"


def test_validate_target_origin_exact_match_wins(monkeypatch):
    _set_origins(
        monkeypatch,
        "https://app.fitcheckaiapp.com",
        ["https://admin.fitcheckaiapp.com"],
    )
    assert (
        _validate_target_origin("https://admin.fitcheckaiapp.com/")
        == "https://admin.fitcheckaiapp.com"
    )


def test_validate_target_origin_first_party_subdomain_allowed(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert (
        _validate_target_origin("https://shop.fitcheckaiapp.com")
        == "https://shop.fitcheckaiapp.com"
    )


def test_validate_target_origin_suffix_attack_rejected(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com")
    assert (
        _validate_target_origin("https://evilfitcheckaiapp.com")
        == "https://fitcheckaiapp.com"
    )


def test_validate_target_origin_unmatched_falls_back_to_frontend(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com", ["http://10.0.0.1:8000"])
    assert _validate_target_origin("https://other.example.com") == "https://fitcheckaiapp.com"


def test_validate_target_origin_skips_hostless_allowed_origins(monkeypatch):
    _set_origins(monkeypatch, "https://fitcheckaiapp.com", ["http://"])
    assert _validate_target_origin("https://other.example.com") == "https://fitcheckaiapp.com"
