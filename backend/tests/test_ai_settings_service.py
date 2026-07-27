"""
Tests for AISettingsService's registry-driven provider dispatch
(get_effective_provider_config, get_ai_service_for_user, test_provider_config).

No dedicated test file existed for this service before this change. Mocks
AISettingsService.get_user_settings directly (matching the convention already
used in tests/test_social_import_pipeline_service.py) rather than the Supabase
db chain, since these tests are about provider-dispatch logic, not persistence
plumbing.
"""

from unittest.mock import AsyncMock, patch

import pytest

from app.core.config import settings
from app.services.ai_provider_interface import AIProvider
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import AISettingsService, encrypt_api_key
from app.services.gemini_provider import GeminiConfig, GeminiProvider


@pytest.fixture(autouse=True)
def _encryption_key(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "test-encryption-key-not-a-real-secret")


class TestGetEffectiveProviderConfigGemini:
    @pytest.mark.asyncio
    async def test_falls_back_to_system_config_when_no_user_override(self, monkeypatch):
        monkeypatch.setattr(settings, "AI_GEMINI_API_KEY", "system-key")
        monkeypatch.setattr(
            AISettingsService, "get_user_settings", AsyncMock(return_value={"provider_configs": {}})
        )
        config = await AISettingsService.get_effective_provider_config("user-1", AIProvider.GEMINI, db=object())
        assert isinstance(config, GeminiConfig)
        assert config.api_key == "system-key"

    @pytest.mark.asyncio
    async def test_uses_byok_override_without_requiring_api_url(self):
        encrypted = encrypt_api_key("user-gemini-key")
        monkeypatch_settings = {
            "provider_configs": {"gemini": {"api_key_encrypted": encrypted, "model": "gemini-3.6-flash"}},
        }
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value=monkeypatch_settings)):
            config = await AISettingsService.get_effective_provider_config("user-1", AIProvider.GEMINI, db=object())
        assert isinstance(config, GeminiConfig)
        assert config.api_key == "user-gemini-key"
        assert config.chat_model == "gemini-3.6-flash"

    @pytest.mark.asyncio
    async def test_ignores_stale_pre_migration_018_openai_shaped_byok_row(self):
        """A 'gemini' BYOK row saved before commit 74ce4d2 (when Gemini was
        still an OpenAI-compatible provider entry) would carry api_url - the
        full encrypt/decrypt round trip through AISettingsService must not
        break or misread it, only ignore the field it doesn't understand."""
        encrypted = encrypt_api_key("user-gemini-key")
        stale_settings = {
            "provider_configs": {"gemini": {
                "api_key_encrypted": encrypted,
                "api_url": "https://generativelanguage.googleapis.com/v1beta",
                "model": "gemini-3-flash-preview",
            }},
        }
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value=stale_settings)):
            config = await AISettingsService.get_effective_provider_config("user-1", AIProvider.GEMINI, db=object())
        assert isinstance(config, GeminiConfig)
        assert config.api_key == "user-gemini-key"
        assert config.chat_model == "gemini-3-flash-preview"
        assert not hasattr(config, "api_url")

    @pytest.mark.asyncio
    async def test_raises_when_neither_user_override_nor_system_config_available(self):
        monkeypatch_none = {"provider_configs": {}}
        with patch.object(settings, "AI_GEMINI_API_KEY", None), \
             patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value=monkeypatch_none)):
            from app.core.exceptions import AIServiceError
            with pytest.raises(AIServiceError):
                await AISettingsService.get_effective_provider_config("user-1", AIProvider.GEMINI, db=object())


class TestGetEffectiveProviderConfigCustom:
    """Unchanged-behavior guard: OPENAI/CUSTOM still require api_url to
    accept a BYOK override, now enforced by ProviderConfig.from_user_dict
    instead of an inline check at the call site."""

    @pytest.mark.asyncio
    async def test_byok_override_missing_api_url_falls_back_to_system_config(self):
        encrypted = encrypt_api_key("user-key")
        raw_settings = {
            "provider_configs": {"custom": {"api_key_encrypted": encrypted, "model": "some-model"}},
        }
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value=raw_settings)):
            config = await AISettingsService.get_effective_provider_config("user-1", AIProvider.CUSTOM, db=object())
        # Falls through to system config (Agnes defaults), not the incomplete override.
        assert config.api_url == settings.AI_CHAT_API_URL
        assert config.api_key == settings.AI_CHAT_API_KEY

    @pytest.mark.asyncio
    async def test_byok_override_with_api_url_is_used(self):
        encrypted = encrypt_api_key("user-key")
        raw_settings = {
            "provider_configs": {"custom": {
                "api_key_encrypted": encrypted,
                "api_url": "https://my-proxy.example.com/v1",
                "model": "some-model",
            }},
        }
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value=raw_settings)):
            config = await AISettingsService.get_effective_provider_config("user-1", AIProvider.CUSTOM, db=object())
        assert config.api_url == "https://my-proxy.example.com/v1"
        assert config.api_key == "user-key"
        assert config.model == "some-model"


class TestGetAiServiceForUser:
    @pytest.mark.asyncio
    async def test_returns_gemini_provider_instance_for_gemini_default(self, monkeypatch):
        monkeypatch.setattr(settings, "AI_GEMINI_API_KEY", "system-key")
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
            "default_provider": "gemini", "provider_configs": {},
        })):
            service = await AISettingsService.get_ai_service_for_user("user-1", db=object())
        assert isinstance(service, GeminiProvider)
        await service.close()

    @pytest.mark.asyncio
    async def test_returns_ai_provider_service_instance_for_custom_default(self):
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
            "default_provider": "custom", "provider_configs": {},
        })):
            service = await AISettingsService.get_ai_service_for_user("user-1", db=object())
        assert isinstance(service, AIProviderService)
        await service.close()

    @pytest.mark.asyncio
    async def test_explicit_provider_argument_overrides_stored_default(self, monkeypatch):
        monkeypatch.setattr(settings, "AI_GEMINI_API_KEY", "system-key")
        with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
            "default_provider": "custom", "provider_configs": {},
        })):
            service = await AISettingsService.get_ai_service_for_user(
                "user-1", db=object(), provider=AIProvider.GEMINI
            )
        assert isinstance(service, GeminiProvider)
        await service.close()


class TestTestProviderConfig:
    @pytest.mark.asyncio
    async def test_gemini_provider_does_not_require_api_url(self):
        with patch.object(
            GeminiProvider, "test_connection", AsyncMock(return_value={"success": True, "message": "ok"})
        ):
            result = await AISettingsService.test_provider_config(
                api_key="k", model="gemini-3.6-flash", api_url=None, provider=AIProvider.GEMINI,
            )
        assert result["success"] is True

    @pytest.mark.asyncio
    async def test_custom_provider_dispatch_still_works(self):
        with patch.object(
            AIProviderService, "test_connection", AsyncMock(return_value={"success": True, "message": "ok"})
        ):
            result = await AISettingsService.test_provider_config(
                api_key="k", model="m", api_url="https://example.com/v1", provider=AIProvider.CUSTOM,
            )
        assert result["success"] is True

    @pytest.mark.asyncio
    async def test_default_provider_is_custom_for_backward_compatibility(self):
        """Callers that never pass `provider` (there were none before this
        change added the parameter) must keep getting the OpenAI-compatible
        path, matching the old hardcoded behavior."""
        with patch.object(
            AIProviderService, "test_connection", AsyncMock(return_value={"success": True, "message": "ok"})
        ):
            result = await AISettingsService.test_provider_config(
                api_key="k", model="m", api_url="https://example.com/v1",
            )
        assert result["success"] is True
