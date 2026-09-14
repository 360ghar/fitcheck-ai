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
-- Idempotent (CREATE INDEX IF NOT EXISTS + CREATE OR REPLACE, plus recovery
-- for INVALID leftovers of a failed/canceled concurrent build): safe to
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
-- Data normalization: items.is_deleted
-- =============================================================================
-- The column ships NULLable (BOOLEAN DEFAULT FALSE), but every read in the
-- app filters `is_deleted = FALSE` (PostgREST/SQL equality excludes NULLs),
-- so a legacy NULL row would be permanently invisible. Normalize instead of
-- tolerating NULLs: backfill to the insert default, then make NULL
-- unrepresentable, so all readers (and the RPC below) can use a plain
-- `is_deleted = FALSE` predicate with identical semantics. Guarded by the
-- nullability check so a re-run no-ops once the column is NOT NULL.
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = 'public'
          AND table_name = 'items'
          AND column_name = 'is_deleted'
          AND is_nullable = 'YES'
    ) THEN
        UPDATE public.items SET is_deleted = FALSE WHERE is_deleted IS NULL;
        ALTER TABLE public.items ALTER COLUMN is_deleted SET NOT NULL;
    END IF;
END;
$$;

-- =============================================================================
-- Composite indexes
-- =============================================================================

-- A failed or canceled CONCURRENTLY build leaves an INVALID index with the
-- target name behind; `CREATE INDEX ... IF NOT EXISTS` would then keep
-- skipping that name forever, leaving the hot query without a usable index
-- while still paying the update overhead. Drop any invalid leftover up front
-- so the guarded builds below actually rebuild. Valid indexes are untouched,
-- so re-runs remain no-ops. (Plain DROP INDEX, not CONCURRENTLY: an invalid
-- index has no live content and DO runs as one transaction.)
DO $$
DECLARE
    idx_name text;
BEGIN
    FOREACH idx_name IN ARRAY ARRAY[
        'idx_items_user_deleted_created',
        'idx_items_user_favorite',
        'idx_items_user_category',
        'idx_outfits_user_created',
        'idx_user_streaks_current',
        'idx_calendar_events_user_start',
        'idx_shared_outfits_outfit_visibility'
    ]
    LOOP
        IF EXISTS (
            SELECT 1
            FROM pg_index i
            JOIN pg_class c ON c.oid = i.indexrelid
            JOIN pg_namespace n ON n.oid = c.relnamespace
            WHERE n.nspname = 'public'
              AND c.relname = idx_name
              AND NOT i.indisvalid
        ) THEN
            EXECUTE format('DROP INDEX public.%I', idx_name);
        END IF;
    END LOOP;
END;
$$;

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
-- index-friendly aggregate. Semantics match the app-wide read scope exactly:
-- only rows of the owner with is_deleted = FALSE (the column is NOT NULL
-- after the normalization above, so this predicate needs no NULL handling
-- and cannot drift from the clients' `.eq("is_deleted", false)` reads);
-- NULL/blank category counts as
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
          AND is_deleted = FALSE
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
          AND i.is_deleted = FALSE
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
