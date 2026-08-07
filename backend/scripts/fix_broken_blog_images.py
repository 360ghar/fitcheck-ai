#!/usr/bin/env python3
"""
Fix blog posts whose Unsplash featured images 404 (photos removed from Unsplash).

Found during the 2026-08-07 /blog PageSpeed RCA (PSI console error:
`Failed to load resource ... 404` from images.unsplash.com). Six photo IDs in
blog_posts.featured_image_url now return 404, affecting 17 published posts.
Each broken photo ID is remapped to a replacement photo verified live
(HTTP 200) from the same subject area.

Broken -> replacement mapping (all replacements HEAD-verified 2026-08-07):

    photo-1529139574466-a302c27560a0  -> photo-1567401893414-76b7b1e5a7a5  (man in suit / smart style)
    photo-1551488852-080175b9aa45    -> photo-1539109136881-3be0616acf4b  (street-style trench)
    photo-1485230946086-1d99dedfcf3e -> photo-1515562141207-7a88fb7ce338  (jewelry / rings)
    photo-1520975661595-64536ef8ad7e -> photo-1531366936337-7c912a4589a7  (hat)
    photo-1507680434567-5739c8fbe69d -> photo-1524592094714-0f0654e20314  (wristwatch)
    photo-1550614000-4b9519e09d43    -> photo-1511499767150-a48a237f0083  (sunglasses)

Only the photo ID in the URL is swapped; query params (?w=800&q=80) are kept.

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key

    DRY_RUN=1 python scripts/fix_broken_blog_images.py   # preview (writes nothing)
    DRY_RUN=0 python scripts/fix_broken_blog_images.py   # apply

Idempotent: after a successful run no rows match the broken IDs, so re-running
prints "no matches" and exits 0.
"""
from __future__ import annotations

import os
import sys

import httpx

# Broken photo ID -> replacement photo ID (the part after `photo-`).
BROKEN_TO_REPLACEMENT = {
    "1529139574466-a302c27560a0": "1567401893414-76b7b1e5a7a5",
    "1551488852-080175b9aa45": "1539109136881-3be0616acf4b",
    "1485230946086-1d99dedfcf3e": "1515562141207-7a88fb7ce338",
    "1520975661595-64536ef8ad7e": "1531366936337-7c912a4589a7",
    "1507680434567-5739c8fbe69d": "1524592094714-0f0654e20314",
    "1550614000-4b9519e09d43": "1511499767150-a48a237f0083",
}


def _get_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}", file=sys.stderr)
        raise SystemExit(2)
    return value


def _auth_headers(key: str) -> dict:
    return {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }


def main() -> int:
    dry_run = os.environ.get("DRY_RUN", "1") != "0"
    base_url = _get_env("SUPABASE_URL").rstrip("/")
    key = _get_env("SUPABASE_SECRET_KEY")

    print(f"DRY_RUN:           {dry_run}")

    rows: list[dict] = []
    with httpx.Client(timeout=30) as client:
        # Every row, not just published ones: a draft with a broken image would
        # surface the 404 the moment it is published.
        # PostgREST caps a single response at 1000 rows by default, so page
        # with limit/offset until a page returns fewer than `limit` rows.
        limit = 1000
        offset = 0
        while True:
            response = client.get(
                f"{base_url}/rest/v1/blog_posts",
                params={
                    "select": "id,slug,featured_image_url",
                    "limit": limit,
                    "offset": offset,
                },
                headers=_auth_headers(key),
            )
            response.raise_for_status()
            page_rows = response.json()
            rows.extend(page_rows)
            if len(page_rows) < limit:
                break
            offset += limit

    matches = []
    for row in rows:
        url = row.get("featured_image_url") or ""
        for broken, replacement in BROKEN_TO_REPLACEMENT.items():
            if f"photo-{broken}" in url:
                new_url = url.replace(f"photo-{broken}", f"photo-{replacement}")
                matches.append(
                    {"id": row["id"], "slug": row["slug"], "old": url, "new": new_url}
                )
                break

    if not matches:
        print("No rows reference a broken photo ID — nothing to do.")
        return 0

    print(f"Found {len(matches)} row(s) with a broken featured image:")
    for m in matches:
        print(f"  {m['id']} {m['slug']}")
        print(f"    old: {m['old']}")
        print(f"    new: {m['new']}")

    if dry_run:
        print("\nDRY RUN - no rows updated. Re-run with DRY_RUN=0 to apply.")
        return 0

    with httpx.Client(timeout=30) as client:
        for m in matches:
            patch = client.patch(
                f"{base_url}/rest/v1/blog_posts",
                params={"id": f"eq.{m['id']}"},
                headers={**_auth_headers(key), "Prefer": "return=minimal"},
                json={"featured_image_url": m["new"]},
            )
            patch.raise_for_status()
            print(f"  updated {m['id']} {m['slug']}")

    print(f"\nUpdated {len(matches)} row(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
