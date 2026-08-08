# Plan: Upgrade free-plan users to a 1-month Pro trial (+ email)

Status: completed  
Started: 2026-08-04  
Owner: agent

## Goal

Every user still on the free plan gets a 1-month Pro trial (`plan_type=pro_monthly`,
`status=trial`, `trial_end=+1 month`, `cancel_at_period_end=true`) and a
"You've got Pro, on us" email. `info@360ghar.com` is excluded from grant and email.

## Non-goals

- Not touching paid / live-trial rows (784 users from the Aug 3 campaign).
- No permanent (non-expiring) upgrades; no Stripe/billing writes.
- No changes to the app, schema, or existing campaign scripts.

## Acceptance criteria

- [x] Script targets only `plan_type='free' AND status='active'` rows with no Stripe id.
- [x] `info@360ghar.com` excluded (verified: it is the only free row left after the run).
- [x] 112/112 grants landed; 112/112 emails sent (100 Resend + 12 SMTP); 0 failures (2026-08-04).
- [x] 74/74 grants landed on the 08-06 re-run (74 Resend); 0 failures; trial_end=2026-09-06.
- [x] All 112 granted rows verified: `pro_monthly`/`trial`, `trial_end=2026-09-04`, `cancel_at_period_end=true`; same verification passed for the 74 re-run rows.
- [x] Idempotent audit file + dry-run preview work (`DRY_RUN=1`).

## Context / links

- Script: `backend/scripts/upgrade_free_users_to_pro.py` (self-contained, mirrors
  `grant_free_pro_month.py` / `girlfriend_day_campaign.py`).
- Audit: `backend/logs/free_users_pro_trial.jsonl` (186 granted + 186 emailed records: 112 from the 08-04 run, 74 from the 08-06 re-run).
- Revert after the month: `backend/scripts/revert_expired_pro_trials.py` with
  `AUDIT_FILE=backend/logs/free_users_pro_trial.jsonl`.
- Prior campaign: `backend/logs/pro_grant.jsonl` (Aug 3 campaign, kept separate).

## Progress log

| Date | Note |
|------|------|
| 2026-08-04 | Read-only DB census: 896 users; 784 on pro trial (prior campaign), 112 free. |
| 2026-08-04 | Wrote script; ruff + py_compile clean; `DRY_RUN=1` reported exactly 112 eligible. |
| 2026-08-04 | Live run: 112 granted, 112 emailed (100 Resend, 12 SMTP), 0 failures. |
| 2026-08-04 | Post-run verification: all 112 rows match campaign state; 1 free row remains = `info@360ghar.com` (excluded). |
| 2026-08-06 | Re-run (same script, same audit file): 1,505 users scanned, 74 free/active eligible (excl. `info@360ghar.com`); 74 granted + 74 emailed via Resend, 0 failures; trial_end 2026-09-06. Post-run: all 74 rows verified (`pro_monthly`/`trial`, `cancel_at_period_end=true`); remaining free/active rows = 1 (`info@360ghar.com`). |

## Decision log

| Date | Decision | Why |
|------|----------|-----|
| 2026-08-04 | 1-month trial (not permanent Pro) | Owner chose same semantics as Aug 3 campaign; revertable via existing revert script. |
| 2026-08-04 | Reuse "You've got Pro, on us" email template | Owner approved; consistent with prior campaign. |
| 2026-08-04 | New audit file `free_users_pro_trial.jsonl` | Keeps this campaign's grants separate from `pro_grant.jsonl` so the Aug 3 revert can't clobber them. |
| 2026-08-04 | Transport `split` (100 Resend / 12 SMTP) | 112 recipients exceed Resend's ~100/day cap; split is the proven pattern from `girlfriend_day_campaign.py`. |

## Verification

```bash
cd backend
DRY_RUN=1 .venv/bin/python scripts/upgrade_free_users_to_pro.py   # preview, no writes
.venv/bin/python scripts/upgrade_free_users_to_pro.py             # live grant + email
# post-run (both runs combined, 08-04 + 08-06 re-run):
#   subs distribution: pro_monthly/trial ~970, free/active 1 (info@360ghar.com)
#   audit: 186 granted, 174 emailed/resend, 12 emailed/smtp (trial_end 2026-09-06)
```

## Deferred debt

- Revert window: after 2026-09-06, run `revert_expired_pro_trials.py` with
  `AUDIT_FILE=backend/logs/free_users_pro_trial.jsonl` (or schedule it).
- Observed (pre-existing, not caused by this campaign): `info@360ghar.com`'s row
  was downgraded from pro trial to free at 2026-08-04T19:01:59Z via the
  "Store purchase expired/refunded; downgraded to free" path in
  `subscription_service.py`, 6 minutes before this campaign ran. The account was
  excluded from the campaign regardless. Worth confirming whether the owner
  triggered it or a stale store/webhook sync did.
- 360 pre-existing trial rows have `billing_provider='stripe'`,
  `cancel_at_period_end=false` (referral/other origins, trial_end 2026-09-01..03).
  Untouched by this campaign; flagged for the tech-debt tracker if they matter.
