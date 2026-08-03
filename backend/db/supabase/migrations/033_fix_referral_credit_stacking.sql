-- FitCheck AI - Fix referral credit activation, extension, and stacking
--
-- RCA 2026-08-04 (docs/exec-plans/active/2026-08-04-referral-redemption-rca.md):
-- the 022-era apply_referral_credit_atomic only acts when plan_type='free',
-- so:
--   * a user whose referral trial has EXPIRED (plan_type='pro_monthly',
--     status='trial', trial_end in the past - referral trials are never
--     auto-reverted) can never be reactivated by a new referral: the CASE
--     branches evaluate on the old row and the UPDATE only bumps
--     referral_credit_months. Both the referred user and the referrer stay
--     effectively free ("still on free plan after referral").
--   * a referrer on a LIVE trial never gets trial_end extended - "no limit
--     to how many friends you can refer" (FAQ) is false; only a counter
--     moves.
--
-- The promo path already fixed both semantics in 032
-- (GREATEST(COALESCE(trial_end, NOW()), NOW()) + months, effective-plan
-- judgment, "never overwrite a paying subscriber"). This migration applies
-- the same rules to the referral grant, in one row-locked function:
--
--   1. Paying subscriber (status='active' with a future period end - Stripe,
--      Play, App Store): bank the months in referral_credit_months only.
--      Never touch a paying row - a Stripe snapshot would clobber a
--      locally-extended period anyway.
--   2. Trial row, live OR expired (status='trial' on a paid plan): EXTEND
--      from the later of (existing trial_end, NOW()) so stacking never
--      shrinks a running grant and a lapsed trial reactivates.
--   3. Free / any other non-entitled state: ACTIVATE a Pro trial, again
--      extending from any existing (expired) trial_end so lapsed referrers
--      stack on their previous window.
--
-- NOTE: a LIVE trial is deliberately NOT banked (branch 1) - referrals are
-- meant to stack by extending the running window ("no limit to how many
-- friends you can refer", FAQ), so trial rows fall through to branch 2.
--
-- Idempotent (CREATE OR REPLACE + REVOKE/GRANT guards): safe to re-run.
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
    IF sub_row.plan_type <> 'free' AND sub_row.status = 'trial' THEN
        new_trial_end := GREATEST(COALESCE(sub_row.trial_end, NOW()), NOW())
            + make_interval(months => p_months);
        UPDATE public.subscriptions
        SET trial_end = new_trial_end,
            current_period_end = new_trial_end,
            referral_credit_months = COALESCE(referral_credit_months, 0) + p_months,
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
        referral_credit_months = COALESCE(referral_credit_months, 0) + p_months,
        updated_at = NOW()
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Harden RPC privileges (same policy as 022/026: the backend calls this with
-- the service-role client, so browser roles must not be able to invoke it).
REVOKE EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER) TO service_role;

COMMIT;
