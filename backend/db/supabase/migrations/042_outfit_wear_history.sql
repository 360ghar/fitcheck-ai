-- FitCheck AI - Outfit wear history
--
-- The wear feature (``POST /outfits/{id}/wear`` + ``GET /outfits/{id}/wear-history``,
-- ``backend/app/api/v1/outfits.py``) has written and read this table since the
-- 2026-08-03 wear wave, but no migration ever created it: every write failed
-- with "relation does not exist" (swallowed by the endpoint's try/except and
-- logged as a warning) and every read returned an empty list, so the feature
-- was silently dead and wear history was never recorded. This migration lands
-- the table the code already expects.
--
-- Columns mirror the API's insert payload exactly (``id`` is a client-generated
-- uuid4), plus a nullable ``notes`` column the mobile ``WearHistoryEntry`` model
-- declares.
--
-- Idempotent (CREATE TABLE IF NOT EXISTS + DROP POLICY IF EXISTS guards):
-- safe to re-run in the SQL editor.
--
-- Target: Supabase Postgres

BEGIN;

CREATE TABLE IF NOT EXISTS public.outfit_wear_history (
    id UUID PRIMARY KEY,
    outfit_id UUID NOT NULL REFERENCES public.outfits(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    worn_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- The read path filters by outfit and orders newest-first (limit 100).
CREATE INDEX IF NOT EXISTS idx_outfit_wear_history_outfit_worn_at
    ON public.outfit_wear_history(outfit_id, worn_at DESC);

ALTER TABLE public.outfit_wear_history ENABLE ROW LEVEL SECURITY;

-- Same user-owned policy set as outfits (001): browser roles may only touch
-- their own rows; the backend reads/writes through the service client, which
-- is RLS-exempt.
DROP POLICY IF EXISTS "Users can read own wear history" ON public.outfit_wear_history;
CREATE POLICY "Users can read own wear history"
    ON public.outfit_wear_history FOR SELECT
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own wear history" ON public.outfit_wear_history;
CREATE POLICY "Users can insert own wear history"
    ON public.outfit_wear_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own wear history" ON public.outfit_wear_history;
CREATE POLICY "Users can update own wear history"
    ON public.outfit_wear_history FOR UPDATE
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own wear history" ON public.outfit_wear_history;
CREATE POLICY "Users can delete own wear history"
    ON public.outfit_wear_history FOR DELETE
    USING (auth.uid() = user_id);

COMMENT ON TABLE public.outfit_wear_history IS
    'Per-outfit wear log written by POST /outfits/{id}/wear and read by GET /outfits/{id}/wear-history (migration 042).';
COMMENT ON COLUMN public.outfit_wear_history.notes IS
    'Optional context for a wear entry (declared by the mobile WearHistoryEntry model; not yet written by the API).';

COMMIT;
