-- FitCheck AI - Atomic admin user actions
--
-- Administrative trial and counter actions previously did read-modify-write
-- updates through PostgREST. Concurrent admins could lose a trial extension,
-- and a failed photoshoot reset could be hidden after the AI settings update
-- had already succeeded. Keep each user action in a single transaction.

BEGIN;

CREATE OR REPLACE FUNCTION public.admin_extend_user_trial(
    p_user_id UUID,
    p_days INTEGER
)
RETURNS TABLE (
    subscription JSONB,
    before_trial_end TIMESTAMPTZ,
    after_trial_end TIMESTAMPTZ
) AS $$
DECLARE
    v_subscription public.subscriptions%ROWTYPE;
BEGIN
    IF p_days < 1 OR p_days > 90 THEN
        RAISE EXCEPTION 'Trial extension must be between 1 and 90 days';
    END IF;

    SELECT * INTO v_subscription
    FROM public.subscriptions
    WHERE user_id = p_user_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    before_trial_end := v_subscription.trial_end;
    after_trial_end := GREATEST(COALESCE(before_trial_end, NOW()), NOW())
        + make_interval(days => p_days);

    UPDATE public.subscriptions
    SET trial_end = after_trial_end,
        updated_at = NOW()
    WHERE user_id = p_user_id
    RETURNING * INTO v_subscription;

    subscription := to_jsonb(v_subscription);
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;


CREATE OR REPLACE FUNCTION public.admin_clear_user_daily_ai_counters(
    p_user_id UUID
)
RETURNS TABLE (
    today DATE,
    period_start DATE
) AS $$
DECLARE
    v_today DATE := (NOW() AT TIME ZONE 'UTC')::DATE;
BEGIN
    PERFORM 1
    FROM public.users
    WHERE id = p_user_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    period_start := date_trunc('month', v_today)::DATE;

    INSERT INTO public.user_ai_settings (user_id)
    VALUES (p_user_id)
    ON CONFLICT (user_id) DO NOTHING;

    UPDATE public.user_ai_settings
    SET daily_extraction_count = 0,
        daily_generation_count = 0,
        daily_embedding_count = 0,
        last_reset_date = v_today,
        updated_at = NOW()
    WHERE user_id = p_user_id;

    INSERT INTO public.subscription_usage (
        user_id,
        period_start,
        monthly_extractions,
        monthly_generations,
        monthly_embeddings,
        daily_photoshoot_images,
        last_photoshoot_reset
    ) VALUES (
        p_user_id,
        period_start,
        0,
        0,
        0,
        0,
        v_today
    )
    ON CONFLICT (user_id, period_start) DO UPDATE
    SET daily_photoshoot_images = 0,
        last_photoshoot_reset = EXCLUDED.last_photoshoot_reset,
        updated_at = NOW();

    today := v_today;
    RETURN NEXT;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.admin_extend_user_trial(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION public.admin_clear_user_daily_ai_counters(UUID)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.admin_extend_user_trial(UUID, INTEGER)
    TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_clear_user_daily_ai_counters(UUID)
    TO service_role;

COMMIT;
