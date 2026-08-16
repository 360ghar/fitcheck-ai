"""Pins the "every migration is re-runnable" contract to the migration SQL.

Observed 2026-08-08: re-running migration 016 on a hosted DB that already had
`extraction_jobs` (from a prior partial application) aborted with
`ERROR: 42710: trigger "extraction_jobs_updated_at" for relation
"extraction_jobs" already exists` — the file had a plain `CREATE TRIGGER` /
`CREATE POLICY` with no drop guard, and the apply run died there, leaving
023/035 (and the photoshoot 503s) behind it.

Postgres has no `CREATE TRIGGER/POLICY IF NOT EXISTS` and no `ADD CONSTRAINT
IF NOT EXISTS`, so the repo contract (`docs/references/local-setup.md`) is:

- every `CREATE POLICY` / `CREATE TRIGGER` is preceded by a matching
  `DROP ... IF EXISTS ... ON <same table>` (drop-then-create);
- every `ADD CONSTRAINT` is preceded by `DROP CONSTRAINT IF EXISTS <name>`,
  or sits in a `DO` block guarded by `IF NOT EXISTS (... conname = '<name>' ...)`;
- every top-level seed `INSERT INTO` carries `ON CONFLICT`;
- every top-level `UPDATE <table> SET ...` / `DELETE FROM <table>` sits inside
  a `DO $$` block (guarded, so DML that references columns a later migration
  drops cannot 42703 a rerun — e.g. 014/015's `date_of_birth` backfill);
- `CREATE TABLE` / `CREATE INDEX` use `IF NOT EXISTS`;
- `CREATE FUNCTION` uses `CREATE OR REPLACE`.

A future migration that breaks the contract fails here instead of at the next
SQL-editor apply. Mirrors the static audit used for the 2026-08-08 pass (all
43 files applied twice in sequence on a scratch PostgreSQL 17 as the dynamic
check).
"""

import re
from pathlib import Path

import app

MIGRATIONS_DIR = Path(app.__file__).resolve().parents[1] / "db" / "supabase" / "migrations"


def _body_spans(sql: str) -> list:
    """Spans of $$...$$ bodies (function bodies and DO blocks)."""
    delims = [m.start() for m in re.finditer(r"\$\$", sql)]
    spans = []
    for i in range(0, len(delims) - 1, 2):
        spans.append((delims[i], delims[i + 1] + 2))
    return spans


def _is_inside(pos: int, spans: list) -> bool:
    return any(start <= pos < end for start, end in spans)


def _strip_comment_lines(sql: str) -> str:
    """Remove full-line `--` comments so they cannot false-positive the checks."""
    return "\n".join(
        line for line in sql.splitlines() if not line.lstrip().startswith("--")
    )


def _check_file(path: Path) -> list:
    """Return human-readable violations for one migration file."""
    sql = path.read_text(encoding="utf-8")
    top = _strip_comment_lines(sql)
    # Spans must come from the same text the matches are taken from:
    # stripping comment lines shifts offsets, so spans computed on `sql`
    # would misclassify statements that follow a comment.
    spans = _body_spans(top)
    violations = []

    def flag(msg: str, pos: int) -> None:
        violations.append(f"{path.name}:{sql[:pos].count(chr(10)) + 1}: {msg}")

    # CREATE POLICY "name" [AS ...] ON table  -> drop guard on the same table.
    for m in re.finditer(
        r"CREATE\s+POLICY\s+(?:\"([^\"]+)\"|(\w+))(?:(?!;).)*?\bON\s+([\w.]+)",
        top, re.I | re.S,
    ):
        if _is_inside(m.start(), spans):
            continue
        name, table = (m.group(1) or m.group(2)), m.group(3)
        before = top[: m.start()]
        pat = (r"DROP\s+POLICY\s+IF\s+EXISTS\s+(\"" + re.escape(name) + r"\"|"
               + re.escape(name) + r")\s+ON\s+" + re.escape(table))
        if not re.search(pat, before, re.I):
            flag(f'CREATE POLICY "{name}" ON {table} has no DROP POLICY IF EXISTS guard before it', m.start())

    # CREATE TRIGGER name ... [BEFORE|AFTER ...] ON table -> drop guard.
    for m in re.finditer(
        r"CREATE\s+TRIGGER\s+(\w+)(?:(?!;).)*?\bON\s+([\w.]+)",
        top, re.I | re.S,
    ):
        if _is_inside(m.start(), spans):
            continue
        name, table = m.group(1), m.group(2)
        before = top[: m.start()]
        pat = r"DROP\s+TRIGGER\s+IF\s+EXISTS\s+" + re.escape(name) + r"\s+ON\s+" + re.escape(table)
        if not re.search(pat, before, re.I):
            flag(f'CREATE TRIGGER "{name}" ON {table} has no DROP TRIGGER IF EXISTS guard before it', m.start())

    # ADD CONSTRAINT name -> DROP CONSTRAINT IF EXISTS, or a DO-block guard.
    for m in re.finditer(r"ADD\s+CONSTRAINT\s+(\w+)", top, re.I):
        name = m.group(1)
        if _is_inside(m.start(), spans):
            # Inside a DO block: require an IF NOT EXISTS pg_constraint guard
            # naming the constraint.
            body_start = max(start for start, _end in spans if start <= m.start())
            body_end = min(end for _start, end in spans if m.start() < end)
            body = top[body_start:body_end]
            if "IF NOT EXISTS" not in body or "conname" not in body or f"'{name}'" not in body:
                flag(f'ADD CONSTRAINT "{name}" in a DO block without a pg_constraint IF NOT EXISTS guard', m.start())
            continue
        before = top[: m.start()]
        if not re.search(r"DROP\s+CONSTRAINT\s+IF\s+EXISTS\s+" + re.escape(name), before, re.I):
            flag(f'ADD CONSTRAINT "{name}" has no DROP CONSTRAINT IF EXISTS guard before it', m.start())

    # Top-level seed INSERT INTO ... -> ON CONFLICT in the same statement.
    for m in re.finditer(r"INSERT\s+INTO\s+([\w.]+)", top, re.I):
        if _is_inside(m.start(), spans):
            continue
        stmt_end = top.find(";", m.start())
        stmt = top[m.start(): stmt_end if stmt_end != -1 else m.start() + 2000]
        if "ON CONFLICT" not in stmt:
            flag(f'top-level INSERT INTO {m.group(1)} has no ON CONFLICT guard', m.start())

    # Top-level UPDATE <table> SET ... / DELETE FROM <table> must live inside a
    # DO $$ block so a rerun cannot hit DML that references a column a later
    # migration drops (42703 — the 014/015 date_of_birth backfill bug class).
    # "UPDATE ... SET" pins the statement shape: "FOR UPDATE" (row lock) and
    # "ON CONFLICT DO UPDATE SET" (upsert) cannot match.
    for m in re.finditer(r"UPDATE\s+[\w.\"]+\s+SET\b", top, re.I | re.S):
        if not _is_inside(m.start(), spans):
            flag(f'top-level UPDATE {m.group(0)!r} is not inside a DO $$ block', m.start())
    for m in re.finditer(r"\bDELETE\s+FROM\b", top, re.I):
        if not _is_inside(m.start(), spans):
            flag("top-level DELETE FROM is not inside a DO $$ block", m.start())

    # CREATE TABLE / CREATE INDEX / CREATE FUNCTION guards.
    for m in re.finditer(r"CREATE\s+TABLE\s+(?!IF\s+NOT\s+EXISTS)", top, re.I):
        if not _is_inside(m.start(), spans):
            flag("CREATE TABLE without IF NOT EXISTS", m.start())
    for m in re.finditer(r"CREATE\s+(?:UNIQUE\s+)?INDEX\s+(?!IF\s+NOT\s+EXISTS)", top, re.I):
        if not _is_inside(m.start(), spans):
            flag("CREATE INDEX without IF NOT EXISTS", m.start())
    for m in re.finditer(r"CREATE\s+(?!OR\s+REPLACE\s+FUNCTION\b)FUNCTION\b", top, re.I):
        if not _is_inside(m.start(), spans):
            flag("CREATE FUNCTION without OR REPLACE", m.start())

    return violations


def test_all_migrations_are_rerunnable():
    migrations = sorted(MIGRATIONS_DIR.glob("*.sql"))
    assert migrations, "no migration files found"
    violations = []
    for path in migrations:
        violations.extend(_check_file(path))
    assert not violations, (
        "Migration re-runnability contract broken (see docs/references/"
        "local-setup.md):\n" + "\n".join(violations)
    )
