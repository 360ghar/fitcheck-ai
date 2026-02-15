import sys
import types

import pytest

from app.core.exceptions import SocialImportJobNotFoundError
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
