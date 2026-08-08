"""Shared fakes/scaffolding for the social-import pipeline test files.

The orchestration flows (test_social_import_pipeline_flows.py) and the
coverage-completing file (test_social_import_pipeline_service_coverage.py)
patch the same collaborators in the same way. Keeping one copy here stops the
fakes from silently diverging between the two files (they already drifted
once before this module existed).
"""

from types import SimpleNamespace

from app.models.social_import import (
    SocialImportJobStatus,
    SocialImportPhotoStatus,
)
from app.models.subscription import OperationType
from app.services import social_import_pipeline_service as pipeline_mod
from app.services.ai_settings_service import AISettingsService
from app.services.social_import_event_service import SocialImportEventService
from app.services.social_import_job_store import SocialImportJobStore
from app.services.social_import_pipeline_service import SocialImportPipelineService
from app.services.social_scraper_service import SocialScraperService
from app.services.storage_service import StorageService


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
