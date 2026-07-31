#!/usr/bin/env python3
"""Generate docs/generated/db-schema.md from Supabase SQL migrations.

Heuristic extractor: lists CREATE TABLE / ALTER TABLE statements and migration files.
Not a full SQL parser, good enough for agent orientation.

Limitations (kept visible on purpose): regex extraction can miss PostgreSQL-quoted
identifiers, schema-qualified names, materialized views, statements embedded in
PL/pgSQL or dollar-quoted bodies, and CREATE/ALTER TABLE calls hidden inside IF/ELSE
or multi-line conditional blocks. Treat the generated file as an orientation index;
confirm DDL in the source migrations or live Supabase before relying on it.
"""

from __future__ import annotations

import re
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = ROOT / "backend" / "db" / "supabase" / "migrations"
OUT = ROOT / "docs" / "generated" / "db-schema.md"

CREATE_TABLE_RE = re.compile(
    r"CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?([a-zA-Z0-9_\.\"]+)",
    re.IGNORECASE,
)
ALTER_TABLE_RE = re.compile(
    r"ALTER\s+TABLE\s+(?:IF\s+EXISTS\s+)?([a-zA-Z0-9_\.\"]+)",
    re.IGNORECASE,
)
# ALTER TABLE ... ADD COLUMN [IF NOT EXISTS] <name> <rest-of-statement-until-;>
# Captures the column definition so contract-critical additions (NOT NULL
# DEFAULT) can be flagged generically instead of per-migration.
ALTER_ADD_COLUMN_RE = re.compile(
    r"ALTER\s+TABLE\s+(?:IF\s+EXISTS\s+)?([a-zA-Z0-9_\.\"]+)\s+ADD\s+COLUMN\s+IF\s+NOT\s+EXISTS\s+([a-zA-Z0-9_\"]+)([^;]*)",
    re.IGNORECASE | re.DOTALL,
)


def clean_name(name: str) -> str:
    return name.replace('"', "").split(".")[-1]


def main() -> None:
    files = sorted(MIGRATIONS.glob("*.sql"))
    tables: dict[str, list[str]] = {}
    alters: list[tuple[str, str]] = []
    added_columns: list[tuple[str, str, str, str]] = []

    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        for m in CREATE_TABLE_RE.finditer(text):
            t = clean_name(m.group(1))
            tables.setdefault(t, []).append(path.name)
        for m in ALTER_TABLE_RE.finditer(text):
            alters.append((path.name, clean_name(m.group(1))))
        for m in ALTER_ADD_COLUMN_RE.finditer(text):
            added_columns.append(
                (path.name, clean_name(m.group(1)), m.group(2).replace('"', ""), m.group(3))
            )

    lines = [
        "# Database schema (generated)",
        "",
        f"Generated: {date.today().isoformat()}",
        "",
        "Source: `backend/db/supabase/migrations/`.",
        "Regenerate: `python scripts/generate_db_schema_doc.py`.",
        "",
        "## Limitations",
        "",
        "> This file is produced by regular-expression heuristics, not a real SQL parser.",
        "> Quoted identifiers, schema-qualified names, materialized views, statements inside",
        "> PL/pgSQL / dollar-quoted bodies, and CREATE/ALTER TABLE calls hidden behind IF/ELSE",
        "> or multi-line conditional blocks may be missed or misattributed. Treat this as an",
        "> orientation index for agents; confirm DDL in the migration files or live Supabase",
        "> before relying on it.",
        "",
        "This is an orientation index for agents, not a substitute for reading migrations or live Supabase.",
        "",
        "## Migration files",
        "",
    ]
    for path in files:
        lines.append(f"- `{path.name}`")
    lines.extend(["", "## Tables (CREATE TABLE)", ""])
    if not tables:
        lines.append("_No CREATE TABLE statements detected._")
    else:
        lines.append("| Table | Introduced in |")
        lines.append("|-------|---------------|")
        for t in sorted(tables):
            lines.append(f"| `{t}` | {', '.join(f'`{x}`' for x in tables[t])} |")

    # The extractor intentionally stays lightweight, but migrations that add a
    # contract-critical column (required, NOT NULL, with a DEFAULT) deserve an
    # explicit orientation note. Detected generically from the DDL so future
    # migrations are covered without a per-file special case.
    contract_columns = [
        (mig, table, column)
        for mig, table, column, definition in added_columns
        if "NOT NULL" in definition.upper() and "DEFAULT" in definition.upper()
    ]
    if contract_columns:
        lines.extend(["", "## Required columns added after table creation", ""])
        lines.append("| Migration | Table | Column |")
        lines.append("|-----------|-------|--------|")
        for mig, table, column in contract_columns:
            lines.append(f"| `{mig}` | `{table}` | `{column}` |")
        lines.extend(
            [
                "",
                "These columns are added after their table's CREATE TABLE and are "
                "required (NOT NULL DEFAULT), so inserts rely on the default until "
                "a value is supplied.",
            ]
        )

    lines.extend(["", "## ALTER TABLE references", ""])
    if not alters:
        lines.append("_None detected._")
    else:
        for mig, table in alters[:200]:
            lines.append(f"- `{mig}` → `{table}`")
        if len(alters) > 200:
            lines.append(f"- … and {len(alters) - 200} more")

    lines.extend(
        [
            "",
            "## Related",
            "",
            "- `docs/references/data-models.md`",
            "- `docs/BACKEND.md`",
            "",
        ]
    )

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
