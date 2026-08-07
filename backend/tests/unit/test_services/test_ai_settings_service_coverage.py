"""Coverage-completing tests for AISettingsService.

Sibling to test_ai_settings_service.py: this file exercises the persistence
and quota machinery that file's provider-dispatch tests skip - encryption
helpers (missing key / failure branches), the daily-reset path of
get_user_settings, update_user_settings config merging, check_rate_limit,
ensure_ai_settings_row (FK race / missing RPC handling), reserve_usage /
release_usage success and failure branches, usage stats and the display
config masking.

DB access goes through the in-memory FakeDB (the suite's "fresh database")
with the real execute_with_reconnect, except where an error injection point
is needed.
"""

from enum import Enum
from types import SimpleNamespace
from unittest.mock import AsyncMock, patch

import pytest

from app.core.config import settings
from app.core.exceptions import AIServiceError
from app.services.ai_provider_service import AIProviderService
from app.services.ai_settings_service import (
    AISettingsService,
    _get_encryption_key,
    _get_legacy_encryption_key,
    decrypt_api_key,
    encrypt_api_key,
)

from datetime import date, timedelta


class _Operation(str, Enum):
    GENERATION = "generation"


class _BoomRpcDb:
    """DB fake whose rpc().execute() raises a fixed exception."""

    def __init__(self, exc):
        self._exc = exc

    def rpc(self, name, params=None):
        return SimpleNamespace(execute=lambda: (_ for _ in ()).throw(self._exc))


class _BoomTableDb:
    """DB fake whose update chain's execute() raises a fixed exception."""

    def __init__(self, exc):
        self._exc = exc

    def table(self, name):
        return SimpleNamespace(
            update=lambda payload: SimpleNamespace(
                eq=lambda col, val: SimpleNamespace(
                    execute=lambda: (_ for _ in ()).throw(self._exc)
                )
            )
        )


@pytest.fixture(autouse=True)
def _encryption_key(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "test-encryption-key-not-a-real-secret")


# =============================================================================
# Encryption helpers - missing key / failure branches
# =============================================================================


def test_get_encryption_key_none_when_unset(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None)
    assert _get_encryption_key() is None


def test_get_encryption_key_none_when_derivation_fails(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "k")
    with patch(
        "app.services.ai_settings_service.derive_fernet_key",
        side_effect=ValueError("bad key"),
    ):
        assert _get_encryption_key() is None


def test_get_legacy_encryption_key_none_when_unset(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None)
    assert _get_legacy_encryption_key() is None


def test_get_legacy_encryption_key_none_when_derivation_fails(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "k")
    with patch(
        "app.services.ai_settings_service.legacy_derive_fernet_key",
        side_effect=ValueError("bad key"),
    ):
        assert _get_legacy_encryption_key() is None


def test_encrypt_api_key_raises_in_production_without_key(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None)
    monkeypatch.setattr(settings, "DEBUG", False)
    with pytest.raises(AIServiceError, match="AI_ENCRYPTION_KEY must be configured"):
        encrypt_api_key("secret")


def test_encrypt_api_key_plaintext_marker_in_debug_without_key(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None)
    monkeypatch.setattr(settings, "DEBUG", True)
    assert encrypt_api_key("secret") == "__PLAINTEXT__secret"


def test_encrypt_api_key_returns_none_on_encryption_failure():
    class _BoomFernet:
        def __init__(self, key):
            pass

        def encrypt(self, data):
            raise RuntimeError("crypto failure")

    with patch("app.services.ai_settings_service.Fernet", _BoomFernet):
        assert encrypt_api_key("secret") is None


def test_decrypt_api_key_plaintext_marker():
    assert decrypt_api_key("__PLAINTEXT__secret") == "secret"


def test_decrypt_api_key_none_without_key(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", None)
    assert decrypt_api_key("garbage-token") is None


def test_decrypt_api_key_skips_none_legacy_key():
    with patch("app.services.ai_settings_service._get_legacy_encryption_key", return_value=None):
        assert decrypt_api_key("not-a-valid-token") is None


def test_decrypt_api_key_handles_unexpected_decrypt_error():
    class _BoomFernet:
        def __init__(self, key):
            pass

        def decrypt(self, token):
            raise RuntimeError("crypto failure")

    with patch("app.services.ai_settings_service._get_legacy_encryption_key", return_value=b"legacy-key"), \
         patch("app.services.ai_settings_service.Fernet", _BoomFernet):
        assert decrypt_api_key("not-a-valid-token") is None


# =============================================================================
# get_user_settings - daily reset and error paths
# =============================================================================


@pytest.mark.asyncio
async def test_get_user_settings_resets_daily_counts_when_stale_string_date(fake_db):
    yesterday = (date.today() - timedelta(days=1)).isoformat()
    fake_db.rows["user_ai_settings"] = [{
        "user_id": "u1", "provider_configs": {}, "default_provider": "custom",
        "daily_extraction_count": 5, "daily_generation_count": 3, "daily_embedding_count": 2,
        "last_reset_date": yesterday,
    }]

    result = await AISettingsService.get_user_settings("u1", db=fake_db)

    assert result["daily_extraction_count"] == 0
    assert result["daily_generation_count"] == 0
    assert result["daily_embedding_count"] == 0
    assert fake_db.updates == [(
        "user_ai_settings",
        {
            "daily_extraction_count": 0,
            "daily_generation_count": 0,
            "daily_embedding_count": 0,
            "last_reset_date": date.today().isoformat(),
        },
    )]


@pytest.mark.asyncio
async def test_get_user_settings_resets_when_last_reset_is_date_object(fake_db):
    yesterday = date.today() - timedelta(days=1)
    fake_db.rows["user_ai_settings"] = [{
        "user_id": "u1", "provider_configs": {}, "default_provider": "custom",
        "daily_extraction_count": 5, "daily_generation_count": 3, "daily_embedding_count": 2,
        "last_reset_date": yesterday,
    }]

    result = await AISettingsService.get_user_settings("u1", db=fake_db)

    assert result["daily_extraction_count"] == 0
    assert fake_db.updates, "expected a reset update"


@pytest.mark.asyncio
async def test_get_user_settings_skips_reset_when_last_reset_is_current(fake_db):
    fake_db.rows["user_ai_settings"] = [{
        "user_id": "u1", "provider_configs": {}, "default_provider": "custom",
        "daily_extraction_count": 5, "daily_generation_count": 3, "daily_embedding_count": 2,
        "last_reset_date": date.today().isoformat(),
    }]

    result = await AISettingsService.get_user_settings("u1", db=fake_db)

    assert result["daily_extraction_count"] == 5
    assert fake_db.updates == []


@pytest.mark.asyncio
async def test_get_user_settings_propagates_as_aiservice_error():
    async def _boom(builder, db, *, extra=None):
        raise RuntimeError("db down")

    with patch("app.services.ai_settings_service.execute_with_reconnect", new=_boom):
        with pytest.raises(AIServiceError, match="Failed to get AI settings"):
            await AISettingsService.get_user_settings("u1", db=object())


# =============================================================================
# update_user_settings - config encryption/merge and error paths
# =============================================================================


@pytest.mark.asyncio
async def test_update_user_settings_encrypts_and_merges_provider_configs(fake_db):
    fake_db.rows["user_ai_settings"] = [{
        "user_id": "u1", "provider_configs": {"custom": {"model": "old"}},
    }]

    result = await AISettingsService.update_user_settings(
        "u1",
        {"provider_configs": {"custom": {"api_key": "new-key", "model": "new"}}},
        db=fake_db,
    )

    cfg = fake_db.rows["user_ai_settings"][0]["provider_configs"]["custom"]
    assert cfg["model"] == "new"
    assert cfg["api_key_encrypted"].startswith("gAAAA")  # Fernet ciphertext
    assert "api_key" not in cfg
    assert result["provider_configs"]["custom"]["model"] == "new"


@pytest.mark.asyncio
async def test_update_user_settings_adds_new_provider_config(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]

    await AISettingsService.update_user_settings(
        "u1", {"provider_configs": {"openai": {"api_key": "k", "model": "m"}}}, db=fake_db,
    )

    cfg = fake_db.rows["user_ai_settings"][0]["provider_configs"]["openai"]
    assert cfg["api_key_encrypted"]
    assert "api_key" not in cfg


@pytest.mark.asyncio
async def test_update_user_settings_without_provider_configs(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]

    result = await AISettingsService.update_user_settings(
        "u1", {"default_provider": "gemini"}, db=fake_db,
    )

    assert result["default_provider"] == "gemini"


@pytest.mark.asyncio
async def test_update_user_settings_config_without_api_key_merged_asis(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]

    await AISettingsService.update_user_settings(
        "u1", {"provider_configs": {"custom": {"model": "m", "vision_model": "vm"}}}, db=fake_db,
    )

    cfg = fake_db.rows["user_ai_settings"][0]["provider_configs"]["custom"]
    assert cfg == {"model": "m", "vision_model": "vm"}


@pytest.mark.asyncio
async def test_update_user_settings_empty_api_key_is_kept_untouched(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]

    await AISettingsService.update_user_settings(
        "u1", {"provider_configs": {"custom": {"api_key": ""}}}, db=fake_db,
    )

    cfg = fake_db.rows["user_ai_settings"][0]["provider_configs"]["custom"]
    assert cfg == {"api_key": ""}


@pytest.mark.asyncio
async def test_update_user_settings_encryption_failure_drops_key(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]

    with patch("app.services.ai_settings_service.encrypt_api_key", return_value=None):
        await AISettingsService.update_user_settings(
            "u1", {"provider_configs": {"custom": {"api_key": "k"}}}, db=fake_db,
        )

    cfg = fake_db.rows["user_ai_settings"][0]["provider_configs"]["custom"]
    assert cfg == {}


@pytest.mark.asyncio
async def test_update_user_settings_falls_back_when_update_returns_no_rows(fake_db):
    # current_settings is supplied, so no pre-read; the update matches nothing
    # (empty table), forcing the get_user_settings fallback which provisions.
    result = await AISettingsService.update_user_settings(
        "u1",
        {"default_provider": "custom"},
        db=fake_db,
        current_settings={"user_id": "u1", "provider_configs": {}},
    )
    assert result["user_id"] == "u1"


@pytest.mark.asyncio
async def test_update_user_settings_propagates_aiservice_error():
    db = _BoomTableDb(RuntimeError("db down"))
    with pytest.raises(AIServiceError, match="Failed to update AI settings"):
        await AISettingsService.update_user_settings(
            "u1", {"x": 1}, db=db, current_settings={"provider_configs": {}},
        )


# =============================================================================
# get_ai_service_for_user - provider resolution edge cases
# =============================================================================


@pytest.mark.asyncio
async def test_get_ai_service_for_user_invalid_default_provider_falls_back_to_custom():
    with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
        "default_provider": "bogus-provider", "provider_configs": {},
    })):
        service = await AISettingsService.get_ai_service_for_user("user-1", db=object())
    assert isinstance(service, AIProviderService)
    await service.close()


@pytest.mark.asyncio
async def test_get_ai_service_for_user_no_fallback_when_requested_is_system_default():
    with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
        "default_provider": "custom", "provider_configs": {},
    })), patch.object(
        AISettingsService, "get_effective_provider_config",
        AsyncMock(side_effect=AIServiceError("custom not configured")),
    ):
        with pytest.raises(AIServiceError):
            await AISettingsService.get_ai_service_for_user("user-1", db=object())


# =============================================================================
# check_rate_limit
# =============================================================================


@pytest.mark.asyncio
async def test_check_rate_limit_extraction_branch(monkeypatch):
    monkeypatch.setattr(settings, "AI_DAILY_EXTRACTION_LIMIT", 10)
    with patch.object(
        AISettingsService, "get_user_settings",
        AsyncMock(return_value={"daily_extraction_count": 8}),
    ):
        result = await AISettingsService.check_rate_limit("u1", "extraction", db=object(), count=2)
    assert result == {"allowed": True, "current_count": 8, "limit": 10, "remaining": 2}

    with patch.object(
        AISettingsService, "get_user_settings",
        AsyncMock(return_value={"daily_extraction_count": 9}),
    ):
        result = await AISettingsService.check_rate_limit("u1", "extraction", db=object(), count=2)
    assert result["allowed"] is False
    assert result["remaining"] == 1


@pytest.mark.asyncio
async def test_check_rate_limit_embedding_and_generation_branches(monkeypatch):
    monkeypatch.setattr(settings, "AI_DAILY_EMBEDDING_LIMIT", 5)
    monkeypatch.setattr(settings, "AI_DAILY_GENERATION_LIMIT", 7)
    with patch.object(
        AISettingsService, "get_user_settings",
        AsyncMock(return_value={"daily_embedding_count": 4}),
    ):
        result = await AISettingsService.check_rate_limit("u1", "embedding", db=object())
    assert result["limit"] == 5
    assert result["remaining"] == 1

    with patch.object(
        AISettingsService, "get_user_settings",
        AsyncMock(return_value={"daily_generation_count": 6}),
    ):
        result = await AISettingsService.check_rate_limit("u1", "generation", db=object())
    assert result["limit"] == 7
    assert result["remaining"] == 1


@pytest.mark.asyncio
async def test_check_rate_limit_clamps_negative_count(monkeypatch):
    monkeypatch.setattr(settings, "AI_DAILY_GENERATION_LIMIT", 7)
    with patch.object(
        AISettingsService, "get_user_settings",
        AsyncMock(return_value={"daily_generation_count": 0}),
    ):
        result = await AISettingsService.check_rate_limit("u1", "generation", db=object(), count="-5")
    assert result["allowed"] is True
    assert result["remaining"] == 7


# =============================================================================
# ensure_ai_settings_row
# =============================================================================


@pytest.mark.asyncio
async def test_ensure_ai_settings_row_returns_when_row_exists(fake_db):
    fake_db.rows["user_ai_settings"] = [{"user_id": "u1", "provider_configs": {}}]
    await AISettingsService.ensure_ai_settings_row("u1", db=fake_db)
    assert fake_db.inserts == []


@pytest.mark.asyncio
async def test_ensure_ai_settings_row_upserts_when_missing(fake_db):
    await AISettingsService.ensure_ai_settings_row("u1", db=fake_db)
    assert fake_db.inserts
    assert fake_db.inserts[0][0] == "user_ai_settings"
    assert fake_db.inserts[0][2] == "user_id"  # on_conflict="user_id"


@pytest.mark.asyncio
async def test_ensure_ai_settings_row_fk_race_raises_account_not_ready():
    async def _boom(builder, db, *, extra=None):
        raise RuntimeError(
            "insert or update on table user_ai_settings violates foreign key "
            "constraint users_id_fkey (23503)"
        )

    with patch("app.services.ai_settings_service.execute_with_reconnect", new=_boom):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.ensure_ai_settings_row("u1", db=object())
    assert exc_info.value.retryable is True
    assert "still being set up" in str(exc_info.value)


@pytest.mark.asyncio
async def test_ensure_ai_settings_row_other_error_raises_quota_unavailable():
    async def _boom(builder, db, *, extra=None):
        raise RuntimeError("db down")

    with patch("app.services.ai_settings_service.execute_with_reconnect", new=_boom):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.ensure_ai_settings_row("u1", db=object())
    assert exc_info.value.retryable is True


# =============================================================================
# reserve_usage / release_usage
# =============================================================================


@pytest.mark.asyncio
async def test_reserve_usage_rejects_non_positive_count():
    with pytest.raises(ValueError, match="count must be positive"):
        await AISettingsService.reserve_usage("u1", "extraction", db=object(), count=0)
    with pytest.raises(ValueError, match="count must be positive"):
        await AISettingsService.reserve_usage("u1", "extraction", db=object(), count=-1)


@pytest.mark.asyncio
async def test_reserve_usage_rejects_unknown_operation():
    with pytest.raises(ValueError, match="Unknown AI operation type"):
        await AISettingsService.reserve_usage("u1", "photoshoot", db=object())


@pytest.mark.asyncio
async def test_reserve_usage_success(fake_db):
    fake_db.rpc_results["reserve_ai_usage"] = [{"reserve_ai_usage": True}]

    ok = await AISettingsService.reserve_usage("u1", "generation", db=fake_db, count=2)

    assert ok is True
    assert fake_db.rpc_calls == [(
        "reserve_ai_usage",
        {
            "p_user_id": "u1",
            "p_operation": "generation",
            "p_count": 2,
            "p_limit": settings.AI_DAILY_GENERATION_LIMIT,
        },
    )]
    # ensure_ai_settings_row ran first and provisioned the default row.
    assert fake_db.inserts and fake_db.inserts[0][0] == "user_ai_settings"


@pytest.mark.asyncio
async def test_reserve_usage_accepts_enum_operation_and_false_result(fake_db):
    fake_db.rpc_results["reserve_ai_usage"] = [{"reserve_ai_usage": False}]

    ok = await AISettingsService.reserve_usage("u1", _Operation.GENERATION, db=fake_db)

    assert ok is False
    assert fake_db.rpc_calls[0][1]["p_operation"] == "generation"


@pytest.mark.asyncio
async def test_reserve_usage_pgrst202_raises_quota_unavailable():
    db = _BoomRpcDb(
        RuntimeError('PGRST202 Could not find the function "reserve_ai_usage" in the schema cache')
    )
    with patch.object(AISettingsService, "ensure_ai_settings_row", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.reserve_usage("u1", "extraction", db=db)
    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_reserve_usage_other_error_raises_quota_unavailable():
    db = _BoomRpcDb(RuntimeError("connection refused"))
    with patch.object(AISettingsService, "ensure_ai_settings_row", AsyncMock()):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.reserve_usage("u1", "extraction", db=db)
    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_release_usage_success(fake_db):
    await AISettingsService.release_usage("u1", "generation", db=fake_db, count=1)
    assert fake_db.rpc_calls == [(
        "release_ai_usage",
        {"p_user_id": "u1", "p_operation": "generation", "p_count": 1},
    )]


@pytest.mark.asyncio
async def test_release_usage_pgrst202_raises():
    async def _boom(builder, db, *, extra=None):
        raise RuntimeError('PGRST202 could not find the function "release_ai_usage"')

    with patch("app.services.ai_settings_service.execute_with_reconnect", new=_boom):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.release_usage("u1", "extraction", db=object())
    assert exc_info.value.retryable is True


@pytest.mark.asyncio
async def test_release_usage_other_error_raises():
    async def _boom(builder, db, *, extra=None):
        raise RuntimeError("db down")

    with patch("app.services.ai_settings_service.execute_with_reconnect", new=_boom):
        with pytest.raises(AIServiceError) as exc_info:
            await AISettingsService.release_usage("u1", "extraction", db=object())
    assert exc_info.value.retryable is True


# =============================================================================
# get_usage_stats / get_provider_display_config
# =============================================================================


@pytest.mark.asyncio
async def test_get_usage_stats_shape(monkeypatch):
    monkeypatch.setattr(settings, "AI_DAILY_EXTRACTION_LIMIT", 10)
    monkeypatch.setattr(settings, "AI_DAILY_GENERATION_LIMIT", 20)
    monkeypatch.setattr(settings, "AI_DAILY_EMBEDDING_LIMIT", 30)
    with patch.object(AISettingsService, "get_user_settings", AsyncMock(return_value={
        "daily_extraction_count": 2,
        "daily_generation_count": 3,
        "daily_embedding_count": 4,
        "total_extractions": 9,
        "total_generations": 8,
        "total_embeddings": 7,
    })):
        stats = await AISettingsService.get_usage_stats("u1", db=object())

    assert stats["daily"] == {"extractions": 2, "generations": 3, "embeddings": 4}
    assert stats["total"] == {"extractions": 9, "generations": 8, "embeddings": 7}
    assert stats["limits"] == {
        "daily_extractions": 10, "daily_generations": 20, "daily_embeddings": 30,
    }
    assert stats["remaining"] == {
        "extractions": 8, "generations": 17, "embeddings": 26,
    }


def test_get_provider_display_config_masks_keys():
    display = AISettingsService.get_provider_display_config({
        "custom": {
            "api_url": "https://x.example.com/v1",
            "model": "m",
            "vision_model": "vm",
            "vision_fallback_model": "vfm",
            "image_gen_model": "igm",
            "api_key_encrypted": "abc",
        },
        "openai": {"api_url": "", "model": ""},
    })

    assert display["custom"]["api_key_set"] is True
    assert "api_key_encrypted" not in display["custom"]
    assert display["custom"]["api_url"] == "https://x.example.com/v1"
    assert display["custom"]["vision_fallback_model"] == "vfm"
    assert display["openai"]["api_key_set"] is False
