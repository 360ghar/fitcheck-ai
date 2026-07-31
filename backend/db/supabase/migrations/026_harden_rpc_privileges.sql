-- Backend RPCs are invoked with the Supabase service-role client. These
-- functions accept user IDs and quota/credit values, so browser roles must
-- not be able to call them directly.
BEGIN;

REVOKE EXECUTE ON FUNCTION public.reserve_usage(UUID, DATE, TEXT, INTEGER, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.redeem_referral_atomic(UUID, TEXT, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.reserve_ai_usage(UUID, TEXT, INTEGER, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.release_ai_usage(UUID, TEXT, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.reserve_daily_photoshoot_usage(UUID, DATE, INTEGER, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.increment_usage(UUID, DATE, TEXT, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.increment_referral_times_used(UUID, INTEGER)
    FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.get_billing_period_start(UUID)
    FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.reserve_usage(UUID, DATE, TEXT, INTEGER, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.apply_referral_credit_atomic(UUID, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.redeem_referral_atomic(UUID, TEXT, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.reserve_ai_usage(UUID, TEXT, INTEGER, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.release_ai_usage(UUID, TEXT, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.reserve_daily_photoshoot_usage(UUID, DATE, INTEGER, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.increment_usage(UUID, DATE, TEXT, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.increment_referral_times_used(UUID, INTEGER) TO service_role;
GRANT EXECUTE ON FUNCTION public.get_billing_period_start(UUID) TO service_role;

COMMIT;
