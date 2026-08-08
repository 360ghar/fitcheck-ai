# RCA: silent referral-redemption failures

Status: active (code fixes landed; repair script + migration 033 pending ops review)
Started: 2026-08-04
Owner: agent

## Goal

Referral redemptions could fail SILENTLY and permanently: the new user stayed
free and the referrer got nothing, with no retry and no visible error. This
RCA documents the failure modes, the durable-retry design that fixes them,
and the migration + repair script that back-fill the damage already done.

## Root cause

Two independent failure modes (both observed in production 2026-08-03/04):

1. **Swallowed signup-time errors.** `redeem_referral` called the atomic RPC
   `redeem_referral_atomic` (migrations 022/026) and the error handlers in
   register/`oauth/sync` caught everything and logged at WARN — so a missing
   RPC (migrations never applied to the hosted project) or a dead pooled
   Supabase connection (the 2026-08-01/03 `ConnectionTerminated` family)
   silently dropped the redemption forever.

2. **Partial / expired-trial grants.** The 022-era
   `apply_referral_credit_atomic` only acted when `plan_type='free'`, so a
   partially-applied row (one credit side applied, the other lost) or a
   redemption on an expired-trial account never completed. Migration 033
   fixes activation/extension/stacking.

## Fixes (landed)

- **Durable retry hook**: `redeem_referral` now persists
  `users.referred_by_code` BEFORE calling the RPC (best-effort write). A
  transient failure leaves the hook in place; `process_pending_referral`
  (wired into `login` and `oauth/sync`) completes the grant on the next
  sign-in. The hook is cleared on a definitive rejection (invalid/own code)
  so a code that can never succeed is not retried. The atomic RPC is one
  transaction with row locks, so replays are no-ops once everything is
  applied (idempotent).
- **Transient-failure response**: registration/`oauth/sync` now return a
  "we couldn't apply your referral right now — it will be applied
  automatically on your next sign-in" block instead of silence.
  (`RedeemReferralResponse` is imported at module level; a missing import
  here crashed this exact path with NameError -> 500, found by ruff during
  verification and fixed.)
- **Migration `033_fix_referral_credit_stacking.sql`**: fixes
  activation/extension/stacking semantics.
- **Boot probe**: `missing_referral_rpcs` (in `app/utils/db.py`) probes
  `redeem_referral_atomic` / `apply_referral_credit_atomic` at boot so a
  missing-migration gap is logged with the runbook hint immediately.
- **Repair script**: `backend/scripts/repair_pending_referrals.py` re-calls
  the idempotent RPC for every candidate (users with a pending hook, and
  redemptions with either credit side missing), back-filling whichever side
  is missing without double-granting. Safe to run repeatedly.

## Code

- `backend/app/services/referral_service.py` — `redeem_referral`,
  `process_pending_referral`
- `backend/app/api/v1/auth.py` — register / login / `oauth/sync` wiring
- `backend/db/supabase/migrations/033_fix_referral_credit_stacking.sql`
- `backend/scripts/repair_pending_referrals.py`
- `backend/app/utils/db.py` — `missing_referral_rpcs` boot probe
- `backend/app/main.py` — boot probe wiring (referral RPCs logged at boot)
- `frontend/src/stores/authStore.ts` — OAuth callback now toasts a
  destructive "Referral not applied" on `referral.success === false`
  (previously silent); the email-register path already rendered the toast
  via `RegisterPage`
- `flutter/lib/features/auth/controllers/auth_controller.dart` — register
  stashes the referral code via `ReferralService.setPendingReferralCode`
  when (a) the redemption fails transiently or (b) email confirmation is
  required (redemption cannot run until the account is confirmed); the
  auth-change listener / next login retries through
  `handleOAuthCallback`'s pending-code path

## Tests

- `backend/tests/test_referral_service.py` — hook persisted before RPC,
  hook cleared on definitive rejection, hook kept on transient failure,
  pending redemption completes, already-redeemed clears without RPC
- `backend/tests/test_auth.py::test_register_transient_referral_failure_returns_will_retry_message`
  — endpoint-level: a raising `redeem_referral` still returns 201 with the
  "will retry" referral block
- `backend/tests/test_auth.py::test_login_retries_pending_referral` —
  login calls `process_pending_referral` for the pending hook
- `backend/tests/test_wave_b_hardening.py` — `missing_referral_rpcs`
  detects missing functions, counts non-PGRST202 errors as present, and
  both probes are non-mutating (nil UUID / nonexistent code)
- `flutter/test/features/auth/auth_controller_referral_test.dart` — 3
  widget tests: transient failure stashes, email-confirmation stashes,
  success does not stash

## Verification

```bash
cd backend && source .venv/bin/activate
python -m pytest -q
ruff check app tests
cd .. && python scripts/check_architecture.py && python scripts/check_docs_structure.py
cd frontend && npm run lint && npm run build
cd flutter && flutter analyze lib test && flutter test
```

## Ops runbook (required — human)

1. **Verify the hosted project state** (read-only, Supabase SQL editor):
   ```sql
   SELECT proname FROM pg_proc
   WHERE proname IN ('redeem_referral_atomic', 'apply_referral_credit_atomic',
                     'redeem_promo_atomic');
   ```
- Empty → migrations 022/026 were never applied (the 07-31 gap).
- Also check the damage window:
     ```sql
     SELECT count(*) FROM public.users WHERE referred_by_code IS NOT NULL;
     SELECT count(*) FROM public.referral_redemptions
     WHERE referrer_credit_applied = FALSE OR referred_credit_applied = FALSE;
     ```
2. **Apply migrations in order** if any are missing: `022_wave_b_hardening.sql`,
   `026_harden_rpc_privileges.sql`, then `033_fix_referral_credit_stacking.sql`
   (each is idempotent; 033 applies the 032-style activation/extension/
   stacking semantics to `apply_referral_credit_atomic`).
3. **Deploy the backend** (durable hook, login/oauth retry, boot probe).
4. **Repair past damage** once migrations are live:
   ```bash
   cd backend
   export SUPABASE_URL=... SUPABASE_SECRET_KEY=...
   DRY_RUN=1 python scripts/repair_pending_referrals.py   # preview
   python scripts/repair_pending_referrals.py             # apply
   ```
   Re-calls the idempotent atomic RPC for every user with a pending hook or
   a redemption row with a missing credit side; safe to re-run.
5. After deploy, confirm the boot log has no
   `Referral redemption RPCs missing from hosted Supabase` error line.

## Progress log

| Date | Note |
|------|------|
| 2026-08-04 | RCA complete: swallowed signup errors (missing RPC from unapplied 022/026, dead pooled connections) + 022-era credit function that only acted on `plan_type='free'` (no reactivation of expired trials, no stacking for referrers, no partial-grant completion). Durable retry hook, login/oauth retry wiring, surfaced failures, boot probe, repair script, migration 033, web + flutter client-side handling landed with tests. Backend targeted suites green; flutter widget tests green. |
