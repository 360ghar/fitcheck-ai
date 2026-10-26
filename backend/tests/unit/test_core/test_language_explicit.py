"""`language_explicit` write path and the migration's backfill predicate.

Migration 065 adds `user_settings.language_explicit BOOLEAN NOT NULL DEFAULT
FALSE` so the backend can tell a deliberate English choice from the column's
`DEFAULT 'en'`. This file pins the three wire cases the client can send, plus
the predicate the migration relies on to say "every existing row is a default".
"""

import re
from pathlib import Path

from app.api.v1.users import _derive_language_explicit
from app.models.user import UserSettingsUpdate

MIGRATION = (
    Path(__file__).resolve().parents[3]
    / "db"
    / "supabase"
    / "migrations"
    / "065_language_explicit.sql"
)


def _update(**payload) -> UserSettingsUpdate:
    return UserSettingsUpdate(**payload)


# ---------------------------------------------------------------------------
# The three wire cases
# ---------------------------------------------------------------------------


def test_picking_a_language_marks_it_explicit():
    """`language: "hi"` is a choice, so the flag follows automatically."""
    body = _update(language="hi")

    _derive_language_explicit(body)

    assert body.language == "hi"
    assert body.language_explicit is True


def test_picking_english_explicitly_is_still_a_choice():
    """The case the column exists for: English must be able to win."""
    body = _update(language="en")

    _derive_language_explicit(body)

    assert body.language == "en"
    assert body.language_explicit is True


def test_null_language_clears_the_flag_and_keeps_the_column_default():
    """`language: null` means "follow the device".

    The column must not become NULL (the response model types it `str` and the
    DB default is 'en'); the flag is what carries the meaning instead.
    """
    body = _update(language=None)

    _derive_language_explicit(body)

    assert body.language == "en"
    assert body.language_explicit is False


def test_omitting_language_leaves_the_stored_pair_alone():
    """No picker interaction -> no flag write, so an explicit choice survives."""
    body = _update(dark_mode=True)

    _derive_language_explicit(body)

    assert "language_explicit" not in body.model_fields_set
    assert body.language is None


def test_a_stated_flag_overrides_the_derivation():
    """A client that sends the flag itself is not second-guessed."""
    body = _update(language="en", language_explicit=False)

    _derive_language_explicit(body)

    assert body.language_explicit is False


def test_a_stated_flag_survives_a_clearing_language():
    body = _update(language=None, language_explicit=True)

    _derive_language_explicit(body)

    assert body.language == "en"
    assert body.language_explicit is True


def test_normalizes_are_not_applied_to_the_stored_tag():
    """The route stores what it was given; `effective_language` normalizes.

    Regression guard: normalizing here would silently turn an unsupported tag
    into 'en' WITH the explicit flag set, which would then beat a real device
    language. Leaving the raw value lets `normalize_language` treat it as
    unsupported and fall back to the header.
    """
    body = _update(language="tlh")

    _derive_language_explicit(body)

    assert body.language == "tlh"


# ---------------------------------------------------------------------------
# Settings response carries the flag
# ---------------------------------------------------------------------------


def test_settings_response_exposes_the_flag():
    """The client needs to read back what it set (GET /users/settings)."""
    from datetime import datetime, timezone
    from uuid import uuid4

    from app.models.user import UserSettings

    model = UserSettings(
        user_id=uuid4(),
        created_at=datetime.now(timezone.utc),
        updated_at=datetime.now(timezone.utc),
        language="en",
        language_explicit=True,
    )

    assert model.model_dump()["language_explicit"] is True


# ---------------------------------------------------------------------------
# Migration file
# ---------------------------------------------------------------------------


def test_migration_declares_the_column_not_null_with_the_expected_default():
    sql = MIGRATION.read_text(encoding="utf-8")

    assert re.search(
        r"ADD COLUMN IF NOT EXISTS language_explicit BOOLEAN NOT NULL DEFAULT FALSE",
        sql,
    ), "the flag must be NOT NULL DEFAULT FALSE, not nullable"


def test_migration_is_idempotent():
    sql = MIGRATION.read_text(encoding="utf-8")

    assert "ADD COLUMN IF NOT EXISTS" in sql
    # No top-level UPDATE: the repo's re-runnability contract forbids it, and
    # NOT NULL DEFAULT FALSE already backfills every existing row.
    assert "UPDATE public.user_settings\n   SET" not in sql


def test_backfill_predicate_matches_only_default_rows():
    """The migration's claim, checkable here.

    Every pre-065 row is a default because the only shipped writers of
    `user_settings.language` write the literal 'en' on profile creation:
    migrations 001/002/008 triggers, api/v1/auth.py (3 sites) and
    api/v1/deps.py. Nothing read the column, and the one client that writes a
    deliberate choice (flutter/lib/core/i18n/locale_controller.dart) is
    untracked, so it is in no shipped build.

    This test pins both halves of that claim: the writers are all literal
    defaults, and "backfill" is the column's DEFAULT, which Postgres applies to
    every existing row when a NOT NULL column is added.
    """
    repo = Path(__file__).resolve().parents[4]
    shipped_writers: list[str] = []
    for rel in ("backend/app/api/v1/auth.py", "backend/app/api/v1/deps.py"):
        text = (repo / rel).read_text(encoding="utf-8")
        for line_no, line in enumerate(text.splitlines(), start=1):
            if re.search(r'"language"\s*:', line):
                shipped_writers.append(f"{rel}:{line_no}: {line.strip()}")

    assert shipped_writers, "expected literal language writes in the shipped auth paths"
    for write in shipped_writers:
        assert '"language": "en"' in write, (
            f"a non-default language is written by shipped code, so the "
            f"backfill's 'every existing row is a default' claim is unsound: {write}"
        )

    # The backfill IS the column default; assert it exists and is FALSE.
    sql = MIGRATION.read_text(encoding="utf-8")
    assert re.search(r"NOT NULL DEFAULT FALSE", sql)


def test_migration_number_is_free():
    """065 must not collide with a parallel agent's migration."""
    siblings = sorted(p.name for p in MIGRATION.parent.glob("*.sql"))
    prefixes = [name[:3] for name in siblings]

    assert prefixes.count("065") == 1, f"duplicate 065 prefix in {siblings}"
    assert "065_language_explicit.sql" in siblings
