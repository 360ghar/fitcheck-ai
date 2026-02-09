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
