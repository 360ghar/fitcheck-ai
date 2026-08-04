#!/usr/bin/env python3
"""
Downgrade one account to the free app plan WITHOUT touching its billing rail.

This is an app-side conversion only: it flips the local `subscriptions` row
(plan_type -> 'free', status -> 'active', period/trial dates cleared,
cancel_at_period_end -> false). The Stripe subscription, App Store
subscription, or Play subscription, if any, is deliberately left untouched
and KEEPS BILLING until cancelled in the provider dashboard.

Why billing is left alone matters: Stripe webhooks (customer.subscription.updated,
e.g. on renewal) call sync_stripe_subscription and can re-apply the paid plan
to this row. The clean end state is reached by cancelling the subscription in
the provider dashboard: the built-in `customer.subscription.deleted` webhook
handler then downgrades the row to free automatically. This script exists for
the window before that happens (and for rows with no billing identity at all,
e.g. gifted trials).

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key

    # preview (writes nothing):
    DRY_RUN=1 python scripts/convert_account_to_free.py

    # run for real:
    python scripts/convert_account_to_free.py

Optional env:
    EMAIL=info@360ghar.com   # account email to convert (case-insensitive)
    USER_ID=...              # pin one user when the email has multiple accounts
    AUDIT_FILE=backend/logs/account_conversions.jsonl   # JSONL audit trail

The audit file is the durable record of the conversion (who, when, from what
state). Safe to re-run: an already-free row is a no-op.
"""
from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from supabase import create_client

REPO_ROOT = Path(__file__).resolve().parents[2]


def _env(name: str, default: Optional[str] = None, *, required: bool = False) -> str:
    value = os.environ.get(name, default)
    if required and not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value or ""


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {"1", "true", "yes", "on"}


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _append_audit(path: Path, record: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(record, separators=(",", ":"), default=str) + "\n")


def _row_data(result: Any) -> Optional[dict]:
    """Normalize a PostgREST response to a single row dict or None."""
    raw = getattr(result, "data", None)
    if isinstance(raw, list):
        return raw[0] if raw else None
    return raw


def _summarize(row: Optional[dict]) -> dict:
    """Compact view of the subscription row for printing/auditing.

    Store tokens are never printed (they are sensitive identifiers); their
    presence is shown as a boolean instead.
    """
    if not row:
        return {}
    return {
        "plan_type": row.get("plan_type"),
        "status": row.get("status"),
        "current_period_start": row.get("current_period_start"),
        "current_period_end": row.get("current_period_end"),
        "trial_end": row.get("trial_end"),
        "cancel_at_period_end": row.get("cancel_at_period_end"),
        "billing_provider": row.get("billing_provider"),
        "stripe_customer_id": row.get("stripe_customer_id"),
        "stripe_subscription_id": row.get("stripe_subscription_id"),
        "has_apple_transaction": bool(row.get("apple_original_transaction_id")),
        "has_google_token": bool(row.get("google_purchase_token")),
        "referral_credit_months": row.get("referral_credit_months", 0),
    }


def main() -> int:
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)
    email = _env("EMAIL", "info@360ghar.com").strip().lower()
    user_id_pin = _env("USER_ID", "").strip() or None
    dry_run = _env_bool("DRY_RUN", False)
    audit_path = Path(
        _env("AUDIT_FILE", str(REPO_ROOT / "backend" / "logs" / "account_conversions.jsonl"))
    )

    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] convert account to free app plan")
    print(f"  email     = {email}")
    if user_id_pin:
        print(f"  user_id   = {user_id_pin} (pinned)")
    print(f"  audit     = {audit_path}")
    print()

    db = create_client(supabase_url, supabase_key)

    # --- 1) locate the user ------------------------------------------------ #
    # Exact match first; a case-insensitive fallback covers differently-cased
    # registrations. A company inbox may own several accounts, so ambiguity
    # fails closed unless USER_ID pins one.
    res = db.table("users").select("id,email,full_name").eq("email", email).execute()
    users = list(res.data or [])
    if not users:
        res = db.table("users").select("id,email,full_name").ilike("email", email).execute()
        users = list(res.data or [])
    if not users:
        print(f"ERROR: no user found with email {email!r}", file=sys.stderr)
        return 2
    if len(users) > 1 and not user_id_pin:
        print(
            f"ERROR: {len(users)} accounts use {email!r}; re-run with USER_ID=<uuid> to pin one:",
            file=sys.stderr,
        )
        for u in users:
            print(f"  - {u['id']}  {u.get('email')}  {u.get('full_name') or ''}")
        return 2
    if user_id_pin:
        matched = [u for u in users if u["id"] == user_id_pin]
        if not matched:
            print(
                f"ERROR: USER_ID={user_id_pin} is not among the accounts for {email!r}",
                file=sys.stderr,
            )
            return 2
        user = matched[0]
    else:
        user = users[0]

    print(f"user      = {user['id']}  {user.get('email')}  {user.get('full_name') or ''}")

    # --- 2) current subscription row --------------------------------------- #
    sub_res = db.table("subscriptions").select("*").eq("user_id", user["id"]).maybe_single().execute()
    sub = _row_data(sub_res)

    if not sub:
        # No row at all: the account is effectively free already (the service
        # creates a default free row on first access). Nothing to convert.
        print("no subscription row; account is already on the default free plan. Nothing to do.")
        return 0

    print("current subscription:")
    for key, value in _summarize(sub).items():
        print(f"  {key:<24} = {value}")

    stripe_sub_id = (sub.get("stripe_subscription_id") or "").strip()
    apple_tx = (sub.get("apple_original_transaction_id") or "").strip()
    google_token = (sub.get("google_purchase_token") or "").strip()
    has_live_billing = bool(stripe_sub_id or apple_tx or google_token)

    if has_live_billing:
        rail = {
            "stripe": "Stripe",
            "apple": "the App Store",
            "google": "the Play Store",
        }.get(sub.get("billing_provider"), "its billing provider")
        print()
        print(
            f"NOTE: this account has a live {rail} subscription that this script "
            "does NOT touch. It keeps billing until cancelled in the provider "
            "dashboard. Until then, provider webhooks (e.g. Stripe "
            "customer.subscription.updated on renewal) can re-apply the paid "
            "plan to this row. Cancelling the subscription there fires the "
            "customer.subscription.deleted webhook, which downgrades the row "
            "to free automatically."
        )

    # --- 3) target state --------------------------------------------------- #
    now_iso = _now_iso()
    old_summary = _summarize(sub)
    already_free = (
        sub.get("plan_type") == "free"
        and sub.get("status") == "active"
        and not sub.get("current_period_end")
        and not sub.get("trial_end")
        and not sub.get("cancel_at_period_end")
    )
    if already_free:
        print()
        print("subscription is already on the free plan (active, no period/trial). Nothing to do.")
        return 0

    update_payload = {
        "plan_type": "free",
        "status": "active",
        "current_period_end": None,
        "trial_end": None,
        "cancel_at_period_end": False,
        "updated_at": now_iso,
    }
    print()
    print("planned update (billing identities kept as-is):")
    for key, value in update_payload.items():
        print(f"  {key:<24} = {value}")

    if dry_run:
        print()
        print("DRY-RUN: no writes performed.")
        return 0

    # --- 4) convert -------------------------------------------------------- #
    # Guard on the observed plan/status so a concurrent change (e.g. a webhook
    # re-grant between read and write) cannot be silently clobbered; the
    # update then matches nothing and we report it.
    result = (
        db.table("subscriptions")
        .update(update_payload)
        .eq("user_id", user["id"])
        .eq("plan_type", sub.get("plan_type"))
        .eq("status", sub.get("status"))
        .execute()
    )
    if not (result.data and len(result.data) > 0):
        print(
            "ERROR: subscription changed between read and write; no update applied. "
            "Re-run the script to re-read the current state.",
            file=sys.stderr,
        )
        return 1

    # --- 5) verify --------------------------------------------------------- #
    check = db.table("subscriptions").select("*").eq("user_id", user["id"]).maybe_single().execute()
    new_summary = _summarize(_row_data(check))
    print()
    print("updated subscription (verified by re-read):")
    for key, value in new_summary.items():
        print(f"  {key:<24} = {value}")

    _append_audit(audit_path, {
        "action": "converted_to_free",
        "converted_at": now_iso,
        "email": user.get("email"),
        "user_id": user["id"],
        "old": old_summary,
        "new": new_summary,
    })
    print()
    print(f"DONE. Account {user['id']} is now on the free app plan. Audit: {audit_path}")
    if has_live_billing:
        print(
            "REMINDER: the billing subscription is still active and charging. "
            "Cancel it in the provider dashboard to finish the conversion."
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
