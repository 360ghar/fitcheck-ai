"""Residual branch coverage for app.api.v1.feedback.

Covers attachment upload paths (success incl. storage_path, upload failure
continues, cap enforcement), device-info parsing branches, and the
my-tickets endpoint.
"""

import io
from unittest.mock import AsyncMock, patch

import pytest
from fastapi import UploadFile

from app.api.v1.feedback import _create_feedback_ticket, get_my_tickets
from app.core.exceptions import ValidationError
from app.models.feedback import TicketCategory
from app.services.feedback_service import FeedbackService
from app.services.storage_service import StorageService


def _upload(name: str = "shot.png", content: bytes = b"png-data") -> UploadFile:
    return UploadFile(filename=name, file=io.BytesIO(content))


def _db():
    class _DB:
        pass

    return _DB()


@pytest.mark.asyncio
async def test_create_ticket_with_attachment_and_device_info(monkeypatch):
    monkeypatch.setattr(
        StorageService,
        "upload_feedback_attachment",
        AsyncMock(
            return_value={"image_url": "https://cdn/x.png", "storage_path": "feedback/u1/x.png"}
        ),
    )
    captured = {}

    async def _create_ticket(request, user_id, attachment_urls, attachment_storage_paths, db):
        captured["request"] = request
        captured["urls"] = attachment_urls
        captured["paths"] = attachment_storage_paths

        class _Resp:
            def model_dump(self, mode):
                return {"id": "t1"}

        return _Resp()

    monkeypatch.setattr(FeedbackService, "create_ticket", _create_ticket)

    result = await _create_feedback_ticket(
        category=TicketCategory.BUG_REPORT,
        subject="Broken button",
        description="The button does nothing",
        contact_email="me@example.com",
        device_info='{"app_version": "1.2.3", "platform": "ios"}',
        app_version="1.2.3",
        app_platform="ios",
        attachments=[_upload()],
        user_id="user-1",
        db=_db(),
    )

    assert result["data"]["id"] == "t1"
    assert captured["urls"] == ["https://cdn/x.png"]
    assert captured["paths"] == ["feedback/u1/x.png"]
    assert captured["request"].device_info is not None
    # contact_email is dropped for authenticated users.
    assert captured["request"].contact_email is None


@pytest.mark.asyncio
async def test_create_ticket_upload_failure_continues_without_attachment(monkeypatch):
    monkeypatch.setattr(
        StorageService,
        "upload_feedback_attachment",
        AsyncMock(side_effect=RuntimeError("storage down")),
    )
    captured = {}

    async def _create_ticket(request, user_id, attachment_urls, attachment_storage_paths, db):
        captured["urls"] = attachment_urls
        captured["paths"] = attachment_storage_paths

        class _Resp:
            def model_dump(self, mode):
                return {"id": "t2"}

        return _Resp()

    monkeypatch.setattr(FeedbackService, "create_ticket", _create_ticket)

    await _create_feedback_ticket(
        category=TicketCategory.FEATURE_REQUEST,
        subject="Add dark mode",
        description="Dark mode would be nice",
        contact_email=None,
        device_info=None,
        app_version=None,
        app_platform=None,
        attachments=[_upload()],
        user_id=None,
        db=_db(),
    )

    assert captured["urls"] == []
    assert captured["paths"] == []


@pytest.mark.asyncio
async def test_create_ticket_attachment_without_filename_skipped():
    class _Resp:
        def model_dump(self, mode):
            return {"id": "t3"}

    async def _create_ticket(request, user_id, attachment_urls, attachment_storage_paths, db):
        return _Resp()

    with patch.object(FeedbackService, "create_ticket", _create_ticket):
        result = await _create_feedback_ticket(
            category=TicketCategory.GENERAL_FEEDBACK,
            subject="Just saying hi",
            description="This is a friendly message",
            contact_email="anon@example.com",
            device_info="not-json{{{",
            app_version=None,
            app_platform=None,
            attachments=[_upload(name="")],
            user_id=None,
            db=_db(),
        )
    # Invalid device_info JSON parses to None without raising.
    assert result["data"]["id"] == "t3"


@pytest.mark.asyncio
async def test_create_ticket_rejects_more_than_five_attachments():
    with pytest.raises(ValidationError, match="5 attachments"):
        await _create_feedback_ticket(
            category=TicketCategory.BUG_REPORT,
            subject="Too many files",
            description="Way too many attachments here",
            contact_email=None,
            device_info=None,
            app_version=None,
            app_platform=None,
            attachments=[_upload(f"{i}.png") for i in range(6)],
            user_id=None,
            db=_db(),
        )


@pytest.mark.asyncio
async def test_get_my_tickets():
    class _Resp:
        def model_dump(self, mode):
            return {"tickets": []}

    async def _get_user_tickets(user_id, db, limit, offset):
        assert limit == 20
        assert offset == 0
        return _Resp()

    with patch.object(FeedbackService, "get_user_tickets", _get_user_tickets):
        result = await get_my_tickets(
            limit=20, offset=0, user={"id": "u9"}, db=_db()
        )
    assert result["data"] == {"tickets": []}


@pytest.mark.asyncio
async def test_get_my_tickets_caps_limit():
    async def _get_user_tickets(user_id, db, limit, offset):
        assert limit == 50
        return type("_R", (), {"model_dump": lambda self, mode: {}})()

    with patch.object(FeedbackService, "get_user_tickets", _get_user_tickets):
        await get_my_tickets(limit=999, offset=0, user={"id": "u9"}, db=_db())
