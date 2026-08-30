"""
Rollback the 2026-08-29 spicy blog batch. Deletes the 52 posts dated
2026-08-29 from the blog_posts table. Idempotent.

Usage:
  python scripts/blog_batch_2026_08_29/rollback.py --dry-run
  python scripts/blog_batch_2026_08_29/rollback.py --commit
"""

from __future__ import annotations

import argparse
import os
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
BACKEND_ENV = REPO_ROOT / "backend" / ".env"

BATCH_DATE = "2026-08-29"


def _load_env_file(path: Path) -> None:
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))


def _require_env(name: str) -> str:
    v = os.environ.get(name, "").strip()
    if not v:
        sys.exit(f"ERROR: {name} not set in {BACKEND_ENV}")
    return v


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--commit", action="store_true")
    args = parser.parse_args()
    if not (args.dry_run or args.commit):
        print("Pass --dry-run or --commit", file=sys.stderr)
        return 2

    _load_env_file(BACKEND_ENV)
    from supabase import create_client
    sys.path.insert(0, str(Path(__file__).parent))
    from publish import _build_posts  # noqa: E402

    posts = _build_posts()
    slugs = [p["slug"] for p in posts]
    print(f"Posts in publish.py to remove: {len(slugs)}")

    if args.dry_run:
        for s in slugs:
            print(f"  {s}")
        return 0

    client = create_client(_require_env("SUPABASE_URL"), _require_env("SUPABASE_SECRET_KEY"))

    # Confirm what we'd be deleting: query by date + count
    pre = client.table("blog_posts").select("slug").eq("date", BATCH_DATE).execute()
    pre_slugs = {r["slug"] for r in (pre.data or [])}
    matches = [s for s in slugs if s in pre_slugs]
    print(f"Matching rows in DB for date {BATCH_DATE}: {len(matches)}")
    print(f"DB slugs not in current script: {pre_slugs - set(slugs)}")

    deleted = 0
    for slug in matches:
        try:
            res = client.table("blog_posts").delete().eq("slug", slug).eq("date", BATCH_DATE).execute()
            n = len(res.data or [])
            if n:
                print(f"  ✓ {slug}  (deleted {n})")
                deleted += n
        except Exception as exc:
            print(f"  ✗ {slug}: {exc}")

    print(f"\nDeleted: {deleted}")
    # Post-check
    post = client.table("blog_posts").select("slug").eq("date", BATCH_DATE).execute()
    remaining = len(post.data or [])
    print(f"Rows remaining for date {BATCH_DATE}: {remaining}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
