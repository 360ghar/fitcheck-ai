#!/usr/bin/env python3
"""
Verify the 2026-08-29 spicy blog batch landed in `blog_posts`.

Loads SUPABASE_URL and SUPABASE_SECRET_KEY from `backend/.env` and queries
the Supabase REST API via the `supabase` Python SDK. Use after running
`scripts/blog_batch_2026_08_29/publish.py --commit`.

Usage (from repo root):
    python scripts/blog_batch_2026_08_29/verify.py                       # default: count + schema + 3 samples
    python scripts/blog_batch_2026_08_29/verify.py --count              # print count of posts dated 2026-08-29
    python scripts/blog_batch_2026_08_29/verify.py --sample 5           # print 5 titles + slugs + first 100 chars of excerpt
    python scripts/blog_batch_2026_08_29/verify.py --check-schema       # verify required fields are populated on every post
    python scripts/blog_batch_2026_08_29/verify.py --slugs              # print all 52 slugs as a list

Exit codes:
    0  success
    1  schema error (one or more posts missing required fields)
    2  no posts found for the batch date
    3  config / connection error (missing env, bad URL, network)
"""
from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path
from typing import Any

# --------------------------------------------------------------------------- #
# paths
# --------------------------------------------------------------------------- #
REPO_ROOT = Path(__file__).resolve().parents[2]
BACKEND_ENV = REPO_ROOT / "backend" / ".env"

BATCH_DATE = "2026-08-29"
EXPECTED_TOTAL = 52

# Required (NOT NULL) columns per migration 017_blog_posts.sql
REQUIRED_FIELDS = (
    "slug",
    "title",
    "excerpt",
    "content",
    "category",
    "date",
    "read_time",
    "emoji",
    "author",
)


# --------------------------------------------------------------------------- #
# env loading
# --------------------------------------------------------------------------- #
def _load_env_file(path: Path) -> None:
    """Minimal KEY=VALUE .env loader; does not override existing env."""
    if not path.is_file():
        return
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        os.environ.setdefault(key, value)


def _require_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        print(f"ERROR: {name} is not set (load it into env or add to {BACKEND_ENV})", file=sys.stderr)
        sys.exit(3)
    return value


def _connect():
    """Create a Supabase client; exits 3 on failure."""
    _load_env_file(BACKEND_ENV)
    try:
        from supabase import create_client  # local import so --help works without the dep
    except ImportError:
        print("ERROR: the 'supabase' python package is not installed. Try: pip install supabase", file=sys.stderr)
        sys.exit(3)

    url = _require_env("SUPABASE_URL")
    key = _require_env("SUPABASE_SECRET_KEY")
    try:
        return create_client(url, key)
    except Exception as exc:  # noqa: BLE001 - surface any client init error verbatim
        print(f"ERROR: failed to construct Supabase client: {exc}", file=sys.stderr)
        sys.exit(3)


# --------------------------------------------------------------------------- #
# fetch
# --------------------------------------------------------------------------- #
def _fetch_batch(client) -> list[dict[str, Any]]:
    """Fetch every blog_posts row dated 2026-08-29 (no pagination tricks; 52 rows)."""
    try:
        resp = (
            client.table("blog_posts")
            .select("*")
            .eq("date", BATCH_DATE)
            .execute()
        )
    except Exception as exc:  # noqa: BLE001
        print(f"ERROR: query failed: {exc}", file=sys.stderr)
        sys.exit(3)
    return list(resp.data or [])


# --------------------------------------------------------------------------- #
# commands
# --------------------------------------------------------------------------- #
def cmd_count(client, posts: list[dict[str, Any]]) -> int:
    n = len(posts)
    suffix = " (matches expected)" if n == EXPECTED_TOTAL else f" (expected {EXPECTED_TOTAL})"
    print(f"{n}{suffix}")
    return 0 if n > 0 else 2


def cmd_sample(client, posts: list[dict[str, Any]], n: int) -> int:
    if not posts:
        print("(no posts to sample)")
        return 2
    take = min(n, len(posts))
    for i, row in enumerate(posts[:take], start=1):
        title = (row.get("title") or "").strip()
        slug = (row.get("slug") or "").strip()
        excerpt = (row.get("excerpt") or "").strip()
        excerpt_short = excerpt[:100] + ("..." if len(excerpt) > 100 else "")
        print(f"{i:>2}. {title}")
        print(f"    slug: {slug}")
        print(f"    excerpt: {excerpt_short}")
    return 0


def cmd_check_schema(client, posts: list[dict[str, Any]]) -> int:
    if not posts:
        print("(no posts to check)")
        return 2
    errors: list[str] = []
    for idx, row in enumerate(posts, start=1):
        for field in REQUIRED_FIELDS:
            value = row.get(field)
            # Treat empty strings as missing too (Supabase TEXT NOT NULL accepts "")
            if value is None or (isinstance(value, str) and not value.strip()):
                errors.append(f"row {idx} (slug={row.get('slug')!r}) missing {field!r}")
    if errors:
        print(f"SCHEMA ERRORS ({len(errors)}):", file=sys.stderr)
        for err in errors:
            print(f"  - {err}", file=sys.stderr)
        return 1
    print(f"OK: all {len(posts)} posts have required fields populated")
    return 0


def cmd_slugs(client, posts: list[dict[str, Any]]) -> int:
    if not posts:
        print("(no posts)")
        return 2
    for row in sorted(posts, key=lambda r: r.get("slug") or ""):
        print(row.get("slug", ""))
    return 0


# --------------------------------------------------------------------------- #
# CLI
# --------------------------------------------------------------------------- #
def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Verify the 2026-08-29 spicy blog batch.")
    parser.add_argument("--count", action="store_true", help="print count of posts dated 2026-08-29")
    parser.add_argument("--sample", type=int, metavar="N", help="print N post titles + slugs + first 100 chars of excerpt")
    parser.add_argument("--check-schema", action="store_true", help="verify all posts have required fields")
    parser.add_argument("--slugs", action="store_true", help="print all slugs as a list")
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    # Default behaviour: --count --check-schema --sample 3
    if not (args.count or args.sample is not None or args.check_schema or args.slugs):
        args.count = True
        args.check_schema = True
        args.sample = 3

    client = _connect()
    posts = _fetch_batch(client)

    highest = 0
    if args.count:
        highest = max(highest, cmd_count(client, posts))
    if args.sample is not None:
        highest = max(highest, cmd_sample(client, posts, args.sample))
    if args.check_schema:
        highest = max(highest, cmd_check_schema(client, posts))
    if args.slugs:
        highest = max(highest, cmd_slugs(client, posts))

    return highest


if __name__ == "__main__":
    sys.exit(main())
