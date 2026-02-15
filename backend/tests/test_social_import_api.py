import pytest
from fastapi import HTTPException

from app.api.v1.social_import import create_social_import_job
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
