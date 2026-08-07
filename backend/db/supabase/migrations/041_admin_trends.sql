-- Admin dashboard time-series RPCs (revenue/trends wave, 2026-08-07).
--
-- WHY RPCs: same reason as 040_admin_dashboard_top_users.sql — PostgREST
-- select-side aggregates are disabled on this project, so grouped daily
-- counts for the admin trends endpoint run through these service-role-only
-- functions instead. Hardened identically: SECURITY DEFINER with an explicit
-- search_path, and EXECUTE revoked from every browser role — only the
-- backend's service-role client may call them.
--
-- Status buckets per table use each table's own terminal vocabulary
-- (extraction 'completed' vs photoshoot 'complete', etc.) — see
-- app/models/{batch,social_import,outfit}.py and migration 023.
--
-- CALL-SITE CONTRACT: the parameter is `p_days`, and
-- `admin_service.dashboard_trends` must call these via
-- `d.rpc(name, {"p_days": days})` — PostgREST matches RPC arguments by
-- parameter name, so a `days` key raises PGRST202 (regression hit on
-- 2026-08-07; test_admin_revenue_trends.py asserts the `p_days` shape).
--
-- AMBIGUITY NOTE: functions with a UNION subquery qualify every outer
-- column with the subquery alias `s` — the RETURNS TABLE out-params are
-- PL/pgSQL variables, so bare names like `day` are ambiguous (Postgres
-- 42702) and the call fails at runtime (hit on 2026-08-07; verify with a
-- direct `SELECT public.admin_trend_jobs(30)` after re-applying).
BEGIN;

CREATE OR REPLACE FUNCTION public.admin_trend_signups(p_days integer DEFAULT 30)
RETURNS TABLE(day date, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT date_trunc('day', users.created_at)::date AS day, count(*) AS count
    FROM public.users
    WHERE users.created_at >= (CURRENT_DATE - p_days + 1)
    GROUP BY 1
    ORDER BY 1;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_trend_jobs(p_days integer DEFAULT 30)
RETURNS TABLE(day date, kind text, total bigint, succeeded bigint, failed bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    -- Qualify with the subquery alias `s`: the RETURNS TABLE out-params
    -- (day/kind/total/...) are PL/pgSQL variables, so a bare `day` in the
    -- outer SELECT is ambiguous (Postgres 42702) and the call fails.
    RETURN QUERY
    SELECT s.day, s.kind, s.total, s.succeeded, s.failed
    FROM (
        SELECT date_trunc('day', created_at)::date AS day,
               'extraction'::text AS kind,
               count(*) AS total,
               count(*) FILTER (WHERE status = 'completed') AS succeeded,
               count(*) FILTER (WHERE status = 'failed') AS failed
        FROM public.extraction_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1
        UNION ALL
        SELECT date_trunc('day', created_at)::date,
               'photoshoot'::text,
               count(*),
               count(*) FILTER (WHERE status = 'complete'),
               count(*) FILTER (WHERE status = 'failed')
        FROM public.photoshoot_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1
        UNION ALL
        SELECT date_trunc('day', created_at)::date,
               'social_import'::text,
               count(*),
               count(*) FILTER (WHERE status = 'completed'),
               count(*) FILTER (WHERE status = 'failed')
        FROM public.social_import_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1
        UNION ALL
        SELECT date_trunc('day', created_at)::date,
               'outfit_generation'::text,
               count(*),
               count(*) FILTER (WHERE status = 'completed'),
               count(*) FILTER (WHERE status = 'failed')
        FROM public.outfit_generations
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1
    ) s
    ORDER BY s.day, s.kind;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_trend_paid(p_days integer DEFAULT 30)
RETURNS TABLE(day date, provider text, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT s.day, s.provider, s.count
    FROM (
        -- Stripe: current_period_start captures renewals + first periods
        -- ("billing events per day"); store rows have no period table, so
        -- IAP uses the subscription row's created_at (first purchase).
        SELECT date_trunc('day', current_period_start)::date AS day,
               'stripe'::text AS provider,
               count(*) AS count
        FROM public.subscriptions
        WHERE billing_provider = 'stripe'
          AND plan_type <> 'free'
          AND status = 'active'
          AND current_period_start >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1
        UNION ALL
        SELECT date_trunc('day', created_at)::date,
               billing_provider,
               count(*)
        FROM public.subscriptions
        WHERE billing_provider IN ('apple', 'google')
          AND plan_type <> 'free'
          AND status = 'active'
          AND created_at >= (CURRENT_DATE - p_days + 1)
        GROUP BY 1, 2
    ) s
    ORDER BY s.day, s.provider;
END;
$$;

CREATE OR REPLACE FUNCTION public.admin_trend_active(p_days integer DEFAULT 30)
RETURNS TABLE(day date, count bigint)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    -- "AI-active users": distinct users with at least one durable job that
    -- day. users.last_login_at only stores the most recent login, so it
    -- cannot produce a daily series; job tables are the honest proxy. All
    -- four durable job tables count, matching the jobs series (extraction
    -- included: extraction-only days are still AI activity).
    RETURN QUERY
    SELECT s.day, count(DISTINCT s.user_id) AS count
    FROM (
        SELECT user_id, date_trunc('day', created_at)::date AS day
        FROM public.extraction_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        UNION ALL
        SELECT user_id, date_trunc('day', created_at)::date
        FROM public.photoshoot_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        UNION ALL
        SELECT user_id, date_trunc('day', created_at)::date
        FROM public.social_import_jobs
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
        UNION ALL
        SELECT user_id, date_trunc('day', created_at)::date
        FROM public.outfit_generations
        WHERE created_at >= (CURRENT_DATE - p_days + 1)
    ) s
    GROUP BY s.day
    ORDER BY s.day;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.admin_trend_signups(integer) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_trend_jobs(integer) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_trend_paid(integer) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.admin_trend_active(integer) FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.admin_trend_signups(integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_trend_jobs(integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_trend_paid(integer) TO service_role;
GRANT EXECUTE ON FUNCTION public.admin_trend_active(integer) TO service_role;

COMMIT;
