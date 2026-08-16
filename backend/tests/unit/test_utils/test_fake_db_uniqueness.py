"""Tests for the fake DB's uniqueness semantics (tests/utils/fake_db.py).

The fake mirrors PostgREST here: a plain ``insert`` that collides with an
existing unique key raises (SQLSTATE 23505), while ``upsert(..., on_conflict=
...)`` replaces the conflicting row in place. Pinning this is what lets the
suite catch upsert-vs-insert regressions (services that use ``insert`` where
they must be idempotent).
"""

import pytest

from tests.utils.fake_db import (
    PGRSTDuplicateError,
    UNIQUE_KEYS,
    FakeDB,
)


def test_unique_key_registry_mirrors_migrations():
    assert UNIQUE_KEYS["subscriptions"] == ("user_id",)
    assert UNIQUE_KEYS["promo_redemptions"] == ("user_id",)
    assert UNIQUE_KEYS["shared_outfits"] == ("outfit_id", "user_id")
    assert UNIQUE_KEYS["user_preferences"] == ("user_id",)
    assert UNIQUE_KEYS["user_settings"] == ("user_id",)
    assert UNIQUE_KEYS["user_ai_settings"] == ("user_id",)
    assert UNIQUE_KEYS["referral_redemptions"] == ("referred_user_id",)
    assert UNIQUE_KEYS["waitlist"] == ("email",)


def test_plain_insert_raises_on_duplicate_unique_key():
    db = FakeDB()
    db.table("waitlist").insert({"email": "a@example.com", "full_name": "A"}).execute()

    with pytest.raises(PGRSTDuplicateError) as exc_info:
        db.table("waitlist").insert({"email": "a@example.com", "full_name": "B"}).execute()

    assert exc_info.value.code == "23505"
    assert len(db.rows["waitlist"]) == 1


def test_plain_insert_appends_when_key_is_free():
    db = FakeDB()
    db.table("waitlist").insert({"email": "a@example.com"}).execute()
    db.table("waitlist").insert({"email": "b@example.com"}).execute()

    assert len(db.rows["waitlist"]) == 2


def test_multi_row_insert_with_intra_batch_duplicate_raises():
    db = FakeDB()
    with pytest.raises(PGRSTDuplicateError):
        db.table("waitlist").insert(
            [
                {"email": "a@example.com"},
                {"email": "a@example.com"},
            ]
        ).execute()


def test_upsert_with_on_conflict_replaces_existing_row():
    db = FakeDB()
    db.table("subscriptions").insert(
        {"user_id": "u1", "plan_type": "free", "status": "active"}
    ).execute()

    db.table("subscriptions").upsert(
        {"user_id": "u1", "plan_type": "pro_monthly", "status": "trial"},
        on_conflict="user_id",
    ).execute()

    rows = db.rows["subscriptions"]
    assert len(rows) == 1, "upsert must replace, not append"
    assert rows[0]["plan_type"] == "pro_monthly"


def test_upsert_appends_when_no_conflict():
    db = FakeDB()
    db.table("subscriptions").upsert(
        {"user_id": "u1", "plan_type": "free", "status": "active"},
        on_conflict="user_id",
    ).execute()
    db.table("subscriptions").upsert(
        {"user_id": "u2", "plan_type": "free", "status": "active"},
        on_conflict="user_id",
    ).execute()

    assert len(db.rows["subscriptions"]) == 2


def test_upsert_defaults_on_conflict_to_registry_key():
    db = FakeDB()
    db.table("subscriptions").upsert(
        {"user_id": "u1", "plan_type": "free", "status": "active"}
    ).execute()
    db.table("subscriptions").upsert(
        {"user_id": "u1", "plan_type": "pro_monthly", "status": "trial"}
    ).execute()

    rows = db.rows["subscriptions"]
    assert len(rows) == 1
    assert rows[0]["plan_type"] == "pro_monthly"


def test_upsert_replaces_on_compound_key():
    db = FakeDB()
    db.table("shared_outfits").upsert(
        {"outfit_id": "o1", "user_id": "u1", "caption": "old"},
        on_conflict="outfit_id,user_id",
    ).execute()
    db.table("shared_outfits").upsert(
        {"outfit_id": "o1", "user_id": "u1", "caption": "new"},
        on_conflict="outfit_id,user_id",
    ).execute()

    rows = db.rows["shared_outfits"]
    assert len(rows) == 1
    assert rows[0]["caption"] == "new"
