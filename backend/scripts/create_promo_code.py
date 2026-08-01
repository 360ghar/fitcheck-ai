#!/usr/bin/env python3
"""
Create a promo code for the FitCheck AI promo campaign.

Promo codes are shareable campaign links (`https://app.fitcheckaiapp.com/auth/register?promo=CODE`)
that grant the code's Plus/Pro plan for free for a fixed number of months.

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key

    # 1) preview (writes nothing):
    DRY_RUN=1 python scripts/create_promo_code.py --code LAUNCH30 --plan pro_monthly --months 1

    # 2) create for real:
    python scripts/create_promo_code.py --code LAUNCH30 --plan pro_monthly --months 1 \
        --max-uses 100 --expires 2026-09-01

Args:
    --code       Promo code (3-50 chars, alphanumeric + _ -). Case is kept for
                 display; matching is case-insensitive.
    --plan       Plan variant to grant: plus_monthly | plus_yearly | pro_monthly | pro_yearly
    --months     Free-access duration in months (default 1)
    --max-uses   Optional usage cap (default: unlimited)
    --expires    Optional expiry date (ISO, e.g. 2026-09-01 or 2026-09-01T23:59:59Z)

Idempotent: re-running with the same code prints the existing row and exits 0,
so campaign scripts can be retried safely.
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from datetime import datetime

import httpx

VALID_PLANS = ("plus_monthly", "plus_yearly", "pro_monthly", "pro_yearly")
CODE_RE = re.compile(r"^[a-zA-Z0-9][a-zA-Z0-9_-]{2,49}$")


def _get_env(name: str) -> str:
    value = os.environ.get(name, "").strip()
    if not value:
        print(f"Missing required env var: {name}", file=sys.stderr)
        raise SystemExit(2)
    return value


def _parse_expires(value: str) -> str:
    """Normalize an ISO date/datetime into a full timestamp for the DB."""
    raw = value.strip()
    try:
        parsed = datetime.fromisoformat(raw.replace("Z", "+00:00"))
    except ValueError:
        print(f"Invalid --expires value: {value!r} (use ISO, e.g. 2026-09-01)", file=sys.stderr)
        raise SystemExit(2)
    if parsed.tzinfo is None:
        parsed = parsed.replace(tzinfo=datetime.now().astimezone().tzinfo)
    return parsed.isoformat()


def _insert_promo(client: httpx.Client, base_url: str, key: str, payload: dict) -> dict:
    response = client.post(
        f"{base_url}/rest/v1/promo_codes",
        headers={
            "apikey": key,
            "Authorization": f"Bearer {key}",
            "Content-Type": "application/json",
            "Prefer": "return=representation",
        },
        json=payload,
    )
    if response.status_code == 409:
        # Unique violation: the code already exists.
        return {"already_exists": True}
    response.raise_for_status()
    rows = response.json()
    return {"row": rows[0] if rows else None}


def main() -> int:
    parser = argparse.ArgumentParser(description="Create a FitCheck AI promo code")
    parser.add_argument("--code", required=True, help="Promo code (3-50 chars, alphanumeric + _ -)")
    parser.add_argument("--plan", required=True, choices=VALID_PLANS, help="Plan variant to grant")
    parser.add_argument("--months", type=int, default=1, help="Free-access duration in months (default 1)")
    parser.add_argument("--max-uses", type=int, default=None, help="Usage cap (default: unlimited)")
    parser.add_argument("--expires", default=None, help="Expiry date (ISO, e.g. 2026-09-01)")
    args = parser.parse_args()

    if not CODE_RE.match(args.code):
        print(
            f"Invalid --code {args.code!r}: 3-50 chars, starting alphanumeric, "
            "only letters/digits/_/-",
            file=sys.stderr,
        )
        return 2
    if args.months < 1:
        print("--months must be >= 1", file=sys.stderr)
        return 2
    if args.max_uses is not None and args.max_uses < 1:
        print("--max-uses must be >= 1 (or omit for unlimited)", file=sys.stderr)
        return 2

    payload = {
        "code": args.code,
        "plan_type": args.plan,
        "months": args.months,
        "active": True,
        "used_count": 0,
    }
    if args.max_uses is not None:
        payload["max_uses"] = args.max_uses
    if args.expires:
        payload["expires_at"] = _parse_expires(args.expires)

    dry_run = os.environ.get("DRY_RUN", "0") == "1"
    frontend_url = os.environ.get("FRONTEND_URL", "https://fitcheckaiapp.com").rstrip("/")
    print(f"Promo code:        {args.code}")
    print(f"Grants:            {args.plan} free for {args.months} month(s)")
    print(f"Max uses:          {args.max_uses if args.max_uses is not None else 'unlimited'}")
    print(f"Expires:           {payload.get('expires_at', 'never')}")
    print(f"Shareable URL:     {frontend_url}/auth/register?promo={args.code}")
    print(f"DRY_RUN:           {dry_run}")

    if dry_run:
        print("\nDRY RUN - no row written.")
        return 0

    base_url = _get_env("SUPABASE_URL").rstrip("/")
    key = _get_env("SUPABASE_SECRET_KEY")

    with httpx.Client() as client:
        result = _insert_promo(client, base_url, key, payload)

    if result.get("already_exists"):
        print(f"\nPromo code {args.code} already exists - leaving it untouched.")
        return 0

    row = result.get("row")
    if not row:
        print("\nFailed to create promo code (no row returned).", file=sys.stderr)
        return 1
    print(f"\nCreated promo code {row['code']} (id={row['id']}).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
