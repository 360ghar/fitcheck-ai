"""
CORS allowlist assembly tests.

BACKEND_CORS_ORIGINS (env override) is merged with the always-allowed
first-party origins in Settings._ensure_cors_origins. Regression: on
2026-08-07 the production Railway env predated the admin panel, so
admin.fitcheckaiapp.com was missing from the allowlist and the admin panel's
cross-origin API calls were rejected (preflight 400, no allow-origin header).
A stale override must never be able to drop a first-party origin again.
"""

import importlib

import pytest

from app.core import config as config_mod

# Canonical first-party origins from Settings.ALWAYS_ALLOWED_CORS_ORIGINS.
FIRST_PARTY_ORIGINS = (
    "https://www.fitcheckaiapp.com",
    "https://fitcheckaiapp.com",
    "https://admin.fitcheckaiapp.com",
)


@pytest.fixture(autouse=True)
def _restore_config_defaults(monkeypatch):
    """Reload config with no env override after each test so the shared
    settings singleton returns to its default state."""
    yield
    monkeypatch.delenv("BACKEND_CORS_ORIGINS", raising=False)
    importlib.reload(config_mod)


def test_stale_env_override_keeps_first_party_origins(monkeypatch):
    """An override omitting the admin origin still allows it (2026-08-07)."""
    monkeypatch.setenv(
        "BACKEND_CORS_ORIGINS",
        "https://www.fitcheckaiapp.com,https://fitcheckaiapp.com",
    )
    importlib.reload(config_mod)

    origins = config_mod.settings.BACKEND_CORS_ORIGINS
    for origin in FIRST_PARTY_ORIGINS:
        assert origin in origins


def test_env_override_still_controls_non_first_party_origins(monkeypatch):
    """Everything outside the always-allowed set still follows the env value."""
    monkeypatch.setenv("BACKEND_CORS_ORIGINS", "https://only.example.com")
    importlib.reload(config_mod)

    origins = config_mod.settings.BACKEND_CORS_ORIGINS
    assert "https://only.example.com" in origins
    assert "http://localhost:5173" not in origins


def test_json_array_override_parses_and_merges(monkeypatch):
    """JSON-array env values keep working and still merge first-party origins."""
    monkeypatch.setenv(
        "BACKEND_CORS_ORIGINS",
        '["https://one.example.com","https://two.example.com"]',
    )
    importlib.reload(config_mod)

    origins = config_mod.settings.BACKEND_CORS_ORIGINS
    assert "https://one.example.com" in origins
    assert "https://two.example.com" in origins
    assert "https://admin.fitcheckaiapp.com" in origins
