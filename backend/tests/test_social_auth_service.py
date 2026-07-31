import typing
from datetime import datetime, timezone

import pytest

from app.core.exceptions import SocialImportEncryptionConfigError
from app.services.social_auth_service import SocialAuthService


def test_encrypt_decrypt_session_payload_roundtrip(monkeypatch):
    monkeypatch.setattr('app.services.social_auth_service.settings.AI_ENCRYPTION_KEY', 'a' * 64)

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
    monkeypatch.setattr('app.services.social_auth_service.settings.AI_ENCRYPTION_KEY', None)

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
