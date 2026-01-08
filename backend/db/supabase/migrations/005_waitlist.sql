    -- FitCheck AI - Waitlist Schema
    -- Migration: 005_waitlist.sql

    BEGIN;

    -- =============================================================================
    -- WAITLIST TABLE
    -- =============================================================================

    -- Waitlist entries (public signups, no auth required)
    CREATE TABLE IF NOT EXISTS public.waitlist (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) NOT NULL,
        full_name VARCHAR(255),
        source VARCHAR(100) DEFAULT 'landing_page',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        -- Prevent duplicate email signups
        CONSTRAINT waitlist_email_unique UNIQUE (email)
    );

    -- Index for querying by email and creation date
    CREATE INDEX IF NOT EXISTS idx_waitlist_email ON public.waitlist(email);
    CREATE INDEX IF NOT EXISTS idx_waitlist_created_at ON public.waitlist(created_at DESC);

    -- =============================================================================
    -- ROW LEVEL SECURITY
    -- =============================================================================

    -- Enable RLS but allow public inserts (no auth required for signups)
    ALTER TABLE public.waitlist ENABLE ROW LEVEL SECURITY;

    -- Policy: Anyone can insert into waitlist (public endpoint)
    DROP POLICY IF EXISTS "Anyone can join waitlist" ON public.waitlist;
    CREATE POLICY "Anyone can join waitlist"
        ON public.waitlist FOR INSERT
        WITH CHECK (true);

    -- Policy: Only service role can read/manage waitlist entries (admin dashboard)
    DROP POLICY IF EXISTS "Service role can manage waitlist" ON public.waitlist;
    CREATE POLICY "Service role can manage waitlist"
        ON public.waitlist FOR ALL
        USING (auth.role() = 'service_role');

    -- =============================================================================
    -- GRANTS
    -- =============================================================================

    GRANT INSERT ON public.waitlist TO anon, authenticated;
    GRANT ALL ON public.waitlist TO service_role;

    COMMIT;
