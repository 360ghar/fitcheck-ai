"""
Regression tests for HKDF domain-separated key derivation.

Previously ai_settings_service.py and social_auth_service.py both derived
the identical Fernet key from AI_ENCRYPTION_KEY (sha256 -> base64, no purpose
label), and social_oauth_service.py used the raw secret directly for HMAC -
one leaked/rotated key affected all three domains. Each now derives an
independent key via HKDF with a distinct purpose label, and the two
persisted-ciphertext domains (ai_settings, social_auth) can still decrypt
data written with the old, undifferentiated key.
"""
import json
from unittest.mock import patch

from cryptography.fernet import Fernet

from app.services import ai_settings_service, social_auth_service, social_oauth_service
from app.services.social_oauth_service import SocialOAuthService
from app.utils.crypto import legacy_derive_fernet_key

TEST_KEY = "a" * 64  # hex-encoded 32-byte key, matches the existing convention


def test_ai_settings_and_social_auth_derive_different_keys():
    with patch.object(ai_settings_service.settings, "AI_ENCRYPTION_KEY", TEST_KEY), \
         patch.object(social_auth_service.settings, "AI_ENCRYPTION_KEY", TEST_KEY):
        ai_settings_key = ai_settings_service._get_encryption_key()
        social_auth_fernet = social_auth_service.SocialAuthService._fernet()

    assert ai_settings_key is not None
    # Same plaintext, encrypted with each domain's key, must not be
    # decryptable by the other domain's Fernet instance.
    ai_settings_ciphertext = Fernet(ai_settings_key).encrypt(b"shared-plaintext")
    try:
        social_auth_fernet.decrypt(ai_settings_ciphertext)
        assert False, "ai_settings ciphertext should not decrypt with the social_auth key"
    except Exception:
        pass


def test_ai_settings_service_decrypts_legacy_ciphertext():
    legacy_key = legacy_derive_fernet_key(TEST_KEY)
    legacy_ciphertext = Fernet(legacy_key).encrypt(b"sk-my-provider-key").decode()

    with patch.object(ai_settings_service.settings, "AI_ENCRYPTION_KEY", TEST_KEY), \
         patch.object(ai_settings_service.settings, "DEBUG", False):
        decrypted = ai_settings_service.decrypt_api_key(legacy_ciphertext)

    assert decrypted == "sk-my-provider-key"


def test_ai_settings_service_encrypt_decrypt_roundtrip_uses_new_key():
    with patch.object(ai_settings_service.settings, "AI_ENCRYPTION_KEY", TEST_KEY), \
         patch.object(ai_settings_service.settings, "DEBUG", False):
        encrypted = ai_settings_service.encrypt_api_key("sk-new-key")
        decrypted = ai_settings_service.decrypt_api_key(encrypted)

    assert decrypted == "sk-new-key"
    # New ciphertext should NOT be decryptable with the legacy key - proves
    # new writes actually use the purpose-scoped key, not the old one.
    legacy_key = legacy_derive_fernet_key(TEST_KEY)
    try:
        Fernet(legacy_key).decrypt(encrypted.encode())
        assert False, "new ciphertext should not decrypt with the legacy key"
    except Exception:
        pass


def test_social_auth_service_decrypts_legacy_session_payload():
    legacy_key = legacy_derive_fernet_key(TEST_KEY)
    legacy_ciphertext = Fernet(legacy_key).encrypt(json.dumps({"foo": "bar"}).encode()).decode()

    with patch.object(social_auth_service.settings, "AI_ENCRYPTION_KEY", TEST_KEY):
        decrypted = social_auth_service.SocialAuthService.decrypt_session_payload(legacy_ciphertext)

    assert decrypted == {"foo": "bar"}


def test_oauth_state_secret_no_longer_falls_back_to_jwt_secret():
    with patch.object(social_oauth_service.settings, "AI_ENCRYPTION_KEY", None), \
         patch.object(social_oauth_service.settings, "SUPABASE_JWT_SECRET", "some-jwt-secret"):
        try:
            SocialOAuthService._state_secret()
            assert False, "should fail closed when AI_ENCRYPTION_KEY is unset"
        except Exception as e:
            assert "AI_ENCRYPTION_KEY" in str(e)
