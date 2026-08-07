-- Admin dashboard: top-10 users by row count per entity.
--
-- WHY RPCs: PostgREST select-side aggregates are disabled on this project
-- (db-aggregates-enabled = false) and the legacy bare-`count` select
-- shorthand emits SQL without GROUP BY (Postgres error 42803), so grouped
-- counts for the admin dashboard run through these service-role-only
-- functions instead (see admin_service._top_users_from_rpc).
--
-- Hardened like 026_harden_rpc_privileges.sql: SECURITY DEFINER with an
-- explicit search_path, and EXECUTE revoked from every browser role — only
-- the backend's service-role client may call them.
BEGIN;

CREATE OR REPLACE FUNCTION public.admin_top_users_outfits()
RETURNS TABLE(user_id uuid, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT outfits.user_id, count(*) AS count
    FROM public.outfits
    GROUP BY outfits.user_id
    ORDER BY count(*) DESC, outfits.user_id
    LIMIT 10;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_top_users_items()
RETURNS TABLE(user_id uuid, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT items.user_id, count(*) AS count
    FROM public.items
    GROUP BY items.user_id
    ORDER BY count(*) DESC, items.user_id
    LIMIT 10;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_top_users_referrals()
RETURNS TABLE(user_id uuid, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT referral_redemptions.referrer_user_id AS user_id, count(*) AS count
    FROM public.referral_redemptions
    GROUP BY referral_redemptions.referrer_user_id
    ORDER BY count(*) DESC, referral_redemptions.referrer_user_id
    LIMIT 10;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.admin_top_users_outfits() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_top_users_items() FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_top_users_referrals() FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.admin_top_users_outfits() TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_top_users_items() TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_top_users_referrals() TO service_role;

COMMIT;
