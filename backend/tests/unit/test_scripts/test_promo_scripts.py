"""Regression coverage for the promo code creation script."""

from __future__ import annotations

import importlib.util
from pathlib import Path

import app

import pytest

BACKEND_ROOT = Path(app.__file__).resolve().parents[1]


def _load(name: str):
    path = BACKEND_ROOT / "scripts" / name
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


create_promo = _load("create_promo_code.py")


def test_code_regex_accepts_valid_campaign_codes():
    for code in ("LAUNCH30", "launch-30", "friends_2026", "PROMO1"):
        assert create_promo.CODE_RE.match(code), code


def test_code_regex_rejects_malformed_codes():
    for code in ("a", "ab", "has space", "emoji🔥", "code with spaces!"):
        assert not create_promo.CODE_RE.match(code), code


def test_parse_expires_normalizes_plain_date_to_timestamp():
    parsed = create_promo._parse_expires("2026-09-01")
    assert parsed.startswith("2026-09-01T00:00:00")
    # Ends with a numeric UTC offset (e.g. +00:00 / +05:30) from the local zone.
    assert "+" in parsed[-6:]
    assert ":" in parsed[-5:]


def test_parse_expires_rejects_garbage(monkeypatch):
    with pytest.raises(SystemExit) as exc:
        create_promo._parse_expires("not-a-date")
    assert exc.value.code == 2


def test_dry_run_returns_zero_without_env(monkeypatch, capsys):
    """DRY_RUN=1 must never read env vars or touch the network."""
    monkeypatch.setenv("DRY_RUN", "1")
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_SECRET_KEY", raising=False)
    monkeypatch.setattr(
        "sys.argv",
        ["create_promo_code.py", "--code", "LAUNCH30", "--plan", "pro_monthly", "--months", "1"],
    )

    code = create_promo.main()
    out = capsys.readouterr().out

    assert code == 0
    assert "DRY RUN" in out
    assert "?promo=LAUNCH30" in out  # shareable URL is printed for the operator
