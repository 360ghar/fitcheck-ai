"""
Tests for the configurable process-wide AI concurrency gates.

Verifies that AI_EXTRACTION_CONCURRENCY, AI_GENERATION_CONCURRENCY and
AI_IMAGE_PROVIDER_CONCURRENCY env vars are read into Settings and propagated
into the asyncio.Semaphore singletons in app/core/concurrency.py. The
semaphores are built at import time, so we reload the modules under a
monkeypatched environment.
"""

import importlib
from typing import Optional

import pytest

from app.core import concurrency as concurrency_mod
from app.core import config as config_mod


def _reload_with_caps(
    extraction: int,
    generation: int,
    monkeypatch,
    provider: Optional[int] = None,
):
    """Reload config + concurrency modules with overridden env caps."""
    monkeypatch.setenv("AI_EXTRACTION_CONCURRENCY", str(extraction))
    monkeypatch.setenv("AI_GENERATION_CONCURRENCY", str(generation))
    if provider is None:
        monkeypatch.delenv("AI_IMAGE_PROVIDER_CONCURRENCY", raising=False)
    else:
        monkeypatch.setenv("AI_IMAGE_PROVIDER_CONCURRENCY", str(provider))
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)


def _restore_defaults(monkeypatch):
    """Reload modules without the overrides so other tests see defaults."""
    monkeypatch.delenv("AI_EXTRACTION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_GENERATION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_IMAGE_PROVIDER_CONCURRENCY", raising=False)
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)


def test_defaults_are_30(monkeypatch):
    """Without env overrides the process caps (and semaphore bounds) are 30,
    and the provider gate defaults to 15."""
    monkeypatch.delenv("AI_EXTRACTION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_GENERATION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_IMAGE_PROVIDER_CONCURRENCY", raising=False)
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)

    assert config_mod.settings.AI_EXTRACTION_CONCURRENCY == 30
    assert config_mod.settings.AI_GENERATION_CONCURRENCY == 30
    assert config_mod.settings.AI_IMAGE_PROVIDER_CONCURRENCY == 15
    # _value is the remaining permits on a fresh, un-acquired semaphore.
    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 30
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 30
    assert concurrency_mod.IMAGE_PROVIDER_SEMAPHORE._value == 15


def test_env_overrides_propagate_to_semaphores(monkeypatch):
    """Custom env values flow through Settings into the semaphore bounds."""
    _reload_with_caps(7, 11, monkeypatch)

    assert config_mod.settings.AI_EXTRACTION_CONCURRENCY == 7
    assert config_mod.settings.AI_GENERATION_CONCURRENCY == 11
    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 7
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 11

    _restore_defaults(monkeypatch)


def test_provider_concurrency_env_override(monkeypatch):
    """AI_IMAGE_PROVIDER_CONCURRENCY is settable independently of the
    process-wide generation cap (2026-09-17: the Agnes gateway caps image
    concurrency well below AI_GENERATION_CONCURRENCY)."""
    _reload_with_caps(7, 11, monkeypatch, provider=2)

    assert config_mod.settings.AI_IMAGE_PROVIDER_CONCURRENCY == 2
    assert concurrency_mod.IMAGE_PROVIDER_SEMAPHORE._value == 2

    _restore_defaults(monkeypatch)


def test_provider_concurrency_cannot_exceed_generation_cap(monkeypatch):
    """The nested provider gate must be the binding constraint; a provider
    value above the generation cap would silently do nothing."""
    _reload_with_caps(7, 3, monkeypatch, provider=15)

    assert concurrency_mod.GENERATION_SEMAPHORE._value == 3
    assert concurrency_mod.IMAGE_PROVIDER_SEMAPHORE._value == 3

    _restore_defaults(monkeypatch)


def test_provider_concurrency_default_is_clamped_to_generation_cap(monkeypatch):
    """Even the default provider value is clamped when the generation cap is
    lowered below it."""
    _reload_with_caps(7, 2, monkeypatch)

    assert config_mod.settings.AI_IMAGE_PROVIDER_CONCURRENCY == 15
    assert concurrency_mod.IMAGE_PROVIDER_SEMAPHORE._value == 2

    _restore_defaults(monkeypatch)


def test_invalid_values_floor_at_one(monkeypatch):
    """0 / negative env values must not produce a zero-cap (deadlocking) semaphore."""
    _reload_with_caps(0, -5, monkeypatch, provider=-3)

    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 1
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 1
    assert concurrency_mod.IMAGE_PROVIDER_SEMAPHORE._value == 1

    _restore_defaults(monkeypatch)


@pytest.fixture(autouse=True)
def _restore_modules_after_test(monkeypatch):
    """Ensure other tests see the default 30 singletons regardless of test order."""
    yield
    _restore_defaults(monkeypatch)
