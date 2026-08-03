#!/usr/bin/env python3
"""
Repair pending / partially-applied referral grants.

RCA 2026-08-04 (docs/exec-plans/active/2026-08-04-referral-redemption-rca.md):
referral redemptions could fail SILENTLY and permanently:

  1. Signup-time redemption errors (missing `redeem_referral_atomic` RPC from
     unapplied migrations 022/026, dead pooled Supabase connection) were
     swallowed by register/oauth_sync - the new user stayed free and the
     referrer got nothing, with no retry.
  2. The 022-era `apply_referral_credit_atomic` only acted when
     plan_type='free', so partially-applied rows (one side credited, the
     other not) and expired-trial reactivations never completed.

The app now persists `users.referred_by_code` BEFORE the RPC and retries on
the next login, and migration 033 fixes activation/extension/stacking. This
script repairs the damage already done: it re-calls the idempotent
`redeem_referral_atomic` RPC for every candidate, which back-fills whichever
credit side is missing without double-granting.

Two candidate sets are scanned:

  A. users.referred_by_code IS NOT NULL
     -> a redemption that failed after the hook was persisted (or one that
        is still pending). Re-calling the RPC creates the redemption and
        applies both credits if absent; if the redemption already exists the
        RPC reports already-redeemed and only back-fills missing sides.
  B. referral_redemptions with referrer_credit_applied = FALSE OR
     referred_credit_applied = FALSE
     -> a partial grant (e.g. an old transaction that applied one side and
        lost the other). The code is looked up via referral_code_id and the
        RPC is re-called for the referred user.

Safe to run multiple times: the atomic RPC is one transaction with row
locks, so replays are no-ops once everything is applied.

Usage:
    cd backend
    export SUPABASE_URL=https://YOUR_PROJECT.supabase.co
    export SUPABASE_SECRET_KEY=eyJ...        # service-role key
    # preview:
    DRY_RUN=1 python scripts/repair_pending_referrals.py
    # run for real:
    python scripts/repair_pending_referrals.py

Optional env:
    REFERRAL_CREDIT_MONTHS=1                  # must match settings.REFERRAL_CREDIT_MONTHS
"""
from __future__ import annotations

import os
import sys

from supabase import create_client


def _env(name: str, required: bool = False, default: str = "") -> str:
    value = os.environ.get(name, default)
    if required and not value:
        print(f"ERROR: missing required env var {name}", file=sys.stderr)
        sys.exit(1)
    return value or ""


def _env_bool(name: str, default: bool = False) -> bool:
    return os.environ.get(name, "1" if default else "0").strip() in {
        "1",
        "true",
        "yes",
        "on",
    }


def _fetch_candidates(db) -> list[tuple[str, str]]:
    """Return [(referred_user_id, code)] from both candidate sets, deduped."""
    candidates: dict[str, str] = {}

    # A. users with a persisted (pending or stale) referral hook.
    try:
        res = (
            db.table("users")
            .select("id,referred_by_code")
            .not_("referred_by_code", "is", "null")
            .execute()
        )
        for row in res.data or []:
            code = (row.get("referred_by_code") or "").strip().lower()
            if row.get("id") and code:
                candidates[str(row["id"])] = code
    except Exception as e:
        print(f"WARNING: could not scan users.referred_by_code: {e}", file=sys.stderr)

    # B. redemption rows with a missing credit side; the code comes from the
    #    referrer's referral_codes row (referral_code_id).
    try:
        res = (
            db.table("referral_redemptions")
            .select(
                "referred_user_id,referral_code_id,"
                "referrer_credit_applied,referred_credit_applied,"
                "referral_codes!inner(code)"
            )
            .or_(
                "referrer_credit_applied.eq.false,"
                "referred_credit_applied.eq.false"
            )
            .execute()
        )
        for row in res.data or []:
            code = None
            nested = row.get("referral_codes")
            if isinstance(nested, list) and nested:
                code = (nested[0].get("code") or "").strip().lower()
            elif isinstance(nested, dict):
                code = (nested.get("code") or "").strip().lower()
            if row.get("referred_user_id") and code:
                candidates.setdefault(str(row["referred_user_id"]), code)
    except Exception as e:
        print(
            f"WARNING: could not scan incomplete referral_redemptions: {e}",
            file=sys.stderr,
        )

    return list(candidates.items())


def main() -> int:
    supabase_url = _env("SUPABASE_URL", required=True).rstrip("/")
    supabase_key = _env("SUPABASE_SECRET_KEY", required=True)
    dry_run = _env_bool("DRY_RUN", False)
    try:
        credit_months = int(_env("REFERRAL_CREDIT_MONTHS", default="1"))
    except ValueError:
        print("ERROR: REFERRAL_CREDIT_MONTHS must be an integer", file=sys.stderr)
        return 1
    if credit_months <= 0:
        print("ERROR: REFERRAL_CREDIT_MONTHS must be positive", file=sys.stderr)
        return 1

    mode = "DRY-RUN" if dry_run else "LIVE"
    print(f"[{mode}] repair pending / partially-applied referral grants")
    print(f"  credit_months = {credit_months}")
    print()

    db = create_client(supabase_url, supabase_key)

    candidates = _fetch_candidates(db)
    print(f"candidates (referred users to re-redeem): {len(candidates)}")
    if not candidates:
        print("nothing to do.")
        return 0

    if dry_run:
        print()
        print("DRY-RUN: no writes. Would re-call redeem_referral_atomic for:")
        for uid, code in candidates[:20]:
            print(f"  - {uid} (code={code})")
        if len(candidates) > 20:
            print(f"  ... and {len(candidates) - 20} more")
        return 0

    succeeded = 0
    already_done = 0
    rejected = 0
    failed = 0
    for i, (uid, code) in enumerate(candidates, start=1):
        try:
            result = db.rpc(
                "redeem_referral_atomic",
                {
                    "p_referred_user_id": uid,
                    "p_code": code,
                    "p_credit_months": credit_months,
                },
            ).execute()
            payload = result.data
            if isinstance(payload, list):
                payload = payload[0] if payload else None
            if not isinstance(payload, dict):
                print(f"  ERROR {uid}: unexpected RPC payload {result.data!r}", file=sys.stderr)
                failed += 1
                continue
            if payload.get("success") is True:
                # Fresh grant applied, or already-redeemed (both credit sides
                # now applied). Clear the stale hook, matching the app's
                # process_pending_referral behavior.
                if payload.get("already_redeemed"):
                    already_done += 1
                else:
                    succeeded += 1
                try:
                    db.table("users").update(
                        {"referred_by_code": None}
                    ).eq("id", uid).execute()
                except Exception as e:
                    print(f"  WARNING: could not clear referred_by_code for {uid}: {e}", file=sys.stderr)
            else:
                # Definitive rejection (invalid/self code) - clear the hook
                # so it stops being retried.
                rejected += 1
                print(
                    f"  REJECTED {uid}: {payload.get('message')}",
                    file=sys.stderr,
                )
                try:
                    db.table("users").update(
                        {"referred_by_code": None}
                    ).eq("id", uid).execute()
                except Exception as e:
                    print(f"  WARNING: could not clear referred_by_code for {uid}: {e}", file=sys.stderr)
        except Exception as e:
            # Transient (missing RPC from unapplied migration, dead
            # connection): leave the hook in place for the next run.
            print(f"  ERROR {uid}: {e}", file=sys.stderr)
            failed += 1
        if i % 25 == 0:
            print(f"  processed {i}/{len(candidates)}")

    print()
    print(
        f"DONE. applied={succeeded} already_redeemed={already_done} "
        f"rejected={rejected} failed={failed} (of {len(candidates)})"
    )
    if failed:
        print(
            "Some candidates could not be processed (see errors above). "
            "If the errors mention PGRST202, migrations 022_wave_b_hardening.sql "
            "and 026_harden_rpc_privileges.sql have not been applied to this "
            "Supabase project - apply them first, then re-run.",
            file=sys.stderr,
        )
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
