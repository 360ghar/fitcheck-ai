"""Regression coverage for the one-off campaign safety scripts."""

from __future__ import annotations

import importlib.util
from pathlib import Path
from types import SimpleNamespace

import pytest


BACKEND_ROOT = Path(__file__).resolve().parents[1]


def _load(name: str):
    path = BACKEND_ROOT / "scripts" / name
    spec = importlib.util.spec_from_file_location(path.stem, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


grant = _load("grant_free_pro_month.py")
revert = _load("revert_expired_pro_trials.py")


class _Query:
    def __init__(self, data=None, *, update_payloads=None):
        self.data = data or []
        self.update_payloads = update_payloads if update_payloads is not None else []
        self.payload = None
        self.filters = []
        self.null_filters = []

    def select(self, *_args):
        return self

    def order(self, *_args):
        return self

    def range(self, *_args):
        return self

    def in_(self, *_args):
        return self

    def update(self, payload):
        self.payload = payload
        self.update_payloads.append(payload)
        return self

    def eq(self, *args):
        self.filters.append(args)
        return self

    def is_(self, *args):
        self.null_filters.append(args)
        return self

    def execute(self):
        return SimpleNamespace(data=self.data)


class _RevertDb:
    def __init__(self, row):
        self.select_query = _Query([row])
        self.update_payloads = []
        self.update_query = _Query([row], update_payloads=self.update_payloads)

    def table(self, _name):
        return self

    def select(self, *_args):
        return self.select_query

    def update(self, payload):
        return self.update_query.update(payload)

    def in_(self, *args):
        return self.select_query.in_(*args)


class _GrantDb:
    def __init__(self):
        self.user_query = _Query(
            [{"id": "user-1", "email": "user@real.test", "full_name": "User"}]
        )
        self.sub_query = _Query([{
            "user_id": "user-1",
            "plan_type": "free",
            "status": "active",
            "stripe_subscription_id": None,
        }])
        # Empty update result simulates a concurrent checkout changing the row
        # after the eligibility read but before the conditional grant.
        self.update_query = _Query([])
        self.range_calls = 0

    def table(self, name):
        self.current_table = name
        return self

    def select(self, *_args):
        return self.user_query if self.current_table == "users" else self.sub_query

    def order(self, *_args):
        return self

    def range(self, *_args):
        self.range_calls += 1
        return self

    def in_(self, *_args):
        return self

    def update(self, _payload):
        return self.update_query

    def eq(self, *args):
        return self.update_query

    def is_(self, *args):
        return self.update_query

    def execute(self):
        if self.current_table == "users":
            # First page has one user; the next page ends iteration.
            return SimpleNamespace(data=self.user_query.data if self.range_calls == 1 else [])
        if self.current_table == "subscriptions":
            return SimpleNamespace(data=self.sub_query.data)
        return self.update_query.execute()


def test_resend_credentials_are_required_before_any_grant_write(monkeypatch, tmp_path):
    monkeypatch.setenv("SUPABASE_URL", "https://project.supabase.co")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "service-key")
    monkeypatch.setenv("SKIP_EMAIL", "0")
    monkeypatch.setenv("EMAIL_TRANSPORT", "resend")
    monkeypatch.setenv("AUDIT_FILE", str(tmp_path / "grant.jsonl"))
    monkeypatch.delenv("RESEND_API_KEY", raising=False)

    create_client_called = False

    def fail_if_client_created(*_args, **_kwargs):
        nonlocal create_client_called
        create_client_called = True
        raise AssertionError("database client must not be created before credential validation")

    monkeypatch.setattr(grant, "create_client", fail_if_client_created)
    with pytest.raises(SystemExit):
        grant.main()

    assert create_client_called is False


def test_conditional_grant_skips_a_row_changed_by_a_concurrent_checkout(monkeypatch, tmp_path):
    db = _GrantDb()
    monkeypatch.setenv("SUPABASE_URL", "https://project.supabase.co")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "service-key")
    monkeypatch.setenv("SKIP_EMAIL", "1")
    monkeypatch.setenv("DRY_RUN", "0")
    monkeypatch.setenv("AUDIT_FILE", str(tmp_path / "grant.jsonl"))
    monkeypatch.setattr(grant, "create_client", lambda *_args: db)

    assert grant.main() == 0
    assert not (tmp_path / "grant.jsonl").exists()


def test_include_paid_requires_confirmation_and_clears_stripe_ids(monkeypatch, tmp_path):
    trial_end = "2020-01-01T00:00:00+00:00"
    audit = tmp_path / "grant.jsonl"
    audit.write_text('{"user_id":"user-1","action":"granted","trial_end":"' + trial_end + '"}\n')
    db = _RevertDb({
        "user_id": "user-1",
        "plan_type": "pro_monthly",
        "status": "trial",
        "stripe_subscription_id": "sub_external",
        "trial_end": trial_end,
    })
    monkeypatch.setenv("SUPABASE_URL", "https://project.supabase.co")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "service-key")
    monkeypatch.setenv("AUDIT_FILE", str(audit))
    monkeypatch.setenv("INCLUDE_PAID", "1")
    monkeypatch.setenv("STRIPE_CANCEL_CONFIRMED", "1")
    monkeypatch.setattr(revert, "create_client", lambda *_args: db)

    assert revert.main() == 0
    assert db.update_payloads == [{
        "plan_type": "free",
        "status": "active",
        "trial_end": None,
        "current_period_end": None,
        "cancel_at_period_end": False,
        "stripe_subscription_id": None,
        "stripe_customer_id": None,
    }]


def test_malformed_campaign_timestamp_is_skipped(monkeypatch, tmp_path, capsys):
    audit = tmp_path / "grant.jsonl"
    audit.write_text('{"user_id":"user-1","action":"granted","trial_end":"not-a-date"}\n')
    monkeypatch.setenv("SUPABASE_URL", "https://project.supabase.co")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "service-key")
    monkeypatch.setenv("AUDIT_FILE", str(audit))

    # No expired valid records means the database client must not be touched.
    monkeypatch.setattr(revert, "create_client", lambda *_args: pytest.fail("unexpected database access"))
    assert revert.main() == 0
    assert "malformed trial_end" in capsys.readouterr().out


def test_non_string_campaign_timestamp_is_skipped(monkeypatch, tmp_path, capsys):
    audit = tmp_path / "grant.jsonl"
    audit.write_text('{"user_id":"user-1","action":"granted","trial_end":123}\n')
    monkeypatch.setenv("SUPABASE_URL", "https://project.supabase.co")
    monkeypatch.setenv("SUPABASE_SECRET_KEY", "service-key")
    monkeypatch.setenv("AUDIT_FILE", str(audit))

    monkeypatch.setattr(revert, "create_client", lambda *_args: pytest.fail("unexpected database access"))
    assert revert.main() == 0
    assert "malformed trial_end" in capsys.readouterr().out
