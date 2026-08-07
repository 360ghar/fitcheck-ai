"""Tests for SocialAuthService: encrypted session storage/retrieval on FakeDB,
fernet factory behavior, and the decrypt fallback chain (current key, then the
legacy pre-domain-separation key)."""

import json
import typing
from datetime import datetime, timezone

import pytest
from cryptography.fernet import Fernet, InvalidToken

from app.core.exceptions import (
    SocialImportEncryptionConfigError,
    SocialImportLoginFailedError,
    SocialImportMFARequiredError,
)
from app.services.social_auth_service import SocialAuthService
from app.utils.crypto import legacy_derive_fernet_key

SETTINGS_KEY = "app.services.social_auth_service.settings.AI_ENCRYPTION_KEY"


@pytest.fixture(autouse=True)
def _encryption_key(monkeypatch):
    monkeypatch.setattr(SETTINGS_KEY, "a" * 64, raising=False)


def _legacy_encrypt(payload: dict) -> str:
    """Encrypt with the pre-domain-separation derivation (sha256 of the key).

    Reads the key from the service module's own settings reference: other test
    files (tests/unit/test_core) reload app.core.config at teardown, which
    swaps app.core.config.settings for a fresh instance, so a fresh import here
    could read a different object than the one the test monkeypatches.
    """
    from app.services import social_auth_service

    fernet = Fernet(legacy_derive_fernet_key(social_auth_service.settings.AI_ENCRYPTION_KEY))
    return fernet.encrypt(json.dumps(payload).encode("utf-8")).decode("utf-8")


# ---------------------------------------------------------------------------
# existing tests (kept from the original file)
# ---------------------------------------------------------------------------


def test_encrypt_decrypt_session_payload_roundtrip(monkeypatch):
    monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

    payload = {
        'provider_access_token': 'token-123',
        'provider_user_id': 'user-1',
    }

    encrypted = SocialAuthService.encrypt_session_payload(payload)
    assert encrypted
    assert encrypted != payload['provider_access_token']

    decrypted = SocialAuthService.decrypt_session_payload(encrypted)
    assert decrypted == payload


def test_encrypt_session_payload_fails_closed_without_encryption_key(monkeypatch):
    monkeypatch.setattr(SETTINGS_KEY, None)

    payload = {'username': 'demo', 'password': 'demo-pass'}

    with pytest.raises(SocialImportEncryptionConfigError):
        SocialAuthService.encrypt_session_payload(payload)


def test_expiry_returns_aware_future_datetime(monkeypatch):
    monkeypatch.setattr(
        'app.services.social_auth_service.settings.SOCIAL_IMPORT_AUTH_SESSION_TTL_MINUTES',
        30,
    )

    expiry = SocialAuthService._expiry()

    assert isinstance(expiry, datetime)
    assert expiry.tzinfo is not None
    assert expiry > datetime.now(timezone.utc)


def test_expiry_floors_ttl_at_five_minutes(monkeypatch):
    monkeypatch.setattr(
        'app.services.social_auth_service.settings.SOCIAL_IMPORT_AUTH_SESSION_TTL_MINUTES',
        0,
    )

    delta = SocialAuthService._expiry() - datetime.now(timezone.utc)

    assert 4 * 60 < delta.total_seconds() <= 5 * 60


@pytest.mark.parametrize('func_name', ['_expiry', 'store_oauth_session'])
def test_annotations_are_resolvable(func_name):
    """Guard the `datetime` F821 that shipped here.

    ``social_auth_service`` uses ``from __future__ import annotations``, so a
    missing name in a signature stays latent until something resolves the
    hints (``get_type_hints``, Pydantic, FastAPI dependency parsing). These two
    signatures referenced ``datetime`` without importing it; resolving them is
    the cheapest assertion that the module's names are actually all present.
    """
    func = getattr(SocialAuthService, func_name)

    hints = typing.get_type_hints(func)

    assert hints  # resolution succeeded rather than raising NameError


# ---------------------------------------------------------------------------
# fernet factories
# ---------------------------------------------------------------------------


class TestFernetFactories:
    def test_both_fernets_return_none_without_key(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, None)

        assert SocialAuthService._fernet() is None
        assert SocialAuthService._legacy_fernet() is None

    def test_fernet_factories_return_instances_with_key(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

        assert isinstance(SocialAuthService._fernet(), Fernet)
        assert isinstance(SocialAuthService._legacy_fernet(), Fernet)

    def test_legacy_and_current_keys_are_domain_separated(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        payload = json.dumps({"k": "v"}).encode("utf-8")

        current = SocialAuthService._fernet()
        legacy = SocialAuthService._legacy_fernet()
        encrypted_current = current.encrypt(payload)
        encrypted_legacy = legacy.encrypt(payload)

        # Cross-decryption must fail: the two derivations are distinct keys.
        with pytest.raises(InvalidToken):
            legacy.decrypt(encrypted_current)
        with pytest.raises(InvalidToken):
            current.decrypt(encrypted_legacy)


# ---------------------------------------------------------------------------
# decrypt_session_payload
# ---------------------------------------------------------------------------


class TestDecryptSessionPayload:
    def test_empty_payload_returns_none(self):
        assert SocialAuthService.decrypt_session_payload("") is None

    def test_garbage_payload_returns_none(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

        assert SocialAuthService.decrypt_session_payload("not-a-fernet-token") is None

    def test_no_key_configured_returns_none(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, None)

        assert SocialAuthService.decrypt_session_payload("garbage") is None

    def test_legacy_ciphertext_still_readable(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        payload = {"username": "legacy-user", "password": "p"}

        encrypted = _legacy_encrypt(payload)

        assert SocialAuthService.decrypt_session_payload(encrypted) == payload

    def test_invalid_utf8_payload_returns_none(self, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        # Valid Fernet token whose plaintext is not UTF-8 -> decode ValueError
        # must fall through both fernets and return None.
        encrypted = SocialAuthService._fernet().encrypt(b"\xff\xfe\x00garbage").decode("utf-8")

        assert SocialAuthService.decrypt_session_payload(encrypted) is None


# ---------------------------------------------------------------------------
# store_oauth_session
# ---------------------------------------------------------------------------


class TestStoreOAuthSession:
    @pytest.mark.asyncio
    async def test_upserts_encrypted_oauth_session(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        expires_at = datetime(2026, 9, 1, 12, 0, 0, tzinfo=timezone.utc)

        data = await SocialAuthService.store_oauth_session(
            fake_db,
            job_id="job-1",
            user_id="user-1",
            provider_access_token="tok",
            provider_refresh_token="refresh",
            provider_user_id="ig-1",
            provider_page_access_token="page-tok",
            provider_page_id="page-1",
            provider_username="my.handle",
            expires_at=expires_at,
        )

        assert data["job_id"] == "job-1"
        assert data["user_id"] == "user-1"
        assert data["auth_type"] == "oauth"
        assert data["expires_at"]
        fake_db.assert_insert(
            "social_import_auth_sessions",
            job_id="job-1",
            user_id="user-1",
            auth_type="oauth",
        )

        stored = fake_db.rows["social_import_auth_sessions"][0]
        payload = SocialAuthService.decrypt_session_payload(stored["encrypted_session_blob"])
        assert payload["provider_access_token"] == "tok"
        assert payload["provider_refresh_token"] == "refresh"
        assert payload["provider_user_id"] == "ig-1"
        assert payload["provider_page_access_token"] == "page-tok"
        assert payload["provider_page_id"] == "page-1"
        assert payload["provider_username"] == "my.handle"
        assert payload["provider_expires_at"] == expires_at.isoformat()
        assert payload["saved_at"]

    @pytest.mark.asyncio
    async def test_oauth_session_without_expiry_stores_null(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

        await SocialAuthService.store_oauth_session(
            fake_db,
            job_id="job-2",
            user_id="user-1",
            provider_access_token="t",
            provider_refresh_token=None,
            provider_user_id=None,
            expires_at=None,
        )

        stored = fake_db.rows["social_import_auth_sessions"][0]
        payload = SocialAuthService.decrypt_session_payload(stored["encrypted_session_blob"])
        assert payload["provider_expires_at"] is None
        assert payload["provider_refresh_token"] is None


# ---------------------------------------------------------------------------
# store_scraper_session
# ---------------------------------------------------------------------------


class TestStoreScraperSession:
    @pytest.mark.asyncio
    async def test_missing_username_or_password_raises(self, fake_db):
        with pytest.raises(SocialImportLoginFailedError):
            await SocialAuthService.store_scraper_session(
                fake_db, job_id="j", user_id="u", username="", password="pass", otp_code=None,
            )
        with pytest.raises(SocialImportLoginFailedError):
            await SocialAuthService.store_scraper_session(
                fake_db, job_id="j", user_id="u", username="user", password="", otp_code=None,
            )
        assert fake_db.ops_on("social_import_auth_sessions") == []

    @pytest.mark.asyncio
    async def test_mfa_username_without_otp_raises(self, fake_db):
        with pytest.raises(SocialImportMFARequiredError):
            await SocialAuthService.store_scraper_session(
                fake_db, job_id="j", user_id="u", username="MFA-user", password="pass", otp_code=None,
            )

    @pytest.mark.asyncio
    async def test_upserts_encrypted_scraper_session(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

        data = await SocialAuthService.store_scraper_session(
            fake_db,
            job_id="job-3",
            user_id="user-1",
            username="mfa-user",
            password="pass",
            otp_code="123456",
            two_factor_identifier="tf-id",
            sessionid="sess",
            csrftoken="csrf",
            ds_user_id="42",
        )

        assert data["auth_type"] == "scraper"
        fake_db.assert_insert(
            "social_import_auth_sessions",
            job_id="job-3",
            user_id="user-1",
            auth_type="scraper",
        )

        stored = fake_db.rows["social_import_auth_sessions"][0]
        payload = SocialAuthService.decrypt_session_payload(stored["encrypted_session_blob"])
        assert payload["username"] == "mfa-user"
        assert payload["password"] == "pass"
        assert payload["otp_code"] == "123456"
        assert payload["two_factor_identifier"] == "tf-id"
        assert payload["sessionid"] == "sess"
        assert payload["csrftoken"] == "csrf"
        assert payload["ds_user_id"] == "42"
        assert payload["session_kind"] == "ephemeral_credentials"
        assert payload["saved_at"]


# ---------------------------------------------------------------------------
# get_active_session / delete_sessions / cleanup_expired_sessions
# ---------------------------------------------------------------------------


class TestGetActiveSession:
    @pytest.mark.asyncio
    async def test_returns_none_when_no_rows(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)

        session = await SocialAuthService.get_active_session(fake_db, job_id="job-1", user_id="user-1")

        assert session is None

    @pytest.mark.asyncio
    async def test_returns_row_with_decrypted_payload(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        payload = {"provider_access_token": "tok", "provider_user_id": "ig-1"}
        fake_db.rows["social_import_auth_sessions"] = [
            {
                "job_id": "job-1",
                "user_id": "user-1",
                "encrypted_session_blob": SocialAuthService.encrypt_session_payload(payload),
                "expires_at": "2999-01-01T00:00:00+00:00",
                "created_at": "2026-01-01T00:00:00+00:00",
            },
        ]

        session = await SocialAuthService.get_active_session(fake_db, job_id="job-1", user_id="user-1")

        assert session["job_id"] == "job-1"
        assert session["session_payload"] == payload
        assert ("social_import_auth_sessions", "eq", "job_id", "job-1") in fake_db.filters
        assert ("social_import_auth_sessions", "eq", "user_id", "user-1") in fake_db.filters

    @pytest.mark.asyncio
    async def test_undecryptable_blob_returns_none(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        fake_db.rows["social_import_auth_sessions"] = [
            {
                "job_id": "job-1",
                "user_id": "user-1",
                "encrypted_session_blob": "garbage",
                "expires_at": "2999-01-01T00:00:00+00:00",
            },
        ]

        assert await SocialAuthService.get_active_session(fake_db, job_id="job-1", user_id="user-1") is None

    @pytest.mark.asyncio
    async def test_expired_row_is_excluded(self, fake_db, monkeypatch):
        monkeypatch.setattr(SETTINGS_KEY, 'a' * 64)
        fake_db.rows["social_import_auth_sessions"] = [
            {"job_id": "job-1", "user_id": "user-1", "encrypted_session_blob": "x",
             "expires_at": "2000-01-01T00:00:00+00:00"},
            {"job_id": "job-2", "user_id": "user-1", "encrypted_session_blob": "x",
             "expires_at": "2999-01-01T00:00:00+00:00"},
        ]

        assert await SocialAuthService.get_active_session(fake_db, job_id="job-1", user_id="user-1") is None
        assert any(op == "gte" and col == "expires_at" for _t, op, col, _v in fake_db.filters)


class TestDeleteSessions:
    @pytest.mark.asyncio
    async def test_deletes_only_matching_rows(self, fake_db):
        fake_db.rows["social_import_auth_sessions"] = [
            {"job_id": "job-1", "user_id": "user-1"},
            {"job_id": "job-1", "user_id": "user-1"},
            {"job_id": "job-1", "user_id": "user-2"},
        ]

        await SocialAuthService.delete_sessions(fake_db, job_id="job-1", user_id="user-1")

        assert fake_db.rows["social_import_auth_sessions"] == [{"job_id": "job-1", "user_id": "user-2"}]
        assert fake_db.ops_on("social_import_auth_sessions") == [("delete", None)]


class TestCleanupExpiredSessions:
    @pytest.mark.asyncio
    async def test_deletes_expired_rows_and_returns_count(self, fake_db):
        fake_db.rows["social_import_auth_sessions"] = [
            {"id": 1, "expires_at": "2000-01-01T00:00:00+00:00"},
            {"id": 2, "expires_at": "2999-01-01T00:00:00+00:00"},
            {"id": 3, "expires_at": "2001-01-01T00:00:00+00:00"},
        ]

        deleted = await SocialAuthService.cleanup_expired_sessions(fake_db)

        assert deleted == 2
        assert [row["id"] for row in fake_db.rows["social_import_auth_sessions"]] == [2]
        assert any(op == "lt" and col == "expires_at" for _t, op, col, _v in fake_db.filters)
