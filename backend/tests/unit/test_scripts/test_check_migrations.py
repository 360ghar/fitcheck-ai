"""Tests for the static migration checker (scripts/check_migrations.py).

``check_migrations.py`` lives at the repo root (``scripts/``, not
``backend/scripts/``), so it is loaded by path the same way the other
script tests resolve their targets. The functions under test are pure: they
neither touch the filesystem nor the network. The ``_policy_to_roles``
parser is the regression surface for the end-of-statement role-list bug
(a ``CREATE POLICY ... FOR ALL TO public;`` whose TO clause ends the body
must still be detected, not silently skipped).

The real ``check_migrations()`` pass is also exercised end-to-end against
the live migrations directory so a regex change that breaks it fails here
too.
"""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

import app

import pytest

REPO_ROOT = Path(app.__file__).resolve().parents[2]
SCRIPT_PATH = REPO_ROOT / "scripts" / "check_migrations.py"


@pytest.fixture(scope="module")
def checker():
    """Load check_migrations.py by path and return the module object."""
    if str(REPO_ROOT) not in sys.path:
        sys.path.insert(0, str(REPO_ROOT))
    spec = importlib.util.spec_from_file_location("check_migrations", SCRIPT_PATH)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    spec.loader.exec_module(module)
    return module


class TestPolicyToRoles:
    """The role-list parser must terminate at end-of-body without requiring a
    trailing whitespace + keyword. The body is captured by POLICY_RE which
    strips the closing ``;``, so ``... FOR ALL TO public`` (no trailing gap)
    is a real, common shape."""

    def test_end_of_body_public_role_list(self, checker):
        # The bug case: the TO clause ends the body with no trailing
        # whitespace/USING/WITH/FOR. roles must be ['public'], not None.
        assert checker._policy_to_roles(" ON t FOR ALL TO public") == ["public"]

    def test_end_of_body_service_role(self, checker):
        assert checker._policy_to_roles(" ON t FOR ALL TO service_role") == ["service_role"]

    def test_to_service_role_using(self, checker):
        assert checker._policy_to_roles(" TO service_role USING (TRUE)") == ["service_role"]

    def test_to_public_with_check(self, checker):
        assert checker._policy_to_roles(" TO public WITH CHECK (TRUE)") == ["public"]

    def test_to_authenticated_for_select(self, checker):
        assert checker._policy_to_roles(" TO authenticated FOR SELECT") == ["authenticated"]

    def test_multi_role_list(self, checker):
        assert checker._policy_to_roles(
            " TO service_role, anon USING (TRUE)"
        ) == ["service_role", "anon"]

    def test_to_role_keyword_prefix(self, checker):
        assert checker._policy_to_roles(
            " TO ROLE service_role USING (TRUE)"
        ) == ["service_role"]

    def test_no_to_clause_returns_none(self, checker):
        assert checker._policy_to_roles(" ON t FOR ALL USING (TRUE)") is None


class TestCommentStripping:
    """A trailing ``-- comment`` mentioning a role must not be parsed as a real
    TO grant (the regex runs over the raw body otherwise). Block comments
    (``/* ... */``) must be stripped too, so a role name inside a block comment
    is not misread as a grant."""

    def test_trailing_comment_with_role_word_is_ignored(self, checker):
        body = " FOR ALL USING (TRUE) -- scoped to public"
        stripped = checker._strip_sql_comments(body)
        assert "public" not in stripped
        assert checker._policy_to_roles(stripped) is None

    def test_comment_after_real_to_clause_preserves_roles(self, checker):
        body = " TO service_role USING (TRUE) -- note"
        stripped = checker._strip_sql_comments(body)
        assert checker._policy_to_roles(stripped) == ["service_role"]

    def test_block_comment_with_role_word_is_ignored(self, checker):
        # A /* ... */ comment inside a policy body must not leak its content
        # into the role-list parse: the parser would otherwise read the
        # ``TO public`` inside the comment as a real grant and falsely flag a
        # safe FOR ALL policy.
        body = " FOR ALL /* TO public */ USING (TRUE)"
        stripped = checker._strip_sql_comments(body)
        assert "public" not in stripped
        assert checker._policy_to_roles(stripped) is None

    def test_block_comment_multi_line_is_stripped(self, checker):
        body = " FOR ALL\n  /* scoped\n     TO public */ USING (TRUE)"
        stripped = checker._strip_sql_comments(body)
        assert "public" not in stripped
        assert checker._policy_to_roles(stripped) is None

    def test_real_to_clause_survives_block_comment_stripping(self, checker):
        body = " /* preamble */ TO service_role USING (TRUE) /* tail */"
        stripped = checker._strip_sql_comments(body)
        assert checker._policy_to_roles(stripped) == ["service_role"]


class TestEndOfBodyPublicIsFlagged:
    """A synthetic policy body that grants FOR ALL TO public at end-of-body
    must be detected as a violation by the full ``check_migrations`` run
    (not silently skipped because roles parsed as None). We synthesize a
    migration file in a tmp dir and point the checker at it."""

    def test_for_all_to_public_at_end_of_body_is_rejected(self, checker, tmp_path, monkeypatch):
        migrations = tmp_path / "migrations"
        migrations.mkdir()
        (migrations / "900_for_all_to_public.sql").write_text(
            'CREATE POLICY "bad" ON public.t FOR ALL TO public;\n',
            encoding="utf-8",
        )
        monkeypatch.setattr(checker, "MIGRATIONS_DIR", migrations)
        rc = checker.check_migrations()
        assert rc == 1, "FOR ALL TO public must be rejected even at end-of-body"

    def test_for_all_to_service_role_at_end_of_body_passes(self, checker, tmp_path, monkeypatch):
        migrations = tmp_path / "migrations"
        migrations.mkdir()
        (migrations / "901_for_all_to_service_role.sql").write_text(
            'CREATE POLICY "Service role manages t" ON public.t FOR ALL TO service_role;\n',
            encoding="utf-8",
        )
        monkeypatch.setattr(checker, "MIGRATIONS_DIR", migrations)
        rc = checker.check_migrations()
        assert rc == 0, "FOR ALL TO service_role at end-of-body must pass"


class TestRealMigrationsPass:
    """The checker must still pass on the real migrations directory after the
    regex change (no false positives on legitimate policies)."""

    def test_real_migrations_pass(self, checker):
        rc = checker.check_migrations()
        assert rc == 0, "check_migrations must pass on the real migrations dir"
