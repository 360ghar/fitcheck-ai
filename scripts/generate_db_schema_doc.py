#!/usr/bin/env python3
"""Generate docs/generated/db-schema.md from Supabase SQL migrations.

Heuristic extractor: lists CREATE TABLE / ALTER TABLE statements and migration files.
Not a full SQL parser—good enough for agent orientation.
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


def clean_name(name: str) -> str:
    return name.replace('"', "").split(".")[-1]


def main() -> None:
    files = sorted(MIGRATIONS.glob("*.sql"))
    tables: dict[str, list[str]] = {}
    alters: list[tuple[str, str]] = []

    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        for m in CREATE_TABLE_RE.finditer(text):
            t = clean_name(m.group(1))
            tables.setdefault(t, []).append(path.name)
        for m in ALTER_TABLE_RE.finditer(text):
            alters.append((path.name, clean_name(m.group(1))))

    lines = [
        "# Database schema (generated)",
        "",
        f"Generated: {date.today().isoformat()}",
        "",
        "Source: `backend/db/supabase/migrations/`.",
        "Regenerate: `python scripts/generate_db_schema_doc.py`.",
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
