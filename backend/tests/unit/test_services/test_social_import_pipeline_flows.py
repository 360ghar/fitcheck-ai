"""Flow-level tests for SocialImportPipelineService.

Complements test_social_import_pipeline_service.py (auth/resume/spawn paths)
by driving the orchestration flows themselves: run() lifecycle, photo
discovery pagination + auth gating, the queue loop, per-photo processing
(reservation/release, generation, capacity exhaustion), approve/reject,
job completion/cancellation, and the save-item/embedding path.

Style: collaborator classes (JobStore, AuthService, ScraperService,
EventService, AISettingsService, StorageService, agents) are replaced with
async fakes via monkeypatch + staticmethod, matching the convention in the
sibling test file. No network, no real timers (capacity-retry sleep is
patched).
"""

from __future__ import annotations

import asyncio
import sys
import types
from types import SimpleNamespace

import httpx
import pytest

import app.services.social_import_pipeline_service as pipeline_mod
from app.core.exceptions import (
    SocialImportAuthRequiredError,
    SocialImportJobNotFoundError,
)
from app.models.social_import import (
    SocialImportItemStatus,
    SocialImportJobStatus,
    SocialImportPhotoStatus,
)
from app.models.subscription import OperationType
from app.services.ai_settings_service import AISettingsService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_auth_service import SocialAuthService
from app.services.social_scraper_service import SocialScraperService
from app.services.storage_service import StorageService

if "pinecone" not in sys.modules:
    pinecone_stub = types.ModuleType("pinecone")
    pinecone_stub.Pinecone = object
    pinecone_stub.ServerlessSpec = object
    sys.modules["pinecone"] = pinecone_stub


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def make_job(**overrides):
    """A realistic social_import_jobs row."""
    job = {
        "id": "job-1",
        "user_id": "user-1",
        "status": SocialImportJobStatus.PROCESSING.value,
        "platform": "instagram",
        "source_url": "https://www.instagram.com/example/",
        "normalized_url": "https://www.instagram.com/example/",
        "discovered_photos": 0,
        "total_photos": 0,
        "processed_photos": 0,
        "approved_photos": 0,
        "rejected_photos": 0,
        "failed_photos": 0,
        "auth_required": False,
        "discovery_completed": False,
        "error_message": None,
        "metadata": {},
    }
    job.update(overrides)
    return job


def make_photo(**overrides):
    photo = {
        "id": "photo-1",
        "job_id": "job-1",
        "user_id": "user-1",
        "ordinal": 1,
        "status": SocialImportPhotoStatus.PROCESSING.value,
        "source_photo_url": "https://example.com/photo.jpg",
    }
    photo.update(overrides)
    return photo


def make_discovery_result(**overrides):
    """A DiscoverPhotosResult-shaped fake (plain namespace is fine)."""
    data = {
        "requires_auth": False,
        "photos": [],
        "next_cursor": None,
        "exhausted": True,
        "metadata": {},
    }
    data.update(overrides)
    return SimpleNamespace(**data)


def make_service(user_id="user-1", db=None):
    service = SocialImportPipelineService(user_id=user_id, db=db or SimpleNamespace())
    # Keep any accidentally-untouched sleeps instant rather than 300s.
    service.CAPACITY_RETRY_DELAY_SECONDS = 0
    return service


def patch_store(monkeypatch, **fakes):
    """Install async fakes on SocialImportJobStore methods."""
    for name, fake in fakes.items():
        monkeypatch.setattr(SocialImportJobStore, name, staticmethod(fake))


def patch_event(monkeypatch, fake=None):
    events = []

    async def _publish(db, *, job_id, user_id, event_type, payload):
        events.append({"job_id": job_id, "event_type": event_type, "payload": payload})

    monkeypatch.setattr(SocialImportEventService, "publish", staticmethod(fake or _publish))
    return events


# ---------------------------------------------------------------------------
# Task lifecycle: schedule / cancel / cleanup
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_schedule_job_starts_run_and_dedupes(monkeypatch):
    runs = []

    async def fake_run(self, job_id):
        runs.append(job_id)
        await asyncio.sleep(0)

    monkeypatch.setattr(SocialImportPipelineService, "run", fake_run)
    service = make_service()

    await SocialImportPipelineService.schedule_job(service, "job-sched")
    # Let the created task start.
    await asyncio.sleep(0)
    # Second schedule while the first is still pending must not create a new task.
    await SocialImportPipelineService.schedule_job(service, "job-sched")
    await asyncio.sleep(0)

    assert runs == ["job-sched"]
    task = SocialImportPipelineService._tasks.get("job-sched")
    assert task is not None
    await task
    await SocialImportPipelineService._cleanup_job_resources("job-sched")


@pytest.mark.asyncio
async def test_schedule_job_replaces_finished_task(monkeypatch):
    runs = []

    async def fake_run(self, job_id):
        runs.append(job_id)

    monkeypatch.setattr(SocialImportPipelineService, "run", fake_run)
    service = make_service()

    await SocialImportPipelineService.schedule_job(service, "job-sched2")
    await asyncio.sleep(0)
    await SocialImportPipelineService._tasks["job-sched2"]
    # The first task is done; scheduling again must create a fresh one.
    await SocialImportPipelineService.schedule_job(service, "job-sched2")
    await asyncio.sleep(0)
    await SocialImportPipelineService._tasks["job-sched2"]

    assert runs == ["job-sched2", "job-sched2"]
    await SocialImportPipelineService._cleanup_job_resources("job-sched2")


@pytest.mark.asyncio
async def test_cancel_scheduled_job_cancels_pending_task(monkeypatch):
    async def fake_run(self, job_id):
        await asyncio.sleep(3600)

    monkeypatch.setattr(SocialImportPipelineService, "run", fake_run)
    service = make_service()
    await SocialImportPipelineService.schedule_job(service, "job-cancel")
    await asyncio.sleep(0)

    await SocialImportPipelineService.cancel_scheduled_job("job-cancel")
    task = SocialImportPipelineService._tasks.get("job-cancel")
    assert task is None
    # The cancelled task reference is gone; nothing left to clean.
    assert "job-cancel" not in SocialImportPipelineService._tasks


@pytest.mark.asyncio
async def test_cancel_scheduled_job_noop_when_absent():
    await SocialImportPipelineService.cancel_scheduled_job("job-absent")


@pytest.mark.asyncio
async def test_cleanup_all_finished_tasks_removes_done_entries(monkeypatch):
    async def fake_run(self, job_id):
        return None

    monkeypatch.setattr(SocialImportPipelineService, "run", fake_run)
    service = make_service()
    await SocialImportPipelineService.schedule_job(service, "job-a")
    await SocialImportPipelineService.schedule_job(service, "job-b")
    await asyncio.sleep(0)
    await asyncio.gather(*SocialImportPipelineService._tasks.values())

    SocialImportPipelineService._cleanup_all_finished_tasks()
    assert "job-a" not in SocialImportPipelineService._tasks
    assert "job-b" not in SocialImportPipelineService._tasks


@pytest.mark.asyncio
async def test_schedule_capacity_retry_reschedules_after_sleep(monkeypatch):
    scheduled = []

    async def fake_schedule_job(cls, service, job_id):
        scheduled.append(job_id)

    monkeypatch.setattr(asyncio, "sleep", lambda seconds: _instant_sleep())
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job)
    )
    service = make_service()
    await service._schedule_capacity_retry("job-1")
    assert scheduled == ["job-1"]


async def _instant_sleep():
    return None


async def _completed():
    return None


@pytest.mark.asyncio
async def test_schedule_capacity_retry_returns_on_cancellation(monkeypatch):
    async def fake_sleep(seconds):
        raise asyncio.CancelledError

    scheduled = []

    async def fake_schedule_job(cls, service, job_id):
        scheduled.append(job_id)

    monkeypatch.setattr(asyncio, "sleep", fake_sleep)
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job)
    )
    service = make_service()
    await service._schedule_capacity_retry("job-1")
    assert scheduled == []


@pytest.mark.asyncio
async def test_publish_event_forwards_to_event_service(monkeypatch):
    events = []

    async def fake_publish(db, *, job_id, user_id, event_type, payload):
        events.append((job_id, user_id, event_type, payload))

    monkeypatch.setattr(SocialImportEventService, "publish", staticmethod(fake_publish))
    service = make_service()
    await service._publish_event("job-1", "job_updated", {"status": "processing"})
    assert events == [("job-1", "user-1", "job_updated", {"status": "processing"})]


# ---------------------------------------------------------------------------
# run() lifecycle
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_run_job_not_found_cleans_up(monkeypatch):
    cleaned = []

    async def fake_get_job(db, *, job_id, user_id):
        return None

    async def fake_cleanup(cls, job_id):
        cleaned.append(job_id)

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(
        SocialImportPipelineService, "_cleanup_job_resources", classmethod(fake_cleanup)
    )
    service = make_service()
    await service.run("job-1")
    assert cleaned == ["job-1"]


@pytest.mark.asyncio
async def test_run_terminal_state_returns(monkeypatch):
    cleaned = []
    ran_queue = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(status=SocialImportJobStatus.COMPLETED.value)

    async def fake_cleanup(cls, job_id):
        cleaned.append(job_id)

    async def fake_run_queue(self, job_id):
        ran_queue.append(job_id)

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(
        SocialImportPipelineService, "_cleanup_job_resources", classmethod(fake_cleanup)
    )
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")
    assert cleaned == ["job-1"]
    assert ran_queue == []


@pytest.mark.asyncio
async def test_run_happy_path_discover_then_queue(monkeypatch):
    patch_event(monkeypatch)
    discovered = []
    queued = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_discover(self, job_id):
        discovered.append(job_id)

    async def fake_run_queue(self, job_id):
        queued.append(job_id)

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(SocialImportPipelineService, "_discover_all_photos", fake_discover)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")
    assert discovered == ["job-1"]
    assert queued == ["job-1"]
    # The lock/task state must be cleaned up after the run.
    assert "job-1" not in SocialImportPipelineService._locks


@pytest.mark.asyncio
async def test_run_discovery_failure_path(monkeypatch):
    """After discovery the job may already be FAILED; run must return quietly."""
    calls = {"get": 0}
    patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        calls["get"] += 1
        if calls["get"] == 1:
            return make_job()
        return make_job(status=SocialImportJobStatus.FAILED.value)

    async def fake_discover(self, job_id):
        return None

    async def fake_run_queue(self, job_id):
        raise AssertionError("queue must not run after discovery failure")

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(SocialImportPipelineService, "_discover_all_photos", fake_discover)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")
    assert calls["get"] == 2


@pytest.mark.asyncio
async def test_run_awaiting_auth_returns_without_queue(monkeypatch):
    patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(
            discovery_completed=True, status=SocialImportJobStatus.AWAITING_AUTH.value
        )

    async def fake_run_queue(self, job_id):
        raise AssertionError("queue must not run while awaiting auth")

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")


@pytest.mark.asyncio
async def test_run_surfaces_auth_required_and_returns(monkeypatch):
    events = patch_event(monkeypatch)
    failed = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(discovery_completed=True)

    async def fake_run_queue(self, job_id):
        raise SocialImportAuthRequiredError()

    async def fake_set_failed(*args, **kwargs):
        failed.append(args)

    patch_store(monkeypatch, get_job=fake_get_job, set_job_status=fake_set_failed)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")
    assert failed == []
    assert not [e for e in events if e["event_type"] == "job_failed"]


@pytest.mark.asyncio
async def test_run_exception_marks_job_failed_and_publishes(monkeypatch):
    events = patch_event(monkeypatch)
    status_updates = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(discovery_completed=True)

    async def fake_run_queue(self, job_id):
        raise ValueError("boom")

    async def fake_set_job_status(db, *, job_id, user_id, status, error_message=None, **kwargs):
        status_updates.append((status, error_message))

    patch_store(monkeypatch, get_job=fake_get_job, set_job_status=fake_set_job_status)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")

    assert status_updates == [
        (SocialImportJobStatus.FAILED, "boom"),
    ]
    failed_events = [e for e in events if e["event_type"] == "job_failed"]
    assert failed_events and failed_events[0]["payload"]["error"] == "boom"


@pytest.mark.asyncio
async def test_run_re_raises_cancelled(monkeypatch):
    events = patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(discovery_completed=True)

    async def fake_run_queue(self, job_id):
        raise asyncio.CancelledError

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    with pytest.raises(asyncio.CancelledError):
        await service.run("job-1")
    # Cancelled jobs must not be marked failed.
    assert not [e for e in events if e["event_type"] == "job_failed"]


# ---------------------------------------------------------------------------
# _discover_all_photos
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_job_missing_raises(monkeypatch):
    async def fake_get_job(db, *, job_id, user_id):
        return None

    patch_store(monkeypatch, get_job=fake_get_job)
    service = make_service()
    with pytest.raises(SocialImportJobNotFoundError):
        await service._discover_all_photos("job-1")


@pytest.mark.asyncio
async def test_discover_all_photos_paginates_and_completes(monkeypatch):
    """Two cursor pages, then exhausted: photos inserted, status PROCESSING."""
    events = patch_event(monkeypatch)
    inserted = []
    updated = []
    statuses = []
    discover_calls = {"count": 0}

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(db, *, job_id, user_id, status, error_message=None, **kwargs):
        statuses.append(status)

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        discover_calls["count"] += 1
        if discover_calls["count"] == 1:
            return make_discovery_result(
                photos=[SimpleNamespace(model_dump=lambda: {"id": "p1"})],
                next_cursor="cursor-2",
                exhausted=False,
            )
        return make_discovery_result(
            photos=[SimpleNamespace(model_dump=lambda: {"id": "p2"})],
            next_cursor=None,
            exhausted=True,
        )

    async def fake_add_discovered_photos(db, *, job_id, user_id, start_ordinal, photos):
        inserted.append((start_ordinal, [p["id"] for p in photos]))
        return [{"id": p["id"]} for p in photos]

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=fake_add_discovered_photos,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(
        SocialImportPipelineService, "_persist_scraper_session_from_payload",
        lambda self, **kwargs: _noop(),
    )

    service = make_service()
    await service._discover_all_photos("job-1")

    assert [o for o, _ in inserted] == [1, 2]
    assert inserted[0][1] == ["p1"] and inserted[1][1] == ["p2"]
    assert statuses == [SocialImportJobStatus.DISCOVERING.value]
    final_update = updated[-1]
    assert final_update["discovery_completed"] is True
    assert final_update["status"] == SocialImportJobStatus.PROCESSING.value
    photo_events = [e for e in events if e["event_type"] == "photo_discovered"]
    assert len(photo_events) == 2


async def _noop():
    return None


@pytest.mark.asyncio
async def test_discover_all_photos_auth_required_persists_two_factor(monkeypatch):
    events = patch_event(monkeypatch)
    stored_sessions = []
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return {
            "session_payload": {
                "username": "ada",
                "password": "pw",
                "sessionid": "sid",
                "csrftoken": "csrf",
                "ds_user_id": "123",
            }
        }

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        return make_discovery_result(
            requires_auth=True,
            metadata={
                "reason": "login_required",
                "two_factor_identifier": "2fa-token",
                "message": "OTP needed",
            },
        )

    async def fake_store_scraper_session(
        db, *, job_id, user_id, username, password, otp_code,
        two_factor_identifier, sessionid, csrftoken, ds_user_id,
    ):
        stored_sessions.append(
            (username, password, two_factor_identifier, sessionid, csrftoken, ds_user_id)
        )

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialAuthService, "store_scraper_session", staticmethod(fake_store_scraper_session)
    )
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(
        SocialImportPipelineService, "_persist_scraper_session_from_payload",
        lambda self, **kwargs: _noop(),
    )

    service = make_service()
    with pytest.raises(SocialImportAuthRequiredError):
        await service._discover_all_photos("job-1")

    assert stored_sessions == [("ada", "pw", "2fa-token", "sid", "csrf", "123")]
    auth_update = updated[0]
    assert auth_update["status"] == SocialImportJobStatus.AWAITING_AUTH.value
    assert auth_update["auth_required"] is True
    assert auth_update["metadata"]["two_factor_identifier"] == "2fa-token"
    auth_events = [e for e in events if e["event_type"] == "auth_required"]
    assert auth_events and auth_events[0]["payload"]["two_factor_identifier"] == "2fa-token"


@pytest.mark.asyncio
async def test_discover_all_photos_auth_required_without_session_payload(monkeypatch):
    """Auth required with no session payload must not crash persisting 2FA."""
    events = patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        return make_discovery_result(
            requires_auth=True,
            metadata={"reason": "login_required", "checkpoint_url": "https://cp"},
        )

    async def fake_update_job(db, *, job_id, user_id, updates):
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(
        SocialImportPipelineService, "_persist_scraper_session_from_payload",
        lambda self, **kwargs: _noop(),
    )

    service = make_service()
    with pytest.raises(SocialImportAuthRequiredError):
        await service._discover_all_photos("job-1")

    auth_events = [e for e in events if e["event_type"] == "auth_required"]
    assert auth_events[0]["payload"]["checkpoint_url"] == "https://cp"
    assert "two_factor_identifier" not in auth_events[0]["payload"]


@pytest.mark.asyncio
async def test_discover_all_photos_surfaces_discovery_failure(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        return make_discovery_result(
            photos=[],
            metadata={"error_type": "fetch_failure", "message": "network down"},
        )

    async def fake_with_retry(coro, **kwargs):
        # The real _discover converts metadata errors into raised exceptions;
        # simulate the retry cycle completing with the failure surfaced in the
        # result metadata so the post-retry FAILED path is exercised.
        return make_discovery_result(
            photos=[],
            metadata={"error_type": "fetch_failure", "message": "network down"},
        )

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(pipeline_mod, "with_retry", fake_with_retry)
    monkeypatch.setattr(
        SocialImportPipelineService, "_persist_scraper_session_from_payload",
        lambda self, **kwargs: _noop(),
    )

    service = make_service()
    await service._discover_all_photos("job-1")

    fail_update = updated[0]
    assert fail_update["status"] == SocialImportJobStatus.FAILED.value
    assert fail_update["error_message"] == "network down"
    assert fail_update["metadata"]["discovery_failure"] is True
    failed_events = [e for e in events if e["event_type"] == "job_failed"]
    assert failed_events and failed_events[0]["payload"]["retryable"] is True


@pytest.mark.asyncio
async def test_discover_all_photos_wraps_retry_exhaustion(monkeypatch):
    """If with_retry gives up, discovery failure is wrapped in RuntimeError."""
    patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_with_retry(*args, **kwargs):
        raise RuntimeError("repeated failure")

    patch_store(monkeypatch, get_job=fake_get_job, set_job_status=fake_set_job_status)
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(pipeline_mod, "with_retry", fake_with_retry)

    service = make_service()
    with pytest.raises(RuntimeError, match="Photo discovery failed after retries"):
        await service._discover_all_photos("job-1")


@pytest.mark.asyncio
async def test_discover_all_photos_uses_retry_on_transient_result(monkeypatch):
    """A fetch_failure metadata result is turned into a retried exception."""
    patch_event(monkeypatch)
    attempts = {"count": 0}

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        attempts["count"] += 1
        return make_discovery_result(
            metadata={"error_type": "discovery_failure", "message": "flaky"},
        )

    captured = {}

    async def fake_with_retry(coro, **kwargs):
        captured["on_retry"] = kwargs.get("on_retry")
        try:
            await coro()
        except RuntimeError as e:
            captured["error"] = str(e)
            raise e

    patch_store(monkeypatch, get_job=fake_get_job, set_job_status=fake_set_job_status)
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(pipeline_mod, "with_retry", fake_with_retry)

    service = make_service()
    with pytest.raises(RuntimeError, match="Photo discovery failed"):
        await service._discover_all_photos("job-1")
    assert "flaky" in captured["error"]


@pytest.mark.asyncio
async def test_discover_all_photos_hits_max_photo_cap(monkeypatch):
    events = patch_event(monkeypatch)
    service = make_service()
    service.MAX_DISCOVERY_PHOTOS = 3
    discover_calls = {"count": 0}
    final_updates = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        discover_calls["count"] += 1
        return make_discovery_result(
            photos=[SimpleNamespace(model_dump=lambda: {"id": f"p{i}"}) for i in range(3)],
            next_cursor="cursor-next",
            exhausted=False,
        )

    async def fake_add_discovered_photos(db, *, job_id, user_id, start_ordinal, photos):
        return [{"id": p["id"]} for p in photos]

    async def fake_update_job(db, *, job_id, user_id, updates):
        final_updates.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=fake_add_discovered_photos,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(
        SocialScraperService, "discover_profile_photos", staticmethod(fake_discover)
    )
    monkeypatch.setattr(
        SocialImportPipelineService, "_persist_scraper_session_from_payload",
        lambda self, **kwargs: _noop(),
    )

    await service._discover_all_photos("job-1")

    # The cap (MAX_DISCOVERY_PHOTOS=3) stops the loop after the first page:
    # exactly 3 photos are added and no further pages are fetched.
    assert discover_calls["count"] == 1
    # The 3-photo page fills the cap, so the loop breaks before the
    # photo_discovered event is emitted; discovery then completes normally.
    assert not [e for e in events if e["event_type"] == "photo_discovered"]
    final_update = final_updates[-1]
    assert final_update["discovery_completed"] is True
    assert final_update["status"] == SocialImportJobStatus.PROCESSING.value
    assert "discovery_cursor" not in final_update["metadata"]


# ---------------------------------------------------------------------------
# _persist_scraper_session_from_payload
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_persist_session_skips_without_session(monkeypatch):
    stored = []

    async def fake_store(**kwargs):
        stored.append(kwargs)

    monkeypatch.setattr(SocialAuthService, "store_scraper_session", staticmethod(fake_store))
    service = make_service()
    await service._persist_scraper_session_from_payload(job_id="job-1", auth_session=None)
    assert stored == []


@pytest.mark.asyncio
async def test_persist_session_skips_without_credentials(monkeypatch):
    stored = []

    async def fake_store(**kwargs):
        stored.append(kwargs)

    monkeypatch.setattr(SocialAuthService, "store_scraper_session", staticmethod(fake_store))
    service = make_service()
    await service._persist_scraper_session_from_payload(
        job_id="job-1", auth_session={"session_payload": {"username": "ada"}}
    )
    assert stored == []


@pytest.mark.asyncio
async def test_persist_session_skips_without_artifacts(monkeypatch):
    stored = []

    async def fake_store(**kwargs):
        stored.append(kwargs)

    monkeypatch.setattr(SocialAuthService, "store_scraper_session", staticmethod(fake_store))
    service = make_service()
    await service._persist_scraper_session_from_payload(
        job_id="job-1",
        auth_session={"session_payload": {"username": "ada", "password": "pw"}},
    )
    assert stored == []


@pytest.mark.asyncio
async def test_persist_session_stores_artifacts(monkeypatch):
    stored = []

    async def fake_store(
        db, *, job_id, user_id, username, password, otp_code,
        two_factor_identifier, sessionid, csrftoken, ds_user_id,
    ):
        stored.append(
            (username, password, otp_code, two_factor_identifier, sessionid, csrftoken, ds_user_id)
        )

    monkeypatch.setattr(SocialAuthService, "store_scraper_session", staticmethod(fake_store))
    service = make_service()
    await service._persist_scraper_session_from_payload(
        job_id="job-1",
        auth_session={
            "session_payload": {
                "username": "ada",
                "password": "pw",
                "sessionid": "sid",
                "csrftoken": "csrf",
                "otp_code": "123456",
            }
        },
    )
    assert stored == [("ada", "pw", "123456", None, "sid", "csrf", None)]


@pytest.mark.asyncio
async def test_persist_session_store_failure_is_swallowed(monkeypatch, caplog):
    async def fake_store(**kwargs):
        raise RuntimeError("db down")

    monkeypatch.setattr(SocialAuthService, "store_scraper_session", staticmethod(fake_store))
    service = make_service()
    # Must not raise; the failure is only logged.
    await service._persist_scraper_session_from_payload(
        job_id="job-1",
        auth_session={
            "session_payload": {"username": "ada", "password": "pw", "sessionid": "sid"}
        },
    )


# ---------------------------------------------------------------------------
# _run_queue
# ---------------------------------------------------------------------------


def patch_queue_collaborators(monkeypatch, job, slots, *, claimed=None, processed=False):
    """Common fakes for _run_queue tests: get_job/get_slots/claim/update_photo."""
    slots = {"awaiting": None, "buffered": None, "processing": None, **slots}
    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(job),
        get_slots=_async_value(slots),
        claim_next_queued_photo=_async_value(claimed),
        update_photo=_async_value(None),
        get_photo_with_items=_async_value(None),
    )


def _async_value(value):
    async def _inner(*args, **kwargs):
        return value

    return _inner


@pytest.mark.asyncio
async def test_run_queue_capacity_exhausted_schedules_retry(monkeypatch):
    patch_event(monkeypatch)
    retried = []

    def fake_retry(job_id):
        # Record synchronously and return a completed coroutine: the real
        # _spawn_background schedules it on the loop without awaiting.
        retried.append(job_id)
        return _completed()

    service = make_service()
    service._capacity_exhausted = True
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(service, "_schedule_capacity_retry", fake_retry)
    patch_store(monkeypatch, set_job_status=_async_value(None))

    await service._run_queue("job-1")
    assert retried == ["job-1"]


async def _noop_async(*args, **kwargs):
    return None


async def _identity_photo(db, *, job_id, photo, user_id):
    return photo


@pytest.mark.asyncio
async def test_run_queue_job_missing_returns(monkeypatch):
    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(None),
    )
    service = make_service()
    await service._run_queue("job-1")


@pytest.mark.asyncio
async def test_run_queue_terminal_statuses_return(monkeypatch):
    for status in (
        SocialImportJobStatus.CANCELLED,
        SocialImportJobStatus.FAILED,
        SocialImportJobStatus.AWAITING_AUTH,
        SocialImportJobStatus.PAUSED_RATE_LIMITED,
    ):
        patch_store(
            monkeypatch,
            set_job_status=_async_value(None),
            get_job=_async_value(make_job(status=status.value)),
        )
        service = make_service()
        await service._run_queue("job-1")


@pytest.mark.asyncio
async def test_run_queue_processes_processing_slot(monkeypatch):
    processed = []
    patch_event(monkeypatch)
    get_calls = {"n": 0}

    async def fake_process(job_id, photo):
        processed.append(photo["id"])

    async def fake_get_job(db, *, job_id, user_id):
        get_calls["n"] += 1
        if get_calls["n"] > 1:
            # After the processing slot is handled, stop pumping.
            return make_job(status=SocialImportJobStatus.CANCELLED.value)
        return make_job()

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        get_slots=_async_value(
            {"awaiting": None, "buffered": None, "processing": make_photo()}
        ),
        set_job_status=_async_value(None),
    )
    service = make_service()
    monkeypatch.setattr(service, "_process_single_photo", fake_process)
    await service._run_queue("job-1")
    assert processed == ["photo-1"]


@pytest.mark.asyncio
async def test_run_queue_waits_when_queue_full(monkeypatch):
    synced = []
    patch_event(monkeypatch)

    async def fake_sync(job_id):
        synced.append(job_id)

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(make_job()),
        get_slots=_async_value(
            {
                "awaiting": make_photo(),
                "buffered": make_photo(id="photo-2"),
                "processing": None,
            }
        ),
    )
    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", fake_sync)
    await service._run_queue("job-1")
    assert synced == ["job-1"]


@pytest.mark.asyncio
async def test_run_queue_promotes_buffered_photo(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append((photo_id, dict(updates)))
        return {"id": photo_id, **updates}

    async def fake_get_photo_with_items(db, *, job_id, photo, user_id):
        return photo

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(make_job()),
        get_slots=_async_value(
            {
                "awaiting": None,
                "buffered": make_photo(id="photo-2"),
                "processing": None,
            }
        ),
        update_photo=fake_update_photo,
        get_photo_with_items=fake_get_photo_with_items,
    )
    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._run_queue("job-1")

    assert updated == [("photo-2", {"status": SocialImportPhotoStatus.AWAITING_REVIEW.value})]
    ready_events = [e for e in events if e["event_type"] == "photo_ready_for_review"]
    assert ready_events and ready_events[0]["payload"]["photo"]["id"] == "photo-2"


@pytest.mark.asyncio
async def test_run_queue_claims_and_processes_when_no_awaiting(monkeypatch):
    processed = []
    get_calls = {"n": 0}

    async def fake_process(job_id, photo):
        processed.append(photo["id"])

    async def fake_get_job(db, *, job_id, user_id):
        get_calls["n"] += 1
        if get_calls["n"] > 1:
            # Second loop iteration: stop pumping.
            return make_job(status=SocialImportJobStatus.CANCELLED.value)
        return make_job()

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=fake_get_job,
        get_slots=_async_value(
            {"awaiting": None, "buffered": None, "processing": None}
        ),
        claim_next_queued_photo=_async_value(make_photo()),
    )
    service = make_service()
    monkeypatch.setattr(service, "_process_single_photo", fake_process)
    await service._run_queue("job-1")
    assert processed == ["photo-1"]


@pytest.mark.asyncio
async def test_run_queue_claims_background_photo_while_awaiting(monkeypatch):
    processed = []
    get_calls = {"n": 0}

    async def fake_process(job_id, photo):
        processed.append(photo["id"])

    async def fake_get_job(db, *, job_id, user_id):
        get_calls["n"] += 1
        if get_calls["n"] > 1:
            return make_job(status=SocialImportJobStatus.CANCELLED.value)
        return make_job()

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=fake_get_job,
        get_slots=_async_value(
            {
                "awaiting": make_photo(id="photo-a"),
                "buffered": None,
                "processing": None,
            }
        ),
        claim_next_queued_photo=_async_value(make_photo(id="photo-b")),
    )
    service = make_service()
    monkeypatch.setattr(service, "_process_single_photo", fake_process)
    await service._run_queue("job-1")
    assert processed == ["photo-b"]


@pytest.mark.asyncio
async def test_run_queue_completes_job(monkeypatch):
    patch_event(monkeypatch)
    completed = []

    async def fake_complete(job_id):
        completed.append(job_id)

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(make_job(discovery_completed=True)),
        get_slots=_async_value(
            {"awaiting": None, "buffered": None, "processing": None}
        ),
        claim_next_queued_photo=_async_value(None),
    )
    service = make_service()
    monkeypatch.setattr(service, "_is_job_complete", _async_value(True))
    monkeypatch.setattr(service, "_complete_job", fake_complete)
    await service._run_queue("job-1")
    assert completed == ["job-1"]


@pytest.mark.asyncio
async def test_run_queue_syncs_and_returns_when_not_complete(monkeypatch):
    synced = []
    patch_event(monkeypatch)

    async def fake_sync(job_id):
        synced.append(job_id)

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(make_job(discovery_completed=True)),
        get_slots=_async_value(
            {"awaiting": None, "buffered": None, "processing": None}
        ),
        claim_next_queued_photo=_async_value(None),
    )
    service = make_service()
    monkeypatch.setattr(service, "_is_job_complete", _async_value(False))
    monkeypatch.setattr(service, "_sync_job_counters", fake_sync)
    await service._run_queue("job-1")
    assert synced == ["job-1"]


# ---------------------------------------------------------------------------
# _check_rate_limit_with_pause / _pause_for_rate_limit
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_check_rate_limit_reserved_returns_true(monkeypatch):
    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    service = make_service()
    assert await service._check_rate_limit_with_pause("job-1", OperationType.EXTRACTION) is True


@pytest.mark.asyncio
async def test_check_rate_limit_unavailable_pauses(monkeypatch):
    paused = []

    async def fake_reserve(user_id, operation_type, db, count=1):
        return False

    async def fake_pause(job_id, operation_type):
        paused.append((job_id, operation_type))

    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    service = make_service()
    monkeypatch.setattr(service, "_pause_for_rate_limit", fake_pause)
    assert await service._check_rate_limit_with_pause("job-1", OperationType.GENERATION) is False
    assert paused == [("job-1", OperationType.GENERATION)]


@pytest.mark.asyncio
async def test_pause_for_rate_limit_sets_status_and_publishes(monkeypatch):
    events = patch_event(monkeypatch)
    statuses = []

    async def fake_set_job_status(db, *, job_id, user_id, status, error_message=None, **kwargs):
        statuses.append((status, error_message))

    patch_store(monkeypatch, set_job_status=fake_set_job_status)
    service = make_service()
    await service._pause_for_rate_limit("job-1", OperationType.EXTRACTION)

    assert statuses[0][0] == SocialImportJobStatus.PAUSED_RATE_LIMITED
    assert "limit" in statuses[0][1]
    rate_events = [e for e in events if e["event_type"] == "rate_limit_paused"]
    assert rate_events and rate_events[0]["payload"]["operation_type"] == OperationType.EXTRACTION


# ---------------------------------------------------------------------------
# _process_single_photo
# ---------------------------------------------------------------------------


def patch_process_collaborators(monkeypatch, *, reserve=True, gen_reserve=True, items=None):
    """Standard fakes for _process_single_photo; override via kwargs."""

    async def fake_reserve_usage(user_id, operation_type, db, count=1):
        if operation_type == OperationType.EXTRACTION:
            return reserve
        return gen_reserve

    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve_usage))

    async def fake_fetch(url):
        return "data:image/jpeg;base64,aGVsbG8="

    monkeypatch.setattr(SocialScraperService, "fetch_photo_as_base64", staticmethod(fake_fetch))

    class FakeExtractionAgent:
        async def extract_multiple_items(self, image_base64):
            if items is None:
                raise AssertionError("unexpected extraction call")
            return {"items": items}

    class FakeGenerationAgent:
        def __init__(self):
            self.calls = []

        async def generate_product_image(self, **kwargs):
            self.calls.append(kwargs)
            return SimpleNamespace(image_base64="aGVsbG8=")

    fake_extraction = FakeExtractionAgent()
    fake_generation = FakeGenerationAgent()

    async def fake_get_extraction_agent(user_id, db):
        return fake_extraction

    async def fake_get_generation_agent(user_id, db):
        return fake_generation

    monkeypatch.setattr(pipeline_mod, "get_item_extraction_agent", fake_get_extraction_agent)
    monkeypatch.setattr(pipeline_mod, "get_image_generation_agent", fake_get_generation_agent)
    monkeypatch.setattr(
        pipeline_mod,
        "resolve_product_reference_image",
        lambda image, bbox, confidence, siblings: (image, "full"),
    )

    async def fake_upload_source(db, user_id, file_data, extension):
        return {"image_url": "https://src", "storage_path": "src-path"}

    async def fake_upload_temp(db, user_id, file_data, source):
        return {"image_url": "https://gen", "thumbnail_url": "https://thumb", "storage_path": "gen-path"}

    monkeypatch.setattr(StorageService, "upload_source_image", staticmethod(fake_upload_source))
    monkeypatch.setattr(StorageService, "upload_temp_generated_image", staticmethod(fake_upload_temp))
    return fake_extraction, fake_generation


@pytest.mark.asyncio
async def test_process_single_photo_rate_limit_blocks(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(monkeypatch, update_photo=fake_update_photo)
    patch_process_collaborators(monkeypatch, reserve=False)

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(service, "_pause_for_rate_limit", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert updated == [{"status": SocialImportPhotoStatus.QUEUED.value}]
    assert not [e for e in events if e["event_type"] == "photo_failed"]


@pytest.mark.asyncio
async def test_process_single_photo_no_items_detected(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(monkeypatch, update_photo=fake_update_photo)
    patch_process_collaborators(monkeypatch, items=[])

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert updated[0]["status"] == SocialImportPhotoStatus.FAILED.value
    assert updated[0]["error_message"] == "No clothing items detected in photo"
    failed_events = [e for e in events if e["event_type"] == "photo_failed"]
    assert failed_events and failed_events[0]["payload"]["error"] == "No items detected"


@pytest.mark.asyncio
async def test_process_single_photo_happy_path(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []
    items_upserted = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    async def fake_upsert_items(db, *, job_id, photo_id, user_id, items):
        items_upserted.append(items)

    patch_store(
        monkeypatch,
        update_photo=fake_update_photo,
        upsert_photo_items=fake_upsert_items,
        get_slots=_async_value({"awaiting": None}),
        get_photo_with_items=_identity_photo,
    )
    patch_process_collaborators(
        monkeypatch,
        items=[
            {
                "temp_id": "t1",
                "name": "Blue Shirt",
                "category": "tops",
                "sub_category": "shirt",
                "colors": ["blue"],
                "confidence": 0.9,
                "bounding_box": [1, 2, 3, 4],
            }
        ],
    )

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert items_upserted[0][0]["temp_id"] == "t1"
    assert items_upserted[0][0]["status"] == SocialImportItemStatus.GENERATED.value
    assert items_upserted[0][0]["generated_image_url"] == "https://gen"
    assert items_upserted[0][0]["source_image_url"] == "https://src"
    assert updated[0]["status"] == SocialImportPhotoStatus.AWAITING_REVIEW.value
    assert updated[0]["processing_completed_at"] is not None
    ready_events = [e for e in events if e["event_type"] == "photo_ready_for_review"]
    assert ready_events and ready_events[0]["payload"]["photo"]["id"] == "photo-1"


@pytest.mark.asyncio
async def test_process_single_photo_buffered_when_awaiting_slot(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        update_photo=fake_update_photo,
        upsert_photo_items=_noop_async,
        get_slots=_async_value({"awaiting": make_photo(id="photo-a")}),
        get_photo_with_items=_identity_photo,
    )
    patch_process_collaborators(
        monkeypatch,
        items=[{"temp_id": "t1", "category": "tops"}],
    )

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert updated[0]["status"] == SocialImportPhotoStatus.BUFFERED_READY.value
    buffered_events = [e for e in events if e["event_type"] == "photo_buffered_ready"]
    assert buffered_events


@pytest.mark.asyncio
async def test_process_single_photo_item_generation_failure(monkeypatch):
    patch_event(monkeypatch)
    items_upserted = []

    async def fake_upsert_items(db, *, job_id, photo_id, user_id, items):
        items_upserted.append(items)

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        upsert_photo_items=fake_upsert_items,
        update_photo=fake_update_photo,
        get_slots=_async_value({"awaiting": None}),
        get_photo_with_items=_identity_photo,
    )
    fake_extraction, fake_generation = patch_process_collaborators(
        monkeypatch,
        items=[{"temp_id": "t1", "category": "tops"}],
    )

    async def _fail_generation(**kwargs):
        raise RuntimeError("provider rejected")

    fake_generation.generate_product_image = _fail_generation

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    item = items_upserted[0][0]
    assert item["status"] == SocialImportItemStatus.FAILED.value
    assert "provider rejected" in item["generation_error"]
    assert not service._capacity_exhausted


@pytest.mark.asyncio
async def test_process_single_photo_capacity_exhaustion_sets_flag(monkeypatch):
    events = patch_event(monkeypatch)
    items_upserted = []

    async def fake_upsert_items(db, *, job_id, photo_id, user_id, items):
        items_upserted.append(items)

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        upsert_photo_items=fake_upsert_items,
        update_photo=fake_update_photo,
        get_slots=_async_value({"awaiting": None}),
        get_photo_with_items=_identity_photo,
    )
    fake_extraction, fake_generation = patch_process_collaborators(
        monkeypatch,
        items=[{"temp_id": "t1", "category": "tops"}],
    )

    class QuotaError(Exception):
        error_kind = "upstream_quota"
        retry_after_seconds = 30

    async def _quota_generation(**kwargs):
        raise QuotaError("quota")

    fake_generation.generate_product_image = _quota_generation

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert service._capacity_exhausted is True
    capacity_events = [e for e in events if e["event_type"] == "capacity_exhausted"]
    assert capacity_events
    assert capacity_events[0]["payload"]["error_kind"] == "upstream_quota"
    assert capacity_events[0]["payload"]["retry_after_seconds"] == 30


@pytest.mark.asyncio
async def test_process_single_photo_outer_failure_marks_photo_failed(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(monkeypatch, update_photo=fake_update_photo)

    async def fake_fetch(url):
        raise RuntimeError("network exploded")

    monkeypatch.setattr(SocialScraperService, "fetch_photo_as_base64", staticmethod(fake_fetch))
    # reserve_usage returns True so the reservation is made but never consumed.
    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    released = []

    async def fake_release(user_id, operation_type, db):
        released.append(operation_type)

    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    monkeypatch.setattr(AISettingsService, "release_usage", staticmethod(fake_release))

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert updated[0]["status"] == SocialImportPhotoStatus.FAILED.value
    assert "network exploded" in updated[0]["error_message"]
    # The un-consumed extraction reservation is returned to the daily budget.
    assert released == [OperationType.EXTRACTION]
    failed_events = [e for e in events if e["event_type"] == "photo_failed"]
    assert failed_events and failed_events[0]["payload"]["error"] == "network exploded"


@pytest.mark.asyncio
async def test_process_single_photo_release_failure_does_not_mask(monkeypatch):
    patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(monkeypatch, update_photo=fake_update_photo)

    async def fake_fetch(url):
        raise RuntimeError("network exploded")

    monkeypatch.setattr(SocialScraperService, "fetch_photo_as_base64", staticmethod(fake_fetch))

    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    async def fake_release(user_id, operation_type, db):
        raise RuntimeError("release failed too")

    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    monkeypatch.setattr(AISettingsService, "release_usage", staticmethod(fake_release))

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    # Original error must survive the failed release.
    await service._process_single_photo("job-1", make_photo())
    assert "network exploded" in updated[0]["error_message"]


@pytest.mark.asyncio
async def test_process_single_photo_generation_reserve_blocked(monkeypatch):
    """When the generation reservation fails the photo goes back to QUEUED."""
    patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(monkeypatch, update_photo=fake_update_photo)
    patch_process_collaborators(monkeypatch, items=[{"temp_id": "t1"}], gen_reserve=False)

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(service, "_pause_for_rate_limit", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert updated == [{"status": SocialImportPhotoStatus.QUEUED.value}]


@pytest.mark.asyncio
async def test_process_single_photo_source_upload_failure_degrades(monkeypatch):
    """A source-image upload failure must not fail the photo (text-only gen)."""
    patch_event(monkeypatch)
    items_upserted = []

    async def fake_upsert_items(db, *, job_id, photo_id, user_id, items):
        items_upserted.append(items)

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        upsert_photo_items=fake_upsert_items,
        update_photo=fake_update_photo,
        get_slots=_async_value({"awaiting": None}),
        get_photo_with_items=_identity_photo,
    )
    patch_process_collaborators(monkeypatch, items=[{"temp_id": "t1", "category": "tops"}])

    async def _fail_upload_source(db, user_id, file_data, extension):
        raise RuntimeError("bucket unavailable")

    monkeypatch.setattr(StorageService, "upload_source_image", staticmethod(_fail_upload_source))

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    item = items_upserted[0][0]
    assert item["status"] == SocialImportItemStatus.GENERATED.value
    assert item["source_image_url"] is None


@pytest.mark.asyncio
async def test_process_single_photo_reference_fetch_failure_degrades(monkeypatch):
    """A failed optional reference download degrades to text-only generation."""
    patch_event(monkeypatch)
    resolved = []

    async def fake_upsert_items(db, *, job_id, photo_id, user_id, items):
        return None

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        upsert_photo_items=fake_upsert_items,
        update_photo=fake_update_photo,
        get_slots=_async_value({"awaiting": None}),
        get_photo_with_items=_identity_photo,
    )

    fake_extraction, fake_generation = patch_process_collaborators(
        monkeypatch,
        items=[
            {
                "temp_id": "t1",
                "category": "tops",
                "source_image_url": "https://item-src",
            }
        ],
    )

    # Patched LAST so it wins over the helper's fetch fake: the reference
    # download (and only it) fails, degrading to text-only generation. The
    # service only treats SocialImportError/httpx transport errors as a
    # degraded reference, so raise a real httpx.RequestError subclass.
    async def fake_fetch(url):
        if url == "https://item-src":
            raise httpx.ConnectError("ref download failed")
        return "data:image/jpeg;base64,aGVsbG8="

    monkeypatch.setattr(SocialScraperService, "fetch_photo_as_base64", staticmethod(fake_fetch))

    def _resolve(image, bbox, confidence, siblings):
        resolved.append((image, bbox, confidence, siblings))
        return None, "text_only"

    monkeypatch.setattr(pipeline_mod, "resolve_product_reference_image", _resolve)

    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    assert resolved == [(None, None, 0.0, 1)]
    assert fake_generation.calls[0]["reference_image"] is None


# ---------------------------------------------------------------------------
# approve / reject / patch / cancel
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_approve_photo_skips_terminal_items(monkeypatch):
    """FAILED/DISCARDED/SAVED items are skipped and never re-saved."""
    patch_event(monkeypatch)
    update_item_calls = []

    async def fake_get_photo(db, *, job_id, user_id, photo_id):
        return make_photo()

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        return [
            {"id": "i-failed", "status": SocialImportItemStatus.FAILED.value},
            {"id": "i-discarded", "status": SocialImportItemStatus.DISCARDED.value},
            {"id": "i-saved", "status": SocialImportItemStatus.SAVED.value},
        ]

    async def fake_update_item(db, *, job_id, photo_id, item_id, user_id, updates):
        update_item_calls.append(item_id)

    async def fake_save(self, social_item):
        raise AssertionError("terminal items must not be saved")

    patch_store(
        monkeypatch,
        get_photo=fake_get_photo,
        list_items_for_photo=fake_list_items,
        update_item=fake_update_item,
        update_photo=_async_value(make_photo()),
    )
    service = make_service()
    monkeypatch.setattr(service, "_publish_event", _noop_async)
    monkeypatch.setattr(service, "_save_item_from_social_item", fake_save)
    monkeypatch.setattr(service, "_promote_buffered_if_available", _noop_async)
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(_noop_classmethod)
    )

    result = await service.approve_photo("job-1", "photo-1")
    assert result == {"saved_count": 0, "saved_items": []}
    assert update_item_calls == []


async def _noop_classmethod(cls, service, job_id):
    return None


@pytest.mark.asyncio
async def test_approve_photo_happy_path(monkeypatch):
    events = patch_event(monkeypatch)
    update_item_calls = []
    saved_items = []

    async def fake_get_photo(db, *, job_id, user_id, photo_id):
        return make_photo()

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        return [{"id": "i1", "status": SocialImportItemStatus.GENERATED.value}]

    async def fake_update_item(db, *, job_id, photo_id, item_id, user_id, updates):
        update_item_calls.append((item_id, dict(updates)))
        return {"id": item_id, **updates}

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    async def fake_save(social_item):
        saved_items.append(social_item)
        return "saved-item-1"

    patch_store(
        monkeypatch,
        get_photo=fake_get_photo,
        list_items_for_photo=fake_list_items,
        update_item=fake_update_item,
        update_photo=fake_update_photo,
    )
    service = make_service()
    monkeypatch.setattr(service, "_save_item_from_social_item", fake_save)
    monkeypatch.setattr(service, "_promote_buffered_if_available", _noop_async)
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(_noop_classmethod)
    )

    result = await service.approve_photo("job-1", "photo-1")

    assert result == {"saved_count": 1, "saved_items": [{"id": "saved-item-1", "category": None}]}
    assert update_item_calls == [("i1", {"status": SocialImportItemStatus.SAVED.value, "saved_item_id": "saved-item-1"})]
    approved_events = [e for e in events if e["event_type"] == "photo_approved"]
    assert approved_events and approved_events[0]["payload"]["saved_count"] == 1


@pytest.mark.asyncio
async def test_approve_photo_missing_photo_raises(monkeypatch):
    async def fake_get_photo(db, *, job_id, user_id, photo_id):
        return None

    patch_store(monkeypatch, get_photo=fake_get_photo)
    service = make_service()
    with pytest.raises(SocialImportJobNotFoundError):
        await service.approve_photo("job-1", "photo-1")


@pytest.mark.asyncio
async def test_reject_photo_happy_path(monkeypatch):
    events = patch_event(monkeypatch)
    cleaned = []

    async def fake_get_photo(db, *, job_id, user_id, photo_id):
        return make_photo()

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        return [
            {"id": "i1", "generated_storage_path": "gen/path-1"},
            {"id": "i2", "generated_storage_path": None},
        ]

    async def fake_cleanup(db, paths):
        cleaned.append(paths)

    async def fake_set_items(db, *, job_id, photo_id, user_id, status):
        return None

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        get_photo=fake_get_photo,
        list_items_for_photo=fake_list_items,
        set_items_status_for_photo=fake_set_items,
        update_photo=fake_update_photo,
    )
    monkeypatch.setattr(StorageService, "cleanup_temp_images", staticmethod(fake_cleanup))
    service = make_service()
    monkeypatch.setattr(service, "_promote_buffered_if_available", _noop_async)
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(_noop_classmethod)
    )

    result = await service.reject_photo("job-1", "photo-1")
    assert result == {"rejected": True}
    assert cleaned == [["gen/path-1"]]
    rejected_events = [e for e in events if e["event_type"] == "photo_rejected"]
    assert rejected_events


@pytest.mark.asyncio
async def test_patch_item_marks_edited(monkeypatch):
    captured = {}

    async def fake_update_item(db, *, job_id, photo_id, item_id, user_id, updates):
        captured["updates"] = dict(updates)
        return {"id": item_id, **updates}

    patch_store(monkeypatch, update_item=fake_update_item)
    service = make_service()
    result = await service.patch_item(
        "job-1", "photo-1", "item-1", {"name": "Renamed"}
    )
    assert captured["updates"] == {"name": "Renamed", "status": SocialImportItemStatus.EDITED.value}
    assert result["name"] == "Renamed"


@pytest.mark.asyncio
async def test_cancel_job(monkeypatch):
    events = patch_event(monkeypatch)
    calls = []

    async def fake_set_job_status(db, *, job_id, user_id, status, completed=None, **kwargs):
        calls.append(("set_status", status, completed))

    async def fake_cleanup_assets(job_id):
        calls.append(("cleanup",))

    async def fake_delete_artifacts(db, *, job_id, user_id):
        calls.append(("delete_artifacts",))

    async def fake_cancel_scheduled(cls, job_id):
        calls.append(("cancel_scheduled",))

    patch_store(
        monkeypatch,
        set_job_status=fake_set_job_status,
        delete_job_artifacts=fake_delete_artifacts,
    )
    service = make_service()
    monkeypatch.setattr(service, "_cleanup_unsaved_temp_assets", fake_cleanup_assets)
    monkeypatch.setattr(
        SocialImportPipelineService, "cancel_scheduled_job", classmethod(fake_cancel_scheduled)
    )

    await service.cancel_job("job-1")

    assert calls[0] == ("set_status", SocialImportJobStatus.CANCELLED, True)
    assert ("cleanup",) in calls
    assert ("delete_artifacts",) in calls
    assert ("cancel_scheduled",) in calls
    cancelled_events = [e for e in events if e["event_type"] == "job_cancelled"]
    assert cancelled_events


# ---------------------------------------------------------------------------
# accept_auth (scraper path + resume)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_accept_scraper_auth_merges_existing_session(monkeypatch):
    stored = []
    events = patch_event(monkeypatch)

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(
            discovery_completed=True, status=SocialImportJobStatus.AWAITING_AUTH.value
        )

    async def fake_get_active_session(db, *, job_id, user_id):
        return {
            "session_payload": {"two_factor_identifier": "existing-2fa", "sessionid": "sid"}
        }

    async def fake_store_scraper_session(db, **kwargs):
        stored.append(kwargs)

    async def fake_update_job(db, *, job_id, user_id, updates):
        return {"id": job_id, **updates}

    async def fake_schedule(cls, service, job_id):
        return None

    patch_store(monkeypatch, get_job=fake_get_job, update_job=fake_update_job)
    monkeypatch.setattr(
        SocialAuthService, "get_active_session", staticmethod(fake_get_active_session)
    )
    monkeypatch.setattr(
        SocialAuthService, "store_scraper_session", staticmethod(fake_store_scraper_session)
    )
    monkeypatch.setattr(
        SocialImportPipelineService, "schedule_job", classmethod(fake_schedule)
    )

    service = make_service()
    await service.accept_auth(
        "job-1",
        "scraper",
        {"username": "ada", "password": "pw", "otp_code": "654321"},
    )

    assert stored[0]["two_factor_identifier"] == "existing-2fa"
    assert stored[0]["sessionid"] == "sid"
    assert stored[0]["otp_code"] == "654321"
    # Job was awaiting auth -> metadata cleared, status PROCESSING, resumed.
    assert stored[0]["username"] == "ada"
    auth_events = [e for e in events if e["event_type"] == "auth_accepted"]
    assert auth_events and auth_events[0]["payload"]["auth_type"] == "scraper"


@pytest.mark.asyncio
async def test_accept_auth_update_missing_raises(monkeypatch):
    async def fake_get_job(db, *, job_id, user_id):
        return make_job(status=SocialImportJobStatus.AWAITING_AUTH.value)

    async def fake_update_job(db, *, job_id, user_id, updates):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_store_scraper_session(db, **kwargs):
        return {"id": "session-1"}

    patch_store(monkeypatch, get_job=fake_get_job, update_job=fake_update_job)
    monkeypatch.setattr(
        SocialAuthService, "get_active_session", staticmethod(fake_get_active_session)
    )
    monkeypatch.setattr(
        SocialAuthService, "store_scraper_session", staticmethod(fake_store_scraper_session)
    )
    service = make_service()
    with pytest.raises(SocialImportJobNotFoundError):
        await service.accept_auth("job-1", "scraper", {"username": "ada", "password": "pw"})


@pytest.mark.asyncio
async def test_get_status_happy_path(monkeypatch):
    job = make_job(
        discovery_completed=True,
        metadata={"auth_reason": "login_required", "two_factor_identifier": "2fa"},
    )
    slots = {"awaiting": make_photo(), "buffered": None, "processing": None}
    counts = {SocialImportPhotoStatus.QUEUED.value: 3}

    patch_store(
        monkeypatch,
        get_job=_async_value(job),
        get_slots=_async_value(slots),
        get_photo_with_items=_identity_photo,
        count_by_status=_async_value(counts),
    )
    service = make_service()
    status = await service.get_status("job-1")

    assert status["id"] == "job-1"
    assert status["status"] == SocialImportJobStatus.PROCESSING.value
    assert status["queued_count"] == 3
    assert status["auth_reason"] == "login_required"
    assert status["awaiting_review_photo"]["id"] == "photo-1"


@pytest.mark.asyncio
async def test_get_status_resumes_rate_limited_job(monkeypatch):
    calls = {"get": 0}

    async def fake_get_job(db, *, job_id, user_id):
        calls["get"] += 1
        if calls["get"] == 1:
            return make_job(status=SocialImportJobStatus.PAUSED_RATE_LIMITED.value)
        return make_job(status=SocialImportJobStatus.PROCESSING.value)

    slots = {"awaiting": None, "buffered": None, "processing": None}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        get_slots=_async_value(slots),
        get_photo_with_items=_identity_photo,
        count_by_status=_async_value({}),
    )
    service = make_service()
    monkeypatch.setattr(service, "_try_resume_rate_limited_job", _async_value(True))
    status = await service.get_status("job-1")
    assert status["status"] == SocialImportJobStatus.PROCESSING.value
    assert calls["get"] == 2


@pytest.mark.asyncio
async def test_get_status_missing_job_raises(monkeypatch):
    patch_store(monkeypatch, get_job=_async_value(None))
    service = make_service()
    with pytest.raises(SocialImportJobNotFoundError):
        await service.get_status("job-1")


# ---------------------------------------------------------------------------
# _promote_buffered_if_available / _sync_job_counters / completion
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_promote_buffered_skips_when_awaiting_slot(monkeypatch):
    patch_store(
        monkeypatch,
        get_slots=_async_value({"awaiting": make_photo(), "buffered": make_photo()}),
    )
    service = make_service()
    await service._promote_buffered_if_available("job-1")


@pytest.mark.asyncio
async def test_promote_buffered_skips_when_no_buffered(monkeypatch):
    patch_store(
        monkeypatch,
        get_slots=_async_value({"awaiting": None, "buffered": None}),
    )
    service = make_service()
    await service._promote_buffered_if_available("job-1")


@pytest.mark.asyncio
async def test_promote_buffered_promotes_and_publishes(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append((photo_id, dict(updates)))
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        get_slots=_async_value({"awaiting": None, "buffered": make_photo(id="photo-b")}),
        update_photo=fake_update_photo,
        get_photo_with_items=_identity_photo,
    )
    service = make_service()
    await service._promote_buffered_if_available("job-1")

    assert updated == [("photo-b", {"status": SocialImportPhotoStatus.AWAITING_REVIEW.value})]
    ready_events = [e for e in events if e["event_type"] == "photo_ready_for_review"]
    assert ready_events and ready_events[0]["payload"]["photo"]["id"] == "photo-b"


@pytest.mark.asyncio
async def test_sync_job_counters_aggregates(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []

    async def fake_count(db, *, job_id, user_id):
        return {
            SocialImportPhotoStatus.AWAITING_REVIEW.value: 1,
            SocialImportPhotoStatus.BUFFERED_READY.value: 1,
            SocialImportPhotoStatus.APPROVED.value: 2,
            SocialImportPhotoStatus.REJECTED.value: 1,
            SocialImportPhotoStatus.FAILED.value: 1,
            SocialImportPhotoStatus.PROCESSING.value: 0,
            SocialImportPhotoStatus.QUEUED.value: 5,
        }

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(monkeypatch, count_by_status=fake_count, update_job=fake_update_job)
    service = make_service()
    await service._sync_job_counters("job-1")

    assert updated[0]["processed_photos"] == 6
    assert updated[0]["approved_photos"] == 2
    assert updated[0]["rejected_photos"] == 1
    assert updated[0]["failed_photos"] == 1
    assert updated[0]["total_photos"] == 11
    job_events = [e for e in events if e["event_type"] == "job_updated"]
    assert job_events and job_events[0]["payload"]["queued_count"] == 5


@pytest.mark.asyncio
async def test_try_resume_rate_limited_returns_false_when_blocked(monkeypatch):
    async def fake_check(user_id, operation_type, db, count=1):
        return {"allowed": operation_type == OperationType.GENERATION}

    monkeypatch.setattr(AISettingsService, "check_rate_limit", staticmethod(fake_check))
    service = make_service()
    assert await service._try_resume_rate_limited_job("job-1") is False


@pytest.mark.asyncio
async def test_is_job_complete_variants(monkeypatch):
    async def fake_get_job(db, *, job_id, user_id):
        return make_job(discovery_completed=True)

    async def fake_count(db, *, job_id, user_id):
        return {SocialImportPhotoStatus.QUEUED.value: 0, SocialImportPhotoStatus.PROCESSING.value: 0}

    patch_store(monkeypatch, get_job=fake_get_job, count_by_status=fake_count)
    service = make_service()
    assert await service._is_job_complete("job-1") is True

    # A queued photo means not complete.
    async def fake_count2(db, *, job_id, user_id):
        return {SocialImportPhotoStatus.QUEUED.value: 1, SocialImportPhotoStatus.PROCESSING.value: 0}

    patch_store(monkeypatch, count_by_status=fake_count2)
    assert await service._is_job_complete("job-1") is False

    # Missing job means not complete.
    patch_store(monkeypatch, get_job=_async_value(None))
    assert await service._is_job_complete("job-1") is False

    # Discovery not finished means not complete.
    patch_store(monkeypatch, get_job=_async_value(make_job(discovery_completed=False)))
    assert await service._is_job_complete("job-1") is False


@pytest.mark.asyncio
async def test_complete_job(monkeypatch):
    events = patch_event(monkeypatch)
    calls = []

    async def fake_set_job_status(db, *, job_id, user_id, status, completed=None, **kwargs):
        calls.append(("set_status", status, completed))

    async def fake_cleanup_assets(job_id):
        calls.append(("cleanup",))

    async def fake_delete_artifacts(db, *, job_id, user_id):
        calls.append(("delete_artifacts",))

    patch_store(
        monkeypatch,
        set_job_status=fake_set_job_status,
        delete_job_artifacts=fake_delete_artifacts,
    )
    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    monkeypatch.setattr(service, "_cleanup_unsaved_temp_assets", fake_cleanup_assets)

    await service._complete_job("job-1")

    assert calls[0] == ("set_status", SocialImportJobStatus.COMPLETED, True)
    assert ("cleanup",) in calls
    assert ("delete_artifacts",) in calls
    completed_events = [e for e in events if e["event_type"] == "job_completed"]
    assert completed_events


@pytest.mark.asyncio
async def test_cleanup_unsaved_temp_assets_only_unsaved(monkeypatch):
    cleaned = []

    async def fake_list_photos(db, *, job_id, user_id):
        return [{"id": "photo-1"}, {"id": "photo-2"}]

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        if photo_id == "photo-1":
            return [
                {"status": SocialImportItemStatus.SAVED.value, "generated_storage_path": "saved/path"},
                {"status": SocialImportItemStatus.GENERATED.value, "generated_storage_path": "temp/path-1"},
            ]
        return [{"status": SocialImportItemStatus.GENERATED.value, "generated_storage_path": "temp/path-2"}]

    async def fake_cleanup(db, paths):
        cleaned.append(paths)

    patch_store(
        monkeypatch,
        list_photos=fake_list_photos,
        list_items_for_photo=fake_list_items,
    )
    monkeypatch.setattr(StorageService, "cleanup_temp_images", staticmethod(fake_cleanup))
    service = make_service()
    await service._cleanup_unsaved_temp_assets("job-1")
    assert cleaned == [["temp/path-1", "temp/path-2"]]


@pytest.mark.asyncio
async def test_cleanup_unsaved_temp_assets_skips_when_none(monkeypatch):
    cleaned = []

    async def fake_list_photos(db, *, job_id, user_id):
        return [{"id": "photo-1"}]

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        return [{"status": SocialImportItemStatus.SAVED.value, "generated_storage_path": "saved"}]

    async def fake_cleanup(db, paths):
        cleaned.append(paths)

    patch_store(monkeypatch, list_photos=fake_list_photos, list_items_for_photo=fake_list_items)
    monkeypatch.setattr(StorageService, "cleanup_temp_images", staticmethod(fake_cleanup))
    service = make_service()
    await service._cleanup_unsaved_temp_assets("job-1")
    assert cleaned == []


# ---------------------------------------------------------------------------
# _save_item_from_social_item + _suggest_item_name + _build_item_dict
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_save_item_skips_without_storage_path(monkeypatch):
    service = make_service(db=SimpleNamespace())
    assert await service._save_item_from_social_item({"generated_storage_path": None}) is None


@pytest.mark.asyncio
async def test_save_item_happy_path_with_embedding(monkeypatch):
    db = SimpleNamespace(inserts=[])

    class FakeTable:
        def __init__(self, name, db):
            self.name = name
            self.db = db

        def insert(self, row):
            self.db.inserts.append((self.name, row))
            return self

        def execute(self):
            return SimpleNamespace(data=[])

    def fake_table(name):
        return FakeTable(name, db)

    db.table = fake_table

    promoted = {"image_url": "https://i", "thumbnail_url": "https://t", "storage_path": "p"}

    async def fake_promote(db, user_id, temp_storage_path, filename_hint):
        return promoted

    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    async def fake_embedding(data):
        return [0.1, 0.2]

    upserted = []

    class FakeVectorService:
        async def upsert_item(self, item_id, embedding, metadata):
            upserted.append((item_id, embedding, metadata))

    monkeypatch.setattr(StorageService, "promote_temp_image_to_item", staticmethod(fake_promote))
    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    monkeypatch.setattr(pipeline_mod.AIService, "generate_item_embedding", staticmethod(fake_embedding))
    monkeypatch.setattr(pipeline_mod, "get_vector_service", lambda: FakeVectorService())

    service = make_service(db=db)
    item_id = await service._save_item_from_social_item(
        {
            "temp_id": "t1",
            "name": "Blue Shirt",
            "category": "tops",
            "colors": ["blue"],
            "generated_storage_path": "gen/path",
            "source_image_url": "https://src",
            "source_image_storage_path": "src/path",
        }
    )

    assert item_id
    tables = [name for name, _ in db.inserts]
    assert tables == ["items", "item_images"]
    items_row = dict(db.inserts[0][1])
    assert items_row["category"] == "tops"
    assert items_row["tags"] == ["social-import"]
    assert items_row["source_image_url"] == "https://src"
    assert upserted[0][0] == item_id
    assert upserted[0][1] == [0.1, 0.2]


@pytest.mark.asyncio
async def test_save_item_embedding_failure_is_best_effort(monkeypatch):
    db = SimpleNamespace()
    db.inserts = []

    class FakeTable:
        def __init__(self, name, db):
            self.name = name
            self.db = db

        def insert(self, row):
            self.db.inserts.append((self.name, row))
            return self

        def execute(self):
            return SimpleNamespace(data=[])

    def fake_table(name):
        return FakeTable(name, db)

    db.table = fake_table

    async def fake_promote(db, user_id, temp_storage_path, filename_hint):
        return {"image_url": "https://i", "thumbnail_url": "https://t", "storage_path": "p"}

    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    async def fake_embedding(data):
        raise RuntimeError("embedding provider down")

    monkeypatch.setattr(StorageService, "promote_temp_image_to_item", staticmethod(fake_promote))
    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    monkeypatch.setattr(pipeline_mod.AIService, "generate_item_embedding", staticmethod(fake_embedding))

    service = make_service(db=db)
    item_id = await service._save_item_from_social_item(
        {"temp_id": "t1", "generated_storage_path": "gen/path"}
    )
    # Item and image are still saved; embedding failure is swallowed.
    assert item_id
    assert [name for name, _ in db.inserts] == ["items", "item_images"]


@pytest.mark.asyncio
async def test_save_item_skips_embedding_when_not_reserved(monkeypatch):
    db = SimpleNamespace()
    db.inserts = []

    class FakeTable:
        def __init__(self, name, db):
            self.name = name
            self.db = db

        def insert(self, row):
            db.inserts.append((self.name, row))
            return self

        def execute(self):
            return SimpleNamespace(data=[])

    def fake_table(name):
        return FakeTable(name, db)

    db.table = fake_table

    async def fake_promote(db, user_id, temp_storage_path, filename_hint):
        return {"image_url": "https://i", "thumbnail_url": "https://t", "storage_path": "p"}

    async def fake_reserve(user_id, operation_type, db, count=1):
        return False

    called = []

    async def fake_embedding(data):
        called.append(True)
        return [1.0]

    monkeypatch.setattr(StorageService, "promote_temp_image_to_item", staticmethod(fake_promote))
    monkeypatch.setattr(AISettingsService, "reserve_usage", staticmethod(fake_reserve))
    monkeypatch.setattr(pipeline_mod.AIService, "generate_item_embedding", staticmethod(fake_embedding))

    service = make_service(db=db)
    assert await service._save_item_from_social_item({"generated_storage_path": "p"})
    assert called == []


def test_suggest_item_name_variants():
    service = make_service()
    assert service._suggest_item_name({"colors": ["blue"], "sub_category": "shirt"}) == "Blue Shirt"
    assert service._suggest_item_name({"colors": ["blue"], "category": "tops"}) == "Blue Tops"
    assert service._suggest_item_name({"sub_category": "shirt"}) == "Shirt"
    assert service._suggest_item_name({}) == "Imported Item"


def test_build_item_dict_variants():
    service = make_service()
    base = service._build_item_dict(
        {"name": "x", "category": "tops"}, "t1", SocialImportItemStatus.GENERATED
    )
    assert base["status"] == SocialImportItemStatus.GENERATED.value
    assert base["category"] == "tops"
    assert base["colors"] == []
    assert "generated_image_url" not in base

    with_urls = service._build_item_dict(
        {"name": "x"},
        "t1",
        SocialImportItemStatus.GENERATED,
        generated_urls={"image_url": "u", "thumbnail_url": "t", "storage_path": "p"},
    )
    assert with_urls["generated_image_url"] == "u"

    with_error = service._build_item_dict(
        {"name": "x"}, "t1", SocialImportItemStatus.FAILED, generation_error="oops"
    )
    assert with_error["generation_error"] == "oops"
