#!/usr/bin/env python3
"""Scan the live blog API for broken featured images.

QA/verification helper: fetches every published blog post from the production
API and HEAD-checks each featured_image_url. Used to verify the 2026-08-07
broken-image fix and to catch future removals (Unsplash photos disappear over
time). Exits non-zero when any reachable image URL fails.

Usage: python scripts/scan_live_blog_images.py
"""

import concurrent.futures as cf
import json
import sys
import urllib.parse
import urllib.request

API = "https://api.fitcheckaiapp.com/api/v1/blog/posts"
PAGE_SIZE = 50

# featured_image_url is admin-controlled free-form TEXT in the DB, so the
# script must never open arbitrary URLs: only HTTPS to images.unsplash.com is
# allowed, which prevents SSRF against internal endpoints (localhost, cloud
# metadata services, etc.).
ALLOWED_IMAGE_HOST = "images.unsplash.com"


class _NoRedirect(urllib.request.HTTPRedirectHandler):
    """Never follow redirects: verify the exact stored URL, not wherever it
    points."""

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def fetch_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=15) as res:
        return json.load(res)


def head_ok(url: str) -> bool:
    try:
        parsed = urllib.parse.urlsplit(url)
        if parsed.scheme != "https" or parsed.hostname != ALLOWED_IMAGE_HOST:
            return False
        if parsed.port not in (None, 443):
            return False
        req = urllib.request.Request(url, method="HEAD")
        opener = urllib.request.build_opener(_NoRedirect())
        with opener.open(req, timeout=15) as res:
            return res.status == 200
    except (ValueError, OSError):
        # ValueError: malformed URL/port; OSError covers URLError + HTTPError.
        # Any other exception would be a bug worth surfacing, not a "broken
        # image", so the catch is intentionally narrow.
        return False


def check_one(post: dict) -> tuple:
    """Return (slug, url, ok). Posts without a featured image are fine by
    design — the frontend shows the emoji fallback."""
    url = post.get("featured_image_url")
    if not url:
        return post["slug"], None, True
    return post["slug"], url, head_ok(url)


def main() -> int:
    broken: list[tuple] = []
    ok_count = 0
    with_images = 0
    page = 1
    while True:
        body = fetch_json(f"{API}?page={page}&page_size={PAGE_SIZE}")
        posts = (body or {}).get("data", {}).get("posts", [])
        if not posts:
            break
        with cf.ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(check_one, posts))
        for slug, url, ok in results:
            if not url:
                continue
            with_images += 1
            if ok:
                ok_count += 1
            else:
                broken.append((slug, url))
        if not (body or {}).get("data", {}).get("has_next"):
            break
        page += 1

    print(f"checked {ok_count} of {with_images} featured images")
    if broken:
        for slug, url in broken:
            print(f"BROKEN {slug}: {url}")
        return 1
    print("0 broken images")
    return 0


if __name__ == "__main__":
    sys.exit(main())
