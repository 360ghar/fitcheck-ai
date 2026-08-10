-- FitCheck AI - Forward migration: referral trial grants never bank credit
--
-- Migration 033 (released 2026-08-04) fixed the referral credit
-- activation/extension/stacking semantics, but the ORIGINAL released 033
-- banked `referral_credit_months` in branch 2 (live/expired trial extension)
-- and branch 3 (activation) as well as branch 1 (paying subscriber). The
-- banking was removed from the repo's 033 copy only in the 2026-08 bug sweep;
-- existing deployments still run the banking version, so a trial grant is
-- handed out twice: once as the trial window, then again when
-- _consume_banked_referral_credit spends the bank after the trial lapses
-- (A1-02).
--
-- This forward migration recreates apply_referral_credit_atomic with the
-- corrected branches (bank reserved for paying subscribers only), following
-- the 032/033 pattern. Identical to the corrected 033 body.
--
-- Rerunnable (CREATE OR REPLACE + guarded REVOKE/GRANT): safe to re-run.
--
-- Target: Supabase Postgres

BEGIN;

CREATE OR REPLACE FUNCTION public.apply_referral_credit_atomic(
    p_user_id UUID,
    p_months INTEGER
)
RETURNS VOID AS $$
DECLARE
    sub_row public.subscriptions%ROWTYPE;
    new_trial_end TIMESTAMPTZ;
BEGIN
    IF p_months <= 0 THEN
        RAISE EXCEPTION 'Referral credit must be positive';
    END IF;

    -- Lock the subscription row for the whole decision so concurrent
    -- redemptions (referrer + referred, or a retry) serialize instead of
    -- both reading the same "free" state.
    SELECT * INTO sub_row
    FROM public.subscriptions
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO public.subscriptions (user_id, plan_type, status, current_period_start)
        VALUES (p_user_id, 'free', 'active', NOW())
        ON CONFLICT (user_id) DO NOTHING;
        SELECT * INTO sub_row
        FROM public.subscriptions
        WHERE user_id = p_user_id;
    END IF;

    -- 1. Paying subscriber (status='active' with a future period end):
    --    bank only, never overwrite (same rule as redeem_promo_atomic in
    --    032 and grant_free_pro_month.py). Deliberately narrower than
    --    SubscriptionService.effective_plan_type: a LIVE trial is NOT
    --    banked here - referrals stack by EXTENDING the running window
    --    (branch 2), per the FAQ promise and the RCA 2026-08-04
    --    requirement. An expired trial (trial_end in the past) is
    --    effectively free, so its holder can still be granted a trial.
    IF sub_row.plan_type <> 'free'
       AND sub_row.status = 'active'
       AND sub_row.current_period_end IS NOT NULL
       AND sub_row.current_period_end > NOW() THEN
        UPDATE public.subscriptions
        SET referral_credit_months = COALESCE(referral_credit_months, 0) + p_months,
            updated_at = NOW()
        WHERE user_id = p_user_id;
        RETURN;
    END IF;

    -- 2. Trial row, live or expired (status='trial' on a paid plan): extend
    --    the window instead of restarting it, so stacking a referral on a
    --    running trial never shrinks it and a lapsed trial reactivates from
    --    NOW() via GREATEST.
    --    A1-02: the EXTENSION is the grant — the bank is NOT incremented
    --    here (or in branch 3). The bank is reserved for paying subscribers
    --    (branch 1) whose credit cannot be granted as a trial; banking a
    --    trial grant as well handed the same months out twice when
    --    _consume_banked_referral_credit later spent the bank after the
    --    trial lapsed.
    IF sub_row.plan_type <> 'free' AND sub_row.status = 'trial' THEN
        new_trial_end := GREATEST(COALESCE(sub_row.trial_end, NOW()), NOW())
            + make_interval(months => p_months);
        UPDATE public.subscriptions
        SET trial_end = new_trial_end,
            current_period_end = new_trial_end,
            updated_at = NOW()
        WHERE user_id = p_user_id;
        RETURN;
    END IF;

    -- 3. Free / expired trial / non-entitled state: activate (or reactivate)
    --    a Pro referral trial. Extending from the later of the existing
    --    trial_end (even an expired one) and NOW() means a lapsed referrer's
    --    next referral stacks on their previous window instead of shrinking
    --    it, and an active trial holder who somehow falls through here keeps
    --    their full remaining time.
    new_trial_end := GREATEST(COALESCE(sub_row.trial_end, NOW()), NOW())
        + make_interval(months => p_months);

    UPDATE public.subscriptions
    SET plan_type = 'pro_monthly',
        status = 'trial',
        current_period_start = NOW(),
        current_period_end = new_trial_end,
        cancel_at_period_end = FALSE,
        trial_end = new_trial_end,
        updated_at = NOW()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Harden RPC privileges (same policy as 022/026/033: the backend calls this
-- with the service-role client, so browser roles must not be able to invoke
-- it).
REVOKE EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER) TO service_role;

COMMIT;
