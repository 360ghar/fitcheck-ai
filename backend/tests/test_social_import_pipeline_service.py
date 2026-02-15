import sys
import types

import pytest

from app.core.exceptions import SocialImportError, SocialImportJobNotFoundError
from app.services.ai_settings_service import AISettingsService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore

if "pinecone" not in sys.modules:
    pinecone_stub = types.ModuleType("pinecone")
    pinecone_stub.Pinecone = object
    pinecone_stub.ServerlessSpec = object
    sys.modules["pinecone"] = pinecone_stub

from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_auth_service import SocialAuthService
from app.services.social_scraper_service import SocialScraperService


@pytest.mark.asyncio
async def test_accept_oauth_auth_requires_owned_job(monkeypatch):
    calls = {"store": 0, "update": 0}

    async def fake_get_job(db, *, job_id, user_id):  # noqa: ANN001
        return None

    async def fake_store_oauth_session(*args, **kwargs):  # noqa: ANN001
        calls["store"] += 1

    async def fake_update_job(*args, **kwargs):  # noqa: ANN001
        calls["update"] += 1
        return {"id": "job-1"}

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(fake_get_job))
    monkeypatch.setattr(SocialAuthService, "store_oauth_session", staticmethod(fake_store_oauth_session))
    monkeypatch.setattr(SocialImportJobStore, "update_job", staticmethod(fake_update_job))

    service = SocialImportPipelineService(user_id="user-1", db=object())
    with pytest.raises(SocialImportJobNotFoundError):
        await service.accept_auth(
            "job-1",
            "oauth",
            {"provider_access_token": "token-1234567890"},
        )

    assert calls["store"] == 0
    assert calls["update"] == 0


@pytest.mark.asyncio
async def test_accept_auth_rejects_terminal_jobs(monkeypatch):
    calls = {"store": 0, "update": 0, "schedule": 0}

    async def fake_get_job(db, *, job_id, user_id):  # noqa: ANN001
        return {"id": job_id, "status": "cancelled", "metadata": {}}

    async def fake_store_oauth_session(*args, **kwargs):  # noqa: ANN001
        calls["store"] += 1

    async def fake_update_job(*args, **kwargs):  # noqa: ANN001
        calls["update"] += 1
        return {"id": "job-1"}

    async def fake_schedule_job(cls, service, job_id):  # noqa: ANN001
        calls["schedule"] += 1

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(fake_get_job))
    monkeypatch.setattr(
        SocialAuthService,
        "store_oauth_session",
        staticmethod(fake_store_oauth_session),
    )
    monkeypatch.setattr(SocialImportJobStore, "update_job", staticmethod(fake_update_job))
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job)
    )

    service = SocialImportPipelineService(user_id="user-1", db=object())
    with pytest.raises(SocialImportError, match="terminal state"):
        await service.accept_auth(
            "job-1",
            "oauth",
            {"provider_access_token": "token-1234567890"},
        )

    assert calls["store"] == 0
    assert calls["update"] == 0
    assert calls["schedule"] == 0


@pytest.mark.asyncio
async def test_accept_auth_does_not_reschedule_when_job_not_awaiting_auth(monkeypatch):
    calls = {"store": 0, "update": 0, "publish": 0, "schedule": 0}

    async def fake_get_job(db, *, job_id, user_id):  # noqa: ANN001
        return {"id": job_id, "status": "processing", "metadata": {}}

    async def fake_store_oauth_session(*args, **kwargs):  # noqa: ANN001
        calls["store"] += 1

    async def fake_update_job(*args, **kwargs):  # noqa: ANN001
        calls["update"] += 1
        return {"id": "job-1"}

    async def fake_publish(*args, **kwargs):  # noqa: ANN001
        calls["publish"] += 1
        return {}

    async def fake_schedule_job(cls, service, job_id):  # noqa: ANN001
        calls["schedule"] += 1

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(fake_get_job))
    monkeypatch.setattr(
        SocialAuthService,
        "store_oauth_session",
        staticmethod(fake_store_oauth_session),
    )
    monkeypatch.setattr(SocialImportJobStore, "update_job", staticmethod(fake_update_job))
    monkeypatch.setattr(SocialImportEventService, "publish", staticmethod(fake_publish))
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job)
    )

    service = SocialImportPipelineService(user_id="user-1", db=object())
    await service.accept_auth(
        "job-1",
        "oauth",
        {"provider_access_token": "token-1234567890"},
    )

    assert calls["store"] == 1
    assert calls["update"] == 0
    assert calls["publish"] == 1
    assert calls["schedule"] == 0


@pytest.mark.asyncio
async def test_try_resume_rate_limited_job_when_limits_reset(monkeypatch):
    update_calls = []
    publish_calls = []
    schedule_calls = []

    async def fake_check_rate_limit(user_id, operation_type, db, count=1):  # noqa: ANN001
        return {"allowed": True, "remaining": 100, "limit": 100, "current_count": 0}

    async def fake_update_job(db, *, job_id, user_id, updates):  # noqa: ANN001
        update_calls.append({"job_id": job_id, "user_id": user_id, "updates": dict(updates)})
        return {"id": job_id, **updates}

    async def fake_publish(db, *, job_id, user_id, event_type, payload):  # noqa: ANN001
        publish_calls.append({"job_id": job_id, "event_type": event_type, "payload": dict(payload)})
        return {}

    async def fake_schedule_job(cls, service, job_id):  # noqa: ANN001
        schedule_calls.append(job_id)

    monkeypatch.setattr(AISettingsService, "check_rate_limit", staticmethod(fake_check_rate_limit))
    monkeypatch.setattr(SocialImportJobStore, "update_job", staticmethod(fake_update_job))
    monkeypatch.setattr(SocialImportEventService, "publish", staticmethod(fake_publish))
    monkeypatch.setattr(SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job))

    service = SocialImportPipelineService(user_id="user-1", db=object())
    resumed = await service._try_resume_rate_limited_job("job-1")

    assert resumed is True
    assert update_calls
    assert update_calls[0]["updates"]["status"] == "processing"
    assert publish_calls
    assert publish_calls[0]["event_type"] == "job_updated"
    assert schedule_calls == ["job-1"]


def test_rate_limit_pause_message_includes_queue_referral_and_upgrade():
    message = SocialImportPipelineService._build_rate_limit_pause_message("generation")
    assert "queued" in message.lower()
    assert "refer" in message.lower()
    assert "upgrade" in message.lower()


@pytest.mark.asyncio
async def test_discover_all_photos_handles_none_result_without_attribute_error(
    monkeypatch,
):
    async def fake_get_job(db, *, job_id, user_id):  # noqa: ANN001
        return {
            "id": job_id,
            "normalized_url": "https://www.instagram.com/example/",
            "platform": "instagram",
            "discovered_photos": 0,
            "metadata": {},
        }

    async def fake_set_job_status(*args, **kwargs):  # noqa: ANN001
        return None

    async def fake_update_job(*args, **kwargs):  # noqa: ANN001
        return {}

    async def fake_get_active_session(*args, **kwargs):  # noqa: ANN001
        return None

    async def fake_discover_profile_photos(*args, **kwargs):  # noqa: ANN001
        return None

    monkeypatch.setattr(SocialImportJobStore, "get_job", staticmethod(fake_get_job))
    monkeypatch.setattr(SocialImportJobStore, "set_job_status", staticmethod(fake_set_job_status))
    monkeypatch.setattr(SocialImportJobStore, "update_job", staticmethod(fake_update_job))
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService,
        "discover_profile_photos",
        staticmethod(fake_discover_profile_photos),
    )

    service = SocialImportPipelineService(user_id="user-1", db=object())
    service.DISCOVERY_RETRY_ATTEMPTS = 1
    monkeypatch.setattr(service, "_publish_event", fake_update_job)

    with pytest.raises(RuntimeError, match="Photo discovery failed"):
        await service._discover_all_photos("job-1")


@pytest.mark.asyncio
async def test_approve_photo_continues_when_one_item_save_fails(monkeypatch):
    update_item_calls = []

    async def fake_get_photo(db, *, job_id, user_id, photo_id):  # noqa: ANN001
        return {"id": photo_id}

    async def fake_list_items_for_photo(db, *, job_id, photo_id, user_id):  # noqa: ANN001
        return [
            {"id": "item-1", "status": "generated"},
            {"id": "item-2", "status": "generated"},
        ]

    async def fake_update_item(db, *, job_id, photo_id, item_id, user_id, updates):  # noqa: ANN001
        update_item_calls.append({"item_id": item_id, "updates": dict(updates)})
        return {"id": item_id, **updates}

    async def fake_noop(*args, **kwargs):  # noqa: ANN001
        return {}

    async def fake_schedule_job(cls, service, job_id):  # noqa: ANN001
        return None

    async def fake_save(item):  # noqa: ANN001
        if item["id"] == "item-1":
            raise RuntimeError("storage error")
        return "saved-item-2"

    monkeypatch.setattr(SocialImportJobStore, "get_photo", staticmethod(fake_get_photo))
    monkeypatch.setattr(
        SocialImportJobStore,
        "list_items_for_photo",
        staticmethod(fake_list_items_for_photo),
    )
    monkeypatch.setattr(SocialImportJobStore, "update_item", staticmethod(fake_update_item))
    monkeypatch.setattr(SocialImportJobStore, "update_photo", staticmethod(fake_noop))
    monkeypatch.setattr(SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job))

    service = SocialImportPipelineService(user_id="user-1", db=object())
    monkeypatch.setattr(service, "_publish_event", fake_noop)
    monkeypatch.setattr(service, "_promote_buffered_if_available", fake_noop)
    monkeypatch.setattr(service, "_sync_job_counters", fake_noop)
    monkeypatch.setattr(service, "_save_item_from_social_item", fake_save)

    result = await service.approve_photo("job-1", "photo-1")

    assert result["saved_count"] == 1
    failed_item = next(call for call in update_item_calls if call["item_id"] == "item-1")
    assert failed_item["updates"]["status"] == "failed"
    saved_item = next(call for call in update_item_calls if call["item_id"] == "item-2")
    assert saved_item["updates"]["status"] == "saved"
