"""
Phase 5 coverage gaps for SocialImportPipelineService.

Fills the remaining missed statements/branches from the full-suite coverage
report (lines 194-199, 282-283, 285->512, 319, 375-376, 386, 469-470,
485->496, 501, 627->631, 978-979, 996->1012, 1087->1057, 1144, 1342->1349,
1347, 1559, 1637->1634, 1717->1738). 1330->exit is provably dead and is
marked with a pragma in the service instead.
"""

from __future__ import annotations

import sys
import types
from types import SimpleNamespace

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
# Helpers (same shape as test_social_import_pipeline_flows.py)
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


def _async_value(value):
    async def _inner(*args, **kwargs):
        return value

    return _inner


async def _noop_async(*args, **kwargs):
    return None


async def _identity_photo(db, *, job_id, photo, user_id):
    return photo


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


class _UpstreamQuotaError(RuntimeError):
    """Error shaped like an upstream capacity failure from a provider."""

    def __init__(self):
        super().__init__("upstream capacity exhausted")
        self.error_kind = "upstream_quota"
        self.retry_after_seconds = 60


# ---------------------------------------------------------------------------
# run(): job disappears after discovery (194-199)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_run_job_disappears_after_discovery(monkeypatch):
    patch_event(monkeypatch)
    calls = {"get": 0}

    async def fake_get_job(db, *, job_id, user_id):
        calls["get"] += 1
        if calls["get"] == 1:
            return make_job()
        return None

    async def fake_discover(self, job_id):
        return None

    async def fake_run_queue(self, job_id):
        raise AssertionError("queue must not run when the job vanished")

    patch_store(monkeypatch, get_job=fake_get_job)
    monkeypatch.setattr(SocialImportPipelineService, "_discover_all_photos", fake_discover)
    monkeypatch.setattr(SocialImportPipelineService, "_run_queue", fake_run_queue)
    service = make_service()
    await service.run("job-1")
    assert calls["get"] == 2
    # The lock/task state must be cleaned up after the run.
    assert "job-1" not in SocialImportPipelineService._locks


# ---------------------------------------------------------------------------
# _discover_all_photos: iteration-count guard (282-283)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_handles_malformed_iteration_count(monkeypatch):
    patch_event(monkeypatch)
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(metadata={"discovery_iteration": "not-an-int"})

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        return make_discovery_result(exhausted=True)

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=_async_value([]),
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    await service._discover_all_photos("job-1")

    # The malformed iteration value falls back to 0 and discovery completes.
    assert updated[-1]["discovery_completed"] is True


# ---------------------------------------------------------------------------
# _discover_all_photos: iteration-limit exit (285->512) + no-insert fall (485->496)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_stops_at_iteration_limit_with_no_inserts(monkeypatch):
    patch_event(monkeypatch)
    updated = []
    discover_calls = {"count": 0}

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        discover_calls["count"] += 1
        return make_discovery_result(
            next_cursor=f"cursor-{discover_calls['count']}",
            exhausted=False,
        )

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=_async_value([]),
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    service.MAX_DISCOVERY_ITERATIONS = 2
    await service._discover_all_photos("job-1")

    # Never-exhausted pages with no insertions end via the iteration cap,
    # not via a break; discovery still completes.
    assert discover_calls["count"] == 2
    assert updated[-1]["discovery_completed"] is True


# ---------------------------------------------------------------------------
# _discover_all_photos: retry callback log (319)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_retry_callback_logs_warning(monkeypatch):
    patch_event(monkeypatch)
    discover_calls = {"count": 0}
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        discover_calls["count"] += 1
        if discover_calls["count"] == 1:
            return make_discovery_result(
                metadata={"error_type": "fetch_failure", "message": "flaky"}
            )
        return make_discovery_result(exhausted=True)

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=_async_value([]),
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    service.DISCOVERY_RETRY_BASE_DELAY_SECONDS = 0.01
    await service._discover_all_photos("job-1")

    # Real with_retry: first attempt fails, on_retry logs, second succeeds.
    assert discover_calls["count"] == 2
    assert updated[-1]["discovery_completed"] is True


# ---------------------------------------------------------------------------
# _discover_all_photos: 2FA persist failure (375-376) + cursor metadata (386)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_auth_persist_failure_with_cursor(monkeypatch):
    patch_event(monkeypatch)
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(metadata={"discovery_cursor": "cur-1"})

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return {"session_payload": {"username": "ada", "password": "pw"}}

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        assert cursor == "cur-1"
        return make_discovery_result(
            requires_auth=True,
            metadata={
                "reason": "two_factor_required",
                "two_factor_identifier": "tf-1",
                "message": "OTP needed",
            },
        )

    async def fake_store_scraper_session(*args, **kwargs):
        raise RuntimeError("session store down")

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
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    with pytest.raises(SocialImportAuthRequiredError):
        await service._discover_all_photos("job-1")

    # The cursor is preserved in metadata even though 2FA persist failed.
    auth_update = updated[0]
    assert auth_update["status"] == SocialImportJobStatus.AWAITING_AUTH.value
    assert auth_update["metadata"]["discovery_cursor"] == "cur-1"
    assert auth_update["metadata"]["auth_reason"] == "two_factor_required"
    assert auth_update["metadata"]["two_factor_identifier"] == "tf-1"


# ---------------------------------------------------------------------------
# _discover_all_photos: max-limit truncation (469-470) + cursor-less break (501)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_discover_all_photos_truncates_to_max_photo_cap(monkeypatch):
    patch_event(monkeypatch)
    added = []
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job(discovered_photos=1995)

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        return make_discovery_result(
            photos=[
                SimpleNamespace(model_dump=lambda i=i: {"id": f"p{i}"})
                for i in range(10)
            ],
            exhausted=True,
        )

    async def fake_add_discovered_photos(db, *, job_id, user_id, start_ordinal, photos):
        added.append((start_ordinal, [p["id"] for p in photos]))
        return [{"id": p["id"]} for p in photos]

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=fake_add_discovered_photos,
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    await service._discover_all_photos("job-1")

    # 1995 discovered + a 10-photo page overflows MAX_DISCOVERY_PHOTOS (2000),
    # so only the first 5 are added before the loop stops.
    assert added == [(1996, [f"p{i}" for i in range(5)])]
    assert updated[-1]["discovery_completed"] is True


@pytest.mark.asyncio
async def test_discover_all_photos_breaks_when_no_next_cursor(monkeypatch):
    patch_event(monkeypatch)
    updated = []

    async def fake_get_job(db, *, job_id, user_id):
        return make_job()

    async def fake_set_job_status(*args, **kwargs):
        return None

    async def fake_get_active_session(db, *, job_id, user_id):
        return None

    async def fake_discover(normalized_url, platform, auth_session, cursor):
        # Not exhausted but no cursor: the loop must still stop.
        return make_discovery_result(exhausted=False, next_cursor=None)

    async def fake_update_job(db, *, job_id, user_id, updates):
        updated.append(dict(updates))
        return {"id": job_id}

    patch_store(
        monkeypatch,
        get_job=fake_get_job,
        set_job_status=fake_set_job_status,
        update_job=fake_update_job,
        add_discovered_photos=_async_value([]),
    )
    monkeypatch.setattr(SocialAuthService, "get_active_session", staticmethod(fake_get_active_session))
    monkeypatch.setattr(SocialScraperService, "discover_profile_photos", staticmethod(fake_discover))

    service = make_service()
    await service._discover_all_photos("job-1")
    assert updated[-1]["discovery_completed"] is True


# ---------------------------------------------------------------------------
# _run_queue: empty claim while awaiting (627->631)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_run_queue_claim_empty_while_awaiting_syncs_and_returns(monkeypatch):
    synced = []
    patch_event(monkeypatch)

    async def fake_sync(job_id):
        synced.append(job_id)

    patch_store(
        monkeypatch,
        set_job_status=_async_value(None),
        get_job=_async_value(make_job(discovery_completed=True)),
        get_slots=_async_value(
            {"awaiting": make_photo(), "buffered": None, "processing": None}
        ),
        claim_next_queued_photo=_async_value(None),
    )
    service = make_service()
    monkeypatch.setattr(service, "_is_job_complete", _async_value(False))
    monkeypatch.setattr(service, "_sync_job_counters", fake_sync)
    await service._run_queue("job-1")
    assert synced == ["job-1"]


# ---------------------------------------------------------------------------
# _process_single_photo: outer upstream-quota error (978-979, 996->1012)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_process_single_photo_outer_upstream_quota_marks_capacity(monkeypatch):
    events = patch_event(monkeypatch)
    updated = []
    patch_process_collaborators(
        monkeypatch,
        items=[{"temp_id": "t1", "category": "tops", "colors": ["blue"]}],
    )

    async def fake_upsert_photo_items(db, *, job_id, photo_id, user_id, items):
        raise _UpstreamQuotaError()

    async def fake_update_photo(db, *, job_id, user_id, photo_id, updates):
        updated.append(dict(updates))
        return {"id": photo_id, **updates}

    patch_store(
        monkeypatch,
        upsert_photo_items=fake_upsert_photo_items,
        update_photo=fake_update_photo,
    )
    service = make_service()
    monkeypatch.setattr(service, "_sync_job_counters", _noop_async)
    await service._process_single_photo("job-1", make_photo())

    # The photo already reached the VLM, so the extraction reservation was
    # consumed; the quota error marks capacity and fails the photo.
    assert service._capacity_exhausted is True
    cap_events = [e for e in events if e["event_type"] == "capacity_exhausted"]
    assert cap_events and cap_events[0]["payload"]["error_kind"] == "upstream_quota"
    assert updated[0]["status"] == SocialImportPhotoStatus.FAILED.value


# ---------------------------------------------------------------------------
# approve_photo: save returns None (1087->1057) / reject_photo: missing (1144)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_approve_photo_handles_item_save_returning_none(monkeypatch):
    patch_event(monkeypatch)

    async def fake_get_photo(db, *, job_id, user_id, photo_id):
        return {"id": photo_id}

    async def fake_list_items_for_photo(db, *, job_id, photo_id, user_id):
        return [{"id": "item-1", "status": SocialImportItemStatus.GENERATED.value}]

    async def fake_noop(*args, **kwargs):
        return {}

    async def fake_schedule_job(cls, service, job_id):
        return None

    async def fake_save(item):
        return None

    patch_store(
        monkeypatch,
        get_photo=fake_get_photo,
        list_items_for_photo=fake_list_items_for_photo,
        update_photo=fake_noop,
    )
    monkeypatch.setattr(SocialImportPipelineService, "schedule_job", classmethod(fake_schedule_job))
    service = make_service()
    monkeypatch.setattr(service, "_publish_event", fake_noop)
    monkeypatch.setattr(service, "_promote_buffered_if_available", fake_noop)
    monkeypatch.setattr(service, "_sync_job_counters", fake_noop)
    monkeypatch.setattr(service, "_save_item_from_social_item", fake_save)

    result = await service.approve_photo("job-1", "photo-1")
    assert result == {"saved_count": 0, "saved_items": []}


@pytest.mark.asyncio
async def test_reject_photo_missing_photo_raises(monkeypatch):
    patch_store(monkeypatch, get_photo=_async_value(None))
    service = make_service()
    with pytest.raises(SocialImportJobNotFoundError):
        await service.reject_photo("job-1", "photo-1")


# ---------------------------------------------------------------------------
# get_status: resume failure (1342->1349) and vanished job after resume (1347)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_get_status_resume_attempt_fails_keeps_paused_status(monkeypatch):
    slots = {"awaiting": None, "buffered": None, "processing": None}
    patch_store(
        monkeypatch,
        get_job=_async_value(make_job(status=SocialImportJobStatus.PAUSED_RATE_LIMITED.value)),
        get_slots=_async_value(slots),
        get_photo_with_items=_identity_photo,
        count_by_status=_async_value({}),
    )
    service = make_service()
    monkeypatch.setattr(service, "_try_resume_rate_limited_job", _async_value(False))
    status = await service.get_status("job-1")
    assert status["status"] == SocialImportJobStatus.PAUSED_RATE_LIMITED.value


@pytest.mark.asyncio
async def test_get_status_resumed_job_disappears_raises(monkeypatch):
    calls = {"get": 0}

    async def fake_get_job(db, *, job_id, user_id):
        calls["get"] += 1
        if calls["get"] == 1:
            return make_job(status=SocialImportJobStatus.PAUSED_RATE_LIMITED.value)
        return None

    patch_store(monkeypatch, get_job=fake_get_job)
    service = make_service()
    monkeypatch.setattr(service, "_try_resume_rate_limited_job", _async_value(True))
    with pytest.raises(SocialImportJobNotFoundError):
        await service.get_status("job-1")


# ---------------------------------------------------------------------------
# _try_resume_rate_limited_job: update_job falsy (1559)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_try_resume_rate_limited_update_failure_returns_false(monkeypatch):
    async def fake_check(user_id, operation_type, db, count=1):
        return {"allowed": True, "remaining": 1, "limit": 1, "current_count": 0}

    patch_store(monkeypatch, update_job=_async_value(None))
    monkeypatch.setattr(AISettingsService, "check_rate_limit", staticmethod(fake_check))
    service = make_service()
    assert await service._try_resume_rate_limited_job("job-1") is False


# ---------------------------------------------------------------------------
# _cleanup_unsaved_temp_assets: unsaved item without path (1637->1634)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_cleanup_unsaved_temp_assets_ignores_unsaved_without_path(monkeypatch):
    cleaned = []

    async def fake_list_photos(db, *, job_id, user_id):
        return [{"id": "photo-1"}]

    async def fake_list_items(db, *, job_id, photo_id, user_id):
        return [
            {"status": SocialImportItemStatus.GENERATED.value, "generated_storage_path": None},
            {"status": SocialImportItemStatus.SAVED.value, "generated_storage_path": "saved/path"},
        ]

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
    assert cleaned == []


# ---------------------------------------------------------------------------
# _save_item_from_social_item: embedding None skips upsert (1717->1738)
# ---------------------------------------------------------------------------


@pytest.mark.asyncio
async def test_save_item_skips_vector_upsert_when_embedding_none(monkeypatch):
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

    async def fake_promote(db, user_id, temp_storage_path, filename_hint):
        return {"image_url": "https://i", "thumbnail_url": "https://t", "storage_path": "p"}

    async def fake_reserve(user_id, operation_type, db, count=1):
        return True

    async def fake_embedding(data):
        return None

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
        }
    )

    assert item_id
    assert upserted == []
    assert [name for name, _ in db.inserts] == ["items", "item_images"]
