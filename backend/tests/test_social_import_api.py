import pytest
from fastapi import HTTPException

import app.api.v1.social_import as social_import_api
from app.api.v1.social_import import approve_social_photo, create_social_import_job
from app.core.config import settings
from app.models.social_import import SocialImportStartRequest
from app.services.social_import_job_store import SocialImportJobStore


@pytest.mark.asyncio
async def test_create_social_import_job_enforces_concurrent_limit(monkeypatch):
    monkeypatch.setattr(settings, "ENABLE_SOCIAL_IMPORT", True)
    monkeypatch.setattr(settings, "SOCIAL_IMPORT_MAX_CONCURRENT_JOBS", 1)

    async def fake_count_active_jobs(db, *, user_id):  # noqa: ANN001
        return 1

    monkeypatch.setattr(
        SocialImportJobStore,
        "count_active_jobs",
        staticmethod(fake_count_active_jobs),
    )

    with pytest.raises(HTTPException) as exc_info:
        await create_social_import_job(
            SocialImportStartRequest(source_url="https://www.instagram.com/example/"),
            user_id="user-1",
            db=object(),
        )

    assert exc_info.value.status_code == 429


@pytest.mark.asyncio
async def test_approve_photo_returns_saved_items(monkeypatch):
    """Approve should surface saved item ids/categories so the client can auto-create
    an outfit from the photo's items."""

    class _FakeService:
        async def approve_photo(self, job_id, photo_id):  # noqa: ANN001, ANN202
            return {
                "saved_count": 2,
                "saved_items": [
                    {"id": "item-1", "category": "tops"},
                    {"id": "item-2", "category": "bottoms"},
                ],
            }

    monkeypatch.setattr(
        social_import_api, "_service", lambda user_id, db: _FakeService()
    )

    result = await approve_social_photo(job_id="job-1", photo_id="photo-1", user_id="user-1", db=object())

    assert result["message"] == "Approved"
    assert result["data"]["saved_items"] == [
        {"id": "item-1", "category": "tops"},
        {"id": "item-2", "category": "bottoms"},
    ]
    assert result["data"]["status"] == "approved"
