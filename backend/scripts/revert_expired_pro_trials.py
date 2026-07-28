#!/usr/bin/env python3
"""
Revert expired Pro trials from a grant_free_pro_month.py campaign.

There is no auto-expiry in the app today (`is_pro_plan()` checks only
`plan_type`), so without this script gifted Pro stays forever. This script
reads the campaign audit file (written by grant_free_pro_month.py) and, for
each user whose `trial_end` has passed AND who has no live Stripe
subscription, downgrades them back to free.

Safe to run multiple times - once a row is reverted it's reset to
plan_type='free', so subsequent runs are no-ops for it.

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key

    # preview:
    DRY_RUN=1 python scripts/revert_expired_pro_trials.py

    # run for real:
    python scripts/revert_expired_pro_trials.py

Optional env:
    AUDIT_FILE=backend/logs/pro_grant.jsonl   # must match the grant run
    INCLUDE_PAID=0                            # 1 = also revert paying users (DANGEROUS)

Recommended: schedule daily (Railway cron / system cron) until the campaign
window is fully reverted, then retire. Not wired automatically.
"""
from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

from supabase import create_client


def _env(name: str, default: str | None = None, *, required: bool = False) -> str:
    value = os.environ.get(name, default)
    if required and not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value or ""


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {"1", "true", "yes", "on"}


def _load_campaign(path: Path) -> dict[str, str]:
    """Return {user_id: trial_end_iso} for granted rows in the audit file."""
    out: dict[str, str] = {}
    if not path.exists():
        print(f"ERROR: audit file not found: {path}", file=sys.stderr)
        sys.exit(1)
    with path.open("r", encoding="utf-8") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            if rec.get("action") == "granted" and rec.get("user_id") and rec.get("trial_end"):
                out[rec["user_id"]] = rec["trial_end"]
    return out


def main() -> int:
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)
    audit_path = Path(_env("AUDIT_FILE", "backend/logs/pro_grant.jsonl"))
    include_paid = _env_bool("INCLUDE_PAID", False)
    dry_run = _env_bool("DRY_RUN", False)

    now = datetime.now(timezone.utc)
    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] revert expired Free Pro Month trials")
    print(f"  now         = {now.isoformat()}")
    print(f"  audit_file  = {audit_path}")
    print(f"  include_paid= {include_paid}")
    print()

    campaign = _load_campaign(audit_path)
    print(f"campaign users in audit: {len(campaign)}")
    if not campaign:
        print("nothing to do.")
        return 0

    # Which ones are past trial_end?
    expired_ids = [uid for uid, te in campaign.items()
                   if datetime.fromisoformat(te) < now]
    print(f"expired (trial_end < now): {len(expired_ids)}")
    if not expired_ids:
        print("no expired trials yet; nothing to revert.")
        return 0

    db = create_client(supabase_url, supabase_key)

    # Fetch current subscription rows in pages to filter out paying users
    # and confirm the row is still on a pro/trial state worth reverting.
    page = 500
    to_revert: list[str] = []
    skipped_paid = 0
    skipped_already_free = 0
    for i in range(0, len(expired_ids), page):
        chunk = expired_ids[i : i + page]
        res = db.table("subscriptions").select(
            "user_id,plan_type,status,stripe_subscription_id"
        ).in_("user_id", chunk).execute()
        for row in (res.data or []):
            uid = row["user_id"]
            has_stripe = bool(row.get("stripe_subscription_id"))
            if has_stripe and not include_paid:
                skipped_paid += 1
                continue
            # Only revert rows that are actually still pro/trial from the gift.
            # If the user already moved to free by some other path, leave them.
            if row.get("plan_type") not in ("pro_monthly", "pro_yearly"):
                skipped_already_free += 1
                continue
            if row.get("status") not in ("trial", "active"):
                skipped_already_free += 1
                continue
            to_revert.append(uid)

    print(f"skipped (now paying): {skipped_paid}")
    print(f"skipped (already free/cancelled): {skipped_already_free}")
    print(f"to revert: {len(to_revert)}")

    if dry_run:
        print()
        print("DRY-RUN: no writes. Would downgrade these user_ids to free:")
        for uid in to_revert[:20]:
            print(f"  - {uid}")
        if len(to_revert) > 20:
            print(f"  ... and {len(to_revert) - 20} more")
        return 0

    reverted = 0
    for uid in to_revert:
        try:
            db.table("subscriptions").update({
                "plan_type": "free",
                "status": "active",
                "trial_end": None,
                "current_period_end": None,
                "cancel_at_period_end": False,
            }).eq("user_id", uid).execute()
        except Exception as e:
            print(f"  ERROR reverting {uid}: {e}", file=sys.stderr)
            continue
        reverted += 1
        if reverted % 25 == 0:
            print(f"  reverted {reverted}/{len(to_revert)}")

    print()
    print(f"DONE. reverted={reverted}/{len(to_revert)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
