"""
Tests for the configurable process-wide AI concurrency gates.

Verifies that AI_EXTRACTION_CONCURRENCY and AI_GENERATION_CONCURRENCY env vars
are read into Settings and propagated into the asyncio.Semaphore singletons in
app/core/concurrency.py. The semaphores are built at import time, so we reload
the modules under a monkeypatched environment.
"""

import importlib

import pytest

from app.core import concurrency as concurrency_mod
from app.core import config as config_mod


def _reload_with_caps(extraction: int, generation: int, monkeypatch):
    """Reload config + concurrency modules with overridden env caps."""
    monkeypatch.setenv("AI_EXTRACTION_CONCURRENCY", str(extraction))
    monkeypatch.setenv("AI_GENERATION_CONCURRENCY", str(generation))
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)


def _restore_defaults(monkeypatch):
    """Reload modules without the overrides so other tests see defaults."""
    monkeypatch.delenv("AI_EXTRACTION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_GENERATION_CONCURRENCY", raising=False)
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)


def test_defaults_are_30(monkeypatch):
    """Without env overrides the caps (and thus semaphore bounds) are 30."""
    monkeypatch.delenv("AI_EXTRACTION_CONCURRENCY", raising=False)
    monkeypatch.delenv("AI_GENERATION_CONCURRENCY", raising=False)
    importlib.reload(config_mod)
    importlib.reload(concurrency_mod)

    assert config_mod.settings.AI_EXTRACTION_CONCURRENCY == 30
    assert config_mod.settings.AI_GENERATION_CONCURRENCY == 30
    # _value is the remaining permits on a fresh, un-acquired semaphore.
    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 30
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 30


def test_env_overrides_propagate_to_semaphores(monkeypatch):
    """Custom env values flow through Settings into the semaphore bounds."""
    _reload_with_caps(7, 11, monkeypatch)

    assert config_mod.settings.AI_EXTRACTION_CONCURRENCY == 7
    assert config_mod.settings.AI_GENERATION_CONCURRENCY == 11
    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 7
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 11

    _restore_defaults(monkeypatch)


def test_invalid_values_floor_at_one(monkeypatch):
    """0 / negative env values must not produce a zero-cap (deadlocking) semaphore."""
    _reload_with_caps(0, -5, monkeypatch)

    assert concurrency_mod.EXTRACTION_SEMAPHORE._value == 1
    assert concurrency_mod.GENERATION_SEMAPHORE._value == 1

    _restore_defaults(monkeypatch)


@pytest.fixture(autouse=True)
def _restore_modules_after_test(monkeypatch):
    """Ensure other tests see the default 30 singletons regardless of test order."""
    yield
    _restore_defaults(monkeypatch)
