-- FitCheck AI - Forward migration: referral_redemptions.credit_months column
--
-- Migration 007 (shipped 2026-01-14) created referral_redemptions WITHOUT the
-- credit_months column; the column was added to the repo's 007 copy only in
-- the 2026-08 bug sweep. Existing deployments therefore still lack it, and
-- ReferralService.get_referral_stats (which SELECTs credit_months) fails with
-- an undefined-column error instead of returning stats.
--
-- Rerunnable (ADD COLUMN IF NOT EXISTS): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

ALTER TABLE public.referral_redemptions
    ADD COLUMN IF NOT EXISTS credit_months INTEGER;

COMMIT;
