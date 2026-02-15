import pytest

from app.core.config import settings
from app.core.exceptions import SocialImportOAuthStateError
from app.models.social_import import SocialPlatform
from app.services.social_oauth_service import SocialOAuthService


def test_oauth_state_roundtrip(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.INSTAGRAM,
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.user_id == "user-123"
    assert parsed.job_id == "job-456"
    assert parsed.platform == SocialPlatform.INSTAGRAM


def test_oauth_state_roundtrip_with_mobile_redirect(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.INSTAGRAM,
        mobile_redirect_uri="fitcheck.ai://social-import-callback",
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.mobile_redirect_uri == "fitcheck.ai://social-import-callback"


def test_oauth_state_ignores_invalid_mobile_redirect(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
        mobile_redirect_uri="https://malicious.example/callback",
    )

    parsed = SocialOAuthService.parse_state(state)
    assert parsed.mobile_redirect_uri is None


def test_oauth_state_rejects_tampering(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)
    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
    )
    encoded_payload, signature = state.split(".", 1)
    tampered = f"{encoded_payload}.{signature[:-1]}x"

    with pytest.raises(SocialImportOAuthStateError):
        SocialOAuthService.parse_state(tampered)


def test_oauth_state_rejects_expired(monkeypatch):
    monkeypatch.setattr(settings, "AI_ENCRYPTION_KEY", "unit-test-state-secret", raising=False)
    monkeypatch.setattr(SocialOAuthService, "_STATE_TTL_SECONDS", -1, raising=False)

    state = SocialOAuthService.create_state(
        user_id="user-123",
        job_id="job-456",
        platform=SocialPlatform.FACEBOOK,
    )

    with pytest.raises(SocialImportOAuthStateError):
        SocialOAuthService.parse_state(state)
