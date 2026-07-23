#!/usr/bin/env python3
"""
Seed an App Store reviewer demo account with sample wardrobe data.

Creates (or reuses) a password user, then seeds body profile, ~12 wardrobe
items (metadata only — no photo upload), and 2–3 outfits via the public API.

Usage:
    cd backend
    export API_BASE_URL=https://api.fitcheckaiapp.com
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_ANON_KEY=eyJ...
    export REVIEW_EMAIL=review@fitcheckaiapp.com
    export REVIEW_PASSWORD='choose-a-strong-password'
    python scripts/seed_app_store_reviewer.py

Optional:
    REVIEW_FULL_NAME="App Store Reviewer"
    SKIP_EXISTING_ITEMS=1   # if items already exist, only report counts

After success, paste REVIEW_EMAIL / REVIEW_PASSWORD into App Store Connect
Review Notes (see docs/store/app-store-listing.md §4).
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request
from typing import Any


def _env(name: str, default: str | None = None) -> str:
    value = os.environ.get(name, default)
    if not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value


def _request(
    method: str,
    url: str,
    *,
    headers: dict[str, str] | None = None,
    body: dict[str, Any] | None = None,
) -> tuple[int, Any]:
    data = None
    req_headers = {"Accept": "application/json", **(headers or {})}
    if body is not None:
        data = json.dumps(body).encode("utf-8")
        req_headers["Content-Type"] = "application/json"
    req = urllib.request.Request(url, data=data, headers=req_headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read().decode("utf-8") or "null"
            return resp.status, json.loads(raw)
    except urllib.error.HTTPError as e:
        raw = e.read().decode("utf-8", errors="replace")
        try:
            parsed: Any = json.loads(raw) if raw else None
        except json.JSONDecodeError:
            parsed = raw
        return e.code, parsed


SAMPLE_ITEMS: list[dict[str, Any]] = [
    {"name": "White Oxford Shirt", "category": "tops", "colors": ["white"], "style": "classic", "seasonal_tags": ["spring", "fall"], "occasion_tags": ["work", "casual"]},
    {"name": "Navy Polo", "category": "tops", "colors": ["navy"], "style": "casual", "seasonal_tags": ["summer"], "occasion_tags": ["casual"]},
    {"name": "Black Crew Tee", "category": "tops", "colors": ["black"], "style": "casual", "seasonal_tags": ["all-season"], "occasion_tags": ["casual"]},
    {"name": "Grey Merino Sweater", "category": "tops", "colors": ["grey"], "style": "smart-casual", "seasonal_tags": ["fall", "winter"], "occasion_tags": ["work"]},
    {"name": "Dark Wash Jeans", "category": "bottoms", "colors": ["blue"], "style": "casual", "seasonal_tags": ["all-season"], "occasion_tags": ["casual"]},
    {"name": "Khaki Chinos", "category": "bottoms", "colors": ["beige"], "style": "smart-casual", "seasonal_tags": ["spring", "summer"], "occasion_tags": ["work", "casual"]},
    {"name": "Black Tailored Trousers", "category": "bottoms", "colors": ["black"], "style": "formal", "seasonal_tags": ["all-season"], "occasion_tags": ["work", "formal"]},
    {"name": "White Sneakers", "category": "shoes", "colors": ["white"], "style": "casual", "seasonal_tags": ["all-season"], "occasion_tags": ["casual"]},
    {"name": "Brown Leather Loafers", "category": "shoes", "colors": ["brown"], "style": "smart-casual", "seasonal_tags": ["all-season"], "occasion_tags": ["work"]},
    {"name": "Navy Blazer", "category": "outerwear", "colors": ["navy"], "style": "smart-casual", "seasonal_tags": ["fall", "spring"], "occasion_tags": ["work"]},
    {"name": "Beige Trench Coat", "category": "outerwear", "colors": ["beige"], "style": "classic", "seasonal_tags": ["fall", "spring"], "occasion_tags": ["casual", "work"]},
    {"name": "Leather Belt", "category": "accessories", "colors": ["brown"], "style": "classic", "seasonal_tags": ["all-season"], "occasion_tags": ["work", "casual"]},
]


def main() -> None:
    api_base = _env("API_BASE_URL", "https://api.fitcheckaiapp.com").rstrip("/")
    supabase_url = _env("SUPABASE_URL").rstrip("/")
    anon_key = _env("SUPABASE_ANON_KEY")
    email = _env("REVIEW_EMAIL", "review@fitcheckaiapp.com")
    password = _env("REVIEW_PASSWORD")
    full_name = os.environ.get("REVIEW_FULL_NAME", "App Store Reviewer")
    skip_existing = os.environ.get("SKIP_EXISTING_ITEMS", "").lower() in {
        "1",
        "true",
        "yes",
    }

    print(f"API:      {api_base}")
    print(f"Supabase: {supabase_url}")
    print(f"Email:    {email}")

    # --- Auth: try sign-in, else sign-up ---
    token: str | None = None
    status, payload = _request(
        "POST",
        f"{supabase_url}/auth/v1/token?grant_type=password",
        headers={"apikey": anon_key, "Authorization": f"Bearer {anon_key}"},
        body={"email": email, "password": password},
    )
    if status == 200 and isinstance(payload, dict) and payload.get("access_token"):
        token = payload["access_token"]
        print("Signed in existing user.")
    else:
        status, payload = _request(
            "POST",
            f"{supabase_url}/auth/v1/signup",
            headers={"apikey": anon_key, "Authorization": f"Bearer {anon_key}"},
            body={
                "email": email,
                "password": password,
                "data": {"full_name": full_name},
            },
        )
        if status in (200, 201) and isinstance(payload, dict):
            token = payload.get("access_token") or (payload.get("session") or {}).get(
                "access_token"
            )
            if token:
                print("Created user and obtained session.")
            else:
                print(
                    "User created but no session returned (email confirm may be required)."
                )
                print("Confirm the user in Supabase Auth, then re-run this script.")
                print(f"Signup response status={status}: {payload}")
                sys.exit(2)
        else:
            print(f"Auth failed status={status}: {payload}", file=sys.stderr)
            sys.exit(1)

    assert token
    auth_headers = {"Authorization": f"Bearer {token}"}

    # --- Profile name ---
    status, payload = _request(
        "PUT",
        f"{api_base}/api/v1/users/me",
        headers=auth_headers,
        body={"full_name": full_name},
    )
    print(f"Update profile: HTTP {status}")

    # --- Body profile ---
    status, payload = _request(
        "POST",
        f"{api_base}/api/v1/users/body-profiles",
        headers=auth_headers,
        body={
            "name": "Default",
            "height_cm": 175,
            "weight_kg": 72,
            "body_shape": "rectangle",
            "skin_tone": "medium",
            "is_default": True,
        },
    )
    if status in (200, 201):
        print("Body profile created.")
    else:
        print(f"Body profile note HTTP {status}: {payload} (may already exist)")

    # --- Items ---
    status, existing = _request(
        "GET",
        f"{api_base}/api/v1/items?page=1&page_size=50",
        headers=auth_headers,
    )
    existing_count = 0
    if status == 200 and isinstance(existing, dict):
        data = existing.get("data") or existing.get("items") or []
        if isinstance(data, dict):
            data = data.get("items") or data.get("data") or []
        existing_count = len(data) if isinstance(data, list) else 0

    item_ids: list[str] = []
    if existing_count >= 8 and skip_existing:
        print(f"Skipping item create ({existing_count} items already present).")
        if isinstance(existing, dict):
            rows = existing.get("data") or []
            if isinstance(rows, dict):
                rows = rows.get("items") or []
            if isinstance(rows, list):
                item_ids = [str(r["id"]) for r in rows if isinstance(r, dict) and r.get("id")]
    else:
        for item in SAMPLE_ITEMS:
            status, payload = _request(
                "POST",
                f"{api_base}/api/v1/items",
                headers=auth_headers,
                body=item,
            )
            if status in (200, 201) and isinstance(payload, dict):
                row = payload.get("data") or payload
                iid = row.get("id") if isinstance(row, dict) else None
                if iid:
                    item_ids.append(str(iid))
                    print(f"  + item {item['name']} ({iid})")
                else:
                    print(f"  ? item {item['name']} HTTP {status}: {payload}")
            else:
                print(f"  ! item {item['name']} failed HTTP {status}: {payload}")

    if len(item_ids) < 4:
        print(
            "Not enough item IDs to build outfits. "
            "List items in the app or re-run without SKIP_EXISTING_ITEMS.",
            file=sys.stderr,
        )
        sys.exit(1)

    # --- Outfits ---
    outfits = [
        {
            "name": "Smart casual Friday",
            "description": "Navy polo + chinos + loafers",
            "item_ids": item_ids[1:2] + item_ids[5:6] + item_ids[8:9],
            "style": "smart-casual",
            "occasion": "work",
            "is_draft": False,
        },
        {
            "name": "Weekend casual",
            "description": "Tee + jeans + sneakers",
            "item_ids": item_ids[2:3] + item_ids[4:5] + item_ids[7:8],
            "style": "casual",
            "occasion": "casual",
            "is_draft": False,
        },
        {
            "name": "Office ready",
            "description": "Oxford + trousers + blazer",
            "item_ids": item_ids[0:1] + item_ids[6:7] + item_ids[9:10],
            "style": "formal",
            "occasion": "work",
            "is_draft": False,
        },
    ]

    for outfit in outfits:
        # Filter empty id slots if list shorter
        outfit["item_ids"] = [i for i in outfit["item_ids"] if i]
        if len(outfit["item_ids"]) < 2:
            continue
        status, payload = _request(
            "POST",
            f"{api_base}/api/v1/outfits",
            headers=auth_headers,
            body=outfit,
        )
        print(f"Outfit '{outfit['name']}': HTTP {status}")

    print()
    print("=== Done ===")
    print(f"Demo email:    {email}")
    print("Demo password: (as set in REVIEW_PASSWORD)")
    print("Paste credentials into App Store Connect Review Notes.")
    print("Optional: open the app, add 1–2 real photos for richer screenshots.")


if __name__ == "__main__":
    main()
