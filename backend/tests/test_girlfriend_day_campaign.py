"""Regression coverage for the Girlfriend's Day campaign script."""

from __future__ import annotations

import importlib.util
from pathlib import Path

BACKEND_ROOT = Path(__file__).resolve().parents[1]


def _load(name: str):
    path = BACKEND_ROOT / "scripts" / name
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


campaign = _load("girlfriend_day_campaign.py")


def test_render_email_contains_code_and_share_url(monkeypatch):
    monkeypatch.setenv("FRONTEND_URL", "https://fitcheckaiapp.com")
    html, text = campaign._render_email("Saksham", "GFDAY2026",
                                        "https://fitcheckaiapp.com/auth/register?promo=GFDAY2026")

    assert "Hi Saksham," in text
    assert "GFDAY2026" in text
    assert "https://fitcheckaiapp.com/auth/register?promo=GFDAY2026" in text
    assert "girlies" in text
    # HTML carries the same code and a CTA button to the share URL.
    assert "GFDAY2026" in html
    assert "auth/register?promo=GFDAY2026" in html
    assert "1 month of FitCheck Pro free" in html


def test_render_email_falls_back_to_generic_greeting():
    html, text = campaign._render_email(None, "GFDAY2026", "https://x.test/register?promo=GFDAY2026")
    assert "Hi there," in text


def test_transport_plan_split_honors_resend_cap():
    users = [{"id": str(i)} for i in range(12)]

    plan = campaign._get_transport_plan(users, resend_cap=5, mode="split")

    assert len(plan["resend"]) == 5
    assert len(plan["smtp"]) == 7


def test_transport_plan_split_caps_at_recipient_count():
    users = [{"id": str(i)} for i in range(3)]

    plan = campaign._get_transport_plan(users, resend_cap=100, mode="split")

    assert len(plan["resend"]) == 3
    assert len(plan["smtp"]) == 0


def test_transport_plan_modes():
    users = [{"id": "1"}, {"id": "2"}]

    assert len(campaign._get_transport_plan(users, 100, "resend")["smtp"]) == 0
    assert len(campaign._get_transport_plan(users, 100, "smtp")["resend"]) == 0


def test_bogus_domain_skip():
    assert campaign._is_bogus_email("a@example.com") is True
    assert campaign._is_bogus_email("a@test.com") is True
    assert campaign._is_bogus_email("saksham1991999@gmail.com") is False


def test_preview_mode_requires_no_env(monkeypatch, capsys):
    monkeypatch.delenv("SUPABASE_URL", raising=False)
    monkeypatch.delenv("SUPABASE_SECRET_KEY", raising=False)
    monkeypatch.setattr(
        "sys.argv",
        ["girlfriend_day_campaign.py", "--code", "GFDAY2026", "--preview"],
    )

    code = campaign.main()
    out = capsys.readouterr().out

    assert code == 0
    assert "Happy Girlfriend's Day" in out
    assert "GFDAY2026" in out
    assert "auth/register?promo=GFDAY2026" in out
