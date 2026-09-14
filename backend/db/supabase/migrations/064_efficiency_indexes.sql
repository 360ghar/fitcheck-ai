-- FitCheck AI - backend efficiency indexes + item stats RPC
--
-- Read-path optimisation for the hottest queries both clients hit on every
-- app open (see docs/exec-plans/active/backend-efficiency.md). The base
-- schema (001) only has single-column indexes on items/outfits, so the hot
-- list queries (WHERE user_id + is_deleted ORDER BY created_at) filter and
-- sort after a user_id scan; user_streaks has no index at all, so the
-- leaderboard sorts/counts the whole table; calendar month views range-scan
-- on (user_id, start_time) without a composite; the public share lookup
-- filters (outfit_id, visibility) but only (outfit_id, user_id) is indexed.
--
-- Also adds get_item_stats_aggregate so GET /items/stats stops fetching up
-- to 1000 rows to count categories/conditions/colors/value in Python.
--
-- Security: the function is SECURITY DEFINER (runs as the owner,
-- RLS-exempt) with `SET search_path = public`, and EXECUTE is revoked from
-- PUBLIC/anon/authenticated and granted to service_role only — the backend
-- calls it with the service-role client. Same style as migrations 022/024/
-- 026/031/044.
--
-- Idempotent (CREATE INDEX IF NOT EXISTS + CREATE OR REPLACE): safe to
-- re-run in the SQL editor.
--
-- Target: Supabase Postgres (apply on hosted Supabase only).
--
-- NOT wrapped in BEGIN/COMMIT: the indexes are created CONCURRENTLY, which
-- Postgres refuses inside a transaction block. Applying a plain CREATE INDEX
-- on a populated database takes ACCESS EXCLUSIVE locks and blocks all writes
-- to items/outfits/user_streaks/calendar_events/shared_outfits for the build
-- duration; CONCURRENTLY lets reads and writes continue. Note CONCURRENTLY
-- cannot build inside a transaction, so run the file as-is in the SQL editor
-- (still idempotent, still safe to re-run).

-- =============================================================================
-- Composite indexes
-- =============================================================================

-- Wardrobe list/browse: WHERE user_id = ? AND is_deleted = false
-- ORDER BY created_at DESC (default sort), plus the count query.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_items_user_deleted_created
    ON public.items(user_id, is_deleted, created_at DESC);

-- Favorites filter (browse + /recommendations/personalized).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_items_user_favorite
    ON public.items(user_id, is_favorite)
    WHERE is_favorite = TRUE;

-- By-category endpoint + category filters.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_items_user_category
    ON public.items(user_id, category);

-- Outfits list: WHERE user_id = ? ORDER BY created_at DESC (plus count).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_outfits_user_created
    ON public.outfits(user_id, created_at DESC);

-- Leaderboard: ORDER BY current_streak DESC LIMIT 25 + the gt() rank count.
-- user_streaks previously had no index at all (PK only).
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_user_streaks_current
    ON public.user_streaks(current_streak DESC);

-- Calendar month views: WHERE user_id = ? AND start_time BETWEEN ? AND ?
-- ORDER BY start_time.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_calendar_events_user_start
    ON public.calendar_events(user_id, start_time);

-- Public share lookup: WHERE outfit_id = ? AND visibility = 'public'
-- ORDER BY created_at DESC LIMIT 1.
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_shared_outfits_outfit_visibility
    ON public.shared_outfits(outfit_id, visibility, created_at DESC);

-- =============================================================================
-- RPC: get_item_stats_aggregate
-- =============================================================================
-- Replaces the up-to-1000-row Python rollup in GET /items/stats with one
-- index-friendly aggregate. Semantics mirror the old Python loop exactly:
-- only non-deleted rows of the owner; NULL/blank category counts as
-- "other", NULL/blank condition as "clean"; colors are counted per element
-- (lowercased, non-string JSON coerced with ::text like str(c) did);
-- total_value sums price and skips NULL/unparseable values.
CREATE OR REPLACE FUNCTION public.get_item_stats_aggregate(user_uuid UUID)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH scoped AS (
        SELECT
            NULLIF(btrim(COALESCE(category, '')), '') AS cat,
            NULLIF(btrim(COALESCE(condition, '')), '') AS cond,
            price
        FROM public.items
        WHERE user_id = user_uuid
          AND COALESCE(is_deleted, FALSE) = FALSE
    ),
    color_counts AS (
        SELECT lower(
                   CASE
                       WHEN jsonb_typeof(c.value) = 'string' THEN btrim(c.value #>> '{}')
                       ELSE btrim(c.value::text, '"')
                   END
               ) AS color
        FROM public.items i
        -- jsonb_array_elements raises on a scalar/object payload; the column
        -- accepts arbitrary JSONB, so non-array values contribute no colors
        -- instead of failing the whole statistics response.
        CROSS JOIN LATERAL jsonb_array_elements(
            CASE WHEN jsonb_typeof(i.colors) = 'array' THEN i.colors ELSE '[]'::jsonb END
        ) AS c(value)
        WHERE i.user_id = user_uuid
          AND COALESCE(i.is_deleted, FALSE) = FALSE
    )
    SELECT jsonb_build_object(
        'total_items', (SELECT COUNT(*) FROM scoped),
        'items_by_category', COALESCE(
            (SELECT jsonb_object_agg(lower(COALESCE(cat, 'other')), cnt)
             FROM (SELECT COALESCE(cat, 'other') AS cat, COUNT(*) AS cnt
                   FROM scoped GROUP BY 1) s),
            '{}'::jsonb),
        'items_by_condition', COALESCE(
            (SELECT jsonb_object_agg(lower(COALESCE(cond, 'clean')), cnt)
             FROM (SELECT COALESCE(cond, 'clean') AS cond, COUNT(*) AS cnt
                   FROM scoped GROUP BY 1) s),
            '{}'::jsonb),
        'items_by_color', COALESCE(
            (SELECT jsonb_object_agg(color, cnt)
             FROM (SELECT color, COUNT(*) AS cnt FROM color_counts
                   WHERE NULLIF(color, '') IS NOT NULL GROUP BY 1) s),
            '{}'::jsonb),
        'total_value', COALESCE(
            (SELECT SUM(price) FROM scoped
             WHERE price IS NOT NULL),
            0)
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

REVOKE ALL ON FUNCTION public.get_item_stats_aggregate(UUID)
    FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_item_stats_aggregate(UUID) TO service_role;

COMMIT;
