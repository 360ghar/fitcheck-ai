-- FitCheck AI - Support Tickets System
-- This migration adds support for user feedback, bug reports, and feature requests.

BEGIN;

-- =============================================================================
-- TABLE: support_tickets
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,  -- Nullable for anonymous

    -- Ticket content
    category VARCHAR(30) NOT NULL,  -- 'bug_report', 'feature_request', 'general_feedback', 'support_request'
    subject VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,

    -- Attachments (array of storage URLs)
    attachment_urls TEXT[] DEFAULT '{}',

    -- Device/app context
    device_info JSONB,  -- { platform, os_version, device_model, browser, screen_size }
    app_version VARCHAR(50),
    app_platform VARCHAR(20),  -- 'web', 'ios', 'android'

    -- Ticket status workflow
    status VARCHAR(20) NOT NULL DEFAULT 'open',  -- 'open', 'in_progress', 'resolved', 'closed'

    -- Contact info for anonymous submissions
    contact_email VARCHAR(255),

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_support_tickets_user_id ON public.support_tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_support_tickets_category ON public.support_tickets(category);
CREATE INDEX IF NOT EXISTS idx_support_tickets_status ON public.support_tickets(status);
CREATE INDEX IF NOT EXISTS idx_support_tickets_created_at ON public.support_tickets(created_at DESC);

-- =============================================================================
-- RLS Policies
-- =============================================================================

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

-- Users can view their own tickets
DROP POLICY IF EXISTS "Users can view own tickets" ON public.support_tickets;
CREATE POLICY "Users can view own tickets"
    ON public.support_tickets FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own tickets
DROP POLICY IF EXISTS "Users can create tickets" ON public.support_tickets;
CREATE POLICY "Users can create tickets"
    ON public.support_tickets FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Service role can manage all tickets
DROP POLICY IF EXISTS "Service role can manage tickets" ON public.support_tickets;
CREATE POLICY "Service role can manage tickets"
    ON public.support_tickets FOR ALL
    USING (TRUE)
    WITH CHECK (TRUE);

-- =============================================================================
-- Updated_at trigger
-- =============================================================================

CREATE OR REPLACE FUNCTION public.update_support_ticket_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS support_tickets_updated_at ON public.support_tickets;
CREATE TRIGGER support_tickets_updated_at
    BEFORE UPDATE ON public.support_tickets
    FOR EACH ROW EXECUTE FUNCTION public.update_support_ticket_updated_at();

COMMIT;
