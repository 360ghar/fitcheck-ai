"""Handler-branch coverage for app/api/v1/ai_settings.py.

Exercises the settings CRUD endpoints (get/update), provider testing, usage
stats, rate-limit checks, and provider reset — including the
_provider_has_usable_config guard (RCA 2026-08-05) and every error branch
(invalid provider, unconfigured provider, not-found/missing configs, generic
failures wrapped as AIServiceError).

Follows the house convention of calling route functions directly with
tests.utils.fake_db.FakeDB and patching AISettingsService staticmethods.
"""
from types import SimpleNamespace
from unittest.mock import AsyncMock

import pytest

from app.api.v1 import ai_settings as ai_settings_module
from app.core.exceptions import AIServiceError, ValidationError
from app.models.ai import (
    AISettingsUpdate,
    HealthCheckResult,
    ProviderConfigInput,
    TestProviderRequest,
)
from app.services.ai_settings_service import AISettingsService
from tests.utils.fake_db import FakeDB

USER_ID = "11111111-1111-1111-1111-111111111111"

_USAGE = {
    "daily": {"extractions": 1, "generations": 2, "embeddings": 0},
    "total": {"extractions": 10, "generations": 20, "embeddings": 0},
    "limits": {"daily_extractions": 50, "daily_generations": 50, "daily_embeddings": 500},
    "remaining": {"extractions": 49, "generations": 48, "embeddings": 500},
}

_SETTINGS = {
    "default_provider": "custom",
    "provider_configs": {
        "custom": {"api_url": "http://gateway", "model": "m", "api_key_encrypted": "enc"},
    },
}


def _patch_settings_services(monkeypatch, settings=None, usage=None, error=None):
    """Stub the AISettingsService read paths used by the route handlers."""
    if error is not None:
        monkeypatch.setattr(AISettingsService, "get_user_settings", AsyncMock(side_effect=error))
        return
    monkeypatch.setattr(
        AISettingsService, "get_user_settings", AsyncMock(return_value=settings or _SETTINGS)
    )
    monkeypatch.setattr(
        AISettingsService, "get_usage_stats", AsyncMock(return_value=usage or _USAGE)
    )


# ===========================================================================
# _provider_has_usable_config
# ===========================================================================


def test_provider_has_usable_config_passes_unknown_provider_values():
    assert ai_settings_module._provider_has_usable_config("bogus", AISettingsUpdate(), {}) is True


def test_provider_has_usable_config_true_with_system_config(monkeypatch):
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: SimpleNamespace())
    assert ai_settings_module._provider_has_usable_config("openai", AISettingsUpdate(), {}) is True


def test_provider_has_usable_config_true_with_key_in_request():
    request = AISettingsUpdate(
        provider_configs={"openai": ProviderConfigInput(api_key="sk-x", api_url="http://x")}
    )
    monkeypatch = pytest.MonkeyPatch()
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: None)
    try:
        assert ai_settings_module._provider_has_usable_config("openai", request, {}) is True
    finally:
        monkeypatch.undo()


def test_provider_has_usable_config_true_with_stored_byok_key(monkeypatch):
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: None)
    monkeypatch.setattr(AISettingsService, "has_stored_byok_key", staticmethod(lambda settings, provider: True))

    assert ai_settings_module._provider_has_usable_config("openai", AISettingsUpdate(), {}) is True


def test_provider_has_usable_config_false_when_nothing_configured(monkeypatch):
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: None)
    monkeypatch.setattr(AISettingsService, "has_stored_byok_key", staticmethod(lambda settings, provider: False))

    assert ai_settings_module._provider_has_usable_config("openai", AISettingsUpdate(), {}) is False


# ===========================================================================
# GET /ai/settings
# ===========================================================================


@pytest.mark.asyncio
async def test_get_ai_settings_returns_masked_configs_and_usage(monkeypatch):
    _patch_settings_services(monkeypatch)

    result = await ai_settings_module.get_ai_settings(user_id=USER_ID, db=FakeDB())

    assert result["message"] == "OK"
    assert result["data"]["default_provider"] == "custom"
    display = result["data"]["provider_configs"]["custom"]
    assert display["api_url"] == "http://gateway"
    assert display["api_key_set"] is True
    assert "api_key_encrypted" not in display
    assert result["data"]["usage"]["total"]["generations"] == 20


@pytest.mark.asyncio
async def test_get_ai_settings_propagates_ai_service_error(monkeypatch):
    _patch_settings_services(monkeypatch, error=AIServiceError("db down"))

    with pytest.raises(AIServiceError):
        await ai_settings_module.get_ai_settings(user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_get_ai_settings_wraps_generic_errors(monkeypatch):
    _patch_settings_services(monkeypatch, error=RuntimeError("boom"))

    with pytest.raises(AIServiceError) as exc_info:
        await ai_settings_module.get_ai_settings(user_id=USER_ID, db=FakeDB())
    assert "Failed to get AI settings" in str(exc_info.value)


# ===========================================================================
# PUT /ai/settings
# ===========================================================================


@pytest.mark.asyncio
async def test_update_ai_settings_rejects_invalid_provider():
    request = AISettingsUpdate(default_provider="bogus")

    with pytest.raises(ValidationError):
        await ai_settings_module.update_ai_settings(request, user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_update_ai_settings_rejects_unconfigured_provider(monkeypatch):
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: None)
    _patch_settings_services(monkeypatch, settings={"provider_configs": {}})

    request = AISettingsUpdate(default_provider="openai")

    with pytest.raises(ValidationError) as exc_info:
        await ai_settings_module.update_ai_settings(request, user_id=USER_ID, db=FakeDB())
    assert "not configured" in str(exc_info.value)


@pytest.mark.asyncio
async def test_update_ai_settings_default_provider_happy_path(monkeypatch):
    monkeypatch.setattr(
        ai_settings_module, "get_system_provider_config", lambda provider: SimpleNamespace()
    )
    _patch_settings_services(monkeypatch)
    monkeypatch.setattr(AISettingsService, "update_user_settings", AsyncMock(return_value={}))

    result = await ai_settings_module.update_ai_settings(
        AISettingsUpdate(default_provider="custom"), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "OK"
    upd = AISettingsService.update_user_settings.await_args
    assert upd.kwargs["updates"] == {"default_provider": "custom"}


@pytest.mark.asyncio
async def test_update_ai_settings_provider_configs_only(monkeypatch):
    _patch_settings_services(monkeypatch)
    monkeypatch.setattr(AISettingsService, "update_user_settings", AsyncMock(return_value={}))

    request = AISettingsUpdate(
        provider_configs={"custom": ProviderConfigInput(api_key="sk-x", api_url="http://y")}
    )

    result = await ai_settings_module.update_ai_settings(
        request, user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "OK"
    upd = AISettingsService.update_user_settings.await_args
    assert upd.kwargs["updates"]["provider_configs"] == {
        "custom": {"api_key": "sk-x", "api_url": "http://y"}
    }


@pytest.mark.asyncio
async def test_update_ai_settings_empty_request_reads_current(monkeypatch):
    _patch_settings_services(monkeypatch)
    monkeypatch.setattr(AISettingsService, "update_user_settings", AsyncMock(return_value={}))

    result = await ai_settings_module.update_ai_settings(
        AISettingsUpdate(), user_id=USER_ID, db=FakeDB()
    )

    assert result["message"] == "OK"
    assert result["data"]["default_provider"] == "custom"
    AISettingsService.update_user_settings.assert_not_called()


@pytest.mark.asyncio
async def test_update_ai_settings_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(ai_settings_module, "get_system_provider_config", lambda provider: None)
    _patch_settings_services(monkeypatch, error=RuntimeError("boom"))

    with pytest.raises(AIServiceError) as exc_info:
        await ai_settings_module.update_ai_settings(
            AISettingsUpdate(default_provider="custom"), user_id=USER_ID, db=FakeDB()
        )
    assert "Failed to update AI settings" in str(exc_info.value)


# ===========================================================================
# POST /ai/settings/test
# ===========================================================================


@pytest.mark.asyncio
async def test_test_provider_config_rejects_invalid_provider():
    result = await ai_settings_module.test_provider_config(
        TestProviderRequest(provider="bogus", api_key="k", model="m"), user_id=USER_ID
    )

    assert result["message"] == "Test failed"
    assert result["data"]["success"] is False
    assert "Invalid provider" in result["data"]["message"]


@pytest.mark.asyncio
async def test_test_provider_config_requires_api_url_for_non_gemini():
    result = await ai_settings_module.test_provider_config(
        TestProviderRequest(provider="custom", api_key="k", model="m"), user_id=USER_ID
    )

    assert result["data"]["success"] is False
    assert "api_url is required" in result["data"]["message"]


@pytest.mark.asyncio
async def test_test_provider_config_happy_path(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "test_provider_config",
        AsyncMock(return_value=HealthCheckResult(available=True, message="ok", model="m", response="r")),
    )

    result = await ai_settings_module.test_provider_config(
        TestProviderRequest(provider="gemini", api_key="k", model="m"), user_id=USER_ID
    )

    assert result["message"] == "Test completed"
    assert result["data"]["success"] is True
    assert result["data"]["message"] == "ok"
    assert result["data"]["response"] == "r"


@pytest.mark.asyncio
async def test_test_provider_config_accepts_dict_envelope(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "test_provider_config",
        AsyncMock(return_value={"success": False, "message": "nope"}),
    )

    result = await ai_settings_module.test_provider_config(
        TestProviderRequest(provider="gemini", api_key="k", model="m"), user_id=USER_ID
    )

    assert result["data"]["success"] is False
    assert result["data"]["message"] == "nope"


@pytest.mark.asyncio
async def test_test_provider_config_reports_exceptions(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "test_provider_config",
        AsyncMock(side_effect=RuntimeError("connection refused")),
    )

    result = await ai_settings_module.test_provider_config(
        TestProviderRequest(provider="gemini", api_key="k", model="m"), user_id=USER_ID
    )

    assert result["data"]["success"] is False
    assert "connection refused" in result["data"]["message"]


# ===========================================================================
# GET /ai/settings/usage
# ===========================================================================


@pytest.mark.asyncio
async def test_get_usage_stats_happy_path(monkeypatch):
    monkeypatch.setattr(AISettingsService, "get_usage_stats", AsyncMock(return_value=_USAGE))

    result = await ai_settings_module.get_usage_stats(user_id=USER_ID, db=FakeDB())

    assert result["message"] == "OK"
    assert result["data"]["daily"]["extractions"] == 1
    assert result["data"]["remaining"]["generations"] == 48


@pytest.mark.asyncio
async def test_get_usage_stats_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(
        AISettingsService, "get_usage_stats", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(AIServiceError) as exc_info:
        await ai_settings_module.get_usage_stats(user_id=USER_ID, db=FakeDB())
    assert "Failed to get usage stats" in str(exc_info.value)


# ===========================================================================
# GET /ai/settings/rate-limit/{operation_type}
# ===========================================================================


@pytest.mark.asyncio
async def test_check_rate_limit_rejects_invalid_operation():
    with pytest.raises(ValidationError):
        await ai_settings_module.check_rate_limit("photoshoot", user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_check_rate_limit_happy_path(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "check_rate_limit",
        AsyncMock(return_value={"allowed": True, "current_count": 1, "limit": 10, "remaining": 9}),
    )

    result = await ai_settings_module.check_rate_limit("generation", user_id=USER_ID, db=FakeDB())

    assert result["message"] == "OK"
    assert result["data"]["allowed"] is True
    assert result["data"]["remaining"] == 9
    call = AISettingsService.check_rate_limit.await_args
    assert call.kwargs["user_id"] == USER_ID
    assert call.kwargs["operation_type"] == "generation"


@pytest.mark.asyncio
async def test_check_rate_limit_propagates_ai_service_error(monkeypatch):
    monkeypatch.setattr(
        AISettingsService, "check_rate_limit", AsyncMock(side_effect=AIServiceError("quota down"))
    )

    with pytest.raises(AIServiceError):
        await ai_settings_module.check_rate_limit("extraction", user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_check_rate_limit_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(
        AISettingsService, "check_rate_limit", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(AIServiceError) as exc_info:
        await ai_settings_module.check_rate_limit("extraction", user_id=USER_ID, db=FakeDB())
    assert "Failed to check rate limit" in str(exc_info.value)


# ===========================================================================
# POST /ai/settings/reset-provider/{provider}
# ===========================================================================


@pytest.mark.asyncio
async def test_reset_provider_config_rejects_invalid_provider():
    with pytest.raises(ValidationError):
        await ai_settings_module.reset_provider_config("bogus", user_id=USER_ID, db=FakeDB())


@pytest.mark.asyncio
async def test_reset_provider_config_removes_stored_config(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "get_user_settings",
        AsyncMock(
            return_value={"provider_configs": {"custom": {"api_key_encrypted": "enc"}, "gemini": {}}}
        ),
    )
    db = FakeDB()

    result = await ai_settings_module.reset_provider_config("custom", user_id=USER_ID, db=db)

    assert result["data"] == {"provider": "custom", "reset": True}
    assert db.updates == [("user_ai_settings", {"provider_configs": {"gemini": {}}})]


@pytest.mark.asyncio
async def test_reset_provider_config_noop_when_provider_absent(monkeypatch):
    monkeypatch.setattr(
        AISettingsService,
        "get_user_settings",
        AsyncMock(return_value={"provider_configs": {"gemini": {}}}),
    )
    db = FakeDB()

    result = await ai_settings_module.reset_provider_config("custom", user_id=USER_ID, db=db)

    assert result["data"]["reset"] is True
    assert db.updates == []


@pytest.mark.asyncio
async def test_reset_provider_config_wraps_generic_errors(monkeypatch):
    monkeypatch.setattr(
        AISettingsService, "get_user_settings", AsyncMock(side_effect=RuntimeError("boom"))
    )

    with pytest.raises(AIServiceError) as exc_info:
        await ai_settings_module.reset_provider_config("custom", user_id=USER_ID, db=FakeDB())
    assert "Failed to reset provider" in str(exc_info.value)
