"""Residual small-arc coverage for several modules.

Targets the last remaining single-line/branch misses from the full-suite
coverage report: app/core/predicates.py, app/core/permissions.py,
app/core/middleware.py, app/api/v1/ai_settings.py, app/agents/prompt_fidelity.py,
app/api/v1/recommendations.py, and app/api/v1/feedback.py.
"""

from app.agents.prompt_fidelity import sandwich_prompt
from app.api.v1.ai_settings import _provider_has_usable_config
from app.api.v1.recommendations import _coerce_time
from app.core.permissions import is_admin_role
from app.core.predicates import evaluate_predicate
from app.models.ai import AISettingsUpdate, ProviderConfigInput


# ---------------------------------------------------------------------------
# app/core/predicates.py — unknown-op fallthrough
# ---------------------------------------------------------------------------


def test_evaluate_predicate_unknown_op_returns_false():
    # Unknown operator tokens are rejected by the _EVALUATABLE_OPS check
    # (not the final return-False tail, which is unreachable).
    assert evaluate_predicate({"price": 10}, "price.unknown.5") is False
    assert evaluate_predicate({"name": "x"}, "name.nonsense.y") is False


# ---------------------------------------------------------------------------
# app/core/permissions.py — non-admin role
# ---------------------------------------------------------------------------


def test_is_admin_role_false_for_plain_user():
    assert is_admin_role("user") is False
    assert is_admin_role("admin") is True


# ---------------------------------------------------------------------------
# app/api/v1/ai_settings.py — submitted config without api_key
# ---------------------------------------------------------------------------


def test_provider_has_usable_config_without_request_key(monkeypatch):
    from app.services.ai_settings_service import AISettingsService

    request = AISettingsUpdate(
        provider_configs={"openai": ProviderConfigInput(api_url="https://x")}
    )
    monkeypatch.setattr(
        AISettingsService,
        "has_stored_byok_key",
        lambda current, provider: False,
    )
    # No system key (openai requires BYOK), no request api_key, no stored key.
    assert _provider_has_usable_config("openai", request, {}) is False


def test_provider_has_usable_config_with_request_key():
    request = AISettingsUpdate(
        provider_configs={"openai": ProviderConfigInput(api_key="sk-test")}
    )
    assert _provider_has_usable_config("openai", request, {}) is True


# ---------------------------------------------------------------------------
# app/agents/prompt_fidelity.py — optional section arcs
# ---------------------------------------------------------------------------


def test_sandwich_prompt_without_outfit_lock_or_scene():
    out = sandwich_prompt("the subject", "", include_outfit_lock=False)
    assert "OUTFIT LOCK" not in out
    assert "SUBJECT LOCK (copy exactly):\nthe subject" in out
    assert "SCENE (change only these)" not in out


def test_sandwich_prompt_with_scene_but_no_subject():
    out = sandwich_prompt("", "the scene", include_outfit_lock=True)
    assert "SCENE (change only these):\nthe scene" in out
    # No subject -> no SUBJECT LOCK blocks at all.
    assert "SUBJECT LOCK" not in out


# ---------------------------------------------------------------------------
# app/api/v1/recommendations.py — time parsing
# ---------------------------------------------------------------------------


def test_coerce_time_trailing_offsets():
    assert _coerce_time("12:34:56Z") is not None
    assert _coerce_time("12:34:56.000000Z") is not None
    assert _coerce_time("12:34:56+05:30") is not None


# ---------------------------------------------------------------------------
# app/api/v1/feedback.py — upload result without storage_path
# ---------------------------------------------------------------------------


def test_create_ticket_attachment_without_storage_path(monkeypatch):
    from unittest.mock import AsyncMock, patch

    from fastapi import UploadFile

    from app.api.v1.feedback import _create_feedback_ticket
    from app.models.feedback import TicketCategory
    from app.services.feedback_service import FeedbackService
    from app.services.storage_service import StorageService

    import io

    monkeypatch.setattr(
        StorageService,
        "upload_feedback_attachment",
        AsyncMock(return_value={"image_url": "https://cdn/x.png"}),  # no storage_path
    )
    captured = {}

    async def _create_ticket(request, user_id, attachment_urls, attachment_storage_paths, db):
        captured["urls"] = attachment_urls
        captured["paths"] = attachment_storage_paths

        class _Resp:
            def model_dump(self, mode):
                return {"id": "t4"}

        return _Resp()

    with patch.object(FeedbackService, "create_ticket", _create_ticket):
        result = __import__("asyncio").run(
            _create_feedback_ticket(
                category=TicketCategory.BUG_REPORT,
                subject="Broken attachment",
                description="Uploaded file is missing its storage path",
                contact_email=None,
                device_info=None,
                app_version=None,
                app_platform=None,
                attachments=[UploadFile(filename="a.png", file=io.BytesIO(b"x"))],
                user_id=None,
                db=object(),
            )
        )
    assert result["data"]["id"] == "t4"
    assert captured["urls"] == ["https://cdn/x.png"]
    # No storage_path -> the storage path list stays empty (arc back to loop).
    assert captured["paths"] == []
