#!/usr/bin/env python3
"""Validate knowledge-base structure, relative markdown links, and freshness.

Fails when required harness files are missing, CLAUDE.md does not import
AGENTS.md, internal .md links break, or docs carrying a 'Last updated'
header are stale relative to their last git commit.
"""

from __future__ import annotations

import re
import subprocess
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"

REQUIRED = [
    ROOT / "AGENTS.md",
    ROOT / "CLAUDE.md",
    ROOT / "ARCHITECTURE.md",
    DOCS / "README.md",
    DOCS / "BACKEND.md",
    DOCS / "FRONTEND.md",
    DOCS / "FLUTTER.md",
    DOCS / "DESIGN.md",
    DOCS / "PLANS.md",
    DOCS / "PRODUCT_SENSE.md",
    DOCS / "QUALITY_SCORE.md",
    DOCS / "RELIABILITY.md",
    DOCS / "SECURITY.md",
    DOCS / "design-docs" / "index.md",
    DOCS / "design-docs" / "core-beliefs.md",
    DOCS / "exec-plans" / "README.md",
    DOCS / "exec-plans" / "tech-debt-tracker.md",
    DOCS / "exec-plans" / "active" / "_TEMPLATE.md",
    DOCS / "product-specs" / "index.md",
    DOCS / "product-specs" / "overview.md",
    DOCS / "product-specs" / "implementation-status.md",
    DOCS / "store" / "app-store-listing.md",
    DOCS / "store" / "app-store-screenshots.md",
    DOCS / "store" / "play-store-aso.md",
    DOCS / "generated" / "db-schema.md",
    DOCS / "references" / "local-setup.md",
]

LINK_RE = re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
# Backtick-wrapped docs paths, e.g. `docs/BACKEND.md` or `docs/product-specs/overview.md`
DOCS_BACKTICK_RE = re.compile(r"`(docs/[^`\s]+)`")
# Optional comment/string mentions of docs/ paths outside markdown
DOCS_STRING_RE = re.compile(r"""(?:docs/[A-Za-z0-9_./-]+\.(?:md|txt|sql|py|sh|json|ya?ml))""")

errors: list[str] = []


def check_required() -> None:
    for path in REQUIRED:
        if not path.is_file():
            errors.append(f"missing required file: {path.relative_to(ROOT)}")


def check_claude_imports_agents() -> None:
    """CLAUDE.md must exist and import AGENTS.md via a single '@AGENTS.md' line."""
    claude = ROOT / "CLAUDE.md"
    if not claude.is_file():
        errors.append(
            "CLAUDE.md is missing; it must exist and start with '@AGENTS.md' to "
            "import the shared agent map. "
            "REMEDIATE: restore CLAUDE.md as a single '@AGENTS.md' import line."
        )
        return
    first_non_empty = next(
        (
            line
            for line in claude.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ),
        None,
    )
    if first_non_empty != "@AGENTS.md":
        errors.append(
            f"CLAUDE.md first non-empty line is {first_non_empty!r}, "
            "expected '@AGENTS.md'. "
            "REMEDIATE: CLAUDE.md must start with '@AGENTS.md' to import the "
            "shared agent map."
        )
    # AGENTS.md existence is enforced by check_required()


def check_schema_doc_freshness() -> None:
    """Fail if any SQL migration is newer than the generated schema doc."""
    schema_doc = DOCS / "generated" / "db-schema.md"
    migrations = ROOT / "backend" / "db" / "supabase" / "migrations"
    if not schema_doc.is_file() or not migrations.is_dir():
        return
    schema_mtime = schema_doc.stat().st_mtime
    newer = [
        p.name
        for p in migrations.glob("*.sql")
        if p.stat().st_mtime > schema_mtime + 1.0
    ]
    if newer:
        errors.append(
            "docs/generated/db-schema.md is older than migration(s): "
            + ", ".join(sorted(newer))
            + ". REMEDIATE: run `python scripts/generate_db_schema_doc.py`."
        )


LAST_UPDATED_RE = re.compile(r"Last updated:\s*(\d{4}-\d{2}-\d{2})")
FRESHNESS_GRACE_DAYS = 3


def _last_commit_date(path: Path) -> date | None:
    """Return the last commit date (date-only) for a repo file, or None if unknown."""
    rel = path.relative_to(ROOT).as_posix()
    try:
        proc = subprocess.run(
            ["git", "log", "-1", "--format=%cI", "--", rel],
            cwd=ROOT,
            capture_output=True,
            text=True,
            timeout=15,
        )
    except (OSError, subprocess.SubprocessError):
        return None
    if proc.returncode != 0:
        return None
    stamp = proc.stdout.strip()
    if not stamp:
        return None
    try:
        return datetime.fromisoformat(stamp).date()
    except ValueError:
        return None


def check_last_updated_freshness() -> None:
    """Fail when a doc's 'Last updated' header predates its last commit by >3 days.

    Files without a 'Last updated' header, untracked files, and repos where git
    is unavailable are skipped. Uncommitted working-tree edits are intentionally
    measured against the last COMMIT date (the intended behavior: a doc edited
    today but committed months ago passes as long as its header is newer than
    the commit date).
    """
    for path in sorted(DOCS.rglob("*.md")):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        match = LAST_UPDATED_RE.search(text)
        if not match:
            continue
        try:
            header_date = datetime.strptime(match.group(1), "%Y-%m-%d").date()
        except ValueError:
            continue
        commit_date = _last_commit_date(path)
        if commit_date is None:
            continue
        if header_date < commit_date - timedelta(days=FRESHNESS_GRACE_DAYS):
            errors.append(
                f"{path.relative_to(ROOT)}: 'Last updated' header ({header_date}) "
                f"is stale (file last changed {commit_date}). "
                f"REMEDIATE: bump the Last updated header (or check the last commit) "
                f"— file was last changed on {commit_date}."
            )


def check_markdown_links() -> None:
    md_files = [ROOT / "AGENTS.md", ROOT / "CLAUDE.md", ROOT / "ARCHITECTURE.md"]
    md_files.extend(DOCS.rglob("*.md"))
    for path in md_files:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for match in LINK_RE.finditer(text):
            target = match.group(2).strip()
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            # strip anchors
            file_part = target.split("#", 1)[0]
            if not file_part:
                continue
            if file_part.startswith("`") or " " in file_part and not file_part.endswith(".md"):
                continue
            resolved = (path.parent / file_part).resolve()
            try:
                resolved.relative_to(ROOT.resolve())
            except ValueError:
                # outside repo — skip
                continue
            if not resolved.exists():
                errors.append(
                    f"{path.relative_to(ROOT)}: broken link '{target}'. "
                    f"REMEDIATE: fix path or create the target file."
                )


def _is_skippable_docs_ref(ref: str) -> bool:
    """Skip URLs, anchors-only, and non-path noise."""
    if ref.startswith(("http://", "https://", "mailto:")):
        return True
    if "://" in ref:
        return True
    return False


def _normalize_docs_ref(ref: str) -> str | None:
    """Return a clean repo-relative docs path, or None if not a file path."""
    ref = ref.strip().rstrip(".,;:)")
    if not ref or _is_skippable_docs_ref(ref):
        return None
    # strip anchors / query
    file_part = ref.split("#", 1)[0].split("?", 1)[0]
    if not file_part.startswith("docs/"):
        return None
    # Directories as path prefixes (e.g. docs/exec-plans/) are allowed as refs
    # only when they look like files with an extension, or explicit tree leaves.
    # Keep directory-like refs that end with / out of existence checks as files.
    if file_part.endswith("/"):
        return None
    # Template / placeholder paths (e.g. docs/exec-plans/active/<name>.md)
    if any(ch in file_part for ch in ("<", ">", "*", "?")):
        return None
    return file_part


def _scan_text_for_docs_paths(path: Path, text: str, use_backtick_only: bool) -> None:
    seen: set[str] = set()
    if use_backtick_only:
        candidates = DOCS_BACKTICK_RE.findall(text)
    else:
        # Comments / strings: loose docs/...path matches
        candidates = DOCS_STRING_RE.findall(text)
        # Also catch backtick-wrapped if present
        candidates = list(candidates) + DOCS_BACKTICK_RE.findall(text)

    for raw in candidates:
        norm = _normalize_docs_ref(raw)
        if not norm or norm in seen:
            continue
        seen.add(norm)
        target = ROOT / norm
        if not target.exists():
            errors.append(
                f"{path.relative_to(ROOT)}: referenced path `{norm}` does not exist. "
                f"REMEDIATE: fix the path string or create the missing docs file."
            )


def check_docs_path_references() -> None:
    """Verify backtick-wrapped `docs/...` paths (and optional script mentions) exist."""
    # Primary markdown / agent map sources — backtick-wrapped docs paths
    md_scan: list[Path] = [
        ROOT / "AGENTS.md",
        ROOT / "CLAUDE.md",
        ROOT / "ARCHITECTURE.md",
        ROOT / "README.md",
        ROOT / "backend" / "CLAUDE.md",
        ROOT / "frontend" / "CLAUDE.md",
    ]
    if DOCS.is_dir():
        md_scan.extend(DOCS.rglob("*.md"))
    metadata = ROOT / "flutter" / "metadata"
    if metadata.is_dir():
        md_scan.extend(metadata.rglob("*.md"))

    for path in md_scan:
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        _scan_text_for_docs_paths(path, text, use_backtick_only=True)

    # Optional: backend/scripts/*.py and flutter/scripts/*.sh comments/strings
    optional_dirs = [
        (ROOT / "backend" / "scripts", "*.py"),
        (ROOT / "flutter" / "scripts", "*.sh"),
    ]
    for directory, pattern in optional_dirs:
        if not directory.is_dir():
            continue
        for path in directory.rglob(pattern):
            if not path.is_file():
                continue
            text = path.read_text(encoding="utf-8", errors="replace")
            _scan_text_for_docs_paths(path, text, use_backtick_only=False)


def main() -> int:
    check_required()
    check_claude_imports_agents()
    check_schema_doc_freshness()
    check_last_updated_freshness()
    check_markdown_links()
    check_docs_path_references()
    if errors:
        print(f"Docs structure check failed ({len(errors)} issue(s)):\n", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        return 1
    print("Docs structure check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
